UPRNX ;Import routine [ 03/19/2019  12:12 PM ]
 
 ;
IMPORT ;
 d files
SURE ;
 W !!,"You are about to delete the ABP data and replace it"
 W !!,"Are you sure you wish to proceeed !!?"
 r *yn s yn=$$lc^UPRNL($C(yn))
 i yn="n" q
 i yn'="y" G SURE
 s del=$c(9)
 s abp=^UPRNF("abpfolder")
DPA w !,"Importing DPA file..."
 D IMPDPA
 w !,"Importing LPI file...."
LPI D IMPLPI
 q
IMPDPA ;Imports and indexes the DPA file.
 D SETSWAPS^UPRNU
 s del=","
 s d="~"
 o 51:(abp_"\ID28_DPA_Records.CSV")
 u 51 r rec
 for  u 51  d  q:rec=""
 .u 51 r rec
 .q:rec=""
 .s rec=$tr($$lc^UPRNL(rec),""".'")
 .s rec=$$tr^UPRNL(rec,", ,",",,")
 .s rec=$tr(rec,"""","")
 .s uprn=$p(rec,del,4)
 .I uprn="46009991" b
 .I '$D(^UPRN("U",uprn)) q
 .s post=$tr($p(rec,del,16)," ")
 .S key=$p(rec,del,5)
 .set org=$p(rec,del,6)
 .set dep=$p(rec,del,7)
 .s flat=$p(rec,del,8)
 .s build=$$lt^UPRNL($p(rec,del,9))
 .s bno=$p(rec,del,10)
 .s depth=$$lt^UPRNL($p(rec,del,11))
 .i depth?1n.n1" ".1l.e,bno="" d
 ..s bno=$p(depth," ")
 ..s depth=$p(depth," ",2,20)
 .s street=$$lt^UPRNL($p(rec,del,12))
 .I street?1n.n1" "1l.e,bno="" d
 ..s bno=$p(street," ")
 ..s street=$p(street," ",2,20)
 .;s ddeploc=$p(rec,del,13)
 .s deploc=$$lt^UPRNL($p(rec,del,13))
 .s loc=$p(rec,del,14)
 .S town=$p(rec,del,15)
 .S ptype=$p(rec,del,17)
 .s suff=$p(rec,del,18)
 .i build?1n.n1l d
 ..I flat="" d  q
 ...s flat=build,build=""
 ..i bno="" d  q
 ...s bno=build,build=""
 .i build?1n.n.l1"-"1n.n.l d
 ..I flat="" d  q
 ...s flat=build,build=""
 ..i bno="" d  q
 ...s bno=build,build=""
 .i build?1n.n.l1"-"1n.n1" "1e.e,flat="" d
 ..s flat=$p(build," ")
 ..s build=$p(build," ",2,20)
 .i build?1n.n.l1" "1e.e,flat="" d
 ..s flat=$p(build," ")
 ..s build=$p(build," ",2,10)
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
 I flat'="",bno'="",street'="",build'="" d
 .S ^UPRN("X4",post,street,bno,flat,build,uprn,table,key)=""
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
 
 
IMPLPI ;Imports and indexes LPI file
 s del=","
 s d="~"
 o 51:(abp_"\ID24_LPI_Records.CSV")
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
 .s end=$p(rec,del,9)
 .s paos=$p(rec,del,17)
 .s paosf=$p(rec,del,18)
 .s paoe=$p(rec,del,19)
 .s paoef=$p(rec,del,20)
 .s paot=$p(rec,del,21)
 .s str=$p(rec,del,22)_"-"_$P(rec,del,6)
 .s org=""
 .;i status=8 D  q
 ..;U 0 w rec r t
 .i status=1,end'="" d
 ..u 0 w rec r t
 .S nrec=saos_"~"_saosf_"~"_saoe_"~"_saoef_"~"_saot
 .s nrec=nrec_"~"_paos_"~"_paosf_"~"_paoe_"~"_paoef_"~"_paot
 .s nrec=nrec_"~"_str_"~"_status
 .k dpadd
 .d GETLPI^UPRNU(saos,saosf,saoe,saoef,saot,paos,paosf,paoe,paoef,paot,str,uprn,.dpadd)
 .s flat=dpadd("flat")
 .s build=$$lt^UPRNL(dpadd("building"))
 .s depth=""
 .s street=$$lt^UPRNL(dpadd("street"))
 .s bno=dpadd("number")
 .s deploc=$$lt^UPRNL(dpadd("deploc"))
 .s loc=$$lt^UPRNL(dpadd("locality"))
 .s post=dpadd("postcode")
 .set street=$$correct^UPRNU(street)
 .set bno=$$correct^UPRNU(bno)
 .set build=$$correct^UPRNU(build)
 .set flat=$$flat^UPRNU($$correct^UPRNU(flat))
 .set loc=$$correct^UPRNU(loc)
 .set town=dpadd("town")
 .i $l(street," ")>5 q
 .i $l(build," ")>5 q
 .s table="L"
 .do setind
 c 51
 Q
 q
files ;
 s country=""
 W !,"England or Wales : " r *c
 i c=13 q
 s country=$c(c)
 s folder=""
 s folder=$G(^UPRNF("abpfolder"))
 w !,"ABP folder ("_folder_") :" r folder
 i folder="" s folder=$g(^UPRNF("abpfolder"))
 s att=$ZOS(10,folder)
 i att<2 W *7,"Error no folder " H 2 G files
 s ^UPRNF("abpfolder")=folder
 s country=$$lc^UPRNL(country)
 i country="" q
 i country'="e"&(country'="w") G files
 i country="e" s folder="Shared"
 i country="w" s folder="Wales"
 w !,"Address file ("_$G(^UPRNF("adrfile"))_") : " r adrfile
 i adrfile="" s adrfile=^UPRNF("adrfile")
 s ^UPRNF("adrfile")=adrfile
 s resdir=$p(adrfile,"\",1,$l(adrfile,"\")-1)_"\Results"
 s att=$ZOS(10,resdir)
 s err=""
 i att<2 s err=$ZOS(6,resdir)
 i err'="" W !,*7,"Error creating results directory" h 2 G files
 s ^UPRNF("Results")=resdir
 q
