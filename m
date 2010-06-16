From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 16 Jun 2010 13:01:28 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM libdm/libdevma ...
Message-ID: <20100616130128.30656.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-06-16 13:01:26

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	libdm          : libdevmapper.h libdm-report.c 
	liblvm         : lvm2app.h 
	tools          : lvm2cmd.h 

Log message:
	Remove C++ private keyword from headers.
	Add extern C definition for libdevmapper, lvm2app and lvm2cmd.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1611&r2=1.1612
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.378&r2=1.379
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.115&r2=1.116
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-report.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm2cmd.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2010/06/07 14:39:18	1.1611
+++ LVM2/WHATS_NEW	2010/06/16 13:01:25	1.1612
@@ -1,5 +1,6 @@
 Version 2.02.68 -
 ===============================
+  Allow use of lvm2app and lvm2cmd headers in C++ mode.
   Fix wrong lvm path creation from configure introduced in previous release.
   Fix segfault in clvmd -R if no response from daemon received.
 
--- LVM2/WHATS_NEW_DM	2010/06/07 10:25:45	1.378
+++ LVM2/WHATS_NEW_DM	2010/06/16 13:01:25	1.379
@@ -1,5 +1,6 @@
 Version 1.02.50 - 
 ===============================
+  Allow use of devmapper header file in C++ mode.
 
 Version 1.02.49 - 4th June 2010
 ===============================
--- LVM2/libdm/libdevmapper.h	2010/05/21 12:27:03	1.115
+++ LVM2/libdm/libdevmapper.h	2010/06/16 13:01:25	1.116
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -29,6 +29,10 @@
 #include <stdlib.h>
 #include <stdio.h>
 
+#ifdef __cplusplus
+extern "C" {
+#endif
+
 /*****************************************************************
  * The first section of this file provides direct access to the
  * individual device-mapper ioctls.  Since it is quite laborious to
@@ -1022,7 +1026,7 @@
 	const char heading[32];	/* string printed in header */
 	int (*report_fn)(struct dm_report *rh, struct dm_pool *mem,
 			 struct dm_report_field *field, const void *data,
-			 void *private);
+			 void *private_data);
 	const char *desc;	/* description of the field */
 };
 
@@ -1044,7 +1048,7 @@
 				 const char *output_separator,
 				 uint32_t output_flags,
 				 const char *sort_keys,
-				 void *private);
+				 void *private_data);
 int dm_report_object(struct dm_report *rh, void *object);
 int dm_report_output(struct dm_report *rh);
 void dm_report_free(struct dm_report *rh);
@@ -1163,4 +1167,7 @@
 
 #define DM_DEV_DIR_UMASK 0022
 
+#ifdef __cplusplus
+}
+#endif
 #endif				/* LIB_DEVICE_MAPPER_H */
--- LVM2/libdm/libdm-report.c	2010/02/15 18:36:48	1.35
+++ LVM2/libdm/libdm-report.c	2010/06/16 13:01:25	1.36
@@ -566,7 +566,7 @@
 				 const char *output_separator,
 				 uint32_t output_flags,
 				 const char *sort_keys,
-				 void *private)
+				 void *private_data)
 {
 	struct dm_report *rh;
 	const struct dm_report_object_type *type;
@@ -588,7 +588,7 @@
 	rh->separator = output_separator;
 	rh->fields = fields;
 	rh->types = types;
-	rh->private = private;
+	rh->private = private_data;
 
 	rh->flags |= output_flags & DM_REPORT_OUTPUT_MASK;
 
--- LVM2/liblvm/lvm2app.h	2010/05/19 11:53:12	1.16
+++ LVM2/liblvm/lvm2app.h	2010/06/16 13:01:25	1.17
@@ -18,6 +18,9 @@
 
 #include <stdint.h>
 
+#ifdef __cplusplus
+extern "C" {
+#endif
 
 /******************************** WARNING ***********************************
  *
@@ -1194,4 +1197,7 @@
  */
 int lvm_pv_resize(const pv_t pv, uint64_t new_size);
 
+#ifdef __cplusplus
+}
+#endif
 #endif /* _LIB_LVM2APP_H */
--- LVM2/tools/lvm2cmd.h	2009/09/26 00:29:13	1.4
+++ LVM2/tools/lvm2cmd.h	2010/06/16 13:01:25	1.5
@@ -16,6 +16,10 @@
 #ifndef _LVM_CMDLIB_H
 #define _LVM_CMDLIB_H
 
+#ifdef __cplusplus
+extern "C" {
+#endif
+
 #ifndef _LVM_LOG_H
 typedef void (*lvm2_log_fn_t) (int level, const char *file, int line,
                                int dm_errno, const char *message);
@@ -63,4 +67,7 @@
 /* Release handle */
 void lvm2_exit(void *handle);
 
+#ifdef __cplusplus
+}
+#endif
 #endif


