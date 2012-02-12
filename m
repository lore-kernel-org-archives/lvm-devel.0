From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Feb 2012 23:01:20 -0000
Subject: LVM2/lib metadata/metadata-exported.h metadata ...
Message-ID: <20120212230120.7979.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-12 23:01:20

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	lib/cache      : lvmcache.c 
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: archive.c archiver.c format-text.c 

Log message:
	FMT_INSTANCE_VG is redundant now

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.229&r2=1.230
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.479&r2=1.480
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.124&r2=1.125
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.142&r2=1.143
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archive.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.189&r2=1.190

--- LVM2/lib/metadata/metadata-exported.h	2012/02/12 22:37:24	1.229
+++ LVM2/lib/metadata/metadata-exported.h	2012/02/12 23:01:19	1.230
@@ -199,20 +199,15 @@
 #define pvseg_is_allocated(pvseg) ((pvseg)->lvseg)
 
 /*
- * These flags define the type of the format instance to be created.
- * There used to be a PV-based type, but all are now VG-based.
- * We can further control the format_instance initialisation and functionality
- * by using the other flags. Today, the primary role of the format_instance
- * is to temporarily store metadata area information we are working with. More
- * flags can be defined to cover even more functionality in the future...
+ * Properties of each format instance type.
+ * The primary role of the format_instance is to temporarily store metadata
+ * area information we are working with.
  */
 
-/* VG-based format instance */
-#define FMT_INSTANCE_VG			0x00000001U
-
 /* Include any existing PV mdas during format_instance initialisation */
 #define FMT_INSTANCE_MDAS		0x00000002U
 
+/* FIXME Define auxiliary here! */
 /* Include any auxiliary mdas during format_instance intialisation */
 #define FMT_INSTANCE_AUX_MDAS		0x00000004U
 
--- LVM2/lib/metadata/metadata.c	2012/02/12 20:19:39	1.479
+++ LVM2/lib/metadata/metadata.c	2012/02/12 23:01:19	1.480
@@ -956,7 +956,7 @@
 
 	vg->pv_count = 0;
 
-	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
+	fic.type = FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = vg_name;
 	fic.context.vg_ref.vg_id = NULL;
 	if (!(fid = cmd->fmt->ops->create_instance(cmd->fmt, &fic))) {
@@ -2940,7 +2940,7 @@
 		use_precommitted = 0;
 
 	/* create format instance with appropriate metadata area */
-	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
+	fic.type = FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = vgname;
 	fic.context.vg_ref.vg_id = vgid;
 	if (!(fid = fmt->ops->create_instance(fmt, &fic))) {
@@ -3120,7 +3120,7 @@
 			use_precommitted = 0;
 
 		/* create format instance with appropriate metadata area */
-		fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
+		fic.type = FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
 		fic.context.vg_ref.vg_name = vgname;
 		fic.context.vg_ref.vg_id = vgid;
 		if (!(fid = fmt->ops->create_instance(fmt, &fic))) {
@@ -4207,14 +4207,12 @@
 		return 1;
 
 	/* Add metadata area to index. */
-	if (fid->type & FMT_INSTANCE_VG) {
-		if (!_convert_key_to_string(key, key_len, sub_key,
-					    full_key, sizeof(full_key)))
-		return_0;
+	if (!_convert_key_to_string(key, key_len, sub_key,
+				    full_key, sizeof(full_key)))
+	return_0;
 
-		dm_hash_insert(fid->metadata_areas_index,
-			       full_key, mda);
-	}
+	dm_hash_insert(fid->metadata_areas_index,
+		       full_key, mda);
 
 	return 1;
 }
@@ -4245,13 +4243,11 @@
 	struct metadata_area *mda = NULL;
 
 
-	if (fid->type & FMT_INSTANCE_VG) {
-		if (!_convert_key_to_string(key, key_len, sub_key,
-					    full_key, sizeof(full_key)))
-			return_NULL;
-		mda = (struct metadata_area *) dm_hash_lookup(fid->metadata_areas_index,
-							      full_key);
-	}
+	if (!_convert_key_to_string(key, key_len, sub_key,
+				    full_key, sizeof(full_key)))
+		return_NULL;
+	mda = (struct metadata_area *) dm_hash_lookup(fid->metadata_areas_index,
+						      full_key);
 
 	return mda;
 }
@@ -4278,13 +4274,11 @@
 
 		mda = mda_indexed;
 
-		if (fid->type & FMT_INSTANCE_VG) {
-			if (!_convert_key_to_string(key, key_len, sub_key,
-					    full_key, sizeof(full_key)))
-				return_0;
+		if (!_convert_key_to_string(key, key_len, sub_key,
+				    full_key, sizeof(full_key)))
+			return_0;
 
-			dm_hash_remove(fid->metadata_areas_index, full_key);
-		}
+		dm_hash_remove(fid->metadata_areas_index, full_key);
 	}
 
 	dm_list_del(&mda->list);
--- LVM2/lib/cache/lvmcache.c	2012/02/10 02:53:03	1.124
+++ LVM2/lib/cache/lvmcache.c	2012/02/12 23:01:19	1.125
@@ -707,7 +707,7 @@
 	if ((vg = vginfo->cached_vg))
 		goto out;
 
-	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
+	fic.type = FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = vginfo->vgname;
 	fic.context.vg_ref.vg_id = vgid;
 	if (!(fid = vginfo->fmt->ops->create_instance(vginfo->fmt, &fic)))
--- LVM2/lib/format1/format1.c	2012/02/10 02:53:04	1.142
+++ LVM2/lib/format1/format1.c	2012/02/12 23:01:19	1.143
@@ -609,7 +609,7 @@
 		log_error("Couldn't create lvm1 orphan VG.");
 		return NULL;
 	}
-	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_AUX_MDAS;
+	fic.type = FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = fmt->orphan_vg_name;
 	fic.context.vg_ref.vg_id = NULL;
 	if (!(fid = _format1_create_instance(fmt, &fic))) {
--- LVM2/lib/format_pool/format_pool.c	2012/02/10 02:53:04	1.47
+++ LVM2/lib/format_pool/format_pool.c	2012/02/12 23:01:19	1.48
@@ -322,7 +322,7 @@
 		log_error("Couldn't create lvm1 orphan VG.");
 		return NULL;
 	}
-	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_AUX_MDAS;
+	fic.type = FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = fmt->orphan_vg_name;
 	fic.context.vg_ref.vg_id = NULL;
 	if (!(fid = _pool_create_instance(fmt, &fic))) {
--- LVM2/lib/format_text/archive.c	2011/08/10 20:25:30	1.44
+++ LVM2/lib/format_text/archive.c	2012/02/12 23:01:19	1.45
@@ -310,7 +310,7 @@
 	log_print(" ");
 	log_print("File:\t\t%s", af->path);
 
-	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_PRIVATE_MDAS;
+	fic.type = FMT_INSTANCE_PRIVATE_MDAS;
 	fic.context.private = &tc;
 	if (!(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, &fic))) {
 		log_error("Couldn't create text instance object.");
--- LVM2/lib/format_text/archiver.c	2012/02/08 12:50:10	1.49
+++ LVM2/lib/format_text/archiver.c	2012/02/12 23:01:19	1.50
@@ -279,7 +279,7 @@
 				  .desc = cmd->cmd_line};
 	struct metadata_area *mda;
 
-	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_PRIVATE_MDAS;
+	fic.type = FMT_INSTANCE_PRIVATE_MDAS;
 	fic.context.private = &tc;
 	if (!(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, &fic))) {
 		log_error("Couldn't create text format object.");
@@ -312,7 +312,7 @@
 	 */
 
 	/* Attempt to write out using currently active format */
-	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_AUX_MDAS;
+	fic.type = FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = vg->name;
 	fic.context.vg_ref.vg_id = NULL;
 	if (!(fid = cmd->fmt->ops->create_instance(cmd->fmt, &fic))) {
@@ -409,7 +409,7 @@
 
 	log_verbose("Creating volume group backup \"%s\" (seqno %u).", file, vg->seqno);
 
-	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_PRIVATE_MDAS;
+	fic.type = FMT_INSTANCE_PRIVATE_MDAS;
 	fic.context.private = &tc;
 	if (!(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, &fic))) {
 		log_error("Couldn't create backup object.");
--- LVM2/lib/format_text/format-text.c	2012/02/10 02:53:05	1.189
+++ LVM2/lib/format_text/format-text.c	2012/02/12 23:01:19	1.190
@@ -1084,7 +1084,7 @@
 
 				/* FIXME stat file to see if it's changed */
 				/* FIXME: Check this fid is OK! */
-				fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_PRIVATE_MDAS;
+				fic.type = FMT_INSTANCE_PRIVATE_MDAS;
 				fic.context.private = NULL;
 				fid = _text_create_text_instance(fmt, &fic);
 				if ((vg = _vg_read_file_name(fid, scanned_vgname,
@@ -1513,7 +1513,7 @@
 static void _text_destroy_instance(struct format_instance *fid)
 {
 	if (--fid->ref_count <= 1) {
-		if (fid->type & FMT_INSTANCE_VG && fid->metadata_areas_index)
+		if (fid->metadata_areas_index)
 			dm_hash_destroy(fid->metadata_areas_index);
 		dm_pool_destroy(fid->mem);
 	}
@@ -1671,12 +1671,6 @@
 	return 1;
 }
 
-static int _create_pv_text_instance(struct format_instance *fid,
-                                    const struct format_instance_ctx *fic)
-{
-	return 0; /* just fail */
-}
-
 static void *_create_text_context(struct dm_pool *mem, struct text_context *tc)
 {
 	struct text_context *new_tc;
@@ -2173,8 +2167,7 @@
 	if (!(fid = alloc_fid(fmt, fic)))
 		return_NULL;
 
-	if (fid->type & FMT_INSTANCE_VG ? _create_vg_text_instance(fid, fic) :
-					  _create_pv_text_instance(fid, fic))
+	if (_create_vg_text_instance(fid, fic))
 		return fid;
 
 	dm_pool_destroy(fid->mem);
@@ -2342,7 +2335,7 @@
 		return NULL;
 	}
 
-	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_AUX_MDAS;
+	fic.type = FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = fmt->orphan_vg_name;
 	fic.context.vg_ref.vg_id = NULL;
 	if (!(fid = _text_create_text_instance(fmt, &fic))) {


