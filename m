From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 2 Mar 2011 23:38:23 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c
Message-ID: <20110302233823.21409.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-03-02 23:38:22

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 

Log message:
	Fix syslog initialisation in clvmd to respect lvm.conf setting.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1933&r2=1.1934
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114

--- LVM2/WHATS_NEW	2011/03/02 20:00:09	1.1933
+++ LVM2/WHATS_NEW	2011/03/02 23:38:22	1.1934
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Fix syslog initialisation in clvmd to respect lvm.conf setting.
   Fix possible overflow in maximum stripe size and physical extent size.
   Add test for failed allocation from dm_task_set_uuid() in dmeventd.
   Improve pvremove error message when PV belongs to a VG.
--- LVM2/daemons/clvmd/lvm-functions.c	2011/02/18 14:16:11	1.113
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/03/02 23:38:22	1.114
@@ -915,6 +915,10 @@
 /* Called to initialise the LVM context of the daemon */
 int init_clvm(int using_gulm, char **argv)
 {
+	/* Use LOG_DAEMON for syslog messages instead of LOG_USER */
+	init_syslog(LOG_DAEMON);
+	openlog("clvmd", LOG_PID, LOG_DAEMON);
+
 	if (!(cmd = create_toolcontext(1, NULL))) {
 		log_error("Failed to allocate command context");
 		return 0;
@@ -925,9 +929,6 @@
 		return 0;
 	}
 
-	/* Use LOG_DAEMON for syslog messages instead of LOG_USER */
-	init_syslog(LOG_DAEMON);
-	openlog("clvmd", LOG_PID, LOG_DAEMON);
 	cmd->cmd_line = "clvmd";
 
 	/* Check lvm.conf is setup for cluster-LVM */


