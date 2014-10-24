From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:41:03 +0000 (UTC)
Subject: master - pools: error path removes metadata
Message-ID: <20141024144103.D82AE60CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=51a29e60564d5379b38ee4688bca5eb9b844c410
Commit:        51a29e60564d5379b38ee4688bca5eb9b844c410
Parent:        dfcf03a9ce2fe9b618f44c5f99e13ff5610ffcc0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 24 15:21:48 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:32 2014 +0200

pools: error path removes metadata

When pool volume is create - it has already managed to update metadata
once within lv_extend - so revert new created LV here.
---
 lib/metadata/lv_manip.c |   20 +++++++++++++++-----
 1 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 5125412..277a51d 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6888,8 +6888,10 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		first_seg(lv)->feature_flags = lp->feature_flags;
 		/* TODO: some calc_policy solution for cache ? */
 		if (!recalculate_pool_chunk_size_with_dev_hints(lv, lp->passed_args,
-								THIN_CHUNK_SIZE_CALC_METHOD_GENERIC))
-			return_NULL;
+								THIN_CHUNK_SIZE_CALC_METHOD_GENERIC)) {
+			stack;
+			goto revert_new_lv;
+		}
 	} else if (seg_is_raid(lp)) {
 		first_seg(lv)->min_recovery_rate = lp->min_recovery_rate;
 		first_seg(lv)->max_recovery_rate = lp->max_recovery_rate;
@@ -6900,8 +6902,10 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		/* FIXME: use lowwatermark  via lvm.conf global for all thinpools ? */
 		first_seg(lv)->low_water_mark = 0;
 		if (!recalculate_pool_chunk_size_with_dev_hints(lv, lp->passed_args,
-								lp->thin_chunk_size_calc_policy))
-			return_NULL;
+								lp->thin_chunk_size_calc_policy)) {
+			stack;
+			goto revert_new_lv;
+		}
 	} else if (seg_is_thin_volume(lp)) {
 		pool_lv = first_seg(lv)->pool_lv;
 		if (!(first_seg(lv)->device_id =
@@ -7007,8 +7011,14 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	}
 
 	/* store vg on disk(s) */
-	if (!vg_write(vg) || !vg_commit(vg))
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		if (seg_is_pool(lp)) {
+			/* Pool volumes have already created metadata LV */
+			stack;
+			goto revert_new_lv;
+		}
 		return_NULL;
+	}
 
 	backup(vg);
 


