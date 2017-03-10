From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:35:30 -0500
Subject: master - cache: set chunk_size as first param
Message-ID: <201703101835.v2AIZUOg004117@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2d11fc695e7c2baff1b919fb9f92e491e49d5db1
Commit:        2d11fc695e7c2baff1b919fb9f92e491e49d5db1
Parent:        41843319654c671ce4419443a73f3cf87bb15199
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 9 15:54:30 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:00 2017 +0100

cache: set chunk_size as first param

---
 lib/metadata/cache_manip.c       |    4 ++--
 lib/metadata/lv_manip.c          |    8 ++++----
 lib/metadata/metadata-exported.h |    4 ++--
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 1e93127..eb4ebfe 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -756,10 +756,10 @@ out:
  * to update all commonly specified cache parameters
  */
 int cache_set_params(struct lv_segment *seg,
+		     uint32_t chunk_size,
 		     cache_mode_t mode,
 		     const char *policy_name,
-		     const struct dm_config_tree *policy_settings,
-		     uint32_t chunk_size)
+		     const struct dm_config_tree *policy_settings)
 {
 	struct lv_segment *pool_seg;
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index cb9ba68..6528811 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7672,10 +7672,10 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 	if (lv_is_cache_pool(lv)) {
 		if (!cache_set_params(first_seg(lv),
+				      lp->chunk_size,
 				      lp->cache_mode,
 				      lp->policy_name,
-				      lp->policy_settings,
-				      lp->chunk_size)) {
+				      lp->policy_settings)) {
 			stack;
 			goto revert_new_lv;
 		}
@@ -7881,10 +7881,10 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		lv = tmp_lv;
 
 		if (!cache_set_params(first_seg(lv),
+				      lp->chunk_size,
 				      lp->cache_mode,
 				      lp->policy_name,
-				      lp->policy_settings,
-				      (lp->passed_args & PASS_ARG_CHUNK_SIZE) ? lp->chunk_size : 0))
+				      lp->policy_settings))
 			return_NULL; /* revert? */
 
 		cache_check_for_warns(first_seg(lv));
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 7f9bbfe..c0b6359 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1276,10 +1276,10 @@ int cache_set_cache_mode(struct lv_segment *cache_seg, cache_mode_t mode);
 int cache_set_policy(struct lv_segment *cache_seg, const char *name,
 		     const struct dm_config_tree *settings);
 int cache_set_params(struct lv_segment *seg,
+		     uint32_t chunk_size,
 		     cache_mode_t mode,
 		     const char *policy_name,
-		     const struct dm_config_tree *policy_settings,
-		     uint32_t chunk_size);
+		     const struct dm_config_tree *policy_settings);
 void cache_check_for_warns(const struct lv_segment *seg);
 int update_cache_pool_params(const struct segment_type *segtype,
 			     struct volume_group *vg, unsigned attr,


