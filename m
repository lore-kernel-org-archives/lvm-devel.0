From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 May 2016 22:01:31 +0000 (UTC)
Subject: master - lvcreate: improve --chunksize support for cached volume.
Message-ID: <20160505220131.6672460C97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d1ecbfa52d3f35c8702ca50f30577daa8c324eb9
Commit:        d1ecbfa52d3f35c8702ca50f30577daa8c324eb9
Parent:        d3b15674df99a2dd17b5205b850606d80a155df7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 5 21:34:21 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 5 23:50:10 2016 +0200

lvcreate: improve --chunksize support for cached volume.

Support parsing --chunksize option also when converting.
Now user can use cache pool created with i.e. 32K chunksize,
while in caching user can select 512K blocks.
Tool is supposed to validate cache metadata size is big enough
to support such chunk size. Otherwise error is shown.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   43 ++++++++++++++++++++-----------------------
 man/lvcreate.8.in       |    2 ++
 3 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d0943f5..eb442df 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.153 - 
 ==================================
+  Support --chunksize option also when caching LV when possible.
   Add function to check for target presence and version via 1 ioctl.
 
 Version 2.02.152 - 30th April 2016
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2969d2a..45dd1f5 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7166,9 +7166,17 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			return NULL;
 		}
 
+		if (seg_is_cache(lp)) {
+			/* validate metadata size */
+			if (!validate_lv_cache_chunk_size(pool_lv, lp->chunk_size))
+				return_0;
+
+			first_seg(pool_lv)->chunk_size = lp->chunk_size;
+		}
+
 		/* Validate volume size to to aling on chunk for small extents */
 		/* Cache chunk size is always set */
-		size = seg_is_cache(lp) ? lp->chunk_size : first_seg(pool_lv)->chunk_size;
+		size = first_seg(pool_lv)->chunk_size;
 		if (size > vg->extent_size) {
 			/* Align extents on chunk boundary size */
 			size = ((uint64_t)vg->extent_size * lp->extents + size - 1) /
@@ -7427,27 +7435,15 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	/* Unlock memory if possible */
 	memlock_unlock(vg->cmd);
 
-	if (lv_is_cache_pool(lv) || lv_is_cache(lv)) {
-		if (!cache_set_mode(first_seg(lv), lp->cache_mode)) {
-			stack;
-			goto revert_new_lv;
-		}
-
-		if (!cache_set_policy(first_seg(lv), lp->policy_name, lp->policy_settings)) {
+	if (lv_is_cache_pool(lv)) {
+		if (!cache_set_params(first_seg(lv),
+				      lp->cache_mode,
+				      lp->policy_name,
+				      lp->policy_settings,
+				      lp->chunk_size)) {
 			stack;
 			goto revert_new_lv;
 		}
-
-		pool_lv = pool_lv ? : lv;
-		if (lp->chunk_size) {
-			first_seg(pool_lv)->chunk_size = lp->chunk_size;
-			/* TODO: some calc_policy solution for cache ? */
-			if (!recalculate_pool_chunk_size_with_dev_hints(pool_lv, lp->passed_args,
-									THIN_CHUNK_SIZE_CALC_METHOD_GENERIC)) {
-				stack;
-				goto revert_new_lv;
-			}
-		}
 	} else if (lv_is_raid(lv)) {
 		first_seg(lv)->min_recovery_rate = lp->min_recovery_rate;
 		first_seg(lv)->max_recovery_rate = lp->max_recovery_rate;
@@ -7649,10 +7645,11 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 		lv = tmp_lv;
 
-		if (!cache_set_mode(first_seg(lv), lp->cache_mode))
-			return_NULL; /* revert? */
-
-		if (!cache_set_policy(first_seg(lv), lp->policy_name, lp->policy_settings))
+		if (!cache_set_params(first_seg(lv),
+				      lp->cache_mode,
+				      lp->policy_name,
+				      lp->policy_settings,
+				      (lp->passed_args & PASS_ARG_CHUNK_SIZE) ? lp->chunk_size : 0))
 			return_NULL; /* revert? */
 
 		cache_check_for_warns(first_seg(lv));
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index fd8b3a7..e008b58 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -260,6 +260,8 @@ and the default value is 4KiB.
 .br
 For cache pools the value must a multiple of 32KiB
 between 32KiB and 1GiB. The default is 64KiB.
+When the size is specified with volume caching, it may not be smaller
+then cache pool creation chunk size was.
 .br
 For thin pools the value must be a multiple of 64KiB
 between 64KiB and 1GiB.


