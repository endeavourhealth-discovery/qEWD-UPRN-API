UPRNA ;Formats discovery address [ 06/09/2019  10:58 AM ]
 
 ;
format(adrec,address)    ;
 ;Populates the discovery address object
 ;initialise address field variabls
 
 k address
 n d,tempadd
 s d="~"
 set adflat=""
 set adbuild=""
 set adbno=""
 set adepth=""
 set adeploc=""
 set adstreet=""
 set adloc=""
 set post=""
 set tempadd=""
 ;remove london
 
 
 ;Lower case the address, remove characterset /. double spaces
 set d="~" ;field delimiter is ~
 set address=$$lc^UPRNL(adrec)
 set address=$tr(address,","," ")
 set address=$tr(address,"',")
 set address=$tr(address,"/","-")
 set address=$tr(address,"."," ")
 set address=$tr(address,"*"," ")
 set address=$$tr^UPRNL(address,"  "," ")
 set address=$$tr^UPRNL(address,"~ ","~")
 
 
 ;get the post code from the last field
 set length=$length(address,d)
 set post=$$lc^UPRNL($p(address,d,length))
 set post=$tr(post," ") ;Remove spaces
 
 ;Try to find how many address lines and which is which
 ;Use lines before the city if present
 ;addlines is number of address lines to format
 ;
 set addlines=0
 ;remove london,middlesex
 s tempadd=""
 F i=1:1:(length-1) d
 .s part=$p(address,d,i)
 .q:part=""
 .i $D(^UPRNS("CITY",part)) q
 .I $D(^UPRNS("COUNTY",part)) q
 .I $D(^UPRNS("COUNTY",$p(part," ",$l(part," ")))) d
 ..S part=$p(part," ",1,$l(part," ")-1)
 .i $d(^UPRNS("CITY",$p(part," ",$l(part," ")))) D
 ..S part=$p(part," ",1,$l(part," ")-1)
 .s tempadd=tempadd_$s(tempadd="":part,1:"~"_part)
 s address=tempadd_"~"_post
 S addlines=$l(address,"~")-1
 
 ;too many address lines may be duplicate post code
 i addlines>2 d
 .f i=2:1:addlines d
 ..I $D(^UPRN("X5",$tr($p(address,d,i)," "))) d
 ...s post=$tr($p(address,d,i)," ")
 ...s addlines=i-1
 ...s address=$p(address,d,1,addlines+1)
 
 ;may have too many address lines number is alone in field 1
 I addlines>2 d
 .i $p(address,d,1)?1n.n."-".n,$p(address,d,2)?1l.e d
 ..s $p(address,d,1)=$p(address,d,1)_" "_$p(address,d,2)
 ..s address=$p(address,d,1)_d_$p(address,d,3,10)
 ..s addlines=addlines-1
 
 ;Still too many, number s alone in field 2
 i addlines>2 d
 .i $p(address,d,2)?1n.n,$p(address,d,3)?1l.e d
 ..s $p(address,d,2)=$p(address,d,2)_" "_$p(address,d,3)
 ..s address=$p(address,d,1,2)_d_$p(address,d,4,10)
 ..s addlines=addlines-1
 
 ;Duplicate street?
 i addlines>2 d
 .i $p($p(address,d,2)," ",2,10)=$p(address,d,3) d
 ..s address=$p(address,d,1,2)_"~"_$p(address,d,4,10)
 ..s addlines=addlines-1
 
 
 ;Initialise address line variabs
 ;flat and building is line 1, number and street is line 2
 i addlines=1 d
 .s adstreet=$p(address,d,1)
 .i adstreet?1l.e d
 ..f i=1:1:$l(adstreet," ") q:(adbuild'="")  d
 ...i $p(adstreet," ",i)?1n.n.l d
 ....i $p(adstreet," ",i+1)?1n.n.l d  q
 .....s adbuild=$p(adstreet," ",1,i)
 .....s adstreet=$p(adstreet," ",i+1,20)
 ....s adbuild=$p(adstreet," ",1,i-1),adstreet=$p(adstreet," ",i,20)
 i addlines=2 d
 .s adbuild=$p(address,d,1)
 .s adstreet=$p(address,d,2)
 .i adstreet?1n.n,adbuild'="" d
 ..s adstreet=adstreet_" "_adbuild
 ..s adbuild=""
 i addlines=3 d
 .s adbuild=$p(address,d,1)
 .s adstreet=$p(address,d,2)
 .s adloc=$p(address,d,3)
 i addlines=4 d
 .s adbuild=$p(address,d,1)
 .s adstreet=$p(address,d,2)
 .s adeploc=$p(address,d,3)
 .s adloc=$p(address,d,4)
 i addlines=5 d
 .s adbuild=$p(address,d,1)
 .s adepth=$p(address,d,2)
 .s adstreet=$p(address,d,3)
 .s adeploc=$p(address,d,4)
 .s adloc=$p(address,d,5)
 i addlines=6 d
 .s adbuild=$p(address,d,1)_" "_$p(address,d,2)
 .s adepth=$p(address,d,3)
 .s adstreet=$p(address,d,4)
 .s adeploc=$p(address,d,5)
 .s adloc=$p(address,d,6)
 .;.s adepth=$p(address,d,3)
 .;.s adeploc=$p(address,d,4)
 .;.s adloc=$p(address,d,5)
 .;.i adepth?1n.n!(adepth?1n.n1),adeploc'="" d
 .;..s adbuild=adbuild_" "_adstreet
 .;..s adstreet=adepth_" "_adeploc
 .;..s adepth="",adeploc=""
 i addlines=7 d
 .s adbuild=$p(address,d,1)_" "_$p(address,d,2)
 .s adepth=$p(address,d,3)
 .s adstreet=$p(address,d,4)_" "_$p(address,d,5)
 .s adeploc=$p(address,d,6)
 .s adloc=$p(address,d,7)
 f var="adbuild","adstreet","adepth","adeploc","adloc" d
 .s @var=$$lt^UPRNL(@var)
 
 ;if >2 lines then last may be locality and append street
 ;if >3 lines then may be a dependent street
 ;i addlines>2 d
 
 ;.if addlines=7 d
 ;..s adepth=$p(address,d,3)
 ;..s adeploc=$p(address,d,4)
 ;..s adloc=$p(address,d,5)
 ;..i adepth?1n.n!(adepth?1n.n1),adeploc'="" d
 ;...s adbuild=adbuild_" "_adstreet
 ;...s adstreet=adepth_" "_adeploc
 ;...s adepth="",adeploc=""
 ;.if addlines=6 d  Q
 ;..s adepth=$p(address,d,3)
 ;..s adeploc=$p(address,d,4)
 ;..s adloc=$p(address,d,5)
 ;..i adepth?1n.n!(adepth?1n.n1),adeploc'="" d
 ;...s adbuild=adbuild_" "_adstreet
 ;...s adstreet=adepth_" "_adeploc
 ;...s adepth="",adeploc=""
 ;.if addlines=5 d  Q
 ;..set adloc=$p(address,d,addlines)
 ;..set adeploc=$p(address,d,addlines-1)
 ;..set adepth=$p(address,d,2)
 ;..set adstreet=$p(address,d,3)
 ;..i adepth?1n.n!(adepth?1n.n1l),adeploc'="" d
 ;...set adstreet=adepth_" "_adstreet
 ;...set adepth=""
 ;.if addlines=4 d  Q  ;Must have street dependency
 ;..i adstreet?1n.n.l d
 ;...s adstreet=adstreet_" "_$p(address,d,3)
 ;..s adeploc=$p(address,d,addlines-1)
 ;..s adloc=$p(address,d,addlines)
 ;.i addlines=3 d  Q
 ;..i $$isflat^UPRNU(adstreet) d  q
 ;...s adbuild=adstreet_" "_adbuild
 ;...s adstreet=$p(address,d,3)
 ;..s adloc=$p(address,d,addlines)
 
 set address("original")=$$tr^UPRNL($$lt^UPRNL(post_" "_adbuild_" "_adepth_" "_adstreet_" "_adeploc),"  "," ")
 
 ;
 ;Dependent locality is street
 i adeploc'="" d
 .i $$isroad(adeploc),'$$isroad(adstreet) d
 ..I adbuild'="",adstreet?1n.n!(adstreet?1n.n1l) d
 ...s adstreet=adstreet_" "_adeploc,adeploc=""
 ..if adstreet?1l.e,adeploc?1n.n."-".n1" "1l.e d  q
 ...i adstreet["flat" d
 ....s adbuild=adstreet_" "_adbuild
 ....s adstreet=adeploc
 ....s adeploc=""
 ...e  d
 ....s adbuild=adbuild_" "_adstreet
 ....s adstreet=adeploc
 ....s adeploc=""
 ..i adbuild'="" d
 ...i $d(^UPRNS("FLOOR",$p(adstreet," "))) d  q
 ....s adbuild=adbuild_" "_adstreet
 ....s adstreet=""
 ....i adepth'="" d
 .....s adstreet=adepth_" "_adeploc
 .....s adepth="",adeploc=""
 ....e  d
 .....s adstreet=adeploc
 ...i $$isflat^UPRNU(adstreet) d  q
 ....s adbuild=adstreet_" "_adbuild
 ....s adstreet=adepth_" "_adeploc
 ....s adepth="",adeploc=""
 
 ;Location is street, street is building
 i adloc'="",adstreet'="" d
 .if $$isroad(adloc),'$$isroad(adstreet) do
 ..if adloc?1n.n1" "1l.e d  q
 ...if adstreet?1n.n do
 ....i adbuild?1l.l.e d  q
 .....s adbuild=adstreet_" "_adbuild
 .....s adstreet=adloc
 .....s adloc=""
 ..i adstreet?1n.n!(adstreet?1n.n1"-"1n.n)!(adstreet?1n.n1l) do  q
 ...s adstreet=adstreet_" "_adloc
 ...s adloc=""
 ..i adflat="" d  q
 ...s adflat=adbuild
 ...I adstreet'="" d
 ....set adbuild=adstreet
 ...e  i adflat?1n.n.l1" "2l.e d
 ....set adbuild=$p(adflat," ",2,20)
 ....set adflat=$p(adflat," ")
 ...set adstreet=adloc
 ...set adloc=""
 ..set adbuild=adbuild_" "_adstreet
 ..set adstreet=adloc
 ..set adloc=""
 
 ;Only one  line, likely to be street But may be flat and building
 
 
 ;Location is actually number and street
 if adloc?1n.n.l1" "1l.e d
 .if adstreet'?1n.n.l1" ".e d
 ..set adbuild=adbuild_" "_adstreet
 ..set adstreet=adloc
 ..set adloc=""
 
 ;Street starts with flat number so swap
 ;May or may not contain building
 if $$isflat^UPRNU(adstreet) d  ;Might be flat
 .if '$$isroad(adstreet) do   q ;straight swap
 ..set xbuild=adbuild
 ..set adbuild=adstreet
 ..set adstreet=xbuild
 .else  d
 ..if $$isno($p(adstreet," ",3)) do
 ...if adbuild'="" d
 ....set adbuild=$p(adstreet," ",1,2)_" "_adbuild
 ...else  d
 ....s adbuild=$p(adstreet," ",1,2)
 ...set adstreet=$p(adstreet," ",3,20)
 
 
 ;Ordinary flat building various formats, split it up
 if adflat="" do flatbld(.adflat,.adbuild)
 
 ;Ordinary street format , split it up
 do numstr(.adbno,.adstreet,.adflat,.adbuild)
 
 ;Left shift locality to street, street to building, building to flat?
 i adloc?1n.n1" "1l.e d
 .i adbuild="",adbno'="" do
 ..s adflat=adflat_" "_adbno
 ..s adbuild=adstreet
 ..s adbno=$p(adloc," ",1)
 ..s adstreet=$p(adloc," ",2,10)
 ..s adloc=""
 
 
 ;Is number in the flat field?
 if $$isno(adflat) d
 .if adbuild="" d
 ..if adbno="" d
 ...set adbno=adflat
 ...set adflat=""
 
 ;Building is street,street is null or not
 ;111 abbotts park road,  ,
 ;111 abotts park road, leyton,,
 ;111 abbotts park road , leyton, leyton
 if $$isroad(adbuild) do
 .i adbno="" d
 ..i adstreet="" d  q
 ...I $$isflat^UPRNU(adbuild) d  q
 ....i $p(adbuild," ",2)?1n.n d  q
 .....s xflat=adflat
 .....s adflat=$p(adbuild," ",1,2)
 .....s adbno=xflat
 .....s adbuild=$p(adbuild," ",3,20)
 ...I adbuild?1l.l.e d  q
 ....s adbno=adflat
 ....s adstreet=adbuild
 ....s adflat="",adbuild=""
 ...i adbuild?1n.n.l1" "1l.e d  q
 ....s adbno=$p(adbuild," ",1)
 ....s adstreet=$p(adbuild," ",2,10)
 ....s adbuild=""
 ..i adloc="" d
 ...i '$$isroad(adstreet) d
 ....s adloc=adstreet
 ....s adstreet=adbuild
 ....s adbno=adflat
 ....s (adflat,adbuild)=""
 if adflat'="",adbuild'="",adbno="",adstreet="" d
 .if adbno="",adstreet="" d  q
 ..i adflat["flat" d  q
 ...s adstreet=adbuild
 ...s adbuild=""
 ..set adbno=adflat
 ..set adstreet=adbuild
 ..set adflat="",adbuild=""
 .if adbno="",adloc="" d
 ..i '$$hasflat^UPRNU(adflat_" "_adbuild) d  Q
 ...set adloc=adstreet
 ...set adbno=adflat
 ...set adstreet=adbuild
 ...set adflat=""
 ...set adbuild=""
 ..d splitstr(adflat,adbuild,adbno,adstreet,.adflat,.adbuild,.adbno,.adstreet)
 .if '$$isroad(adstreet) do
 ..if adbno="" do  q
 ...if adstreet=adloc  d
 ....set adstreet=adbuild
 ....set adbuild=""
 ....set adbno=adflat
 ..if adbno'="" do
 ...set xbuild=adbuild
 ...set xflat=adflat
 ...set adbuild=adstreet
 ...set adflat=adbno
 ...set adbno=xflat
 ...set adstreet=xbuild
 
 ;Building is number,make sure street doesn't have the number !
 ;Number contains flat so assign number to flat
 if adbno?1n.n.l1" "1n.n.l d
 .s adflat=$p(adbno," ")
 .s adbno=$p(adbno," ",2)
 
 ;
 ;Strip space from number to assign suffix
 if adbno?1n.n1" "1l s adbno=$tr(adbno," ")
 
 ;Street is a number, locality is the street
 if $$isno(adstreet) d
 .if adbno'="" d
 ..s adbno=adstreet
 ..s adstreet=adloc
 ..s adloc=""
 
 ;Locality is street, street is building
 if $$isroad(adloc) d
 .if adflat="",adbuild="" d
 ..s adflat=adbno,adbno=""
 ..s adbuild=adstreet
 ..s adstreet=adloc,adloc=""
 
 
 ;Confusing flat number now split out
 if $$isflat^UPRNU(adbuild) d
 .if adflat=adbno d
 ..s adflat=$p(adbuild," ",1,2)
 ..s adbuild=$p(adbuild," ",3,10)
 .else  d
 ..if adflat'="" d
 ...if adbuild?1l.l1" "1l1" "1l.e d  q ; room f unite stratford
 ....set adflat=adflat_" "_$p(adbuild," ",1,2)
 ....set adbuild=$p(adbuild," ",3,20)
 ...i adbuild?1l.l1" "1l d  q ; room h
 ....set adflat=adflat_" "_$p(adbuild," ",1,2)
 ....set adbuild=$p(adbuild," ",3,20)
 
 
 ;Street has flat name and flat has street
 if $$isflat^UPRNU(adstreet) d
 .if adflat?1n.n d
 ..if adbuild'="" d
 ...n flatbuild
 ...set flatbuild=$S(adbno'="":adbno_" ",1:"")_adstreet
 ...set adbno=adflat
 ...set adstreet=adbuild
 ...set adflat=$p(flatbuild," ",1,2)
 ...set adbuild=$p(flatbuild," ",3,20)
 ...if adbuild?1l do
 ...set adflat=adflat_" "_adbuild,adbuild=""
 
 ;Duplicate flat building number and street,remove flat and building
 if adflat'="",adbuild'="",adbno'="",adstreet'="" d
 .if $e((adbno*1)_" "_adstreet,1,$l((adflat*1)_" "_adbuild))=((adflat*1)_" "_adbuild) d
 ..set adflat="",adbuild=""
 
 
 ;first floor 96a second avenue
 ;street contains flat term before the number
 n i,word
 if adbno="" do
 .for i=2:1:$l(adstreet," ") do
 ..set word=$p(adstreet," ",i)
 ..if word?1n.n.l do
 ...if adflat="",adbuild="" d
 ....set adflat=$p(adstreet," ",1,i-1)
 ...else  do
 ....if adflat'="" do
 .....if adbuild="" d
 ......set adbuild=$p(adstreet," ",1,i-1)
 .....else  do
 ......s adbuild=adbuild_" "_$p(adstreet," ",1,i-1)
 ...set adbno=word
 ...set adstreet=$p(adstreet," ",i+1,20)
 
 ;
 ;street contains flat number near the end
 if adstreet[" flat " d
 .set adflat="flat "_$p(adstreet,"flat ",2,10)
 .set adstreet=$p(adstreet," flat",1)
 
 ;Bulding is number suffix
 ; a~12 high street
 if adbuild?1l,adflat="",adbno?1n.n do
 .set adbno=adbno_adbuild
 .set adbuild=""
 
 ;Street number mixed with flat and building
 ;20 284-288 haggerston studios~ kingsland road
 if adbuild?1n.n1" "1n.n."-".n1" "1l.e do
 .if adflat="",adbno="" d
 ..set adflat=$p(adbuild," ",1)
 ..set adbno=$p(adbuild," ",2)
 ..set adbuild=$p(adbuild,3,20)
 
 ;duplicate flat number in building number without street
 ;46, 46 ballance road
 if adbuild?1n.n1" "1n.n do
 .if adbno="",adflat="" do
 ..set adbno=$p(adbuild," ",2)
 ..set adflat=$p(adbuild," ",1)
 ..set adbuild=""
 
 ;110 , 110 carlton road
 ;Duplicate flat and number
 if adflat=adbno,adbuild="" d
 .set adflat=""
 
 ;street number is in location!
 ; bendish road , 11
 if adloc?1n.n,adbno="" do
 .set adbno=adloc
 .set adloc=""
 
 ;Error in flat number
 ;flat go1
 if $p(adflat," ",2)?1l.l1"o"1n.n d
 .set $p(adflat," ",2)=$tr($p(adflat," ",2),"o","0")
 
 ;Now has flat as number and number still in street
 ;,,flat 1, 22 plashet road
 if adbno'="",$$isno($P(adstreet," ")) do
 .if adflat="",adbuild="" d
 ..set adflat=adbno
 ..set adbno=$p(adstreet," ")
 ..set adstreet=$p(adstreet," ",2,20)
 
 ;area in street
 I adloc="",$l(adstreet," ")>1 d
 .i $D(^UPRNS("TOWN",$p(adstreet," ",$l(adstreet," ")))) d
 ..s adloc=$p(adstreet," ",$l(adstreet," "))
 ..s adstreet=$p(adstreet," ",0,$l(adstreet," ")-1)
 
 ;building is the number
 if $$isno(adbuild),adstreet'="",adbno="" do
 .set adbno=adbuild
 .set adbuild=""
 
 ;suffixes split across fields
 if adflat'="",adbuild?1l1" "1l.e do
 .set adflat=adflat_$e(adbuild)
 .set adbuild=$p(adbuild,2,20)
 .set adbuild=$p(adbuild,2,20)
 
 if adbno'="",adstreet?1l1" "1l.e d
 .I $e(adstreet)'="y" d
 ..set adbno=adbno_$e(adstreet)
 ..set adstreet=$p(adstreet," ",2,20)
 
 ;Two streets
 if $$isroad(adloc),$$isroad(adstreet) do
 .if adflat="",adbuild="" do
 ..set adflat=adbno
 ..set adbuild=adstreet
 ..set adbno=""
 ..set adstreet=adloc
 ..set adloc=""
 ;
 
 ;009 
 ;strip leading zeros
 if adflat?1n.n set adflat=adflat*1
 if adbno?1n.n set adbno=adbno*1
 
 ;Building ends in number
 i adbno="",adflat="",adstreet?1l.l1" "1l.l.e d
 .i $p(adbuild," ",$l(adbuild," "))?1n.n d
 ..s adbno=$p(adbuild," ",$l(adbuild," "))
 ..s adbuild=$p(adbuild," ",1,$l(adbuild," ")-1)
 ;Correct spelling
 i '$d(address("obuild")) s address("obuild")=adbuild
 s address("ostr")=adstreet
 s adbuild=$$correct^UPRNU(adbuild)
 s adstreet=$$correct^UPRNU(adstreet)
 set adflat=$$flat^UPRNU($$co($$correct^UPRNU(adflat)))
 i adbno'="" s adbno=$$flat^UPRNU($$co($$correct^UPRNU(adbno)))
 
 ;Duplicate building
 i adbuild=adstreet d
 .i adbno="",adflat'="" d
 ..s adbno=adflat
 ..s adbuild=""
 ..s adflat=""
 
 ;Street still has number
 i adstreet?1n.n1l1" "1l.e,adbno="",adflat'="" d
 .s adbno=$p(adstreet," ")
 .s adstreet=$p(adstreet," ",2,10)
 
 ;Street contains building
 i adbuild="",adflat="" d
 .i $$isroad(adstreet) d
 ..f i=1:1:($l(adstreet," ")-2) D
 ...i $d(^UPRNS("BUILDING",$p(adstreet," ",i)))!($d(^UPRNS("COURT",$p(adstreet," ",i)))) d
 ....s adbuild=$p(adstreet," ",1,i)
 ....s adstreet=$p(adstreet," ",i+1,$l(adstreet," "))
 ....s adflat=adbno
 ....s adbno=""
 
 
 ;dependent locality has number
 i adepth?1n.n1l!(adeploc?1n.n),adbno="" d
 .s adbno=adepth
 .s adepth=""
 
 ;House and street in same line
 i adflat="",adbuild="",adbno'="",$l(adstreet," ")>2 d
 .f i=$l(adstreet," ")-1:-1:2 i $D(^UPRN("X.STR",$p(adstreet," ",i,$l(adstreet," ")))) d  q
 ..s adflat=adbno
 ..s adbuild=$p(adstreet," ",1,i-1)
 ..s adbno=""
 ..s adstreet=$p(adstreet," ",i,$l(adstreet," "))
 
 ;set address object values
 s address("flat")=adflat
 s address("building")=adbuild
 s address("number")=adbno
 s address("deploc")=adeploc
 s address("depth")=adepth
 s address("street")=adstreet
 s address("locality")=adloc
 s address("postcode")=post
 s short="",long=""
 
eform q
co(number)         ;Strips off care of
 i $tr($p(number," "),"-")="co" d
 .i $l(number," ")>1 d
 ..s number=$p(number," ",2,10)
 q number
 
splitstr(oflat,obuild,obno,ostreet,adflat,adbuild,adbno,adstreet) 
 ;Splits up building into street and vice versa
 n i,xbuild,xstreet
 f i=1:1:$l(obuild," ") d
 .i $p(obuild," ",i)?1n.n d
 ..i $$hasflat^UPRNU($p(obuild," ",i+1,i+10)) d
 ...s adbno=adflat
 ...s xstreet=adstreet
 ...s adstreet=$p(obuild," ",0,i-1)
 ...s adflat=$p(obuild," ",i,i+10)
 ...s adbuild=xstreet
 q
isno(word)         ;is it a number
 if word?1n.n q 1
 if word?1n.n1l q 1
 if word?1n.n1"-"1n.n q 1
 if word?1n.n1l1"-"1n.n1l q 1
 q 0
 
flatbld(adflat,adbuild) ;
 ;is it a flat or number and if so what piece is the rest?
 s adbuild=$$co(adbuild)
 
 if $$isflat^UPRNU(adbuild) do  q
 .set adflat=$p(adbuild," ",1,2)
 .set adbuild=$p(adbuild," ",3,10)
 .if adbuild?1l1" ".e d
 ..set adflat=adflat_$p(adbuild," ")
 ..set adbuild=$p(adbuild," ",2,20)
 .if adbuild?1n.n.l1" "1l.e d
 ..i $D(^UPRNS("FLOOR",$P(adbuild," "))) q
 ..s adflat=adflat_" "_$p(adbuild," ")
 ..s adbuild=$p(adbuild," ",2,10)
 
 
 
 ;2nd floor flat etc
 i adbuild'="" d
 .s address("obuild")=adbuild
 .s $p(adbuild," ")=$$correct^UPRNU($p(adbuild," "))
 
 ;18pondo road
 if adbuild?1n.n2l.l1" "2l.e do  q
 .n i
 .f i=1:1 q:$e(adbuild,i)'?1n  d
 ..set adflat=adflat_$e(adbuild,i)
 .set adbuild=$p(adbuild,adflat,2,10)
 
 ;19a
 if adbuild?1n.n.l do  q
 .set adflat=adbuild
 .set adbuild=""
 if adbuild?1n.n1" "1l do  q
 .set adflat=$p(adbuild," ")_$p(adbuild," ",2)
 .set adbuild=""
 
 ;19 a eagle house
 if adbuild?1n.n1" "1l1" ".e do  q
 .set adflat=$p(adbuild," ",1)_$p(adbuild," ",2)
 .set adbuild=$p(adbuild," ",3,20)
 
 ;18dn forth avenue
 if adbuild?1n.n2l1" "1l.e d  q
 .set adflat=$p(adbuild," ",1)
 .set adbuild=$p(adbuild," ",2,10)
 
 ;19 eagle house or garden flat 1
 if adbuild?1n.n.l1" "1l.e do  q
 .set adflat=$p(adbuild," ",1)
 .set adbuild=$p(adbuild," ",2,20)
 
 ;19a-19c eagle house
 if adbuild?1n.n.l1"-"1n.n.1" ".l.e do  q
 .set adflat=$p(adbuild," ",1)
 .set adbuild=$p(adbuild," ",2,20)
 
 ;19- eagle house
 if adbuild?1n.n1"-"1" "1l.e do  q
 .set adflat=$p(adbuild,"-",1)
 .set adbuild=$p(adbuild," ",2,20)
 
 ;first floor flat
 if adbuild[" flat"!(adbuild[" room"),adflat="" do  q
 .set adflat=adbuild
 .set adbuild=""
 
 ;116 - 118 
 if adbuild?1n.n.l1" "1"-"1" "1n.n.l.e do  q
 .set adflat=$p(adbuild," ",1)_"-"_$p(adbuild," ",3)
 .set adbuild=$p(adbuild," ",4,20)
 
 ;12 -20 rosina street
 if adbuild?1n.n1" "1"-"1n.n1" "1l.e do  q
 .set adflat=$p(adbuild," ",1)_$p(adbuild," ",2)
 .set adbuild=$p(adbuild," ",3,20)
 
 ;a cranberry lane
 if adbuild?1l1" "1l.l1" "1l.e do  q
 .set adflat=$p(adbuild," ")
 .set adbuild=$p(adbuild," ",2,10)
 
 ;a203 carmine wharf
 ;dlg02 carminw wharf
 if adbuild?1l.l1n.n.1" "1l.e do  q
 .set adflat=$p(adbuild," ")
 .set adbuild=$p(adbuild," ",2,20)
 
 ;b202h unit building
 if adbuild?1l1n.n.l1" "1l.e do  q
 .set adflat=$p(adbuild," ",1)
 .set adbuild=$p(adbuild," ",2,20)
 
 ;flaflat 10 mileset lodge
 if $p(adbuild," ")["flat" do  q
 .I $p(adbuild," ",2)?1n.n.l d
 ..set adflat="flat"_" "_$p(adbuild," ",2)
 ..set adbuild=$p(adbuild," ",3,20)
 .e  d
 ..if adflat'="" d
 ...set adflat="flat "_adflat
 ...set adbuild=$p(adbuild," ",2,20)
 
 ;workshop 6
 if adflat="",adbuild?1.l1" "1n.n.l do  q
 .s adflat=adbuild
 .s adbuild=""
 
 
 q
 
numstr(adbno,adstreet,adflat,adbuild) ;
 ;Reformat a variety of number and street patterns
 
 ;11 high street
 if adstreet?1n.n1" "2l.e do  q
 .set adbno=$p(adstreet," ",1)
 .set adstreet=$p(adstreet," ",2,10)
 .if adstreet?1"flat "1n.n.l1" "1l.e d
 ..i adflat="" d
 ...s adflat=$p(adstreet," ",1,2)
 ...s adstreet=$p(adstreet," ",3,20)
 
 ;100 S0oth
 if adstreet?1n.n1" "1l.n.l.e d  q
 .set adbno=$p(adstreet," ",1)
 .set adstreet=$p(adstreet," ",2,10)
 
 ;123-15 dunlace road
 if adstreet?1n.n1"-"1n.n1" "1l.e do  q
 .set adbno=$p(adstreet," ",1)
 .set adstreet=$p(adstreet," ",2,20)
 
 ;11a high street
 if adstreet?1n.n1l1" "1l.e do  q
 .set adbno=$p(adstreet," ",1)
 .set adstreet=$p(adstreet," ",2,20)
 
 ;14 - 16 lower clapton road
 if adstreet?1n.n1" "1"-"1" "1n.n1" "1l.e do  q
 .set adbno=$p(adstreet," ",1)_"-"_$p(adstreet," ",3)
 .set adstreet=$p(adstreet," ",4,10)
 
 ;109- 111 Leytonstone road....
 if adstreet?1n.n1"-"1" "1n.n1" ".l.e do  q
 .set adbno=$p(adstreet," ",1)_$p(adstreet," ",2)
 .set adstreet=$p(adstreet," ",3,20)
 
 ;109a-111 Leytonstone road....
 if adstreet?1n.n1l1"-"1n.n1" "1l.e do  q
 .set adbno=$p(adstreet," ",1)
 .set adstreet=$p(adstreet," ",2,20)
 
 ;110haley road
 if adstreet?1n.n2l.l1" "2l.e do  q
 .n i
 .f i=1:1 q:$e(adstreet,i)'?1n  d
 ..set adbno=adbno_$e(adstreet,i)
 .set adstreet=$p(adstreet,adbno,2,10)
 
 ;1a 
 if adstreet?1n.n1l do  q
 .set adbno=adstreet
 .set adstreet=""
   
 ;99 a high street
 if adstreet?1n.n1" "1l1" ".e do  q
 .if $p(adstreet," ",2)="y" d
 ..set adbno=$p(adstreet," ",1)
 ..set adstreet=$p(adstreet," ",2,20)
 .e  d
 ..set adbno=$p(adstreet," ",1)_$p(adstreet," ",2)
 ..set adstreet=$p(adstreet," ",3,20)
 
 ;9a-11b high street
 if adstreet?1n.n1l1"-"1n.n1l1" ".l.e do  q
 .set adbno=$p(adstreet," ",1)
 .set adstreet=$p(adstreet," ",2,20)
 
 
 ;10-10a blurton road
 if adstreet?1n.n1"-"1n.n1l1" "1l.e d
 .set adbno=$P(adstreet," ",1)
 .set adstreet=$p(adstreet," ",2,20)
 
 ;99- high street
 if adstreet?1n.n1"-"1" "1l.e d
 .set adbno=$p(adbuild,"-",1)
 .set adstreet=$p(adstreet," ",2,20)
 
 ;westdown road 99
 i $p(adstreet," ",$l(adstreet," "))?1n.n d
 .s adbno=$p(adstreet," ",$l(adstreet," "))
 .s adstreet=$p(adstreet," ",0,$l(adstreet," ")-1)
 q
 
isroad(text)       ;
 n i,word,road
 s road=0
 f i=1:1:$l(text," ") d
 .s word=$p(text," ",i)
 .q:word=""
 .I $D(^UPRNS("ROAD",word)) s road=1
 q road
 
iscity(text)       ;
 n word,done
 s done=0
 s word=""
 for  s word=$O(^UPRNS("CITY",word)) q:word=""  d
 .i text[word s done=1
 q done
