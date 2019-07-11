START ;
	D ^UPRNUI,SETUP^UPRNHOOK2
	w !,"starting web server"
	j START^VPRJREQ(9080,"","dev")
	w !,"check htop"
	quit
