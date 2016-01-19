From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 19 Jan 2016 13:30:43 +0000 (UTC)
Subject: master - report: make devices, metadata_devices, seg_pe_ranges and seg_metadata_le_ranges fields consistent
Message-ID: <20160119133043.5BEFD602DD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fccb1bb276d37825d5147936c80e761e1334032b
Commit:        fccb1bb276d37825d5147936c80e761e1334032b
Parent:        b160b73800e867a791f196af7b1114243cfd1a65
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jan 19 12:26:01 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jan 19 14:30:20 2016 +0100

report: make devices, metadata_devices, seg_pe_ranges and seg_metadata_le_ranges fields consistent

There are two basic groups of fields for LV segment device reporting:
  - related to LV segment's devices: devices and seg_pe_ranges
  - related to LV segment's metadata devices: metadata_devices and seg_metadata_le_ranges

The devices and metadata_devices report devices in this format:
    "device_name(extent_start)"

The seg_pe_ranges and seg_metadata_le_ranges report devices in
this format:
    "device_name:extent_start-extent_end"

This patch reverts partly what commit 7f74a995029caa41ee3cf9aec0bd024a34bfd89a
(v 2.02.140) introduced in this area - it added [] for
hidden devices to mark them for all four fields mentioned above.

We won't be marking hidden devices in devices and metadata_devices
fields.

The seg_metadata_le_ranges field will have hidden devices marked -
it's new enough that we don't need to care about compatibility much
yet.

The seg_pe_ranges is old enough that we shouldn't be changing this
one - so we're reverting to not marking hidden devices here.
Instead, there's going to be a new field "seg_le_ranges" which
is going to replace the seg_pe_ranges and it will mark hidden devices -
this is going to be introduced in a patch later.

So in the end we'll end up with:

   (LV segment's devices)
   devices field with "device_name(extent_start)" format, not marking hidden devices
   seg_pe_ranges field with "device_name:extent_start-extent_end" format, not marking hidden devices (deprecated, new seg_le_ranges should be used instead for standardized format)
   seg_le_ranges field with "device_name:extent_start-extent_end" format, marking hidden devices

   (LV segment's metadata devices)
   metadata_devices field with "device_name:extent_start-extent_end" format, not marking hidden devices
   seg_metadata_le_ranges field with "device_name:extent_start-extent_end" format, marking hidden devices

Also, both seg_le_ranges and seg_metadata_le_ranges will honour the
report/list_item_separator setting which can be used to configure
the delimiter used for list items.

So, to sum it up, we will recommend using the new seg_le_ranges and
seg_metadata_le_ranges fields because they display devices with
standard extent range format, they can mark hidden devices and they
honour the report/list_item_separator setting.

We'll be keeping devices,seg_pe_ranges and metadata_devices fields
for compatibility.
---
 WHATS_NEW                   |    2 ++
 lib/metadata/lv.c           |    8 ++++----
 lib/report/report.c         |    2 +-
 test/shell/report-hidden.sh |    6 ------
 4 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5a16d16..6f3e5ea 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.141 - 
 ====================================
+  Honour report/list_item_separator for seg_metadata_le_ranges report field.
+  Don't mark hidden devs in -o devices,metadata_devices,seg_pe_ranges (2.02.140).
   Change LV sizes in seg_pe_ranges report field to match underlying devices.
   Add kernel_cache_settings report field for cache LV settings used in kernel.
 
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 70a22b3..8178530 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -130,7 +130,7 @@ bad:
 
 struct dm_list *lvseg_devices(struct dm_pool *mem, const struct lv_segment *seg)
 {
-	return _format_pvsegs(mem, seg, 0, 0, seg->lv->vg->cmd->report_mark_hidden_devices);
+	return _format_pvsegs(mem, seg, 0, 0, 0);
 }
 
 char *lvseg_devices_str(struct dm_pool *mem, const struct lv_segment *seg)
@@ -145,7 +145,7 @@ char *lvseg_devices_str(struct dm_pool *mem, const struct lv_segment *seg)
 
 struct dm_list *lvseg_metadata_devices(struct dm_pool *mem, const struct lv_segment *seg)
 {
-	return _format_pvsegs(mem, seg, 0, 1, seg->lv->vg->cmd->report_mark_hidden_devices);
+	return _format_pvsegs(mem, seg, 0, 1, 0);
 }
 
 char *lvseg_metadata_devices_str(struct dm_pool *mem, const struct lv_segment *seg)
@@ -160,7 +160,7 @@ char *lvseg_metadata_devices_str(struct dm_pool *mem, const struct lv_segment *s
 
 struct dm_list *lvseg_seg_pe_ranges(struct dm_pool *mem, const struct lv_segment *seg)
 {
-	return _format_pvsegs(mem, seg, 1, 0, seg->lv->vg->cmd->report_mark_hidden_devices);
+	return _format_pvsegs(mem, seg, 1, 0, 0);
 }
 
 char *lvseg_seg_pe_ranges_str(struct dm_pool *mem, const struct lv_segment *seg)
@@ -185,7 +185,7 @@ char *lvseg_seg_metadata_le_ranges_str(struct dm_pool *mem, const struct lv_segm
 	if (!(list = lvseg_seg_metadata_le_ranges(mem, seg)))
 		return_NULL;
 
-	return str_list_to_str(mem, list, " ");
+	return str_list_to_str(mem, list, seg->lv->vg->cmd->report_list_item_separator);
 }
 
 char *lvseg_tags_dup(const struct lv_segment *seg)
diff --git a/lib/report/report.c b/lib/report/report.c
index 02d8b22..788d806 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1342,7 +1342,7 @@ static int _metadataleranges_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (!(list = lvseg_seg_metadata_le_ranges(mem, seg)))
 		return_0;
 
-	return _field_set_string_list(rh, field, list, private, 0, " ");
+	return _field_set_string_list(rh, field, list, private, 0, NULL);
 }
 
 static int _tags_disp(struct dm_report *rh, struct dm_pool *mem,
diff --git a/test/shell/report-hidden.sh b/test/shell/report-hidden.sh
index ff33df5..7f77282 100644
--- a/test/shell/report-hidden.sh
+++ b/test/shell/report-hidden.sh
@@ -24,16 +24,10 @@ aux lvmconf "report/mark_hidden_devices = 0"
 lvs --noheadings -a -o name $vg > out
 grep "^${lv1}_mimage_0" out
 not grep "^\[${lv1}_mimage_0\]" out
-lvs --noheadings -a -o devices $vg/$lv1 > out
-grep "^${lv1}_mimage_0" out
-not grep "^\[${lv1}_mimage_0\]" out
 
 aux lvmconf "report/mark_hidden_devices = 1"
 lvs --noheadings -a -o name $vg > out
 grep "^\[${lv1}_mimage_0\]" out
 not grep "^${lv1}_mimage_0" out
-lvs --noheadings -a -o devices $vg/$lv1 > out
-grep "^\[${lv1}_mimage_0\]" out
-not grep "^${lv1}_mimage_0" out
 
 vgremove -ff $vg


