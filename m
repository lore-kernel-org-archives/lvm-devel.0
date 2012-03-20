From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Mar 2012 17:38:48 -0000
Subject: LVM2 ./WHATS_NEW_DM daemons/dmeventd/libdevmap ...
Message-ID: <20120320173848.22420.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-20 17:38:48

Modified files:
	.              : WHATS_NEW_DM 
	daemons/dmeventd: libdevmapper-event.c 

Log message:
	Fix check for passed in path for dmeventd startup
	
	Check passed in executable path for dmeventd instead of predefined
	compiled in path which is not the thing to be executed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.595&r2=1.596
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50

--- LVM2/WHATS_NEW_DM	2012/03/15 08:45:55	1.595
+++ LVM2/WHATS_NEW_DM	2012/03/20 17:38:47	1.596
@@ -1,5 +1,6 @@
 Version 1.02.75 - 
 ================================
+  Properly support passed in dmevent path in dm_event_register_handler().
   Remove dmeventd fifos on exit if they are not managed by systemd.
   Use SD_ACTIVATION env. var. in systemd units to better detect systemd in use.
   Do not run a new dmeventd instance on restart if there's no existing one.
--- LVM2/daemons/dmeventd/libdevmapper-event.c	2012/03/12 14:46:53	1.49
+++ LVM2/daemons/dmeventd/libdevmapper-event.c	2012/03/20 17:38:47	1.50
@@ -440,8 +440,8 @@
       start_server:
 	/* server is not running */
 
-	if (!strncmp(DMEVENTD_PATH, "/", 1) && stat(DMEVENTD_PATH, &statbuf)) {
-		log_sys_error("stat", DMEVENTD_PATH);
+	if ((args[0][0] == '/') && stat(args[0], &statbuf)) {
+		log_sys_error("stat", args[0]);
 		return 0;
 	}
 


