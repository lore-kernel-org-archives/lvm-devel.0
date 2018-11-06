From: David Teigland <teigland@sourceware.org>
Date: Tue, 6 Nov 2018 16:43:08 -0500
Subject: master - cache: improve warning message about cached thin data
Message-ID: <201811062143.wA6Lh8jk004772@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3e547fa9528e119205fcf182aecccd49c3695547
Commit:        3e547fa9528e119205fcf182aecccd49c3695547
Parent:        5ee1727f808e76f59637d78f2691aadc25d49b17
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 5 16:08:31 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 6 11:36:28 2018 -0600

cache: improve warning message about cached thin data

---
 lib/metadata/cache_manip.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index b4d269d..6b87873 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -171,9 +171,10 @@ void cache_check_for_warns(const struct lv_segment *seg)
 		log_warn("WARNING: Data redundancy could be lost with writeback "
 			 "caching of raid logical volume!");
 
-	if (lv_is_thin_pool_data(seg->lv))
-		log_warn("WARNING: Cached thin pool's data cannot be currently "
-			 "resized and require manual uncache before resize!");
+	if (lv_is_thin_pool_data(seg->lv)) {
+		log_warn("WARNING: thin pool data will not be automatically extended when cached.");
+		log_warn("WARNING: manual splitcache is required before extending thin pool data.");
+	}
 }
 
 /*


