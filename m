From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Mar 2011 14:50:17 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/format1.c lib/for ...
Message-ID: <20110311145017.11347.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-03-11 14:50:15

Modified files:
	.              : WHATS_NEW 
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: format-text.c import_vsn1.c 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Use only vg_set_fid and new pv_set_fid fn to assign the format instance.
	
	This is essential for proper format instance ref_count support. We must
	use these functions to set the fid everywhere from now on, even the NULL
	value!

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1947&r2=1.1948
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.136&r2=1.137
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.176&r2=1.177
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.443&r2=1.444
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.241&r2=1.242

--- LVM2/WHATS_NEW	2011/03/11 14:45:17	1.1947
+++ LVM2/WHATS_NEW	2011/03/11 14:50:13	1.1948
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Use only vg_set_fid and new pv_set_fid fn to assign the format instance.
   Make create_text_context fn static and move it inside create_instance fn.
   Add mem and ref_count fields to struct format_instance for own mempool use.
   Use new alloc_fid fn for common format instance initialisation.
--- LVM2/lib/format1/format1.c	2011/03/11 14:38:39	1.136
+++ LVM2/lib/format1/format1.c	2011/03/11 14:50:14	1.137
@@ -198,7 +198,7 @@
 	if (dm_list_empty(&pvs))
 		goto_bad;
 
-	vg->fid = fid;
+	vg_set_fid(vg, fid);
 
 	if (!_check_vgs(&pvs, vg))
 		goto_bad;
--- LVM2/lib/format_pool/format_pool.c	2011/03/11 14:38:39	1.42
+++ LVM2/lib/format_pool/format_pool.c	2011/03/11 14:50:14	1.43
@@ -120,7 +120,8 @@
 	if (!read_pool_pds(fid->fmt, vg_name, vg->vgmem, &pds))
 		goto_bad;
 
-	vg->fid = fid;
+	vg_set_fid(vg, fid);
+
 	/* Setting pool seqno to 1 because the code always did this,
 	 * although we don't think it's needed. */
 	vg->seqno = 1;
--- LVM2/lib/format_text/format-text.c	2011/03/11 14:45:18	1.176
+++ LVM2/lib/format_text/format-text.c	2011/03/11 14:50:15	1.177
@@ -1690,12 +1690,8 @@
 	    (pv_mdac = pv_mda->metadata_locn))
 		size_reduction = pv_mdac->area.size >> SECTOR_SHIFT;
 
-	/* Destroy old PV-based format instance if it exists. */
-	if (!(pv->fid->type & FMT_INSTANCE_VG))
-		pv->fmt->ops->destroy_instance(pv->fid);
-
 	/* From now on, VG format instance will be used. */
-	pv->fid = vg->fid;
+	pv_set_fid(pv, vg->fid);
 
 	/* FIXME Cope with genuine pe_count 0 */
 
--- LVM2/lib/format_text/import_vsn1.c	2011/03/10 12:43:29	1.83
+++ LVM2/lib/format_text/import_vsn1.c	2011/03/11 14:50:15	1.84
@@ -666,10 +666,6 @@
 	if (!(vg = alloc_vg("read_vg", fid->fmt->cmd, vgn->key)))
 		return_NULL;
 
-	/* FIXME Determine format type from file contents */
-	/* eg Set to instance of fmt1 here if reading a format1 backup? */
-	vg->fid = fid;
-
 	if (!(vg->system_id = dm_pool_zalloc(vg->vgmem, NAME_LEN)))
 		goto_bad;
 
@@ -796,6 +792,10 @@
 	dm_hash_destroy(pv_hash);
 	dm_hash_destroy(lv_hash);
 
+	/* FIXME Determine format type from file contents */
+	/* eg Set to instance of fmt1 here if reading a format1 backup? */
+	vg_set_fid(vg, fid);
+
 	/*
 	 * Finished.
 	 */
--- LVM2/lib/metadata/metadata.c	2011/03/11 14:38:39	1.443
+++ LVM2/lib/metadata/metadata.c	2011/03/11 14:50:15	1.444
@@ -166,14 +166,24 @@
 	dm_list_add(&vg->pvs, &pvl->list);
 	vg->pv_count++;
 	pvl->pv->vg = vg;
-	pvl->pv->fid = vg->fid;
+	pv_set_fid(pvl->pv, vg->fid);
 }
 
 void del_pvl_from_vgs(struct volume_group *vg, struct pv_list *pvl)
 {
+	struct format_instance_ctx fic;
+	struct format_instance *fid;
+
 	vg->pv_count--;
 	dm_list_del(&pvl->list);
 	pvl->pv->vg = NULL; /* orphan */
+
+	/* Use a new PV-based format instance since the PV is orphan now. */
+	fic.type = FMT_INSTANCE_PV | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
+	fic.context.pv_id = (const char *) &pvl->pv->id;
+	fid = pvl->pv->fid->fmt->ops->create_instance(pvl->pv->fid->fmt, &fic);
+
+	pv_set_fid(pvl->pv, fid);
 }
 
 
@@ -288,6 +298,10 @@
 {
 	memcpy(pv_to, pv_from, sizeof(*pv_to));
 
+	/* We must use pv_set_fid here to update the reference counter! */
+	pv_to->fid = NULL;
+	pv_set_fid(pv_to, pv_from->fid);
+
 	if (!(pv_to->vg_name = dm_pool_strdup(pvmem, pv_from->vg_name)))
 		return_0;
 
@@ -881,6 +895,7 @@
 {
 	struct volume_group *vg;
 	struct format_instance_ctx fic;
+	struct format_instance *fid;
 	int consistent = 0;
 	uint32_t rc;
 
@@ -937,10 +952,11 @@
 	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = vg_name;
 	fic.context.vg_ref.vg_id = NULL;
-	if (!(vg->fid = cmd->fmt->ops->create_instance(cmd->fmt, &fic))) {
+	if (!(fid = cmd->fmt->ops->create_instance(cmd->fmt, &fic))) {
 		log_error("Failed to create format instance");
 		goto bad;
 	}
+	vg_set_fid(vg, fid);
 
 	if (vg->fid->fmt->ops->vg_setup &&
 	    !vg->fid->fmt->ops->vg_setup(vg->fid, vg)) {
@@ -1507,7 +1523,7 @@
 	if (!pv)
 		return_NULL;
 
-	pv->fid = NULL;
+	pv_set_fid(pv, NULL);
 	pv->pe_size = 0;
 	pv->pe_start = 0;
 	pv->pe_count = 0;
@@ -1562,6 +1578,7 @@
 {
 	const struct format_type *fmt = cmd->fmt;
 	struct format_instance_ctx fic;
+	struct format_instance *fid;
 	struct dm_pool *mem = fmt->cmd->mem;
 	struct physical_volume *pv = _alloc_pv(mem, dev);
 	unsigned mda_index;
@@ -1605,10 +1622,11 @@
 
 	fic.type = FMT_INSTANCE_PV;
 	fic.context.pv_id = (const char *) &pv->id;
-	if (!(pv->fid = fmt->ops->create_instance(fmt, &fic))) {
+	if (!(fid = fmt->ops->create_instance(fmt, &fic))) {
 		log_error("Couldn't create format instance for PV %s.", pv_dev_name(pv));
 		goto bad;
 	}
+	pv_set_fid(pv, fid);
 
 	pv->fmt = fmt;
 	pv->vg_name = fmt->orphan_vg_name;
@@ -2615,6 +2633,7 @@
 					     const char *orphan_vgname)
 {
 	struct format_instance_ctx fic;
+	struct format_instance *fid;
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
 	struct pv_list *pvl;
@@ -2633,10 +2652,11 @@
 	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = orphan_vgname;
 	fic.context.vg_ref.vg_id = NULL;
-	if (!(vg->fid = vginfo->fmt->ops->create_instance(vginfo->fmt, &fic))) {
+	if (!(fid = vginfo->fmt->ops->create_instance(vginfo->fmt, &fic))) {
 		log_error("Failed to create format instance");
 		goto bad;
 	}
+	vg_set_fid(vg, fid);
 
 	dm_list_iterate_items(info, &vginfo->infos) {
 		if (!(pv = _pv_read(cmd, vg->vgmem, dev_name(info->dev),
@@ -3415,11 +3435,12 @@
 	else {
 		fic.type = FMT_INSTANCE_PV | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
 		fic.context.pv_id = (const char *) &pv->id;
-		if (!(pv->fid = pv->fmt->ops->create_instance(pv->fmt, &fic))) {
+		if (!(fid = pv->fmt->ops->create_instance(pv->fmt, &fic))) {
 			log_error("_pv_read: Couldn't create format instance "
 				  "for PV %s", pv_name);
 			goto bad;
 		}
+		pv_set_fid(pv, fid);
 	}
 
 	return pv;
@@ -3970,14 +3991,31 @@
 	return NULL;
 }
 
+void pv_set_fid(struct physical_volume *pv,
+		struct format_instance *fid)
+{
+	if (pv->fid)
+		pv->fid->fmt->ops->destroy_instance(pv->fid);
+
+	pv->fid = fid;
+	if (fid)
+		fid->ref_count++;
+}
+
 void vg_set_fid(struct volume_group *vg,
 		 struct format_instance *fid)
 {
 	struct pv_list *pvl;
 
+	if (vg->fid)
+		vg->fid->fmt->ops->destroy_instance(vg->fid);
+
 	vg->fid = fid;
+	if (fid)
+		fid->ref_count++;
+
 	dm_list_iterate_items(pvl, &vg->pvs)
-		pvl->pv->fid = fid;
+		pv_set_fid(pvl->pv, fid);
 }
 
 static int _convert_key_to_string(const char *key, size_t key_len,
--- LVM2/lib/metadata/metadata.h	2011/03/11 14:30:28	1.241
+++ LVM2/lib/metadata/metadata.h	2011/03/11 14:50:15	1.242
@@ -206,7 +206,15 @@
 
 struct format_instance *alloc_fid(const struct format_type *fmt,
 				  const struct format_instance_ctx *fic);
+
+/*
+ * Format instance must always be set using pv_set_fid or vg_set_fid
+ * (NULL value as well), never asign it directly! This is essential
+ * for proper reference counting for the format instance.
+ */
+void pv_set_fid(struct physical_volume *pv, struct format_instance *fid);
 void vg_set_fid(struct volume_group *vg, struct format_instance *fid);
+
 /* FIXME: Add generic interface for mda counts based on given key. */
 int fid_add_mda(struct format_instance *fid, struct metadata_area *mda,
 		const char *key, size_t key_len, const unsigned sub_key);


