From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 13:02:00 +0000 (UTC)
Subject: master - cleanup: remove unused sizearg variable
Message-ID: <20160623130200.0FD3A6090A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5a919e48053079670e6318fe862783e720dd2aea
Commit:        5a919e48053079670e6318fe862783e720dd2aea
Parent:        4de15aa58d2cd25075d3b17c3d3d9ad06b4bb493
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 17 13:25:56 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 23 14:59:29 2016 +0200

cleanup: remove unused sizearg variable

It's not used for anything now.
---
 lib/locking/lvmlockd.c           |    1 -
 lib/metadata/lv_manip.c          |    1 -
 lib/metadata/metadata-exported.h |    1 -
 liblvm/lvm_lv.c                  |    1 -
 tools/lvresize.c                 |    1 -
 5 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index e865c10..f9d215a 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -373,7 +373,6 @@ static int _extend_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
 		.percent = PERCENT_NONE,
 		.resize = LV_EXTEND,
 		.force = 1,
-		.sizeargs = 1,
 	};
 
 	if (!lv_resize(lv, &lp, &vg->pvs)) {
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 70969e8..46815e3 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5004,7 +5004,6 @@ static int _lvresize_adjust_extents(struct logical_volume *lv,
 				seg_size = lp->extents - existing_logical_extents;	// Recalculate
 				if (lp->extents == existing_logical_extents) {
 					/* Signal that normal resizing is not required */
-					lp->sizeargs = 0;
 					return 1;
 				}
 			}
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index d2c9db2..b8275d6 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -607,7 +607,6 @@ struct lvresize_params {
 
 	const struct segment_type *segtype;
 
-	int sizeargs;
 	uint64_t poolmetadata_size;
 	sign_t poolmetadata_sign;
 	uint32_t poolmetadataextents;
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index d732ed7..ccdc340 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -463,7 +463,6 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 		.resize = LV_ANY,
 		.size = new_size >> SECTOR_SHIFT,
 		.force = 1,	/* Assume the user has a good backup? */
-		.sizeargs = 1,
 	};
 	struct saved_env e = store_user_env(lv->vg->cmd);
 
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 1258f14..45d3558 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -55,7 +55,6 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 		 * If only --poolmetadatasize is specified with list of PVs,
 		 * then metadata will be extended there.
 		 */
-		lp->sizeargs = arg_is_set(cmd, extents_ARG) + arg_is_set(cmd, size_ARG);
 		if ((lp->extents = arg_uint_value(cmd, extents_ARG, 0))) {
 			lp->sign = arg_sign_value(cmd, extents_ARG, SIGN_NONE);
 			lp->percent = arg_percent_value(cmd, extents_ARG, PERCENT_NONE);


