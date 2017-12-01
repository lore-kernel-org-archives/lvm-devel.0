From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 1 Dec 2017 06:20:44 -0500
Subject: master - cleanup: remove debug code
Message-ID: <201712011120.vB1BKih7029498@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a42c3a0e90d712652890696fefca51380969d595
Commit:        a42c3a0e90d712652890696fefca51380969d595
Parent:        0e177cc7c90139441530fc065125fa510671e610
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 27 16:52:38 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 1 12:19:09 2017 +0100

cleanup: remove debug code

---
 lib/activate/activate.c    |    7 -------
 lib/activate/dev_manager.c |    2 --
 2 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 381083b..e7653a2 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -323,12 +323,6 @@ int lvs_in_vg_opened(const struct volume_group *vg)
 {
 	return 0;
 }
-/******
-int lv_suspend(struct cmd_context *cmd, const char *lvid_s)
-{
-	return 1;
-}
-*******/
 int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, unsigned exclusive,
 			 const struct logical_volume *lv, const struct logical_volume *lv_pre)
 {
@@ -2369,7 +2363,6 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 		if (error_if_not_active)
 			goto_out;
 
-
 		/* ATM only thin-pool with origin-only suspend does not really suspend anything
 		 * it's used only for message passing to thin-pool */
 		if (laopts->origin_only && lv_is_thin_pool(lv))
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 9f19912..5662090 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -3135,8 +3135,6 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 		if (!dm_tree_preload_children(root, dlid, DLID_SIZE))
 			goto_out;
 
-		//if (action == PRELOAD) { log_debug("SLEEP"); sleep(7); }
-
 		if ((dm_tree_node_size_changed(root) < 0))
 			dm->flush_required = 1;
 		/* Currently keep the code require flush for any


