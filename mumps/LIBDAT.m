LIBDAT ;Library functions - Date [ 02/11/2000  6:20 PM ] ; 11/14/19 9:18am
 ;
 ;HSDT - convert $H to short date and time
HSDT(zx) Q $$HSD(zx)_" "_$$HST(zx)
 
 ;HST - convert $H to short time
HST(zx) Q $TR("1234","12:34",$$HT(zx,"STANDARD"))
 
 ;HSD - convert $H to short format
HSD(zx) Q:zx="11111" "NK" 
 I $P(zx,".",2)=3 Q $TR("'78","12.34.5678",$$HD(zx,"STANDARD"))
 I $P(zx,".",2)=2 Q $TR("34/78","12.34.5678",$$HD(zx,"STANDARD"))
 Q $TR("123478","12.34.5678",$$HD(zx,"STANDARD"))
 
HF(date) G HF1^LIBDAT1   ;$H to financial year
 
HADT(ZX) Q $$HAD(ZX)_" "_$S($P(ZX,",",2)="":"",1:$$HT($P(ZX,",",2)))
HDT(ZX) Q $$HD(ZX)_" "_$S($P(ZX,",",2)="":"",1:$$HT($P(ZX,",",2)))
 ;
 ;Time (hh:mm) to numeric ($H format)
TH(ZX) N h Q:ZX="" "" S h=$TR($J($P(ZX,":",1)*3600+($P(ZX,":",2)*60),5)," ",0)
 S:(ZX["P"!(ZX["p"))&(h<(13*3600)) h=h+(12*3600)
 Q h
 ;
 ;numeric ($H format) to Time (hh:mm)
HT(ZX,F) N ret Q:ZX="" ""  S ZX=$G(ZX,$H) S:ZX["," ZX=$P(ZX,",",2) 
 S ret=(ZX\3600)_":"_$TR($J(ZX\60#60,2)," ",0)
 I $G(F)="STANDARD" Q $TR($J($P(ret,":",1),2)," ",0)_":"_$P(ret,":",2)
 D:$G(F)
 . I $P(ret,":")>11 S ret=$S($P(ret,":")=12:12,1:$P(ret,":")-12)_":"_$P(ret,":",2)_"pm"
 . E  S ret=ret_"am"
 Q ret
 ;
 ;Convert $H format date to the day of the week
HDAY(ZX) Q $P("Thursday Friday Saturday Sunday Monday Tuesday Wednesday"," ",ZX#7+1)
HDAYNUM(ZX)        Q $P("4 5 6 7 1 2 3"," ",ZX#7+1)
 
HMON(ZX) Q $P("January February March April May June July August September October November December"," ",$P($$HD^LIBDAT(ZX,1),".",2))
 
NMON(ZX) Q $P("January February March April May June July August September October November December"," ",ZX)
 
 ;Date (as per CONFIG(SYSTEM)) to numeric ($H format)
DH(v,s) N d,m,y,f,%DN,ap,%DS,%4,%5
 Q:v="NK" "11111" Q:v="" "" S:v?1.2N1A.E v=$E(v,1,2)_" "_$E(v,3,255)
 Q:$E(v)="C" v Q:v?1"F"1P1N.N.E v
 S f=$$CONFIG^LIBSYS("SYSTEM",1,0),v=$TR(v,"/ ",".."),ap=""
 S f=$G(s,f)   ;allow "STANDARD" conversion CWS 20/8/93
 S d=$P(v,".",$S(f>5:2,1:1)),m=$P(v,".",$S(f>5:1,1:2)),y=$P(v,".",3)
 I m="" S y=d,m=1,d=1,ap=".3"
 E  I y="" S y=m,m=d,d=1,ap=".2"
 S:m'?.N m=$F("JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC",$$UC(m))\4
 S %DS=(+d)_"/"_(+m)_"/"_(+y)
 S %5=%DS 
 I m>12!(d>31) S %DS="" Q %DS
 S:y<100 y=20_y   ; KGM changed century
 S %DN=+m_"/"_+d_"/"_$S($E(y,1,2)="19":$E(y,3,4),1:y),%4=y-1\4-(y-1\100)+(y-1\400)-446,%DN=366*%4+(y-1841-%4*365)+d
 F %4=31,$S(y#4:28,y#100:29,y#400:28,1:29),31,30,31,30,31,31,30,31,30,31 S m=m-1 Q:m=0  S %DN=%DN+%4
 I $L(%DN)<5 S %DN=$E("0000",1,5-$L(%DN))_%DN
 I d'>%4*d>0 S %DS=%DN Q %DS_ap
 I d<32 s %DS=%DN Q %DN_ap   ; KGM
 S %DS="" Q %DS_ap
 ;HS - return standard format date for internal (dd.mm.yyyy)
HS(v) Q $$HD(v,"STANDARD")
 ;
 ;numeric ($H format) to day
HAD(v) Q $$NADJ^LIBSTR($P($$HD^LIBDAT(v),".",1))
 
CH(v) Q:$E(v)'="C" v 
 Q $$ADJUST(+$H,$P($P(v,"C",2),".",1),$P(v,".",2))_"."_$P(v,".",2)
 
CFH(v) Q:$E(v)'="F" v
 Q $$ADJUST(^ZZ("VDATENO"),$P($P(v,"C",2),"."),$P(v,".",2))_"."_$P(v,".",2)
 
HRD(d1) N ap S ap=+$P(d1,".",2)
 S d1=$TR("CcYyMmDd","Dd.Mm.CcYy",$$HD($P(d1,"."),"STANDARD"))
 Q $E($S(ap=2:$E(d1,1,6),ap=3:$E(d1,1,4),1:d1)_"00000000",1,8)
 
 
HCMP(d1,d2)  S d1=$$HRD(d1),d2=$$HRD(d2) Q $S(d1<d2:-1,d1>d2:+1,1:0)
 
HD(v,s) N p,ret,mons,dlm,prefix,param Q:v="" ""  Q:v="11111" "NK"
 I "CF"[$E(v) D  Q ret
 . N typ S typ=$P(v,".",2) S:typ="" typ=1
 . I $P(v,".")=($E(v)_"-1") S ret="Last" Q
 . I $P(v,".")=($E(v)_"+1") S ret="Next" Q
 . S ret="Current "_$P($P(v,$E(v),2),".")
 . Q
 Q:$G(s)="FULL" $$HDAY(v)_" "_$$NADJ^LIBSTR($P($$HD(v,"STANDARD"),".",1))_" "_$$HMON(v)_" "_$P($$HD(v,"STANDARD"),".",3)
 S p=$P(v,".",2),v=$P(v,".")
 S param=$S($ZV["Cache":4,1:3)
 I $ZV["Cache",(v>2980013) S v=0        ; default to 1840
 S ret=$TR($ZD(v,param),"/",".")
 S mons="Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec"
 S:v["," v=$P(v,",") 
 I v'<58074 S prefix="20"
 I v<58074 S prefix="19"
 S:$L($P(ret,".",3))=2 $P(ret,".",3)=prefix_$P(ret,".",3)
 ; KGM removed the $e from the lines below
 Q:$G(s)="FH" $P(ret,".")_"/"_$P(ret,".",2)_"/"_$P(ret,".",3)
 I $D(s) Q ret  ;S:p ret=$P(ret,".",p,3) Q ret
 X "S ret=$$HD"_$$CONFIG^LIBSYS("SYSTEM",1,0)_"(.dlm)"
 S:p ret=$P(ret,dlm,p,3)
 Q ret
HD0(dlm) S dlm="." Q ret
HD1(dlm) S dlm=" " Q $P(ret,".",1)_" "_$P(mons," ",$P(ret,".",2))_" "_$P(ret,".",3)
HD2(dlm) S dlm="/" Q $TR(ret,".","/")
HD6(dlm) S dlm="." Q $P(ret,".",2)_"."_$P(ret,".",1)_"."_$P(ret,".",3)
HD7(dlm) S dlm=" " Q $P(mons," ",$P(ret,".",2))_" "_$P(ret,".",1)_" "_$P(ret,".",3)
HD8(dlm) S dlm="/" Q $P(ret,".",2)_"/"_$P(ret,".",1)_"/"_$P(ret,".",3)
 ;
PERIOD(date1,date2,format) G PERIOD^LIBDAT1
 
DPLUS(date,off) G DPLUS^LIBDAT1
 
 ;CWS 11/8/93
 ;add days/months/years to a given date
ADJUST(date1,offset,format)  G ADJUST^LIBDAT1
 
 ;ASCII date to $H  
AH(ZX) Q:$E(ZX,1,5)="3'!""#" "11111" Q:$E(ZX,1,5)="@%!,>" "11111"
 N d,m,y,%DN,%DS,ap S d=$A(ZX,5)-33,m=$A(ZX,4)-33
 S y=$A(ZX,1)-33_($A(ZX,2)-33)_($A(ZX,3)-33)
 I y>2500 S y=5000-y S m=12-m S d=$S(y#4!(y=1900):$P("31 28 31 30 31 30 31 31 30 31 30 31"," ",m)-d,1:$P("31 29 31 30 31 30 31 31 30 31 30 31"," ",m)-d)
 Q:m=0&(d=0)&(y=0) 0
 s ap=""
 i d=0 s ap=.2,d=1
 i m=0 s ap=.3,m=1
 S %DS=(+m)_"/"_(+d)_"/"_(+y)
 S %5=%DS 
 I m>12!(d>31) S %DS="" Q %DS
 S:y<100 y=20_y   ; KGM changed to 20 from 19
 S %DN=+m_"/"_+d_"/"_$S($E(y,1,2)="19":$E(y,3,4),1:y),%4=y-1\4-(y-1\100)+(y-1\400)-446,%DN=366*%4+(y-1841-%4*365)+d
 F %4=31,$S(y#4:28,y#100:29,y#400:28,1:29),31,30,31,30,31,31,30,31,30,31 S m=m-1 Q:m=0  S %DN=%DN+%4
 I $L(%DN)<5 S %DN=$E("0000",1,5-$L(%DN))_%DN
 I d'>%4*d>0 S %DS=%DN Q %DS_ap
 S %DS="" Q %DS
 
 
DA(ZX) Q:ZX="NK" "3'!""#"
 Q:ZX["nknown" "3'!""#"
 Q $$HA($$DH(ZX))
 
 ;$H format to ASCII
HA(ZX) N d,ap,v,param
 S v=$P(ZX,".")
 s ap=$p(ZX,".",2)
 S param=$S($ZV["Cache":4,1:3)
 I $ZV["Cache",(v>2980013) S v=0        ; default to 1840
 ;KGM added FH parameter next line 
 S d=$TR($$HD(v,"FH"),".","/")
 i $p(d,"/",3)?2N S $P(d,"/",3)=20_$p(d,"/",3)
 s d=$P(d,"/",1)_"/"_$p(d,"/",2)_"/"_$p(d,"/",3)
 i ap>1 s $p(d,"/")=0
 i ap=3 s $p(d,"/",2)=0
 Q $C($E($P(d,"/",3),1,2)+33)_$C($E($P(d,"/",3),3)+33)_$C($E($P(d,"/",3),4)+33)_$C($P(d,"/",2)+33)_$C($P(d,"/",1)+33)
 
 ;$H format to reverse ASCII
HR(ZX) Q:ZX="11111" "@%!,>" Q $$RV^LIB($$HA(ZX))
 
 ; Ascii to real date
AD(ZX) Q:ZX="3'!""#" "NK" Q:ZX="" "" Q $$HD($$AH(ZX))
 
 ;$H to elapsed minutes
HMIN(V) Q $P(($P(V,",",1)*1440)+($P(V,",",2)/60),".")
 
 ;$H to elapsed seconds
HSEC(V) Q ($P(V,",",1)*1440*60)+$P(V,",",2)
 ;
UC(V) Q $TR(V,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
 
 ;convert from $H to CCYYMMDD format
DATSTR(hdate) 
 Q:hdate="" "" N date S date=$$HD(hdate,"STANDARD")
 Q $P(date,".",3)_$P(date,".",2)_$P(date,".",1)
 
 ;convert from CCYYMMDD to $H format
STRDAT(strdate) 
 Q:strdate="" ""
 Q $$DH($E(strdate,7,8)_"."_$E(strdate,5,6)_"."_$E(strdate,1,4),"STANDARD")
 
RH(V) Q $$STRDAT(V)
RD(V) Q $$HD($$STRDAT(V))    
 
 ; convert from 2nd $H piece format into HHMM format
TIMSTR(htime) 
 i htime>86399 s htime=htime#86400          ;MH 17/5/96
 ;i htime>83999 s htime=htime#84000
 Q:htime="" "" Q $TR($J($TR($$HT(htime),":"),4)," ",0)
 
 ; convert from HHMM to 2nd $H piece format
STRTIM(strtime) 
 Q:strtime="" "" Q $$TH($E(strtime,1,2)_":"_$E(strtime,3,4))
 
HOLD(ZX,ZY) ;Date from $H format
 N %D,%I,%LY,%M,%R,%Y,%NP
20 S ZX=ZX>21914+ZX
 S %LY=ZX\1461,%R=ZX#1461,%Y=%LY*4+1841+(%R\365),%D=%R#365,%M=1
 I %R=1460,%LY'=14 S %D=365,%Y=%Y-1
 F %I=31,(%R>1154)&(%LY'=14)+28,31,30,31,30,31,31,30,31,30 Q:%I'<%D  S %M=%M+1,%D=%D-%I
 I %D=0 S %Y=%Y-1,%M=12,%D=31
 ;KGM removed next line
 ;I $E(%Y,1,2)="19" S %Y=$E(%Y,3,4)
 I $D(ZY) S ZX=%M_"/"_%D_"/"_%Y Q ZX
 S ZX=%D_"."_%M_"."_%Y Q ZX
 Q ZX
 
 ;Take a $H format date and return the $H of the last day of the month
HL(v) N d,m,y S d=$$HD(v,"STANDARD"),m=$P(d,".",2)+1,y=$P(d,".",3)
 Q $P($$DH^LIBDAT($S(m=13:"1."_(y+1),1:m_"."_y)),".")-1
 
TM() Q $$HT($H)
TD() Q $$HD($H)
 
 ;For any format of date return the last day in the month
 ; $H    mmm yy    dd.mm.yy     dd/mm/yy   f/h period    etc
DL(date,fmt) S:date?3N date=$E(^ZPERMTH(date),1,3)_" "_$E(^ZPERMTH(date),4,5)
 S:date'?1N.N.".".N date=$$DH(date)
 S date=$$HD^LIBDAT(date,"STANDARD")
 S dlm=$S($G(fmt)="FH":"/",1:".")
 Q $P("31~"_(28+'($P(date,".",3)#4))_"~31~30~31~30~31~31~30~31~30~31","~",$P(date,".",2))_dlm_$P(date,".",2)_dlm_$P(date,".",3)
 
 ;Return f/h period number for $H format date
HP(v) Q $$UPN(v)   ;($P($ZD(v,3),"/",3)*12)+$P($ZD(v,3),"/",2)-995   
 
 ;UF - Unknown to financial year
UF(v) N year,dh Q:v?4N v 
 ;S dh=$$UH($S(v?1"F".E1".3":"F.1",1:v))
 S dh=$$FH(v)
 S year=$$HF^LIBDAT($S(dh=v:v,1:$P(dh,".",1)))
 I v?1U1"-"1N1"."1N S year=year+$E($P(v,".",1),2,255)
 Q year
 
 ;Convert unknown format to expanded date
UD(v,s) Q $$HD($$UH(v),.s)
 
UH(v,f) I v="" Q ""
 S:v["/" v=$TR(v," ")
 S:v["." v=$TR(v," ")  ; -AJL
 I v?1"C"0.1P.N.E S ret=$$HH(v) G UHx                ; C+/-NN format    
 I v?1"F"1E1N.N.E S ret=$$HH(v) G UHx                ; F+/-NN format
 I v?3N Q $$FH($$FPX(v))   ;$$DH^LIBDAT($TR("ABC DE","ABCDE",$$FPX(v))) G UHx ; FH per
 I v?4N S ret=$$DH(v) G UHx                          ; yyyy
 I v?1N.N1"Y" S ret=$$ADJUST($H,-v,$P(v,+v,2)) G UHx   ; age in years
 I v?1N.N1"M" S ret=$$ADJUST($H,-v,$P(v,+2,2)) G UHx   ; age in months
 I v?1N.N1"D" S ret=$$ADJUST($H,-v,$P(v,+2,2)) G UHx   ; age in days
 I v?1N.N1"W" S ret=$$ADJUST($H,-v,$P(v,+2,2)) G UHx   ; age in weeks 
 I v?1N.N1","1N.N S ret=v G UHx                      ; full $H
 I v?1N.N0.1"."0.1N S ret=v G UHx                    ; part $H
 I v?3U2N Q $$FH(v)   ;S ret=$$DH($TR("ABC DE","ABCDE",v)) G UHx   ; mmmyy
 I v?1.2N1P1.4N S ret=$$DH(v) G UHx                  ;mm?yy
 I v?1.2N1P1.2N1P1.4N S ret=$$DH(v) G UHx             ;nn?mm?yy
 I v?1.2N1P1.3U1P1.4N D  S ret=$$DH(v) G UHx          ;nn?MMM?yy
 . S v=$TR(v," ") F i=1:1:$L(v) S:$E(v,i)?1P $E(v,i)=" "
 S ret=$$AH(v)                                      ; ascii (or reverse)
UHx Q:$G(f)="M" $$DH($$HD($P(ret,".",1)_".2"))
 Q:$G(f)="Y" $$DH($$HD($P(ret,".",1)_".3"))
 Q ret
 
 ;Covert Current/Last etc date format to $H
 ;f = "M" - force to months
 ;f = "Y" - force to years
HH(v,f) N new,adj 
 I $E(v)="C" D
 . S adj=$P(v,".",2) S typ=$S(adj=3:"Y",adj=2:"M",1:"D")
 . S v=$$ADJUST(+$H,$P($P(v,".",1),"C",2),typ)_"."_adj
 I $E(v)="F" D
 . S adj=$P(v,".",2) S typ=$S(adj=3:"Y",adj=2:"M",1:"D")
 . S v=$$ADJUST(^ZZ("VDATENO"),$P($P(v,".",1),"F",2),typ)_"."_adj
 I $G(f)="M" Q $$DH($$HD($P(v,".",1)_".2"))
 I $G(f)="Y" Q $$DH($$HD($P(v,".",1)_".3"))
 Q $$DH($$HD(v))
 
UPN(zx) G UPN1^LIBDAT1   ;Unknown format to fundholding period number
 
UPX(zx) G UPX1^LIBDAT1   ;Unkown format to fundholding period name
 
FPX(n) G FPX1^LIBDAT1   ;Convert fundholding period number to its expansion MMMYY
 
UYP(zx) G UYP1^LIBDAT1   ;Convert unknown to first period of financial year
 
 ;HFH - $H to fundholding format date
HFH(zx) N i,date
 S date=$S(zx="":"",1:$TR("dD/mM/yY","dD.mM.19yY",$$HD(zx,"STANDARD")))
 F i=1,4 S:$E(date,i)=0 $E(date,i)=" "
 Q date
 
FH(date) G FH1^LIBDAT1
 
MF(date) G MF1^LIBDAT1
