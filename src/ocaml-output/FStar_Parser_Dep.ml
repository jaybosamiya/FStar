open Prims
type verify_mode =
  | VerifyAll 
  | VerifyUserList 
  | VerifyFigureItOut [@@deriving show]
let (uu___is_VerifyAll : verify_mode -> Prims.bool) =
  fun projectee  ->
    match projectee with | VerifyAll  -> true | uu____6 -> false
  
let (uu___is_VerifyUserList : verify_mode -> Prims.bool) =
  fun projectee  ->
    match projectee with | VerifyUserList  -> true | uu____12 -> false
  
let (uu___is_VerifyFigureItOut : verify_mode -> Prims.bool) =
  fun projectee  ->
    match projectee with | VerifyFigureItOut  -> true | uu____18 -> false
  
type files_for_module_name =
  (Prims.string FStar_Pervasives_Native.option,Prims.string
                                                 FStar_Pervasives_Native.option)
    FStar_Pervasives_Native.tuple2 FStar_Util.smap[@@deriving show]
type color =
  | White 
  | Gray 
  | Black [@@deriving show]
let (uu___is_White : color -> Prims.bool) =
  fun projectee  -> match projectee with | White  -> true | uu____34 -> false 
let (uu___is_Gray : color -> Prims.bool) =
  fun projectee  -> match projectee with | Gray  -> true | uu____40 -> false 
let (uu___is_Black : color -> Prims.bool) =
  fun projectee  -> match projectee with | Black  -> true | uu____46 -> false 
type open_kind =
  | Open_module 
  | Open_namespace [@@deriving show]
let (uu___is_Open_module : open_kind -> Prims.bool) =
  fun projectee  ->
    match projectee with | Open_module  -> true | uu____52 -> false
  
let (uu___is_Open_namespace : open_kind -> Prims.bool) =
  fun projectee  ->
    match projectee with | Open_namespace  -> true | uu____58 -> false
  
let (check_and_strip_suffix :
  Prims.string -> Prims.string FStar_Pervasives_Native.option) =
  fun f  ->
    let suffixes = [".fsti"; ".fst"; ".fsi"; ".fs"]  in
    let matches =
      FStar_List.map
        (fun ext  ->
           let lext = FStar_String.length ext  in
           let l = FStar_String.length f  in
           let uu____86 =
             (l > lext) &&
               (let uu____98 = FStar_String.substring f (l - lext) lext  in
                uu____98 = ext)
              in
           if uu____86
           then
             let uu____115 =
               FStar_String.substring f (Prims.parse_int "0") (l - lext)  in
             FStar_Pervasives_Native.Some uu____115
           else FStar_Pervasives_Native.None) suffixes
       in
    let uu____127 = FStar_List.filter FStar_Util.is_some matches  in
    match uu____127 with
    | (FStar_Pervasives_Native.Some m)::uu____137 ->
        FStar_Pervasives_Native.Some m
    | uu____144 -> FStar_Pervasives_Native.None
  
let (is_interface : Prims.string -> Prims.bool) =
  fun f  ->
    let uu____154 =
      FStar_String.get f ((FStar_String.length f) - (Prims.parse_int "1"))
       in
    uu____154 = 105
  
let (is_implementation : Prims.string -> Prims.bool) =
  fun f  -> let uu____163 = is_interface f  in Prims.op_Negation uu____163 
let list_of_option :
  'Auu____168 .
    'Auu____168 FStar_Pervasives_Native.option -> 'Auu____168 Prims.list
  =
  fun uu___55_177  ->
    match uu___55_177 with
    | FStar_Pervasives_Native.Some x -> [x]
    | FStar_Pervasives_Native.None  -> []
  
let list_of_pair :
  'Auu____185 .
    ('Auu____185 FStar_Pervasives_Native.option,'Auu____185
                                                  FStar_Pervasives_Native.option)
      FStar_Pervasives_Native.tuple2 -> 'Auu____185 Prims.list
  =
  fun uu____200  ->
    match uu____200 with
    | (intf,impl) ->
        FStar_List.append (list_of_option intf) (list_of_option impl)
  
let (module_name_of_file : Prims.string -> Prims.string) =
  fun f  ->
    let uu____224 =
      let uu____227 = FStar_Util.basename f  in
      check_and_strip_suffix uu____227  in
    match uu____224 with
    | FStar_Pervasives_Native.Some longname -> longname
    | FStar_Pervasives_Native.None  ->
        let uu____229 =
          let uu____234 = FStar_Util.format1 "not a valid FStar file: %s\n" f
             in
          (FStar_Errors.Fatal_NotValidFStarFile, uu____234)  in
        FStar_Errors.raise_err uu____229
  
let (lowercase_module_name : Prims.string -> Prims.string) =
  fun f  ->
    let uu____240 = module_name_of_file f  in
    FStar_String.lowercase uu____240
  
let (namespace_of_module :
  Prims.string -> FStar_Ident.lident FStar_Pervasives_Native.option) =
  fun f  ->
    let lid =
      let uu____249 = FStar_Ident.path_of_text f  in
      FStar_Ident.lid_of_path uu____249 FStar_Range.dummyRange  in
    match lid.FStar_Ident.ns with
    | [] -> FStar_Pervasives_Native.None
    | uu____252 ->
        let uu____255 = FStar_Ident.lid_of_ids lid.FStar_Ident.ns  in
        FStar_Pervasives_Native.Some uu____255
  
type file_name = Prims.string[@@deriving show]
type module_name = Prims.string[@@deriving show]
type dependence =
  | UseInterface of module_name 
  | PreferInterface of module_name 
  | UseImplementation of module_name [@@deriving show]
let (uu___is_UseInterface : dependence -> Prims.bool) =
  fun projectee  ->
    match projectee with | UseInterface _0 -> true | uu____277 -> false
  
let (__proj__UseInterface__item___0 : dependence -> module_name) =
  fun projectee  -> match projectee with | UseInterface _0 -> _0 
let (uu___is_PreferInterface : dependence -> Prims.bool) =
  fun projectee  ->
    match projectee with | PreferInterface _0 -> true | uu____291 -> false
  
let (__proj__PreferInterface__item___0 : dependence -> module_name) =
  fun projectee  -> match projectee with | PreferInterface _0 -> _0 
let (uu___is_UseImplementation : dependence -> Prims.bool) =
  fun projectee  ->
    match projectee with | UseImplementation _0 -> true | uu____305 -> false
  
let (__proj__UseImplementation__item___0 : dependence -> module_name) =
  fun projectee  -> match projectee with | UseImplementation _0 -> _0 
type dependences = dependence Prims.list[@@deriving show]
let empty_dependences : 'Auu____317 . unit -> 'Auu____317 Prims.list =
  fun uu____320  -> [] 
type dependence_graph =
  | Deps of (dependences,color) FStar_Pervasives_Native.tuple2
  FStar_Util.smap [@@deriving show]
let (uu___is_Deps : dependence_graph -> Prims.bool) = fun projectee  -> true 
let (__proj__Deps__item___0 :
  dependence_graph ->
    (dependences,color) FStar_Pervasives_Native.tuple2 FStar_Util.smap)
  = fun projectee  -> match projectee with | Deps _0 -> _0 
type deps =
  | Mk of (dependence_graph,files_for_module_name,file_name Prims.list)
  FStar_Pervasives_Native.tuple3 [@@deriving show]
let (uu___is_Mk : deps -> Prims.bool) = fun projectee  -> true 
let (__proj__Mk__item___0 :
  deps ->
    (dependence_graph,files_for_module_name,file_name Prims.list)
      FStar_Pervasives_Native.tuple3)
  = fun projectee  -> match projectee with | Mk _0 -> _0 
let (deps_try_find :
  dependence_graph ->
    Prims.string ->
      (dependences,color) FStar_Pervasives_Native.tuple2
        FStar_Pervasives_Native.option)
  =
  fun uu____423  ->
    fun k  -> match uu____423 with | Deps m -> FStar_Util.smap_try_find m k
  
let (deps_add_dep :
  dependence_graph ->
    Prims.string ->
      (dependences,color) FStar_Pervasives_Native.tuple2 -> unit)
  =
  fun uu____458  ->
    fun k  ->
      fun v1  -> match uu____458 with | Deps m -> FStar_Util.smap_add m k v1
  
let (deps_keys : dependence_graph -> Prims.string Prims.list) =
  fun uu____482  -> match uu____482 with | Deps m -> FStar_Util.smap_keys m 
let (deps_empty : unit -> dependence_graph) =
  fun uu____500  ->
    let uu____501 = FStar_Util.smap_create (Prims.parse_int "41")  in
    Deps uu____501
  
let (empty_deps : deps) =
  let uu____512 =
    let uu____521 = deps_empty ()  in
    let uu____522 = FStar_Util.smap_create (Prims.parse_int "0")  in
    (uu____521, uu____522, [])  in
  Mk uu____512 
let (module_name_of_dep : dependence -> module_name) =
  fun uu___56_557  ->
    match uu___56_557 with
    | UseInterface m -> m
    | PreferInterface m -> m
    | UseImplementation m -> m
  
let (resolve_module_name :
  files_for_module_name ->
    module_name -> module_name FStar_Pervasives_Native.option)
  =
  fun file_system_map  ->
    fun key  ->
      let uu____575 = FStar_Util.smap_try_find file_system_map key  in
      match uu____575 with
      | FStar_Pervasives_Native.Some
          (FStar_Pervasives_Native.Some fn,uu____597) ->
          let uu____612 = lowercase_module_name fn  in
          FStar_Pervasives_Native.Some uu____612
      | FStar_Pervasives_Native.Some
          (uu____613,FStar_Pervasives_Native.Some fn) ->
          let uu____629 = lowercase_module_name fn  in
          FStar_Pervasives_Native.Some uu____629
      | uu____630 -> FStar_Pervasives_Native.None
  
let (interface_of :
  files_for_module_name ->
    module_name -> file_name FStar_Pervasives_Native.option)
  =
  fun file_system_map  ->
    fun key  ->
      let uu____655 = FStar_Util.smap_try_find file_system_map key  in
      match uu____655 with
      | FStar_Pervasives_Native.Some
          (FStar_Pervasives_Native.Some iface,uu____677) ->
          FStar_Pervasives_Native.Some iface
      | uu____692 -> FStar_Pervasives_Native.None
  
let (implementation_of :
  files_for_module_name ->
    module_name -> file_name FStar_Pervasives_Native.option)
  =
  fun file_system_map  ->
    fun key  ->
      let uu____717 = FStar_Util.smap_try_find file_system_map key  in
      match uu____717 with
      | FStar_Pervasives_Native.Some
          (uu____738,FStar_Pervasives_Native.Some impl) ->
          FStar_Pervasives_Native.Some impl
      | uu____754 -> FStar_Pervasives_Native.None
  
let (has_interface : files_for_module_name -> module_name -> Prims.bool) =
  fun file_system_map  ->
    fun key  ->
      let uu____775 = interface_of file_system_map key  in
      FStar_Option.isSome uu____775
  
let (has_implementation : files_for_module_name -> module_name -> Prims.bool)
  =
  fun file_system_map  ->
    fun key  ->
      let uu____788 = implementation_of file_system_map key  in
      FStar_Option.isSome uu____788
  
let (cache_file_name : Prims.string -> Prims.string) =
  fun fn  ->
    let uu____796 =
      let uu____797 = FStar_Options.lax ()  in
      if uu____797
      then Prims.strcat fn ".checked.lax"
      else Prims.strcat fn ".checked"  in
    FStar_Options.prepend_cache_dir uu____796
  
let (file_of_dep_aux :
  Prims.bool ->
    files_for_module_name -> file_name Prims.list -> dependence -> file_name)
  =
  fun use_checked_file  ->
    fun file_system_map  ->
      fun all_cmd_line_files  ->
        fun d  ->
          let cmd_line_has_impl key =
            FStar_All.pipe_right all_cmd_line_files
              (FStar_Util.for_some
                 (fun fn  ->
                    (is_implementation fn) &&
                      (let uu____834 = lowercase_module_name fn  in
                       key = uu____834)))
             in
          let maybe_add_suffix f =
            if use_checked_file then cache_file_name f else f  in
          match d with
          | UseInterface key ->
              let uu____843 = interface_of file_system_map key  in
              (match uu____843 with
               | FStar_Pervasives_Native.None  ->
                   let uu____847 =
                     let uu____852 =
                       FStar_Util.format1
                         "Expected an interface for module %s, but couldn't find one"
                         key
                        in
                     (FStar_Errors.Fatal_MissingInterface, uu____852)  in
                   FStar_Errors.raise_err uu____847
               | FStar_Pervasives_Native.Some f ->
                   if use_checked_file
                   then
                     FStar_Options.prepend_cache_dir
                       (Prims.strcat f ".source")
                   else f)
          | PreferInterface key when has_interface file_system_map key ->
              let uu____856 =
                (cmd_line_has_impl key) &&
                  (let uu____858 = FStar_Options.dep ()  in
                   FStar_Option.isNone uu____858)
                 in
              if uu____856
              then
                let uu____861 = FStar_Options.expose_interfaces ()  in
                (if uu____861
                 then
                   let uu____862 =
                     let uu____863 = implementation_of file_system_map key
                        in
                     FStar_Option.get uu____863  in
                   maybe_add_suffix uu____862
                 else
                   (let uu____867 =
                      let uu____872 =
                        let uu____873 =
                          let uu____874 =
                            implementation_of file_system_map key  in
                          FStar_Option.get uu____874  in
                        let uu____877 =
                          let uu____878 = interface_of file_system_map key
                             in
                          FStar_Option.get uu____878  in
                        FStar_Util.format2
                          "Invoking fstar with %s on the command line breaks the abstraction imposed by its interface %s; if you really want this behavior add the option '--expose_interfaces'"
                          uu____873 uu____877
                         in
                      (FStar_Errors.Fatal_MissingExposeInterfacesOption,
                        uu____872)
                       in
                    FStar_Errors.raise_err uu____867))
              else
                (let uu____882 =
                   let uu____883 = interface_of file_system_map key  in
                   FStar_Option.get uu____883  in
                 maybe_add_suffix uu____882)
          | PreferInterface key ->
              let uu____887 = implementation_of file_system_map key  in
              (match uu____887 with
               | FStar_Pervasives_Native.None  ->
                   let uu____891 =
                     let uu____896 =
                       FStar_Util.format1
                         "Expected an implementation of module %s, but couldn't find one"
                         key
                        in
                     (FStar_Errors.Fatal_MissingImplementation, uu____896)
                      in
                   FStar_Errors.raise_err uu____891
               | FStar_Pervasives_Native.Some f -> maybe_add_suffix f)
          | UseImplementation key ->
              let uu____899 = implementation_of file_system_map key  in
              (match uu____899 with
               | FStar_Pervasives_Native.None  ->
                   let uu____903 =
                     let uu____908 =
                       FStar_Util.format1
                         "Expected an implementation of module %s, but couldn't find one"
                         key
                        in
                     (FStar_Errors.Fatal_MissingImplementation, uu____908)
                      in
                   FStar_Errors.raise_err uu____903
               | FStar_Pervasives_Native.Some f -> maybe_add_suffix f)
  
let (file_of_dep :
  files_for_module_name -> file_name Prims.list -> dependence -> file_name) =
  file_of_dep_aux false 
let (dependences_of :
  files_for_module_name ->
    dependence_graph ->
      file_name Prims.list -> file_name -> file_name Prims.list)
  =
  fun file_system_map  ->
    fun deps  ->
      fun all_cmd_line_files  ->
        fun fn  ->
          let uu____952 = deps_try_find deps fn  in
          match uu____952 with
          | FStar_Pervasives_Native.None  -> empty_dependences ()
          | FStar_Pervasives_Native.Some (deps1,uu____966) ->
              FStar_List.map (file_of_dep file_system_map all_cmd_line_files)
                deps1
  
let (add_dependence : dependence_graph -> file_name -> file_name -> unit) =
  fun deps  ->
    fun from  ->
      fun to_  ->
        let add_dep uu____1007 to_1 =
          match uu____1007 with
          | (d,color) ->
              let uu____1027 = is_interface to_1  in
              if uu____1027
              then
                let uu____1034 =
                  let uu____1037 =
                    let uu____1038 = lowercase_module_name to_1  in
                    PreferInterface uu____1038  in
                  uu____1037 :: d  in
                (uu____1034, color)
              else
                (let uu____1042 =
                   let uu____1045 =
                     let uu____1046 = lowercase_module_name to_1  in
                     UseImplementation uu____1046  in
                   uu____1045 :: d  in
                 (uu____1042, color))
           in
        let uu____1049 = deps_try_find deps from  in
        match uu____1049 with
        | FStar_Pervasives_Native.None  ->
            let uu____1060 = add_dep ((empty_dependences ()), White) to_  in
            deps_add_dep deps from uu____1060
        | FStar_Pervasives_Native.Some key_deps ->
            let uu____1076 = add_dep key_deps to_  in
            deps_add_dep deps from uu____1076
  
let (print_graph : dependence_graph -> unit) =
  fun graph  ->
    FStar_Util.print_endline
      "A DOT-format graph has been dumped in the current directory as dep.graph";
    FStar_Util.print_endline
      "With GraphViz installed, try: fdp -Tpng -odep.png dep.graph";
    FStar_Util.print_endline
      "Hint: cat dep.graph | grep -v _ | grep -v prims";
    (let uu____1089 =
       let uu____1090 =
         let uu____1091 =
           let uu____1092 =
             let uu____1095 =
               let uu____1098 = deps_keys graph  in
               FStar_List.unique uu____1098  in
             FStar_List.collect
               (fun k  ->
                  let deps =
                    let uu____1107 =
                      let uu____1112 = deps_try_find graph k  in
                      FStar_Util.must uu____1112  in
                    FStar_Pervasives_Native.fst uu____1107  in
                  let r s = FStar_Util.replace_char s 46 95  in
                  let print7 dep1 =
                    FStar_Util.format2 " %s -> %s" (r k)
                      (r (module_name_of_dep dep1))
                     in
                  FStar_List.map print7 deps) uu____1095
              in
           FStar_String.concat "\n" uu____1092  in
         Prims.strcat uu____1091 "\n}\n"  in
       Prims.strcat "digraph {\n" uu____1090  in
     FStar_Util.write_file "dep.graph" uu____1089)
  
let (build_inclusion_candidates_list :
  unit ->
    (Prims.string,Prims.string) FStar_Pervasives_Native.tuple2 Prims.list)
  =
  fun uu____1147  ->
    let include_directories = FStar_Options.include_path ()  in
    let include_directories1 =
      FStar_List.map FStar_Util.normalize_file_path include_directories  in
    let include_directories2 = FStar_List.unique include_directories1  in
    let cwd =
      let uu____1164 = FStar_Util.getcwd ()  in
      FStar_Util.normalize_file_path uu____1164  in
    FStar_List.concatMap
      (fun d  ->
         if FStar_Util.file_exists d
         then
           let files = FStar_Util.readdir d  in
           FStar_List.filter_map
             (fun f  ->
                let f1 = FStar_Util.basename f  in
                let uu____1190 = check_and_strip_suffix f1  in
                FStar_All.pipe_right uu____1190
                  (FStar_Util.map_option
                     (fun longname  ->
                        let full_path =
                          if d = cwd then f1 else FStar_Util.join_paths d f1
                           in
                        (longname, full_path)))) files
         else
           (let uu____1211 =
              let uu____1216 =
                FStar_Util.format1 "not a valid include directory: %s\n" d
                 in
              (FStar_Errors.Fatal_NotValidIncludeDirectory, uu____1216)  in
            FStar_Errors.raise_err uu____1211)) include_directories2
  
let (build_map : Prims.string Prims.list -> files_for_module_name) =
  fun filenames  ->
    let map1 = FStar_Util.smap_create (Prims.parse_int "41")  in
    let add_entry key full_path =
      let uu____1262 = FStar_Util.smap_try_find map1 key  in
      match uu____1262 with
      | FStar_Pervasives_Native.Some (intf,impl) ->
          let uu____1299 = is_interface full_path  in
          if uu____1299
          then
            FStar_Util.smap_add map1 key
              ((FStar_Pervasives_Native.Some full_path), impl)
          else
            FStar_Util.smap_add map1 key
              (intf, (FStar_Pervasives_Native.Some full_path))
      | FStar_Pervasives_Native.None  ->
          let uu____1333 = is_interface full_path  in
          if uu____1333
          then
            FStar_Util.smap_add map1 key
              ((FStar_Pervasives_Native.Some full_path),
                FStar_Pervasives_Native.None)
          else
            FStar_Util.smap_add map1 key
              (FStar_Pervasives_Native.None,
                (FStar_Pervasives_Native.Some full_path))
       in
    (let uu____1360 = build_inclusion_candidates_list ()  in
     FStar_List.iter
       (fun uu____1374  ->
          match uu____1374 with
          | (longname,full_path) ->
              add_entry (FStar_String.lowercase longname) full_path)
       uu____1360);
    FStar_List.iter
      (fun f  ->
         let uu____1385 = lowercase_module_name f  in add_entry uu____1385 f)
      filenames;
    map1
  
let (enter_namespace :
  files_for_module_name ->
    files_for_module_name -> Prims.string -> Prims.bool)
  =
  fun original_map  ->
    fun working_map  ->
      fun prefix1  ->
        let found = FStar_Util.mk_ref false  in
        let prefix2 = Prims.strcat prefix1 "."  in
        (let uu____1406 =
           let uu____1409 = FStar_Util.smap_keys original_map  in
           FStar_List.unique uu____1409  in
         FStar_List.iter
           (fun k  ->
              if FStar_Util.starts_with k prefix2
              then
                let suffix =
                  FStar_String.substring k (FStar_String.length prefix2)
                    ((FStar_String.length k) - (FStar_String.length prefix2))
                   in
                let filename =
                  let uu____1435 = FStar_Util.smap_try_find original_map k
                     in
                  FStar_Util.must uu____1435  in
                (FStar_Util.smap_add working_map suffix filename;
                 FStar_ST.op_Colon_Equals found true)
              else ()) uu____1406);
        FStar_ST.op_Bang found
  
let (string_of_lid : FStar_Ident.lident -> Prims.bool -> Prims.string) =
  fun l  ->
    fun last1  ->
      let suffix =
        if last1 then [(l.FStar_Ident.ident).FStar_Ident.idText] else []  in
      let names =
        let uu____1581 =
          FStar_List.map (fun x  -> x.FStar_Ident.idText) l.FStar_Ident.ns
           in
        FStar_List.append uu____1581 suffix  in
      FStar_String.concat "." names
  
let (lowercase_join_longident :
  FStar_Ident.lident -> Prims.bool -> Prims.string) =
  fun l  ->
    fun last1  ->
      let uu____1596 = string_of_lid l last1  in
      FStar_String.lowercase uu____1596
  
let (namespace_of_lid : FStar_Ident.lident -> Prims.string) =
  fun l  ->
    let uu____1602 = FStar_List.map FStar_Ident.text_of_id l.FStar_Ident.ns
       in
    FStar_String.concat "_" uu____1602
  
let (check_module_declaration_against_filename :
  FStar_Ident.lident -> Prims.string -> unit) =
  fun lid  ->
    fun filename  ->
      let k' = lowercase_join_longident lid true  in
      let uu____1616 =
        let uu____1617 =
          let uu____1618 =
            let uu____1619 =
              let uu____1622 = FStar_Util.basename filename  in
              check_and_strip_suffix uu____1622  in
            FStar_Util.must uu____1619  in
          FStar_String.lowercase uu____1618  in
        uu____1617 <> k'  in
      if uu____1616
      then
        let uu____1623 = FStar_Ident.range_of_lid lid  in
        let uu____1624 =
          let uu____1629 =
            let uu____1630 = string_of_lid lid true  in
            FStar_Util.format2
              "The module declaration \"module %s\" found in file %s does not match its filename. Dependencies will be incorrect and the module will not be verified.\n"
              uu____1630 filename
             in
          (FStar_Errors.Error_ModuleFileNameMismatch, uu____1629)  in
        FStar_Errors.log_issue uu____1623 uu____1624
      else ()
  
exception Exit 
let (uu___is_Exit : Prims.exn -> Prims.bool) =
  fun projectee  ->
    match projectee with | Exit  -> true | uu____1637 -> false
  
let (hard_coded_dependencies :
  Prims.string ->
    (FStar_Ident.lident,open_kind) FStar_Pervasives_Native.tuple2 Prims.list)
  =
  fun full_filename  ->
    let filename = FStar_Util.basename full_filename  in
    let corelibs =
      let uu____1653 = FStar_Options.prims_basename ()  in
      let uu____1654 =
        let uu____1657 = FStar_Options.pervasives_basename ()  in
        let uu____1658 =
          let uu____1661 = FStar_Options.pervasives_native_basename ()  in
          [uu____1661]  in
        uu____1657 :: uu____1658  in
      uu____1653 :: uu____1654  in
    if FStar_List.mem filename corelibs
    then []
    else
      (let implicit_deps =
         [(FStar_Parser_Const.fstar_ns_lid, Open_namespace);
         (FStar_Parser_Const.prims_lid, Open_module);
         (FStar_Parser_Const.pervasives_lid, Open_module)]  in
       let uu____1696 =
         let uu____1699 = lowercase_module_name full_filename  in
         namespace_of_module uu____1699  in
       match uu____1696 with
       | FStar_Pervasives_Native.None  -> implicit_deps
       | FStar_Pervasives_Native.Some ns ->
           FStar_List.append implicit_deps [(ns, Open_namespace)])
  
let (collect_one :
  files_for_module_name ->
    Prims.string ->
      (dependence Prims.list,dependence Prims.list)
        FStar_Pervasives_Native.tuple2)
  =
  fun original_map  ->
    fun filename  ->
      let deps = FStar_Util.mk_ref []  in
      let mo_roots = FStar_Util.mk_ref []  in
      let add_dep deps1 d =
        let uu____1925 =
          let uu____1926 =
            let uu____1927 = FStar_ST.op_Bang deps1  in
            FStar_List.existsML (fun d'  -> d' = d) uu____1927  in
          Prims.op_Negation uu____1926  in
        if uu____1925
        then
          let uu____2001 =
            let uu____2004 = FStar_ST.op_Bang deps1  in d :: uu____2004  in
          FStar_ST.op_Colon_Equals deps1 uu____2001
        else ()  in
      let working_map = FStar_Util.smap_copy original_map  in
      let add_dependence_edge original_or_working_map lid =
        let key = lowercase_join_longident lid true  in
        let uu____2177 = resolve_module_name original_or_working_map key  in
        match uu____2177 with
        | FStar_Pervasives_Native.Some module_name ->
            (add_dep deps (PreferInterface module_name);
             (let uu____2216 =
                ((has_interface original_or_working_map module_name) &&
                   (has_implementation original_or_working_map module_name))
                  &&
                  (let uu____2218 = FStar_Options.dep ()  in
                   uu____2218 = (FStar_Pervasives_Native.Some "full"))
                 in
              if uu____2216
              then add_dep mo_roots (UseImplementation module_name)
              else ());
             true)
        | uu____2257 -> false  in
      let record_open_module let_open lid =
        let uu____2271 =
          (let_open && (add_dependence_edge working_map lid)) ||
            ((Prims.op_Negation let_open) &&
               (add_dependence_edge original_map lid))
           in
        if uu____2271
        then true
        else
          (if let_open
           then
             (let uu____2274 = FStar_Ident.range_of_lid lid  in
              let uu____2275 =
                let uu____2280 =
                  let uu____2281 = string_of_lid lid true  in
                  FStar_Util.format1 "Module not found: %s" uu____2281  in
                (FStar_Errors.Warning_ModuleOrFileNotFoundWarning,
                  uu____2280)
                 in
              FStar_Errors.log_issue uu____2274 uu____2275)
           else ();
           false)
         in
      let record_open_namespace lid =
        let key = lowercase_join_longident lid true  in
        let r = enter_namespace original_map working_map key  in
        if Prims.op_Negation r
        then
          let uu____2291 = FStar_Ident.range_of_lid lid  in
          let uu____2292 =
            let uu____2297 =
              let uu____2298 = string_of_lid lid true  in
              FStar_Util.format1
                "No modules in namespace %s and no file with that name either"
                uu____2298
               in
            (FStar_Errors.Warning_ModuleOrFileNotFoundWarning, uu____2297)
             in
          FStar_Errors.log_issue uu____2291 uu____2292
        else ()  in
      let record_open let_open lid =
        let uu____2311 = record_open_module let_open lid  in
        if uu____2311
        then ()
        else
          if Prims.op_Negation let_open
          then record_open_namespace lid
          else ()
         in
      let record_open_module_or_namespace uu____2323 =
        match uu____2323 with
        | (lid,kind) ->
            (match kind with
             | Open_namespace  -> record_open_namespace lid
             | Open_module  ->
                 let uu____2330 = record_open_module false lid  in ())
         in
      let record_module_alias ident lid =
        let key =
          let uu____2343 = FStar_Ident.text_of_id ident  in
          FStar_String.lowercase uu____2343  in
        let alias = lowercase_join_longident lid true  in
        let uu____2345 = FStar_Util.smap_try_find original_map alias  in
        match uu____2345 with
        | FStar_Pervasives_Native.Some deps_of_aliased_module ->
            (FStar_Util.smap_add working_map key deps_of_aliased_module; true)
        | FStar_Pervasives_Native.None  ->
            ((let uu____2399 = FStar_Ident.range_of_lid lid  in
              let uu____2400 =
                let uu____2405 =
                  FStar_Util.format1 "module not found in search path: %s\n"
                    alias
                   in
                (FStar_Errors.Warning_ModuleOrFileNotFoundWarning,
                  uu____2405)
                 in
              FStar_Errors.log_issue uu____2399 uu____2400);
             false)
         in
      let record_lid lid =
        match lid.FStar_Ident.ns with
        | [] -> ()
        | uu____2412 ->
            let module_name = FStar_Ident.lid_of_ids lid.FStar_Ident.ns  in
            let uu____2416 = add_dependence_edge working_map module_name  in
            if uu____2416
            then ()
            else
              (let uu____2418 = FStar_Options.debug_any ()  in
               if uu____2418
               then
                 let uu____2419 = FStar_Ident.range_of_lid lid  in
                 let uu____2420 =
                   let uu____2425 =
                     let uu____2426 = FStar_Ident.string_of_lid module_name
                        in
                     FStar_Util.format1 "Unbound module reference %s"
                       uu____2426
                      in
                   (FStar_Errors.Warning_UnboundModuleReference, uu____2425)
                    in
                 FStar_Errors.log_issue uu____2419 uu____2420
               else ())
         in
      let auto_open = hard_coded_dependencies filename  in
      FStar_List.iter record_open_module_or_namespace auto_open;
      (let num_of_toplevelmods = FStar_Util.mk_ref (Prims.parse_int "0")  in
       let rec collect_module uu___57_2542 =
         match uu___57_2542 with
         | FStar_Parser_AST.Module (lid,decls) ->
             (check_module_declaration_against_filename lid filename;
              if
                (FStar_List.length lid.FStar_Ident.ns) >
                  (Prims.parse_int "0")
              then
                (let uu____2551 =
                   let uu____2552 = namespace_of_lid lid  in
                   enter_namespace original_map working_map uu____2552  in
                 ())
              else ();
              collect_decls decls)
         | FStar_Parser_AST.Interface (lid,decls,uu____2556) ->
             (check_module_declaration_against_filename lid filename;
              if
                (FStar_List.length lid.FStar_Ident.ns) >
                  (Prims.parse_int "0")
              then
                (let uu____2563 =
                   let uu____2564 = namespace_of_lid lid  in
                   enter_namespace original_map working_map uu____2564  in
                 ())
              else ();
              collect_decls decls)
       
       and collect_decls decls =
         FStar_List.iter
           (fun x  ->
              collect_decl x.FStar_Parser_AST.d;
              FStar_List.iter collect_term x.FStar_Parser_AST.attrs) decls
       
       and collect_decl uu___58_2573 =
         match uu___58_2573 with
         | FStar_Parser_AST.Include lid -> record_open false lid
         | FStar_Parser_AST.Open lid -> record_open false lid
         | FStar_Parser_AST.ModuleAbbrev (ident,lid) ->
             let uu____2578 = record_module_alias ident lid  in
             if uu____2578
             then
               let uu____2579 =
                 let uu____2580 = lowercase_join_longident lid true  in
                 PreferInterface uu____2580  in
               add_dep deps uu____2579
             else ()
         | FStar_Parser_AST.TopLevelLet (uu____2615,patterms) ->
             FStar_List.iter
               (fun uu____2637  ->
                  match uu____2637 with
                  | (pat,t) -> (collect_pattern pat; collect_term t))
               patterms
         | FStar_Parser_AST.Main t -> collect_term t
         | FStar_Parser_AST.Splice (uu____2646,t) -> collect_term t
         | FStar_Parser_AST.Assume (uu____2652,t) -> collect_term t
         | FStar_Parser_AST.SubEffect
             { FStar_Parser_AST.msource = uu____2654;
               FStar_Parser_AST.mdest = uu____2655;
               FStar_Parser_AST.lift_op = FStar_Parser_AST.NonReifiableLift t;_}
             -> collect_term t
         | FStar_Parser_AST.SubEffect
             { FStar_Parser_AST.msource = uu____2657;
               FStar_Parser_AST.mdest = uu____2658;
               FStar_Parser_AST.lift_op = FStar_Parser_AST.LiftForFree t;_}
             -> collect_term t
         | FStar_Parser_AST.Val (uu____2660,t) -> collect_term t
         | FStar_Parser_AST.SubEffect
             { FStar_Parser_AST.msource = uu____2662;
               FStar_Parser_AST.mdest = uu____2663;
               FStar_Parser_AST.lift_op = FStar_Parser_AST.ReifiableLift
                 (t0,t1);_}
             -> (collect_term t0; collect_term t1)
         | FStar_Parser_AST.Tycon (uu____2667,ts) ->
             let ts1 =
               FStar_List.map
                 (fun uu____2697  -> match uu____2697 with | (x,docnik) -> x)
                 ts
                in
             FStar_List.iter collect_tycon ts1
         | FStar_Parser_AST.Exception (uu____2710,t) ->
             FStar_Util.iter_opt t collect_term
         | FStar_Parser_AST.NewEffect ed -> collect_effect_decl ed
         | FStar_Parser_AST.Fsdoc uu____2717 -> ()
         | FStar_Parser_AST.Pragma uu____2718 -> ()
         | FStar_Parser_AST.TopLevelModule lid ->
             (FStar_Util.incr num_of_toplevelmods;
              (let uu____2754 =
                 let uu____2755 = FStar_ST.op_Bang num_of_toplevelmods  in
                 uu____2755 > (Prims.parse_int "1")  in
               if uu____2754
               then
                 let uu____2801 =
                   let uu____2806 =
                     let uu____2807 = string_of_lid lid true  in
                     FStar_Util.format1
                       "Automatic dependency analysis demands one module per file (module %s not supported)"
                       uu____2807
                      in
                   (FStar_Errors.Fatal_OneModulePerFile, uu____2806)  in
                 let uu____2808 = FStar_Ident.range_of_lid lid  in
                 FStar_Errors.raise_error uu____2801 uu____2808
               else ()))
       
       and collect_tycon uu___59_2810 =
         match uu___59_2810 with
         | FStar_Parser_AST.TyconAbstract (uu____2811,binders,k) ->
             (collect_binders binders; FStar_Util.iter_opt k collect_term)
         | FStar_Parser_AST.TyconAbbrev (uu____2823,binders,k,t) ->
             (collect_binders binders;
              FStar_Util.iter_opt k collect_term;
              collect_term t)
         | FStar_Parser_AST.TyconRecord (uu____2837,binders,k,identterms) ->
             (collect_binders binders;
              FStar_Util.iter_opt k collect_term;
              FStar_List.iter
                (fun uu____2883  ->
                   match uu____2883 with
                   | (uu____2892,t,uu____2894) -> collect_term t) identterms)
         | FStar_Parser_AST.TyconVariant (uu____2899,binders,k,identterms) ->
             (collect_binders binders;
              FStar_Util.iter_opt k collect_term;
              FStar_List.iter
                (fun uu____2958  ->
                   match uu____2958 with
                   | (uu____2971,t,uu____2973,uu____2974) ->
                       FStar_Util.iter_opt t collect_term) identterms)
       
       and collect_effect_decl uu___60_2983 =
         match uu___60_2983 with
         | FStar_Parser_AST.DefineEffect (uu____2984,binders,t,decls) ->
             (collect_binders binders; collect_term t; collect_decls decls)
         | FStar_Parser_AST.RedefineEffect (uu____2998,binders,t) ->
             (collect_binders binders; collect_term t)
       
       and collect_binders binders = FStar_List.iter collect_binder binders
       
       and collect_binder uu___61_3009 =
         match uu___61_3009 with
         | { FStar_Parser_AST.b = FStar_Parser_AST.Annotated (uu____3010,t);
             FStar_Parser_AST.brange = uu____3012;
             FStar_Parser_AST.blevel = uu____3013;
             FStar_Parser_AST.aqual = uu____3014;_} -> collect_term t
         | { FStar_Parser_AST.b = FStar_Parser_AST.TAnnotated (uu____3015,t);
             FStar_Parser_AST.brange = uu____3017;
             FStar_Parser_AST.blevel = uu____3018;
             FStar_Parser_AST.aqual = uu____3019;_} -> collect_term t
         | { FStar_Parser_AST.b = FStar_Parser_AST.NoName t;
             FStar_Parser_AST.brange = uu____3021;
             FStar_Parser_AST.blevel = uu____3022;
             FStar_Parser_AST.aqual = uu____3023;_} -> collect_term t
         | uu____3024 -> ()
       
       and collect_term t = collect_term' t.FStar_Parser_AST.tm
       
       and collect_constant uu___62_3026 =
         match uu___62_3026 with
         | FStar_Const.Const_int
             (uu____3027,FStar_Pervasives_Native.Some (signedness,width)) ->
             let u =
               match signedness with
               | FStar_Const.Unsigned  -> "u"
               | FStar_Const.Signed  -> ""  in
             let w =
               match width with
               | FStar_Const.Int8  -> "8"
               | FStar_Const.Int16  -> "16"
               | FStar_Const.Int32  -> "32"
               | FStar_Const.Int64  -> "64"  in
             let uu____3042 =
               let uu____3043 = FStar_Util.format2 "fstar.%sint%s" u w  in
               PreferInterface uu____3043  in
             add_dep deps uu____3042
         | FStar_Const.Const_char uu____3077 ->
             add_dep deps (PreferInterface "fstar.char")
         | FStar_Const.Const_float uu____3111 ->
             add_dep deps (PreferInterface "fstar.float")
         | uu____3145 -> ()
       
       and collect_term' uu___63_3146 =
         match uu___63_3146 with
         | FStar_Parser_AST.Wild  -> ()
         | FStar_Parser_AST.Const c -> collect_constant c
         | FStar_Parser_AST.Op (s,ts) ->
             ((let uu____3155 =
                 let uu____3156 = FStar_Ident.text_of_id s  in
                 uu____3156 = "@"  in
               if uu____3155
               then
                 let uu____3157 =
                   let uu____3158 =
                     let uu____3159 =
                       FStar_Ident.path_of_text "FStar.List.Tot.Base.append"
                        in
                     FStar_Ident.lid_of_path uu____3159
                       FStar_Range.dummyRange
                      in
                   FStar_Parser_AST.Name uu____3158  in
                 collect_term' uu____3157
               else ());
              FStar_List.iter collect_term ts)
         | FStar_Parser_AST.Tvar uu____3161 -> ()
         | FStar_Parser_AST.Uvar uu____3162 -> ()
         | FStar_Parser_AST.Var lid -> record_lid lid
         | FStar_Parser_AST.Projector (lid,uu____3165) -> record_lid lid
         | FStar_Parser_AST.Discrim lid -> record_lid lid
         | FStar_Parser_AST.Name lid -> record_lid lid
         | FStar_Parser_AST.Construct (lid,termimps) ->
             (if (FStar_List.length termimps) = (Prims.parse_int "1")
              then record_lid lid
              else ();
              FStar_List.iter
                (fun uu____3195  ->
                   match uu____3195 with | (t,uu____3201) -> collect_term t)
                termimps)
         | FStar_Parser_AST.Abs (pats,t) ->
             (collect_patterns pats; collect_term t)
         | FStar_Parser_AST.App (t1,t2,uu____3211) ->
             (collect_term t1; collect_term t2)
         | FStar_Parser_AST.Let (uu____3213,patterms,t) ->
             (FStar_List.iter
                (fun uu____3263  ->
                   match uu____3263 with
                   | (attrs_opt,(pat,t1)) ->
                       ((let uu____3292 =
                           FStar_Util.map_opt attrs_opt
                             (FStar_List.iter collect_term)
                            in
                         ());
                        collect_pattern pat;
                        collect_term t1)) patterms;
              collect_term t)
         | FStar_Parser_AST.LetOpen (lid,t) ->
             (record_open true lid; collect_term t)
         | FStar_Parser_AST.Bind (uu____3301,t1,t2) ->
             (collect_term t1; collect_term t2)
         | FStar_Parser_AST.Seq (t1,t2) -> (collect_term t1; collect_term t2)
         | FStar_Parser_AST.If (t1,t2,t3) ->
             (collect_term t1; collect_term t2; collect_term t3)
         | FStar_Parser_AST.Match (t,bs) ->
             (collect_term t; collect_branches bs)
         | FStar_Parser_AST.TryWith (t,bs) ->
             (collect_term t; collect_branches bs)
         | FStar_Parser_AST.Ascribed (t1,t2,FStar_Pervasives_Native.None ) ->
             (collect_term t1; collect_term t2)
         | FStar_Parser_AST.Ascribed (t1,t2,FStar_Pervasives_Native.Some tac)
             -> (collect_term t1; collect_term t2; collect_term tac)
         | FStar_Parser_AST.Record (t,idterms) ->
             (FStar_Util.iter_opt t collect_term;
              FStar_List.iter
                (fun uu____3397  ->
                   match uu____3397 with | (uu____3402,t1) -> collect_term t1)
                idterms)
         | FStar_Parser_AST.Project (t,uu____3405) -> collect_term t
         | FStar_Parser_AST.Product (binders,t) ->
             (collect_binders binders; collect_term t)
         | FStar_Parser_AST.Sum (binders,t) ->
             (collect_binders binders; collect_term t)
         | FStar_Parser_AST.QForall (binders,ts,t) ->
             (collect_binders binders;
              FStar_List.iter (FStar_List.iter collect_term) ts;
              collect_term t)
         | FStar_Parser_AST.QExists (binders,ts,t) ->
             (collect_binders binders;
              FStar_List.iter (FStar_List.iter collect_term) ts;
              collect_term t)
         | FStar_Parser_AST.Refine (binder,t) ->
             (collect_binder binder; collect_term t)
         | FStar_Parser_AST.NamedTyp (uu____3461,t) -> collect_term t
         | FStar_Parser_AST.Paren t -> collect_term t
         | FStar_Parser_AST.Requires (t,uu____3465) -> collect_term t
         | FStar_Parser_AST.Ensures (t,uu____3471) -> collect_term t
         | FStar_Parser_AST.Labeled (t,uu____3477,uu____3478) ->
             collect_term t
         | FStar_Parser_AST.VQuote t -> collect_term t
         | FStar_Parser_AST.Quote uu____3480 -> ()
         | FStar_Parser_AST.Antiquote uu____3485 -> ()
         | FStar_Parser_AST.Attributes cattributes ->
             FStar_List.iter collect_term cattributes
       
       and collect_patterns ps = FStar_List.iter collect_pattern ps
       
       and collect_pattern p = collect_pattern' p.FStar_Parser_AST.pat
       
       and collect_pattern' uu___64_3497 =
         match uu___64_3497 with
         | FStar_Parser_AST.PatWild  -> ()
         | FStar_Parser_AST.PatOp uu____3498 -> ()
         | FStar_Parser_AST.PatConst uu____3499 -> ()
         | FStar_Parser_AST.PatApp (p,ps) ->
             (collect_pattern p; collect_patterns ps)
         | FStar_Parser_AST.PatVar uu____3507 -> ()
         | FStar_Parser_AST.PatName uu____3514 -> ()
         | FStar_Parser_AST.PatTvar uu____3515 -> ()
         | FStar_Parser_AST.PatList ps -> collect_patterns ps
         | FStar_Parser_AST.PatOr ps -> collect_patterns ps
         | FStar_Parser_AST.PatTuple (ps,uu____3529) -> collect_patterns ps
         | FStar_Parser_AST.PatRecord lidpats ->
             FStar_List.iter
               (fun uu____3548  ->
                  match uu____3548 with | (uu____3553,p) -> collect_pattern p)
               lidpats
         | FStar_Parser_AST.PatAscribed (p,(t,FStar_Pervasives_Native.None ))
             -> (collect_pattern p; collect_term t)
         | FStar_Parser_AST.PatAscribed
             (p,(t,FStar_Pervasives_Native.Some tac)) ->
             (collect_pattern p; collect_term t; collect_term tac)
       
       and collect_branches bs = FStar_List.iter collect_branch bs
       
       and collect_branch uu____3598 =
         match uu____3598 with
         | (pat,t1,t2) ->
             (collect_pattern pat;
              FStar_Util.iter_opt t1 collect_term;
              collect_term t2)
        in
       let uu____3616 = FStar_Parser_Driver.parse_file filename  in
       match uu____3616 with
       | (ast,uu____3636) ->
           let mname = lowercase_module_name filename  in
           ((let uu____3651 =
               ((is_interface filename) &&
                  (has_implementation original_map mname))
                 &&
                 (let uu____3653 = FStar_Options.dep ()  in
                  uu____3653 = (FStar_Pervasives_Native.Some "full"))
                in
             if uu____3651
             then add_dep mo_roots (UseImplementation mname)
             else ());
            collect_module ast;
            (let uu____3693 = FStar_ST.op_Bang deps  in
             let uu____3745 = FStar_ST.op_Bang mo_roots  in
             (uu____3693, uu____3745))))
  
let (collect :
  Prims.string Prims.list ->
    (Prims.string Prims.list,deps) FStar_Pervasives_Native.tuple2)
  =
  fun all_cmd_line_files  ->
    let all_cmd_line_files1 =
      FStar_All.pipe_right all_cmd_line_files
        (FStar_List.map
           (fun fn  ->
              let uu____3833 = FStar_Options.find_file fn  in
              match uu____3833 with
              | FStar_Pervasives_Native.None  ->
                  let uu____3836 =
                    let uu____3841 =
                      FStar_Util.format1 "File %s could not be found\n" fn
                       in
                    (FStar_Errors.Fatal_ModuleOrFileNotFound, uu____3841)  in
                  FStar_Errors.raise_err uu____3836
              | FStar_Pervasives_Native.Some fn1 -> fn1))
       in
    let dep_graph = deps_empty ()  in
    let file_system_map = build_map all_cmd_line_files1  in
    let rec discover_one file_name =
      let uu____3851 =
        let uu____3852 = deps_try_find dep_graph file_name  in
        uu____3852 = FStar_Pervasives_Native.None  in
      if uu____3851
      then
        let uu____3869 = collect_one file_system_map file_name  in
        match uu____3869 with
        | (deps,mo_roots) ->
            let deps1 =
              let module_name = lowercase_module_name file_name  in
              let uu____3892 =
                (is_implementation file_name) &&
                  (has_interface file_system_map module_name)
                 in
              if uu____3892
              then FStar_List.append deps [UseInterface module_name]
              else deps  in
            ((let uu____3897 =
                let uu____3902 = FStar_List.unique deps1  in
                (uu____3902, White)  in
              deps_add_dep dep_graph file_name uu____3897);
             (let uu____3907 =
                FStar_List.map
                  (file_of_dep file_system_map all_cmd_line_files1)
                  (FStar_List.append deps1 mo_roots)
                 in
              FStar_List.iter discover_one uu____3907))
      else ()  in
    FStar_List.iter discover_one all_cmd_line_files1;
    (let topological_dependences_of all_command_line_files =
       let topologically_sorted = FStar_Util.mk_ref []  in
       let rec aux cycle filename =
         let uu____3946 =
           let uu____3951 = deps_try_find dep_graph filename  in
           FStar_Util.must uu____3951  in
         match uu____3946 with
         | (direct_deps,color) ->
             (match color with
              | Gray  ->
                  ((let uu____3965 =
                      let uu____3970 =
                        FStar_Util.format1
                          "Recursive dependency on module %s\n" filename
                         in
                      (FStar_Errors.Warning_RecursiveDependency, uu____3970)
                       in
                    FStar_Errors.log_issue FStar_Range.dummyRange uu____3965);
                   FStar_Util.print1
                     "The cycle contains a subset of the modules in:\n%s \n"
                     (FStar_String.concat "\n`used by` " cycle);
                   print_graph dep_graph;
                   FStar_Util.print_string "\n";
                   FStar_All.exit (Prims.parse_int "1"))
              | Black  -> ()
              | White  ->
                  (deps_add_dep dep_graph filename (direct_deps, Gray);
                   (let uu____3976 =
                      dependences_of file_system_map dep_graph
                        all_command_line_files filename
                       in
                    FStar_List.iter (fun k  -> aux (k :: cycle) k) uu____3976);
                   deps_add_dep dep_graph filename (direct_deps, Black);
                   (let uu____3982 =
                      let uu____3985 = FStar_ST.op_Bang topologically_sorted
                         in
                      filename :: uu____3985  in
                    FStar_ST.op_Colon_Equals topologically_sorted uu____3982)))
          in
       FStar_List.iter (aux []) all_command_line_files;
       FStar_ST.op_Bang topologically_sorted  in
     FStar_All.pipe_right all_cmd_line_files1
       (FStar_List.iter
          (fun f  ->
             let m = lowercase_module_name f  in
             FStar_Options.add_verify_module m));
     (let uu____4143 = topological_dependences_of all_cmd_line_files1  in
      (uu____4143, (Mk (dep_graph, file_system_map, all_cmd_line_files1)))))
  
let (deps_of : deps -> Prims.string -> Prims.string Prims.list) =
  fun uu____4160  ->
    fun f  ->
      match uu____4160 with
      | Mk (deps,file_system_map,all_cmd_line_files) ->
          dependences_of file_system_map deps all_cmd_line_files f
  
let (hash_dependences :
  deps ->
    Prims.string ->
      (Prims.string,Prims.string) FStar_Pervasives_Native.tuple2 Prims.list
        FStar_Pervasives_Native.option)
  =
  fun uu____4189  ->
    fun fn  ->
      match uu____4189 with
      | Mk (deps,file_system_map,all_cmd_line_files) ->
          let fn1 =
            let uu____4207 = FStar_Options.find_file fn  in
            match uu____4207 with
            | FStar_Pervasives_Native.Some fn1 -> fn1
            | uu____4211 -> fn  in
          let cache_file = cache_file_name fn1  in
          let digest_of_file1 fn2 =
            (let uu____4222 = FStar_Options.debug_any ()  in
             if uu____4222
             then
               FStar_Util.print2 "%s: contains digest of %s\n" cache_file fn2
             else ());
            FStar_Util.digest_of_file fn2  in
          let module_name = lowercase_module_name fn1  in
          let source_hash = digest_of_file1 fn1  in
          let interface_hash =
            let uu____4233 =
              (is_implementation fn1) &&
                (has_interface file_system_map module_name)
               in
            if uu____4233
            then
              let uu____4240 =
                let uu____4245 =
                  let uu____4246 =
                    let uu____4247 = interface_of file_system_map module_name
                       in
                    FStar_Option.get uu____4247  in
                  digest_of_file1 uu____4246  in
                ("interface", uu____4245)  in
              [uu____4240]
            else []  in
          let binary_deps =
            let uu____4266 =
              dependences_of file_system_map deps all_cmd_line_files fn1  in
            FStar_All.pipe_right uu____4266
              (FStar_List.filter
                 (fun fn2  ->
                    let uu____4276 =
                      (is_interface fn2) &&
                        (let uu____4278 = lowercase_module_name fn2  in
                         uu____4278 = module_name)
                       in
                    Prims.op_Negation uu____4276))
             in
          let binary_deps1 =
            FStar_List.sortWith
              (fun fn11  ->
                 fun fn2  ->
                   let uu____4288 = lowercase_module_name fn11  in
                   let uu____4289 = lowercase_module_name fn2  in
                   FStar_String.compare uu____4288 uu____4289) binary_deps
             in
          let rec hash_deps out uu___65_4316 =
            match uu___65_4316 with
            | [] ->
                FStar_Pervasives_Native.Some
                  (FStar_List.append (("source", source_hash) ::
                     interface_hash) out)
            | fn2::deps1 ->
                let cache_fn = cache_file_name fn2  in
                if FStar_Util.file_exists cache_fn
                then
                  let uu____4360 =
                    let uu____4367 =
                      let uu____4372 = lowercase_module_name fn2  in
                      let uu____4373 = digest_of_file1 cache_fn  in
                      (uu____4372, uu____4373)  in
                    uu____4367 :: out  in
                  hash_deps uu____4360 deps1
                else
                  ((let uu____4380 = FStar_Options.debug_any ()  in
                    if uu____4380
                    then
                      FStar_Util.print2 "%s: missed digest of file %s\n"
                        cache_file cache_fn
                    else ());
                   FStar_Pervasives_Native.None)
             in
          hash_deps [] binary_deps1
  
let (print_digest :
  (Prims.string,Prims.string) FStar_Pervasives_Native.tuple2 Prims.list ->
    Prims.string)
  =
  fun dig  ->
    let uu____4409 =
      FStar_All.pipe_right dig
        (FStar_List.map
           (fun uu____4428  ->
              match uu____4428 with
              | (m,d) ->
                  let uu____4435 = FStar_Util.base64_encode d  in
                  FStar_Util.format2 "%s:%s" m uu____4435))
       in
    FStar_All.pipe_right uu____4409 (FStar_String.concat "\n")
  
let (print_make : deps -> unit) =
  fun uu____4442  ->
    match uu____4442 with
    | Mk (deps,file_system_map,all_cmd_line_files) ->
        let keys = deps_keys deps  in
        FStar_All.pipe_right keys
          (FStar_List.iter
             (fun f  ->
                let uu____4462 =
                  let uu____4467 = deps_try_find deps f  in
                  FStar_All.pipe_right uu____4467 FStar_Option.get  in
                match uu____4462 with
                | (f_deps,uu____4489) ->
                    let files =
                      FStar_List.map
                        (file_of_dep file_system_map all_cmd_line_files)
                        f_deps
                       in
                    let files1 =
                      FStar_List.map
                        (fun s  -> FStar_Util.replace_chars s 32 "\\ ") files
                       in
                    FStar_Util.print2 "%s: %s\n\n" f
                      (FStar_String.concat " " files1)))
  
let (print_full : deps -> unit) =
  fun uu____4503  ->
    match uu____4503 with
    | Mk (deps,file_system_map,all_cmd_line_files) ->
        let sort_output_files orig_output_file_map =
          let order = FStar_Util.mk_ref []  in
          let remaining_output_files =
            FStar_Util.smap_copy orig_output_file_map  in
          let visited_other_modules =
            FStar_Util.smap_create (Prims.parse_int "41")  in
          let should_visit lc_module_name =
            (let uu____4544 =
               FStar_Util.smap_try_find remaining_output_files lc_module_name
                in
             FStar_Option.isSome uu____4544) ||
              (let uu____4548 =
                 FStar_Util.smap_try_find visited_other_modules
                   lc_module_name
                  in
               FStar_Option.isNone uu____4548)
             in
          let mark_visiting lc_module_name =
            let ml_file_opt =
              FStar_Util.smap_try_find remaining_output_files lc_module_name
               in
            FStar_Util.smap_remove remaining_output_files lc_module_name;
            FStar_Util.smap_add visited_other_modules lc_module_name true;
            ml_file_opt  in
          let emit_output_file_opt ml_file_opt =
            match ml_file_opt with
            | FStar_Pervasives_Native.None  -> ()
            | FStar_Pervasives_Native.Some ml_file ->
                let uu____4575 =
                  let uu____4578 = FStar_ST.op_Bang order  in ml_file ::
                    uu____4578
                   in
                FStar_ST.op_Colon_Equals order uu____4575
             in
          let rec aux uu___66_4686 =
            match uu___66_4686 with
            | [] -> ()
            | lc_module_name::modules_to_extract ->
                let visit_file file_opt =
                  match file_opt with
                  | FStar_Pervasives_Native.None  -> ()
                  | FStar_Pervasives_Native.Some file_name ->
                      let uu____4704 = deps_try_find deps file_name  in
                      (match uu____4704 with
                       | FStar_Pervasives_Native.None  ->
                           let uu____4715 =
                             FStar_Util.format2
                               "Impossible: module %s: %s not found"
                               lc_module_name file_name
                              in
                           failwith uu____4715
                       | FStar_Pervasives_Native.Some
                           (immediate_deps,uu____4717) ->
                           let immediate_deps1 =
                             FStar_List.map
                               (fun x  ->
                                  FStar_String.lowercase
                                    (module_name_of_dep x)) immediate_deps
                              in
                           aux immediate_deps1)
                   in
                ((let uu____4728 = should_visit lc_module_name  in
                  if uu____4728
                  then
                    let ml_file_opt = mark_visiting lc_module_name  in
                    ((let uu____4733 =
                        implementation_of file_system_map lc_module_name  in
                      visit_file uu____4733);
                     (let uu____4737 =
                        interface_of file_system_map lc_module_name  in
                      visit_file uu____4737);
                     emit_output_file_opt ml_file_opt)
                  else ());
                 aux modules_to_extract)
             in
          let all_extracted_modules =
            FStar_Util.smap_keys orig_output_file_map  in
          aux all_extracted_modules;
          (let uu____4745 = FStar_ST.op_Bang order  in
           FStar_List.rev uu____4745)
           in
        let keys = deps_keys deps  in
        let output_file ext fst_file =
          let ml_base_name =
            let uu____4812 =
              let uu____4813 =
                let uu____4816 = FStar_Util.basename fst_file  in
                check_and_strip_suffix uu____4816  in
              FStar_Option.get uu____4813  in
            FStar_Util.replace_chars uu____4812 46 "_"  in
          FStar_Options.prepend_output_dir (Prims.strcat ml_base_name ext)
           in
        let norm_path s = FStar_Util.replace_chars s 92 "/"  in
        let output_ml_file f =
          let uu____4831 = output_file ".ml" f  in norm_path uu____4831  in
        let output_krml_file f =
          let uu____4838 = output_file ".krml" f  in norm_path uu____4838  in
        let output_cmx_file f =
          let uu____4845 = output_file ".cmx" f  in norm_path uu____4845  in
        let cache_file f =
          let uu____4852 = cache_file_name f  in norm_path uu____4852  in
        let transitive_krml = FStar_Util.smap_create (Prims.parse_int "41")
           in
        (FStar_All.pipe_right keys
           (FStar_List.iter
              (fun f  ->
                 let uu____4895 =
                   let uu____4900 = deps_try_find deps f  in
                   FStar_All.pipe_right uu____4900 FStar_Option.get  in
                 match uu____4895 with
                 | (f_deps,uu____4922) ->
                     let norm_f = norm_path f  in
                     let files =
                       FStar_List.map
                         (file_of_dep_aux true file_system_map
                            all_cmd_line_files) f_deps
                        in
                     let files1 = FStar_List.map norm_path files  in
                     let files2 =
                       FStar_List.map
                         (fun s  -> FStar_Util.replace_chars s 32 "\\ ")
                         files1
                        in
                     let files3 = FStar_String.concat "\\\n\t" files2  in
                     ((let uu____4938 = is_interface f  in
                       if uu____4938
                       then
                         let uu____4939 =
                           let uu____4940 =
                             FStar_Options.prepend_cache_dir norm_f  in
                           norm_path uu____4940  in
                         FStar_Util.print3
                           "%s.source: %s \\\n\t%s\n\ttouch $@\n\n"
                           uu____4939 norm_f files3
                       else ());
                      (let uu____4943 = cache_file f  in
                       FStar_Util.print3 "%s: %s \\\n\t%s\n\n" uu____4943
                         norm_f files3);
                      (let already_there =
                         let uu____4947 =
                           let uu____4958 =
                             let uu____4959 = output_file ".krml" f  in
                             norm_path uu____4959  in
                           FStar_Util.smap_try_find transitive_krml
                             uu____4958
                            in
                         match uu____4947 with
                         | FStar_Pervasives_Native.Some
                             (uu____4970,already_there,uu____4972) ->
                             already_there
                         | FStar_Pervasives_Native.None  -> []  in
                       (let uu____4994 =
                          let uu____4995 = output_file ".krml" f  in
                          norm_path uu____4995  in
                        let uu____4996 =
                          let uu____5005 =
                            let uu____5006 = output_file ".exe" f  in
                            norm_path uu____5006  in
                          let uu____5007 =
                            let uu____5010 =
                              let uu____5013 =
                                let uu____5016 =
                                  deps_of
                                    (Mk
                                       (deps, file_system_map,
                                         all_cmd_line_files)) f
                                   in
                                FStar_List.map
                                  (fun x  ->
                                     let uu____5024 = output_file ".krml" x
                                        in
                                     norm_path uu____5024) uu____5016
                                 in
                              FStar_List.append already_there uu____5013  in
                            FStar_List.unique uu____5010  in
                          (uu____5005, uu____5007, false)  in
                        FStar_Util.smap_add transitive_krml uu____4994
                          uu____4996);
                       (let uu____5035 = is_implementation f  in
                        if uu____5035
                        then
                          ((let uu____5037 = output_ml_file f  in
                            let uu____5038 = cache_file f  in
                            FStar_Util.print2 "%s: %s\n\n" uu____5037
                              uu____5038);
                           (let cmx_files =
                              let fst_files =
                                FStar_All.pipe_right f_deps
                                  (FStar_List.map
                                     (file_of_dep_aux false file_system_map
                                        all_cmd_line_files))
                                 in
                              let extracted_fst_files =
                                FStar_All.pipe_right fst_files
                                  (FStar_List.filter
                                     (fun df  ->
                                        (let uu____5060 =
                                           lowercase_module_name df  in
                                         let uu____5061 =
                                           lowercase_module_name f  in
                                         uu____5060 <> uu____5061) &&
                                          (let uu____5063 =
                                             lowercase_module_name df  in
                                           FStar_Options.should_extract
                                             uu____5063)))
                                 in
                              FStar_All.pipe_right extracted_fst_files
                                (FStar_List.map output_cmx_file)
                               in
                            (let uu____5069 =
                               let uu____5070 = lowercase_module_name f  in
                               FStar_Options.should_extract uu____5070  in
                             if uu____5069
                             then
                               let uu____5071 = output_cmx_file f  in
                               let uu____5072 = output_ml_file f  in
                               FStar_Util.print3 "%s: %s \\\n\t%s\n\n"
                                 uu____5071 uu____5072
                                 (FStar_String.concat "\\\n\t" cmx_files)
                             else ());
                            (let uu____5074 = output_krml_file f  in
                             let uu____5075 = cache_file f  in
                             FStar_Util.print2 "%s: %s\n\n" uu____5074
                               uu____5075)))
                        else
                          (let uu____5077 =
                             (let uu____5080 =
                                let uu____5081 = lowercase_module_name f  in
                                has_implementation file_system_map uu____5081
                                 in
                              Prims.op_Negation uu____5080) &&
                               (is_interface f)
                              in
                           if uu____5077
                           then
                             let uu____5082 = output_krml_file f  in
                             let uu____5083 = cache_file f  in
                             FStar_Util.print2 "%s: %s\n\n" uu____5082
                               uu____5083
                           else ()))))));
         (let all_fst_files =
            let uu____5088 =
              FStar_All.pipe_right keys (FStar_List.filter is_implementation)
               in
            FStar_All.pipe_right uu____5088
              (FStar_Util.sort_with FStar_String.compare)
             in
          let all_ml_files =
            let ml_file_map = FStar_Util.smap_create (Prims.parse_int "41")
               in
            FStar_All.pipe_right all_fst_files
              (FStar_List.iter
                 (fun fst_file  ->
                    let mname = lowercase_module_name fst_file  in
                    let uu____5114 = FStar_Options.should_extract mname  in
                    if uu____5114
                    then
                      let uu____5115 = output_ml_file fst_file  in
                      FStar_Util.smap_add ml_file_map mname uu____5115
                    else ()));
            sort_output_files ml_file_map  in
          let all_krml_files =
            let krml_file_map = FStar_Util.smap_create (Prims.parse_int "41")
               in
            FStar_All.pipe_right keys
              (FStar_List.iter
                 (fun fst_file  ->
                    let mname = lowercase_module_name fst_file  in
                    let uu____5131 = output_krml_file fst_file  in
                    FStar_Util.smap_add krml_file_map mname uu____5131));
            sort_output_files krml_file_map  in
          let rec make_transitive f =
            let uu____5144 =
              let uu____5153 = FStar_Util.smap_try_find transitive_krml f  in
              FStar_Util.must uu____5153  in
            match uu____5144 with
            | (exe,deps1,seen) ->
                if seen
                then (exe, deps1)
                else
                  (FStar_Util.smap_add transitive_krml f (exe, deps1, true);
                   (let deps2 =
                      let uu____5216 =
                        let uu____5219 =
                          FStar_List.map
                            (fun dep1  ->
                               let uu____5231 = make_transitive dep1  in
                               match uu____5231 with
                               | (uu____5240,deps2) -> dep1 :: deps2) deps1
                           in
                        FStar_List.flatten uu____5219  in
                      FStar_List.unique uu____5216  in
                    FStar_Util.smap_add transitive_krml f (exe, deps2, true);
                    (exe, deps2)))
             in
          (let uu____5260 = FStar_Util.smap_keys transitive_krml  in
           FStar_List.iter
             (fun f  ->
                let uu____5279 = make_transitive f  in
                match uu____5279 with
                | (exe,deps1) ->
                    let deps2 =
                      let uu____5293 = FStar_List.unique (f :: deps1)  in
                      FStar_String.concat " " uu____5293  in
                    let wasm =
                      let uu____5297 =
                        FStar_Util.substring exe (Prims.parse_int "0")
                          ((FStar_String.length exe) - (Prims.parse_int "4"))
                         in
                      Prims.strcat uu____5297 ".wasm"  in
                    (FStar_Util.print2 "%s: %s\n\n" exe deps2;
                     FStar_Util.print2 "%s: %s\n\n" wasm deps2)) uu____5260);
          (let uu____5300 =
             let uu____5301 =
               FStar_All.pipe_right all_fst_files (FStar_List.map norm_path)
                in
             FStar_All.pipe_right uu____5301 (FStar_String.concat " \\\n\t")
              in
           FStar_Util.print1 "ALL_FST_FILES=\\\n\t%s\n\n" uu____5300);
          (let uu____5311 =
             let uu____5312 =
               FStar_All.pipe_right all_ml_files (FStar_List.map norm_path)
                in
             FStar_All.pipe_right uu____5312 (FStar_String.concat " \\\n\t")
              in
           FStar_Util.print1 "ALL_ML_FILES=\\\n\t%s\n\n" uu____5311);
          (let uu____5321 =
             let uu____5322 =
               FStar_All.pipe_right all_krml_files (FStar_List.map norm_path)
                in
             FStar_All.pipe_right uu____5322 (FStar_String.concat " \\\n\t")
              in
           FStar_Util.print1 "ALL_KRML_FILES=\\\n\t%s\n" uu____5321)))
  
let (print : deps -> unit) =
  fun deps  ->
    let uu____5336 = FStar_Options.dep ()  in
    match uu____5336 with
    | FStar_Pervasives_Native.Some "make" -> print_make deps
    | FStar_Pervasives_Native.Some "full" -> print_full deps
    | FStar_Pervasives_Native.Some "graph" ->
        let uu____5339 = deps  in
        (match uu____5339 with
         | Mk (deps1,uu____5341,uu____5342) -> print_graph deps1)
    | FStar_Pervasives_Native.Some uu____5347 ->
        FStar_Errors.raise_err
          (FStar_Errors.Fatal_UnknownToolForDep, "unknown tool for --dep\n")
    | FStar_Pervasives_Native.None  -> ()
  