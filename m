From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Jul 2009 10:00:37 -0000
Subject: LVM2 lib/config/defaults.h tools/vgcreate.c to ...
Message-ID: <20090709100037.25343.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-09 10:00:37

Modified files:
	lib/config     : defaults.h 
	tools          : vgcreate.c vgsplit.c 

Log message:
	Add defines for default vgcreate parameters.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82

--- LVM2/lib/config/defaults.h	2009/06/04 12:01:15	1.45
+++ LVM2/lib/config/defaults.h	2009/07/09 10:00:36	1.46
@@ -1,6 +1,6 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -66,6 +66,10 @@
 #define DEFAULT_LABELSECTOR UINT64_C(1)
 #define DEFAULT_READ_AHEAD "auto"
 #define DEFAULT_EXTENT_SIZE 4096	/* In KB */
+#define DEFAULT_MAX_PV 0
+#define DEFAULT_MAX_LV 0
+#define DEFAULT_ALLOC_POLICY ALLOC_NORMAL
+#define DEFAULT_CLUSTERED 0
 
 #define DEFAULT_MSG_PREFIX "  "
 #define DEFAULT_CMD_NAME 0
--- LVM2/tools/vgcreate.c	2009/06/09 14:30:44	1.61
+++ LVM2/tools/vgcreate.c	2009/07/09 10:00:36	1.62
@@ -36,10 +36,10 @@
 
 	vp_def.vg_name = NULL;
 	vp_def.extent_size = DEFAULT_EXTENT_SIZE * 2;
-	vp_def.max_pv = 0;
-	vp_def.max_lv = 0;
-	vp_def.alloc = ALLOC_NORMAL;
-	vp_def.clustered = 0;
+	vp_def.max_pv = DEFAULT_MAX_PV;
+	vp_def.max_lv = DEFAULT_MAX_LV;
+	vp_def.alloc = DEFAULT_ALLOC_POLICY;
+	vp_def.clustered = DEFAULT_CLUSTERED;
 	if (fill_vg_create_params(cmd, argv[0], &vp_new, &vp_def))
 		return EINVALID_CMD_LINE;
 
--- LVM2/tools/vgsplit.c	2009/07/09 05:40:59	1.81
+++ LVM2/tools/vgsplit.c	2009/07/09 10:00:36	1.82
@@ -368,7 +368,7 @@
 		vp_def.max_pv = vg_from->max_pv;
 		vp_def.max_lv = vg_from->max_lv;
 		vp_def.alloc = vg_from->alloc;
-		vp_def.clustered = 0;
+		vp_def.clustered = DEFAULT_CLUSTERED;
 
 		if (fill_vg_create_params(cmd, vg_name_to, &vp_new, &vp_def)) {
 			r = EINVALID_CMD_LINE;


