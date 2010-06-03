From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 3 Jun 2010 21:03:54 -0000
Subject: LVM2 ./WHATS_NEW scripts/clvmd_init_red_hat.in
Message-ID: <20100603210354.32723.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-06-03 21:03:54

Modified files:
	.              : WHATS_NEW 
	scripts        : clvmd_init_red_hat.in 

Log message:
	Fix clvmd initscript restart command to start clvmd if not yet running.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1605&r2=1.1606
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/clvmd_init_red_hat.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/WHATS_NEW	2010/06/03 13:50:26	1.1605
+++ LVM2/WHATS_NEW	2010/06/03 21:03:53	1.1606
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Fix clvmd initscript restart command to start clvmd if not yet running.
   Use absolute paths for clvmd restart.
   Require partial option in lvchange --refresh for partial LVs.
   Do not fail lvm_init() if init_logging() or _init_rand() generates an errno.
--- LVM2/scripts/clvmd_init_red_hat.in	2010/05/17 03:18:28	1.7
+++ LVM2/scripts/clvmd_init_red_hat.in	2010/06/03 21:03:54	1.8
@@ -152,13 +152,15 @@
 
 	# Try to get clvmd to restart itself. This will preserve 
 	# exclusive LV locks
-	action "Restarting $DAEMON: " $DAEMON -S || return $?
+	action "Restarting $DAEMON: " $DAEMON -S
 
 	# If that fails then do a normal stop & restart
 	if  [ $? != 0 ]; then
 	    stop && start
+	    return $?
 	else
 	    touch $LOCK_FILE
+	    return 0
 	fi
 }
 


