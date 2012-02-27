From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 27 Feb 2012 08:56:47 -0000
Subject: LVM2/scripts lvm2_lvmetad_init_red_hat.in
Message-ID: <20120227085647.9355.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-27 08:56:46

Modified files:
	scripts        : lvm2_lvmetad_init_red_hat.in 

Log message:
	Use 'killproc' fn in lvmetad init script (fn provided by 'functions' init script library).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_lvmetad_init_red_hat.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/scripts/lvm2_lvmetad_init_red_hat.in	2012/02/24 13:45:37	1.3
+++ LVM2/scripts/lvm2_lvmetad_init_red_hat.in	2012/02/27 08:56:46	1.4
@@ -63,7 +63,7 @@
 stop()
 {
 	ret=0
-	action "Signaling LVM metadata daemon to exit:" kill -TERM $(pidofproc -p $PID_FILE $DAEMON) || ret=$?
+	action "Signaling LVM metadata daemon to exit:" killproc -p $PID_FILE $DAEMON -TERM || ret=$?
 	return $ret
 }
 


