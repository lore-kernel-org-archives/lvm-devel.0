From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Mar 2008 19:08:25 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20080328190825.16500.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-03-28 19:08:24

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c metadata.c metadata.h 

Log message:
	Add find_lv_in_lv_list() and find_pv_in_pv_list().
	Update _add_pvs() to call find_pv_in_pv_list().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.811&r2=1.812
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.151&r2=1.152
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.162&r2=1.163
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.178&r2=1.179

--- LVM2/WHATS_NEW	2008/03/28 12:58:08	1.811
+++ LVM2/WHATS_NEW	2008/03/28 19:08:23	1.812
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Add find_lv_in_lv_list() and find_pv_in_pv_list().
   Fix uninitialised variable in clvmd that could cause odd hangs.
   Add vgmerge tests.
   Add pvseg_is_allocated() for identifying a PV segment allocated to a LV.
--- LVM2/lib/metadata/lv_manip.c	2008/02/22 13:22:21	1.151
+++ LVM2/lib/metadata/lv_manip.c	2008/03/28 19:08:23	1.152
@@ -1875,8 +1875,7 @@
 	struct pv_list *pvl;
 
 	/* Don't add again if it's already on list. */
-	list_iterate_items(pvl, &spvs->pvs)
-		if (pvl->pv == peg->pv)
+	if (find_pv_in_pv_list(&spvs->pvs, peg->pv))
 			return 1;
 
 	if (!(pvl = dm_pool_alloc(cmd->mem, sizeof(*pvl)))) {
--- LVM2/lib/metadata/metadata.c	2008/03/26 17:26:32	1.162
+++ LVM2/lib/metadata/metadata.c	2008/03/28 19:08:23	1.163
@@ -868,6 +868,17 @@
 	return NULL;
 }
 
+struct pv_list *find_pv_in_pv_list(const struct list *pl,
+				   const struct physical_volume *pv)
+{
+	struct pv_list *pvl;
+
+	list_iterate_items(pvl, pl)
+		if (pvl->pv == pv)
+			return pvl;
+	return NULL;
+}
+
 int pv_is_in_vg(struct volume_group *vg, struct physical_volume *pv)
 {
 	struct pv_list *pvl;
@@ -929,6 +940,17 @@
 	return NULL;
 }
 
+struct lv_list *find_lv_in_lv_list(const struct list *ll,
+				   const struct logical_volume *lv)
+{
+	struct lv_list *lvl;
+
+	list_iterate_items(lvl, ll)
+		if (lvl->lv == lv)
+			return lvl;
+	return NULL;
+}
+
 struct lv_list *find_lv_in_vg_by_lvid(struct volume_group *vg,
 				      const union lvid *lvid)
 {
--- LVM2/lib/metadata/metadata.h	2008/03/17 16:51:31	1.178
+++ LVM2/lib/metadata/metadata.h	2008/03/28 19:08:23	1.179
@@ -257,6 +257,9 @@
 struct lv_list *find_lv_in_vg_by_lvid(struct volume_group *vg,
 				      const union lvid *lvid);
 
+struct lv_list *find_lv_in_lv_list(const struct list *ll,
+				   const struct logical_volume *lv);
+
 /* Return the VG that contains a given LV (based on path given in lv_name) */
 /* or environment var */
 struct volume_group *find_vg_with_lv(const char *lv_name);
@@ -269,6 +272,9 @@
 /* FIXME Merge these functions with ones above */
 struct physical_volume *find_pv(struct volume_group *vg, struct device *dev);
 
+struct pv_list *find_pv_in_pv_list(const struct list *pl,
+				   const struct physical_volume *pv);
+
 /* Find LV segment containing given LE */
 struct lv_segment *find_seg_by_le(const struct logical_volume *lv, uint32_t le);
 


