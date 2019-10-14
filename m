From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 14 Oct 2019 09:22:39 -0400
Subject: master - cachevol: use lv_cache_remove
Message-ID: <201910141322.x9EDMdIR018843@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=201ffbd04a76789eb5b1ef3aced6a89cb064d4c6
Commit:        201ffbd04a76789eb5b1ef3aced6a89cb064d4c6
Parent:        2825ad9dd20a4f34693666d1efaa4ceb1c8e2b8f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 14 10:25:31 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 14 15:20:25 2019 +0200

cachevol: use lv_cache_remove

Use same routine for dropping cache.
---
 lib/metadata/lv_manip.c |    2 +-
 tools/lvconvert.c       |    5 ++---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ebdb0cb..e6524f3 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6278,7 +6278,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (lv_is_cache(lv) && lv_is_cache_vol(first_seg(lv)->pool_lv)) {
 		struct logical_volume *cachevol_lv = first_seg(lv)->pool_lv;
 
-		if (!lv_detach_cache_vol(lv, 0)) {
+		if (!lv_cache_remove(lv)) {
 			log_error("Failed to detach cache from %s", display_lvname(lv));
 			return 0;
 		}
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index f875ac7..3fa1b04 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1844,7 +1844,6 @@ static int _lvconvert_split_and_keep_cachevol(struct cmd_context *cmd,
 	char *c;
 	struct lv_segment *cache_seg = first_seg(lv);
 	int cache_mode = cache_seg->cache_mode;
-	int noflush = 0;
 
 	if (!archive(lv->vg))
 		return_0;
@@ -1878,8 +1877,8 @@ static int _lvconvert_split_and_keep_cachevol(struct cmd_context *cmd,
 		/* Switch internally to WRITETHROUGH which does not require flushing */
 		cache_seg->cache_mode = CACHE_MODE_WRITETHROUGH;
 	}
-				
-	if (!lv_detach_cache_vol(lv, noflush))
+
+	if (!lv_cache_remove(lv))
 		return_0;
 
 	/* Cut off suffix _cvol */


