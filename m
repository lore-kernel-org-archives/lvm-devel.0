From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  5 Feb 2013 13:47:46 +0000 (UTC)
Subject: master - thin: add function pool_is_active
Message-ID: <20130205134746.AD8D6A0C2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=11eaf1c98c3fac8524f227956f57c3d486740a1a
Commit:        11eaf1c98c3fac8524f227956f57c3d486740a1a
Parent:        9d445f371c7658969d6580748233dc33c3ba0453
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 5 10:52:39 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 5 14:35:44 2013 +0100

thin: add function pool_is_active

This internal function check for active pool device.
For cluster it checks every thin volume,
On the non-clustered VG we need to check just
for presence of -tpool device.
---
 WHATS_NEW                 |    1 +
 lib/metadata/metadata.h   |    1 +
 lib/metadata/thin_manip.c |   27 +++++++++++++++++++++++++++
 3 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 64b811e..1b26317 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add pool_is_active() to check for any pool related active LV.
   Report blank field if the LV doesn't have an origin instead of 0.
   Do not take a free lv name argument for lvconvert --thinpool option.
   Avoid flushing thin pool when quering for transaction_id.
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 19bf742..8a80147 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -472,6 +472,7 @@ int attach_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
 			int auto_increment);
 int pool_has_message(const struct lv_segment *seg,
 		     const struct logical_volume *lv, uint32_t device_id);
+int pool_is_active(const struct lv_segment *pool_seg);
 int pool_below_threshold(const struct lv_segment *pool_seg);
 int extend_pool(struct logical_volume *lv, const struct segment_type *segtype,
 		struct alloc_handle *ah, uint32_t stripes, uint32_t stripe_size);
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 016f776..51f3d16 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -230,6 +230,33 @@ int pool_has_message(const struct lv_segment *seg,
 	return 0;
 }
 
+int pool_is_active(const struct lv_segment *pool_seg)
+{
+	struct lvinfo info;
+	const struct seg_list *sl;
+	const struct logical_volume *lv = pool_seg->lv;
+
+	if (!seg_is_thin_pool(pool_seg)) {
+		log_error(INTERNAL_ERROR "LV %s is not pool.", lv->name);
+		return 0;
+	}
+
+	/* On clustered VG, query every related thin pool volume */
+	if (vg_is_clustered(lv->vg)) {
+		if (lv_is_active(lv))
+			return 1;
+
+		dm_list_iterate_items(sl, &lv->segs_using_this_lv)
+			if (lv_is_active(sl->seg->lv)) {
+				log_debug("Thin volume \"%s\" is active.", sl->seg->lv->name);
+				return 1;
+			}
+	} else if (lv_info(lv->vg->cmd, lv, 1, &info, 0, 0) && info.exists)
+		return 1; /* Non clustered VG - just checks for '-tpool' */
+
+	return 0;
+}
+
 int pool_below_threshold(const struct lv_segment *pool_seg)
 {
 	percent_t percent;


