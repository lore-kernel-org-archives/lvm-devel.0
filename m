From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 17 Sep 2014 22:50:39 +0000 (UTC)
Subject: master - cleanup: detect unsupported options earlier
Message-ID: <20140917225039.3324F60E7C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=31548e4e7c4e3ae3b2f04b7b32491617ec7181d0
Commit:        31548e4e7c4e3ae3b2f04b7b32491617ec7181d0
Parent:        8cbb04563ac240346693ec4da1587df20b049df7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 17 23:31:51 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 18 00:42:53 2014 +0200

cleanup: detect unsupported options earlier

Avoid unnecessary converions of pool.
---
 tools/lvconvert.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4291a9e..b6ef1bf 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2674,6 +2674,18 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (arg_is_set(cmd, cachepool_ARG) && lv_is_thin_pool(pool_lv)) {
+		log_error("--cachepool requires a cache pool.  %s is a thin pool.",
+			  display_lvname(pool_lv));
+		return 0;
+	}
+
+	if (arg_is_set(cmd, thinpool_ARG) && lv_is_cache_pool(pool_lv)) {
+		log_error("--thinpool requires a thin pool.  %s is a cache pool.",
+			  display_lvname(pool_lv));
+		return 0;
+	}
+
 	if (lp->pool_metadata_lv_name) {
 		if (!(lp->pool_metadata_lv = find_lv(vg, lp->pool_metadata_lv_name))) {
 			log_error("Unknown pool metadata LV %s.", lp->pool_metadata_lv_name);
@@ -2763,18 +2775,6 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 	if (lv_is_pool(pool_lv)) {
 		lp->pool_data_lv = pool_lv;
 
-		if (arg_is_set(cmd, cachepool_ARG) && lv_is_thin_pool(pool_lv)) {
-			log_error("--cachepool requires a cache pool.  %s is a thin pool.",
-				  display_lvname(pool_lv));
-			return 0;
-		}
-
-		if (arg_is_set(cmd, thinpool_ARG) && lv_is_cache_pool(pool_lv)) {
-			log_error("--thinpool requires a thin pool.  %s is a cache pool.",
-				  display_lvname(pool_lv));
-			return 0;
-		}
-
 		if (!metadata_lv) {
 			if (arg_from_list_is_set(cmd, "is invalid with existing pool",
 						 cachemode_ARG,chunksize_ARG, discards_ARG,


