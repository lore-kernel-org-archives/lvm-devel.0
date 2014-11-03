From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:23:34 +0000 (UTC)
Subject: master - cache: convert thin-pool
Message-ID: <20141103132334.56FF1602D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=969ab6bbf02c11bf989ccc3105910a205448507b
Commit:        969ab6bbf02c11bf989ccc3105910a205448507b
Parent:        127cf4895a8531e1ffcae06ce472c9ecf3b94f2c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 2 17:03:14 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:33 2014 +0100

cache: convert thin-pool

Support caching of thin-pool.

lvresize needs to be resolved - so far, user
has to manually drop cache-pool before resizing.
---
 lib/metadata/cache_manip.c |    5 ++++-
 tools/lvconvert.c          |   13 +++++--------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 44d1bd8..e59a32f 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -171,9 +171,12 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool_lv,
 	struct lv_segment *seg;
 
 	if (!validate_lv_cache_create_pool(pool_lv) ||
-	    !validate_lv_cache_create_origin(origin_lv))
+	    !validate_lv_cache_create_origin(cache_lv))
 		return_NULL;
 
+	if (lv_is_thin_pool(cache_lv))
+		cache_lv = seg_lv(first_seg(cache_lv), 0); /* cache _tdata */
+
 	if (!(segtype = get_segtype_from_string(cmd, "cache")))
 		return_NULL;
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index f37a7a8..a512709 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3188,8 +3188,7 @@ static int _lvconvert_cache(struct cmd_context *cmd,
 	struct logical_volume *pool_lv = lp->pool_data_lv;
 	struct logical_volume *cache_lv;
 
-	if (!validate_lv_cache_create_pool(pool_lv) ||
-	    !validate_lv_cache_create_origin(origin_lv))
+	if (!validate_lv_cache_create_pool(pool_lv))
 		return_0;
 
 	if (!archive(origin_lv->vg))
@@ -3254,12 +3253,10 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return ECMD_PROCESSED;
 	}
 
-	if (lp->cache) {
-		if (lv_is_thin_pool(lv))
-			lv = seg_lv(first_seg(lv), 0); /* cache _tdata */
-		if (!validate_lv_cache_create_origin(lv))
-			return_ECMD_FAILED;
-	}
+	/* Validate origin prior we start conversion of pool */
+	if (lp->cache &&
+	    !validate_lv_cache_create_origin(lv))
+		return_ECMD_FAILED;
 
 	if (lp->thin) {
 		if (lv_is_cache_type(lv) ||


