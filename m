From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 25 Oct 2015 20:10:03 +0000 (UTC)
Subject: master - dev_manager: no flush for extension
Message-ID: <20151025201003.0BF4C60AA4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f898cf7539149a54a121b0aae59076c2d647bb37
Commit:        f898cf7539149a54a121b0aae59076c2d647bb37
Parent:        844b00958492224c448b30f89ae5532bb6591fd2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 25 20:41:19 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 25 21:09:31 2015 +0100

dev_manager: no flush for extension

Recognize the target only 'extends' and do not enforce
'flush' in this case.  Only the size reduction
still requires flush (so disables usage of no_flush flag).

If some other targets do require flush before suspend,
they have to explicitly ask for it.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 33d11a4..80a198a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Enforce flush for suspend only when volume size is reduced.
   Enable code which detects the need of flush during suspend.
   Ensure --use-policy will resize volume to fit below threshold.
   Correct percentage evaluation when checking thin-pool over threshold.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 1caa2d7..dc6d2fd 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -3296,7 +3296,7 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 		if (!dm_tree_preload_children(root, dlid, DLID_SIZE))
 			goto_out;
 
-		if (dm_tree_node_size_changed(root))
+		if ((dm_tree_node_size_changed(root) < 0))
 			dm->flush_required = 1;
 
 		if (action == ACTIVATE) {


