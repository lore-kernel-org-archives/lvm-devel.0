From: David Teigland <teigland@sourceware.org>
Date: Wed, 13 Jun 2018 15:33:23 -0400
Subject: master - filters: remove cache file in persistent filter
Message-ID: <201806131933.w5DJXNJj016937@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=22c5467add88268554a7d163a26892166dbc3104
Commit:        22c5467add88268554a7d163a26892166dbc3104
Parent:        17f5572bc972c932bcf62fc2bff3029268ae0109
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 13 14:00:47 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 13 14:00:47 2018 -0500

filters: remove cache file in persistent filter

It creates problems because it's not always correct,
and it doesn't actually help much.
---
 lib/commands/toolcontext.c      |   37 +------
 lib/commands/toolcontext.h      |    1 -
 lib/config/config_settings.h    |   17 +--
 lib/filters/filter-composite.c  |   13 --
 lib/filters/filter-persistent.c |  233 +--------------------------------------
 lib/filters/filter.h            |    6 +-
 6 files changed, 8 insertions(+), 299 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 8c18fc6..a76c68d 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1195,20 +1195,15 @@ bad:
  */
 int init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
 {
-	const char *dev_cache;
 	struct dev_filter *filter = NULL, *filter_components[2] = {0};
 	int nr_filt;
-	struct stat st;
 	const struct dm_config_node *cn;
-	struct timespec ts, cts;
 
 	if (!cmd->initialized.connections) {
 		log_error(INTERNAL_ERROR "connections must be initialized before filters");
 		return 0;
 	}
 
-	cmd->dump_filter = 0;
-
 	cmd->lvmetad_filter = _init_lvmetad_filter_chain(cmd);
 	if (!cmd->lvmetad_filter)
 		goto_bad;
@@ -1246,10 +1241,7 @@ int init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
 		cmd->lvmetad_filter = NULL;
 	}
 
-	if (!(dev_cache = find_config_tree_str(cmd, devices_cache_CFG, NULL)))
-		goto_bad;
-
-	if (!(filter = persistent_filter_create(cmd->dev_types, filter, dev_cache))) {
+	if (!(filter = persistent_filter_create(cmd->dev_types, filter))) {
 		log_verbose("Failed to create persistent device filter.");
 		goto bad;
 	}
@@ -1267,29 +1259,6 @@ int init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
 	} else
 		cmd->full_filter = filter;
 
-	/* Should we ever dump persistent filter state? */
-	if (find_config_tree_bool(cmd, devices_write_cache_state_CFG, NULL))
-		cmd->dump_filter = 1;
-
-	if (!*cmd->system_dir)
-		cmd->dump_filter = 0;
-
-	/*
-	 * Only load persistent filter device cache on startup if it is newer
-	 * than the config file and this is not a long-lived process. Also avoid
-	 * it when lvmetad is enabled.
-	 */
-	if (!find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL) &&
-	    load_persistent_cache && !cmd->is_long_lived &&
-	    !stat(dev_cache, &st)) {
-		lvm_stat_ctim(&ts, &st);
-		cts = config_file_timestamp(cmd->cft);
-		if (timespeccmp(&ts, &cts, >) &&
-		    !persistent_filter_load(cmd->filter, NULL))
-			log_verbose("Failed to load existing device cache from %s",
-				    dev_cache);
-	}
-
 	cmd->initialized.filters = 1;
 	return 1;
 bad:
@@ -2166,10 +2135,6 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	struct dm_config_tree *cft_cmdline;
 	int flags;
 
-	if (cmd->dump_filter && cmd->filter && cmd->filter->dump &&
-	    !cmd->filter->dump(cmd->filter, 1))
-		stack;
-
 	archive_exit(cmd);
 	backup_exit(cmd);
 	lvmcache_destroy(cmd, 0, 0);
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 18e1b7d..baecfbd 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -179,7 +179,6 @@ struct cmd_context {
 	struct dev_filter *lvmetad_filter;	/* pre-lvmetad filter chain */
 	struct dev_filter *filter;		/* post-lvmetad filter chain */
 	struct dev_filter *full_filter;		/* lvmetad_filter + filter */
-	int dump_filter;			/* Dump filter when exiting? */
 
 	/*
 	 * Configuration.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 8aa4879..a730afb 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -312,24 +312,17 @@ cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_D
 	"The syntax is the same as devices/filter. Devices rejected by\n"
 	"global_filter are not opened by LVM.\n")
 
-cfg_runtime(devices_cache_CFG, "cache", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0), vsn(1, 2, 19),
-	"This has been replaced by the devices/cache_dir setting.\n",
-	"Cache file path.\n")
+cfg_runtime(devices_cache_CFG, "cache", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0), vsn(1, 2, 19), NULL,
+	"This setting is no longer used.\n")
 
 cfg_runtime(devices_cache_dir_CFG, "cache_dir", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 2, 19), 0, NULL,
-	"Directory in which to store the device cache file.\n"
-	"The results of filtering are cached on disk to avoid rescanning dud\n"
-	"devices (which can take a very long time). By default this cache is\n"
-	"stored in a file named .cache. It is safe to delete this file; the\n"
-	"tools regenerate it. If obtain_device_list_from_udev is enabled, the\n"
-	"list of devices is obtained from udev and any existing .cache file\n"
-	"is removed.\n")
+	"This setting is no longer used.\n")
 
 cfg(devices_cache_file_prefix_CFG, "cache_file_prefix", devices_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, DEFAULT_CACHE_FILE_PREFIX, vsn(1, 2, 19), NULL, 0, NULL,
-	"A prefix used before the .cache file name. See devices/cache_dir.\n")
+	"This setting is no longer used.\n")
 
 cfg(devices_write_cache_state_CFG, "write_cache_state", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(1, 0, 0), NULL, 0, NULL,
-	"Enable/disable writing the cache file. See devices/cache_dir.\n")
+	"This setting is no longer used.\n")
 
 cfg_array(devices_types_CFG, "types", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_ADVANCED, CFG_TYPE_INT | CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of additional acceptable block device types.\n"
diff --git a/lib/filters/filter-composite.c b/lib/filters/filter-composite.c
index 8691aeb..ba837af 100644
--- a/lib/filters/filter-composite.c
+++ b/lib/filters/filter-composite.c
@@ -58,18 +58,6 @@ static void _composite_destroy(struct dev_filter *f)
 	free(f);
 }
 
-static int _dump(struct dev_filter *f, int merge_existing)
-{
-	struct dev_filter **filters;
-
-	for (filters = (struct dev_filter **) f->private; *filters; ++filters)
-		if ((*filters)->dump &&
-		    !(*filters)->dump(*filters, merge_existing))
-			return_0;
-
-	return 1;
-}
-
 static void _wipe(struct dev_filter *f)
 {
 	struct dev_filter **filters;
@@ -102,7 +90,6 @@ struct dev_filter *composite_filter_create(int n, int use_dev_ext_info, struct d
 
 	cft->passes_filter = use_dev_ext_info ? _and_p_with_dev_ext_info : _and_p;
 	cft->destroy = _composite_destroy;
-	cft->dump = _dump;
 	cft->wipe = _wipe;
 	cft->use_count = 0;
 	cft->private = filters_copy;
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 643c349..9ee3957 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -17,13 +17,10 @@
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
 #include "lib/config/config.h"
-#include "lib/misc/lvm-file.h"
 
 struct pfilter {
-	char *file;
 	struct dm_hash_table *devices;
 	struct dev_filter *real;
-	struct timespec ctime;
 	struct dev_types *dt;
 };
 
@@ -44,11 +41,6 @@ struct pfilter {
  * times.  A device should be checked against the filter once, and then not
  * need to be checked again.  With scanning now controlled, we could probably
  * do this.
- *
- * FIXME: "persistent" isn't a great name for this caching filter.  This filter
- * at one time saved its cache results to a file, which is how it got the name.
- * That .cache file does not work well, causes problems, and is no longer used
- * by default.  The old code for it should be removed.
  */
 
 /*
@@ -76,214 +68,6 @@ static void _persistent_filter_wipe(struct dev_filter *f)
 	dm_hash_wipe(pf->devices);
 }
 
-static int _read_array(struct pfilter *pf, struct dm_config_tree *cft,
-		       const char *path, void *data)
-{
-	const struct dm_config_node *cn;
-	const struct dm_config_value *cv;
-
-	if (!(cn = dm_config_find_node(cft->root, path))) {
-		log_very_verbose("Couldn't find %s array in '%s'",
-				 path, pf->file);
-		return 0;
-	}
-
-	/*
-	 * iterate through the array, adding
-	 * devices as we go.
-	 */
-	for (cv = cn->v; cv; cv = cv->next) {
-		if (cv->type != DM_CFG_STRING) {
-			log_verbose("Devices array contains a value "
-				    "which is not a string ... ignoring");
-			continue;
-		}
-
-		if (!dm_hash_insert(pf->devices, cv->v.str, data))
-			log_verbose("Couldn't add '%s' to filter ... ignoring",
-				    cv->v.str);
-		/* Populate dev_cache ourselves */
-		dev_cache_get(cv->v.str, NULL);
-	}
-	return 1;
-}
-
-int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out)
-{
-	struct pfilter *pf = (struct pfilter *) f->private;
-	struct dm_config_tree *cft;
-	struct stat info;
-	int r = 0;
-
-	if (obtain_device_list_from_udev()) {
-		if (!stat(pf->file, &info)) {
-			log_very_verbose("Obtaining device list from udev. "
-					 "Removing obsolete %s.",
-					 pf->file);
-			if (unlink(pf->file) < 0 && errno != EROFS)
-				log_sys_error("unlink", pf->file);
-		}
-		return 1;
-	}
-
-	if (!stat(pf->file, &info))
-		lvm_stat_ctim(&pf->ctime, &info);
-	else {
-		log_very_verbose("%s: stat failed: %s", pf->file,
-				 strerror(errno));
-		return_0;
-	}
-
-	if (!(cft = config_open(CONFIG_FILE_SPECIAL, pf->file, 1)))
-		return_0;
-
-	if (!config_file_read(cft))
-		goto_out;
-
-	log_debug_devs("Loading persistent filter cache from %s", pf->file);
-	_read_array(pf, cft, "persistent_filter_cache/valid_devices",
-		    PF_GOOD_DEVICE);
-	/* We don't gain anything by holding invalid devices */
-	/* _read_array(pf, cft, "persistent_filter_cache/invalid_devices",
-	   PF_BAD_DEVICE); */
-
-	log_very_verbose("Loaded persistent filter cache from %s", pf->file);
-
-      out:
-	if (r && cft_out)
-		*cft_out = cft;
-	else
-		config_destroy(cft);
-	return r;
-}
-
-static void _write_array(struct pfilter *pf, FILE *fp, const char *path,
-			 void *data)
-{
-	void *d;
-	int first = 1;
-	char buf[2 * PATH_MAX];
-	struct dm_hash_node *n;
-
-	for (n = dm_hash_get_first(pf->devices); n;
-	     n = dm_hash_get_next(pf->devices, n)) {
-		d = dm_hash_get_data(pf->devices, n);
-
-		if (d != data)
-			continue;
-
-		if (!first)
-			fprintf(fp, ",\n");
-		else {
-			fprintf(fp, "\t%s=[\n", path);
-			first = 0;
-		}
-
-		dm_escape_double_quotes(buf, dm_hash_get_key(pf->devices, n));
-		fprintf(fp, "\t\t\"%s\"", buf);
-	}
-
-	if (!first)
-		fprintf(fp, "\n\t]\n");
-}
-
-static int _persistent_filter_dump(struct dev_filter *f, int merge_existing)
-{
-	struct pfilter *pf;
-	char *tmp_file;
-	struct stat info, info2;
-	struct timespec ts;
-	struct dm_config_tree *cft = NULL;
-	FILE *fp;
-	int lockfd;
-	int r = 0;
-
-	if (obtain_device_list_from_udev())
-		return 1;
-
-	if (!f)
-		return_0;
-	pf = (struct pfilter *) f->private;
-
-	if (!dm_hash_get_num_entries(pf->devices)) {
-		log_very_verbose("Internal persistent device cache empty "
-				 "- not writing to %s", pf->file);
-		return 1;
-	}
-	if (!dev_cache_has_scanned()) {
-		log_very_verbose("Device cache incomplete - not writing "
-				 "to %s", pf->file);
-		return 0;
-	}
-
-	log_very_verbose("Dumping persistent device cache to %s", pf->file);
-
-	while (1) {
-		if ((lockfd = fcntl_lock_file(pf->file, F_WRLCK, 0)) < 0)
-			return_0;
-
-		/*
-		 * Ensure we locked the file we expected
-		 */
-		if (fstat(lockfd, &info)) {
-			log_sys_error("fstat", pf->file);
-			goto out;
-		}
-		if (stat(pf->file, &info2)) {
-			log_sys_error("stat", pf->file);
-			goto out;
-		}
-
-		if (is_same_inode(info, info2))
-			break;
-	
-		fcntl_unlock_file(lockfd);
-	}
-
-	/*
-	 * If file contents changed since we loaded it, merge new contents
-	 */
-	lvm_stat_ctim(&ts, &info);
-	if (merge_existing && timespeccmp(&ts, &pf->ctime, !=))
-		/* Keep cft open to avoid losing lock */
-		persistent_filter_load(f, &cft);
-
-	tmp_file = alloca(strlen(pf->file) + 5);
-	sprintf(tmp_file, "%s.tmp", pf->file);
-
-	if (!(fp = fopen(tmp_file, "w"))) {
-		/* EACCES has been reported over NFS */
-		if (errno != EROFS && errno != EACCES)
-			log_sys_error("fopen", tmp_file);
-		goto out;
-	}
-
-	fprintf(fp, "# This file is automatically maintained by lvm.\n\n");
-	fprintf(fp, "persistent_filter_cache {\n");
-
-	_write_array(pf, fp, "valid_devices", PF_GOOD_DEVICE);
-	/* We don't gain anything by remembering invalid devices */
-	/* _write_array(pf, fp, "invalid_devices", PF_BAD_DEVICE); */
-
-	fprintf(fp, "}\n");
-	if (lvm_fclose(fp, tmp_file))
-		goto_out;
-
-	if (rename(tmp_file, pf->file))
-		log_error("%s: rename to %s failed: %s", tmp_file, pf->file,
-			  strerror(errno));
-
-	r = 1;
-
-out:
-	fcntl_unlock_file(lockfd);
-
-	if (cft)
-		config_destroy(cft);
-
-	return r;
-}
-
 static int _lookup_p(struct dev_filter *f, struct device *dev)
 {
 	struct pfilter *pf = (struct pfilter *) f->private;
@@ -361,19 +145,15 @@ static void _persistent_destroy(struct dev_filter *f)
 		log_error(INTERNAL_ERROR "Destroying persistent filter while in use %u times.", f->use_count);
 
 	dm_hash_destroy(pf->devices);
-	free(pf->file);
 	pf->real->destroy(pf->real);
 	free(pf);
 	free(f);
 }
 
-struct dev_filter *persistent_filter_create(struct dev_types *dt,
-					    struct dev_filter *real,
-					    const char *file)
+struct dev_filter *persistent_filter_create(struct dev_types *dt, struct dev_filter *real)
 {
 	struct pfilter *pf;
 	struct dev_filter *f = NULL;
-	struct stat info;
 
 	if (!(pf = zalloc(sizeof(*pf)))) {
 		log_error("Allocation of persistent filter failed.");
@@ -382,11 +162,6 @@ struct dev_filter *persistent_filter_create(struct dev_types *dt,
 
 	pf->dt = dt;
 
-	if (!(pf->file = strdup(file))) {
-		log_error("Filename duplication for persistent filter failed.");
-		goto bad;
-	}
-
 	pf->real = real;
 
 	if (!(_init_hash(pf))) {
@@ -399,23 +174,17 @@ struct dev_filter *persistent_filter_create(struct dev_types *dt,
 		goto bad;
 	}
 
-	/* Only merge cache file before dumping it if it changed externally. */
-	if (!stat(pf->file, &info))
-		lvm_stat_ctim(&pf->ctime, &info);
-
 	f->passes_filter = _lookup_p;
 	f->destroy = _persistent_destroy;
 	f->use_count = 0;
 	f->private = pf;
 	f->wipe = _persistent_filter_wipe;
-	f->dump = _persistent_filter_dump;
 
 	log_debug_devs("Persistent filter initialised.");
 
 	return f;
 
       bad:
-	free(pf->file);
 	if (pf->devices)
 		dm_hash_destroy(pf->devices);
 	free(pf);
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index ff9cc1b..cdd5a14 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -27,9 +27,7 @@ struct dev_filter *md_filter_create(struct cmd_context *cmd, struct dev_types *d
 struct dev_filter *fwraid_filter_create(struct dev_types *dt);
 struct dev_filter *mpath_filter_create(struct dev_types *dt);
 struct dev_filter *partitioned_filter_create(struct dev_types *dt);
-struct dev_filter *persistent_filter_create(struct dev_types *dt,
-					    struct dev_filter *f,
-					    const char *file);
+struct dev_filter *persistent_filter_create(struct dev_types *dt, struct dev_filter *f);
 struct dev_filter *sysfs_filter_create(void);
 struct dev_filter *signature_filter_create(struct dev_types *dt);
 
@@ -54,6 +52,4 @@ typedef enum {
 } filter_mode_t;
 struct dev_filter *usable_filter_create(struct dev_types *dt, filter_mode_t mode);
 
-int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out);
-
 #endif 	/* _LVM_FILTER_H */


