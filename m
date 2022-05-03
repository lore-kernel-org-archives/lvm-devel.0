From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  3 May 2022 17:11:36 +0000 (GMT)
Subject: main - vdo: support --vdosettings
Message-ID: <20220503171136.180253948471@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5e060b8fa71dcf7ad2ff2daca8dbfa009f691852
Commit:        5e060b8fa71dcf7ad2ff2daca8dbfa009f691852
Parent:        dd28460017356d9a1a30a787b5572e9bcbf1c4a4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 13 15:09:08 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 3 19:09:52 2022 +0200

vdo: support --vdosettings

Allow to use --vdosettings with lvcreate,lvconvert,lvchange.
Support settings currenly only configurable via lvm.conf.
With lvchange we require inactivate LV for changes to be applied.

Settings block_map_era_length has supported alias block_map_period.
---
 WHATS_NEW                   |   1 +
 device_mapper/vdo/target.h  |   6 +-
 man/lvmvdo.7_main           |  39 ++++++++--
 test/shell/lvchange-vdo.sh  |   8 ++
 test/shell/lvconvert-vdo.sh |   8 +-
 test/shell/lvcreate-vdo.sh  |   6 +-
 tools/args.h                |   9 +++
 tools/command-lines.in      |   6 +-
 tools/lvchange.c            |  43 ++++++++++-
 tools/lvconvert.c           |   9 +--
 tools/lvcreate.c            |  34 +++++----
 tools/toollib.c             | 177 ++++++++++++++++++++++++++++++++++++++++++++
 tools/toollib.h             |   6 ++
 13 files changed, 313 insertions(+), 39 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7c93d804d..fad32ab08 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.16 - 
 ====================================
+  Add support --vdosettings with lvcreate, lvconvert, lvchange.
   Fix lossing of delete message on thin-pool extension.
 
 Version 2.03.15 - 07th February 2022
diff --git a/device_mapper/vdo/target.h b/device_mapper/vdo/target.h
index 51dde3f4d..60c5bff56 100644
--- a/device_mapper/vdo/target.h
+++ b/device_mapper/vdo/target.h
@@ -77,8 +77,10 @@ enum dm_vdo_write_policy {
 struct dm_vdo_target_params {
 	uint32_t minimum_io_size;       // in sectors
 	uint32_t block_map_cache_size_mb;
-	uint32_t block_map_era_length;	// format period
-
+	union {
+		uint32_t block_map_era_length;	// format period
+		uint32_t block_map_period;      // supported alias
+	};
 	uint32_t check_point_frequency;
 	uint32_t index_memory_size_mb;  // format
 
diff --git a/man/lvmvdo.7_main b/man/lvmvdo.7_main
index 3b77173c4..14bd640b5 100644
--- a/man/lvmvdo.7_main
+++ b/man/lvmvdo.7_main
@@ -132,6 +132,19 @@ that can keep 100% incompressible data there.
 # lvconvert --type vdo-pool -n vdo0 -V10G vg/ExistingLV
 .fi
 .
+.SS \n+[step]. Change the compression and deduplication of a VDOPoolLV
+.
+Disable or enable the compression and deduplication for VDOPoolLV
+(the volume that maintains all VDO LV(s) associated with it).
+.P
+.B lvchange --compression y|n --deduplication y|n VG/VDOPoolLV
+.P
+.I Example
+.nf
+# lvchange --compression n  vg/vdopool0
+# lvchange --deduplication y vg/vdopool1
+.fi
+.
 .SS \n+[step]. Change the default settings used for creating a VDOPoolLV
 .
 VDO allows to set a large variety of options. Lots of these settings
@@ -173,17 +186,27 @@ EOF
 # lvcreate --vdo -L10G --config 'allocation/vdo_cpu_threads=4' vg/vdopool1
 .fi
 .
-.SS \n+[step]. Change the compression and deduplication of a VDOPoolLV
-.
-Disable or enable the compression and deduplication for VDOPoolLV
-(the volume that maintains all VDO LV(s) associated with it).
-.P
-.B lvchange --compression y|n --deduplication y|n VG/VDOPoolLV
+.SS \n+[step]. Set or change VDO settings with option --vdosettings
+.
+Use the form 'option=value' or 'option1=value option2=value',
+or repeat --vdosettings for each option being set.
+Options are listed in the Example section above, for the full description see
+.BR lvm.conf (5).
+Options can omit 'vdo_' and 'vdo_use_' prefixes and all its underscores.
+So i.e.  vdo_use_metadata_hints=1  and  metadatahints=1 are equivalent.
+To change the option for an already existing VDOPoolLV use
+.BR lvchange (8)
+command. However not all option can be changed.
+Only compression and deduplication options can be also changed for an active VDO LV.
+Lowest priority options are specified with configuration file,
+then with --vdosettings and highest are expliction option --compression
+and --deduplication.
 .P
 .I Example
+.P
 .nf
-# lvchange --compression n  vg/vdopool0
-# lvchange --deduplication y vg/vdopool1
+# lvcreate --vdo -L10G --vdosettings 'ack_threads=1 hash_zone_threads=2' vg/vdopool0
+# lvchange --vdosettings 'bio_threads=2 deduplication=1' vg/vdopool0
 .fi
 .
 .SS \n+[step]. Checking the usage of VDOPoolLV
diff --git a/test/shell/lvchange-vdo.sh b/test/shell/lvchange-vdo.sh
index 461b7821f..7cc44d6bc 100644
--- a/test/shell/lvchange-vdo.sh
+++ b/test/shell/lvchange-vdo.sh
@@ -48,9 +48,17 @@ check grep_dmsetup status $vg-vdopool-vpool " online online "
 lvchange --compression n --deduplication n $vg/vdopool
 check grep_dmsetup status $vg-vdopool-vpool " offline offline "
 
+# --vdosettings needs inactive LV
+not lvchange --vdosettings 'ack_threads=8' $vg/vdopool
 
 lvchange -an $vg/$lv1
 
+# With inactive vdo-pool changes are applied
+# explicit option --compression has highest priority
+lvchange --vdosettings 'ack_threads=5 compression=0' --compression y $vg/vdopool
+check lv_field $vg/$lv1 vdo_ack_threads "5"
+check lv_field $vg/$lv1 vdo_compression "enabled"
+
 # Test activation
 lvchange -aly $vg/$lv1
 check active $vg $lv1
diff --git a/test/shell/lvconvert-vdo.sh b/test/shell/lvconvert-vdo.sh
index 529f325bd..c42d8f25a 100644
--- a/test/shell/lvconvert-vdo.sh
+++ b/test/shell/lvconvert-vdo.sh
@@ -28,12 +28,12 @@ lvcreate -L5G -n $lv1 $vg
 not lvconvert --type vdo-pool $vg/$lv1 |& tee out
 grep "WARNING" out
 
-
-lvconvert -y --type vdo-pool $vg/$lv1
+# Check --vdosettings is also applied to converted vdo-pool
+lvconvert -y --type vdo-pool --vdosettings 'ack_threads=5' $vg/$lv1
+check lv_field $vg/$lv1 vdo_ack_threads "5"
 lvremove -f $vg
 
-
-# 
+#
 lvcreate -L5G -n $lv1 $vg
 lvconvert -y --vdopool $vg/$lv1
 lvremove -f $vg
diff --git a/test/shell/lvcreate-vdo.sh b/test/shell/lvcreate-vdo.sh
index 44f8bf094..3e807ac94 100644
--- a/test/shell/lvcreate-vdo.sh
+++ b/test/shell/lvcreate-vdo.sh
@@ -79,8 +79,12 @@ not fsck -n "$DM_DEV_DIR/mapper/$vg-${lv2}"
 
 lvremove -ff $vg
 
+# Unknown settings does not pass
+# TODO: try to catch this in parser and 'fail'
+not lvcreate --type vdo --vdosettings 'ack_Xthreads=4' -L10G -V1T -ky -n $lv1 $vg
 
-lvcreate --type vdo -L10G -V1T -ky -n $lv1 $vg
+lvcreate --type vdo --vdosettings 'ack_threads=4' -L10G -V1T -ky -n $lv1 $vg
+check lv_field $vg/$lv1 vdo_ack_threads "4"
 lvs -a $vg
 lvremove -ff $vg
 
diff --git a/tools/args.h b/tools/args.h
index 57d2dfc52..baae333e1 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -912,6 +912,15 @@ arg(vdopool_ARG, '\0', "vdopool", lv_VAL, 0, 0,
     "The name of a VDO pool LV.\n"
     "See \\fBlvmvdo\\fP(7) for more information about VDO usage.\n")
 
+arg(vdosettings_ARG, '\0', "vdosettings", string_VAL, ARG_GROUPABLE, 0,
+    "Specifies tunable VDO options for VDO LVs.\n"
+    "Use the form 'option=value' or 'option1=value option2=value', or\n"
+    "repeat --vdosettings for each option being set.\n"
+    "These settings override the default VDO behaviors.\n"
+    "To remove vdosettings and revert to the default\n"
+    "VDO behaviors, use --vdosettings 'default'.\n"
+    "See \\fBlvmvdo\\fP(7) for more information.\n")
+
 arg(version_ARG, '\0', "version", 0, 0, 0,
     "Display version information.\n")
 
diff --git a/tools/command-lines.in b/tools/command-lines.in
index ce350e95c..b64fd0dda 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -243,6 +243,7 @@ OO_LVCHANGE_META: --addtag Tag, --deltag Tag,
 --setautoactivation Bool, --errorwhenfull Bool, --discards Discards, --zero Bool,
 --cachemode CacheMode, --cachepolicy String, --cachesettings String,
 --minrecoveryrate SizeKB, --maxrecoveryrate SizeKB,
+--vdosettings String,
 --writebehind Number, --writemostly WriteMostlyPV, --persistent n
 
 # It's unfortunate that activate needs to be optionally allowed here;
@@ -341,7 +342,8 @@ OO_LVCONVERT_CACHE: --cachemetadataformat CacheMetadataFormat,
 --cachesettings String, --zero Bool
 
 OO_LVCONVERT_VDO: --metadataprofile String, --readahead Readahead,
---compression Bool, --deduplication Bool, --zero Bool
+--compression Bool, --deduplication Bool, --vdosettings String,
+--zero Bool
 
 OO_LVCONVERT: --alloc Alloc, --background, --force, --noudevsync
 
@@ -839,7 +841,7 @@ OO_LVCREATE_POOL: --poolmetadatasize SizeMB, --poolmetadataspare Bool, --chunksi
 
 OO_LVCREATE_THINPOOL: --discards Discards, --errorwhenfull Bool
 
-OO_LVCREATE_VDO: --compression Bool, --deduplication Bool
+OO_LVCREATE_VDO: --compression Bool, --deduplication Bool, --vdosettings String
 ---
 
 lvcreate --type error --size SizeMB VG
diff --git a/tools/lvchange.c b/tools/lvchange.c
index d9c1bc688..670a4ec3d 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -755,6 +755,43 @@ out:
 	return r;
 }
 
+static int _lvchange_vdo(struct cmd_context *cmd,
+			 struct logical_volume *lv,
+			 uint32_t *mr)
+{
+	struct lv_segment *seg;
+	int updated = 0;
+
+	seg = first_seg(lv);
+
+	// With VDO LV given flip to VDO pool
+	if (seg_is_vdo(seg))
+		seg = first_seg(seg_lv(seg, 0));
+
+	if (!get_vdo_settings(cmd, &seg->vdo_params, &updated))
+		return_0;
+
+	if ((updated & VDO_CHANGE_OFFLINE) &&
+	    lv_info(cmd, seg->lv, 1, NULL, 0, 0)) {
+		log_error("Cannot change VDO settings for active VDO pool %s.",
+			  display_lvname(seg->lv));
+		// TODO maybe add --force support with prompt here
+		log_print_unless_silent("VDO pool %s with all its LVs needs to be deactivated.",
+					display_lvname(seg->lv));
+		return 0;
+	}
+
+	if (updated) {
+		if (!dm_vdo_validate_target_params(&seg->vdo_params, 0 /* vdo_size */))
+			return_0;
+
+		/* Request caller to commit and reload metadata */
+		*mr |= MR_RELOAD;
+	}
+
+	return 1;
+}
+
 static int _lvchange_tag(struct cmd_context *cmd, struct logical_volume *lv,
 			 int arg, uint32_t *mr)
 {
@@ -1154,6 +1191,7 @@ static int _option_requires_direct_commit(int opt_enum)
 		cachemode_ARG,
 		cachepolicy_ARG,
 		cachesettings_ARG,
+		vdosettings_ARG,
 		-1
 	};
 
@@ -1354,7 +1392,10 @@ static int _lvchange_properties_single(struct cmd_context *cmd,
 			docmds++;
 			doit += _lvchange_cache(cmd, lv, &mr);
 			break;
-
+		case vdosettings_ARG:
+			docmds++;
+			doit += _lvchange_vdo(cmd, lv, &mr);
+			break;
 		default:
 			log_error(INTERNAL_ERROR "Failed to check for option %s",
 				  arg_long_option_name(i));
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 1c4351e9d..76bef806c 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5454,13 +5454,8 @@ static int _lvconvert_to_vdopool_single(struct cmd_context *cmd,
 	if (!fill_vdo_target_params(cmd, &vdo_params, &vdo_pool_header_size, vg->profile))
 		goto_out;
 
-	if (arg_is_set(cmd, compression_ARG))
-		vdo_params.use_compression =
-			arg_int_value(cmd, compression_ARG, 0);
-
-	if (arg_is_set(cmd, deduplication_ARG))
-		vdo_params.use_deduplication =
-			arg_int_value(cmd, deduplication_ARG, 0);
+	if (!get_vdo_settings(cmd, &vdo_params, NULL))
+		return_0;
 
 	if (!activate_lv(cmd, lv)) {
 		log_error("Cannot activate %s.", display_lvname(lv));
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index b58fd62bb..20d7e4690 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -698,6 +698,23 @@ static int _read_cache_params(struct cmd_context *cmd,
 	return 1;
 }
 
+static int _read_vdo_params(struct cmd_context *cmd,
+			    struct lvcreate_params *lp)
+{
+	if (!seg_is_vdo(lp))
+		return 1;
+
+	// prefiling settings here
+	if (!fill_vdo_target_params(cmd, &lp->vdo_params,  &lp->vdo_pool_header_size, NULL))
+		return_0;
+
+	// override with optional vdo settings
+	if (!get_vdo_settings(cmd, &lp->vdo_params, NULL))
+		return_0;
+
+	return 1;
+}
+
 static int _read_activation_params(struct cmd_context *cmd,
 				   struct volume_group *vg,
 				   struct lvcreate_params *lp)
@@ -888,7 +905,8 @@ static int _lvcreate_params(struct cmd_context *cmd,
 #define VDO_POOL_ARGS \
 	vdopool_ARG,\
 	compression_ARG,\
-	deduplication_ARG
+	deduplication_ARG,\
+	vdosettings_ARG
 
 	/* Cache and cache-pool segment type */
 	if (seg_is_cache(lp)) {
@@ -1098,19 +1116,6 @@ static int _lvcreate_params(struct cmd_context *cmd,
 						zero_ARG,
 						-1))
 			return_0;
-
-		// FIXME: prefiling here - this is wrong place
-		// but will work for this moment
-		if (!fill_vdo_target_params(cmd, &lp->vdo_params, &lp->vdo_pool_header_size, NULL))
-			return_0;
-
-		if (arg_is_set(cmd, compression_ARG))
-			lp->vdo_params.use_compression =
-				arg_int_value(cmd, compression_ARG, 0);
-
-		if (arg_is_set(cmd, deduplication_ARG))
-			lp->vdo_params.use_deduplication =
-				arg_int_value(cmd, deduplication_ARG, 0);
 	}
 
 	/* Check options shared between more segment types */
@@ -1198,6 +1203,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 			      &lp->pool_metadata_size, &lp->pool_metadata_spare,
 			      &lp->chunk_size, &lp->discards, &lp->zero_new_blocks)) ||
 	    !_read_cache_params(cmd, lp) ||
+	    !_read_vdo_params(cmd, lp) ||
 	    !_read_mirror_and_raid_params(cmd, lp))
 		return_0;
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 897adec34..545407c2f 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1200,6 +1200,183 @@ out:
 	return ok;
 }
 
+/*
+ * Compare VDO option name, skip any '_' in name
+ * and also allow to use it without  vdo_[use_] prefix
+ */
+static int _compare_vdo_option(const char *b1, const char *b2)
+{
+	if (strncasecmp(b1, "vdo", 3) == 0) // skip vdo prefix
+		b1 += 3;
+
+	if ((tolower(*b1) != tolower(*b2)) &&
+	    (strncmp(b2, "use_", 4) == 0))
+		b2 += 4;  // try again with skipped prefix 'use_'
+
+	while (*b1 && *b2) {
+		if (tolower(*b1) == tolower(*b2)) {
+			++b1;
+			++b2;
+			continue;	// matching char
+		}
+
+		if (*b1 == '_')
+			++b1;           // skip to next char
+		else if (*b2 == '_')
+			++b2;           // skip to next char
+		else
+			break;          // mismatch
+	}
+
+	return (*b1 || *b2) ? 0 : 1;
+}
+
+#define CHECK_AND_SET(var, onoff) \
+	option = #var;\
+	if (_compare_vdo_option(cn->key, option)) {\
+		if (is_lvchange || !cn->v || (cn->v->type != DM_CFG_INT))\
+			goto err;\
+		if (vtp->var != cn->v->v.i) {\
+			vtp->var = cn->v->v.i;\
+			u |= onoff;\
+		}\
+		continue;\
+	}
+
+#define DO_OFFLINE(var) \
+	CHECK_AND_SET(var, VDO_CHANGE_OFFLINE)
+
+#define DO_ONLINE(var) \
+	CHECK_AND_SET(var, VDO_CHANGE_ONLINE)
+
+int get_vdo_settings(struct cmd_context *cmd,
+		     struct dm_vdo_target_params *vtp,
+		     int *updated)
+{
+	const char *str, *option = NULL;
+	struct arg_value_group_list *group;
+	struct dm_config_tree *result = NULL, *prev = NULL, *current = NULL;
+	struct dm_config_node *cn;
+	int r = 0, u = 0, is_lvchange;
+	int use_compression = vtp->use_compression;
+	int use_deduplication = vtp->use_deduplication;
+	int checked_lvchange;
+
+	if (updated)
+		*updated = 0;
+
+	// Group all --vdosettings
+	dm_list_iterate_items(group, &cmd->arg_value_groups) {
+		if (!grouped_arg_is_set(group->arg_values, vdosettings_ARG))
+			continue;
+
+		if (!(current = dm_config_create()))
+			goto_out;
+		if (prev)
+			current->cascade = prev;
+		prev = current;
+
+		if (!(str = grouped_arg_str_value(group->arg_values,
+						  vdosettings_ARG,
+						  NULL)))
+			goto_out;
+
+		if (!dm_config_parse_without_dup_node_check(current, str, str + strlen(str)))
+			goto_out;
+	}
+
+	if (current) {
+		if (!(result = dm_config_flatten(current)))
+			goto_out;
+
+		checked_lvchange = !strcmp(cmd->name, "lvchange");
+
+		/* Use all acceptable VDO options */
+		for (cn = result->root; cn; cn = cn->sib) {
+			is_lvchange = 0;
+			DO_OFFLINE(ack_threads);
+			DO_OFFLINE(bio_rotation);
+			DO_OFFLINE(bio_threads);
+			DO_OFFLINE(block_map_cache_size_mb);
+			DO_OFFLINE(block_map_era_length);
+			DO_OFFLINE(block_map_period); // alias for block_map_era_length
+			DO_OFFLINE(cpu_threads);
+			DO_OFFLINE(hash_zone_threads);
+			DO_OFFLINE(logical_threads);
+			DO_OFFLINE(max_discard);
+			DO_OFFLINE(physical_threads);
+
+			// Support also these - even when we have regular opts for them
+			DO_ONLINE(use_compression);
+			DO_ONLINE(use_deduplication);
+
+			// Settings bellow cannot be changed with lvchange command
+			is_lvchange = checked_lvchange;
+
+			DO_OFFLINE(check_point_frequency);
+			DO_OFFLINE(index_memory_size_mb);
+			DO_OFFLINE(minimum_io_size);
+			DO_OFFLINE(slab_size_mb);
+			DO_OFFLINE(use_metadata_hints);
+			DO_OFFLINE(use_sparse_index);
+
+			option = "write_policy";
+			if (_compare_vdo_option(cn->key, option)) {
+				if (is_lvchange || !cn->v || (cn->v->type != DM_CFG_STRING))
+					goto err;
+				if (!set_vdo_write_policy(&vtp->write_policy, cn->v->v.str))
+					goto_out;
+				u |= VDO_CHANGE_OFFLINE;
+				continue;
+			}
+
+			log_error("Unknown VDO setting \"%s\".", cn->key);
+			goto out;
+		}
+	}
+
+	if (arg_is_set(cmd, compression_ARG)) {
+		vtp->use_compression = arg_int_value(cmd, compression_ARG, 0);
+		if (vtp->use_compression != use_compression)
+			u |= VDO_CHANGE_ONLINE;
+	}
+
+	if (arg_is_set(cmd, deduplication_ARG)) {
+		vtp->use_deduplication = arg_int_value(cmd, deduplication_ARG, 0);
+		if (vtp->use_deduplication != use_deduplication)
+			u |= VDO_CHANGE_ONLINE;
+	}
+
+	if (updated) {
+		// validation of updated VDO option
+		if (!dm_vdo_validate_target_params(vtp, 0 /* vdo_size */)) {
+err:
+			if (is_lvchange)
+				log_error("Cannot change VDO setting \"vdo_%s\" in existing VDO pool.",
+					  option);
+			else
+				log_error("Invalid argument for VDO setting \"vdo_%s\".",
+					  option);
+			goto out;
+		}
+
+		*updated = u;
+	}
+
+	r = 1;
+out:
+	if (result)
+		dm_config_destroy(result);
+
+	while (prev) {
+		current = prev->cascade;
+		dm_config_destroy(prev);
+		prev = current;
+	}
+
+	return r;
+}
+
 static int _get_one_writecache_setting(struct cmd_context *cmd, struct writecache_settings *settings,
 				       char *key, char *val, uint32_t *block_size_sectors)
 {
diff --git a/tools/toollib.h b/tools/toollib.h
index f3a60fbc4..2b38e4e4f 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -217,6 +217,12 @@ int get_cache_params(struct cmd_context *cmd,
 		     const char **name,
 		     struct dm_config_tree **settings);
 
+#define VDO_CHANGE_ONLINE  1
+#define VDO_CHANGE_OFFLINE 2
+int get_vdo_settings(struct cmd_context *cmd,
+		     struct dm_vdo_target_params *vtp,
+		     int *updated);
+
 int get_writecache_settings(struct cmd_context *cmd, struct writecache_settings *settings,
                             uint32_t *block_size_sectors);
 

