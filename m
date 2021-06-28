From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 28 Jun 2021 18:42:28 +0000 (GMT)
Subject: master - vdo: support vdo_pool_header_size
Message-ID: <20210628184228.D5D633988426@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2c6a2b6e86b57aeb96e93618193426ee129b00a6
Commit:        2c6a2b6e86b57aeb96e93618193426ee129b00a6
Parent:        5fcbc3bd7d3473f14e556508fff1b381431c59f0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 28 17:53:08 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 28 20:41:07 2021 +0200

vdo: support vdo_pool_header_size

Add profilable configurable setting for vdo pool header size, that is
used as 'extra' empty space at the front and end of vdo-pool device
to avoid having a disk in the system the may have same data is real
vdo LV.

For some conversion cases however we may need to allow using '0' header size.

TODO: in this case we may eventually avoid adding 'linear' mapping layer
in future - but this requires further modification over lvm code base.
---
 conf/example.conf.in             |  5 +++++
 lib/config/config_settings.h     |  3 +++
 lib/config/defaults.h            |  3 +--
 lib/metadata/lv_manip.c          |  3 ++-
 lib/metadata/metadata-exported.h |  5 ++++-
 lib/metadata/vdo_manip.c         | 13 ++++++++-----
 tools/lvconvert.c                |  6 ++++--
 tools/lvcreate.c                 |  2 +-
 8 files changed, 28 insertions(+), 12 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 16b49a495..50cf6f42b 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -733,6 +733,11 @@ allocation {
 	# The default and minimum is 1. The maximum is UINT_MAX / 4096.
 	# This configuration option has an automatic default value.
 	# vdo_max_discard = 1
+
+	# Configuration option allocation/vdo_pool_header_size.
+	# Specified the emptry header size in KiB at the front and end of vdo pool device.
+	# This configuration option has an automatic default value.
+	# vdo_pool_header_size = 512
 }
 
 # Configuration section log.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index fe14a1eb2..d66a9a3a7 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -816,6 +816,9 @@ cfg(allocation_vdo_max_discard_CFG, "vdo_max_discard", allocation_CFG_SECTION, C
 	"increased latency for the individual discard requests.\n"
 	"The default and minimum is 1. The maximum is UINT_MAX / 4096.\n")
 
+cfg(allocation_vdo_pool_header_size_CFG, "vdo_pool_header_size", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_POOL_HEADER_SIZE_KB, vsn(2, 3, 12), NULL, 0, NULL,
+	"Specified the emptry header size in KiB at the front and end of vdo pool device.\n")
+
 cfg(log_report_command_log_CFG, "report_command_log", log_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED | CFG_DISALLOW_INTERACTIVE, CFG_TYPE_BOOL, DEFAULT_COMMAND_LOG_REPORT, vsn(2, 2, 158), NULL, 0, NULL,
 	"Enable or disable LVM log reporting.\n"
 	"If enabled, LVM will collect a log of operations, messages,\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 2870dee12..d5e5b3b1a 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -181,8 +181,7 @@
  * VDO pool will reverve some sectors in the front and the back of pool device to avoid
  * seeing same device twice in the system.
  */
-#define DEFAULT_VDO_POOL_HEADER_SIZE  (1024)   // 512KiB
-
+#define DEFAULT_VDO_POOL_HEADER_SIZE_KB  (512)
 
 
 #define DEFAULT_FSADM_PATH FSADM_PATH
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index eb92d6eca..7e66afd9c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -8739,7 +8739,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	}
 
 	if (seg_is_vdo_pool(lp)) {
-		if (!convert_vdo_pool_lv(lv, &lp->vdo_params, &lp->virtual_extents, 1)) {
+		if (!convert_vdo_pool_lv(lv, &lp->vdo_params, &lp->virtual_extents,
+					 1, lp->vdo_pool_header_size)) {
 			stack;
 			goto deactivate_and_revert_new_lv;
 		}
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 9ac3c677e..96a9533d2 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1034,6 +1034,7 @@ struct lvcreate_params {
 	int approx_alloc;     /* all */
 	alloc_policy_t alloc; /* all */
 	struct dm_vdo_target_params vdo_params; /* vdo */
+	uint64_t vdo_pool_header_size; /* VDO */
 
 	int raidintegrity;
 	const char *raidintegritymode;
@@ -1368,10 +1369,12 @@ int parse_vdo_pool_status(struct dm_pool *mem, const struct logical_volume *vdo_
 struct logical_volume *convert_vdo_pool_lv(struct logical_volume *data_lv,
 					   const struct dm_vdo_target_params *vtp,
 					   uint32_t *virtual_extents,
-					   int format);
+					   int format,
+					   uint64_t vdo_pool_header_size);
 int set_vdo_write_policy(enum dm_vdo_write_policy *vwp, const char *policy);
 int fill_vdo_target_params(struct cmd_context *cmd,
 			   struct dm_vdo_target_params *vtp,
+			   uint64_t *vdo_pool_header_size,
 			   struct profile *profile);
 /* --  metadata/vdo_manip.c */
 
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index afc513ae5..3f2de1a01 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -356,9 +356,9 @@ static int _format_vdo_pool_data_lv(struct logical_volume *data_lv,
 struct logical_volume *convert_vdo_pool_lv(struct logical_volume *data_lv,
 					   const struct dm_vdo_target_params *vtp,
 					   uint32_t *virtual_extents,
-					   int format)
+					   int format,
+					   uint64_t vdo_pool_header_size)
 {
-	const uint64_t header_size = DEFAULT_VDO_POOL_HEADER_SIZE;
 	const uint32_t extent_size = data_lv->vg->extent_size;
 	struct cmd_context *cmd = data_lv->vg->cmd;
 	struct logical_volume *vdo_pool_lv = data_lv;
@@ -379,7 +379,7 @@ struct logical_volume *convert_vdo_pool_lv(struct logical_volume *data_lv,
 
 	if (*virtual_extents)
 		vdo_logical_size =
-			_get_virtual_size(*virtual_extents, extent_size, header_size);
+			_get_virtual_size(*virtual_extents, extent_size, vdo_pool_header_size);
 
 	if (!dm_vdo_validate_target_params(vtp, vdo_logical_size))
 		return_0;
@@ -403,7 +403,7 @@ struct logical_volume *convert_vdo_pool_lv(struct logical_volume *data_lv,
 		return NULL;
 	}
 
-	vdo_logical_size -= 2 * header_size;
+	vdo_logical_size -= 2 * vdo_pool_header_size;
 
 	if (vdo_logical_size < extent_size) {
 		if (!*virtual_extents)
@@ -426,7 +426,7 @@ struct logical_volume *convert_vdo_pool_lv(struct logical_volume *data_lv,
 	vdo_pool_seg = first_seg(vdo_pool_lv);
 	vdo_pool_seg->segtype = vdo_pool_segtype;
 	vdo_pool_seg->vdo_params = *vtp;
-	vdo_pool_seg->vdo_pool_header_size = DEFAULT_VDO_POOL_HEADER_SIZE;
+	vdo_pool_seg->vdo_pool_header_size = vdo_pool_header_size;
 	vdo_pool_seg->vdo_pool_virtual_extents = *virtual_extents;
 
 	vdo_pool_lv->status |= LV_VDO_POOL;
@@ -453,6 +453,7 @@ int set_vdo_write_policy(enum dm_vdo_write_policy *vwp, const char *policy)
 
 int fill_vdo_target_params(struct cmd_context *cmd,
 			   struct dm_vdo_target_params *vtp,
+			   uint64_t *vdo_pool_header_size,
 			   struct profile *profile)
 {
 	const char *policy;
@@ -501,5 +502,7 @@ int fill_vdo_target_params(struct cmd_context *cmd,
 	if (!set_vdo_write_policy(&vtp->write_policy, policy))
 		return_0;
 
+	*vdo_pool_header_size = 2 * find_config_tree_int64(cmd, allocation_vdo_pool_header_size_CFG, profile);
+
 	return 1;
 }
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 19b3c587e..7fbe84952 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5405,6 +5405,7 @@ static int _lvconvert_to_vdopool_single(struct cmd_context *cmd,
 {
 	const char *vg_name = NULL;
 	unsigned int vdo_pool_zero;
+	uint64_t vdo_pool_header_size;
 	struct volume_group *vg = lv->vg;
 	struct logical_volume *vdo_lv;
 	struct dm_vdo_target_params vdo_params; /* vdo */
@@ -5447,7 +5448,7 @@ static int _lvconvert_to_vdopool_single(struct cmd_context *cmd,
 		goto out;
 	}
 
-	if (!fill_vdo_target_params(cmd, &vdo_params, vg->profile))
+	if (!fill_vdo_target_params(cmd, &vdo_params, &vdo_pool_header_size, vg->profile))
 		goto_out;
 
 	if (arg_is_set(cmd, compression_ARG))
@@ -5489,7 +5490,8 @@ static int _lvconvert_to_vdopool_single(struct cmd_context *cmd,
 		}
 	}
 
-	if (!convert_vdo_pool_lv(lv, &vdo_params, &lvc.virtual_extents, vdo_pool_zero))
+	if (!convert_vdo_pool_lv(lv, &vdo_params, &lvc.virtual_extents,
+				 vdo_pool_zero, vdo_pool_header_size))
 		goto_out;
 
 	dm_list_init(&lvc.tags);
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index a28f0931e..0def23639 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1097,7 +1097,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 
 		// FIXME: prefiling here - this is wrong place
 		// but will work for this moment
-		if (!fill_vdo_target_params(cmd, &lp->vdo_params, NULL))
+		if (!fill_vdo_target_params(cmd, &lp->vdo_params, &lp->vdo_pool_header_size, NULL))
 			return_0;
 
 		if (arg_is_set(cmd, compression_ARG))


