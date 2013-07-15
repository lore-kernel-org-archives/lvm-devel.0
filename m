From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Jul 2013 14:03:03 +0000 (UTC)
Subject: master - thin: check and use layered origin lv
Message-ID: <20130715140303.9391460FE8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=97d36d5750924029c247265c8d700f993405668f
Commit:        97d36d5750924029c247265c8d700f993405668f
Parent:        925701d9f37e149a738aa4875f2933bee42ca8d0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 15 11:47:10 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 15 15:51:39 2013 +0200

thin: check and use layered origin lv

Code needs to check if the layer origin device is suspended,
It's valid to create  thinvolume snapshot of thinvolume which is also
used as an old-style snapshot. In this case we need to check -real
is suspended.

When adding origin_only - add only layer thin volume.
(in case it's also old-snapshot add only -real device)
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    2 +-
 lib/thin/thin.c            |    2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index deb0338..008fdf7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Properly use snapshot layer for origin which is also thin volume.
   Avoid generating metadata backup when calling update_pool_lv().
   Send thin messages also for active thin pool and inactive thin volume.
   Add activation/auto_set_activation_skip to control activation skip flagging.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 724742d..986e696 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1681,7 +1681,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		return_0;
 
 	if (origin_only && lv_is_thin_volume(lv)) {
-		if (!_add_dev_to_dtree(dm, dtree, lv, NULL))
+		if (!_add_dev_to_dtree(dm, dtree, lv, lv_layer(lv)))
 			return_0;
 #if 0
 		/* ? Use origin_only to avoid 'deep' thin pool suspend ? */
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 1867ef9..9bc9e4d 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -298,7 +298,7 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 		case DM_THIN_MESSAGE_CREATE_THIN:
 			origin = first_seg(lmsg->u.lv)->origin;
 			/* Check if the origin is suspended */
-			if (origin && lv_info(cmd, origin, 0, &info, 0, 0) &&
+			if (origin && lv_info(cmd, origin, 1, &info, 0, 0) &&
 			    info.exists && !info.suspended) {
 				/* Origin is not suspended, but the transaction may have been
 				 * already transfered, so test for transaction_id and


