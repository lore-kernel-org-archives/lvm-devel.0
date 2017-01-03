From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  3 Jan 2017 13:56:19 +0000 (UTC)
Subject: master - cleanup: more use of lvseg_name
Message-ID: <20170103135619.5858B6102C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1f5dde38a7ec18d86c38c0b7e1cb2a953ea5cf44
Commit:        1f5dde38a7ec18d86c38c0b7e1cb2a953ea5cf44
Parent:        dc5bb12956d11f84352d45c69805570fc64ba66e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 25 00:29:30 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 3 14:55:16 2017 +0100

cleanup: more use of lvseg_name

Use existing function lvseg_name().
---
 lib/activate/activate.c     |    2 +-
 lib/activate/dev_manager.c  |    2 +-
 lib/format1/import-export.c |    2 +-
 lib/metadata/cache_manip.c  |    2 +-
 lib/metadata/lv_manip.c     |    2 +-
 lib/metadata/raid_manip.c   |   11 +----------
 tools/lvchange.c            |    2 +-
 7 files changed, 7 insertions(+), 16 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 742d838..608611f 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1940,7 +1940,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 			/* FIXME specify events */
 			if (!monitor_fn(seg, 0)) {
 				log_error("%s: %s segment monitoring function failed.",
-					  display_lvname(lv), seg->segtype->name);
+					  display_lvname(lv), lvseg_name(seg));
 				return 0;
 			}
 		} else
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 685c055..6df254a 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2493,7 +2493,7 @@ static int _add_target_to_dtree(struct dev_manager *dm,
 
 	if (!seg->segtype->ops->add_target_line) {
 		log_error(INTERNAL_ERROR "_emit_target cannot handle "
-			  "segment type %s.", seg->segtype->name);
+			  "segment type %s.", lvseg_name(seg));
 		return 0;
 	}
 
diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index 146623e..c174031 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -398,7 +398,7 @@ int export_extents(struct disk_list *dl, uint32_t lv_num,
 			if (!(seg->segtype->flags & SEG_FORMAT1_SUPPORT)) {
 				log_error("Segment type %s in LV %s: "
 					  "unsupported by format1",
-					  seg->segtype->name, lv->name);
+					  lvseg_name(seg), lv->name);
 				return 0;
 			}
 			if (seg_type(seg, s) != AREA_PV) {
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index cddaf82..aee3db8 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -326,7 +326,7 @@ int validate_lv_cache_create_origin(const struct logical_volume *origin_lv)
 	    lv_is_cow(origin_lv) || lv_is_merging_cow(origin_lv) ||
 	    lv_is_virtual(origin_lv)) {
 		log_error("Cache is not supported with %s segment type of the original logical volume %s.",
-			  first_seg(origin_lv)->segtype->name, display_lvname(origin_lv));
+			  lvseg_name(first_seg(origin_lv)), display_lvname(origin_lv));
 		return 0;
 	}
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e948512..9759cda 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4596,7 +4596,7 @@ static int _lvresize_adjust_policy(const struct logical_volume *lv,
 
 	if (!policy_amount) {
 		log_error("Can't extend %s with %s autoextend percent set to 0%%.",
-			  display_lvname(lv),  first_seg(lv)->segtype->name);
+			  display_lvname(lv),  lvseg_name(first_seg(lv)));
 		return 0;
 	}
 
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 5ec86a3..bceff79 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2724,15 +2724,6 @@ static const char *_get_segtype_alias(const struct segment_type *segtype)
 	return "";
 }
 
-/* Return "linear" for striped segtype with 1 area instead of "striped" */
-static const char *_get_segtype_name(const struct segment_type *segtype, unsigned new_image_count)
-{
-	if (!segtype || (segtype_is_striped(segtype) && new_image_count == 1))
-		return "linear";
-
-	return segtype->name;
-}
-
 static int _log_possible_conversion_types(const struct logical_volume *lv, const struct segment_type *new_segtype)
 {
 	unsigned possible_conversions = 0;
@@ -2753,7 +2744,7 @@ static int _log_possible_conversion_types(const struct logical_volume *lv, const
 
 			log_error("Converting %s from %s%s%s%s is "
 				  "directly possible to the following layout%s:",
-				  display_lvname(lv), _get_segtype_name(seg->segtype, seg->area_count),
+				  display_lvname(lv), lvseg_name(seg),
 				  *alias ? " (same as " : "", alias, *alias ? ")" : "",
 				  possible_conversions > 1 ? "s" : "");
 
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 250d720..9fec436 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -431,7 +431,7 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 	/* Separate mirror log or metadata devices so we can clear them */
 	if (!detach_metadata_devices(seg, &device_list)) {
 		log_error("Failed to clear %s %s for %s.",
-			  seg->segtype->name, seg_is_raid(seg) ?
+			  lvseg_name(seg), seg_is_raid(seg) ?
 			  "metadata area" : "mirror log", display_lvname(lv));
 		return 0;
 	}


