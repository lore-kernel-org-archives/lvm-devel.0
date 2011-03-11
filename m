From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Mar 2011 14:45:22 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/archive.c lib ...
Message-ID: <20110311144522.6248.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-03-11 14:45:18

Modified files:
	.              : WHATS_NEW 
	lib/format_text: archive.c archiver.c format-text.c 
	                 format-text.h 

Log message:
	Make create_text_context fn static and move it inside create_instance fn.
	
	We'd like to use the fid mempool for text_context that is stored
	in the instance (we used cmd mempool before, so the order of
	initialisation was not a matter, but now it is since we need to
	create the fid mempool first which happens in create_instance fn).
	
	The text_context initialisation is not needed anywhere outside the
	create_instance fn so move it there.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1946&r2=1.1947
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archive.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.175&r2=1.176
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.h.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/WHATS_NEW	2011/03/11 14:38:38	1.1946
+++ LVM2/WHATS_NEW	2011/03/11 14:45:17	1.1947
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Make create_text_context fn static and move it inside create_instance fn.
   Add mem and ref_count fields to struct format_instance for own mempool use.
   Use new alloc_fid fn for common format instance initialisation.
   Optimise _get_token() and _eat_space().
--- LVM2/lib/format_text/archive.c	2011/02/21 12:07:03	1.41
+++ LVM2/lib/format_text/archive.c	2011/03/11 14:45:18	1.42
@@ -301,6 +301,9 @@
 	struct volume_group *vg = NULL;
 	struct format_instance *tf;
 	struct format_instance_ctx fic;
+	struct text_context tc = {.path_live = af->path,
+				  .path_edit = NULL,
+				  .desc = NULL};
 	time_t when;
 	char *desc;
 
@@ -308,8 +311,8 @@
 	log_print("File:\t\t%s", af->path);
 
 	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_PRIVATE_MDAS;
-	if (!(fic.context.private = create_text_context(cmd, af->path, NULL)) ||
-	    !(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, &fic))) {
+	fic.context.private = &tc;
+	if (!(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, &fic))) {
 		log_error("Couldn't create text instance object.");
 		return;
 	}
--- LVM2/lib/format_text/archiver.c	2011/02/28 20:50:01	1.44
+++ LVM2/lib/format_text/archiver.c	2011/03/11 14:45:18	1.45
@@ -271,11 +271,14 @@
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
@@ -379,6 +382,9 @@
 	int r = 0;
 	struct format_instance *tf;
 	struct format_instance_ctx fic;
+	struct text_context tc = {.path_live = file,
+				  .path_edit = NULL,
+				  .desc = desc};
 	struct metadata_area *mda;
 	struct cmd_context *cmd;
 
@@ -387,8 +393,8 @@
 	log_verbose("Creating volume group backup \"%s\" (seqno %u).", file, vg->seqno);
 
 	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_PRIVATE_MDAS;
-	if (!(fic.context.private = create_text_context(cmd, file, desc)) ||
-	    !(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, &fic))) {
+	fic.context.private = &tc;
+	if (!(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, &fic))) {
 		log_error("Couldn't create backup object.");
 		return 0;
 	}
--- LVM2/lib/format_text/format-text.c	2011/03/11 14:38:39	1.175
+++ LVM2/lib/format_text/format-text.c	2011/03/11 14:45:18	1.176
@@ -59,12 +59,6 @@
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
@@ -992,7 +986,7 @@
 			   struct metadata_area *mda)
 {
 	struct text_context *tc = (struct text_context *) mda->metadata_locn;
-	char *slash;
+	const char *slash;
 	char new_name[PATH_MAX];
 	size_t len;
 
@@ -1758,6 +1752,52 @@
 	return 1;
 }
 
+static void *_create_text_context(struct dm_pool *mem, struct text_context *tc)
+{
+	struct text_context *new_tc;
+	const char *path;
+	char *tmp;
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
+		if (!(tmp = dm_pool_alloc(mem, strlen(path) + 5)))
+			goto_bad;
+		sprintf(tmp, "%s.tmp", path);
+		new_tc->path_edit = tmp;
+	}
+	else if (!(new_tc->path_edit = dm_pool_strdup(mem, tc->path_edit)))
+		goto_bad;
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
@@ -1769,6 +1809,7 @@
 	struct raw_list *rl;
 	struct dm_list *dir_list, *raw_list;
 	char path[PATH_MAX];
+	struct text_context tc;
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
 	const char *vg_name, *vg_id;
@@ -1786,7 +1827,7 @@
 		if (!(mda = dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*mda))))
 			return_0;
 		mda->ops = &_metadata_text_file_backup_ops;
-		mda->metadata_locn = fic->context.private;
+		mda->metadata_locn = _create_text_context(fid->fmt->cmd->mem, fic->context.private);
 		mda->status = 0;
 		fid->metadata_areas_index.hash = NULL;
 		fid_add_mda(fid, mda, NULL, 0, 0);
@@ -1811,7 +1852,9 @@
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
@@ -2210,44 +2253,6 @@
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
--- LVM2/lib/format_text/format-text.h	2011/03/02 10:19:14	1.32
+++ LVM2/lib/format_text/format-text.h	2011/03/11 14:45:18	1.33
@@ -44,9 +44,12 @@
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
 


