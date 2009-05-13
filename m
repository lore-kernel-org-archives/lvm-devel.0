From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 13 May 2009 21:25:03 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/import-export.c l ...
Message-ID: <20090513212503.27423.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-13 21:25:02

Modified files:
	.              : WHATS_NEW 
	lib/format1    : import-export.c 
	lib/format_pool: import_export.c 
	lib/format_text: import_vsn1.c 
	lib/metadata   : lv_manip.c metadata-exported.h 

Log message:
	Introduce link_lv_to_vg and unlink_lv_from_vg functions.
	
	link_lv_to_vg and unlink_lv_from_vg are the only functions
	for adding/removing logical volume from volume group.
	
	Only these function should manipulate with vg->lvs list.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1105&r2=1.1106
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/import_export.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.167&r2=1.168
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.68&r2=1.69

--- LVM2/WHATS_NEW	2009/05/13 21:22:57	1.1105
+++ LVM2/WHATS_NEW	2009/05/13 21:25:01	1.1106
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Introduce link_lv_to_vg and unlink_lv_from_vg functions.
   Remove lv_count from VG and use counter function instead.
   Fix snapshot segment import to not use duplicate segments & replace.
   Do not query nonexistent devices for readahead.
--- LVM2/lib/format1/import-export.c	2009/05/13 21:24:12	1.104
+++ LVM2/lib/format1/import-export.c	2009/05/13 21:25:01	1.105
@@ -455,25 +455,23 @@
 				      struct volume_group *vg,
 				      struct lv_disk *lvd)
 {
-	struct lv_list *ll;
 	struct logical_volume *lv;
 
-	if (!(ll = dm_pool_zalloc(mem, sizeof(*ll))) ||
-	    !(ll->lv = dm_pool_zalloc(mem, sizeof(*ll->lv))))
+	if (!(lv = dm_pool_zalloc(mem, sizeof(*lv))))
 		return_NULL;
-	lv = ll->lv;
-	lv->vg = vg;
 
 	lvid_from_lvnum(&lv->lvid, &vg->id, lvd->lv_number);
 
-	if (!import_lv(vg->cmd, mem, lv, lvd)) {
-		dm_pool_free(mem, ll);
-		return_NULL;
-	}
+	if (!import_lv(vg->cmd, mem, lv, lvd)) 
+		goto_bad;
 
-	dm_list_add(&vg->lvs, &ll->list);
+	if (!link_lv_to_vg(vg, lv))
+		goto_bad;
 
 	return lv;
+bad:
+	dm_pool_free(mem, lv);
+	return NULL;
 }
 
 int import_lvs(struct dm_pool *mem, struct volume_group *vg, struct dm_list *pvds)
--- LVM2/lib/format_pool/import_export.c	2009/05/13 21:22:57	1.26
+++ LVM2/lib/format_pool/import_export.c	2009/05/13 21:25:02	1.27
@@ -57,22 +57,14 @@
 int import_pool_lvs(struct volume_group *vg, struct dm_pool *mem, struct dm_list *pls)
 {
 	struct pool_list *pl;
-	struct lv_list *lvl = dm_pool_zalloc(mem, sizeof(*lvl));
 	struct logical_volume *lv;
 
-	if (!lvl) {
-		log_error("Unable to allocate lv list structure");
-		return 0;
-	}
-
-	if (!(lvl->lv = dm_pool_zalloc(mem, sizeof(*lvl->lv)))) {
+	if (!(lv = dm_pool_zalloc(mem, sizeof(*lv)))) {
 		log_error("Unable to allocate logical volume structure");
 		return 0;
 	}
 
-	lv = lvl->lv;
 	lv->status = 0;
-	lv->vg = vg;
 	lv->alloc = ALLOC_NORMAL;
 	lv->size = 0;
 	lv->name = NULL;
@@ -114,10 +106,8 @@
 	}
 
 	lv->le_count = lv->size / POOL_PE_SIZE;
-	lvl->lv = lv;
-	dm_list_add(&vg->lvs, &lvl->list);
 
-	return 1;
+	return link_lv_to_vg(vg, lv);
 }
 
 int import_pool_pvs(const struct format_type *fmt, struct volume_group *vg,
--- LVM2/lib/format_text/import_vsn1.c	2009/05/13 21:22:57	1.60
+++ LVM2/lib/format_text/import_vsn1.c	2009/05/13 21:25:02	1.61
@@ -495,15 +495,11 @@
 			 struct dm_hash_table *pv_hash __attribute((unused)))
 {
 	struct logical_volume *lv;
-	struct lv_list *lvl;
 	struct config_node *cn;
 
-	if (!(lvl = dm_pool_zalloc(mem, sizeof(*lvl))) ||
-	    !(lvl->lv = dm_pool_zalloc(mem, sizeof(*lvl->lv))))
+	if (!(lv = dm_pool_zalloc(mem, sizeof(*lv))))
 		return_0;
 
-	lv = lvl->lv;
-
 	if (!(lv->name = dm_pool_strdup(mem, lvn->key)))
 		return_0;
 
@@ -561,10 +557,7 @@
 		return 0;
 	}
 
-	lv->vg = vg;
-	dm_list_add(&vg->lvs, &lvl->list);
-
-	return 1;
+	return link_lv_to_vg(vg, lv);
 }
 
 static int _read_lvsegs(struct format_instance *fid __attribute((unused)),
--- LVM2/lib/metadata/lv_manip.c	2009/05/13 21:22:57	1.167
+++ LVM2/lib/metadata/lv_manip.c	2009/05/13 21:25:02	1.168
@@ -402,7 +402,6 @@
  */
 static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 {
-	struct lv_list *lvl;
 	struct lv_segment *seg;
 	uint32_t count = extents;
 	uint32_t reduction;
@@ -433,12 +432,9 @@
 		return 1;
 
 	/* Remove the LV if it is now empty */
-	if (!lv->le_count) {
-		if (!(lvl = find_lv_in_vg(lv->vg, lv->name)))
-			return_0;
-
-		dm_list_del(&lvl->list);
-	} else if (lv->vg->fid->fmt->ops->lv_setup &&
+	if (!lv->le_count && !unlink_lv_from_vg(lv))
+		return_0;
+	else if (lv->vg->fid->fmt->ops->lv_setup &&
 		   !lv->vg->fid->fmt->ops->lv_setup(lv->vg->fid, lv))
 		return_0;
 
@@ -1819,8 +1815,6 @@
 				       struct volume_group *vg)
 {
 	struct format_instance *fi = vg->fid;
-	struct cmd_context *cmd = vg->cmd;
-	struct lv_list *ll = NULL;
 	struct logical_volume *lv;
 	char dname[NAME_LEN];
 
@@ -1840,23 +1834,11 @@
 	if (!import)
 		log_verbose("Creating logical volume %s", name);
 
-	if (!(ll = dm_pool_zalloc(cmd->mem, sizeof(*ll))) ||
-	    !(ll->lv = dm_pool_zalloc(cmd->mem, sizeof(*ll->lv)))) {
-		log_error("lv_list allocation failed");
-		if (ll)
-			dm_pool_free(cmd->mem, ll);
-		return NULL;
-	}
+	if (!(lv = dm_pool_zalloc(vg->vgmem, sizeof(*lv))))
+		return_NULL;
 
-	lv = ll->lv;
-	lv->vg = vg;
-
-	if (!(lv->name = dm_pool_strdup(cmd->mem, name))) {
-		log_error("lv name strdup failed");
-		if (ll)
-			dm_pool_free(cmd->mem, ll);
-		return NULL;
-	}
+	if (!(lv->name = dm_pool_strdup(vg->vgmem, name)))
+		goto_bad;
 
 	lv->status = status;
 	lv->alloc = alloc;
@@ -1874,15 +1856,16 @@
 	if (lvid)
 		lv->lvid = *lvid;
 
-	if (fi->fmt->ops->lv_setup && !fi->fmt->ops->lv_setup(fi, lv)) {
-		if (ll)
-			dm_pool_free(cmd->mem, ll);
-		return_NULL;
-	}
-
-	dm_list_add(&vg->lvs, &ll->list);
-
+	if (!link_lv_to_vg(vg, lv))
+		goto_bad;
+ 
+	if (fi->fmt->ops->lv_setup && !fi->fmt->ops->lv_setup(fi, lv))
+		goto_bad;
+ 
 	return lv;
+bad:
+	dm_pool_free(vg->vgmem, lv);
+	return NULL;
 }
 
 static int _add_pvs(struct cmd_context *cmd, struct pv_segment *peg,
@@ -1951,6 +1934,32 @@
 	return parallel_areas;
 }
 
+int link_lv_to_vg(struct volume_group *vg, struct logical_volume *lv)
+{
+	struct lv_list *lvl;
+
+	if (!(lvl = dm_pool_zalloc(vg->vgmem, sizeof(*lvl))))
+		return_0;
+
+	lvl->lv = lv;
+	lv->vg = vg;
+	dm_list_add(&vg->lvs, &lvl->list);
+
+	return 1;
+}
+
+int unlink_lv_from_vg(struct logical_volume *lv)
+{
+	struct lv_list *lvl;
+
+	if (!(lvl = find_lv_in_vg(lv->vg, lv->name)))
+		return_0;
+
+	dm_list_del(&lvl->list);
+
+	return 1;
+}
+
 int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		     const force_t force)
 {
--- LVM2/lib/metadata/metadata-exported.h	2009/05/13 21:22:57	1.68
+++ LVM2/lib/metadata/metadata-exported.h	2009/05/13 21:25:02	1.69
@@ -368,6 +368,12 @@
 				int warnings, int scan_label_only);
 struct dm_list *get_pvs(struct cmd_context *cmd);
 
+/*
+ * Add/remove LV to/from volume group
+ */
+int link_lv_to_vg(struct volume_group *vg, struct logical_volume *lv);
+int unlink_lv_from_vg(struct logical_volume *lv);
+
 /* Set full_scan to 1 to re-read every (filtered) device label */
 struct dm_list *get_vgnames(struct cmd_context *cmd, int full_scan);
 struct dm_list *get_vgids(struct cmd_context *cmd, int full_scan);


