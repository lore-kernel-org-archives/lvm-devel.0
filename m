From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Jan 2018 08:46:52 -0500
Subject: master - cleanup: enhance messages
Message-ID: <201801171346.w0HDkqRC030042@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=38b81e6537a8dc497a4bc616a1f51632b43137ca
Commit:        38b81e6537a8dc497a4bc616a1f51632b43137ca
Parent:        a8bcdef4fd172b705572e3c0b277e6941be642f4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 11 10:46:04 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 17 14:45:48 2018 +0100

cleanup: enhance messages

Add extra info about failing local exlusive activation
(as in cluster the LV can be active on some other nodes).
---
 lib/locking/locking.c |    3 ++-
 tools/pvmove.c        |   27 ++++++++++++++-------------
 2 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index c68d4c7..8daa61e 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -406,7 +406,8 @@ int activate_lvs(struct cmd_context *cmd, struct dm_list *lvs)
 
 	dm_list_iterate_items(lvl, lvs) {
 		if (!activate_lv_excl_local(cmd, lvl->lv)) {
-			log_error("Failed to activate %s", display_lvname(lvl->lv));
+			log_error("Failed to locally exclusively activate %s.",
+				  display_lvname(lvl->lv));
 			dm_list_uniterate(lvh, lvs, &lvl->list) {
 				lvl = dm_list_item(lvh, struct lv_list);
 				if (!deactivate_lv(cmd, lvl->lv))
diff --git a/tools/pvmove.c b/tools/pvmove.c
index c5d7e52..af3fec4 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -375,9 +375,9 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			continue;
 
 		if (lv_is_converting(lv) || lv_is_merging(lv)) {
-			log_error("Unable to pvmove when %s volumes are present.",
-				  lv_is_converting(lv) ?
-				  "converting" : "merging");
+			log_error("Unable to pvmove when %s volume %s is present.",
+				  lv_is_converting(lv) ? "converting" : "merging",
+				  display_lvname(lv));
 			return NULL;
 		}
 
@@ -389,13 +389,13 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 				return_NULL;
 
 			/*
- 			 * Remove any PVs holding SubLV siblings to allow
- 			 * for collocation (e.g. *rmeta_0 -> *rimage_0).
- 			 *
- 			 * Callee checks for lv_name and valid raid segment type.
- 			 *
- 			 * FIXME: don't rely on namespace
- 			 */
+			 * Remove any PVs holding SubLV siblings to allow
+			 * for collocation (e.g. *rmeta_0 -> *rimage_0).
+			 *
+			 * Callee checks for lv_name and valid raid segment type.
+			 *
+			 * FIXME: don't rely on namespace
+			 */
 			if (!_remove_sibling_pvs_from_trim_list(lv, lv_name, &trim_list))
 				return_NULL;
 
@@ -436,7 +436,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 
 		if (lv_is_locked(lv)) {
 			lv_skipped = 1;
-			log_print_unless_silent("Skipping locked LV %s.", lv->name);
+			log_print_unless_silent("Skipping locked LV %s.", display_lvname(lv));
 			continue;
 		}
 
@@ -445,8 +445,9 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		    lv_is_active(lv) &&
 		    !lv_is_active_exclusive_locally(lv)) {
 			lv_skipped = 1;
-			log_print_unless_silent("Skipping LV %s which is activated "
-						"exclusively on remote node.", lv->name);
+			log_print_unless_silent("Skipping LV %s which is active, "
+						"but not locally exclusively.",
+						display_lvname(lv));
 			continue;
 		}
 


