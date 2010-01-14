From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 14 Jan 2010 10:08:03 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20100114100803.25319.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-01-14 10:08:03

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	lvol%d is generated for NULL name in lv_create_empty().
	So just avoid code duplication.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.202&r2=1.203

--- LVM2/lib/metadata/lv_manip.c	2010/01/13 01:56:18	1.202
+++ LVM2/lib/metadata/lv_manip.c	2010/01/14 10:08:03	1.203
@@ -2852,8 +2852,6 @@
 	uint64_t status = UINT64_C(0);
 	struct logical_volume *lv, *org = NULL;
 	int origin_active = 0;
-	char lv_name_buf[128];
-	const char *lv_name;
 	struct lvinfo info;
 
 	if (lp->lv_name && find_lv_in_vg(vg, lp->lv_name)) {
@@ -3008,16 +3006,6 @@
 	if (!archive(vg))
 		return 0;
 
-	if (lp->lv_name)
-		lv_name = lp->lv_name;
-	else {
-		if (!generate_lv_name(vg, "lvol%d", lv_name_buf, sizeof(lv_name_buf))) {
-			log_error("Failed to generate LV name.");
-			return 0;
-		}
-		lv_name = &lv_name_buf[0];
-	}
-
 	if (lp->tag) {
 		if (!(vg->fid->fmt->features & FMT_TAGS)) {
 			log_error("Volume group %s does not support tags",
@@ -3036,7 +3024,7 @@
 		}
 	}
 
-	if (!(lv = lv_create_empty(lv_name ? lv_name : "lvol%d", NULL,
+	if (!(lv = lv_create_empty(lp->lv_name ? lp->lv_name : "lvol%d", NULL,
 				   status, lp->alloc, vg)))
 		return_0;
 


