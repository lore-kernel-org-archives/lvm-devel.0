From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Jul 2009 05:40:59 -0000
Subject: LVM2/tools vgsplit.c
Message-ID: <20090709054059.28168.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-09 05:40:59

Modified files:
	tools          : vgsplit.c 

Log message:
	Fix memory leak in vgsplit when re-reading the VG.
	
	Call vg_release() before re-reading the vg.
	Remove vgsplit whitespace and update copyright.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81

--- LVM2/tools/vgsplit.c	2009/07/08 14:33:17	1.80
+++ LVM2/tools/vgsplit.c	2009/07/09 05:40:59	1.81
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -100,7 +100,7 @@
 	struct logical_volume *lv = dm_list_item(lvh, struct lv_list)->lv;
 
 	dm_list_move(&vg_to->lvs, lvh);
-	
+
 	if (lv_is_active(lv)) {
 		log_error("Logical volume \"%s\" must be inactive", lv->name);
 		return 0;
@@ -162,7 +162,7 @@
 			}
 
 		}
-			
+
 		if (vg_with == vg_from)
 			continue;
 
@@ -245,7 +245,7 @@
 			    seg_in++;
 
 		log_in = (!seg->log_lv || _lv_is_in_vg(vg_to, seg->log_lv));
-		
+
 		if ((seg_in && seg_in < seg->area_count) ||
 		    (seg_in && seg->log_lv && !log_in) ||
 		    (!seg_in && seg->log_lv && log_in)) {
@@ -461,6 +461,7 @@
 	 * Finally, remove the EXPORTED flag from the new VG and write it out.
 	 */
 	if (!test_mode()) {
+		vg_release(vg_to);
 		vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
 					   READ_ALLOW_EXPORTED);
 		if (vg_read_error(vg_to)) {


