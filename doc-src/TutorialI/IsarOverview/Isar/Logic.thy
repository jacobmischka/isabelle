(*<*)theory Logic = Main:(*>*)
text{* We begin by looking at a simplified grammar for Isar proofs
where parentheses are used for grouping and $^?$ indicates an optional item:
\begin{center}
\begin{tabular}{lrl}
\emph{proof} & ::= & \isakeyword{proof} \emph{method}$^?$
                     \emph{statement}*
                     \isakeyword{qed} \\
                 &$\mid$& \isakeyword{by} \emph{method}\\[1ex]
\emph{statement} &::= & \isakeyword{fix} \emph{variables} \\
             &$\mid$& \isakeyword{assume} \emph{propositions} \\
             &$\mid$& (\isakeyword{from} \emph{facts})$^?$ 
                    (\isakeyword{show} $\mid$ \isakeyword{have})
                      \emph{propositions} \emph{proof} \\[1ex]
\emph{proposition} &::=& (\emph{label}{\bf:})$^?$ \emph{string} \\[1ex]
\emph{fact} &::=& \emph{label}
\end{tabular}
\end{center}

This is a typical proof skeleton:
\begin{center}
\begin{tabular}{@ {}ll}
\isakeyword{proof}\\
\hspace*{3ex}\isakeyword{assume} @{text"\""}\emph{the-assm}@{text"\""}\\
\hspace*{3ex}\isakeyword{have} @{text"\""}\dots@{text"\""}  & --- intermediate result\\
\hspace*{3ex}\vdots\\
\hspace*{3ex}\isakeyword{have} @{text"\""}\dots@{text"\""}  & --- intermediate result\\
\hspace*{3ex}\isakeyword{show} @{text"\""}\emph{the-concl}@{text"\""}\\
\isakeyword{qed}
\end{tabular}
\end{center}
It proves \emph{the-assm}~@{text"\<Longrightarrow>"}~\emph{the-concl}.
Text starting with ``---'' is a comment.

Note that \emph{propositions} (following \isakeyword{assume} etc)
may but need not be
separated by \isakeyword{and}, whose purpose is to structure them
into possibly named blocks. For example in
\begin{center}
\isakeyword{assume} @{text"A:"} $A_1$ $A_2$ \isakeyword{and} @{text"B:"} $A_3$
\isakeyword{and} $A_4$
\end{center}
label @{text A} refers to the list of propositions $A_1$ $A_2$ and
label @{text B} to $A_3$.
*}

section{*Logic*}

subsection{*Propositional logic*}

subsubsection{*Introduction rules*}

text{* We start with a really trivial toy proof to introduce the basic
features of structured proofs. *}
lemma "A \<longrightarrow> A"
proof (rule impI)
  assume a: "A"
  show "A" by(rule a)
qed
text{*\noindent
The operational reading: the \isakeyword{assume}-\isakeyword{show} block
proves @{prop"A \<Longrightarrow> A"},
which rule @{thm[source]impI} turns into the desired @{prop"A \<longrightarrow> A"}.
However, this text is much too detailed for comfort. Therefore Isar
implements the following principle:
\begin{quote}\em
Command \isakeyword{proof} automatically tries to select an introduction rule
based on the goal and a predefined list of rules.
\end{quote}
Here @{thm[source]impI} is applied automatically:
*}

lemma "A \<longrightarrow> A"
proof
  assume a: "A"
  show "A" by(rule a)
qed

text{* Trivial proofs, in particular those by assumption, should be trivial
to perform. Proof ``.'' does just that (and a bit more). Thus
naming of assumptions is often superfluous: *}
lemma "A \<longrightarrow> A"
proof
  assume "A"
  show "A" .
qed

text{* To hide proofs by assumption further, \isakeyword{by}@{text"(method)"}
first applies @{text method} and then tries to solve all remaining subgoals
by assumption: *}
lemma "A \<longrightarrow> A \<and> A"
proof
  assume A
  show "A \<and> A" by(rule conjI)
qed
text{*\noindent A drawback of these implicit proofs by assumption is that it
is no longer obvious where an assumption is used.

Proofs of the form \isakeyword{by}@{text"(rule"}~\emph{name}@{text")"} can be
abbreviated to ``..''
if \emph{name} refers to one of the predefined introduction rules:
*}

lemma "A \<longrightarrow> A \<and> A"
proof
  assume A
  show "A \<and> A" ..
qed
text{*\noindent
This is what happens: first the matching introduction rule @{thm[source]conjI}
is applied (first ``.''), then the two subgoals are solved by assumption
(second ``.''). *}

subsubsection{*Elimination rules*}

text{*A typical elimination rule is @{thm[source]conjE}, $\land$-elimination:
@{thm[display,indent=5]conjE[no_vars]}  In the following proof it is applied
by hand, after its first (``\emph{major}'') premise has been eliminated via
@{text"[OF AB]"}: *}
lemma "A \<and> B \<longrightarrow> B \<and> A"
proof
  assume AB: "A \<and> B"
  show "B \<and> A"
  proof (rule conjE[OF AB])  -- {*@{text"conjE[OF AB]"}: @{thm conjE[OF AB]} *}
    assume A and B
    show ?thesis ..
  qed
qed
text{*\noindent Note that the term @{text"?thesis"} always stands for the
``current goal'', i.e.\ the enclosing \isakeyword{show} (or
\isakeyword{have}) statement.

This is too much proof text. Elimination rules should be selected
automatically based on their major premise, the formula or rather connective
to be eliminated. In Isar they are triggered by propositions being fed
\emph{into} a proof. Syntax:
\begin{center}
\isakeyword{from} \emph{fact} \isakeyword{show} \emph{proposition} \emph{proof}
\end{center}
where \emph{fact} stands for the name of a previously proved
proposition, e.g.\ an assumption, an intermediate result or some global
theorem, which may also be modified with @{text of}, @{text OF} etc.
The \emph{fact} is ``piped'' into the \emph{proof}, which can deal with it
how it choses. If the \emph{proof} starts with a plain \isakeyword{proof},
an elimination rule (from a predefined list) is applied
whose first premise is solved by the \emph{fact}. Thus the proof above
is equivalent to the following one: *}

lemma "A \<and> B \<longrightarrow> B \<and> A"
proof
  assume AB: "A \<and> B"
  from AB show "B \<and> A"
  proof
    assume A and B
    show ?thesis ..
  qed
qed

text{* Now we come a second important principle:
\begin{quote}\em
Try to arrange the sequence of propositions in a UNIX-like pipe,
such that the proof of each proposition builds on the previous proposition.
\end{quote}
The previous proposition can be referred to via the fact @{text this}.
This greatly reduces the need for explicit naming of propositions:
*}
lemma "A \<and> B \<longrightarrow> B \<and> A"
proof
  assume "A \<and> B"
  from this show "B \<and> A"
  proof
    assume A and B
    show ?thesis ..
  qed
qed

text{*\noindent Because of the frequency of \isakeyword{from}~@{text
this} Isar provides two abbreviations:
\begin{center}
\begin{tabular}{rcl}
\isakeyword{then} &=& \isakeyword{from} @{text this} \\
\isakeyword{thus} &=& \isakeyword{then} \isakeyword{show}
\end{tabular}
\end{center}
\medskip

Here is an alternative proof that operates purely by forward reasoning: *}
lemma "A \<and> B \<longrightarrow> B \<and> A"
proof
  assume ab: "A \<and> B"
  from ab have a: A ..
  from ab have b: B ..
  from b a show "B \<and> A" ..
qed
text{*\noindent
It is worth examining this text in detail because it exhibits a number of new concepts.

For a start, this is the first time we have proved intermediate propositions
(\isakeyword{have}) on the way to the final \isakeyword{show}. This is the
norm in any nontrivial proof where one cannot bridge the gap between the
assumptions and the conclusion in one step. Both \isakeyword{have}s above are
proved automatically via @{thm[source]conjE} triggered by
\isakeyword{from}~@{text ab}.

The \isakeyword{show} command illustrates two things:
\begin{itemize}
\item \isakeyword{from} can be followed by any number of facts.
Given \isakeyword{from}~@{text f}$_1$~\dots~@{text f}$_n$, the
\isakeyword{proof} step after \isakeyword{show}
tries to find an elimination rule whose first $n$ premises can be proved
by the given facts in the given order.
\item If there is no matching elimination rule, introduction rules are tried,
again using the facts to prove the premises.
\end{itemize}
In this case, the proof succeeds with @{thm[source]conjI}. Note that the proof
would fail had we written \isakeyword{from}~@{text"a b"}
instead of \isakeyword{from}~@{text"b a"}.

This treatment of facts fed into a proof is not restricted to implicit
application of introduction and elimination rules but applies to explicit
application of rules as well. Thus you could replace the final ``..'' above
with \isakeyword{by}@{text"(rule conjI)"}. 
*}

subsection{*More constructs*}

text{* In the previous proof of @{prop"A \<and> B \<longrightarrow> B \<and> A"} we needed to feed
more than one fact into a proof step, a frequent situation. Then the
UNIX-pipe model appears to break down and we need to name the different
facts to refer to them. But this can be avoided:
*}
lemma "A \<and> B \<longrightarrow> B \<and> A"
proof
  assume ab: "A \<and> B"
  from ab have B ..
  moreover
  from ab have A ..
  ultimately show "B \<and> A" ..
qed
text{*\noindent You can combine any number of facts @{term A1} \dots\ @{term
An} into a sequence by separating their proofs with
\isakeyword{moreover}. After the final fact, \isakeyword{ultimately} stands
for \isakeyword{from}~@{term A1}~\dots~@{term An}.  This avoids having to
introduce names for all of the sequence elements.  *}

text{* Although we have only seen a few introduction and elemination rules so
far, Isar's predefined rules include all the usual natural deduction
rules. We conclude our exposition of propositional logic with an extended
example --- which rules are used implicitly where? *}
lemma "\<not> (A \<and> B) \<longrightarrow> \<not> A \<or> \<not> B"
proof
  assume n: "\<not> (A \<and> B)"
  show "\<not> A \<or> \<not> B"
  proof (rule ccontr)
    assume nn: "\<not> (\<not> A \<or> \<not> B)"
    have "\<not> A"
    proof
      assume A
      have "\<not> B"
      proof
        assume B
        have "A \<and> B" ..
        with n show False ..
      qed
      hence "\<not> A \<or> \<not> B" ..
      with nn show False ..
    qed
    hence "\<not> A \<or> \<not> B" ..
    with nn show False ..
  qed
qed
text{*\noindent
Rule @{thm[source]ccontr} (``classical contradiction'') is
@{thm ccontr[no_vars]}.
Apart from demonstrating the strangeness of classical
arguments by contradiction, this example also introduces two new
abbreviations:
\begin{center}
\begin{tabular}{lcl}
\isakeyword{hence} &=& \isakeyword{then} \isakeyword{have} \\
\isakeyword{with}~\emph{facts} &=&
\isakeyword{from}~\emph{facts} \isakeyword{and} @{text this}
\end{tabular}
\end{center}
*}

subsection{*Avoiding duplication*}

text{* So far our examples have been a bit unnatural: normally we want to
prove rules expressed with @{text"\<Longrightarrow>"}, not @{text"\<longrightarrow>"}. Here is an example:
*}
lemma "A \<and> B \<Longrightarrow> B \<and> A"
proof
  assume "A \<and> B" thus "B" ..
next
  assume "A \<and> B" thus "A" ..
qed
text{*\noindent The \isakeyword{proof} always works on the conclusion,
@{prop"B \<and> A"} in our case, thus selecting $\land$-introduction. Hence
we must show @{prop B} and @{prop A}; both are proved by
$\land$-elimination and the proofs are separated by \isakeyword{next}:
\begin{description}
\item[\isakeyword{next}] deals with multiple subgoals. For example,
when showing @{term"A \<and> B"} we need to show both @{term A} and @{term
B}.  Each subgoal is proved separately, in \emph{any} order. The
individual proofs are separated by \isakeyword{next}.
\end{description}

This is all very well as long as formulae are small. Let us now look at some
devices to avoid repeating (possibly large) formulae. A very general method
is pattern matching: *}

lemma "large_A \<and> large_B \<Longrightarrow> large_B \<and> large_A"
      (is "?AB \<Longrightarrow> ?B \<and> ?A")
proof
  assume ?AB thus ?B ..
next
  assume ?AB thus ?A ..
qed
text{*\noindent Any formula may be followed by
@{text"("}\isakeyword{is}~\emph{pattern}@{text")"} which causes the pattern
to be matched against the formula, instantiating the @{text"?"}-variables in
the pattern. Subsequent uses of these variables in other terms simply causes
them to be replaced by the terms they stand for.

We can simplify things even more by stating the theorem by means of the
\isakeyword{assumes} and \isakeyword{shows} elements which allow direct
naming of assumptions: *}

lemma assumes AB: "large_A \<and> large_B"
  shows "large_B \<and> large_A" (is "?B \<and> ?A")
proof
  from AB show ?B ..
next
  from AB show ?A ..
qed
text{*\noindent Note the difference between @{text ?AB}, a term, and
@{text AB}, a fact.

Finally we want to start the proof with $\land$-elimination so we
don't have to perform it twice, as above. Here is a slick way to
achieve this: *}

lemma assumes AB: "large_A \<and> large_B"
  shows "large_B \<and> large_A" (is "?B \<and> ?A")
using AB
proof
  assume ?A and ?B show ?thesis ..
qed
text{*\noindent Command \isakeyword{using} can appear before a proof
and adds further facts to those piped into the proof. Here @{text AB}
is the only such fact and it triggers $\land$-elimination. Another
frequent usage is as follows:
\begin{center}
\isakeyword{from} \emph{important facts}
\isakeyword{show} \emph{something}
\isakeyword{using} \emph{minor facts}
\end{center}
\medskip

Sometimes it is necessary to suppress the implicit application of rules in a
\isakeyword{proof}. For example \isakeyword{show}~@{prop"A \<or> B"} would
trigger $\lor$-introduction, requiring us to prove @{prop A}. A simple
``@{text"-"}'' prevents this \emph{faut pas}: *}

lemma assumes AB: "A \<or> B" shows "B \<or> A"
proof -
  from AB show ?thesis
  proof
    assume A show ?thesis ..
  next
    assume B show ?thesis ..
  qed
qed
text{*\noindent Could \isakeyword{using} help to eliminate this ``@{text"-"}''? *}

subsection{*Predicate calculus*}

text{* Command \isakeyword{fix} introduces new local variables into a
proof. The pair \isakeyword{fix}-\isakeyword{show} corresponds to @{text"\<And>"}
(the universal quantifier at the
meta-level) just like \isakeyword{assume}-\isakeyword{show} corresponds to
@{text"\<Longrightarrow>"}. Here is a sample proof, annotated with the rules that are
applied implicitly: *}
lemma assumes P: "\<forall>x. P x" shows "\<forall>x. P(f x)"
proof                       --"@{thm[source]allI}: @{thm allI}"
  fix a
  from P show "P(f a)" ..  --"@{thm[source]allE}: @{thm allE}"
qed
text{*\noindent Note that in the proof we have chosen to call the bound
variable @{term a} instead of @{term x} merely to show that the choice of
local names is irrelevant.

Next we look at @{text"\<exists>"} which is a bit more tricky.
*}

lemma assumes Pf: "\<exists>x. P(f x)" shows "\<exists>y. P y"
proof -
  from Pf show ?thesis
  proof              -- "@{thm[source]exE}: @{thm exE}"
    fix x
    assume "P(f x)"
    show ?thesis ..  -- "@{thm[source]exI}: @{thm exI}"
  qed
qed
text{*\noindent Explicit $\exists$-elimination as seen above can become
cumbersome in practice.  The derived Isar language element
\isakeyword{obtain} provides a more appealing form of generalized
existence reasoning: *}

lemma assumes Pf: "\<exists>x. P(f x)" shows "\<exists>y. P y"
proof -
  from Pf obtain x where "P(f x)" ..
  thus "\<exists>y. P y" ..
qed
text{*\noindent Note how the proof text follows the usual mathematical style
of concluding $P(x)$ from $\exists x. P(x)$, while carefully introducing $x$
as a new local variable.  Technically, \isakeyword{obtain} is similar to
\isakeyword{fix} and \isakeyword{assume} together with a soundness proof of
the elimination involved.

Here is a proof of a well known tautology.
Figure out which rule is used where!  *}

lemma assumes ex: "\<exists>x. \<forall>y. P x y" shows "\<forall>y. \<exists>x. P x y"
proof
  fix y
  from ex obtain x where "\<forall>y. P x y" ..
  hence "P x y" ..
  thus "\<exists>x. P x y" ..
qed

text{* So far we have confined ourselves to single step proofs. Of course
powerful automatic methods can be used just as well. Here is an example,
Cantor's theorem that there is no surjective function from a set to its
powerset: *}
theorem "\<exists>S. S \<notin> range (f :: 'a \<Rightarrow> 'a set)"
proof
  let ?S = "{x. x \<notin> f x}"
  show "?S \<notin> range f"
  proof
    assume "?S \<in> range f"
    then obtain y where fy: "?S = f y" ..
    show False
    proof cases
      assume "y \<in> ?S"
      with fy show False by blast
    next
      assume "y \<notin> ?S"
      with fy show False by blast
    qed
  qed
qed
text{*\noindent
For a start, the example demonstrates two new constructs:
\begin{itemize}
\item \isakeyword{let} introduces an abbreviation for a term, in our case
the witness for the claim.
\item Proof by @{text"cases"} starts a proof by cases. Note that it remains
implicit what the two cases are: it is merely expected that the two subproofs
prove @{text"P \<Longrightarrow> ?thesis"} and @{text"\<not>P \<Longrightarrow> ?thesis"} (in that order)
for some @{term P}.
\end{itemize}
If you wonder how to \isakeyword{obtain} @{term y}:
via the predefined elimination rule @{thm rangeE[no_vars]}.

Method @{text blast} is used because the contradiction does not follow easily
by just a single rule. If you find the proof too cryptic for human
consumption, here is a more detailed version; the beginning up to
\isakeyword{obtain} stays unchanged. *}

theorem "\<exists>S. S \<notin> range (f :: 'a \<Rightarrow> 'a set)"
proof
  let ?S = "{x. x \<notin> f x}"
  show "?S \<notin> range f"
  proof
    assume "?S \<in> range f"
    then obtain y where fy: "?S = f y" ..
    show False
    proof cases
      assume "y \<in> ?S"
      hence "y \<notin> f y"   by simp
      hence "y \<notin> ?S"    by(simp add:fy)
      thus False        by contradiction
    next
      assume "y \<notin> ?S"
      hence "y \<in> f y"   by simp
      hence "y \<in> ?S"    by(simp add:fy)
      thus False        by contradiction
    qed
  qed
qed
text{*\noindent Method @{text contradiction} succeeds if both $P$ and
$\neg P$ are among the assumptions and the facts fed into that step, in any order.

As it happens, Cantor's theorem can be proved automatically by best-first
search. Depth-first search would diverge, but best-first search successfully
navigates through the large search space:
*}

theorem "\<exists>S. S \<notin> range (f :: 'a \<Rightarrow> 'a set)"
by best
text{*\noindent Of course this only works in the context of HOL's carefully
constructed introduction and elimination rules for set theory.

Finally, whole ``scripts'' (unstructured proofs in the style of
\cite{LNCS2283}) may appear in the leaves of the proof tree, although this is
best avoided.  Here is a contrived example: *}

lemma "A \<longrightarrow> (A \<longrightarrow> B) \<longrightarrow> B"
proof
  assume a: A
  show "(A \<longrightarrow>B) \<longrightarrow> B"
    apply(rule impI)
    apply(erule impE)
    apply(rule a)
    apply assumption
    done
qed
text{*\noindent You may need to resort to this technique if an automatic step
fails to prove the desired proposition. *}

section{*Case distinction and induction*}


subsection{*Case distinction*}

text{* We have already met the @{text cases} method for performing
binary case splits. Here is another example: *}
lemma "P \<or> \<not> P"
proof cases
  assume "P" thus ?thesis ..
next
  assume "\<not> P" thus ?thesis ..
qed
text{*\noindent Note that the two cases must come in this order.

This form is appropriate if @{term P} is textually small.  However, if
@{term P} is large, we don't want to repeat it. This can be avoided by
the following idiom *}

lemma "P \<or> \<not> P"
proof (cases "P")
  case True thus ?thesis ..
next
  case False thus ?thesis ..
qed
text{*\noindent which is simply a shorthand for the previous
proof. More precisely, the phrases \isakeyword{case}~@{prop
True}/@{prop False} abbreviate the corresponding assumptions @{prop P}
and @{prop"\<not>P"}. In contrast to the previous proof we can prove the cases
in arbitrary order.

The same game can be played with other datatypes, for example lists:
*}
(*<*)declare length_tl[simp del](*>*)
lemma "length(tl xs) = length xs - 1"
proof (cases xs)
  case Nil thus ?thesis by simp
next
  case Cons thus ?thesis by simp
qed
text{*\noindent Here \isakeyword{case}~@{text Nil} abbreviates
\isakeyword{assume}~@{prop"xs = []"} and \isakeyword{case}~@{text Cons}
abbreviates \isakeyword{fix}~@{text"? ??"}
\isakeyword{assume}~@{text"xs = ? # ??"} where @{text"?"} and @{text"??"}
stand for variable names that have been chosen by the system.
Therefore we cannot
refer to them (this would lead to obscure proofs) and have not even shown
them. Luckily, this proof is simple enough we do not need to refer to them.
However, sometimes one may have to. Hence Isar offers a simple scheme for
naming those variables: replace the anonymous @{text Cons} by, for example,
@{text"(Cons y ys)"}, which abbreviates \isakeyword{fix}~@{text"y ys"}
\isakeyword{assume}~@{text"xs = Cons y ys"}, i.e.\ @{prop"xs = y # ys"}. Here
is a (somewhat contrived) example: *}

lemma "length(tl xs) = length xs - 1"
proof (cases xs)
  case Nil thus ?thesis by simp
next
  case (Cons y ys)
  hence "length(tl xs) = length ys  \<and>  length xs = length ys + 1"
    by simp
  thus ?thesis by simp
qed


subsection{*Structural induction*}

text{* We start with a simple inductive proof where both cases are proved automatically: *}
lemma "2 * (\<Sum>i<n+1. i) = n*(n+1)"
by (induct n, simp_all)

text{*\noindent If we want to expose more of the structure of the
proof, we can use pattern matching to avoid having to repeat the goal
statement: *}
lemma "2 * (\<Sum>i<n+1. i) = n*(n+1)" (is "?P n")
proof (induct n)
  show "?P 0" by simp
next
  fix n assume "?P n"
  thus "?P(Suc n)" by simp
qed

text{* \noindent We could refine this further to show more of the equational
proof. Instead we explore the same avenue as for case distinctions:
introducing context via the \isakeyword{case} command: *}
lemma "2 * (\<Sum>i<n+1. i) = n*(n+1)"
proof (induct n)
  case 0 show ?case by simp
next
  case Suc thus ?case by simp
qed

text{* \noindent The implicitly defined @{text ?case} refers to the
corresponding case to be proved, i.e.\ @{text"?P 0"} in the first case and
@{text"?P(Suc n)"} in the second case. Context \isakeyword{case}~@{text 0} is
empty whereas \isakeyword{case}~@{text Suc} assumes @{text"?P n"}. Again we
have the same problem as with case distinctions: we cannot refer to an anonymous @{term n}
in the induction step because it has not been introduced via \isakeyword{fix}
(in contrast to the previous proof). The solution is the same as above:
replace @{term Suc} by @{text"(Suc i)"}: *}
lemma fixes n::nat shows "n < n*n + 1"
proof (induct n)
  case 0 show ?case by simp
next
  case (Suc i) thus "Suc i < Suc i * Suc i + 1" by simp
qed

text{* \noindent Of course we could again have written
\isakeyword{thus}~@{text ?case} instead of giving the term explicitly
but we wanted to use @{term i} somewhere. *}

subsection{*Induction formulae involving @{text"\<And>"} or @{text"\<Longrightarrow>"}*}

text{* Let us now consider the situation where the goal to be proved contains
@{text"\<And>"} or @{text"\<Longrightarrow>"}, say @{prop"\<And>x. P x \<Longrightarrow> Q x"} --- motivation and a
real example follow shortly.  This means that in each case of the induction,
@{text ?case} would be of the same form @{prop"\<And>x. P' x \<Longrightarrow> Q' x"}.  Thus the
first proof steps will be the canonical ones, fixing @{text x} and assuming
@{prop"P' x"}. To avoid this tedium, induction performs these steps
automatically: for example in case @{text"(Suc n)"}, @{text ?case} is only
@{prop"Q' x"} whereas the assumptions (named @{term Suc}) contain both the
usual induction hypothesis \emph{and} @{prop"P' x"}. To fix the name of the
bound variable @{term x} you may write @{text"(Suc n x)"}, thus abbreviating
\isakeyword{fix}~@{term x}.
It should be clear how this example generalizes to more complex formulae.

As a concrete example we will now prove complete induction via
structural induction: *}

lemma assumes A: "(\<And>n. (\<And>m. m < n \<Longrightarrow> P m) \<Longrightarrow> P n)"
  shows "P(n::nat)"
proof (rule A)
  show "\<And>m. m < n \<Longrightarrow> P m"
  proof (induct n)
    case 0 thus ?case by simp
  next
    case (Suc n m)    -- {*@{text"?m < n \<Longrightarrow> P ?m"}  and  @{prop"m < Suc n"}*}
    show ?case       -- {*@{term ?case}*}
    proof cases
      assume eq: "m = n"
      from Suc A have "P n" by blast
      with eq show "P m" by simp
    next
      assume "m \<noteq> n"
      with Suc have "m < n" by arith
      thus "P m" by(rule Suc)
    qed
  qed
qed
text{* \noindent Given the explanations above and the comments in
the proof text, the proof should be quite readable.

The statement of the lemma is interesting because it deviates from the style in
the Tutorial~\cite{LNCS2283}, which suggests to introduce @{text"\<forall>"} or
@{text"\<longrightarrow>"} into a theorem to strengthen it for induction. In structured Isar
proofs we can use @{text"\<And>"} and @{text"\<Longrightarrow>"} instead. This simplifies the
proof and means we do not have to convert between the two kinds of
connectives.
*}

subsection{*Rule induction*}

text{* We define our own version of reflexive transitive closure of a
relation *}
consts rtc :: "('a \<times> 'a)set \<Rightarrow> ('a \<times> 'a)set"   ("_*" [1000] 999)
inductive "r*"
intros
refl:  "(x,x) \<in> r*"
step:  "\<lbrakk> (x,y) \<in> r; (y,z) \<in> r* \<rbrakk> \<Longrightarrow> (x,z) \<in> r*"

text{* \noindent and prove that @{term"r*"} is indeed transitive: *}
lemma assumes A: "(x,y) \<in> r*" shows "(y,z) \<in> r* \<Longrightarrow> (x,z) \<in> r*"
using A
proof induct
  case refl thus ?case .
next
  case step thus ?case by(blast intro: rtc.step)
qed
text{*\noindent Rule induction is triggered by a fact $(x_1,\dots,x_n)
\in R$ piped into the proof, here \isakeyword{using}~@{text A}. The
proof itself follows the inductive definition very
closely: there is one case for each rule, and it has the same name as
the rule, analogous to structural induction.

However, this proof is rather terse. Here is a more readable version:
*}

lemma assumes A: "(x,y) \<in> r*" and B: "(y,z) \<in> r*"
  shows "(x,z) \<in> r*"
proof -
  from A B show ?thesis
  proof induct
    fix x assume "(x,z) \<in> r*"  -- {*@{text B}[@{text y} := @{text x}]*}
    thus "(x,z) \<in> r*" .
  next
    fix x' x y
    assume 1: "(x',x) \<in> r" and
           IH: "(y,z) \<in> r* \<Longrightarrow> (x,z) \<in> r*" and
           B:  "(y,z) \<in> r*"
    from 1 IH[OF B] show "(x',z) \<in> r*" by(rule rtc.step)
  qed
qed
text{*\noindent We start the proof with \isakeyword{from}~@{text"A
B"}. Only @{text A} is ``consumed'' by the induction step.
Since @{text B} is left over we don't just prove @{text
?thesis} but @{text"B \<Longrightarrow> ?thesis"}, just as in the previous proof. The
base case is trivial. In the assumptions for the induction step we can
see very clearly how things fit together and permit ourselves the
obvious forward step @{text"IH[OF B]"}. *}

subsection{*More induction*}

text{* We close the section by demonstrating how arbitrary induction rules
are applied. As a simple example we have chosen recursion induction, i.e.\
induction based on a recursive function definition. The example is an unusual
definition of rotation: *}

consts rot :: "'a list \<Rightarrow> 'a list"
recdef rot "measure length"
"rot [] = []"
"rot [x] = [x]"
"rot (x#y#zs) = y # rot(x#zs)"

text{* In the first proof we set up each case explicitly, merely using
pattern matching to abbreviate the statement: *}

lemma "length(rot xs) = length xs" (is "?P xs")
proof (induct xs rule: rot.induct)
  show "?P []" by simp
next
  fix x show "?P [x]" by simp
next
  fix x y zs assume "?P (x#zs)"
  thus "?P (x#y#zs)" by simp
qed
text{*\noindent
This proof skeleton works for arbitrary induction rules, not just
@{thm[source]rot.induct}.

In the following proof we rely on a default naming scheme for cases: they are
called 1, 2, etc, unless they have been named explicitly. The latter happens
only with datatypes and inductively defined sets, but not with recursive
functions. *}

lemma "xs \<noteq> [] \<Longrightarrow> rot xs = tl xs @ [hd xs]"
proof (induct xs rule: rot.induct)
  case 1 thus ?case by simp
next
  case 2 show ?case by simp
next
  case 3 thus ?case by simp
qed

text{*\noindent Why can case 2 get away with \isakeyword{show} instead of
\isakeyword{thus}?

Of course both proofs are so simple that they can be condensed to*}
(*<*)lemma "xs \<noteq> [] \<Longrightarrow> rot xs = tl xs @ [hd xs]"(*>*)
by (induct xs rule: rot.induct, simp_all)
(*<*)end(*>*)
