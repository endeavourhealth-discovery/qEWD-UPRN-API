UPRN1 ;Import routine [ 06/10/2019   8:21 AM ]
 
 ;
IMPORT ;
 W !,"England or Wales : " r folder
 
 w !,"Post code : " r qpost
 s qpost=$$lc^UPRNL(qpost)
 K ^UPRN
 s del=","
 w !,"Importing street descriptors..."
 D IMPSTR
 w !,"Importing uprns...."
 D IMPBLP
DPA w !,"Importing DPA file..."
 D IMPDPA
 w !,"Importing LPI file...."
LPI D IMPLPI
 w !,"Importing discovery addresses..."
ADNO d IMPADNO
 w !,"Cross referencing wrongly spelled streets..."
 D LEVENSTR
 w !,"Done."
 W !
 Q
LEVENSTR ;
 ;K ^UPRNW("SFIX")
 s adno=""
 for  s adno=$O(^UPRN("D",adno)) q:adno=""  d
 .s adrec=^(adno)
 .k address
 .S address=adrec
 .d format^UPRNA(adrec,.address)
 .s street=address("street")
 .S post=address("postcode")
 .s bno=address("number")
 .s build=address("building")
 .for var="street","build" do
 ..i @var="" q
 ..f index="X3" d
 ...I $D(^UPRN(index,@var)) q ;Valid street or building
 ...s st=$e(@var,1,2)
 ...s match=st
 ...for  s match=$O(^UPRN(index,match)) q:($e(match,1,2)'=st)  d
 ....Q:match=@var
 ....q:($l(match," ")>5)
 ....I $$levensh^UPRNU(@var,match,10,2) d
 .....s ^UPRNW("SFIX",@var,match)=""
 q
IMPADNO ;
 i folder="Wales" d Wales
 i folder="England" d England
 q
Wales ;Imports welsh addressses
 s adno=0
 s lno=0
 K ^TUPRN($J,"ITX")
 K ^UPRN("M")
 K ^UPRN("D")
 s del=$c(9)
 o 51:("c:\msm\wales\addresses.txt")
 u 51 r rec
 f lno=1:1:764000 u 51  d
 .u 51 r rec
 .i rec="" Q
 .s adno=$p(rec,del,1)
 .s line1=$p(rec,del,2)_" "_$p(rec,del,3)
 .s line2=$p(rec,del,3)_" "_$p(rec,del,4)
 .S line3=$p(rec,del,5)
 .s post=$tr($p(rec,del,7)," ")
 .s ^UPRN("D",adno)=$$lt^UPRNL($$lc^UPRNL(line1_"~"_line2_"~"_line3_"~"_post))
 c 51
 q
England s adno=0
 s lno=0
 K ^TUPRN($J,"ITX")
 K ^UPRN("M")
 K ^UPRN("D")
 o 51:("c:\msm\shared\address_full_element.CSV")
 u 51 r rec
 f lno=1:1:764000 u 51  d
 .u 51 r rec
 .i rec="" Q
 .s lno=lno+1
 .s adrec=$p(rec,",",2,200)
 .I adrec="" q
 .s line="",text=""
 .s type=$p(adrec,":",1)
 .i $e(type,1,6)="""text""" d
 ..d TXTADNO($p(adrec,":",2,200))
 .q
 .i $e(type,1,6)="""line""" d
 ..s line=$p(adrec,"""line"":",2,200)
 ..D LINEADNO(line)
 .q
 c 51
 s adno=0
 f key="T","S" d
 .s rec=""
 .for  s rec=$O(^TUPRN($J,"ITX",key,rec)) q:rec=""  d
 ..i key="S" Q:$d(^TUPRN($J,"ITX","T",rec))
 ..S post=$p(rec,"~",$l(rec,"~"))
 ..i $e(post,1,$l(qpost))'=qpost q
 ..s adno=adno+1
 ..s ^UPRN("D",adno)=rec
 K ^TUPRN($J,"ITX")
EEng q
TXTADNO(adrec)       ;
 i rec["""line"":" d
 .s line=$p(adrec,"""line"":",2,200)
 .S text=$p(adrec,"""line"":",1)
 .S text=$tr(text,"""")
 .I $P(text,",",$l(text,","))="" d
 ..s text=$p(text,",",1,$l(text,",")-1)
 ..i $p(text,",",$l(text,","))=" " d
 ...s text=$p(text,",",1,$l(text,",")-1)
 .i $L(text,",")<2 q
 .s text=$tr(text,",","~")
 .s text=$$tr^UPRNL(text,"~ ","~")
 .S text=$$lc^UPRNL(text)
 .s ^TUPRN($J,"ITX","T",text,lno)=""
 q
LINEADNO(line)     ;
 s line=$tr(line,"""")
 s addline=""
 s house="",street="",locality="",loc2="",town="",post="",county=""
 s add12=$p($p(line,"]",1),"[",2)
 f i=1:1:$l(add12,",") d
 .s var=$p(add12,",",i)
 .i i=1 s house=var q
 .i i=2 s street=var q
 .i i=3 s locality=var Q
 .i i>3 s loc2=$S(loc2="":var,1:loc2_","_var)
 s rest=$p($p(line,"],",2,200),"{")
 f i=1:1:$l(rest,",") d 
 .s attval=$p(rest,",",i)
 .s att=$p(attval,":")
 .s value=$p($p(attval,":",2),"{")
 .i att="postalCode" s post=value q
 .i att="district" s county=value q
 .i att="city" s town=value q
 .i att="" q
 .i att="state" q
 .s value=county_" "_value
 s struct=""
 s post=$tr(post," ")
 f var="house","street","locality","loc2","town","county","post" d
 .i @var'="" d
 ..s struct=$s(struct="":@var,1:struct_"~"_@var)
 s struct=$tr(struct,",","~")
 s ^TUPRN($J,"ITX","S",struct,lno)=""
 
 Q
ATTVAL(attribut,data)       ;
 n value
 s value=$p(data,attribute,":",2)
 s value=$tr(value,"""","")
 q value
 
 ;
IMPDPA ;Imports and indexes the DPA file.
 D SETSWAPS^UPRNU
 s del=","
 s d="~"
 o 51:("c:\msm\wales\DPA.CSV")
 u 51 r rec
 for  u 51  d  q:rec=""
 .u 51 r rec
 .q:rec=""
 .s rec=$tr($$lc^UPRNL(rec),""".'")
 .s rec=$$tr^UPRNL(rec,", ,",",,")
 .s rec=$tr(rec,"""","")
 .s uprn=$p(rec,del,4)
 .I '$D(^UPRN("U",uprn)) q
 .s post=$tr($p(rec,del,16)," ")
 .i $e(post)'=$e(qpost) q
 .S key=$p(rec,del,5)
 .set org=$p(rec,del,6)
 .set dep=$p(rec,del,7)
 .s flat=$p(rec,del,8)
 .s build=$p(rec,del,9)
 .s bno=$p(rec,del,10)
 .s depth=$p(rec,del,11)
 .s street=$p(rec,del,12)
 .;s ddeploc=$p(rec,del,13)
 .s deploc=$p(rec,del,13)
 .I deploc'="" b
 .s loc=$p(rec,del,14)
 .S town=$p(rec,del,15)
 .S ptype=$p(rec,del,17)
 .s suff=$p(rec,del,18)
 .S ^UPRN("DPA",uprn,key)=flat_d_build_d_bno_d_depth_d_street_d_deploc_d_loc_d_town_d_post_d_org_d_dep_d_ptype
 .set street=$$correct^UPRNU(street)
 .set bno=$$correct^UPRNU(bno)
 .set build=$$correct^UPRNU(build)
 .set flat=$$flat^UPRNU($$correct^UPRNU(flat))
 .set loc=$$correct^UPRNU(loc)
 .if depth'="" s depth=$$correct^UPRNU(depth)
 .if deploc'="" s deploc=$$correct^UPRNU(deploc)
e .set ^UPRN("U",uprn,"D",key)=flat_d_build_d_bno_d_depth_d_street_d_deploc_d_loc_d_town_d_post_d_org_d_dep_d_ptype
 .s table="D"
 .d setind
 .q
 c 51
 q
 
setind ;Sets indexes
 s pbuild=$$plural^UPRNU(build)
 s pstreet=$$plural^UPRNU(street)
 s pdepth=$$plural^UPRNU(depth)
 i deploc'="" d
 .s ^UPRN("X5",post,street_" "_deploc,bno,build,flat,uprn,table,key)=""
 .s ^UPRN("X5",post,pstreet_" "_deploc,bno,pbuild,flat,uprn,table,key)=""
 i depth'="" d
 .s ^UPRN("X5",post,depth_" "_street,bno,build,flat,uprn,table,key)=""
 .s ^UPRN("X5",post,pdepth_" "_pstreet,bno,pbuild,flat,uprn,table,key)=""
 .s ^UPRN("X5",post,street,bno,depth,flat_" "_build,uprn,table,key)=""
 .s ^UPRN("X5",post,pstreet,bno,pdepth,flat_" "_pbuild,uprn,table,key)=""
 s ^UPRN("X5",post,street,bno,build,flat,uprn,table,key)=""
 s ^UPRN("X5",post,pstreet,bno,pbuild,flat,uprn,table,key)=""
 i deploc'="",street="" d
 .S ^UPRN("X5",post,deploc,bno,build,flat,uprn,table,key)=""
 .S ^UPRN("X5",post,deploc,bno,pbuild,flat,uprn,table,key)=""
 i depth'="",street="" d
 .S ^UPRN("X5",depth,bno,build,flat,uprn,table,key)=""
 .S ^UPRN("X5",pdepth,bno,pbuild,flat,uprn,table,key)=""
 i street'="" d
 .set ^UPRN("X3",street,bno,post,uprn,table,key)=""
 .set ^UPRN("X3",pstreet,bno,post,uprn,table,key)=""
 i build'="",flat'="" d
 .set ^UPRN("X3",build,flat,post,uprn,table,key)=""
 .set ^UPRN("X3",pbuild,flat,post,uprn,table,key)=""
 if build="",org'="" d
 .set ^UPRN("X5",post,street,bno,org,flat,uprn,table,key)=""
 .if flat'="" d
 ..set ^UPRN("X3",org,flat,post,uprn,table,key)=""
eind q
 
 
IMPLPI ;Imports and indexes LPI file
 s del=","
 s d="~"
 o 51:("c:\msm\wales\LPI.CSV")
 u 51 r rec
 for  u 51  d  q:rec=""
 .u 51 r rec
 .q:rec=""
 .s rec=$$lc^UPRNL(rec)
 .s rec=$tr(rec,"""")
 .s uprn=$p(rec,del,4)
 .I '$D(^UPRN("U",uprn)) q
 .s key=$p(rec,del,5)
 .s saos=$p(rec,del,12)
 .s saosf=$p(rec,del,13)
 .s saoe=$p(rec,del,14)
 .s saoef=$p(rec,del,15)
 .s saot=$p(rec,del,16)
 .s status=$p(rec,del,7)
 .s paos=$p(rec,del,17)
 .s paosf=$p(rec,del,18)
 .s paoe=$p(rec,del,19)
 .s paoef=$p(rec,del,20)
 .s paot=$p(rec,del,21)
 .s street=$p(rec,del,22)_"-"_$P(rec,del,6)
 .s org=""
 .i status=8 q
 .S nrec=saos_"~"_saosf_"~"_saoe_"~"_saoef_"~"_saot
 .s nrec=nrec_"~"_paos_"~"_paosf_"~"_paoe_"~"_paoef_"~"_paot
 .s nrec=nrec_"~"_street_"~"_status
 .S ^UPRN("LPI",uprn,key)=nrec
 .k dpadd
 .d GETLPI^UPRNU(saos,saosf,saoe,saoef,saot,paos,paosf,paoe,paoef,paot,street,uprn,.dpadd)
 .s flat=dpadd("flat")
 .s build=dpadd("building")
 .s depth=""
 .s street=dpadd("street")
 .s bno=dpadd("number")
 .s deploc=dpadd("deploc")
 .s loc=dpadd("locality")
 .s post=dpadd("postcode")
 .set street=$$correct^UPRNU(street)
 .set bno=$$correct^UPRNU(bno)
 .set build=$$correct^UPRNU(build)
 .set flat=$$flat^UPRNU($$correct^UPRNU(flat))
 .set loc=$$correct^UPRNU(loc)
 .set town=dpadd("town")
L .set ^UPRN("U",uprn,"L",key)=flat_d_build_d_bno_d_depth_d_street_d_deploc_d_loc_d_town_d_post
 .s table="L"
 .do setind
 c 51
 Q
 ;
IMPSTR ;
 s del=","
 K ^UPRN("LPSTR")
 o 51:("c:\msm\wales\Street.CSV")
 u 51 r rec
 for  u 51  d  q:rec=""
 .u 51 r rec
 .q:rec=""
 .s rec=$tr($$lc^UPRNL(rec),"""")
 .s usrn=$p(rec,del,4)
 .s name=$p(rec,del,5)
 .s locality=$p(rec,del,6)
 .s admin=$p(rec,del,8)
 .S lang=$p(rec,del,9)
 .S ^UPRN("LPSTR",usrn_"-"_lang)=name_"~"_locality_"~"_admin
 C 51
 Q
IMPBLP ;
 s del=","
 o 51:("c:\msm\wales\BLPU.CSV")
 u 51 r rec
 for  u 51  d  q:rec=""
 .U 51 r rec
 .Q:rec=""
 .s rec=$tr($$lc^UPRNL(rec),"""")
 .s post=$tr($p(rec,del,21)," ")
 .i $e(post)'=$e(qpost) q
 .s uprn=$p(rec,del,4)
 .s status=$p(rec,del,5)
 .i status=8 q
 .s bpstat=$p(rec,del,6)
 .s insdate=$p(rec,del,16)
 .s update=$p(rec,del,18)
 .s parent=$p(rec,del,8)
 .s coord1=$p(rec,del,9)_","_$P(rec,del,10)
 .s adpost=$p(rec,del,20)
 .S ^UPRN("U",uprn)=$tr(adpost_"~"_post_"~"_status_"~"_bpstat_"~"_insdate_"~"_update_"~"_coord1,"""")
 .i parent'="" d
 ..S ^UPRN("UPC",parent,uprn)=""
 .if post'="" S ^UPRN("X1",post,uprn)=""
 c 51
 q
