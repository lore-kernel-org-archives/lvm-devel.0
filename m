From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 13 May 2009 21:22:59 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/import-export.c l ...
Message-ID: <20090513212259.26543.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-13 21:22:58

Modified files:
	.              : WHATS_NEW 
	lib/format1    : import-export.c 
	lib/format_pool: format_pool.c import_export.c 
	lib/format_text: import_vsn1.c 
	lib/metadata   : lv_manip.c metadata-exported.h metadata.c 
	                 snapshot_manip.c 
	tools          : vgchange.c vgmerge.c vgsplit.c 

Log message:
	Remove vg->lv_count and use counter function.
	
	This should not cause problems but simplifies code a lot.
	
	(the volumes_count is merged and renamed with lvs_visible
	function by following patch.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1104&r2=1.1105
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/import_export.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.166&r2=1.167
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.216&r2=1.217
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73

--- LVM2/WHATS_NEW	2009/05/13 21:21:58	1.1104
+++ LVM2/WHATS_NEW	2009/05/13 21:22:57	1.1105
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Remove lv_count from VG and use counter function instead.
   Fix snapshot segment import to not use duplicate segments & replace.
   Do not query nonexistent devices for readahead.
   Remove NON_BLOCKING lock flag from tools and set a policy to auto-set.
--- LVM2/lib/format1/import-export.c	2009/05/13 21:21:58	1.102
+++ LVM2/lib/format1/import-export.c	2009/05/13 21:22:57	1.103
@@ -282,7 +282,7 @@
 		vgd->vg_status |= VG_EXTENDABLE;
 
 	vgd->lv_max = vg->max_lv;
-	vgd->lv_cur = vg->lv_count + snapshot_count(vg);
+	vgd->lv_cur = volumes_count(vg) + snapshot_count(vg);
 
 	vgd->pv_max = vg->max_pv;
 	vgd->pv_cur = vg->pv_count;
@@ -469,7 +469,6 @@
 		return_NULL;
 
 	dm_list_add(&vg->lvs, &ll->list);
-	vg->lv_count++;
 
 	return lv;
 }
--- LVM2/lib/format_pool/format_pool.c	2009/05/12 19:12:09	1.22
+++ LVM2/lib/format_pool/format_pool.c	2009/05/13 21:22:57	1.23
@@ -119,7 +119,6 @@
 	vg->status = 0;
 	vg->extent_count = 0;
 	vg->pv_count = 0;
-	vg->lv_count = 0;
 	vg->seqno = 1;
 	vg->system_id = NULL;
 	dm_list_init(&vg->pvs);
--- LVM2/lib/format_pool/import_export.c	2008/11/03 22:14:28	1.25
+++ LVM2/lib/format_pool/import_export.c	2009/05/13 21:22:57	1.26
@@ -49,7 +49,6 @@
 		vg->max_lv = 1;
 		vg->max_pv = POOL_MAX_DEVICES;
 		vg->alloc = ALLOC_NORMAL;
-		vg->lv_count = 0;
 	}
 
 	return 1;
@@ -117,7 +116,6 @@
 	lv->le_count = lv->size / POOL_PE_SIZE;
 	lvl->lv = lv;
 	dm_list_add(&vg->lvs, &lvl->list);
-	vg->lv_count++;
 
 	return 1;
 }
--- LVM2/lib/format_text/import_vsn1.c	2009/05/13 21:21:58	1.59
+++ LVM2/lib/format_text/import_vsn1.c	2009/05/13 21:22:57	1.60
@@ -562,7 +562,6 @@
 	}
 
 	lv->vg = vg;
-	vg->lv_count++;
 	dm_list_add(&vg->lvs, &lvl->list);
 
 	return 1;
--- LVM2/lib/metadata/lv_manip.c	2009/04/21 14:31:58	1.166
+++ LVM2/lib/metadata/lv_manip.c	2009/05/13 21:22:57	1.167
@@ -438,9 +438,6 @@
 			return_0;
 
 		dm_list_del(&lvl->list);
-
-		if (!(lv->status & SNAPSHOT))
-			lv->vg->lv_count--;
 	} else if (lv->vg->fid->fmt->ops->lv_setup &&
 		   !lv->vg->fid->fmt->ops->lv_setup(lv->vg->fid, lv))
 		return_0;
@@ -1827,7 +1824,7 @@
 	struct logical_volume *lv;
 	char dname[NAME_LEN];
 
-	if (vg->max_lv && (vg->max_lv == vg->lv_count)) {
+	if (vg->max_lv && (vg->max_lv == volumes_count(vg))) {
 		log_error("Maximum number of logical volumes (%u) reached "
 			  "in volume group %s", vg->max_lv, vg->name);
 		return NULL;
@@ -1883,9 +1880,6 @@
 		return_NULL;
 	}
 
-	if (!import)
-		vg->lv_count++;
-
 	dm_list_add(&vg->lvs, &ll->list);
 
 	return lv;
--- LVM2/lib/metadata/metadata-exported.h	2009/05/13 21:21:58	1.67
+++ LVM2/lib/metadata/metadata-exported.h	2009/05/13 21:22:57	1.68
@@ -251,7 +251,6 @@
 	 * - one for the user-visible mirror LV
 	 * all of the instances are reflected in lv_count.
 	 */
-	uint32_t lv_count;
 	struct dm_list lvs;
 
 	struct dm_list tags;
@@ -556,6 +555,8 @@
 
 int vg_check_status(const struct volume_group *vg, uint32_t status);
 
+unsigned volumes_count(const struct volume_group *vg);
+
 /*
 * Mirroring functions
 */
--- LVM2/lib/metadata/metadata.c	2009/05/13 01:48:18	1.216
+++ LVM2/lib/metadata/metadata.c	2009/05/13 21:22:57	1.217
@@ -571,7 +571,6 @@
 	vg->pv_count = 0;
 	dm_list_init(&vg->pvs);
 
-	vg->lv_count = 0;
 	dm_list_init(&vg->lvs);
 
 	dm_list_init(&vg->tags);
@@ -1165,6 +1164,22 @@
 	return num_snapshots;
 }
 
+unsigned volumes_count(const struct volume_group *vg)
+{
+	struct lv_list *lvl;
+	unsigned lv_count = 0;
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (lv_is_cow(lvl->lv))
+			continue;
+		if (lvl->lv->status & SNAPSHOT)
+			continue;
+		lv_count++;
+	}
+
+	return lv_count;
+}
+
 /*
  * Determine whether two vgs are compatible for merging.
  */
@@ -1199,7 +1214,7 @@
 	}
 
 	if (vg_to->max_lv &&
-	    (vg_to->max_lv < vg_to->lv_count + vg_from->lv_count)) {
+	    (vg_to->max_lv < volumes_count(vg_to) + volumes_count(vg_from))) {
 		log_error("Maximum number of logical volumes (%d) exceeded "
 			  " for \"%s\" and \"%s\"", vg_to->max_lv, vg_to->name,
 			  vg_from->name);
@@ -1455,10 +1470,10 @@
 	}
 
 	if ((lv_count = (uint32_t) dm_list_size(&vg->lvs)) !=
-	    vg->lv_count + 2 * snapshot_count(vg)) {
+	    volumes_count(vg) + 2 * snapshot_count(vg)) {
 		log_error("Internal error: #internal LVs (%u) != #LVs (%"
 			  PRIu32 ") + 2 * #snapshots (%" PRIu32 ") in VG %s",
-			  dm_list_size(&vg->lvs), vg->lv_count,
+			  dm_list_size(&vg->lvs), volumes_count(vg),
 			  snapshot_count(vg), vg->name);
 		r = 0;
 	}
@@ -1502,10 +1517,10 @@
 		r = 0;
 	}
 
-	if (vg->max_lv && (vg->max_lv < vg->lv_count)) {
+	if (vg->max_lv && (vg->max_lv < volumes_count(vg))) {
 		log_error("Internal error: Volume group %s contains %u volumes"
 			  " but the limit is set to %u.",
-			  vg->name, vg->lv_count, vg->max_lv);
+			  vg->name, volumes_count(vg), vg->max_lv);
 		r = 0;
 	}
 
--- LVM2/lib/metadata/snapshot_manip.c	2009/05/13 21:21:58	1.37
+++ LVM2/lib/metadata/snapshot_manip.c	2009/05/13 21:22:57	1.38
@@ -69,13 +69,10 @@
 	seg->origin = origin;
 	seg->cow = cow;
 
-	// FIXME: direct count manipulation to be removed later
 	cow->status &= ~VISIBLE_LV;
-	cow->vg->lv_count--;
 	cow->snapshot = seg;
 
 	origin->origin_count++;
-	origin->vg->lv_count--;
 
 	/* FIXME Assumes an invisible origin belongs to a sparse device */
 	if (!lv_is_visible(origin))
@@ -116,7 +113,6 @@
 	if (!(seg = alloc_snapshot_seg(snap, 0, 0)))
 		return_0;
 
-	origin->vg->lv_count++;
 	init_snapshot_seg(seg, origin, cow, chunk_size);
 
 	return 1;
@@ -134,8 +130,6 @@
 	}
 
 	cow->snapshot = NULL;
-
-	cow->vg->lv_count++;
 	cow->status |= VISIBLE_LV;
 
 	return 1;
--- LVM2/tools/vgchange.c	2009/04/10 10:01:38	1.69
+++ LVM2/tools/vgchange.c	2009/05/13 21:22:57	1.70
@@ -308,9 +308,9 @@
 		}
 	}
 
-	if (max_lv && max_lv < vg->lv_count) {
+	if (max_lv && max_lv < volumes_count(vg)) {
 		log_error("MaxLogicalVolume is less than the current number "
-			  "%d of LVs for \"%s\"", vg->lv_count,
+			  "%d of LVs for %s", volumes_count(vg),
 			  vg->name);
 		return ECMD_FAILED;
 	}
--- LVM2/tools/vgmerge.c	2009/05/13 13:02:56	1.53
+++ LVM2/tools/vgmerge.c	2009/05/13 21:22:57	1.54
@@ -101,7 +101,6 @@
 		dm_list_move(&vg_to->fid->metadata_areas, mdah);
 	}
 
-	vg_to->lv_count += vg_from->lv_count;
 	vg_to->extent_count += vg_from->extent_count;
 	vg_to->free_count += vg_from->free_count;
 
--- LVM2/tools/vgsplit.c	2009/05/13 13:02:56	1.72
+++ LVM2/tools/vgsplit.c	2009/05/13 21:22:57	1.73
@@ -106,12 +106,8 @@
 		return 0;
 	}
 
-	if (!(lv->status & SNAPSHOT) && !lv_is_cow(lv)) {
-		vg_from->lv_count--;
-		vg_to->lv_count++;
-	}
 	return 1;
-}	
+}
 
 static int _move_lvs(struct volume_group *vg_from, struct volume_group *vg_to)
 {


