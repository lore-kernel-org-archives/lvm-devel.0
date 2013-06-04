From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:25:34 +0000 (UTC)
Subject: dev-mornfall-activate - report: show dmeventd monitoring status
Message-ID: <20130604192534.D09656141B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b18ab76d27f40094f281d5695a6bb82b65e1976
Commit:        8b18ab76d27f40094f281d5695a6bb82b65e1976
Parent:        3f7de58e96a2ba84bf2590465ee9f5f7929cb74d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 25 12:07:57 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 25 17:33:24 2013 +0200

report: show dmeventd monitoring status

Add new lvs segment field 'Monitor' showing 3 states:

"monitored" - LV is monitored by dmeventd.

"not monitored" - LV is currently not being monitored by dmeventd

"" (empty) - LV does not support monitoring, or dmeventd support
             is not compiled in.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv.c       |   34 ++++++++++++++++++++++++++++++++++
 lib/metadata/lv.h       |    1 +
 lib/report/columns.h    |    1 +
 lib/report/properties.c |    2 ++
 lib/report/report.c     |   14 ++++++++++++++
 6 files changed, 53 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 27ebcec..a625dba 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add "monitor" segment reporting field to show dmevent monitoring status.
   Document lvextend --use-policies option in man.
   Fix creation and removal of clustered snapshot.
   Fix clvmd caching of metadata when suspending inactive volumes.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 6afa468..e515e02 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -128,6 +128,40 @@ char *lvseg_discards_dup(struct dm_pool *mem, const struct lv_segment *seg)
 	return  dm_pool_strdup(mem, get_pool_discards_name(seg->discards));
 }
 
+#ifdef DMEVENTD
+#  include "libdevmapper-event.h"
+#endif
+char *lvseg_monitor_dup(struct dm_pool *mem, const struct lv_segment *seg)
+{
+	const char *s = "";
+
+#ifdef DMEVENTD
+	struct lvinfo info;
+	int pending = 0, monitored;
+	struct lv_segment *segm = (struct lv_segment *) seg;
+
+	if (lv_is_cow(seg->lv) && !lv_is_merging_cow(seg->lv))
+		segm = first_seg(seg->lv->snapshot->lv);
+	else if (seg->log_lv)
+		segm = first_seg(seg->log_lv);
+
+	// log_debug("Query LV:%s mon:%s segm:%s tgtm:%p  segmon:%d statusm:%d", seg->lv->name, segm->lv->name, segm->segtype->name, segm->segtype->ops->target_monitored, seg_monitored(segm), (int)(segm->status & PVMOVE));
+	if (!segm->segtype->ops->target_monitored)
+		/* Nothing to do, monitoring not supported */;
+	else if (!seg_monitored(segm) || (segm->status & PVMOVE))
+		s = "not monitored";
+	else if (lv_info(seg->lv->vg->cmd, seg->lv, 1, &info, 0, 0) && info.exists) {
+		monitored = segm->segtype->ops->
+			target_monitored((struct lv_segment*)segm, &pending);
+		if (pending)
+			s = "pending";
+		else
+			s = (monitored) ? "monitored" : "not monitored";
+	} // else log_debug("Not active");
+#endif
+	return dm_pool_strdup(mem, s);
+}
+
 uint64_t lvseg_chunksize(const struct lv_segment *seg)
 {
 	uint64_t size;
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 03255fb..7652cd4 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -76,6 +76,7 @@ uint64_t lvseg_size(const struct lv_segment *seg);
 uint64_t lvseg_chunksize(const struct lv_segment *seg);
 char *lvseg_segtype_dup(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_discards_dup(struct dm_pool *mem, const struct lv_segment *seg);
+char *lvseg_monitor_dup(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_tags_dup(const struct lv_segment *seg);
 char *lvseg_devices(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_seg_pe_ranges(struct dm_pool *mem, const struct lv_segment *seg);
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 42858f1..07c9b7b 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -155,6 +155,7 @@ FIELD(SEGS, seg, NUM, "SSize", list, 5, segsize, seg_size, "Size of segment in c
 FIELD(SEGS, seg, STR, "Seg Tags", tags, 8, tags, seg_tags, "Tags, if any.", 0)
 FIELD(SEGS, seg, STR, "PE Ranges", list, 9, peranges, seg_pe_ranges, "Ranges of Physical Extents of underlying devices in command line format.", 0)
 FIELD(SEGS, seg, STR, "Devices", list, 7, devices, devices, "Underlying devices used with starting extent numbers.", 0)
+FIELD(SEGS, seg, STR, "Monitor", list, 7, segmonitor, monitor, "Dmeventd monitoring status of the segment.", 0)
 
 FIELD(PVSEGS, pvseg, NUM, "Start", pe, 5, uint32, pvseg_start, "Physical Extent number of start of segment.", 0)
 FIELD(PVSEGS, pvseg, NUM, "SSize", len, 5, uint32, pvseg_size, "Number of extents in segment.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 71b3cb1..6f0d980 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -332,6 +332,8 @@ GET_LVSEG_STR_PROPERTY_FN(seg_pe_ranges,
 #define _seg_pe_ranges_set _not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(devices, lvseg_devices(lvseg->lv->vg->vgmem, lvseg))
 #define _devices_set _not_implemented_set
+GET_LVSEG_STR_PROPERTY_FN(monitor, lvseg_monitor_dup(lvseg->lv->vg->vgmem, lvseg))
+#define _monitor_set _not_implemented_set
 
 
 /* PVSEG */
diff --git a/lib/report/report.c b/lib/report/report.c
index 8578ff7..9ef2687 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -489,6 +489,20 @@ static int _vgsize_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _size64_disp(rh, mem, field, &size, private);
 }
 
+static int _segmonitor_disp(struct dm_report *rh, struct dm_pool *mem,
+			    struct dm_report_field *field,
+			    const void *data, void *private)
+{
+	char *str;
+
+	if (!(str = lvseg_monitor_dup(mem, (const struct lv_segment *)data)))
+		return_0;
+
+	dm_report_field_set_value(field, str, NULL);
+
+	return 1;
+}
+
 static int _segstart_disp(struct dm_report *rh, struct dm_pool *mem,
 			  struct dm_report_field *field,
 			  const void *data, void *private)


