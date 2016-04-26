From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 26 Apr 2016 21:31:32 +0000 (UTC)
Subject: master - thin: zero and transaction_id also with thin volumes
Message-ID: <20160426213132.45A7660509@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=84a5b19539483e5f06b4a1405bb76e46ce9226b2
Commit:        84a5b19539483e5f06b4a1405bb76e46ce9226b2
Parent:        8b5967e1e3313e8f9caa8065e170dd35ada8e57a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 23 21:08:46 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 26 23:24:51 2016 +0200

thin: zero and transaction_id also with thin volumes

Show trasaction_id when thin volume was created.
Also show zeroing state of thin-pool with thin volume (so user
doesn't need to lookup thin-pool).
---
 WHATS_NEW            |    1 +
 lib/report/columns.h |    4 ++--
 lib/report/report.c  |    5 ++++-
 3 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4b33913..b6d9fd2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.152 - 
 ==================================
+  Show creation transaction_id and zeroing state of pool with thin volume.
   Stop checking for dm_cache_mq policy with cache target 1.9 (alias to smq).
   Check first /sys/module/dm_* dir existance before using modprobe.
   Remove mpath from 10-dm.rules, superseded by 11-dm-mpath.rules (mpath>=0.6.0).
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 7f5e11d..b31b3f1 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -191,8 +191,8 @@ FIELD(SEGS, seg, SIZ, "Chunk", list, 0, chunksize, chunk_size, "For snapshots, t
 FIELD(SEGS, seg, NUM, "#Thins", list, 0, thincount, thin_count, "For thin pools, the number of thin volumes in this pool.", 0)
 FIELD(SEGS, seg, STR, "Discards", list, 0, discards, discards, "For thin pools, how discards are handled.", 0)
 FIELD(SEGS, seg, STR, "CacheMode", list, 0, cachemode, cache_mode, "For cache pools, how writes are cached.", 0)
-FIELD(SEGS, seg, BIN, "Zero", list, 0, thinzero, zero, "For thin pools, if zeroing is enabled.", 0)
-FIELD(SEGS, seg, NUM, "TransId", list, 0, transactionid, transaction_id, "For thin pools, the transaction id.", 0)
+FIELD(SEGS, seg, BIN, "Zero", list, 0, thinzero, zero, "For thin pools and volumes, if zeroing is enabled.", 0)
+FIELD(SEGS, seg, NUM, "TransId", list, 0, transactionid, transaction_id, "For thin pools, the transaction id and creation transaction id for thins.", 0)
 FIELD(SEGS, seg, NUM, "ThId", list, 0, thinid, thin_id, "For thin volume, the thin device id.", 0)
 FIELD(SEGS, seg, SIZ, "Start", list, 0, segstart, seg_start, "Offset within the LV to the start of the segment in current units.", 0)
 FIELD(SEGS, seg, NUM, "Start", list, 0, segstartpe, seg_start_pe, "Offset within the LV to the start of the segment in physical extents.", 0)
diff --git a/lib/report/report.c b/lib/report/report.c
index abf6a9e..016d41d 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2446,7 +2446,7 @@ static int _transactionid_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 
-	if (seg_is_thin_pool(seg))
+	if (seg_is_thin_pool(seg) || seg_is_thin_volume(seg))
 		return dm_report_field_uint64(rh, field, &seg->transaction_id);
 
 	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
@@ -3478,6 +3478,9 @@ static int _thinzero_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 
+	if (seg_is_thin_volume(seg))
+		seg = first_seg(seg->pool_lv);
+
 	if (seg_is_thin_pool(seg))
 		return _binary_disp(rh, mem, field, seg->zero_new_blocks, GET_FIRST_RESERVED_NAME(zero_y), private);
 


