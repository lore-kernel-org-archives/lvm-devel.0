From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:39:53 +0000 (UTC)
Subject: master - cleanup: drop default implementation
Message-ID: <20141024143953.1BAC860E3E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d4dab0aa34102527c32d68f69196aaabda5e3711
Commit:        d4dab0aa34102527c32d68f69196aaabda5e3711
Parent:        9411c19b31b391e7be262d95fb2fa5a5162012b2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 20 20:09:42 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

cleanup: drop default implementation

Now we reference segment name via  lvseg_name() and
we can drop default implementation and leave its
function pointer to be NULL.

Default give us 'return seg->segtype->name'.
---
 lib/cache_segtype/cache.c   |    7 -------
 lib/error/errseg.c          |    6 ------
 lib/freeseg/freeseg.c       |    6 ------
 lib/mirror/mirrored.c       |    6 ------
 lib/raid/raid.c             |    8 +-------
 lib/replicator/replicator.c |    6 ------
 lib/snapshot/snapshot.c     |    8 +-------
 lib/thin/thin.c             |   12 ------------
 lib/unknown/unknown.c       |    7 -------
 lib/zero/zero.c             |    6 ------
 10 files changed, 2 insertions(+), 70 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index ddaf3cf..9927688 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -31,11 +31,6 @@
                   dm_config_parent_name(sn), seg->lv->name), 0;
 
 
-static const char *_name(const struct lv_segment *seg)
-{
-	return seg->segtype->name;
-}
-
 static int _cache_pool_text_import(struct lv_segment *seg,
 				   const struct dm_config_node *sn,
 				   struct dm_hash_table *pv_hash __attribute__((unused)))
@@ -262,7 +257,6 @@ static int _modules_needed(struct dm_pool *mem,
 #endif /* DEVMAPPER_SUPPORT */
 
 static struct segtype_handler _cache_pool_ops = {
-	.name = _name,
 	.text_import = _cache_pool_text_import,
 	.text_import_area_count = _cache_pool_text_import_area_count,
 	.text_export = _cache_pool_text_export,
@@ -365,7 +359,6 @@ static int _cache_add_target_line(struct dev_manager *dm,
 #endif /* DEVMAPPER_SUPPORT */
 
 static struct segtype_handler _cache_ops = {
-	.name = _name,
 	.text_import = _cache_text_import,
 	.text_import_area_count = _cache_text_import_area_count,
 	.text_export = _cache_text_export,
diff --git a/lib/error/errseg.c b/lib/error/errseg.c
index f3bf9c9..af19e7d 100644
--- a/lib/error/errseg.c
+++ b/lib/error/errseg.c
@@ -21,11 +21,6 @@
 #include "activate.h"
 #include "str_list.h"
 
-static const char *_errseg_name(const struct lv_segment *seg)
-{
-	return seg->segtype->name;
-}
-
 static int _errseg_merge_segments(struct lv_segment *seg1, struct lv_segment *seg2)
 {
 	seg1->len += seg2->len;
@@ -83,7 +78,6 @@ static void _errseg_destroy(struct segment_type *segtype)
 }
 
 static struct segtype_handler _error_ops = {
-	.name = _errseg_name,
 	.merge_segments = _errseg_merge_segments,
 #ifdef DEVMAPPER_SUPPORT
 	.add_target_line = _errseg_add_target_line,
diff --git a/lib/freeseg/freeseg.c b/lib/freeseg/freeseg.c
index 1dce243..b4eba94 100644
--- a/lib/freeseg/freeseg.c
+++ b/lib/freeseg/freeseg.c
@@ -16,18 +16,12 @@
 #include "toolcontext.h"
 #include "segtype.h"
 
-static const char *_freeseg_name(const struct lv_segment *seg)
-{
-	return seg->segtype->name;
-}
-
 static void _freeseg_destroy(struct segment_type *segtype)
 {
 	dm_free(segtype);
 }
 
 static struct segtype_handler _freeseg_ops = {
-	.name = _freeseg_name,
 	.destroy = _freeseg_destroy,
 };
 
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 411b4d4..46dfe02 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -38,11 +38,6 @@ struct mirror_state {
 	uint32_t default_region_size;
 };
 
-static const char *_mirrored_name(const struct lv_segment *seg)
-{
-	return seg->segtype->name;
-}
-
 static void _mirrored_display(const struct lv_segment *seg)
 {
 	const char *size;
@@ -592,7 +587,6 @@ static void _mirrored_destroy(struct segment_type *segtype)
 }
 
 static struct segtype_handler _mirrored_ops = {
-	.name = _mirrored_name,
 	.display = _mirrored_display,
 	.text_import_area_count = _mirrored_text_import_area_count,
 	.text_import = _mirrored_text_import,
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 6628dc8..7cc4301 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -25,11 +25,6 @@
 #include "metadata.h"
 #include "lv_alloc.h"
 
-static const char *_raid_name(const struct lv_segment *seg)
-{
-	return seg->segtype->name;
-}
-
 static void _raid_display(const struct lv_segment *seg)
 {
 	unsigned s;
@@ -243,7 +238,7 @@ static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 	if (mirror_in_sync())
 		flags = DM_NOSYNC;
 
-	params.raid_type = _raid_name(seg);
+	params.raid_type = lvseg_name(seg);
 	if (seg->segtype->parity_devs) {
 		/* RAID 4/5/6 */
 		params.mirrors = 1;
@@ -418,7 +413,6 @@ static int _raid_target_unmonitor_events(struct lv_segment *seg, int events)
 #endif /* DEVMAPPER_SUPPORT */
 
 static struct segtype_handler _raid_ops = {
-	.name = _raid_name,
 	.display = _raid_display,
 	.text_import_area_count = _raid_text_import_area_count,
 	.text_import = _raid_text_import,
diff --git a/lib/replicator/replicator.c b/lib/replicator/replicator.c
index 2e3632a..ae87d7f 100644
--- a/lib/replicator/replicator.c
+++ b/lib/replicator/replicator.c
@@ -39,10 +39,6 @@
 /*
  *  Replicator target
  */
-static const char *_replicator_name(const struct lv_segment *seg)
-{
-	return seg->segtype->name;
-}
 
 /* FIXME: missing implementation */
 static void _replicator_display(const struct lv_segment *seg)
@@ -410,7 +406,6 @@ static void _replicator_destroy(struct segment_type *segtype)
 }
 
 static struct segtype_handler _replicator_ops = {
-	.name = _replicator_name,
 	.display = _replicator_display,
 	.text_import = _replicator_text_import,
 	.text_export = _replicator_text_export,
@@ -739,7 +734,6 @@ static int _replicator_dev_target_present(struct cmd_context *cmd,
 #endif
 
 static struct segtype_handler _replicator_dev_ops = {
-	.name = _replicator_name,
 	.display = _replicator_dev_display,
 	.text_import = _replicator_dev_text_import,
 	.text_export = _replicator_dev_text_export,
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 0557f45..18e8111 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -25,18 +25,13 @@
 	log_error(t " segment %s of logical volume %s.", ## p, \
 		  dm_config_parent_name(sn), seg->lv->name), 0;
 
-static const char *_snap_name(const struct lv_segment *seg)
-{
-	return seg->segtype->name;
-}
-
 static const char *_snap_target_name(const struct lv_segment *seg,
 				     const struct lv_activate_opts *laopts)
 {
 	if (!laopts->no_merging && (seg->status & MERGING))
 		return "snapshot-merge";
 
-	return _snap_name(seg);
+	return lvseg_name(seg);
 }
 
 static int _snap_text_import(struct lv_segment *seg, const struct dm_config_node *sn,
@@ -234,7 +229,6 @@ static void _snap_destroy(struct segment_type *segtype)
 }
 
 static struct segtype_handler _snapshot_ops = {
-	.name = _snap_name,
 	.target_name = _snap_target_name,
 	.text_import = _snap_text_import,
 	.text_export = _snap_text_export,
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 6982782..9ae237e 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -36,11 +36,6 @@ static const char _thin_module[] = "thin";
 /* TODO: using static field here, maybe should be a part of segment_type */
 static unsigned _feature_mask;
 
-static const char *_thin_pool_name(const struct lv_segment *seg)
-{
-	return seg->segtype->name;
-}
-
 static void _thin_pool_display(const struct lv_segment *seg)
 {
 	log_print("  Chunk size\t\t%s",
@@ -449,11 +444,6 @@ static int _target_unregister_events(struct lv_segment *seg,
 #  endif /* DMEVENTD */
 #endif /* DEVMAPPER_SUPPORT */
 
-static const char *_thin_name(const struct lv_segment *seg)
-{
-	return seg->segtype->name;
-}
-
 static void _thin_display(const struct lv_segment *seg)
 {
 	log_print("  Device ID\t\t%u", seg->device_id);
@@ -720,7 +710,6 @@ static void _thin_destroy(struct segment_type *segtype)
 }
 
 static struct segtype_handler _thin_pool_ops = {
-	.name = _thin_pool_name,
 	.display = _thin_pool_display,
 	.text_import = _thin_pool_text_import,
 	.text_import_area_count = _thin_pool_text_import_area_count,
@@ -740,7 +729,6 @@ static struct segtype_handler _thin_pool_ops = {
 };
 
 static struct segtype_handler _thin_ops = {
-	.name = _thin_name,
 	.display = _thin_display,
 	.text_import = _thin_text_import,
 	.text_export = _thin_text_export,
diff --git a/lib/unknown/unknown.c b/lib/unknown/unknown.c
index 2ce2f9d..760f1c2 100644
--- a/lib/unknown/unknown.c
+++ b/lib/unknown/unknown.c
@@ -18,12 +18,6 @@
 #include "text_export.h"
 #include "config.h"
 
-static const char *_unknown_name(const struct lv_segment *seg)
-{
-
-	return seg->segtype->name;
-}
-
 static int _unknown_text_import(struct lv_segment *seg, const struct dm_config_node *sn,
 				struct dm_hash_table *pv_hash)
 {
@@ -59,7 +53,6 @@ static void _unknown_destroy(struct segment_type *segtype)
 }
 
 static struct segtype_handler _unknown_ops = {
-	.name = _unknown_name,
 	.text_import = _unknown_text_import,
 	.text_export = _unknown_text_export,
 	.destroy = _unknown_destroy,
diff --git a/lib/zero/zero.c b/lib/zero/zero.c
index 2a1fd0b..9f9d06c 100644
--- a/lib/zero/zero.c
+++ b/lib/zero/zero.c
@@ -19,11 +19,6 @@
 #include "str_list.h"
 #include "activate.h"
 
-static const char *_zero_name(const struct lv_segment *seg)
-{
-	return seg->segtype->name;
-}
-
 static int _zero_merge_segments(struct lv_segment *seg1, struct lv_segment *seg2)
 {
 	seg1->len += seg2->len;
@@ -79,7 +74,6 @@ static void _zero_destroy(struct segment_type *segtype)
 }
 
 static struct segtype_handler _zero_ops = {
-	.name = _zero_name,
 	.merge_segments = _zero_merge_segments,
 #ifdef DEVMAPPER_SUPPORT
 	.add_target_line = _zero_add_target_line,


