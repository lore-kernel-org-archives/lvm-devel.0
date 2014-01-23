From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jan 2014 13:23:42 +0000 (UTC)
Subject: master - thin: rename function
Message-ID: <20140123132342.6905C6062C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2dae78b722cff63eb6e11aa6cedad1ee3545871b
Commit:        2dae78b722cff63eb6e11aa6cedad1ee3545871b
Parent:        1d7b2715e51b399dd275a832f488cd712b044844
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 23 11:47:10 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 23 14:19:17 2014 +0100

thin: rename function

Rename pool_can_resize_metadata() to more reusable
thin_pool_feature_supported() which could be queried
for mutiple different features.
---
 WHATS_NEW                        |    1 +
 lib/metadata/lv_manip.c          |    4 ++--
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/thin_manip.c        |    4 ++--
 4 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 73f716c..e491ed8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Rename internal pool_can_resize_metadata() to thin_pool_feature_supported().
   Issue error if libbblkid detects signature and fails to return offset/length.
   Update autoconf config.guess/sub to 2014-01-01.
   Online thin pool metadata resize requires 1.10 kernel thin pool target.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 07ee764..6333ef6 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3469,7 +3469,7 @@ static int _adjust_policy_params(struct cmd_context *cmd,
 			return_0;
 		if ((PERCENT_0 < percent && percent <= PERCENT_100) &&
 		    (percent > policy_threshold)) {
-			if (!pool_can_resize_metadata(lv)) {
+			if (!thin_pool_feature_supported(lv, THIN_FEATURE_METADATA_RESIZE)) {
 				log_error_once("Online metadata resize for %s/%s is not supported.",
 					       lp->vg_name, lp->lv_name);
 				return 0;
@@ -3535,7 +3535,7 @@ static int _lvresize_poolmetadata_prepare(struct cmd_context *cmd,
 
 	lp->poolmetadataextents = 0;
 
-	if (!pool_can_resize_metadata(pool_lv)) {
+	if (!thin_pool_feature_supported(pool_lv, THIN_FEATURE_METADATA_RESIZE)) {
 		log_error("Support for online metadata resize not detected.");
 		return 0;
 	}
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 52a1c4c..6e7987d 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -674,7 +674,7 @@ uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 
 struct logical_volume *find_pool_lv(const struct logical_volume *lv);
 int pool_is_active(const struct logical_volume *pool_lv);
-int pool_can_resize_metadata(const struct logical_volume *pool_lv);
+int thin_pool_feature_supported(const struct logical_volume *pool_lv, int feature);
 int update_pool_lv(struct logical_volume *lv, int activate);
 int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profile,
 				  int passed_args, int *chunk_size_calc_method,
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 00647cc..92c4177 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -206,7 +206,7 @@ int pool_is_active(const struct logical_volume *lv)
 	return 0;
 }
 
-int pool_can_resize_metadata(const struct logical_volume *lv)
+int thin_pool_feature_supported(const struct logical_volume *lv, int feature)
 {
 	static unsigned attr = 0U;
 	struct lv_segment *seg;
@@ -225,7 +225,7 @@ int pool_can_resize_metadata(const struct logical_volume *lv)
 		return 0;
 	}
 
-	return (attr & THIN_FEATURE_METADATA_RESIZE) ? 1 : 0;
+	return (attr & feature) ? 1 : 0;
 }
 
 int pool_below_threshold(const struct lv_segment *pool_seg)


