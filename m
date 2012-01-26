From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 26 Jan 2012 21:39:34 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20120126213934.12945.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-26 21:39:33

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Thin  for_each_sub_lv
	
	Adapt to scan thin dependency LVs

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.353&r2=1.354

--- LVM2/lib/metadata/lv_manip.c	2012/01/25 11:27:42	1.353
+++ LVM2/lib/metadata/lv_manip.c	2012/01/26 21:39:32	1.354
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -2784,8 +2784,21 @@
 			if (!for_each_sub_lv(cmd, seg->log_lv, fn, data))
 				return_0;
 		}
-		if (seg->metadata_lv && !fn(cmd, seg->metadata_lv, data))
-			return_0;
+
+		if (seg->pool_lv) {
+			if (!fn(cmd, seg->pool_lv, data))
+				return_0;
+			if (!for_each_sub_lv(cmd, seg->pool_lv, fn, data))
+				return_0;
+		}
+
+		if (seg->metadata_lv) {
+			if (!fn(cmd, seg->metadata_lv, data))
+				return_0;
+			if (!for_each_sub_lv(cmd, seg->metadata_lv, fn, data))
+				return_0;
+		}
+
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) != AREA_LV)
 				continue;


