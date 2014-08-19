From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 19 Aug 2014 12:20:43 +0000 (UTC)
Subject: master - lv: remove lv_type_name fn
Message-ID: <20140819122043.C533660DF1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=84860fd54f05ca24c389ee60c4aef6903ae227ce
Commit:        84860fd54f05ca24c389ee60c4aef6903ae227ce
Parent:        aec4d0c939653cfc0dadcec43a9db98597154bcb
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 19 14:16:39 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 19 14:16:39 2014 +0200

lv: remove lv_type_name fn

The lv_type_name function is remnant from old code that reported
only single string for the LV type. LV types are now reported
in a more extended way as keyword list that describe the type
precisely (using lv_layout_and_type fn).

The lv_type_name was used in some error messages to display the
type of the LV so just reinstate the old messages back referencing
the type directly with a string - this is enough for error messages.
They don't need to display the LV type as precisely as it's used
on lvs output (which is optimized for selection anyway).
---
 lib/metadata/lv_manip.c          |    5 -----
 lib/metadata/metadata-exported.h |    3 ---
 tools/lvconvert.c                |   15 +++++++--------
 3 files changed, 7 insertions(+), 16 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index dd0ba33..c314377 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -151,11 +151,6 @@ static const char *_lv_type_names[] = {
 	[LV_TYPE_RAID_N_CONTINUE] =			"n-continue",
 };
 
-const char *lv_type_name(const struct logical_volume *lv)
-{
-	return " ";
-}
-
 static int _lv_type_list_mirror(struct dm_pool *mem,
 				const struct logical_volume *lv,
 				struct dm_list *layout,
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 59d68d6..61bb140 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -910,9 +910,6 @@ int get_pv_list_for_lv(struct dm_pool *mem,
 struct lv_segment *first_seg(const struct logical_volume *lv);
 struct lv_segment *last_seg(const struct logical_volume *lv);
 
-/* Human-readable LV type name. */
-const char *lv_type_name(const struct logical_volume *lv);
-
 /*
 * Useful functions for managing snapshots.
 */
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 7330c73..cf8d2c0 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2718,8 +2718,8 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		}
 		if (lv_is_thin_type(metadata_lv) ||
 		    lv_is_cache_type(metadata_lv)) {
-			log_error("Can't use %s LV %s for pool metadata.",
-				  lv_type_name(metadata_lv), display_lvname(metadata_lv));
+			log_error("Can't use thin or cache type LV %s for pool metadata.",
+				  display_lvname(metadata_lv));
 			return 0;
 		}
 
@@ -2822,16 +2822,15 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 
 		if (!lp->yes &&
 		    yes_no_prompt("Do you want to swap metadata of %s "
-				  "pool with %s volume %s? [y/n]: ",
+				  "pool with metadata volume %s? [y/n]: ",
 				  display_lvname(pool_lv),
-				  lv_type_name(metadata_lv),
 				  display_lvname(metadata_lv)) == 'n') {
 			log_error("Conversion aborted.");
 			return 0;
 		}
 	} else if (lv_is_thin_type(pool_lv)) {
-		log_error("Can't use %s logical volume %s for thin pool data.",
-			  lv_type_name(pool_lv), display_lvname(pool_lv));
+		log_error("Can't use thin type logical volume %s for thin pool data.",
+			  display_lvname(pool_lv));
 		return 0;
 	} else {
 		log_warn("WARNING: Converting logical volume %s%s%s to pool's data%s.",
@@ -3047,8 +3046,8 @@ static int _lvconvert_cache(struct cmd_context *cmd,
 	}
 
 	if (lv_is_pool(origin) || lv_is_cache_type(origin)) {
-		log_error("Can't cache %s volume %s.",
-			  lv_type_name(origin), display_lvname(origin));
+		log_error("Can't cache pool or cache type volume %s.",
+			  display_lvname(origin));
 		return 0;
 	}
 


