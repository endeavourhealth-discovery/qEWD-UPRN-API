ET	; write error to console and log error in ^ZERROR
	new I,J,H,ze,i
	kill ^temp($j)
	set H=$Horolog
	set ^ZERROR(H)=$ZSTATUS
    for I=$STACK(-1):-1:1 DO
    .for J="PLACE","MCODE","ECODE" do 
	..set ^ZERROR(H,I,J)=$STACK(I,J)
	set ^temp($j,"error",1)="**ErRoR: "_$ZSTATUS
	
	set i=$order(^ZERROR(H,""),-1)
	S ze="" if i'="" set ze=$get(^ZERROR(H,i,"MCODE"))
	
	S ^IMPORT("STATUS")="ERROR"
	S ^IMPORT("ERROR")=$TR(ze,"""","'")
	S ^IMPORT("ERRORTEXT")=$ZSTATUS
	
    set $ECODE="",$ZTRAP=""
	
	QUIT 1
	
START	;
 K ^IMPORT
 s abp="/tmp"
 S ^IMPORT("LOAD")="Counties"
 s file=abp_"/Counties.txt"
 S ^IMPORT("FILE")=$$ESCAPE^UPRN1(file)
 S ^IMPORT("START")=$$DH^UPRNL1($H)_"T"_$$TH^UPRNL1($P($H,",",2))
 s ^IMPORT("FOLDER")=$$ESCAPE^UPRN1(abp)
 quit
 
END	;
 K ^IMPORT
 s abp="/tmp"
 s file=abp_"/Counties.txt"
 S ^IMPORT("FILE")=$$ESCAPE^UPRN1(file)
 S ^IMPORT("START")=$$DH^UPRNL1($H)_"T"_$$TH^UPRNL1($P($H,",",2))
 s ^IMPORT("FOLDER")=$$ESCAPE^UPRN1(abp)
 W !,"Hanging 10 secs"
 H 10
 S ^IMPORT("END")=$$DH^UPRNL1($H)_"T"_$$TH^UPRNL1($P($H,",",2))
 quit