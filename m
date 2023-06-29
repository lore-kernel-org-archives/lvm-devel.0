From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2023 18:25:03 +0000 (GMT)
Subject: main - lv: more details about monitoring lvs
Message-ID: <20230629182503.C3C873858416@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3596558861e62ca0c6f37bfba6a4e80e46dcca47
Commit:        3596558861e62ca0c6f37bfba6a4e80e46dcca47
Parent:        8a07f57ba478c16ca5d5eacf778ee2708109aa65
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 11:51:35 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 13:10:42 2023 +0200

lv: more details about monitoring lvs

Show "not supported" when LV does not support dmeventd monitoring.
Show "disabled" for LV with disabled dmeventd monitoring.
(lvdisplay -m)
---
 lib/metadata/lv.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 21aa3b422..1e3fc02d4 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -311,10 +311,11 @@ char *lvseg_monitor_dup(struct dm_pool *mem, const struct lv_segment *seg)
 		segm = first_seg(seg->lv->snapshot->lv);
 
 	// log_debug("Query LV:%s mon:%s segm:%s tgtm:%p  segmon:%d statusm:%d", seg->lv->name, segm->lv->name, segm->segtype->name, segm->segtype->ops->target_monitored, seg_monitored(segm), (int)(segm->status & PVMOVE));
-	if ((dmeventd_monitor_mode() != 1) ||
-	    !segm->segtype->ops ||
+	if (!segm->segtype->ops ||
 	    !segm->segtype->ops->target_monitored)
-		/* Nothing to do, monitoring not supported */;
+		s = "disabled";
+	else if (dmeventd_monitor_mode() != 1)
+		s = "not enabled";
 	else if (lv_is_cow_covering_origin(seg->lv))
 		/* Nothing to do, snapshot already covers origin */;
 	else if (!seg_monitored(segm) || (segm->status & PVMOVE))

