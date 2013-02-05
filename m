From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  5 Feb 2013 15:54:55 +0000 (UTC)
Subject: master - thin: update pool_is_active
Message-ID: <20130205155456.11E8F230F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7910b6c0badbf222e7c434f4cb3c0ad2ed3bd3a7
Commit:        7910b6c0badbf222e7c434f4cb3c0ad2ed3bd3a7
Parent:        c984d8fbab73face6a137cd72c114e3c2edb0448
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 5 16:49:09 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 5 16:54:11 2013 +0100

thin: update pool_is_active

Change it to take LV and move it to exported header - seems
to be a better fit for usability from tools/ directory.
---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.h          |    1 -
 lib/metadata/thin_manip.c        |    5 ++---
 tools/lvchange.c                 |    2 +-
 4 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index ffec129..db62d51 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -566,6 +566,7 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 			   uint32_t extent_size);
 
+int pool_is_active(const struct logical_volume *pool_lv);
 int update_pool_lv(struct logical_volume *lv, int activate);
 int get_pool_discards(const char *str, thin_discards_t *discards);
 const char *get_pool_discards_name(thin_discards_t discards);
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 8a80147..19bf742 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -472,7 +472,6 @@ int attach_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
 			int auto_increment);
 int pool_has_message(const struct lv_segment *seg,
 		     const struct logical_volume *lv, uint32_t device_id);
-int pool_is_active(const struct lv_segment *pool_seg);
 int pool_below_threshold(const struct lv_segment *pool_seg);
 int extend_pool(struct logical_volume *lv, const struct segment_type *segtype,
 		struct alloc_handle *ah, uint32_t stripes, uint32_t stripe_size);
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 6ec97d4..05fc052 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -234,13 +234,12 @@ int pool_has_message(const struct lv_segment *seg,
 	return 0;
 }
 
-int pool_is_active(const struct lv_segment *pool_seg)
+int pool_is_active(const struct logical_volume *lv)
 {
 	struct lvinfo info;
 	const struct seg_list *sl;
-	const struct logical_volume *lv = pool_seg->lv;
 
-	if (!seg_is_thin_pool(pool_seg)) {
+	if (!lv_is_thin_pool(lv)) {
 		log_error(INTERNAL_ERROR "LV %s is not pool.", lv->name);
 		return 0;
 	}
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 0ea2e78..07015e7 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -113,7 +113,7 @@ static int lvchange_pool_update(struct cmd_context *cmd,
 		if (discards != first_seg(lv)->discards) {
 			if (((discards == THIN_DISCARDS_IGNORE) ||
 			     (first_seg(lv)->discards == THIN_DISCARDS_IGNORE)) &&
-			    pool_is_active(first_seg(lv)))
+			    pool_is_active(lv))
 				log_error("Cannot change discards state for active "
 					  "pool volume \"%s\".", lv->name);
 			else {


