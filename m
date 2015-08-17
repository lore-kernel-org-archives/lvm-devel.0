From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Aug 2015 13:52:58 +0000 (UTC)
Subject: master - cache: move detection code to cache_set_policy
Message-ID: <20150817135258.0B0CC6055C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4b28383b1c5f84d5f4190dd19586082c23d6c904
Commit:        4b28383b1c5f84d5f4190dd19586082c23d6c904
Parent:        94c56559ca485c32c0e5c7253d22159ab1bbc0ea
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 17 15:35:43 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 17 15:52:06 2015 +0200

cache: move detection code to cache_set_policy

Move code which runtime detects settings for cache_policy
out of config dir to cache seg handling code.

Also mark cache_mode as command profilable setting.
---
 lib/config/config.c          |   24 ------------------------
 lib/config/config_settings.h |    4 ++--
 lib/metadata/cache_manip.c   |   35 +++++++++++++++++++++++++++++++++--
 3 files changed, 35 insertions(+), 28 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index ad2db76..d7a6cd9 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -2419,27 +2419,3 @@ int get_default_allocation_cache_pool_chunk_size_CFG(struct cmd_context *cmd, st
 {
 	return DEFAULT_CACHE_POOL_CHUNK_SIZE * 2;
 }
-
-const char *get_default_allocation_cache_policy_CFG(struct cmd_context *cmd, struct profile *profile)
-{
-	const struct segment_type *segtype = get_segtype_from_string(cmd, "cache");
-	unsigned attr = ~0;
-
-	if (!segtype ||
-	    !segtype->ops->target_present ||
-	    !segtype->ops->target_present(cmd, NULL, &attr)) {
-		log_warn("WARNING: Cannot detect default cache policy, using \""
-			 DEFAULT_CACHE_POLICY "\".");
-		return DEFAULT_CACHE_POLICY;
-	}
-
-	if (attr & CACHE_FEATURE_POLICY_SMQ)
-		return "smq";
-
-	if (attr & CACHE_FEATURE_POLICY_MQ)
-		return "mq";
-
-	log_warn("WARNING: Default cache policy not available.");
-
-	return NULL;
-}
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index f18d173..bdf7e6c 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -466,7 +466,7 @@ cfg(allocation_cache_pool_cachemode_CFG, "cache_pool_cachemode", allocation_CFG_
 	"This has been replaced by the allocation/cache_mode setting.\n",
 	"Cache mode.\n")
 
-cfg(allocation_cache_mode_CFG, "cache_mode", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_CACHE_MODE, vsn(2, 2, 128), NULL, 0, NULL,
+cfg(allocation_cache_mode_CFG, "cache_mode", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_CACHE_MODE, vsn(2, 2, 128), NULL, 0, NULL,
 	"The default cache mode used for new cache.\n"
 	"Possible options are: writethrough, writeback.\n"
 	"writethrough - Data blocks are immediately written from\n"
@@ -474,7 +474,7 @@ cfg(allocation_cache_mode_CFG, "cache_mode", allocation_CFG_SECTION, CFG_DEFAULT
 	"writeback - Data blocks are written from the cache back\n"
 	"to disk after some delay to improve performance.\n")
 
-cfg_runtime(allocation_cache_policy_CFG, "cache_policy", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, vsn(2, 2, 128), 0, NULL,
+cfg(allocation_cache_policy_CFG, "cache_policy", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, 0, vsn(2, 2, 128), NULL, 0, NULL,
 	"The default cache policy used for new cache volume.\n"
 	"For the kernel 4.2 and newer the default policy is smq\n"
 	"(Stochastic multique), otherwise the older mq (Multiqueue),\n"
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index fbd0663..30d890c 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -434,6 +434,34 @@ int lv_is_cache_origin(const struct logical_volume *lv)
 	return seg && lv_is_cache(seg->lv) && !lv_is_pending_delete(seg->lv) && (seg_lv(seg, 0) == lv);
 }
 
+static const char *_get_default_cache_policy(struct cmd_context *cmd)
+{
+	const struct segment_type *segtype = get_segtype_from_string(cmd, "cache");
+	unsigned attr = ~0;
+        const char *def = NULL;
+
+	if (!segtype ||
+	    !segtype->ops->target_present ||
+	    !segtype->ops->target_present(cmd, NULL, &attr)) {
+		log_warn("WARNING: Cannot detect default cache policy, using \""
+			 DEFAULT_CACHE_POLICY "\".");
+		return DEFAULT_CACHE_POLICY;
+	}
+
+	if (attr & CACHE_FEATURE_POLICY_SMQ)
+		def = "smq";
+	else if (attr & CACHE_FEATURE_POLICY_MQ)
+		def = "mq";
+	else {
+		log_error("Default cache policy is not available.");
+		return NULL;
+	}
+
+	log_debug_metadata("Detected default cache_policy \"%s\".", def);
+
+	return def;
+}
+
 int cache_set_policy(struct lv_segment *seg, const char *name,
 		     const struct dm_config_tree *settings)
 {
@@ -451,8 +479,11 @@ int cache_set_policy(struct lv_segment *seg, const char *name,
 			log_error("Failed to duplicate policy name.");
 			return 0;
 		}
-	} else if (!seg->policy_name && passed_seg_is_cache)
-		seg->policy_name = find_config_tree_str(seg->lv->vg->cmd, allocation_cache_policy_CFG, NULL);
+	} else if (!seg->policy_name && passed_seg_is_cache) {
+		if (!(seg->policy_name = find_config_tree_str(seg->lv->vg->cmd, allocation_cache_policy_CFG, NULL)) &&
+		    !(seg->policy_name = _get_default_cache_policy(seg->lv->vg->cmd)))
+			return_0;
+	}
 
 	if (settings) {
 		if (!seg->policy_name) {


