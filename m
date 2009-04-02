From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 02 Apr 2009 13:19:25 -0400
Subject: [RFC PATCH 4/7] support metadata cache feature
In-Reply-To: <49D3D9F5.902@redhat.com>
References: <49D3D9F5.902@redhat.com>
Message-ID: <49D4F39D.80409@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Metadata cache files are read from the specified directory, and their
information are registered into lvmcache. The CACHE_INVALID flag is
set to the caches so that they will be reloaded from actual devices
when they are really processed.

This prototype uses metadata backup files in the backup directory as
cache files. But the own cache directory will be used in the future
version.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 lib/cache/lvmcache.c          |    5 +++
 lib/cache/lvmcache.h          |    2 +
 lib/commands/toolcontext.c    |    1 
 lib/commands/toolcontext.h    |    3 ++
 lib/format_text/archiver.c    |   50 +++++++++++++++++++++++++++++++++
 lib/format_text/archiver.h    |    5 +++
 lib/format_text/format-text.c |   63 ++++++++++++++++++++++++++++++++++++++++++
 lib/metadata/metadata.h       |    5 +++
 8 files changed, 134 insertions(+)

Index: LVM2.02.46-cvs-20090324/lib/cache/lvmcache.c
===================================================================
--- LVM2.02.46-cvs-20090324.orig/lib/cache/lvmcache.c
+++ LVM2.02.46-cvs-20090324/lib/cache/lvmcache.c
@@ -1274,3 +1274,8 @@ void lvmcache_destroy(struct cmd_context
 	if (retain_orphans)
 		init_lvmcache_orphans(cmd);
 }
+
+void lvmcache_reset_need_scan(void)
+{
+	_need_scan = 0;
+}
Index: LVM2.02.46-cvs-20090324/lib/cache/lvmcache.h
===================================================================
--- LVM2.02.46-cvs-20090324.orig/lib/cache/lvmcache.h
+++ LVM2.02.46-cvs-20090324/lib/cache/lvmcache.h
@@ -112,4 +112,6 @@ struct dm_list *lvmcache_get_pvids(struc
 struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted);
 void lvmcache_drop_metadata(const char *vgname);
 
+void lvmcache_reset_need_scan(void);
+
 #endif
Index: LVM2.02.46-cvs-20090324/lib/commands/toolcontext.c
===================================================================
--- LVM2.02.46-cvs-20090324.orig/lib/commands/toolcontext.c
+++ LVM2.02.46-cvs-20090324/lib/commands/toolcontext.c
@@ -776,6 +776,7 @@ static int _init_formats(struct cmd_cont
 	dm_list_add(&cmd->formats, &fmt->list);
 
 	cmd->fmt_backup = fmt;
+	cmd->fmt_mcache = fmt;
 
 	format = find_config_tree_str(cmd, "global/format",
 				 DEFAULT_FORMAT);
Index: LVM2.02.46-cvs-20090324/lib/commands/toolcontext.h
===================================================================
--- LVM2.02.46-cvs-20090324.orig/lib/commands/toolcontext.h
+++ LVM2.02.46-cvs-20090324/lib/commands/toolcontext.h
@@ -33,6 +33,7 @@ struct config_info {
 	int suffix;
 	int archive;		/* should we archive ? */
 	int backup;		/* should we backup ? */
+	int mcache;		/* should we enable metadata cache ? */
 	int read_ahead;		/* DM_READ_AHEAD_NONE or _AUTO */
 	int cache_vgmetadata;
 	const char *msg_prefix;
@@ -56,6 +57,7 @@ struct cmd_context {
 
 	const struct format_type *fmt;	/* Current format to use by default */
 	struct format_type *fmt_backup;	/* Format to use for backups */
+	struct format_type *fmt_mcache;	/* Format to use for metadata cache */
 
 	struct dm_list formats;	/* Available formats */
 	struct dm_list segtypes;	/* Available segment types */
@@ -82,6 +84,7 @@ struct cmd_context {
 
 	struct archive_params *archive_params;
 	struct backup_params *backup_params;
+	struct mcache_params *mcache_params;
 	const char *stripe_filler;
 
 	/* List of defined tags */
Index: LVM2.02.46-cvs-20090324/lib/format_text/archiver.c
===================================================================
--- LVM2.02.46-cvs-20090324.orig/lib/format_text/archiver.c
+++ LVM2.02.46-cvs-20090324/lib/format_text/archiver.c
@@ -35,6 +35,11 @@ struct backup_params {
 	char *dir;
 };
 
+struct mcache_params {
+	int enabled;
+	char *dir;
+};
+
 int archive_init(struct cmd_context *cmd, const char *dir,
 		 unsigned int keep_days, unsigned int keep_min,
 		 int enabled)
@@ -423,3 +428,48 @@ void check_current_backup(struct volume_
 	archive(vg);
 	backup(vg);
 }
+
+int mcache_init(struct cmd_context *cmd, const char *dir,
+		int enabled)
+{
+	if (!(cmd->mcache_params = dm_pool_zalloc(cmd->libmem,
+					       sizeof(*cmd->mcache_params)))) {
+		log_error("mcache_params alloc failed");
+		return 0;
+	}
+
+	cmd->mcache_params->dir = NULL;
+	if (!*dir)
+		return 1;
+
+	if (!(cmd->mcache_params->dir = dm_strdup(dir))) {
+		log_error("Couldn't copy mcache directory name.");
+		return 0;
+	}
+	mcache_enable(cmd, enabled);
+
+	return 1;
+}
+
+void mcache_exit(struct cmd_context *cmd)
+{
+	if (cmd->mcache_params->dir)
+		dm_free(cmd->mcache_params->dir);
+	memset(cmd->mcache_params, 0, sizeof(*cmd->mcache_params));
+}
+
+void mcache_enable(struct cmd_context *cmd, int flag)
+{
+	cmd->mcache_params->enabled = flag;
+}
+
+void mcache_load(struct cmd_context *cmd)
+{
+	if (!cmd->mcache_params->enabled || !cmd->mcache_params->dir)
+		return;
+
+	if (cmd->fmt_mcache->ops->scan_mcache &&
+	    cmd->fmt_mcache->ops->scan_mcache(cmd->fmt,
+					      cmd->mcache_params->dir))
+		lvmcache_reset_need_scan();
+}
Index: LVM2.02.46-cvs-20090324/lib/format_text/archiver.h
===================================================================
--- LVM2.02.46-cvs-20090324.orig/lib/format_text/archiver.h
+++ LVM2.02.46-cvs-20090324/lib/format_text/archiver.h
@@ -59,4 +59,9 @@ int backup_to_file(const char *file, con
 
 void check_current_backup(struct volume_group *vg);
 
+int mcache_init(struct cmd_context *cmd, const char *dir, int enabled);
+void mcache_exit(struct cmd_context *cmd);
+void mcache_enable(struct cmd_context *cmd, int flag);
+void mcache_load(struct cmd_context *cmd);
+
 #endif
Index: LVM2.02.46-cvs-20090324/lib/format_text/format-text.c
===================================================================
--- LVM2.02.46-cvs-20090324.orig/lib/format_text/format-text.c
+++ LVM2.02.46-cvs-20090324/lib/format_text/format-text.c
@@ -1062,6 +1062,68 @@ static int _scan_file(const struct forma
 	return 1;
 }
 
+static int _text_scan_mcache(const struct format_type *fmt, const char *dir)
+{
+	struct dirent *dirent;
+	char *tmp;
+	DIR *d;
+	struct volume_group *vg;
+	struct format_instance *fid;
+	char path[PATH_MAX];
+	char *vgname;
+	int ret = 1;
+
+	if (!(d = opendir(dir))) {
+		log_sys_error("opendir", dir);
+		return 0;
+	}
+
+	while ((dirent = readdir(d))) {
+		if (!strcmp(dirent->d_name, ".") ||
+		    !strcmp(dirent->d_name, "..") ||
+		    ((tmp = strstr(dirent->d_name, ".tmp")) &&
+		     tmp == dirent->d_name + strlen(dirent->d_name) - 4))
+			continue;
+
+		vgname = dirent->d_name;
+		if (dm_snprintf(path, PATH_MAX, "%s/%s", dir, vgname) < 0) {
+			log_error("Name too long %s/%s", dir, vgname);
+			break;
+		}
+
+		/* FIXME stat file to see if it's changed */
+		fid = _text_create_text_instance(fmt, NULL, NULL, NULL);
+		if ((vg = _vg_read_file_name(fid, vgname, path, 0))) {
+			struct pv_list *pvl;
+			struct lvmcache_info *info;
+
+			dm_list_iterate_items(pvl, &vg->pvs) {
+				info = lvmcache_add(fmt->labeller,
+						    (char *)pvl->pv->id.uuid,
+						    pvl->pv->dev, vg->name,
+						    (char *)vg->id.uuid, 0);
+				if (!info) {
+					/* FIXME: remove all mcache here */
+					ret = 0;
+					goto out;
+				}
+
+				dm_list_init(&info->mdas);
+				dm_list_init(&info->das);
+
+				/* info is generated from metadata cache and
+				   it is need to be revalidated later */
+				info->status |= CACHE_INVALID;
+			}
+		}
+	}
+ out:
+	if (closedir(d))
+		log_sys_error("closedir", dir);
+
+	return ret;
+}
+
 const char *vgname_from_mda(const struct format_type *fmt,
 			    struct device_area *dev_area, struct id *vgid,
 			    uint32_t *vgstatus, char **creation_host,
@@ -1889,6 +1951,7 @@ void *create_text_context(struct cmd_con
 
 static struct format_handler _text_handler = {
 	.scan = _text_scan,
+	.scan_mcache = _text_scan_mcache,
 	.pv_read = _text_pv_read,
 	.pv_setup = _text_pv_setup,
 	.pv_write = _text_pv_write,
Index: LVM2.02.46-cvs-20090324/lib/metadata/metadata.h
===================================================================
--- LVM2.02.46-cvs-20090324.orig/lib/metadata/metadata.h
+++ LVM2.02.46-cvs-20090324/lib/metadata/metadata.h
@@ -198,6 +198,11 @@ struct format_handler {
 	int (*scan) (const struct format_type * fmt);
 
 	/*
+	 * Load and setup metadata cache files
+	 */
+	int (*scan_mcache) (const struct format_type *fmt, const char *dir);
+
+	/*
 	 * Return PV with given path.
 	 */
 	int (*pv_read) (const struct format_type * fmt, const char *pv_name,




