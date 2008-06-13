From: meyering@sourceware.org <meyering@sourceware.org>
Date: 13 Jun 2008 12:15:56 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20080613121556.22218.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2008-06-13 12:15:55

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	Don't deref uninitialized log_lv upon failed mirror addition.
	
	* mirror.c (add_mirror_images): Ensure that log_lv is initialized.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.902&r2=1.903
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72

--- LVM2/WHATS_NEW	2008/06/13 07:44:14	1.902
+++ LVM2/WHATS_NEW	2008/06/13 12:15:55	1.903
@@ -1,10 +1,11 @@
 Version 2.02.39 -
 ================================
+  Fix add_mirror_images not to dereference uninitialized log_lv upon failure.
   Don't call openlog for every debug line output by clvmd.
   Add --force to lvextend and lvresize.
   Fix vgchange to not activate mirror leg and log volumes directly.
   Fix test directory clean up in make distclean.
- 
+
 Version 2.02.38 - 11th June 2008
 ================================
   Fix tracking of validity of PVs with no mdas in lvmcache.
--- LVM2/lib/metadata/mirror.c	2008/04/07 10:23:46	1.71
+++ LVM2/lib/metadata/mirror.c	2008/06/13 12:15:55	1.72
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -1344,7 +1344,8 @@
 	struct alloc_handle *ah;
 	const struct segment_type *segtype;
 	struct list *parallel_areas;
-	struct logical_volume **img_lvs, *log_lv;
+	struct logical_volume **img_lvs;
+	struct logical_volume *log_lv = NULL;
 
 	if (stripes > 1) {
 		log_error("stripes > 1 is not supported");
@@ -1416,8 +1417,8 @@
 	return 1;
 
   out_remove_log:
-	if (!lv_remove(log_lv) || !vg_write(log_lv->vg) ||
-	    (backup(log_lv->vg), !vg_commit(log_lv->vg)))
+	if (log_lv && (!lv_remove(log_lv) || !vg_write(log_lv->vg) ||
+		       (backup(log_lv->vg), !vg_commit(log_lv->vg))))
 		log_error("Manual intervention may be required to remove "
 			  "abandoned log LV before retrying.");
 


