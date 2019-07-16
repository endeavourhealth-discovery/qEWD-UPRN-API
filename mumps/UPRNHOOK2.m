UPRNHOOK2	;
LOAD(folder)
	set ^FOLDER=folder
	kill ^temp($j)
	set ^temp($j,1)="{""Response"": {""Error"": ""Folder not found""}}"
	quit 1

SETUP	;
	S ^%W(17.6001,"B","GET","api/getinfo","GETMUPRN^UPRNHOOK2",100)=""
	S ^%W(17.6001,100,"AUTH")=1
	S ^%W(17.6001,100,0)="GET"
	S ^%W(17.6001,100,1)="api/getinfo"
	S ^%W(17.6001,100,2)="GETMUPRN^UPRNHOOK2"
	quit
	
	; M Web server hook
	; http://192.168.59.134:9080/api/getinfo?adrec=Crystal Palace football club, SE25 6PU
	; TEST
GETMUPRN(result,arguments)
	K ^TMP($J)
	
	;set token=$get(HTTPREQ("header","authorization"))
	;if token="" S HTTPERR=500 D SETERROR^VPRJRUT("500","undefined") quit
	;set token=$piece(token,"Bearer ",2)
	;if '$data(^TOKEN(token)) S HTTPERR=500 D SETERROR^VPRJRUT("500","undefined") quit

	set adrec=$Get(arguments("adrec"))
	set qpost=$Get(arguments("qpost"))
	set country=$Get(arguments("country"))
	set summary=$Get(arguments("summary"))
	set orgpost=$Get(arguments("orgpost"))
	D GETUPRN^UPRNMGR(adrec,qpost,orgpost,country,summary)
	set result("mime")="application/json, text/plain, */*"
	S ^TMP($J,1)=^temp($J,1)
	set result=$na(^TMP($j))
	quit
	
	; qEWD Web server hook	
GETUPRN(adrec,qpost,orgpost,country,summary)
	kill ^temp($j)
	set adrec=$get(adrec)
	set qpost=$get(qpost)
	set orgpost=$get(orgpost)
	set country=$get(country)
	set summary=$get(summary)
	; GETUPRN(adrec,qpost,orgpost,country,summary) ;Returns the result of a matching request
	S ^HOOK=adrec_"~"_qpost_"~"_orgpost_"~"_country_"~"_summary
	;set ^temp($j,1)="{""Address_format"": ""good"",""Postcode_quality"": ""good"",""Matched"": true,""UPRN"": 100023136739,""Qualifier"": ""Child"",""Algorithm"": ""120-match2b"",""ABPAddress"": {""Number"": 133,""Street"": ""Shepherdess Walk"",""Town"": ""London"",""Postcode"": ""N1 7QA""},""Match_pattern"": {""Postcode"": ""equivalent"",""Street"": ""equivalent"",""Number"": ""equivalent"",""Building"": ""equivalent"",""Flat"": ""matched as child""}}"
	;D GETUPRN^UPRNMGR("Yvonne carter Building,58 turner street,london,E1 2AB","","","england")
	D GETUPRN^UPRNMGR(adrec,qpost,orgpost,country,summary)
	quit 1
	
STATUS()
	k ^temp($j)
	set ^temp($j,1)="{""Status"": {""Commenced"": ""2019-06-09T12:33"",""Completed"": ""2019-06-09T14:33""}}"
	quit 1
