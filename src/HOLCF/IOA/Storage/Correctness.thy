(*  Title:      HOL/IOA/example/Correctness.thy
    ID:         $Id$
    Author:     Olaf Mueller
    Copyright   1997  TU Muenchen

Correctness Proof
*)

Correctness = SimCorrectness + Spec + Impl + 

default term

consts

sim_relation   :: "((nat * bool) * (nat set * bool)) set"

defs
  
sim_relation_def
  "sim_relation == {qua. let c = fst qua; a = snd qua ; 
                             k = fst c;   b = snd c;
                             used = fst a; c = snd a
                         in
                         (! l:used. l < k) & b=c }"

end