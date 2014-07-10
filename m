From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 10 Jul 2014 13:25:36 +0000 (UTC)
Subject: master - report: report LV's zero field as binary field
Message-ID: <20140710132536.E1D1C60ED8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e2448bb0dcfa63b2a8fae24b989393a821917120
Commit:        e2448bb0dcfa63b2a8fae24b989393a821917120
Parent:        e31ec38d8e657d5f6d6efca6eade083357675276
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 10 15:23:56 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 10 15:25:01 2014 +0200

report: report LV's zero field as binary field

Like other binary fields we already have:

$ lvs -o name,zero vg/lvx vg/pool vg/pool1
  LV    Zero
  lvx   unknown
  pool
  pool1    zero

$ lvs -o name,zero vg/lvx vg/pool vg/pool1 --binary
  LV    Zero
  lvx     -1
  pool     0
  pool1    1
---
 lib/report/columns.h |    2 +-
 lib/report/report.c  |    4 ++--
 lib/report/values.h  |    1 +
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 3d3d76e..dd5aa9e 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -158,7 +158,7 @@ FIELD(SEGS, seg, SIZ, "Chunk", list, 5, chunksize, chunksize, "For snapshots, th
 FIELD(SEGS, seg, SIZ, "Chunk", list, 5, chunksize, chunk_size, "For snapshots, the unit of data used when tracking changes.", 0)
 FIELD(SEGS, seg, NUM, "#Thins", list, 4, thincount, thin_count, "For thin pools, the number of thin volumes in this pool.", 0)
 FIELD(SEGS, seg, STR, "Discards", list, 8, discards, discards, "For thin pools, how discards are handled.", 0)
-FIELD(SEGS, seg, NUM, "Zero", list, 4, thinzero, zero, "For thin pools, if zeroing is enabled.", 0)
+FIELD(SEGS, seg, BIN, "Zero", list, 4, thinzero, zero, "For thin pools, if zeroing is enabled.", 0)
 FIELD(SEGS, seg, NUM, "TransId", list, 4, transactionid, transaction_id, "For thin pools, the transaction id.", 0)
 FIELD(SEGS, seg, NUM, "ThId", list, 4, thinid, thin_id, "For thin volume, the thin device id.", 0)
 FIELD(SEGS, seg, NUM, "Start", list, 5, segstart, seg_start, "Offset within the LV to the start of the segment in current units.", 0)
diff --git a/lib/report/report.c b/lib/report/report.c
index 63b1647..5931021 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1594,9 +1594,9 @@ static int _thinzero_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 
 	if (seg_is_thin_pool(seg))
-		return _uint32_disp(rh, mem, field, &seg->zero_new_blocks, private);
+		return _binary_disp(rh, mem, field, seg->zero_new_blocks, FIRST_NAME(zero_y), private);
 
-	return _field_set_value(field, "", &RESERVED(number_undef_64));
+	return _binary_undef_disp(rh, mem, field, private);
 }
 
 static int _lvhealthstatus_disp(struct dm_report *rh, struct dm_pool *mem,
diff --git a/lib/report/values.h b/lib/report/values.h
index d8de665..7425bc6 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -75,6 +75,7 @@ FIELD_RESERVED_BINARY_VALUE(lv_live_table, lv_live_table, "", "live table presen
 FIELD_RESERVED_BINARY_VALUE(lv_inactive_table, lv_inactive_table, "", "inactive table present", "inactive table", "inactive")
 FIELD_RESERVED_BINARY_VALUE(lv_device_open, lv_device_open, "", "open")
 FIELD_RESERVED_BINARY_VALUE(lv_skip_activation, lv_skip_activation, "", "skip activation", "skip")
+FIELD_RESERVED_BINARY_VALUE(zero, zero, "", "zero")
 FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_rw, "", FIRST_NAME(lv_permissions_rw), "writeable", "rw", "read-write")
 FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r, "", FIRST_NAME(lv_permissions_r), "", "read-only", "r", "ro")
 FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r_override, "", FIRST_NAME(lv_permissions_r_override), "", "read-only-override", "ro-override", "r-override", "R")


