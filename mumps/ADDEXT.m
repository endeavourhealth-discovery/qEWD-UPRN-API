ADDEXT ; ; 7/30/19 7:45am
 D GO("/tmp/address_extract.csv")
 QUIT
 
GO(file) 
 new z,i
 o file:(readonly):0
 
 S (G,T)=0
 
 for i=1:1 use file read x q:$zeof  do
 .set z=$tr(x,"""")
 .set orgpost=$p(z,",",1)
 .set personid=$p(z,",",2)
 .set add1=$p(z,",",3)
 .set add2=$p(z,",",4)
 .set add3=$p(z,",",5)
 .set add4=$p(z,",",6)
 .set county=$p(z,",",7)
 .set postcode=$p(z,",",8)
 .set adrec=add1_","_add2_","_add3_","_add4_","_county_","_postcode
 .;set adrec=add1_","_add2_","_add3_","_add4_","_county_","_orgpost
 .set adrec=$tr(adrec,$c(13),"")
 .set orgpost=$tr(orgpost,$c(13),"")
 .d GETUPRN^UPRNMGR(adrec,"",orgpost)
 .;
 .;U 0 W !,orgpost,!,adrec,!,^temp($j,1),! r *y
 .s json=^temp($j,1)
 .kill b,err
 .do DECODE^VPRJSON($name(json),$name(b),$name(err))
 .;u 0 w ! zwr b w !
 .I G#1000=0 U 0 w !,orgpost,!,adrec,!,$get(b("UPRN")),!
 .S G=G+1
 .I $G(b("UPRN"))="" S T=T+1
 .quit
 
 close file
 
 W !,"T = ",T
 W !,"G = ",G
 
 quit
