/* Offline lexical highlighting. Keeps raw source offsets; Isabelle escapes
 * render as Unicode using the installed distribution's symbol mapping.
 * Nested Rocq/Isabelle comments and embedded ACSL/refinement syntax are scanned
 * before identifiers, so keywords inside ordinary comments are not recolored.
 */
const LabSyntax=(()=>{
 const display=(text,language)=>['isabelle','hol'].includes(language)?text.replace(/\\<[^>]+>/g,s=>IsabelleSymbols[s]||s):text;
 const words=s=>new Set(s.split(/\s+/));
 const cKeywords=words('auto break case const continue default do else enum extern for goto if inline register restrict return sizeof static struct switch typedef union volatile while _Alignas _Alignof _Atomic _Bool _Complex _Generic _Imaginary _Noreturn _Static_assert _Thread_local');
 const cTypes=words('char double float int long short signed unsigned void size_t ptrdiff_t intptr_t uintptr_t int32_t uint32_t bool node_t');
 const acsl=words('requires ensures assigns allocates frees behavior behaviors complete disjoint assumes terminates decreases loop invariant variant assert check admit logic predicate inductive case lemma axiom axiomatic reads integer real boolean for nothing everything');
 const rocqKeywords=words('From Require Import Export Module End Section Context Variable Variables Hypothesis Hypotheses Parameter Parameters Definition Let Fixpoint CoFixpoint Inductive CoInductive Record Structure Class Instance Existing Canonical Program Function Arguments Notation Infix Reserved Open Close Scope Local Global Declare Set Unset Generalizable Implicit Types Hint Resolve Rewrite Constructors Transparent Opaque Eval Compute Check Print About Search Locate Goal Lemma Theorem Corollary Proposition Fact Remark Example Proof Qed Defined Abort Save Next Obligation Equations Derive Match Ltac Ltac2 Tactic Notation match with end fun forall exists let in if then else return as at using by of where for struct measure Prop SProp Type');
 const tactics=words('start_function forward forward_if forward_while forward_call forward_for_simple_bound entailer entailer! Intros Exists assert_PROP cancel sep_apply make_compspecs mk_varspecs with_library intros intro induction destruct assert rewrite autorewrite change unfold fold subst split apply eapply exact eexact refine erefine f_equal reflexivity symmetry transitivity lia nia lra nra rep_lia simpl cbn cbv lazy compute vm_compute native_compute auto eauto intuition tauto firstorder congruence contradiction discriminate inversion injection dependent generalize pose proof specialize revert clear rename remember replace constructor left right exists exfalso assumption trivial easy done have suffices move case elim apply: rewrite: fail idtac try repeat first solve progress now do once all tryif then else timeout abstract unshelve shelve focus unfocus bullet Unshelve Show prepare_parameters split_blocks liRStep liShow print_typesystem_goal unshelve_sidecond sidecond_hook prepare_sideconditions normalize_and_simpl_goal solve_goal unsolved_sidecond_hook print_sidecondition_goal print_remaining_shelved_goal');
 const types=words('Prop SProp Type Set Z nat N bool unit list option prod sum val int tint tvoid tptr tarray mpred funspec funspecs varspecs compspecs tycontext statement function iProp gmap loc i32 u32');
 const specs=words('DECLARE WITH PRE POST PROP PARAMS SEP LOCAL RETURN EX');
 const builtins=words('True False true false Some None nil cons O S eq eq_refl emp nullval data_at typed_function semax semax_body Vint Int min_int max_int int own array optionalO at_type');
 const isaKeywords=words('theory imports begin end context locale interpretation sublocale definition abbreviation primrec fun function inductive inductive_set datatype record typedef type_synonym lemma theorem corollary proposition assumes shows fixes obtains and where for if proof qed by apply done using unfolding have show then thus hence from with also finally moreover ultimately next fix assume let note obtain case subgoal premises supply include includes declare lemmas named_theorems ML method_setup setup install_C_file autocorres thm');
 const isaMethods=words('simp simp_all auto force fastforce blast fast clarify clarsimp rule erule drule frule intro intros elim cases induction induct linarith presburger arith metis meson subst assumption fact solve runs_to_vcg runs_to_whileLoop_res runs_to_whileLoop_exn');
 const holWords=words('if then else let in case of SOME THE True False ALL EX All Ex undefined');
 const holTypes=words('int nat bool unit list set option word ptr lifted_globals');
 const attributes=words('parameters args requires returns ensures exists refined_by typedef field inv_vars constraints tactics lemmas import');
 const wordPattern=/^[\p{L}_][\p{L}\p{N}_']*(?:\.[\p{L}_][\p{L}\p{N}_']*)*/u;
 const numberPattern=/^(?:0[xX][\da-fA-F]+|0[bB][01]+|\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)[uUlLfF]*/;
 function scan(source,language='rocq',offset=0){
  const out=[];let i=0,previous='';
  const emit=(end,kind)=>{if(end>i)out.push({start:offset+i,end:offset+end,text:source.slice(i,end),kind,language});i=end;};
  const nestedComment=()=>{let j=i+2,depth=1;while(j<source.length&&depth){if(source.startsWith('(*',j)){depth++;j+=2;}else if(source.startsWith('*)',j)){depth--;j+=2;}else j++;}return j;};
  const stringEnd=quote=>{let j=i+1;while(j<source.length){if(source[j]===quote){if(language==='rocq'&&source[j+1]===quote){j+=2;continue;}return j+1;}if(source[j]==='\\'&&language!=='rocq')j+=2;else j++;}return source.length;};
  while(i<source.length){
   const rest=source.slice(i),ch=source[i];let m;
   if((m=/^\s+/.exec(rest))){emit(i+m[0].length,'');continue;}
   if((language==='rocq'||language==='isabelle'||language==='hol')&&source.startsWith('(*',i)){emit(nestedComment(),'comment');continue;}
   if(language==='c'&&source.startsWith('/*@',i)){
    let stop=source.indexOf('*/',i+3);if(stop<0)stop=source.length;
    emit(i+3,'annotation');out.push(...scan(source.slice(i,stop),'acsl',offset+i));i=stop;
    if(stop<source.length)emit(i+2,'annotation');continue;
   }
   if(language==='c'&&source.startsWith('/*',i)){let stop=source.indexOf('*/',i+2);emit(stop<0?source.length:stop+2,'comment');continue;}
   if(language==='c'&&source.startsWith('//@rc::',i)){
    let stop=source.indexOf('\n',i);emit(stop<0?source.length:stop,'annotation');continue;
   }
   if(language==='c'&&source.startsWith('//',i)){let stop=source.indexOf('\n',i);emit(stop<0?source.length:stop,'comment');continue;}
   if(language==='c'&&ch==='#'&&/^\s*$/.test(source.slice(source.lastIndexOf('\n',i-1)+1,i))){
    m=/^#\s*[a-zA-Z_]+/.exec(rest);if(m){emit(i+m[0].length,'preprocessor');continue;}
   }
   if((language==='isabelle'||language==='hol')&&(m=/^\\<[^>\s]+>/.exec(rest))){emit(i+m[0].length,'operator');continue;}
   if(language==='acsl'&&(m=/^\\[a-zA-Z_]+/.exec(rest))){emit(i+m[0].length,'builtin');continue;}
   if(ch==='"'||(language==='c'&&ch==="'"&&/^'(?:\\.|[^'\n])'/.test(rest))){
    const end=stringEnd(ch),inside=source.slice(i+1,end-1);
    const attributeString=language==='c'&&/\[\[rc::[^\]]*$/.test(source.slice(0,i));
    const logicalString=language==='isabelle'&&(/\\<|\s|[=∀∃λ]/.test(inside))&&!/\.(?:c|thy)$/.test(inside);
    if(ch==='"'&&(attributeString||logicalString)){
     emit(i+1,'string');out.push(...scan(source.slice(i,end-1),attributeString?'rocq':'hol',offset+i));i=end-1;emit(end,'string');
    }else emit(end,'string');
    continue;
   }
   if(language==='rocq'&&(m=/^(?:\d+ goals?(?: \(ID \d+\))?|goal \d+ \(ID \d+\) is:|No more goals\.|={4,})/.exec(rest))){emit(i+m[0].length,'goal');continue;}
   if((m=numberPattern.exec(rest))){emit(i+m[0].length,'number');continue;}
   if((m=wordPattern.exec(rest))){
    const word=m[0],tail=source.slice(i+word.length);let kind='';
    if(language==='c'){
     if(cKeywords.has(word))kind='keyword';else if(cTypes.has(word))kind='type';
     else if(word==='rc'||attributes.has(word)&&/rc::$/.test(source.slice(0,i)))kind='annotation';
     else if(/^[A-Z][A-Z_\d]+$/.test(word))kind='constant';else if(/^\s*\(/.test(tail))kind='function';
    }else if(language==='acsl'){
     if(acsl.has(word))kind='annotation';else if(/^[A-Z][A-Z_\d]+$/.test(word))kind='constant';else if(/^\s*\(/.test(tail))kind='function';
    }else if(language==='isabelle'||language==='hol'){
     if(isaKeywords.has(word)||holWords.has(word))kind='keyword';else if(isaMethods.has(word))kind='tactic';else if(holTypes.has(word))kind='type';
     else if(['lemma','theorem','definition','primrec','fun','theory'].includes(previous))kind='function';else if(/^[A-Z][A-Z_\d]+$/.test(word))kind='constant';
    }else{
     if(types.has(word))kind='type';else if(specs.has(word))kind='annotation';else if(tactics.has(word))kind='tactic';
     else if(rocqKeywords.has(word))kind='keyword';else if(builtins.has(word))kind='builtin';
     else if(['Definition','Fixpoint','Lemma','Theorem','Corollary','Instance','Ltac'].includes(previous)||word.includes('.'))kind='function';
    }
    previous=word;emit(i+word.length,kind);continue;
   }
   if((m=/^(?:<==>|==>|<->|->|<-|:=|::|=>|<=|>=|==|!=|<>|\/\\|\\\/|\|--|&&|\|\||\+\+|--|[+*=<>!~^%&|\/\\:−→←↔⇒∀∃λ⊢⌜⌝∗◁≤≥≠∈∅]+)/.exec(rest))){
    const escape=(language==='isabelle'||language==='hol')?m[0].indexOf('\\<'):-1;
    emit(i+(escape>0?escape:m[0].length),'operator');continue;
   }
   if(ch==='-'&&(language==='rocq'||language==='isabelle')){emit(i+1,'operator');continue;}
   if(/[()[\]{},;.]/.test(ch)){emit(i+1,'punctuation');continue;}
   emit(i+1,'');
  }
  return out;
 }
 function fragment(tokens,start=0,end=Infinity){
  const result=document.createDocumentFragment();
  for(const token of tokens){if(token.end<=start)continue;if(token.start>=end)break;
   const raw=token.text.slice(Math.max(start-token.start,0),Math.min(end-token.start,token.text.length));
   const text=display(raw,token.language);
   if(token.kind){const span=document.createElement('span');span.className='tok-'+token.kind;span.textContent=text;result.append(span);}
   else result.append(document.createTextNode(text));
  }
  return result;
 }
 function render(element,source,language){element.replaceChildren(fragment(scan(source,language)));}
 function lineNumbers(pre,source){
  pre.querySelector('.line-gutter')?.remove();
  pre.classList.add('numbered-source');
  const gutter=document.createElement('span');gutter.className='line-gutter';gutter.setAttribute('aria-hidden','true');
  const count=source.split('\n').length-(source.endsWith('\n')?1:0);
  gutter.dataset.lines=Array.from({length:count},(_,i)=>i+1).join('\n');
  pre.style.setProperty('--gutter-width',Math.max(3,String(count).length)+2+'ch');
  pre.prepend(gutter);
 }
 return {scan,fragment,render,display,lineNumbers};
})();
document.querySelectorAll('[data-language]').forEach(element=>{
 const source=element.textContent,language=element.dataset.language;
 LabSyntax.render(element,source,language);
 if(['rocq','isabelle'].includes(language)&&element.closest('pre'))LabSyntax.lineNumbers(element.closest('pre'),source);
});
