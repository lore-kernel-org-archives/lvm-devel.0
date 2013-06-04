From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:25:43 +0000 (UTC)
Subject: dev-mornfall-activate - cleanup: use dm_list_iterate_items
Message-ID: <20130604192543.67AF76146B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f39f5b86c3f94fe83744054012d6d8b33bb7d7a0
Commit:        f39f5b86c3f94fe83744054012d6d8b33bb7d7a0
Parent:        c1eb17ab07f457d92bff58ea489c670be7bed9ed
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 25 11:46:17 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 25 17:33:24 2013 +0200

cleanup: use dm_list_iterate_items

---
 lib/activate/activate.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 670b85c..05cfb66 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1410,7 +1410,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
 #ifdef DMEVENTD
 	int i, pending = 0, monitored;
 	int r = 1;
-	struct dm_list *tmp, *snh, *snht;
+	struct dm_list *snh, *snht;
 	struct lv_segment *seg;
 	struct lv_segment *log_seg;
 	int (*monitor_fn) (struct lv_segment *s, int e);
@@ -1473,9 +1473,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
 		if (!monitor_dev_for_events(cmd, seg->log_lv, NULL, monitor))
 			r = 0;
 
-	dm_list_iterate(tmp, &lv->segments) {
-		seg = dm_list_item(tmp, struct lv_segment);
-
+	dm_list_iterate_items(seg, &lv->segments) {
 		/* Recurse for AREA_LV */
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) != AREA_LV)


