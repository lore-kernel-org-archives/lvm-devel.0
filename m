From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:39:57 +0000 (UTC)
Subject: master - cache: better error message
Message-ID: <20141024143957.40BBF60641@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e901a87a69bf8573e441790ebca2ca9376aaf8a6
Commit:        e901a87a69bf8573e441790ebca2ca9376aaf8a6
Parent:        6e57dbfcaa3fdc2aabe7c05f95268a35d6b198ca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 20 14:53:48 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

cache: better error message

---
 lib/metadata/cache_manip.c |    4 ++--
 tools/lvcreate.c           |   21 ++++++++++-----------
 2 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 837c651..6aad50d 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -148,8 +148,8 @@ int validate_lv_cache_create(const struct logical_volume *pool_lv,
 	    lv_is_cow(origin_lv) || lv_is_merging_cow(origin_lv) ||
 	    lv_is_external_origin(origin_lv) ||
 	    lv_is_virtual(origin_lv)) {
-		log_error("Cache is not supported with origin LV %s type.",
-			  display_lvname(origin_lv));
+		log_error("Cache is not supported with %s segment type of the original logical volume %s.",
+			  first_seg(origin_lv)->segtype->name, display_lvname(origin_lv));
 		return 0;
 	}
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 5a4bced..d849f93 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -61,21 +61,21 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 
 	if (seg_is_cache(lp)) {
 		/*
-		 * We allowed somewhat hard to 'parse' syntax
-		 * (usage of lvcreate to convert LV to a cached LV).
-		 * So let's try to do our best to avoid wrong steps.
+		 * 2 ways of cache usage for lvcreate -H -l1 vg/lv
+		 *
+		 * vg/lv is existing cache pool:
+		 *       cached LV is created using this cache pool
+		 * vg/lv is not cache pool so it is cache origin
+		 *       origin is cached with created cache pool
 		 *
 		 * We are looking for the vgname or cache pool or cache origin LV.
 		 *
-		 * We store the lv name in 'lp->pool', but
-		 * it must be accessed later (when we can look-up the
-		 * LV in the VG) whether it is truly the cache pool
-		 * or whether it is the origin for cached LV.
+		 * lv name is stored in origin_name and pool_name and
+		 * later with opened VG it's decided what should happen.
 		 */
 		if (!argc) {
 			if (!lp->pool_name) {
-				/* Don't advertise we could handle cache origin */
-				log_error("Please specify a logical volume to act as the cache pool.");
+				log_error("Please specify a logical volume to act as the cache pool or origin.");
 				return 0;
 			}
 		} else {
@@ -85,7 +85,7 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 				if (!_set_vg_name(lp, vg_name))
 					return_0;
 			} else {
-				/* Lets pretend it's cache origin for now */
+				/* Assume it's cache origin for now */
 				lp->origin_name = vg_name;
 				if (!validate_lvname_param(cmd, &lp->vg_name, &lp->origin_name))
 					return_0;
@@ -94,7 +94,6 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 					if (strcmp(lp->pool_name, lp->origin_name)) {
 						log_error("Unsupported syntax, cannot use cache origin %s and --cachepool %s.",
 							  lp->origin_name, lp->pool_name);
-						/* Stop here, only older form remains supported */
 						return 0;
 					}
 					lp->origin_name = NULL;


