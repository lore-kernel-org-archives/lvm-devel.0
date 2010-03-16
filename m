From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Mar 2010 14:37:43 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20100316143743.16877.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-16 14:37:39

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h metadata.c pv_map.c 
	tools          : lvconvert.c toollib.c vgreduce.c 

Log message:
	Introduce is_missing_pv().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1460&r2=1.1461
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.133&r2=1.134
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.318&r2=1.319
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_map.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.121&r2=1.122
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.185&r2=1.186
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100

--- LVM2/WHATS_NEW	2010/03/16 08:47:46	1.1460
+++ LVM2/WHATS_NEW	2010/03/16 14:37:38	1.1461
@@ -1,5 +1,6 @@
 Version 2.02.63 - 
 ================================
+  Introduce is_missing_pv().
   Fix clvmd Makefile to not overwrite LIBS from template definition.
 
 Version 2.02.62 - 9th March 2010
--- LVM2/lib/metadata/metadata-exported.h	2010/02/24 18:15:49	1.133
+++ LVM2/lib/metadata/metadata-exported.h	2010/03/16 14:37:38	1.134
@@ -415,6 +415,7 @@
 			const char *lv_name);
 int is_orphan_vg(const char *vg_name);
 int is_orphan(const struct physical_volume *pv);
+int is_missing_pv(const struct physical_volume *pv);
 int vgs_are_compatible(struct cmd_context *cmd,
 		       struct volume_group *vg_from,
 		       struct volume_group *vg_to);
--- LVM2/lib/metadata/metadata.c	2010/03/02 21:56:14	1.318
+++ LVM2/lib/metadata/metadata.c	2010/03/16 14:37:38	1.319
@@ -2068,7 +2068,7 @@
 	dm_list_iterate_items(lvseg, &lv->segments) {
 		for (s = 0; s < lvseg->area_count; ++s) {
 			if (seg_type(lvseg, s) == AREA_PV) {
-				if (seg_pv(lvseg, s)->status & MISSING_PV)
+				if (is_missing_pv(seg_pv(lvseg, s)))
 					lv->status |= PARTIAL_LV;
 			}
 		}
@@ -2513,7 +2513,7 @@
 	int ret = 0;
 	struct pv_list *pvl;
 	dm_list_iterate_items(pvl, &vg->pvs) {
-		if (pvl->pv->status & MISSING_PV)
+		if (is_missing_pv(pvl->pv))
 			++ ret;
 	}
 	return ret;
@@ -2525,7 +2525,7 @@
 	struct pv_list *pvl;
 
 	dm_list_iterate_items(pvl, &correct_vg->pvs)
-		if (pv->dev == pvl->pv->dev && pvl->pv->status & MISSING_PV) {
+		if (pv->dev == pvl->pv->dev && is_missing_pv(pvl->pv)) {
 			log_warn("Missing device %s reappeared, updating "
 				 "metadata for VG %s to version %u.",
 				 pv_dev_name(pvl->pv),  pv_vg_name(pvl->pv), 
@@ -2705,7 +2705,7 @@
 				correct_vg = NULL;
 			}
 		} else dm_list_iterate_items(pvl, &correct_vg->pvs) {
-			if (pvl->pv->status & MISSING_PV)
+			if (is_missing_pv(pvl->pv))
 				continue;
 			if (!str_list_match_item(pvids, pvl->pv->dev->pvid)) {
 				log_debug("Cached VG %s had incorrect PV list",
@@ -3275,6 +3275,11 @@
 {
 	return (pv_field(pv, vg_name) ? 1 : 0);
 }
+ 
+int is_missing_pv(const struct physical_volume *pv)
+{
+	return pv_field(pv, status) & MISSING_PV ? 1 : 0;
+}
 
 /*
  * Returns:
--- LVM2/lib/metadata/pv_map.c	2009/04/23 16:41:27	1.34
+++ LVM2/lib/metadata/pv_map.c	2010/03/16 14:37:38	1.35
@@ -129,7 +129,7 @@
 	dm_list_iterate_items(pvl, pvs) {
 		if (!(pvl->pv->status & ALLOCATABLE_PV))
 			continue;
-		if (pvl->pv->status & MISSING_PV)
+		if (is_missing_pv(pvl->pv))
 			continue;
 		assert(pvl->pv->dev);
 
--- LVM2/tools/lvconvert.c	2010/02/17 22:59:46	1.121
+++ LVM2/tools/lvconvert.c	2010/03/16 14:37:39	1.122
@@ -527,7 +527,7 @@
 		if (seg_lv(lvseg, s)->status & PARTIAL_LV)
 			return 1;
 	} else if ((seg_type(lvseg, s) == AREA_PV) &&
-		   (seg_pv(lvseg, s)->status & MISSING_PV))
+		   (is_missing_pv(seg_pv(lvseg, s))))
 		return 1;
 
 	return 0;
@@ -564,7 +564,7 @@
 	dm_list_init(failed_pvs);
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
-		if (!(pvl->pv->status & MISSING_PV))
+		if (!is_missing_pv(pvl->pv))
 			continue;
 
 		/* 
@@ -688,7 +688,7 @@
 	dm_list_iterate_items(pvl, remove_pvs) {
 		dm_list_iterate_items_safe(pvl_vg, pvlt, &vg->pvs) {
 			if (!id_equal(&pvl->pv->id, &pvl_vg->pv->id) ||
-			    !(pvl_vg->pv->status & MISSING_PV) ||
+			    !is_missing_pv(pvl_vg->pv) ||
 			    pvl_vg->pv->pe_alloc_count != 0)
 				continue;
 
--- LVM2/tools/toollib.c	2010/02/03 14:08:40	1.185
+++ LVM2/tools/toollib.c	2010/03/16 14:37:39	1.186
@@ -1001,7 +1001,7 @@
 		return 1;
 	}
 
-	if (allocatable_only && (pvl->pv->status & MISSING_PV)) {
+	if (allocatable_only && is_missing_pv(pvl->pv)) {
 		log_error("Physical volume %s is missing", pvname);
 		return 1;
 	}
--- LVM2/tools/vgreduce.c	2009/12/17 13:54:46	1.99
+++ LVM2/tools/vgreduce.c	2010/03/16 14:37:39	1.100
@@ -152,7 +152,7 @@
 	}
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
-		if (pvl->pv->dev && !(pvl->pv->status & MISSING_PV))
+		if (pvl->pv->dev && !is_missing_pv(pvl->pv))
 			continue;
 		if (r && !_remove_pv(vg, pvl, 0))
 			return_0;
@@ -193,7 +193,7 @@
 
 				pv = seg_pv(seg, s);
 				if (!pv || !pv_dev(pv) ||
-				    (pv->status & MISSING_PV)) {
+				    is_missing_pv(pv)) {
 					if (arg_count(cmd, mirrorsonly_ARG) &&
 					    !(lv->status & MIRROR_IMAGE)) {
 						log_error("Non-mirror-image LV %s found: can't remove.", lv->name);
@@ -224,7 +224,7 @@
 	 */
 	dm_list_iterate_safe(pvh, pvht, &vg->pvs) {
 		pvl = dm_list_item(pvh, struct pv_list);
-		if (pvl->pv->dev && !(pvl->pv->status & MISSING_PV))
+		if (pvl->pv->dev && !is_missing_pv(pvl->pv))
 			continue;
 		if (!_remove_pv(vg, pvl, 0))
 			return_0;


