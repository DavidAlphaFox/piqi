(*
   Copyright 2009, 2010 Anton Lavrik

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


open Piqi_common


let has_parent name =
  String.contains name '/'


(* analogous to Filename.dirname *)
let get_module_name x =
  try
    let pos = String.rindex x '/' in
    assert (pos <> 0);
    let res = String.sub x 0 pos in
    Some res
  with
    Not_found -> None


(* analogous to Filename.basename *)
let get_local_name x =
  try
    let pos = String.rindex x '/' in
    String.sub x (pos + 1) ((String.length x) - pos - 1)
  with
    Not_found -> x


let split_name x =
  get_module_name x, get_local_name x


let make_local_name modname =
  let name = get_local_name modname in
  underscores_to_dashes name


let is_valid_char allow = function
  | 'a'..'z'
  | 'A'..'Z'
  | '0'..'9'
  | '-' -> true
  | x -> String.contains allow x


let is_valid_name ?(allow="") x =
  let len = String.length x in
  let rec check_char i =
    if i >= len
    then true
    else
      if is_valid_char allow x.[i] 
      then check_char (i + 1)
      else false
  in
  if len = 0 then false
  else
    match x.[0] with
      | 'a'..'z'
      | 'A'..'Z' -> check_char 1
      | _ -> false


let some f = function
  | None -> true
  | Some x -> f x
    

let is_valid_scoped_name x =
  let m, n = split_name x in
  some is_valid_name m && is_valid_name n


let is_valid_pathname x =
  (* TODO: check domain name and URL/paths validity *)
  is_valid_name x ~allow:"/._"


let is_valid_modname x =
  let dirname, basename = split_name x in
  (* NOTE: allowing underscores in basename *)
  some is_valid_pathname dirname && is_valid_name basename ~allow:"_"


let is_valid_typename ?allow x =
  let modname, typename = split_name x in
  some is_valid_modname modname && is_valid_name typename ?allow
