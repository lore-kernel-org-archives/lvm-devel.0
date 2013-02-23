From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 23 Feb 2013 09:41:56 +0000 (UTC)
Subject: master - lvremove: easier removal of dependent lvs
Message-ID: <20130223094156.6D1B640A4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d023b2d12f31700956bca3b274e88c42f2d65d7a
Commit:        d023b2d12f31700956bca3b274e88c42f2d65d7a
Parent:        3679bb1cd9f48a0dc4a557ad1c3c3b3713e840bf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 20 16:13:17 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Feb 23 10:31:05 2013 +0100

lvremove: easier removal of dependent lvs

Add function to remove lvs which are depending on removed lv
prior the lv is removed.

User is asked for confirmation.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   49 ++++++++++++++++++++++++++++++----------------
 2 files changed, 33 insertions(+), 17 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 273f152..4e1f758 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add _lv_remove_segs_using_this_lv() for removal of dependent lvs.
   Improve activation code for better support of stacked devices.
   Add _add_layer_target_to_dtree() for adding linear layer into dtree.
   Extend _cached_info() to accept layer string.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 818e740..58c1e26 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3488,6 +3488,35 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
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
@@ -3496,7 +3525,6 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 {
 	percent_t snap_percent;
 	struct dm_list *snh, *snht;
-	struct seg_list *sl, *tsl;
 	struct lvinfo info;
 
 	if (lv_is_cow(lv)) {
@@ -3547,22 +3575,9 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
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
-
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


