From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Mar 2011 14:30:29 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/format1.c lib/for ...
Message-ID: <20110311143029.9562.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-03-11 14:30:28

Modified files:
	.              : WHATS_NEW 
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: format-text.c 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Use new alloc_fid fn for common format instance initialisation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1944&r2=1.1945
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.134&r2=1.135
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.173&r2=1.174
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.441&r2=1.442
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.240&r2=1.241

--- LVM2/WHATS_NEW	2011/03/10 14:51:35	1.1944
+++ LVM2/WHATS_NEW	2011/03/11 14:30:27	1.1945
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Use new alloc_fid fn for common format instance initialisation.
   Optimise _get_token() and _eat_space().
   Add _lv_postorder_vg() to improve efficiency for all LVs in VG.
   Use hash tables to speedup string search in validate_vg().
--- LVM2/lib/format1/format1.c	2011/03/10 12:43:29	1.134
+++ LVM2/lib/format1/format1.c	2011/03/11 14:30:27	1.135
@@ -504,15 +504,9 @@
 	struct format_instance *fid;
 	struct metadata_area *mda;
 
-	if (!(fid = dm_pool_alloc(fmt->cmd->mem, sizeof(*fid))))
+	if (!(fid = alloc_fid(fmt, fic)))
 		return_NULL;
 
-	fid->fmt = fmt;
-	fid->type = fic->type;
-
-	dm_list_init(&fid->metadata_areas_in_use);
-	dm_list_init(&fid->metadata_areas_ignored);
-
 	/* Define a NULL metadata area */
 	if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda)))) {
 		dm_pool_free(fmt->cmd->mem, fid);
--- LVM2/lib/format_pool/format_pool.c	2011/03/10 12:43:29	1.40
+++ LVM2/lib/format_pool/format_pool.c	2011/03/11 14:30:27	1.41
@@ -228,17 +228,8 @@
 	struct format_instance *fid;
 	struct metadata_area *mda;
 
-	if (!(fid = dm_pool_zalloc(fmt->cmd->mem, sizeof(*fid)))) {
-		log_error("Unable to allocate format instance structure for "
-			  "pool format");
-		return NULL;
-	}
-
-	fid->fmt = fmt;
-	fid->type = fic->type;
-
-	dm_list_init(&fid->metadata_areas_in_use);
-	dm_list_init(&fid->metadata_areas_ignored);
+	if (!(fid = alloc_fid(fmt, fic)))
+		return_NULL;
 
 	/* Define a NULL metadata area */
 	if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda)))) {
--- LVM2/lib/format_text/format-text.c	2011/03/02 10:23:29	1.173
+++ LVM2/lib/format_text/format-text.c	2011/03/11 14:30:27	1.174
@@ -2190,21 +2190,13 @@
 
 /* NULL vgname means use only the supplied context e.g. an archive file */
 static struct format_instance *_text_create_text_instance(const struct format_type *fmt,
-							   const struct format_instance_ctx *fic)
+							  const struct format_instance_ctx *fic)
 {
 	struct format_instance *fid;
 	int r;
 
-	if (!(fid = dm_pool_alloc(fmt->cmd->mem, sizeof(*fid)))) {
-		log_error("Couldn't allocate format instance object.");
-		return NULL;
-	}
-
-	fid->fmt = fmt;
-	fid->type = fic->type;
-
-	dm_list_init(&fid->metadata_areas_in_use);
-	dm_list_init(&fid->metadata_areas_ignored);
+	if (!(fid = alloc_fid(fmt, fic)))
+		return_NULL;
 
 	if (fid->type & FMT_INSTANCE_VG)
 		r = _create_vg_text_instance(fid, fic);
--- LVM2/lib/metadata/metadata.c	2011/03/10 22:39:36	1.441
+++ LVM2/lib/metadata/metadata.c	2011/03/11 14:30:28	1.442
@@ -3941,6 +3941,25 @@
 	return FAILED_EXIST;
 }
 
+struct format_instance *alloc_fid(const struct format_type *fmt,
+				  const struct format_instance_ctx *fic)
+{
+	struct format_instance *fid;
+
+	if (!(fid = dm_pool_zalloc(fmt->cmd->mem, sizeof(*fid)))) {
+		log_error("Couldn't allocate format_instance object.");
+		return NULL;
+	}
+
+	fid->fmt = fmt;
+	fid->type = fic->type;
+
+	dm_list_init(&fid->metadata_areas_in_use);
+	dm_list_init(&fid->metadata_areas_ignored);
+
+	return fid;
+}
+
 void vg_set_fid(struct volume_group *vg,
 		 struct format_instance *fid)
 {
--- LVM2/lib/metadata/metadata.h	2011/02/28 13:19:02	1.240
+++ LVM2/lib/metadata/metadata.h	2011/03/11 14:30:28	1.241
@@ -191,6 +191,21 @@
 unsigned mda_is_ignored(struct metadata_area *mda);
 void mda_set_ignored(struct metadata_area *mda, unsigned ignored);
 unsigned mda_locns_match(struct metadata_area *mda1, struct metadata_area *mda2);
+
+struct format_instance_ctx {
+	uint32_t type;
+	union {
+		const char *pv_id;
+		struct {
+			const char *vg_name;
+			const char *vg_id;
+		} vg_ref;
+		void *private;
+	} context;
+};
+
+struct format_instance *alloc_fid(const struct format_type *fmt,
+				  const struct format_instance_ctx *fic);
 void vg_set_fid(struct volume_group *vg, struct format_instance *fid);
 /* FIXME: Add generic interface for mda counts based on given key. */
 int fid_add_mda(struct format_instance *fid, struct metadata_area *mda,
@@ -229,18 +244,6 @@
 	struct lv_segment *seg;
 };
 
-struct format_instance_ctx {
-	uint32_t type;
-	union {
-		const char *pv_id;
-		struct {
-			const char *vg_name;
-			const char *vg_id;
-		} vg_ref;
-		void *private;
-	} context;
-};
-
 /*
  * Ownership of objects passes to caller.
  */


