From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 14 Dec 2010 17:07:37 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20101214170737.6019.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-12-14 17:07:36

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Add a validation step for pvmoveN internal LVs to vg_validate.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.416&r2=1.417

--- LVM2/lib/metadata/metadata.c	2010/12/10 22:39:55	1.416
+++ LVM2/lib/metadata/metadata.c	2010/12/14 17:07:35	1.417
@@ -2157,6 +2157,7 @@
 {
 	struct pv_list *pvl, *pvl2;
 	struct lv_list *lvl, *lvl2;
+	struct lv_segment *seg;
 	char uuid[64] __attribute__((aligned(8)));
 	int r = 1;
 	uint32_t hidden_lv_count = 0, lv_count = 0, lv_visible_count = 0;
@@ -2318,6 +2319,26 @@
 		}
 	}
 
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (!(lvl->lv->status & PVMOVE))
+			continue;
+		dm_list_iterate_items(seg, &lvl->lv->segments) {
+			if (seg_is_mirrored(seg)) {
+				if (seg->area_count != 2) {
+					log_error(INTERNAL_ERROR
+						  "Segment %d in %s is not 2-way.",
+						  loop_counter1, lvl->lv->name);
+					r = 0;
+				}
+			} else if (seg->area_count != 1) {
+				log_error(INTERNAL_ERROR
+					  "Segment %d in %s has wrong number of areas: %d.",
+					  loop_counter1, lvl->lv->name, seg->area_count);
+				r = 0;
+			}
+		}
+	}
+
 	if (!(vg->fid->fmt->features & FMT_UNLIMITED_VOLS) &&
 	    (!vg->max_lv || !vg->max_pv)) {
 		log_error(INTERNAL_ERROR "Volume group %s has limited PV/LV count"


