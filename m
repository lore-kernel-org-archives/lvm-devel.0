From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 31 May 2016 06:46:45 +0000 (UTC)
Subject: master - report: fix lvm devtypes internal error if -S is used with field name from pvs/vgs/lvs
Message-ID: <20160531064645.671376055E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e4ec6bcdd38505c6c229d578aa3eca006441b035
Commit:        e4ec6bcdd38505c6c229d578aa3eca006441b035
Parent:        815f1ee26d5ee5c64493f83a78f8c074fc8c82d8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon May 30 16:37:05 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon May 30 16:46:18 2016 +0200

report: fix lvm devtypes internal error if -S is used with field name from pvs/vgs/lvs

Before this fix, when reporting 'lvm devtypes', the report was
initialized with incorrect reserved values - the ones used for
pvs/vgs/lvs report were used instead of NULL value (because devtypes
doesn't have any reserved values).

For example, trying to (incorrectly) use lv_name for the -S|--select
with lvm devtypes which doesn't have this field at all:

Before this patch (internal error issued):

$ lvm devtypes -S 'lv_name=lvol0'
  Internal error: _check_reserved_values_supported: field-specific reserved value of type 0x0 for field  not supported
  Internal error: dm_report_init_with_selection: trying to register unsupported reserved value type, skipping report selection
  DevType       MaxParts Description
  aoe                 16 ATA over Ethernet
  ataraid             16 ATA Raid
  bcache               1 bcache block device cache
  ...

With this patch applied (correct error displayed about
unrecognized selection field):

$ lvm devtypes -S 'lv_name=lvol0'
  Device Types Fields
  -------------------
    devtype_name           - Name of Device Type exactly as it appears in /proc/devices. [string]
    devtype_max_partitions - Maximum number of partitions. (How many device minor numbers get reserved for each device.) [number]
    devtype_description    - Description of Device Type. [string]

  Special Fields
  --------------
    selected               - Set if item passes selection criteria. [number]
    help                   - Show help. [unselectable number]
    ?                      - Show help. [unselectable number]

  Unrecognised selection field: lv_name
  Selection syntax error at 'lv_name=lvol0'.
  Use 'help' for selection to get more help.
---
 WHATS_NEW           |    1 +
 lib/report/report.c |   20 +++++++++++++++-----
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7eac3a7..1bad12a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.155 - 
 ================================
+  Fix lvm devtypes internal error if -S used with field name from pvs/vgs/lvs.
   When reporting Data%,Snap%,Meta%,Cpy%Sync use single ioctl per LV.
   Add lvseg_percent_with_info_and_seg_status() for percent retrieval.
   Enhance internal seg_status handling to understand snapshots better.
diff --git a/lib/report/report.c b/lib/report/report.c
index 56c6f5b..8e08c75 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3689,7 +3689,9 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  int quoted, int columns_as_rows, const char *selection)
 {
 	uint32_t report_flags = 0;
-	int devtypes_report = *report_type & DEVTYPES ? 1 : 0;
+	const struct dm_report_object_type *types;
+	const struct dm_report_field_type *fields;
+	const struct dm_report_reserved_value *reserved_values;
 	void *rh;
 
 	if (aligned)
@@ -3710,11 +3712,19 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 	if (columns_as_rows)
 		report_flags |= DM_REPORT_OUTPUT_COLUMNS_AS_ROWS;
 
-	rh = dm_report_init_with_selection(report_type,
-		devtypes_report ? _devtypes_report_types : _report_types,
-		devtypes_report ? _devtypes_fields : _fields,
+	if (*report_type & DEVTYPES) {
+		types = _devtypes_report_types;
+		fields = _devtypes_fields;
+		reserved_values = NULL;
+	} else {
+		types = _report_types;
+		fields = _fields;
+		reserved_values = _report_reserved_values;
+	}
+
+	rh = dm_report_init_with_selection(report_type, types, fields,
 		format, separator, report_flags, keys,
-		selection, _report_reserved_values, cmd);
+		selection, reserved_values, cmd);
 
 	if (rh && field_prefixes)
 		dm_report_set_output_field_name_prefix(rh, "lvm2_");


