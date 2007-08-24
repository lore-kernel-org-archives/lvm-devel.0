From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 24 Aug 2007 08:29:41 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c
Message-ID: <20070824082941.5534.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2007-08-24 08:29:40

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 

Log message:
	Fix clvmd logging so you can get lvm-level debugging out of it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.694&r2=1.695
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/WHATS_NEW	2007/08/23 15:02:26	1.694
+++ LVM2/WHATS_NEW	2007/08/24 08:29:39	1.695
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Fix clvmd logging so you can get lvm-level debugging out of it.
   Introduce VG_GLOBAL lock type for vgscan/pvscan to trigger clvmd -R.
   Fix clvmd -R, so it fully refreshes the caches.
   Change lvconvert_mirrors to use mirror segtype not striped.
--- LVM2/daemons/clvmd/lvm-functions.c	2007/08/23 12:44:09	1.33
+++ LVM2/daemons/clvmd/lvm-functions.c	2007/08/24 08:29:39	1.34
@@ -548,6 +548,15 @@
 static void lvm2_log_fn(int level, const char *file, int line,
 			const char *message)
 {
+
+	/* Send messages to the normal LVM2 logging system too,
+	   so we get debug output when it's asked for. 
+ 	   We need to NULL the function ptr otherwise it will just call
+	   back into here! */
+	init_log_fn(NULL);
+	print_log(level, file, line, "%s", message);
+	init_log_fn(lvm2_log_fn);
+
 	/*
 	 * Ignore non-error messages, but store the latest one for returning
 	 * to the user.
@@ -601,7 +610,10 @@
 
 	/* Use LOG_DAEMON for syslog messages instead of LOG_USER */
 	init_syslog(LOG_DAEMON);
-	init_debug(_LOG_ERR);
+	openlog("clvmd", LOG_PID, LOG_DAEMON);
+	init_debug(cmd->current_settings.debug);
+	init_verbose(cmd->current_settings.verbose + VERBOSE_BASE_LEVEL);
+	set_activation(cmd->current_settings.activation);
 
 	/* Check lvm.conf is setup for cluster-LVM */
 	check_config();


