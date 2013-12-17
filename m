From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Dec 2013 13:09:10 +0000 (UTC)
Subject: master - tree_action: destroy devices from failing activation
Message-ID: <20131217130910.068BB6004F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=24639be558a9d4561a34f2b76485b227aed8e9c3
Commit:        24639be558a9d4561a34f2b76485b227aed8e9c3
Parent:        94137b72edf232a0e82758c1669f1f60f2df3c50
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 17 13:49:03 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 17 14:08:54 2013 +0100

tree_action: destroy devices from failing activation

When activation fails - we may leak large tree of partially loaded
devices in the dm table (i.e. failure in snapshot activation)

The best we can do here is try to deactivate whole device and
remove as much inactive table entries as we can.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   10 ++++++++--
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a7522f9..59820b2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Try to remove any unusable devices from dm table when activation fails.
   Dependency scan counts with snapshots and external origins.
   Make sure VG extent size is always greater or equal to PV phys. block size.
   Optimize double call of stat() for cached devices.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 7b0b6e2..a4147d3 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2754,15 +2754,21 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 			goto_out;
 
 		/* Preload any devices required before any suspensions */
-		if (!dm_tree_preload_children(root, dlid, DLID_SIZE))
+		if (!dm_tree_preload_children(root, dlid, DLID_SIZE)) {
+		bad:
+			if (!dm_tree_deactivate_children(root, dlid, DLID_SIZE))
+				stack;
+			if (!_remove_lv_symlinks(dm, root))
+				log_warn("Failed to remove all device symlinks associated with %s.", lv->name);
 			goto_out;
+		}
 
 		if (dm_tree_node_size_changed(root))
 			dm->flush_required = 1;
 
 		if (action == ACTIVATE) {
 			if (!dm_tree_activate_children(root, dlid, DLID_SIZE))
-				goto_out;
+				goto_bad;
 			if (!_create_lv_symlinks(dm, root))
 				log_warn("Failed to create symlinks for %s.", lv->name);
 		}


