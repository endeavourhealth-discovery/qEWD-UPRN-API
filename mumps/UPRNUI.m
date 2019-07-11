UPRNUI	;
	set ^%W(17.6001,"B","GET","ui/login","LOGIN^UPRNUI",0)=""
	set ^%W(17.6001,"B","POST","check/login","CHECK^UPRNUI",8)=""
	set ^%W(17.6001,"B","POST","ui/calculate","CALC^UPRNUI",8)=""
	quit
	
LOGIN(result,arguments)	;
	kill ^TMP($J)
	d H("<html>")
	d H("<form action=""https://apiuprn.discoverydataservice.net:8443/check/login"" method=""post"">")
	;http://10.0.101.22:9080
	;d H("<form action=""http://10.0.101.22:9080/check/login"" method=""post"">")
	d H("<table border=1>")
	d H("<td>UserName:</td><td><input type=""text"" name=""username"" /></td><tr>")
	d H("<td>Password:</td><td><input type=""password"" name=""pwd"" /></td><tr>")
	d H("<td><input type=""submit""></td><td></tr><tr>")
	d H("</table>")
	d H("</form>")
	d H("</html>")
	
	set result("mime")="text/html"
	set result=$na(^TMP($J))
	quit

CALC(arguments,body,result)	;
	new data,a
	K ^TMP($J),^BODY
	M ^BODY=body

	S data=""
	f i=1:1:$o(body(""),-1) set ^TMP($J,i)=body(i)_"<br>",data=data_body(i)
	s i=i+1
	;s ^TMP($J,i)="<b>ZWR ^BODY</b>"

	K ^TMP($J)
	;S ^TMP($J,1)=$$REL(data)
	
	set cnt=1,data=$$REL(data)
	F i=1:1:$L(data,$c(13)) set:$p(data,$c(13),i)'=$C(10) a(cnt)=$p(data,$c(13,10),i),cnt=cnt+1
	
	s zi=""
	f  s zi=$o(a(zi)) q:zi=""  do
	.s adrec=a(zi)
	.D GETUPRN^UPRNMGR(adrec)
	.s json=^temp($j,1)
	.K B,C
	.D DECODE^VPRJSON($name(json),$name(B),$name(C))
	.set UPRN=$GET(B("UPRN"))
	.S ^TMP($J,cnt)=adrec_" = "_UPRN_"<BR>"
	.S cnt=cnt+1
	.quit

	set result("mime")="text/html"
	set result=$na(^TMP($J))
	Q 1
	
CHECK(arguments,body,result)	;
	k ^TMP($J)
	M ^BODY=body
	f i=1:1:$o(body(""),-1) set ^TMP($J,i)=body(i)_"<br>"
	s i=i+1
	s ^TMP($J,i)="<b>end</b>"
	
	;set result("mime")="text/html"
	;set result=$na(^TMP($J))
	;m ^A=^TMP($J)
	; check the username/password

	kill ^TMP($J)

	d H("<html>")
	d H("<form action=""https://apiuprn.discoverydataservice.net:8443/ui/calculate"" method=""post"">")
	d H("<textarea rows=""4"" cols=""50"" name=""addrlines"">")
	d H("Yvonne carter Building,58 turner street,london,E1 2AB"_$C(10))
	d H("top flat,133 shepherdess walk,,london,,n17qa"_$C(10))
	d H("5 uferstrasse,,,stuebach,Germany,g1 4sg"_$C(10))
	d H("Crystal Palace football club,  SE25 6PU"_$C(10))
	d H("10 Downing St,Westminster,London,SW1A2AA"_$C(10)) 
	d H("</textarea>")
	
	d H("<input type=""submit"">")
	d H("</form>")
	d H("</html>")

	set result("mime")="text/html"
	set result=$na(^TMP($J))
	quit 1
	
H(H)	;
	n c
	s c=$order(^TMP($J,""),-1)+1
	s ^TMP($J,c)=H_$c(13)_$c(10)
	quit

TR(ZX,ZY,ZZ) ;Extrinsix function to translate a string [ 01/19/92  5:03 PM ]
         ;ZX is the variable
         ;ZY is the string to translate
         ;ZZis the string to tranlsate to
         N ZW
         S ZW=0
         FOR  S ZW=$F(ZX,ZY,ZW) Q:ZW=0  S ZW=ZW-$L(ZY)-1 S ZX=$E(ZX,0,ZW)_ZZ_$E(ZX,ZW+$L(ZY)+1,99999),ZW=ZW+$L(ZZ)+1
         Q ZX

REL(data)
         S data=$$TR(data,"+"," ")
         D HEX
         S A=""
         F  S A=$O(^TOPT($J_"HEX",A)) Q:A=""  D
         .S HEX=$P(A,"%",2)
	 .;W $$FUNC^%HD("2C")
         .S data=$$TR(data,A,$C($$FUNC^%HD(HEX)))
         .Q
         Q data

HEX      K ^TOPT($J_"HEX")
	 ; %0D%0A%0D%0A
	 S ^TOPT($J_"HEX","%0D")="",^TOPT($J_"HEX","%0A")=""
         S ^TOPT($J_"HEX","%20")="",^TOPT($J_"HEX","%C2")=""
         S ^TOPT($J_"HEX","%22")="",^TOPT($J_"HEX","%A3")=""
         S ^TOPT($J_"HEX","%3D")="",^TOPT($J_"HEX","%2B")=""
         S ^TOPT($J_"HEX","%5E")="",^TOPT($J_"HEX","%7E")=""
         S ^TOPT($J_"HEX","%2F")="",^TOPT($J_"HEX","%28")=""
         S ^TOPT($J_"HEX","%29")="",^TOPT($J_"HEX","%2C")=""
         S ^TOPT($J_"HEX","%26")="",^TOPT($J_"HEX","%21")=""
         S ^TOPT($J_"HEX","%5B")="",^TOPT($J_"HEX","%5D")=""
         S ^TOPT($J_"HEX","%3F")="",^TOPT($J_"HEX","%24")=""
         S ^TOPT($J_"HEX","%25")="",^TOPT($J_"HEX","%7B")=""
         S ^TOPT($J_"HEX","%7D")="",^TOPT($J_"HEX","%5C")=""
         S ^TOPT($J_"HEX","%23")="",^TOPT($J_"HEX","%3A")=""
         S ^TOPT($J_"HEX","%3B")="",^TOPT($J_"HEX","%27")=""
         S ^TOPT($J_"HEX","%3C")="",^TOPT($J_"HEX","%3E")=""
         Q