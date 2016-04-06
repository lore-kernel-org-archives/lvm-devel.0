From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  6 Apr 2016 09:55:32 +0000 (UTC)
Subject: master - mirror: fix flushing for mirror target
Message-ID: <20160406095532.370CE6112E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d4c03cf7b21279ad28b8b9944d0281a55692efcc
Commit:        d4c03cf7b21279ad28b8b9944d0281a55692efcc
Parent:        76fc41fb9d06519d7410f0054c279ea3a8dccc37
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 5 21:34:42 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 6 11:31:02 2016 +0200

mirror: fix flushing for mirror target

Fix regression caused by commit ba41ee1dc94264f7ac8e61f8b1d56b10225b0d2f.
The idea was to use no_flush for changed device only for thin volumes
and thin pools but also to merge this with change made in commit
844b00958492224c448b30f89ae5532bb6591fd2.

However the resulting condition has caused misbehavior for the mirror
suspend - as that has been before the ONLY allowed target type
that could have been suspended with noflush.

Result was badly working repair for --type mirror that has been
passing 'flush' to the repaired mirror target whenever preload
wrongly set flush_required.

The origin code has required the flush_required to be set whenever
deivce size is changed.

Now it first detects if device size got smaller
'dm_tree_node_size_changed(root) < 0' - this requires flush.
Otherwise it checks device is not thin volume nor thin pool and its
size has changed (got bigger) and requires flush.

This mean upsize of thin-pool or thin volume will not require flush.
---
 lib/activate/dev_manager.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 3563d5a..22331c3 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -3044,12 +3044,11 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 
 		if ((dm_tree_node_size_changed(root) < 0))
 			dm->flush_required = 1;
-
 		/* Currently keep the code require flush for any
-		 * non 'thin pool/volume, mirror' or with any size change */
-		if (!lv_is_thin_volume(lv) &&
-		    !lv_is_thin_pool(lv) &&
-		    (!lv_is_mirror(lv) || dm_tree_node_size_changed(root)))
+		 * non 'thin pool/volume' and  size increase */
+		else if (!lv_is_thin_volume(lv) &&
+			 !lv_is_thin_pool(lv) &&
+			 dm_tree_node_size_changed(root))
 			dm->flush_required = 1;
 
 		if (action == ACTIVATE) {


