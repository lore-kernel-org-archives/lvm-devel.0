From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 11:29:14 -0000
Subject: LVM2 daemons/dmeventd/plugins/mirror/dmeventd_ ...
Message-ID: <20120208112914.5397.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 11:29:14

Modified files:
	daemons/dmeventd/plugins/mirror: dmeventd_mirror.c 
	lib/mirror     : mirrored.c 

Log message:
	Add boundary test for number of mirror devs and logs
	
	As atoi may return negative value - test for both limits.
	Test log_args for limits before calling alloca().
	Code from dmeventd mirror plugin should probably share same code as
	we have in mirrored.c.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93

--- LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2011/12/22 16:37:02	1.38
+++ LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2012/02/08 11:29:13	1.39
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -18,6 +18,7 @@
 #include "errors.h"
 #include "libdevmapper-event.h"
 #include "dmeventd_lvm.h"
+#include "defaults.h"
 
 #include <syslog.h> /* FIXME Replace syslog with multilog */
 /* FIXME Missing openlog? */
@@ -81,7 +82,8 @@
 	if (!dm_split_words(params, 1, 0, &p))
 		goto out_parse;
 
-	if (!(num_devs = atoi(p)))
+	if (!(num_devs = atoi(p)) ||
+	    (num_devs > DEFAULT_MIRROR_MAX_IMAGES) || (num_devs < 0))
 		goto out_parse;
 	p += strlen(p) + 1;
 
@@ -90,6 +92,7 @@
 	if (!args || dm_split_words(p, num_devs + 7, 0, args) < num_devs + 5)
 		goto out_parse;
 
+	/* FIXME: Code differs from lib/mirror/mirrored.c */
 	dev_status_str = args[2 + num_devs];
 	log_argc = atoi(args[3 + num_devs]);
 	log_status_str = args[3 + num_devs + log_argc];
--- LVM2/lib/mirror/mirrored.c	2011/11/28 20:37:52	1.92
+++ LVM2/lib/mirror/mirrored.c	2012/02/08 11:29:14	1.93
@@ -248,7 +248,7 @@
 
 	p += strlen(p) + 1;
 
-	if (num_devs > DEFAULT_MIRROR_MAX_IMAGES) {
+	if (num_devs > DEFAULT_MIRROR_MAX_IMAGES || num_devs < 0) {
 		log_error("Unexpectedly many (%d) mirror images in %s.",
 			  num_devs, lv->name);
 		return_0;
@@ -261,14 +261,14 @@
 		return_0;
 
 	log_argc = atoi(args[3 + num_devs]);
-	log_args = alloca(log_argc * sizeof(char *));
 
-	if (log_argc > 16) {
+	if (log_argc > 16 || log_argc < 0) {
 		log_error("Unexpectedly many (%d) log arguments in %s.",
 			  log_argc, lv->name);
 		return_0;
 	}
 
+	log_args = alloca(log_argc * sizeof(char *));
 
 	if (dm_split_words(args[3 + num_devs] + strlen(args[3 + num_devs]) + 1,
 			   log_argc, 0, log_args) < log_argc)


