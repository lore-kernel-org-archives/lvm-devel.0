From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 14 Oct 2019 09:21:59 -0400
Subject: master - cache: recognize cachevol with lv_cache_remove
Message-ID: <201910141321.x9EDLxN2018740@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bc35ccd1740a588293b5a2eb5bbe936f837f6c21
Commit:        bc35ccd1740a588293b5a2eb5bbe936f837f6c21
Parent:        36944e1009e932902269d3eab547e0b19da13468
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 12 23:40:15 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 14 15:14:25 2019 +0200

cache: recognize cachevol with lv_cache_remove

---
 lib/metadata/cache_manip.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index e4cd345..e444e37 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -758,6 +758,7 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	struct lv_segment *cache_seg = first_seg(cache_lv);
 	struct logical_volume *corigin_lv;
 	struct logical_volume *cache_pool_lv;
+	cache_mode_t cache_mode;
 	int is_clear;
 
 	if (!lv_is_cache(cache_lv)) {
@@ -783,7 +784,9 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 		if (!deactivate_lv_with_sub_lv(cache_lv))
 			return_0;
 
-		switch (first_seg(cache_seg->pool_lv)->cache_mode) {
+		cache_mode = (lv_is_cache_pool(cache_seg->pool_lv)) ?
+			first_seg(cache_seg->pool_lv)->cache_mode : cache_seg->cache_mode;
+		switch (cache_mode) {
 		case CACHE_MODE_WRITETHROUGH:
 		case CACHE_MODE_PASSTHROUGH:
 			/* For inactive pass/writethrough just drop cache layer */


