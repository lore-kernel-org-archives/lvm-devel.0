From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 4 Apr 2008 08:53:47 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c
Message-ID: <20080404085347.11783.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2008-04-04 08:53:47

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 

Log message:
	If lvm.conf was touched, clvmd attempted to update the toolcontext
	but only did half of the job. It now shares the do_refresh_cache()
	function that vgscan invokes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.822&r2=1.823
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/WHATS_NEW	2008/04/03 18:56:39	1.822
+++ LVM2/WHATS_NEW	2008/04/04 08:53:46	1.823
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Make clvmd refresh the context correctly when lvm.conf is updated.
   Add some basic internal VG lock validation.
   Add per-command flags to control which commands use the VG metadata cache.
   Fix vgsplit locking of new VG (2.02.30).
--- LVM2/daemons/clvmd/lvm-functions.c	2007/12/05 13:17:18	1.37
+++ LVM2/daemons/clvmd/lvm-functions.c	2008/04/04 08:53:47	1.38
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -318,7 +318,7 @@
 	pthread_mutex_lock(&lvm_lock);
 	if (!cmd->config_valid || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */
-		if (!refresh_toolcontext(cmd)) {
+		if (do_refresh_cache()) {
 			log_error("Updated config file invalid. Aborting.");
 			pthread_mutex_unlock(&lvm_lock);
 			return EINVAL;
@@ -437,7 +437,7 @@
 	return 0;
 }
 
-/* Check if a VG is un use by LVM1 so we don't stomp on it */
+/* Check if a VG is in use by LVM1 so we don't stomp on it */
 int do_check_lvm1(const char *vgname)
 {
 	int status;


