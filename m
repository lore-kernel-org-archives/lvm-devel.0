From: David Teigland <teigland@sourceware.org>
Date: Tue, 15 Jan 2019 11:31:11 -0500
Subject: master - add device hints to reduce scanning
Message-ID: <201901151631.x0FGVBxo008394@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6620dc9475d55207bfcd5e666f0379bcdf11831a
Commit:        6620dc9475d55207bfcd5e666f0379bcdf11831a
Parent:        81b3b71dae7775c93adebdea60308e11057a4ee8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Dec 7 14:35:22 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jan 15 10:23:47 2019 -0600

add device hints to reduce scanning

Save the list of PVs in /run/lvm/hints.  These hints
are used to reduce scanning in a number of commands
to only the PVs on the system, or only the PVs in a
requested VG (rather than all devices on the system.)
---
 lib/Makefile.in                          |    1 +
 lib/cache/lvmcache.c                     |   18 +
 lib/cache/lvmcache.h                     |    3 +
 lib/commands/toolcontext.c               |    1 +
 lib/commands/toolcontext.h               |    7 +-
 lib/config/config_settings.h             |   14 +
 lib/config/defaults.h                    |    2 +
 lib/device/dev-cache.c                   |    6 +-
 lib/device/dev-cache.h                   |    3 +-
 lib/device/dev-type.c                    |   30 +
 lib/device/dev-type.h                    |    2 +
 lib/device/device.h                      |    1 +
 lib/filters/filter-composite.c           |   11 +-
 lib/filters/filter-fwraid.c              |    3 +-
 lib/filters/filter-internal.c            |    3 +-
 lib/filters/filter-md.c                  |    3 +-
 lib/filters/filter-mpath.c               |    3 +-
 lib/filters/filter-partitioned.c         |    3 +-
 lib/filters/filter-persistent.c          |    8 +-
 lib/filters/filter-regex.c               |    3 +-
 lib/filters/filter-signature.c           |    3 +-
 lib/filters/filter-sysfs.c               |    3 +-
 lib/filters/filter-type.c                |    3 +-
 lib/filters/filter-usable.c              |    3 +-
 lib/label/hints.c                        | 1241 ++++++++++++++++++++++++++++++
 lib/label/hints.h                        |   37 +
 lib/label/label.c                        |   71 ++-
 test/shell/hints.sh                      |  377 +++++++++
 test/shell/process-each-duplicate-pvs.sh |   18 +-
 tools/command.c                          |    2 +
 tools/commands.h                         |   34 +-
 tools/lvmcmdline.c                       |   30 +
 tools/pvchange.c                         |    2 +
 tools/pvcreate.c                         |    2 +
 tools/pvdisplay.c                        |    7 +
 tools/pvremove.c                         |    2 +
 tools/pvscan.c                           |    9 +
 tools/reporter.c                         |    7 +
 tools/toollib.c                          |   33 +-
 tools/tools.h                            |    3 +
 tools/vgcfgrestore.c                     |    2 +
 tools/vgcreate.c                         |    2 +
 tools/vgextend.c                         |    2 +
 tools/vgimportclone.c                    |    2 +
 tools/vgmerge.c                          |    2 +
 tools/vgreduce.c                         |    2 +
 tools/vgremove.c                         |    2 +
 tools/vgrename.c                         |    2 +
 tools/vgsplit.c                          |    2 +
 49 files changed, 1979 insertions(+), 51 deletions(-)

diff --git a/lib/Makefile.in b/lib/Makefile.in
index bde66f9..654c322 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -61,6 +61,7 @@ SOURCES =\
 	format_text/text_label.c \
 	freeseg/freeseg.c \
 	label/label.c \
+	label/hints.c \
 	locking/file_locking.c \
 	locking/locking.c \
 	log/log.c \
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index da8b4d8..0ffa604 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -69,6 +69,7 @@ static DM_LIST_INIT(_unused_duplicate_devs);
 static int _scanning_in_progress = 0;
 static int _vgs_locked = 0;
 static int _found_duplicate_pvs = 0;	/* If we never see a duplicate PV we can skip checking for them later. */
+static int _found_duplicate_vgnames = 0;
 
 int lvmcache_init(struct cmd_context *cmd)
 {
@@ -131,6 +132,11 @@ int lvmcache_found_duplicate_pvs(void)
 	return _found_duplicate_pvs;
 }
 
+int lvmcache_found_duplicate_vgnames(void)
+{
+	return _found_duplicate_vgnames;
+}
+
 int lvmcache_get_unused_duplicate_devs(struct cmd_context *cmd, struct dm_list *head)
 {
 	struct device_list *devl, *devl2;
@@ -1225,6 +1231,8 @@ static int _insert_vginfo(struct lvmcache_vginfo *new_vginfo, const char *vgid,
 				     sizeof(uuid_primary)))
 			return_0;
 
+		_found_duplicate_vgnames = 1;
+
 		/*
 		 * vginfo is kept for each VG with the same name.
 		 * They are saved with the vginfo->next list.
@@ -2278,3 +2286,13 @@ int lvmcache_scan_mismatch(struct cmd_context *cmd, const char *vgname, const ch
 	return 1;
 }
 
+int lvmcache_vginfo_has_pvid(struct lvmcache_vginfo *vginfo, char *pvid)
+{
+	struct lvmcache_info *info;
+
+	dm_list_iterate_items(info, &vginfo->infos) {
+		if (!strcmp(info->dev->pvid, pvid))
+			return 1;
+	}
+	return 0;
+}
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index ba60405..12f17df 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -169,6 +169,7 @@ int lvmcache_vgid_is_cached(const char *vgid);
 uint64_t lvmcache_smallest_mda_size(struct lvmcache_info *info);
 
 int lvmcache_found_duplicate_pvs(void);
+int lvmcache_found_duplicate_vgnames(void);
 
 void lvmcache_pvscan_duplicate_check(struct cmd_context *cmd);
 
@@ -198,6 +199,8 @@ void lvmcache_set_independent_location(const char *vgname);
 
 int lvmcache_scan_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid);
 
+int lvmcache_vginfo_has_pvid(struct lvmcache_vginfo *vginfo, char *pvid);
+
 /*
  * These are clvmd-specific functions and are not related to lvmcache.
  * FIXME: rename these with a clvm_ prefix in place of lvmcache_
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 63eafe8..39ab3df 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1484,6 +1484,7 @@ struct cmd_context *create_config_context(void)
 
 	dm_list_init(&cmd->config_files);
 	dm_list_init(&cmd->tags);
+	dm_list_init(&cmd->hints);
 
 	if (!_init_lvm_conf(cmd))
 		goto_out;
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 6396f6c..e8ce312 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -172,11 +172,16 @@ struct cmd_context {
 	unsigned is_clvmd:1;
 	unsigned use_full_md_check:1;
 	unsigned is_activating:1;
+	unsigned enable_hints:1;		/* hints are enabled for cmds in general */
+	unsigned use_hints:1;			/* if hints are enabled this cmd can use them */
+	unsigned pvscan_recreate_hints:1;	/* enable special case hint handling for pvscan --cache */
+	unsigned scan_lvs:1;
 
 	/*
-	 * Filtering.
+	 * Devices and filtering.
 	 */
 	struct dev_filter *filter;
+	struct dm_list hints;
 
 	/*
 	 * Configuration.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index f1d2826..e15494d 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -255,6 +255,20 @@ cfg(devices_external_device_info_source_CFG, "external_device_info_source", devi
 	"    compiled with udev support.\n"
 	"#\n")
 
+cfg(devices_hints_CFG, "hints", devices_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_HINTS, vsn(2, 3, 2), NULL, 0, NULL,
+	"Use a local file to remember which devices have PVs on them.\n"
+	"Some commands will use this as an optimization to reduce device\n"
+	"scanning, and will only scan the listed PVs. Removing the hint file\n"
+	"will cause lvm to generate a new one. Disable hints if PVs will\n"
+	"be copied onto devices using non-lvm commands, like dd.\n"
+	"#\n"
+	"Accepted values:\n"
+	"  all\n"
+	"    Use all hints.\n"
+	"  none\n"
+	"    Use no hints.\n"
+	"#\n")
+
 cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED , CFG_TYPE_STRING, NULL, vsn(1, 2, 19), NULL, 0, NULL,
 	"Select which path name to display for a block device.\n"
 	"If multiple path names exist for a block device, and LVM needs to\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index b45324b..06a5ecf 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -312,4 +312,6 @@
 
 #define DEFAULT_SCAN_LVS 1
 
+#define DEFAULT_HINTS "all"
+
 #endif				/* _LVM_DEFAULTS_H */
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index fb48f1a..8afebfe 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1473,7 +1473,7 @@ struct device *dev_cache_get(struct cmd_context *cmd, const char *name, struct d
 		return d;
 
 	if (f && !(d->flags & DEV_REGULAR)) {
-		ret = f->passes_filter(cmd, f, d);
+		ret = f->passes_filter(cmd, f, d, NULL);
 
 		if (ret == -EAGAIN) {
 			log_debug_devs("get device by name defer filter %s", dev_name(d));
@@ -1546,7 +1546,7 @@ struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t dev, struct
 	if (!f)
 		return d;
 
-	ret = f->passes_filter(cmd, f, d);
+	ret = f->passes_filter(cmd, f, d, NULL);
 
 	if (ret == -EAGAIN) {
 		log_debug_devs("get device by number defer filter %s", dev_name(d));
@@ -1603,7 +1603,7 @@ struct device *dev_iter_get(struct cmd_context *cmd, struct dev_iter *iter)
 		f = iter->filter;
 
 		if (f && !(d->flags & DEV_REGULAR)) {
-			ret = f->passes_filter(cmd, f, d);
+			ret = f->passes_filter(cmd, f, d, NULL);
 
 			if (ret == -EAGAIN) {
 				log_debug_devs("get device by iter defer filter %s", dev_name(d));
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 41c4a9c..9233c52 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -25,11 +25,12 @@ struct cmd_context;
  * predicate for devices.
  */
 struct dev_filter {
-	int (*passes_filter) (struct cmd_context *cmd, struct dev_filter *f, struct device *dev);
+	int (*passes_filter) (struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name);
 	void (*destroy) (struct dev_filter *f);
 	void (*wipe) (struct dev_filter *f);
 	void *private;
 	unsigned use_count;
+	const char *name;
 };
 
 int dev_cache_index_devs(void);
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 638f4b2..9278b51 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -79,6 +79,36 @@ int dev_is_pmem(struct device *dev)
 	return 0;
 }
 
+int dev_is_lv(struct device *dev)
+{
+	FILE *fp;
+	char path[PATH_MAX];
+	char buffer[64];
+
+	if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d/dm/uuid",
+			dm_sysfs_dir(),
+			(int) MAJOR(dev->dev),
+			(int) MINOR(dev->dev)) < 0) {
+		log_warn("Sysfs dm uuid path for %s is too long.", dev_name(dev));
+		return 0;
+	}
+
+	if (!(fp = fopen(path, "r")))
+		return 0;
+
+	if (!fgets(buffer, sizeof(buffer), fp)) {
+		log_warn("Failed to read %s.", path);
+		fclose(fp);
+		return 0;
+	}
+
+	fclose(fp);
+
+	if (!strncmp(buffer, "LVM-", 4))
+		return 1;
+	return 0;
+}
+
 struct dev_types *create_dev_types(const char *proc_dir,
 				   const struct dm_config_node *cn)
 {
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 75539e8..d349905 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -95,4 +95,6 @@ int dev_is_rotational(struct dev_types *dt, struct device *dev);
 
 int dev_is_pmem(struct device *dev);
 
+int dev_is_lv(struct device *dev);
+
 #endif
diff --git a/lib/device/device.h b/lib/device/device.h
index e879dbb..fa7e738 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -36,6 +36,7 @@
 #define DEV_FILTER_AFTER_SCAN	0x00002000	/* apply filter after bcache has data */
 #define DEV_FILTER_OUT_SCAN	0x00004000	/* filtered out during label scan */
 #define DEV_BCACHE_WRITE	0x00008000      /* bcache_fd is open with RDWR */
+#define DEV_SCAN_FOUND_LABEL	0x00010000      /* label scan read dev and found label */
 
 /*
  * Support for external device info.
diff --git a/lib/filters/filter-composite.c b/lib/filters/filter-composite.c
index a9374ab..b0063f1 100644
--- a/lib/filters/filter-composite.c
+++ b/lib/filters/filter-composite.c
@@ -18,13 +18,15 @@
 #include "lib/filters/filter.h"
 #include "lib/device/device.h"
 
-static int _and_p(struct cmd_context *cmd, struct dev_filter *f, struct device *dev)
+static int _and_p(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
 {
 	struct dev_filter **filters;
 	int ret;
 
 	for (filters = (struct dev_filter **) f->private; *filters; ++filters) {
-		ret = (*filters)->passes_filter(cmd, *filters, dev);
+		if (use_filter_name && strcmp((*filters)->name, use_filter_name))
+			continue;
+		ret = (*filters)->passes_filter(cmd, *filters, dev, use_filter_name);
 
 		if (!ret)
 			return 0;	/* No 'stack': a filter, not an error. */
@@ -33,12 +35,12 @@ static int _and_p(struct cmd_context *cmd, struct dev_filter *f, struct device *
 	return 1;
 }
 
-static int _and_p_with_dev_ext_info(struct cmd_context *cmd, struct dev_filter *f, struct device *dev)
+static int _and_p_with_dev_ext_info(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
 {
 	int r;
 
 	dev_ext_enable(dev, external_device_info_source());
-	r = _and_p(cmd, f, dev);
+	r = _and_p(cmd, f, dev, use_filter_name);
 	dev_ext_disable(dev);
 
 	return r;
@@ -93,6 +95,7 @@ struct dev_filter *composite_filter_create(int n, int use_dev_ext_info, struct d
 	cft->wipe = _wipe;
 	cft->use_count = 0;
 	cft->private = filters_copy;
+	cft->name = "composite";
 
 	log_debug_devs("Composite filter initialised.");
 
diff --git a/lib/filters/filter-fwraid.c b/lib/filters/filter-fwraid.c
index 6f47692..992eba8 100644
--- a/lib/filters/filter-fwraid.c
+++ b/lib/filters/filter-fwraid.c
@@ -65,7 +65,7 @@ static int _dev_is_fwraid(struct device *dev)
 #define MSG_SKIPPING "%s: Skipping firmware RAID component device"
 
 static int _ignore_fwraid(struct cmd_context *cmd, struct dev_filter *f __attribute__((unused)),
-			   struct device *dev)
+			   struct device *dev, const char *use_filter_name)
 {
 	int ret;
 
@@ -113,6 +113,7 @@ struct dev_filter *fwraid_filter_create(struct dev_types *dt __attribute__((unus
 	f->destroy = _destroy;
 	f->use_count = 0;
 	f->private = NULL;
+	f->name = "fwraid";
 
 	log_debug_devs("Firmware RAID filter initialised.");
 
diff --git a/lib/filters/filter-internal.c b/lib/filters/filter-internal.c
index 8cc0011..c10e810 100644
--- a/lib/filters/filter-internal.c
+++ b/lib/filters/filter-internal.c
@@ -38,7 +38,7 @@ void internal_filter_clear(void)
 }
 
 static int _passes_internal(struct cmd_context *cmd, struct dev_filter *f __attribute__((unused)),
-			    struct device *dev)
+			    struct device *dev, const char *use_filter_name)
 {
 	struct device_list *devl;
 
@@ -74,6 +74,7 @@ struct dev_filter *internal_filter_create(void)
 	f->passes_filter = _passes_internal;
 	f->destroy = _destroy;
 	f->use_count = 0;
+	f->name = "internal";
 
 	log_debug_devs("Internal filter initialised.");
 
diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index 9cc1a06..d6dd28c 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -82,7 +82,7 @@
  * that will not pass.
  */
 
-static int _passes_md_filter(struct cmd_context *cmd, struct dev_filter *f __attribute__((unused)), struct device *dev)
+static int _passes_md_filter(struct cmd_context *cmd, struct dev_filter *f __attribute__((unused)), struct device *dev, const char *use_filter_name)
 {
 	int ret;
 
@@ -145,6 +145,7 @@ struct dev_filter *md_filter_create(struct cmd_context *cmd, struct dev_types *d
 	f->destroy = _destroy;
 	f->use_count = 0;
 	f->private = dt;
+	f->name = "md";
 
 	log_debug_devs("MD filter initialised.");
 
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index bcd1e52..f0374b4 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -247,7 +247,7 @@ static int _dev_is_mpath(struct dev_filter *f, struct device *dev)
 
 #define MSG_SKIPPING "%s: Skipping mpath component device"
 
-static int _ignore_mpath(struct cmd_context *cmd, struct dev_filter *f, struct device *dev)
+static int _ignore_mpath(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
 {
 	if (_dev_is_mpath(f, dev) == 1) {
 		if (dev->ext.src == DEV_EXT_NONE)
@@ -288,6 +288,7 @@ struct dev_filter *mpath_filter_create(struct dev_types *dt)
 	f->destroy = _destroy;
 	f->use_count = 0;
 	f->private = dt;
+	f->name = "mpath";
 
 	log_debug_devs("mpath filter initialised.");
 
diff --git a/lib/filters/filter-partitioned.c b/lib/filters/filter-partitioned.c
index 6418cdf..1a70054 100644
--- a/lib/filters/filter-partitioned.c
+++ b/lib/filters/filter-partitioned.c
@@ -19,7 +19,7 @@
 
 #define MSG_SKIPPING "%s: Skipping: Partition table signature found"
 
-static int _passes_partitioned_filter(struct cmd_context *cmd, struct dev_filter *f, struct device *dev)
+static int _passes_partitioned_filter(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
 {
 	struct dev_types *dt = (struct dev_types *) f->private;
 	int ret;
@@ -66,6 +66,7 @@ struct dev_filter *partitioned_filter_create(struct dev_types *dt)
 	f->destroy = _partitioned_filter_destroy;
 	f->use_count = 0;
 	f->private = dt;
+	f->name = "partitioned";
 
 	log_debug_devs("Partitioned filter initialised.");
 
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 130b1e5..afa32d4 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -71,13 +71,16 @@ static void _persistent_filter_wipe(struct dev_filter *f)
 	dm_hash_wipe(pf->devices);
 }
 
-static int _lookup_p(struct cmd_context *cmd, struct dev_filter *f, struct device *dev)
+static int _lookup_p(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
 {
 	struct pfilter *pf = (struct pfilter *) f->private;
 	void *l;
 	struct dm_str_list *sl;
 	int pass = 1;
 
+	if (use_filter_name && strcmp(f->name, use_filter_name))
+		return pf->real->passes_filter(cmd, pf->real, dev, use_filter_name);
+
 	if (dm_list_empty(&dev->aliases)) {
 		log_debug_devs("%d:%d: filter cache skipping (no name)",
 				(int)MAJOR(dev->dev), (int)MINOR(dev->dev));
@@ -102,7 +105,7 @@ static int _lookup_p(struct cmd_context *cmd, struct dev_filter *f, struct devic
 	if (!l) {
 		dev->flags &= ~DEV_FILTER_AFTER_SCAN;
 
-		pass = pf->real->passes_filter(cmd, pf->real, dev);
+		pass = pf->real->passes_filter(cmd, pf->real, dev, use_filter_name);
 
 		if (!pass) {
 			/*
@@ -182,6 +185,7 @@ struct dev_filter *persistent_filter_create(struct dev_types *dt, struct dev_fil
 	f->use_count = 0;
 	f->private = pf;
 	f->wipe = _persistent_filter_wipe;
+	f->name = "persistent";
 
 	log_debug_devs("Persistent filter initialised.");
 
diff --git a/lib/filters/filter-regex.c b/lib/filters/filter-regex.c
index 1a8e8a2..e439b36 100644
--- a/lib/filters/filter-regex.c
+++ b/lib/filters/filter-regex.c
@@ -145,7 +145,7 @@ static int _build_matcher(struct rfilter *rf, const struct dm_config_value *val)
 	return r;
 }
 
-static int _accept_p(struct cmd_context *cmd, struct dev_filter *f, struct device *dev)
+static int _accept_p(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
 {
 	int m, first = 1, rejected = 0;
 	struct rfilter *rf = (struct rfilter *) f->private;
@@ -212,6 +212,7 @@ struct dev_filter *regex_filter_create(const struct dm_config_value *patterns)
 	f->destroy = _regex_destroy;
 	f->use_count = 0;
 	f->private = rf;
+	f->name = "regex";
 
 	log_debug_devs("Regex filter initialised.");
 
diff --git a/lib/filters/filter-signature.c b/lib/filters/filter-signature.c
index 5c5796f..6a81203 100644
--- a/lib/filters/filter-signature.c
+++ b/lib/filters/filter-signature.c
@@ -22,7 +22,7 @@
 #define BUFSIZE 4096
 
 static int _ignore_signature(struct cmd_context *cmd, struct dev_filter *f __attribute__((unused)),
-		      struct device *dev)
+		      struct device *dev, const char *use_filter_name)
 {
 	char buf[BUFSIZE];
 	int ret = 0;
@@ -81,6 +81,7 @@ struct dev_filter *signature_filter_create(struct dev_types *dt)
 	f->destroy = _destroy;
 	f->use_count = 0;
 	f->private = dt;
+	f->name = "signature";
 
 	log_debug_devs("signature filter initialised.");
 
diff --git a/lib/filters/filter-sysfs.c b/lib/filters/filter-sysfs.c
index c77c4a6..ebca808 100644
--- a/lib/filters/filter-sysfs.c
+++ b/lib/filters/filter-sysfs.c
@@ -260,7 +260,7 @@ static int _init_devs(struct dev_set *ds)
 }
 
 
-static int _accept_p(struct cmd_context *cmd, struct dev_filter *f, struct device *dev)
+static int _accept_p(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
 {
 	struct dev_set *ds = (struct dev_set *) f->private;
 
@@ -323,6 +323,7 @@ struct dev_filter *sysfs_filter_create(void)
 	f->destroy = _destroy;
 	f->use_count = 0;
 	f->private = ds;
+	f->name = "sysfs";
 
 	log_debug_devs("Sysfs filter initialised.");
 
diff --git a/lib/filters/filter-type.c b/lib/filters/filter-type.c
index 3b0a644..1d08370 100644
--- a/lib/filters/filter-type.c
+++ b/lib/filters/filter-type.c
@@ -17,7 +17,7 @@
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
 
-static int _passes_lvm_type_device_filter(struct cmd_context *cmd, struct dev_filter *f, struct device *dev)
+static int _passes_lvm_type_device_filter(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
 {
 	struct dev_types *dt = (struct dev_types *) f->private;
 	const char *name = dev_name(dev);
@@ -53,6 +53,7 @@ struct dev_filter *lvm_type_filter_create(struct dev_types *dt)
 	f->destroy = _lvm_type_filter_destroy;
 	f->use_count = 0;
 	f->private = dt;
+	f->name = "type";
 
 	log_debug_devs("LVM type filter initialised.");
 
diff --git a/lib/filters/filter-usable.c b/lib/filters/filter-usable.c
index 6997368..b3ff650 100644
--- a/lib/filters/filter-usable.c
+++ b/lib/filters/filter-usable.c
@@ -105,7 +105,7 @@ static int _check_pv_min_size(struct device *dev)
 	return 0;
 }
 
-static int _passes_usable_filter(struct cmd_context *cmd, struct dev_filter *f, struct device *dev)
+static int _passes_usable_filter(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
 {
 	struct filter_data *data = f->private;
 	filter_mode_t mode = data->mode;
@@ -185,6 +185,7 @@ struct dev_filter *usable_filter_create(struct cmd_context *cmd, struct dev_type
 	f->passes_filter = _passes_usable_filter;
 	f->destroy = _usable_filter_destroy;
 	f->use_count = 0;
+	f->name = "usable";
 
 	if (!(data = zalloc(sizeof(struct filter_data)))) {
 		log_error("Usable device filter mode allocation failed");
diff --git a/lib/label/hints.c b/lib/label/hints.c
new file mode 100644
index 0000000..bdd70a9
--- /dev/null
+++ b/lib/label/hints.c
@@ -0,0 +1,1241 @@
+/*
+ * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+/*
+ * There are four different ways that commands handle hints:
+ *
+ * 1. Commands that use hints to reduce scanning, and create new
+ *    hints when needed:
+ *
+ *    fullreport, lvchange, lvcreate, lvdisplay, lvremove, lvresize,
+ *    lvs, pvdisplay, lvpoll, pvs, vgchange, vgck, vgdisplay, vgs,
+ *    lvextend, lvreduce, lvrename
+ *
+ * 2. Commands that just remove existing hints:
+ *
+ *    pvcreate, pvremove, vgcreate, vgremove, vgextend, vgreduce,
+ *    vgcfgrestore, vgimportclone, vgmerge, vgsplit, pvchange
+ *
+ * 3. Commands that ignore hints:
+ *
+ *    lvconvert, lvmdiskscan, lvscan, pvresize, pvck, pvmove, pvscan,
+ *    vgcfgbackup, vgexport, vgimport, vgscan, pvs -a, pvdisplay -a
+ *
+ * 4. Command that removes existing hints and creates new hints:
+ *
+ *    pvscan --cache
+ *
+ *
+ * For 1, hints are used to reduce scanning by:
+ * . get the list of all devices on the system from dev_cache_scan()
+ * . remove devices from that list which are not listed in hints
+ * . do scan the remaining list of devices
+ *
+ * label_scan() is where those steps are implemented:
+ *      . dev_cache_scan() produces all_devs list
+ *      . get_hints(all_devs, scan_devs, &newhints)
+ *        moves some devs from all_devs to scan_devs list (or sets newhints
+ *        if no hints are applied, and a new hints file should be created)
+ *      . _scan_list(scan_devs) does the label scan
+ *      . if newhints was set, call write_hint_file() to create new hints
+ *        based on which devs _scan_list saw an lvm label on
+ *
+ * For 2, commands that change "global state" remove existing hints.
+ * The hints become incorrect as a result of the changes the command
+ * is making. "global state" is lvm state that is not isolated within a VG.
+ * (This is basically: which devices are PVs, and which VG names are used.)
+ *
+ * Commands that change global state do not create new hints because
+ * it's much simpler to create hints based solely on the result of a
+ * full standard label scan, i.e. which devices had an lvm label.
+ * (It's much more complicated to create hints based on making specific
+ * changes to existing hints based on what the command has changed.)
+ *
+ * For 3, these commands are a combination of: uncommon commands that
+ * don't need optimization, commands where the purpose is to read all
+ * devices, commands dealing with global state where it's important to
+ * not miss anything, commands where it's safer to know everything.
+ *
+ * For 4, this is the traditional way of forcing any locally cached
+ * state to be cleared and regenerated.  This would be used to reset
+ * hints after doing something that invalidates the hints in a way
+ * that lvm couldn't detect itself, e.g. using dd to copy a PV to
+ * a non-PV device.  (A user could also just rm /run/lvm/hints in
+ * place of running pvscan --cache.)
+ *
+ *
+ * Creating hints:
+ *
+ * A command in list 1 above calls get_hints() to try to read the
+ * hints file.  get_hints() will sometimes not return any hints, in
+ * which case the label_scan will scan all devices.  This happens if:
+ *
+ * a. the /run/lvm/hints file does not exist *
+ * b. the /run/lvm/hints file is empty *
+ * c. the /run/lvm/hints file content is not applicable *
+ * d. the /run/lvm/newhints file exists *
+ * e. the /run/lvm/nohints file exists
+ * f. a shared nonblocking flock on /run/lvm/hints fails
+ *
+ * When get_hints(all_devs, scan_devs, &newhints) does not find hints to use,
+ * it will sometimes set "newhints" so that the command will create a new
+ * hints file after scanning all the devs.  [* These commands create a
+ * new hint file after scanning.]
+ *
+ * After scanning a dev list that was reduced by applying hints, label_scan
+ * calls validate_hints() to check if the hints were consistent with what
+ * the scan saw on the devs.  Sometimes it's not, in which case the command
+ * then scans the remaining devs, and creates /run/lvm/newhints to signal
+ * to the next command that it should create new hints.
+ *
+ * Causes of each case above:
+ * a) First command run, or a user removed the file
+ * b) A command from list 2 cleared the hint file
+ * c) See below
+ * d) Another command from list 1 found invalid hints after scanning.
+ *    A command from list 2 also creates a newhints file in addition
+ *    to clearing the hint file.
+ * e) A command from list 2 is blocking other commands from using
+ *    hints while it makes global changes.
+ * f) A command from list 2 is holding the ex flock to block
+ *    other commands from using hints while it makes global changes.
+ *
+ * The content of the hint file is ignored and invalidated in get_hints if:
+ *
+ * . The lvm.conf filters or scan_lvs setting used by the command that
+ *   created the hints do not match the settings used by this command.
+ *   When these settings change, different PVs can become visible,
+ *   making previous hints invalid.
+ *
+ * . The list of devices on the system changes.  When a new device
+ *   appears on the system, it may have a PV that was not not around
+ *   when the hints were created, and it needs to be scanned.
+ *   (A hash of all dev names on the system is used to detect when
+ *   the list of devices changes and hints need to be recreated.)
+ *
+ * The hint file is invalidated in validate_hints if:
+ *
+ * . The devs in the hint file have a different PVID or VG name
+ *   than what was seen during the scan.
+ *
+ * . Duplicate PVs were seen in the scan.
+ *
+ * . Others may be added.
+ *
+ */
+
+#include "base/memory/zalloc.h"
+#include "lib/misc/lib.h"
+#include "lib/label/label.h"
+#include "lib/misc/crc.h"
+#include "lib/mm/xlate.h"
+#include "lib/cache/lvmcache.h"
+#include "lib/device/bcache.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/activate/activate.h"
+#include "lib/label/hints.h"
+#include "lib/device/dev-type.h"
+
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <time.h>
+#include <sys/types.h>
+#include <sys/file.h>
+#include <sys/sysmacros.h>
+
+static const char *_hints_file = DEFAULT_RUN_DIR "/hints";
+static const char *_nohints_file = DEFAULT_RUN_DIR "/nohints";
+static const char *_newhints_file = DEFAULT_RUN_DIR "/newhints";
+
+/*
+ * Format of hints file.  Increase the major number when
+ * making a change to the hint file format that older lvm
+ * versions can't use.  Older lvm versions will not try to
+ * use the hint file if the major number in it is larger
+ * than they were built with.  Increase the minor number
+ * when adding features that older lvm versions can just
+ * ignore while continuing to use the other content.
+ */
+#define HINTS_VERSION_MAJOR 1
+#define HINTS_VERSION_MINOR 1
+
+#define HINT_LINE_LEN (PATH_MAX + NAME_LEN + ID_LEN + 64)
+#define HINT_LINE_WORDS 4
+static char _hint_line[HINT_LINE_LEN];
+
+static int _hints_fd = -1;
+
+#define NONBLOCK 1
+
+#define NEWHINTS_NONE     0
+#define NEWHINTS_FILE     1
+#define NEWHINTS_INIT     2
+#define NEWHINTS_REFRESH  3
+#define NEWHINTS_EMPTY    4
+
+static int _hints_exists(void)
+{
+	struct stat buf;
+
+	if (!stat(_hints_file, &buf))
+		return 1;
+	if (errno != ENOENT)
+		log_debug("hints_exist errno %d", errno);
+	return 0;
+}
+
+static int _nohints_exists(void)
+{
+	struct stat buf;
+
+	if (!stat(_nohints_file, &buf))
+		return 1;
+	if (errno != ENOENT)
+		log_debug("nohints_exist errno %d", errno);
+	return 0;
+}
+
+static int _newhints_exists(void)
+{
+	struct stat buf;
+
+	if (!stat(_newhints_file, &buf))
+		return 1;
+	if (errno != ENOENT)
+		log_debug("newhints_exist errno %d", errno);
+	return 0;
+}
+
+static int _touch_newhints(void)
+{
+	FILE *fp;
+
+	if (!(fp = fopen(_newhints_file, "w")))
+		return_0;
+	if (fclose(fp))
+		stack;
+	return 1;
+}
+
+static int _touch_nohints(void)
+{
+	FILE *fp;
+
+	if (!(fp = fopen(_nohints_file, "w")))
+		return_0;
+	if (fclose(fp))
+		stack;
+	return 1;
+}
+
+static int _touch_hints(void)
+{
+	FILE *fp;
+
+	if (!(fp = fopen(_hints_file, "w")))
+		return_0;
+	if (fclose(fp))
+		stack;
+	return 1;
+}
+
+static void _unlink_nohints(void)
+{
+	if (unlink(_nohints_file))
+		log_debug("unlink_nohints errno %d", errno);
+}
+
+static void _unlink_hints(void)
+{
+	if (unlink(_hints_file))
+		log_debug("unlink_hints errno %d", errno);
+}
+
+static void _unlink_newhints(void)
+{
+	if (unlink(_newhints_file))
+		log_debug("unlink_newhints errno %d", errno);
+}
+
+static int _clear_hints(struct cmd_context *cmd)
+{
+	FILE *fp;
+	time_t t;
+
+	if (!(fp = fopen(_hints_file, "w"))) {
+		log_warn("Failed to clear hint file.");
+		/* shouldn't happen, but try to unlink in case */
+		_unlink_hints();
+		return 0;
+	}
+
+	t = time(NULL);
+
+	fprintf(fp, "# Created empty by %s pid %d %s", cmd->name, getpid(), ctime(&t));
+
+	if (fflush(fp))
+		log_debug("clear_hints flush errno %d", errno);
+
+	if (fclose(fp))
+		log_debug("clear_hints close errno %d", errno);
+
+	return 1;
+}
+
+static int _lock_hints(int mode, int nonblock)
+{
+	int fd;
+	int op = mode;
+	int ret;
+
+	if (nonblock)
+		op |= LOCK_NB;
+
+	if (_hints_fd != -1) {
+		log_warn("lock_hints existing fd %d", _hints_fd);
+		return 0;
+	}
+
+	fd = open(_hints_file, O_RDWR);
+	if (fd < 0) {
+		log_debug("lock_hints open errno %d", errno);
+		return 0;
+	}
+
+
+	ret = flock(fd, op);
+	if (!ret) {
+		_hints_fd = fd;
+		return 1;
+	}
+
+	if (close(fd))
+		stack;
+	return 0;
+}
+
+static void _unlock_hints(void)
+{
+	int ret;
+
+	if (_hints_fd == -1) {
+		log_warn("unlock_hints no existing fd");
+		return;
+	}
+
+	ret = flock(_hints_fd, LOCK_UN);
+	if (ret)
+		log_warn("unlock_hints flock errno %d", errno);
+
+	if (close(_hints_fd))
+		stack;
+	_hints_fd = -1;
+}
+
+static struct hint *_find_hint_name(struct dm_list *hints, const char *name)
+{
+	struct hint *hint;
+
+	dm_list_iterate_items(hint, hints) {
+		if (!strcmp(hint->name, name))
+			return hint;
+	}
+	return NULL;
+}
+
+/*
+ * Decide if a given device name should be included in the hint hash.
+ * If it is, then the hash changes if the device is added or removed
+ * from the system, which causes the hints to be regenerated.
+ * If it is not, then the device being added/removed from the system
+ * does not change the hint hash, which means hints remain unchanged.
+ *
+ * If we know that lvm does not want to scan this device, then it should
+ * be excluded from the hint hash.  If a dev is excluded by the regex
+ * filter or by scan_lvs setting, then we know lvm doesn't want to scan
+ * it, so when it is added/removed the scanning results won't change, and
+ * we don't want to regenerate hints.
+ *
+ * One effect of this is that the regex filter and scan_lvs setting also
+ * need to be saved in the hint file, since if those settings change,
+ * it may impact what devs lvm wants to scan, and therefore change what
+ * the hints are.
+ *
+ * We do not need or want to apply all filters to a device here.  The full
+ * filters still determine if a device is scanned and used.  This is simply
+ * used to decide if the device name should be included in the hash,
+ * where the changing hash triggers hints to be recreated.  So, by
+ * including a device here which is excluded by the real filters, the result is
+ * simply that we could end up recreating hints more often than necessary,
+ * which is not a problem.  Not recreating hints when we should is a bigger
+ * problem, so it's best to include devices here if we're unsure.
+ *
+ * Any filter used here obviously cannot rely on reading the device, since
+ * the whole point of the hints is to avoid reading the device.
+ *
+ * It's common for the system to include a device path for a disconnected
+ * device and report zero size for it (e.g. a loop device).  When the
+ * device is connected, a new device name doesn't appear, but the dev size
+ * for the existing device is now reported as non-zero.  So, if a device
+ * is connected/disconnected, changing the size from/to zero, it is
+ * included/excluded in the hint hash.
+ */
+
+static int _dev_in_hint_hash(struct cmd_context *cmd, struct device *dev)
+{
+	uint64_t devsize = 0;
+
+	if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "regex"))
+		return 0;
+
+	if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "type"))
+		return 0;
+
+	/* exclude LVs from hint accounting when scan_lvs is 0 */
+	if (!cmd->scan_lvs && dm_is_dm_major(MAJOR(dev->dev)) && dev_is_lv(dev))
+		return 0;
+
+	if (dev_get_size(dev, &devsize) && !devsize)
+		return 0;
+
+	return 1;
+}
+
+/*
+ * Hints were used to reduce devs that were scanned.  After the reduced
+ * scanning is done, this is called to check if the hints may have been
+ * incorrect or insufficient, in which case we want to continue scanning all
+ * the other (unhinted) devices, as would be done when no hints are used.
+ * This should not generally happen, but is done in an attempt to catch
+ * any unusual situations where the hints become incorrect from something
+ * unexpected.
+ */
+int validate_hints(struct cmd_context *cmd, struct dm_list *hints)
+{
+	struct hint *hint;
+	struct dev_iter *iter;
+	struct device *dev;
+	int ret = 1;
+
+	/* No commands are using hints. */
+	if (!cmd->enable_hints)
+		return 0;
+
+	/* This command does not use hints. */
+	if (!cmd->use_hints && !cmd->pvscan_recreate_hints)
+		return 0;
+
+	if (lvmcache_found_duplicate_pvs()) {
+		log_debug("Hints not used with duplicate pvs");
+		ret = 0;
+		goto out;
+	}
+
+	if (lvmcache_found_duplicate_vgnames()) {
+		log_debug("Hints not used with duplicate vg names");
+		ret = 0;
+		goto out;
+	}
+
+	/*
+	 * Check that the PVID saved in the hint for each device matches the
+	 * PVID that the scan found on the device.  If not, then the hints
+	 * became stale somehow (e.g. manually copying devices with dd) and
+	 * need to be refreshed.
+	 */
+	if (!(iter = dev_iter_create(NULL, 0)))
+		return 0;
+	while ((dev = dev_iter_get(cmd, iter))) {
+		if (!(hint = _find_hint_name(hints, dev_name(dev))))
+			continue;
+
+		/* The cmd hasn't needed this hint's dev so it's not been scanned. */
+		if (!hint->chosen)
+			continue;
+
+		if (strcmp(dev->pvid, hint->pvid)) {
+			log_debug("Invalid hint device %d:%d %s pvid %s had hint pvid %s",
+				  major(hint->devt), minor(hint->devt), dev_name(dev),
+				  dev->pvid, hint->pvid);
+			ret = 0;
+		}
+	}
+	dev_iter_destroy(iter);
+
+	/*
+	 * Check in lvmcache to see if the scan noticed any missing PVs
+	 * which might mean the hints left out a device that we should
+	 * have scanned.
+	 *
+	 * FIXME: the scan cannot currently detect missing PVs.
+	 * They are only detected in vg_read when the PVIDs listed
+	 * in the metadata are looked for and not found.  This could
+	 * be addressed by at least saving the number of expected PVs
+	 * during the scan (in the summary), and then comparing that
+	 * number with the number of PVs found in the hints listing
+	 * that VG name.
+	 */
+
+	/*
+	 * The scan placed a summary of each VG (vginfo) and PV (info)
+	 * into lvmcache lists.  Check in lvmcache to see if the VG name
+	 * for each PV matches the vgname saved in the hint for the PV.
+	 */
+	dm_list_iterate_items(hint, hints) {
+		struct lvmcache_vginfo *vginfo;
+
+		/* The cmd hasn't needed this hint's dev so it's not been scanned. */
+		if (!hint->chosen)
+			continue;
+
+		if (!hint->vgname[0] || (hint->vgname[0] == '-'))
+			continue;
+
+		if (!(vginfo = lvmcache_vginfo_from_vgname(hint->vgname, NULL))) {
+			log_debug("Invalid hint device %d:%d %s pvid %s had vgname %s no VG info.",
+				  major(hint->devt), minor(hint->devt), hint->name,
+				  hint->pvid, hint->vgname);
+			ret = 0;
+			continue;
+		}
+
+		if (!lvmcache_vginfo_has_pvid(vginfo, hint->pvid)) {
+			log_debug("Invalid hint device %d:%d %s pvid %s had vgname %s no PV info.",
+				  major(hint->devt), minor(hint->devt), hint->name,
+				  hint->pvid, hint->vgname);
+			ret = 0;
+			continue;
+		}
+	}
+
+out:
+	if (!ret) {
+		/*
+		 * Force next cmd to recreate hints.  If we can't
+		 * create newhints, the next cmd should get here
+		 * like we have.  We don't use _clear_hints because
+		 * we don't want to take an ex lock here.
+		 */
+		if (!_touch_newhints())
+			stack;
+	}
+
+	return ret;
+}
+
+/*
+ * For devs that match entries in hints, move them from devs_in to devs_out.
+ */
+static void _apply_hints(struct cmd_context *cmd, struct dm_list *hints,
+		char *vgname, struct dm_list *devs_in, struct dm_list *devs_out)
+{
+	struct hint *hint;
+	struct device_list *devl, *devl2;
+	struct dm_list *name_list;
+	struct dm_str_list *name_sl;
+
+	dm_list_iterate_items_safe(devl, devl2, devs_in) {
+		if (!(name_list = dm_list_first(&devl->dev->aliases)))
+			continue;
+		name_sl = dm_list_item(name_list, struct dm_str_list);
+
+		if (!(hint = _find_hint_name(hints, name_sl->str)))
+			continue;
+
+		/* if vgname is set, pick hints with matching vgname */
+		if (vgname && hint->vgname[0] && (hint->vgname[0] != '-')) {
+			if (strcmp(vgname, hint->vgname))
+				continue;
+		}
+
+		dm_list_del(&devl->list);
+		dm_list_add(devs_out, &devl->list);
+		hint->chosen = 1;
+	}
+}
+
+/*
+ * Return 1 and needs_refresh 0: the hints can be used
+ * Return 1 and needs_refresh 1: the hints can't be used and should be updated
+ * Return 0: the hints can't be used
+ *
+ * recreate is set if hint file should be refreshed/recreated
+ */
+static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *needs_refresh)
+{
+	char devpath[PATH_MAX];
+	FILE *fp;
+	const struct dm_config_node *cn;
+	struct dev_iter *iter;
+	struct hint *hint;
+	struct device *dev;
+	char *split[HINT_LINE_WORDS];
+	char *name, *pvid, *devn, *vgname, *p;
+	uint32_t read_hash = 0;
+	uint32_t calc_hash = INITIAL_CRC;
+	uint32_t read_count = 0;
+	uint32_t calc_count = 0;
+	int found = 0;
+	int keylen;
+	int hv_major, hv_minor;
+	int major, minor;
+	int ret = 1;
+	int i;
+
+	if (!(fp = fopen(_hints_file, "r")))
+		return 0;
+
+	for (i = 0; i < HINT_LINE_WORDS; i++)
+		split[i] = NULL;
+
+	while (fgets(_hint_line, sizeof(_hint_line), fp)) {
+		if (!(hint = zalloc(sizeof(struct hint)))) {
+			ret = 0;
+			break;
+		}
+
+		if (_hint_line[0] == '#')
+			continue;
+
+		if ((p = strchr(_hint_line, '\n')))
+			*p = '\0';
+
+		/*
+		 * Data in the hint file cannot be used if:
+		 * - the hints file major version is larger than used by this cmd
+		 * - filters used for hints don't match filters used by this cmd
+		 * - scan_lvs setting used when creating hints doesn't match the
+		 *   scan_lvs setting used by this cmd
+		 * - the list of devs used when creating hints does not match the
+		 *   list of devs used by this cmd
+		 */
+
+		keylen = strlen("hints_version:");
+		if (!strncmp(_hint_line, "hints_version:", keylen)) {
+			if (sscanf(_hint_line + keylen, "%d.%d", &hv_major, &hv_minor) != 2) {
+				log_debug("ignore hints with unknown version %d.%d", hv_major, hv_minor);
+				*needs_refresh = 1;
+				break;
+			}
+
+			if (hv_major > HINTS_VERSION_MAJOR) {
+				log_debug("ignore hints with newer major version %d.%d", hv_major, hv_minor);
+				*needs_refresh = 1;
+				break;
+			}
+			continue;
+		}
+
+		keylen = strlen("global_filter:");
+		if (!strncmp(_hint_line, "global_filter:", keylen)) {
+			cn = find_config_tree_array(cmd, devices_global_filter_CFG, NULL);
+			if (strcmp(cn->v->v.str, _hint_line + keylen)) {
+				log_debug("ignore hints with different global_filter");
+				*needs_refresh = 1;
+				break;
+			}
+			continue;
+		}
+
+		keylen = strlen("filter:");
+		if (!strncmp(_hint_line, "filter:", keylen)) {
+			cn = find_config_tree_array(cmd, devices_filter_CFG, NULL);
+			if (strcmp(cn->v->v.str, _hint_line + keylen)) {
+				log_debug("ignore hints with different filter");
+				*needs_refresh = 1;
+				break;
+			}
+			continue;
+		}
+
+		keylen = strlen("scan_lvs:");
+		if (!strncmp(_hint_line, "scan_lvs:", keylen)) {
+			int scan_lvs = 0;
+			sscanf(_hint_line + keylen, "%u", &scan_lvs);
+
+			if (scan_lvs != cmd->scan_lvs) {
+				log_debug("ignore hints with different scan_lvs");
+				*needs_refresh = 1;
+				break;
+			}
+			continue;
+		}
+
+		keylen = strlen("devs_hash:");
+		if (!strncmp(_hint_line, "devs_hash:", keylen)) {
+			sscanf(_hint_line + keylen, "%u %u", &read_hash, &read_count);
+			continue;
+		}
+
+		/*
+		 * Ignore any other line prefixes that we don't recognize.
+		 */
+		keylen = strlen("scan:");
+		if (strncmp(_hint_line, "scan:", keylen))
+			continue;
+
+		if (dm_split_words(_hint_line, HINT_LINE_WORDS, 0, split) < 1)
+			continue;
+
+		name = split[0];
+		pvid = split[1];
+		devn = split[2];
+		vgname = split[3];
+
+		if (name && !strncmp(name, "scan:", 5))
+			strncpy(hint->name, name+5, PATH_MAX);
+
+		if (pvid && !strncmp(pvid, "pvid:", 5))
+			strncpy(hint->pvid, pvid+5, ID_LEN);
+
+		if (devn && sscanf(devn, "devn:%d:%d", &major, &minor) == 2)
+			hint->devt = makedev(major, minor);
+
+		if (vgname && (strlen(vgname) > 3) && (vgname[4] != '-'))
+			strncpy(hint->vgname, vgname+3, NAME_LEN);
+
+		log_debug("add hint %s %s %d:%d %s", hint->name, hint->pvid, major, minor, vgname);
+		dm_list_add(hints, &hint->list);
+		found++;
+	}
+
+	if (fclose(fp))
+		stack;
+
+	if (!ret)
+		return 0;
+
+	if (!found)
+		return 1;
+
+	if (*needs_refresh)
+		return 1;
+
+	/*
+	 * Calculate and compare hash of devices that may be scanned.
+	 */
+	if (!(iter = dev_iter_create(NULL, 0)))
+		return 0;
+	while ((dev = dev_iter_get(cmd, iter))) {
+		if (!_dev_in_hint_hash(cmd, dev))
+			continue;
+		memset(devpath, 0, sizeof(devpath));
+		strncpy(devpath, dev_name(dev), PATH_MAX);
+		calc_hash = calc_crc(calc_hash, (const uint8_t *)devpath, strlen(devpath));
+		calc_count++;
+	}
+	dev_iter_destroy(iter);
+
+	if (read_hash && (read_hash != calc_hash)) {
+		/* The count is just informational. */
+		log_debug("ignore hints with read_hash %u count %u calc_hash %u count %u",
+			  read_hash, read_count, calc_hash, calc_count);
+		*needs_refresh = 1;
+		return 1;
+	}
+
+	log_debug("accept hints found %d", dm_list_size(hints));
+	return 1;
+}
+
+/*
+ * Include any device in the hints that label_scan saw which had an lvm label
+ * header. label_scan set DEV_SCAN_FOUND_LABEL on the dev if it saw an lvm
+ * header.  We only create new hints here after a complete label_scan at the
+ * start of the command.  (It makes things far simpler to always just recreate
+ * hints from a clean, full scan, than to try to make granular updates to the
+ * content of an existing hint file.)
+ *
+ * Hints are not valid from one command to the next if the commands are using
+ * different filters or different scan_lvs settings.  These differences would
+ * cause the two commands to consider different devices for scanning.
+ *
+ * If the set of devices on the system changes from one cmd to the next
+ * (excluding those skipped by filters or scan_lvs), the hints are ignored
+ * since there may be a new device that is now present that should be scanned
+ * that was not present when the hints were created.  The change in the set of
+ * devices is detected by creating a hash of all dev names.  When a device is
+ * added or removed from this system, this hash changes triggering hints to be
+ * recreated.
+ *
+ * (This hash detection depends on the two commands iterating through dev names
+ * in the same order, which happens because the devs are inserted into the
+ * btree using devno.  If the btree implementation changes, then we need
+ * to sort the dev names here before iterating through them.)
+ *
+ * N.B. the config setting pv_min_size should technically be included in
+ * the hint file like the filter and scan_lvs setting, since increasing
+ * pv_min_size can cause new devices to be scanned that were not before.
+ * It is left out since it is not often changed, but could be easily added.
+ */
+
+int write_hint_file(struct cmd_context *cmd, int newhints)
+{
+	char devpath[PATH_MAX];
+	FILE *fp;
+	const struct dm_config_node *cn;
+	struct lvmcache_info *info;
+	struct dev_iter *iter;
+	struct device *dev;
+	const char *vgname;
+	uint32_t hash = INITIAL_CRC;
+	uint32_t count = 0;
+	time_t t;
+	int ret = 1;
+
+	/* This function should not be called if !enable_hints or !use_hints. */
+
+	/* No commands are using hints. */
+	if (!cmd->enable_hints)
+		return 0;
+
+	/* This command does not use hints. */
+	if (!cmd->use_hints && !cmd->pvscan_recreate_hints)
+		return 0;
+
+	if (lvmcache_found_duplicate_pvs() || lvmcache_found_duplicate_vgnames()) {
+		/*
+		 * When newhints is EMPTY, it means get_hints() found an empty
+		 * hint file.  So we scanned all devs and found duplicate pvids
+		 * or duplicate vgnames (which is probably why the hints were
+		 * empty.)  Since the hint file is already empty, we don't need
+		 * to recreate an empty file.
+		 */
+		if (newhints == NEWHINTS_EMPTY)
+			return 1;
+	}
+
+	log_debug("Writing hint file %d", newhints);
+
+	if (!(fp = fopen(_hints_file, "w"))) {
+		ret = 0;
+		goto out_unlock;
+	}
+
+	t = time(NULL);
+
+	if (lvmcache_found_duplicate_pvs() || lvmcache_found_duplicate_vgnames()) {
+		fprintf(fp, "# Created empty by %s pid %d %s", cmd->name, getpid(), ctime(&t));
+
+		/* leave a comment about why it's empty in case someone is curious */
+		if (lvmcache_found_duplicate_pvs())
+			fprintf(fp, "# info: duplicate_pvs\n");
+		if (lvmcache_found_duplicate_vgnames())
+			fprintf(fp, "# info: duplicate_vgnames\n");
+		goto out_flush;
+	}
+
+	fprintf(fp, "# Created by %s pid %d %s", cmd->name, getpid(), ctime(&t));
+	fprintf(fp, "hints_version: %d.%d\n", HINTS_VERSION_MAJOR, HINTS_VERSION_MINOR);
+
+	cn = find_config_tree_array(cmd, devices_global_filter_CFG, NULL);
+	fprintf(fp, "global_filter:%s\n", cn->v->v.str);
+
+	cn = find_config_tree_array(cmd, devices_filter_CFG, NULL);
+	fprintf(fp, "filter:%s\n", cn->v->v.str);
+
+	fprintf(fp, "scan_lvs:%d\n", cmd->scan_lvs);
+
+	/* 
+	 * iterate through all devs and write a line for each
+	 * dev flagged DEV_SCAN_FOUND_LABEL
+	 */
+
+	if (!(iter = dev_iter_create(NULL, 0))) {
+		ret = 0;
+		goto out_close;
+	}
+
+	/*
+	 * This loop does two different things (for clarity this should be
+	 * two separate dev_iter loops, but one is used for efficiency).
+	 * 1. compute the hint hash from all relevant devs
+	 * 2. add PVs to the hint file
+	 */
+	while ((dev = dev_iter_get(cmd, iter))) {
+		if (!_dev_in_hint_hash(cmd, dev)) {
+			if (dev->flags & DEV_SCAN_FOUND_LABEL) {
+				/* should never happen */
+				log_error("skip hint hash but found label %s", dev_name(dev));
+			}
+			continue;
+		}
+
+		/*
+		 * Create a hash of all device names on the system so we can
+		 * detect when the devices on the system change, which
+		 * invalidates the existing hints.
+		 */
+		memset(devpath, 0, sizeof(devpath));
+		strncpy(devpath, dev_name(dev), PATH_MAX);
+		hash = calc_crc(hash, (const uint8_t *)devpath, strlen(devpath));
+		count++;
+
+		if (!(dev->flags & DEV_SCAN_FOUND_LABEL))
+			continue;
+
+		/*
+		 * No vgname will be found here for a PV with no mdas,
+		 * in which case the vgname hint will be incomplete.
+		 * (The label scan cannot associate nomda-pvs with the
+		 * correct vg in lvmcache; that is only done by vg_read.)
+		 * When using vgname hint we would always want to also
+		 * scan any PVs missing a vgname hint in case they are
+		 * part of the vg we are looking for.
+		 */
+		if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 0)))
+			vgname = lvmcache_vgname_from_info(info);
+		else
+			vgname = NULL;
+
+		if (vgname && is_orphan_vg(vgname))
+			vgname = NULL;
+
+		fprintf(fp, "scan:%s pvid:%s devn:%d:%d vg:%s\n",
+			dev_name(dev),
+			dev->pvid,
+			major(dev->dev), minor(dev->dev),
+			vgname ?: "-");
+	}
+
+	fprintf(fp, "devs_hash: %u %u\n", hash, count);
+	dev_iter_destroy(iter);
+
+ out_flush:
+	if (fflush(fp))
+		stack;
+
+	log_debug("Wrote hint file with devs_hash %u count %u", hash, count);
+
+	/*
+	 * We are writing refreshed hints because another command told us to by
+	 * touching newhints, so unlink the newhints file.
+	 */
+	if (newhints == NEWHINTS_FILE)
+		_unlink_newhints();
+
+ out_close:
+	if (fclose(fp))
+		stack;
+
+ out_unlock:
+	/* get_hints() took ex lock before returning with newhints set */
+	_unlock_hints();
+
+	return ret;
+}
+
+/*
+ * Commands that do things that would change existing hints (i.e. create or
+ * remove PVs) call this function before they start to get rid of the existing
+ * hints.  This function clears the content of the hint file so that subsequent
+ * commands will recreate it.  These commands do not try to recreate hints when
+ * they are done (this keeps hint creation simple, always done in one way from
+ * one place.)  While this command runs, it holds an ex lock on the hint file.
+ * This causes any other command that tries to use the hints to ignore the
+ * hints by failing in _lock_hints(SH).  We do not want another command to
+ * be creating new hints at the same time that this command is changing things
+ * that would invalidate them, so we block new hints from being created until
+ * we are done with the changes.
+ *
+ * This is the only place that makes a blocking lock request on the hints file.
+ * It does this so that it won't clear the hint file while a previous command
+ * is still reading it, and to ensure we are holding the hints lock before we
+ * begin changing things.  (In place of a blocking request we could add a retry
+ * loop around nonblocking requests, which would allow us to better handle
+ * instances where a bad/stuck lock is blocking this for a long time.)
+ *
+ * To handle cases of indefinite postponement (repeated commands taking sh lock
+ * on the hints file, preventing us from ever getting the ex lock), we touch
+ * the nohints file first.  The nohints file causes all other commands to
+ * ignore hints.  This means we should only have to block waiting for
+ * pre-existing commands that have locked the hints file.
+ *
+ * (If the command were to crash or be SIGKILLed between touch_nohints
+ * and unlink_nohints, it could leave the nohints file in place.  This
+ * is not a huge deal - it would be cleared by the next command like
+ * this that doesn't crash, or by a reboot, or manually.  If it's still
+ * an issue we could easily write the pid in the nohints file, and
+ * others could check if the pid is still around before obeying it.)
+ *
+ * The intention is to call this function after the global ex lock has been
+ * taken, which is the official lock serializing commands changing which
+ * devs are PVs or not.  This means that a command should never block in
+ * this function due to another command that has used this function --
+ * they would be serialized by the official global lock first.
+ * e.g. two pvcreates should never block each other from the hint lock,
+ * but rather from the global lock...
+ *
+ * Unfortunately, the global(orphan) lock is not used consistently so it's not
+ * quite doing its job right and needs some cleanup.  Until that's done,
+ * concurrent commands like pvcreate may block each other on the hint lock.
+ */
+
+void clear_hint_file(struct cmd_context *cmd)
+{
+	/* No commands are using hints. */
+	if (!cmd->enable_hints)
+		return;
+
+	/*
+	 * This function runs even when cmd->use_hints is 0,
+	 * which means this command does not use hints, but
+	 * others do, so we are clearing the hints for them.
+	 */
+
+	/* limit potential delay blocking on hints lock next */
+	if (!_touch_nohints())
+		stack;
+
+	/*
+	 * We are relying on the command exit to release this flock,
+	 * we should probably add an explicit unlock_hints call.
+	 */
+
+	if (!_lock_hints(LOCK_EX, 0))
+		stack;
+
+	_unlink_nohints();
+
+	if (!_clear_hints(cmd))
+		stack;
+
+	/*
+	 * Creating a newhints file here is not necessary, since
+	 * get_hints would see an empty hints file, but get_hints
+	 * is more efficient if it sees a newhints file first.
+	 */
+	if (!_touch_newhints())
+		stack;
+}
+
+/*
+ * Currently, all the commands using hints (ALLOW_HINTS) take an optional or
+ * required first position arg of a VG name or LV name.  If some other command
+ * began using hints which took some other kind of position arg, we would
+ * probably want to exclude that command from attempting this optimization,
+ * because it would be difficult to know what VG that command wanted to use.
+ */
+static void _get_single_vgname_cmd_arg(struct cmd_context *cmd,
+				       struct dm_list *hints, char **vgname)
+{
+	struct hint *hint;
+	char namebuf[NAME_LEN];
+	char *name = NULL;
+	char *arg, *st, *p;
+	int i = 0;
+	
+	memset(namebuf, 0, sizeof(namebuf));
+
+	if (cmd->position_argc != 1)
+		return;
+
+	if (!cmd->position_argv[0])
+		return;
+
+	arg = cmd->position_argv[0];
+
+	/* tag */
+	if (arg[0] == '@')
+		return;
+
+	/* /dev/path - strip chars before vgname */
+	if (arg[0] == '/') {
+#if 0
+		/* skip_dev_dir only available in tools layer */
+		const char *strip;
+		if (!(strip = skip_dev_dir(cmd, (const char *)arg, NULL)))
+			return;
+		arg = (char *)strip;
+#endif
+		return;
+	}
+
+	if (!(st = strchr(arg, '/'))) {
+		/* simple vgname */
+		name = strdup(arg);
+		goto check;
+	}
+
+	/* take vgname from vgname/lvname */
+	for (p = arg; p < st; p++)
+		namebuf[i++] = *p;
+
+	name = strdup(namebuf);
+
+check:
+	/*
+	 * Only use this vgname hint if there are hints that contain this
+	 * vgname.  This might happen if we aren't able to properly extract the
+	 * vgname from the command args (could happen in some odd cases, e.g.
+	 * only LV name is specified without VG name).
+	 */
+	dm_list_iterate_items(hint, hints) {
+		if (!strcmp(hint->vgname, name)) {
+			*vgname = name;
+			return;
+		}
+	}
+}
+
+/*
+ * Returns 0: no hints are used.
+ *  . newhints is set if this command should create new hints after scan
+ *    for subsequent commands to use.
+ *
+ * Returns 1: use hints that are returned in hints list.
+ */
+
+int get_hints(struct cmd_context *cmd, struct dm_list *hints, int *newhints,
+	      struct dm_list *devs_in, struct dm_list *devs_out)
+{
+	int needs_refresh = 0;
+	char *vgname = NULL;
+
+	/* Decide below if the caller should create new hints. */
+	*newhints = NEWHINTS_NONE;
+
+	/* No commands are using hints. */
+	if (!cmd->enable_hints)
+		return 0;
+
+	/*
+	 * Special case for 'pvscan --cache' which removes hints,
+	 * and then creates new hints.  pvscan does not use hints,
+	 * so this has to be checked before the cmd->use_hints check.
+	 */
+	if (cmd->pvscan_recreate_hints) {
+		/* clear_hint_file already locked hints ex */
+		/* create new hints after scan */
+		log_debug("get_hints: pvscan recreate");
+		*newhints = NEWHINTS_FILE;
+		return 0;
+	}
+
+	/* This command does not use hints. */
+	if (!cmd->use_hints)
+		return 0;
+
+	/*
+	 * Check if another command created the nohints file to prevent us from
+	 * using hints.
+	 */
+	if (_nohints_exists()) {
+		log_debug("get_hints: nohints file");
+		return 0;
+	}
+
+	/*
+	 * Check if another command created the newhints file to cause us to
+	 * ignore current hints and recreate new ones.  We'll unlink_newhints
+	 * to remove newhints file after writing refreshed hints file.
+	 */
+	if (_newhints_exists()) {
+		log_debug("get_hints: newhints file");
+		if (!_hints_exists())
+			_touch_hints();
+		if (!_lock_hints(LOCK_EX, NONBLOCK))
+			return 0;
+		/* create new hints after scan */
+		*newhints = NEWHINTS_FILE;
+		return 0;
+	}
+
+	/*
+	 * no hints file exists, a normal case
+	 */
+	if (!_hints_exists()) {
+		log_debug("get_hints: no file");
+		if (!_touch_hints())
+			return 0;
+		if (!_lock_hints(LOCK_EX, NONBLOCK))
+			return 0;
+		/* create new hints after scan */
+		*newhints = NEWHINTS_INIT;
+		return 0;
+	}
+
+	/*
+	 * hints are locked by a command modifying things, just skip using
+	 * hints this time since they aren't accurate while things change.
+	 * We hold a sh lock on the hints file while reading it to prevent
+	 * another command from clearing it while we're reading
+	 */
+	if (!_lock_hints(LOCK_SH, NONBLOCK)) {
+		log_debug("get_hints: lock fail");
+		return 0;
+	}
+
+	/*
+	 * couln't read file for some reason, not normal, just skip using hints
+	 */
+	if (!_read_hint_file(cmd, hints, &needs_refresh)) {
+		log_debug("get_hints: read fail");
+		_unlock_hints();
+		return 0;
+	}
+
+	_unlock_hints();
+
+	/*
+	 * The content of the hint file is invalid and should be refreshed,
+	 * so we'll scan everything and then recreate the hints.
+	 */
+	if (needs_refresh) {
+		log_debug("get_hints: needs refresh");
+
+		if (!_lock_hints(LOCK_EX, NONBLOCK))
+			return 0;
+
+		/* create new hints after scan */
+		*newhints = NEWHINTS_REFRESH;
+		return 0;
+
+	}
+	
+	/*
+	 * A command that changes global state clears the content
+	 * of the hints file so it will be recreated, and we must
+	 * be following that since we found no hints.
+	 */
+	if (dm_list_empty(hints)) {
+		log_debug("get_hints: no entries");
+
+		if (!_lock_hints(LOCK_EX, NONBLOCK))
+			return 0;
+
+		/* create new hints after scan */
+		*newhints = NEWHINTS_EMPTY;
+		return 0;
+	}
+
+	/*
+	 * If the command specifies a single VG (alone or as part of a single
+	 * LV), then we can set vgname to further reduce scanning by only
+	 * scanning the hints for the given vgname.
+	 *
+	 * (This is a further optimization beyond the basic hints that tell
+	 * us which devs are PVs. We might want to enable this optimization
+	 * separately.)
+	 */
+	_get_single_vgname_cmd_arg(cmd, hints, &vgname);
+
+	_apply_hints(cmd, hints, vgname, devs_in, devs_out);
+
+	log_debug("get_hints: applied using %d other %d",
+		  dm_list_size(devs_out), dm_list_size(devs_in));
+	return 1;
+}
+
diff --git a/lib/label/hints.h b/lib/label/hints.h
new file mode 100644
index 0000000..d80016e
--- /dev/null
+++ b/lib/label/hints.h
@@ -0,0 +1,37 @@
+/*
+ * Copyright (C) 2004-2018 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#ifndef _LVM_HINTS_H
+#define _LVM_HINTS_H
+
+struct hint {
+	struct dm_list list;
+	char name[PATH_MAX];
+	char pvid[ID_LEN + 1];
+	char vgname[NAME_LEN];
+	dev_t devt;
+	unsigned chosen:1; /* this hint's dev was chosen for scanning */
+};
+
+int write_hint_file(struct cmd_context *cmd, int newhints);
+
+void clear_hint_file(struct cmd_context *cmd);
+
+int get_hints(struct cmd_context *cmd, struct dm_list *hints, int *newhints,
+              struct dm_list *devs_in, struct dm_list *devs_out);
+
+int validate_hints(struct cmd_context *cmd, struct dm_list *hints);
+
+#endif
+
diff --git a/lib/label/label.c b/lib/label/label.c
index 6fe1e41..7d5073e 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -22,6 +22,7 @@
 #include "lib/device/bcache.h"
 #include "lib/commands/toolcontext.h"
 #include "lib/activate/activate.h"
+#include "lib/label/hints.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
@@ -358,6 +359,8 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 	int ret = 0;
 	int pass;
 
+	dev->flags &= ~DEV_SCAN_FOUND_LABEL;
+
 	/*
 	 * The device may have signatures that exclude it from being processed.
 	 * If filters were applied before bcache data was available, some
@@ -370,7 +373,7 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 
 		log_debug_devs("Scan filtering %s", dev_name(dev));
 		
-		pass = f->passes_filter(cmd, f, dev);
+		pass = f->passes_filter(cmd, f, dev, NULL);
 
 		if ((pass == -EAGAIN) || (dev->flags & DEV_FILTER_AFTER_SCAN)) {
 			/* Shouldn't happen */
@@ -412,6 +415,7 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 		goto_out;
 	}
 
+	dev->flags |= DEV_SCAN_FOUND_LABEL;
 	*is_lvm_device = 1;
 
 	/*
@@ -827,6 +831,16 @@ static int _setup_bcache(int cache_blocks)
 	return 1;
 }
 
+static void _free_hints(struct dm_list *hints)
+{
+	struct hint *hint, *hint2;
+
+	dm_list_iterate_items_safe(hint, hint2, hints) {
+		dm_list_del(&hint->list);
+		free(hint);
+	}
+}
+
 /*
  * Scan and cache lvm data from all devices on the system.
  * The cache should be empty/reset before calling this.
@@ -835,13 +849,18 @@ static int _setup_bcache(int cache_blocks)
 int label_scan(struct cmd_context *cmd)
 {
 	struct dm_list all_devs;
+	struct dm_list scan_devs;
+	struct dm_list hints;
 	struct dev_iter *iter;
 	struct device_list *devl, *devl2;
 	struct device *dev;
+	int newhints = 0;
 
 	log_debug_devs("Finding devices to scan");
 
 	dm_list_init(&all_devs);
+	dm_list_init(&scan_devs);
+	dm_list_init(&hints);
 
 	/*
 	 * Iterate through all the devices in dev-cache (block devs that appear
@@ -889,20 +908,64 @@ int label_scan(struct cmd_context *cmd)
 	};
 	dev_iter_destroy(iter);
 
-	log_debug_devs("Found %d devices to scan", dm_list_size(&all_devs));
-
 	if (!scan_bcache) {
 		if (!_setup_bcache(dm_list_size(&all_devs)))
 			return 0;
 	}
 
-	_scan_list(cmd, cmd->filter, &all_devs, NULL);
+	/*
+	 * In some common cases we can avoid scanning all devices.
+	 *
+	 * TODO: if the command is using hints and a single vgname
+	 * arg, we can also take the vg lock here, prior to scanning.
+	 * This means we would not need to rescan the PVs in the VG
+	 * in vg_read (skip lvmcache_label_rescan_vg) after the
+	 * vg lock is usually taken.  (Some commands are already
+	 * able to avoid rescan in vg_read, but locking early would
+	 * apply to more cases.)
+	 */
+	if (!get_hints(cmd, &hints, &newhints, &all_devs, &scan_devs))
+		dm_list_splice(&scan_devs, &all_devs);
+
+	log_debug("Will scan %d devices skip %d", dm_list_size(&scan_devs), dm_list_size(&all_devs));
+
+	/*
+	 * Do the main scan.
+	 */
+	_scan_list(cmd, cmd->filter, &scan_devs, NULL);
+
+	dm_list_init(&cmd->hints);
+
+	if (!dm_list_empty(&hints)) {
+		if (!validate_hints(cmd, &hints)) {
+			/*
+			 * We scanned a subset of all devices based on hints.
+			 * With the results from the scan we may decide that
+			 * the hints are not valid, so scan all others.
+			 */
+			log_debug("Will scan %d remaining devices", dm_list_size(&all_devs));
+			_scan_list(cmd, cmd->filter, &all_devs, NULL);
+			_free_hints(&hints);
+			newhints = 0;
+		} else {
+			/* The hints may be used by another device iteration. */
+			dm_list_splice(&cmd->hints, &hints);
+		}
+	}
 
 	dm_list_iterate_items_safe(devl, devl2, &all_devs) {
 		dm_list_del(&devl->list);
 		free(devl);
 	}
 
+	dm_list_iterate_items_safe(devl, devl2, &scan_devs) {
+		dm_list_del(&devl->list);
+		free(devl);
+	}
+
+	if (newhints)
+		write_hint_file(cmd, newhints);
+
 	return 1;
 }
 
diff --git a/test/shell/hints.sh b/test/shell/hints.sh
new file mode 100644
index 0000000..bdaf3be
--- /dev/null
+++ b/test/shell/hints.sh
@@ -0,0 +1,377 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMPOLLD=1
+
+/* hints are currently disabled with lvmlockd */
+SKIP_WITH_LVMLOCKD=1
+
+RUNDIR="/run"
+test -d "$RUNDIR" || RUNDIR="/var/run"
+HINTS="$RUNDIR/lvm/hints"
+NOHINTS="$RUNDIR/lvm/nohints"
+NEWHINTS="$RUNDIR/lvm/newhints"
+PREV="$RUNDIR/lvm/prev-hints"
+
+. lib/inittest
+
+# TODO:
+# Test commands that ignore hints
+# Test flock
+
+
+aux lvmconf 'devices/scan_lvs = 0'
+
+aux prepare_devs 6
+
+# no PVs yet so hints should have no devs
+pvs
+not grep scan: $HINTS
+
+#
+# vg1 uses dev1,dev2
+#
+# Test basics that PVs are in hints, not non-PV devs,
+# and that only PVs are scanned when using hints.
+#
+
+vgcreate $vg1 "$dev1" "$dev2"
+lvcreate -n $lv1 -l 4 $vg1
+
+# test that only the two PVs are in hints
+pvs
+grep -v -E "$dev1|$dev2" $HINTS > tmptest
+not grep scan: tmptest
+
+# test that 'pvs' submits only two reads, one for each PV in hints
+strace -e io_submit pvs 2>&1|tee tmptest
+test "$(grep io_submit tmptest | wc -l)" -eq 2
+
+# test that 'pvs -a' submits six reads, one for each device
+strace -e io_submit pvs -a 2>&1|tee tmptest
+test "$(grep io_submit tmptest | wc -l)" -eq 6
+
+#
+# vg2 uses dev3,dev4
+#
+# Test common commands that cause hints to be refreshed:
+# pvcreate/vgcreate/vgextend/vgreduce/vgremove/pvremove
+#
+
+not pvs "$dev3"
+not grep "$dev3" $HINTS
+cp $HINTS $PREV
+pvcreate "$dev3"
+grep "# Created empty" $HINTS
+cat $NEWHINTS
+# next cmd recreates hints
+pvs "$dev3"
+grep "$dev3" $HINTS
+not diff $HINTS $PREV
+not cat $NEWHINTS
+
+not vgs $vg2
+cp $HINTS $PREV
+vgcreate $vg2 "$dev3"
+grep "# Created empty" $HINTS
+cat $NEWHINTS
+# next cmd recreates hints
+vgs $vg2
+grep $vg2 $HINTS
+not diff $HINTS $PREV
+not cat $NEWHINTS
+
+cp $HINTS $PREV
+vgextend $vg2 "$dev4"
+grep "# Created empty" $HINTS
+cat $NEWHINTS
+# next cmd recreates hints
+vgs $vg2
+grep "$dev4" $HINTS
+not diff $HINTS $PREV
+not cat $NEWHINTS
+
+cp $HINTS $PREV
+vgreduce $vg2 "$dev4"
+grep "# Created empty" $HINTS
+cat $NEWHINTS
+# next cmd recreates hints
+vgs $vg2
+grep "$dev4" $HINTS
+not diff $HINTS $PREV
+not cat $NEWHINTS
+
+cp $HINTS $PREV
+vgremove $vg2
+grep "# Created empty" $HINTS
+cat $NEWHINTS
+# next cmd recreates hints
+not vgs $vg2
+not grep $vg2 $HINTS
+not diff $HINTS $PREV
+not cat $NEWHINTS
+
+cp $HINTS $PREV
+pvremove "$dev3" "$dev4"
+grep "# Created empty" $HINTS
+cat $NEWHINTS
+# next cmd recreates hints
+not pvs "$dev3"
+not pvs "$dev4"
+not grep "$dev3" $HINTS
+not grep "$dev4" $HINTS
+not diff $HINTS $PREV
+not cat $NEWHINTS
+
+#
+# Test that adding a new device and removing a device
+# causes hints to be recreated.
+#
+
+not pvs "$dev5"
+
+# create a new temp device that will cause hint hash to change
+DEVNAME=${PREFIX}pv99
+echo "0 `blockdev --getsize $dev5` linear $dev5 0" | dmsetup create $DEVNAME
+dmsetup status $DEVNAME
+
+cp $HINTS $PREV
+# pvs ignores current hints because of different dev hash and refreshes new hints
+pvs
+# devs listed in hints before and after are the same
+grep scan: $PREV > scan1
+grep scan: $HINTS > scan2
+diff scan1 scan2
+# hash listed before and after are different
+cat $PREV
+cat $HINTS
+grep devs_hash $PREV > devs_hash1
+grep devs_hash $HINTS > devs_hash2
+not diff devs_hash1 devs_hash2
+
+# hints are stable/unchanging
+cp $HINTS $PREV
+pvs
+diff $HINTS $PREV
+
+# remove the temp device which will cause hint hash to change again
+dmsetup remove $DEVNAME
+
+cp $HINTS $PREV
+# pvs ignores current hints because of different dev hash and refreshes new hints
+pvs
+# devs listed in hints before and after are the same
+grep scan: $PREV > scan1
+grep scan: $HINTS > scan2
+diff scan1 scan2
+# hash listed before and after are different
+grep devs_hash $PREV > devs_hash1
+grep devs_hash $HINTS > devs_hash2
+not diff devs_hash1 devs_hash2
+
+#
+# Test that hints don't change from a bunch of commands
+# that use hints and shouldn't change it.
+#
+
+# first create some more metadata using vg2
+pvcreate "$dev3" "$dev4"
+vgcreate $vg2 "$dev3"
+lvcreate -n $lv1 -l1 $vg2
+lvcreate -n $lv2 -l1 $vg2
+
+cp $HINTS $PREV
+lvm fullreport
+lvchange -ay $vg1
+lvchange -an $vg1
+lvcreate -l1 -n $lv2 $vg1
+lvcreate -l1 -an -n $lv3 $vg1
+lvchange -an $vg1
+lvremove $vg1/$lv3
+lvresize -l+1 $vg1/$lv2
+lvresize -l-1 $vg1/$lv2
+lvdisplay
+pvdisplay
+vgdisplay
+lvs
+pvs
+vgs
+vgchange -ay $vg2
+vgchange -an $vg2
+vgck $vg2
+lvrename $vg1 $lv2 $lv3
+# no change in hints after all that
+diff $HINTS $PREV
+
+#
+# Test that changing the filter will cause hint refresh
+#
+
+rm $HINTS $PREV
+vgs
+cp $HINTS $PREV
+# this changes the filter to exclude dev5 which is not a PV
+aux hide_dev "$dev5"
+# next cmd sees different filter, ignores hints, creates new hints
+pvs
+not diff $HINTS $PREV
+# run cmds using new filter
+pvs
+cp $HINTS $PREV
+vgs
+# hints are stable once refreshed
+diff $HINTS $PREV
+# this changes the filter to include dev5
+aux unhide_dev "$dev5"
+# next cmd sees different filter, ignores hints, creates new hints
+pvs
+not diff $HINTS $PREV
+# hints are stable
+cp $HINTS $PREV
+vgs
+diff $HINTS $PREV
+
+#
+# Test that changing scan_lvs will cause hint refresh
+# 
+
+rm $HINTS $PREV
+vgs
+cp $HINTS $PREV
+# change lvm.conf
+aux lvmconf 'devices/scan_lvs = 1'
+# next cmd sees new setting, ignores hints, creates new hints
+pvs
+not diff $HINTS $PREV
+# run cmds using new filter
+pvs
+cp $HINTS $PREV
+vgs
+# hints are stable once refreshed
+diff $HINTS $PREV
+# change lvm.conf back
+aux lvmconf 'devices/scan_lvs = 0'
+# next cmd sees different scan_lvs, ignores hints, creates new hints
+pvs
+not diff $HINTS $PREV
+# hints are stable once refreshed
+cp $HINTS $PREV
+pvs
+diff $HINTS $PREV
+
+#
+# Test pvscan --cache to force hints refresh
+#
+
+# pvs (no change), pvscan (hints are new), pvs (no change)
+pvs
+cp $HINTS $PREV
+diff $HINTS $PREV
+cp $HINTS $PREV
+pvscan --cache
+not diff $HINTS $PREV
+cp $HINTS $PREV
+pvs
+diff $HINTS $PREV
+grep 'Created by pvscan' $HINTS
+# dev4 is a PV not used by a VG, dev5 is not a PV
+# using dd to copy skirts hint tracking so dev5 won't be seen
+dd if="$dev4" of="$dev5" bs=1M
+# this pvs won't see dev5
+pvs > foo
+cat foo
+grep "$dev4" foo
+not grep "$dev5" foo
+# no hints have changed after dd and pvs since dd cannot be detected
+diff $HINTS $PREV
+# force hints refresh, will see duplicate now
+pvscan --cache
+not diff $HINTS $PREV
+cat $HINTS
+pvs -a > foo
+# after force refresh, both devs (dups) appear in output
+cat foo
+grep "$dev4" foo
+grep "$dev5" foo
+# clear PV from dev5
+dd if=/dev/zero of="$dev5" bs=1M count=1
+# this pvs won't use hints because of duplicate PVs,
+# and will create new hints
+cp $HINTS $PREV
+pvs > foo
+not diff $HINTS $PREV
+grep "$dev4" foo
+not grep "$dev5" foo
+grep "$dev4" $HINTS
+not grep "$dev5" $HINTS
+
+
+#
+# Test incorrect dev-to-pvid info in hints is detected
+# dev4 is a PV not in a VG
+#
+
+pvs
+cp $HINTS tmp-old
+# this pvchange will invalidate current hints
+pvchange -u "$dev4"
+grep "# Created empty" $HINTS
+cat $NEWHINTS
+# this next pvs will create new hints with the new uuid
+pvs
+grep "$dev4" $HINTS > tmp-newuuid
+cp $HINTS tmp-new
+not diff tmp-old tmp-new
+# hints are stable
+pvs
+diff $HINTS tmp-new
+# replace the current hints with the old hints with the old uuid
+cp tmp-old $HINTS
+# this next pvs will see wrong dev-to-pvid mapping and invalidate hints
+pvs
+cat $HINTS
+cat $NEWHINTS
+# this next pvs will create new hints with the new uuid
+pvs
+cat $HINTS
+grep -f tmp-newuuid $HINTS
+rm tmp-old tmp-new tmp-newuuid
+
+
+#
+# Test incorrent pvid-to-vgname info in hints is detected
+#
+
+# this vgcreate invalidates current hints
+vgcreate $vg3 $dev4
+# this pvs creates new hints
+pvs
+cp $HINTS tmp-old
+# this vgrename will invalidate current hints
+vgrename $vg3 $vg4
+# this pvs will create new hints with the new vg name
+pvs
+cp $HINTS tmp-new
+not diff tmp-old tmp-new
+# replace the current hints with the old hints with the old vg name
+cp tmp-old $HINTS
+# this pvs will see wrong pvid-to-vgname mapping and invalidate hints
+pvs
+cat $NEWHINTS
+# this pvs will create new hints with the new vg name
+pvs
+grep $vg4 $HINTS
+
+vgremove -y $vg4
+vgremove -y $vg2
+vgremove -y $vg1
+
diff --git a/test/shell/process-each-duplicate-pvs.sh b/test/shell/process-each-duplicate-pvs.sh
index b8a8774..ffd085a 100644
--- a/test/shell/process-each-duplicate-pvs.sh
+++ b/test/shell/process-each-duplicate-pvs.sh
@@ -55,7 +55,7 @@ check pv_field "$dev2" dev_size "$SIZE2"
 
 # Copy dev1 over dev2.
 dd if="$dev1" of="$dev2" bs=1M iflag=direct oflag=direct,sync
-pvscan --cache
+#pvscan --cache
 
 # The single preferred dev is shown from 'pvs'.
 pvs -o+uuid,duplicate 2>&1 | tee out
@@ -292,7 +292,7 @@ grep "$dev3" out
 grep "$dev4" out
 
 dd if="$dev3" of="$dev4" bs=1M iflag=direct oflag=direct,sync
-pvscan --cache
+#pvscan --cache
 
 # One appears with 'pvs'
 
@@ -375,7 +375,7 @@ check pv_field "$dev4" dev_size "$SIZE4"
 
 dd if=/dev/zero of="$dev3" bs=1M oflag=direct,sync || true
 dd if=/dev/zero of="$dev4" bs=1M oflag=direct,sync || true
-pvscan --cache
+#pvscan --cache
 
 # The previous steps prevent us from nicely cleaning up
 # the vg lockspace in lvmlockd, so just restart it;
@@ -392,6 +392,9 @@ lvcreate -l1 -n $lv2 $vg2 "$dev4"
 
 dd if="$dev3" of="$dev5" bs=1M iflag=direct oflag=direct,sync
 dd if="$dev4" of="$dev6" bs=1M iflag=direct oflag=direct,sync
+# dev5/dev6 not pvs so dd'ing pv onto them causes invalid hints
+# that won't be detected, so 5/6 won't be scanned unless we
+# force hint recreation
 pvscan --cache
 
 pvs -o+uuid,duplicate 2>&1 | tee out
@@ -450,7 +453,7 @@ not grep "prefers device $dev6" warn
 
 dd if=/dev/zero of="$dev5" bs=1M oflag=direct,sync || true
 dd if=/dev/zero of="$dev6" bs=1M oflag=direct,sync || true
-pvscan --cache
+#pvscan --cache
 
 lvremove -y $vg2/$lv1
 lvremove -y $vg2/$lv2
@@ -460,7 +463,7 @@ pvremove -ff -y "$dev4"
 
 dd if=/dev/zero of="$dev3" bs=1M oflag=direct,sync || true
 dd if=/dev/zero of="$dev4" bs=1M oflag=direct,sync || true
-pvscan --cache
+#pvscan --cache
 
 # Reverse devs in the previous in case dev3/dev4 would be
 # preferred even without an active LV using them.
@@ -471,6 +474,9 @@ lvcreate -l1 -n $lv2 $vg2 "$dev6"
 
 dd if="$dev5" of="$dev3" bs=1M iflag=direct oflag=direct,sync
 dd if="$dev6" of="$dev4" bs=1M iflag=direct oflag=direct,sync
+# dev3/dev4 are not pvs (zeroed above) so dd'ing pv onto them causes
+# invalid hints that won't be detected, so 3/4 won't be scanned
+# unless we force hint recreation
 pvscan --cache
 
 pvs -o+uuid,duplicate 2>&1 | tee out
@@ -506,7 +512,7 @@ not grep "prefers device $dev4" warn
 
 dd if=/dev/zero of="$dev3" bs=1M oflag=direct,sync || true
 dd if=/dev/zero of="$dev4" bs=1M oflag=direct,sync || true
-pvscan --cache
+#pvscan --cache
 
 lvremove -y $vg2/$lv1
 lvremove -y $vg2/$lv2
diff --git a/tools/command.c b/tools/command.c
index 6931e44..bf2879f 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -136,6 +136,8 @@ static inline int configtype_arg(struct cmd_context *cmd __attribute__((unused))
 #define DISALLOW_TAG_ARGS        0x00000800
 #define GET_VGNAME_FROM_OPTIONS  0x00001000
 #define CAN_USE_ONE_SCAN	 0x00002000
+#define ALLOW_HINTS              0x00004000
+
 
 /* create foo_CMD enums for command def ID's in command-lines.in */
 
diff --git a/tools/commands.h b/tools/commands.h
index 8c653e6..83e50e7 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -35,7 +35,7 @@ xx(help,
 
 xx(fullreport,
    "Display full report",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | ALLOW_HINTS)
 
 xx(lastlog,
    "Display last command's log report",
@@ -43,7 +43,7 @@ xx(lastlog,
 
 xx(lvchange,
    "Change the attributes of logical volume(s)",
-   PERMITTED_READ_ONLY)
+   PERMITTED_READ_ONLY | ALLOW_HINTS)
 
 xx(lvconvert,
    "Change logical volume layout",
@@ -51,15 +51,15 @@ xx(lvconvert,
 
 xx(lvcreate,
    "Create a logical volume",
-   0)
+   ALLOW_HINTS)
 
 xx(lvdisplay,
    "Display information about a logical volume",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS)
 
 xx(lvextend,
    "Add space to a logical volume",
-   0)
+   ALLOW_HINTS)
 
 xx(lvmchange,
    "With the device mapper, this is obsolete and does nothing.",
@@ -83,23 +83,23 @@ xx(lvmsar,
 
 xx(lvreduce,
    "Reduce the size of a logical volume",
-   0)
+   ALLOW_HINTS)
 
 xx(lvremove,
    "Remove logical volume(s) from the system",
-   ALL_VGS_IS_DEFAULT) /* all VGs only with --select */
+   ALL_VGS_IS_DEFAULT | ALLOW_HINTS) /* all VGs only with --select */
 
 xx(lvrename,
    "Rename a logical volume",
-   0)
+   ALLOW_HINTS)
 
 xx(lvresize,
    "Resize a logical volume",
-   0)
+   ALLOW_HINTS)
 
 xx(lvs,
    "Display information about logical volumes",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS)
 
 xx(lvscan,
    "List all logical volumes in all volume groups",
@@ -127,7 +127,7 @@ xx(pvdata,
 
 xx(pvdisplay,
    "Display various attributes of physical volume(s)",
-   PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH | CAN_USE_ONE_SCAN)
+   PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS)
 
 /* ALL_VGS_IS_DEFAULT is for polldaemon to find pvmoves in-progress using process_each_vg. */
 
@@ -137,7 +137,7 @@ xx(pvmove,
 
 xx(lvpoll,
    "Continue already initiated poll operation on a logical volume",
-   0)
+   ALLOW_HINTS)
 
 xx(pvremove,
    "Remove LVM label(s) from physical volume(s)",
@@ -145,7 +145,7 @@ xx(pvremove,
 
 xx(pvs,
    "Display information about physical volumes",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH | CAN_USE_ONE_SCAN)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS)
 
 xx(pvscan,
    "List all physical volumes",
@@ -173,11 +173,11 @@ xx(vgcfgrestore,
 
 xx(vgchange,
    "Change volume group attributes",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ALLOW_HINTS)
 
 xx(vgck,
    "Check the consistency of volume group(s)",
-   ALL_VGS_IS_DEFAULT | LOCKD_VG_SH)
+   ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | ALLOW_HINTS)
 
 xx(vgconvert,
    "Change volume group metadata format",
@@ -189,7 +189,7 @@ xx(vgcreate,
 
 xx(vgdisplay,
    "Display volume group information",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS)
 
 xx(vgexport,
    "Unregister volume group(s) from the system",
@@ -228,7 +228,7 @@ xx(vgrename,
 
 xx(vgs,
    "Display information about volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS)
 
 xx(vgscan,
    "Search for all volume groups",
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 9c0476e..55a068f 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2286,6 +2286,7 @@ static void _apply_current_output_settings(struct cmd_context *cmd)
 static int _get_current_settings(struct cmd_context *cmd)
 {
 	const char *activation_mode;
+	const char *hint_mode;
 
 	_get_current_output_settings_from_args(cmd);
 
@@ -2313,6 +2314,29 @@ static int _get_current_settings(struct cmd_context *cmd)
 	if (cmd->cname->flags & CAN_USE_ONE_SCAN)
 		cmd->can_use_one_scan = 1;
 
+	cmd->scan_lvs = find_config_tree_bool(cmd, devices_scan_lvs_CFG, NULL);
+
+	/*
+	 * enable_hints is set to 1 if any commands are using hints.
+	 * use_hints is set to 1 if this command doesn't use the hints.
+	 * enable_hints=1 and use_hints=0 means that this command won't
+	 * use the hints, but it may invalidate the hints that are used
+	 * by other commands.
+	 *
+	 * enable_hints=0 means no commands are using hints, so this
+	 * command would not need to invalidate hints for other cmds.
+	 */
+	cmd->enable_hints = 1;
+
+	/* Only certain commands need to be optimized by using hints. */
+	if (cmd->cname->flags & ALLOW_HINTS)
+		cmd->use_hints = 1;
+
+	if ((hint_mode = find_config_tree_str(cmd, devices_hints_CFG, NULL))) {
+		if (!strcmp(hint_mode, "none"))
+			cmd->enable_hints = 0;
+	}
+
 	cmd->partial_activation = 0;
 	cmd->degraded_activation = 0;
 	activation_mode = find_config_tree_str(cmd, activation_mode_CFG, NULL);
@@ -2688,6 +2712,12 @@ static int _init_lvmlockd(struct cmd_context *cmd)
 	const char *lvmlockd_socket;
 	int use_lvmlockd = find_config_tree_bool(cmd, global_use_lvmlockd_CFG, NULL);
 
+	/*
+	 * Think about when/how to enable hints with lvmlockd.
+	 */
+	if (use_lvmlockd)
+		cmd->enable_hints = 0;
+
 	if (use_lvmlockd && arg_is_set(cmd, nolocking_ARG)) {
 		/* --nolocking is only allowed with vgs/lvs/pvs commands */
 		cmd->lockd_gl_disable = 1;
diff --git a/tools/pvchange.c b/tools/pvchange.c
index 8c19268..696dab4 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -252,6 +252,8 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 
 	set_pv_notify(cmd);
 
+	clear_hint_file(cmd);
+
 	ret = process_each_pv(cmd, argc, argv, NULL, 0, READ_FOR_UPDATE | READ_ALLOW_EXPORTED, handle, _pvchange_single);
 
 	if (!argc)
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 4ffb12f..c244a1f 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -148,6 +148,8 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 	cmd->lockd_gl_disable = 1;
 
+	clear_hint_file(cmd);
+
 	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;
diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index 3c97a7f..11f38eb 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -93,6 +93,13 @@ int pvdisplay(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	/*
+	 * Without -a, command only looks at PVs and can use hints,
+	 * with -a, the command looks at all (non-hinted) devices.
+	 */
+	if (arg_is_set(cmd, all_ARG))
+		cmd->use_hints = 0;
+
 	ret = process_each_pv(cmd, argc, argv, NULL,
 			      arg_is_set(cmd, all_ARG), 0,
 			      NULL, _pvdisplay_single);
diff --git a/tools/pvremove.c b/tools/pvremove.c
index 06a7e73..5f76de6 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -48,6 +48,8 @@ int pvremove(struct cmd_context *cmd, int argc, char **argv)
 	}
 	cmd->lockd_gl_disable = 1;
 
+	clear_hint_file(cmd);
+
 	/* When forcibly clearing a PV we don't care about a VG lock. */
 	if (pp.force == DONT_PROMPT_OVERRIDE)
 		cmd->lockd_vg_disable = 1;
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 3f3c745..da1e435 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -656,6 +656,15 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	 * Scan all devices when no args are given.
 	 */
 	if (!argc && !devno_args) {
+		/*
+		 * pvscan --cache removes existing hints and recreates new ones.
+		 * We begin by clearing hints at the start of the command like
+		 * vgcreate would do.  The pvscan_recreate_hints flag is used
+		 * to enable the special case hint recreation in label_scan.
+		 */
+		cmd->pvscan_recreate_hints = 1;
+		clear_hint_file(cmd);
+
 		log_verbose("pvscan all devices.");
 		_online_pvid_files_remove();
 		_online_pvscan_all_devs(cmd, NULL, NULL);
diff --git a/tools/reporter.c b/tools/reporter.c
index c321d21..ee38db3 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -1456,6 +1456,13 @@ int pvs(struct cmd_context *cmd, int argc, char **argv)
 {
 	report_type_t type;
 
+	/*
+	 * Without -a, command only looks at PVs and can use hints,
+	 * with -a, the command looks at all (non-hinted) devices.
+	 */
+	if (arg_is_set(cmd, all_ARG))
+		cmd->use_hints = 0;
+
 	if (arg_is_set(cmd, segments_ARG))
 		type = PVSEGS;
 	else
diff --git a/tools/toollib.c b/tools/toollib.c
index d8394a3..5206e26 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -15,6 +15,7 @@
 
 #include "tools.h"
 #include "lib/format_text/format-text.h"
+#include "lib/label/hints.h"
 
 #include <sys/stat.h>
 #include <signal.h>
@@ -3908,14 +3909,40 @@ static int _get_arg_devices(struct cmd_context *cmd,
 	return ret_max;
 }
 
-static int _get_all_devices(struct cmd_context *cmd, struct dm_list *all_devices)
+static int _get_all_devices(struct cmd_context *cmd,
+			    int process_all_devices,
+			    struct dm_list *all_devices)
 {
 	struct dev_iter *iter;
 	struct device *dev;
 	struct device_id_list *dil;
+	struct hint *hint;
 	int r = ECMD_FAILED;
 
-	log_debug("Getting list of all devices");
+	/*
+	 * If command is using hints and is only looking for PVs
+	 * (not all devices), then we can use only devs from hints.
+	 */
+	if (!process_all_devices && !dm_list_empty(&cmd->hints)) {
+		log_debug("Getting list of all devices from hints");
+
+		dm_list_iterate_items(hint, &cmd->hints) {
+			if (!(dev = dev_cache_get(cmd, hint->name, NULL)))
+				continue;
+
+			if (!(dil = dm_pool_alloc(cmd->mem, sizeof(*dil)))) {
+				log_error("device_id_list alloc failed.");
+				goto out;
+			}
+
+			strncpy(dil->pvid, hint->pvid, ID_LEN);
+			dil->dev = dev;
+			dm_list_add(all_devices, &dil->list);
+		}
+		return 1;
+	}
+
+	log_debug("Getting list of all devices from system");
 
 	if (!(iter = dev_iter_create(cmd->filter, 1))) {
 		log_error("dev_iter creation failed.");
@@ -4488,7 +4515,7 @@ int process_each_pv(struct cmd_context *cmd,
 	 * from all VGs are processed first, removing them from all_devices.  Then
 	 * any devs remaining in all_devices are processed.
 	 */
-	if ((ret = _get_all_devices(cmd, &all_devices)) != ECMD_PROCESSED) {
+	if ((ret = _get_all_devices(cmd, process_all_devices, &all_devices)) != ECMD_PROCESSED) {
 		ret_max = ret;
 		goto_out;
 	}
diff --git a/tools/tools.h b/tools/tools.h
index 5e0cd30..ab9503e 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -42,6 +42,7 @@
 #include "lib/commands/toolcontext.h"
 #include "toollib.h"
 #include "lib/notify/lvmnotify.h"
+#include "lib/label/hints.h"
 
 #include <ctype.h>
 #include <sys/types.h>
@@ -133,6 +134,8 @@ struct arg_value_group_list {
 #define GET_VGNAME_FROM_OPTIONS  0x00001000
 /* The data read from disk by label scan can be used for vg_read. */
 #define CAN_USE_ONE_SCAN	 0x00002000
+/* Command can use hints file */
+#define ALLOW_HINTS		 0x00004000
 
 
 void usage(const char *name);
diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index 84032f1..2302f0a 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -130,6 +130,8 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
+	clear_hint_file(cmd);
+
 	lvmcache_label_scan(cmd);
 
 	cmd->handles_unknown_segments = 1;
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 2a40bc7..c146ab7 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -64,6 +64,8 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 	cmd->lockd_gl_disable = 1;
 
+	clear_hint_file(cmd);
+
 	/* Check for old md signatures at the end of devices. */
 	cmd->use_full_md_check = 1;
 
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 5287a36..c727d75 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -166,6 +166,8 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 	cmd->lockd_gl_disable = 1;
 
+	clear_hint_file(cmd);
+
 	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index b7fae61..34c211c 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -345,6 +345,8 @@ retry_name:
 	 */
 	cmd->lockd_vg_disable = 1;
 
+	clear_hint_file(cmd);
+
 	ret = process_each_vg(cmd, 0, NULL, vp.old_vgname, NULL, READ_FOR_UPDATE | READ_ALLOW_EXPORTED, 0, handle, _vgimportclone_vg_single);
 
 	unlock_vg(cmd, NULL, vp.new_vgname);
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index f2c785b..8c8f2a2 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -210,6 +210,8 @@ int vgmerge(struct cmd_context *cmd, int argc, char **argv)
 	if (!lockd_gl(cmd, "ex", LDGL_UPDATE_NAMES))
 		return ECMD_FAILED;
 
+	clear_hint_file(cmd);
+
 	vg_name_to = skip_dev_dir(cmd, argv[0], NULL);
 	argc--;
 	argv++;
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index ce3d155..1bca33f 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -224,6 +224,8 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 	cmd->lockd_gl_disable = 1;
 
+	clear_hint_file(cmd);
+
 	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;
diff --git a/tools/vgremove.c b/tools/vgremove.c
index 5010e7d..2120858 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -101,6 +101,8 @@ int vgremove(struct cmd_context *cmd, int argc, char **argv)
 	if (!lockd_gl(cmd, "ex", LDGL_UPDATE_NAMES))
 		return ECMD_FAILED;
 
+	clear_hint_file(cmd);
+
 	/*
 	 * This is a special case: if vgremove is given a tag, it causes
 	 * process_each_vg to do lockd_gl(sh) when getting a list of all
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 5e386cc..1286ed9 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -195,6 +195,8 @@ int vgrename(struct cmd_context *cmd, int argc, char **argv)
 	if (!lockd_gl(cmd, "ex", LDGL_UPDATE_NAMES))
 		return_ECMD_FAILED;
 
+	clear_hint_file(cmd);
+
 	/*
 	 * Special case where vg_name_old may be a UUID:
 	 * If vg_name_old is a UUID, then process_each may
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index fc99d2e..87f48df 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -569,6 +569,8 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	if (!lockd_gl(cmd, "ex", LDGL_UPDATE_NAMES))
 		return_ECMD_FAILED;
 
+	clear_hint_file(cmd);
+
 	if (arg_is_set(cmd, name_ARG))
 		lv_name = arg_value(cmd, name_ARG);
 	else


