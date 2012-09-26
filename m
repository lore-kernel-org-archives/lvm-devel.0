From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Sep 2012 17:56:10 +0000 (UTC)
Subject: master - lvremove: Ask before discarding data areas.
Message-ID: <20120926175610.81D5EA33AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5f5832e318e43c86054a28a4c9f3003542513663
Commit:        5f5832e318e43c86054a28a4c9f3003542513663
Parent:        f8e287cca21feda34ff261e449e8d5a89a9490e9
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Sep 26 12:23:44 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 26 17:26:23 2012 +0200

lvremove: Ask before discarding data areas.

---
 lib/metadata/lv_manip.c |   29 ++++++++++++++++++++++-------
 1 files changed, 22 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 3702caf..6c62bb3 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3253,6 +3253,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	int format1_reload_required = 0;
 	int visible;
 	struct logical_volume *pool_lv = NULL;
+	int ask_discard;
 
 	vg = lv->vg;
 
@@ -3296,6 +3297,8 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* FIXME Ensure not referred to by another existing LVs */
+	ask_discard = find_config_tree_bool(cmd,
+					    "devices/issue_discards", DEFAULT_ISSUE_DISCARDS);
 
 	if (lv_info(cmd, lv, 0, &info, 1, 0)) {
 		if (!lv_check_not_in_use(cmd, lv, &info))
@@ -3303,16 +3306,28 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 		if ((force == PROMPT) &&
 		    lv_is_visible(lv) &&
-		    lv_is_active(lv) &&
-		    yes_no_prompt("Do you really want to remove active "
-				  "%slogical volume %s? [y/n]: ",
-				  vg_is_clustered(vg) ? "clustered " : "",
-				  lv->name) == 'n') {
-			log_error("Logical volume %s not removed", lv->name);
-			return 0;
+		    lv_is_active(lv)) {
+			if (yes_no_prompt("Do you really want to remove%s active "
+					  "%slogical volume %s? [y/n]: ",
+					  ask_discard ? " and DISCARD" : "",
+					  vg_is_clustered(vg) ? "clustered " : "",
+					  lv->name) == 'n') {
+				log_error("Logical volume %s not removed", lv->name);
+				return 0;
+			} else {
+				ask_discard = 0;
+			}
 		}
 	}
 
+	if ((force == PROMPT) && ask_discard &&
+	    yes_no_prompt("Do you really want to remove and DISCARD "
+			  "logical volume %s? [y/n]: ",
+			  lv->name) == 'n') {
+		log_error("Logical volume %s not removed", lv->name);
+		return 0;
+	}
+
 	if (!archive(vg))
 		return 0;
 


