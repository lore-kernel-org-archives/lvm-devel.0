From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 31 Oct 2019 08:18:03 -0400
Subject: stable-2.02 - manip: optimize lvs_using_lv
Message-ID: <201910311218.x9VCI3vJ010842@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2c46c60155a1a22626875b1023ce964216f23f95
Commit:        2c46c60155a1a22626875b1023ce964216f23f95
Parent:        4b7bcf3ed4b5e427984bd7883238e681405edf5f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 31 12:38:56 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 31 13:00:01 2019 +0100

manip: optimize lvs_using_lv

Instead of checking all LVs in a VG - do just a direct copy of LVs
from the existing list ->segs_using_thin_lv.

TODO: maybe it could be better to expose seg_list to /tools...
---
 lib/metadata/mirror.c |   33 ++++++++-------------------------
 1 files changed, 8 insertions(+), 25 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 411079a..4e88f25 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1374,10 +1374,8 @@ struct dm_list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
 			  struct logical_volume *lv)
 {
 	struct dm_list *lvs;
-	struct logical_volume *lv1;
-	struct lv_list *lvl, *lvl1;
-	struct lv_segment *seg;
-	uint32_t s;
+	struct lv_list *lvl;
+	struct seg_list *sl;
 
 	if (!(lvs = dm_pool_alloc(cmd->mem, sizeof(*lvs)))) {
 		log_error("lvs list alloc failed.");
@@ -1386,29 +1384,14 @@ struct dm_list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
 
 	dm_list_init(lvs);
 
-	/* Loop through all LVs except the one supplied */
-	dm_list_iterate_items(lvl1, &vg->lvs) {
-		lv1 = lvl1->lv;
-		if (lv1 == lv)
-			continue;
-
+	dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
 		/* Find whether any segment points at the supplied LV */
-		dm_list_iterate_items(seg, &lv1->segments) {
-			for (s = 0; s < seg->area_count; s++) {
-				if (seg_type(seg, s) != AREA_LV ||
-				    seg_lv(seg, s) != lv)
-					continue;
-				if (!(lvl = dm_pool_alloc(cmd->mem, sizeof(*lvl)))) {
-					log_error("lv_list alloc failed.");
-					return NULL;
-				}
-				lvl->lv = lv1;
-				dm_list_add(lvs, &lvl->list);
-				goto next_lv;
-			}
+		if (!(lvl = dm_pool_alloc(cmd->mem, sizeof(*lvl)))) {
+			log_error("lv_list alloc failed.");
+			return NULL;
 		}
-	      next_lv:
-		;
+		lvl->lv = sl->seg->lv;
+		dm_list_add(lvs, &lvl->list);
 	}
 
 	return lvs;


