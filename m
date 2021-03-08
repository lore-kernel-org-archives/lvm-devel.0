From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Mar 2021 14:46:46 +0000 (GMT)
Subject: main - lvremove: reduce ioctl count
Message-ID: <20210308144646.8A59E3952022@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=78c7ae7cd2dab7abf9ece9bec37979fa3b33c978
Commit:        78c7ae7cd2dab7abf9ece9bec37979fa3b33c978
Parent:        dceef4709d7ee5d06fb61120cc15fc29feb3e6b8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 8 14:22:43 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 8 15:32:10 2021 +0100

lvremove: reduce ioctl count

Just like with deactivation, call of 'lv_is_not_in_use()'
now has embeded report for inactivate LV.

Note: this patch cannot be backported to stable-2.02 - as
there lv_is_active() has 'cluster' meaning and differs from lvinfo().
---
 lib/metadata/lv_manip.c | 39 ++++++++++++++++++++-------------------
 1 file changed, 20 insertions(+), 19 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b93f18e6e..5573e6f43 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6602,26 +6602,27 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	/* FIXME Ensure not referred to by another existing LVs */
 	ask_discard = find_config_tree_bool(cmd, devices_issue_discards_CFG, NULL);
 
-	if (!lv_is_cache_vol(lv) &&
-	    lv_is_active(lv)) {
-		if (!lv_check_not_in_use(lv, 1))
-			return_0;
-
-		if ((force == PROMPT) &&
-		    !lv_is_pending_delete(lv) &&
-		    lv_is_visible(lv)) {
-			if (vg->needs_write_and_commit && (!vg_write(vg) || !vg_commit(vg)))
-				return 0;
-			if (yes_no_prompt("Do you really want to remove%s active "
-					  "%slogical volume %s? [y/n]: ",
-					  ask_discard ? " and DISCARD" : "",
-					  vg_is_clustered(vg) ? "clustered " : "",
-					  display_lvname(lv)) == 'n') {
-				log_error("Logical volume %s not removed.", display_lvname(lv));
-				return 0;
+	if (!lv_is_cache_vol(lv)) {
+		switch (lv_check_not_in_use(lv, 1)) {
+		case 0: return_0;
+		case 1: /* Active, not in use */
+			if ((force == PROMPT) &&
+			    !lv_is_pending_delete(lv) &&
+			    lv_is_visible(lv)) {
+				if (vg->needs_write_and_commit && (!vg_write(vg) || !vg_commit(vg)))
+					return 0;
+				if (yes_no_prompt("Do you really want to remove%s active "
+						  "%slogical volume %s? [y/n]: ",
+						  ask_discard ? " and DISCARD" : "",
+						  vg_is_clustered(vg) ? "clustered " : "",
+						  display_lvname(lv)) == 'n') {
+					log_error("Logical volume %s not removed.", display_lvname(lv));
+					return 0;
+				}
+				ask_discard = 0;
 			}
-
-			ask_discard = 0;
+			break;
+		default: /* Not active */ ;
 		}
 	}
 


