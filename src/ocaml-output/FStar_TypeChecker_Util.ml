open Prims
type lcomp_with_binder =
  (FStar_Syntax_Syntax.bv FStar_Pervasives_Native.option,FStar_Syntax_Syntax.lcomp)
    FStar_Pervasives_Native.tuple2[@@deriving show]
let (report :
  FStar_TypeChecker_Env.env -> Prims.string Prims.list -> Prims.unit) =
  fun env  ->
    fun errs  ->
      let uu____17 = FStar_TypeChecker_Env.get_range env  in
      let uu____18 = FStar_TypeChecker_Err.failed_to_prove_specification errs
         in
      FStar_Errors.log_issue uu____17 uu____18
  
let (is_type : FStar_Syntax_Syntax.term -> Prims.bool) =
  fun t  ->
    let uu____26 =
      let uu____27 = FStar_Syntax_Subst.compress t  in
      uu____27.FStar_Syntax_Syntax.n  in
    match uu____26 with
    | FStar_Syntax_Syntax.Tm_type uu____30 -> true
    | uu____31 -> false
  
let (t_binders :
  FStar_TypeChecker_Env.env ->
    (FStar_Syntax_Syntax.bv,FStar_Syntax_Syntax.aqual)
      FStar_Pervasives_Native.tuple2 Prims.list)
  =
  fun env  ->
    let uu____41 = FStar_TypeChecker_Env.all_binders env  in
    FStar_All.pipe_right uu____41
      (FStar_List.filter
         (fun uu____55  ->
            match uu____55 with
            | (x,uu____61) -> is_type x.FStar_Syntax_Syntax.sort))
  
let (new_uvar_aux :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.typ ->
      (FStar_Syntax_Syntax.typ,FStar_Syntax_Syntax.typ)
        FStar_Pervasives_Native.tuple2)
  =
  fun env  ->
    fun k  ->
      let bs =
        let uu____73 =
          (FStar_Options.full_context_dependency ()) ||
            (let uu____75 = FStar_TypeChecker_Env.current_module env  in
             FStar_Ident.lid_equals FStar_Parser_Const.prims_lid uu____75)
           in
        if uu____73
        then FStar_TypeChecker_Env.all_binders env
        else t_binders env  in
      let uu____77 = FStar_TypeChecker_Env.get_range env  in
      FStar_TypeChecker_Rel.new_uvar uu____77 bs k
  
let (new_uvar :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.typ -> FStar_Syntax_Syntax.typ)
  =
  fun env  ->
    fun k  ->
      let uu____84 = new_uvar_aux env k  in
      FStar_Pervasives_Native.fst uu____84
  
let (as_uvar : FStar_Syntax_Syntax.typ -> FStar_Syntax_Syntax.uvar) =
  fun uu___77_93  ->
    match uu___77_93 with
    | { FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_uvar (uv,uu____95);
        FStar_Syntax_Syntax.pos = uu____96;
        FStar_Syntax_Syntax.vars = uu____97;_} -> uv
    | uu____124 -> failwith "Impossible"
  
let (new_implicit_var :
  Prims.string ->
    FStar_Range.range ->
      FStar_TypeChecker_Env.env ->
        FStar_Syntax_Syntax.typ ->
          (FStar_Syntax_Syntax.term,(FStar_Syntax_Syntax.uvar,FStar_Range.range)
                                      FStar_Pervasives_Native.tuple2
                                      Prims.list,FStar_TypeChecker_Env.guard_t)
            FStar_Pervasives_Native.tuple3)
  =
  fun reason  ->
    fun r  ->
      fun env  ->
        fun k  ->
          let uu____149 =
            FStar_Syntax_Util.destruct k FStar_Parser_Const.range_of_lid  in
          match uu____149 with
          | FStar_Pervasives_Native.Some (uu____172::(tm,uu____174)::[]) ->
              let t =
                FStar_Syntax_Syntax.mk
                  (FStar_Syntax_Syntax.Tm_constant
                     (FStar_Const.Const_range (tm.FStar_Syntax_Syntax.pos)))
                  FStar_Pervasives_Native.None tm.FStar_Syntax_Syntax.pos
                 in
              (t, [], FStar_TypeChecker_Rel.trivial_guard)
          | uu____226 ->
              let uu____237 = new_uvar_aux env k  in
              (match uu____237 with
               | (t,u) ->
                   let g =
                     let uu___96_257 = FStar_TypeChecker_Rel.trivial_guard
                        in
                     let uu____258 =
                       let uu____273 =
                         let uu____286 = as_uvar u  in
                         (reason, env, uu____286, t, k, r)  in
                       [uu____273]  in
                     {
                       FStar_TypeChecker_Env.guard_f =
                         (uu___96_257.FStar_TypeChecker_Env.guard_f);
                       FStar_TypeChecker_Env.deferred =
                         (uu___96_257.FStar_TypeChecker_Env.deferred);
                       FStar_TypeChecker_Env.univ_ineqs =
                         (uu___96_257.FStar_TypeChecker_Env.univ_ineqs);
                       FStar_TypeChecker_Env.implicits = uu____258
                     }  in
                   let uu____311 =
                     let uu____318 =
                       let uu____323 = as_uvar u  in (uu____323, r)  in
                     [uu____318]  in
                   (t, uu____311, g))
  
let (check_uvars :
  FStar_Range.range -> FStar_Syntax_Syntax.typ -> Prims.unit) =
  fun r  ->
    fun t  ->
      let uvs = FStar_Syntax_Free.uvars t  in
      let uu____351 =
        let uu____352 = FStar_Util.set_is_empty uvs  in
        Prims.op_Negation uu____352  in
      if uu____351
      then
        let us =
          let uu____358 =
            let uu____361 = FStar_Util.set_elements uvs  in
            FStar_List.map
              (fun uu____379  ->
                 match uu____379 with
                 | (x,uu____385) -> FStar_Syntax_Print.uvar_to_string x)
              uu____361
             in
          FStar_All.pipe_right uu____358 (FStar_String.concat ", ")  in
        (FStar_Options.push ();
         FStar_Options.set_option "hide_uvar_nums" (FStar_Options.Bool false);
         FStar_Options.set_option "print_implicits" (FStar_Options.Bool true);
         (let uu____392 =
            let uu____397 =
              let uu____398 = FStar_Syntax_Print.term_to_string t  in
              FStar_Util.format2
                "Unconstrained unification variables %s in type signature %s; please add an annotation"
                us uu____398
               in
            (FStar_Errors.Error_UncontrainedUnificationVar, uu____397)  in
          FStar_Errors.log_issue r uu____392);
         FStar_Options.pop ())
      else ()
  
let (extract_let_rec_annotation :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.letbinding ->
      (FStar_Syntax_Syntax.univ_names,FStar_Syntax_Syntax.typ,Prims.bool)
        FStar_Pervasives_Native.tuple3)
  =
  fun env  ->
    fun uu____411  ->
      match uu____411 with
      | { FStar_Syntax_Syntax.lbname = lbname;
          FStar_Syntax_Syntax.lbunivs = univ_vars1;
          FStar_Syntax_Syntax.lbtyp = t;
          FStar_Syntax_Syntax.lbeff = uu____421;
          FStar_Syntax_Syntax.lbdef = e;
          FStar_Syntax_Syntax.lbattrs = uu____423;
          FStar_Syntax_Syntax.lbpos = uu____424;_} ->
          let rng = FStar_Syntax_Syntax.range_of_lbname lbname  in
          let t1 = FStar_Syntax_Subst.compress t  in
          (match t1.FStar_Syntax_Syntax.n with
           | FStar_Syntax_Syntax.Tm_unknown  ->
               let uu____457 = FStar_Syntax_Subst.open_univ_vars univ_vars1 e
                  in
               (match uu____457 with
                | (univ_vars2,e1) ->
                    let env1 =
                      FStar_TypeChecker_Env.push_univ_vars env univ_vars2  in
                    let r = FStar_TypeChecker_Env.get_range env1  in
                    let mk_binder1 scope a =
                      let uu____485 =
                        let uu____486 =
                          FStar_Syntax_Subst.compress
                            a.FStar_Syntax_Syntax.sort
                           in
                        uu____486.FStar_Syntax_Syntax.n  in
                      match uu____485 with
                      | FStar_Syntax_Syntax.Tm_unknown  ->
                          let uu____493 = FStar_Syntax_Util.type_u ()  in
                          (match uu____493 with
                           | (k,uu____503) ->
                               let t2 =
                                 let uu____505 =
                                   FStar_TypeChecker_Rel.new_uvar
                                     e1.FStar_Syntax_Syntax.pos scope k
                                    in
                                 FStar_All.pipe_right uu____505
                                   FStar_Pervasives_Native.fst
                                  in
                               ((let uu___97_515 = a  in
                                 {
                                   FStar_Syntax_Syntax.ppname =
                                     (uu___97_515.FStar_Syntax_Syntax.ppname);
                                   FStar_Syntax_Syntax.index =
                                     (uu___97_515.FStar_Syntax_Syntax.index);
                                   FStar_Syntax_Syntax.sort = t2
                                 }), false))
                      | uu____516 -> (a, true)  in
                    let rec aux must_check_ty vars e2 =
                      let e3 = FStar_Syntax_Subst.compress e2  in
                      match e3.FStar_Syntax_Syntax.n with
                      | FStar_Syntax_Syntax.Tm_meta (e4,uu____553) ->
                          aux must_check_ty vars e4
                      | FStar_Syntax_Syntax.Tm_ascribed (e4,t2,uu____560) ->
                          ((FStar_Pervasives_Native.fst t2), true)
                      | FStar_Syntax_Syntax.Tm_abs (bs,body,uu____623) ->
                          let uu____644 =
                            FStar_All.pipe_right bs
                              (FStar_List.fold_left
                                 (fun uu____704  ->
                                    fun uu____705  ->
                                      match (uu____704, uu____705) with
                                      | ((scope,bs1,must_check_ty1),(a,imp))
                                          ->
                                          let uu____783 =
                                            if must_check_ty1
                                            then (a, true)
                                            else mk_binder1 scope a  in
                                          (match uu____783 with
                                           | (tb,must_check_ty2) ->
                                               let b = (tb, imp)  in
                                               let bs2 =
                                                 FStar_List.append bs1 [b]
                                                  in
                                               let scope1 =
                                                 FStar_List.append scope [b]
                                                  in
                                               (scope1, bs2, must_check_ty2)))
                                 (vars, [], must_check_ty))
                             in
                          (match uu____644 with
                           | (scope,bs1,must_check_ty1) ->
                               let uu____895 = aux must_check_ty1 scope body
                                  in
                               (match uu____895 with
                                | (res,must_check_ty2) ->
                                    let c =
                                      match res with
                                      | FStar_Util.Inl t2 ->
                                          let uu____924 =
                                            FStar_Options.ml_ish ()  in
                                          if uu____924
                                          then FStar_Syntax_Util.ml_comp t2 r
                                          else
                                            FStar_Syntax_Syntax.mk_Total t2
                                      | FStar_Util.Inr c -> c  in
                                    let t2 = FStar_Syntax_Util.arrow bs1 c
                                       in
                                    ((let uu____931 =
                                        FStar_TypeChecker_Env.debug env1
                                          FStar_Options.High
                                         in
                                      if uu____931
                                      then
                                        let uu____932 =
                                          FStar_Range.string_of_range r  in
                                        let uu____933 =
                                          FStar_Syntax_Print.term_to_string
                                            t2
                                           in
                                        let uu____934 =
                                          FStar_Util.string_of_bool
                                            must_check_ty2
                                           in
                                        FStar_Util.print3
                                          "(%s) Using type %s .... must check = %s\n"
                                          uu____932 uu____933 uu____934
                                      else ());
                                     ((FStar_Util.Inl t2), must_check_ty2))))
                      | uu____944 ->
                          if must_check_ty
                          then
                            ((FStar_Util.Inl FStar_Syntax_Syntax.tun), true)
                          else
                            (let uu____958 =
                               let uu____963 =
                                 let uu____964 =
                                   FStar_TypeChecker_Rel.new_uvar r vars
                                     FStar_Syntax_Util.ktype0
                                    in
                                 FStar_All.pipe_right uu____964
                                   FStar_Pervasives_Native.fst
                                  in
                               FStar_Util.Inl uu____963  in
                             (uu____958, false))
                       in
                    let uu____977 =
                      let uu____986 = t_binders env1  in
                      aux false uu____986 e1  in
                    (match uu____977 with
                     | (t2,b) ->
                         let t3 =
                           match t2 with
                           | FStar_Util.Inr c ->
                               let uu____1011 =
                                 FStar_Syntax_Util.is_tot_or_gtot_comp c  in
                               if uu____1011
                               then FStar_Syntax_Util.comp_result c
                               else
                                 (let uu____1015 =
                                    let uu____1020 =
                                      let uu____1021 =
                                        FStar_Syntax_Print.comp_to_string c
                                         in
                                      FStar_Util.format1
                                        "Expected a 'let rec' to be annotated with a value type; got a computation type %s"
                                        uu____1021
                                       in
                                    (FStar_Errors.Fatal_UnexpectedComputationTypeForLetRec,
                                      uu____1020)
                                     in
                                  FStar_Errors.raise_error uu____1015 rng)
                           | FStar_Util.Inl t3 -> t3  in
                         (univ_vars2, t3, b)))
           | uu____1027 ->
               let uu____1028 =
                 FStar_Syntax_Subst.open_univ_vars univ_vars1 t1  in
               (match uu____1028 with
                | (univ_vars2,t2) -> (univ_vars2, t2, false)))
  
let (pat_as_exp :
  Prims.bool ->
    FStar_TypeChecker_Env.env ->
      FStar_Syntax_Syntax.pat ->
        (FStar_TypeChecker_Env.env ->
           FStar_Syntax_Syntax.term ->
             (FStar_Syntax_Syntax.term,FStar_TypeChecker_Env.guard_t)
               FStar_Pervasives_Native.tuple2)
          ->
          (FStar_Syntax_Syntax.bv Prims.list,FStar_Syntax_Syntax.term,
            FStar_TypeChecker_Env.guard_t,FStar_Syntax_Syntax.pat)
            FStar_Pervasives_Native.tuple4)
  =
  fun allow_implicits  ->
    fun env  ->
      fun p  ->
        fun tc_annot  ->
          let check_bv env1 x =
            let uu____1108 =
              let uu____1113 =
                FStar_Syntax_Subst.compress x.FStar_Syntax_Syntax.sort  in
              match uu____1113 with
              | { FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_unknown ;
                  FStar_Syntax_Syntax.pos = uu____1118;
                  FStar_Syntax_Syntax.vars = uu____1119;_} ->
                  let uu____1122 = FStar_Syntax_Util.type_u ()  in
                  (match uu____1122 with
                   | (t,uu____1132) ->
                       let uu____1133 = new_uvar env1 t  in
                       (uu____1133, FStar_TypeChecker_Rel.trivial_guard))
              | t -> tc_annot env1 t  in
            match uu____1108 with
            | (t_x,guard) ->
                ((let uu___98_1142 = x  in
                  {
                    FStar_Syntax_Syntax.ppname =
                      (uu___98_1142.FStar_Syntax_Syntax.ppname);
                    FStar_Syntax_Syntax.index =
                      (uu___98_1142.FStar_Syntax_Syntax.index);
                    FStar_Syntax_Syntax.sort = t_x
                  }), guard)
             in
          let rec pat_as_arg_with_env allow_wc_dependence env1 p1 =
            match p1.FStar_Syntax_Syntax.v with
            | FStar_Syntax_Syntax.Pat_constant c ->
                let e =
                  match c with
                  | FStar_Const.Const_int
                      (repr,FStar_Pervasives_Native.Some sw) ->
                      FStar_ToSyntax_ToSyntax.desugar_machine_integer
                        env1.FStar_TypeChecker_Env.dsenv repr sw
                        p1.FStar_Syntax_Syntax.p
                  | uu____1211 ->
                      FStar_Syntax_Syntax.mk
                        (FStar_Syntax_Syntax.Tm_constant c)
                        FStar_Pervasives_Native.None p1.FStar_Syntax_Syntax.p
                   in
                ([], [], [], env1, e, FStar_TypeChecker_Rel.trivial_guard,
                  p1)
            | FStar_Syntax_Syntax.Pat_dot_term (x,uu____1219) ->
                let uu____1224 = FStar_Syntax_Util.type_u ()  in
                (match uu____1224 with
                 | (k,uu____1250) ->
                     let t = new_uvar env1 k  in
                     let x1 =
                       let uu___99_1253 = x  in
                       {
                         FStar_Syntax_Syntax.ppname =
                           (uu___99_1253.FStar_Syntax_Syntax.ppname);
                         FStar_Syntax_Syntax.index =
                           (uu___99_1253.FStar_Syntax_Syntax.index);
                         FStar_Syntax_Syntax.sort = t
                       }  in
                     let uu____1254 =
                       let uu____1259 =
                         FStar_TypeChecker_Env.all_binders env1  in
                       FStar_TypeChecker_Rel.new_uvar
                         p1.FStar_Syntax_Syntax.p uu____1259 t
                        in
                     (match uu____1254 with
                      | (e,u) ->
                          let p2 =
                            let uu___100_1285 = p1  in
                            {
                              FStar_Syntax_Syntax.v =
                                (FStar_Syntax_Syntax.Pat_dot_term (x1, e));
                              FStar_Syntax_Syntax.p =
                                (uu___100_1285.FStar_Syntax_Syntax.p)
                            }  in
                          ([], [], [], env1, e,
                            FStar_TypeChecker_Rel.trivial_guard, p2)))
            | FStar_Syntax_Syntax.Pat_wild x ->
                let uu____1295 = check_bv env1 x  in
                (match uu____1295 with
                 | (x1,g) ->
                     let env2 =
                       if allow_wc_dependence
                       then FStar_TypeChecker_Env.push_bv env1 x1
                       else env1  in
                     let e =
                       FStar_Syntax_Syntax.mk
                         (FStar_Syntax_Syntax.Tm_name x1)
                         FStar_Pervasives_Native.None
                         p1.FStar_Syntax_Syntax.p
                        in
                     ([x1], [], [x1], env2, e, g, p1))
            | FStar_Syntax_Syntax.Pat_var x ->
                let uu____1336 = check_bv env1 x  in
                (match uu____1336 with
                 | (x1,g) ->
                     let env2 = FStar_TypeChecker_Env.push_bv env1 x1  in
                     let e =
                       FStar_Syntax_Syntax.mk
                         (FStar_Syntax_Syntax.Tm_name x1)
                         FStar_Pervasives_Native.None
                         p1.FStar_Syntax_Syntax.p
                        in
                     ([x1], [x1], [], env2, e, g, p1))
            | FStar_Syntax_Syntax.Pat_cons (fv,pats) ->
                let uu____1393 =
                  FStar_All.pipe_right pats
                    (FStar_List.fold_left
                       (fun uu____1529  ->
                          fun uu____1530  ->
                            match (uu____1529, uu____1530) with
                            | ((b,a,w,env2,args,guard,pats1),(p2,imp)) ->
                                let uu____1728 =
                                  pat_as_arg_with_env allow_wc_dependence
                                    env2 p2
                                   in
                                (match uu____1728 with
                                 | (b',a',w',env3,te,guard',pat) ->
                                     let arg =
                                       if imp
                                       then FStar_Syntax_Syntax.iarg te
                                       else FStar_Syntax_Syntax.as_arg te  in
                                     let uu____1804 =
                                       FStar_TypeChecker_Rel.conj_guard guard
                                         guard'
                                        in
                                     ((b' :: b), (a' :: a), (w' :: w), env3,
                                       (arg :: args), uu____1804, ((pat, imp)
                                       :: pats1))))
                       ([], [], [], env1, [],
                         FStar_TypeChecker_Rel.trivial_guard, []))
                   in
                (match uu____1393 with
                 | (b,a,w,env2,args,guard,pats1) ->
                     let e =
                       let uu____1935 =
                         let uu____1936 = FStar_Syntax_Syntax.fv_to_tm fv  in
                         let uu____1937 =
                           FStar_All.pipe_right args FStar_List.rev  in
                         FStar_Syntax_Syntax.mk_Tm_app uu____1936 uu____1937
                          in
                       uu____1935 FStar_Pervasives_Native.None
                         p1.FStar_Syntax_Syntax.p
                        in
                     let uu____1944 =
                       FStar_All.pipe_right (FStar_List.rev b)
                         FStar_List.flatten
                        in
                     let uu____1955 =
                       FStar_All.pipe_right (FStar_List.rev a)
                         FStar_List.flatten
                        in
                     let uu____1966 =
                       FStar_All.pipe_right (FStar_List.rev w)
                         FStar_List.flatten
                        in
                     (uu____1944, uu____1955, uu____1966, env2, e, guard,
                       (let uu___101_1988 = p1  in
                        {
                          FStar_Syntax_Syntax.v =
                            (FStar_Syntax_Syntax.Pat_cons
                               (fv, (FStar_List.rev pats1)));
                          FStar_Syntax_Syntax.p =
                            (uu___101_1988.FStar_Syntax_Syntax.p)
                        })))
             in
          let rec elaborate_pat env1 p1 =
            let maybe_dot inaccessible a r =
              if allow_implicits && inaccessible
              then
                FStar_Syntax_Syntax.withinfo
                  (FStar_Syntax_Syntax.Pat_dot_term
                     (a, FStar_Syntax_Syntax.tun)) r
              else
                FStar_Syntax_Syntax.withinfo (FStar_Syntax_Syntax.Pat_var a)
                  r
               in
            match p1.FStar_Syntax_Syntax.v with
            | FStar_Syntax_Syntax.Pat_cons (fv,pats) ->
                let pats1 =
                  FStar_List.map
                    (fun uu____2072  ->
                       match uu____2072 with
                       | (p2,imp) ->
                           let uu____2091 = elaborate_pat env1 p2  in
                           (uu____2091, imp)) pats
                   in
                let uu____2096 =
                  FStar_TypeChecker_Env.lookup_datacon env1
                    (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                   in
                (match uu____2096 with
                 | (uu____2103,t) ->
                     let uu____2105 = FStar_Syntax_Util.arrow_formals t  in
                     (match uu____2105 with
                      | (f,uu____2121) ->
                          let rec aux formals pats2 =
                            match (formals, pats2) with
                            | ([],[]) -> []
                            | ([],uu____2243::uu____2244) ->
                                let uu____2287 =
                                  FStar_Ident.range_of_lid
                                    (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                                   in
                                FStar_Errors.raise_error
                                  (FStar_Errors.Fatal_TooManyPatternArguments,
                                    "Too many pattern arguments") uu____2287
                            | (uu____2296::uu____2297,[]) ->
                                FStar_All.pipe_right formals
                                  (FStar_List.map
                                     (fun uu____2375  ->
                                        match uu____2375 with
                                        | (t1,imp) ->
                                            (match imp with
                                             | FStar_Pervasives_Native.Some
                                                 (FStar_Syntax_Syntax.Implicit
                                                 inaccessible) ->
                                                 let a =
                                                   let uu____2402 =
                                                     let uu____2405 =
                                                       FStar_Syntax_Syntax.range_of_bv
                                                         t1
                                                        in
                                                     FStar_Pervasives_Native.Some
                                                       uu____2405
                                                      in
                                                   FStar_Syntax_Syntax.new_bv
                                                     uu____2402
                                                     FStar_Syntax_Syntax.tun
                                                    in
                                                 let r =
                                                   FStar_Ident.range_of_lid
                                                     (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                                                    in
                                                 let uu____2407 =
                                                   maybe_dot inaccessible a r
                                                    in
                                                 (uu____2407, true)
                                             | uu____2412 ->
                                                 let uu____2415 =
                                                   let uu____2420 =
                                                     let uu____2421 =
                                                       FStar_Syntax_Print.pat_to_string
                                                         p1
                                                        in
                                                     FStar_Util.format1
                                                       "Insufficient pattern arguments (%s)"
                                                       uu____2421
                                                      in
                                                   (FStar_Errors.Fatal_InsufficientPatternArguments,
                                                     uu____2420)
                                                    in
                                                 let uu____2422 =
                                                   FStar_Ident.range_of_lid
                                                     (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                                                    in
                                                 FStar_Errors.raise_error
                                                   uu____2415 uu____2422)))
                            | (f1::formals',(p2,p_imp)::pats') ->
                                (match f1 with
                                 | (uu____2496,FStar_Pervasives_Native.Some
                                    (FStar_Syntax_Syntax.Implicit
                                    uu____2497)) when p_imp ->
                                     let uu____2500 = aux formals' pats'  in
                                     (p2, true) :: uu____2500
                                 | (uu____2517,FStar_Pervasives_Native.Some
                                    (FStar_Syntax_Syntax.Implicit
                                    inaccessible)) ->
                                     let a =
                                       FStar_Syntax_Syntax.new_bv
                                         (FStar_Pervasives_Native.Some
                                            (p2.FStar_Syntax_Syntax.p))
                                         FStar_Syntax_Syntax.tun
                                        in
                                     let p3 =
                                       let uu____2525 =
                                         FStar_Ident.range_of_lid
                                           (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                                          in
                                       maybe_dot inaccessible a uu____2525
                                        in
                                     let uu____2526 = aux formals' pats2  in
                                     (p3, true) :: uu____2526
                                 | (uu____2543,imp) ->
                                     let uu____2549 =
                                       let uu____2556 =
                                         FStar_Syntax_Syntax.is_implicit imp
                                          in
                                       (p2, uu____2556)  in
                                     let uu____2559 = aux formals' pats'  in
                                     uu____2549 :: uu____2559)
                             in
                          let uu___102_2574 = p1  in
                          let uu____2577 =
                            let uu____2578 =
                              let uu____2591 = aux f pats1  in
                              (fv, uu____2591)  in
                            FStar_Syntax_Syntax.Pat_cons uu____2578  in
                          {
                            FStar_Syntax_Syntax.v = uu____2577;
                            FStar_Syntax_Syntax.p =
                              (uu___102_2574.FStar_Syntax_Syntax.p)
                          }))
            | uu____2608 -> p1  in
          let one_pat allow_wc_dependence env1 p1 =
            let p2 = elaborate_pat env1 p1  in
            let uu____2644 = pat_as_arg_with_env allow_wc_dependence env1 p2
               in
            match uu____2644 with
            | (b,a,w,env2,arg,guard,p3) ->
                let uu____2702 =
                  FStar_All.pipe_right b
                    (FStar_Util.find_dup FStar_Syntax_Syntax.bv_eq)
                   in
                (match uu____2702 with
                 | FStar_Pervasives_Native.Some x ->
                     let uu____2728 =
                       FStar_TypeChecker_Err.nonlinear_pattern_variable x  in
                     FStar_Errors.raise_error uu____2728
                       p3.FStar_Syntax_Syntax.p
                 | uu____2751 -> (b, a, w, arg, guard, p3))
             in
          let uu____2760 = one_pat true env p  in
          match uu____2760 with
          | (b,uu____2790,uu____2791,tm,guard,p1) -> (b, tm, guard, p1)
  
let (decorate_pattern :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.pat ->
      FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.pat)
  =
  fun env  ->
    fun p  ->
      fun exp  ->
        let qq = p  in
        let rec aux p1 e =
          let pkg q = FStar_Syntax_Syntax.withinfo q p1.FStar_Syntax_Syntax.p
             in
          let e1 = FStar_Syntax_Util.unmeta e  in
          match ((p1.FStar_Syntax_Syntax.v), (e1.FStar_Syntax_Syntax.n)) with
          | (uu____2837,FStar_Syntax_Syntax.Tm_uinst (e2,uu____2839)) ->
              aux p1 e2
          | (FStar_Syntax_Syntax.Pat_constant uu____2844,uu____2845) ->
              pkg p1.FStar_Syntax_Syntax.v
          | (FStar_Syntax_Syntax.Pat_var x,FStar_Syntax_Syntax.Tm_name y) ->
              (if Prims.op_Negation (FStar_Syntax_Syntax.bv_eq x y)
               then
                 (let uu____2849 =
                    let uu____2850 = FStar_Syntax_Print.bv_to_string x  in
                    let uu____2851 = FStar_Syntax_Print.bv_to_string y  in
                    FStar_Util.format2 "Expected pattern variable %s; got %s"
                      uu____2850 uu____2851
                     in
                  failwith uu____2849)
               else ();
               (let uu____2854 =
                  FStar_All.pipe_left (FStar_TypeChecker_Env.debug env)
                    (FStar_Options.Other "Pat")
                   in
                if uu____2854
                then
                  let uu____2855 = FStar_Syntax_Print.bv_to_string x  in
                  let uu____2856 =
                    FStar_TypeChecker_Normalize.term_to_string env
                      y.FStar_Syntax_Syntax.sort
                     in
                  FStar_Util.print2
                    "Pattern variable %s introduced at type %s\n" uu____2855
                    uu____2856
                else ());
               (let s =
                  FStar_TypeChecker_Normalize.normalize
                    [FStar_TypeChecker_Normalize.Beta] env
                    y.FStar_Syntax_Syntax.sort
                   in
                let x1 =
                  let uu___103_2860 = x  in
                  {
                    FStar_Syntax_Syntax.ppname =
                      (uu___103_2860.FStar_Syntax_Syntax.ppname);
                    FStar_Syntax_Syntax.index =
                      (uu___103_2860.FStar_Syntax_Syntax.index);
                    FStar_Syntax_Syntax.sort = s
                  }  in
                pkg (FStar_Syntax_Syntax.Pat_var x1)))
          | (FStar_Syntax_Syntax.Pat_wild x,FStar_Syntax_Syntax.Tm_name y) ->
              ((let uu____2864 =
                  FStar_All.pipe_right (FStar_Syntax_Syntax.bv_eq x y)
                    Prims.op_Negation
                   in
                if uu____2864
                then
                  let uu____2865 =
                    let uu____2866 = FStar_Syntax_Print.bv_to_string x  in
                    let uu____2867 = FStar_Syntax_Print.bv_to_string y  in
                    FStar_Util.format2 "Expected pattern variable %s; got %s"
                      uu____2866 uu____2867
                     in
                  failwith uu____2865
                else ());
               (let s =
                  FStar_TypeChecker_Normalize.normalize
                    [FStar_TypeChecker_Normalize.Beta] env
                    y.FStar_Syntax_Syntax.sort
                   in
                let x1 =
                  let uu___104_2871 = x  in
                  {
                    FStar_Syntax_Syntax.ppname =
                      (uu___104_2871.FStar_Syntax_Syntax.ppname);
                    FStar_Syntax_Syntax.index =
                      (uu___104_2871.FStar_Syntax_Syntax.index);
                    FStar_Syntax_Syntax.sort = s
                  }  in
                pkg (FStar_Syntax_Syntax.Pat_wild x1)))
          | (FStar_Syntax_Syntax.Pat_dot_term (x,uu____2873),uu____2874) ->
              pkg (FStar_Syntax_Syntax.Pat_dot_term (x, e1))
          | (FStar_Syntax_Syntax.Pat_cons (fv,[]),FStar_Syntax_Syntax.Tm_fvar
             fv') ->
              ((let uu____2896 =
                  let uu____2897 = FStar_Syntax_Syntax.fv_eq fv fv'  in
                  Prims.op_Negation uu____2897  in
                if uu____2896
                then
                  let uu____2898 =
                    FStar_Util.format2
                      "Expected pattern constructor %s; got %s"
                      ((fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v).FStar_Ident.str
                      ((fv'.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v).FStar_Ident.str
                     in
                  failwith uu____2898
                else ());
               pkg (FStar_Syntax_Syntax.Pat_cons (fv', [])))
          | (FStar_Syntax_Syntax.Pat_cons
             (fv,argpats),FStar_Syntax_Syntax.Tm_app
             ({ FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar fv';
                FStar_Syntax_Syntax.pos = uu____2917;
                FStar_Syntax_Syntax.vars = uu____2918;_},args))
              ->
              ((let uu____2957 =
                  let uu____2958 = FStar_Syntax_Syntax.fv_eq fv fv'  in
                  FStar_All.pipe_right uu____2958 Prims.op_Negation  in
                if uu____2957
                then
                  let uu____2959 =
                    FStar_Util.format2
                      "Expected pattern constructor %s; got %s"
                      ((fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v).FStar_Ident.str
                      ((fv'.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v).FStar_Ident.str
                     in
                  failwith uu____2959
                else ());
               (let fv1 = fv'  in
                let rec match_args matched_pats args1 argpats1 =
                  match (args1, argpats1) with
                  | ([],[]) ->
                      pkg
                        (FStar_Syntax_Syntax.Pat_cons
                           (fv1, (FStar_List.rev matched_pats)))
                  | (arg::args2,(argpat,uu____3095)::argpats2) ->
                      (match (arg, (argpat.FStar_Syntax_Syntax.v)) with
                       | ((e2,FStar_Pervasives_Native.Some
                           (FStar_Syntax_Syntax.Implicit (true ))),FStar_Syntax_Syntax.Pat_dot_term
                          uu____3170) ->
                           let x =
                             FStar_Syntax_Syntax.new_bv
                               (FStar_Pervasives_Native.Some
                                  (p1.FStar_Syntax_Syntax.p))
                               FStar_Syntax_Syntax.tun
                              in
                           let q =
                             FStar_Syntax_Syntax.withinfo
                               (FStar_Syntax_Syntax.Pat_dot_term (x, e2))
                               p1.FStar_Syntax_Syntax.p
                              in
                           match_args ((q, true) :: matched_pats) args2
                             argpats2
                       | ((e2,imp),uu____3207) ->
                           let pat =
                             let uu____3229 = aux argpat e2  in
                             let uu____3230 =
                               FStar_Syntax_Syntax.is_implicit imp  in
                             (uu____3229, uu____3230)  in
                           match_args (pat :: matched_pats) args2 argpats2)
                  | uu____3235 ->
                      let uu____3258 =
                        let uu____3259 = FStar_Syntax_Print.pat_to_string p1
                           in
                        let uu____3260 = FStar_Syntax_Print.term_to_string e1
                           in
                        FStar_Util.format2
                          "Unexpected number of pattern arguments: \n\t%s\n\t%s\n"
                          uu____3259 uu____3260
                         in
                      failwith uu____3258
                   in
                match_args [] args argpats))
          | (FStar_Syntax_Syntax.Pat_cons
             (fv,argpats),FStar_Syntax_Syntax.Tm_app
             ({
                FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_uinst
                  ({ FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar fv';
                     FStar_Syntax_Syntax.pos = uu____3272;
                     FStar_Syntax_Syntax.vars = uu____3273;_},uu____3274);
                FStar_Syntax_Syntax.pos = uu____3275;
                FStar_Syntax_Syntax.vars = uu____3276;_},args))
              ->
              ((let uu____3319 =
                  let uu____3320 = FStar_Syntax_Syntax.fv_eq fv fv'  in
                  FStar_All.pipe_right uu____3320 Prims.op_Negation  in
                if uu____3319
                then
                  let uu____3321 =
                    FStar_Util.format2
                      "Expected pattern constructor %s; got %s"
                      ((fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v).FStar_Ident.str
                      ((fv'.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v).FStar_Ident.str
                     in
                  failwith uu____3321
                else ());
               (let fv1 = fv'  in
                let rec match_args matched_pats args1 argpats1 =
                  match (args1, argpats1) with
                  | ([],[]) ->
                      pkg
                        (FStar_Syntax_Syntax.Pat_cons
                           (fv1, (FStar_List.rev matched_pats)))
                  | (arg::args2,(argpat,uu____3457)::argpats2) ->
                      (match (arg, (argpat.FStar_Syntax_Syntax.v)) with
                       | ((e2,FStar_Pervasives_Native.Some
                           (FStar_Syntax_Syntax.Implicit (true ))),FStar_Syntax_Syntax.Pat_dot_term
                          uu____3532) ->
                           let x =
                             FStar_Syntax_Syntax.new_bv
                               (FStar_Pervasives_Native.Some
                                  (p1.FStar_Syntax_Syntax.p))
                               FStar_Syntax_Syntax.tun
                              in
                           let q =
                             FStar_Syntax_Syntax.withinfo
                               (FStar_Syntax_Syntax.Pat_dot_term (x, e2))
                               p1.FStar_Syntax_Syntax.p
                              in
                           match_args ((q, true) :: matched_pats) args2
                             argpats2
                       | ((e2,imp),uu____3569) ->
                           let pat =
                             let uu____3591 = aux argpat e2  in
                             let uu____3592 =
                               FStar_Syntax_Syntax.is_implicit imp  in
                             (uu____3591, uu____3592)  in
                           match_args (pat :: matched_pats) args2 argpats2)
                  | uu____3597 ->
                      let uu____3620 =
                        let uu____3621 = FStar_Syntax_Print.pat_to_string p1
                           in
                        let uu____3622 = FStar_Syntax_Print.term_to_string e1
                           in
                        FStar_Util.format2
                          "Unexpected number of pattern arguments: \n\t%s\n\t%s\n"
                          uu____3621 uu____3622
                         in
                      failwith uu____3620
                   in
                match_args [] args argpats))
          | uu____3631 ->
              let uu____3636 =
                let uu____3637 =
                  FStar_Range.string_of_range qq.FStar_Syntax_Syntax.p  in
                let uu____3638 = FStar_Syntax_Print.pat_to_string qq  in
                let uu____3639 = FStar_Syntax_Print.term_to_string exp  in
                FStar_Util.format3
                  "(%s) Impossible: pattern to decorate is %s; expression is %s\n"
                  uu____3637 uu____3638 uu____3639
                 in
              failwith uu____3636
           in
        aux p exp
  
let rec (decorated_pattern_as_term :
  FStar_Syntax_Syntax.pat ->
    (FStar_Syntax_Syntax.bv Prims.list,FStar_Syntax_Syntax.term)
      FStar_Pervasives_Native.tuple2)
  =
  fun pat  ->
    let mk1 f =
      FStar_Syntax_Syntax.mk f FStar_Pervasives_Native.None
        pat.FStar_Syntax_Syntax.p
       in
    let pat_as_arg uu____3676 =
      match uu____3676 with
      | (p,i) ->
          let uu____3693 = decorated_pattern_as_term p  in
          (match uu____3693 with
           | (vars,te) ->
               let uu____3716 =
                 let uu____3721 = FStar_Syntax_Syntax.as_implicit i  in
                 (te, uu____3721)  in
               (vars, uu____3716))
       in
    match pat.FStar_Syntax_Syntax.v with
    | FStar_Syntax_Syntax.Pat_constant c ->
        let uu____3735 = mk1 (FStar_Syntax_Syntax.Tm_constant c)  in
        ([], uu____3735)
    | FStar_Syntax_Syntax.Pat_wild x ->
        let uu____3739 = mk1 (FStar_Syntax_Syntax.Tm_name x)  in
        ([x], uu____3739)
    | FStar_Syntax_Syntax.Pat_var x ->
        let uu____3743 = mk1 (FStar_Syntax_Syntax.Tm_name x)  in
        ([x], uu____3743)
    | FStar_Syntax_Syntax.Pat_cons (fv,pats) ->
        let uu____3764 =
          let uu____3779 =
            FStar_All.pipe_right pats (FStar_List.map pat_as_arg)  in
          FStar_All.pipe_right uu____3779 FStar_List.unzip  in
        (match uu____3764 with
         | (vars,args) ->
             let vars1 = FStar_List.flatten vars  in
             let uu____3889 =
               let uu____3890 =
                 let uu____3891 =
                   let uu____3906 = FStar_Syntax_Syntax.fv_to_tm fv  in
                   (uu____3906, args)  in
                 FStar_Syntax_Syntax.Tm_app uu____3891  in
               mk1 uu____3890  in
             (vars1, uu____3889))
    | FStar_Syntax_Syntax.Pat_dot_term (x,e) -> ([], e)
  
let (comp_univ_opt :
  FStar_Syntax_Syntax.comp' FStar_Syntax_Syntax.syntax ->
    FStar_Syntax_Syntax.universe FStar_Pervasives_Native.option)
  =
  fun c  ->
    match c.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Total (uu____3936,uopt) -> uopt
    | FStar_Syntax_Syntax.GTotal (uu____3946,uopt) -> uopt
    | FStar_Syntax_Syntax.Comp c1 ->
        (match c1.FStar_Syntax_Syntax.comp_univs with
         | [] -> FStar_Pervasives_Native.None
         | hd1::uu____3960 -> FStar_Pervasives_Native.Some hd1)
  
let (destruct_comp :
  FStar_Syntax_Syntax.comp_typ ->
    (FStar_Syntax_Syntax.universe,FStar_Syntax_Syntax.typ,FStar_Syntax_Syntax.typ)
      FStar_Pervasives_Native.tuple3)
  =
  fun c  ->
    let wp =
      match c.FStar_Syntax_Syntax.effect_args with
      | (wp,uu____3984)::[] -> wp
      | uu____4001 ->
          let uu____4010 =
            let uu____4011 =
              let uu____4012 =
                FStar_List.map
                  (fun uu____4022  ->
                     match uu____4022 with
                     | (x,uu____4028) -> FStar_Syntax_Print.term_to_string x)
                  c.FStar_Syntax_Syntax.effect_args
                 in
              FStar_All.pipe_right uu____4012 (FStar_String.concat ", ")  in
            FStar_Util.format2
              "Impossible: Got a computation %s with effect args [%s]"
              (c.FStar_Syntax_Syntax.effect_name).FStar_Ident.str uu____4011
             in
          failwith uu____4010
       in
    let uu____4033 = FStar_List.hd c.FStar_Syntax_Syntax.comp_univs  in
    (uu____4033, (c.FStar_Syntax_Syntax.result_typ), wp)
  
let (lift_comp :
  FStar_Syntax_Syntax.comp_typ ->
    FStar_Ident.lident ->
      FStar_TypeChecker_Env.mlift -> FStar_Syntax_Syntax.comp_typ)
  =
  fun c  ->
    fun m  ->
      fun lift  ->
        let uu____4047 = destruct_comp c  in
        match uu____4047 with
        | (u,uu____4055,wp) ->
            let uu____4057 =
              let uu____4066 =
                let uu____4067 =
                  lift.FStar_TypeChecker_Env.mlift_wp u
                    c.FStar_Syntax_Syntax.result_typ wp
                   in
                FStar_Syntax_Syntax.as_arg uu____4067  in
              [uu____4066]  in
            {
              FStar_Syntax_Syntax.comp_univs = [u];
              FStar_Syntax_Syntax.effect_name = m;
              FStar_Syntax_Syntax.result_typ =
                (c.FStar_Syntax_Syntax.result_typ);
              FStar_Syntax_Syntax.effect_args = uu____4057;
              FStar_Syntax_Syntax.flags = []
            }
  
let (join_effects :
  FStar_TypeChecker_Env.env ->
    FStar_Ident.lident -> FStar_Ident.lident -> FStar_Ident.lident)
  =
  fun env  ->
    fun l1  ->
      fun l2  ->
        let uu____4077 =
          let uu____4084 = FStar_TypeChecker_Env.norm_eff_name env l1  in
          let uu____4085 = FStar_TypeChecker_Env.norm_eff_name env l2  in
          FStar_TypeChecker_Env.join env uu____4084 uu____4085  in
        match uu____4077 with | (m,uu____4087,uu____4088) -> m
  
let (join_lcomp :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.lcomp ->
      FStar_Syntax_Syntax.lcomp -> FStar_Ident.lident)
  =
  fun env  ->
    fun c1  ->
      fun c2  ->
        let uu____4098 =
          (FStar_Syntax_Util.is_total_lcomp c1) &&
            (FStar_Syntax_Util.is_total_lcomp c2)
           in
        if uu____4098
        then FStar_Parser_Const.effect_Tot_lid
        else
          join_effects env c1.FStar_Syntax_Syntax.eff_name
            c2.FStar_Syntax_Syntax.eff_name
  
let (lift_and_destruct :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.comp ->
      FStar_Syntax_Syntax.comp ->
        ((FStar_Syntax_Syntax.eff_decl,FStar_Syntax_Syntax.bv,FStar_Syntax_Syntax.term)
           FStar_Pervasives_Native.tuple3,(FStar_Syntax_Syntax.universe,
                                            FStar_Syntax_Syntax.typ,FStar_Syntax_Syntax.typ)
                                            FStar_Pervasives_Native.tuple3,
          (FStar_Syntax_Syntax.universe,FStar_Syntax_Syntax.typ,FStar_Syntax_Syntax.typ)
            FStar_Pervasives_Native.tuple3)
          FStar_Pervasives_Native.tuple3)
  =
  fun env  ->
    fun c1  ->
      fun c2  ->
        let c11 = FStar_TypeChecker_Env.unfold_effect_abbrev env c1  in
        let c21 = FStar_TypeChecker_Env.unfold_effect_abbrev env c2  in
        let uu____4135 =
          FStar_TypeChecker_Env.join env c11.FStar_Syntax_Syntax.effect_name
            c21.FStar_Syntax_Syntax.effect_name
           in
        match uu____4135 with
        | (m,lift1,lift2) ->
            let m1 = lift_comp c11 m lift1  in
            let m2 = lift_comp c21 m lift2  in
            let md = FStar_TypeChecker_Env.get_effect_decl env m  in
            let uu____4172 =
              FStar_TypeChecker_Env.wp_signature env
                md.FStar_Syntax_Syntax.mname
               in
            (match uu____4172 with
             | (a,kwp) ->
                 let uu____4203 = destruct_comp m1  in
                 let uu____4210 = destruct_comp m2  in
                 ((md, a, kwp), uu____4203, uu____4210))
  
let (is_pure_effect :
  FStar_TypeChecker_Env.env -> FStar_Ident.lident -> Prims.bool) =
  fun env  ->
    fun l  ->
      let l1 = FStar_TypeChecker_Env.norm_eff_name env l  in
      FStar_Ident.lid_equals l1 FStar_Parser_Const.effect_PURE_lid
  
let (is_pure_or_ghost_effect :
  FStar_TypeChecker_Env.env -> FStar_Ident.lident -> Prims.bool) =
  fun env  ->
    fun l  ->
      let l1 = FStar_TypeChecker_Env.norm_eff_name env l  in
      (FStar_Ident.lid_equals l1 FStar_Parser_Const.effect_PURE_lid) ||
        (FStar_Ident.lid_equals l1 FStar_Parser_Const.effect_GHOST_lid)
  
let (mk_comp_l :
  FStar_Ident.lident ->
    FStar_Syntax_Syntax.universe ->
      FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
        FStar_Syntax_Syntax.term ->
          FStar_Syntax_Syntax.cflags Prims.list -> FStar_Syntax_Syntax.comp)
  =
  fun mname  ->
    fun u_result  ->
      fun result  ->
        fun wp  ->
          fun flags1  ->
            let uu____4272 =
              let uu____4273 =
                let uu____4282 = FStar_Syntax_Syntax.as_arg wp  in
                [uu____4282]  in
              {
                FStar_Syntax_Syntax.comp_univs = [u_result];
                FStar_Syntax_Syntax.effect_name = mname;
                FStar_Syntax_Syntax.result_typ = result;
                FStar_Syntax_Syntax.effect_args = uu____4273;
                FStar_Syntax_Syntax.flags = flags1
              }  in
            FStar_Syntax_Syntax.mk_Comp uu____4272
  
let (mk_comp :
  FStar_Syntax_Syntax.eff_decl ->
    FStar_Syntax_Syntax.universe ->
      FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
        FStar_Syntax_Syntax.term ->
          FStar_Syntax_Syntax.cflags Prims.list -> FStar_Syntax_Syntax.comp)
  = fun md  -> mk_comp_l md.FStar_Syntax_Syntax.mname 
let (lax_mk_tot_or_comp_l :
  FStar_Ident.lident ->
    FStar_Syntax_Syntax.universe ->
      FStar_Syntax_Syntax.typ ->
        FStar_Syntax_Syntax.cflags Prims.list -> FStar_Syntax_Syntax.comp)
  =
  fun mname  ->
    fun u_result  ->
      fun result  ->
        fun flags1  ->
          let uu____4314 =
            FStar_Ident.lid_equals mname FStar_Parser_Const.effect_Tot_lid
             in
          if uu____4314
          then
            FStar_Syntax_Syntax.mk_Total' result
              (FStar_Pervasives_Native.Some u_result)
          else mk_comp_l mname u_result result FStar_Syntax_Syntax.tun flags1
  
let (subst_lcomp :
  FStar_Syntax_Syntax.subst_t ->
    FStar_Syntax_Syntax.lcomp -> FStar_Syntax_Syntax.lcomp)
  =
  fun subst1  ->
    fun lc  ->
      let uu____4322 =
        FStar_Syntax_Subst.subst subst1 lc.FStar_Syntax_Syntax.res_typ  in
      FStar_Syntax_Syntax.mk_lcomp lc.FStar_Syntax_Syntax.eff_name uu____4322
        lc.FStar_Syntax_Syntax.cflags
        (fun uu____4325  ->
           let uu____4326 = FStar_Syntax_Syntax.lcomp_comp lc  in
           FStar_Syntax_Subst.subst_comp subst1 uu____4326)
  
let (is_function : FStar_Syntax_Syntax.term -> Prims.bool) =
  fun t  ->
    let uu____4330 =
      let uu____4331 = FStar_Syntax_Subst.compress t  in
      uu____4331.FStar_Syntax_Syntax.n  in
    match uu____4330 with
    | FStar_Syntax_Syntax.Tm_arrow uu____4334 -> true
    | uu____4347 -> false
  
let (label :
  Prims.string ->
    FStar_Range.range -> FStar_Syntax_Syntax.typ -> FStar_Syntax_Syntax.typ)
  =
  fun reason  ->
    fun r  ->
      fun f  ->
        FStar_Syntax_Syntax.mk
          (FStar_Syntax_Syntax.Tm_meta
             (f, (FStar_Syntax_Syntax.Meta_labeled (reason, r, false))))
          FStar_Pervasives_Native.None f.FStar_Syntax_Syntax.pos
  
let (label_opt :
  FStar_TypeChecker_Env.env ->
    (Prims.unit -> Prims.string) FStar_Pervasives_Native.option ->
      FStar_Range.range -> FStar_Syntax_Syntax.typ -> FStar_Syntax_Syntax.typ)
  =
  fun env  ->
    fun reason  ->
      fun r  ->
        fun f  ->
          match reason with
          | FStar_Pervasives_Native.None  -> f
          | FStar_Pervasives_Native.Some reason1 ->
              let uu____4385 =
                let uu____4386 = FStar_TypeChecker_Env.should_verify env  in
                FStar_All.pipe_left Prims.op_Negation uu____4386  in
              if uu____4385
              then f
              else (let uu____4388 = reason1 ()  in label uu____4388 r f)
  
let (label_guard :
  FStar_Range.range ->
    Prims.string ->
      FStar_TypeChecker_Env.guard_t -> FStar_TypeChecker_Env.guard_t)
  =
  fun r  ->
    fun reason  ->
      fun g  ->
        match g.FStar_TypeChecker_Env.guard_f with
        | FStar_TypeChecker_Common.Trivial  -> g
        | FStar_TypeChecker_Common.NonTrivial f ->
            let uu___105_4399 = g  in
            let uu____4400 =
              let uu____4401 = label reason r f  in
              FStar_TypeChecker_Common.NonTrivial uu____4401  in
            {
              FStar_TypeChecker_Env.guard_f = uu____4400;
              FStar_TypeChecker_Env.deferred =
                (uu___105_4399.FStar_TypeChecker_Env.deferred);
              FStar_TypeChecker_Env.univ_ineqs =
                (uu___105_4399.FStar_TypeChecker_Env.univ_ineqs);
              FStar_TypeChecker_Env.implicits =
                (uu___105_4399.FStar_TypeChecker_Env.implicits)
            }
  
let (close_comp :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.bv Prims.list ->
      FStar_Syntax_Syntax.comp -> FStar_Syntax_Syntax.comp)
  =
  fun env  ->
    fun bvs  ->
      fun c  ->
        let uu____4415 = FStar_Syntax_Util.is_ml_comp c  in
        if uu____4415
        then c
        else
          (let uu____4417 =
             env.FStar_TypeChecker_Env.lax && (FStar_Options.ml_ish ())  in
           if uu____4417
           then c
           else
             (let close_wp u_res md res_t bvs1 wp0 =
                FStar_List.fold_right
                  (fun x  ->
                     fun wp  ->
                       let bs =
                         let uu____4456 = FStar_Syntax_Syntax.mk_binder x  in
                         [uu____4456]  in
                       let us =
                         let uu____4460 =
                           let uu____4463 =
                             env.FStar_TypeChecker_Env.universe_of env
                               x.FStar_Syntax_Syntax.sort
                              in
                           [uu____4463]  in
                         u_res :: uu____4460  in
                       let wp1 =
                         FStar_Syntax_Util.abs bs wp
                           (FStar_Pervasives_Native.Some
                              (FStar_Syntax_Util.mk_residual_comp
                                 FStar_Parser_Const.effect_Tot_lid
                                 FStar_Pervasives_Native.None
                                 [FStar_Syntax_Syntax.TOTAL]))
                          in
                       let uu____4467 =
                         let uu____4468 =
                           FStar_TypeChecker_Env.inst_effect_fun_with us env
                             md md.FStar_Syntax_Syntax.close_wp
                            in
                         let uu____4469 =
                           let uu____4470 = FStar_Syntax_Syntax.as_arg res_t
                              in
                           let uu____4471 =
                             let uu____4474 =
                               FStar_Syntax_Syntax.as_arg
                                 x.FStar_Syntax_Syntax.sort
                                in
                             let uu____4475 =
                               let uu____4478 =
                                 FStar_Syntax_Syntax.as_arg wp1  in
                               [uu____4478]  in
                             uu____4474 :: uu____4475  in
                           uu____4470 :: uu____4471  in
                         FStar_Syntax_Syntax.mk_Tm_app uu____4468 uu____4469
                          in
                       uu____4467 FStar_Pervasives_Native.None
                         wp0.FStar_Syntax_Syntax.pos) bvs1 wp0
                 in
              let c1 = FStar_TypeChecker_Env.unfold_effect_abbrev env c  in
              let uu____4482 = destruct_comp c1  in
              match uu____4482 with
              | (u_res_t,res_t,wp) ->
                  let md =
                    FStar_TypeChecker_Env.get_effect_decl env
                      c1.FStar_Syntax_Syntax.effect_name
                     in
                  let wp1 = close_wp u_res_t md res_t bvs wp  in
                  mk_comp md u_res_t c1.FStar_Syntax_Syntax.result_typ wp1
                    c1.FStar_Syntax_Syntax.flags))
  
let (close_lcomp :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.bv Prims.list ->
      FStar_Syntax_Syntax.lcomp -> FStar_Syntax_Syntax.lcomp)
  =
  fun env  ->
    fun bvs  ->
      fun lc  ->
        FStar_Syntax_Syntax.mk_lcomp lc.FStar_Syntax_Syntax.eff_name
          lc.FStar_Syntax_Syntax.res_typ lc.FStar_Syntax_Syntax.cflags
          (fun uu____4509  ->
             let uu____4510 = FStar_Syntax_Syntax.lcomp_comp lc  in
             close_comp env bvs uu____4510)
  
let (should_not_inline_lc : FStar_Syntax_Syntax.lcomp -> Prims.bool) =
  fun lc  ->
    FStar_All.pipe_right lc.FStar_Syntax_Syntax.cflags
      (FStar_Util.for_some
         (fun uu___78_4517  ->
            match uu___78_4517 with
            | FStar_Syntax_Syntax.SHOULD_NOT_INLINE  -> true
            | uu____4518 -> false))
  
let (should_return :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term FStar_Pervasives_Native.option ->
      FStar_Syntax_Syntax.lcomp -> Prims.bool)
  =
  fun env  ->
    fun eopt  ->
      fun lc  ->
        match eopt with
        | FStar_Pervasives_Native.None  -> false
        | FStar_Pervasives_Native.Some e ->
            (((FStar_Syntax_Util.is_pure_or_ghost_lcomp lc) &&
                (let uu____4534 =
                   FStar_Syntax_Util.is_unit lc.FStar_Syntax_Syntax.res_typ
                    in
                 Prims.op_Negation uu____4534))
               &&
               (let uu____4541 = FStar_Syntax_Util.head_and_args' e  in
                match uu____4541 with
                | (head1,uu____4555) ->
                    let uu____4572 =
                      let uu____4573 = FStar_Syntax_Util.un_uinst head1  in
                      uu____4573.FStar_Syntax_Syntax.n  in
                    (match uu____4572 with
                     | FStar_Syntax_Syntax.Tm_fvar fv ->
                         let uu____4577 =
                           let uu____4578 = FStar_Syntax_Syntax.lid_of_fv fv
                              in
                           FStar_TypeChecker_Env.is_irreducible env
                             uu____4578
                            in
                         Prims.op_Negation uu____4577
                     | uu____4579 -> true)))
              &&
              (let uu____4581 = should_not_inline_lc lc  in
               Prims.op_Negation uu____4581)
  
let (return_value :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.universe FStar_Pervasives_Native.option ->
      FStar_Syntax_Syntax.typ ->
        FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.comp)
  =
  fun env  ->
    fun u_t_opt  ->
      fun t  ->
        fun v1  ->
          let c =
            let uu____4599 =
              let uu____4600 =
                FStar_TypeChecker_Env.lid_exists env
                  FStar_Parser_Const.effect_GTot_lid
                 in
              FStar_All.pipe_left Prims.op_Negation uu____4600  in
            if uu____4599
            then FStar_Syntax_Syntax.mk_Total t
            else
              (let uu____4602 = FStar_Syntax_Util.is_unit t  in
               if uu____4602
               then
                 FStar_Syntax_Syntax.mk_Total' t
                   (FStar_Pervasives_Native.Some FStar_Syntax_Syntax.U_zero)
               else
                 (let m =
                    FStar_TypeChecker_Env.get_effect_decl env
                      FStar_Parser_Const.effect_PURE_lid
                     in
                  let u_t =
                    match u_t_opt with
                    | FStar_Pervasives_Native.None  ->
                        env.FStar_TypeChecker_Env.universe_of env t
                    | FStar_Pervasives_Native.Some u_t -> u_t  in
                  let wp =
                    let uu____4608 =
                      env.FStar_TypeChecker_Env.lax &&
                        (FStar_Options.ml_ish ())
                       in
                    if uu____4608
                    then FStar_Syntax_Syntax.tun
                    else
                      (let uu____4610 =
                         FStar_TypeChecker_Env.wp_signature env
                           FStar_Parser_Const.effect_PURE_lid
                          in
                       match uu____4610 with
                       | (a,kwp) ->
                           let k =
                             FStar_Syntax_Subst.subst
                               [FStar_Syntax_Syntax.NT (a, t)] kwp
                              in
                           let uu____4618 =
                             let uu____4619 =
                               let uu____4620 =
                                 FStar_TypeChecker_Env.inst_effect_fun_with
                                   [u_t] env m m.FStar_Syntax_Syntax.ret_wp
                                  in
                               let uu____4621 =
                                 let uu____4622 =
                                   FStar_Syntax_Syntax.as_arg t  in
                                 let uu____4623 =
                                   let uu____4626 =
                                     FStar_Syntax_Syntax.as_arg v1  in
                                   [uu____4626]  in
                                 uu____4622 :: uu____4623  in
                               FStar_Syntax_Syntax.mk_Tm_app uu____4620
                                 uu____4621
                                in
                             uu____4619 FStar_Pervasives_Native.None
                               v1.FStar_Syntax_Syntax.pos
                              in
                           FStar_TypeChecker_Normalize.normalize
                             [FStar_TypeChecker_Normalize.Beta;
                             FStar_TypeChecker_Normalize.NoFullNorm] env
                             uu____4618)
                     in
                  mk_comp m u_t t wp [FStar_Syntax_Syntax.RETURN]))
             in
          (let uu____4630 =
             FStar_All.pipe_left (FStar_TypeChecker_Env.debug env)
               (FStar_Options.Other "Return")
              in
           if uu____4630
           then
             let uu____4631 =
               FStar_Range.string_of_range v1.FStar_Syntax_Syntax.pos  in
             let uu____4632 = FStar_Syntax_Print.term_to_string v1  in
             let uu____4633 =
               FStar_TypeChecker_Normalize.comp_to_string env c  in
             FStar_Util.print3 "(%s) returning %s at comp type %s\n"
               uu____4631 uu____4632 uu____4633
           else ());
          c
  
let (weaken_flags :
  FStar_Syntax_Syntax.cflags Prims.list ->
    FStar_Syntax_Syntax.cflags Prims.list)
  =
  fun flags1  ->
    let uu____4644 =
      FStar_All.pipe_right flags1
        (FStar_Util.for_some
           (fun uu___79_4648  ->
              match uu___79_4648 with
              | FStar_Syntax_Syntax.SHOULD_NOT_INLINE  -> true
              | uu____4649 -> false))
       in
    if uu____4644
    then [FStar_Syntax_Syntax.SHOULD_NOT_INLINE]
    else
      FStar_All.pipe_right flags1
        (FStar_List.collect
           (fun uu___80_4658  ->
              match uu___80_4658 with
              | FStar_Syntax_Syntax.TOTAL  ->
                  [FStar_Syntax_Syntax.TRIVIAL_POSTCONDITION]
              | FStar_Syntax_Syntax.RETURN  ->
                  [FStar_Syntax_Syntax.PARTIAL_RETURN;
                  FStar_Syntax_Syntax.TRIVIAL_POSTCONDITION]
              | f -> [f]))
  
let (weaken_comp :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.comp ->
      FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.comp)
  =
  fun env  ->
    fun c  ->
      fun formula  ->
        let uu____4671 = FStar_Syntax_Util.is_ml_comp c  in
        if uu____4671
        then c
        else
          (let c1 = FStar_TypeChecker_Env.unfold_effect_abbrev env c  in
           let uu____4674 = destruct_comp c1  in
           match uu____4674 with
           | (u_res_t,res_t,wp) ->
               let md =
                 FStar_TypeChecker_Env.get_effect_decl env
                   c1.FStar_Syntax_Syntax.effect_name
                  in
               let wp1 =
                 let uu____4688 =
                   let uu____4689 =
                     FStar_TypeChecker_Env.inst_effect_fun_with [u_res_t] env
                       md md.FStar_Syntax_Syntax.assume_p
                      in
                   let uu____4690 =
                     let uu____4691 = FStar_Syntax_Syntax.as_arg res_t  in
                     let uu____4692 =
                       let uu____4695 = FStar_Syntax_Syntax.as_arg formula
                          in
                       let uu____4696 =
                         let uu____4699 = FStar_Syntax_Syntax.as_arg wp  in
                         [uu____4699]  in
                       uu____4695 :: uu____4696  in
                     uu____4691 :: uu____4692  in
                   FStar_Syntax_Syntax.mk_Tm_app uu____4689 uu____4690  in
                 uu____4688 FStar_Pervasives_Native.None
                   wp.FStar_Syntax_Syntax.pos
                  in
               let uu____4702 = weaken_flags c1.FStar_Syntax_Syntax.flags  in
               mk_comp md u_res_t res_t wp1 uu____4702)
  
let (weaken_precondition :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.lcomp ->
      FStar_TypeChecker_Common.guard_formula -> FStar_Syntax_Syntax.lcomp)
  =
  fun env  ->
    fun lc  ->
      fun f  ->
        let weaken uu____4717 =
          let c = FStar_Syntax_Syntax.lcomp_comp lc  in
          let uu____4719 =
            env.FStar_TypeChecker_Env.lax && (FStar_Options.ml_ish ())  in
          if uu____4719
          then c
          else
            (match f with
             | FStar_TypeChecker_Common.Trivial  -> c
             | FStar_TypeChecker_Common.NonTrivial f1 -> weaken_comp env c f1)
           in
        let uu____4722 = weaken_flags lc.FStar_Syntax_Syntax.cflags  in
        FStar_Syntax_Syntax.mk_lcomp lc.FStar_Syntax_Syntax.eff_name
          lc.FStar_Syntax_Syntax.res_typ uu____4722 weaken
  
let (strengthen_comp :
  FStar_TypeChecker_Env.env ->
    (Prims.unit -> Prims.string) FStar_Pervasives_Native.option ->
      FStar_Syntax_Syntax.comp ->
        FStar_Syntax_Syntax.formula ->
          FStar_Syntax_Syntax.cflags Prims.list -> FStar_Syntax_Syntax.comp)
  =
  fun env  ->
    fun reason  ->
      fun c  ->
        fun f  ->
          fun flags1  ->
            if env.FStar_TypeChecker_Env.lax
            then c
            else
              (let c1 = FStar_TypeChecker_Env.unfold_effect_abbrev env c  in
               let uu____4755 = destruct_comp c1  in
               match uu____4755 with
               | (u_res_t,res_t,wp) ->
                   let md =
                     FStar_TypeChecker_Env.get_effect_decl env
                       c1.FStar_Syntax_Syntax.effect_name
                      in
                   let wp1 =
                     let uu____4769 =
                       let uu____4770 =
                         FStar_TypeChecker_Env.inst_effect_fun_with [u_res_t]
                           env md md.FStar_Syntax_Syntax.assert_p
                          in
                       let uu____4771 =
                         let uu____4772 = FStar_Syntax_Syntax.as_arg res_t
                            in
                         let uu____4773 =
                           let uu____4776 =
                             let uu____4777 =
                               let uu____4778 =
                                 FStar_TypeChecker_Env.get_range env  in
                               label_opt env reason uu____4778 f  in
                             FStar_All.pipe_left FStar_Syntax_Syntax.as_arg
                               uu____4777
                              in
                           let uu____4779 =
                             let uu____4782 = FStar_Syntax_Syntax.as_arg wp
                                in
                             [uu____4782]  in
                           uu____4776 :: uu____4779  in
                         uu____4772 :: uu____4773  in
                       FStar_Syntax_Syntax.mk_Tm_app uu____4770 uu____4771
                        in
                     uu____4769 FStar_Pervasives_Native.None
                       wp.FStar_Syntax_Syntax.pos
                      in
                   mk_comp md u_res_t res_t wp1 flags1)
  
let (strengthen_precondition :
  (Prims.unit -> Prims.string) FStar_Pervasives_Native.option ->
    FStar_TypeChecker_Env.env ->
      FStar_Syntax_Syntax.term ->
        FStar_Syntax_Syntax.lcomp ->
          FStar_TypeChecker_Env.guard_t ->
            (FStar_Syntax_Syntax.lcomp,FStar_TypeChecker_Env.guard_t)
              FStar_Pervasives_Native.tuple2)
  =
  fun reason  ->
    fun env  ->
      fun e_for_debug_only  ->
        fun lc  ->
          fun g0  ->
            let uu____4817 = FStar_TypeChecker_Rel.is_trivial g0  in
            if uu____4817
            then (lc, g0)
            else
              (let flags1 =
                 let uu____4826 =
                   let uu____4833 = FStar_Syntax_Util.is_tot_or_gtot_lcomp lc
                      in
                   if uu____4833
                   then (true, [FStar_Syntax_Syntax.TRIVIAL_POSTCONDITION])
                   else (false, [])  in
                 match uu____4826 with
                 | (maybe_trivial_post,flags1) ->
                     let uu____4853 =
                       FStar_All.pipe_right lc.FStar_Syntax_Syntax.cflags
                         (FStar_List.collect
                            (fun uu___81_4861  ->
                               match uu___81_4861 with
                               | FStar_Syntax_Syntax.RETURN  ->
                                   [FStar_Syntax_Syntax.PARTIAL_RETURN]
                               | FStar_Syntax_Syntax.PARTIAL_RETURN  ->
                                   [FStar_Syntax_Syntax.PARTIAL_RETURN]
                               | FStar_Syntax_Syntax.SOMETRIVIAL  when
                                   Prims.op_Negation maybe_trivial_post ->
                                   [FStar_Syntax_Syntax.TRIVIAL_POSTCONDITION]
                               | FStar_Syntax_Syntax.TRIVIAL_POSTCONDITION 
                                   when Prims.op_Negation maybe_trivial_post
                                   ->
                                   [FStar_Syntax_Syntax.TRIVIAL_POSTCONDITION]
                               | FStar_Syntax_Syntax.SHOULD_NOT_INLINE  ->
                                   [FStar_Syntax_Syntax.SHOULD_NOT_INLINE]
                               | uu____4864 -> []))
                        in
                     FStar_List.append flags1 uu____4853
                  in
               let strengthen uu____4868 =
                 let c = FStar_Syntax_Syntax.lcomp_comp lc  in
                 if env.FStar_TypeChecker_Env.lax
                 then c
                 else
                   (let g01 = FStar_TypeChecker_Rel.simplify_guard env g0  in
                    let uu____4872 = FStar_TypeChecker_Rel.guard_form g01  in
                    match uu____4872 with
                    | FStar_TypeChecker_Common.Trivial  -> c
                    | FStar_TypeChecker_Common.NonTrivial f ->
                        ((let uu____4875 =
                            FStar_All.pipe_left
                              (FStar_TypeChecker_Env.debug env)
                              FStar_Options.Extreme
                             in
                          if uu____4875
                          then
                            let uu____4876 =
                              FStar_TypeChecker_Normalize.term_to_string env
                                e_for_debug_only
                               in
                            let uu____4877 =
                              FStar_TypeChecker_Normalize.term_to_string env
                                f
                               in
                            FStar_Util.print2
                              "-------------Strengthening pre-condition of term %s with guard %s\n"
                              uu____4876 uu____4877
                          else ());
                         strengthen_comp env reason c f flags1))
                  in
               let uu____4879 =
                 let uu____4880 =
                   FStar_TypeChecker_Env.norm_eff_name env
                     lc.FStar_Syntax_Syntax.eff_name
                    in
                 FStar_Syntax_Syntax.mk_lcomp uu____4880
                   lc.FStar_Syntax_Syntax.res_typ flags1 strengthen
                  in
               (uu____4879,
                 (let uu___106_4882 = g0  in
                  {
                    FStar_TypeChecker_Env.guard_f =
                      FStar_TypeChecker_Common.Trivial;
                    FStar_TypeChecker_Env.deferred =
                      (uu___106_4882.FStar_TypeChecker_Env.deferred);
                    FStar_TypeChecker_Env.univ_ineqs =
                      (uu___106_4882.FStar_TypeChecker_Env.univ_ineqs);
                    FStar_TypeChecker_Env.implicits =
                      (uu___106_4882.FStar_TypeChecker_Env.implicits)
                  })))
  
let (lcomp_has_trivial_postcondition :
  FStar_Syntax_Syntax.lcomp -> Prims.bool) =
  fun lc  ->
    (FStar_Syntax_Util.is_tot_or_gtot_lcomp lc) ||
      (FStar_Util.for_some
         (fun uu___82_4887  ->
            match uu___82_4887 with
            | FStar_Syntax_Syntax.SOMETRIVIAL  -> true
            | FStar_Syntax_Syntax.TRIVIAL_POSTCONDITION  -> true
            | uu____4888 -> false) lc.FStar_Syntax_Syntax.cflags)
  
let (maybe_add_with_type :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.universe FStar_Pervasives_Native.option ->
      FStar_Syntax_Syntax.lcomp ->
        FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term)
  =
  fun env  ->
    fun uopt  ->
      fun lc  ->
        fun e  ->
          let uu____4905 =
            (FStar_Syntax_Util.is_lcomp_partial_return lc) ||
              env.FStar_TypeChecker_Env.lax
             in
          if uu____4905
          then e
          else
            (let uu____4907 =
               (lcomp_has_trivial_postcondition lc) &&
                 (let uu____4909 =
                    FStar_TypeChecker_Env.try_lookup_lid env
                      FStar_Parser_Const.with_type_lid
                     in
                  FStar_Option.isSome uu____4909)
                in
             if uu____4907
             then
               let u =
                 match uopt with
                 | FStar_Pervasives_Native.Some u -> u
                 | FStar_Pervasives_Native.None  ->
                     env.FStar_TypeChecker_Env.universe_of env
                       lc.FStar_Syntax_Syntax.res_typ
                  in
               FStar_Syntax_Util.mk_with_type u
                 lc.FStar_Syntax_Syntax.res_typ e
             else e)
  
let (bind :
  FStar_Range.range ->
    FStar_TypeChecker_Env.env ->
      FStar_Syntax_Syntax.term FStar_Pervasives_Native.option ->
        FStar_Syntax_Syntax.lcomp ->
          lcomp_with_binder -> FStar_Syntax_Syntax.lcomp)
  =
  fun r1  ->
    fun env  ->
      fun e1opt  ->
        fun lc1  ->
          fun uu____4947  ->
            match uu____4947 with
            | (b,lc2) ->
                let debug1 f =
                  let uu____4965 =
                    (FStar_TypeChecker_Env.debug env FStar_Options.Extreme)
                      ||
                      (FStar_All.pipe_left (FStar_TypeChecker_Env.debug env)
                         (FStar_Options.Other "bind"))
                     in
                  if uu____4965 then f () else ()  in
                (debug1
                   (fun uu____4976  ->
                      let uu____4977 = FStar_Syntax_Print.lcomp_to_string lc1
                         in
                      let uu____4978 =
                        match b with
                        | FStar_Pervasives_Native.Some bv ->
                            FStar_Syntax_Print.bv_to_string bv
                        | FStar_Pervasives_Native.None  -> "(none"  in
                      let uu____4980 = FStar_Syntax_Print.lcomp_to_string lc2
                         in
                      FStar_Util.print3
                        "(0) bind:\n\tlc1 = %s\n\tb=%s\n\tlc2=%s\n"
                        uu____4977 uu____4978 uu____4980);
                 (let lc11 =
                    FStar_TypeChecker_Normalize.ghost_to_pure_lcomp env lc1
                     in
                  let lc21 =
                    FStar_TypeChecker_Normalize.ghost_to_pure_lcomp env lc2
                     in
                  let joined_eff = join_lcomp env lc11 lc21  in
                  let bind_flags =
                    let uu____4987 =
                      (should_not_inline_lc lc11) ||
                        (should_not_inline_lc lc21)
                       in
                    if uu____4987
                    then [FStar_Syntax_Syntax.SHOULD_NOT_INLINE]
                    else
                      (let flags1 =
                         let uu____4994 =
                           FStar_Syntax_Util.is_total_lcomp lc11  in
                         if uu____4994
                         then
                           let uu____4997 =
                             FStar_Syntax_Util.is_total_lcomp lc21  in
                           (if uu____4997
                            then [FStar_Syntax_Syntax.TOTAL]
                            else
                              (let uu____5001 =
                                 FStar_Syntax_Util.is_tot_or_gtot_lcomp lc21
                                  in
                               if uu____5001
                               then [FStar_Syntax_Syntax.SOMETRIVIAL]
                               else []))
                         else
                           (let uu____5006 =
                              (FStar_Syntax_Util.is_tot_or_gtot_lcomp lc11)
                                &&
                                (FStar_Syntax_Util.is_tot_or_gtot_lcomp lc21)
                               in
                            if uu____5006
                            then [FStar_Syntax_Syntax.SOMETRIVIAL]
                            else [])
                          in
                       let uu____5010 = lcomp_has_trivial_postcondition lc21
                          in
                       if uu____5010
                       then FStar_Syntax_Syntax.TRIVIAL_POSTCONDITION ::
                         flags1
                       else flags1)
                     in
                  let bind_it uu____5017 =
                    let uu____5018 =
                      env.FStar_TypeChecker_Env.lax &&
                        (FStar_Options.ml_ish ())
                       in
                    if uu____5018
                    then
                      let u_t =
                        env.FStar_TypeChecker_Env.universe_of env
                          lc21.FStar_Syntax_Syntax.res_typ
                         in
                      lax_mk_tot_or_comp_l joined_eff u_t
                        lc21.FStar_Syntax_Syntax.res_typ []
                    else
                      (let c1 = FStar_Syntax_Syntax.lcomp_comp lc11  in
                       let c2 = FStar_Syntax_Syntax.lcomp_comp lc21  in
                       debug1
                         (fun uu____5032  ->
                            let uu____5033 =
                              FStar_Syntax_Print.comp_to_string c1  in
                            let uu____5034 =
                              match b with
                              | FStar_Pervasives_Native.None  -> "none"
                              | FStar_Pervasives_Native.Some x ->
                                  FStar_Syntax_Print.bv_to_string x
                               in
                            let uu____5036 =
                              FStar_Syntax_Print.comp_to_string c2  in
                            FStar_Util.print3
                              "(1) bind: \n\tc1=%s\n\tx=%s\n\tc2=%s\n(1. end bind)\n"
                              uu____5033 uu____5034 uu____5036);
                       (let aux uu____5048 =
                          let uu____5049 = FStar_Syntax_Util.is_trivial_wp c1
                             in
                          if uu____5049
                          then
                            match b with
                            | FStar_Pervasives_Native.None  ->
                                FStar_Util.Inl (c2, "trivial no binder")
                            | FStar_Pervasives_Native.Some uu____5070 ->
                                let uu____5071 =
                                  FStar_Syntax_Util.is_ml_comp c2  in
                                (if uu____5071
                                 then FStar_Util.Inl (c2, "trivial ml")
                                 else
                                   FStar_Util.Inr
                                     "c1 trivial; but c2 is not ML")
                          else
                            (let uu____5090 =
                               (FStar_Syntax_Util.is_ml_comp c1) &&
                                 (FStar_Syntax_Util.is_ml_comp c2)
                                in
                             if uu____5090
                             then FStar_Util.Inl (c2, "both ml")
                             else
                               FStar_Util.Inr
                                 "c1 not trivial, and both are not ML")
                           in
                        let subst_c2 e1opt1 reason =
                          match (e1opt1, b) with
                          | (FStar_Pervasives_Native.Some
                             e,FStar_Pervasives_Native.Some x) ->
                              let uu____5157 =
                                let uu____5162 =
                                  FStar_Syntax_Subst.subst_comp
                                    [FStar_Syntax_Syntax.NT (x, e)] c2
                                   in
                                (uu____5162, reason)  in
                              FStar_Util.Inl uu____5157
                          | uu____5169 -> aux ()  in
                        let try_simplify uu____5191 =
                          let rec maybe_close t x c =
                            let uu____5202 =
                              let uu____5203 =
                                FStar_TypeChecker_Normalize.unfold_whnf env t
                                 in
                              uu____5203.FStar_Syntax_Syntax.n  in
                            match uu____5202 with
                            | FStar_Syntax_Syntax.Tm_refine (y,uu____5207) ->
                                maybe_close y.FStar_Syntax_Syntax.sort x c
                            | FStar_Syntax_Syntax.Tm_fvar fv when
                                FStar_Syntax_Syntax.fv_eq_lid fv
                                  FStar_Parser_Const.unit_lid
                                -> close_comp env [x] c
                            | uu____5213 -> c  in
                          let uu____5214 =
                            let uu____5215 =
                              FStar_TypeChecker_Env.try_lookup_effect_lid env
                                FStar_Parser_Const.effect_GTot_lid
                               in
                            FStar_Option.isNone uu____5215  in
                          if uu____5214
                          then
                            let uu____5226 =
                              (FStar_Syntax_Util.is_tot_or_gtot_comp c1) &&
                                (FStar_Syntax_Util.is_tot_or_gtot_comp c2)
                               in
                            (if uu____5226
                             then
                               FStar_Util.Inl
                                 (c2,
                                   "Early in prims; we don't have bind yet")
                             else
                               (let uu____5240 =
                                  FStar_TypeChecker_Env.get_range env  in
                                FStar_Errors.raise_error
                                  (FStar_Errors.Fatal_NonTrivialPreConditionInPrims,
                                    "Non-trivial pre-conditions very early in prims, even before we have defined the PURE monad")
                                  uu____5240))
                          else
                            (let uu____5250 =
                               (FStar_Syntax_Util.is_total_comp c1) &&
                                 (FStar_Syntax_Util.is_total_comp c2)
                                in
                             if uu____5250
                             then subst_c2 e1opt "both total"
                             else
                               (let uu____5260 =
                                  (FStar_Syntax_Util.is_tot_or_gtot_comp c1)
                                    &&
                                    (FStar_Syntax_Util.is_tot_or_gtot_comp c2)
                                   in
                                if uu____5260
                                then
                                  let uu____5269 =
                                    let uu____5274 =
                                      FStar_Syntax_Syntax.mk_GTotal
                                        (FStar_Syntax_Util.comp_result c2)
                                       in
                                    (uu____5274, "both gtot")  in
                                  FStar_Util.Inl uu____5269
                                else
                                  (match (e1opt, b) with
                                   | (FStar_Pervasives_Native.Some
                                      e,FStar_Pervasives_Native.Some x) ->
                                       let uu____5298 =
                                         (FStar_Syntax_Util.is_total_comp c1)
                                           &&
                                           (let uu____5300 =
                                              FStar_Syntax_Syntax.is_null_bv
                                                x
                                               in
                                            Prims.op_Negation uu____5300)
                                          in
                                       if uu____5298
                                       then
                                         let c21 =
                                           FStar_Syntax_Subst.subst_comp
                                             [FStar_Syntax_Syntax.NT (x, e)]
                                             c2
                                            in
                                         let x1 =
                                           let uu___107_5311 = x  in
                                           {
                                             FStar_Syntax_Syntax.ppname =
                                               (uu___107_5311.FStar_Syntax_Syntax.ppname);
                                             FStar_Syntax_Syntax.index =
                                               (uu___107_5311.FStar_Syntax_Syntax.index);
                                             FStar_Syntax_Syntax.sort =
                                               (FStar_Syntax_Util.comp_result
                                                  c1)
                                           }  in
                                         let uu____5312 =
                                           let uu____5317 =
                                             maybe_close
                                               x1.FStar_Syntax_Syntax.sort x1
                                               c21
                                              in
                                           (uu____5317, "c1 Tot")  in
                                         FStar_Util.Inl uu____5312
                                       else aux ()
                                   | uu____5323 -> aux ())))
                           in
                        let uu____5332 = try_simplify ()  in
                        match uu____5332 with
                        | FStar_Util.Inl (c,reason) ->
                            (debug1
                               (fun uu____5352  ->
                                  let uu____5353 =
                                    FStar_Syntax_Print.comp_to_string c  in
                                  FStar_Util.print2
                                    "(2) bind: Simplified (because %s) to\n\t%s\n"
                                    reason uu____5353);
                             c)
                        | FStar_Util.Inr reason ->
                            (debug1
                               (fun uu____5362  ->
                                  FStar_Util.print1
                                    "(2) bind: Not simplified because %s\n"
                                    reason);
                             (let mk_bind c11 b1 c21 =
                                let uu____5377 =
                                  lift_and_destruct env c11 c21  in
                                match uu____5377 with
                                | ((md,a,kwp),(u_t1,t1,wp1),(u_t2,t2,wp2)) ->
                                    let bs =
                                      match b1 with
                                      | FStar_Pervasives_Native.None  ->
                                          let uu____5434 =
                                            FStar_Syntax_Syntax.null_binder
                                              t1
                                             in
                                          [uu____5434]
                                      | FStar_Pervasives_Native.Some x ->
                                          let uu____5436 =
                                            FStar_Syntax_Syntax.mk_binder x
                                             in
                                          [uu____5436]
                                       in
                                    let mk_lam wp =
                                      FStar_Syntax_Util.abs bs wp
                                        (FStar_Pervasives_Native.Some
                                           (FStar_Syntax_Util.mk_residual_comp
                                              FStar_Parser_Const.effect_Tot_lid
                                              FStar_Pervasives_Native.None
                                              [FStar_Syntax_Syntax.TOTAL]))
                                       in
                                    let r11 =
                                      FStar_Syntax_Syntax.mk
                                        (FStar_Syntax_Syntax.Tm_constant
                                           (FStar_Const.Const_range r1))
                                        FStar_Pervasives_Native.None r1
                                       in
                                    let wp_args =
                                      let uu____5449 =
                                        FStar_Syntax_Syntax.as_arg r11  in
                                      let uu____5450 =
                                        let uu____5453 =
                                          FStar_Syntax_Syntax.as_arg t1  in
                                        let uu____5454 =
                                          let uu____5457 =
                                            FStar_Syntax_Syntax.as_arg t2  in
                                          let uu____5458 =
                                            let uu____5461 =
                                              FStar_Syntax_Syntax.as_arg wp1
                                               in
                                            let uu____5462 =
                                              let uu____5465 =
                                                let uu____5466 = mk_lam wp2
                                                   in
                                                FStar_Syntax_Syntax.as_arg
                                                  uu____5466
                                                 in
                                              [uu____5465]  in
                                            uu____5461 :: uu____5462  in
                                          uu____5457 :: uu____5458  in
                                        uu____5453 :: uu____5454  in
                                      uu____5449 :: uu____5450  in
                                    let wp =
                                      let uu____5470 =
                                        let uu____5471 =
                                          FStar_TypeChecker_Env.inst_effect_fun_with
                                            [u_t1; u_t2] env md
                                            md.FStar_Syntax_Syntax.bind_wp
                                           in
                                        FStar_Syntax_Syntax.mk_Tm_app
                                          uu____5471 wp_args
                                         in
                                      uu____5470 FStar_Pervasives_Native.None
                                        t2.FStar_Syntax_Syntax.pos
                                       in
                                    mk_comp md u_t2 t2 wp bind_flags
                                 in
                              let mk_seq c11 b1 c21 =
                                let c12 =
                                  FStar_TypeChecker_Env.unfold_effect_abbrev
                                    env c11
                                   in
                                let c22 =
                                  FStar_TypeChecker_Env.unfold_effect_abbrev
                                    env c21
                                   in
                                let uu____5490 =
                                  FStar_TypeChecker_Env.join env
                                    c12.FStar_Syntax_Syntax.effect_name
                                    c22.FStar_Syntax_Syntax.effect_name
                                   in
                                match uu____5490 with
                                | (m,uu____5498,lift2) ->
                                    let c23 =
                                      let uu____5501 = lift_comp c22 m lift2
                                         in
                                      FStar_Syntax_Syntax.mk_Comp uu____5501
                                       in
                                    let uu____5502 = destruct_comp c12  in
                                    (match uu____5502 with
                                     | (u1,t1,wp1) ->
                                         let md_pure_or_ghost =
                                           FStar_TypeChecker_Env.get_effect_decl
                                             env
                                             c12.FStar_Syntax_Syntax.effect_name
                                            in
                                         let vc1 =
                                           let uu____5516 =
                                             let uu____5517 =
                                               FStar_TypeChecker_Env.inst_effect_fun_with
                                                 [u1] env md_pure_or_ghost
                                                 md_pure_or_ghost.FStar_Syntax_Syntax.trivial
                                                in
                                             let uu____5518 =
                                               let uu____5519 =
                                                 FStar_Syntax_Syntax.as_arg
                                                   t1
                                                  in
                                               let uu____5520 =
                                                 let uu____5523 =
                                                   FStar_Syntax_Syntax.as_arg
                                                     wp1
                                                    in
                                                 [uu____5523]  in
                                               uu____5519 :: uu____5520  in
                                             FStar_Syntax_Syntax.mk_Tm_app
                                               uu____5517 uu____5518
                                              in
                                           uu____5516
                                             FStar_Pervasives_Native.None r1
                                            in
                                         strengthen_comp env
                                           FStar_Pervasives_Native.None c23
                                           vc1 bind_flags)
                                 in
                              let c1_typ =
                                FStar_TypeChecker_Env.unfold_effect_abbrev
                                  env c1
                                 in
                              let uu____5529 = destruct_comp c1_typ  in
                              match uu____5529 with
                              | (u_res_t1,res_t1,uu____5538) ->
                                  let uu____5539 =
                                    (FStar_Option.isSome b) &&
                                      (should_return env e1opt lc11)
                                     in
                                  if uu____5539
                                  then
                                    let e1 = FStar_Option.get e1opt  in
                                    let x = FStar_Option.get b  in
                                    let uu____5542 =
                                      FStar_Syntax_Util.is_partial_return c1
                                       in
                                    (if uu____5542
                                     then
                                       (debug1
                                          (fun uu____5550  ->
                                             let uu____5551 =
                                               FStar_TypeChecker_Normalize.term_to_string
                                                 env e1
                                                in
                                             let uu____5552 =
                                               FStar_Syntax_Print.bv_to_string
                                                 x
                                                in
                                             FStar_Util.print2
                                               "(3) bind (case a): Substituting %s for %s"
                                               uu____5551 uu____5552);
                                        (let c21 =
                                           FStar_Syntax_Subst.subst_comp
                                             [FStar_Syntax_Syntax.NT (x, e1)]
                                             c2
                                            in
                                         mk_bind c1 b c21))
                                     else
                                       (let uu____5555 =
                                          ((FStar_Options.vcgen_optimize_bind_as_seq
                                              ())
                                             &&
                                             (lcomp_has_trivial_postcondition
                                                lc11))
                                            &&
                                            (let uu____5557 =
                                               FStar_TypeChecker_Env.try_lookup_lid
                                                 env
                                                 FStar_Parser_Const.with_type_lid
                                                in
                                             FStar_Option.isSome uu____5557)
                                           in
                                        if uu____5555
                                        then
                                          let e1' =
                                            let uu____5579 =
                                              FStar_Options.vcgen_decorate_with_type
                                                ()
                                               in
                                            if uu____5579
                                            then
                                              FStar_Syntax_Util.mk_with_type
                                                u_res_t1 res_t1 e1
                                            else e1  in
                                          (debug1
                                             (fun uu____5590  ->
                                                let uu____5591 =
                                                  FStar_TypeChecker_Normalize.term_to_string
                                                    env e1'
                                                   in
                                                let uu____5592 =
                                                  FStar_Syntax_Print.bv_to_string
                                                    x
                                                   in
                                                FStar_Util.print2
                                                  "(3) bind (case b): Substituting %s for %s"
                                                  uu____5591 uu____5592);
                                           (let c21 =
                                              FStar_Syntax_Subst.subst_comp
                                                [FStar_Syntax_Syntax.NT
                                                   (x, e1')] c2
                                               in
                                            mk_seq c1 b c21))
                                        else
                                          (debug1
                                             (fun uu____5604  ->
                                                let uu____5605 =
                                                  FStar_TypeChecker_Normalize.term_to_string
                                                    env e1
                                                   in
                                                let uu____5606 =
                                                  FStar_Syntax_Print.bv_to_string
                                                    x
                                                   in
                                                FStar_Util.print2
                                                  "(3) bind (case c): Adding equality %s = %s"
                                                  uu____5605 uu____5606);
                                           (let c21 =
                                              FStar_Syntax_Subst.subst_comp
                                                [FStar_Syntax_Syntax.NT
                                                   (x, e1)] c2
                                               in
                                            let x_eq_e =
                                              let uu____5609 =
                                                FStar_Syntax_Syntax.bv_to_name
                                                  x
                                                 in
                                              FStar_Syntax_Util.mk_eq2
                                                u_res_t1 res_t1 e1 uu____5609
                                               in
                                            let c22 =
                                              weaken_comp env c21 x_eq_e  in
                                            mk_bind c1 b c22))))
                                  else mk_bind c1 b c2))))
                     in
                  FStar_Syntax_Syntax.mk_lcomp joined_eff
                    lc21.FStar_Syntax_Syntax.res_typ bind_flags bind_it))
  
let (weaken_guard :
  FStar_TypeChecker_Common.guard_formula ->
    FStar_TypeChecker_Common.guard_formula ->
      FStar_TypeChecker_Common.guard_formula)
  =
  fun g1  ->
    fun g2  ->
      match (g1, g2) with
      | (FStar_TypeChecker_Common.NonTrivial
         f1,FStar_TypeChecker_Common.NonTrivial f2) ->
          let g = FStar_Syntax_Util.mk_imp f1 f2  in
          FStar_TypeChecker_Common.NonTrivial g
      | uu____5621 -> g2
  
let (maybe_assume_result_eq_pure_term :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.lcomp -> FStar_Syntax_Syntax.lcomp)
  =
  fun env  ->
    fun e  ->
      fun lc  ->
        let should_return1 =
          (((Prims.op_Negation env.FStar_TypeChecker_Env.lax) &&
              (FStar_TypeChecker_Env.lid_exists env
                 FStar_Parser_Const.effect_GTot_lid))
             && (should_return env (FStar_Pervasives_Native.Some e) lc))
            &&
            (let uu____5637 = FStar_Syntax_Util.is_lcomp_partial_return lc
                in
             Prims.op_Negation uu____5637)
           in
        let flags1 =
          if should_return1
          then
            let uu____5643 = FStar_Syntax_Util.is_total_lcomp lc  in
            (if uu____5643
             then FStar_Syntax_Syntax.RETURN ::
               (lc.FStar_Syntax_Syntax.cflags)
             else FStar_Syntax_Syntax.PARTIAL_RETURN ::
               (lc.FStar_Syntax_Syntax.cflags))
          else lc.FStar_Syntax_Syntax.cflags  in
        let refine1 uu____5651 =
          let c = FStar_Syntax_Syntax.lcomp_comp lc  in
          let u_t =
            match comp_univ_opt c with
            | FStar_Pervasives_Native.Some u_t -> u_t
            | FStar_Pervasives_Native.None  ->
                env.FStar_TypeChecker_Env.universe_of env
                  (FStar_Syntax_Util.comp_result c)
             in
          let uu____5655 = FStar_Syntax_Util.is_tot_or_gtot_comp c  in
          if uu____5655
          then
            let retc =
              return_value env (FStar_Pervasives_Native.Some u_t)
                (FStar_Syntax_Util.comp_result c) e
               in
            let uu____5657 =
              let uu____5658 = FStar_Syntax_Util.is_pure_comp c  in
              Prims.op_Negation uu____5658  in
            (if uu____5657
             then
               let retc1 = FStar_Syntax_Util.comp_to_comp_typ retc  in
               let retc2 =
                 let uu___108_5661 = retc1  in
                 {
                   FStar_Syntax_Syntax.comp_univs =
                     (uu___108_5661.FStar_Syntax_Syntax.comp_univs);
                   FStar_Syntax_Syntax.effect_name =
                     FStar_Parser_Const.effect_GHOST_lid;
                   FStar_Syntax_Syntax.result_typ =
                     (uu___108_5661.FStar_Syntax_Syntax.result_typ);
                   FStar_Syntax_Syntax.effect_args =
                     (uu___108_5661.FStar_Syntax_Syntax.effect_args);
                   FStar_Syntax_Syntax.flags = flags1
                 }  in
               FStar_Syntax_Syntax.mk_Comp retc2
             else FStar_Syntax_Util.comp_set_flags retc flags1)
          else
            (let c1 = FStar_TypeChecker_Env.unfold_effect_abbrev env c  in
             let t = c1.FStar_Syntax_Syntax.result_typ  in
             let c2 = FStar_Syntax_Syntax.mk_Comp c1  in
             let x =
               FStar_Syntax_Syntax.new_bv
                 (FStar_Pervasives_Native.Some (t.FStar_Syntax_Syntax.pos)) t
                in
             let xexp = FStar_Syntax_Syntax.bv_to_name x  in
             let ret1 =
               let uu____5672 =
                 let uu____5675 =
                   return_value env (FStar_Pervasives_Native.Some u_t) t xexp
                    in
                 FStar_Syntax_Util.comp_set_flags uu____5675
                   [FStar_Syntax_Syntax.PARTIAL_RETURN]
                  in
               FStar_All.pipe_left FStar_Syntax_Util.lcomp_of_comp uu____5672
                in
             let eq1 = FStar_Syntax_Util.mk_eq2 u_t t xexp e  in
             let eq_ret =
               weaken_precondition env ret1
                 (FStar_TypeChecker_Common.NonTrivial eq1)
                in
             let uu____5680 =
               let uu____5681 =
                 let uu____5682 = FStar_Syntax_Util.lcomp_of_comp c2  in
                 bind e.FStar_Syntax_Syntax.pos env
                   FStar_Pervasives_Native.None uu____5682
                   ((FStar_Pervasives_Native.Some x), eq_ret)
                  in
               FStar_Syntax_Syntax.lcomp_comp uu____5681  in
             FStar_Syntax_Util.comp_set_flags uu____5680 flags1)
           in
        if Prims.op_Negation should_return1
        then lc
        else
          FStar_Syntax_Syntax.mk_lcomp lc.FStar_Syntax_Syntax.eff_name
            lc.FStar_Syntax_Syntax.res_typ flags1 refine1
  
let (maybe_return_e2_and_bind :
  FStar_Range.range ->
    FStar_TypeChecker_Env.env ->
      FStar_Syntax_Syntax.term FStar_Pervasives_Native.option ->
        FStar_Syntax_Syntax.lcomp ->
          FStar_Syntax_Syntax.term ->
            lcomp_with_binder -> FStar_Syntax_Syntax.lcomp)
  =
  fun r  ->
    fun env  ->
      fun e1opt  ->
        fun lc1  ->
          fun e2  ->
            fun uu____5705  ->
              match uu____5705 with
              | (x,lc2) ->
                  let lc21 =
                    let eff1 =
                      FStar_TypeChecker_Env.norm_eff_name env
                        lc1.FStar_Syntax_Syntax.eff_name
                       in
                    let eff2 =
                      FStar_TypeChecker_Env.norm_eff_name env
                        lc2.FStar_Syntax_Syntax.eff_name
                       in
                    let uu____5717 =
                      ((let uu____5720 = is_pure_or_ghost_effect env eff1  in
                        Prims.op_Negation uu____5720) ||
                         (should_not_inline_lc lc1))
                        && (is_pure_or_ghost_effect env eff2)
                       in
                    if uu____5717
                    then maybe_assume_result_eq_pure_term env e2 lc2
                    else lc2  in
                  bind r env e1opt lc1 (x, lc21)
  
let (fvar_const :
  FStar_TypeChecker_Env.env -> FStar_Ident.lident -> FStar_Syntax_Syntax.term)
  =
  fun env  ->
    fun lid  ->
      let uu____5730 =
        let uu____5731 = FStar_TypeChecker_Env.get_range env  in
        FStar_Ident.set_lid_range lid uu____5731  in
      FStar_Syntax_Syntax.fvar uu____5730 FStar_Syntax_Syntax.Delta_constant
        FStar_Pervasives_Native.None
  
let (bind_cases :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.typ ->
      (FStar_Syntax_Syntax.typ,FStar_Ident.lident,FStar_Syntax_Syntax.cflags
                                                    Prims.list,Prims.bool ->
                                                                 FStar_Syntax_Syntax.lcomp)
        FStar_Pervasives_Native.tuple4 Prims.list ->
        FStar_Syntax_Syntax.lcomp)
  =
  fun env  ->
    fun res_t  ->
      fun lcases  ->
        let eff =
          FStar_List.fold_left
            (fun eff  ->
               fun uu____5790  ->
                 match uu____5790 with
                 | (uu____5803,eff_label,uu____5805,uu____5806) ->
                     join_effects env eff eff_label)
            FStar_Parser_Const.effect_PURE_lid lcases
           in
        let uu____5815 =
          let uu____5822 =
            FStar_All.pipe_right lcases
              (FStar_Util.for_some
                 (fun uu____5854  ->
                    match uu____5854 with
                    | (uu____5867,uu____5868,flags1,uu____5870) ->
                        FStar_All.pipe_right flags1
                          (FStar_Util.for_some
                             (fun uu___83_5882  ->
                                match uu___83_5882 with
                                | FStar_Syntax_Syntax.SHOULD_NOT_INLINE  ->
                                    true
                                | uu____5883 -> false))))
             in
          if uu____5822
          then (true, [FStar_Syntax_Syntax.SHOULD_NOT_INLINE])
          else (false, [])  in
        match uu____5815 with
        | (should_not_inline_whole_match,bind_cases_flags) ->
            let bind_cases uu____5904 =
              let u_res_t = env.FStar_TypeChecker_Env.universe_of env res_t
                 in
              let uu____5906 =
                env.FStar_TypeChecker_Env.lax && (FStar_Options.ml_ish ())
                 in
              if uu____5906
              then lax_mk_tot_or_comp_l eff u_res_t res_t []
              else
                (let ifthenelse md res_t1 g wp_t wp_e =
                   let uu____5926 =
                     FStar_Range.union_ranges wp_t.FStar_Syntax_Syntax.pos
                       wp_e.FStar_Syntax_Syntax.pos
                      in
                   let uu____5927 =
                     let uu____5928 =
                       FStar_TypeChecker_Env.inst_effect_fun_with [u_res_t]
                         env md md.FStar_Syntax_Syntax.if_then_else
                        in
                     let uu____5929 =
                       let uu____5930 = FStar_Syntax_Syntax.as_arg res_t1  in
                       let uu____5931 =
                         let uu____5934 = FStar_Syntax_Syntax.as_arg g  in
                         let uu____5935 =
                           let uu____5938 = FStar_Syntax_Syntax.as_arg wp_t
                              in
                           let uu____5939 =
                             let uu____5942 = FStar_Syntax_Syntax.as_arg wp_e
                                in
                             [uu____5942]  in
                           uu____5938 :: uu____5939  in
                         uu____5934 :: uu____5935  in
                       uu____5930 :: uu____5931  in
                     FStar_Syntax_Syntax.mk_Tm_app uu____5928 uu____5929  in
                   uu____5927 FStar_Pervasives_Native.None uu____5926  in
                 let default_case =
                   let post_k =
                     let uu____5949 =
                       let uu____5956 = FStar_Syntax_Syntax.null_binder res_t
                          in
                       [uu____5956]  in
                     let uu____5957 =
                       FStar_Syntax_Syntax.mk_Total FStar_Syntax_Util.ktype0
                        in
                     FStar_Syntax_Util.arrow uu____5949 uu____5957  in
                   let kwp =
                     let uu____5963 =
                       let uu____5970 =
                         FStar_Syntax_Syntax.null_binder post_k  in
                       [uu____5970]  in
                     let uu____5971 =
                       FStar_Syntax_Syntax.mk_Total FStar_Syntax_Util.ktype0
                        in
                     FStar_Syntax_Util.arrow uu____5963 uu____5971  in
                   let post =
                     FStar_Syntax_Syntax.new_bv FStar_Pervasives_Native.None
                       post_k
                      in
                   let wp =
                     let uu____5976 =
                       let uu____5977 = FStar_Syntax_Syntax.mk_binder post
                          in
                       [uu____5977]  in
                     let uu____5978 =
                       let uu____5979 =
                         let uu____5982 = FStar_TypeChecker_Env.get_range env
                            in
                         label FStar_TypeChecker_Err.exhaustiveness_check
                           uu____5982
                          in
                       let uu____5983 =
                         fvar_const env FStar_Parser_Const.false_lid  in
                       FStar_All.pipe_left uu____5979 uu____5983  in
                     FStar_Syntax_Util.abs uu____5976 uu____5978
                       (FStar_Pervasives_Native.Some
                          (FStar_Syntax_Util.mk_residual_comp
                             FStar_Parser_Const.effect_Tot_lid
                             FStar_Pervasives_Native.None
                             [FStar_Syntax_Syntax.TOTAL]))
                      in
                   let md =
                     FStar_TypeChecker_Env.get_effect_decl env
                       FStar_Parser_Const.effect_PURE_lid
                      in
                   mk_comp md u_res_t res_t wp []  in
                 let maybe_return eff_label_then cthen =
                   let uu____5999 =
                     should_not_inline_whole_match ||
                       (let uu____6001 = is_pure_or_ghost_effect env eff  in
                        Prims.op_Negation uu____6001)
                      in
                   if uu____5999 then cthen true else cthen false  in
                 let comp =
                   FStar_List.fold_right
                     (fun uu____6033  ->
                        fun celse  ->
                          match uu____6033 with
                          | (g,eff_label,uu____6049,cthen) ->
                              let uu____6059 =
                                let uu____6084 =
                                  let uu____6085 =
                                    maybe_return eff_label cthen  in
                                  FStar_Syntax_Syntax.lcomp_comp uu____6085
                                   in
                                lift_and_destruct env uu____6084 celse  in
                              (match uu____6059 with
                               | ((md,uu____6087,uu____6088),(uu____6089,uu____6090,wp_then),
                                  (uu____6092,uu____6093,wp_else)) ->
                                   let uu____6113 =
                                     ifthenelse md res_t g wp_then wp_else
                                      in
                                   mk_comp md u_res_t res_t uu____6113 []))
                     lcases default_case
                    in
                 match lcases with
                 | [] -> comp
                 | uu____6126::[] -> comp
                 | uu____6163 ->
                     let comp1 =
                       FStar_TypeChecker_Env.comp_to_comp_typ env comp  in
                     let md =
                       FStar_TypeChecker_Env.get_effect_decl env
                         comp1.FStar_Syntax_Syntax.effect_name
                        in
                     let uu____6180 = destruct_comp comp1  in
                     (match uu____6180 with
                      | (uu____6187,uu____6188,wp) ->
                          let wp1 =
                            let uu____6193 =
                              let uu____6194 =
                                FStar_TypeChecker_Env.inst_effect_fun_with
                                  [u_res_t] env md
                                  md.FStar_Syntax_Syntax.ite_wp
                                 in
                              let uu____6195 =
                                let uu____6196 =
                                  FStar_Syntax_Syntax.as_arg res_t  in
                                let uu____6197 =
                                  let uu____6200 =
                                    FStar_Syntax_Syntax.as_arg wp  in
                                  [uu____6200]  in
                                uu____6196 :: uu____6197  in
                              FStar_Syntax_Syntax.mk_Tm_app uu____6194
                                uu____6195
                               in
                            uu____6193 FStar_Pervasives_Native.None
                              wp.FStar_Syntax_Syntax.pos
                             in
                          mk_comp md u_res_t res_t wp1 bind_cases_flags))
               in
            FStar_Syntax_Syntax.mk_lcomp eff res_t bind_cases_flags
              bind_cases
  
let (check_comp :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.comp ->
        FStar_Syntax_Syntax.comp ->
          (FStar_Syntax_Syntax.term,FStar_Syntax_Syntax.comp,FStar_TypeChecker_Env.guard_t)
            FStar_Pervasives_Native.tuple3)
  =
  fun env  ->
    fun e  ->
      fun c  ->
        fun c'  ->
          let uu____6227 = FStar_TypeChecker_Rel.sub_comp env c c'  in
          match uu____6227 with
          | FStar_Pervasives_Native.None  ->
              let uu____6236 =
                FStar_TypeChecker_Err.computed_computation_type_does_not_match_annotation
                  env e c c'
                 in
              let uu____6241 = FStar_TypeChecker_Env.get_range env  in
              FStar_Errors.raise_error uu____6236 uu____6241
          | FStar_Pervasives_Native.Some g -> (e, c', g)
  
let (maybe_coerce_bool_to_type :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.lcomp ->
        FStar_Syntax_Syntax.typ ->
          (FStar_Syntax_Syntax.term,FStar_Syntax_Syntax.lcomp)
            FStar_Pervasives_Native.tuple2)
  =
  fun env  ->
    fun e  ->
      fun lc  ->
        fun t  ->
          let is_type1 t1 =
            let t2 = FStar_TypeChecker_Normalize.unfold_whnf env t1  in
            let uu____6274 =
              let uu____6275 = FStar_Syntax_Subst.compress t2  in
              uu____6275.FStar_Syntax_Syntax.n  in
            match uu____6274 with
            | FStar_Syntax_Syntax.Tm_type uu____6278 -> true
            | uu____6279 -> false  in
          let uu____6280 =
            let uu____6281 =
              FStar_Syntax_Util.unrefine lc.FStar_Syntax_Syntax.res_typ  in
            uu____6281.FStar_Syntax_Syntax.n  in
          match uu____6280 with
          | FStar_Syntax_Syntax.Tm_fvar fv when
              (FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.bool_lid)
                && (is_type1 t)
              ->
              let uu____6289 =
                FStar_TypeChecker_Env.lookup_lid env
                  FStar_Parser_Const.b2t_lid
                 in
              let b2t1 =
                let uu____6299 =
                  FStar_Ident.set_lid_range FStar_Parser_Const.b2t_lid
                    e.FStar_Syntax_Syntax.pos
                   in
                FStar_Syntax_Syntax.fvar uu____6299
                  (FStar_Syntax_Syntax.Delta_defined_at_level
                     (Prims.parse_int "1")) FStar_Pervasives_Native.None
                 in
              let lc1 =
                let uu____6301 =
                  let uu____6302 =
                    let uu____6303 =
                      FStar_Syntax_Syntax.mk_Total FStar_Syntax_Util.ktype0
                       in
                    FStar_All.pipe_left FStar_Syntax_Util.lcomp_of_comp
                      uu____6303
                     in
                  (FStar_Pervasives_Native.None, uu____6302)  in
                bind e.FStar_Syntax_Syntax.pos env
                  (FStar_Pervasives_Native.Some e) lc uu____6301
                 in
              let e1 =
                let uu____6313 =
                  let uu____6314 =
                    let uu____6315 = FStar_Syntax_Syntax.as_arg e  in
                    [uu____6315]  in
                  FStar_Syntax_Syntax.mk_Tm_app b2t1 uu____6314  in
                uu____6313 FStar_Pervasives_Native.None
                  e.FStar_Syntax_Syntax.pos
                 in
              (e1, lc1)
          | uu____6320 -> (e, lc)
  
let (weaken_result_typ :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.lcomp ->
        FStar_Syntax_Syntax.typ ->
          (FStar_Syntax_Syntax.term,FStar_Syntax_Syntax.lcomp,FStar_TypeChecker_Env.guard_t)
            FStar_Pervasives_Native.tuple3)
  =
  fun env  ->
    fun e  ->
      fun lc  ->
        fun t  ->
          let use_eq =
            env.FStar_TypeChecker_Env.use_eq ||
              (let uu____6349 =
                 FStar_TypeChecker_Env.effect_decl_opt env
                   lc.FStar_Syntax_Syntax.eff_name
                  in
               match uu____6349 with
               | FStar_Pervasives_Native.Some (ed,qualifiers) ->
                   FStar_All.pipe_right qualifiers
                     (FStar_List.contains FStar_Syntax_Syntax.Reifiable)
               | uu____6372 -> false)
             in
          let gopt =
            if use_eq
            then
              let uu____6394 =
                FStar_TypeChecker_Rel.try_teq true env
                  lc.FStar_Syntax_Syntax.res_typ t
                 in
              (uu____6394, false)
            else
              (let uu____6400 =
                 FStar_TypeChecker_Rel.get_subtyping_predicate env
                   lc.FStar_Syntax_Syntax.res_typ t
                  in
               (uu____6400, true))
             in
          match gopt with
          | (FStar_Pervasives_Native.None ,uu____6411) ->
              if env.FStar_TypeChecker_Env.failhard
              then
                let uu____6420 =
                  FStar_TypeChecker_Err.basic_type_error env
                    (FStar_Pervasives_Native.Some e) t
                    lc.FStar_Syntax_Syntax.res_typ
                   in
                FStar_Errors.raise_error uu____6420 e.FStar_Syntax_Syntax.pos
              else
                (FStar_TypeChecker_Rel.subtype_fail env e
                   lc.FStar_Syntax_Syntax.res_typ t;
                 (e,
                   ((let uu___109_6434 = lc  in
                     {
                       FStar_Syntax_Syntax.eff_name =
                         (uu___109_6434.FStar_Syntax_Syntax.eff_name);
                       FStar_Syntax_Syntax.res_typ = t;
                       FStar_Syntax_Syntax.cflags =
                         (uu___109_6434.FStar_Syntax_Syntax.cflags);
                       FStar_Syntax_Syntax.comp_thunk =
                         (uu___109_6434.FStar_Syntax_Syntax.comp_thunk)
                     })), FStar_TypeChecker_Rel.trivial_guard))
          | (FStar_Pervasives_Native.Some g,apply_guard1) ->
              let uu____6439 = FStar_TypeChecker_Rel.guard_form g  in
              (match uu____6439 with
               | FStar_TypeChecker_Common.Trivial  ->
                   let lc1 =
                     let uu___110_6447 = lc  in
                     {
                       FStar_Syntax_Syntax.eff_name =
                         (uu___110_6447.FStar_Syntax_Syntax.eff_name);
                       FStar_Syntax_Syntax.res_typ = t;
                       FStar_Syntax_Syntax.cflags =
                         (uu___110_6447.FStar_Syntax_Syntax.cflags);
                       FStar_Syntax_Syntax.comp_thunk =
                         (uu___110_6447.FStar_Syntax_Syntax.comp_thunk)
                     }  in
                   (e, lc1, g)
               | FStar_TypeChecker_Common.NonTrivial f ->
                   let g1 =
                     let uu___111_6450 = g  in
                     {
                       FStar_TypeChecker_Env.guard_f =
                         FStar_TypeChecker_Common.Trivial;
                       FStar_TypeChecker_Env.deferred =
                         (uu___111_6450.FStar_TypeChecker_Env.deferred);
                       FStar_TypeChecker_Env.univ_ineqs =
                         (uu___111_6450.FStar_TypeChecker_Env.univ_ineqs);
                       FStar_TypeChecker_Env.implicits =
                         (uu___111_6450.FStar_TypeChecker_Env.implicits)
                     }  in
                   let strengthen uu____6454 =
                     let uu____6455 =
                       env.FStar_TypeChecker_Env.lax &&
                         (FStar_Options.ml_ish ())
                        in
                     if uu____6455
                     then FStar_Syntax_Syntax.lcomp_comp lc
                     else
                       (let f1 =
                          FStar_TypeChecker_Normalize.normalize
                            [FStar_TypeChecker_Normalize.Beta;
                            FStar_TypeChecker_Normalize.Eager_unfolding;
                            FStar_TypeChecker_Normalize.Simplify;
                            FStar_TypeChecker_Normalize.Primops] env f
                           in
                        let uu____6458 =
                          let uu____6459 = FStar_Syntax_Subst.compress f1  in
                          uu____6459.FStar_Syntax_Syntax.n  in
                        match uu____6458 with
                        | FStar_Syntax_Syntax.Tm_abs
                            (uu____6462,{
                                          FStar_Syntax_Syntax.n =
                                            FStar_Syntax_Syntax.Tm_fvar fv;
                                          FStar_Syntax_Syntax.pos =
                                            uu____6464;
                                          FStar_Syntax_Syntax.vars =
                                            uu____6465;_},uu____6466)
                            when
                            FStar_Syntax_Syntax.fv_eq_lid fv
                              FStar_Parser_Const.true_lid
                            ->
                            let lc1 =
                              let uu___112_6488 = lc  in
                              {
                                FStar_Syntax_Syntax.eff_name =
                                  (uu___112_6488.FStar_Syntax_Syntax.eff_name);
                                FStar_Syntax_Syntax.res_typ = t;
                                FStar_Syntax_Syntax.cflags =
                                  (uu___112_6488.FStar_Syntax_Syntax.cflags);
                                FStar_Syntax_Syntax.comp_thunk =
                                  (uu___112_6488.FStar_Syntax_Syntax.comp_thunk)
                              }  in
                            FStar_Syntax_Syntax.lcomp_comp lc1
                        | uu____6489 ->
                            let c = FStar_Syntax_Syntax.lcomp_comp lc  in
                            ((let uu____6492 =
                                FStar_All.pipe_left
                                  (FStar_TypeChecker_Env.debug env)
                                  FStar_Options.Extreme
                                 in
                              if uu____6492
                              then
                                let uu____6493 =
                                  FStar_TypeChecker_Normalize.term_to_string
                                    env lc.FStar_Syntax_Syntax.res_typ
                                   in
                                let uu____6494 =
                                  FStar_TypeChecker_Normalize.term_to_string
                                    env t
                                   in
                                let uu____6495 =
                                  FStar_TypeChecker_Normalize.comp_to_string
                                    env c
                                   in
                                let uu____6496 =
                                  FStar_TypeChecker_Normalize.term_to_string
                                    env f1
                                   in
                                FStar_Util.print4
                                  "Weakened from %s to %s\nStrengthening %s with guard %s\n"
                                  uu____6493 uu____6494 uu____6495 uu____6496
                              else ());
                             (let u_t_opt = comp_univ_opt c  in
                              let x =
                                FStar_Syntax_Syntax.new_bv
                                  (FStar_Pervasives_Native.Some
                                     (t.FStar_Syntax_Syntax.pos)) t
                                 in
                              let xexp = FStar_Syntax_Syntax.bv_to_name x  in
                              let cret = return_value env u_t_opt t xexp  in
                              let guard =
                                if apply_guard1
                                then
                                  let uu____6509 =
                                    let uu____6510 =
                                      let uu____6511 =
                                        FStar_Syntax_Syntax.as_arg xexp  in
                                      [uu____6511]  in
                                    FStar_Syntax_Syntax.mk_Tm_app f1
                                      uu____6510
                                     in
                                  uu____6509 FStar_Pervasives_Native.None
                                    f1.FStar_Syntax_Syntax.pos
                                else f1  in
                              let uu____6515 =
                                let uu____6520 =
                                  FStar_All.pipe_left
                                    (fun _0_40  ->
                                       FStar_Pervasives_Native.Some _0_40)
                                    (FStar_TypeChecker_Err.subtyping_failed
                                       env lc.FStar_Syntax_Syntax.res_typ t)
                                   in
                                let uu____6533 =
                                  FStar_TypeChecker_Env.set_range env
                                    e.FStar_Syntax_Syntax.pos
                                   in
                                let uu____6534 =
                                  FStar_Syntax_Util.lcomp_of_comp cret  in
                                let uu____6535 =
                                  FStar_All.pipe_left
                                    FStar_TypeChecker_Rel.guard_of_guard_formula
                                    (FStar_TypeChecker_Common.NonTrivial
                                       guard)
                                   in
                                strengthen_precondition uu____6520 uu____6533
                                  e uu____6534 uu____6535
                                 in
                              match uu____6515 with
                              | (eq_ret,_trivial_so_ok_to_discard) ->
                                  let x1 =
                                    let uu___113_6539 = x  in
                                    {
                                      FStar_Syntax_Syntax.ppname =
                                        (uu___113_6539.FStar_Syntax_Syntax.ppname);
                                      FStar_Syntax_Syntax.index =
                                        (uu___113_6539.FStar_Syntax_Syntax.index);
                                      FStar_Syntax_Syntax.sort =
                                        (lc.FStar_Syntax_Syntax.res_typ)
                                    }  in
                                  let c1 =
                                    let uu____6541 =
                                      FStar_Syntax_Util.lcomp_of_comp c  in
                                    bind e.FStar_Syntax_Syntax.pos env
                                      (FStar_Pervasives_Native.Some e)
                                      uu____6541
                                      ((FStar_Pervasives_Native.Some x1),
                                        eq_ret)
                                     in
                                  let c2 = FStar_Syntax_Syntax.lcomp_comp c1
                                     in
                                  ((let uu____6546 =
                                      FStar_All.pipe_left
                                        (FStar_TypeChecker_Env.debug env)
                                        FStar_Options.Extreme
                                       in
                                    if uu____6546
                                    then
                                      let uu____6547 =
                                        FStar_TypeChecker_Normalize.comp_to_string
                                          env c2
                                         in
                                      FStar_Util.print1
                                        "Strengthened to %s\n" uu____6547
                                    else ());
                                   c2))))
                      in
                   let flags1 =
                     FStar_All.pipe_right lc.FStar_Syntax_Syntax.cflags
                       (FStar_List.collect
                          (fun uu___84_6557  ->
                             match uu___84_6557 with
                             | FStar_Syntax_Syntax.RETURN  ->
                                 [FStar_Syntax_Syntax.PARTIAL_RETURN]
                             | FStar_Syntax_Syntax.PARTIAL_RETURN  ->
                                 [FStar_Syntax_Syntax.PARTIAL_RETURN]
                             | FStar_Syntax_Syntax.CPS  ->
                                 [FStar_Syntax_Syntax.CPS]
                             | uu____6560 -> []))
                      in
                   let lc1 =
                     let uu____6562 =
                       FStar_TypeChecker_Env.norm_eff_name env
                         lc.FStar_Syntax_Syntax.eff_name
                        in
                     FStar_Syntax_Syntax.mk_lcomp uu____6562 t flags1
                       strengthen
                      in
                   let g2 =
                     let uu___114_6564 = g1  in
                     {
                       FStar_TypeChecker_Env.guard_f =
                         FStar_TypeChecker_Common.Trivial;
                       FStar_TypeChecker_Env.deferred =
                         (uu___114_6564.FStar_TypeChecker_Env.deferred);
                       FStar_TypeChecker_Env.univ_ineqs =
                         (uu___114_6564.FStar_TypeChecker_Env.univ_ineqs);
                       FStar_TypeChecker_Env.implicits =
                         (uu___114_6564.FStar_TypeChecker_Env.implicits)
                     }  in
                   (e, lc1, g2))
  
let (pure_or_ghost_pre_and_post :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.comp ->
      (FStar_Syntax_Syntax.typ FStar_Pervasives_Native.option,FStar_Syntax_Syntax.typ)
        FStar_Pervasives_Native.tuple2)
  =
  fun env  ->
    fun comp  ->
      let mk_post_type res_t ens =
        let x = FStar_Syntax_Syntax.new_bv FStar_Pervasives_Native.None res_t
           in
        let uu____6587 =
          let uu____6588 =
            let uu____6589 =
              let uu____6590 =
                let uu____6591 = FStar_Syntax_Syntax.bv_to_name x  in
                FStar_Syntax_Syntax.as_arg uu____6591  in
              [uu____6590]  in
            FStar_Syntax_Syntax.mk_Tm_app ens uu____6589  in
          uu____6588 FStar_Pervasives_Native.None
            res_t.FStar_Syntax_Syntax.pos
           in
        FStar_Syntax_Util.refine x uu____6587  in
      let norm1 t =
        FStar_TypeChecker_Normalize.normalize
          [FStar_TypeChecker_Normalize.Beta;
          FStar_TypeChecker_Normalize.Eager_unfolding;
          FStar_TypeChecker_Normalize.EraseUniverses] env t
         in
      let uu____6598 = FStar_Syntax_Util.is_tot_or_gtot_comp comp  in
      if uu____6598
      then
        (FStar_Pervasives_Native.None, (FStar_Syntax_Util.comp_result comp))
      else
        (match comp.FStar_Syntax_Syntax.n with
         | FStar_Syntax_Syntax.GTotal uu____6616 -> failwith "Impossible"
         | FStar_Syntax_Syntax.Total uu____6631 -> failwith "Impossible"
         | FStar_Syntax_Syntax.Comp ct ->
             let uu____6647 =
               (FStar_Ident.lid_equals ct.FStar_Syntax_Syntax.effect_name
                  FStar_Parser_Const.effect_Pure_lid)
                 ||
                 (FStar_Ident.lid_equals ct.FStar_Syntax_Syntax.effect_name
                    FStar_Parser_Const.effect_Ghost_lid)
                in
             if uu____6647
             then
               (match ct.FStar_Syntax_Syntax.effect_args with
                | (req,uu____6661)::(ens,uu____6663)::uu____6664 ->
                    let uu____6693 =
                      let uu____6696 = norm1 req  in
                      FStar_Pervasives_Native.Some uu____6696  in
                    let uu____6697 =
                      let uu____6698 =
                        mk_post_type ct.FStar_Syntax_Syntax.result_typ ens
                         in
                      FStar_All.pipe_left norm1 uu____6698  in
                    (uu____6693, uu____6697)
                | uu____6701 ->
                    let uu____6710 =
                      let uu____6715 =
                        let uu____6716 =
                          FStar_Syntax_Print.comp_to_string comp  in
                        FStar_Util.format1
                          "Effect constructor is not fully applied; got %s"
                          uu____6716
                         in
                      (FStar_Errors.Fatal_EffectConstructorNotFullyApplied,
                        uu____6715)
                       in
                    FStar_Errors.raise_error uu____6710
                      comp.FStar_Syntax_Syntax.pos)
             else
               (let ct1 = FStar_TypeChecker_Env.unfold_effect_abbrev env comp
                   in
                match ct1.FStar_Syntax_Syntax.effect_args with
                | (wp,uu____6732)::uu____6733 ->
                    let uu____6752 =
                      let uu____6757 =
                        FStar_TypeChecker_Env.lookup_lid env
                          FStar_Parser_Const.as_requires
                         in
                      FStar_All.pipe_left FStar_Pervasives_Native.fst
                        uu____6757
                       in
                    (match uu____6752 with
                     | (us_r,uu____6789) ->
                         let uu____6790 =
                           let uu____6795 =
                             FStar_TypeChecker_Env.lookup_lid env
                               FStar_Parser_Const.as_ensures
                              in
                           FStar_All.pipe_left FStar_Pervasives_Native.fst
                             uu____6795
                            in
                         (match uu____6790 with
                          | (us_e,uu____6827) ->
                              let r =
                                (ct1.FStar_Syntax_Syntax.result_typ).FStar_Syntax_Syntax.pos
                                 in
                              let as_req =
                                let uu____6830 =
                                  let uu____6831 =
                                    FStar_Ident.set_lid_range
                                      FStar_Parser_Const.as_requires r
                                     in
                                  FStar_Syntax_Syntax.fvar uu____6831
                                    FStar_Syntax_Syntax.Delta_equational
                                    FStar_Pervasives_Native.None
                                   in
                                FStar_Syntax_Syntax.mk_Tm_uinst uu____6830
                                  us_r
                                 in
                              let as_ens =
                                let uu____6833 =
                                  let uu____6834 =
                                    FStar_Ident.set_lid_range
                                      FStar_Parser_Const.as_ensures r
                                     in
                                  FStar_Syntax_Syntax.fvar uu____6834
                                    FStar_Syntax_Syntax.Delta_equational
                                    FStar_Pervasives_Native.None
                                   in
                                FStar_Syntax_Syntax.mk_Tm_uinst uu____6833
                                  us_e
                                 in
                              let req =
                                let uu____6838 =
                                  let uu____6839 =
                                    let uu____6840 =
                                      let uu____6851 =
                                        FStar_Syntax_Syntax.as_arg wp  in
                                      [uu____6851]  in
                                    ((ct1.FStar_Syntax_Syntax.result_typ),
                                      (FStar_Pervasives_Native.Some
                                         FStar_Syntax_Syntax.imp_tag))
                                      :: uu____6840
                                     in
                                  FStar_Syntax_Syntax.mk_Tm_app as_req
                                    uu____6839
                                   in
                                uu____6838 FStar_Pervasives_Native.None
                                  (ct1.FStar_Syntax_Syntax.result_typ).FStar_Syntax_Syntax.pos
                                 in
                              let ens =
                                let uu____6869 =
                                  let uu____6870 =
                                    let uu____6871 =
                                      let uu____6882 =
                                        FStar_Syntax_Syntax.as_arg wp  in
                                      [uu____6882]  in
                                    ((ct1.FStar_Syntax_Syntax.result_typ),
                                      (FStar_Pervasives_Native.Some
                                         FStar_Syntax_Syntax.imp_tag))
                                      :: uu____6871
                                     in
                                  FStar_Syntax_Syntax.mk_Tm_app as_ens
                                    uu____6870
                                   in
                                uu____6869 FStar_Pervasives_Native.None
                                  (ct1.FStar_Syntax_Syntax.result_typ).FStar_Syntax_Syntax.pos
                                 in
                              let uu____6897 =
                                let uu____6900 = norm1 req  in
                                FStar_Pervasives_Native.Some uu____6900  in
                              let uu____6901 =
                                let uu____6902 =
                                  mk_post_type
                                    ct1.FStar_Syntax_Syntax.result_typ ens
                                   in
                                norm1 uu____6902  in
                              (uu____6897, uu____6901)))
                | uu____6905 -> failwith "Impossible"))
  
let (reify_body :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term)
  =
  fun env  ->
    fun t  ->
      let tm = FStar_Syntax_Util.mk_reify t  in
      let tm' =
        FStar_TypeChecker_Normalize.normalize
          [FStar_TypeChecker_Normalize.Beta;
          FStar_TypeChecker_Normalize.Reify;
          FStar_TypeChecker_Normalize.Eager_unfolding;
          FStar_TypeChecker_Normalize.EraseUniverses;
          FStar_TypeChecker_Normalize.AllowUnboundUniverses] env tm
         in
      (let uu____6931 =
         FStar_All.pipe_left (FStar_TypeChecker_Env.debug env)
           (FStar_Options.Other "SMTEncodingReify")
          in
       if uu____6931
       then
         let uu____6932 = FStar_Syntax_Print.term_to_string tm  in
         let uu____6933 = FStar_Syntax_Print.term_to_string tm'  in
         FStar_Util.print2 "Reified body %s \nto %s\n" uu____6932 uu____6933
       else ());
      tm'
  
let (reify_body_with_arg :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.arg -> FStar_Syntax_Syntax.term)
  =
  fun env  ->
    fun head1  ->
      fun arg  ->
        let tm =
          FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_app (head1, [arg]))
            FStar_Pervasives_Native.None head1.FStar_Syntax_Syntax.pos
           in
        let tm' =
          FStar_TypeChecker_Normalize.normalize
            [FStar_TypeChecker_Normalize.Beta;
            FStar_TypeChecker_Normalize.Reify;
            FStar_TypeChecker_Normalize.Eager_unfolding;
            FStar_TypeChecker_Normalize.EraseUniverses;
            FStar_TypeChecker_Normalize.AllowUnboundUniverses] env tm
           in
        (let uu____6951 =
           FStar_All.pipe_left (FStar_TypeChecker_Env.debug env)
             (FStar_Options.Other "SMTEncodingReify")
            in
         if uu____6951
         then
           let uu____6952 = FStar_Syntax_Print.term_to_string tm  in
           let uu____6953 = FStar_Syntax_Print.term_to_string tm'  in
           FStar_Util.print2 "Reified body %s \nto %s\n" uu____6952
             uu____6953
         else ());
        tm'
  
let (remove_reify : FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term) =
  fun t  ->
    let uu____6958 =
      let uu____6959 =
        let uu____6960 = FStar_Syntax_Subst.compress t  in
        uu____6960.FStar_Syntax_Syntax.n  in
      match uu____6959 with
      | FStar_Syntax_Syntax.Tm_app uu____6963 -> false
      | uu____6978 -> true  in
    if uu____6958
    then t
    else
      (let uu____6980 = FStar_Syntax_Util.head_and_args t  in
       match uu____6980 with
       | (head1,args) ->
           let uu____7017 =
             let uu____7018 =
               let uu____7019 = FStar_Syntax_Subst.compress head1  in
               uu____7019.FStar_Syntax_Syntax.n  in
             match uu____7018 with
             | FStar_Syntax_Syntax.Tm_constant (FStar_Const.Const_reify ) ->
                 true
             | uu____7022 -> false  in
           if uu____7017
           then
             (match args with
              | x::[] -> FStar_Pervasives_Native.fst x
              | uu____7044 ->
                  failwith
                    "Impossible : Reify applied to multiple arguments after normalization.")
           else t)
  
let (maybe_instantiate :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.typ ->
        (FStar_Syntax_Syntax.term,FStar_Syntax_Syntax.typ,FStar_TypeChecker_Env.guard_t)
          FStar_Pervasives_Native.tuple3)
  =
  fun env  ->
    fun e  ->
      fun t  ->
        let torig = FStar_Syntax_Subst.compress t  in
        if Prims.op_Negation env.FStar_TypeChecker_Env.instantiate_imp
        then (e, torig, FStar_TypeChecker_Rel.trivial_guard)
        else
          (let number_of_implicits t1 =
             let uu____7081 = FStar_Syntax_Util.arrow_formals t1  in
             match uu____7081 with
             | (formals,uu____7095) ->
                 let n_implicits =
                   let uu____7113 =
                     FStar_All.pipe_right formals
                       (FStar_Util.prefix_until
                          (fun uu____7189  ->
                             match uu____7189 with
                             | (uu____7196,imp) ->
                                 (imp = FStar_Pervasives_Native.None) ||
                                   (imp =
                                      (FStar_Pervasives_Native.Some
                                         FStar_Syntax_Syntax.Equality))))
                      in
                   match uu____7113 with
                   | FStar_Pervasives_Native.None  ->
                       FStar_List.length formals
                   | FStar_Pervasives_Native.Some
                       (implicits,_first_explicit,_rest) ->
                       FStar_List.length implicits
                    in
                 n_implicits
              in
           let inst_n_binders t1 =
             let uu____7327 = FStar_TypeChecker_Env.expected_typ env  in
             match uu____7327 with
             | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None
             | FStar_Pervasives_Native.Some expected_t ->
                 let n_expected = number_of_implicits expected_t  in
                 let n_available = number_of_implicits t1  in
                 if n_available < n_expected
                 then
                   let uu____7351 =
                     let uu____7356 =
                       let uu____7357 = FStar_Util.string_of_int n_expected
                          in
                       let uu____7364 = FStar_Syntax_Print.term_to_string e
                          in
                       let uu____7365 = FStar_Util.string_of_int n_available
                          in
                       FStar_Util.format3
                         "Expected a term with %s implicit arguments, but %s has only %s"
                         uu____7357 uu____7364 uu____7365
                        in
                     (FStar_Errors.Fatal_MissingImplicitArguments,
                       uu____7356)
                      in
                   let uu____7372 = FStar_TypeChecker_Env.get_range env  in
                   FStar_Errors.raise_error uu____7351 uu____7372
                 else FStar_Pervasives_Native.Some (n_available - n_expected)
              in
           let decr_inst uu___85_7393 =
             match uu___85_7393 with
             | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None
             | FStar_Pervasives_Native.Some i ->
                 FStar_Pervasives_Native.Some (i - (Prims.parse_int "1"))
              in
           match torig.FStar_Syntax_Syntax.n with
           | FStar_Syntax_Syntax.Tm_arrow (bs,c) ->
               let uu____7423 = FStar_Syntax_Subst.open_comp bs c  in
               (match uu____7423 with
                | (bs1,c1) ->
                    let rec aux subst1 inst_n bs2 =
                      match (inst_n, bs2) with
                      | (FStar_Pervasives_Native.Some _0_41,uu____7532) when
                          _0_41 = (Prims.parse_int "0") ->
                          ([], bs2, subst1,
                            FStar_TypeChecker_Rel.trivial_guard)
                      | (uu____7575,(x,FStar_Pervasives_Native.Some
                                     (FStar_Syntax_Syntax.Implicit dot))::rest)
                          ->
                          let t1 =
                            FStar_Syntax_Subst.subst subst1
                              x.FStar_Syntax_Syntax.sort
                             in
                          let uu____7608 =
                            new_implicit_var
                              "Instantiation of implicit argument"
                              e.FStar_Syntax_Syntax.pos env t1
                             in
                          (match uu____7608 with
                           | (v1,uu____7648,g) ->
                               let subst2 = (FStar_Syntax_Syntax.NT (x, v1))
                                 :: subst1  in
                               let uu____7665 =
                                 aux subst2 (decr_inst inst_n) rest  in
                               (match uu____7665 with
                                | (args,bs3,subst3,g') ->
                                    let uu____7758 =
                                      FStar_TypeChecker_Rel.conj_guard g g'
                                       in
                                    (((v1,
                                        (FStar_Pervasives_Native.Some
                                           (FStar_Syntax_Syntax.Implicit dot)))
                                      :: args), bs3, subst3, uu____7758)))
                      | (uu____7785,bs3) ->
                          ([], bs3, subst1,
                            FStar_TypeChecker_Rel.trivial_guard)
                       in
                    let uu____7831 =
                      let uu____7858 = inst_n_binders t  in
                      aux [] uu____7858 bs1  in
                    (match uu____7831 with
                     | (args,bs2,subst1,guard) ->
                         (match (args, bs2) with
                          | ([],uu____7929) -> (e, torig, guard)
                          | (uu____7960,[]) when
                              let uu____7991 =
                                FStar_Syntax_Util.is_total_comp c1  in
                              Prims.op_Negation uu____7991 ->
                              (e, torig, FStar_TypeChecker_Rel.trivial_guard)
                          | uu____7992 ->
                              let t1 =
                                match bs2 with
                                | [] -> FStar_Syntax_Util.comp_result c1
                                | uu____8024 ->
                                    FStar_Syntax_Util.arrow bs2 c1
                                 in
                              let t2 = FStar_Syntax_Subst.subst subst1 t1  in
                              let e1 =
                                FStar_Syntax_Syntax.mk_Tm_app e args
                                  FStar_Pervasives_Native.None
                                  e.FStar_Syntax_Syntax.pos
                                 in
                              (e1, t2, guard))))
           | uu____8039 -> (e, t, FStar_TypeChecker_Rel.trivial_guard))
  
let (string_of_univs :
  FStar_Syntax_Syntax.universe_uvar FStar_Util.set -> Prims.string) =
  fun univs1  ->
    let uu____8047 =
      let uu____8050 = FStar_Util.set_elements univs1  in
      FStar_All.pipe_right uu____8050
        (FStar_List.map
           (fun u  ->
              let uu____8060 = FStar_Syntax_Unionfind.univ_uvar_id u  in
              FStar_All.pipe_right uu____8060 FStar_Util.string_of_int))
       in
    FStar_All.pipe_right uu____8047 (FStar_String.concat ", ")
  
let (gen_univs :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.universe_uvar FStar_Util.set ->
      FStar_Syntax_Syntax.univ_name Prims.list)
  =
  fun env  ->
    fun x  ->
      let uu____8077 = FStar_Util.set_is_empty x  in
      if uu____8077
      then []
      else
        (let s =
           let uu____8084 =
             let uu____8087 = FStar_TypeChecker_Env.univ_vars env  in
             FStar_Util.set_difference x uu____8087  in
           FStar_All.pipe_right uu____8084 FStar_Util.set_elements  in
         (let uu____8095 =
            FStar_All.pipe_left (FStar_TypeChecker_Env.debug env)
              (FStar_Options.Other "Gen")
             in
          if uu____8095
          then
            let uu____8096 =
              let uu____8097 = FStar_TypeChecker_Env.univ_vars env  in
              string_of_univs uu____8097  in
            FStar_Util.print1 "univ_vars in env: %s\n" uu____8096
          else ());
         (let r =
            let uu____8104 = FStar_TypeChecker_Env.get_range env  in
            FStar_Pervasives_Native.Some uu____8104  in
          let u_names =
            FStar_All.pipe_right s
              (FStar_List.map
                 (fun u  ->
                    let u_name = FStar_Syntax_Syntax.new_univ_name r  in
                    (let uu____8119 =
                       FStar_All.pipe_left (FStar_TypeChecker_Env.debug env)
                         (FStar_Options.Other "Gen")
                        in
                     if uu____8119
                     then
                       let uu____8120 =
                         let uu____8121 =
                           FStar_Syntax_Unionfind.univ_uvar_id u  in
                         FStar_All.pipe_left FStar_Util.string_of_int
                           uu____8121
                          in
                       let uu____8122 =
                         FStar_Syntax_Print.univ_to_string
                           (FStar_Syntax_Syntax.U_unif u)
                          in
                       let uu____8123 =
                         FStar_Syntax_Print.univ_to_string
                           (FStar_Syntax_Syntax.U_name u_name)
                          in
                       FStar_Util.print3 "Setting ?%s (%s) to %s\n"
                         uu____8120 uu____8122 uu____8123
                     else ());
                    FStar_Syntax_Unionfind.univ_change u
                      (FStar_Syntax_Syntax.U_name u_name);
                    u_name))
             in
          u_names))
  
let (gather_free_univnames :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.univ_name Prims.list)
  =
  fun env  ->
    fun t  ->
      let ctx_univnames = FStar_TypeChecker_Env.univnames env  in
      let tm_univnames = FStar_Syntax_Free.univnames t  in
      let univnames1 =
        let uu____8145 = FStar_Util.set_difference tm_univnames ctx_univnames
           in
        FStar_All.pipe_right uu____8145 FStar_Util.set_elements  in
      univnames1
  
let (check_universe_generalization :
  FStar_Syntax_Syntax.univ_name Prims.list ->
    FStar_Syntax_Syntax.univ_name Prims.list ->
      FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.univ_name Prims.list)
  =
  fun explicit_univ_names  ->
    fun generalized_univ_names  ->
      fun t  ->
        match (explicit_univ_names, generalized_univ_names) with
        | ([],uu____8177) -> generalized_univ_names
        | (uu____8184,[]) -> explicit_univ_names
        | uu____8191 ->
            let uu____8200 =
              let uu____8205 =
                let uu____8206 = FStar_Syntax_Print.term_to_string t  in
                Prims.strcat
                  "Generalized universe in a term containing explicit universe annotation : "
                  uu____8206
                 in
              (FStar_Errors.Fatal_UnexpectedGeneralizedUniverse, uu____8205)
               in
            FStar_Errors.raise_error uu____8200 t.FStar_Syntax_Syntax.pos
  
let (generalize_universes :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.tscheme)
  =
  fun env  ->
    fun t0  ->
      let t =
        FStar_TypeChecker_Normalize.normalize
          [FStar_TypeChecker_Normalize.NoFullNorm;
          FStar_TypeChecker_Normalize.Beta;
          FStar_TypeChecker_Normalize.DoNotUnfoldPureLets] env t0
         in
      let univnames1 = gather_free_univnames env t  in
      (let uu____8220 =
         FStar_All.pipe_left (FStar_TypeChecker_Env.debug env)
           (FStar_Options.Other "Gen")
          in
       if uu____8220
       then
         let uu____8221 = FStar_Syntax_Print.term_to_string t  in
         let uu____8222 = FStar_Syntax_Print.univ_names_to_string univnames1
            in
         FStar_Util.print2
           "generalizing universes in the term (post norm): %s with univnames: %s\n"
           uu____8221 uu____8222
       else ());
      (let univs1 = FStar_Syntax_Free.univs t  in
       (let uu____8228 =
          FStar_All.pipe_left (FStar_TypeChecker_Env.debug env)
            (FStar_Options.Other "Gen")
           in
        if uu____8228
        then
          let uu____8229 = string_of_univs univs1  in
          FStar_Util.print1 "univs to gen : %s\n" uu____8229
        else ());
       (let gen1 = gen_univs env univs1  in
        (let uu____8235 =
           FStar_All.pipe_left (FStar_TypeChecker_Env.debug env)
             (FStar_Options.Other "Gen")
            in
         if uu____8235
         then
           let uu____8236 = FStar_Syntax_Print.term_to_string t  in
           let uu____8237 = FStar_Syntax_Print.univ_names_to_string gen1  in
           FStar_Util.print2 "After generalization, t: %s and univs: %s\n"
             uu____8236 uu____8237
         else ());
        (let univs2 = check_universe_generalization univnames1 gen1 t0  in
         let t1 = FStar_TypeChecker_Normalize.reduce_uvar_solutions env t  in
         let ts = FStar_Syntax_Subst.close_univ_vars univs2 t1  in
         (univs2, ts))))
  
let (gen :
  FStar_TypeChecker_Env.env ->
    Prims.bool ->
      (FStar_Syntax_Syntax.lbname,FStar_Syntax_Syntax.term,FStar_Syntax_Syntax.comp)
        FStar_Pervasives_Native.tuple3 Prims.list ->
        (FStar_Syntax_Syntax.lbname,FStar_Syntax_Syntax.univ_name Prims.list,
          FStar_Syntax_Syntax.term,FStar_Syntax_Syntax.comp,FStar_Syntax_Syntax.binder
                                                              Prims.list)
          FStar_Pervasives_Native.tuple5 Prims.list
          FStar_Pervasives_Native.option)
  =
  fun env  ->
    fun is_rec  ->
      fun lecs  ->
        let uu____8307 =
          let uu____8308 =
            FStar_Util.for_all
              (fun uu____8321  ->
                 match uu____8321 with
                 | (uu____8330,uu____8331,c) ->
                     FStar_Syntax_Util.is_pure_or_ghost_comp c) lecs
             in
          FStar_All.pipe_left Prims.op_Negation uu____8308  in
        if uu____8307
        then FStar_Pervasives_Native.None
        else
          (let norm1 c =
             (let uu____8377 =
                FStar_TypeChecker_Env.debug env FStar_Options.Medium  in
              if uu____8377
              then
                let uu____8378 = FStar_Syntax_Print.comp_to_string c  in
                FStar_Util.print1 "Normalizing before generalizing:\n\t %s\n"
                  uu____8378
              else ());
             (let c1 =
                FStar_TypeChecker_Normalize.normalize_comp
                  [FStar_TypeChecker_Normalize.Beta;
                  FStar_TypeChecker_Normalize.Exclude
                    FStar_TypeChecker_Normalize.Zeta;
                  FStar_TypeChecker_Normalize.NoFullNorm;
                  FStar_TypeChecker_Normalize.DoNotUnfoldPureLets] env c
                 in
              (let uu____8382 =
                 FStar_TypeChecker_Env.debug env FStar_Options.Medium  in
               if uu____8382
               then
                 let uu____8383 = FStar_Syntax_Print.comp_to_string c1  in
                 FStar_Util.print1 "Normalized to:\n\t %s\n" uu____8383
               else ());
              c1)
              in
           let env_uvars = FStar_TypeChecker_Env.uvars_in_env env  in
           let gen_uvars uvs =
             let uu____8444 = FStar_Util.set_difference uvs env_uvars  in
             FStar_All.pipe_right uu____8444 FStar_Util.set_elements  in
           let univs_and_uvars_of_lec uu____8574 =
             match uu____8574 with
             | (lbname,e,c) ->
                 let t =
                   FStar_All.pipe_right (FStar_Syntax_Util.comp_result c)
                     FStar_Syntax_Subst.compress
                    in
                 let c1 = norm1 c  in
                 let t1 = FStar_Syntax_Util.comp_result c1  in
                 let univs1 = FStar_Syntax_Free.univs t1  in
                 let uvt = FStar_Syntax_Free.uvars t1  in
                 ((let uu____8640 =
                     FStar_All.pipe_left (FStar_TypeChecker_Env.debug env)
                       (FStar_Options.Other "Gen")
                      in
                   if uu____8640
                   then
                     let uu____8641 =
                       let uu____8642 =
                         let uu____8645 = FStar_Util.set_elements univs1  in
                         FStar_All.pipe_right uu____8645
                           (FStar_List.map
                              (fun u  ->
                                 FStar_Syntax_Print.univ_to_string
                                   (FStar_Syntax_Syntax.U_unif u)))
                          in
                       FStar_All.pipe_right uu____8642
                         (FStar_String.concat ", ")
                        in
                     let uu____8672 =
                       let uu____8673 =
                         let uu____8676 = FStar_Util.set_elements uvt  in
                         FStar_All.pipe_right uu____8676
                           (FStar_List.map
                              (fun uu____8704  ->
                                 match uu____8704 with
                                 | (u,t2) ->
                                     let uu____8711 =
                                       FStar_Syntax_Print.uvar_to_string u
                                        in
                                     let uu____8712 =
                                       FStar_Syntax_Print.term_to_string t2
                                        in
                                     FStar_Util.format2 "(%s : %s)"
                                       uu____8711 uu____8712))
                          in
                       FStar_All.pipe_right uu____8673
                         (FStar_String.concat ", ")
                        in
                     FStar_Util.print2
                       "^^^^\n\tFree univs = %s\n\tFree uvt=%s\n" uu____8641
                       uu____8672
                   else ());
                  (let univs2 =
                     let uu____8719 = FStar_Util.set_elements uvt  in
                     FStar_List.fold_left
                       (fun univs2  ->
                          fun uu____8742  ->
                            match uu____8742 with
                            | (uu____8751,t2) ->
                                let uu____8753 = FStar_Syntax_Free.univs t2
                                   in
                                FStar_Util.set_union univs2 uu____8753)
                       univs1 uu____8719
                      in
                   let uvs = gen_uvars uvt  in
                   (let uu____8776 =
                      FStar_All.pipe_left (FStar_TypeChecker_Env.debug env)
                        (FStar_Options.Other "Gen")
                       in
                    if uu____8776
                    then
                      let uu____8777 =
                        let uu____8778 =
                          let uu____8781 = FStar_Util.set_elements univs2  in
                          FStar_All.pipe_right uu____8781
                            (FStar_List.map
                               (fun u  ->
                                  FStar_Syntax_Print.univ_to_string
                                    (FStar_Syntax_Syntax.U_unif u)))
                           in
                        FStar_All.pipe_right uu____8778
                          (FStar_String.concat ", ")
                         in
                      let uu____8808 =
                        let uu____8809 =
                          FStar_All.pipe_right uvs
                            (FStar_List.map
                               (fun uu____8841  ->
                                  match uu____8841 with
                                  | (u,t2) ->
                                      let uu____8848 =
                                        FStar_Syntax_Print.uvar_to_string u
                                         in
                                      let uu____8849 =
                                        FStar_TypeChecker_Normalize.term_to_string
                                          env t2
                                         in
                                      FStar_Util.format2 "(%s : %s)"
                                        uu____8848 uu____8849))
                           in
                        FStar_All.pipe_right uu____8809
                          (FStar_String.concat ", ")
                         in
                      FStar_Util.print2
                        "^^^^\n\tFree univs = %s\n\tgen_uvars =%s" uu____8777
                        uu____8808
                    else ());
                   (univs2, uvs, (lbname, e, c1))))
              in
           let uu____8879 =
             let uu____8912 = FStar_List.hd lecs  in
             univs_and_uvars_of_lec uu____8912  in
           match uu____8879 with
           | (univs1,uvs,lec_hd) ->
               let force_univs_eq lec2 u1 u2 =
                 let uu____9030 =
                   (FStar_Util.set_is_subset_of u1 u2) &&
                     (FStar_Util.set_is_subset_of u2 u1)
                    in
                 if uu____9030
                 then ()
                 else
                   (let uu____9032 = lec_hd  in
                    match uu____9032 with
                    | (lb1,uu____9040,uu____9041) ->
                        let uu____9042 = lec2  in
                        (match uu____9042 with
                         | (lb2,uu____9050,uu____9051) ->
                             let msg =
                               let uu____9053 =
                                 FStar_Syntax_Print.lbname_to_string lb1  in
                               let uu____9054 =
                                 FStar_Syntax_Print.lbname_to_string lb2  in
                               FStar_Util.format2
                                 "Generalizing the types of these mutually recursive definitions requires an incompatible set of universes for %s and %s"
                                 uu____9053 uu____9054
                                in
                             let uu____9055 =
                               FStar_TypeChecker_Env.get_range env  in
                             FStar_Errors.raise_error
                               (FStar_Errors.Fatal_IncompatibleSetOfUniverse,
                                 msg) uu____9055))
                  in
               let force_uvars_eq lec2 u1 u2 =
                 let uvars_subseteq u11 u21 =
                   FStar_All.pipe_right u11
                     (FStar_Util.for_all
                        (fun uu____9166  ->
                           match uu____9166 with
                           | (u,uu____9174) ->
                               FStar_All.pipe_right u21
                                 (FStar_Util.for_some
                                    (fun uu____9196  ->
                                       match uu____9196 with
                                       | (u',uu____9204) ->
                                           FStar_Syntax_Unionfind.equiv u u'))))
                    in
                 let uu____9209 =
                   (uvars_subseteq u1 u2) && (uvars_subseteq u2 u1)  in
                 if uu____9209
                 then ()
                 else
                   (let uu____9211 = lec_hd  in
                    match uu____9211 with
                    | (lb1,uu____9219,uu____9220) ->
                        let uu____9221 = lec2  in
                        (match uu____9221 with
                         | (lb2,uu____9229,uu____9230) ->
                             let msg =
                               let uu____9232 =
                                 FStar_Syntax_Print.lbname_to_string lb1  in
                               let uu____9233 =
                                 FStar_Syntax_Print.lbname_to_string lb2  in
                               FStar_Util.format2
                                 "Generalizing the types of these mutually recursive definitions requires an incompatible number of types for %s and %s"
                                 uu____9232 uu____9233
                                in
                             let uu____9234 =
                               FStar_TypeChecker_Env.get_range env  in
                             FStar_Errors.raise_error
                               (FStar_Errors.Fatal_IncompatibleNumberOfTypes,
                                 msg) uu____9234))
                  in
               let lecs1 =
                 let uu____9244 = FStar_List.tl lecs  in
                 FStar_List.fold_right
                   (fun this_lec  ->
                      fun lecs1  ->
                        let uu____9303 = univs_and_uvars_of_lec this_lec  in
                        match uu____9303 with
                        | (this_univs,this_uvs,this_lec1) ->
                            (force_univs_eq this_lec1 univs1 this_univs;
                             force_uvars_eq this_lec1 uvs this_uvs;
                             this_lec1
                             ::
                             lecs1)) uu____9244 []
                  in
               let lecs2 = lec_hd :: lecs1  in
               let gen_types uvs1 =
                 let fail1 k =
                   let uu____9456 = lec_hd  in
                   match uu____9456 with
                   | (lbname,e,c) ->
                       let uu____9466 =
                         let uu____9471 =
                           let uu____9472 =
                             FStar_Syntax_Print.term_to_string k  in
                           let uu____9473 =
                             FStar_Syntax_Print.lbname_to_string lbname  in
                           let uu____9474 =
                             FStar_Syntax_Print.term_to_string
                               (FStar_Syntax_Util.comp_result c)
                              in
                           FStar_Util.format3
                             "Failed to resolve implicit argument of type '%s' in the type of %s (%s)"
                             uu____9472 uu____9473 uu____9474
                            in
                         (FStar_Errors.Fatal_FailToResolveImplicitArgument,
                           uu____9471)
                          in
                       let uu____9475 = FStar_TypeChecker_Env.get_range env
                          in
                       FStar_Errors.raise_error uu____9466 uu____9475
                    in
                 FStar_All.pipe_right uvs1
                   (FStar_List.map
                      (fun uu____9505  ->
                         match uu____9505 with
                         | (u,k) ->
                             let uu____9518 = FStar_Syntax_Unionfind.find u
                                in
                             (match uu____9518 with
                              | FStar_Pervasives_Native.Some uu____9527 ->
                                  failwith
                                    "Unexpected instantiation of mutually recursive uvar"
                              | uu____9534 ->
                                  let k1 =
                                    FStar_TypeChecker_Normalize.normalize
                                      [FStar_TypeChecker_Normalize.Beta;
                                      FStar_TypeChecker_Normalize.Exclude
                                        FStar_TypeChecker_Normalize.Zeta] env
                                      k
                                     in
                                  let uu____9538 =
                                    FStar_Syntax_Util.arrow_formals k1  in
                                  (match uu____9538 with
                                   | (bs,kres) ->
                                       ((let uu____9576 =
                                           let uu____9577 =
                                             let uu____9580 =
                                               FStar_TypeChecker_Normalize.unfold_whnf
                                                 env kres
                                                in
                                             FStar_Syntax_Util.unrefine
                                               uu____9580
                                              in
                                           uu____9577.FStar_Syntax_Syntax.n
                                            in
                                         match uu____9576 with
                                         | FStar_Syntax_Syntax.Tm_type
                                             uu____9581 ->
                                             let free =
                                               FStar_Syntax_Free.names kres
                                                in
                                             let uu____9585 =
                                               let uu____9586 =
                                                 FStar_Util.set_is_empty free
                                                  in
                                               Prims.op_Negation uu____9586
                                                in
                                             if uu____9585
                                             then fail1 kres
                                             else ()
                                         | uu____9588 -> fail1 kres);
                                        (let a =
                                           let uu____9590 =
                                             let uu____9593 =
                                               FStar_TypeChecker_Env.get_range
                                                 env
                                                in
                                             FStar_All.pipe_left
                                               (fun _0_42  ->
                                                  FStar_Pervasives_Native.Some
                                                    _0_42) uu____9593
                                              in
                                           FStar_Syntax_Syntax.new_bv
                                             uu____9590 kres
                                            in
                                         let t =
                                           let uu____9597 =
                                             FStar_Syntax_Syntax.bv_to_name a
                                              in
                                           FStar_Syntax_Util.abs bs
                                             uu____9597
                                             (FStar_Pervasives_Native.Some
                                                (FStar_Syntax_Util.residual_tot
                                                   kres))
                                            in
                                         FStar_Syntax_Util.set_uvar u t;
                                         (a,
                                           (FStar_Pervasives_Native.Some
                                              FStar_Syntax_Syntax.imp_tag))))))))
                  in
               let gen_univs1 = gen_univs env univs1  in
               let gen_tvars = gen_types uvs  in
               let ecs =
                 FStar_All.pipe_right lecs2
                   (FStar_List.map
                      (fun uu____9716  ->
                         match uu____9716 with
                         | (lbname,e,c) ->
                             let uu____9762 =
                               match (gen_tvars, gen_univs1) with
                               | ([],[]) -> (e, c, [])
                               | uu____9831 ->
                                   let uu____9846 = (e, c)  in
                                   (match uu____9846 with
                                    | (e0,c0) ->
                                        let c1 =
                                          FStar_TypeChecker_Normalize.normalize_comp
                                            [FStar_TypeChecker_Normalize.Beta;
                                            FStar_TypeChecker_Normalize.DoNotUnfoldPureLets;
                                            FStar_TypeChecker_Normalize.CompressUvars;
                                            FStar_TypeChecker_Normalize.NoFullNorm;
                                            FStar_TypeChecker_Normalize.Exclude
                                              FStar_TypeChecker_Normalize.Zeta]
                                            env c
                                           in
                                        let e1 =
                                          FStar_TypeChecker_Normalize.reduce_uvar_solutions
                                            env e
                                           in
                                        let e2 =
                                          if is_rec
                                          then
                                            let tvar_args =
                                              FStar_List.map
                                                (fun uu____9883  ->
                                                   match uu____9883 with
                                                   | (x,uu____9891) ->
                                                       let uu____9896 =
                                                         FStar_Syntax_Syntax.bv_to_name
                                                           x
                                                          in
                                                       FStar_Syntax_Syntax.iarg
                                                         uu____9896)
                                                gen_tvars
                                               in
                                            let instantiate_lbname_with_app
                                              tm fv =
                                              let uu____9906 =
                                                let uu____9907 =
                                                  FStar_Util.right lbname  in
                                                FStar_Syntax_Syntax.fv_eq fv
                                                  uu____9907
                                                 in
                                              if uu____9906
                                              then
                                                FStar_Syntax_Syntax.mk_Tm_app
                                                  tm tvar_args
                                                  FStar_Pervasives_Native.None
                                                  tm.FStar_Syntax_Syntax.pos
                                              else tm  in
                                            FStar_Syntax_InstFV.inst
                                              instantiate_lbname_with_app e1
                                          else e1  in
                                        let t =
                                          let uu____9915 =
                                            let uu____9916 =
                                              FStar_Syntax_Subst.compress
                                                (FStar_Syntax_Util.comp_result
                                                   c1)
                                               in
                                            uu____9916.FStar_Syntax_Syntax.n
                                             in
                                          match uu____9915 with
                                          | FStar_Syntax_Syntax.Tm_arrow
                                              (bs,cod) ->
                                              let uu____9939 =
                                                FStar_Syntax_Subst.open_comp
                                                  bs cod
                                                 in
                                              (match uu____9939 with
                                               | (bs1,cod1) ->
                                                   FStar_Syntax_Util.arrow
                                                     (FStar_List.append
                                                        gen_tvars bs1) cod1)
                                          | uu____9954 ->
                                              FStar_Syntax_Util.arrow
                                                gen_tvars c1
                                           in
                                        let e' =
                                          FStar_Syntax_Util.abs gen_tvars e2
                                            (FStar_Pervasives_Native.Some
                                               (FStar_Syntax_Util.residual_comp_of_comp
                                                  c1))
                                           in
                                        let uu____9956 =
                                          FStar_Syntax_Syntax.mk_Total t  in
                                        (e', uu____9956, gen_tvars))
                                in
                             (match uu____9762 with
                              | (e1,c1,gvs) ->
                                  (lbname, gen_univs1, e1, c1, gvs))))
                  in
               FStar_Pervasives_Native.Some ecs)
  
let (generalize :
  FStar_TypeChecker_Env.env ->
    Prims.bool ->
      (FStar_Syntax_Syntax.lbname,FStar_Syntax_Syntax.term,FStar_Syntax_Syntax.comp)
        FStar_Pervasives_Native.tuple3 Prims.list ->
        (FStar_Syntax_Syntax.lbname,FStar_Syntax_Syntax.univ_names,FStar_Syntax_Syntax.term,
          FStar_Syntax_Syntax.comp,FStar_Syntax_Syntax.binder Prims.list)
          FStar_Pervasives_Native.tuple5 Prims.list)
  =
  fun env  ->
    fun is_rec  ->
      fun lecs  ->
        (let uu____10102 = Obj.magic ()  in ());
        (let uu____10104 = FStar_TypeChecker_Env.debug env FStar_Options.Low
            in
         if uu____10104
         then
           let uu____10105 =
             let uu____10106 =
               FStar_List.map
                 (fun uu____10119  ->
                    match uu____10119 with
                    | (lb,uu____10127,uu____10128) ->
                        FStar_Syntax_Print.lbname_to_string lb) lecs
                in
             FStar_All.pipe_right uu____10106 (FStar_String.concat ", ")  in
           FStar_Util.print1 "Generalizing: %s\n" uu____10105
         else ());
        (let univnames_lecs =
           FStar_List.map
             (fun uu____10149  ->
                match uu____10149 with
                | (l,t,c) -> gather_free_univnames env t) lecs
            in
         let generalized_lecs =
           let uu____10178 = gen env is_rec lecs  in
           match uu____10178 with
           | FStar_Pervasives_Native.None  ->
               FStar_All.pipe_right lecs
                 (FStar_List.map
                    (fun uu____10277  ->
                       match uu____10277 with | (l,t,c) -> (l, [], t, c, [])))
           | FStar_Pervasives_Native.Some luecs ->
               ((let uu____10339 =
                   FStar_TypeChecker_Env.debug env FStar_Options.Medium  in
                 if uu____10339
                 then
                   FStar_All.pipe_right luecs
                     (FStar_List.iter
                        (fun uu____10383  ->
                           match uu____10383 with
                           | (l,us,e,c,gvs) ->
                               let uu____10417 =
                                 FStar_Range.string_of_range
                                   e.FStar_Syntax_Syntax.pos
                                  in
                               let uu____10418 =
                                 FStar_Syntax_Print.lbname_to_string l  in
                               let uu____10419 =
                                 FStar_Syntax_Print.term_to_string
                                   (FStar_Syntax_Util.comp_result c)
                                  in
                               let uu____10420 =
                                 FStar_Syntax_Print.term_to_string e  in
                               let uu____10421 =
                                 FStar_Syntax_Print.binders_to_string ", "
                                   gvs
                                  in
                               FStar_Util.print5
                                 "(%s) Generalized %s at type %s\n%s\nVars = (%s)\n"
                                 uu____10417 uu____10418 uu____10419
                                 uu____10420 uu____10421))
                 else ());
                luecs)
            in
         FStar_List.map2
           (fun univnames1  ->
              fun uu____10462  ->
                match uu____10462 with
                | (l,generalized_univs,t,c,gvs) ->
                    let uu____10506 =
                      check_universe_generalization univnames1
                        generalized_univs t
                       in
                    (l, uu____10506, t, c, gvs)) univnames_lecs
           generalized_lecs)
  
let (check_and_ascribe :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.typ ->
        FStar_Syntax_Syntax.typ ->
          (FStar_Syntax_Syntax.term,FStar_TypeChecker_Env.guard_t)
            FStar_Pervasives_Native.tuple2)
  =
  fun env  ->
    fun e  ->
      fun t1  ->
        fun t2  ->
          let env1 =
            FStar_TypeChecker_Env.set_range env e.FStar_Syntax_Syntax.pos  in
          let check1 env2 t11 t21 =
            if env2.FStar_TypeChecker_Env.use_eq
            then FStar_TypeChecker_Rel.try_teq true env2 t11 t21
            else
              (let uu____10549 =
                 FStar_TypeChecker_Rel.get_subtyping_predicate env2 t11 t21
                  in
               match uu____10549 with
               | FStar_Pervasives_Native.None  ->
                   FStar_Pervasives_Native.None
               | FStar_Pervasives_Native.Some f ->
                   let uu____10555 = FStar_TypeChecker_Rel.apply_guard f e
                      in
                   FStar_All.pipe_left
                     (fun _0_43  -> FStar_Pervasives_Native.Some _0_43)
                     uu____10555)
             in
          let is_var e1 =
            let uu____10562 =
              let uu____10563 = FStar_Syntax_Subst.compress e1  in
              uu____10563.FStar_Syntax_Syntax.n  in
            match uu____10562 with
            | FStar_Syntax_Syntax.Tm_name uu____10566 -> true
            | uu____10567 -> false  in
          let decorate e1 t =
            let e2 = FStar_Syntax_Subst.compress e1  in
            match e2.FStar_Syntax_Syntax.n with
            | FStar_Syntax_Syntax.Tm_name x ->
                FStar_Syntax_Syntax.mk
                  (FStar_Syntax_Syntax.Tm_name
                     (let uu___115_10583 = x  in
                      {
                        FStar_Syntax_Syntax.ppname =
                          (uu___115_10583.FStar_Syntax_Syntax.ppname);
                        FStar_Syntax_Syntax.index =
                          (uu___115_10583.FStar_Syntax_Syntax.index);
                        FStar_Syntax_Syntax.sort = t2
                      })) FStar_Pervasives_Native.None
                  e2.FStar_Syntax_Syntax.pos
            | uu____10584 -> e2  in
          let env2 =
            let uu___116_10586 = env1  in
            let uu____10587 =
              env1.FStar_TypeChecker_Env.use_eq ||
                (env1.FStar_TypeChecker_Env.is_pattern && (is_var e))
               in
            {
              FStar_TypeChecker_Env.solver =
                (uu___116_10586.FStar_TypeChecker_Env.solver);
              FStar_TypeChecker_Env.range =
                (uu___116_10586.FStar_TypeChecker_Env.range);
              FStar_TypeChecker_Env.curmodule =
                (uu___116_10586.FStar_TypeChecker_Env.curmodule);
              FStar_TypeChecker_Env.gamma =
                (uu___116_10586.FStar_TypeChecker_Env.gamma);
              FStar_TypeChecker_Env.gamma_cache =
                (uu___116_10586.FStar_TypeChecker_Env.gamma_cache);
              FStar_TypeChecker_Env.modules =
                (uu___116_10586.FStar_TypeChecker_Env.modules);
              FStar_TypeChecker_Env.expected_typ =
                (uu___116_10586.FStar_TypeChecker_Env.expected_typ);
              FStar_TypeChecker_Env.sigtab =
                (uu___116_10586.FStar_TypeChecker_Env.sigtab);
              FStar_TypeChecker_Env.is_pattern =
                (uu___116_10586.FStar_TypeChecker_Env.is_pattern);
              FStar_TypeChecker_Env.instantiate_imp =
                (uu___116_10586.FStar_TypeChecker_Env.instantiate_imp);
              FStar_TypeChecker_Env.effects =
                (uu___116_10586.FStar_TypeChecker_Env.effects);
              FStar_TypeChecker_Env.generalize =
                (uu___116_10586.FStar_TypeChecker_Env.generalize);
              FStar_TypeChecker_Env.letrecs =
                (uu___116_10586.FStar_TypeChecker_Env.letrecs);
              FStar_TypeChecker_Env.top_level =
                (uu___116_10586.FStar_TypeChecker_Env.top_level);
              FStar_TypeChecker_Env.check_uvars =
                (uu___116_10586.FStar_TypeChecker_Env.check_uvars);
              FStar_TypeChecker_Env.use_eq = uu____10587;
              FStar_TypeChecker_Env.is_iface =
                (uu___116_10586.FStar_TypeChecker_Env.is_iface);
              FStar_TypeChecker_Env.admit =
                (uu___116_10586.FStar_TypeChecker_Env.admit);
              FStar_TypeChecker_Env.lax =
                (uu___116_10586.FStar_TypeChecker_Env.lax);
              FStar_TypeChecker_Env.lax_universes =
                (uu___116_10586.FStar_TypeChecker_Env.lax_universes);
              FStar_TypeChecker_Env.failhard =
                (uu___116_10586.FStar_TypeChecker_Env.failhard);
              FStar_TypeChecker_Env.nosynth =
                (uu___116_10586.FStar_TypeChecker_Env.nosynth);
              FStar_TypeChecker_Env.tc_term =
                (uu___116_10586.FStar_TypeChecker_Env.tc_term);
              FStar_TypeChecker_Env.type_of =
                (uu___116_10586.FStar_TypeChecker_Env.type_of);
              FStar_TypeChecker_Env.universe_of =
                (uu___116_10586.FStar_TypeChecker_Env.universe_of);
              FStar_TypeChecker_Env.check_type_of =
                (uu___116_10586.FStar_TypeChecker_Env.check_type_of);
              FStar_TypeChecker_Env.use_bv_sorts =
                (uu___116_10586.FStar_TypeChecker_Env.use_bv_sorts);
              FStar_TypeChecker_Env.qtbl_name_and_index =
                (uu___116_10586.FStar_TypeChecker_Env.qtbl_name_and_index);
              FStar_TypeChecker_Env.normalized_eff_names =
                (uu___116_10586.FStar_TypeChecker_Env.normalized_eff_names);
              FStar_TypeChecker_Env.proof_ns =
                (uu___116_10586.FStar_TypeChecker_Env.proof_ns);
              FStar_TypeChecker_Env.synth_hook =
                (uu___116_10586.FStar_TypeChecker_Env.synth_hook);
              FStar_TypeChecker_Env.splice =
                (uu___116_10586.FStar_TypeChecker_Env.splice);
              FStar_TypeChecker_Env.is_native_tactic =
                (uu___116_10586.FStar_TypeChecker_Env.is_native_tactic);
              FStar_TypeChecker_Env.identifier_info =
                (uu___116_10586.FStar_TypeChecker_Env.identifier_info);
              FStar_TypeChecker_Env.tc_hooks =
                (uu___116_10586.FStar_TypeChecker_Env.tc_hooks);
              FStar_TypeChecker_Env.dsenv =
                (uu___116_10586.FStar_TypeChecker_Env.dsenv);
              FStar_TypeChecker_Env.dep_graph =
                (uu___116_10586.FStar_TypeChecker_Env.dep_graph)
            }  in
          let uu____10588 = check1 env2 t1 t2  in
          match uu____10588 with
          | FStar_Pervasives_Native.None  ->
              let uu____10595 =
                FStar_TypeChecker_Err.expected_expression_of_type env2 t2 e
                  t1
                 in
              let uu____10600 = FStar_TypeChecker_Env.get_range env2  in
              FStar_Errors.raise_error uu____10595 uu____10600
          | FStar_Pervasives_Native.Some g ->
              ((let uu____10607 =
                  FStar_All.pipe_left (FStar_TypeChecker_Env.debug env2)
                    (FStar_Options.Other "Rel")
                   in
                if uu____10607
                then
                  let uu____10608 =
                    FStar_TypeChecker_Rel.guard_to_string env2 g  in
                  FStar_All.pipe_left
                    (FStar_Util.print1 "Applied guard is %s\n") uu____10608
                else ());
               (let uu____10610 = decorate e t2  in (uu____10610, g)))
  
let (check_top_level :
  FStar_TypeChecker_Env.env ->
    FStar_TypeChecker_Env.guard_t ->
      FStar_Syntax_Syntax.lcomp ->
        (Prims.bool,FStar_Syntax_Syntax.comp) FStar_Pervasives_Native.tuple2)
  =
  fun env  ->
    fun g  ->
      fun lc  ->
        let discharge g1 =
          FStar_TypeChecker_Rel.force_trivial_guard env g1;
          FStar_Syntax_Util.is_pure_lcomp lc  in
        let g1 = FStar_TypeChecker_Rel.solve_deferred_constraints env g  in
        let uu____10638 = FStar_Syntax_Util.is_total_lcomp lc  in
        if uu____10638
        then
          let uu____10643 = discharge g1  in
          let uu____10644 = FStar_Syntax_Syntax.lcomp_comp lc  in
          (uu____10643, uu____10644)
        else
          (let c = FStar_Syntax_Syntax.lcomp_comp lc  in
           let steps =
             [FStar_TypeChecker_Normalize.Beta;
             FStar_TypeChecker_Normalize.NoFullNorm;
             FStar_TypeChecker_Normalize.DoNotUnfoldPureLets]  in
           let c1 =
             let uu____10651 =
               let uu____10652 =
                 let uu____10653 =
                   FStar_TypeChecker_Env.unfold_effect_abbrev env c  in
                 FStar_All.pipe_right uu____10653 FStar_Syntax_Syntax.mk_Comp
                  in
               FStar_All.pipe_right uu____10652
                 (FStar_TypeChecker_Normalize.normalize_comp steps env)
                in
             FStar_All.pipe_right uu____10651
               (FStar_TypeChecker_Env.comp_to_comp_typ env)
              in
           let md =
             FStar_TypeChecker_Env.get_effect_decl env
               c1.FStar_Syntax_Syntax.effect_name
              in
           let uu____10655 = destruct_comp c1  in
           match uu____10655 with
           | (u_t,t,wp) ->
               let vc =
                 let uu____10672 = FStar_TypeChecker_Env.get_range env  in
                 let uu____10673 =
                   let uu____10674 =
                     FStar_TypeChecker_Env.inst_effect_fun_with [u_t] env md
                       md.FStar_Syntax_Syntax.trivial
                      in
                   let uu____10675 =
                     let uu____10676 = FStar_Syntax_Syntax.as_arg t  in
                     let uu____10677 =
                       let uu____10680 = FStar_Syntax_Syntax.as_arg wp  in
                       [uu____10680]  in
                     uu____10676 :: uu____10677  in
                   FStar_Syntax_Syntax.mk_Tm_app uu____10674 uu____10675  in
                 uu____10673 FStar_Pervasives_Native.None uu____10672  in
               ((let uu____10684 =
                   FStar_All.pipe_left (FStar_TypeChecker_Env.debug env)
                     (FStar_Options.Other "Simplification")
                    in
                 if uu____10684
                 then
                   let uu____10685 = FStar_Syntax_Print.term_to_string vc  in
                   FStar_Util.print1 "top-level VC: %s\n" uu____10685
                 else ());
                (let g2 =
                   let uu____10688 =
                     FStar_All.pipe_left
                       FStar_TypeChecker_Rel.guard_of_guard_formula
                       (FStar_TypeChecker_Common.NonTrivial vc)
                      in
                   FStar_TypeChecker_Rel.conj_guard g1 uu____10688  in
                 let uu____10689 = discharge g2  in
                 let uu____10690 = FStar_Syntax_Syntax.mk_Comp c1  in
                 (uu____10689, uu____10690))))
  
let (short_circuit :
  FStar_Syntax_Syntax.term ->
    FStar_Syntax_Syntax.args -> FStar_TypeChecker_Common.guard_formula)
  =
  fun head1  ->
    fun seen_args  ->
      let short_bin_op f uu___86_10714 =
        match uu___86_10714 with
        | [] -> FStar_TypeChecker_Common.Trivial
        | (fst1,uu____10722)::[] -> f fst1
        | uu____10739 -> failwith "Unexpexted args to binary operator"  in
      let op_and_e e =
        let uu____10744 = FStar_Syntax_Util.b2t e  in
        FStar_All.pipe_right uu____10744
          (fun _0_44  -> FStar_TypeChecker_Common.NonTrivial _0_44)
         in
      let op_or_e e =
        let uu____10753 =
          let uu____10756 = FStar_Syntax_Util.b2t e  in
          FStar_Syntax_Util.mk_neg uu____10756  in
        FStar_All.pipe_right uu____10753
          (fun _0_45  -> FStar_TypeChecker_Common.NonTrivial _0_45)
         in
      let op_and_t t =
        FStar_All.pipe_right t
          (fun _0_46  -> FStar_TypeChecker_Common.NonTrivial _0_46)
         in
      let op_or_t t =
        let uu____10767 = FStar_All.pipe_right t FStar_Syntax_Util.mk_neg  in
        FStar_All.pipe_right uu____10767
          (fun _0_47  -> FStar_TypeChecker_Common.NonTrivial _0_47)
         in
      let op_imp_t t =
        FStar_All.pipe_right t
          (fun _0_48  -> FStar_TypeChecker_Common.NonTrivial _0_48)
         in
      let short_op_ite uu___87_10781 =
        match uu___87_10781 with
        | [] -> FStar_TypeChecker_Common.Trivial
        | (guard,uu____10789)::[] ->
            FStar_TypeChecker_Common.NonTrivial guard
        | _then::(guard,uu____10808)::[] ->
            let uu____10837 = FStar_Syntax_Util.mk_neg guard  in
            FStar_All.pipe_right uu____10837
              (fun _0_49  -> FStar_TypeChecker_Common.NonTrivial _0_49)
        | uu____10842 -> failwith "Unexpected args to ITE"  in
      let table =
        let uu____10852 =
          let uu____10859 = short_bin_op op_and_e  in
          (FStar_Parser_Const.op_And, uu____10859)  in
        let uu____10864 =
          let uu____10873 =
            let uu____10880 = short_bin_op op_or_e  in
            (FStar_Parser_Const.op_Or, uu____10880)  in
          let uu____10885 =
            let uu____10894 =
              let uu____10901 = short_bin_op op_and_t  in
              (FStar_Parser_Const.and_lid, uu____10901)  in
            let uu____10906 =
              let uu____10915 =
                let uu____10922 = short_bin_op op_or_t  in
                (FStar_Parser_Const.or_lid, uu____10922)  in
              let uu____10927 =
                let uu____10936 =
                  let uu____10943 = short_bin_op op_imp_t  in
                  (FStar_Parser_Const.imp_lid, uu____10943)  in
                [uu____10936; (FStar_Parser_Const.ite_lid, short_op_ite)]  in
              uu____10915 :: uu____10927  in
            uu____10894 :: uu____10906  in
          uu____10873 :: uu____10885  in
        uu____10852 :: uu____10864  in
      match head1.FStar_Syntax_Syntax.n with
      | FStar_Syntax_Syntax.Tm_fvar fv ->
          let lid = (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
             in
          let uu____10994 =
            FStar_Util.find_map table
              (fun uu____11008  ->
                 match uu____11008 with
                 | (x,mk1) ->
                     let uu____11023 = FStar_Ident.lid_equals x lid  in
                     if uu____11023
                     then
                       let uu____11026 = mk1 seen_args  in
                       FStar_Pervasives_Native.Some uu____11026
                     else FStar_Pervasives_Native.None)
             in
          (match uu____10994 with
           | FStar_Pervasives_Native.None  ->
               FStar_TypeChecker_Common.Trivial
           | FStar_Pervasives_Native.Some g -> g)
      | uu____11029 -> FStar_TypeChecker_Common.Trivial
  
let (short_circuit_head : FStar_Syntax_Syntax.term -> Prims.bool) =
  fun l  ->
    let uu____11033 =
      let uu____11034 = FStar_Syntax_Util.un_uinst l  in
      uu____11034.FStar_Syntax_Syntax.n  in
    match uu____11033 with
    | FStar_Syntax_Syntax.Tm_fvar fv ->
        FStar_Util.for_some (FStar_Syntax_Syntax.fv_eq_lid fv)
          [FStar_Parser_Const.op_And;
          FStar_Parser_Const.op_Or;
          FStar_Parser_Const.and_lid;
          FStar_Parser_Const.or_lid;
          FStar_Parser_Const.imp_lid;
          FStar_Parser_Const.ite_lid]
    | uu____11038 -> false
  
let (maybe_add_implicit_binders :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.binders -> FStar_Syntax_Syntax.binders)
  =
  fun env  ->
    fun bs  ->
      let pos bs1 =
        match bs1 with
        | (hd1,uu____11062)::uu____11063 ->
            FStar_Syntax_Syntax.range_of_bv hd1
        | uu____11074 -> FStar_TypeChecker_Env.get_range env  in
      match bs with
      | (uu____11081,FStar_Pervasives_Native.Some
         (FStar_Syntax_Syntax.Implicit uu____11082))::uu____11083 -> bs
      | uu____11100 ->
          let uu____11101 = FStar_TypeChecker_Env.expected_typ env  in
          (match uu____11101 with
           | FStar_Pervasives_Native.None  -> bs
           | FStar_Pervasives_Native.Some t ->
               let uu____11105 =
                 let uu____11106 = FStar_Syntax_Subst.compress t  in
                 uu____11106.FStar_Syntax_Syntax.n  in
               (match uu____11105 with
                | FStar_Syntax_Syntax.Tm_arrow (bs',uu____11110) ->
                    let uu____11127 =
                      FStar_Util.prefix_until
                        (fun uu___88_11167  ->
                           match uu___88_11167 with
                           | (uu____11174,FStar_Pervasives_Native.Some
                              (FStar_Syntax_Syntax.Implicit uu____11175)) ->
                               false
                           | uu____11178 -> true) bs'
                       in
                    (match uu____11127 with
                     | FStar_Pervasives_Native.None  -> bs
                     | FStar_Pervasives_Native.Some
                         ([],uu____11213,uu____11214) -> bs
                     | FStar_Pervasives_Native.Some
                         (imps,uu____11286,uu____11287) ->
                         let uu____11360 =
                           FStar_All.pipe_right imps
                             (FStar_Util.for_all
                                (fun uu____11378  ->
                                   match uu____11378 with
                                   | (x,uu____11386) ->
                                       FStar_Util.starts_with
                                         (x.FStar_Syntax_Syntax.ppname).FStar_Ident.idText
                                         "'"))
                            in
                         if uu____11360
                         then
                           let r = pos bs  in
                           let imps1 =
                             FStar_All.pipe_right imps
                               (FStar_List.map
                                  (fun uu____11433  ->
                                     match uu____11433 with
                                     | (x,i) ->
                                         let uu____11452 =
                                           FStar_Syntax_Syntax.set_range_of_bv
                                             x r
                                            in
                                         (uu____11452, i)))
                              in
                           FStar_List.append imps1 bs
                         else bs)
                | uu____11462 -> bs))
  
let (maybe_lift :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Ident.lident ->
        FStar_Ident.lident ->
          FStar_Syntax_Syntax.typ -> FStar_Syntax_Syntax.term)
  =
  fun env  ->
    fun e  ->
      fun c1  ->
        fun c2  ->
          fun t  ->
            let m1 = FStar_TypeChecker_Env.norm_eff_name env c1  in
            let m2 = FStar_TypeChecker_Env.norm_eff_name env c2  in
            let uu____11480 =
              ((FStar_Ident.lid_equals m1 m2) ||
                 ((FStar_Syntax_Util.is_pure_effect c1) &&
                    (FStar_Syntax_Util.is_ghost_effect c2)))
                ||
                ((FStar_Syntax_Util.is_pure_effect c2) &&
                   (FStar_Syntax_Util.is_ghost_effect c1))
               in
            if uu____11480
            then e
            else
              FStar_Syntax_Syntax.mk
                (FStar_Syntax_Syntax.Tm_meta
                   (e, (FStar_Syntax_Syntax.Meta_monadic_lift (m1, m2, t))))
                FStar_Pervasives_Native.None e.FStar_Syntax_Syntax.pos
  
let (maybe_monadic :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Ident.lident ->
        FStar_Syntax_Syntax.typ -> FStar_Syntax_Syntax.term)
  =
  fun env  ->
    fun e  ->
      fun c  ->
        fun t  ->
          let m = FStar_TypeChecker_Env.norm_eff_name env c  in
          let uu____11495 =
            ((is_pure_or_ghost_effect env m) ||
               (FStar_Ident.lid_equals m FStar_Parser_Const.effect_Tot_lid))
              ||
              (FStar_Ident.lid_equals m FStar_Parser_Const.effect_GTot_lid)
             in
          if uu____11495
          then e
          else
            FStar_Syntax_Syntax.mk
              (FStar_Syntax_Syntax.Tm_meta
                 (e, (FStar_Syntax_Syntax.Meta_monadic (m, t))))
              FStar_Pervasives_Native.None e.FStar_Syntax_Syntax.pos
  
let (d : Prims.string -> Prims.unit) =
  fun s  -> FStar_Util.print1 "\027[01;36m%s\027[00m\n" s 
let (mk_toplevel_definition :
  FStar_TypeChecker_Env.env ->
    FStar_Ident.lident ->
      FStar_Syntax_Syntax.term ->
        (FStar_Syntax_Syntax.sigelt,FStar_Syntax_Syntax.term)
          FStar_Pervasives_Native.tuple2)
  =
  fun env  ->
    fun lident  ->
      fun def  ->
        (let uu____11518 =
           FStar_TypeChecker_Env.debug env (FStar_Options.Other "ED")  in
         if uu____11518
         then
           ((let uu____11520 = FStar_Ident.text_of_lid lident  in
             d uu____11520);
            (let uu____11521 = FStar_Ident.text_of_lid lident  in
             let uu____11522 = FStar_Syntax_Print.term_to_string def  in
             FStar_Util.print2 "Registering top-level definition: %s\n%s\n"
               uu____11521 uu____11522))
         else ());
        (let fv =
           let uu____11525 = FStar_Syntax_Util.incr_delta_qualifier def  in
           FStar_Syntax_Syntax.lid_as_fv lident uu____11525
             FStar_Pervasives_Native.None
            in
         let lbname = FStar_Util.Inr fv  in
         let lb =
           (false,
             [FStar_Syntax_Util.mk_letbinding lbname []
                FStar_Syntax_Syntax.tun FStar_Parser_Const.effect_Tot_lid def
                [] FStar_Range.dummyRange])
            in
         let sig_ctx =
           FStar_Syntax_Syntax.mk_sigelt
             (FStar_Syntax_Syntax.Sig_let (lb, [lident]))
            in
         let uu____11535 =
           FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_fvar fv)
             FStar_Pervasives_Native.None FStar_Range.dummyRange
            in
         ((let uu___117_11541 = sig_ctx  in
           {
             FStar_Syntax_Syntax.sigel =
               (uu___117_11541.FStar_Syntax_Syntax.sigel);
             FStar_Syntax_Syntax.sigrng =
               (uu___117_11541.FStar_Syntax_Syntax.sigrng);
             FStar_Syntax_Syntax.sigquals =
               [FStar_Syntax_Syntax.Unfold_for_unification_and_vcgen];
             FStar_Syntax_Syntax.sigmeta =
               (uu___117_11541.FStar_Syntax_Syntax.sigmeta);
             FStar_Syntax_Syntax.sigattrs =
               (uu___117_11541.FStar_Syntax_Syntax.sigattrs)
           }), uu____11535))
  
let (check_sigelt_quals :
  FStar_TypeChecker_Env.env -> FStar_Syntax_Syntax.sigelt -> Prims.unit) =
  fun env  ->
    fun se  ->
      let visibility uu___89_11551 =
        match uu___89_11551 with
        | FStar_Syntax_Syntax.Private  -> true
        | uu____11552 -> false  in
      let reducibility uu___90_11556 =
        match uu___90_11556 with
        | FStar_Syntax_Syntax.Abstract  -> true
        | FStar_Syntax_Syntax.Irreducible  -> true
        | FStar_Syntax_Syntax.Unfold_for_unification_and_vcgen  -> true
        | FStar_Syntax_Syntax.Visible_default  -> true
        | FStar_Syntax_Syntax.Inline_for_extraction  -> true
        | uu____11557 -> false  in
      let assumption uu___91_11561 =
        match uu___91_11561 with
        | FStar_Syntax_Syntax.Assumption  -> true
        | FStar_Syntax_Syntax.New  -> true
        | uu____11562 -> false  in
      let reification uu___92_11566 =
        match uu___92_11566 with
        | FStar_Syntax_Syntax.Reifiable  -> true
        | FStar_Syntax_Syntax.Reflectable uu____11567 -> true
        | uu____11568 -> false  in
      let inferred uu___93_11572 =
        match uu___93_11572 with
        | FStar_Syntax_Syntax.Discriminator uu____11573 -> true
        | FStar_Syntax_Syntax.Projector uu____11574 -> true
        | FStar_Syntax_Syntax.RecordType uu____11579 -> true
        | FStar_Syntax_Syntax.RecordConstructor uu____11588 -> true
        | FStar_Syntax_Syntax.ExceptionConstructor  -> true
        | FStar_Syntax_Syntax.HasMaskedEffect  -> true
        | FStar_Syntax_Syntax.Effect  -> true
        | uu____11597 -> false  in
      let has_eq uu___94_11601 =
        match uu___94_11601 with
        | FStar_Syntax_Syntax.Noeq  -> true
        | FStar_Syntax_Syntax.Unopteq  -> true
        | uu____11602 -> false  in
      let quals_combo_ok quals q =
        match q with
        | FStar_Syntax_Syntax.Assumption  ->
            FStar_All.pipe_right quals
              (FStar_List.for_all
                 (fun x  ->
                    ((((((x = q) || (x = FStar_Syntax_Syntax.Logic)) ||
                          (inferred x))
                         || (visibility x))
                        || (assumption x))
                       ||
                       (env.FStar_TypeChecker_Env.is_iface &&
                          (x = FStar_Syntax_Syntax.Inline_for_extraction)))
                      || (x = FStar_Syntax_Syntax.NoExtract)))
        | FStar_Syntax_Syntax.New  ->
            FStar_All.pipe_right quals
              (FStar_List.for_all
                 (fun x  ->
                    (((x = q) || (inferred x)) || (visibility x)) ||
                      (assumption x)))
        | FStar_Syntax_Syntax.Inline_for_extraction  ->
            FStar_All.pipe_right quals
              (FStar_List.for_all
                 (fun x  ->
                    (((((((x = q) || (x = FStar_Syntax_Syntax.Logic)) ||
                           (visibility x))
                          || (reducibility x))
                         || (reification x))
                        || (inferred x))
                       ||
                       (env.FStar_TypeChecker_Env.is_iface &&
                          (x = FStar_Syntax_Syntax.Assumption)))
                      || (x = FStar_Syntax_Syntax.NoExtract)))
        | FStar_Syntax_Syntax.Unfold_for_unification_and_vcgen  ->
            FStar_All.pipe_right quals
              (FStar_List.for_all
                 (fun x  ->
                    ((((((((x = q) || (x = FStar_Syntax_Syntax.Logic)) ||
                            (x = FStar_Syntax_Syntax.Abstract))
                           || (x = FStar_Syntax_Syntax.Inline_for_extraction))
                          || (x = FStar_Syntax_Syntax.NoExtract))
                         || (has_eq x))
                        || (inferred x))
                       || (visibility x))
                      || (reification x)))
        | FStar_Syntax_Syntax.Visible_default  ->
            FStar_All.pipe_right quals
              (FStar_List.for_all
                 (fun x  ->
                    ((((((((x = q) || (x = FStar_Syntax_Syntax.Logic)) ||
                            (x = FStar_Syntax_Syntax.Abstract))
                           || (x = FStar_Syntax_Syntax.Inline_for_extraction))
                          || (x = FStar_Syntax_Syntax.NoExtract))
                         || (has_eq x))
                        || (inferred x))
                       || (visibility x))
                      || (reification x)))
        | FStar_Syntax_Syntax.Irreducible  ->
            FStar_All.pipe_right quals
              (FStar_List.for_all
                 (fun x  ->
                    ((((((((x = q) || (x = FStar_Syntax_Syntax.Logic)) ||
                            (x = FStar_Syntax_Syntax.Abstract))
                           || (x = FStar_Syntax_Syntax.Inline_for_extraction))
                          || (x = FStar_Syntax_Syntax.NoExtract))
                         || (has_eq x))
                        || (inferred x))
                       || (visibility x))
                      || (reification x)))
        | FStar_Syntax_Syntax.Abstract  ->
            FStar_All.pipe_right quals
              (FStar_List.for_all
                 (fun x  ->
                    ((((((((x = q) || (x = FStar_Syntax_Syntax.Logic)) ||
                            (x = FStar_Syntax_Syntax.Abstract))
                           || (x = FStar_Syntax_Syntax.Inline_for_extraction))
                          || (x = FStar_Syntax_Syntax.NoExtract))
                         || (has_eq x))
                        || (inferred x))
                       || (visibility x))
                      || (reification x)))
        | FStar_Syntax_Syntax.Noeq  ->
            FStar_All.pipe_right quals
              (FStar_List.for_all
                 (fun x  ->
                    ((((((((x = q) || (x = FStar_Syntax_Syntax.Logic)) ||
                            (x = FStar_Syntax_Syntax.Abstract))
                           || (x = FStar_Syntax_Syntax.Inline_for_extraction))
                          || (x = FStar_Syntax_Syntax.NoExtract))
                         || (has_eq x))
                        || (inferred x))
                       || (visibility x))
                      || (reification x)))
        | FStar_Syntax_Syntax.Unopteq  ->
            FStar_All.pipe_right quals
              (FStar_List.for_all
                 (fun x  ->
                    ((((((((x = q) || (x = FStar_Syntax_Syntax.Logic)) ||
                            (x = FStar_Syntax_Syntax.Abstract))
                           || (x = FStar_Syntax_Syntax.Inline_for_extraction))
                          || (x = FStar_Syntax_Syntax.NoExtract))
                         || (has_eq x))
                        || (inferred x))
                       || (visibility x))
                      || (reification x)))
        | FStar_Syntax_Syntax.TotalEffect  ->
            FStar_All.pipe_right quals
              (FStar_List.for_all
                 (fun x  ->
                    (((x = q) || (inferred x)) || (visibility x)) ||
                      (reification x)))
        | FStar_Syntax_Syntax.Logic  ->
            FStar_All.pipe_right quals
              (FStar_List.for_all
                 (fun x  ->
                    ((((x = q) || (x = FStar_Syntax_Syntax.Assumption)) ||
                        (inferred x))
                       || (visibility x))
                      || (reducibility x)))
        | FStar_Syntax_Syntax.Reifiable  ->
            FStar_All.pipe_right quals
              (FStar_List.for_all
                 (fun x  ->
                    ((((reification x) || (inferred x)) || (visibility x)) ||
                       (x = FStar_Syntax_Syntax.TotalEffect))
                      || (x = FStar_Syntax_Syntax.Visible_default)))
        | FStar_Syntax_Syntax.Reflectable uu____11662 ->
            FStar_All.pipe_right quals
              (FStar_List.for_all
                 (fun x  ->
                    ((((reification x) || (inferred x)) || (visibility x)) ||
                       (x = FStar_Syntax_Syntax.TotalEffect))
                      || (x = FStar_Syntax_Syntax.Visible_default)))
        | FStar_Syntax_Syntax.Private  -> true
        | uu____11667 -> true  in
      let quals = FStar_Syntax_Util.quals_of_sigelt se  in
      let uu____11671 =
        let uu____11672 =
          FStar_All.pipe_right quals
            (FStar_Util.for_some
               (fun uu___95_11676  ->
                  match uu___95_11676 with
                  | FStar_Syntax_Syntax.OnlyName  -> true
                  | uu____11677 -> false))
           in
        FStar_All.pipe_right uu____11672 Prims.op_Negation  in
      if uu____11671
      then
        let r = FStar_Syntax_Util.range_of_sigelt se  in
        let no_dup_quals =
          FStar_Util.remove_dups (fun x  -> fun y  -> x = y) quals  in
        let err' msg =
          let uu____11690 =
            let uu____11695 =
              let uu____11696 = FStar_Syntax_Print.quals_to_string quals  in
              FStar_Util.format2
                "The qualifier list \"[%s]\" is not permissible for this element%s"
                uu____11696 msg
               in
            (FStar_Errors.Fatal_QulifierListNotPermitted, uu____11695)  in
          FStar_Errors.raise_error uu____11690 r  in
        let err msg = err' (Prims.strcat ": " msg)  in
        let err'1 uu____11704 = err' ""  in
        (if (FStar_List.length quals) <> (FStar_List.length no_dup_quals)
         then err "duplicate qualifiers"
         else ();
         (let uu____11708 =
            let uu____11709 =
              FStar_All.pipe_right quals
                (FStar_List.for_all (quals_combo_ok quals))
               in
            Prims.op_Negation uu____11709  in
          if uu____11708 then err "ill-formed combination" else ());
         (match se.FStar_Syntax_Syntax.sigel with
          | FStar_Syntax_Syntax.Sig_let ((is_rec,uu____11714),uu____11715) ->
              ((let uu____11731 =
                  is_rec &&
                    (FStar_All.pipe_right quals
                       (FStar_List.contains
                          FStar_Syntax_Syntax.Unfold_for_unification_and_vcgen))
                   in
                if uu____11731
                then err "recursive definitions cannot be marked inline"
                else ());
               (let uu____11735 =
                  FStar_All.pipe_right quals
                    (FStar_Util.for_some
                       (fun x  -> (assumption x) || (has_eq x)))
                   in
                if uu____11735
                then
                  err
                    "definitions cannot be assumed or marked with equality qualifiers"
                else ()))
          | FStar_Syntax_Syntax.Sig_bundle uu____11741 ->
              let uu____11750 =
                let uu____11751 =
                  FStar_All.pipe_right quals
                    (FStar_Util.for_all
                       (fun x  ->
                          (((x = FStar_Syntax_Syntax.Abstract) ||
                              (inferred x))
                             || (visibility x))
                            || (has_eq x)))
                   in
                Prims.op_Negation uu____11751  in
              if uu____11750 then err'1 () else ()
          | FStar_Syntax_Syntax.Sig_declare_typ uu____11757 ->
              let uu____11764 =
                FStar_All.pipe_right quals (FStar_Util.for_some has_eq)  in
              if uu____11764 then err'1 () else ()
          | FStar_Syntax_Syntax.Sig_assume uu____11768 ->
              let uu____11775 =
                let uu____11776 =
                  FStar_All.pipe_right quals
                    (FStar_Util.for_all
                       (fun x  ->
                          (visibility x) ||
                            (x = FStar_Syntax_Syntax.Assumption)))
                   in
                Prims.op_Negation uu____11776  in
              if uu____11775 then err'1 () else ()
          | FStar_Syntax_Syntax.Sig_new_effect uu____11782 ->
              let uu____11783 =
                let uu____11784 =
                  FStar_All.pipe_right quals
                    (FStar_Util.for_all
                       (fun x  ->
                          (((x = FStar_Syntax_Syntax.TotalEffect) ||
                              (inferred x))
                             || (visibility x))
                            || (reification x)))
                   in
                Prims.op_Negation uu____11784  in
              if uu____11783 then err'1 () else ()
          | FStar_Syntax_Syntax.Sig_new_effect_for_free uu____11790 ->
              let uu____11791 =
                let uu____11792 =
                  FStar_All.pipe_right quals
                    (FStar_Util.for_all
                       (fun x  ->
                          (((x = FStar_Syntax_Syntax.TotalEffect) ||
                              (inferred x))
                             || (visibility x))
                            || (reification x)))
                   in
                Prims.op_Negation uu____11792  in
              if uu____11791 then err'1 () else ()
          | FStar_Syntax_Syntax.Sig_effect_abbrev uu____11798 ->
              let uu____11811 =
                let uu____11812 =
                  FStar_All.pipe_right quals
                    (FStar_Util.for_all
                       (fun x  -> (inferred x) || (visibility x)))
                   in
                Prims.op_Negation uu____11812  in
              if uu____11811 then err'1 () else ()
          | uu____11818 -> ()))
      else ()
  