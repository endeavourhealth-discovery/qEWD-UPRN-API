UPRNHOOK	;
LOAD(folder)
	set ^FOLDER=folder
	kill ^temp($j)
	set ^temp($j,1)="{""Response"": {""Error"": ""Folder not found""}}"
	quit 1
	
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