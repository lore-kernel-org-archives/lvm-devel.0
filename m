From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:57 +0000 (GMT)
Subject: stable-2.02 - active: fix compilation without devmapper
Message-ID: <20201016191157.D4F6F396E814@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7d6dfe901984aeeed23299ab3e6271432061f3be
Commit:        7d6dfe901984aeeed23299ab3e6271432061f3be
Parent:        0a825734161d2c90a5dfea091bf5e94e7002382a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 28 18:56:58 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 18:09:54 2020 +0200

active: fix compilation without devmapper

Better support for compilation without device-mapper.
---
 lib/activate/activate.c   | 22 ++++++++--------------
 lib/metadata/lv_manip.c   |  8 ++++----
 lib/metadata/thin_manip.c |  6 +++---
 lib/raid/raid.c           | 34 +++++++++++++++++-----------------
 4 files changed, 32 insertions(+), 38 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 97486ebf0..0e06e358f 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -186,8 +186,8 @@ void set_activation(int act, int silent)
 	if (warned || !act)
 		return;
 
-	log_error("Compiled without libdevmapper support. "
-		  "Can't enable activation.");
+	log_warn("WARNING: Compiled without libdevmapper support. "
+		 "Can't enable activation.");
 
 	warned = 1;
 }
@@ -222,23 +222,13 @@ int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int use_la
 {
 	return 0;
 }
-int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
-		    struct lvinfo *info, int with_open_count, int with_read_ahead)
-{
-	return 0;
-}
-int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume *lv,
-			    const struct lv_segment *lv_seg, int use_layer,
+int lv_info_with_seg_status(struct cmd_context *cmd,
+			    const struct lv_segment *lv_seg,
 			    struct lv_with_info_and_seg_status *status,
 			    int with_open_count, int with_read_ahead)
 {
 	return 0;
 }
-int lv_status(struct cmd_context *cmd, const struct lv_segment *lv_seg,
-	      int use_layer, struct lv_seg_status *lv_seg_status)
-{
-	return 0;
-}
 int lv_cache_status(const struct logical_volume *cache_lv,
 		    struct lv_status_cache **status)
 {
@@ -285,6 +275,10 @@ int lv_raid_message(const struct logical_volume *lv, const char *msg)
 {
 	return 0;
 }
+int lv_writecache_message(const struct logical_volume *lv, const char *msg)
+{
+	return 0;
+}
 int lv_thin_pool_status(const struct logical_volume *lv, int flush,
 			struct lv_status_thin_pool **thin_pool_status)
 {
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 399ac0774..e4ea30d12 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7559,10 +7559,10 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			return NULL;
 		}
 		/* Does LV need to be zeroed? */
-		if (lp->zero && !seg_is_thin(lp)) {
-			log_error("Can't wipe start of new LV without using "
-				  "device-mapper kernel driver.");
-			return NULL;
+		if (lp->zero) {
+			log_warn("WARNING: Skipping zeroing and wipping, compiled without activation support.");
+			lp->zero = 0;
+			lp->wipe_signatures = 0;
 		}
 	}
 
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 9fb12cfa7..695aff101 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -544,9 +544,9 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 				return_0;
 			}
 			if (!lv_is_active(lv)) {
-				init_dmeventd_monitor(monitored);
-				log_error("Cannot activate thin pool %s, perhaps skipped in lvm.conf volume_list?",
-					  display_lvname(lv));
+				(void) init_dmeventd_monitor(monitored);
+				log_error("Cannot activate thin pool %s%s", display_lvname(lv),
+					  activation() ? ", perhaps skipped in lvm.conf volume_list?" : ".");
 				return 0;
 			}
 		} else
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index e926ae116..28340a0ca 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -24,10 +24,6 @@
 #include "metadata.h"
 #include "lv_alloc.h"
 
-static int _raid_target_present(struct cmd_context *cmd,
-				const struct lv_segment *seg __attribute__((unused)),
-				unsigned *attributes);
-
 static void _raid_display(const struct lv_segment *seg)
 {
 	unsigned s;
@@ -239,6 +235,22 @@ static int _raid_text_export(const struct lv_segment *seg, struct formatter *f)
 	return _raid_text_export_raid(seg, f);
 }
 
+static int _raid_target_status_compatible(const char *type)
+{
+	return (strstr(type, "raid") != NULL);
+}
+
+static void _raid_destroy(struct segment_type *segtype)
+{
+	dm_free((void *) segtype->dso);
+	dm_free(segtype);
+}
+
+#ifdef DEVMAPPER_SUPPORT
+static int _raid_target_present(struct cmd_context *cmd,
+				const struct lv_segment *seg __attribute__((unused)),
+				unsigned *attributes);
+
 static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 				 struct dm_pool *mem __attribute__((unused)),
 				 struct cmd_context *cmd __attribute__((unused)),
@@ -356,18 +368,6 @@ static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 	return add_areas_line(dm, seg, node, 0u, seg->area_count);
 }
 
-static int _raid_target_status_compatible(const char *type)
-{
-	return (strstr(type, "raid") != NULL);
-}
-
-static void _raid_destroy(struct segment_type *segtype)
-{
-	dm_free((void *) segtype->dso);
-	dm_free(segtype);
-}
-
-#ifdef DEVMAPPER_SUPPORT
 static int _raid_target_percent(void **target_state,
 				dm_percent_t *percent,
 				struct dm_pool *mem,
@@ -568,9 +568,9 @@ static struct segtype_handler _raid_ops = {
 	.text_import_area_count = _raid_text_import_area_count,
 	.text_import = _raid_text_import,
 	.text_export = _raid_text_export,
-	.add_target_line = _raid_add_target_line,
 	.target_status_compatible = _raid_target_status_compatible,
 #ifdef DEVMAPPER_SUPPORT
+	.add_target_line = _raid_add_target_line,
 	.target_percent = _raid_target_percent,
 	.target_present = _raid_target_present,
 	.check_transient_status = _raid_transient_status,


