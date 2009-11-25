From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Nov 2009 15:59:10 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/plugins/mirr ...
Message-ID: <20091125155910.25562.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-11-25 15:59:08

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd/plugins/mirror: dmeventd_mirror.c 

Log message:
	Log failure type and recognise type 'F' (flush) in dmeventd mirror plugin.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1331&r2=1.1332
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/WHATS_NEW	2009/11/24 22:55:55	1.1331
+++ LVM2/WHATS_NEW	2009/11/25 15:59:07	1.1332
@@ -1,6 +1,7 @@
 Version 2.02.57 -
 ====================================
- Switch status from 32-bit to 64-bit.
+  Log failure type and recognise type 'F' (flush) in dmeventd mirror plugin.
+  Extend internal PV/VG/LV/segment status variables from 32-bit to 64-bit.
 
 Version 2.02.56 - 24th November 2009
 ====================================
--- LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2009/10/22 10:40:41	1.27
+++ LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2009/11/25 15:59:08	1.28
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -27,6 +27,8 @@
 
 #include <syslog.h> /* FIXME Replace syslog with multilog */
 /* FIXME Missing openlog? */
+/* FIXME Replace most syslogs with log_error() style messages and add complete context. */
+/* FIXME Reformat to 80 char lines. */
 
 #define ME_IGNORE    0
 #define ME_INSYNC    1
@@ -51,6 +53,36 @@
  */
 static pthread_mutex_t _event_mutex = PTHREAD_MUTEX_INITIALIZER;
 
+static int _process_status_code(const char status_code, const char *dev_name,
+				const char *dev_type, int r)
+{
+	/*
+	 *    A => Alive - No failures
+	 *    D => Dead - A write failure occurred leaving mirror out-of-sync
+	 *    F => Flush failed.
+	 *    S => Sync - A sychronization failure occurred, mirror out-of-sync
+	 *    R => Read - A read failure occurred, mirror data unaffected
+	 *    U => Unclassified failure (bug)
+	 */ 
+	if (status_code == 'F') {
+		syslog(LOG_ERR, "%s device %s flush failed.\n",
+		       dev_type, dev_name);
+		r = ME_FAILURE;
+	} else if (status_code == 'S')
+		syslog(LOG_ERR, "%s device %s sync failed.\n",
+		       dev_type, dev_name);
+	else if (status_code == 'R')
+		syslog(LOG_ERR, "%s device %s read failed.\n",
+		       dev_type, dev_name);
+	else if (status_code != 'A') {
+		syslog(LOG_ERR, "%s device %s has failed (%c).\n",
+		       dev_type, dev_name, status_code);
+		r = ME_FAILURE;
+	}
+
+	return r;
+}
+
 static int _get_mirror_event(char *params)
 {
 	int i, r = ME_INSYNC;
@@ -90,17 +122,14 @@
 
 	/* Check for bad mirror devices */
 	for (i = 0; i < num_devs; i++)
-		if (dev_status_str[i] == 'D') {
-			syslog(LOG_ERR, "Mirror device, %s, has failed.\n", args[i]);
-			r = ME_FAILURE;
-		}
+		r = _process_status_code(dev_status_str[i], args[i],
+			i ? "Secondary mirror" : "Primary mirror", r);
 
 	/* Check for bad disk log device */
-	if (log_argc > 1 && log_status_str[0] == 'D') {
-		syslog(LOG_ERR, "Log device, %s, has failed.\n",
-		       args[2 + num_devs + log_argc]);
-		r = ME_FAILURE;
-	}
+	if (log_argc > 1)
+		r = _process_status_code(log_status_str[0],
+					 args[2 + num_devs + log_argc],
+					 "Log", r);
 
 	if (r == ME_FAILURE)
 		goto out;


