From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Feb 2012 00:11:02 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20120223001102.31205.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-23 00:11:01

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Check all tags and LV names are in a valid form in vg_validate.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2300&r2=1.2301
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.484&r2=1.485

--- LVM2/WHATS_NEW	2012/02/22 17:55:10	1.2300
+++ LVM2/WHATS_NEW	2012/02/23 00:11:01	1.2301
@@ -1,5 +1,6 @@
 Version 2.02.93 - 
 ====================================
+  Check all tags and LV names are in a valid form in vg_validate.
   Add tmpfiles.d style configuration for lvm2 lock and run directory.
   Add configure --with-tmpfilesdir for dir holding volatile-file configuration.
   Allow 'lvconvert --repair' to operate on RAID 4/5/6
--- LVM2/lib/metadata/metadata.c	2012/02/13 11:04:00	1.484
+++ LVM2/lib/metadata/metadata.c	2012/02/23 00:11:01	1.485
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -2294,6 +2294,7 @@
 	struct pv_list *pvl;
 	struct lv_list *lvl;
 	struct lv_segment *seg;
+	struct str_list *sl;
 	char uuid[64] __attribute__((aligned(8)));
 	int r = 1;
 	uint32_t hidden_lv_count = 0, lv_count = 0, lv_visible_count = 0;
@@ -2313,6 +2314,13 @@
 		return 0;
 	}
 
+	dm_list_iterate_items(sl, &vg->tags)
+		if (!validate_tag(sl->str)) {
+			log_error(INTERNAL_ERROR "VG %s tag %s has invalid form.",
+				  vg->name, sl->str);
+			r = 0;
+		}
+
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (++pv_count > vg->pv_count) {
 			log_error(INTERNAL_ERROR "PV list corruption detected in VG %s.", vg->name);
@@ -2345,6 +2353,13 @@
 			r = 0;
 		}
 
+		dm_list_iterate_items(sl, &pvl->pv->tags)
+			if (!validate_tag(sl->str)) {
+				log_error(INTERNAL_ERROR "PV %s tag %s has invalid form.",
+					  pv_dev_name(pvl->pv), sl->str);
+				r = 0;
+			}
+
 		if (!dm_hash_insert_binary(vhash.pvid, &pvl->pv->id,
 					   sizeof(pvl->pv->id), pvl->pv)) {
 			log_error("Failed to hash pvid.");
@@ -2384,6 +2399,18 @@
 			r = 0;
 		}
 
+		if (!validate_name(lvl->lv->name)) {
+			log_error(INTERNAL_ERROR "LV name %s has invalid form.", lvl->lv->name);
+			r = 0;
+		}
+
+		dm_list_iterate_items(sl, &lvl->lv->tags)
+			if (!validate_tag(sl->str)) {
+				log_error(INTERNAL_ERROR "LV %s tag %s has invalid form.",
+					  lvl->lv->name, sl->str);
+				r = 0;
+			}
+
 		if (lvl->lv->status & VISIBLE_LV)
 			continue;
 


