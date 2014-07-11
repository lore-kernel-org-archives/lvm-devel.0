From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:34:30 +0000 (UTC)
Subject: master - cache: warn about metadata size limits
Message-ID: <20140711113430.986BD6105E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f7d661406196568abce68abb66a45b27177b4379
Commit:        f7d661406196568abce68abb66a45b27177b4379
Parent:        04b8e55f2a2a96d2ffbd124fe3c0fc7c452cfb26
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 11 12:12:51 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 13:31:19 2014 +0200

cache: warn about metadata size limits

Cache pools are similar as with thin pools.
Add (needs %s) - since cache has currently
a bit strange need for extra few kb over
our default 4M extent size so make it more obvious.
---
 lib/metadata/cache_manip.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 6a0f0f6..e220dd9 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -60,15 +60,18 @@ int update_cache_pool_params(struct volume_group *vg, unsigned attr,
 	if (!*pool_metadata_size)
 		*pool_metadata_size = min_meta_size;
 
-	if (*pool_metadata_size < min_meta_size) {
-		*pool_metadata_size = min_meta_size;
-		log_print("Increasing metadata device size to %"
-			  PRIu64 " sectors", *pool_metadata_size);
-	}
 	if (*pool_metadata_size > (2 * DEFAULT_CACHE_POOL_MAX_METADATA_SIZE)) {
 		*pool_metadata_size = 2 * DEFAULT_CACHE_POOL_MAX_METADATA_SIZE;
-		log_print("Reducing metadata device size to %" PRIu64 " sectors",
-			  *pool_metadata_size);
+		if (passed_args & PASS_ARG_POOL_METADATA_SIZE)
+			log_warn("WARNING: Maximum supported pool metadata size is %s.",
+				 display_size(vg->cmd, *pool_metadata_size));
+	} else if (*pool_metadata_size < min_meta_size) {
+		if (passed_args & PASS_ARG_POOL_METADATA_SIZE)
+			log_warn("WARNING: Minimum supported pool metadata size is %s "
+				 "(needs extra %s).",
+				 display_size(vg->cmd, min_meta_size),
+				 display_size(vg->cmd, min_meta_size - *pool_metadata_size));
+		*pool_metadata_size = min_meta_size;
 	}
 
 	return 1;


