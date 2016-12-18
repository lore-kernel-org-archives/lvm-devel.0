From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 18 Dec 2016 18:52:17 +0000 (UTC)
Subject: master - cache: improve activation with -real
Message-ID: <20161218185217.063F160E2E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=69434c2eca5bb7667d73916a28d03b8c687aea32
Commit:        69434c2eca5bb7667d73916a28d03b8c687aea32
Parent:        954c59779d35436a6d2f28482ec1ed6dc128844c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 18 15:05:31 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 18 19:30:50 2016 +0100

cache: improve activation with -real

When cache volume may be converted from normal to -real layer LV
we need to improve logic for call cache_check.

With this patch, we register call for cache_check only when metadata LV
is not yet present in active table slot (should match initial table
load).
This avoids unwanted checking when cache would become layer device
online.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6ab2b19..74638fd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Support cache volume activation with -real layer.
   Improve search of lock-holder for external origin and thin-pool.
   Support status checking of cache volume used in layer.
   Avoid shifting by one number of blocks when clearing dirty cache volume.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 8245454..520a0a1 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2901,6 +2901,10 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		return_0;
 
 	if (lv_is_cache(lv) &&
+	    /* Register callback only for layer activation or non-layered cache LV */
+	    (layer || !lv_layer(lv)) &&
+	    /* Register callback when metadata LV is NOT already active */
+	    !_cached_dm_info(dm->mem, dtree, first_seg(first_seg(lv)->pool_lv)->metadata_lv, NULL) &&
 	    !_pool_register_callback(dm, dnode, lv))
 		return_0;
 


