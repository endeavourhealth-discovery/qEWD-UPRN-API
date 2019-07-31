PS ; ; 7/27/19 1:14pm
 K ^PS
 S (A,B)=""
 F  S A=$O(^UPRN(A)) Q:A=""  D
 .F  S B=$O(^UPRN(A,B)) Q:B=""  D
 ..S ^PS(A)=$G(^PS(A))+1
 ..Q
 .QUIT
 QUIT
