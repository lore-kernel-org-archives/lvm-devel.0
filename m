From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 11 Jun 2018 16:28:02 -0400
Subject: master - snapshot: improve checking of merging snapshot
Message-ID: <201806112028.w5BKS2iG030027@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=77d5caae90a898888d32603bc7823de40f426c06
Commit:        77d5caae90a898888d32603bc7823de40f426c06
Parent:        75fed05d3ef648583764ff56cc577e0f3eba1bba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 11 22:19:20 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 11 22:25:42 2018 +0200

snapshot: improve checking of merging snapshot

Add runtime detection for 'lvs -o+seg_monitor' and 'vgchange --monitor'.
This fix should avoid unnecessary timeout on systemd shutdown.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |    3 ++-
 lib/metadata/lv.c       |    3 ++-
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 162b584..a875553 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 3.0.0
 =============
+  Fix unmonitoring of merging snapshots.
   Cache can uses metadata format 2 with cleaner policy.
   Fix check if resized PV can also fit metadata area.
   Avoid showing internal error in lvs output or pvmoved LVs.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index ce67ec8..8f4462a 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1735,7 +1735,8 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 	 * In case of a snapshot device, we monitor lv->snapshot->lv,
 	 * not the actual LV itself.
 	 */
-	if (lv_is_cow(lv) && (laopts->no_merging || !lv_is_merging_cow(lv))) {
+	if (lv_is_cow(lv) && (laopts->no_merging || !lv_is_merging_cow(lv) ||
+			      lv_has_target_type(lv->vg->cmd->mem, lv, NULL, TARGET_NAME_SNAPSHOT))) {
 		if (!(r = monitor_dev_for_events(cmd, lv->snapshot->lv, NULL, monitor)))
 			stack;
 		return r;
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 14d7312..7ab06cb 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -301,7 +301,8 @@ char *lvseg_monitor_dup(struct dm_pool *mem, const struct lv_segment *seg)
 	int pending = 0, monitored = 0;
 	struct lv_segment *segm = (struct lv_segment *) seg;
 
-	if (lv_is_cow(seg->lv) && !lv_is_merging_cow(seg->lv))
+	if (lv_is_cow(seg->lv) && (!lv_is_merging_cow(seg->lv) ||
+				   lv_has_target_type(seg->lv->vg->cmd->mem, seg->lv, NULL, TARGET_NAME_SNAPSHOT)))
 		segm = first_seg(seg->lv->snapshot->lv);
 
 	// log_debug("Query LV:%s mon:%s segm:%s tgtm:%p  segmon:%d statusm:%d", seg->lv->name, segm->lv->name, segm->segtype->name, segm->segtype->ops->target_monitored, seg_monitored(segm), (int)(segm->status & PVMOVE));


