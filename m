From: David Teigland <teigland@sourceware.org>
Date: Thu, 10 May 2018 17:03:55 -0400
Subject: master - filter: use bcache for filter reads
Message-ID: <201805102103.w4AL3tqD020497@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=57bb46c5e7f8d6af1737af5ed1acae8abc37cded
Commit:        57bb46c5e7f8d6af1737af5ed1acae8abc37cded
Parent:        39ce38eb8868e367fa796ddb12b1020647d14c63
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 3 17:12:07 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 10 16:03:19 2018 -0500

filter: use bcache for filter reads

Filters are still applied before any device reading or
the label scan, but any filter checks that want to read
the device are skipped and the device is flagged.

After bcache is populated, but before lvm looks for
devices (i.e. before label scan), the filters are
reapplied to the devices that were flagged above.
The filters will then find the data they need in
bcache.
---
 lib/cache/lvmcache.c             |    2 +-
 lib/cache/lvmetad.c              |    2 +-
 lib/commands/toolcontext.c       |    2 +-
 lib/commands/toolcontext.h       |    1 +
 lib/device/dev-cache.c           |   70 +++++++++++++++++++++++++++++-----
 lib/device/dev-io.c              |    4 +-
 lib/device/dev-luks.c            |   13 ++----
 lib/device/dev-md.c              |   67 +++++++++++++++++++++++++--------
 lib/device/dev-swap.c            |   16 ++-----
 lib/device/dev-type.c            |   18 +++------
 lib/device/dev-type.h            |    7 ++-
 lib/device/device.h              |    2 +
 lib/filters/filter-composite.c   |    9 +++-
 lib/filters/filter-md.c          |   39 ++++++++++++++++--
 lib/filters/filter-partitioned.c |   12 +++++-
 lib/filters/filter-persistent.c  |   78 ++++++++++++++++++++++++++++++-------
 lib/filters/filter-signature.c   |   12 +++---
 lib/filters/filter-usable.c      |    9 ----
 lib/filters/filter.h             |    2 +-
 lib/label/label.c                |   58 +++++++++++++++++++++++-----
 lib/label/label.h                |    2 +-
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/metadata.c          |   19 ++-------
 tools/lvmdiskscan.c              |    5 +-
 tools/pvck.c                     |   48 +++++++++++++++++------
 tools/pvcreate.c                 |    3 +
 tools/pvscan.c                   |   54 +++++++++++++++++++++++---
 tools/vgcreate.c                 |    3 +
 tools/vgextend.c                 |    3 +
 29 files changed, 408 insertions(+), 154 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 745e219..290d733 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1320,7 +1320,7 @@ int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const
 	/* FIXME: should we also rescan unused_duplicate_devs for devs
 	   being rescanned here and then repeat resolving the duplicates? */
 
-	label_scan_devs(cmd, &devs);
+	label_scan_devs(cmd, cmd->filter, &devs);
 
 	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid))) {
 		log_warn("VG info not found after rescan of %s", vgname);
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index f21829c..235f72b 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1878,7 +1878,7 @@ static struct volume_group *_lvmetad_pvscan_vg(struct cmd_context *cmd, struct v
 	 */
 	log_debug_lvmetad("Rescan VG %s scanning data from devs in previous metadata.", vg->name);
 
-	label_scan_devs(cmd, &pvs_scan);
+	label_scan_devs(cmd, cmd->full_filter, &pvs_scan);
 
 	/*
 	 * Check if any pvs_scan entries are no longer PVs.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 4fdd62f..e9f9357 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1144,7 +1144,7 @@ static struct dev_filter *_init_lvmetad_filter_chain(struct cmd_context *cmd)
 	/* md component filter. Optional, non-critical. */
 	if (find_config_tree_bool(cmd, devices_md_component_detection_CFG, NULL)) {
 		init_md_filtering(1);
-		if ((filters[nr_filt] = md_filter_create(cmd->dev_types)))
+		if ((filters[nr_filt] = md_filter_create(cmd, cmd->dev_types)))
 			nr_filt++;
 	}
 
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 34222ee..83c8e82 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -171,6 +171,7 @@ struct cmd_context {
 	unsigned pvscan_cache_single:1;
 	unsigned can_use_one_scan:1;
 	unsigned is_clvmd:1;
+	unsigned use_full_md_check:1;
 
 	/*
 	 * Filtering.
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 52edad8..15d4cdf 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1378,6 +1378,7 @@ struct device *dev_cache_get(const char *name, struct dev_filter *f)
 	struct stat buf;
 	struct device *d = (struct device *) dm_hash_lookup(_cache.names, name);
 	int info_available = 0;
+	int ret = 1;
 
 	if (d && (d->flags & DEV_REGULAR))
 		return d;
@@ -1405,10 +1406,25 @@ struct device *dev_cache_get(const char *name, struct dev_filter *f)
 		}
 	}
 
-	if (!d || (f && !(d->flags & DEV_REGULAR) && !(f->passes_filter(f, d))))
+	if (!d)
+		return NULL;
+
+	if (d && (d->flags & DEV_REGULAR))
+		return d;
+
+	if (f && !(d->flags & DEV_REGULAR)) {
+		ret = f->passes_filter(f, d);
+
+		if (ret == -EAGAIN) {
+			log_debug_devs("get device by name defer filter %s", dev_name(d));
+			d->flags |= DEV_FILTER_AFTER_SCAN;
+			ret = 1;
+		}
+	}
+
+	if (f && !(d->flags & DEV_REGULAR) && !ret)
 		return NULL;
 
-	log_debug_devs("%s: Using device (%d:%d)", dev_name(d), (int) MAJOR(d->dev), (int) MINOR(d->dev));
 	return d;
 }
 
@@ -1435,6 +1451,7 @@ struct device *dev_cache_get_by_devt(dev_t dev, struct dev_filter *f)
 	const char *sysfs_dir;
 	struct stat info;
 	struct device *d = _dev_cache_seek_devt(dev);
+	int ret;
 
 	if (d && (d->flags & DEV_REGULAR))
 		return d;
@@ -1450,8 +1467,8 @@ struct device *dev_cache_get_by_devt(dev_t dev, struct dev_filter *f)
 			}
 
 			if (lstat(path, &info)) {
-				log_debug("No sysfs entry for %d:%d.",
-					  (int)MAJOR(dev), (int)MINOR(dev));
+				log_debug("No sysfs entry for %d:%d errno %d at %s.",
+					  (int)MAJOR(dev), (int)MINOR(dev), errno, path);
 				return NULL;
 			}
 		}
@@ -1460,8 +1477,27 @@ struct device *dev_cache_get_by_devt(dev_t dev, struct dev_filter *f)
 		d = _dev_cache_seek_devt(dev);
 	}
 
-	return (d && (!f || (d->flags & DEV_REGULAR) ||
-		      f->passes_filter(f, d))) ? d : NULL;
+	if (!d)
+		return NULL;
+
+	if (d->flags & DEV_REGULAR)
+		return d;
+
+	if (!f)
+		return d;
+
+	ret = f->passes_filter(f, d);
+
+	if (ret == -EAGAIN) {
+		log_debug_devs("get device by number defer filter %s", dev_name(d));
+		d->flags |= DEV_FILTER_AFTER_SCAN;
+		ret = 1;
+	}
+
+	if (ret)
+		return d;
+
+	return NULL;
 }
 
 struct dev_iter *dev_iter_create(struct dev_filter *f, int unused)
@@ -1497,13 +1533,27 @@ static struct device *_iter_next(struct dev_iter *iter)
 
 struct device *dev_iter_get(struct dev_iter *iter)
 {
+	struct dev_filter *f;
+	int ret;
+
 	while (iter->current) {
 		struct device *d = _iter_next(iter);
-		if (!iter->filter || (d->flags & DEV_REGULAR) ||
-		    iter->filter->passes_filter(iter->filter, d)) {
-			log_debug_devs("%s: Using device (%d:%d)", dev_name(d), (int) MAJOR(d->dev), (int) MINOR(d->dev));
-			return d;
+		ret = 1;
+
+		f = iter->filter;
+
+		if (f && !(d->flags & DEV_REGULAR)) {
+			ret = f->passes_filter(f, d);
+
+			if (ret == -EAGAIN) {
+				log_debug_devs("get device by iter defer filter %s", dev_name(d));
+				d->flags |= DEV_FILTER_AFTER_SCAN;
+				ret = 1;
+			}
 		}
+
+		if (!f || (d->flags & DEV_REGULAR) || ret)
+			return d;
 	}
 
 	return NULL;
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 39d5d30..cce5a94 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -358,11 +358,11 @@ static int _dev_get_size_dev(struct device *dev, uint64_t *size)
 	dev->size = *size;
 	dev->size_seqno = _dev_size_seqno;
 
+	log_very_verbose("%s: size is %" PRIu64 " sectors", name, *size);
+
 	if (do_close && !dev_close(dev))
 		log_sys_error("close", name);
 
-	log_very_verbose("%s: size is %" PRIu64 " sectors", name, *size);
-
 	return 1;
 }
 
diff --git a/lib/device/dev-luks.c b/lib/device/dev-luks.c
index 8513e14..25a8b2c 100644
--- a/lib/device/dev-luks.c
+++ b/lib/device/dev-luks.c
@@ -18,27 +18,22 @@
 #define LUKS_SIGNATURE "LUKS\xba\xbe"
 #define LUKS_SIGNATURE_SIZE 6
 
-int dev_is_luks(struct device *dev, uint64_t *offset_found)
+int dev_is_luks(struct device *dev, uint64_t *offset_found, int full)
 {
 	char buf[LUKS_SIGNATURE_SIZE];
 	int ret = -1;
 
-	if (!dev_open_readonly(dev)) {
-		stack;
-		return -1;
-	}
+	if (!scan_bcache)
+		return -EAGAIN;
 
 	if (offset_found)
 		*offset_found = 0;
 
-	if (!dev_read(dev, 0, LUKS_SIGNATURE_SIZE, DEV_IO_SIGNATURES, buf))
+	if (!dev_read_bytes(dev, 0, LUKS_SIGNATURE_SIZE, buf))
 		goto_out;
 
 	ret = memcmp(buf, LUKS_SIGNATURE, LUKS_SIGNATURE_SIZE) ? 0 : 1;
 
 out:
-	if (!dev_close(dev))
-		stack;
-
 	return ret;
 }
diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 92ee214..f32c1c3 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -37,9 +37,12 @@ static int _dev_has_md_magic(struct device *dev, uint64_t sb_offset)
 	uint32_t md_magic;
 
 	/* Version 1 is little endian; version 0.90.0 is machine endian */
-	if (dev_read(dev, sb_offset, sizeof(uint32_t), DEV_IO_SIGNATURES, &md_magic) &&
-	    ((md_magic == MD_SB_MAGIC) ||
-	     ((MD_SB_MAGIC != xlate32(MD_SB_MAGIC)) && (md_magic == xlate32(MD_SB_MAGIC)))))
+
+	if (!dev_read_bytes(dev, sb_offset, sizeof(uint32_t), &md_magic))
+		return_0;
+
+	if ((md_magic == MD_SB_MAGIC) ||
+	     ((MD_SB_MAGIC != xlate32(MD_SB_MAGIC)) && (md_magic == xlate32(MD_SB_MAGIC))))
 		return 1;
 
 	return 0;
@@ -109,11 +112,14 @@ static int _udev_dev_is_md(struct device *dev)
 /*
  * Returns -1 on error
  */
-static int _native_dev_is_md(struct device *dev, uint64_t *offset_found)
+static int _native_dev_is_md(struct device *dev, uint64_t *offset_found, int full)
 {
-	int ret = 1;
 	md_minor_version_t minor;
 	uint64_t size, sb_offset;
+	int ret;
+
+	if (!scan_bcache)
+		return -EAGAIN;
 
 	if (!dev_get_size(dev, &size)) {
 		stack;
@@ -123,38 +129,67 @@ static int _native_dev_is_md(struct device *dev, uint64_t *offset_found)
 	if (size < MD_RESERVED_SECTORS * 2)
 		return 0;
 
-	if (!dev_open_readonly(dev)) {
-		stack;
-		return -1;
+	/*
+	 * Old md versions locate the magic number at the end of the device.
+	 * Those checks can't be satisfied with the initial bcache data, and
+	 * would require an extra read i/o at the end of every device.  Issuing
+	 * an extra read to every device in every command, just to check for
+	 * the old md format is a bad tradeoff.  It's also not a big issue if
+	 * one happens to exist and we don't filter it out.
+	 *
+	 * When "full" is set, we check a the start and end of the device for
+	 * md magic numbers.  When "full" is not set, we only check@the
+	 * start of the device for the magic numbers.  We decide for each
+	 * command if it should do a full check (cmd->use_full_md_check),
+	 * and set it for commands that could possibly write to an md dev
+	 * (pvcreate/vgcreate/vgextend).
+	 */
+	if (!full) {
+		sb_offset = 0;
+		if (_dev_has_md_magic(dev, sb_offset)) {
+			log_debug_devs("Found md magic number at offset 0 of %s.", dev_name(dev));
+			ret = 1;
+			goto out;
+		}
+
+		sb_offset = 8 << SECTOR_SHIFT;
+		if (_dev_has_md_magic(dev, sb_offset)) {
+			log_debug_devs("Found md magic number@offset %d of %s.", (int)sb_offset, dev_name(dev));
+			ret = 1;
+			goto out;
+		}
+
+		ret = 0;
+		goto out;
 	}
 
 	/* Check if it is an md component device. */
 	/* Version 0.90.0 */
 	sb_offset = MD_NEW_SIZE_SECTORS(size) << SECTOR_SHIFT;
-	if (_dev_has_md_magic(dev, sb_offset))
+	if (_dev_has_md_magic(dev, sb_offset)) {
+		ret = 1;
 		goto out;
+	}
 
 	minor = MD_MINOR_VERSION_MIN;
 	/* Version 1, try v1.0 -> v1.2 */
 	do {
 		sb_offset = _v1_sb_offset(size, minor);
-		if (_dev_has_md_magic(dev, sb_offset))
+		if (_dev_has_md_magic(dev, sb_offset)) {
+			ret = 1;
 			goto out;
+		}
 	} while (++minor <= MD_MINOR_VERSION_MAX);
 
 	ret = 0;
-
 out:
-	if (!dev_close(dev))
-		stack;
-
 	if (ret && offset_found)
 		*offset_found = sb_offset;
 
 	return ret;
 }
 
-int dev_is_md(struct device *dev, uint64_t *offset_found)
+int dev_is_md(struct device *dev, uint64_t *offset_found, int full)
 {
 
 	/*
@@ -163,7 +198,7 @@ int dev_is_md(struct device *dev, uint64_t *offset_found)
 	 * information is not in udev db.
 	 */
 	if ((dev->ext.src == DEV_EXT_NONE) || offset_found)
-		return _native_dev_is_md(dev, offset_found);
+		return _native_dev_is_md(dev, offset_found, full);
 
 	if (dev->ext.src == DEV_EXT_UDEV)
 		return _udev_dev_is_md(dev);
diff --git a/lib/device/dev-swap.c b/lib/device/dev-swap.c
index a7ff10b..3bfb72b 100644
--- a/lib/device/dev-swap.c
+++ b/lib/device/dev-swap.c
@@ -35,19 +35,17 @@ static int _swap_detect_signature(const char *buf)
 	return 0;
 }
 
-int dev_is_swap(struct device *dev, uint64_t *offset_found)
+int dev_is_swap(struct device *dev, uint64_t *offset_found, int full)
 {
 	char buf[10];
 	uint64_t size;
 	unsigned page;
 	int ret = 0;
 
-	if (!dev_get_size(dev, &size)) {
-		stack;
-		return -1;
-	}
+	if (!scan_bcache)
+		return -EAGAIN;
 
-	if (!dev_open_readonly(dev)) {
+	if (!dev_get_size(dev, &size)) {
 		stack;
 		return -1;
 	}
@@ -60,8 +58,7 @@ int dev_is_swap(struct device *dev, uint64_t *offset_found)
 			continue;
 		if (size < (page >> SECTOR_SHIFT))
 			break;
-		if (!dev_read(dev, page - SIGNATURE_SIZE,
-			      SIGNATURE_SIZE, DEV_IO_SIGNATURES, buf)) {
+		if (!dev_read_bytes(dev, page - SIGNATURE_SIZE, SIGNATURE_SIZE, buf)) {
 			ret = -1;
 			break;
 		}
@@ -73,9 +70,6 @@ int dev_is_swap(struct device *dev, uint64_t *offset_found)
 		}
 	}
 
-	if (!dev_close(dev))
-		stack;
-
 	return ret;
 }
 
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 9923943..8d4a403 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -365,7 +365,7 @@ static int _has_partition_table(struct device *dev)
 		uint16_t magic;
 	} __attribute__((packed)) buf; /* sizeof() == SECTOR_SIZE */
 
-	if (!dev_read(dev, UINT64_C(0), sizeof(buf), DEV_IO_SIGNATURES, &buf))
+	if (!dev_read_bytes(dev, UINT64_C(0), sizeof(buf), &buf))
 		return_0;
 
 	/* FIXME Check for other types of partition table too */
@@ -434,6 +434,9 @@ static int _native_dev_is_partitioned(struct dev_types *dt, struct device *dev)
 {
 	int r;
 
+	if (!scan_bcache)
+		return -EAGAIN;
+
 	if (!_is_partitionable(dt, dev))
 		return 0;
 
@@ -441,17 +444,8 @@ static int _native_dev_is_partitioned(struct dev_types *dt, struct device *dev)
 	if ((MAJOR(dev->dev) == dt->dasd_major) && dasd_is_cdl_formatted(dev))
 		return 1;
 
-	if (!dev_open_readonly_quiet(dev)) {
-		log_debug_devs("%s: failed to open device, considering device "
-			       "is partitioned", dev_name(dev));
-		return 1;
-	}
-
 	r = _has_partition_table(dev);
 
-	if (!dev_close(dev))
-		stack;
-
 	return r;
 }
 
@@ -750,12 +744,12 @@ out:
 
 static int _wipe_signature(struct device *dev, const char *type, const char *name,
 			   int wipe_len, int yes, force_t force, int *wiped,
-			   int (*signature_detection_fn)(struct device *dev, uint64_t *offset_found))
+			   int (*signature_detection_fn)(struct device *dev, uint64_t *offset_found, int full))
 {
 	int wipe;
 	uint64_t offset_found;
 
-	wipe = signature_detection_fn(dev, &offset_found);
+	wipe = signature_detection_fn(dev, &offset_found, 1);
 	if (wipe == -1) {
 		log_error("Fatal error while trying to detect %s on %s.",
 			  type, name);
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index e48e22b..843e254 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -17,6 +17,7 @@
 
 #include "device.h"
 #include "display.h"
+#include "label.h"
 
 #define NUMBER_OF_MAJORS 4096
 
@@ -56,9 +57,9 @@ const char *dev_subsystem_name(struct dev_types *dt, struct device *dev);
 int major_is_scsi_device(struct dev_types *dt, int major);
 
 /* Signature/superblock recognition with position returned where found. */
-int dev_is_md(struct device *dev, uint64_t *sb);
-int dev_is_swap(struct device *dev, uint64_t *signature);
-int dev_is_luks(struct device *dev, uint64_t *signature);
+int dev_is_md(struct device *dev, uint64_t *sb, int full);
+int dev_is_swap(struct device *dev, uint64_t *signature, int full);
+int dev_is_luks(struct device *dev, uint64_t *signature, int full);
 int dasd_is_cdl_formatted(struct device *dev);
 int udev_dev_is_mpath_component(struct device *dev);
 
diff --git a/lib/device/device.h b/lib/device/device.h
index 36d1e3e..fd8cbb7 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -33,6 +33,8 @@
 #define DEV_NOT_O_NOATIME	0x00000400	/* Don't use O_NOATIME */
 #define DEV_IN_BCACHE		0x00000800      /* dev fd is open and used in bcache */
 #define DEV_BCACHE_EXCL		0x00001000      /* bcache_fd should be open EXCL */
+#define DEV_FILTER_AFTER_SCAN	0x00002000	/* apply filter after bcache has data */
+#define DEV_FILTER_OUT_SCAN	0x00004000	/* filtered out during label scan */
 
 /*
  * Support for external device info.
diff --git a/lib/filters/filter-composite.c b/lib/filters/filter-composite.c
index c635896..f15ff12 100644
--- a/lib/filters/filter-composite.c
+++ b/lib/filters/filter-composite.c
@@ -15,14 +15,19 @@
 
 #include "lib.h"
 #include "filter.h"
+#include "device.h"
 
 static int _and_p(struct dev_filter *f, struct device *dev)
 {
 	struct dev_filter **filters;
+	int ret;
 
-	for (filters = (struct dev_filter **) f->private; *filters; ++filters)
-		if (!(*filters)->passes_filter(*filters, dev))
+	for (filters = (struct dev_filter **) f->private; *filters; ++filters) {
+		ret = (*filters)->passes_filter(*filters, dev);
+
+		if (!ret)
 			return 0;	/* No 'stack': a filter, not an error. */
+	}
 
 	return 1;
 }
diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index 7fac50a..bb8a7cf 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -20,15 +20,21 @@
 
 #define MSG_SKIPPING "%s: Skipping md component device"
 
-static int _ignore_md(struct dev_filter *f __attribute__((unused)),
-		      struct device *dev)
+static int _ignore_md(struct device *dev, int full)
 {
 	int ret;
 	
 	if (!md_filtering())
 		return 1;
 	
-	ret = dev_is_md(dev, NULL);
+	ret = dev_is_md(dev, NULL, full);
+
+	if (ret == -EAGAIN) {
+		/* let pass, call again after scan */
+		dev->flags |= DEV_FILTER_AFTER_SCAN;
+		log_debug_devs("filter md deferred %s", dev_name(dev));
+		return 1;
+	}
 
 	if (ret == 1) {
 		if (dev->ext.src == DEV_EXT_NONE)
@@ -48,6 +54,18 @@ static int _ignore_md(struct dev_filter *f __attribute__((unused)),
 	return 1;
 }
 
+static int _ignore_md_lite(struct dev_filter *f __attribute__((unused)),
+		           struct device *dev)
+{
+	return _ignore_md(dev, 0);
+}
+
+static int _ignore_md_full(struct dev_filter *f __attribute__((unused)),
+		           struct device *dev)
+{
+	return _ignore_md(dev, 1);
+}
+
 static void _destroy(struct dev_filter *f)
 {
 	if (f->use_count)
@@ -56,7 +74,7 @@ static void _destroy(struct dev_filter *f)
 	dm_free(f);
 }
 
-struct dev_filter *md_filter_create(struct dev_types *dt)
+struct dev_filter *md_filter_create(struct cmd_context *cmd, struct dev_types *dt)
 {
 	struct dev_filter *f;
 
@@ -65,7 +83,18 @@ struct dev_filter *md_filter_create(struct dev_types *dt)
 		return NULL;
 	}
 
-	f->passes_filter = _ignore_md;
+	/*
+	 * FIXME: for commands that want a full md check (pvcreate, vgcreate,
+	 * vgextend), we do an extra read at the end of every device that the
+	 * filter looks at.  This isn't necessary; we only need to do the full
+	 * md check on the PVs that these commands are trying to use.
+	 */
+
+	if (cmd->use_full_md_check)
+		f->passes_filter = _ignore_md_full;
+	else
+		f->passes_filter = _ignore_md_lite;
+
 	f->destroy = _destroy;
 	f->use_count = 0;
 	f->private = dt;
diff --git a/lib/filters/filter-partitioned.c b/lib/filters/filter-partitioned.c
index f23fae6..5e1c4e8 100644
--- a/lib/filters/filter-partitioned.c
+++ b/lib/filters/filter-partitioned.c
@@ -21,8 +21,18 @@
 static int _passes_partitioned_filter(struct dev_filter *f, struct device *dev)
 {
 	struct dev_types *dt = (struct dev_types *) f->private;
+	int ret;
 
-	if (dev_is_partitioned(dt, dev)) {
+	ret = dev_is_partitioned(dt, dev);
+
+	if (ret == -EAGAIN) {
+		/* let pass, call again after scan */
+		log_debug_devs("filter partitioned deferred %s", dev_name(dev));
+		dev->flags |= DEV_FILTER_AFTER_SCAN;
+		return 1;
+	}
+
+	if (ret) {
 		if (dev->ext.src == DEV_EXT_NONE)
 			log_debug_devs(MSG_SKIPPING, dev_name(dev));
 		else
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index a4151c2..3fa57f1 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -27,6 +27,30 @@ struct pfilter {
 };
 
 /*
+ * The persistent filter is filter layer that sits above the other filters and
+ * caches the final result of those other filters.  When a device is first
+ * checked against filters, it will not be in this cache, so this filter will
+ * pass the device down to the other filters to check it.  The other filters
+ * will run and either include the device (good/pass) or exclude the device
+ * (bad/fail).  That good or bad result propagates up through this filter which
+ * saves the result.  The next time some code checks the filters against the
+ * device, this persistent/cache filter is checked first.  This filter finds
+ * the previous result in its cache and returns it without reevaluating the
+ * other real filters.
+ *
+ * FIXME: a cache like this should not be needed.  The fact it's needed is a
+ * symptom of code that should be fixed to not reevaluate filters multiple
+ * times.  A device should be checked against the filter once, and then not
+ * need to be checked again.  With scanning now controlled, we could probably
+ * do this.
+ *
+ * FIXME: "persistent" isn't a great name for this caching filter.  This filter
+ * at one time saved its cache results to a file, which is how it got the name.
+ * That .cache file does not work well, causes problems, and is no longer used
+ * by default.  The old code for it should be removed.
+ */
+
+/*
  * The hash table holds one of these two states
  * against each entry.
  */
@@ -264,27 +288,51 @@ static int _lookup_p(struct dev_filter *f, struct device *dev)
 	struct pfilter *pf = (struct pfilter *) f->private;
 	void *l = dm_hash_lookup(pf->devices, dev_name(dev));
 	struct dm_str_list *sl;
+	int pass = 1;
 
-	/* Cached BAD? */
+	/* Cached bad, skip dev */
 	if (l == PF_BAD_DEVICE) {
-		log_debug_devs("%s: Skipping (cached)", dev_name(dev));
+		log_debug_devs("%s: filter cache skipping (cached bad)", dev_name(dev));
 		return 0;
 	}
 
-	/* Test dm devices every time, so cache them as GOOD. */
-	if (MAJOR(dev->dev) == pf->dt->device_mapper_major) {
-		if (!l)
-			dm_list_iterate_items(sl, &dev->aliases)
-				if (!dm_hash_insert(pf->devices, sl->str, PF_GOOD_DEVICE)) {
-					log_error("Failed to hash device to filter.");
-					return 0;
-				}
-		return pf->real->passes_filter(pf->real, dev);
+	/* Cached good, use dev */
+	if (l == PF_GOOD_DEVICE) {
+		log_debug_devs("%s: filter cache using (cached good)", dev_name(dev));
+		return 1;
 	}
 
-	/* Uncached */
+	/* Uncached, check filters and cache the result */
 	if (!l) {
-		l = pf->real->passes_filter(pf->real, dev) ?  PF_GOOD_DEVICE : PF_BAD_DEVICE;
+		dev->flags &= ~DEV_FILTER_AFTER_SCAN;
+
+		pass = pf->real->passes_filter(pf->real, dev);
+
+		if (!pass) {
+			/*
+			 * A device that does not pass one filter is excluded
+			 * even if the result of another filter is deferred,
+			 * because the deferred result won't change the exclude.
+			 */
+			l = PF_BAD_DEVICE;
+
+		} else if ((pass == -EAGAIN) || (dev->flags & DEV_FILTER_AFTER_SCAN)) {
+			/*
+			 * When the filter result is deferred, we let the device
+			 * pass for now, but do not cache the result.  We need to
+			 * rerun the filters later.  At that point the final result
+			 * will be cached.
+			 */
+			log_debug_devs("filter cache deferred %s", dev_name(dev));
+			dev->flags |= DEV_FILTER_AFTER_SCAN;
+			pass = 1;
+			goto out;
+
+		} else if (pass) {
+			l = PF_GOOD_DEVICE;
+		}
+
+		log_debug_devs("filter caching %s %s", pass ? "good" : "bad", dev_name(dev));
 
 		dm_list_iterate_items(sl, &dev->aliases)
 			if (!dm_hash_insert(pf->devices, sl->str, l)) {
@@ -292,8 +340,8 @@ static int _lookup_p(struct dev_filter *f, struct device *dev)
 				return 0;
 			}
 	}
-
-	return (l == PF_BAD_DEVICE) ? 0 : 1;
+ out:
+	return pass;
 }
 
 static void _persistent_destroy(struct dev_filter *f)
diff --git a/lib/filters/filter-signature.c b/lib/filters/filter-signature.c
index b426476..23b01e7 100644
--- a/lib/filters/filter-signature.c
+++ b/lib/filters/filter-signature.c
@@ -26,14 +26,16 @@ static int _ignore_signature(struct dev_filter *f __attribute__((unused)),
 	char buf[BUFSIZE];
 	int ret = 0;
 
-	if (!dev_open_readonly(dev)) {
-		stack;
-		return -1;
+	if (!scan_bcache) {
+		/* let pass, call again after scan */
+		log_debug_devs("filter signature deferred %s", dev_name(dev));
+		dev->flags |= DEV_FILTER_AFTER_SCAN;
+		return 1;
 	}
 
 	memset(buf, 0, BUFSIZE);
 
-	if (!dev_read(dev, 0, BUFSIZE, DEV_IO_SIGNATURES, buf)) {
+	if (!dev_read_bytes(dev, 0, BUFSIZE, buf)) {
 		log_debug_devs("%s: Skipping: error in signature detection",
 			       dev_name(dev));
 		ret = 0;
@@ -54,8 +56,6 @@ static int _ignore_signature(struct dev_filter *f __attribute__((unused)),
 	ret = 1;
 
 out:
-	dev_close(dev);
-
 	return ret;
 }
 
diff --git a/lib/filters/filter-usable.c b/lib/filters/filter-usable.c
index 4ee2e9d..2de2a0f 100644
--- a/lib/filters/filter-usable.c
+++ b/lib/filters/filter-usable.c
@@ -27,12 +27,6 @@ static int _native_check_pv_min_size(struct device *dev)
 	uint64_t size;
 	int ret = 0;
 
-	/* Check it's accessible */
-	if (!dev_open_readonly_quiet(dev)) {
-		log_debug_devs("%s: Skipping: open failed", dev_name(dev));
-		return 0;
-	}
-
 	/* Check it's not too small */
 	if (!dev_get_size(dev, &size)) {
 		log_debug_devs("%s: Skipping: dev_get_size failed", dev_name(dev));
@@ -47,9 +41,6 @@ static int _native_check_pv_min_size(struct device *dev)
 
 	ret = 1;
 out:
-	if (!dev_close(dev))
-		stack;
-
 	return ret;
 }
 
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index 2f809dd..6245827 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -23,7 +23,7 @@
 struct dev_filter *composite_filter_create(int n, int use_dev_ext_info, struct dev_filter **filters);
 
 struct dev_filter *lvm_type_filter_create(struct dev_types *dt);
-struct dev_filter *md_filter_create(struct dev_types *dt);
+struct dev_filter *md_filter_create(struct cmd_context *cmd, struct dev_types *dt);
 struct dev_filter *fwraid_filter_create(struct dev_types *dt);
 struct dev_filter *mpath_filter_create(struct dev_types *dt);
 struct dev_filter *partitioned_filter_create(struct dev_types *dt);
diff --git a/lib/label/label.c b/lib/label/label.c
index cf45c1f..071c2e7 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -328,13 +328,44 @@ static struct labeller *_find_lvm_header(struct device *dev,
  * beyond the range of the scanned block, then additional reads
  * are performed in the processing functions to get that data.
  */
-static int _process_block(struct device *dev, struct block *bb, int *is_lvm_device)
+static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
+			  struct device *dev, struct block *bb, int *is_lvm_device)
 {
 	char label_buf[LABEL_SIZE] __attribute__((aligned(8)));
 	struct label *label = NULL;
 	struct labeller *labeller;
 	uint64_t sector;
 	int ret = 0;
+	int pass;
+
+	/*
+	 * The device may have signatures that exclude it from being processed.
+	 * If filters were applied before bcache data was available, some
+	 * filters may have deferred their check until the point where bcache
+	 * data had been read (here).  They set this flag to indicate that the
+	 * filters should be retested now that data from the device is ready.
+	 */
+	if (cmd && (dev->flags & DEV_FILTER_AFTER_SCAN)) {
+		dev->flags &= ~DEV_FILTER_AFTER_SCAN;
+
+		log_debug_devs("Scan filtering %s", dev_name(dev));
+		
+		pass = f->passes_filter(f, dev);
+
+		if ((pass == -EAGAIN) || (dev->flags & DEV_FILTER_AFTER_SCAN)) {
+			/* Shouldn't happen */
+			dev->flags &= ~DEV_FILTER_OUT_SCAN;
+			log_debug_devs("Scan filter should not be deferred %s", dev_name(dev));
+			pass = 1;
+		}
+
+		if (!pass) {
+			log_very_verbose("%s: Not processing filtered", dev_name(dev));
+			dev->flags |= DEV_FILTER_OUT_SCAN;
+			*is_lvm_device = 0;
+			goto_out;
+		}
+	}
 
 	/*
 	 * Finds the data sector containing the label and copies into label_buf.
@@ -460,7 +491,8 @@ static int _scan_dev_close(struct device *dev)
  * its info is removed from lvmcache.
  */
 
-static int _scan_list(struct dm_list *devs, int *failed)
+static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
+		      struct dm_list *devs, int *failed)
 {
 	struct dm_list wait_devs;
 	struct dm_list done_devs;
@@ -471,6 +503,7 @@ static int _scan_list(struct dm_list *devs, int *failed)
 	int scan_process_errors = 0;
 	int scan_failed_count = 0;
 	int rem_prefetches;
+	int submit_count;
 	int scan_failed;
 	int is_lvm_device;
 	int error;
@@ -483,6 +516,7 @@ static int _scan_list(struct dm_list *devs, int *failed)
 
  scan_more:
 	rem_prefetches = bcache_max_prefetches(scan_bcache);
+	submit_count = 0;
 
 	dm_list_iterate_items_safe(devl, devl2, devs) {
 
@@ -510,11 +544,14 @@ static int _scan_list(struct dm_list *devs, int *failed)
 		bcache_prefetch(scan_bcache, devl->dev->bcache_fd, 0);
 
 		rem_prefetches--;
+		submit_count++;
 
 		dm_list_del(&devl->list);
 		dm_list_add(&wait_devs, &devl->list);
 	}
 
+	log_debug_devs("Scanning submitted %d reads", submit_count);
+
 	dm_list_iterate_items_safe(devl, devl2, &wait_devs) {
 		bb = NULL;
 		error = 0;
@@ -530,7 +567,7 @@ static int _scan_list(struct dm_list *devs, int *failed)
 		} else {
 			log_debug_devs("Processing data from device %s fd %d block %p", dev_name(devl->dev), devl->dev->bcache_fd, bb);
 
-			ret = _process_block(devl->dev, bb, &is_lvm_device);
+			ret = _process_block(cmd, f, devl->dev, bb, &is_lvm_device);
 
 			if (!ret && is_lvm_device) {
 				log_debug_devs("Scan failed to process %s", dev_name(devl->dev));
@@ -666,7 +703,7 @@ int label_scan(struct cmd_context *cmd)
 			return 0;
 	}
 
-	_scan_list(&all_devs, NULL);
+	_scan_list(cmd, cmd->full_filter, &all_devs, NULL);
 
 	return 1;
 }
@@ -679,7 +716,7 @@ int label_scan(struct cmd_context *cmd)
  * without a lock.)
  */
 
-int label_scan_devs(struct cmd_context *cmd, struct dm_list *devs)
+int label_scan_devs(struct cmd_context *cmd, struct dev_filter *f, struct dm_list *devs)
 {
 	struct device_list *devl;
 
@@ -697,7 +734,7 @@ int label_scan_devs(struct cmd_context *cmd, struct dm_list *devs)
 		}
 	}
 
-	_scan_list(devs, NULL);
+	_scan_list(cmd, f, devs, NULL);
 
 	/* FIXME: this function should probably fail if any devs couldn't be scanned */
 
@@ -721,7 +758,7 @@ int label_scan_devs_excl(struct dm_list *devs)
 		devl->dev->flags |= DEV_BCACHE_EXCL;
 	}
 
-	_scan_list(devs, &failed);
+	_scan_list(NULL, NULL, devs, &failed);
 
 	if (failed)
 		return 0;
@@ -750,7 +787,7 @@ void label_scan_invalidate_lv(struct cmd_context *cmd, struct logical_volume *lv
 
 	lv_info(cmd, lv, 0, &lvinfo, 0, 0);
 	devt = MKDEV(lvinfo.major, lvinfo.minor);
-	if ((dev = dev_cache_get_by_devt(devt, cmd->filter)))
+	if ((dev = dev_cache_get_by_devt(devt, NULL)))
 		label_scan_invalidate(dev);
 }
 
@@ -764,9 +801,8 @@ void label_scan_drop(struct cmd_context *cmd)
 	struct dev_iter *iter;
 	struct device *dev;
 
-	if (!(iter = dev_iter_create(cmd->full_filter, 0))) {
+	if (!(iter = dev_iter_create(NULL, 0)))
 		return;
-	}
 
 	while ((dev = dev_iter_get(iter))) {
 		if (_in_bcache(dev))
@@ -818,7 +854,7 @@ int label_read(struct device *dev, struct label **labelp, uint64_t unused_sector
 		_scan_dev_close(dev);
 	}
 
-	_scan_list(&one_dev, &failed);
+	_scan_list(NULL, NULL, &one_dev, &failed);
 
 	/*
 	 * FIXME: this ugliness of returning a pointer to the label is
diff --git a/lib/label/label.h b/lib/label/label.h
index bccf777..3483321 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -103,7 +103,7 @@ void label_destroy(struct label *label);
 extern struct bcache *scan_bcache;
 
 int label_scan(struct cmd_context *cmd);
-int label_scan_devs(struct cmd_context *cmd, struct dm_list *devs);
+int label_scan_devs(struct cmd_context *cmd, struct dev_filter *f, struct dm_list *devs);
 int label_scan_devs_excl(struct dm_list *devs);
 void label_scan_invalidate(struct device *dev);
 void label_scan_invalidate_lv(struct cmd_context *cmd, struct logical_volume *lv);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 120dbb0..97184ed 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -723,7 +723,7 @@ int pv_resize_single(struct cmd_context *cmd,
 			     const uint64_t new_size,
 			     int yes);
 
-int pv_analyze(struct cmd_context *cmd, const char *pv_name,
+int pv_analyze(struct cmd_context *cmd, struct device *dev,
 	       uint64_t label_sector);
 
 /* FIXME: move internal to library */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 16fd6fa..b8f1b97 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -5059,30 +5059,19 @@ static int _analyze_mda(struct metadata_area *mda, void *baton)
  *  0 - fail
  *  1 - success
  */
-int pv_analyze(struct cmd_context *cmd, const char *pv_name,
+int pv_analyze(struct cmd_context *cmd, struct device *dev,
 	       uint64_t label_sector)
 {
 	struct label *label;
-	struct device *dev;
 	struct lvmcache_info *info;
 
-	dev = dev_cache_get(pv_name, cmd->filter);
-	if (!dev) {
-		log_error("Device %s %s.", pv_name, dev_cache_filtered_reason(pv_name));
-		return 0;
-	}
-
-	/*
-	 * First, scan for LVM labels.
-	 */
-	if (!label_read(dev, &label, label_sector)) {
-		log_error("Could not find LVM label on %s",
-			  pv_name);
+	if (!(label = lvmcache_get_dev_label(dev))) {
+		log_error("Could not find LVM label on %s", dev_name(dev));
 		return 0;
 	}
 
 	log_print("Found label on %s, sector %"PRIu64", type=%.8s",
-		  pv_name, label->sector, label->type);
+		  dev_name(dev), label->sector, label->type);
 
 	/*
 	 * Next, loop through metadata areas
diff --git a/tools/lvmdiskscan.c b/tools/lvmdiskscan.c
index 7e2fc88..772694c 100644
--- a/tools/lvmdiskscan.c
+++ b/tools/lvmdiskscan.c
@@ -97,6 +97,9 @@ int lvmdiskscan(struct cmd_context *cmd, int argc __attribute__((unused)),
 	if (arg_is_set(cmd, lvmpartition_ARG))
 		log_warn("WARNING: only considering LVM devices");
 
+	/* Call before using dev_iter which uses filters which want bcache data. */
+	label_scan(cmd);
+
 	max_len = _get_max_dev_name_len(cmd->full_filter);
 
 	if (!(iter = dev_iter_create(cmd->full_filter, 0))) {
@@ -104,8 +107,6 @@ int lvmdiskscan(struct cmd_context *cmd, int argc __attribute__((unused)),
 		return ECMD_FAILED;
 	}
 
-	label_scan(cmd);
-
 	for (dev = dev_iter_get(iter); dev; dev = dev_iter_get(iter)) {
 		if (lvmcache_has_dev_info(dev)) {
 			if (!dev_get_size(dev, &size)) {
diff --git a/tools/pvck.c b/tools/pvck.c
index 634b38d..5d3c7d1 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -17,27 +17,51 @@
 
 int pvck(struct cmd_context *cmd, int argc, char **argv)
 {
+	struct dm_list devs;
+	struct device_list *devl;
+	struct device *dev;
+	const char *pv_name;
+	uint64_t labelsector;
 	int i;
 	int ret_max = ECMD_PROCESSED;
 
 	/* FIXME: validate cmdline options */
 	/* FIXME: what does the cmdline look like? */
 
-	label_scan_setup_bcache();
+	labelsector = arg_uint64_value(cmd, labelsector_ARG, UINT64_C(0));
 
-	/*
-	 * Use what's on the cmdline directly, and avoid calling into
-	 * some of the other infrastructure functions, so as to avoid
-	 * hitting some of the lvmcache behavior, scanning other devices,
-	 * etc.
-	 */
-	for (i = 0; i < argc; i++) {
-		/* FIXME: warning and/or check if in use? */
-		log_verbose("Scanning %s", argv[i]);
+	if (labelsector) {
+		/* FIXME: see label_read_sector */
+		log_error("TODO: reading label from non-zero sector");
+		return ECMD_FAILED;
+	}
+
+	dm_list_init(&devs);
 
+	for (i = 0; i < argc; i++) {
 		dm_unescape_colons_and_at_signs(argv[i], NULL, NULL);
-		if (!pv_analyze(cmd, argv[i],
-				arg_uint64_value(cmd, labelsector_ARG, UINT64_C(0)))) {
+
+		pv_name = argv[i];
+
+		dev = dev_cache_get(pv_name, cmd->filter);
+
+		if (!dev) {
+			log_error("Device %s %s.", pv_name, dev_cache_filtered_reason(pv_name));
+			continue;
+		}
+
+		if (!(devl = dm_zalloc(sizeof(*devl))))
+			continue;
+
+		devl->dev = dev;
+		dm_list_add(&devs, &devl->list);
+	}
+
+	label_scan_setup_bcache();
+	label_scan_devs(cmd, cmd->filter, &devs);
+
+	dm_list_iterate_items(devl, &devs) {
+		if (!pv_analyze(cmd, devl->dev, labelsector)) {
 			stack;
 			ret_max = ECMD_FAILED;
 		}
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 73605a8..0af9d49 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -147,6 +147,9 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 	pp.pv_count = argc;
 	pp.pv_names = argv;
 
+	/* Check for old md signatures at the end of devices. */
+	cmd->use_full_md_check = 1;
+
 	/*
 	 * Needed to change the set of orphan PVs.
 	 * (disable afterward to prevent process_each_pv from doing
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 5796309..f1f1f8a 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -302,6 +302,7 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 	struct dm_list found_vgnames;
 	struct device *dev;
 	struct device_list *devl;
+	struct dev_filter *f;
 	const char *pv_name;
 	const char *reason = NULL;
 	int32_t major = -1;
@@ -439,6 +440,9 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 		cmd->pvscan_cache_single = 1;
 	}
 
+	/* Creates a list of dev names from /dev, sysfs, etc; does not read any. */
+	dev_cache_scan();
+
 	dm_list_init(&single_devs);
 
 	while (argc--) {
@@ -455,7 +459,11 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 					ret = ECMD_FAILED;
 				}
 			} else {
-				/* Add device path to lvmetad. */
+				/*
+				 * Scan device.  This dev could still be
+				 * removed from lvmetad below if it doesn't
+				 * pass other filters.
+				 */
 				log_debug("Scanning dev %s for lvmetad cache.", pv_name);
 
 				if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
@@ -476,7 +484,11 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 				if (!_lvmetad_clear_dev(devno, major, minor))
 					remove_errors++;
 			} else {
-				/* Add major:minor to lvmetad. */
+				/*
+				 * Scan device.  This dev could still be
+				 * removed from lvmetad below if it doesn't
+				 * pass other filters.
+				 */
 				log_debug("Scanning dev %d:%d for lvmetad cache.", major, minor);
 
 				if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
@@ -493,11 +505,25 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (!dm_list_empty(&single_devs)) {
-		dev_cache_scan();
-		label_scan_devs(cmd, &single_devs);
+		label_scan_devs(cmd, cmd->lvmetad_filter, &single_devs);
+
+		f = cmd->lvmetad_filter;
 
 		dm_list_iterate_items(devl, &single_devs) {
-			if (!lvmetad_pvscan_single(cmd, devl->dev, &found_vgnames, &pp.changed_vgnames))
+			dev = devl->dev;
+
+			if (dev->flags & DEV_FILTER_OUT_SCAN) {
+				log_debug("Removing dev %s from lvmetad cache after scan.", dev_name(dev));
+				if (!_lvmetad_clear_dev(dev->dev, MAJOR(dev->dev), MINOR(dev->dev)))
+					remove_errors++;
+				continue;
+			}
+
+			/*
+			 * Devices that exist and pass the lvmetad filter
+			 * are added to lvmetad.
+			 */
+			if (!lvmetad_pvscan_single(cmd, dev, &found_vgnames, &pp.changed_vgnames))
 				add_errors++;
 		}
 	}
@@ -539,10 +565,24 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (!dm_list_empty(&single_devs)) {
-		dev_cache_scan();
-		label_scan_devs(cmd, &single_devs);
+		label_scan_devs(cmd, cmd->lvmetad_filter, &single_devs);
+
+		f = cmd->lvmetad_filter;
 
 		dm_list_iterate_items(devl, &single_devs) {
+			dev = devl->dev;
+
+			if (dev->flags & DEV_FILTER_OUT_SCAN) {
+				log_debug("Removing dev %s from lvmetad cache after scan.", dev_name(dev));
+				if (!_lvmetad_clear_dev(dev->dev, MAJOR(dev->dev), MINOR(dev->dev)))
+					remove_errors++;
+				continue;
+			}
+
+			/*
+			 * Devices that exist and pass the lvmetad filter
+			 * are added to lvmetad.
+			 */
 			if (!lvmetad_pvscan_single(cmd, devl->dev, &found_vgnames, &pp.changed_vgnames))
 				add_errors++;
 		}
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 0c4c428..e9f9073 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -65,6 +65,9 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 	cmd->lockd_gl_disable = 1;
 
+	/* Check for old md signatures at the end of devices. */
+	cmd->use_full_md_check = 1;
+
 	/*
 	 * Check if the VG name already exists.  This should be done before
 	 * creating PVs on any of the devices.
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 35168e9..5287a36 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -154,6 +154,9 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	/* pvcreate within vgextend cannot be forced. */
 	pp->force = 0;
 
+	/* Check for old md signatures at the end of devices. */
+	cmd->use_full_md_check = 1;
+
 	/*
 	 * Needed to change the set of orphan PVs.
 	 * (disable afterward to prevent process_each_pv from doing


