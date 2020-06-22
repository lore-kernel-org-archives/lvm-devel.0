From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Jun 2020 16:40:11 +0000 (GMT)
Subject: master - lvcreate: new cache or writecache lv with single command
Message-ID: <20200622164011.0672B383E802@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2aed2a41f7602e9168613a0c37d8dd557e7dba9b
Commit:        2aed2a41f7602e9168613a0c37d8dd557e7dba9b
Parent:        21b37964eb88d404998e37acae5530ec102a2116
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 10 13:17:37 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 16 13:46:51 2020 -0500

lvcreate: new cache or writecache lv with single command

To create a new cache or writecache LV with a single command:

lvcreate --type cache|writecache
    -n Name -L Size --cachedevice PVfast VG [PVslow ...]

- A new main linear|striped LV is created as usual, using the
  specified -n Name and -L Size, and using the optionally
  specified PVslow devices.
- Then, a new cachevol LV is created internally, using PVfast
  specified by the cachedevice option.
- Then, the cachevol is attached to the main LV, converting the
  main LV to type cache|writecache.

Include --cachesize Size to specify the size of cache|writecache
to create from the specified --cachedevice PVs, otherwise the
entire cachedevice PV is used.  The --cachedevice option can be
repeated to create the cache from multiple devices, or the
cachedevice option can contain a tag name specifying a set of PVs
to allocate the cache from.

To create a new cache or writecache LV with a single command
using an existing cachevol LV:

lvcreate --type cache|writecache
    -n Name -L Size --cachevol LVfast VG [PVslow ...]

- A new main linear|striped LV is created as usual, using the
  specified -n Name and -L Size, and using the optionally
  specified PVslow devices.
- Then, the cachevol LVfast is attached to the main LV, converting
  the main LV to type cache|writecache.

In cases where more advanced types (for the main LV or cachevol LV)
are needed, they should be created independently and then combined
with lvconvert.

Example
-------

user creates a new VG with one slow device and one fast device:

$ vgcreate vg /dev/slow1 /dev/fast1

user creates a new 8G main LV on /dev/slow1 that uses all of
/dev/fast1 as a writecache:

$ lvcreate --type writecache --cachedevice /dev/fast1
    -n main -L 8G vg /dev/slow1

Example
-------

user creates a new VG with two slow devs and two fast devs:

$ vgcreate vg /dev/slow1 /dev/slow2 /dev/fast1 /dev/fast2

user creates a new 8G main LV on /dev/slow1 and /dev/slow2
that uses all of /dev/fast1 and /dev/fast2 as a writecache:

$ lvcreate --type writecache --cachedevice /dev/fast1 --cachedevice /dev/fast2
    -n main -L 8G vg /dev/slow1 /dev/slow2

Example
-------

A user has several slow devices and several fast devices in their VG,
the slow devs have tag @slow, the fast devs have tag @fast.

user creates a new 8G main LV on the slow devs with a
2G writecache on the fast devs:

$ lvcreate --type writecache -n main -L 8G
    --cachedevice @fast --cachesize 2G vg @slow
---
 lib/metadata/metadata-exported.h |   1 +
 tools/args.h                     |   2 +-
 tools/command-lines.in           | 126 ++++++++++++++++-------------
 tools/command.c                  |   3 +
 tools/lvconvert.c                | 166 ++++++++++++++++++++++-----------------
 tools/lvcreate.c                 | 153 +++++++++++++++++++++++++++++++++++-
 tools/lvmcmdline.c               |   6 ++
 tools/tools.h                    |  11 +++
 8 files changed, 341 insertions(+), 127 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0d6be136b..0cc5f37a0 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -954,6 +954,7 @@ struct lvcreate_params {
 	int thin_chunk_size_calc_policy;
 	unsigned suppress_zero_warn : 1;
 	unsigned needs_lockd_init : 1;
+	unsigned ignore_type : 1;
 
 	const char *vg_name; /* only-used when VG is not yet opened (in /tools) */
 	const char *lv_name; /* all */
diff --git a/tools/args.h b/tools/args.h
index c69a0ecce..3a7e5d488 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -126,7 +126,7 @@ arg(cachepool_ARG, '\0', "cachepool", lv_VAL, 0, 0,
 arg(cachevol_ARG, '\0', "cachevol", lv_VAL, 0, 0,
     "The name of a cache volume.\n")
 
-arg(cachedevice_ARG, '\0', "cachedevice", pv_VAL, 0, 0,
+arg(cachedevice_ARG, '\0', "cachedevice", pv_VAL, ARG_GROUPABLE, 0,
     "The name of a device to use for a cache.\n")
 
 arg(cachesize_ARG, '\0', "cachesize", sizemb_VAL, 0, 0,
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 8d389b665..0051b77b5 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1219,87 +1219,107 @@ lvcreate --type cache --size SizeMB --cachepool LV_cachepool VG
 OO: --cache, OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
-ID: lvcreate_cache_vol_with_new_origin
-DESC: Create a cache LV, first creating a new origin LV,
-DESC: then combining it with the existing cache pool named
-DESC: by the --cachepool arg.
+ID: lvcreate_and_attach_cachepool
+DESC: Create a new LV, then attach the specified cachepool
+DESC: which converts the new LV to type cache.
 
 # alternate form of lvcreate --type cache
+# (omits the --type cache option which is inferred)
 lvcreate --size SizeMB --cachepool LV_cachepool VG
 OO: --type cache, --cache, OO_LVCREATE_CACHE, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
-ID: lvcreate_cache_vol_with_new_origin
-DESC: Create a cache LV, first creating a new origin LV,
-DESC: then combining it with the existing cache pool named
-DESC: by the --cachepool arg (variant, infers --type cache).
+ID: lvcreate_and_attach_cachepool_v2
+DESC: Create a new LV, then attach the specified cachepool
+DESC: which converts the new LV to type cache
+DESC: (variant, infers --type cache.)
 FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type cache
+# (moves cachepool from option arg to position arg,
+# dropping the normal VG position arg)
 lvcreate --type cache --size SizeMB LV_cachepool
 OO: --cache, OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
-ID: lvcreate_cache_vol_with_new_origin
-DESC: Create a cache LV, first creating a new origin LV,
-DESC: then combining it with the existing cache pool named
-DESC: in the first arg (variant, also use --cachepool).
+ID: lvcreate_and_attach_cachepool_v3
+DESC: Create a new LV, then attach the specified cachepool
+DESC: which converts the new LV to type cache.
+DESC: (variant, also use --cachepool).
 FLAGS: SECONDARY_SYNTAX
 
-# This is a ridiculously crazy command which nobody could
-# understand.  It should be be eliminated.  It does two different
-# things depending on whether LV in pos 1 is a cachepool LV
-# or not.  Both variations are unnecessary.
-#
-# 1. If LV is a cachepool, then it's an alternate form of
-#    an already complicated command above.
-#
-# # alternate form for lvcreate_cache_vol_with_new_origin
-# lvcreate --cache --size SizeMB LV_cachepool
-# OO: --type cache, --cache, OO_LVCREATE_CACHE, OO_LVCREATE, --stripes Number, --stripesize SizeKB
-# OP: PV ...
-# ID: lvcreate_cache_vol_with_new_origin
-# DESC: Create a cache LV, first creating a new origin LV,
-# DESC: then combining it with the existing cache pool named
-# DESC: in the first arg (variant, infers --type cache,
-# DESC: also use --cachepool).
-#
-# 2. If LV is not a cachepool, then it's a disguised lvconvert.
-#
-# # FIXME: this should be done by lvconvert, and this command removed
-# lvcreate --type cache --size SizeMB LV
-# OO: OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE
-# OP: PV ...
-# ID: lvcreate_convert_to_cache_vol_with_cachepool
-# DESC: Convert the specified LV to type cache after creating a new
-# DESC: cache pool LV to use (use lvconvert).
+# This command has two different meanings which ought to
+# have separate command defs, but since the syntax is the
+# same for both they have to share one command def with
+# an ambiguous meaning.  Which command is performed depends
+# on whether the LV in the first arg position is a
+# cachepool or not (we can't have two different command
+# defs that differ only in the type of LV in the arg position
+# because when parsing commands we don't know the LV type.)
+#
+# 1. An alternate form of lvcreate_and_attach_cachepool_v3
+#    this syntax:         lvcreate --cache --size SizeMB LV_cachepool
+#    is alternative for:  lvcreate --type cache --size SizeMB LV_cachepool
+#
+# 2. An alternative to using lvconvert to convert LV to type cache,
+#    but in this case the cachepool is created internally and
+#    then attached to the LV arg.
 #
 # Note that stripes are accepted by the first and not by the
 # second, but it's not possible to validate this until after
 # the LV type is known.
-#
-# So, to define this syntax we have to combine both of
-# those variants, each crazy on it's own, into one
-# ridiculous command.
 
-# def1: alternate form of lvcreate --type cache, or
-# def2: it should be done by lvconvert.
 lvcreate --cache --size SizeMB LV
 OO: OO_LVCREATE_CACHE, OO_LVCREATE_POOL, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
-ID: lvcreate_cache_vol_with_new_origin_or_convert_to_cache_vol_with_cachepool
-DESC: When LV is a cache pool, create a cache LV,
-DESC: first creating a new origin LV, then combining it with
-DESC: the existing cache pool named in the first arg
-DESC: (variant, infers --type cache, also use --cachepool).
-DESC: When LV is not a cache pool, convert the specified LV
-DESC: to type cache after creating a new cache pool LV to use
-DESC: (use lvconvert).
+ID: lvcreate_new_plus_old_cachepool_or_lvconvert_old_plus_new_cachepool
+DESC: When the LV arg is a cachepool, then create a new LV and
+DESC: attach the cachepool arg to it.
+DESC: (variant, use --type cache and --cachepool.)
+DESC: When the LV arg is not a cachepool, then create a new cachepool
+DESC: and attach it to the LV arg (alternative, use lvconvert.)
 FLAGS: SECONDARY_SYNTAX
 
 ---
 
+# These all create a new origin LV, then forwards to lvconvert
+# which combines it with a cachevol (which already exists or
+# which needs to be created from cachedevice), converting
+# the new LV to type cache or writecache.
+
+lvcreate --type cache --size SizeMB --cachevol LV VG
+OO: OO_LVCREATE, OO_LVCREATE_CACHE, --stripes Number, --stripesize SizeKB
+OP: PV ...
+ID: lvcreate_and_attach_cachevol_for_cache
+DESC: Create a new LV, then attach the specified cachevol
+DESC: which converts the new LV to type cache.
+
+lvcreate --type cache --size SizeMB --cachedevice PV VG
+OO: OO_LVCREATE, OO_LVCREATE_CACHE, --cachesize SizeMB, --stripes Number, --stripesize SizeKB
+OP: PV ...
+ID: lvcreate_and_attach_cachedevice_for_cache
+DESC: Create a new LV, then attach a cachevol created from
+DESC: the specified cache device, which converts the
+DESC: new LV to type cache.
+
+lvcreate --type writecache --size SizeMB --cachevol LV VG
+OO: OO_LVCREATE, --cachesettings String, --stripes Number, --stripesize SizeKB
+OP: PV ...
+ID: lvcreate_and_attach_cachevol_for_writecache
+DESC: Create a new LV, then attach the specified cachevol
+DESC: which converts the new LV to type writecache.
+
+lvcreate --type writecache --size SizeMB --cachedevice PV VG
+OO: OO_LVCREATE, --cachesize SizeMB, --cachesettings String, --stripes Number, --stripesize SizeKB
+OP: PV ...
+ID: lvcreate_and_attach_cachedevice_for_writecache
+DESC: Create a new LV, then attach a cachevol created from
+DESC: the specified cache device, which converts the
+DESC: new LV to type writecache.
+
+---
+
 lvdisplay
 OO: --aligned, --all, --binary, --colon, --columns,
 --configreport ConfigReport, --foreign, --history, --ignorelockingfailure,
diff --git a/tools/command.c b/tools/command.c
index 511dda13d..2d0184941 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1420,6 +1420,9 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 		if (line[0] == '\n')
 			break;
 
+		if (!strcmp(line, "---") || !strcmp(line, "--"))
+			continue;
+
 		if ((n = strchr(line, '\n')))
 			*n = '\0';
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 76a9160f3..0155fdbf9 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4248,18 +4248,25 @@ int lvconvert_to_pool_cmd(struct cmd_context *cmd, int argc, char **argv)
 			       NULL, NULL, &_lvconvert_to_pool_single);
 }
 
+#define MAX_CACHEDEVS 8
+
 static int _lv_create_cachevol(struct cmd_context *cmd,
 			       struct volume_group *vg,
 			       struct logical_volume *lv,
-			       const char *dev_name,
 			       struct logical_volume **cachevol_lv)
 {
 	char cvname[NAME_LEN];
-	struct device *dev_fast;
 	struct dm_list *use_pvh;
-	uint64_t cache_size_sectors;
-	struct logical_volume *cachevol;
 	struct pv_list *pvl;
+	char *dev_name;
+	struct device *dev_fast;
+	char *dev_argv[MAX_CACHEDEVS];
+	int dev_argc = 0;
+	uint64_t cache_size_sectors = 0;
+	uint64_t full_size_sectors = 0;
+	uint64_t pv_size_sectors;
+	struct logical_volume *cachevol;
+	struct arg_value_group_list *group;
 	struct lvcreate_params lp = {
 		.activate = CHANGE_AN,
 		.alloc = ALLOC_INHERIT,
@@ -4275,48 +4282,86 @@ static int _lv_create_cachevol(struct cmd_context *cmd,
 		.suppress_zero_warn = 1,
 	};
 
-	if (dm_snprintf(cvname, NAME_LEN, "%s_cache", lv->name) < 0) {
-		log_error("Failed to create cachevol LV name.");
-		return 0;
-	}
+	/*
+	 * If cache size is not set, and all cachedevice's are unused,
+	 * then the cache size is the sum of all cachedevice sizes.
+	 */
+	cache_size_sectors = arg_uint64_value(cmd, cachesize_ARG, 0);
 
-	if (!(dev_fast = dev_cache_get(cmd, dev_name, cmd->filter))) {
-		log_error("Device %s not found.", dev_name);
-		return 0;
-	}
+	dm_list_iterate_items(group, &cmd->arg_value_groups) {
+		if (!grouped_arg_is_set(group->arg_values, cachedevice_ARG))
+			continue;
 
-	if (!(pvl = find_pv_in_vg(vg, dev_name))) {
-		log_error("PV %s not found in VG.", dev_name);
-		return 0;
-	}
+		if (!(dev_name = (char *)grouped_arg_str_value(group->arg_values, cachedevice_ARG, NULL)))
+			break;
 
-	/*
-	 * If fast_dev is used in the VG, then require a cachesize to allocate
-	 * from it.  If fast_dev is not used in the VG, then prompt asking if
-	 * the entire dev should be used.
-	 */
-	if (!(cache_size_sectors = arg_uint64_value(cmd, cachesize_ARG, 0))) {
-		if (pvl->pv->pe_alloc_count) {
+		if (dev_name[0] == '@') {
+			if (!cache_size_sectors) {
+				log_error("With tag as cachedevice, --cachesize is required.");
+				return 0;
+			}
+			goto add_dev_arg;
+		}
+
+		if (!(dev_fast = dev_cache_get(cmd, dev_name, cmd->filter))) {
+			log_error("Device %s not found.", dev_name);
+			return 0;
+		}
+
+		if (!(pvl = find_pv_in_vg(vg, dev_name))) {
+			log_error("PV %s not found in VG.", dev_name);
+			return 0;
+		}
+
+		/*
+		 * If the dev is used in the VG, then require a cachesize to allocate
+		 * from it.  If it is not used in the VG, then prompt asking if the
+		 * entire dev should be used.
+		 */
+		if (!cache_size_sectors && pvl->pv->pe_alloc_count) {
 			log_error("PV %s is in use, --cachesize is required.", dev_name);
 			return 0;
 		}
 
-		cache_size_sectors = (pvl->pv->pe_count * vg->extent_size);
+		if (!cache_size_sectors) {
+			pv_size_sectors = (pvl->pv->pe_count * vg->extent_size);
 
-		if (!arg_is_set(cmd, yes_ARG) &&
-		    yes_no_prompt("Use all %s from %s for cache? [y/n]: ",
-				  display_size(cmd, cache_size_sectors), dev_name) == 'n') {
-			log_print("Use --cachesize SizeMB to use a part of the cachedevice.");
-			log_error("Conversion aborted.");
+			if (!arg_is_set(cmd, yes_ARG) &&
+			    yes_no_prompt("Use all %s from %s for cache? [y/n]: ",
+					  display_size(cmd, pv_size_sectors), dev_name) == 'n') {
+				log_print("Use --cachesize SizeMB to use a part of the cachedevice.");
+				log_error("Conversion aborted.");
+				return 0;
+			}
+			full_size_sectors += pv_size_sectors;
+		}
+ add_dev_arg:
+		if (dev_argc >= MAX_CACHEDEVS) {
+			log_error("Cannot allocate from more than %u cache devices.", MAX_CACHEDEVS);
 			return 0;
 		}
+
+		dev_argv[dev_argc++] = dev_name;
+	}
+
+	if (!cache_size_sectors)
+		cache_size_sectors = full_size_sectors;
+
+	if (!dev_argc) {
+		log_error("No cachedevice specified to create a cachevol.");
+		return 0;
 	}
 
-	if (!(use_pvh = create_pv_list(cmd->mem, vg, 1, (char **)&dev_name, 1))) {
+	if (!(use_pvh = create_pv_list(cmd->mem, vg, dev_argc, dev_argv, 1))) {
 		log_error("cachedevice not found in VG %s.", dev_name);
 		return 0;
 	}
 
+	if (dm_snprintf(cvname, NAME_LEN, "%s_cache", lv->name) < 0) {
+		log_error("Failed to create cachevol LV name.");
+		return 0;
+	}
+
 	lp.lv_name = cvname;
 	lp.pvh = use_pvh;
 	lp.extents = cache_size_sectors / vg->extent_size;
@@ -4338,27 +4383,19 @@ static int _lv_create_cachevol(struct cmd_context *cmd,
 	return 1;
 }
 
-static int _lvconvert_cachevol_attach_single(struct cmd_context *cmd,
-					  struct logical_volume *lv,
-					  struct processing_handle *handle)
+int lvconvert_cachevol_attach_single(struct cmd_context *cmd,
+				     struct logical_volume *lv,
+				     struct processing_handle *handle)
 {
 	struct volume_group *vg = lv->vg;
 	struct logical_volume *lv_fast;
-	const char *fast_name, *dev_name;
-
-	fast_name = arg_str_value(cmd, cachevol_ARG, NULL);
-	dev_name = arg_str_value(cmd, cachedevice_ARG, NULL);
-
-	if (!fast_name && !dev_name)
-		goto_bad;
-
-	if (fast_name && dev_name)
-		goto_bad;
+	const char *fast_name;
 
 	/*
-	 * User specifies an existing cachevol to use.
+	 * User specifies an existing cachevol to use or a cachedevice
+	 * to create a cachevol from.
 	 */
-	if (fast_name) {
+	if ((fast_name = arg_str_value(cmd, cachevol_ARG, NULL))) {
 		if (!validate_lvname_param(cmd, &vg->name, &fast_name))
 			goto_bad;
 
@@ -4385,13 +4422,8 @@ static int _lvconvert_cachevol_attach_single(struct cmd_context *cmd,
 
 		if (!lockd_lv(cmd, lv_fast, "ex", 0))
 			goto_bad;
-	}
-
-	/*
-	 * User specifies a device and lvm creates a cachevol on it.
-	 */
-	if (dev_name) {
-		if (!_lv_create_cachevol(cmd, vg, lv, dev_name, &lv_fast))
+	} else {
+		if (!_lv_create_cachevol(cmd, vg, lv, &lv_fast))
 			goto_bad;
 	}
 
@@ -5705,7 +5737,7 @@ bad:
 	return 0;
 }
 
-static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
+int lvconvert_writecache_attach_single(struct cmd_context *cmd,
 					struct logical_volume *lv,
 					struct processing_handle *handle)
 {
@@ -5713,7 +5745,7 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 	struct logical_volume *lv_wcorig;
 	struct logical_volume *lv_fast;
 	struct writecache_settings settings;
-	const char *fast_name, *dev_name;
+	const char *fast_name;
 	uint32_t block_size_sectors = 0;
 	char *lockd_fast_args = NULL;
 	char *lockd_fast_name = NULL;
@@ -5721,16 +5753,11 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 	char cvol_name[NAME_LEN];
 	int is_active;
 
-	fast_name = arg_str_value(cmd, cachevol_ARG, NULL);
-	dev_name = arg_str_value(cmd, cachedevice_ARG, NULL);
-
-	if (!fast_name && !dev_name)
-		goto_bad;
-
 	/*
-	 * User specifies an existing cachevol to use.
+	 * User specifies an existing cachevol to use or a cachedevice
+	 * to create a cachevol from.
 	 */
-	if (fast_name) {
+	if ((fast_name = arg_str_value(cmd, cachevol_ARG, NULL))) {
 		if (!validate_lvname_param(cmd, &vg->name, &fast_name))
 			goto_bad;
 
@@ -5765,13 +5792,8 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 			log_error("Conversion aborted.");
 			goto bad;
 		}
-	}
-
-	/*
-	 * User specifies a device and lvm creates a cachevol on it.
-	 */
-	if (dev_name) {
-		if (!_lv_create_cachevol(cmd, vg, lv, dev_name, &lv_fast))
+	} else {
+		if (!_lv_create_cachevol(cmd, vg, lv, &lv_fast))
 			goto_bad;
 	}
 
@@ -5808,7 +5830,7 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 	/* Ensure the LV is not active elsewhere. */
 	if (!lockd_lv(cmd, lv, "ex", 0))
 		goto_bad;
-	if (!dev_name && !lockd_lv(cmd, lv_fast, "ex", 0))
+	if (fast_name && !lockd_lv(cmd, lv_fast, "ex", 0))
 		goto_bad;
 
 	if (!archive(vg))
@@ -5899,7 +5921,7 @@ int lvconvert_to_writecache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	cmd->cname->flags &= ~GET_VGNAME_FROM_OPTIONS;
 
 	ret = process_each_lv(cmd, cmd->position_argc, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE, handle, NULL,
-			      &_lvconvert_writecache_attach_single);
+			      &lvconvert_writecache_attach_single);
 
 	destroy_processing_handle(cmd, handle);
 
@@ -5922,7 +5944,7 @@ int lvconvert_to_cache_with_cachevol_cmd(struct cmd_context *cmd, int argc, char
 	cmd->cname->flags &= ~GET_VGNAME_FROM_OPTIONS;
 
 	ret = process_each_lv(cmd, cmd->position_argc, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE, handle, NULL,
-			      &_lvconvert_cachevol_attach_single);
+			      &lvconvert_cachevol_attach_single);
 
 	destroy_processing_handle(cmd, handle);
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 5c978b3cc..3357a08c5 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -766,7 +766,9 @@ static int _lvcreate_params(struct cmd_context *cmd,
 	 *
 	 * Ordering of following type tests is IMPORTANT
 	 */
-	if ((segtype_str = arg_str_value(cmd, type_ARG, NULL))) {
+	if (lp->ignore_type) {
+		segtype_str = SEG_TYPE_NAME_STRIPED;
+	} else if ((segtype_str = arg_str_value(cmd, type_ARG, NULL))) {
 		lp->type = 1;
 		if (!strcmp(segtype_str, "linear")) {
 			segtype_str = "striped";
@@ -1799,3 +1801,152 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 	destroy_processing_handle(cmd, handle);
 	return ret;
 }
+
+static int _lvcreate_and_attach_writecache_single(struct cmd_context *cmd,
+		const char *vg_name, struct volume_group *vg, struct processing_handle *handle)
+{
+	struct processing_params *pp = (struct processing_params *) handle->custom_handle;
+	struct lvcreate_params *lp = pp->lp;
+	struct logical_volume *lv;
+	int ret;
+
+	ret = _lvcreate_single(cmd, vg_name, vg, handle);
+
+	if (ret == ECMD_FAILED)
+		return ret;
+
+	if (!(lv = find_lv(vg, lp->lv_name))) {
+		log_error("Failed to find LV %s to add writecache.", lp->lv_name);
+		return ECMD_FAILED;
+	}
+
+	ret = lvconvert_writecache_attach_single(cmd, lv, handle);
+
+	if (ret == ECMD_FAILED) {
+		log_error("Removing new LV after failing to add writecache.");
+		if (!deactivate_lv(cmd, lv))
+			log_error("Failed to deactivate new LV %s.", display_lvname(lv));
+		if (!lv_remove_with_dependencies(cmd, lv, 1, 0))
+			log_error("Failed to remove new LV %s.", display_lvname(lv));
+		return ECMD_FAILED;
+	}
+
+	return ECMD_PROCESSED;
+}
+
+int lvcreate_and_attach_writecache_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	struct processing_handle *handle = NULL;
+	struct processing_params pp;
+	struct lvcreate_params lp = {
+		.major = -1,
+		.minor = -1,
+	};
+	struct lvcreate_cmdline_params lcp = { 0 };
+	int ret;
+
+	/*
+	 * Tell lvcreate to ignore --type since we are using lvcreate
+	 * to create a linear LV and using lvconvert to add cache.
+	 * (Would be better if lvcreate code was split up so we could
+	 * call a specific function that just created a linear/striped LV.)
+	 */
+	lp.ignore_type = 1;
+
+	if (!_lvcreate_params(cmd, argc, argv, &lp, &lcp)) {
+		stack;
+		return EINVALID_CMD_LINE;
+	}
+
+	pp.lp = &lp;
+	pp.lcp = &lcp;
+
+        if (!(handle = init_processing_handle(cmd, NULL))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	handle->custom_handle = &pp;
+
+	ret = process_each_vg(cmd, 0, NULL, lp.vg_name, NULL, READ_FOR_UPDATE, 0, handle,
+			      &_lvcreate_and_attach_writecache_single);
+
+	_destroy_lvcreate_params(&lp);
+	destroy_processing_handle(cmd, handle);
+	return ret;
+}
+
+static int _lvcreate_and_attach_cache_single(struct cmd_context *cmd,
+		const char *vg_name, struct volume_group *vg, struct processing_handle *handle)
+{
+	struct processing_params *pp = (struct processing_params *) handle->custom_handle;
+	struct lvcreate_params *lp = pp->lp;
+	struct logical_volume *lv;
+	int ret;
+
+	ret = _lvcreate_single(cmd, vg_name, vg, handle);
+
+	if (ret == ECMD_FAILED)
+		return ret;
+
+	if (!(lv = find_lv(vg, lp->lv_name))) {
+		log_error("Failed to find LV %s to add cache.", lp->lv_name);
+		return ECMD_FAILED;
+	}
+
+	ret = lvconvert_cachevol_attach_single(cmd, lv, handle);
+
+	if (ret == ECMD_FAILED) {
+		log_error("Removing new LV after failing to add cache.");
+		if (!deactivate_lv(cmd, lv))
+			log_error("Failed to deactivate new LV %s.", display_lvname(lv));
+		if (!lv_remove_with_dependencies(cmd, lv, 1, 0))
+			log_error("Failed to remove new LV %s.", display_lvname(lv));
+		return ECMD_FAILED;
+	}
+
+	return ECMD_PROCESSED;
+}
+
+int lvcreate_and_attach_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	struct processing_handle *handle = NULL;
+	struct processing_params pp;
+	struct lvcreate_params lp = {
+		.major = -1,
+		.minor = -1,
+	};
+	struct lvcreate_cmdline_params lcp = { 0 };
+	int ret;
+
+	/*
+	 * Tell lvcreate to ignore --type since we are using lvcreate
+	 * to create a linear LV and using lvconvert to add cache.
+	 * (Would be better if lvcreate code was split up so we could
+	 * call a specific function that just created a linear/striped LV.)
+	 */
+	lp.ignore_type = 1;
+
+	if (!_lvcreate_params(cmd, argc, argv, &lp, &lcp)) {
+		stack;
+		return EINVALID_CMD_LINE;
+	}
+
+	pp.lp = &lp;
+	pp.lcp = &lcp;
+
+	if (!(handle = init_processing_handle(cmd, NULL))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	handle->custom_handle = &pp;
+
+	ret = process_each_vg(cmd, 0, NULL, lp.vg_name, NULL, READ_FOR_UPDATE, 0, handle,
+			      &_lvcreate_and_attach_cache_single);
+
+	_destroy_lvcreate_params(&lp);
+	destroy_processing_handle(cmd, handle);
+	return ret;
+}
+
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 9c345bd99..7cf4e3ff0 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -154,6 +154,12 @@ static const struct command_function _command_functions[CMD_COUNT] = {
 	/* lvconvert for integrity */
 	{ lvconvert_integrity_CMD, lvconvert_integrity_cmd },
 
+	/* lvcreate */
+	{ lvcreate_and_attach_cachevol_for_cache_CMD,		lvcreate_and_attach_cache_cmd },
+	{ lvcreate_and_attach_cachedevice_for_cache_CMD,	lvcreate_and_attach_cache_cmd },
+	{ lvcreate_and_attach_cachevol_for_writecache_CMD,	lvcreate_and_attach_writecache_cmd },
+	{ lvcreate_and_attach_cachedevice_for_writecache_CMD,	lvcreate_and_attach_writecache_cmd },
+
 	{ pvscan_display_CMD, pvscan_display_cmd },
 	{ pvscan_cache_CMD, pvscan_cache_cmd },
 };
diff --git a/tools/tools.h b/tools/tools.h
index 7f2434d06..c3d780d36 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -278,7 +278,18 @@ int lvconvert_to_vdopool_param_cmd(struct cmd_context *cmd, int argc, char **arg
 
 int lvconvert_integrity_cmd(struct cmd_context *cmd, int argc, char **argv);
 
+int lvcreate_and_attach_writecache_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvcreate_and_attach_cache_cmd(struct cmd_context *cmd, int argc, char **argv);
+
 int pvscan_display_cmd(struct cmd_context *cmd, int argc, char **argv);
 int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv);
 
+
+int lvconvert_writecache_attach_single(struct cmd_context *cmd,
+                                        struct logical_volume *lv,
+                                        struct processing_handle *handle);
+int lvconvert_cachevol_attach_single(struct cmd_context *cmd,
+                                     struct logical_volume *lv,
+                                     struct processing_handle *handle);
+
 #endif


