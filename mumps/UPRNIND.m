UPRNIND ;Rebuilds all the UPRN indexes [ 11/15/2019  3:18 PM ]
 n
 S ^STATS("START")=$H
 s d="~"
 f i="",1:1:6 K ^UPRN("X"_i)
 F index="STR","BLD" K ^UPRN("X."_index)
 ;
 ;First the name uprn BLPU table
 D BLPU
 
 ;Removes parent child links
 D UPC
 
GO ;Next the post office DPA table
 D DPA
 
 ;Next the local authority LPI table
 D LPI
 S ^STATS("END")=$H
 Q
 
BLPU ;Index on BLPU record
 s i=1
 s d="~"
 s uprn=""
 for  s uprn=$O(^UPRN("U",uprn)) q:uprn=""  d
 .s rec=^(uprn)
 .s post=$p(rec,d,2)
 .S ^UPRN("X1",post,uprn)=""
 .;s i=i+1 i '(i#50000) w !,"BLPU ",uprn," ",i
 q
 
UPC ;Checks for any parent child links
 s i=1
 s d="~"
 ;Kills them if missing
 s (parent,child)=""
 for  s parent=$O(^UPRN("UPC",parent)) q:parent=""  d
 .i '$D(^UPRN("U",parent)) d  q
 ..K ^UPRN("UPC",parent)
 .for  s child=$O(^UPRN("UPC",parent,child)) q:child=""  d
 ..I '$D(^UPRN("U",child)) d
 ...K ^UPRN("UPC",parent,child)
 for  s child=$O(^UPRN("UCP",child)) q:child=""  d
 .I '$D(^UPRN("U",child)) d  q
 ..K ^UPRN("UCP",child)
 .for  s parent=$O(^UPRN("UCP",child,parent)) q:parent=""  d
 ..i '$D(^UPRN("U",parent)) d
 ...k ^UPRN("UCP",child,parent)
 .;s i=i+1 i '(i#10000) w !,"UPC ",parent," ",i
 q
 
DPA ;Index on DPA table
 s i=1
 s d="~"
 s table="D"
 s (uprn,key)=""
 for  s uprn=$O(^UPRN("DPA",uprn)) q:uprn=""  d
 .for  s key=$O(^UPRN("DPA",uprn,key)) q:key=""  d
 ..s rec=$g(^UPRN("U",uprn,"D",key))
 ..q:rec=""
 ..s flat=$p(rec,d,1)
 ..s build=$p(rec,d,2)
 ..s bno=$p(rec,d,3)
 ..s depth=$p(rec,d,4)
 ..s street=$p(rec,d,5)
 ..s deploc=$p(rec,d,6)
 ..s loc=$p(rec,d,7)
 ..s town=$p(rec,d,8)
 ..s post=$p(rec,d,9)
 ..s org=$p(rec,d,10)
 ..s dep=$p(rec,d,11)
 ..s ptype=$p(rec,d,12)
 ..d setind
 ..;s i=i+1 i '(i#10000) w !,"DPA ",uprn," ",i
 q
 
LPI ;Index on LPI table
 s i=1
 s d="~"
 s table="L"
 S (uprn,key)=""
 for  s uprn=$O(^UPRN("LPI",uprn)) q:uprn=""  d
 .for  s key=$O(^UPRN("LPI",uprn,key)) q:key=""  d
 ..S rec=$g(^UPRN("U",uprn,"L",key))
 ..q:rec=""
 ..s flat=$p(rec,d,1)
 ..s build=$p(rec,d,2)
 ..s bno=$p(rec,d,3)
 ..s depth=$p(rec,d,4)
 ..s street=$p(rec,d,5)
 ..s deploc=$p(rec,d,6)
 ..s loc=$p(rec,d,7)
 ..s town=$p(rec,d,8)
 ..s post=$p(rec,d,9)
 ..S org="",dep="",ptype=""
 ..d setind
 ..;s i=i+1 i '(i#10000) w !,"LPI ",uprn," ",i
 q
 
setind ;Sets indexes
 n i
 i town'="" S ^UPRNS("TOWN",town)=""
 i loc'="" S ^UPRNS("TOWN",loc)=""
 i $l(street," ")>6 q
 i $l(build," ")>6 q
 s pstreet=$$plural^UPRNU(street)
 s pbuild=$$plural^UPRNU(build)
 s pdepth=$$plural^UPRNU(depth)
 s same=0
 i pstreet=street,pbuild=build,pdepth=depth s same=1
 s indrec=post_" "_flat_" "_build_" "_bno_" "_depth_" "_street_" "_deploc_" "_loc
 for  q:(indrec'["  ")  s indrec=$$tr^UPRNL(indrec,"  "," ")
 s indrec=$$lt^UPRNL(indrec)
 S ^UPRN("X",indrec,uprn,table,key)=""
 i 'same d
 .s indrec=post_" "_flat_" "_pbuild_" "_bno_" "_pdepth_" "_pstreet_" "_deploc_" "_loc
 .for  q:(indrec'["  ")  s indrec=$$tr^UPRNL(indrec,"  "," ")
 .s indrec=$$lt^UPRNL(indrec)
 .S ^UPRN("X",indrec,uprn,table,key)=""
 i deploc'="" d
 .s ^UPRN("X5",post,street_" "_deploc,bno,build,flat,uprn,table,key)=""
 i depth'="" d
 .s ^UPRN("X5",post,depth_" "_street,bno,build,flat,uprn,table,key)=""
 .s ^UPRN("X5",post,street,bno,depth,flat_" "_build,uprn,table,key)=""
 .i 'same d
 ..s ^UPRN("X5",post,pstreet,bno,pdepth,flat_" "_pbuild,uprn,table,key)=""
 s ^UPRN("X5",post,street,bno,build,flat,uprn,table,key)=""
 i 'same d
 .s ^UPRN("X5",post,pstreet,bno,pbuild,flat,uprn,table,key)=""
 i depth'="" d
 .set ^UPRN("X3",depth,bno,post,uprn,table,key)=""
 .set ^UPRN("X3",pdepth,bno,post,uprn,table,key)=""
 .D indexstr("STR",depth)
 .i pdepth'=depth D indexstr("STR",pdepth)
 i deploc'="",street="" d
 .S ^UPRN("X5",post,deploc,bno,build,flat,uprn,table,key)=""
 i depth'="",street="" d
 .S ^UPRN("X5",depth,bno,build,flat,uprn,table,key)=""
 .i 'same d
 ..S ^UPRN("X5",pdepth,bno,pbuild,flat,uprn,table,key)=""
 i street'="" d
 .set ^UPRN("X3",street,bno,post,uprn,table,key)=""
 .i 'same d
 ..set ^UPRN("X3",pstreet,bno,post,uprn,table,key)=""
 .set ^UPRN("X3",$tr(street," "),bno,post,uprn,table,key)=""
 .I depth'="" d
 ..set ^UPRN("X3",depth_" "_street,bno,post,uprn,table,key)=""
 ..i 'same d
 ...set ^UPRN("X3",pdepth_" "_pstreet,bno,post,uprn,table,key)=""
 .do indexstr("STR",street)
 .i pstreet'=street do indexstr("STR",pstreet)
 i build'="" d
 .set ^UPRN("X3",build,flat,post,uprn,table,key)=""
 .i 'same d
 ..set ^UPRN("X3",pbuild,flat,post,uprn,table,key)=""
 .do indexstr("BLD",build)
 .i pbuild'=build do indexstr("BLD",pbuild)
 i build'="",flat'="",street'="" d
 .set ^UPRN("X2",build,street,flat,post,bno,uprn,table,key)=""
 I flat'="",bno'="",street'="",build'="" d
 .S ^UPRN("X4",post,street,bno,flat,build,uprn,table,key)=""
 if build="",org'="" d
 .set ^UPRN("X5",post,street,bno,org,flat,uprn,table,key)=""
 .i 'same d
 ..set ^UPRN("X5",post,pstreet,bno,org,flat,uprn,table,key)=""
 .if flat'="" d
 ..set ^UPRN("X3",org,flat,post,uprn,table,key)=""
 ..do indexstr("BLD",org)
 I street'="",bno'="",build'="",flat'="" d
 .S ^UPRN("X5A",post,street,build,flat,bno,uprn,table,key)=""
 .i 'same d
 ..S ^UPRN("X5A",post,pstreet,pbuild,flat,bno,uprn,table,key)=""
 I pstreet'=street!(pbuild'=build) d
 .I deploc'="" d
 ..s ^UPRN("X5",post,pstreet_" "_deploc,bno,pbuild,flat,uprn,table,key)=""
 .I pdepth'="" d
 ..s ^UPRN("X5",post,pdepth_" "_pstreet,bno,pbuild,flat,uprn,table,key)=""
eind q
indexstr(index,term)         ;Indexes street or building etc
 n strno,i,word
 if '$d(^UPRN("X."_index,term)) d
 .S ^UPRN("X."_index)=$G(^UPRN("X."_index))+1
 .S strno=^UPRN("X."_index)
 .S ^UPRN("X."_index,term)=strno
 .s ^UPRN(index,strno)=term
 s strno=^UPRN("X."_index,term)
 f i=1:1:$l(term," ") d
 .s word=$p(term," ",1)
 .q:word=""
 .i $D(^UPRNS("CORRECT",word)) d
 ..s word=^UPRNS("CORRECT",word)
 .I $D(^UPRNS("ROAD",word)) q
 .I $D(^UPRN("X."_index,word)) q
 .s ^UPRN("X.W",word,index,strno)=""
 q



