UPRNU ;Library functionset for UPRN matching [ 03/19/2019  3:02 PM ]
 ;
ISSTRNO(adstreet) 
 if adstreet?1n.n1" "1l1" "
 if adstreet?1n.n1" "1l1" ".l.e q 3
 if adstreet?1n.n1" "1l.e q 2
 if adstreet?1n.n1l1" "1l.e q 2
 if adstreet?1n.n1"-"1n.n1" ".l.e q 2
 if adstreet?1n.n.l1"-"1n.n.l1" ".l.e q 2
 if adstreet?1n.n1" "1n.n1" ".e q 3
 q 0
 
Mflat(flat,adflat,levensh)   ;
 n leftover,matched
 set matched=0
 if $p(flat," ",1,$l(adflat," "))=adflat d
 .set leftover=$p(flat,adflat_" ",2)
 .if levensh>1,((leftover?1n)!(leftover?1l)) d
 ..S SUBFLATI=1
 ..set matched=1
 if $p(adflat," ",1,$l(flat," "))=flat d
 .set leftover=$p(adflat,flat_" ",2)
 .if levensh>1,((leftover?1n)!(leftover?1l)) d
 ..S SUBFLATD=1
 ..set matched=1
 S flat=$$flat(flat)
 set adflat=$$flat(adflat)
 if flat=adflat q 1
 I adflat?1n.n,flat?1n.n i (adflat*1)=(flat*1) q 1
 if levensh>1 d
 .if flat*1=($P(adflat," ")*1) d
 ..set SUFFIGNORE=1
 ..set matched=1
 .if adflat*1=($p(flat," ")*1) d
 ..S SUFFDROP=1
 ..set matched=1
 q matched
getno(paos,paosf,paoe,paoef) ;
 ;REturnset street number or range
 n numb
 set numb=""
 if paos'="" d
 .set numb=paos_paosf
 .if paoe'="" d
 ..set numb=numb_"-"_paoe_paoef
 q numb
getflat(saos,saosf,saoe,saoef,saot)    ;
 ;Returnset flat number or range
 n flat
 set flat=""
 if saot'="" do  q flat
 .set flat=saot
 .if saos'="" d
 ..set flat=flat_" "_(saos_saosf)
 ..if saoe'="" d
 ...set flat=flat_"-"_(saoe_saoef)
 if saos'="" do  q flat
 .set flat=(saos_saosf)
 .if saoe'="" d
 ..set flat=flat_"-"_saoe_saoef
 q flat
SOUNDPOS(post,adbno,adstreet)         ;
 K ^TUPRN
 k postlist
 n postlist
 set postlist(post)=""
 set npost=""
 set index=adbno_"~"_$$SOUNDEX(adstreet)
 for  set npost=$O(^UPRN("SIND",index,npost)) q:npost=""  d
 .if $D(postlist(npost)) q
 .if $e(npost,1,3)=$e(post,1,3) D  q
 ..set postlist(npost)=""
 ..D GETUPRNS(npost,1)
 .if $$LEVENSH^UPRNU(post,npost,6) d
 ..set postlist(npost)=""
 ..do GETUPRNS(npost,1)
 Q
LPIIND(adbuild,adbno,adstreet)         ;
 n index,house
 set index=adbuild_" "_adbno_" "_adstreet
 set uprn=""
 for  set uprn=$O(^UPRN("LPIND",index,uprn)) q:uprn=""  d
 .D SETAPB(uprn,1)
 set index=adbno_" "_adstreet
 set house=""
 for  set house=$O(^UPRN("LPINDB",index,house)) q:house=""  d
 .I $$MPART(house,adbuild,1) D
 ..set uprn=""
 ..for  set uprn=$O(^UPRN("LPINDB",index,house,uprn)) q:uprn=""  d
 ...do SETAPB(uprn,1)
 q
STREQUIV(post,adno,adstreet,adflat,adbuild)  ;
 n postlist
 set postlist(post)=""
 n altstr
 if adbno'="",adstreet'="" d
 .set altstr=""
 .for  set altstr=$O(^UPRN("STREQUIV",adstreet,altstr)) q:altstr=""  d
 ..f ad=1:1:$l(adbno,"-") d
 ...set sub=$p(adbno,"-",ad)
 ...I '$D(^UPRN("STRX",sub_"~"_altstr,post)) q
 ...do GETIND(sub_"~"_altstr)
 if adflat'="",adbuild'="" d
 .set altstr=""
 .for  set altstr=$O(^UPRN("STREQUIV",adbuild,altstr)) q:altstr=""  d
 ..i '$D(^UPRN("STRX",adflat_"~"_altstr,post)) q
 ..do GETIND(adflat_"~"_altstr)
 q
 
 q
        
GETPOST(uprn)       ;
 ;
 n mkey,mrec
 set mkey=$O(^UPRN("DPA",uprn,""))
 if mkey="" q ""
 set mrec=^UPRN("DPA",uprn,mkey)
 q $p(mrec,"~",9)
 ;
ADDPA(uprn,key,address)    ;
 ;
 s rec=^UPRN("DPA",uprn,key)
 s flat=$p(rec,"~",1)
 s build=$p(rec,"~",2)
 s number=$p(rec,"~",3)
 s depth=$p(rec,"~",4)
 s street=$p(rec,"~",5)
 s deploc=$p(rec,"~",6)
 s loc=$p(rec,"~",7)
 s town=$p(rec,"~",8)
 s post=$p(rec,"~",9)
 s org=$p(rec,"~",10)
 d GETDPA(flat,build,number,depth,street,deploc,loc,town,post,org,.address)
 q
GETDPA(flat,build,number,depth,street,deploc,loc,town,post,org,apaddres) 
 ;Returnset DPA details
 set apaddress("flat")=flat
 set apaddress("building")=build
 set apaddress("number")=number
 set apaddress("depth")=depth
 set apaddress("street")=street
 set apaddress("deploc")=deploc
 set apaddress("locality")=loc
 set apaddress("town")=town
 set apaddress("postcode")=post
 set apaddress("org")=org
 set apaddress=apaddress("flat")_" "_apaddress("building")_","_apaddress("number")_" "_" "_apaddress("depth")_" "_apaddress("street")_","_apaddress("deploc")_" "_apaddress("locality")_","_post
 set apaddress=$$tr^UPRNL(apaddress,"  "," ")
 q
GETADR(uprn,table,key,flat,build,bno,depth,street,deploc,loc,town,post,org)       ;
 ;Returns address variables from UPRN record
 n rec
 s rec=^UPRN("U",uprn,table,key)
 s flat=$p(rec,"~",1)
 s build=$p(rec,"~",2)
 s bno=$p(rec,"~",3)
 s depth=$p(rec,"~",4)
 s street=$p(rec,"~",5)
 s deploc=$p(rec,"~",6)
 s loc=$p(rec,"~",7)
 s town=$p(rec,"~",8)
 s post=$p(rec,"~",9)
 s org=$p(rec,"~",10)
 q
ADLPI(uprn,key,address) 
 n rec
 s rec=^UPRN("LPI",uprn,key)
 s saos=$p(rec,"~",1)
 s saosf=$p(rec,"~",2)
 s saoe=$p(rec,"~",3)
 s saoef=$p(rec,"~",4)
 s saot=$p(rec,"~",5)
 s paos=$p(rec,"~",6)
 s paosf=$p(rec,"~",7)
 s paoe=$p(rec,"~",8)
 s paoef=$p(rec,"~",9)
 s paot=$p(rec,"~",10)
 s lpstr=$p(rec,"~",11)
 D GETLPI(saos,saosf,saoe,saoef,saot,paos,paosf,paoe,paoef,paot,lpstr,uprn,.address)
 q
 
GETLPI(saos,saosf,saoe,saoef,saot,paos,paosf,paoe,paoef,paot,lpstr,uprn,apaddress) ;
 ;Returns LPI fields in address object
 k apaddress
 S lpdes="",lploc="",lptown=""
 if lpstr'="" d
 .I $D(^UPRN("LPSTR",lpstr)) d
 ..set lpdes=$p(^UPRN("LPSTR",lpstr),"~")
 ..set lploc=$p(^UPRN("LPSTR",lpstr),"~",2)
 ..set lptown=$p(^UPRN("LPSTR",lpstr),"~",3)
 .S lpdes=$tr(lpdes,"'.,")
 set apaddress("flat")=$$getflat(saos,saosf,saoe,saoef,saot)
 set apaddress("building")=paot
 set apaddress("number")=$$getno(paos,paosf,paoe,paoef)
 set apaddress("depth")=""
 set post=$p(^UPRN("U",uprn),"~",2)
 set apaddress("street")=lpdes
 set apaddress("deploc")=""
 set apaddress("locality")=lploc
 set apaddress("town")=lptown
 set apaddress("postcode")=post
 set apaddress=apaddress("flat")_" "_apaddress("building")_","_apaddress("number")_" "_apaddress("street")_","_apaddress("locality")_","_post
 q
 ;
stripr(text)    ;
 n i,word
 f i=1:1:$l(text," ") d
 .s word=$p(text," ",i)
 .q:word=""
 .I $D(^UPRNS("ROAD",word)) d
 ..s text=$p(text," ",1,i-1)
 q text
roadmiss(test,tomatch) 
 n matched
 s matched=0
 i $l(tomatch," ")<2 q 0
 i tomatch="" q 0
 i $D(^UPRNS("ROAD",$p(tomatch," ",$l(tomatch," ")))) d
 .i $p(tomatch," ",1,$l(tomatch," ")-1)=test s matched=1
 q matched
contains(depth,street,tstreet) 
 i depth=""!(street="")!(tstreet="") q 0
 ;Can discovery street contain both street and depth
 i tstreet[depth,tstreet[street q 1
 q 0
fuzflat(test,tomatch)        ;Tests a fuzzy flat
 i test=tomatch q 1
 i (" "_tomatch_" ")[(" "_test_" ") q 1
 i (" "_test_" ")[(" "_tomatch_" ") q 1
 q 0
mcount(test,tomatch) 
 i test="",tomatch="" q 1
 n i,count
 s count=0
 f i=1:1:$l(test," ") d
 .i $p(test," ",i)=$p(tomatch," ",i) s count=count+1
 q count
partial(test,tomatch)        ;Partial multiword
 n matched
 s matched=0
 d swap(.test,.tmatch)
 d drop(.test,.tomatch)
 i $l(test," ")>1 d
 .i $l(tomatch," ")>$l(test," ") d
 ..i $p(tomatch," ",1,$l(test," "))=test d
 ...s matched=1
 Q matched
approx(test,tomatch)         ;goes for a very approximatr match
 i $l(test," ")'=$l(tomatch," ") q 0
 n i,count,matched
 s count=0,matched=0
 f i=1:1:$l(test," ") d
 .i $p(test," ",i)=$p(tomatch," ",i) s count=count+1
 i 'count q 0
 i $l(test," ")/count<2 q 0
 f i=1:1:$l(test," ") d
 .i $e($p(test," ",i),1,3)=$e($p(tomatch," ",i),1,3) d
 ..s matched=1
 q matched
 
equiv(test,tomatch,min,force)          ;Swaps drops and levenshtein
 i $D(^UPRNW("SFIX",tomatch,test)) q 1
 N otest,otomatch
 s otest=test,otomatch=tomatch
 i $tr(test," ")=$tr(tomatch," ") q 1
 d swap(.test,.tomatch)
 d drop(.test,.tomatch)
 d welsh(.test,.tomatch)
 set test=$$dupl(test)
 set tomatch=$$dupl(tomatch)
 set test=$$tr^UPRNL(test,"ei","ie")
 set tomatch=$$tr^UPRNL(tomatch,"ei","ie")
 i $tr(test," ")=$tr(tomatch," ") q 1
 i $e(test)?1n,$e(tomatch)?1l q 0
 i $e(tomatch)?1n,$e(test)?1l q 0
 i $$levensh($tr(test," "),$tr(tomatch," "),$g(min,10),$g(force)) q 1
 s test=otest,tomatch=otomatch
 i test'["ow" q 0
 S test=$$tr^UPRNL(test,"ow","a")
 i $$levensh($tr(test," "),$tr(tomatch," "),$g(min,10),$g(force)) q 1
 q 0
 
welsh(test,tomatch)          ;Converts welsh language
 I test["clos ",tomatch[" close" d
 .s test=$tr($p(test," ",2,10)," ")
 .s tomatch=$tr($p(tomatch," ",1,$l(tomatch," ")-1)," ")
 Q
 
levensh(s,t,min,force) 
 ;Levenshtein distance algorithm
 ;s and t are the two terms
 ;mininum is the minimum length acceptable for a match if less than 10
 ;force is when you want to force a minimum distance less than defaults
 
 
 n matched,d,m,n,result,i,j,result
 set matched=0
 s s=$e(s,1,20)
 s t=$e(t,1,20)
 n dif,m,n,from,to
 set m=$l(s)
 set n=$l(t)
 set min=$g(min,4)
 if m<min D  q matched
 .if s=t set matched=1
 f i=0:1:m d
 .f j=0:1:n d
 ..set d(i,j)=0
 f i=1:1:m set d(i,0)=i
 f j=1:1:n set d(0,j)=j
 F j=1:1:n d
 .f i=1:1:m d
 ..if $e(s,i)=$e(t,j) set cost=0
 ..e  set cost=1
 ..set d(i,j)=$$min(d(i-1,j)+1,d(i,j-1)+1,d(i-1,j-1)+cost)
 set result=d(m,n)
 I result=0 q 1
 if $g(force),result>force q 0
 if $g(force),result'>force q 1
 if result=1 Q 1
 if result=2 do  q matched
 .I m<10 s matched=0 q
 .I m<min s matched=0 q
 .s matched=result q
 if result=3,m>9 Q 1
 Q 0
OK ;
 set matched=1
 Q
 
min(one,two,three)         ;
 n order
 set order(one)="",order(two)="",order(three)=""
 q $o(order(""))
 ;
soundex(phrase)    ;
 n new,soundex,i,char,lchar,digit,ldigit,hw
 set phrase=$TR(phrase," ")
 set soundex=$e(phrase)
 set new="",lchar=""
 set ldigit=0,hw=""
 f i=1:1:$l(phrase) d
 .set char=$e(phrase,i)
 .if "aeiouyhw"[char set hw=char q
 .set digit=$s("bfpv"[char:1,"cgjkqsxz"[char:2,"dt"[char:3,"l"[char:4,"mn"[char:5,"r"[char:6,1:"")
 .if digit=ldigit,(hw="h")!(hw="w") q
 .if digit=ldigit,hw="" q
 .set soundex=soundex_digit
 .set hw="",ldigit=digit
 q $e(soundex_"00",1,4)
correct(text,tomatch)      ;
 n word,i
 f i=1:1:$l(text," ") d
 .set word=$p(text," ",i)
 .q:word=""
 .I $D(^UPRNS("CORRECT",word)) d
 ..Q:$D(^UPRNS("CORRECT",word,"Except",i))
 ..if $g(tomatch)'="" if (" "_tomatch_" ")[(" "_word_" ") d
 ...set $p(text," ",i)=^UPRNS("CORRECT",word)
 ..e  d
 ...set $p(text," ",i)=^UPRNS("CORRECT",word)
 q text
swap(text,tomatch)         ;Swaps a word in text
 n word,swapto,swapped
 set word="",swapped=0
 for  set word=$O(^UPRNS("SWAP",word)) q:word=""  d
 .if (" "_text_" ")[(" "_word_" ") d
 ..set swapto=^UPRNS("SWAP",word)
 ..set text=$p(text,word,1)_swapto_$p(text,word,2,20)
 .I $G(tomatch)="" q
 .if (" "_tomatch_" ")[(" "_word_" ") d
 ..set swapto=^UPRNS("SWAP",word)
 ..set tomatch=$p(tomatch,word,1)_swapto_$p(tomatch,word,2,20)
 q
 
 ;
SETSWAPS ;
 
 K ^UPRNS("ROAD")
 K ^UPRNS("CITY")
 K ^UPRNS("CORRECT")
 K ^UPRNS("DROP")
 K ^UPRNS("SWAP")
 K ^UPRNS("FLOOR")
 S ^UPRNS("FLOOR","basement","a")=""
 S ^UPRNS("FLOOR","ground floor","a")=""
 S ^UPRNS("FLOOR","first floor","b")=""
 S ^UPRNS("FLOOR","basement",0)=""
 S ^UPRNS("FLOOR","ground floor",1)=""
 S ^UPRNS("FLOOR","first floor",2)=""
 S ^UPRNS("FLOOR","second floor",3)=""
 S ^UPRNS("FLOOR","third floor",4)=""
 s ^UPRNS("FLOOR","1st",2)=""
 s ^UPRNS("FLOOR","2nd",3)=""
 s ^UPRNS("FLOOR","3rd",4)=""
 s ^UPRNS("FLOOR","6th",7)=""
 S ^UPRNS("FLOOR","4th",5)=""
 S ^UPRNS("FLOOR","5th",6)=""
 S ^UPRNS("FLOORNUM",1)="ground"
 S ^UPRNS("FLOORNUM",2)="first"
 S ^UPRNS("FLOORNUM",3)="Second"
 S ^UPRNS("FLOORNUM",0)="basement"
 S ^UPRNS("FLOORCHAR","a")="ground"
 S ^UPRNS("FLOORCHAR","b")="first"
 S ^UPRNS("FLOORCHAR","c")="Second"
 S ^UPRNS("FLOORCHAR","d")="third"
 S ^UPRNS("FLOORCHAR",$c(96))="basement"
 S ^UPRNS("CITY","london")=""
 set ^UPRNS("CORRECT","1st")="first"
 set ^UPRNS("CORRECT","bst")="basement"
 set ^UPRNS("CORRECT","2nd")="second"
 set ^UPRNS("CORRECT","3rd")="third"
 set ^UPRNS("CORRECT","6th")="sixth"
 S ^UPRNS("CORRECT","4th")="fourth"
 S ^UPRNS("CORRECT","5th")="fifth"
 set ^UPRNS("CORRECT","base")="basement"
 S ^UPRNS("CORRECT","almhouse")="almshouse"
 S ^UPRNS("CORRECT","bldg")="building"
 S ^UPRNS("CORRECT","bldgs")="buildings"
 S ^UPRNS("CORRECT","cosmopolitian")="cosmopolitan"
 S ^UPRNS("CORRECT","est")="estate"
 S ^UPRNS("CORRECT","crt")="court"
 S ^UPRNS("CORRECT","falt")="flat"
 S ^UPRNS("CORRECT","cres")="crescent"
 S ^UPRNS("CORRECT","flst")="flat"
 S ^UPRNS("CORRECT","fat")="flat"
 S ^UPRNS("CORRECT","fla")="flat"
 S ^UPRNS("CORRECT","fla1")="flat"
 S ^UPRNS("CORRECT","flalt")="flat"
 S ^UPRNS("CORRECT","flar")="flat"
 S ^UPRNS("CORRECT","flart")="flat"
 S ^UPRNS("CORRECT","flast")="flat"
 S ^UPRNS("CORRECT","hospit")="hospital"
 S ^UPRNS("CORRECT","rd")="road"
 S ^UPRNS("CORRECT","ci")="city"
 S ^UPRNS("CORRECT","apart")="apartment"
 S ^UPRNS("CORRECT","raod")="road"
 S ^UPRNS("SWAP","house")="building"
 S ^UPRNS("SWAP","johnson")="jonson"
 S ^UPRNS("SWAP","road")="street"
 S ^UPRNS("SWAP","apartments")="building"
 S ^UPRNS("SWAP","apartment")="building"
 S ^UPRNS("SWAP","nursing")="care"
 S ^UPRNS("SWAP","upstairs")="first"
 S ^UPRNS("SWAP","upper")="first"
 
 S ^UPRNS("CORRECT","cresent")="crescent"
 S ^UPRNS("CORRECT","sttreet")="street"
 S ^UPRNS("CORRECT","st")="street"
 S ^UPRNS("CORRECT","st","Except",1)=""
 S ^UPRNS("CORRECT","hse")="house"
 S ^UPRNS("CORRECT","apt")="apartment"
 S ^UPRNS("CORRECT","ave")="avenue"
 S ^UPRNS("FLAT","flat")=""
 S ^UPRNS("FLAT","flats")=""
 S ^UPRNS("FLAT","flt")=""
 S ^UPRNS("FLAT","unit")=""
 S ^UPRNS("FLAT","room")=""
 S ^UPRNS("FLAT","apartment")=""
 S ^UPRNS("FLAT","apt")=""
 S ^UPRNS("FLAT","tower")=""
 S ^UPRNS("FLAT","falt")=""
 S ^UPRNS("FLAT","workshop")=""
 S ^UPRNS("DROP","lane ")=""
 S ^UPRNS("DROP","the ")=""
 S ^UPRNS("DROP","basement ")=""
 s ^UPRNS("DROP"," house")=""
 S ^UPRNS("CORRECT","acenue")="avenue"
 f text="road","street","avenue","court","square","drive","way" d
 .S ^UPRNS("ROAD",text)=""
 f text="lane","grove","row","close","walk","causeway","park","place" d
 .S ^UPRNS("ROAD",text)=""
 f text="lanes","hill","plaza","green","rise","rd" d
 .S ^UPRNS("ROAD",text)=""
 S ^UPRNS("NUMBERS","one")=1
 S ^UPRNS("NUMBERS","two")=2
 S ^UPRNS("NUMBERS","three")=3
 f text="house","place" d
 .s ^UPRNS("BUILDING",text)=""
 f text="court","close","mews" d
 .S ^UPRNS("COURT",text)=""
 s ^UPRNS("COUNTY","middlesex")=""
 S ^UPRNS("TOWN","neasden")=""
 S ^UPRNS("TOWN","wembley")=""
 S ^UPRNS("TOWN","harlesden")=""
 q
drop(text,tomatch) ;Dropset a first or middle word
 n word
 set word=""
 for  set word=$O(^UPRNS("DROP",word)) q:word=""  d
 .if text[word d
 ..set text=$p(text,word,1)_$p(text,word,2,20)
 .if tomatch[word d
 ..set tomatch=$p(tomatch,word,1)_$p(tomatch,word,2,20)
 q
 
flat(text) 
 n word
 I text="flat" q ""
 set word=""
 i text?1"flat"1n.n q $p(text,"flat",2,10)
 for  set word=$O(^UPRNS("FLAT",word)) q:word=""  d
 .if text[(word_" ") d
 ..set text=$p(text,word_" ",1)_$p(text,word_" ",2,20)
 for  q:($e(text)'="0")  s text=$e(text,2,50)
 q text
isflat(text) 
 n word,isflat
 set word="",isflat=0
 for  set word=$O(^UPRNS("FLAT",word)) q:word=""  do  q:isflat
 .if $p(text," ")=word set isflat=1
 q isflat
hasflat(text) 
 n word,hasflat
 set word="",hasflat=0
 for  set word=$O(^UPRNS("FLAT",word)) q:word=""  do  q:hasflat
 .if (" "_text_" ")[(" "_word_" ") set hasflat=1
 q hasflat
FLOOR(text)        ;
 if text["floor " q $p(text,"floor ",2)
 q text
PLURAL(text)       ;Removeset plurals
 n i,word
 f i=1:1:$l(text," ") d
 .set word=$p(text," ",i)
 .if $e(word,$l(word))="s" d
 ..set word=$e(word,1,$l(word)-1)
 ..set $p(text," ",i)=word
 ..S PLURAL=1
 q text
getfront(text,tomatch,front,back)          ;Phrase contains phrase
 ;front is the front part of the phrase
 s front=""
 i tomatch[(" "_text) d  q 1
 .s front=$p(tomatch," "_text,1)
 .s back=$p(tomatch," "_text,2)
 q 0
getback(text,tomatch,back)          ;Phrase contains phrase
 ;front is the front part of the phrase
 i text="" q 0
 I $e(text,1,$l(tomatch))=tomatch d  q 1
 .S back=$$lt^UPRNL($p(text,tomatch,2,5))
 I $E(tomatch,1,$l(text))=text d  q 1
 .s back=$$lt^UPRNL($p(tomatch,text,2,5))
 q 0
MPART(test,tomatch,mincount)         ;
 ;One word match only
 n matched,stest,stomatch
 s stest=$tr(test," ")
 s stomatch=$tr(tomatch," ")
 i $l(stest)>6 i $e(stomatch,1,$l(stest))=stest q 1
 i $l(stomatch)>6 i $e(stest,1,$l(stomatch))=stomatch q 1
 i $l(test," ")-$l(tomatch," ")>5 q 0
 d swap(.test,.tomatch)
 d drop(.test,.tomatch)
 set test=$$dupl(test)
 set tomatch=$$dupl(tomatch)
 set test=$$tr^UPRNL(test,"ei","ie")
 set tomatch=$$tr^UPRNL(tomatch,"ei","ie")
 set matched=0
 n i,j,ltest,lto,from,to,count,maxlen
 set ltest=$l(test," ")
 set lto=$l(tomatch," ")
 set from=$s(lto>ltest:"test",1:"tomatch")
 set to=$s(from="test":"tomatch",1:"test")
 set maxlen=$l(@to," ")
 set mincount=$g(mincount,maxlen-1)
 set count=0
 f i=1:1:$l(@from," ") d
 .set word=$p(@from," ",i)
 .I word'="" I $D(^UPRNS("ROAD",word))!($D(^UPRNS("BUILDING",word))) q
 .f j=i:1:$l(@to," ") d
 ..set tword=$p(@to," ",j)
 ..i tword'="",$D(^UPRNS("ROAD",tword))!($d(^UPRNS("BUILDING",word))) q
 ..I $$levensh(word,tword) d
 ...set count=count+1
 I count'<mincount q 1
 q matched
plural(text)       ;
 ;Function to remove trailing s
 f i=1:1:$l(text," ") d
 .set word=$p(text," ",i)
 .q:word=""
 .if $e(word,$l(word))="s" d
 ..set word=$e(word,1,$l(word)-1)
 ..set $p(text," ",i)=word
 q text
dupl(text)         ;Removes duplicate
 n wordlist
 n word
 n i
 f i=1:1:$l(text," ") d
 .set word=$p(text," ",i)
 .q:word=""
 .if $e(word,$l(word))="s" d
 ..set word=$e(word,1,$l(word)-1)
 ..set $p(text," ",i)=word
 .if $d(wordlist(word)) do  q
 ..set text=$p(text," ",1,i-1)_" "_$p(text," ",i+1,20)
 .set wordlist(word)=""
 q text
MFRONT(test,tomatch,count,leftover) ;
 ;Matcheset the fist part of a phrase
 N matched,done
 n ltest,ltomatch,from,to,i,word,word1,mcount
 set matched=0,done=0
 set ltest=$L(test," "),ltomatch=$l(tomatch," ")
 set from=$s(ltest>ltomatch:"tomatch",1:"test")
 set to=$s(from="tomatch":"test",1:"tomatch")
 I $l(@from," ")<count q 0
 set mcount=0
 F i=1:1:$l(@from," ") do  Q:done
 .set word=$p(@from," ",i)
 .set word1=$p(@to," ",i)
 .if $$LEVENSH^UPRNU(word,word1) do  q
 ..set mcount=mcount+1
 .set done=1
 if mcount<count q 0
 set leftover=$p(@to," ",mcount+1,20)
 q 1
 ;
