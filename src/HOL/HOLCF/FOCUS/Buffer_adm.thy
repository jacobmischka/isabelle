(*  Title:      HOL/HOLCF/FOCUS/Buffer_adm.thy
    Author:     David von Oheimb, TU Muenchen
*)

section \<open>One-element buffer, proof of Buf_Eq_imp_AC by induction + admissibility\<close>

theory Buffer_adm
imports Buffer Stream_adm
begin

declare enat_0 [simp]

lemma BufAC_Asm_d2: "a\<leadsto>s \<in> BufAC_Asm \<Longrightarrow> \<exists>d. a=Md d"
by (drule BufAC_Asm_unfold [THEN iffD1], auto)

lemma BufAC_Asm_d3:
    "a\<leadsto>b\<leadsto>s \<in> BufAC_Asm \<Longrightarrow> \<exists>d. a=Md d \<and> b=\<bullet> \<and> s \<in> BufAC_Asm"
by (drule BufAC_Asm_unfold [THEN iffD1], auto)

lemma BufAC_Asm_F_def3:
 "(s \<in> BufAC_Asm_F A) = (s=<> \<or>
  (\<exists>d. ft\<cdot>s=Def(Md d)) \<and> (rt\<cdot>s=<> \<or> ft\<cdot>(rt\<cdot>s)=Def \<bullet> \<and> rt\<cdot>(rt\<cdot>s) \<in> A))"
by (unfold BufAC_Asm_F_def, auto)

lemma cont_BufAC_Asm_F: "inf_continuous BufAC_Asm_F"
by (auto simp add: inf_continuous_def BufAC_Asm_F_def3)

lemma BufAC_Cmt_F_def3:
 "((s,t) \<in> BufAC_Cmt_F C) = (\<forall>d x.
    (s = <>       \<longrightarrow> t = <>                   ) \<and>
    (s = Md d\<leadsto><>  \<longrightarrow> t = <>                   ) \<and>
    (s = Md d\<leadsto>\<bullet>\<leadsto>x \<longrightarrow> ft\<cdot>t = Def d & (x,rt\<cdot>t) \<in> C))"
apply (unfold BufAC_Cmt_F_def)
apply (subgoal_tac "\<forall>d x. (s = Md d\<leadsto>\<bullet>\<leadsto>x \<longrightarrow> (\<exists>y. t = d\<leadsto>y \<and> (x,y) \<in> C)) = 
                     (s = Md d\<leadsto>\<bullet>\<leadsto>x \<longrightarrow> ft\<cdot>t = Def d \<and> (x,rt\<cdot>t) \<in> C)")
apply (simp)
apply (auto intro: surjectiv_scons [symmetric])
done

lemma cont_BufAC_Cmt_F: "inf_continuous BufAC_Cmt_F"
by (auto simp add: inf_continuous_def BufAC_Cmt_F_def3)


(**** adm_BufAC_Asm ***********************************************************)

lemma BufAC_Asm_F_stream_monoP: "stream_monoP BufAC_Asm_F"
apply (unfold BufAC_Asm_F_def stream_monoP_def)
apply (rule_tac x="{x. (\<exists>d. x = Md d\<leadsto>\<bullet>\<leadsto><>)}" in exI)
apply (rule_tac x="Suc (Suc 0)" in exI)
apply (clarsimp)
done

lemma adm_BufAC_Asm: "adm (\<lambda>x. x \<in> BufAC_Asm)"
apply (unfold BufAC_Asm_def)
apply (rule cont_BufAC_Asm_F [THEN BufAC_Asm_F_stream_monoP [THEN fstream_gfp_admI]])
done


(**** adm_non_BufAC_Asm *******************************************************)

lemma BufAC_Asm_F_stream_antiP: "stream_antiP BufAC_Asm_F"
apply (unfold stream_antiP_def BufAC_Asm_F_def)
apply (intro strip)
apply (rule_tac x="{x. (\<exists>d. x = Md d\<leadsto>\<bullet>\<leadsto><>)}" in exI)
apply (rule_tac x="Suc (Suc 0)" in exI)
apply (rule conjI)
prefer 2
apply ( intro strip)
apply ( drule slen_mono)
apply ( drule (1) order_trans)
apply (force)+
done

lemma adm_non_BufAC_Asm: "adm (\<lambda>u. u \<notin> BufAC_Asm)"
apply (unfold BufAC_Asm_def)
apply (rule cont_BufAC_Asm_F [THEN BufAC_Asm_F_stream_antiP [THEN fstream_non_gfp_admI]])
done

(**** adm_BufAC ***************************************************************)

(*adm_non_BufAC_Asm*)
lemma BufAC_Asm_cong [rule_format]: "\<forall>f ff. f \<in> BufEq \<longrightarrow> ff \<in> BufEq \<longrightarrow> s \<in> BufAC_Asm \<longrightarrow> f\<cdot>s = ff\<cdot>s"
apply (rule fstream_ind2)
apply (simp add: adm_non_BufAC_Asm)
apply   (force dest: Buf_f_empty)
apply  (force dest!: BufAC_Asm_d2
              dest: Buf_f_d elim: ssubst)
apply (safe dest!: BufAC_Asm_d3)
apply (drule Buf_f_d_req)+
apply (fast elim: ssubst)
done

(*adm_non_BufAC_Asm,BufAC_Asm_cong*)
lemma BufAC_Cmt_d_req:
"\<And>X. [|f \<in> BufEq; s \<in> BufAC_Asm; (s, f\<cdot>s) \<in> BufAC_Cmt|] ==> (a\<leadsto>b\<leadsto>s, f\<cdot>(a\<leadsto>b\<leadsto>s)) \<in> BufAC_Cmt"
apply (rule BufAC_Cmt_unfold [THEN iffD2])
apply (intro strip)
apply (frule Buf_f_d_req)
apply (auto elim: BufAC_Asm_cong [THEN subst])
done

(*adm_BufAC_Asm*)
lemma BufAC_Asm_antiton: "antitonP BufAC_Asm"
apply (rule antitonPI)
apply (rule allI)
apply (rule fstream_ind2)
apply (  rule adm_lemmas)+
apply (   rule cont_id)
apply (   rule adm_BufAC_Asm)
apply (  safe)
apply (  rule BufAC_Asm_empty)
apply ( force dest!: fstream_prefix
              dest: BufAC_Asm_d2 intro: BufAC_Asm_d)
apply ( force dest!: fstream_prefix
              dest: BufAC_Asm_d3 intro!: BufAC_Asm_d_req)
done

(*adm_BufAC_Asm,BufAC_Asm_antiton,adm_non_BufAC_Asm,BufAC_Asm_cong*)
lemma BufAC_Cmt_2stream_monoP: "f \<in> BufEq \<Longrightarrow> \<exists>l. \<forall>i x s. s \<in> BufAC_Asm \<longrightarrow> x << s \<longrightarrow> enat (l i) < #x \<longrightarrow>
                     (x,f\<cdot>x) \<in> (BufAC_Cmt_F ^^ i) top \<longrightarrow>
                     (s,f\<cdot>s) \<in> (BufAC_Cmt_F ^^ i) top"
apply (rule_tac x="%i. 2*i" in exI)
apply (rule allI)
apply (induct_tac "i")
apply ( simp)
apply (simp add: add.commute)
apply (intro strip)
apply (subst BufAC_Cmt_F_def3)
apply (drule_tac P="%x. x" in BufAC_Cmt_F_def3 [THEN subst])
apply safe
apply (   erule Buf_f_empty)
apply (  erule Buf_f_d)
apply ( drule Buf_f_d_req)
apply ( safe, erule ssubst, simp)
apply clarsimp
apply (rename_tac i d xa ya t)
(*
 1. \<And>i d xa ya t.
       \<lbrakk>f \<in> BufEq;
          \<forall>x s. s \<in> BufAC_Asm \<longrightarrow>
                x \<sqsubseteq> s \<longrightarrow>
                enat (2 * i) < #x \<longrightarrow>
                (x, f\<cdot>x) \<in> down_iterate BufAC_Cmt_F i \<longrightarrow>
                (s, f\<cdot>s) \<in> down_iterate BufAC_Cmt_F i;
          Md d\<leadsto>\<bullet>\<leadsto>xa \<in> BufAC_Asm; enat (2 * i) < #ya; f\<cdot>(Md d\<leadsto>\<bullet>\<leadsto>ya) = d\<leadsto>t;
          (ya, t) \<in> down_iterate BufAC_Cmt_F i; ya \<sqsubseteq> xa\<rbrakk>
       \<Longrightarrow> (xa, rt\<cdot>(f\<cdot>(Md d\<leadsto>\<bullet>\<leadsto>xa))) \<in> down_iterate BufAC_Cmt_F i
*)
apply (rotate_tac 2)
apply (drule BufAC_Asm_prefix2)
apply (frule Buf_f_d_req, erule exE, erule conjE, rotate_tac -1, erule ssubst)
apply (frule Buf_f_d_req, erule exE, erule conjE)
apply (            subgoal_tac "f\<cdot>(Md d\<leadsto>\<bullet>\<leadsto>ya) = d\<leadsto>ffa\<cdot>ya")
prefer 2
apply ( assumption)
apply (            rotate_tac -1)
apply (            simp)
apply (erule subst)
(*
 1. \<And>i d xa ya t ff ffa.
       \<lbrakk>f\<cdot>(Md d\<leadsto>\<bullet>\<leadsto>ya) = d\<leadsto>ffa\<cdot>ya; enat (2 * i) < #ya;
          (ya, ffa\<cdot>ya) \<in> down_iterate BufAC_Cmt_F i; ya \<sqsubseteq> xa; f \<in> BufEq;
          \<forall>x s. s \<in> BufAC_Asm \<longrightarrow>
                x \<sqsubseteq> s \<longrightarrow>
                enat (2 * i) < #x \<longrightarrow>
                (x, f\<cdot>x) \<in> down_iterate BufAC_Cmt_F i \<longrightarrow>
                (s, f\<cdot>s) \<in> down_iterate BufAC_Cmt_F i;
          xa \<in> BufAC_Asm; ff \<in> BufEq; ffa \<in> BufEq\<rbrakk>
       \<Longrightarrow> (xa, ff\<cdot>xa) \<in> down_iterate BufAC_Cmt_F i
*)
apply (drule spec, drule spec, drule (1) mp)
apply (drule (1) mp)
apply (drule (1) mp)
apply (erule impE)
apply ( subst BufAC_Asm_cong, assumption)
prefer 3 apply assumption
apply assumption
apply ( erule (1) BufAC_Asm_antiton [THEN antitonPD])
apply (subst BufAC_Asm_cong, assumption)
prefer 3 apply assumption
apply assumption
apply assumption
done

lemma BufAC_Cmt_iterate_all: "(x\<in>BufAC_Cmt) = (\<forall>n. x\<in>(BufAC_Cmt_F ^^ n) top)"
apply (unfold BufAC_Cmt_def)
apply (subst cont_BufAC_Cmt_F [THEN inf_continuous_gfp])
apply (fast)
done

(*adm_BufAC_Asm,BufAC_Asm_antiton,adm_non_BufAC_Asm,BufAC_Asm_cong,
  BufAC_Cmt_2stream_monoP*)
lemma adm_BufAC: "f \<in> BufEq \<Longrightarrow> adm (\<lambda>s. s \<in> BufAC_Asm \<longrightarrow> (s, f\<cdot>s) \<in> BufAC_Cmt)"
apply (rule flatstream_admI)
apply (subst BufAC_Cmt_iterate_all)
apply (drule BufAC_Cmt_2stream_monoP)
apply safe
apply (drule spec, erule exE)
apply (drule spec, erule impE)
apply  (erule BufAC_Asm_antiton [THEN antitonPD])
apply  (erule is_ub_thelub)
apply (tactic "smp_tac \<^context> 3 1")
apply (drule is_ub_thelub)
apply (drule (1) mp)
apply (drule (1) mp)
apply (erule mp)
apply (drule BufAC_Cmt_iterate_all [THEN iffD1])
apply (erule spec)
done



(**** Buf_Eq_imp_AC by induction **********************************************)

(*adm_BufAC_Asm,BufAC_Asm_antiton,adm_non_BufAC_Asm,BufAC_Asm_cong,
  BufAC_Cmt_2stream_monoP,adm_BufAC,BufAC_Cmt_d_req*)
lemma Buf_Eq_imp_AC: "BufEq <= BufAC"
apply (unfold BufAC_def)
apply (rule subsetI)
apply (simp)
apply (rule allI)
apply (rule fstream_ind2)
back
apply (   erule adm_BufAC)
apply (  safe)
apply (   erule BufAC_Cmt_empty)
apply (  erule BufAC_Cmt_d)
apply ( drule BufAC_Asm_prefix2)
apply ( simp)
apply (fast intro: BufAC_Cmt_d_req BufAC_Asm_prefix2)
done

(**** new approach for admissibility, reduces itself to absurdity *************)

lemma adm_BufAC_Asm': "adm (\<lambda>x. x\<in>BufAC_Asm)"
apply (rule def_gfp_admI)
apply (rule BufAC_Asm_def [THEN eq_reflection])
apply (safe)
apply (unfold BufAC_Asm_F_def)
apply (safe)
apply (erule contrapos_np)
apply (drule fstream_exhaust_eq [THEN iffD1])
apply (clarsimp)
apply (drule (1) fstream_lub_lemma)
apply (clarify)
apply (erule_tac x="j" in all_dupE)
apply (simp)
apply (drule BufAC_Asm_d2)
apply (clarify)
apply (simp)
apply (rule disjCI)
apply (erule contrapos_np)
apply (drule fstream_exhaust_eq [THEN iffD1])
apply (clarsimp)
apply (drule (1) fstream_lub_lemma)
apply (clarsimp)
apply (simp only: ex_simps [symmetric] all_simps [symmetric])
apply (rule_tac x="Xa" in exI)
apply (rule allI)
apply (rotate_tac -1)
apply (erule_tac x="i" in allE)
apply (clarsimp)
apply (erule_tac x="jb" in allE)
apply (clarsimp)
apply (erule_tac x="jc" in allE)
apply (clarsimp dest!: BufAC_Asm_d3)
done

lemma adm_non_BufAC_Asm': "adm (\<lambda>u. u \<notin> BufAC_Asm)" (* uses antitonP *)
apply (rule def_gfp_adm_nonP)
apply (rule BufAC_Asm_def [THEN eq_reflection])
apply (unfold BufAC_Asm_F_def)
apply (safe)
apply (erule contrapos_np)
apply (drule fstream_exhaust_eq [THEN iffD1])
apply (clarsimp)
apply (frule fstream_prefix)
apply (clarsimp)
apply (frule BufAC_Asm_d2)
apply (clarsimp)
apply (rotate_tac -1)
apply (erule contrapos_pp)
apply (drule fstream_exhaust_eq [THEN iffD1])
apply (clarsimp)
apply (frule fstream_prefix)
apply (clarsimp)
apply (frule BufAC_Asm_d3)
apply (force)
done

lemma adm_BufAC': "f \<in> BufEq \<Longrightarrow> adm (\<lambda>u. u \<in> BufAC_Asm \<longrightarrow> (u, f\<cdot>u) \<in> BufAC_Cmt)"
apply (rule triv_admI)
apply (clarify)
apply (erule (1) Buf_Eq_imp_AC_lemma)
      (* this is what we originally aimed to show, using admissibilty :-( *)
done

end

