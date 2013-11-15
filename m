From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Nov 2013 11:39:30 +0000 (UTC)
Subject: master - report: fix dereference of string as uint64_t
Message-ID: <20131115113930.C81E96135C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=36d7c639d14e121e839b2117dcf744097e6ebfde
Commit:        36d7c639d14e121e839b2117dcf744097e6ebfde
Parent:        9eb81b1bf74411bba6cc950a4ebe0a44856c0e74
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 23 10:18:10 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 15 11:05:02 2013 +0100

report: fix dereference of string as uint64_t

Fix buggy usage of "" (empty string) as a numerical string
value used for sorting.

On intel 64b platform this was typically resolve
as 0xffffff0000000000 - which is already 'close' to
UINT64_MAX which is used for _minusone64.

On other platforms it might have been giving
different numbers depends on aligment of strings.

Use proper &_minusone64 for sorting value when the reported
value is NUM.

Note: each numerical value needs to be thought about if it needs
default value &_zero64 or &_minusone64 since for cases, were
value of zero is valid, sorting should not be mixing entries
together.
---
 WHATS_NEW           |    1 +
 lib/report/report.c |   84 ++++++++++++++++++--------------------------------
 2 files changed, 31 insertions(+), 54 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b190ca4..fb3b21a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Fix reporting of empty numerical values.
   Simplify reporting code.
 
 Version 2.02.104 - 13th November 2013
diff --git a/lib/report/report.c b/lib/report/report.c
index 697d642..5caebb2 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -591,13 +591,10 @@ static int _thinzero_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 
-	/* Suppress thin count if not thin pool */
-	if (!seg_is_thin_pool(seg)) {
-		dm_report_field_set_value(field, "", NULL);
-		return 1;
-	}
+	if (seg_is_thin_pool(seg))
+		return _uint32_disp(rh, mem, field, &seg->zero_new_blocks, private);
 
-	return _uint32_disp(rh, mem, field, &seg->zero_new_blocks, private);
+	return _field_set_value(field, "", &_minusone64);
 }
 
 static int _transactionid_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -606,13 +603,10 @@ static int _transactionid_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 
-	/* Suppress thin count if not thin pool */
-	if (!seg_is_thin_pool(seg)) {
-		dm_report_field_set_value(field, "", NULL);
-		return 1;
-	}
+	if (seg_is_thin_pool(seg))
+		return dm_report_field_uint64(rh, field, &seg->transaction_id);
 
-	return  dm_report_field_uint64(rh, field, &seg->transaction_id);
+	return _field_set_value(field, "", &_minusone64);
 }
 
 static int _discards_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -980,13 +974,10 @@ static int _raidmismatchcount_disp(struct dm_report *rh __attribute__((unused)),
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	uint64_t mismatch_count;
 
-	if (!(lv->status & RAID) ||
-	    !lv_raid_mismatch_count(lv, &mismatch_count)) {
-		dm_report_field_set_value(field, "", NULL);
-		return 1;
-	}
+	if (lv_is_raid(lv) && lv_raid_mismatch_count(lv, &mismatch_count))
+		return dm_report_field_uint64(rh, field, &mismatch_count);
 
-	return dm_report_field_uint64(rh, field, &mismatch_count);
+	return _field_set_value(field, "", &_minusone64);
 }
 
 static int _raidwritebehind_disp(struct dm_report *rh __attribute__((unused)),
@@ -997,12 +988,10 @@ static int _raidwritebehind_disp(struct dm_report *rh __attribute__((unused)),
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 
-	if (!lv_is_raid_type(lv) || !first_seg(lv)->writebehind) {
-		dm_report_field_set_value(field, "", NULL);
-		return 1;
-	}
+	if (lv_is_raid_type(lv) && first_seg(lv)->writebehind)
+		return dm_report_field_uint32(rh, field, &first_seg(lv)->writebehind);
 
-	return dm_report_field_uint32(rh, field, &first_seg(lv)->writebehind);
+	return _field_set_value(field, "", &_minusone64);
 }
 
 static int _raidminrecoveryrate_disp(struct dm_report *rh __attribute__((unused)),
@@ -1013,13 +1002,11 @@ static int _raidminrecoveryrate_disp(struct dm_report *rh __attribute__((unused)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 
-	if (!lv_is_raid_type(lv) || !first_seg(lv)->min_recovery_rate) {
-		dm_report_field_set_value(field, "", NULL);
-		return 1;
-	}
+	if (lv_is_raid_type(lv) && first_seg(lv)->min_recovery_rate)
+		return dm_report_field_uint32(rh, field,
+					      &first_seg(lv)->min_recovery_rate);
 
-	return dm_report_field_uint32(rh, field,
-				      &first_seg(lv)->min_recovery_rate);
+	return _field_set_value(field, "", &_minusone64);
 }
 
 static int _raidmaxrecoveryrate_disp(struct dm_report *rh __attribute__((unused)),
@@ -1030,13 +1017,11 @@ static int _raidmaxrecoveryrate_disp(struct dm_report *rh __attribute__((unused)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 
-	if (!lv_is_raid_type(lv) || !first_seg(lv)->max_recovery_rate) {
-		dm_report_field_set_value(field, "", NULL);
-		return 1;
-	}
+	if (lv_is_raid_type(lv) && first_seg(lv)->max_recovery_rate)
+		return dm_report_field_uint32(rh, field,
+					      &first_seg(lv)->max_recovery_rate);
 
-	return dm_report_field_uint32(rh, field,
-				      &first_seg(lv)->max_recovery_rate);
+	return _field_set_value(field, "", &_minusone64);
 }
 
 /* Called only with lv_is_thin_pool/volume */
@@ -1097,9 +1082,7 @@ static int _datapercent_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (lv_is_thin_pool(lv) || lv_is_thin_volume(lv))
 		return _dtpercent_disp(0, mem, field, data, private);
 
-	dm_report_field_set_value(field, "", NULL);
-
-	return 1;
+	return _field_set_value(field, "", &_minusone64);
 }
 
 static int _metadatapercent_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1111,9 +1094,7 @@ static int _metadatapercent_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (lv_is_thin_pool(lv))
 		return _dtpercent_disp(1, mem, field, data, private);
 
-	dm_report_field_set_value(field, "", NULL);
-
-	return 1;
+	return _field_set_value(field, "", &_minusone64);
 }
 
 static int _lvmetadatasize_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1123,14 +1104,12 @@ static int _lvmetadatasize_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	uint64_t size;
 
-	if (!lv_is_thin_pool(lv)) {
-		dm_report_field_set_value(field, "", NULL);
-		return 1;
+	if (lv_is_thin_pool(lv)) {
+		size = lv_metadata_size(lv);
+		return _size64_disp(rh, mem, field, &size, private);
 	}
 
-	size = lv_metadata_size(lv);
-
-	return _size64_disp(rh, mem, field, &size, private);
+	return _field_set_value(field, "", &_minusone64);
 }
 
 static int _thincount_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1140,15 +1119,12 @@ static int _thincount_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 	uint32_t count;
 
-	/* Suppress thin count if not thin pool */
-	if (!seg_is_thin_pool(seg)) {
-		dm_report_field_set_value(field, "", NULL);
-		return 1;
+	if (seg_is_thin_pool(seg)) {
+		count = dm_list_size(&seg->lv->segs_using_this_lv);
+		return _uint32_disp(rh, mem, field, &count, private);
 	}
 
-	count = dm_list_size(&seg->lv->segs_using_this_lv);
-
-	return _uint32_disp(rh, mem, field, &count, private);
+	return _field_set_value(field, "", &_minusone64);
 }
 
 static int _lvtime_disp(struct dm_report *rh, struct dm_pool *mem,


