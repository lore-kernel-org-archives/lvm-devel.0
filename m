From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 17 Oct 2019 07:04:57 -0400
Subject: master - cache: drop validation check
Message-ID: <201910171104.x9HB4vut023590@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f63e20ebcc0488a574fcfb65ea015fb2f988212a
Commit:        f63e20ebcc0488a574fcfb65ea015fb2f988212a
Parent:        af8cfa90d9c4cdcb14c1cf69715405e22ac68432
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 16 18:47:20 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 17 13:03:49 2019 +0200

cache: drop validation check

Since now we can cache either with cache-pool LV or
any other LV (being used as cachevol LV) drop the
validation condition.
---
 lib/metadata/cache_manip.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index febd82a..5275d24 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -341,12 +341,6 @@ int validate_lv_cache_create_pool(const struct logical_volume *pool_lv)
 {
 	struct lv_segment *seg;
 
-	if (!lv_is_cache_pool(pool_lv) && !lv_is_cache_vol(pool_lv)) {
-		log_error("Logical volume %s is not a cache pool.",
-			  display_lvname(pool_lv));
-		return 0;
-	}
-
 	if (lv_is_locked(pool_lv)) {
 		log_error("Cannot use locked cache pool %s.",
 			  display_lvname(pool_lv));


