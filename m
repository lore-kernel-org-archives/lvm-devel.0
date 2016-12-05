From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  5 Dec 2016 16:15:24 +0000 (UTC)
Subject: master - cleanup: simplify code
Message-ID: <20161205161524.729496030D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=69c79ed2f486a9092cdf1586fcf320634e3cd44d
Commit:        69c79ed2f486a9092cdf1586fcf320634e3cd44d
Parent:        114f7e62854e7b62f613925881ad321c3d5f6ff3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 5 14:30:13 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 5 17:12:42 2016 +0100

cleanup: simplify code

Drop unneeded assignemnt in structs (var is set by called function).
---
 lib/metadata/lv.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 087b564..081df71 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -243,10 +243,7 @@ char *lvseg_kernel_discards_dup(struct dm_pool *mem, const struct lv_segment *se
 {
 	char *ret = NULL;
 	struct lv_with_info_and_seg_status status = {
-		.seg_status = {
-			.type = SEG_STATUS_NONE,
-			.seg = seg
-		},
+		.seg_status.type = SEG_STATUS_NONE
 	};
 
 	if (!lv_is_thin_pool(seg->lv))
@@ -416,8 +413,8 @@ dm_percent_t lvseg_percent_with_info_and_seg_status(const struct lv_with_info_an
 			else {
 				log_warn("WARNING: Thin volume %s maps %s while the size is only %s.",
 					 display_lvname(seg->lv),
-					 display_size(lvdm->lv->vg->cmd, s->thin->mapped_sectors),
-					 display_size(lvdm->lv->vg->cmd, csize));
+					 display_size(seg->lv->vg->cmd, s->thin->mapped_sectors),
+					 display_size(seg->lv->vg->cmd, csize));
 				/* Don't show nonsense numbers like i.e. 1000% full */
 				p = DM_PERCENT_100;
 			}
@@ -1312,7 +1309,6 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	char *ret = NULL;
 	struct lv_with_info_and_seg_status status = {
 		.seg_status.type = SEG_STATUS_NONE,
-		.lv = lv
 	};
 
 	if (!(status.seg_status.mem = dm_pool_create("reporter_pool", 1024)))


