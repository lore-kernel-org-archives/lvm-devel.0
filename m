From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue,  4 Feb 2014 14:21:42 +0000 (UTC)
Subject: master - misc: rename variables [min|max]_chunk to [min|max]_chunk_size
Message-ID: <20140204142142.23E6B603AC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=afe2ba657bfa20fa755e71a039ee9cb9027adb1b
Commit:        afe2ba657bfa20fa755e71a039ee9cb9027adb1b
Parent:        b94a3ee9f644e6be6f2f70dacefef0f606e2eaa5
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Feb 4 08:20:10 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Feb 4 08:20:10 2014 -0600

misc: rename variables [min|max]_chunk to [min|max]_chunk_size

better variable names.
---
 lib/metadata/lv_manip.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e95b7e5..6139daa 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5638,7 +5638,7 @@ static int _recalculate_pool_chunk_size_with_dev_hints(struct lvcreate_params *l
 	unsigned long previous_hint = 0, hint = 0;
 	uint32_t chunk_size = lp->chunk_size;
 	uint32_t default_chunk_size;
-	uint32_t min_chunk, max_chunk;
+	uint32_t min_chunk_size, max_chunk_size;
 
 	if (lp->passed_args & PASS_ARG_CHUNK_SIZE)
 		goto out;
@@ -5647,8 +5647,8 @@ static int _recalculate_pool_chunk_size_with_dev_hints(struct lvcreate_params *l
 		if (find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG, NULL))
 			goto out;
 
-		min_chunk = DM_THIN_MIN_DATA_BLOCK_SIZE;
-		max_chunk = DM_THIN_MAX_DATA_BLOCK_SIZE;
+		min_chunk_size = DM_THIN_MIN_DATA_BLOCK_SIZE;
+		max_chunk_size = DM_THIN_MAX_DATA_BLOCK_SIZE;
 		if (lp->thin_chunk_size_calc_policy == THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE)
 			default_chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE*2;
 		else
@@ -5656,8 +5656,8 @@ static int _recalculate_pool_chunk_size_with_dev_hints(struct lvcreate_params *l
 	} else if (seg_is_cache_pool(lp)) {
 		if (find_config_tree_int(cmd, allocation_cache_pool_chunk_size_CFG, NULL))
 			goto out;
-		min_chunk = DM_CACHE_MIN_DATA_BLOCK_SIZE;
-		max_chunk = DM_CACHE_MAX_DATA_BLOCK_SIZE;
+		min_chunk_size = DM_CACHE_MIN_DATA_BLOCK_SIZE;
+		max_chunk_size = DM_CACHE_MAX_DATA_BLOCK_SIZE;
 		default_chunk_size = DEFAULT_CACHE_POOL_CHUNK_SIZE*2;
 	} else {
 		log_error(INTERNAL_ERROR "%s is not a thin pool or cache pool",
@@ -5687,10 +5687,11 @@ static int _recalculate_pool_chunk_size_with_dev_hints(struct lvcreate_params *l
 		goto out;
 	}
 
-	if ((hint < min_chunk) || (hint > max_chunk)) {
+	if ((hint < min_chunk_size) || (hint > max_chunk_size)) {
 		log_debug_alloc("Calculated chunk size value of %ld sectors for"
 				" thin pool %s is out of allowed range (%d-%d).",
-				hint, pool_lv->name, min_chunk, max_chunk);
+				hint, pool_lv->name,
+				min_chunk_size, max_chunk_size);
 	} else
 		chunk_size = (hint >= default_chunk_size) ?
 			hint : default_chunk_size;


