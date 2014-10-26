From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 26 Oct 2014 17:37:54 +0000 (UTC)
Subject: master - cache: support more args
Message-ID: <20141026173754.041E360282@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c9fbbf48baf9866dc57b336f9ca2b54346fb9827
Commit:        c9fbbf48baf9866dc57b336f9ca2b54346fb9827
Parent:        ff2e8b0de6aafcf304b30e5f90501f3638ead22f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 26 16:17:14 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 26 18:37:13 2014 +0100

cache: support more args

Unlike with thin-pool - with cache we support all args also
directly when create cache volume.

So the result of 'separate' cache-pool creation and setting its
options should give same result as specifying those args
during cache creation.

Cache-pool values are used as defaults if the params are
not specified with cache creation.
---
 lib/metadata/lv_manip.c |   11 ++++++-----
 tools/lvcreate.c        |   16 +++++++++++-----
 2 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1e9d1c6..1ab47c6 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6629,7 +6629,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		return_NULL;
 	}
 
-	if (seg_is_pool(lp) &&
+	if ((seg_is_pool(lp) || seg_is_cache(lp)) &&
 	    ((uint64_t)lp->extents * vg->extent_size < lp->chunk_size)) {
 		log_error("Unable to create %s smaller than 1 chunk.",
 			  lp->segtype->name);
@@ -6876,11 +6876,12 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	/* Unlock memory if possible */
 	memlock_unlock(vg->cmd);
 
-	if (seg_is_cache_pool(lp)) {
-		first_seg(lv)->chunk_size = lp->chunk_size;
-		first_seg(lv)->feature_flags = lp->feature_flags;
+	if (seg_is_cache_pool(lp) || seg_is_cache(lp)) {
+		pool_lv = pool_lv ? : lv;
+		first_seg(pool_lv)->chunk_size = lp->chunk_size;
+		first_seg(pool_lv)->feature_flags = lp->feature_flags;
 		/* TODO: some calc_policy solution for cache ? */
-		if (!recalculate_pool_chunk_size_with_dev_hints(lv, lp->passed_args,
+		if (!recalculate_pool_chunk_size_with_dev_hints(pool_lv, lp->passed_args,
 								THIN_CHUNK_SIZE_CALC_METHOD_GENERIC)) {
 			stack;
 			goto revert_new_lv;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 199636c..78b6898 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1035,6 +1035,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 static int _determine_cache_argument(struct volume_group *vg,
 				     struct lvcreate_params *lp)
 {
+	struct cmd_context *cmd = vg->cmd;
 	struct logical_volume *lv;
 
 	if (!lp->pool_name) {
@@ -1045,19 +1046,24 @@ static int _determine_cache_argument(struct volume_group *vg,
 		/* Pool exists, create cache volume */
 		lp->create_pool = 0;
 		lp->origin_name = NULL;
+		/* If cache args not given, use those from cache pool */
+		if (!arg_is_set(cmd, chunksize_ARG))
+			lp->chunk_size = first_seg(lv)->chunk_size;
+		if (!arg_is_set(cmd, cachemode_ARG))
+			lp->feature_flags = first_seg(lv)->feature_flags;
 	} else if (lv) {
 		/* Origin exists, create cache pool volume */
 		if (!validate_lv_cache_create_origin(lv))
 			return_0;
 
-		if (arg_is_set(vg->cmd, permission_ARG) &&
+		if (arg_is_set(cmd, permission_ARG) &&
 		    ((lp->permission & LVM_WRITE) != (lv->status & LVM_WRITE))) {
 			/* Reverting permissions on all error path is very complicated */
 			log_error("Change of volume permission is unsupported with cache conversion, use lvchange.");
 			return 0;
 		}
 		/* FIXME: how to handle skip flag */
-		if (arg_from_list_is_set(vg->cmd, "is unsupported with cache conversion",
+		if (arg_from_list_is_set(cmd, "is unsupported with cache conversion",
 					 setactivationskip_ARG,
 					 ignoreactivationskip_ARG,
 					 -1))
@@ -1066,16 +1072,16 @@ static int _determine_cache_argument(struct volume_group *vg,
 		/* Put origin into resulting activation state first */
 		if (is_change_activating(lp->activate)) {
 			if ((lp->activate == CHANGE_AAY) &&
-			    !lv_passes_auto_activation_filter(vg->cmd, lv)) {
+			    !lv_passes_auto_activation_filter(cmd, lv)) {
 				log_verbose("Skipping activation of cache origin %s.",
 					    display_lvname(lv));
 				return 1;
-			} else if (!activate_lv_excl_local(vg->cmd, lv)) {
+			} else if (!activate_lv_excl_local(cmd, lv)) {
 				log_error("Cannot activate cache origin %s.",
 					  display_lvname(lv));
 				return 0;
 			}
-		} else if (!deactivate_lv(vg->cmd, lv)) {
+		} else if (!deactivate_lv(cmd, lv)) {
 			log_error("Cannot deactivate activate cache origin %s.",
 				  display_lvname(lv));
 			return 0;


