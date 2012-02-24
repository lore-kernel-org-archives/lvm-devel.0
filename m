From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 24 Feb 2012 13:45:37 -0000
Subject: LVM2/scripts lvm2_lvmetad_init_red_hat.in
Message-ID: <20120224134537.13828.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-24 13:45:37

Modified files:
	scripts        : lvm2_lvmetad_init_red_hat.in 

Log message:
	Use '-p PID_FILE' for the status call since the pidfile is in its own lvm subdir and return proper status code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_lvmetad_init_red_hat.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/scripts/lvm2_lvmetad_init_red_hat.in	2012/02/24 13:11:57	1.2
+++ LVM2/scripts/lvm2_lvmetad_init_red_hat.in	2012/02/24 13:45:37	1.3
@@ -41,10 +41,11 @@
 lvm_vgscan=${sbindir}/vgscan
 
 LOCK_FILE="/var/lock/subsys/$DAEMON"
+PID_FILE="@DEFAULT_RUN_DIR@/${DAEMON}.pid"
 
 
 rh_status() {
-	status $DAEMON
+	status -p $PID_FILE $DAEMON
 }
 
 rh_status_q() {
@@ -62,7 +63,7 @@
 stop()
 {
 	ret=0
-	action "Signaling LVM metadata daemon to exit:" kill -TERM $(pidofproc $DAEMON) || ret=$?
+	action "Signaling LVM metadata daemon to exit:" kill -TERM $(pidofproc -p $PID_FILE $DAEMON) || ret=$?
 	return $ret
 }
 
@@ -102,7 +103,8 @@
 	;;
 
   status)
-	status $DAEMON
+	rh_status
+	rtrn=$?
 	;;
 
   *)


