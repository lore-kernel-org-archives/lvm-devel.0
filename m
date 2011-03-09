From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed,  9 Mar 2011 13:22:34 +0100
Subject: [PATCH 2/7] Move text_context allocation inside create_instance fn.
In-Reply-To: <1299673359-6784-1-git-send-email-prajnoha@redhat.com>
References: <1299673359-6784-1-git-send-email-prajnoha@redhat.com>
Message-ID: <1299673359-6784-3-git-send-email-prajnoha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Just another cleanup - moving the text_context part allocation inside
the create_instance fn. There are two simple reasons for this:

  - we'd like to use the fid mempool for text_context that is stored
    in the instance (we used cmd mempool before, so the order of
    initialisation was not a matter, but now it is since we need to
    create the fid mempool first which happens in create_instance fn)

  - there's really no other need to have the allocation code outside
    (the "create_text_context" call)

Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>
---
 lib/format_text/archive.c     |    7 ++-
 lib/format_text/archiver.c    |   14 ++++--
 lib/format_text/format-text.c |   96 +++++++++++++++++++++-------------------
 lib/format_text/format-text.h |    7 ++-
 4 files changed, 70 insertions(+), 54 deletions(-)

diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index 4ba6d07..e23cb2d 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -301,6 +301,9 @@ static void _display_archive(struct cmd_context *cmd, struct archive_file *af)
 	struct volume_group *vg = NULL;
 	struct format_instance *tf;
 	struct format_instance_ctx fic;
+	struct text_context tc = {.path_live = af->path,
+				  .path_edit = NULL,
+				  .desc = NULL};
 	time_t when;
 	char *desc;
 
@@ -308,8 +311,8 @@ static void _display_archive(struct cmd_context *cmd, struct archive_file *af)
 	log_print("File:\t\t%s", af->path);
 
 	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_PRIVATE_MDAS;
-	if (!(fic.context.private = create_text_context(cmd, af->path, NULL)) ||
-	    !(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, &fic))) {
+	fic.context.private = &tc;
+	if (!(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, &fic))) {
 		log_error("Couldn't create text instance object.");
 		return;
 	}
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index cffc04a..3d33e24 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -271,11 +271,14 @@ struct volume_group *backup_read_vg(struct cmd_context *cmd,
 	struct volume_group *vg = NULL;
 	struct format_instance *tf;
 	struct format_instance_ctx fic;
+	struct text_context tc = {.path_live = file,
+				  .path_edit = NULL,
+				  .desc = cmd->cmd_line};
 	struct metadata_area *mda;
 
 	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_PRIVATE_MDAS;
-	if (!(fic.context.private = create_text_context(cmd, file, cmd->cmd_line)) ||
-	    !(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, &fic))) {
+	fic.context.private = &tc;
+	if (!(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, &fic))) {
 		log_error("Couldn't create text format object.");
 		return NULL;
 	}
@@ -379,6 +382,9 @@ int backup_to_file(const char *file, const char *desc, struct volume_group *vg)
 	int r = 0;
 	struct format_instance *tf;
 	struct format_instance_ctx fic;
+	struct text_context tc = {.path_live = file,
+				  .path_edit = NULL,
+				  .desc = desc};
 	struct metadata_area *mda;
 	struct cmd_context *cmd;
 
@@ -387,8 +393,8 @@ int backup_to_file(const char *file, const char *desc, struct volume_group *vg)
 	log_verbose("Creating volume group backup \"%s\" (seqno %u).", file, vg->seqno);
 
 	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_PRIVATE_MDAS;
-	if (!(fic.context.private = create_text_context(cmd, file, desc)) ||
-	    !(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, &fic))) {
+	fic.context.private = &tc;
+	if (!(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, &fic))) {
 		log_error("Couldn't create backup object.");
 		return 0;
 	}
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 2a2f0ed..166c8cc 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -59,12 +59,6 @@ struct raw_list {
 	struct device_area dev_area;
 };
 
-struct text_context {
-	char *path_live;	/* Path to file holding live metadata */
-	char *path_edit;	/* Path to file holding edited metadata */
-	char *desc;		/* Description placed inside file */
-};
-
 int rlocn_is_ignored(const struct raw_locn *rlocn)
 {
 	return (rlocn->flags & RAW_LOCN_IGNORED ? 1 : 0);
@@ -1758,6 +1752,51 @@ static int _create_pv_text_instance(struct format_instance *fid,
 	return 1;
 }
 
+static void *_create_text_context(struct dm_pool *mem, struct text_context *tc)
+{
+	struct text_context *new_tc;
+	char *path, *tmp;
+
+	if (!tc)
+		return NULL;
+
+	path = tc->path_live;
+
+	if ((tmp = strstr(path, ".tmp")) && (tmp == path + strlen(path) - 4)) {
+		log_error("%s: Volume group filename may not end in .tmp",
+			  path);
+		return NULL;
+	}
+
+	if (!(new_tc = dm_pool_alloc(mem, sizeof(*new_tc))))
+		return_NULL;
+
+	if (!(new_tc->path_live = dm_pool_strdup(mem, path)))
+		goto_bad;
+
+	/* If path_edit not defined, create one from path_live with .tmp suffix. */
+	if (!tc->path_edit) {
+		if (!(new_tc->path_edit = dm_pool_alloc(mem, strlen(path) + 5)))
+			goto_bad;
+
+		sprintf(new_tc->path_edit, "%s.tmp", path);
+	}
+	else
+		new_tc->path_edit = dm_pool_strdup(mem, tc->path_edit);
+
+	if (!(new_tc->desc = tc->desc ? dm_pool_strdup(mem, tc->desc)
+				      : dm_pool_strdup(mem, "")))
+		goto_bad;
+
+	return (void *) new_tc;
+
+      bad:
+	dm_pool_free(mem, new_tc);
+
+	log_error("Couldn't allocate text format context object.");
+	return NULL;
+}
+
 static int _create_vg_text_instance(struct format_instance *fid,
                                     const struct format_instance_ctx *fic)
 {
@@ -1769,6 +1808,7 @@ static int _create_vg_text_instance(struct format_instance *fid,
 	struct raw_list *rl;
 	struct dm_list *dir_list, *raw_list;
 	char path[PATH_MAX];
+	struct text_context tc;
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
 	const char *vg_name, *vg_id;
@@ -1786,7 +1826,7 @@ static int _create_vg_text_instance(struct format_instance *fid,
 		if (!(mda = dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*mda))))
 			return_0;
 		mda->ops = &_metadata_text_file_backup_ops;
-		mda->metadata_locn = fic->context.private;
+		mda->metadata_locn = _create_text_context(fid->fmt->cmd->mem, fic->context.private);
 		mda->status = 0;
 		fid->metadata_areas_index.hash = NULL;
 		fid_add_mda(fid, mda, NULL, 0, 0);
@@ -1811,7 +1851,9 @@ static int _create_vg_text_instance(struct format_instance *fid,
 				if (!(mda = dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*mda))))
 					return_0;
 				mda->ops = &_metadata_text_file_ops;
-				mda->metadata_locn = create_text_context(fid->fmt->cmd, path, NULL);
+				tc.path_live = path;
+				tc.path_edit = tc.desc = NULL;
+				mda->metadata_locn = _create_text_context(fid->fmt->cmd->mem, &tc);
 				mda->status = 0;
 				fid_add_mda(fid, mda, NULL, 0, 0);
 			}
@@ -2210,44 +2252,6 @@ static struct format_instance *_text_create_text_instance(const struct format_ty
 	return NULL;
 }
 
-void *create_text_context(struct cmd_context *cmd, const char *path,
-			  const char *desc)
-{
-	struct text_context *tc;
-	char *tmp;
-
-	if ((tmp = strstr(path, ".tmp")) && (tmp == path + strlen(path) - 4)) {
-		log_error("%s: Volume group filename may not end in .tmp",
-			  path);
-		return NULL;
-	}
-
-	if (!(tc = dm_pool_alloc(cmd->mem, sizeof(*tc))))
-		return_NULL;
-
-	if (!(tc->path_live = dm_pool_strdup(cmd->mem, path)))
-		goto_bad;
-
-	if (!(tc->path_edit = dm_pool_alloc(cmd->mem, strlen(path) + 5)))
-		goto_bad;
-
-	sprintf(tc->path_edit, "%s.tmp", path);
-
-	if (!desc)
-		desc = "";
-
-	if (!(tc->desc = dm_pool_strdup(cmd->mem, desc)))
-		goto_bad;
-
-	return (void *) tc;
-
-      bad:
-	dm_pool_free(cmd->mem, tc);
-
-	log_error("Couldn't allocate text format context object.");
-	return NULL;
-}
-
 static struct format_handler _text_handler = {
 	.scan = _text_scan,
 	.pv_read = _text_pv_read,
diff --git a/lib/format_text/format-text.h b/lib/format_text/format-text.h
index 87fe1be..0281879 100644
--- a/lib/format_text/format-text.h
+++ b/lib/format_text/format-text.h
@@ -44,9 +44,12 @@ int backup_list(struct cmd_context *cmd, const char *dir, const char *vgname);
 /*
  * The text format can read and write a volume_group to a file.
  */
+struct text_context {
+	const char *path_live;	/* Path to file holding live metadata */
+	const char *path_edit;	/* Path to file holding edited metadata */
+	const char *desc;	/* Description placed inside file */
+};
 struct format_type *create_text_format(struct cmd_context *cmd);
-void *create_text_context(struct cmd_context *cmd, const char *path,
-			  const char *desc);
 
 struct labeller *text_labeller_create(const struct format_type *fmt);
 
-- 
1.7.4


