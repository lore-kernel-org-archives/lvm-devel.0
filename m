From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 24 Jan 2011 12:03:52 +0100
Subject: [PATCH 01/17] Add pvid parameter to create_instance function.
In-Reply-To: <1295867048-21558-1-git-send-email-prajnoha@redhat.com>
References: <1295867048-21558-1-git-send-email-prajnoha@redhat.com>
Message-ID: <1295867048-21558-2-git-send-email-prajnoha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is a preparation for the next patches...

The format instance holds the information about current metadata areas and it
is a snapshot of what we have in the cache at the moment of the instance
creation. Through the command exection, we use this instance to modify, set
and access modified metadata areas (like we use it to support the
--metadataignore and we store the metadata areas that are in use and the
ones that are ignored).

But to support modifying metadata areas fully (with add/remove metadata
area support), we need to be able to create format instances for PVs as well.
Hence, add the pvid parameter for the create_instance function.

The rules we will follow:

 - the format instance is VG-based or PV-based, but *never both*
   at the same time,

 - when a PV (structure) is alone, not part of any VG, we will have
   a PV based format_instance attached to the PV structure,

 - when a PV is part of the VG, any existing PV-based format_instance
   is destroyed and the PV strucutre will reference VG based format
   instance instead.

 - whatever we need change for mdas, we'll use the format_instance,
   we don't touch the cache directly! This will be synchronized with the
   format instance after pv_write automatically.

Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>
---
 lib/cache/lvmcache.c          |    2 +-
 lib/format1/format1.c         |    1 +
 lib/format_pool/format_pool.c |    1 +
 lib/format_text/archive.c     |    2 +-
 lib/format_text/archiver.c    |    8 ++++----
 lib/format_text/format-text.c |   20 +++++++++++---------
 lib/metadata/metadata.c       |   10 +++++-----
 lib/metadata/metadata.h       |    5 +++--
 8 files changed, 27 insertions(+), 22 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 0e9cae1..476b176 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -653,7 +653,7 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 		return NULL;
 
 	if (!(fid = vginfo->fmt->ops->create_instance(vginfo->fmt,
-						      vginfo->vgname,
+						      NULL, vginfo->vgname,
 						      vgid, NULL)))
 		return_NULL;
 
diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index fc14444..13b757d 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -522,6 +522,7 @@ static struct metadata_area_ops _metadata_format1_ops = {
 };
 
 static struct format_instance *_format1_create_instance(const struct format_type *fmt,
+						const char *pvid __attribute__((unused)),
 						const char *vgname __attribute__((unused)),
 						const char *vgid __attribute__((unused)),
 						void *private __attribute__((unused)))
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index 730da87..814d80c 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -249,6 +249,7 @@ static struct metadata_area_ops _metadata_format_pool_ops = {
 /* *INDENT-ON* */
 
 static struct format_instance *_pool_create_instance(const struct format_type *fmt,
+						const char *pvid __attribute__((unused)),
 						const char *vgname __attribute__((unused)),
 						const char *vgid __attribute__((unused)),
 						void *private __attribute__((unused)))
diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index 43425dc..760153c 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -309,7 +309,7 @@ static void _display_archive(struct cmd_context *cmd, struct archive_file *af)
 
 	if (!(context = create_text_context(cmd, af->path, NULL)) ||
 	    !(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, NULL,
-							 NULL, context))) {
+							 NULL, NULL, context))) {
 		log_error("Couldn't create text instance object.");
 		return;
 	}
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index e0212a2..b7dcad9 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -278,7 +278,7 @@ struct volume_group *backup_read_vg(struct cmd_context *cmd,
 	if (!(context = create_text_context(cmd, file,
 					    cmd->cmd_line)) ||
 	    !(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, NULL,
-							 NULL, context))) {
+							 NULL, NULL, context))) {
 		log_error("Couldn't create text format object.");
 		return NULL;
 	}
@@ -306,8 +306,8 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg)
 	 */
 
 	/* Attempt to write out using currently active format */
-	if (!(vg->fid = cmd->fmt->ops->create_instance(cmd->fmt, vg->name,
-						       NULL, NULL))) {
+	if (!(vg->fid = cmd->fmt->ops->create_instance(cmd->fmt, NULL,
+						vg->name, NULL, NULL))) {
 		log_error("Failed to allocate format instance");
 		return 0;
 	}
@@ -398,7 +398,7 @@ int backup_to_file(const char *file, const char *desc, struct volume_group *vg)
 
 	if (!(context = create_text_context(cmd, file, desc)) ||
 	    !(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, NULL,
-							 NULL, context))) {
+							 NULL, NULL, context))) {
 		log_error("Couldn't create backup object.");
 		return 0;
 	}
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index c186757..fda8255 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -37,10 +37,11 @@
 #include <dirent.h>
 #include <ctype.h>
 
-static struct format_instance *_text_create_text_instance(const struct format_type
-						     *fmt, const char *vgname,
-						     const char *vgid,
-						     void *context);
+static struct format_instance *_text_create_text_instance(const struct format_type *fmt,
+							  const char *pvid,
+							  const char *vgname,
+							  const char *vgid,
+							  void *context);
 
 struct text_fid_context {
 	char *raw_metadata_buf;
@@ -1085,7 +1086,7 @@ static int _scan_file(const struct format_type *fmt, const char *vgname)
 
 				/* FIXME stat file to see if it's changed */
 				fid = _text_create_text_instance(fmt, NULL, NULL,
-							    NULL);
+								 NULL, NULL);
 				if ((vg = _vg_read_file_name(fid, scanned_vgname,
 							     path))) {
 					/* FIXME Store creation host in vg */
@@ -1912,10 +1913,11 @@ static int _text_pv_setup(const struct format_type *fmt,
 }
 
 /* NULL vgname means use only the supplied context e.g. an archive file */
-static struct format_instance *_text_create_text_instance(const struct format_type
-						     *fmt, const char *vgname,
-						     const char *vgid,
-						     void *context)
+static struct format_instance *_text_create_text_instance(const struct format_type*fmt,
+							  const char *pvid,
+							  const char *vgname,
+							  const char *vgid,
+							  void *context)
 {
 	struct format_instance *fid;
 	struct text_fid_context *fidtc;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 771cdb0..fd1948a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -974,8 +974,8 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 	/* initialize removed_pvs list */
 	dm_list_init(&vg->removed_pvs);
 
-	if (!(vg->fid = cmd->fmt->ops->create_instance(cmd->fmt, vg_name,
-						       NULL, NULL))) {
+	if (!(vg->fid = cmd->fmt->ops->create_instance(cmd->fmt, NULL,
+						vg_name, NULL, NULL))) {
 		log_error("Failed to create format instance");
 		goto bad;
 	}
@@ -2629,7 +2629,7 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	}
 
 	/* create format instance with appropriate metadata area */
-	if (!(vg->fid = vginfo->fmt->ops->create_instance(vginfo->fmt,
+	if (!(vg->fid = vginfo->fmt->ops->create_instance(vginfo->fmt, NULL,
 							  orphan_vgname, NULL,
 							  NULL))) {
 		log_error("Failed to create format instance");
@@ -2808,7 +2808,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		use_precommitted = 0;
 
 	/* create format instance with appropriate metadata area */
-	if (!(fid = fmt->ops->create_instance(fmt, vgname, vgid, NULL))) {
+	if (!(fid = fmt->ops->create_instance(fmt, NULL, vgname, vgid, NULL))) {
 		log_error("Failed to create format instance");
 		return NULL;
 	}
@@ -2962,7 +2962,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			use_precommitted = 0;
 
 		/* create format instance with appropriate metadata area */
-		if (!(fid = fmt->ops->create_instance(fmt, vgname, vgid, NULL))) {
+		if (!(fid = fmt->ops->create_instance(fmt, NULL, vgname, vgid, NULL))) {
 			log_error("Failed to create format instance");
 			return NULL;
 		}
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index c0f9148..ab7cff0 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -279,8 +279,9 @@ struct format_handler {
 	/*
 	 * Create format instance with a particular metadata area
 	 */
-	struct format_instance *(*create_instance) (const struct format_type *
-						    fmt, const char *vgname,
+	struct format_instance *(*create_instance) (const struct format_type *fmt,
+						    const char *pvid,
+						    const char *vgname,
 						    const char *vgid,
 						    void *context);
 
-- 
1.7.3.4


