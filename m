From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jun 2017 12:49:15 -0400
Subject: master - cache: restore origin only reload
Message-ID: <201706231649.v5NGnFc0019874@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1bdcd156fdbd007bc6c31ec4077d8215baf5a0af
Commit:        1bdcd156fdbd007bc6c31ec4077d8215baf5a0af
Parent:        63ecbcd1b701b15e43e141f6ab2001dff7622e88
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 23 17:05:24 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 23 18:44:01 2017 +0200

cache: restore origin only reload

Basically reverting commit 58a9f88b8c021a5e056b883053f257f1a898adf7.
We can use origin_only  in case we are snapshot's origin,
as we do support this stack.

So when we are 'uncaching'  origin+snaps - we do need to reload only
origin and we do not need to play with snaps.
---
 WHATS_NEW                  |    1 -
 lib/metadata/cache_manip.c |    4 ++--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f1f354d..19f7a31 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -2,7 +2,6 @@ Version 2.02.172 -
 ===============================
   Do not lvdisplay --maps unset settings of cache pool.
   Fix lvdisplay --maps for cache pool without policy settings.
-  Avoid using origin_only manipulation with cached device.
   Support aborting of flushing cache LV.
   Reenable conversion of data and metadata thin-pool volumes to raid.
   Improve raid status reporting with lvs.
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 057d043..5e0e5c4 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -440,7 +440,7 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 			if (cache_seg->cleaner_policy) {
 				cache_seg->cleaner_policy = 0;
 				/* Restore normal table */
-				if (!lv_update_and_reload(cache_lv))
+				if (!lv_update_and_reload_origin(cache_lv))
 					stack;
 			}
 			return 0;
@@ -485,7 +485,7 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 		/* Switch to cleaner policy to flush the cache */
 		cache_seg->cleaner_policy = 1;
 		/* Reload cache volume with "cleaner" policy */
-		if (!lv_update_and_reload(cache_lv))
+		if (!lv_update_and_reload_origin(cache_lv))
 			return_0;
 
 		if (!sync_local_dev_names(cache_lv->vg->cmd)) {


