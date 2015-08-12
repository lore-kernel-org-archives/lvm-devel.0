From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Aug 2015 12:41:06 +0000 (UTC)
Subject: master - cache: add more validation
Message-ID: <20150812124106.818356062C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=533ac4d47dcecc976c05ba503acff11b9546b67c
Commit:        533ac4d47dcecc976c05ba503acff11b9546b67c
Parent:        f0c18fceb43d77b0a79685fc7b1c8bbe64df7e97
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 11 15:11:45 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 12 14:33:14 2015 +0200

cache: add more validation

---
 WHATS_NEW                 |    1 +
 lib/cache_segtype/cache.c |    3 +++
 lib/metadata/lv_manip.c   |    6 +++++-
 lib/metadata/merge.c      |   16 +++++++++++++++-
 4 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7fcf49a..1e34e1c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.128 - 
 ===================================
+  Check for valid cache mode in validation of cache segment.
   Enhance internal API cache_set_mode() and cache_set_policy().
   Enhance toollib's get_cache_params().
   Runtime detect presence of cache smq policy.
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 0526173..53c867e 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -100,6 +100,9 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 	 *   If the policy is not present, default policy is used.
 	 */
 	if ((sn = dm_config_find_node(sn, "policy_settings"))) {
+		if (!seg->policy_name)
+			return SEG_LOG_ERROR("policy_settings must have a policy_name in");
+
 		if (sn->v)
 			return SEG_LOG_ERROR("policy_settings must be a section in");
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f13df1b..116f099 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7074,7 +7074,11 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				  display_lvname(origin_lv));
 			return NULL;
 		}
-	} else if (pool_lv && seg_is_cache(lp)) {
+	} else if (seg_is_cache(lp)) {
+		if (!pool_lv) {
+			log_error(INTERNAL_ERROR "Pool LV for cache is missing.");
+			return NULL;
+		}
 		if (!lv_is_cache_pool(pool_lv)) {
 			log_error("Logical volume %s is not a cache pool.",
 				  display_lvname(pool_lv));
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index e38cb53..a3e6af1 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -208,7 +208,21 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 				}
 
 			}
-			if (seg_is_cache_pool(seg)) {
+			if (seg_is_cache_pool(seg) &&
+			    !dm_list_empty(&seg->lv->segs_using_this_lv)) {
+				switch (seg->feature_flags &
+					(DM_CACHE_FEATURE_PASSTHROUGH |
+					 DM_CACHE_FEATURE_WRITETHROUGH |
+					 DM_CACHE_FEATURE_WRITEBACK)) {
+					 case DM_CACHE_FEATURE_PASSTHROUGH:
+					 case DM_CACHE_FEATURE_WRITETHROUGH:
+					 case DM_CACHE_FEATURE_WRITEBACK:
+						 break;
+					 default:
+						 log_error("LV %s has invalid cache's feature flag.",
+							   lv->name);
+						 inc_error_count;
+				}
 				if (!seg->policy_name) {
 					log_error("LV %s is missing cache policy name.", lv->name);
 					inc_error_count;


