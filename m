From: David Teigland <teigland@sourceware.org>
Date: Fri, 15 Jun 2018 13:26:15 -0400
Subject: master - Add cmd arg to more functions
Message-ID: <201806151726.w5FHQFUM032597@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8eab37593eccbbb8c6d03a9bae2f6852c17a00a5
Commit:        8eab37593eccbbb8c6d03a9bae2f6852c17a00a5
Parent:        27c647d6ce707326237771d3b046b6049161fb5a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 15 11:03:55 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 15 11:03:55 2018 -0500

Add cmd arg to more functions

so that it can be used in the filter code
---
 lib/cache/lvmetad.c              |    8 ++++----
 lib/device/dev-cache.c           |   12 ++++++------
 lib/device/dev-cache.h           |   17 +++++++++--------
 lib/filters/filter-composite.c   |    8 ++++----
 lib/filters/filter-fwraid.c      |    2 +-
 lib/filters/filter-internal.c    |    2 +-
 lib/filters/filter-md.c          |   36 ++++++++++--------------------------
 lib/filters/filter-mpath.c       |    2 +-
 lib/filters/filter-partitioned.c |    2 +-
 lib/filters/filter-persistent.c  |    4 ++--
 lib/filters/filter-regex.c       |    2 +-
 lib/filters/filter-signature.c   |    2 +-
 lib/filters/filter-sysfs.c       |    2 +-
 lib/filters/filter-type.c        |    2 +-
 lib/filters/filter-usable.c      |    2 +-
 lib/label/label.c                |    8 ++++----
 lib/locking/lvmlockd.c           |    2 +-
 lib/metadata/lv_manip.c          |    2 +-
 lib/metadata/metadata.c          |    2 +-
 lib/metadata/mirror.c            |    2 +-
 tools/lvmdiskscan.c              |    8 ++++----
 tools/pvck.c                     |    2 +-
 tools/pvscan.c                   |    8 ++++----
 tools/reporter.c                 |    2 +-
 tools/toollib.c                  |   10 +++++-----
 25 files changed, 67 insertions(+), 82 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 238a7f1..a75b448 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -863,9 +863,9 @@ static int _pv_populate_lvmcache(struct cmd_context *cmd,
 		return 0;
 	}
 
-	dev = dev_cache_get_by_devt(devt, cmd->filter);
+	dev = dev_cache_get_by_devt(cmd, devt, cmd->filter);
 	if (!dev && fallback)
-		dev = dev_cache_get_by_devt(fallback, cmd->filter);
+		dev = dev_cache_get_by_devt(cmd, fallback, cmd->filter);
 
 	if (!dev) {
 		log_warn("WARNING: Device for PV %s not found or rejected by a filter.", pvid_txt);
@@ -2404,7 +2404,7 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait)
 	was_silent = silent_mode();
 	init_silent(1);
 
-	while ((dev = dev_iter_get(iter))) {
+	while ((dev = dev_iter_get(cmd, iter))) {
 		if (sigint_caught()) {
 			ret = 0;
 			stack;
@@ -2549,7 +2549,7 @@ static void _update_pv_in_udev(struct cmd_context *cmd, dev_t devt)
 #if 0
 	struct device *dev;
 
-	if (!(dev = dev_cache_get_by_devt(devt, cmd->lvmetad_filter))) {
+	if (!(dev = dev_cache_get_by_devt(cmd, devt, cmd->lvmetad_filter))) {
 		log_error("_update_pv_in_udev no dev found");
 		return;
 	}
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index d60454a..1635c99 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1504,7 +1504,7 @@ const char *dev_cache_filtered_reason(const char *name)
 	return reason;
 }
 
-struct device *dev_cache_get(const char *name, struct dev_filter *f)
+struct device *dev_cache_get(struct cmd_context *cmd, const char *name, struct dev_filter *f)
 {
 	struct stat buf;
 	struct device *d = (struct device *) dm_hash_lookup(_cache.names, name);
@@ -1544,7 +1544,7 @@ struct device *dev_cache_get(const char *name, struct dev_filter *f)
 		return d;
 
 	if (f && !(d->flags & DEV_REGULAR)) {
-		ret = f->passes_filter(f, d);
+		ret = f->passes_filter(cmd, f, d);
 
 		if (ret == -EAGAIN) {
 			log_debug_devs("get device by name defer filter %s", dev_name(d));
@@ -1576,7 +1576,7 @@ static struct device *_dev_cache_seek_devt(dev_t dev)
  * TODO This is very inefficient. We probably want a hash table indexed by
  * major:minor for keys to speed up these lookups.
  */
-struct device *dev_cache_get_by_devt(dev_t dev, struct dev_filter *f)
+struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t dev, struct dev_filter *f)
 {
 	char path[PATH_MAX];
 	const char *sysfs_dir;
@@ -1617,7 +1617,7 @@ struct device *dev_cache_get_by_devt(dev_t dev, struct dev_filter *f)
 	if (!f)
 		return d;
 
-	ret = f->passes_filter(f, d);
+	ret = f->passes_filter(cmd, f, d);
 
 	if (ret == -EAGAIN) {
 		log_debug_devs("get device by number defer filter %s", dev_name(d));
@@ -1662,7 +1662,7 @@ static struct device *_iter_next(struct dev_iter *iter)
 	return d;
 }
 
-struct device *dev_iter_get(struct dev_iter *iter)
+struct device *dev_iter_get(struct cmd_context *cmd, struct dev_iter *iter)
 {
 	struct dev_filter *f;
 	int ret;
@@ -1674,7 +1674,7 @@ struct device *dev_iter_get(struct dev_iter *iter)
 		f = iter->filter;
 
 		if (f && !(d->flags & DEV_REGULAR)) {
-			ret = f->passes_filter(f, d);
+			ret = f->passes_filter(cmd, f, d);
 
 			if (ret == -EAGAIN) {
 				log_debug_devs("get device by iter defer filter %s", dev_name(d));
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index c56ff50..6386ba9 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -19,14 +19,15 @@
 #include "lib/device/device.h"
 #include "lib/misc/lvm-wrappers.h"
 
+struct cmd_context;
+
 /*
  * predicate for devices.
  */
 struct dev_filter {
-	int (*passes_filter) (struct dev_filter * f, struct device * dev);
-	void (*destroy) (struct dev_filter * f);
-	void (*wipe) (struct dev_filter * f);
-	int (*dump) (struct dev_filter * f, int merge_existing);
+	int (*passes_filter) (struct cmd_context *cmd, struct dev_filter *f, struct device *dev);
+	void (*destroy) (struct dev_filter *f);
+	void (*wipe) (struct dev_filter *f);
 	void *private;
 	unsigned use_count;
 };
@@ -38,9 +39,9 @@ struct dm_list *dev_cache_get_dev_list_for_lvid(const char *lvid);
 /*
  * The global device cache.
  */
-struct cmd_context;
 int dev_cache_init(struct cmd_context *cmd);
 int dev_cache_exit(void);
+
 /*
  * Returns number of open devices.
  */
@@ -52,11 +53,11 @@ int dev_cache_has_scanned(void);
 int dev_cache_add_dir(const char *path);
 int dev_cache_add_loopfile(const char *path);
 __attribute__((nonnull(1)))
-struct device *dev_cache_get(const char *name, struct dev_filter *f);
+struct device *dev_cache_get(struct cmd_context *cmd, const char *name, struct dev_filter *f);
 const char *dev_cache_filtered_reason(const char *name);
 
 // TODO
-struct device *dev_cache_get_by_devt(dev_t device, struct dev_filter *f);
+struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t device, struct dev_filter *f);
 
 void dev_set_preferred_name(struct dm_str_list *sl, struct device *dev);
 
@@ -66,7 +67,7 @@ void dev_set_preferred_name(struct dm_str_list *sl, struct device *dev);
 struct dev_iter;
 struct dev_iter *dev_iter_create(struct dev_filter *f, int unused);
 void dev_iter_destroy(struct dev_iter *iter);
-struct device *dev_iter_get(struct dev_iter *iter);
+struct device *dev_iter_get(struct cmd_context *cmd, struct dev_iter *iter);
 
 void dev_reset_error_count(struct cmd_context *cmd);
 
diff --git a/lib/filters/filter-composite.c b/lib/filters/filter-composite.c
index ba837af..a9374ab 100644
--- a/lib/filters/filter-composite.c
+++ b/lib/filters/filter-composite.c
@@ -18,13 +18,13 @@
 #include "lib/filters/filter.h"
 #include "lib/device/device.h"
 
-static int _and_p(struct dev_filter *f, struct device *dev)
+static int _and_p(struct cmd_context *cmd, struct dev_filter *f, struct device *dev)
 {
 	struct dev_filter **filters;
 	int ret;
 
 	for (filters = (struct dev_filter **) f->private; *filters; ++filters) {
-		ret = (*filters)->passes_filter(*filters, dev);
+		ret = (*filters)->passes_filter(cmd, *filters, dev);
 
 		if (!ret)
 			return 0;	/* No 'stack': a filter, not an error. */
@@ -33,12 +33,12 @@ static int _and_p(struct dev_filter *f, struct device *dev)
 	return 1;
 }
 
-static int _and_p_with_dev_ext_info(struct dev_filter *f, struct device *dev)
+static int _and_p_with_dev_ext_info(struct cmd_context *cmd, struct dev_filter *f, struct device *dev)
 {
 	int r;
 
 	dev_ext_enable(dev, external_device_info_source());
-	r = _and_p(f, dev);
+	r = _and_p(cmd, f, dev);
 	dev_ext_disable(dev);
 
 	return r;
diff --git a/lib/filters/filter-fwraid.c b/lib/filters/filter-fwraid.c
index 03c63b3..6f47692 100644
--- a/lib/filters/filter-fwraid.c
+++ b/lib/filters/filter-fwraid.c
@@ -64,7 +64,7 @@ static int _dev_is_fwraid(struct device *dev)
 
 #define MSG_SKIPPING "%s: Skipping firmware RAID component device"
 
-static int _ignore_fwraid(struct dev_filter *f __attribute__((unused)),
+static int _ignore_fwraid(struct cmd_context *cmd, struct dev_filter *f __attribute__((unused)),
 			   struct device *dev)
 {
 	int ret;
diff --git a/lib/filters/filter-internal.c b/lib/filters/filter-internal.c
index 85e04d4..8cc0011 100644
--- a/lib/filters/filter-internal.c
+++ b/lib/filters/filter-internal.c
@@ -37,7 +37,7 @@ void internal_filter_clear(void)
 	dm_list_init(&_allow_devs);
 }
 
-static int _passes_internal(struct dev_filter *f __attribute__((unused)),
+static int _passes_internal(struct cmd_context *cmd, struct dev_filter *f __attribute__((unused)),
 			    struct device *dev)
 {
 	struct device_list *devl;
diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index 4fcbca9..95e0aad 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -70,6 +70,13 @@
  */
 
 /*
+ * FIXME: for commands that want a full md check (pvcreate, vgcreate,
+ * vgextend), we do an extra read at the end of every device that the
+ * filter looks at.  This isn't necessary; we only need to do the full
+ * md check on the PVs that these commands are trying to use.
+ */
+
+/*
  * Returns 0 if:
  * the device is an md component and it should be ignored.
  *
@@ -81,7 +88,7 @@
  * that will not pass.
  */
 
-static int _passes_md_filter(struct device *dev, int full)
+static int _passes_md_filter(struct cmd_context *cmd, struct dev_filter *f __attribute__((unused)), struct device *dev)
 {
 	int ret;
 
@@ -92,7 +99,7 @@ static int _passes_md_filter(struct device *dev, int full)
 	if (!md_filtering())
 		return 1;
 
-	ret = dev_is_md(dev, NULL, full);
+	ret = dev_is_md(dev, NULL, cmd->use_full_md_check);
 
 	if (ret == -EAGAIN) {
 		/* let pass, call again after scan */
@@ -122,18 +129,6 @@ static int _passes_md_filter(struct device *dev, int full)
 	return 1;
 }
 
-static int _passes_md_filter_lite(struct dev_filter *f __attribute__((unused)),
-				  struct device *dev)
-{
-	return _passes_md_filter(dev, 0);
-}
-
-static int _passes_md_filter_full(struct dev_filter *f __attribute__((unused)),
-				  struct device *dev)
-{
-	return _passes_md_filter(dev, 1);
-}
-
 static void _destroy(struct dev_filter *f)
 {
 	if (f->use_count)
@@ -151,18 +146,7 @@ struct dev_filter *md_filter_create(struct cmd_context *cmd, struct dev_types *d
 		return NULL;
 	}
 
-	/*
-	 * FIXME: for commands that want a full md check (pvcreate, vgcreate,
-	 * vgextend), we do an extra read at the end of every device that the
-	 * filter looks at.  This isn't necessary; we only need to do the full
-	 * md check on the PVs that these commands are trying to use.
-	 */
-
-	if (cmd->use_full_md_check)
-		f->passes_filter = _passes_md_filter_full;
-	else
-		f->passes_filter = _passes_md_filter_lite;
-
+	f->passes_filter = _passes_md_filter;
 	f->destroy = _destroy;
 	f->use_count = 0;
 	f->private = dt;
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 785b518..bcd1e52 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -247,7 +247,7 @@ static int _dev_is_mpath(struct dev_filter *f, struct device *dev)
 
 #define MSG_SKIPPING "%s: Skipping mpath component device"
 
-static int _ignore_mpath(struct dev_filter *f, struct device *dev)
+static int _ignore_mpath(struct cmd_context *cmd, struct dev_filter *f, struct device *dev)
 {
 	if (_dev_is_mpath(f, dev) == 1) {
 		if (dev->ext.src == DEV_EXT_NONE)
diff --git a/lib/filters/filter-partitioned.c b/lib/filters/filter-partitioned.c
index 34151fd..6418cdf 100644
--- a/lib/filters/filter-partitioned.c
+++ b/lib/filters/filter-partitioned.c
@@ -19,7 +19,7 @@
 
 #define MSG_SKIPPING "%s: Skipping: Partition table signature found"
 
-static int _passes_partitioned_filter(struct dev_filter *f, struct device *dev)
+static int _passes_partitioned_filter(struct cmd_context *cmd, struct dev_filter *f, struct device *dev)
 {
 	struct dev_types *dt = (struct dev_types *) f->private;
 	int ret;
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 9ee3957..1782bfa 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -68,7 +68,7 @@ static void _persistent_filter_wipe(struct dev_filter *f)
 	dm_hash_wipe(pf->devices);
 }
 
-static int _lookup_p(struct dev_filter *f, struct device *dev)
+static int _lookup_p(struct cmd_context *cmd, struct dev_filter *f, struct device *dev)
 {
 	struct pfilter *pf = (struct pfilter *) f->private;
 	void *l;
@@ -99,7 +99,7 @@ static int _lookup_p(struct dev_filter *f, struct device *dev)
 	if (!l) {
 		dev->flags &= ~DEV_FILTER_AFTER_SCAN;
 
-		pass = pf->real->passes_filter(pf->real, dev);
+		pass = pf->real->passes_filter(cmd, pf->real, dev);
 
 		if (!pass) {
 			/*
diff --git a/lib/filters/filter-regex.c b/lib/filters/filter-regex.c
index c642ec4..1a8e8a2 100644
--- a/lib/filters/filter-regex.c
+++ b/lib/filters/filter-regex.c
@@ -145,7 +145,7 @@ static int _build_matcher(struct rfilter *rf, const struct dm_config_value *val)
 	return r;
 }
 
-static int _accept_p(struct dev_filter *f, struct device *dev)
+static int _accept_p(struct cmd_context *cmd, struct dev_filter *f, struct device *dev)
 {
 	int m, first = 1, rejected = 0;
 	struct rfilter *rf = (struct rfilter *) f->private;
diff --git a/lib/filters/filter-signature.c b/lib/filters/filter-signature.c
index d4b6ea3..5c5796f 100644
--- a/lib/filters/filter-signature.c
+++ b/lib/filters/filter-signature.c
@@ -21,7 +21,7 @@
 
 #define BUFSIZE 4096
 
-static int _ignore_signature(struct dev_filter *f __attribute__((unused)),
+static int _ignore_signature(struct cmd_context *cmd, struct dev_filter *f __attribute__((unused)),
 		      struct device *dev)
 {
 	char buf[BUFSIZE];
diff --git a/lib/filters/filter-sysfs.c b/lib/filters/filter-sysfs.c
index 5b54312..c77c4a6 100644
--- a/lib/filters/filter-sysfs.c
+++ b/lib/filters/filter-sysfs.c
@@ -260,7 +260,7 @@ static int _init_devs(struct dev_set *ds)
 }
 
 
-static int _accept_p(struct dev_filter *f, struct device *dev)
+static int _accept_p(struct cmd_context *cmd, struct dev_filter *f, struct device *dev)
 {
 	struct dev_set *ds = (struct dev_set *) f->private;
 
diff --git a/lib/filters/filter-type.c b/lib/filters/filter-type.c
index 63d7c70..3b0a644 100644
--- a/lib/filters/filter-type.c
+++ b/lib/filters/filter-type.c
@@ -17,7 +17,7 @@
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
 
-static int _passes_lvm_type_device_filter(struct dev_filter *f, struct device *dev)
+static int _passes_lvm_type_device_filter(struct cmd_context *cmd, struct dev_filter *f, struct device *dev)
 {
 	struct dev_types *dt = (struct dev_types *) f->private;
 	const char *name = dev_name(dev);
diff --git a/lib/filters/filter-usable.c b/lib/filters/filter-usable.c
index 498b90c..ab5c02f 100644
--- a/lib/filters/filter-usable.c
+++ b/lib/filters/filter-usable.c
@@ -100,7 +100,7 @@ static int _check_pv_min_size(struct device *dev)
 	return 0;
 }
 
-static int _passes_usable_filter(struct dev_filter *f, struct device *dev)
+static int _passes_usable_filter(struct cmd_context *cmd, struct dev_filter *f, struct device *dev)
 {
 	filter_mode_t mode = *((filter_mode_t *) f->private);
 	struct dev_usable_check_params ucp = {0};
diff --git a/lib/label/label.c b/lib/label/label.c
index 373df29..de5aa88 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -366,7 +366,7 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 
 		log_debug_devs("Scan filtering %s", dev_name(dev));
 		
-		pass = f->passes_filter(f, dev);
+		pass = f->passes_filter(cmd, f, dev);
 
 		if ((pass == -EAGAIN) || (dev->flags & DEV_FILTER_AFTER_SCAN)) {
 			/* Shouldn't happen */
@@ -833,7 +833,7 @@ int label_scan(struct cmd_context *cmd)
 		return 0;
 	}
 
-	while ((dev = dev_iter_get(iter))) {
+	while ((dev = dev_iter_get(cmd, iter))) {
 		if (!(devl = zalloc(sizeof(*devl))))
 			continue;
 		devl->dev = dev;
@@ -946,7 +946,7 @@ void label_scan_invalidate_lv(struct cmd_context *cmd, struct logical_volume *lv
 
 	lv_info(cmd, lv, 0, &lvinfo, 0, 0);
 	devt = MKDEV(lvinfo.major, lvinfo.minor);
-	if ((dev = dev_cache_get_by_devt(devt, NULL)))
+	if ((dev = dev_cache_get_by_devt(cmd, devt, NULL)))
 		label_scan_invalidate(dev);
 }
 
@@ -963,7 +963,7 @@ void label_scan_drop(struct cmd_context *cmd)
 	if (!(iter = dev_iter_create(NULL, 0)))
 		return;
 
-	while ((dev = dev_iter_get(iter))) {
+	while ((dev = dev_iter_get(cmd, iter))) {
 		if (_in_bcache(dev))
 			_scan_dev_close(dev);
 	}
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 21a9696..a277246 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -398,7 +398,7 @@ static int _extend_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
 
 	log_print("Zeroing %u MiB on extended internal lvmlock LV...", extend_mb);
 
-	if (!(dev = dev_cache_get(path, NULL))) {
+	if (!(dev = dev_cache_get(cmd, path, NULL))) {
 		log_error("Extend sanlock LV %s cannot find device.", display_lvname(lv));
 		return 0;
 	}
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b2eba30..27cd2c1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7145,7 +7145,7 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 		return 0;
 	}
 
-	if (!(dev = dev_cache_get(name, NULL))) {
+	if (!(dev = dev_cache_get(lv->vg->cmd, name, NULL))) {
 		log_error("%s: not found: device not cleared", name);
 		return 0;
 	}
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 113c87c..34b1ec7 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1510,7 +1510,7 @@ struct pv_list *find_pv_in_vg(const struct volume_group *vg,
 			       const char *pv_name)
 {
 	struct pv_list *pvl;
-	struct device *dev = dev_cache_get(pv_name, vg->cmd->filter);
+	struct device *dev = dev_cache_get(vg->cmd, pv_name, vg->cmd->filter);
 
 	/*
 	 * If the device does not exist or is filtered out, don't bother trying
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 8de1440..11f2a8f 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -292,7 +292,7 @@ static int _write_log_header(struct cmd_context *cmd, struct logical_volume *lv)
 
 	log_verbose("Writing log header for LV %s to device %s.", display_lvname(lv), name);
 
-	if (!(dev = dev_cache_get(name, NULL))) {
+	if (!(dev = dev_cache_get(cmd, name, NULL))) {
 		log_error("%s: not found: log header not written.", name);
 		return 0;
 	}
diff --git a/tools/lvmdiskscan.c b/tools/lvmdiskscan.c
index 772694c..0b97eba 100644
--- a/tools/lvmdiskscan.c
+++ b/tools/lvmdiskscan.c
@@ -27,7 +27,7 @@ int pv_disks_found;
 int pv_parts_found;
 int max_len;
 
-static int _get_max_dev_name_len(struct dev_filter *filter)
+static int _get_max_dev_name_len(struct cmd_context *cmd, struct dev_filter *filter)
 {
 	int len = 0;
 	int maxlen = 0;
@@ -40,7 +40,7 @@ static int _get_max_dev_name_len(struct dev_filter *filter)
 	}
 
 	/* Do scan */
-	for (dev = dev_iter_get(iter); dev; dev = dev_iter_get(iter)) {
+	for (dev = dev_iter_get(cmd, iter); dev; dev = dev_iter_get(cmd, iter)) {
 		len = strlen(dev_name(dev));
 		if (len > maxlen)
 			maxlen = len;
@@ -100,14 +100,14 @@ int lvmdiskscan(struct cmd_context *cmd, int argc __attribute__((unused)),
 	/* Call before using dev_iter which uses filters which want bcache data. */
 	label_scan(cmd);
 
-	max_len = _get_max_dev_name_len(cmd->full_filter);
+	max_len = _get_max_dev_name_len(cmd, cmd->full_filter);
 
 	if (!(iter = dev_iter_create(cmd->full_filter, 0))) {
 		log_error("dev_iter_create failed");
 		return ECMD_FAILED;
 	}
 
-	for (dev = dev_iter_get(iter); dev; dev = dev_iter_get(iter)) {
+	for (dev = dev_iter_get(cmd, iter); dev; dev = dev_iter_get(cmd, iter)) {
 		if (lvmcache_has_dev_info(dev)) {
 			if (!dev_get_size(dev, &size)) {
 				log_error("Couldn't get size of \"%s\"",
diff --git a/tools/pvck.c b/tools/pvck.c
index 027df6d..ce74036 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -35,7 +35,7 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 
 		pv_name = argv[i];
 
-		dev = dev_cache_get(pv_name, cmd->filter);
+		dev = dev_cache_get(cmd, pv_name, cmd->filter);
 
 		if (!dev) {
 			log_error("Device %s %s.", pv_name, dev_cache_filtered_reason(pv_name));
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 61530ee..17fc1a6 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -438,10 +438,10 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 	while (argc--) {
 		pv_name = *argv++;
 		if (pv_name[0] == '/') {
-			if (!(dev = dev_cache_get(pv_name, cmd->lvmetad_filter))) {
+			if (!(dev = dev_cache_get(cmd, pv_name, cmd->lvmetad_filter))) {
 				/* Remove device path from lvmetad. */
 				log_debug("Removing dev %s from lvmetad cache.", pv_name);
-				if ((dev = dev_cache_get(pv_name, NULL))) {
+				if ((dev = dev_cache_get(cmd, pv_name, NULL))) {
 					if (!_lvmetad_clear_dev(dev->dev, MAJOR(dev->dev), MINOR(dev->dev)))
 						remove_errors++;
 				} else {
@@ -468,7 +468,7 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 			}
 			devno = MKDEV((dev_t)major, (dev_t)minor);
 
-			if (!(dev = dev_cache_get_by_devt(devno, cmd->lvmetad_filter))) {
+			if (!(dev = dev_cache_get_by_devt(cmd, devno, cmd->lvmetad_filter))) {
 				/* Remove major:minor from lvmetad. */
 				log_debug("Removing dev %d:%d from lvmetad cache.", major, minor);
 				if (!_lvmetad_clear_dev(devno, major, minor))
@@ -531,7 +531,7 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 
 		devno = MKDEV((dev_t)major, (dev_t)minor);
 
-		if (!(dev = dev_cache_get_by_devt(devno, cmd->lvmetad_filter))) {
+		if (!(dev = dev_cache_get_by_devt(cmd, devno, cmd->lvmetad_filter))) {
 			/* Remove major:minor from lvmetad. */
 			log_debug("Removing dev %d:%d from lvmetad cache.", major, minor);
 			if (!_lvmetad_clear_dev(devno, major, minor))
diff --git a/tools/reporter.c b/tools/reporter.c
index a7f1f9b..faaff37 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -719,7 +719,7 @@ static void _check_pv_list(struct cmd_context *cmd, struct report_args *args, st
 
 	if (single_args->args_are_pvs && args->argc) {
 		for (i = 0; i < args->argc; i++) {
-			if (!rescan_done && !dev_cache_get(args->argv[i], cmd->full_filter)) {
+			if (!rescan_done && !dev_cache_get(cmd, args->argv[i], cmd->full_filter)) {
 				cmd->filter->wipe(cmd->filter);
 				/* FIXME scan only one device */
 				lvmcache_label_scan(cmd);
diff --git a/tools/toollib.c b/tools/toollib.c
index f64bd58..c81d1c2 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1470,7 +1470,7 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 
 	if (argc) {
 		for (; opt < argc; opt++) {
-			if (!(dev = dev_cache_get(argv[opt], cmd->full_filter))) {
+			if (!(dev = dev_cache_get(cmd, argv[opt], cmd->full_filter))) {
 				log_error("Failed to find device "
 					  "\"%s\".", argv[opt]);
 				ret_max = ECMD_FAILED;
@@ -1547,7 +1547,7 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 		goto out;
 	}
 
-	while ((dev = dev_iter_get(iter)))
+	while ((dev = dev_iter_get(cmd, iter)))
 	{
 		if (!(label = lvmcache_get_dev_label(dev)))
 			continue;
@@ -3870,7 +3870,7 @@ static int _get_arg_devices(struct cmd_context *cmd,
 			return ECMD_FAILED;
 		}
 
-		if (!(dil->dev = dev_cache_get(sl->str, cmd->filter))) {
+		if (!(dil->dev = dev_cache_get(cmd, sl->str, cmd->filter))) {
 			log_error("Failed to find device for physical volume \"%s\".", sl->str);
 			ret_max = ECMD_FAILED;
 		} else {
@@ -3898,7 +3898,7 @@ static int _get_all_devices(struct cmd_context *cmd, struct dm_list *all_devices
 		return ECMD_FAILED;
 	}
 
-	while ((dev = dev_iter_get(iter))) {
+	while ((dev = dev_iter_get(cmd, iter))) {
 		if (!(dil = dm_pool_alloc(cmd->mem, sizeof(*dil)))) {
 			log_error("device_id_list alloc failed.");
 			goto out;
@@ -5398,7 +5398,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	 * Translate arg names into struct device's.
 	 */
 	dm_list_iterate_items(pd, &pp->arg_devices)
-		pd->dev = dev_cache_get(pd->name, cmd->full_filter);
+		pd->dev = dev_cache_get(cmd, pd->name, cmd->full_filter);
 
 	/*
 	 * Use process_each_pv to search all existing PVs and devices.


