UPRN5 ;Command line Main routine for processing a batch of addresseset [ 06/10/2019   8:22 AM ]
 w !,"From address ("_^ADNO_") :" r adno
 I adno="" s adno=^ADNO
 s ui=2
setarea1 ;d batch("D","e,ec,cr,da,ha,ig,kt,n,se,sw,w,nw,rm,sl,sm,wc",from,to,0)
setarea d batch("Unmatched","",adno,10000000000,ui)
 q
 
 
 ;
batch(mkey,qpost,from,to,ui)   ;Processes a batch of addresses for a list of areas
 ;mkey is the node for the address list
 n adno
 ;qpost is the , delimited list of addresses
 ;
 n total
 s xh=$p($H,",",2)
 ;lower case the post code filter
 set qpost=$$lc^UPRNL(qpost)
 
 ;Initiate the spelling swap  and corrections
 d SETSWAPS^UPRNU
 ;Loop through the table of addresses, 
 
 ;Set File delimiter
 set d="~"
   
 ;Initiate the counts
 
 set adno=^ADNO-1
 set total=0
 for  set adno=$O(^UPRN("Stats",mkey,adno)) q:adno=""  q:adno>to  d
U .i $D(^UPRN("Stats","UnmatchedMissingPost",adno)) s skip=1 q
U1 .i $D(^UPRN("Stats","OutOfArea",adno)) s skip=1 q
 .S ^ADNO=adno
 .set adrec=^UPRN("D",adno)
 .d adrqual(adno,adrec)
 .s orgpost=$tr($$lc^UPRNL($p($g(^UPRN("D",adno,"P")),"~",1)),"""")
 .d matchone(adrec,qpost,orgpost,ui)
 ;
 q
adrqual(adno,rec)         ;
 n missing,nopost,invadr,invpost
 s (missing,nopost,invadr,invpost)=0
 I $tr(rec,"~")="" d
 .s missing=1
 i $l($tr(rec,"~"))<9 d
 .s invadr=1
 set rec=$tr(rec,"}{","")
 set length=$length(rec,d)
 set post=$$lc^UPRNL($p(rec,"~",length))
 set post=$tr(post," ") ;Remove spaces
 i post="" s nopost=1
 i '$$validp(post) s invpost=1 
 S ^UPRN("Q",adno)=missing_"~"_invadr_"~"_nopost_"~"_invpost
 q
validp(post)       ;
 s post=$$lc^UPRNL(post)
 i post?2l1n1l1n2l q 1
 i post?1l1n1l1n2l q 1
 i post?1l2n2l q 1
 i post?1l3n2l q 1
 i post?2l2n2l q 1
 i post?2l3n2l q 1
 q 0
 
matchone(adrec,qpost,orgpost,ui)    ;matches one address
 set adrec=$tr(adrec,"}{""","")
 
 set length=$length(adrec,d)
 set post=$$lc^UPRNL($p(adrec,d,length))
 set post=$tr(post," ") ;Remove spaces
 
 ;If post code null increment nopost 
 i post="" d
 .i orgpost'="" d
 ..s post=$$area(orgpost)
 ..s $p(adrec,d,length)=post
 
 ;OutOfArea
 i '$$inpost(post,qpost) d  q
 
 
 d format^UPRNA(adrec,.address)
 ;
 ;format the address record
 set adflat=address("flat")
 set adbuild=address("building")
 set adbno=address("number")
 set adstreet=address("street")
 set adloc=address("locality")
 set adpost=address("postcode")
 set adepth=address("depth")
 set adeploc=address("deploc")
 set adpstreet=$$plural^UPRNU(adstreet)
 set adpbuild=$$plural^UPRNU(adbuild)
 set adflatbl=$$flat^UPRNU(adbuild_" ")
 set adplural=0
 i adpstreet'=adstreet s adplural=1
 if adpbuild'=adbuild s adplural=1
 set adb2=""
 set adf2=""
 i adbuild'="",adflat?1n.n1" "1l.l d
 .s adb2=$p(adflat," ",2,10)_" "_adbuild
 .s adf2=$p(adflat," ")
 
 s indrec=adpost_" "_adflat_" "_adbuild_" "_adbno_" "_adepth_" "_adstreet_" "_adeploc_" "_adloc
 for  q:(indrec'["  ")  s indrec=$$tr^UPRNL(indrec,"  "," ")
 s indrec=$$lt^UPRNL(indrec)
 i adplural d
 .s indprec=adpost_" "_adflat_" "_adpbuild_" "_adbno_" "_adepth_" "_adpstreet_" "_adeploc_" "_adloc
 .for  q:(indprec'["  ")  s indprec=$$tr^UPRNL(indprec,"  "," ")
 .s indprec=$$lt^UPRNL(indrec)
 
 k ^TUPRN
 
 
 
 ;clear down variables
 do clrvars
 
 ;Exact match all fields directly i.e. 1 candidate
 D match^UPRN(adflat,adbuild,adbno,adepth,adstreet,adeploc,adloc,adpost,adf2,adb2)
 i $D(^TUPRN($J)) d  q 
 .d matched
 i adbuild'="" d
 .D match^UPRN(adflat,"former "_adbuild,adbno,adepth,adstreet,adeploc,adloc,adpost,adf2,adb2)
 i $D(^TUPRN($J)) d  q 
 .d matched
 e  d  q
 .d nomatch
 q
 
 
 
nomatch ;Records no match
 if ui,ui<3 D
 .W !!!,"No match"
 .W !,adrec
 .;d ^EXP
 .w !,"Ignore (i):" r ignore
 .i $$lc^UPRNL(ignore)="i" d
 ..s ^UPRN1(adrec)=""
 q
 
matched ;
 n table,key
 I ^TUPRN>1 D filter
 
 I ui>1 D
 .w !!,"Matched"
 .w "  "_ALG
 .w !,adno
 .w !,address
 S uprn=""
 for  s uprn=$O(^TUPRN($J,uprn)) q:uprn=""  d
 .s table=""
 .for  s table=$O(^TUPRN($J,uprn,table)) q:table=""  d
 ..s key=""
 ..for  s key=$O(^TUPRN($J,uprn,table,key)) q:key=""  d
 ...s matchrec=^(key)
 ...I table="D",$p(matchrec,",",4)="Bd" d
 ....I adbuild'="" d
 .....i $P(^UPRN("U",uprn,table,key),"~",10)=adbuild d
 ......s $p(matchrec,",",4)="Be"
 ...S ^UPRN("M",adno,uprn,table,key)=matchrec
 ...S ^UPRN("M",adno,uprn,table,key,"A")=ALG
 ...I ui>1 D
 ....w !,uprn," ",table_": "_^UPRN("U",uprn,table,key)
 ....w ?65,matchrec
 ....i table="L" D
 .....w !,uprn," ","LPI : "_^UPRN("LPI",uprn,key)
 ....i table="D" d
 .....W !,uprn," ","DPA : "_^UPRN("DPA",uprn,key)
 .;I $G(^TUPRN($J))>1 D
 .W *7,!,"Multiple matches"
 .r t
 I ui>1 r t i t=0 s (ui)=0
 q
 
filter ;Filter
 n uprn,key,preferred,exact
 ;
 ;Tries to match on organisation
 ;Gets as many as possible with matches
 f i=0:1:4 d  q:(^TUPRN=1)
 .d fexact(i)
 i ^TUPRN=1 Q
 
 n current
 s current=""
 ;Gets nearest match
 n nearcount
 s nearest=""
 f i=1:1:4 d
 .s uprn="",key=""
 .for  s uprn=$O(^TUPRN($J,uprn)) q:uprn=""  d
 ..s table=""
 ..for  s table=$O(^TUPRN($J,uprn,table)) q:table=""  d
 ...s key=""
 ...for  s key=$O(^TUPRN($J,uprn,table,key)) q:key=""  d
 ....s matchrec=^(key)
 ....i $e($p(matchrec,",",i),2)="e" d
 .....s nearest=uprn_"~"_table_"~"_key
 .....i table="L" d
 ......I $P(^UPRN("LPI",uprn,key),"~",12)=1 d
 .......s current=uprn_"~"_table_"~"_key
 I current'="" d  q
 .s matchrec=^TUPRN($J,$p(current,"~"),$p(current,"~",2),$p(current,"~",3))
 .K ^TUPRN
 .s uprn=$p(current,"~"),table=$p(current,"~",2),key=$p(current,"~",3)
 .S ^TUPRN($J,uprn,table,key)=matchrec
 .S ^TUPRN=1
 
 i nearest'="" d
 .s matchrec=^TUPRN($J,$p(nearest,"~"),$p(nearest,"~",2),$p(nearest,"~",3))
 .K ^TUPRN
 .s uprn=$p(nearest,"~"),table=$p(nearest,"~",2),key=$p(nearest,"~",3)
 .S ^TUPRN($J,uprn,table,key)=matchrec
 .S ^TUPRN=1
 Q
 Q
fexact(mfield)     ;Filters out if possible
 n preferred
 s preferred=0
 s uprn="",key=""
 for  s uprn=$O(^TUPRN($J,uprn)) q:uprn=""  d
 .s table=""
 .for  s table=$O(^TUPRN($J,uprn,table)) q:table=""  d
 ..for  s key=$O(^TUPRN($J,uprn,table,key)) q:key=""  d
 ...s matchrec=^(key)
 ...I $p(matchrec,"~",5)="Fe" d
 ....i table="D" d
 .....s org=$p(^UPRN("U",uprn,table,key),"~",10)
 .....i org'="",org=adflat,$p(matchrec,"~",5)="Fe" d
 ......s $p(matchrec,",",5)="Fe"
 ......s ^TUPRN($J,uprn,table,key)=matchrec
 ...i mfield=0,matchrec="Pe,Se,Ne,Be,Fe" d
 ....s preferred=1
 ....s preferred(uprn,table,key)=""
 ...i mfield>0,$e($p(matchrec,"~",mfield),2)="e" do
 ....s preferred=1
 ....s preferred(uprn,table,key)=""
 i preferred do
 .s (uprn,key)=""
 .for  s uprn=$O(^TUPRN($J,uprn)) q:uprn=""  d
 ..for  s table=$O(^TUPRN($J,uprn,table)) q:table=""  d
 ...for  s key=$O(^TUPRN($J,uprn,table,key)) q:key=""  d
 ....i '$d(preferred(uprn,table,key)) d
 .....K ^TUPRN($J,uprn,table,key)
 .....I '$D(^TUPRN($J,uprn)) s ^TUPRN=^TUPRN-1
 q
 Q
 
 Q
 
ONE ;
 s adno=^ADNO
 s xadno=adno
 d batch("D","",adno,adno,2)
 s adno=xadno
 Q
 ;
 ;
clrvars ;Resetset the flags
 S WRONGPOST=""
 S SUFFIGNORE=""
 S FLATNC="",SUPRA=""
 S NUMSTREET=""
 s ALG=""
 s FIELDS=""
 
 S FLAT="",PLURAL="",DROP="",CORRECT=""
 S SWAP="",DUPL="",SUB="",SIMILAR="",PARTIAL=""
 S ANDLPI="",FIRSTPART="",LEVENOK="",SIBLING="",SUPRA=""
 S SUFFDROP="",SUBFLATI="",SUBFLATD=""
 Q
inpost(post,qpost) ;
 n in,i,q,area
 s in=0
 i post="" q 1
 s area=$$area(post)
 i qpost="" d  q in
 .i $D(^UPRN("AREAS",area)) s in=1
 i ","_qpost_","[(","_area_",") s in=1
 q in
area(post)         ;
 n area,done
 s area="",done=0
 f i=1:1:$l(post) d  q:done
 .i $e(post,i)?1n s done=1 q
 .s area=area_$e(post,i)
 q area
sector(post)       ;returns post code to sector level
 n i,sector
 s sector=""
 f i=$l(post):-1:0 d  q:(sector'="")
 .i $e(post,i)?1n s sector=$e(post,1,i)
 q sector
 
 
