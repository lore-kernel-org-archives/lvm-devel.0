From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:32:59 +0000 (UTC)
Subject: master - lvconvert: reuse cache validation
Message-ID: <20141006133259.CD98E609E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a0cfc5eee2763b7e68c028b517db1825c1f3cce7
Commit:        a0cfc5eee2763b7e68c028b517db1825c1f3cce7
Parent:        5a366918432bf4f825d2ddbb00780943c0761a0d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 3 18:52:08 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:18:05 2014 +0200

lvconvert: reuse cache validation

Validation is now already in
validate_lv_cache_create() so reuse it.

Also properly rename var origin -> origin_lv.
---
 tools/lvconvert.c |   41 +++++------------------------------------
 1 files changed, 5 insertions(+), 36 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 03118cb..11a10f7 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3168,50 +3168,19 @@ revert_new_lv:
  * Convert origin into a cache LV by attaching a cache pool.
  */
 static int _lvconvert_cache(struct cmd_context *cmd,
-			    struct logical_volume *origin,
+			    struct logical_volume *origin_lv,
 			    struct lvconvert_params *lp)
 {
 	struct logical_volume *pool_lv = lp->pool_data_lv;
 	struct logical_volume *cache_lv;
 
-	if (origin == pool_lv) {
-		log_error("Can't use same LV %s for cache pool and cache volume.",
-			  display_lvname(pool_lv));
-		return 0;
-	}
-
-	if (lv_is_pool(origin) || lv_is_cache_type(origin)) {
-		log_error("Can't cache pool or cache type volume %s.",
-			  display_lvname(origin));
-		return 0;
-	}
-
-	/* We support conversion of _tdata */
-	if (!lv_is_visible(origin) && !lv_is_thin_pool_data(origin)) {
-		log_error("Can't convert internal LV %s.", display_lvname(origin));
-		return 0;
-	}
-
-	/*
-	 * Only linear, striped or raid supported.
-	 * FIXME Tidy up all these type restrictions.
-	 */
-	if (lv_is_cache_origin(origin) ||
-	    lv_is_mirror_type(origin) ||
-	    lv_is_thin_volume(origin) || lv_is_thin_pool_metadata(origin) ||
-	    lv_is_origin(origin) || lv_is_merging_origin(origin) ||
-	    lv_is_cow(origin) || lv_is_merging_cow(origin) ||
-	    lv_is_external_origin(origin) ||
-	    lv_is_virtual(origin)) {
-		log_error("Cache is not supported with origin LV %s type.",
-			  display_lvname(origin));
-		return 0;
-	}
+	if (!validate_lv_cache_create(pool_lv, origin_lv))
+		return_0;
 
-	if (!archive(origin->vg))
+	if (!archive(origin_lv->vg))
 		return_0;
 
-	if (!(cache_lv = lv_cache_create(pool_lv, origin)))
+	if (!(cache_lv = lv_cache_create(pool_lv, origin_lv)))
 		return_0;
 
 	if (!lv_update_and_reload(cache_lv))


