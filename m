From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Dec 2013 14:21:36 +0000 (UTC)
Subject: master - Revert "tree_action: destroy devices from failing activation"
Message-ID: <20131217142136.0FCBC61322@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c3d82d717ccd4d4801f5d84787bb12e0189eb1af
Commit:        c3d82d717ccd4d4801f5d84787bb12e0189eb1af
Parent:        3652083f38ca21276c8467f54eeaa8f1365ec6fe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 17 15:17:44 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 17 15:21:28 2013 +0100

Revert "tree_action: destroy devices from failing activation"

This reverts commit 24639be558a9d4561a34f2b76485b227aed8e9c3.

Ok - seems we could be here a bit too active - and we
may remove devices which are unsuable for reasons we are not
aware of - thus taking down whole device could be way to big hammer.

So we still need some solution to recover from failing preload
and activation - but it needs more tunning.
---
 WHATS_NEW                  |    1 -
 lib/activate/dev_manager.c |   10 ++--------
 2 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 59820b2..a7522f9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,5 @@
 Version 2.02.105 -
 =====================================
-  Try to remove any unusable devices from dm table when activation fails.
   Dependency scan counts with snapshots and external origins.
   Make sure VG extent size is always greater or equal to PV phys. block size.
   Optimize double call of stat() for cached devices.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index a4147d3..7b0b6e2 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2754,21 +2754,15 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 			goto_out;
 
 		/* Preload any devices required before any suspensions */
-		if (!dm_tree_preload_children(root, dlid, DLID_SIZE)) {
-		bad:
-			if (!dm_tree_deactivate_children(root, dlid, DLID_SIZE))
-				stack;
-			if (!_remove_lv_symlinks(dm, root))
-				log_warn("Failed to remove all device symlinks associated with %s.", lv->name);
+		if (!dm_tree_preload_children(root, dlid, DLID_SIZE))
 			goto_out;
-		}
 
 		if (dm_tree_node_size_changed(root))
 			dm->flush_required = 1;
 
 		if (action == ACTIVATE) {
 			if (!dm_tree_activate_children(root, dlid, DLID_SIZE))
-				goto_bad;
+				goto_out;
 			if (!_create_lv_symlinks(dm, root))
 				log_warn("Failed to create symlinks for %s.", lv->name);
 		}


