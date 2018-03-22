﻿(*
   Copyright 2008-2016 Nikhil Swamy and Microsoft Research

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*)
#light "off"

//Top-level invocations into the universal type-checker FStar.TypeChecker
module FStar.Universal
open FStar.ST
open FStar.Exn
open FStar.All
open FStar
open FStar.Errors
open FStar.Util
open FStar.Getopt
open FStar.Ident
open FStar.Syntax.Syntax
open FStar.TypeChecker.Common
open FStar.TypeChecker.Env
open FStar.Dependencies

(* Module abbreviations for the universal type-checker  *)
module DsEnv   = FStar.Syntax.DsEnv
module TcEnv   = FStar.TypeChecker.Env
module Syntax  = FStar.Syntax.Syntax
module Util    = FStar.Syntax.Util
module Desugar = FStar.ToSyntax.ToSyntax
module SMT     = FStar.SMTEncoding.Solver
module Const   = FStar.Parser.Const
module Pars    = FStar.Parser.ParseIt
module Tc      = FStar.TypeChecker.Tc
module TcTerm  = FStar.TypeChecker.TcTerm
module BU      = FStar.Util
module Dep     = FStar.Parser.Dep

(* we write this version number to the cache files, and detect when loading the cache that the version number is same *)
let cache_version_number = 1

let module_or_interface_name m = m.is_interface, m.name

let with_tcenv (env:TcEnv.env) (f:DsEnv.withenv<'a>) =
    let a, dsenv = f env.dsenv in
    a, ({ env with dsenv=dsenv })

(***********************************************************************)
(* Parse and desugar a file                                            *)
(***********************************************************************)
let parse (env:TcEnv.env) (pre_fn: option<string>) (fn:string)
  : Syntax.modul
  * TcEnv.env =
  let ast, _ = Parser.Driver.parse_file fn in
  let ast, env = match pre_fn with
    | None ->
        ast, env
    | Some pre_fn ->
        let pre_ast, _ = Parser.Driver.parse_file pre_fn in
        match pre_ast, ast with
        | Parser.AST.Interface (lid1, decls1, _), Parser.AST.Module (lid2, decls2)
          when Ident.lid_equals lid1 lid2 ->
          let _, env = with_tcenv env <| FStar.ToSyntax.Interleave.initialize_interface lid1 decls1 in
          with_tcenv env <| FStar.ToSyntax.Interleave.interleave_module ast true
        | _ ->
            Errors.raise_err (Errors.Fatal_PreModuleMismatch, "mismatch between pre-module and module\n")
  in
  with_tcenv env <| Desugar.ast_modul_to_modul ast

(***********************************************************************)
(* Initialize a clean environment                                      *)
(***********************************************************************)
let init_env deps : TcEnv.env =
  let solver =
    if Options.lax()
    then SMT.dummy
    else {SMT.solver with preprocess=FStar.Tactics.Interpreter.preprocess} in
  let env =
      TcEnv.initial_env
        deps
        TcTerm.tc_term
        TcTerm.type_of_tot_term
        TcTerm.universe_of
        TcTerm.check_type_of_well_typed_term
        solver
        Const.prims_lid
  in
  (* Set up some tactics callbacks *)
  let env = { env with synth_hook = FStar.Tactics.Interpreter.synthesize } in
  let env = { env with splice = FStar.Tactics.Interpreter.splice} in
  let env = { env with is_native_tactic = FStar.Tactics.Native.is_native_tactic } in
  env.solver.init env;
  env

(***********************************************************************)
(* Interactive mode: checking a fragment of a code                     *)
(***********************************************************************)
let tc_one_fragment curmod (env:TcEnv.env) frag =
  let acceptable_mod_name modul =
    (* Interface is sent as the first chunk, so we must allow repeating the same module. *)
    Parser.Dep.lowercase_module_name (List.hd (Options.file_list ())) =
    String.lowercase (string_of_lid modul.name) in

  let range_of_first_mod_decl modul =
    match modul with
    | Parser.AST.Module (_, { Parser.AST.drange = d } :: _)
    | Parser.AST.Interface (_, { Parser.AST.drange = d } :: _, _) -> d
    | _ -> Range.dummyRange in

  match Parser.Driver.parse_fragment frag with
  | Parser.Driver.Empty
  | Parser.Driver.Decls [] ->
    (curmod, env)

  | Parser.Driver.Modul ast_modul ->
    (* It may seem surprising that this function, whose name indicates that
       it type-checks a fragment, can actually parse an entire module.
       Actually, this is an abuse, and just means that we're type-checking the
       first chunk. *)
    let ast_modul, env =
      with_tcenv env <| FStar.ToSyntax.Interleave.interleave_module ast_modul false in
    let modul, env =
      with_tcenv env <| Desugar.partial_ast_modul_to_modul curmod ast_modul in
    if not (acceptable_mod_name modul) then
    begin
       let msg : string =
           BU.format1 "Interactive mode only supports a single module at the top-level. Expected module %s"
                       (Parser.Dep.module_name_of_file (List.hd (Options.file_list ())))
       in
       Errors.raise_error (Errors.Fatal_NonSingletonTopLevelModule, msg)
                             (range_of_first_mod_decl ast_modul)
    end;
    let modul, _, env = if DsEnv.syntax_only env.dsenv then (modul, [], env)
                        else Tc.tc_partial_modul env modul in
    (Some modul, env)
  | Parser.Driver.Decls ast_decls ->
    match curmod with
    | None ->
      let { Parser.AST.drange = rng } = List.hd ast_decls in
      Errors.raise_error (Errors.Fatal_ModuleFirstStatement, "First statement must be a module declaration") rng
    | Some modul ->
      let env, ast_decls_l =
          BU.fold_map
              (fun env a_decl ->
                  let decls, env =
                      with_tcenv env <|
                      FStar.ToSyntax.Interleave.prefix_with_interface_decls a_decl
                  in
                  env, decls)
              env
              ast_decls in
      let sigelts, env = with_tcenv env <| Desugar.decls_to_sigelts (List.flatten ast_decls_l) in
      let modul, _, env  = if DsEnv.syntax_only env.dsenv then (modul, [], env)
                           else Tc.tc_more_partial_modul env modul sigelts in
      (Some modul, env)

let load_interface_decls env interface_file_name : FStar.TypeChecker.Env.env =
  let r = Pars.parse (Pars.Filename interface_file_name) in
  match r with
  | Pars.ASTFragment (Inl (FStar.Parser.AST.Interface(l, decls, _)), _) ->
    snd (with_tcenv env <| FStar.ToSyntax.Interleave.initialize_interface l decls)
  | Pars.ASTFragment _ ->
    Errors.raise_err (FStar.Errors.Fatal_ParseErrors, (BU.format1 "Unexpected result from parsing %s; expected a single interface"
                             interface_file_name))
  | Pars.ParseError (err, msg, rng) ->
    raise (FStar.Errors.Error(err, msg, rng))
  | Pars.Term _ ->
     failwith "Impossible: parsing a Toplevel always results in an ASTFragment"


(***********************************************************************)
(* Loading and storing cache files                                     *)
(***********************************************************************)
let load_module_from_cache
    : env -> string -> option<(Syntax.modul * option<Syntax.modul> * DsEnv.module_inclusion_info)> =
    let some_cache_invalid = BU.mk_ref None in
    let invalidate_cache fn = some_cache_invalid := Some fn in
    fun env fn ->
        let cache_file = Dep.cache_file_name fn in
        let fail tag =
             invalidate_cache();
             FStar.Errors.log_issue
                (Range.mk_range fn (Range.mk_pos 0 0) (Range.mk_pos 0 0))
                (Errors.Warning_CachedFile, BU.format3 "%s cache file %s; will recheck %s and all subsequent files" tag cache_file fn);
             None
        in
        match !some_cache_invalid with
        | Some _ -> None
        | _ ->
          if BU.file_exists cache_file then
            match BU.load_value_from_file cache_file with
            | None ->
              fail "Corrupt"
            | Some (vnum, digest, tcmod, tcmod_iface_opt, mii) ->
              if vnum <> cache_version_number then fail "Stale, because inconsistent cache version"
              else
                match FStar.Parser.Dep.hash_dependences env.dep_graph fn with
                | Some digest' ->
                  if digest=digest'
                  then Some (tcmod, tcmod_iface_opt, mii)
                  else begin
                    if Options.debug_any()
                    then begin
                      BU.print4 "Expected (%s) hashes:\n%s\n\nGot (%s) hashes:\n\t%s\n"
                                (BU.string_of_int (List.length digest'))
                                (FStar.Parser.Dep.print_digest digest')
                                (BU.string_of_int (List.length digest))
                                (FStar.Parser.Dep.print_digest digest);
                      if List.length digest = List.length digest'
                      then List.iter2
                           (fun (x,y) (x', y') ->
                            if x<>x' || y<>y'
                            then BU.print2 "Differ at: Expected %s\n Got %s\n"
                                           (FStar.Parser.Dep.print_digest [(x,y)])
                                           (FStar.Parser.Dep.print_digest [(x',y')]))
                           digest
                           digest'
                    end;
                    fail "Stale"
                  end
                | _ ->
                  fail "Stale"
          else (invalidate_cache (); None)

let store_module_to_cache env fn (m:modul) (modul_iface_opt:option<modul>) (mii:DsEnv.module_inclusion_info) =
    let cache_file = FStar.Parser.Dep.cache_file_name fn in
    let digest = FStar.Parser.Dep.hash_dependences env.dep_graph fn in
    match digest with
    | Some hashes ->
      //cache_version_number should always be the first field here
      BU.save_value_to_file cache_file (cache_version_number, hashes, m, modul_iface_opt, mii)
    | _ ->
      FStar.Errors.log_issue
        (FStar.Range.mk_range fn (FStar.Range.mk_pos 0 0)
                                 (FStar.Range.mk_pos 0 0))
        (Errors.Warning_FileNotWritten, BU.format1 "%s was not written, since some of its dependences were not also checked"
                    cache_file)

(***********************************************************************)
(* Batch mode: checking a file                                         *)
(***********************************************************************)
let tc_one_file env pre_fn fn : (Syntax.modul * int) //checked module and its elapsed checking time
                              * TcEnv.env =
  Syntax.reset_gensym();
  let tc_source_file () =
      let fmod, env = parse env pre_fn fn in
      let check_mod () =
          let (tcmod, tcmod_iface_opt, env), time =
            FStar.Util.record_time (fun () -> Tc.check_module env fmod) in
          (tcmod, time), tcmod_iface_opt, env
      in
      let tcmod, tcmod_iface_opt, env =
        if (Options.should_verify fmod.name.str //if we're verifying this module
            && (FStar.Options.record_hints() //and if we're recording or using hints
                || FStar.Options.use_hints()))
        then SMT.with_hints_db (Pars.find_file fn) check_mod
        else check_mod () //don't add a hints file for modules that are not actually verified
      in
      let mii = FStar.Syntax.DsEnv.inclusion_info env.dsenv (fst tcmod).name in
      tcmod, tcmod_iface_opt, mii, env
  in
  match load_module_from_cache env fn with
       | None ->
         let tcmod, tcmod_iface_opt, mii, env = tc_source_file () in
         if FStar.Errors.get_err_count() = 0
         && Options.cache_checked_modules ()
         && (Options.lax()  //we'll write out a .checked.lax file
             || Options.should_verify (fst tcmod).name.str) //we'll write out a .checked file
         //but we will not write out a .checked file for an unverified dependence
         //of some file that should be checked
         then store_module_to_cache env fn (fst tcmod) tcmod_iface_opt mii;
         tcmod, env
       | Some (tcmod, tcmod_iface_opt, mii) ->
         let tcmod =
           if tcmod.is_interface then tcmod
           else
             if Options.use_extracted_interfaces () then
               if tcmod_iface_opt = None then
                 Errors.raise_error (Errors.Fatal_ModuleNotFound, "use_extracted_interfaces option is set but could not find it in the cache for: " ^ tcmod.name.str)
                                    Range.dummyRange
               else tcmod_iface_opt |> must
             else tcmod
         in
         let _, env =
            with_tcenv env <|
            FStar.ToSyntax.ToSyntax.add_modul_to_env tcmod mii (FStar.TypeChecker.Normalize.erase_universes env)
         in
         let env = FStar.TypeChecker.Tc.load_checked_module env tcmod in
         (tcmod,0), env

(***********************************************************************)
(* Batch mode: composing many files in the presence of pre-modules     *)
(***********************************************************************)
let needs_interleaving intf impl =
  let m1 = Parser.Dep.lowercase_module_name intf in
  let m2 = Parser.Dep.lowercase_module_name impl in
  m1 = m2 &&
  List.mem (FStar.Util.get_file_extension intf) ["fsti"; "fsi"] &&
  List.mem (FStar.Util.get_file_extension impl) ["fst"; "fs"]

let pop_context env msg = Tc.pop_context env msg |> ignore

let push_context env msg = Tc.push_context env msg

let tc_one_file_from_remaining (remaining:list<string>) (env:TcEnv.env) =
  let remaining, (nmods, env) =
    match remaining with
        | intf :: impl :: remaining when needs_interleaving intf impl ->
          let m, env = tc_one_file env (Some intf) impl in
          remaining, ([m], env)
        | intf_or_impl :: remaining ->
          let m, env = tc_one_file env None intf_or_impl in
          remaining, ([m], env)
        | [] -> [], ([], env)
  in
  remaining, nmods, env

let rec tc_fold_interleave (acc:list<(modul * int)> * TcEnv.env) (remaining:list<string>) =
  match remaining with
    | [] -> acc
    | _  ->
      let mods, env = acc in
      let remaining, nmods, env = tc_one_file_from_remaining remaining env in
      tc_fold_interleave (mods@nmods, env) remaining

(***********************************************************************)
(* Batch mode: checking many files                                     *)
(***********************************************************************)
let batch_mode_tc filenames dep_graph =
  if Options.debug_any () then begin
    FStar.Util.print_endline "Auto-deps kicked in; here's some info.";
    FStar.Util.print1 "Here's the list of filenames we will process: %s\n"
      (String.concat " " filenames);
    FStar.Util.print1 "Here's the list of modules we will verify: %s\n"
      (String.concat " " (filenames |> List.filter Options.should_verify_file))
  end;
  let env = init_env dep_graph in
  let all_mods, env = tc_fold_interleave ([], env) filenames in
  if Options.interactive()
  && FStar.Errors.get_err_count () = 0
  then env.solver.refresh()
  else env.solver.finish();
  all_mods, env
