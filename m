From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Sep 2009 15:53:59 -0000
Subject: LVM2 ./WHATS_NEW_DM doc/example.conf tools/dms ...
Message-ID: <20090911155359.9230.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-09-11 15:53:58

Modified files:
	.              : WHATS_NEW_DM 
	doc            : example.conf 
	tools          : dmsetup.c 

Log message:
	Add y|--yes option for dmsetup to provide a default 'YES' answer to questions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.296&r2=1.297
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.123&r2=1.124

--- LVM2/WHATS_NEW_DM	2009/09/11 15:52:22	1.296
+++ LVM2/WHATS_NEW_DM	2009/09/11 15:53:57	1.297
@@ -1,5 +1,6 @@
 Version 1.02.37 -
 =================================
+  Add y|--yes option for dmsetup to provide a default 'YES' answer to questions.
   Fix Makefile to take into account dmsetup's reconfiguration.
   Restore umask when device node creation fails.
   Fix mirror table CTR code to handle 'block_on_error' and 'cluster' features
--- LVM2/doc/example.conf	2009/09/02 14:47:40	1.46
+++ LVM2/doc/example.conf	2009/09/11 15:53:58	1.47
@@ -315,7 +315,7 @@
     # or has rules that ignore the devices LVM2 creates.
     # The command line argument --nodevsync takes precedence over this setting.
     # If set to 1 when udev is not running, and there are LVM2 processes
-    # waiting for udev, run 'dmsetup udevcomplete' manually to wake them up.
+    # waiting for udev, run 'dmsetup udevcomplete_all' manually to wake them up.
     udev_sync = 1
 
     # How to fill in missing stripes if activating an incomplete volume.
--- LVM2/tools/dmsetup.c	2009/08/06 15:56:50	1.123
+++ LVM2/tools/dmsetup.c	2009/09/11 15:53:58	1.124
@@ -142,6 +142,7 @@
 	UUID_ARG,
 	VERBOSE_ARG,
 	VERSION_ARG,
+	YES_ARG,
 	NUM_SWITCHES
 };
 
@@ -771,17 +772,23 @@
 }
 
 #ifndef UDEV_SYNC_SUPPORT
+static const char _cmd_not_supported[] = "Command not supported. Recompile with \"--enable-udev-sync\" to enable.";
+
 static int _udevcomplete_all(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
 {
-	return 1;
+	log_error(_cmd_not_supported);
+
+	return 0;
 }
 
 static int _udevcookies(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
 {
-	return 1;
+	log_error(_cmd_not_supported);
+
+	return 0;
 }
 
-#else
+#else	/* UDEV_SYNC_SUPPORT */
 
 static char _yes_no_prompt(const char *prompt, ...)
 {
@@ -818,15 +825,17 @@
 	struct semid_ds sdata;
 	int counter = 0;
 
-	log_warn("This operation will destroy all semaphores with keys "
-		 "that have a prefix %" PRIu16 " (0x%" PRIx16 ").",
-		 DM_COOKIE_MAGIC, DM_COOKIE_MAGIC);
-
-	if (_yes_no_prompt("Do you really want to continue? [y/n]: ") == 'n') {
-		log_print("Semaphores with keys prefixed by %" PRIu16
-			  " (0x%" PRIx16 ") NOT destroyed.",
-			  DM_COOKIE_MAGIC, DM_COOKIE_MAGIC);
-		return 1;
+	if (!_switches[YES_ARG]) {
+		log_warn("This operation will destroy all semaphores with keys "
+			 "that have a prefix %" PRIu16 " (0x%" PRIx16 ").",
+			 DM_COOKIE_MAGIC, DM_COOKIE_MAGIC);
+
+		if (_yes_no_prompt("Do you really want to continue? [y/n]: ") == 'n') {
+			log_print("Semaphores with keys prefixed by %" PRIu16
+				  " (0x%" PRIx16 ") NOT destroyed.",
+				  DM_COOKIE_MAGIC, DM_COOKIE_MAGIC);
+			return 1;
+		}
 	}
 
 	if ((max_id = semctl(0, 0, SEM_INFO, &sinfo)) < 0) {
@@ -889,13 +898,13 @@
 			time_str = ctime((const time_t *) &sdata.sem_otime);
 
 			printf("0x%-10x %-10d %-10d %s", sdata.sem_perm.__key,
-				sid, val, time_str ? time_str : "unknown");
+				sid, val, time_str ? time_str : "unknown\n");
 		}
 	}
 
 	return 1;
 }
-#endif
+#endif	/* UDEV_SYNC_SUPPORT */
 
 static int _version(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
 {
@@ -2444,7 +2453,7 @@
 	fprintf(out, "Usage:\n\n");
 	fprintf(out, "dmsetup [--version] [-v|--verbose [-v|--verbose ...]]\n"
 		"        [-r|--readonly] [--noopencount] [--nolockfs]\n"
-		"        [--noudevsync] [--readahead [+]<sectors>|auto|none]\n"
+		"        [--noudevsync] [-y|--yes] [--readahead [+]<sectors>|auto|none]\n"
 		"        [-c|-C|--columns] [-o <fields>] [-O|--sort <sort_fields>]\n"
 		"        [--nameprefixes] [--noheadings] [--separator <separator>]\n\n");
 	for (i = 0; _commands[i].name; i++)
@@ -2824,6 +2833,7 @@
 		{"unquoted", 0, &ind, UNQUOTED_ARG},
 		{"verbose", 1, &ind, VERBOSE_ARG},
 		{"version", 0, &ind, VERSION_ARG},
+		{"yes", 0, &ind, YES_ARG},
 		{0, 0, 0, 0}
 	};
 #else
@@ -2879,7 +2889,7 @@
 
 	optarg = 0;
 	optind = OPTIND_INIT;
-	while ((ind = -1, c = GETOPTLONG_FN(*argc, *argv, "cCfG:j:m:M:no:O:ru:U:v",
+	while ((ind = -1, c = GETOPTLONG_FN(*argc, *argv, "cCfG:j:m:M:no:O:ru:U:vy",
 					    long_options, NULL)) != -1) {
 		if (c == ':' || c == '?')
 			return 0;
@@ -2917,6 +2927,8 @@
 			_switches[UUID_ARG]++;
 			_uuid = optarg;
 		}
+		if (c == 'y' || ind == YES_ARG)
+			_switches[YES_ARG]++;
 		if (ind == NOUDEVSYNC_ARG)
 			_switches[NOUDEVSYNC_ARG]++;
 		if (c == 'G' || ind == GID_ARG) {


