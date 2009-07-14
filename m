From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Jul 2009 02:15:23 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20090714021523.5936.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-14 02:15:21

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : vgsplit.c 

Log message:
	Refactor vgsplit - move move_pvs_used_by_lv and move_pv inside library.
	
	In the future we may export these functions or something like them in liblvm
	For now this helps in cleaning up the checks for RESIZEABLE since we can
	use the internal library function vg_bad_status_bits.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Acked-by: Alasdair G Kergon <agk@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.90&r2=1.91
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.247&r2=1.248
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84

--- LVM2/lib/metadata/metadata-exported.h	2009/07/10 21:19:37	1.90
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/14 02:15:21	1.91
@@ -375,6 +375,11 @@
 int pv_write(struct cmd_context *cmd, struct physical_volume *pv,
 	     struct dm_list *mdas, int64_t label_sector);
 int is_pv(pv_t *pv);
+int move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
+	    const char *pv_name);
+int move_pvs_used_by_lv(struct volume_group *vg_from,
+			struct volume_group *vg_to,
+			const char *lv_name);
 int is_orphan_vg(const char *vg_name);
 int is_orphan(const pv_t *pv);
 int vgs_are_compatible(struct cmd_context *cmd,
--- LVM2/lib/metadata/metadata.c	2009/07/14 02:14:04	1.247
+++ LVM2/lib/metadata/metadata.c	2009/07/14 02:15:21	1.248
@@ -274,6 +274,72 @@
 	return r;
 }
 
+int move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
+	    const char *pv_name)
+{
+	struct physical_volume *pv;
+	struct pv_list *pvl;
+
+	/* FIXME: handle tags */
+	if (!(pvl = find_pv_in_vg(vg_from, pv_name))) {
+		log_error("Physical volume %s not in volume group %s",
+			  pv_name, vg_from->name);
+		return 0;
+	}
+
+	dm_list_move(&vg_to->pvs, &pvl->list);
+
+	vg_from->pv_count--;
+	vg_to->pv_count++;
+
+	pv = pvl->pv;
+
+	vg_from->extent_count -= pv_pe_count(pv);
+	vg_to->extent_count += pv_pe_count(pv);
+
+	vg_from->free_count -= pv_pe_count(pv) - pv_pe_alloc_count(pv);
+	vg_to->free_count += pv_pe_count(pv) - pv_pe_alloc_count(pv);
+
+	return 1;
+}
+
+int move_pvs_used_by_lv(struct volume_group *vg_from,
+			struct volume_group *vg_to,
+			const char *lv_name)
+{
+	struct lv_segment *lvseg;
+	unsigned s;
+	struct lv_list *lvl;
+	struct logical_volume *lv;
+
+	/* FIXME: handle tags */
+	if (!(lvl = find_lv_in_vg(vg_from, lv_name))) {
+		log_error("Logical volume %s not in volume group %s",
+			  lv_name, vg_from->name);
+		return 0;
+	}
+
+	dm_list_iterate_items(lvseg, &lvl->lv->segments) {
+		if (lvseg->log_lv)
+			if (!move_pvs_used_by_lv(vg_from, vg_to,
+						     lvseg->log_lv->name))
+				return_0;
+		for (s = 0; s < lvseg->area_count; s++) {
+			if (seg_type(lvseg, s) == AREA_PV) {
+				if (!move_pv(vg_from, vg_to,
+					      pv_dev_name(seg_pv(lvseg, s))))
+					return_0;
+			} else if (seg_type(lvseg, s) == AREA_LV) {
+				lv = seg_lv(lvseg, s);
+				if (!move_pvs_used_by_lv(vg_from, vg_to,
+							     lv->name))
+				    return_0;
+			}
+		}
+	}
+	return 1;
+}
+
 static int validate_new_vg_name(struct cmd_context *cmd, const char *vg_name)
 {
 	char vg_path[PATH_MAX];
--- LVM2/tools/vgsplit.c	2009/07/09 10:09:33	1.83
+++ LVM2/tools/vgsplit.c	2009/07/14 02:15:21	1.84
@@ -15,72 +15,6 @@
 
 #include "tools.h"
 
-static int _move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
-		    const char *pv_name)
-{
-	struct physical_volume *pv;
-	struct pv_list *pvl;
-
-	/* FIXME: handle tags */
-	if (!(pvl = find_pv_in_vg(vg_from, pv_name))) {
-		log_error("Physical volume %s not in volume group %s",
-			  pv_name, vg_from->name);
-		return 0;
-	}
-
-	dm_list_move(&vg_to->pvs, &pvl->list);
-
-	vg_from->pv_count--;
-	vg_to->pv_count++;
-
-	pv = pvl->pv;
-
-	vg_from->extent_count -= pv_pe_count(pv);
-	vg_to->extent_count += pv_pe_count(pv);
-
-	vg_from->free_count -= pv_pe_count(pv) - pv_pe_alloc_count(pv);
-	vg_to->free_count += pv_pe_count(pv) - pv_pe_alloc_count(pv);
-
-	return 1;
-}
-
-static int _move_pvs_used_by_lv(struct volume_group *vg_from,
-				   struct volume_group *vg_to,
-				   const char *lv_name)
-{
-	struct lv_segment *lvseg;
-	unsigned s;
-	struct lv_list *lvl;
-	struct logical_volume *lv;
-
-	/* FIXME: handle tags */
-	if (!(lvl = find_lv_in_vg(vg_from, lv_name))) {
-		log_error("Logical volume %s not in volume group %s",
-			  lv_name, vg_from->name);
-		return 0;
-	}
-
-	dm_list_iterate_items(lvseg, &lvl->lv->segments) {
-		if (lvseg->log_lv)
-			if (!_move_pvs_used_by_lv(vg_from, vg_to,
-						     lvseg->log_lv->name))
-				return_0;
-		for (s = 0; s < lvseg->area_count; s++) {
-			if (seg_type(lvseg, s) == AREA_PV) {
-				if (!_move_pv(vg_from, vg_to,
-					      pv_dev_name(seg_pv(lvseg, s))))
-					return_0;
-			} else if (seg_type(lvseg, s) == AREA_LV) {
-				lv = seg_lv(lvseg, s);
-				if (!_move_pvs_used_by_lv(vg_from, vg_to,
-							     lv->name))
-				    return_0;
-			}
-		}
-	}
-	return 1;
-}
-
 /* FIXME Why not (lv->vg == vg) ? */
 static int _lv_is_in_vg(struct volume_group *vg, struct logical_volume *lv)
 {
@@ -401,12 +335,12 @@
 
 	/* Move PVs across to new structure */
 	for (opt = 0; opt < argc; opt++) {
-		if (!_move_pv(vg_from, vg_to, argv[opt]))
+		if (!move_pv(vg_from, vg_to, argv[opt]))
 			goto_bad;
 	}
 
 	/* If an LV given on the cmdline, move used_by PVs */
-	if (lv_name && !_move_pvs_used_by_lv(vg_from, vg_to, lv_name))
+	if (lv_name && !move_pvs_used_by_lv(vg_from, vg_to, lv_name))
 		goto_bad;
 
 	/* Move required LVs across, checking consistency */


