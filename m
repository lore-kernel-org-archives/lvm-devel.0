From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Jun 2013 12:09:08 +0000 (UTC)
Subject: master - thin: add helper functions
Message-ID: <20130611120908.20E4C60DC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=72c3ae253e52b896795cc0769860c4fcd82ef244
Commit:        72c3ae253e52b896795cc0769860c4fcd82ef244
Parent:        55a3859632c861e8a3bd07a7c848fdb1901e0a05
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 11 12:32:01 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 11 14:03:30 2013 +0200

thin: add helper functions

Add find_pool_lv() and pool_can_resize_metadata().
---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    2 ++
 lib/metadata/thin_manip.c        |   32 ++++++++++++++++++++++++++++++++
 3 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f85730c..084738d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add helper functions find_pool_lv() and pool_can_resize_metadata().
   Add detection for thin pool metadata resize kernel support.
   Report lvs volume type 'e' with higher priority.
   Report lvs volume type 'o' also for external origin volumes.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index cfa5ad8..5fb5b6c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -578,7 +578,9 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 			   uint32_t extent_size);
 
+struct logical_volume *find_pool_lv(struct logical_volume *lv);
 int pool_is_active(const struct logical_volume *pool_lv);
+int pool_can_resize_metadata(const struct logical_volume *pool_lv);
 int update_pool_lv(struct logical_volume *lv, int activate);
 int update_pool_params(struct cmd_context *cmd, unsigned attr, int passed_args,
 		       uint32_t data_extents, uint32_t extent_size,
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 1239af9..37b5d77 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -309,6 +309,28 @@ int pool_is_active(const struct logical_volume *lv)
 	return 0;
 }
 
+int pool_can_resize_metadata(const struct logical_volume *lv)
+{
+	static unsigned attr = 0U;
+	struct lv_segment *seg;
+
+	if (!lv_is_thin_pool(lv)) {
+		log_error(INTERNAL_ERROR "LV %s is not thin pool.", lv->name);
+		return 0;
+	}
+
+	seg = first_seg(lv);
+	if ((attr == 0U) && activation() && seg->segtype &&
+	    seg->segtype->ops->target_present &&
+	    !seg->segtype->ops->target_present(lv->vg->cmd, NULL, &attr)) {
+		log_error("%s: Required device-mapper target(s) not "
+			  "detected in your kernel", seg->segtype->name);
+		return 0;
+	}
+
+	return (attr & THIN_FEATURE_METADATA_RESIZE) ? 1 : 0;
+}
+
 int pool_below_threshold(const struct lv_segment *pool_seg)
 {
 	percent_t percent;
@@ -352,6 +374,16 @@ struct lv_segment *find_pool_seg(const struct lv_segment *seg)
 	return pool_seg;
 }
 
+struct logical_volume *find_pool_lv(struct logical_volume *lv)
+{
+	struct lv_segment *seg;
+
+	if (!(seg = find_pool_seg(first_seg(lv))))
+		return_NULL;
+
+	return seg->lv;
+}
+
 /*
  * Find a free device_id for given thin_pool segment.
  *


