From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Jun 2020 16:40:09 +0000 (GMT)
Subject: master - lvconvert: single step cachevol creation and attachment
Message-ID: <20200622164009.D884A3851C07@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=21b37964eb88d404998e37acae5530ec102a2116
Commit:        21b37964eb88d404998e37acae5530ec102a2116
Parent:        950d2d59c140c82fea35e56d34c92289562d4d6f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 5 13:42:36 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 16 13:46:51 2020 -0500

lvconvert: single step cachevol creation and attachment

To add a cache or writecache to a main LV with a single command:

lvconvert --type cache|writecache --cachedevice /dev/ssd vg/main

A cachevol LV will be allocated from the specified cache device,
then attached to the main LV.  Include --cachesize to specify the
size of cachevol to create, otherwise the entire cachedevice is
used.  The cachedevice option can be repeated to create a cachevol
from multiple devices.

Example
-------

A user has an existing main LV that they want to speed up
using a new ssd.

user adds the new ssd to the VG:

$ vgextend vg /dev/ssd

user attaches the new ssd their main LV:

$ lvconvert --type writecache --cachedevice /dev/ssd vg/main

Example
-------

A user has two existing main LVs that they want to speed up
with a new ssd.

user adds the new 16G ssd to the VG:

$ vgextend vg /dev/ssd

user attaches some of the new ssd to the first main LV,
using half of the space:

$ lvconvert --type writecache --cachedevice /dev/ssd
    --cachesize 8G vg/main1

user attaches some of the new ssd to the second main LV,
using the other half of the space:

$ lvconvert --type writecache --cachedevice /dev/ssd
    --cachesize 8G vg/main2

Example
-------

A user has an existing main LV that they want to speed up using
two new ssds.

user adds the new two ssds the VG:

$ vgextend vg /dev/ssd1
$ vgextend vg /dev/ssd2

user attaches both ssds their main LV:

$ lvconvert --type writecache
    --cachedevice /dev/ssd1 --cachedevice /dev/ssd2 vg/main
---
 tools/args.h           |   6 ++
 tools/command-lines.in |  14 +++
 tools/lvconvert.c      | 250 +++++++++++++++++++++++++++++++++++++------------
 tools/lvmcmdline.c     |   2 +
 4 files changed, 211 insertions(+), 61 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 5fae21abb..c69a0ecce 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -126,6 +126,12 @@ arg(cachepool_ARG, '\0', "cachepool", lv_VAL, 0, 0,
 arg(cachevol_ARG, '\0', "cachevol", lv_VAL, 0, 0,
     "The name of a cache volume.\n")
 
+arg(cachedevice_ARG, '\0', "cachedevice", pv_VAL, 0, 0,
+    "The name of a device to use for a cache.\n")
+
+arg(cachesize_ARG, '\0', "cachesize", sizemb_VAL, 0, 0,
+    "The size of cache to use.\n")
+
 arg(commandprofile_ARG, '\0', "commandprofile", string_VAL, 0, 0,
     "The command profile to use for command configuration.\n"
     "See \\fBlvm.conf\\fP(5) for more information about profiles.\n")
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 98044a918..8d389b665 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -497,6 +497,20 @@ FLAGS: SECONDARY_SYNTAX
 
 ---
 
+lvconvert --type writecache --cachedevice PV LV
+OO: OO_LVCONVERT, --cachesize SizeMB, --cachesettings String
+ID: lvconvert_to_writecache_with_device
+DESC: Add a writecache to an LV, using a specified cache device.
+RULE: all and lv_is_visible
+
+lvconvert --type cache --cachedevice PV LV
+OO: OO_LVCONVERT, --cachesize SizeMB, --cachesettings String
+ID: lvconvert_to_cache_with_device
+DESC: Add a cache to an LV, using a specified cache device.
+RULE: all and lv_is_visible
+
+---
+
 lvconvert --type thin-pool LV_linear_striped_raid_cache
 OO: --stripes_long Number, --stripesize SizeKB,
 --discards Discards, OO_LVCONVERT_POOL, OO_LVCONVERT
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 94ea70fa5..76a9160f3 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4248,51 +4248,159 @@ int lvconvert_to_pool_cmd(struct cmd_context *cmd, int argc, char **argv)
 			       NULL, NULL, &_lvconvert_to_pool_single);
 }
 
+static int _lv_create_cachevol(struct cmd_context *cmd,
+			       struct volume_group *vg,
+			       struct logical_volume *lv,
+			       const char *dev_name,
+			       struct logical_volume **cachevol_lv)
+{
+	char cvname[NAME_LEN];
+	struct device *dev_fast;
+	struct dm_list *use_pvh;
+	uint64_t cache_size_sectors;
+	struct logical_volume *cachevol;
+	struct pv_list *pvl;
+	struct lvcreate_params lp = {
+		.activate = CHANGE_AN,
+		.alloc = ALLOC_INHERIT,
+		.major = -1,
+		.minor = -1,
+		.permission = LVM_READ | LVM_WRITE,
+		.pvh = &vg->pvs,
+		.read_ahead = DM_READ_AHEAD_NONE,
+		.stripes = 1,
+		.vg_name = vg->name,
+		.zero = 0,
+		.wipe_signatures = 0,
+		.suppress_zero_warn = 1,
+	};
+
+	if (dm_snprintf(cvname, NAME_LEN, "%s_cache", lv->name) < 0) {
+		log_error("Failed to create cachevol LV name.");
+		return 0;
+	}
+
+	if (!(dev_fast = dev_cache_get(cmd, dev_name, cmd->filter))) {
+		log_error("Device %s not found.", dev_name);
+		return 0;
+	}
+
+	if (!(pvl = find_pv_in_vg(vg, dev_name))) {
+		log_error("PV %s not found in VG.", dev_name);
+		return 0;
+	}
+
+	/*
+	 * If fast_dev is used in the VG, then require a cachesize to allocate
+	 * from it.  If fast_dev is not used in the VG, then prompt asking if
+	 * the entire dev should be used.
+	 */
+	if (!(cache_size_sectors = arg_uint64_value(cmd, cachesize_ARG, 0))) {
+		if (pvl->pv->pe_alloc_count) {
+			log_error("PV %s is in use, --cachesize is required.", dev_name);
+			return 0;
+		}
+
+		cache_size_sectors = (pvl->pv->pe_count * vg->extent_size);
+
+		if (!arg_is_set(cmd, yes_ARG) &&
+		    yes_no_prompt("Use all %s from %s for cache? [y/n]: ",
+				  display_size(cmd, cache_size_sectors), dev_name) == 'n') {
+			log_print("Use --cachesize SizeMB to use a part of the cachedevice.");
+			log_error("Conversion aborted.");
+			return 0;
+		}
+	}
+
+	if (!(use_pvh = create_pv_list(cmd->mem, vg, 1, (char **)&dev_name, 1))) {
+		log_error("cachedevice not found in VG %s.", dev_name);
+		return 0;
+	}
+
+	lp.lv_name = cvname;
+	lp.pvh = use_pvh;
+	lp.extents = cache_size_sectors / vg->extent_size;
+
+	log_print("Creating cachevol LV %s with size %s.",
+		  cvname, display_size(cmd, cache_size_sectors));
+
+	dm_list_init(&lp.tags);
+
+	if (!(lp.segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_STRIPED)))
+		return_0;
+
+	if (!(cachevol = lv_create_single(vg, &lp))) {
+		log_error("Failed to create cachevol LV");
+		return 0;
+	}
+
+	*cachevol_lv = cachevol;
+	return 1;
+}
+
 static int _lvconvert_cachevol_attach_single(struct cmd_context *cmd,
 					  struct logical_volume *lv,
 					  struct processing_handle *handle)
 {
 	struct volume_group *vg = lv->vg;
-	struct logical_volume *cachevol_lv;
-	const char *cachevol_name;
+	struct logical_volume *lv_fast;
+	const char *fast_name, *dev_name;
 
-	if (!(cachevol_name = arg_str_value(cmd, cachevol_ARG, NULL)))
-		goto_out;
+	fast_name = arg_str_value(cmd, cachevol_ARG, NULL);
+	dev_name = arg_str_value(cmd, cachedevice_ARG, NULL);
 
-	if (!validate_lvname_param(cmd, &vg->name, &cachevol_name))
-		goto_out;
+	if (!fast_name && !dev_name)
+		goto_bad;
 
-	if (!(cachevol_lv = find_lv(vg, cachevol_name))) {
-		log_error("Cache single %s not found.", cachevol_name);
-		goto out;
-	}
+	if (fast_name && dev_name)
+		goto_bad;
 
-	if (lv_is_cache_vol(cachevol_lv)) {
-		log_error("LV %s is already used as a cachevol.", display_lvname(cachevol_lv));
-		goto out;
-	}
+	/*
+	 * User specifies an existing cachevol to use.
+	 */
+	if (fast_name) {
+		if (!validate_lvname_param(cmd, &vg->name, &fast_name))
+			goto_bad;
 
-	/* Ensure the LV is not active elsewhere. */
-	if (!lockd_lv(cmd, lv, "ex", 0))
-		goto_out;
+		if (!(lv_fast = find_lv(vg, fast_name))) {
+			log_error("LV %s not found.", fast_name);
+			goto bad;
+		}
 
-	if (!dm_list_empty(&cachevol_lv->segs_using_this_lv)) {
-		log_error("LV %s is already in use.", display_lvname(cachevol_lv));
-		goto out;
+		if (lv_is_cache_vol(lv_fast)) {
+			log_error("LV %s is already used as a cachevol.", display_lvname(lv_fast));
+			goto bad;
+		}
+
+		if (!dm_list_empty(&lv_fast->segs_using_this_lv)) {
+			log_error("LV %s is already in use.", display_lvname(lv_fast));
+			goto bad;
+		}
+
+		if (!arg_is_set(cmd, yes_ARG) &&
+		    yes_no_prompt("Erase all existing data on %s? [y/n]: ", display_lvname(lv_fast)) == 'n') {
+			log_error("Conversion aborted.");
+			goto bad;
+		}
+
+		if (!lockd_lv(cmd, lv_fast, "ex", 0))
+			goto_bad;
 	}
 
-	if (!arg_is_set(cmd, yes_ARG) &&
-	    yes_no_prompt("Erase all existing data on %s? [y/n]: ", display_lvname(cachevol_lv)) == 'n') {
-		log_error("Conversion aborted.");
-		goto out;
+	/*
+	 * User specifies a device and lvm creates a cachevol on it.
+	 */
+	if (dev_name) {
+		if (!_lv_create_cachevol(cmd, vg, lv, dev_name, &lv_fast))
+			goto_bad;
 	}
 
 	/* Ensure the LV is not active elsewhere. */
-	if (!lockd_lv(cmd, cachevol_lv, "ex", LDLV_PERSISTENT))
-		goto_out;
+	if (!lockd_lv(cmd, lv, "ex", 0))
+		goto_bad;
 
-	if (!wipe_cache_pool(cachevol_lv))
-		goto_out;
+	if (!wipe_cache_pool(lv_fast))
+		goto_bad;
 
 	/* When the lv arg is a thinpool, redirect command to data sub lv. */
 
@@ -4302,17 +4410,17 @@ static int _lvconvert_cachevol_attach_single(struct cmd_context *cmd,
 	}
 
 	if (_raid_split_image_conversion(lv))
-		goto_out;
+		goto_bad;
 
 	/* Attach the cache to the main LV. */
 
-	if (!_cache_vol_attach(cmd, lv, cachevol_lv))
-		goto_out;
+	if (!_cache_vol_attach(cmd, lv, lv_fast))
+		goto_bad;
 
 	log_print_unless_silent("Logical volume %s is now cached.", display_lvname(lv));
 
 	return ECMD_PROCESSED;
- out:
+ bad:
 	return ECMD_FAILED;
 }
 
@@ -5605,7 +5713,7 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 	struct logical_volume *lv_wcorig;
 	struct logical_volume *lv_fast;
 	struct writecache_settings settings;
-	const char *fast_name;
+	const char *fast_name, *dev_name;
 	uint32_t block_size_sectors = 0;
 	char *lockd_fast_args = NULL;
 	char *lockd_fast_name = NULL;
@@ -5613,32 +5721,58 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 	char cvol_name[NAME_LEN];
 	int is_active;
 
-	fast_name = arg_str_value(cmd, cachevol_ARG, "");
+	fast_name = arg_str_value(cmd, cachevol_ARG, NULL);
+	dev_name = arg_str_value(cmd, cachedevice_ARG, NULL);
 
-	if (!(lv_fast = find_lv(vg, fast_name))) {
-		log_error("LV %s not found.", fast_name);
-		goto bad;
-	}
+	if (!fast_name && !dev_name)
+		goto_bad;
 
-	if (lv_fast == lv) {
-		log_error("Invalid cachevol LV.");
-		goto bad;
-	}
+	/*
+	 * User specifies an existing cachevol to use.
+	 */
+	if (fast_name) {
+		if (!validate_lvname_param(cmd, &vg->name, &fast_name))
+			goto_bad;
 
-	if (!seg_is_linear(first_seg(lv_fast))) {
-		log_error("LV %s must be linear to use as a writecache.", display_lvname(lv_fast));
-		goto bad;
-	}
+		if (!(lv_fast = find_lv(vg, fast_name))) {
+			log_error("LV %s not found.", fast_name);
+			goto bad;
+		}
 
-	if (lv_is_cache_vol(lv_fast)) {
-		log_error("LV %s is already used as a cachevol.", display_lvname(lv_fast));
-		goto bad;
+		if (lv_fast == lv) {
+			log_error("Invalid cachevol LV.");
+			goto bad;
+		}
+
+		if (lv_is_cache_vol(lv_fast)) {
+			log_error("LV %s is already used as a cachevol.", display_lvname(lv_fast));
+			goto bad;
+		}
+
+		if (!seg_is_linear(first_seg(lv_fast))) {
+			log_error("LV %s must be linear to use as a writecache.", display_lvname(lv_fast));
+			goto bad;
+		}
+
+		/* fast LV shouldn't generally be active by itself, but just in case. */
+		if (lv_is_active(lv_fast)) {
+			log_error("LV %s must be inactive to attach.", display_lvname(lv_fast));
+			goto bad;
+		}
+
+		if (!arg_is_set(cmd, yes_ARG) &&
+		     yes_no_prompt("Erase all existing data on %s? [y/n]: ", display_lvname(lv_fast)) == 'n') {
+			log_error("Conversion aborted.");
+			goto bad;
+		}
 	}
 
-	/* fast LV shouldn't generally be active by itself, but just in case. */
-	if (lv_info(cmd, lv_fast, 1, NULL, 0, 0)) {
-		log_error("LV %s must be inactive to attach.", display_lvname(lv_fast));
-		goto bad;
+	/*
+	 * User specifies a device and lvm creates a cachevol on it.
+	 */
+	if (dev_name) {
+		if (!_lv_create_cachevol(cmd, vg, lv, dev_name, &lv_fast))
+			goto_bad;
 	}
 
 	is_active = lv_is_active(lv);
@@ -5671,16 +5805,10 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 		}
 	}
 
-	if (!arg_is_set(cmd, yes_ARG) &&
-	    yes_no_prompt("Erase all existing data on %s? [y/n]: ", display_lvname(lv_fast)) == 'n') {
-		log_error("Conversion aborted.");
-		goto bad;
-	}
-
-	/* Ensure the two LVs are not active elsewhere. */
+	/* Ensure the LV is not active elsewhere. */
 	if (!lockd_lv(cmd, lv, "ex", 0))
 		goto_bad;
-	if (!lockd_lv(cmd, lv_fast, "ex", 0))
+	if (!dev_name && !lockd_lv(cmd, lv_fast, "ex", 0))
 		goto_bad;
 
 	if (!archive(vg))
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index d87a8f053..9c345bd99 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -124,8 +124,10 @@ static const struct command_function _command_functions[CMD_COUNT] = {
 	{ lvconvert_to_cachepool_CMD,			lvconvert_to_pool_cmd },
 	{ lvconvert_to_thin_with_external_CMD,		lvconvert_to_thin_with_external_cmd },
 	{ lvconvert_to_cache_with_cachevol_CMD,		lvconvert_to_cache_with_cachevol_cmd },
+	{ lvconvert_to_cache_with_device_CMD,		lvconvert_to_cache_with_cachevol_cmd },
 	{ lvconvert_to_cache_with_cachepool_CMD,	lvconvert_to_cache_with_cachepool_cmd },
 	{ lvconvert_to_writecache_CMD,			lvconvert_to_writecache_cmd },
+	{ lvconvert_to_writecache_with_device_CMD,	lvconvert_to_writecache_cmd },
 	{ lvconvert_swap_pool_metadata_CMD,		lvconvert_swap_pool_metadata_cmd },
 	{ lvconvert_to_thinpool_or_swap_metadata_CMD,   lvconvert_to_pool_or_swap_metadata_cmd },
 	{ lvconvert_to_cachepool_or_swap_metadata_CMD,  lvconvert_to_pool_or_swap_metadata_cmd },


