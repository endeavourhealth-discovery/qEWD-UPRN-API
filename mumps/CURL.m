CURL ; ; 7/24/19 8:43am
 ; key-cloak user validation
VALTOKEN(token) 
 new cmd,json,b
 
 set ^TOKEN=token
 
 set endpoint=$get(^ICONFIG("USERINFO-ENDPOINT"))
 if endpoint="" quit 0
 
 if $piece(token," ")'="Bearer" set token="Bearer "_token
 
 set cmd="curl -s -X POST -i -H ""Authorization: "_token_""" "_endpoint_" > /tmp/a"_$job_".txt"
 ;w !,cmd
 
 zsystem cmd
 
 set json=$$TEMP("/tmp/a"_$job_".txt")
 d DECODE^VPRJSON($name(json),$name(b),$name(err))
 
 if '$data(b("sub")) quit 0
 quit 1
 
 ; use this code to generate a token for testing
GETTOKEN(user,clientid,pass,endpoint) ;
 new cmd,b,token,json
 set cmd="curl -s -X POST -i -H ""Content-Type: application/x-www-form-urlencoded"""
 set cmd=cmd_" -d ""client_id="_clientid_""" -d ""username="_user_""" -d ""password="_pass_""" -d ""grant_type=password"" "
 set cmd=cmd_endpoint_" > /tmp/b"_$job_".txt"
 
 zsystem cmd
 
 set json=$$TEMP("/tmp/b"_$j_".txt")
 D DECODE^VPRJSON($name(json),$name(b),$name(err))
 set token=$get(b("access_token"))
 quit token
 
TEMP(file) 
 new z,data,ret,i
 set data=""
 o file:(readonly):0
 for i=1:1 use file read z q:$zeof  s data(i)=z
 close file
 S ret=$get(data(i-1))
 
 zsystem "rm "_file
 
 quit ret
