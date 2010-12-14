From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 14 Dec 2010 17:51:14 -0000
Subject: LVM2 lib/metadata/metadata.c tools/vgmerge.c t ...
Message-ID: <20101214175114.26172.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-12-14 17:51:11

Modified files:
	lib/metadata   : metadata.c 
	tools          : vgmerge.c vgsplit.c 

Log message:
	Add further consistency checking to vg_validate, ensuring that all segment
	areas point to LVs or PVs that are listed in the respective VG.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.417&r2=1.418
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104

--- LVM2/lib/metadata/metadata.c	2010/12/14 17:07:35	1.417
+++ LVM2/lib/metadata/metadata.c	2010/12/14 17:51:09	1.418
@@ -2153,6 +2153,61 @@
 	}
 }
 
+/*
+ * Check that an LV and all its PV references are correctly listed in vg->lvs
+ * and vg->pvs, respectively. This only looks at a single LV, but *not* at the
+ * LVs it is using. To do the latter, you should use _lv_postorder with this
+ * function. C.f. vg_validate.
+ */
+static int _lv_validate_references_single(struct logical_volume *lv, void *data)
+{
+	struct volume_group *vg = lv->vg;
+	struct lv_segment *lvseg;
+	struct pv_list *pvl;
+	struct lv_list *lvl;
+	int s;
+	int r = 1;
+	int ok = 0;
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (lvl->lv == lv) {
+			ok = 1;
+			break;
+		}
+	}
+
+	if (!ok) {
+		log_error(INTERNAL_ERROR
+			  "Referenced LV %s not listed in VG %s.",
+			  lv->name, vg->name);
+		r = 0;
+	}
+
+	dm_list_iterate_items(lvseg, &lv->segments) {
+		for (s = 0; s < lvseg->area_count; ++s) {
+			if (seg_type(lvseg, s) == AREA_PV) {
+				ok = 0;
+				/* look up the reference in vg->pvs */
+				dm_list_iterate_items(pvl, &vg->pvs) {
+					if (pvl->pv == seg_pv(lvseg, s)) {
+						ok = 1;
+						break;
+					}
+				}
+
+				if (!ok) {
+					log_error(INTERNAL_ERROR
+						  "Referenced PV %s not listed in VG %s.",
+						  pv_dev_name(seg_pv(lvseg, s)), vg->name);
+					r = 0;
+				}
+			}
+		}
+	}
+
+	return r;
+}
+
 int vg_validate(struct volume_group *vg)
 {
 	struct pv_list *pvl, *pvl2;
@@ -2320,6 +2375,11 @@
 	}
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (!_lv_postorder(lvl->lv, _lv_validate_references_single, NULL))
+			r = 0;
+	}
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (!(lvl->lv->status & PVMOVE))
 			continue;
 		dm_list_iterate_items(seg, &lvl->lv->segments) {
--- LVM2/tools/vgmerge.c	2010/12/08 20:50:51	1.70
+++ LVM2/tools/vgmerge.c	2010/12/14 17:51:10	1.71
@@ -114,6 +114,10 @@
 		}
 	}
 
+	dm_list_iterate_items(lvl1, &vg_from->lvs) {
+		lvl1->lv->vg = vg_to;
+	}
+
 	while (!dm_list_empty(&vg_from->lvs)) {
 		struct dm_list *lvh = vg_from->lvs.n;
 
--- LVM2/tools/vgsplit.c	2010/12/08 20:50:51	1.103
+++ LVM2/tools/vgsplit.c	2010/12/14 17:51:10	1.104
@@ -34,6 +34,7 @@
 	struct logical_volume *lv = dm_list_item(lvh, struct lv_list)->lv;
 
 	dm_list_move(&vg_to->lvs, lvh);
+	lv->vg = vg_to;
 
 	if (lv_is_active(lv)) {
 		log_error("Logical volume \"%s\" must be inactive", lv->name);


