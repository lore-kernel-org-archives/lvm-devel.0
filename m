From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:34 +0000 (UTC)
Subject: master - cleanup: move code
Message-ID: <20141024144034.ACD1A60CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cf674142a2c1504d5652a5dd5479041272fd34ec
Commit:        cf674142a2c1504d5652a5dd5479041272fd34ec
Parent:        4f8ed25a999821cd37cc1e2c0051e60e8a63e371
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 18 11:01:34 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

cleanup: move code

---
 lib/metadata/lv_manip.c |   10 ++++------
 tools/lvcreate.c        |    5 ++---
 2 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ec09b41..244db1b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6573,7 +6573,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 {
 	struct cmd_context *cmd = vg->cmd;
 	uint32_t size_rest;
-	uint64_t status = UINT64_C(0);
+	uint64_t status = lp->permission | VISIBLE_LV;
 	struct logical_volume *lv, *origin_lv = NULL;
 	struct logical_volume *pool_lv;
 	struct logical_volume *tmp_lv;
@@ -6672,8 +6672,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		lp->extents = lp->extents - size_rest + lp->stripes;
 	}
 
-	status |= lp->permission | VISIBLE_LV;
-
 	if (seg_is_cache(lp)) {
 		if (!lp->pool_name) {
 			log_error(INTERNAL_ERROR "Cannot create thin volume without thin pool.");
@@ -6900,6 +6898,9 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		if (!recalculate_pool_chunk_size_with_dev_hints(lv, lp->passed_args,
 								THIN_CHUNK_SIZE_CALC_METHOD_GENERIC))
 			return_NULL;
+	} else if (seg_is_raid(lp)) {
+		first_seg(lv)->min_recovery_rate = lp->min_recovery_rate;
+		first_seg(lv)->max_recovery_rate = lp->max_recovery_rate;
 	} else if (seg_is_thin_pool(lp)) {
 		first_seg(lv)->chunk_size = lp->chunk_size;
 		first_seg(lv)->zero_new_blocks = lp->zero ? 1 : 0;
@@ -6936,9 +6937,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		if (!attach_pool_message(first_seg(pool_lv),
 					 DM_THIN_MESSAGE_CREATE_THIN, lv, 0, 0))
 			return_NULL;
-	} else if (seg_is_raid(lp)) {
-		first_seg(lv)->min_recovery_rate = lp->min_recovery_rate;
-		first_seg(lv)->max_recovery_rate = lp->max_recovery_rate;
 	}
 
 	/* FIXME Log allocation and attachment should have happened inside lv_extend. */
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 7573a2e..8b3255c 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -806,9 +806,6 @@ static int _read_activation_params(struct lvcreate_params *lp,
 		return 0;
 	}
 
-	lp->yes = arg_count(cmd, yes_ARG);
-	lp->force = (force_t) arg_count(cmd, force_ARG);
-
 	return 1;
 }
 
@@ -825,6 +822,8 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	memset(lcp, 0, sizeof(*lcp));
 	dm_list_init(&lp->tags);
 	lp->target_attr = ~0;
+	lp->yes = arg_count(cmd, yes_ARG);
+	lp->force = (force_t) arg_count(cmd, force_ARG);
 
 	/* Set default segtype - remember, '-m 0' implies stripe. */
 	if (arg_count(cmd, mirrors_ARG) &&


