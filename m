From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Aug 2015 12:40:53 +0000 (UTC)
Subject: master - cache: detect smq policy presence
Message-ID: <20150812124053.DBB9C61086@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8a74d1ec79d209aa8bce51821836179afe7d48f9
Commit:        8a74d1ec79d209aa8bce51821836179afe7d48f9
Parent:        694c88e031fb44f957c75bea369b898e1dedf932
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 23 11:32:09 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 12 14:11:17 2015 +0200

cache: detect smq policy presence

Add code to detect available cache features.
Support policy_mq & policy_smq  features which might be disabled.

Introduce global_cache_disabled_features_CFG.
---
 lib/cache_segtype/cache.c    |   73 ++++++++++++++++++++++++++++++++++++++++--
 lib/config/config_settings.h |    8 ++++
 lib/metadata/segtype.h       |    3 ++
 3 files changed, 81 insertions(+), 3 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 18c0168..d74fbf1 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -25,6 +25,11 @@
 #include "lv_alloc.h"
 #include "defaults.h"
 
+static const char _cache_module[] = "cache";
+
+/* TODO: using static field here, maybe should be a part of segment_type */
+static unsigned _feature_mask;
+
 #define SEG_LOG_ERROR(t, p...) \
         log_error(t " segment %s of logical volume %s.", ## p,	\
                   dm_config_parent_name(sn), seg->lv->name), 0;
@@ -168,9 +173,26 @@ static int _target_present(struct cmd_context *cmd,
 				const struct lv_segment *seg __attribute__((unused)),
 				unsigned *attributes __attribute__((unused)))
 {
-	uint32_t maj, min, patchlevel;
+	/* List of features with their kernel target version */
+	static const struct feature {
+		uint32_t maj;
+		uint32_t min;
+		unsigned cache_feature;
+		const char feature[12];
+		const char module[12]; /* check dm-%s */
+	} _features[] = {
+		{ 1, 3, CACHE_FEATURE_POLICY_MQ, "policy_mq", "cache-mq" },
+		{ 1, 8, CACHE_FEATURE_POLICY_SMQ, "policy_smq", "cache-smq" },
+	};
+	static const char _lvmconf[] = "global/cache_disabled_features";
+	static unsigned _attrs = 0;
 	static int _cache_checked = 0;
 	static int _cache_present = 0;
+	uint32_t maj, min, patchlevel;
+	unsigned i;
+	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
+	const char *str;
 
 	if (!_cache_checked) {
 		_cache_present = target_present(cmd, "cache", 1);
@@ -184,11 +206,53 @@ static int _target_present(struct cmd_context *cmd,
 
 		if ((maj < 1) ||
 		    ((maj == 1) && (min < 3))) {
-			log_error("The cache kernel module is version %u.%u.%u."
-				  "  Version 1.3.0+ is required.",
+			_cache_present = 0;
+			log_error("The cache kernel module is version %u.%u.%u. "
+				  "Version 1.3.0+ is required.",
 				  maj, min, patchlevel);
 			return 0;
 		}
+
+
+		for (i = 0; i < DM_ARRAY_SIZE(_features); ++i) {
+			if (((maj > _features[i].maj) ||
+			     (maj == _features[i].maj && min >= _features[i].min)) &&
+			    (!_features[i].module[0] || module_present(cmd, _features[i].module)))
+				_attrs |= _features[i].cache_feature;
+			else
+				log_very_verbose("Target %s does not support %s.",
+						 _cache_module, _features[i].feature);
+		}
+	}
+
+	if (attributes) {
+		if (!_feature_mask) {
+			/* Support runtime lvm.conf changes, N.B. avoid 32 feature */
+			if ((cn = find_config_tree_array(cmd, global_cache_disabled_features_CFG, NULL))) {
+				for (cv = cn->v; cv; cv = cv->next) {
+					if (cv->type != DM_CFG_STRING) {
+						log_error("Ignoring invalid string in config file %s.",
+							  _lvmconf);
+						continue;
+					}
+					str = cv->v.str;
+					if (!*str)
+						continue;
+					for (i = 0; i < DM_ARRAY_SIZE(_features); ++i)
+						if (strcasecmp(str, _features[i].feature) == 0)
+							_feature_mask |= _features[i].cache_feature;
+				}
+			}
+
+			_feature_mask = ~_feature_mask;
+
+			for (i = 0; i < DM_ARRAY_SIZE(_features); ++i)
+				if ((_attrs & _features[i].cache_feature) &&
+				    !(_feature_mask & _features[i].cache_feature))
+					log_very_verbose("Target %s %s support disabled by %s",
+							 _cache_module, _features[i].feature, _lvmconf);
+		}
+		*attributes = _attrs & _feature_mask;
 	}
 
 	return _cache_present;
@@ -376,5 +440,8 @@ int init_cache_segtypes(struct cmd_context *cmd,
 		return_0;
 	log_very_verbose("Initialised segtype: %s", segtype->name);
 
+	/* Reset mask for recalc */
+	_feature_mask = 0;
+
 	return 1;
 }
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index deb17ef..c8461f7 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -909,6 +909,14 @@ cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CF
 	"Example:\n"
 	"thin_disabled_features = [ \"discards\", \"block_size\" ]\n")
 
+cfg_array(global_cache_disabled_features_CFG, "cache_disabled_features", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 126), NULL, 0, NULL,
+	"Features to not use in the cache driver.\n"
+	"This can be helpful for testing, or to avoid\n"
+	"using a feature that is causing problems.\n"
+	"Features: policy_mq, policy_smq.\n"
+	"Example:\n"
+	"cache_disabled_features = [ \"policy_smq\" ]\n")
+
 cfg(global_cache_check_executable_CFG, "cache_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, CACHE_CHECK_CMD, vsn(2, 2, 108), "@CACHE_CHECK_CMD@", 0, NULL,
 	"The full path to the cache_check command.\n"
 	"LVM uses this command to check that a cache metadata\n"
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 4b2df78..a80d5ed 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -191,6 +191,9 @@ int init_thin_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
 int init_cache_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
 #endif
 
+#define CACHE_FEATURE_POLICY_MQ			(1U << 0)
+#define CACHE_FEATURE_POLICY_SMQ		(1U << 1)
+
 #define SNAPSHOT_FEATURE_FIXED_LEAK		(1U << 0) /* version 1.12 */
 
 #ifdef SNAPSHOT_INTERNAL


