From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Mar 2011 15:10:19 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/format1.c lib/for ...
Message-ID: <20110311151019.28015.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-03-11 15:10:17

Modified files:
	.              : WHATS_NEW 
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: format-text.c 
	lib/metadata   : metadata.c 

Log message:
	Use format instance mempool where possible and adequate.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1950&r2=1.1951
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.137&r2=1.138
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.177&r2=1.178
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.447&r2=1.448

--- LVM2/WHATS_NEW	2011/03/11 15:06:13	1.1950
+++ LVM2/WHATS_NEW	2011/03/11 15:10:16	1.1951
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Use format instance mempool where possible and adequate.
   Call destroy_instance for any PVs found in VG structure during vg_free call.
   Add new free_pv_fid fn and use it throughout to free all attached fids.
   Use only vg_set_fid and new pv_set_fid fn to assign the format instance.
--- LVM2/lib/format1/format1.c	2011/03/11 14:50:14	1.137
+++ LVM2/lib/format1/format1.c	2011/03/11 15:10:16	1.138
@@ -508,10 +508,9 @@
 		return_NULL;
 
 	/* Define a NULL metadata area */
-	if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda)))) {
+	if (!(mda = dm_pool_zalloc(fid->mem, sizeof(*mda)))) {
 		log_error("Unable to allocate metadata area structure "
 			  "for lvm1 format");
-		dm_pool_free(fmt->cmd->mem, fid);
 		goto bad;
 	}
 
--- LVM2/lib/format_pool/format_pool.c	2011/03/11 14:50:14	1.43
+++ LVM2/lib/format_pool/format_pool.c	2011/03/11 15:10:16	1.44
@@ -233,10 +233,9 @@
 		return_NULL;
 
 	/* Define a NULL metadata area */
-	if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda)))) {
+	if (!(mda = dm_pool_zalloc(fid->mem, sizeof(*mda)))) {
 		log_error("Unable to allocate metadata area structure "
 			  "for pool format");
-		dm_pool_free(fmt->cmd->mem, fid);
 		goto bad;
 	}
 
--- LVM2/lib/format_text/format-text.c	2011/03/11 14:50:15	1.177
+++ LVM2/lib/format_text/format-text.c	2011/03/11 15:10:17	1.178
@@ -1659,7 +1659,7 @@
 
 			/* Be sure it's not already in VG's format instance! */
 			if (!fid_get_mda_indexed(vg->fid, pvid, ID_LEN, mda_index)) {
-				pv_mda_copy = mda_copy(vg->fid->fmt->cmd->mem, pv_mda);
+				pv_mda_copy = mda_copy(vg->fid->mem, pv_mda);
 				fid_add_mda(vg->fid, pv_mda_copy, pvid, ID_LEN, mda_index);
 			}
 		}
@@ -1727,14 +1727,14 @@
 	struct lvmcache_info *info;
 
 	if (!(fid_pv_tc = (struct text_fid_pv_context *)
-			dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*fid_pv_tc)))) {
+			dm_pool_zalloc(fid->mem, sizeof(*fid_pv_tc)))) {
 		log_error("Couldn't allocate text_fid_pv_context.");
 		return 0;
 	}
 	fid_pv_tc->label_sector = -1;
 	fid->private = (void *) fid_pv_tc;
 
-	if (!(fid->metadata_areas_index.array = dm_pool_zalloc(fid->fmt->cmd->mem,
+	if (!(fid->metadata_areas_index.array = dm_pool_zalloc(fid->mem,
 					FMT_TEXT_MAX_MDAS_PER_PV *
 					sizeof(struct metadata_area *)))) {
 		log_error("Couldn't allocate format instance metadata index.");
@@ -1811,7 +1811,7 @@
 	const char *vg_name, *vg_id;
 
 	if (!(fidtc = (struct text_fid_context *)
-			dm_pool_zalloc(fid->fmt->cmd->mem,sizeof(*fidtc)))) {
+			dm_pool_zalloc(fid->mem, sizeof(*fidtc)))) {
 		log_error("Couldn't allocate text_fid_context.");
 		return 0;
 	}
@@ -1820,10 +1820,10 @@
 	fid->private = (void *) fidtc;
 
 	if (type & FMT_INSTANCE_PRIVATE_MDAS) {
-		if (!(mda = dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*mda))))
+		if (!(mda = dm_pool_zalloc(fid->mem, sizeof(*mda))))
 			return_0;
 		mda->ops = &_metadata_text_file_backup_ops;
-		mda->metadata_locn = _create_text_context(fid->fmt->cmd->mem, fic->context.private);
+		mda->metadata_locn = _create_text_context(fid->mem, fic->context.private);
 		mda->status = 0;
 		fid->metadata_areas_index.hash = NULL;
 		fid_add_mda(fid, mda, NULL, 0, 0);
@@ -1845,12 +1845,12 @@
 					return 0;
 				}
 
-				if (!(mda = dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*mda))))
+				if (!(mda = dm_pool_zalloc(fid->mem, sizeof(*mda))))
 					return_0;
 				mda->ops = &_metadata_text_file_ops;
 				tc.path_live = path;
 				tc.path_edit = tc.desc = NULL;
-				mda->metadata_locn = _create_text_context(fid->fmt->cmd->mem, &tc);
+				mda->metadata_locn = _create_text_context(fid->mem, &tc);
 				mda->status = 0;
 				fid_add_mda(fid, mda, NULL, 0, 0);
 			}
@@ -1861,10 +1861,10 @@
 				if (!_raw_holds_vgname(fid, &rl->dev_area, vg_name))
 					continue;
 
-				if (!(mda = dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*mda))))
+				if (!(mda = dm_pool_zalloc(fid->mem, sizeof(*mda))))
 					return_0;
 
-				if (!(mdac = dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*mdac))))
+				if (!(mdac = dm_pool_zalloc(fid->mem, sizeof(*mdac))))
 					return_0;
 				mda->metadata_locn = mdac;
 				/* FIXME Allow multiple dev_areas inside area */
@@ -1912,12 +1912,12 @@
 					  pv->fmt->name);
 	}
 
-	if (!(mda = dm_malloc(sizeof(struct metadata_area)))) {
+	if (!(mda = dm_pool_zalloc(pv->fid->mem, sizeof(struct metadata_area)))) {
 		log_error("struct metadata_area allocation failed");
 		return 0;
 	}
 
-	if (!(mdac = dm_malloc(sizeof(struct mda_context)))) {
+	if (!(mdac = dm_pool_zalloc(pv->fid->mem, sizeof(struct mda_context)))) {
 		log_error("struct mda_context allocation failed");
 		dm_free(mda);
 		return 0;
@@ -2244,7 +2244,6 @@
 					  _create_pv_text_instance(fid, fic))
 		return fid;
 
-	dm_pool_free(fmt->cmd->mem, fid);
 	dm_pool_destroy(fid->mem);
 	return NULL;
 }
--- LVM2/lib/metadata/metadata.c	2011/03/11 15:08:32	1.447
+++ LVM2/lib/metadata/metadata.c	2011/03/11 15:10:17	1.448
@@ -4025,7 +4025,7 @@
 	if (!(mem = dm_pool_create("format_instance", 1024)))
 		return_NULL;
 
-	if (!(fid = dm_pool_zalloc(fmt->cmd->mem, sizeof(*fid)))) {
+	if (!(fid = dm_pool_zalloc(mem, sizeof(*fid)))) {
 		log_error("Couldn't allocate format_instance object.");
 		goto bad;
 	}
@@ -4117,7 +4117,7 @@
 	unsigned mda_index = 0;
 
 	dm_list_iterate_items(mda, mdas) {
-		mda_new = mda_copy(fid->fmt->cmd->mem, mda);
+		mda_new = mda_copy(fid->mem, mda);
 		if (!mda_new)
 			return_0;
 		fid_remove_mda(fid, NULL, key, key_len, mda_index);


