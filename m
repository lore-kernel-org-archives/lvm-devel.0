From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 26 Oct 2015 22:58:30 +0000 (UTC)
Subject: master - thin: limit no-flush using only for thin-pool
Message-ID: <20151026225830.898F2610E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ba41ee1dc94264f7ac8e61f8b1d56b10225b0d2f
Commit:        ba41ee1dc94264f7ac8e61f8b1d56b10225b0d2f
Parent:        b702d677477ff6b37678fe2b6c38969792c09359
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 26 21:46:54 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 26 23:57:31 2015 +0100

thin: limit  no-flush using only for thin-pool

For this release keep usage of 'noflush' only for thin-volume/pool.

For rest of keep - keep usage of 'noflush' flag purely for
non-resized mirrors.
---
 WHATS_NEW                  |    2 +-
 lib/activate/dev_manager.c |    7 +++++++
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 80a198a..bced219 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,6 @@
 Version 2.02.133 - 
 ======================================
-  Enforce flush for suspend only when volume size is reduced.
+  For thins use flush for suspend only when volume size is reduced.
   Enable code which detects the need of flush during suspend.
   Ensure --use-policy will resize volume to fit below threshold.
   Correct percentage evaluation when checking thin-pool over threshold.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index dc6d2fd..964eef5 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -3299,6 +3299,13 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 		if ((dm_tree_node_size_changed(root) < 0))
 			dm->flush_required = 1;
 
+		/* Currently keep the code require flush for any
+		 * non 'thin pool/volume, mirror' or with any size change */
+		if (!lv_is_thin_volume(lv) &&
+		    !lv_is_thin_pool(lv) &&
+		    (!lv_is_mirror(lv) || dm_tree_node_size_changed(root)))
+			dm->flush_required = 1;
+
 		if (action == ACTIVATE) {
 			if (!dm_tree_activate_children(root, dlid, DLID_SIZE))
 				goto_out;


