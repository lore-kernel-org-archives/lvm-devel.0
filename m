From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 1 Dec 2017 06:20:37 -0500
Subject: master - suspend: optimize generated list
Message-ID: <201712011120.vB1BKbwU029476@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4dc81848034f4f5edb02335af03e50f45c3977f0
Commit:        4dc81848034f4f5edb02335af03e50f45c3977f0
Parent:        7e794b7748a84d2e8f48012b6c31ba50992c8ac1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 30 13:24:41 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 1 12:19:09 2017 +0100

suspend: optimize generated list

Avoid adding same LV multiple times into the list.
Just saves couple extra calls and ioctls and makes log shorter.
---
 lib/activate/activate.c |   22 ++++++++++++++++------
 1 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index eacf638..381083b 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2089,7 +2089,7 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	const struct logical_volume *pvmove_lv = NULL;
 	const struct logical_volume *lv_to_free = NULL;
 	const struct logical_volume *lv_pre_to_free = NULL;
-	struct logical_volume *lv_pre_tmp;
+	struct logical_volume *lv_pre_tmp, *lv_tmp;
 	struct seg_list *sl;
 	struct lv_segment *snap_seg;
 	struct lvinfo info;
@@ -2098,6 +2098,7 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	struct dm_pool *mem = NULL;
 	struct dm_list suspend_lvs;
 	struct lv_list *lvl;
+	int found;
 
 	if (!activation())
 		return 1;
@@ -2247,19 +2248,28 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		/* Prepare list of all LVs for suspend ahead */
 		dm_list_init(&suspend_lvs);
 		dm_list_iterate_items(sl, &pvmove_lv->segs_using_this_lv) {
+			lv_tmp = sl->seg->lv;
+			if (lv_is_cow(lv_tmp))
+				/* Never suspend COW, always has to be origin */
+				lv_tmp = origin_from_cow(lv_tmp);
+			found = 0;
+			dm_list_iterate_items(lvl, &suspend_lvs)
+				if (strcmp(lvl->lv->name, lv_tmp->name) == 0) {
+					found = 1;
+					break;
+				}
+			if (found)
+				continue; /* LV is already in the list */
 			if (!(lvl = dm_pool_alloc(mem, sizeof(*lvl)))) {
 				log_error("lv_list alloc failed.");
 				goto out;
 			}
 			/* Look for precommitted LV name in commmitted VG */
-			if (!(lvl->lv = find_lv(lv->vg, sl->seg->lv->name))) {
+			if (!(lvl->lv = find_lv(lv->vg, lv_tmp->name))) {
 				log_error(INTERNAL_ERROR "LV %s missing from preload metadata.",
-					  display_lvname(sl->seg->lv));
+					  display_lvname(lv_tmp));
 				goto out;
 			}
-			/* Never suspend COW, always has to be origin */
-			if (lv_is_cow(lvl->lv))
-				lvl->lv = origin_from_cow(lvl->lv);
 			dm_list_add(&suspend_lvs, &lvl->list);
 		}
 		dm_list_iterate_items(lvl, &suspend_lvs)


