From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue,  5 Feb 2013 14:56:05 +0100
Subject: [PATCH 4/6] thin: removal of external origin
In-Reply-To: <cover.1360072297.git.zkabelac@redhat.com>
References: <cover.1360072297.git.zkabelac@redhat.com>
Message-ID: <6a5b6b0f1587ad9b9bfd407fe526209ae5aaa9ab.1360072297.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If the removal of external origin is requested,
query if the user also want to remove all its users.

Create common static function _lv_remove_segs_using_this_lv()
so the same code can be shared with thin pool removal.

Note: the function cannot use dm_list_iterate_items_safe()

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/lv_manip.c | 57 +++++++++++++++++++++++++++++++++++--------------
 1 file changed, 41 insertions(+), 16 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 07d3fd7..11bd3a4 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3309,6 +3309,12 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
+	if (lv_is_external_origin(lv)) {
+		log_error("Can't remove external origin logical volume \"%s\".",
+			  lv->name);
+		return 0;
+	}
+
 	if (lv->status & MIRROR_IMAGE) {
 		log_error("Can't remove logical volume %s used by a mirror",
 			  lv->name);
@@ -3448,6 +3454,35 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	return 1;
 }
 
+static int _lv_remove_segs_using_this_lv(struct cmd_context *cmd, struct logical_volume *lv,
+					 const force_t force, unsigned level,
+					 const char *lv_type)
+{
+	struct seg_list *sl;
+
+	if ((force == PROMPT) &&
+	    yes_no_prompt("Removing %s \"%s\" will remove %u dependent volume(s). "
+			  "Proceed? [y/n]: ", lv_type, lv->name,
+			  dm_list_size(&lv->segs_using_this_lv)) == 'n') {
+			log_error("Logical volume \"%s\" not removed.", lv->name);
+			return 0;
+		}
+	/*
+	 * Not using _safe iterator here - since we may delete whole subtree
+	 * (similar as process_each_lv_in_vg())
+	 * the code is roughly equivalent to this:
+	 *
+	 * while (!dm_list_empty(&lv->segs_using_this_lv))
+	 * 	dm_list_iterate_items(sl, &lv->segs_using_this_lv)
+	 * 		break;
+	 */
+	dm_list_iterate_items(sl, &lv->segs_using_this_lv)
+		if (!lv_remove_with_dependencies(cmd, sl->seg->lv,
+						 force, level + 1))
+			return_0;
+
+	return 1;
+}
 /*
  * remove LVs with its dependencies - LV leaf nodes should be removed first
  */
@@ -3456,7 +3491,6 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 {
 	percent_t snap_percent;
 	struct dm_list *snh, *snht;
-	struct seg_list *sl, *tsl;
 	struct lvinfo info;
 
 	if (lv_is_cow(lv)) {
@@ -3507,22 +3541,13 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 				return_0;
 	}
 
-	if (lv_is_used_thin_pool(lv)) {
-		/* Remove thin LVs first */
-		if ((force == PROMPT) &&
-		    yes_no_prompt("Removing pool %s will also remove %u "
-				  "thin volume(s). OK? [y/n]: ", lv->name,
-				  /* Note: Snaphosts not included */
-				  dm_list_size(&lv->segs_using_this_lv)) == 'n') {
-			log_error("Logical volume %s not removed.", lv->name);
-			return 0;
-		}
+	if (lv_is_external_origin(lv) &&
+	    !_lv_remove_segs_using_this_lv(cmd, lv, force, level, "external origin"))
+		return_0;
 
-		dm_list_iterate_items_safe(sl, tsl, &lv->segs_using_this_lv)
-			if (!lv_remove_with_dependencies(cmd, sl->seg->lv,
-							 force, level + 1))
-				return_0;
-	}
+	if (lv_is_used_thin_pool(lv) &&
+	    !_lv_remove_segs_using_this_lv(cmd, lv, force, level, "pool"))
+		return_0;
 
 	return lv_remove_single(cmd, lv, force);
 }
-- 
1.8.1.2


