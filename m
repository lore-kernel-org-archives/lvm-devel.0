From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 18 Jul 2012 12:39:22 +0000 (UTC)
Subject: master - thin: add reporting of discard for thin pool
Message-ID: <20120718123922.0BC801567@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=46b9cc1248941cc43f953e1a6b285ebe64a62077
Commit:        46b9cc1248941cc43f953e1a6b285ebe64a62077
Parent:        ebbf7d8e68f37c1a1e448a07676cca0a6e7f1430
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 9 16:48:28 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 18 14:37:44 2012 +0200

thin: add reporting of discard for thin pool

New field  "discard" is added for lvs reporting of lv segment.
Reported as one character:
 (i)gnore
 (n)opassdown
 (p)assdown

lvs -o+discard
---
 WHATS_NEW               |    1 +
 lib/report/columns.h    |    1 +
 lib/report/properties.c |    2 ++
 lib/report/report.c     |   30 ++++++++++++++++++++++++++++++
 man/lvs.8.in            |    1 +
 5 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 41b52be..7811b6d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Report used discard for thin pool and volume.
   Add support for controlling discard behavior of thin pool.
   Detect features for new 1.1 thin pool target.
   Count percentage of completeness upwards when merging a snapshot volume.
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 579f029..7bcaaab 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -140,6 +140,7 @@ FIELD(SEGS, seg, NUM, "Region", region_size, 6, size32, region_size, "For mirror
 FIELD(SEGS, seg, NUM, "Chunk", list, 5, chunksize, chunksize, "For snapshots, the unit of data used when tracking changes.", 0)
 FIELD(SEGS, seg, NUM, "Chunk", list, 5, chunksize, chunk_size, "For snapshots, the unit of data used when tracking changes.", 0)
 FIELD(SEGS, seg, NUM, "#Thins", list, 4, thincount, thin_count, "For thin pools, the number of thin volumes in this pool.", 0)
+FIELD(SEGS, seg, NUM, "Dis", list, 3, discard, discard, "For thin pools, discard handling (i)ignore, (n)o_passdown, (p)assdown.", 0)
 FIELD(SEGS, seg, NUM, "Zero", list, 4, thinzero, zero, "For thin pools, if zeroing is enabled.", 0)
 FIELD(SEGS, seg, NUM, "TransId", list, 4, transactionid, transaction_id, "For thin pools, the transaction id.", 0)
 FIELD(SEGS, seg, NUM, "Start", list, 5, segstart, seg_start, "Offset within the LV to the start of the segment in current units.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 0855f95..d78ad64 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -277,6 +277,8 @@ GET_LVSEG_NUM_PROPERTY_FN(zero, lvseg->zero_new_blocks)
 #define _zero_set _not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(transaction_id, lvseg->transaction_id)
 #define _transaction_id_set _not_implemented_set
+GET_LVSEG_NUM_PROPERTY_FN(discard, lvseg->discard)
+#define _discard_set _not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(seg_start, lvseg_start(lvseg))
 #define _seg_start_set _not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(seg_start_pe, lvseg->le)
diff --git a/lib/report/report.c b/lib/report/report.c
index 97e75b6..3121db3 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -564,6 +564,36 @@ static int _transactionid_disp(struct dm_report *rh, struct dm_pool *mem,
 	return  dm_report_field_uint64(rh, field, &seg->transaction_id);
 }
 
+static int _discard_disp(struct dm_report *rh, struct dm_pool *mem,
+			 struct dm_report_field *field,
+			 const void *data, void *private)
+{
+	static const struct {
+		const char c[2];
+		unsigned val;
+		thin_discard_t discard;
+	} const arr[] = {
+		{ "p", 0, THIN_DISCARD_PASSDOWN },
+		{ "n", 1, THIN_DISCARD_NO_PASSDOWN },
+		{ "i", 2, THIN_DISCARD_IGNORE },
+		{ "" }
+	};
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+	unsigned i = 0;
+
+	if (seg_is_thin_volume(seg))
+		seg = first_seg(seg->pool_lv);
+
+	if (seg_is_thin_pool(seg)) {
+		while (arr[i].c[0] && seg->discard != arr[i].discard)
+			i++;
+
+		dm_report_field_set_value(field, arr[i].c, &arr[i].val);
+	} else
+		dm_report_field_set_value(field, "", NULL);
+
+	return 1;
+}
 
 static int _originsize_disp(struct dm_report *rh, struct dm_pool *mem,
 			    struct dm_report_field *field,
diff --git a/man/lvs.8.in b/man/lvs.8.in
index 9a4bb4d..f492835 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -80,6 +80,7 @@ convert_lv,
 copy_percent,
 data_lv,
 devices,
+discard,
 lv_attr,
 lv_host,
 lv_kernel_major,


