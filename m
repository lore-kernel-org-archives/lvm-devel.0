From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 11 Feb 2015 13:03:03 +0000 (UTC)
Subject: master - report: define ba_start, vg_free and seg_start fields as DM_REPORT_FIELD_TYPE_SIZE instead of DM_REPORT_FIELD_TYPE_NUM
Message-ID: <20150211130303.BC66760517@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=263f7831df111a431a064d30b639e4769445f841
Commit:        263f7831df111a431a064d30b639e4769445f841
Parent:        b88b75f55f54bf07780d389a750bc899f7bed8a9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Feb 11 13:57:18 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Feb 11 13:57:18 2015 +0100

report: define ba_start, vg_free and seg_start fields as DM_REPORT_FIELD_TYPE_SIZE instead of DM_REPORT_FIELD_TYPE_NUM

This makes a difference when using selection criteria based on
these fields - if those fields are defined as DM_REPORT_FIELD_TYPE_SIZE
(in contrast to DM_REPORT_FIELD_TYPE_NUMBER), units are also
recognize in selection clause.

For example:
$ lvs -o+seg_start vg1/lv2
  LV   VG   Attr       LSize  Start
  lv2  vg1  -wi-a----- 12.00m    0
  lv2  vg1  -wi-a----- 12.00m 8.00m

Before this patch:
$ lvs -o+seg_start --select 'seg_start=8m'
  Found size unit specifier but numeric value expected for selection field seg_start.
  Selection syntax error at 'seg_start=8m'.
  Use 'help' for selection to get more help.

With this patch applied:
$lvs -o+seg_start --select 'seg_start=8m'
  LV   VG   Attr       LSize  Start
  lv2  vg1  -wi-a----- 12.00m 8.00m

(the same applies for ba_start and vg_free fields)
---
 WHATS_NEW            |    1 +
 lib/report/columns.h |    6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 314cfd8..99e0c08 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.117 - 
 ====================================
+  Fix selection to recognize units for ba_start, vg_free and seg_start fields.
   Add support for -S/--select to vgexport and vgimport.
   Add support for -S/--select to vgdisplay, lvdisplay and pvdisplay without -C.
   Add support for -S/--select to vgremove and lvremove.
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 449536b..f1d27ef 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -124,7 +124,7 @@ FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, pv_pe_alloc_count, "Tota
 FIELD(PVS, pv, STR_LIST, "PV Tags", tags, 7, tags, pv_tags, "Tags, if any.", 0)
 FIELD(PVS, pv, NUM, "#PMda", id, 5, pvmdas, pv_mda_count, "Number of metadata areas on this device.", 0)
 FIELD(PVS, pv, NUM, "#PMdaUse", id, 8, pvmdasused, pv_mda_used_count, "Number of metadata areas in use on this device.", 0)
-FIELD(PVS, pv, NUM, "BA start", ba_start, 8, size64, pv_ba_start, "Offset to the start of PV Bootloader Area on the underlying device in current units.", 0)
+FIELD(PVS, pv, SIZ, "BA start", ba_start, 8, size64, pv_ba_start, "Offset to the start of PV Bootloader Area on the underlying device in current units.", 0)
 FIELD(PVS, pv, SIZ, "BA size", ba_size, 7, size64, pv_ba_size, "Size of PV Bootloader Area in current units.", 0)
 
 FIELD(VGS, vg, STR, "Fmt", cmd, 3, vgfmt, vg_fmt, "Type of metadata.", 0)
@@ -138,7 +138,7 @@ FIELD(VGS, vg, BIN, "Partial", cmd, 10, vgpartial, vg_partial, "Set if VG is par
 FIELD(VGS, vg, STR, "AllocPol", cmd, 10, vgallocationpolicy, vg_allocation_policy, "VG allocation policy.", 0)
 FIELD(VGS, vg, BIN, "Clustered", cmd, 10, vgclustered, vg_clustered, "Set if VG is clustered.", 0)
 FIELD(VGS, vg, SIZ, "VSize", cmd, 5, vgsize, vg_size, "Total size of VG in current units.", 0)
-FIELD(VGS, vg, NUM, "VFree", cmd, 5, vgfree, vg_free, "Total amount of free space in current units.", 0)
+FIELD(VGS, vg, SIZ, "VFree", cmd, 5, vgfree, vg_free, "Total amount of free space in current units.", 0)
 FIELD(VGS, vg, STR, "SYS ID", system_id, 6, string, vg_sysid, "System ID indicating when and where it was created.", 0)
 FIELD(VGS, vg, SIZ, "Ext", extent_size, 3, size32, vg_extent_size, "Size of Physical Extents in current units.", 0)
 FIELD(VGS, vg, NUM, "#Ext", extent_count, 4, uint32, vg_extent_count, "Total number of Physical Extents.", 0)
@@ -171,7 +171,7 @@ FIELD(SEGS, seg, STR, "Cachemode", list, 9, cachemode, cachemode, "For cache poo
 FIELD(SEGS, seg, BIN, "Zero", list, 4, thinzero, zero, "For thin pools, if zeroing is enabled.", 0)
 FIELD(SEGS, seg, NUM, "TransId", list, 4, transactionid, transaction_id, "For thin pools, the transaction id.", 0)
 FIELD(SEGS, seg, NUM, "ThId", list, 4, thinid, thin_id, "For thin volume, the thin device id.", 0)
-FIELD(SEGS, seg, NUM, "Start", list, 5, segstart, seg_start, "Offset within the LV to the start of the segment in current units.", 0)
+FIELD(SEGS, seg, SIZ, "Start", list, 5, segstart, seg_start, "Offset within the LV to the start of the segment in current units.", 0)
 FIELD(SEGS, seg, NUM, "Start", list, 5, segstartpe, seg_start_pe, "Offset within the LV to the start of the segment in physical extents.", 0)
 FIELD(SEGS, seg, SIZ, "SSize", list, 5, segsize, seg_size, "Size of segment in current units.", 0)
 FIELD(SEGS, seg, SIZ, "SSize", list, 5, segsizepe, seg_size_pe, "Size of segment in physical extents.", 0)


