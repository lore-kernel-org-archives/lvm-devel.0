From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 24 Nov 2015 10:33:17 +0000 (UTC)
Subject: master - thin: work with active thin-pool
Message-ID: <20151124103317.3BED461437@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=94c9453659e9e2ec0389b8ea3e9ed18718d61d6a
Commit:        94c9453659e9e2ec0389b8ea3e9ed18718d61d6a
Parent:        15be97d76b0ca24d62c67a947ae595a2124260be
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 23 19:53:43 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 23 23:41:36 2015 +0100

thin: work with active thin-pool

When 'lvextend -L+XX vg/thinpool'  do not leave inactive table
loaded for 'wrapping' LV on top of resized thin-pool
(ATM we use linear  LV for this with same size as thin-pool).
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0b24981..a4eeebf 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.136 - 
 =====================================
+  Fix inactive table loaded for wrapping thin-pool when resizing it.
   Extend the list of ignored libraries when locking memory.
 
 Version 2.02.135 - 23rd November 2015
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index fd4d842..da24cdd 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2311,7 +2311,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			return_0;
 		if (seg->pool_lv &&
 		    (lv_is_cache_pool(seg->pool_lv) || !dm->skip_external_lv) &&
-		    !_add_lv_to_dtree(dm, dtree, seg->pool_lv, 1)) /* stack */
+		    !_add_lv_to_dtree(dm, dtree, seg->pool_lv, origin_only))
 			return_0;
 
 		for (s = 0; s < seg->area_count; s++) {


