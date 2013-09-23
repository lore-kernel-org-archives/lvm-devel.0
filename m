From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Sep 2013 20:53:57 +0000 (UTC)
Subject: master - lvs: Add seg_size_pe field.
Message-ID: <20130923205357.B9EB5605CC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=11dc6a03c4cdd10bc4065c7d7a8585373455f947
Commit:        11dc6a03c4cdd10bc4065c7d7a8585373455f947
Parent:        8de47abcd231fecde7c0627ff5085f8efef12583
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Sep 23 21:50:14 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Sep 23 21:50:14 2013 +0100

lvs: Add seg_size_pe field.

Requested
https://www.redhat.com/archives/linux-lvm/2013-July/msg00112.html
---
 WHATS_NEW               |    1 +
 lib/report/columns.h    |    1 +
 lib/report/properties.c |    2 ++
 lib/report/report.c     |   11 +++++++++++
 man/lvs.8.in            |    1 +
 5 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4ffbe4f..efd83e6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.103 - 
 ======================================
+  Add seg_size_pe field to reports.
   Support start+length notation with command line PE ranges.
   Exit cleanly with message when pvmove cannot restart because LV is inactive.
 
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 9bb99d3..6df9771 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -125,6 +125,7 @@ FIELD(SEGS, seg, NUM, "TransId", list, 4, transactionid, transaction_id, "For th
 FIELD(SEGS, seg, NUM, "Start", list, 5, segstart, seg_start, "Offset within the LV to the start of the segment in current units.", 0)
 FIELD(SEGS, seg, NUM, "Start", list, 5, segstartpe, seg_start_pe, "Offset within the LV to the start of the segment in physical extents.", 0)
 FIELD(SEGS, seg, NUM, "SSize", list, 5, segsize, seg_size, "Size of segment in current units.", 0)
+FIELD(SEGS, seg, NUM, "SSize", list, 5, segsizepe, seg_size_pe, "Size of segment in physical extents.", 0)
 FIELD(SEGS, seg, STR, "Seg Tags", tags, 8, tags, seg_tags, "Tags, if any.", 0)
 FIELD(SEGS, seg, STR, "PE Ranges", list, 9, peranges, seg_pe_ranges, "Ranges of Physical Extents of underlying devices in command line format.", 0)
 FIELD(SEGS, seg, STR, "Devices", list, 7, devices, devices, "Underlying devices used with starting extent numbers.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 62a1a35..56200f0 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -315,6 +315,8 @@ GET_LVSEG_NUM_PROPERTY_FN(seg_start_pe, lvseg->le)
 #define _seg_start_pe_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(seg_size, (SECTOR_SIZE * lvseg_size(lvseg)))
 #define _seg_size_set prop_not_implemented_set
+GET_LVSEG_NUM_PROPERTY_FN(seg_size_pe, lvseg->len)
+#define _seg_size_pe_set prop_not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(seg_tags, lvseg_tags_dup(lvseg))
 #define _seg_tags_set prop_not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(seg_pe_ranges,
diff --git a/lib/report/report.c b/lib/report/report.c
index 540181a..46edf56 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -560,6 +560,17 @@ static int _segsize_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _size64_disp(rh, mem, field, &size, private);
 }
 
+static int _segsizepe_disp(struct dm_report *rh,
+			   struct dm_pool *mem __attribute__((unused)),
+			   struct dm_report_field *field,
+			   const void *data,
+			   void *private __attribute__((unused)))
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+
+	return dm_report_field_uint32(rh, field, &seg->len);
+}
+
 static int _chunksize_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)
diff --git a/man/lvs.8.in b/man/lvs.8.in
index 32cb788..85f7d33 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -113,6 +113,7 @@ segtype,
 seg_count,
 seg_pe_ranges,
 seg_size,
+seg_size_pe,
 seg_start,
 seg_start_pe,
 seg_tags,


