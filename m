From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  5 Mar 2015 13:04:28 +0000 (UTC)
Subject: master - report: fix seg_monitor field to display monitoring status for thick snapshots and mirrors
Message-ID: <20150305130428.E3A5B60C28@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=190d591fbec672a2e1f77d4709fcee75cc695a06
Commit:        190d591fbec672a2e1f77d4709fcee75cc695a06
Parent:        56606b5f21682cfb8f36aef419f0cb7dcf55cce9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Mar 5 10:45:29 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 5 14:05:34 2015 +0100

report: fix seg_monitor field to display monitoring status for thick snapshots and mirrors

The seg_monitor did not display monitored status for thick snapshots
and mirrors (with mirror log *not* mirrored). The seg monitor did work
correctly even before for other segtypes - thins and raids.

Before (mirrors and snapshots, only mirrors with mirrored log properly displayed monitoring status):

[0] f21/~ # lvs -a -o lv_name,lv_layout,lv_role,seg_monitor vg
  LV                                     Layout     Role                             Monitor
  mirror                                 mirror     public
  [mirror_mimage_0]                      linear     private,mirror,image
  [mirror_mimage_1]                      linear     private,mirror,image
  [mirror_mlog]                          linear     private,mirror,log

  mirror_with_mirror_log                 mirror     public                           monitored
  [mirror_with_mirror_log_mimage_0]      linear     private,mirror,image
  [mirror_with_mirror_log_mimage_1]      linear     private,mirror,image
  [mirror_with_mirror_log_mlog]          mirror     private,mirror,log               monitored
  [mirror_with_mirror_log_mlog_mimage_0] linear     private,mirror,image
  [mirror_with_mirror_log_mlog_mimage_1] linear     private,mirror,image

  thick_origin                           linear     public,origin,thickorigin
  thick_snapshot                         linear     public,snapshot,thicksnapshot

With this patch applied (monitoring status displayed for all mirrors and snapshots):

[0] f21/~ # lvs -a -o lv_name,lv_layout,lv_role,seg_monitor vg
  LV                                     Layout     Role                             Monitor
  mirror                                 mirror     public                           monitored
  [mirror_mimage_0]                      linear     private,mirror,image
  [mirror_mimage_1]                      linear     private,mirror,image
  [mirror_mlog]                          linear     private,mirror,log

  mirror_with_mirror_log                 mirror     public                           monitored
  [mirror_with_mirror_log_mimage_0]      linear     private,mirror,image
  [mirror_with_mirror_log_mimage_1]      linear     private,mirror,image
  [mirror_with_mirror_log_mlog]          mirror     private,mirror,log               monitored
  [mirror_with_mirror_log_mlog_mimage_0] linear     private,mirror,image
  [mirror_with_mirror_log_mlog_mimage_1] linear     private,mirror,image

  thick_origin                           linear     public,origin,thickorigin
  thick_snapshot                         linear     public,snapshot,thicksnapshot    monitored
---
 WHATS_NEW           |    1 +
 lib/metadata/lv.c   |    2 --
 lib/report/report.c |   10 +++++-----
 3 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f597980..46783e1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.118 - 
 =================================
+  Fix seg_monitor field to report status also for mirrors and thick snapshots.
 
 Version 2.02.117 - 4th March 2015
 =================================
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index c3c5d4a..10ce906 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -152,8 +152,6 @@ char *lvseg_monitor_dup(struct dm_pool *mem, const struct lv_segment *seg)
 
 	if (lv_is_cow(seg->lv) && !lv_is_merging_cow(seg->lv))
 		segm = first_seg(seg->lv->snapshot->lv);
-	else if (seg->log_lv)
-		segm = first_seg(seg->log_lv);
 
 	// log_debug("Query LV:%s mon:%s segm:%s tgtm:%p  segmon:%d statusm:%d", seg->lv->name, segm->lv->name, segm->segtype->name, segm->segtype->ops->target_monitored, seg_monitored(segm), (int)(segm->status & PVMOVE));
 	if ((dmeventd_monitor_mode() != 1) ||
diff --git a/lib/report/report.c b/lib/report/report.c
index 75928c0..4ef2b04 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -791,14 +791,14 @@ static int _segmonitor_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_segment *seg = (const struct lv_segment *)data;
 	char *str;
 
-	if (!seg->segtype->ops || !seg->segtype->ops->target_monitored)
-		return _field_set_value(field, GET_FIRST_RESERVED_NAME(seg_monitor_undef),
-					GET_FIELD_RESERVED_VALUE(seg_monitor_undef));
-
 	if (!(str = lvseg_monitor_dup(mem, seg)))
 		return_0;
 
-	return _field_set_value(field, str, NULL);
+	if (*str)
+		return _field_set_value(field, str, NULL);
+
+	return _field_set_value(field, GET_FIRST_RESERVED_NAME(seg_monitor_undef),
+				GET_FIELD_RESERVED_VALUE(seg_monitor_undef));
 }
 
 static int _segstart_disp(struct dm_report *rh, struct dm_pool *mem,


