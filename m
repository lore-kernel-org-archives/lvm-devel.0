From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 14 Oct 2019 09:22:10 -0400
Subject: master - cache: correct condition
Message-ID: <201910141322.x9EDMAQE018752@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6ee83f699b5f3e5ffc09a7264de44425e8634970
Commit:        6ee83f699b5f3e5ffc09a7264de44425e8634970
Parent:        bc35ccd1740a588293b5a2eb5bbe936f837f6c21
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 12 23:40:58 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 14 15:14:25 2019 +0200

cache: correct condition

---
 lib/metadata/cache_manip.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index e444e37..1a5482b 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -1434,8 +1434,7 @@ int wipe_cache_pool(struct logical_volume *cache_pool_lv)
 	int r;
 
 	/* Only unused cache-pool could be activated and wiped */
-	if ((!lv_is_cache_pool(cache_pool_lv) && !lv_is_cache_vol(cache_pool_lv)) ||
-	    !dm_list_empty(&cache_pool_lv->segs_using_this_lv)) {
+	if (lv_is_used_cache_pool(cache_pool_lv) || lv_is_cache_vol(cache_pool_lv)) {
 		log_error(INTERNAL_ERROR "Failed to wipe cache pool for volume %s.",
 			  display_lvname(cache_pool_lv));
 		return 0;


