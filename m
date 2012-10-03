From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  3 Oct 2012 13:14:47 +0000 (UTC)
Subject: master - thin: origin only suspend
Message-ID: <20121003131447.E5B9E30C1@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cf8e1a00937a7ef5eebf363898e237fd4a8dc392
Commit:        cf8e1a00937a7ef5eebf363898e237fd4a8dc392
Parent:        1946a453297535829d3d698dfa51733d8a223400
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 5 11:28:01 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 3 15:05:55 2012 +0200

thin: origin only suspend

Skip tree creating when used with origin_only flag.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bc0c778..8050db8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Skip building dm tree for thin pool when called with origin_only flag.
   Add internal lv_rename_update() to rename LV without updating mda.
   Ensure descriptors 0,1,2 are always available.
   Use /proc/self/fd for closing openned descriptors.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index c8a1e35..31c1c27 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1369,7 +1369,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		seg = first_seg(lv);
 	}
 
-	if (lv_is_thin_pool(lv)) {
+	if (!origin_only && lv_is_thin_pool(lv)) {
 		if (!_add_lv_to_dtree(dm, dtree, seg->metadata_lv, 0))
 			return_0;
 		/* FIXME code from _create_partial_dtree() should be moved here */


