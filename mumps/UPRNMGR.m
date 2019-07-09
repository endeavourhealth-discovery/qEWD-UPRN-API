UPRNMGR ; ;[ 06/10/2019  3:37 PM ]
 w !!,"A  - Run address match from file"
 W !!,"B  - Export results "
 W !!,"C  - Import Data "
 W !!,"Enter A or B  or C: "
 r *opt s opt=$$lc^UPRNL($c(opt))
 i opt'="a"&(opt'="b")&(opt'="c") G UPRNMGR
 i opt="a" D  G UPRNMGR
 .D ^UPRN4 i country="" G UPRNMGR
 .I '$d(^UPRN("D")) Q
 .D ^UPRN
 i opt="b" D ^UPRN2 G UPRNMGR
 i opt="c" D ^UPRN1 G UPRNMGR
 Q
LOAD(folder)       ;Triggers a load of ABP files (background)
 set found=$$8^ZOS(folder)
 if 'found set ^temp($j,1)="{""Response"":{""Error"":""Folder not found""}}" q
 LOCK ^IMPORT:1 I '$t D  Q
 .set ^temp($j,1)="{""Response"":{""Error"":""Import already in progress""}}"
 .quit
 LOCK
 J IMPORT^UPRN1(folder)
 set ^temp($j,1)="{""Response"":{""Success"":""Folder found attempting load""}}"
 q
STATUS() ;Returns the current status of the ABP load and indexing
 kill ^temp($j)
 
 i '$D(^IMPORT("FILE")) d  Q 1
 .set ^temp($j,1)="{""Status"":"_"""Load not commenced""}"
 .quit
 
 set ^temp($j,1)="{""Status"":{"
 I $G(^IMPORT("STATUS"))="ERROR" D  quit 1
 .set ^temp($j,1)=^temp($j,1)_"""Error"":{"
 .set ^temp($j,1)=^temp($j,1)_"""Error text"":"""_^IMPORT("ERRORTEXT")_""","
 .set ^temp($j,1)=^temp($j,1)_"""Debug error"":"""_^IMPORT("ERROR")_"""}}}"
 I $D(^IMPORT("END")) D  quit 1
 .set ^temp($j,1)=^temp($j,1)_"""Commenced"":"""_^IMPORT("START")_""","
 .set ^temp($j,1)=^temp($j,1)_"""Completed"":"""_^IMPORT("END")_"""}}"
 set ^temp($j,1)=^temp($j,1)_"""Commenced"":"""_^IMPORT("START")_""","
 set ^temp($j,1)=^temp($j,1)_"""Folder"":"""_^IMPORT("FOLDER")_""","
 I $D(^IMPORT("LOAD")) D
 .I $D(^IMPORT("FILE")) D
 ..s ^temp($j,1)=^temp($j,1)_"""Loading"":"""_^IMPORT("LOAD")_""",""File"":"""_^IMPORT("FILE")_"""}}"
 Q 1
 
GETUPRN(adrec,qpost,orgpost,country,summary) ;Returns the result of a matching request
 ;adrec is an address string with post code at the end
 ;qpost is list of post code areas (optional)
 ;orgpost is the post code of a local organisatoin to narrow down search
 k ^TUPRN($J)
 s adrec=$tr(adrec,",","~")
 s adrec=$tr(adrec,"""")
 s country=$$lc^UPRNL($g(country))
 s summary=$g(summary)
 I country="" s country="e"
 s country=$s($e(country)="e":"e",$e(country)="w":"w",1:"o")
 ;Checks for library update
 I '$D(^UPRNS("DROPSUFFIX")) D SETSWAPS^UPRNU
 ;Checks quality of address
 D ADRQUAL^UPRN(adrec,country)
 I '$D(^TUPRN($J,"INVALID")) D
 .D MATCHONE^UPRN(adrec,$g(qpost),$g(orgpost))
 E  D
 .S ^TUPRN($J,"NOMATCH")=""
 i summary d SUMMARY Q
 s json="{"
 ;Quality checks
 d QUALCHK(.json)
 d MATCHK(.json)
 s json=json_"}"
 w json
 set ^temp($j,1)=json
 q
SUMMARY ;Summary result
 s json="{"
 d MATCHK(.json,1)
 s json=json_"}"
 w json
 q
 s json=json_"""Matched"":"
 I $D(^TUPRN($J,"NOMATCH")) d  q
 .s json=json_"false}"
 i $D(^TUPRN($J,"MATCHED")) D
 .s json=json_"true,"
MATCHK(json,summary)       ;populates match details
 s json=json_"""Matched"":"
 I $D(^TUPRN($J,"NOMATCH")) D
 .s json=json_"false"
 e  d
 .s json=json_"true,"
 I $D(^TUPRN($J,"MATCHED")) D
 .s uprn=$o(^TUPRN($J,"MATCHED",""))
 .s table=$O(^TUPRN($j,"MATCHED",uprn,""))
 .s key=$O(^TUPRN($J,"MATCHED",uprn,table,""))
 .S matchrec=^TUPRN($j,"MATCHED",uprn,table,key)
 .s json=json_"""UPRN"":"""_uprn_""","
 .s json=json_"""Qualifier"":"""_$$qual^UPRN2(matchrec)_""""
 .I $D(^UPRN("CLASS",uprn)) d
 ..s json=json_",""Classification"":"""_$tr($p(^UPRN("CLASS",uprn),"~"),"""")_""","
 ..s json=json_"""Scheme"":"""_$tr($p(^UPRN("CLASS",uprn),"~",2),"""")_""""
 .I $G(summary) q
 .s json=json_","
 .s alg=^TUPRN($J,"MATCHED",uprn,table,key,"A")
 .D GETADR^UPRNU(uprn,table,key,.flat,.build,.bno,.depth,.street,.deploc,.loc,.town,.post,.org)
 .f var="build","depth","street","deploc","loc","town" d
 ..i @var'="" s @var=$$in^UPRNL(@var)
 .s post=$$repost^UPRN2(post)
 .s json=json_"""Algorithm"":"""_alg_""","
 .s json=json_"""ABPAddress"":{"
 .I flat'="" d
 ..s json=json_"""Flat"":"""_flat_""","
 .i build'="" d
 ..s json=json_"""Building"":"""_build_""","
 .i bno'="" d
 ..s json=json_"""Number"":"""_bno_""","
 .i depth'="" d
 ..s json=json_"""Dependent_thoroughfare"":"""_depth_""","
 .i street'="" d
 ..s json=json_"""Street"":"""_street_""","
 .i deploc'="" d
 ..s json=json_"""Dependent_locality"":"""_deploc_""","
 .i loc'="" d
 ..s json=json_"""Locality"":"""_loc_""","
 .i town'="" d
 ..s json=json_"""Town"":"""_town_""","
 .i post'="" d
 ..s json=json_"""Postcode"":"""_post_""","
 .i org'="" d
 ..s json=json_"""Organisaton"":"""_org_""","
 .i $e(json,$l(json))="," s json=$e(json,1,$l(json)-1)
 .s json=json_"},"
 .D PATTERN(matchrec,.json)
 q
PATTERN(matchrec,json)       ;
 n i,part,degree
 s json=json_"""Match_pattern"":{"
 f i=1:1:$l(matchrec,",") d
 .s part=$p(matchrec,",",i)
 .s degree=$e(part,2,3)
 .I degree="" q
 .s json=json_""""_$$part^UPRN2($e(part))_""":"
 .s json=json_""""_$$degree^UPRN2(degree)_""","
 i $e(json,$l(json))="," s json=$e(json,1,$l(json)-1)
 s json=json_"}"
 q
 
QUALCHK(json) ;Quality checks
 s json=json_"""Address_format"":"
 I $D(^TUPRN($J,"INVALID")) D
 .s json=json_""""_^TUPRN($J,"INVALID")_""","
 e  d
 .s json=json_"""good"","
 s json=json_"""Postcode_quality"":"
 i $d(^TUPRN($J,"POSTCODE")) D
 .s json=json_""""_^TUPRN($J,"POSTCODE")_""","
 E  D
 .s json=json_"""good"","
 Q
