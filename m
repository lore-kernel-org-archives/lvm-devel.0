From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Nov 2013 11:39:34 +0000 (UTC)
Subject: master - thin: report thin device id
Message-ID: <20131115113934.F12306135C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=37b7c6707952b0cca2c583f2a48f997c94576a70
Commit:        37b7c6707952b0cca2c583f2a48f997c94576a70
Parent:        6ca832ceafe4ca599e059464faf2ef5760a29b23
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 11 10:05:45 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 15 12:38:37 2013 +0100

thin: report thin device id

Support   lvs -o+thin_id  to report thin device id.
This device_id is connection between kernel and lvm2 user space thin
metadata.
---
 WHATS_NEW                   |    1 +
 lib/display/display.c       |    1 +
 lib/report/columns.h        |    1 +
 lib/report/properties.c     |    2 ++
 lib/report/report.c         |   12 ++++++++++++
 test/shell/lvcreate-thin.sh |    1 +
 6 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fb3b21a..0a4909a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Add reporting of thin_id device id for thin volumes.
   Fix reporting of empty numerical values.
   Simplify reporting code.
 
diff --git a/lib/display/display.c b/lib/display/display.c
index d3b4d6e..be56f12 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -600,6 +600,7 @@ int lvdisplay_full(struct cmd_context *cmd,
 	if (lv_is_thin_volume(lv)) {
 		seg = first_seg(lv);
 		log_print("LV Pool name           %s", seg->pool_lv->name);
+		log_print("LV Thin device ID      %u", seg->device_id);
 		if (seg->origin)
 			log_print("LV Thin origin name    %s",
 				  seg->origin->name);
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 6df9771..88a0266 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -122,6 +122,7 @@ FIELD(SEGS, seg, NUM, "#Thins", list, 4, thincount, thin_count, "For thin pools,
 FIELD(SEGS, seg, STR, "Discards", list, 8, discards, discards, "For thin pools, how discards are handled.", 0)
 FIELD(SEGS, seg, NUM, "Zero", list, 4, thinzero, zero, "For thin pools, if zeroing is enabled.", 0)
 FIELD(SEGS, seg, NUM, "TransId", list, 4, transactionid, transaction_id, "For thin pools, the transaction id.", 0)
+FIELD(SEGS, seg, NUM, "ThId", list, 4, thinid, thin_id, "For thin volume, the thin device id.", 0)
 FIELD(SEGS, seg, NUM, "Start", list, 5, segstart, seg_start, "Offset within the LV to the start of the segment in current units.", 0)
 FIELD(SEGS, seg, NUM, "Start", list, 5, segstartpe, seg_start_pe, "Offset within the LV to the start of the segment in physical extents.", 0)
 FIELD(SEGS, seg, NUM, "SSize", list, 5, segsize, seg_size, "Size of segment in current units.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 56200f0..8c48de1 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -307,6 +307,8 @@ GET_LVSEG_NUM_PROPERTY_FN(zero, lvseg->zero_new_blocks)
 #define _zero_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(transaction_id, lvseg->transaction_id)
 #define _transaction_id_set prop_not_implemented_set
+GET_LVSEG_NUM_PROPERTY_FN(thin_id, lvseg->device_id)
+#define _thin_id_set prop_not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(discards, lvseg_discards_dup(lvseg->lv->vg->vgmem, lvseg))
 #define _discards_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(seg_start, (SECTOR_SIZE * lvseg_start(lvseg)))
diff --git a/lib/report/report.c b/lib/report/report.c
index 1565aec..c780ca4 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -610,6 +610,18 @@ static int _transactionid_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_set_value(field, "", &_minusone64);
 }
 
+static int _thinid_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+
+	if (seg_is_thin_volume(seg))
+		return dm_report_field_uint32(rh, field, &seg->device_id);
+
+	return _field_set_value(field, "", &_minusone64);
+}
+
 static int _discards_disp(struct dm_report *rh, struct dm_pool *mem,
 			  struct dm_report_field *field,
 			  const void *data, void *private)
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 743da3b..d2e3022 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -129,6 +129,7 @@ lvcreate -V2G --type thin --thinpool pool --name $vg/lv12 $vg
 
 check lv_exists $vg lv1 lv2 lv3 lv4 lv5 lv6 lv7 lv8 lv9 lv10 lv11 lv12
 check vg_field $vg lv_count 19
+check lv_field $vg/lv1 thin_id 7
 
 lvremove -ff $vg
 check vg_field $vg lv_count 0


