From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 12 Jun 2013 11:16:49 +0000 (UTC)
Subject: master - cleanup: use libdm's dm_sysfs_dir() for sysfs directory throughout
Message-ID: <20130612111649.A49F860F27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=657abb08e0e509e084d23d8b4dcf6248362cccd4
Commit:        657abb08e0e509e084d23d8b4dcf6248362cccd4
Parent:        bb70b38021992dd462a94d40527a315ce1e692fd
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 12 11:38:48 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 12 11:44:58 2013 +0200

cleanup: use libdm's dm_sysfs_dir() for sysfs directory throughout

And remove superfluous cmd->sysfs_dir and
set_sysfs_dir_path/sysfs_dir_path fn from lvm-globals.[ch].
---
 lib/commands/toolcontext.c |   18 ++++++------
 lib/commands/toolcontext.h |    1 -
 lib/device/dev-md.c        |   14 +++++-----
 lib/device/device.c        |   59 +++++++++++++++----------------------------
 lib/device/device.h        |   24 +++++------------
 lib/filters/filter-mpath.c |    5 ++-
 lib/filters/filter-mpath.h |    2 +-
 lib/filters/filter-sysfs.c |    3 +-
 lib/filters/filter-sysfs.h |    2 +-
 lib/filters/filter.c       |    2 +-
 lib/metadata/metadata.c    |    9 +++---
 lib/metadata/pv_manip.c    |    4 +-
 12 files changed, 58 insertions(+), 85 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index c409f2a..dca2329 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -79,14 +79,15 @@ static int _get_env_vars(struct cmd_context *cmd)
 	return 1;
 }
 
-static void _get_sysfs_dir(struct cmd_context *cmd)
+static void _get_sysfs_dir(struct cmd_context *cmd, char *buf, size_t buf_size)
 {
 	static char proc_mounts[PATH_MAX];
 	static char *split[4], buffer[PATH_MAX + 16];
 	FILE *fp;
 	char *sys_mnt = NULL;
 
-	cmd->sysfs_dir[0] = '\0';
+	*buf = '\0';
+
 	if (!*cmd->proc_dir) {
 		log_debug("No proc filesystem found: skipping sysfs detection");
 		return;
@@ -119,7 +120,7 @@ static void _get_sysfs_dir(struct cmd_context *cmd)
 		return;
 	}
 
-	strncpy(cmd->sysfs_dir, sys_mnt, sizeof(cmd->sysfs_dir));
+	strncpy(buf, sys_mnt, buf_size);
 }
 
 static int _parse_debug_classes(struct cmd_context *cmd)
@@ -272,6 +273,7 @@ static int _process_config(struct cmd_context *cmd)
 	int64_t pv_min_kb;
 	const char *lvmetad_socket;
 	int udev_disabled = 0;
+	char sysfs_dir[PATH_MAX];
 
 	if (!config_def_check(cmd, 0, 0, 0) && find_config_tree_bool(cmd, config_abort_on_errors_CFG)) {
 		log_error("LVM configuration invalid.");
@@ -312,10 +314,8 @@ static int _process_config(struct cmd_context *cmd)
 		cmd->proc_dir[0] = '\0';
 	}
 
-	/* FIXME Use global value of sysfs_dir everywhere instead cmd->sysfs_dir. */
-	_get_sysfs_dir(cmd);
-	set_sysfs_dir_path(cmd->sysfs_dir);
-	dm_set_sysfs_dir(cmd->sysfs_dir);
+	_get_sysfs_dir(cmd, sysfs_dir, sizeof(sysfs_dir));
+	dm_set_sysfs_dir(sysfs_dir);
 
 	/* activation? */
 	cmd->default_settings.activation = find_config_tree_bool(cmd, global_activation_CFG);
@@ -804,7 +804,7 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 	 * unavailable devices.
 	 */
 	if (find_config_tree_bool(cmd, devices_sysfs_scan_CFG)) {
-		if ((filters[nr_filt] = sysfs_filter_create(cmd->sysfs_dir)))
+		if ((filters[nr_filt] = sysfs_filter_create()))
 			nr_filt++;
 	}
 
@@ -836,7 +836,7 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 
 	/* mpath component filter. Optional, non-critical. */
 	if (find_config_tree_bool(cmd, devices_multipath_component_detection_CFG)) {
-		if ((filters[nr_filt] = mpath_filter_create(cmd->sysfs_dir)))
+		if ((filters[nr_filt] = mpath_filter_create()))
 			nr_filt++;
 	}
 
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index b79ebe2..307dc77 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -113,7 +113,6 @@ struct cmd_context {
 	char system_dir[PATH_MAX];
 	char dev_dir[PATH_MAX];
 	char proc_dir[PATH_MAX];
-	char sysfs_dir[PATH_MAX]; /* FIXME Use global value instead. */
 };
 
 /*
diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 247a8ac..c4e2316 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -127,10 +127,10 @@ out:
 }
 
 static int _md_sysfs_attribute_snprintf(char *path, size_t size,
-					const char *sysfs_dir,
 					struct device *blkdev,
 					const char *attribute)
 {
+	const char *sysfs_dir = dm_sysfs_dir();
 	struct stat info;
 	dev_t dev = blkdev->dev;
 	int ret = -1;
@@ -140,7 +140,7 @@ static int _md_sysfs_attribute_snprintf(char *path, size_t size,
 
 	if (MAJOR(dev) == blkext_major()) {
 		/* lookup parent MD device from blkext partition */
-		if (!get_primary_dev(sysfs_dir, blkdev, &dev))
+		if (!get_primary_dev(blkdev, &dev))
 			return ret;
 	}
 
@@ -181,8 +181,8 @@ static int _md_sysfs_attribute_scanf(const char *sysfs_dir,
 	FILE *fp;
 	int ret = 0;
 
-	if (_md_sysfs_attribute_snprintf(path, PATH_MAX, sysfs_dir,
-					 dev, attribute_name) < 0)
+	if (_md_sysfs_attribute_snprintf(path, PATH_MAX, dev,
+					 attribute_name) < 0)
 		return ret;
 
 	if (!(fp = fopen(path, "r"))) {
@@ -271,8 +271,9 @@ static int dev_md_raid_disks(const char *sysfs_dir, struct device *dev)
 /*
  * Calculate stripe width of md device using its sysfs files.
  */
-unsigned long dev_md_stripe_width(const char *sysfs_dir, struct device *dev)
+unsigned long dev_md_stripe_width(struct device *dev)
 {
+	const char *sysfs_dir = dm_sysfs_dir();
 	unsigned long chunk_size_sectors = 0UL;
 	unsigned long stripe_width_sectors = 0UL;
 	int level, raid_disks, data_disks;
@@ -332,8 +333,7 @@ int dev_is_md(struct device *dev __attribute__((unused)),
 	return 0;
 }
 
-unsigned long dev_md_stripe_width(const char *sysfs_dir __attribute__((unused)),
-				  struct device *dev  __attribute__((unused)))
+unsigned long dev_md_stripe_width(struct device *dev  __attribute__((unused)))
 {
 	return 0UL;
 }
diff --git a/lib/device/device.c b/lib/device/device.c
index a87ae7f..52eb4a6 100644
--- a/lib/device/device.c
+++ b/lib/device/device.c
@@ -278,9 +278,9 @@ int _get_partition_type(struct dev_mgr *dm, struct device *d)
 
 #ifdef linux
 
-int get_primary_dev(const char *sysfs_dir,
-		    const struct device *dev, dev_t *result)
+int get_primary_dev(const struct device *dev, dev_t *result)
 {
+	const char *sysfs_dir = dm_sysfs_dir();
 	char path[PATH_MAX+1];
 	char temp_path[PATH_MAX+1];
 	char buffer[64];
@@ -357,10 +357,9 @@ out:
 	return ret;
 }
 
-static unsigned long _dev_topology_attribute(const char *attribute,
-					     const char *sysfs_dir,
-					     struct device *dev)
+static unsigned long _dev_topology_attribute(const char *attribute, struct device *dev)
 {
+	const char *sysfs_dir = dm_sysfs_dir();
 	static const char sysfs_fmt_str[] = "%s/dev/block/%d:%d/%s";
 	char path[PATH_MAX+1], buffer[64];
 	FILE *fp;
@@ -391,7 +390,7 @@ static unsigned long _dev_topology_attribute(const char *attribute,
 			log_sys_error("stat", path);
 			return 0;
 		}
-		if (!get_primary_dev(sysfs_dir, dev, &primary))
+		if (!get_primary_dev(dev, &primary))
 			return 0;
 
 		/* get attribute from partition's primary device */
@@ -434,75 +433,59 @@ out:
 	return result >> SECTOR_SHIFT;
 }
 
-unsigned long dev_alignment_offset(const char *sysfs_dir,
-				   struct device *dev)
+unsigned long dev_alignment_offset(struct device *dev)
 {
-	return _dev_topology_attribute("alignment_offset",
-				       sysfs_dir, dev);
+	return _dev_topology_attribute("alignment_offset", dev);
 }
 
-unsigned long dev_minimum_io_size(const char *sysfs_dir,
-				  struct device *dev)
+unsigned long dev_minimum_io_size(struct device *dev)
 {
-	return _dev_topology_attribute("queue/minimum_io_size",
-				       sysfs_dir, dev);
+	return _dev_topology_attribute("queue/minimum_io_size", dev);
 }
 
-unsigned long dev_optimal_io_size(const char *sysfs_dir,
-				  struct device *dev)
+unsigned long dev_optimal_io_size(struct device *dev)
 {
-	return _dev_topology_attribute("queue/optimal_io_size",
-				       sysfs_dir, dev);
+	return _dev_topology_attribute("queue/optimal_io_size", dev);
 }
 
-unsigned long dev_discard_max_bytes(const char *sysfs_dir,
-				    struct device *dev)
+unsigned long dev_discard_max_bytes(struct device *dev)
 {
-	return _dev_topology_attribute("queue/discard_max_bytes",
-				       sysfs_dir, dev);
+	return _dev_topology_attribute("queue/discard_max_bytes", dev);
 }
 
-unsigned long dev_discard_granularity(const char *sysfs_dir,
-				      struct device *dev)
+unsigned long dev_discard_granularity(struct device *dev)
 {
-	return _dev_topology_attribute("queue/discard_granularity",
-				       sysfs_dir, dev);
+	return _dev_topology_attribute("queue/discard_granularity", dev);
 }
 
 #else
 
-int get_primary_dev(const char *sysfs_dir,
-		    struct device *dev, dev_t *result)
+int get_primary_dev(struct device *dev, dev_t *result)
 {
 	return 0;
 }
 
-unsigned long dev_alignment_offset(const char *sysfs_dir,
-				   struct device *dev)
+unsigned long dev_alignment_offset(struct device *dev)
 {
 	return 0UL;
 }
 
-unsigned long dev_minimum_io_size(const char *sysfs_dir,
-				  struct device *dev)
+unsigned long dev_minimum_io_size(struct device *dev)
 {
 	return 0UL;
 }
 
-unsigned long dev_optimal_io_size(const char *sysfs_dir,
-				  struct device *dev)
+unsigned long dev_optimal_io_size(struct device *dev)
 {
 	return 0UL;
 }
 
-unsigned long dev_discard_max_bytes(const char *sysfs_dir,
-				    struct device *dev)
+unsigned long dev_discard_max_bytes(struct device *dev)
 {
 	return 0UL;
 }
 
-unsigned long dev_discard_granularity(const char *sysfs_dir,
-				      struct device *dev)
+unsigned long dev_discard_granularity(struct device *dev)
 {
 	return 0UL;
 }
diff --git a/lib/device/device.h b/lib/device/device.h
index 8c32a03..025d4ca 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -103,26 +103,16 @@ const char *dev_name_confirmed(struct device *dev, int quiet);
 int dev_is_md(struct device *dev, uint64_t *sb);
 int dev_is_swap(struct device *dev, uint64_t *signature);
 int dev_is_luks(struct device *dev, uint64_t *signature);
-unsigned long dev_md_stripe_width(const char *sysfs_dir, struct device *dev);
+unsigned long dev_md_stripe_width(struct device *dev);
 
 int is_partitioned_dev(struct device *dev);
 
-int get_primary_dev(const char *sysfs_dir,
-		    const struct device *dev, dev_t *result);
+int get_primary_dev(const struct device *dev, dev_t *result);
 
-unsigned long dev_alignment_offset(const char *sysfs_dir,
-				   struct device *dev);
-
-unsigned long dev_minimum_io_size(const char *sysfs_dir,
-				  struct device *dev);
-
-unsigned long dev_optimal_io_size(const char *sysfs_dir,
-				  struct device *dev);
-
-unsigned long dev_discard_max_bytes(const char *sysfs_dir,
-				    struct device *dev);
-
-unsigned long dev_discard_granularity(const char *sysfs_dir,
-				      struct device *dev);
+unsigned long dev_alignment_offset(struct device *dev);
+unsigned long dev_minimum_io_size(struct device *dev);
+unsigned long dev_optimal_io_size(struct device *dev);
+unsigned long dev_discard_max_bytes(struct device *dev);
+unsigned long dev_discard_granularity(struct device *dev);
 
 #endif
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 2d171e6..f3af268 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -119,7 +119,7 @@ static int dev_is_mpath(struct dev_filter *f, struct device *dev)
 	char path[PATH_MAX+1];
 	char parent_name[PATH_MAX+1];
 	struct stat info;
-	const char *sysfs_dir = f->private;
+	const char *sysfs_dir = dm_sysfs_dir();
 	int major, minor;
 
 	/* Limit this filter only to SCSI devices */
@@ -176,8 +176,9 @@ static void _destroy(struct dev_filter *f)
 	dm_free(f);
 }
 
-struct dev_filter *mpath_filter_create(const char *sysfs_dir)
+struct dev_filter *mpath_filter_create(void)
 {
+	const char *sysfs_dir = dm_sysfs_dir();
 	struct dev_filter *f;
 
 	if (!*sysfs_dir) {
diff --git a/lib/filters/filter-mpath.h b/lib/filters/filter-mpath.h
index 0b5373f..31585eb 100644
--- a/lib/filters/filter-mpath.h
+++ b/lib/filters/filter-mpath.h
@@ -17,7 +17,7 @@
 
 #include "dev-cache.h"
 
-struct dev_filter *mpath_filter_create(const char *sysfs_dir);
+struct dev_filter *mpath_filter_create(void);
 
 #endif
 
diff --git a/lib/filters/filter-sysfs.c b/lib/filters/filter-sysfs.c
index a075f36..cd039c0 100644
--- a/lib/filters/filter-sysfs.c
+++ b/lib/filters/filter-sysfs.c
@@ -290,8 +290,9 @@ static void _destroy(struct dev_filter *f)
 	dm_pool_destroy(ds->mem);
 }
 
-struct dev_filter *sysfs_filter_create(const char *sysfs_dir)
+struct dev_filter *sysfs_filter_create(void)
 {
+	const char *sysfs_dir = dm_sysfs_dir();
 	char sys_block[PATH_MAX];
 	unsigned sysfs_depth;
 	struct dm_pool *mem;
diff --git a/lib/filters/filter-sysfs.h b/lib/filters/filter-sysfs.h
index 9e4f503..6fb5591 100644
--- a/lib/filters/filter-sysfs.h
+++ b/lib/filters/filter-sysfs.h
@@ -18,6 +18,6 @@
 #include "config.h"
 #include "dev-cache.h"
 
-struct dev_filter *sysfs_filter_create(const char *sysfs_dir);
+struct dev_filter *sysfs_filter_create(void);
 
 #endif
diff --git a/lib/filters/filter.c b/lib/filters/filter.c
index 7925440..d3fdd6e 100644
--- a/lib/filters/filter.c
+++ b/lib/filters/filter.c
@@ -76,7 +76,7 @@ int dev_subsystem_part_major(const struct device *dev)
 		return 1;
 
 	if ((MAJOR(dev->dev) == _blkext_major) &&
-	    (get_primary_dev(sysfs_dir_path(), dev, &primary_dev)) &&
+	    (get_primary_dev(dev, &primary_dev)) &&
 	    (MAJOR(primary_dev) == _md_major))
 		return 1;
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d25fe01..4e52bd4 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -84,7 +84,7 @@ unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignm
 	 * Align to stripe-width of underlying md device if present
 	 */
 	if (find_config_tree_bool(pv->fmt->cmd, devices_md_chunk_alignment_CFG)) {
-		temp_pe_align = dev_md_stripe_width(pv->fmt->cmd->sysfs_dir, pv->dev);
+		temp_pe_align = dev_md_stripe_width(pv->dev);
 		if (_alignment_overrides_default(temp_pe_align, default_pe_align))
 			pv->pe_align = temp_pe_align;
 	}
@@ -97,11 +97,11 @@ unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignm
 	 *   (e.g. MD's stripe width)
 	 */
 	if (find_config_tree_bool(pv->fmt->cmd, devices_data_alignment_detection_CFG)) {
-		temp_pe_align = dev_minimum_io_size(pv->fmt->cmd->sysfs_dir, pv->dev);
+		temp_pe_align = dev_minimum_io_size(pv->dev);
 		if (_alignment_overrides_default(temp_pe_align, default_pe_align))
 			pv->pe_align = temp_pe_align;
 
-		temp_pe_align = dev_optimal_io_size(pv->fmt->cmd->sysfs_dir, pv->dev);
+		temp_pe_align = dev_optimal_io_size(pv->dev);
 		if (_alignment_overrides_default(temp_pe_align, default_pe_align))
 			pv->pe_align = temp_pe_align;
 	}
@@ -129,8 +129,7 @@ unsigned long set_pe_align_offset(struct physical_volume *pv,
 		goto out;
 
 	if (find_config_tree_bool(pv->fmt->cmd, devices_data_alignment_offset_detection_CFG)) {
-		int align_offset = dev_alignment_offset(pv->fmt->cmd->sysfs_dir,
-							pv->dev);
+		int align_offset = dev_alignment_offset(pv->dev);
 		/* must handle a -1 alignment_offset; means dev is misaligned */
 		if (align_offset < 0)
 			align_offset = 0;
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 4a65a3e..ae453ae 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -216,8 +216,8 @@ int discard_pv_segment(struct pv_segment *peg, uint32_t discard_area_reduction)
 		return 1;
 	}
 
-	if (!dev_discard_max_bytes(peg->pv->fmt->cmd->sysfs_dir, peg->pv->dev) ||
-	    !dev_discard_granularity(peg->pv->fmt->cmd->sysfs_dir, peg->pv->dev))
+	if (!dev_discard_max_bytes(peg->pv->dev) ||
+	    !dev_discard_granularity(peg->pv->dev))
 		return 1;
 
 	discard_offset_sectors = (peg->pe + peg->lvseg->area_len - discard_area_reduction) *


