From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Mar 2011 14:38:41 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/format1.c lib/for ...
Message-ID: <20110311143841.3269.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-03-11 14:38:40

Modified files:
	.              : WHATS_NEW 
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: format-text.c 
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Add mem and ref_count fields to struct format_instance for own mempool use.
	
	Format instances can be created anytime on demand and it contains
	metadata area information mostly (at least for now, but in the future,
	we may store more things here to update/edit in a PV/VG). In case we
	have lots of metadata areas, memory consumption will rise. Using cmd
	context mempool is not quite optimal here because it is destroyed too
	late. So let's use a separate mempool for format instances.
	
	Reference counting is used because fids could be shared, e.g. each PV
	has either a PV-based fid or VG-based fid. If it's VG-based, each PV has
	a shared fid with the VG - a reference to VG's fid.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1945&r2=1.1946
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.135&r2=1.136
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.174&r2=1.175
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.185&r2=1.186
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.442&r2=1.443

--- LVM2/WHATS_NEW	2011/03/11 14:30:27	1.1945
+++ LVM2/WHATS_NEW	2011/03/11 14:38:38	1.1946
@@ -1,9 +1,10 @@
 Version 2.02.85 - 
 ===================================
+  Add mem and ref_count fields to struct format_instance for own mempool use.
   Use new alloc_fid fn for common format instance initialisation.
   Optimise _get_token() and _eat_space().
   Add _lv_postorder_vg() to improve efficiency for all LVs in VG.
-  Use hash tables to speedup string search in validate_vg().
+  Use hash tables to speedup string search in vg_validate().
   Refactor allocation of VG structure, add alloc_vg().
   Avoid possible endless loop in _free_vginfo when 4 or more VGs have same name.
   Use empty string instead of /dev// for LV path when there's no VG.
--- LVM2/lib/format1/format1.c	2011/03/11 14:30:27	1.135
+++ LVM2/lib/format1/format1.c	2011/03/11 14:38:39	1.136
@@ -509,8 +509,10 @@
 
 	/* Define a NULL metadata area */
 	if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda)))) {
+		log_error("Unable to allocate metadata area structure "
+			  "for lvm1 format");
 		dm_pool_free(fmt->cmd->mem, fid);
-		return_NULL;
+		goto bad;
 	}
 
 	mda->ops = &_metadata_format1_ops;
@@ -519,10 +521,16 @@
 	dm_list_add(&fid->metadata_areas_in_use, &mda->list);
 
 	return fid;
+
+bad:
+	dm_pool_destroy(fid->mem);
+	return NULL;
 }
 
-static void _format1_destroy_instance(struct format_instance *fid __attribute__((unused)))
+static void _format1_destroy_instance(struct format_instance *fid)
 {
+	if (--fid->ref_count <= 1)
+		dm_pool_destroy(fid->mem);
 }
 
 static void _format1_destroy(struct format_type *fmt)
--- LVM2/lib/format_pool/format_pool.c	2011/03/11 14:30:27	1.41
+++ LVM2/lib/format_pool/format_pool.c	2011/03/11 14:38:39	1.42
@@ -236,7 +236,7 @@
 		log_error("Unable to allocate metadata area structure "
 			  "for pool format");
 		dm_pool_free(fmt->cmd->mem, fid);
-		return NULL;
+		goto bad;
 	}
 
 	mda->ops = &_metadata_format_pool_ops;
@@ -245,10 +245,16 @@
 	dm_list_add(&fid->metadata_areas_in_use, &mda->list);
 
 	return fid;
+
+bad:
+	dm_pool_destroy(fid->mem);
+	return NULL;
 }
 
-static void _pool_destroy_instance(struct format_instance *fid __attribute__((unused)))
+static void _pool_destroy_instance(struct format_instance *fid)
 {
+	if (--fid->ref_count <= 1)
+		dm_pool_destroy(fid->mem);
 }
 
 static void _pool_destroy(struct format_type *fmt)
--- LVM2/lib/format_text/format-text.c	2011/03/11 14:30:27	1.174
+++ LVM2/lib/format_text/format-text.c	2011/03/11 14:38:39	1.175
@@ -1571,8 +1571,13 @@
 	return 1;
 }
 
-static void _text_destroy_instance(struct format_instance *fid __attribute__((unused)))
+static void _text_destroy_instance(struct format_instance *fid)
 {
+	if (--fid->ref_count <= 1) {
+		if (fid->type & FMT_INSTANCE_VG && fid->metadata_areas_index.hash)
+			dm_hash_destroy(fid->metadata_areas_index.hash);
+		dm_pool_destroy(fid->mem);
+	}
 }
 
 static void _free_dirs(struct dm_list *dir_list)
@@ -2188,28 +2193,21 @@
 	return 1;
 }
 
-/* NULL vgname means use only the supplied context e.g. an archive file */
 static struct format_instance *_text_create_text_instance(const struct format_type *fmt,
 							  const struct format_instance_ctx *fic)
 {
 	struct format_instance *fid;
-	int r;
 
 	if (!(fid = alloc_fid(fmt, fic)))
 		return_NULL;
 
-	if (fid->type & FMT_INSTANCE_VG)
-		r = _create_vg_text_instance(fid, fic);
-	else
-		r = _create_pv_text_instance(fid, fic);
-
-	if (r)
+	if (fid->type & FMT_INSTANCE_VG ? _create_vg_text_instance(fid, fic) :
+					  _create_pv_text_instance(fid, fic))
 		return fid;
-	else {
-		dm_pool_free(fmt->cmd->mem, fid);
-		return NULL;
-	}
 
+	dm_pool_free(fmt->cmd->mem, fid);
+	dm_pool_destroy(fid->mem);
+	return NULL;
 }
 
 void *create_text_context(struct cmd_context *cmd, const char *path,
--- LVM2/lib/metadata/metadata-exported.h	2011/03/02 20:00:09	1.185
+++ LVM2/lib/metadata/metadata-exported.h	2011/03/11 14:38:39	1.186
@@ -196,6 +196,9 @@
 #define FMT_INSTANCE_PRIVATE_MDAS 	0x00000008U
 
 struct format_instance {
+	unsigned ref_count;
+	struct dm_pool *mem;
+
 	uint32_t type;
 	const struct format_type *fmt;
 
--- LVM2/lib/metadata/metadata.c	2011/03/11 14:30:28	1.442
+++ LVM2/lib/metadata/metadata.c	2011/03/11 14:38:39	1.443
@@ -3944,20 +3944,30 @@
 struct format_instance *alloc_fid(const struct format_type *fmt,
 				  const struct format_instance_ctx *fic)
 {
+	struct dm_pool *mem;
 	struct format_instance *fid;
 
+	if (!(mem = dm_pool_create("format_instance", 1024)))
+		return_NULL;
+
 	if (!(fid = dm_pool_zalloc(fmt->cmd->mem, sizeof(*fid)))) {
 		log_error("Couldn't allocate format_instance object.");
-		return NULL;
+		goto bad;
 	}
 
-	fid->fmt = fmt;
+	fid->ref_count = 1;
+	fid->mem = mem;
 	fid->type = fic->type;
+	fid->fmt = fmt;
 
 	dm_list_init(&fid->metadata_areas_in_use);
 	dm_list_init(&fid->metadata_areas_ignored);
 
 	return fid;
+
+bad:
+	dm_pool_destroy(mem);
+	return NULL;
 }
 
 void vg_set_fid(struct volume_group *vg,


