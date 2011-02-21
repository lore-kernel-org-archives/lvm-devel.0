From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 21 Feb 2011 12:05:51 -0000
Subject: LVM2/lib format1/format1.c format_pool/format_ ...
Message-ID: <20110221120551.25666.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-21 12:05:50

Modified files:
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: format-text.c format-text.h 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Change create_instance to create PV-based as well as VG-based format instances.
	Add supporting functions to work with the format instance and metadata area
	structures stored within the format instance. Add support for simple indexing
	of metadata areas using PV id and mda order (for on-disk PV only for now, we
	can extend the indexing even for other mdas if needed - we only need to define
	a proper key for the index).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.127&r2=1.128
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.155&r2=1.156
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.h.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.424&r2=1.425
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.230&r2=1.231

--- LVM2/lib/format1/format1.c	2010/12/20 14:06:33	1.127
+++ LVM2/lib/format1/format1.c	2011/02/21 12:05:49	1.128
@@ -522,9 +522,7 @@
 };
 
 static struct format_instance *_format1_create_instance(const struct format_type *fmt,
-						const char *vgname __attribute__((unused)),
-						const char *vgid __attribute__((unused)),
-						void *private __attribute__((unused)))
+							const struct format_instance_ctx *fic)
 {
 	struct format_instance *fid;
 	struct metadata_area *mda;
@@ -533,6 +531,8 @@
 		return_NULL;
 
 	fid->fmt = fmt;
+	fid->type = fic->type;
+
 	dm_list_init(&fid->metadata_areas_in_use);
 	dm_list_init(&fid->metadata_areas_ignored);
 
--- LVM2/lib/format_pool/format_pool.c	2010/12/20 13:32:49	1.35
+++ LVM2/lib/format_pool/format_pool.c	2011/02/21 12:05:50	1.36
@@ -249,9 +249,7 @@
 /* *INDENT-ON* */
 
 static struct format_instance *_pool_create_instance(const struct format_type *fmt,
-						const char *vgname __attribute__((unused)),
-						const char *vgid __attribute__((unused)),
-						void *private __attribute__((unused)))
+						     const struct format_instance_ctx *fic)
 {
 	struct format_instance *fid;
 	struct metadata_area *mda;
@@ -263,6 +261,8 @@
 	}
 
 	fid->fmt = fmt;
+	fid->type = fic->type;
+
 	dm_list_init(&fid->metadata_areas_in_use);
 	dm_list_init(&fid->metadata_areas_ignored);
 
--- LVM2/lib/format_text/format-text.c	2011/02/18 14:16:12	1.155
+++ LVM2/lib/format_text/format-text.c	2011/02/21 12:05:50	1.156
@@ -37,16 +37,18 @@
 #include <dirent.h>
 #include <ctype.h>
 
-static struct format_instance *_text_create_text_instance(const struct format_type
-						     *fmt, const char *vgname,
-						     const char *vgid,
-						     void *context);
+static struct format_instance *_text_create_text_instance(const struct format_type *fmt,
+							  const struct format_instance_ctx *fic);
 
 struct text_fid_context {
 	char *raw_metadata_buf;
 	uint32_t raw_metadata_buf_size;
 };
 
+struct text_fid_pv_context {
+	int64_t label_sector;
+};
+
 struct dir_list {
 	struct dm_list list;
 	char dir[0];
@@ -1911,13 +1913,38 @@
 	return 1;
 }
 
-/* NULL vgname means use only the supplied context e.g. an archive file */
-static struct format_instance *_text_create_text_instance(const struct format_type
-						     *fmt, const char *vgname,
-						     const char *vgid,
-						     void *context)
+static int _create_pv_text_instance(struct format_instance *fid,
+                                    const struct format_instance_ctx *fic)
 {
-	struct format_instance *fid;
+	struct text_fid_pv_context *fid_pv_tc;
+	struct lvmcache_info *info;
+
+	if (!(fid_pv_tc = (struct text_fid_pv_context *)
+			dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*fid_pv_tc)))) {
+		log_error("Couldn't allocate text_fid_pv_context.");
+		return 0;
+	}
+	fid_pv_tc->label_sector = -1;
+	fid->private = (void *) fid_pv_tc;
+
+	if (!(fid->metadata_areas_index.array = dm_pool_zalloc(fid->fmt->cmd->mem,
+					FMT_TEXT_MAX_MDAS_PER_PV *
+					sizeof(struct metadata_area *)))) {
+		log_error("Couldn't allocate format instance metadata index.");
+		return 0;
+	}
+
+	if (fic->type & FMT_INSTANCE_MDAS &&
+	    (info = info_from_pvid(fic->context.pv_id, 0)))
+		fid_add_mdas(fid, &info->mdas, fic->context.pv_id, ID_LEN);
+
+	return 1;
+}
+
+static int _create_vg_text_instance(struct format_instance *fid,
+                                    const struct format_instance_ctx *fic)
+{
+	uint32_t type = fic->type;
 	struct text_fid_context *fidtc;
 	struct metadata_area *mda;
 	struct mda_context *mdac;
@@ -1927,86 +1954,120 @@
 	char path[PATH_MAX];
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
-
-	if (!(fid = dm_pool_alloc(fmt->cmd->mem, sizeof(*fid)))) {
-		log_error("Couldn't allocate format instance object.");
-		return NULL;
-	}
+	const char *vg_name, *vg_id;
 
 	if (!(fidtc = (struct text_fid_context *)
-			dm_pool_zalloc(fmt->cmd->mem,sizeof(*fidtc)))) {
+			dm_pool_zalloc(fid->fmt->cmd->mem,sizeof(*fidtc)))) {
 		log_error("Couldn't allocate text_fid_context.");
-		return NULL;
+		return 0;
 	}
 
 	fidtc->raw_metadata_buf = NULL;
 	fid->private = (void *) fidtc;
 
-	fid->fmt = fmt;
-	dm_list_init(&fid->metadata_areas_in_use);
-	dm_list_init(&fid->metadata_areas_ignored);
-
-	if (!vgname) {
-		if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda))))
-			return_NULL;
+	if (type & FMT_INSTANCE_PRIVATE_MDAS) {
+		if (!(mda = dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*mda))))
+			return_0;
 		mda->ops = &_metadata_text_file_backup_ops;
-		mda->metadata_locn = context;
+		mda->metadata_locn = fic->context.private;
 		mda->status = 0;
-		fid_add_mda(fid, mda);
+		fid->metadata_areas_index.hash = NULL;
+		fid_add_mda(fid, mda, NULL, 0, 0);
 	} else {
-		dir_list = &((struct mda_lists *) fmt->private)->dirs;
+		vg_name = fic->context.vg_ref.vg_name;
+		vg_id = fic->context.vg_ref.vg_id;
+
+		if (!(fid->metadata_areas_index.hash = dm_hash_create(128))) {
+			log_error("Couldn't create metadata index for format "
+				  "instance of VG %s.", vg_name);
+			return 0;
+		}
 
-		dm_list_iterate_items(dl, dir_list) {
-			if (dm_snprintf(path, PATH_MAX, "%s/%s",
-					 dl->dir, vgname) < 0) {
-				log_error("Name too long %s/%s", dl->dir,
-					  vgname);
-				return NULL;
+		if (type & FMT_INSTANCE_AUX_MDAS) {
+			dir_list = &((struct mda_lists *) fid->fmt->private)->dirs;
+			dm_list_iterate_items(dl, dir_list) {
+				if (dm_snprintf(path, PATH_MAX, "%s/%s", dl->dir, vg_name) < 0) {
+					log_error("Name too long %s/%s", dl->dir, vg_name);
+					return 0;
+				}
+
+				if (!(mda = dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*mda))))
+					return_0;
+				mda->ops = &_metadata_text_file_ops;
+				mda->metadata_locn = create_text_context(fid->fmt->cmd, path, NULL);
+				mda->status = 0;
+				fid_add_mda(fid, mda, NULL, 0, 0);
 			}
 
-			context = create_text_context(fmt->cmd, path, NULL);
-			if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda))))
-				return_NULL;
-			mda->ops = &_metadata_text_file_ops;
-			mda->metadata_locn = context;
-			mda->status = 0;
-			fid_add_mda(fid, mda);
-		}
-
-		raw_list = &((struct mda_lists *) fmt->private)->raws;
-
-		dm_list_iterate_items(rl, raw_list) {
-			/* FIXME Cache this; rescan below if some missing */
-			if (!_raw_holds_vgname(fid, &rl->dev_area, vgname))
-				continue;
-
-			if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda))))
-				return_NULL;
-
-			if (!(mdac = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mdac))))
-				return_NULL;
-			mda->metadata_locn = mdac;
-			/* FIXME Allow multiple dev_areas inside area */
-			memcpy(&mdac->area, &rl->dev_area, sizeof(mdac->area));
-			mda->ops = &_metadata_text_raw_ops;
-			mda->status = 0;
-			/* FIXME MISTAKE? mda->metadata_locn = context; */
-			fid_add_mda(fid, mda);
-		}
-
-		/* Scan PVs in VG for any further MDAs */
-		lvmcache_label_scan(fmt->cmd, 0);
-		if (!(vginfo = vginfo_from_vgname(vgname, vgid)))
-			goto_out;
-		dm_list_iterate_items(info, &vginfo->infos) {
-			if (!fid_add_mdas(fid, &info->mdas))
-				return_NULL;
+			raw_list = &((struct mda_lists *) fid->fmt->private)->raws;
+			dm_list_iterate_items(rl, raw_list) {
+				/* FIXME Cache this; rescan below if some missing */
+				if (!_raw_holds_vgname(fid, &rl->dev_area, vg_name))
+					continue;
+
+				if (!(mda = dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*mda))))
+					return_0;
+
+				if (!(mdac = dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*mdac))))
+					return_0;
+				mda->metadata_locn = mdac;
+				/* FIXME Allow multiple dev_areas inside area */
+				memcpy(&mdac->area, &rl->dev_area, sizeof(mdac->area));
+				mda->ops = &_metadata_text_raw_ops;
+				mda->status = 0;
+				/* FIXME MISTAKE? mda->metadata_locn = context; */
+				fid_add_mda(fid, mda, NULL, 0, 0);
+			}
+		}
+
+		if (type & FMT_INSTANCE_MDAS) {
+			/* Scan PVs in VG for any further MDAs */
+			lvmcache_label_scan(fid->fmt->cmd, 0);
+			if (!(vginfo = vginfo_from_vgname(vg_name, vg_id)))
+				goto_out;
+			dm_list_iterate_items(info, &vginfo->infos) {
+				if (!fid_add_mdas(fid, &info->mdas, info->dev->pvid, ID_LEN))
+					return_0;
+			}
 		}
+
 		/* FIXME Check raw metadata area count - rescan if required */
 	}
 
-      out:
-	return fid;
+out:
+	return 1;
+}
+
+/* NULL vgname means use only the supplied context e.g. an archive file */
+static struct format_instance *_text_create_text_instance(const struct format_type *fmt,
+							   const struct format_instance_ctx *fic)
+{
+	struct format_instance *fid;
+	int r;
+
+	if (!(fid = dm_pool_alloc(fmt->cmd->mem, sizeof(*fid)))) {
+		log_error("Couldn't allocate format instance object.");
+		return NULL;
+	}
+
+	fid->fmt = fmt;
+	fid->type = fic->type;
+
+	dm_list_init(&fid->metadata_areas_in_use);
+	dm_list_init(&fid->metadata_areas_ignored);
+
+	if (fid->type & FMT_INSTANCE_VG)
+		r = _create_vg_text_instance(fid, fic);
+	else
+		r = _create_pv_text_instance(fid, fic);
+
+	if (r)
+		return fid;
+	else {
+		dm_pool_free(fmt->cmd->mem, fid);
+		return NULL;
+	}
+
 }
 
 void *create_text_context(struct cmd_context *cmd, const char *path,
--- LVM2/lib/format_text/format-text.h	2010/06/30 12:17:24	1.28
+++ LVM2/lib/format_text/format-text.h	2011/02/21 12:05:50	1.29
@@ -22,6 +22,7 @@
 #define FMT_TEXT_NAME "lvm2"
 #define FMT_TEXT_ALIAS "text"
 #define FMT_TEXT_ORPHAN_VG_NAME ORPHAN_VG_NAME(FMT_TEXT_NAME)
+#define FMT_TEXT_MAX_MDAS_PER_PV 2
 
 /*
  * Archives a vg config.  'retain_days' is the minimum number of
--- LVM2/lib/metadata/metadata.c	2011/02/18 14:47:30	1.424
+++ LVM2/lib/metadata/metadata.c	2011/02/21 12:05:50	1.425
@@ -2887,7 +2887,8 @@
 					break;
 				}
 				if (dm_list_size(&info->mdas)) {
-					if (!fid_add_mdas(fid, &info->mdas))
+					if (!fid_add_mdas(fid, &info->mdas,
+							  info->dev->pvid, ID_LEN))
 						return_NULL;
 					 
 					log_debug("Empty mda found for VG %s.", vgname);
@@ -3918,22 +3919,117 @@
 	return FAILED_EXIST;
 }
 
-void fid_add_mda(struct format_instance *fid, struct metadata_area *mda)
+static int _convert_key_to_string(const char *key, size_t key_len,
+				  unsigned sub_key, char *buf, size_t buf_len)
 {
+	memcpy(buf, key, key_len);
+	buf += key_len;
+	buf_len -= key_len;
+	if ((dm_snprintf(buf, buf_len, "_%u", sub_key) == -1))
+		return_0;
+
+	return 1;
+}
+
+int fid_add_mda(struct format_instance *fid, struct metadata_area *mda,
+		 const char *key, size_t key_len, const unsigned sub_key)
+{
+	char full_key[PATH_MAX];
 	dm_list_add(mda_is_ignored(mda) ? &fid->metadata_areas_ignored :
 					  &fid->metadata_areas_in_use, &mda->list);
+
+	/* Return if the mda is not supposed to be indexed. */
+	if (!key)
+		return 1;
+
+	/* Add metadata area to index. */
+	if (fid->type & FMT_INSTANCE_VG) {
+		if (!_convert_key_to_string(key, key_len, sub_key,
+					    full_key, PATH_MAX))
+		return_0;
+
+		dm_hash_insert(fid->metadata_areas_index.hash,
+			       full_key, mda);
+	}
+	else
+		fid->metadata_areas_index.array[sub_key] = mda;
+
+	return 1;
 }
 
-int fid_add_mdas(struct format_instance *fid, struct dm_list *mdas)
+int fid_add_mdas(struct format_instance *fid, struct dm_list *mdas,
+		 const char *key, size_t key_len)
 {
 	struct metadata_area *mda, *mda_new;
+	unsigned mda_index = 0;
 
 	dm_list_iterate_items(mda, mdas) {
 		mda_new = mda_copy(fid->fmt->cmd->mem, mda);
 		if (!mda_new)
 			return_0;
-		fid_add_mda(fid, mda_new);
+
+		fid_add_mda(fid, mda_new, key, key_len, mda_index);
+		mda_index++;
+	}
+
+	return 1;
+}
+
+struct metadata_area *fid_get_mda_indexed(struct format_instance *fid,
+					  const char *key, size_t key_len,
+					  const unsigned sub_key)
+{
+	char full_key[PATH_MAX];
+	struct metadata_area *mda = NULL;
+
+
+	if (fid->type & FMT_INSTANCE_VG) {
+		if (!_convert_key_to_string(key, key_len, sub_key,
+					    full_key, PATH_MAX))
+			return_NULL;
+		mda = (struct metadata_area *) dm_hash_lookup(fid->metadata_areas_index.hash,
+							      full_key);
 	}
+	else
+		mda = fid->metadata_areas_index.array[sub_key];
+
+	return mda;
+}
+
+int fid_remove_mda(struct format_instance *fid, struct metadata_area *mda,
+		   const char *key, size_t key_len, const unsigned sub_key)
+{
+	struct metadata_area *mda_indexed = NULL;
+	char full_key[PATH_MAX];
+
+	/* At least one of mda or key must be specified. */
+	if (!mda && !key)
+		return 1;
+
+	if (key) {
+		/*
+		 * If both mda and key specified, check given mda
+		 * with what we find using the index and return
+		 * immediately if these two do not match.
+		 */
+		if (!(mda_indexed = fid_get_mda_indexed(fid, key, key_len, sub_key)) ||
+		     (mda && mda != mda_indexed))
+			return 1;
+
+		mda = mda_indexed;
+
+		if (fid->type & FMT_INSTANCE_VG) {
+			if (!_convert_key_to_string(key, key_len, sub_key,
+					    full_key, PATH_MAX))
+				return_0;
+
+			dm_hash_remove(fid->metadata_areas_index.hash, full_key);
+		} else
+			fid->metadata_areas_index.array[sub_key] = NULL;
+	}
+
+	dm_list_del(&mda->list);
+
 	return 1;
 }
 
--- LVM2/lib/metadata/metadata.h	2011/02/21 12:01:23	1.230
+++ LVM2/lib/metadata/metadata.h	2011/02/21 12:05:50	1.231
@@ -190,8 +190,14 @@
 unsigned mda_is_ignored(struct metadata_area *mda);
 void mda_set_ignored(struct metadata_area *mda, unsigned ignored);
 unsigned mda_locns_match(struct metadata_area *mda1, struct metadata_area *mda2);
-void fid_add_mda(struct format_instance *fid, struct metadata_area *mda);
-int fid_add_mdas(struct format_instance *fid, struct dm_list *mdas);
+int fid_add_mda(struct format_instance *fid, struct metadata_area *mda,
+		const char *key, size_t key_len, const unsigned sub_key);
+int fid_add_mdas(struct format_instance *fid, struct dm_list *mdas,
+		 const char *key, size_t key_len);
+int fid_remove_mda(struct format_instance *fid, struct metadata_area *mda,
+		   const char *key, size_t key_len, const unsigned sub_key);
+struct metadata_area *fid_get_mda_indexed(struct format_instance *fid,
+		const char *key, size_t key_len, const unsigned sub_key);
 int mdas_empty_or_ignored(struct dm_list *mdas);
 
 #define seg_pvseg(seg, s)	(seg)->areas[(s)].u.pv.pvseg
@@ -290,10 +296,8 @@
 	/*
 	 * Create format instance with a particular metadata area
 	 */
-	struct format_instance *(*create_instance) (const struct format_type *
-						    fmt, const char *vgname,
-						    const char *vgid,
-						    void *context);
+	struct format_instance *(*create_instance) (const struct format_type *fmt,
+						    const struct format_instance_ctx *fic);
 
 	/*
 	 * Destructor for format instance


