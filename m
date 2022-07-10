From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 10 Jul 2022 23:22:26 +0000 (GMT)
Subject: main - cov: restore disable_dm_devs also for error path
Message-ID: <20220710232226.51946385734A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4d2f9a4ff3fbfe4ee0df08478d81ea10f75823de
Commit:        4d2f9a4ff3fbfe4ee0df08478d81ea10f75823de
Parent:        5c463584f6b0541cc0144335b49afd2d94745928
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 9 02:50:08 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 11 01:18:24 2022 +0200

cov: restore disable_dm_devs also for error path

Keep the structure correct for failing error path,
alhtough likely this particual var will not be used.
---
 lib/activate/dev_manager.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 2cae3bed1..8cb31008e 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -3842,11 +3842,12 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 	if (!seg_is_striped_target(first_seg(lv)) || (action == CLEAN))
 		dm->cmd->disable_dm_devs = 1;
 
-	if (!(dtree = _create_partial_dtree(dm, lv, laopts->origin_only)))
-		return_0;
-
+	dtree = _create_partial_dtree(dm, lv, laopts->origin_only);
 	dm->cmd->disable_dm_devs = tmp_state;
 
+	if (!dtree)
+		return_0;
+
 	if (!(root = dm_tree_find_node(dtree, 0, 0))) {
 		log_error("Lost dependency tree root node.");
 		goto out_no_root;

