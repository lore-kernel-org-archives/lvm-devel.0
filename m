From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 22 Jan 2021 15:10:01 +0000 (GMT)
Subject: main - vdo: support online rename
Message-ID: <20210122151001.68AC2398E43C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8532b1ca97e8b9b4a9250140b5d629169f36df28
Commit:        8532b1ca97e8b9b4a9250140b5d629169f36df28
Parent:        4b8e5ad595aefb6e3e389051b9a374cc0d1a02a5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 21 21:18:05 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 22 15:30:37 2021 +0100

vdo: support online rename

New VDO targets v6.2.3 corrects support for online rename of VDO device.
If needed if can be disable via new lvm.conf setting:

vdo_disabled_features = [ "online_rename" ]
---
 conf/example.conf.in         | 10 ++++++++++
 lib/config/config_settings.h |  9 +++++++++
 lib/metadata/lv_manip.c      | 14 +++++++++++---
 lib/metadata/segtype.h       |  2 ++
 lib/vdo/vdo.c                | 46 ++++++++++++++++++++++++++++++++++++--------
 5 files changed, 70 insertions(+), 11 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index c32f4f5ad..8f6546165 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1194,6 +1194,16 @@ global {
 	# This configuration option has an automatic default value.
 	# vdo_format_options = [ "" ]
 
+	# Configuration option global/vdo_disabled_features.
+	# Features to not use in the vdo driver.
+	# This can be helpful for testing, or to avoid using a feature that is
+	# causing problems. Features include: online_rename
+	#
+	# Example
+	# vdo_disabled_features = [ "online_rename" ]
+	#
+	# This configuration option does not have a default value defined.
+
 	# Configuration option global/fsadm_executable.
 	# The full path to the fsadm command.
 	# LVM uses this command to help with lvresize -r operations.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 163e01485..5fc931de6 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1206,6 +1206,15 @@ cfg(global_vdo_format_executable_CFG, "vdo_format_executable", global_CFG_SECTIO
 cfg_array(global_vdo_format_options_CFG, "vdo_format_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_VDO_FORMAT_OPTIONS_CONFIG, VDO_1ST_VSN, NULL, 0, NULL,
 	"List of options passed added to standard vdoformat command.\n")
 
+cfg_array(global_vdo_disabled_features_CFG, "vdo_disabled_features", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 3, 11), NULL, 0, NULL,
+	"Features to not use in the vdo driver.\n"
+	"This can be helpful for testing, or to avoid using a feature that is\n"
+	"causing problems. Features include: online_rename\n"
+	"#\n"
+	"Example\n"
+	"vdo_disabled_features = [ \"online_rename\" ]\n"
+	"#\n")
+
 cfg(global_fsadm_executable_CFG, "fsadm_executable", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_FSADM_PATH, vsn(2, 2, 170), "@FSADM_PATH@", 0, NULL,
 	"The full path to the fsadm command.\n"
 	"LVM uses this command to help with lvresize -r operations.\n")
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c740ba2bd..6c7126378 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4738,6 +4738,8 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 	struct lv_names lv_names = { .old = lv->name };
 	int old_lv_is_historical = lv_is_historical(lv);
 	int historical;
+	unsigned attrs;
+	const struct segment_type *segtype;
 
 	/*
 	 * rename is not allowed on sub LVs except for pools
@@ -4763,9 +4765,15 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	if (lv_is_vdo_pool(lv) && lv_is_active(lv_lock_holder(lv))) {
-		log_error("Cannot rename active VDOPOOL volume %s.",
-			  display_lvname(lv));
-		return 0;
+		segtype = first_seg(lv)->segtype;
+		if (!segtype->ops->target_present ||
+		    !segtype->ops->target_present(lv->vg->cmd, NULL, &attrs) ||
+		    !(attrs & VDO_FEATURE_ONLINE_RENAME)) {
+			log_error("Cannot rename active VDOPOOL volume %s, "
+				  "VDO target feature support is missing.",
+				  display_lvname(lv));
+			return 0;
+		}
 	}
 
 	if (update_mda && !archive(vg))
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 08ddc3565..2714a6b45 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -349,6 +349,8 @@ int init_cache_segtypes(struct cmd_context *cmd, struct segtype_library *seglib)
 int init_vdo_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
 #endif
 
+#define VDO_FEATURE_ONLINE_RENAME		(1U << 0) /* version 6.2.3 */
+
 int init_writecache_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
 
 int init_integrity_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
diff --git a/lib/vdo/vdo.c b/lib/vdo/vdo.c
index c43a5dc26..bb7c78449 100644
--- a/lib/vdo/vdo.c
+++ b/lib/vdo/vdo.c
@@ -25,6 +25,7 @@
 #include "lib/metadata/segtype.h"
 #include "base/memory/zalloc.h"
 
+static const char _vdo_module[] = MODULE_NAME_VDO;
 static unsigned _feature_mask;
 
 static int _bad_field(const char *field)
@@ -391,18 +392,21 @@ static int _vdo_target_present(struct cmd_context *cmd,
 	static const struct feature {
 		uint32_t maj;
 		uint32_t min;
+		uint32_t patchlevel;
 		unsigned vdo_feature;
 		const char *feature;
 	} _features[] = {
-		{ 1, 1, 0, "" },
-		//{ 9, 9, VDO_FEATURE_RESIZE, "resize" },
+		{ 6, 2, 3, VDO_FEATURE_ONLINE_RENAME, "online_rename" },
 	};
-	//static const char _lvmconf[] = "global/vdo_disabled_features";
+	static const char _lvmconf[] = "global/vdo_disabled_features";
 	static int _vdo_checked = 0;
 	static int _vdo_present = 0;
 	static unsigned _vdo_attrs = 0;
 	uint32_t i, maj, min, patchlevel;
 	const struct segment_type *segtype;
+	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
+	const char *str;
 
 	if (!activation())
 		return 0;
@@ -419,8 +423,8 @@ static int _vdo_target_present(struct cmd_context *cmd,
 		}
 
 		if (maj < 6 || (maj == 6 && min < 2)) {
-			log_warn("WARNING: VDO target version %u.%u.%u is too old.",
-				 maj, min, patchlevel);
+			log_warn("WARNING: Target %s version %u.%u.%u is too old.",
+				 _vdo_module, maj, min, patchlevel);
 			return 0;
 		}
 
@@ -437,15 +441,41 @@ static int _vdo_target_present(struct cmd_context *cmd,
 		/* Prepare for adding supported features */
 		for (i = 0; i < DM_ARRAY_SIZE(_features); ++i)
 			if ((maj > _features[i].maj) ||
-			    (maj == _features[i].maj && min >= _features[i].min))
+			    ((maj == _features[i].maj) && (min > _features[i].min)) ||
+			    ((maj == _features[i].maj) && (min == _features[i].min) && (patchlevel >= _features[i].patchlevel)))
 				_vdo_attrs |= _features[i].vdo_feature;
 			else
 				log_very_verbose("Target %s does not support %s.",
-						 TARGET_NAME_VDO,
+						 _vdo_module,
 						 _features[i].feature);
 	}
 
 	if (attributes) {
+		if (!_feature_mask) {
+			/* Support runtime lvm.conf changes, N.B. avoid 32 feature */
+			if ((cn = find_config_tree_array(cmd, global_vdo_disabled_features_CFG, NULL))) {
+				for (cv = cn->v; cv; cv = cv->next) {
+					if (cv->type != DM_CFG_STRING) {
+						log_warn("WARNING: Ignoring invalid string in config file %s.",
+							  _lvmconf);
+						continue;
+					}
+					str = cv->v.str;
+					if (!*str)
+						continue;
+					for (i = 0; i < DM_ARRAY_SIZE(_features); ++i)
+						if (strcasecmp(str, _features[i].feature) == 0)
+							_feature_mask |= _features[i].vdo_feature;
+				}
+			}
+			_feature_mask = ~_feature_mask;
+			for (i = 0; i < DM_ARRAY_SIZE(_features); ++i)
+				if ((_vdo_attrs & _features[i].vdo_feature) &&
+				    !(_feature_mask & _features[i].vdo_feature))
+					log_very_verbose("Target %s %s support disabled by %s.",
+							 _vdo_module,
+							 _features[i].feature, _lvmconf);
+		}
 		*attributes = _vdo_attrs & _feature_mask;
 	}
 
@@ -456,7 +486,7 @@ static int _vdo_modules_needed(struct dm_pool *mem,
 			   const struct lv_segment *seg __attribute__((unused)),
 			   struct dm_list *modules)
 {
-	if (!str_list_add(mem, modules, MODULE_NAME_VDO)) {
+	if (!str_list_add(mem, modules, _vdo_module)) {
 		log_error("String list allocation failed for VDO module.");
 		return 0;
 	}


