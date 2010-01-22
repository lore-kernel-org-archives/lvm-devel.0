From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 22 Jan 2010 16:19:39 -0000
Subject: LVM2 ./WHATS_NEW scripts/cmirrord_init_red_hat.in
Message-ID: <20100122161939.8329.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-01-22 16:19:39

Modified files:
	.              : WHATS_NEW 
	scripts        : cmirrord_init_red_hat.in 

Log message:
	Fix syntax error in cmirror init script
	- break cannot be used here
	- remove CLVMDOPTS
	- add echo to stop call

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1404&r2=1.1405
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/cmirrord_init_red_hat.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/WHATS_NEW	2010/01/22 15:40:31	1.1404
+++ LVM2/WHATS_NEW	2010/01/22 16:19:38	1.1405
@@ -1,5 +1,6 @@
 Version 2.02.60
 ===================================
+  Fix syntax error in cmirror init script.
   Eliminate extra ioctls just to check open_count in _add_new_lv_to_dtree.
   Disable not thread-safe memory debugging if dmeventd is configured.
   Fix first log message prefix in syslog for dmeventd plugins.
--- LVM2/scripts/cmirrord_init_red_hat.in	2010/01/19 02:04:35	1.3
+++ LVM2/scripts/cmirrord_init_red_hat.in	2010/01/22 16:19:38	1.4
@@ -24,14 +24,10 @@
 	if ! pidof $DAEMON > /dev/null 
 	then 
 		echo -n "Starting $DAEMON: "
-		daemon $DAEMON $CLVMDOPTS
+		daemon $DAEMON
 		rtrn=$?
 		echo
-		if [ $rtrn -ne 0 ]
-		then
-			break
-		fi
-	fi      
+	fi
 
 	return $rtrn
 }
@@ -41,6 +37,7 @@
 	echo -n "Stopping $DAEMON:"
 	killproc $DAEMON -TERM
 	rtrn=$?
+	echo
 
 	return $rtrn
 }


