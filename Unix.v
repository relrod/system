Require Import Coq.Lists.List.
Require Import ListString.All.
Require Import IoEffects.All.

Import ListNotations.
Import C.Notations.

Inductive t :=
(** List the files of a directory. *)
| ListFiles (directory : LString.t)
(** Read the content of a file. *)
| ReadFile (file_name : LString.t)
(** Update (or create) a file with some content. *)
| WriteFile (file_name : LString.t) (content : LString.t)
(** Delete a file. *)
| DeleteFile (file_name : LString.t)
(** Run a command. *)
| System (command : LString.t)
(** Print a message on the standard output. *)
| Print (message : LString.t)
(** Read a line on the standard input. *)
| ReadLine.

(** The type of an answer for a command depends on the value of the command. *)
Definition answer (command : t) : Type :=
  match command with
  | ListFiles _ => option (list LString.t)
  | ReadFile _ => option LString.t
  | WriteFile _ _ => bool
  | DeleteFile _ => bool
  | System _ => option bool
  | Print _ => bool
  | ReadLine => option LString.t
  end.

Definition effects : Effects.t := {|
  Effects.command := t;
  Effects.answer := answer |}.

Definition log (message : LString.t) : C.t effects unit :=
  do! call effects (Print (message ++ [LString.Char.n])) in
  ret tt.

Definition read_line : C.t effects (option LString.t) :=
  call effects ReadLine.

Module Run.
  Definition log_ok (message : LString.t) : Run.t (log message) tt.
    apply (Run.Let (Run.Call effects (Print _) true)).
    apply Run.Ret.
  Defined.

  Definition read_line_ok (line : LString.t) : Run.t read_line (Some line).
    apply (Run.Call effects ReadLine (Some line)).
  Defined.

  Definition read_line_error : Run.t read_line None.
    apply (Run.Call effects ReadLine None).
  Defined.
End Run.
