From: David Teigland <teigland@sourceware.org>
Date: Thu,  1 Oct 2020 17:04:18 +0000 (GMT)
Subject: master - devices: support printing the filter that rejects a device
Message-ID: <20201001170418.686FE3857C54@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=450f272b31ef95bd7cb61812d9ef0525c7c1c341
Commit:        450f272b31ef95bd7cb61812d9ef0525c7c1c341
Parent:        ff3945777ba6cb093174b99a9870df2494f4c29b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jul 20 12:48:36 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 1 12:00:09 2020 -0500

devices: support printing the filter that rejects a device

Use of this new message function needs to be added
to various commands to improve the output.
---
 lib/cache/lvmcache.c             | 48 ++++++++++++++++++++++++++++++++++++++++
 lib/cache/lvmcache.h             |  3 +++
 lib/device/dev-cache.c           | 13 ++---------
 lib/device/dev-cache.h           |  3 ++-
 lib/device/device.h              |  1 +
 lib/filters/filter-fwraid.c      |  4 ++++
 lib/filters/filter-internal.c    |  3 +++
 lib/filters/filter-md.c          |  4 ++++
 lib/filters/filter-mpath.c       |  3 +++
 lib/filters/filter-partitioned.c |  3 +++
 lib/filters/filter-regex.c       |  6 ++++-
 lib/filters/filter-signature.c   |  5 +++++
 lib/filters/filter-sysfs.c       |  3 +++
 lib/filters/filter-type.c        |  3 +++
 lib/filters/filter-usable.c      |  9 +++++++-
 lib/filters/filter.h             | 12 ++++++++++
 tools/pvck.c                     |  6 ++---
 17 files changed, 112 insertions(+), 17 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 9716eccaf..a2fa0e3fb 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -23,6 +23,7 @@
 #include "lib/mm/memlock.h"
 #include "lib/format_text/format-text.h"
 #include "lib/config/config.h"
+#include "lib/filters/filter.h"
 
 /* One per device */
 struct lvmcache_info {
@@ -2683,3 +2684,50 @@ bool lvmcache_is_outdated_dev(struct cmd_context *cmd,
 
 	return false;
 }
+
+const char *dev_filtered_reason(struct device *dev)
+{
+	if (dev->filtered_flags & DEV_FILTERED_REGEX)
+		return "device is rejected by filter config";
+	if (dev->filtered_flags & DEV_FILTERED_INTERNAL)
+		return "device is restricted internally";
+	if (dev->filtered_flags & DEV_FILTERED_MD_COMPONENT)
+		return "device is an md component";
+	if (dev->filtered_flags & DEV_FILTERED_MPATH_COMPONENT)
+		return "device is a multipath component";
+	if (dev->filtered_flags & DEV_FILTERED_PARTITIONED)
+		return "device is partitioned";
+	if (dev->filtered_flags & DEV_FILTERED_SIGNATURE)
+		return "device has a signature";
+	if (dev->filtered_flags & DEV_FILTERED_SYSFS)
+		return "device is missing sysfs info";
+	if (dev->filtered_flags & DEV_FILTERED_DEVTYPE)
+		return "device type is unknown";
+	if (dev->filtered_flags & DEV_FILTERED_MINSIZE)
+		return "device is too small (pv_min_size)";
+	if (dev->filtered_flags & DEV_FILTERED_UNUSABLE)
+		return "device is not in a usable state";
+
+	/* flag has not been added here */
+	if (dev->filtered_flags)
+		return "device is filtered";
+
+	return "device cannot be used";
+}
+
+const char *devname_error_reason(const char *devname)
+{
+	struct device *dev;
+
+	if ((dev = dev_hash_get(devname))) {
+		if (dev->filtered_flags)
+			return dev_filtered_reason(dev);
+		if (lvmcache_dev_is_unused_duplicate(dev))
+			return "device is a duplicate";
+		/* Avoid this case by adding by adding other more descriptive checks above. */
+		return "device cannot be used";
+	}
+
+	return "device not found";
+}
+
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 1ee99b534..7a718cad8 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -217,4 +217,7 @@ void lvmcache_get_mdas(struct cmd_context *cmd,
                        const char *vgname, const char *vgid,
                        struct dm_list *mda_list);
 
+const char *dev_filtered_reason(struct device *dev);
+const char *devname_error_reason(const char *devname);
+
 #endif
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 84d65c4db..d5f18ff45 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1423,17 +1423,9 @@ const char *dev_name_confirmed(struct device *dev, int quiet)
 	return dev_name(dev);
 }
 
-/* Provide a custom reason when a device is ignored */
-const char *dev_cache_filtered_reason(const char *name)
+struct device *dev_hash_get(const char *name)
 {
-	const char *reason = "not found";
-	struct device *d = (struct device *) dm_hash_lookup(_cache.names, name);
-
-	if (d)
-		/* FIXME Record which filter caused the exclusion */
-		reason = "excluded by a filter";
-
-	return reason;
+	return (struct device *) dm_hash_lookup(_cache.names, name);
 }
 
 struct device *dev_cache_get(struct cmd_context *cmd, const char *name, struct dev_filter *f)
@@ -1657,4 +1649,3 @@ bool dev_cache_has_md_with_end_superblock(struct dev_types *dt)
 
 	return false;
 }
-
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 46c86c27a..533e4561d 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -54,10 +54,11 @@ int dev_cache_has_scanned(void);
 
 int dev_cache_add_dir(const char *path);
 struct device *dev_cache_get(struct cmd_context *cmd, const char *name, struct dev_filter *f);
-const char *dev_cache_filtered_reason(const char *name);
 
 struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t device, struct dev_filter *f, int *filtered);
 
+struct device *dev_hash_get(const char *name);
+
 void dev_set_preferred_name(struct dm_str_list *sl, struct device *dev);
 
 /*
diff --git a/lib/device/device.h b/lib/device/device.h
index 2706f28e1..a58bff8e3 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -73,6 +73,7 @@ struct device {
 	int bcache_fd;
 	int bcache_di;
 	uint32_t flags;
+	uint32_t filtered_flags;
 	unsigned size_seqno;
 	uint64_t size;
 	uint64_t end;
diff --git a/lib/filters/filter-fwraid.c b/lib/filters/filter-fwraid.c
index 992eba8b8..f82f87397 100644
--- a/lib/filters/filter-fwraid.c
+++ b/lib/filters/filter-fwraid.c
@@ -69,6 +69,8 @@ static int _ignore_fwraid(struct cmd_context *cmd, struct dev_filter *f __attrib
 {
 	int ret;
 
+	dev->filtered_flags &= ~DEV_FILTERED_FWRAID;
+
 	if (!fwraid_filtering())
 		return 1;
 
@@ -80,12 +82,14 @@ static int _ignore_fwraid(struct cmd_context *cmd, struct dev_filter *f __attrib
 		else
 			log_debug_devs(MSG_SKIPPING " [%s:%p]", dev_name(dev),
 					dev_ext_name(dev), dev->ext.handle);
+		dev->filtered_flags |= DEV_FILTERED_FWRAID;
 		return 0;
 	}
 
 	if (ret < 0) {
 		log_debug_devs("%s: Skipping: error in firmware RAID component detection",
 			       dev_name(dev));
+		dev->filtered_flags |= DEV_FILTERED_FWRAID;
 		return 0;
 	}
 
diff --git a/lib/filters/filter-internal.c b/lib/filters/filter-internal.c
index c10e8105f..a49c07e53 100644
--- a/lib/filters/filter-internal.c
+++ b/lib/filters/filter-internal.c
@@ -42,6 +42,8 @@ static int _passes_internal(struct cmd_context *cmd, struct dev_filter *f __attr
 {
 	struct device_list *devl;
 
+	dev->filtered_flags &= ~DEV_FILTERED_INTERNAL;
+
 	if (!internal_filtering())
 		return 1;
 	
@@ -50,6 +52,7 @@ static int _passes_internal(struct cmd_context *cmd, struct dev_filter *f __attr
 			return 1;
 	}
 	
+	dev->filtered_flags |= DEV_FILTERED_INTERNAL;
 	log_debug_devs("%s: Skipping for internal filtering.", dev_name(dev));
 	return 0;
 }
diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index 28903be3f..b530e407d 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -86,6 +86,8 @@ static int _passes_md_filter(struct cmd_context *cmd, struct dev_filter *f __att
 {
 	int ret;
 
+	dev->filtered_flags &= ~DEV_FILTERED_MD_COMPONENT;
+
 	/*
 	 * When md_component_dectection=0, don't even try to skip md
 	 * components.
@@ -112,12 +114,14 @@ static int _passes_md_filter(struct cmd_context *cmd, struct dev_filter *f __att
 		else
 			log_debug_devs(MSG_SKIPPING " [%s:%p]", dev_name(dev),
 					dev_ext_name(dev), dev->ext.handle);
+		dev->filtered_flags |= DEV_FILTERED_MD_COMPONENT;
 		return 0;
 	}
 
 	if (ret < 0) {
 		log_debug_devs("%s: Skipping: error in md component detection",
 			       dev_name(dev));
+		dev->filtered_flags |= DEV_FILTERED_MD_COMPONENT;
 		return 0;
 	}
 
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 53a767c5e..85d1625f6 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -274,12 +274,15 @@ static int _dev_is_mpath(struct dev_filter *f, struct device *dev)
 
 static int _ignore_mpath(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
 {
+	dev->filtered_flags &= ~DEV_FILTERED_MPATH_COMPONENT;
+
 	if (_dev_is_mpath(f, dev) == 1) {
 		if (dev->ext.src == DEV_EXT_NONE)
 			log_debug_devs(MSG_SKIPPING, dev_name(dev));
 		else
 			log_debug_devs(MSG_SKIPPING " [%s:%p]", dev_name(dev),
 					dev_ext_name(dev), dev->ext.handle);
+		dev->filtered_flags |= DEV_FILTERED_MPATH_COMPONENT;
 		return 0;
 	}
 
diff --git a/lib/filters/filter-partitioned.c b/lib/filters/filter-partitioned.c
index 1a700543c..22194f81c 100644
--- a/lib/filters/filter-partitioned.c
+++ b/lib/filters/filter-partitioned.c
@@ -24,6 +24,8 @@ static int _passes_partitioned_filter(struct cmd_context *cmd, struct dev_filter
 	struct dev_types *dt = (struct dev_types *) f->private;
 	int ret;
 
+	dev->filtered_flags &= ~DEV_FILTERED_PARTITIONED;
+
 	ret = dev_is_partitioned(dt, dev);
 
 	if (ret == -EAGAIN) {
@@ -39,6 +41,7 @@ static int _passes_partitioned_filter(struct cmd_context *cmd, struct dev_filter
 		else
 			log_debug_devs(MSG_SKIPPING " [%s:%p]", dev_name(dev),
 					dev_ext_name(dev), dev->ext.handle);
+		dev->filtered_flags |= DEV_FILTERED_PARTITIONED;
 		return 0;
 	}
 
diff --git a/lib/filters/filter-regex.c b/lib/filters/filter-regex.c
index e439b36b5..7575981af 100644
--- a/lib/filters/filter-regex.c
+++ b/lib/filters/filter-regex.c
@@ -151,6 +151,8 @@ static int _accept_p(struct cmd_context *cmd, struct dev_filter *f, struct devic
 	struct rfilter *rf = (struct rfilter *) f->private;
 	struct dm_str_list *sl;
 
+	dev->filtered_flags &= ~DEV_FILTERED_REGEX;
+
 	dm_list_iterate_items(sl, &dev->aliases) {
 		m = dm_regex_match(rf->engine, sl->str);
 
@@ -168,8 +170,10 @@ static int _accept_p(struct cmd_context *cmd, struct dev_filter *f, struct devic
 		first = 0;
 	}
 
-	if (rejected)
+	if (rejected) {
+		dev->filtered_flags |= DEV_FILTERED_REGEX;
 		log_debug_devs("%s: Skipping (regex)", dev_name(dev));
+	}
 
 	/*
 	 * pass everything that doesn't match
diff --git a/lib/filters/filter-signature.c b/lib/filters/filter-signature.c
index 6a81203a9..f32bb2450 100644
--- a/lib/filters/filter-signature.c
+++ b/lib/filters/filter-signature.c
@@ -27,6 +27,8 @@ static int _ignore_signature(struct cmd_context *cmd, struct dev_filter *f __att
 	char buf[BUFSIZE];
 	int ret = 0;
 
+	dev->filtered_flags &= ~DEV_FILTERED_SIGNATURE;
+
 	if (!scan_bcache) {
 		/* let pass, call again after scan */
 		log_debug_devs("filter signature deferred %s", dev_name(dev));
@@ -40,18 +42,21 @@ static int _ignore_signature(struct cmd_context *cmd, struct dev_filter *f __att
 		log_debug_devs("%s: Skipping: error in signature detection",
 			       dev_name(dev));
 		ret = 0;
+		dev->filtered_flags |= DEV_FILTERED_SIGNATURE;
 		goto out;
 	}
 
 	if (dev_is_lvm1(dev, buf, BUFSIZE)) {
 		log_debug_devs("%s: Skipping lvm1 device", dev_name(dev));
 		ret = 0;
+		dev->filtered_flags |= DEV_FILTERED_SIGNATURE;
 		goto out;
 	}
 
 	if (dev_is_pool(dev, buf, BUFSIZE)) {
 		log_debug_devs("%s: Skipping gfs-pool device", dev_name(dev));
 		ret = 0;
+		dev->filtered_flags |= DEV_FILTERED_SIGNATURE;
 		goto out;
 	}
 	ret = 1;
diff --git a/lib/filters/filter-sysfs.c b/lib/filters/filter-sysfs.c
index ebca8087c..b2ac63d7b 100644
--- a/lib/filters/filter-sysfs.c
+++ b/lib/filters/filter-sysfs.c
@@ -264,6 +264,8 @@ static int _accept_p(struct cmd_context *cmd, struct dev_filter *f, struct devic
 {
 	struct dev_set *ds = (struct dev_set *) f->private;
 
+	dev->filtered_flags &= ~DEV_FILTERED_SYSFS;
+
 	if (!ds->initialised)
 		_init_devs(ds);
 
@@ -273,6 +275,7 @@ static int _accept_p(struct cmd_context *cmd, struct dev_filter *f, struct devic
 
 	if (!_set_lookup(ds, dev->dev)) {
 		log_debug_devs("%s: Skipping (sysfs)", dev_name(dev));
+		dev->filtered_flags |= DEV_FILTERED_SYSFS;
 		return 0;
 	}
 
diff --git a/lib/filters/filter-type.c b/lib/filters/filter-type.c
index 1d083707f..bfb8edd34 100644
--- a/lib/filters/filter-type.c
+++ b/lib/filters/filter-type.c
@@ -22,10 +22,13 @@ static int _passes_lvm_type_device_filter(struct cmd_context *cmd, struct dev_fi
 	struct dev_types *dt = (struct dev_types *) f->private;
 	const char *name = dev_name(dev);
 
+	dev->filtered_flags &= ~DEV_FILTERED_DEVTYPE;
+
 	/* Is this a recognised device type? */
 	if (!dt->dev_type_array[MAJOR(dev->dev)].max_partitions) {
 		log_debug_devs("%s: Skipping: Unrecognised LVM device type %"
 			       PRIu64, name, (uint64_t) MAJOR(dev->dev));
+		dev->filtered_flags |= DEV_FILTERED_DEVTYPE;
 		return 0;
 	}
 
diff --git a/lib/filters/filter-usable.c b/lib/filters/filter-usable.c
index b3ff65075..8a5b0d828 100644
--- a/lib/filters/filter-usable.c
+++ b/lib/filters/filter-usable.c
@@ -113,6 +113,9 @@ static int _passes_usable_filter(struct cmd_context *cmd, struct dev_filter *f,
 	struct dev_usable_check_params ucp = {0};
 	int r = 1;
 
+	dev->filtered_flags &= ~DEV_FILTERED_MINSIZE;
+	dev->filtered_flags &= ~DEV_FILTERED_UNUSABLE;
+
 	/* further checks are done on dm devices only */
 	if (dm_is_dm_major(MAJOR(dev->dev))) {
 		switch (mode) {
@@ -142,8 +145,10 @@ static int _passes_usable_filter(struct cmd_context *cmd, struct dev_filter *f,
 			break;
 		}
 
-		if (!(r = device_is_usable(dev, ucp)))
+		if (!(r = device_is_usable(dev, ucp))) {
+			dev->filtered_flags |= DEV_FILTERED_UNUSABLE;
 			log_debug_devs("%s: Skipping unusable device.", dev_name(dev));
+		}
 	}
 
 	if (r) {
@@ -153,6 +158,8 @@ static int _passes_usable_filter(struct cmd_context *cmd, struct dev_filter *f,
 			/* fall through */
 		case FILTER_MODE_PRE_LVMETAD:
 			r = _check_pv_min_size(dev);
+			if (!r)
+				dev->filtered_flags |= DEV_FILTERED_MINSIZE;
 			break;
 		case FILTER_MODE_POST_LVMETAD:
 			/* nothing to do here */
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index 7333cfe3c..bfd045be5 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -52,4 +52,16 @@ typedef enum {
 } filter_mode_t;
 struct dev_filter *usable_filter_create(struct cmd_context *cmd, struct dev_types *dt, filter_mode_t mode);
 
+#define DEV_FILTERED_FWRAID		0x00000001
+#define DEV_FILTERED_INTERNAL		0x00000002
+#define DEV_FILTERED_MD_COMPONENT	0x00000004
+#define DEV_FILTERED_MPATH_COMPONENT	0x00000008
+#define DEV_FILTERED_PARTITIONED	0x00000010
+#define DEV_FILTERED_REGEX		0x00000020
+#define DEV_FILTERED_SIGNATURE		0x00000040
+#define DEV_FILTERED_SYSFS		0x00000080
+#define DEV_FILTERED_DEVTYPE		0x00000100
+#define DEV_FILTERED_MINSIZE		0x00000200
+#define DEV_FILTERED_UNUSABLE		0x00000400
+
 #endif 	/* _LVM_FILTER_H */
diff --git a/tools/pvck.c b/tools/pvck.c
index 39449af68..7ae4976e5 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -3040,7 +3040,7 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 		clear_hint_file(cmd);
 
 		if (!(dev = dev_cache_get(cmd, pv_name, cmd->filter))) {
-			log_error("No device found for %s %s.", pv_name, dev_cache_filtered_reason(pv_name));
+			log_error("Cannot use %s: %s.", pv_name, devname_error_reason(pv_name));
 			return ECMD_FAILED;
 		}
 	}
@@ -3054,7 +3054,7 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 			def = get_devicefile(pv_name);
 
 		if (!dev && !def) {
-			log_error("No device found for %s %s.", pv_name, dev_cache_filtered_reason(pv_name));
+			log_error("Cannot use %s: %s.", pv_name, devname_error_reason(pv_name));
 			return ECMD_FAILED;
 		}
 	}
@@ -3143,7 +3143,7 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 		pv_name = argv[i];
 
 		if (!(dev = dev_cache_get(cmd, argv[i], cmd->filter))) {
-			log_error("Device %s %s.", pv_name, dev_cache_filtered_reason(pv_name));
+			log_error("Cannot use %s: %s.", pv_name, devname_error_reason(pv_name));
 			continue;
 		}
 


