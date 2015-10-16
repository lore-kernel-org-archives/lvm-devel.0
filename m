From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 16 Oct 2015 15:07:27 +0000 (UTC)
Subject: master - config: add report/compact_output_cols to control which columns to compact in report output
Message-ID: <20151016150727.2C8BB60FDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c3bfe07f2ad393963af5b7138bccc622e6561c8f
Commit:        c3bfe07f2ad393963af5b7138bccc622e6561c8f
Parent:        508f0f5a21af8decf32944e01ecf17c0059a9c9f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Oct 16 16:25:51 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 16 17:05:54 2015 +0200

config: add report/compact_output_cols to control which columns to compact in report output

The new report/compact_output_cols setting has exactly the same effect
as report/compact_output setting. The difference is that with the new
setting it's possible to define which cols should be compacted exactly
in contrast to all cols in case of report/compact_output.

In case both compact_output and compact_output_cols is enabled/set,
the compact_output prevails.

For example:

$ lvmconfig --type full report/compact_output report/compact_output_cols
compact_output=0
compact_output_cols=""

$ lvs vg
  LV    VG   Attr       LSize Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lvol0 vg   -wi-a----- 4.00m

---

$ lvmconfig --type full report/compact_output report/compact_output_cols
compact_output=0
compact_output_cols="data_percent,metadata_percent,pool_lv,move_pv,origin"

$ lvs vg
  LV    VG   Attr       LSize Log Cpy%Sync Convert
  lvol0 vg   -wi-a----- 4.00m

---

$ lvmconfig --type full report/compact_output report/compact_output_cols
compact_output=1
compact_output_cols="data_percent,metadata_percent,pool_lv,move_pv,origin"

$ lvs vg
  LV    VG   Attr       LSize
  lvol0 vg   -wi-a----- 4.00m
---
 WHATS_NEW                    |    1 +
 conf/example.conf.in         |    9 +++++++++
 lib/config/config_settings.h |    7 +++++++
 lib/config/defaults.h        |    2 ++
 libdm/libdevmapper.h         |    2 +-
 tools/reporter.c             |   11 ++++++++---
 6 files changed, 28 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c089228..f973f11 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Add report/compact_output_cols to lvm.conf to define report cols to compact.
   Do not change logging in lvm2 library when it's already set.
   Check for enough space in thin-pool in command before creating new thin.
   Make libblkid detect all copies of the same signature if use_blkid_wiping=1.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index c0afcb7..e1afed6 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1501,6 +1501,15 @@ activation {
 	# This configuration option has an automatic default value.
 	# compact_output = 0
 
+	# Configuration option report/compact_output_cols.
+	# Do not print empty values for given report fields.
+	# The same as compact_output setting, but the compaction is not done
+	# globally for all fields in report but only for given fields. If both
+	# compact_output and compact_output_fields is used at the same time,
+	# the compact_output setting prevails.
+	# This configuration option has an automatic default value.
+	# compact_output_cols = ""
+
 	# Configuration option report/aligned.
 	# Align columns in report output.
 	# This configuration option has an automatic default value.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 9cc444f..cefc579 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1421,6 +1421,13 @@ cfg(report_compact_output_CFG, "compact_output", report_CFG_SECTION, CFG_PROFILA
 	"skipped and not printed. Compact output is applicable only if\n"
 	"report/buffered is enabled.\n")
 
+cfg(report_compact_output_cols_CFG, "compact_output_cols", report_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_COMPACT_OUTPUT_COLS, vsn(2, 2, 133), NULL, 0, NULL,
+	"Do not print empty values for given report fields.\n"
+	"The same as compact_output setting, but the compaction is not done\n"
+	"globally for all fields in report but only for given fields. If both\n"
+	"compact_output and compact_output_fields is used at the same time,\n"
+	"the compact_output setting prevails.\n")
+
 cfg(report_aligned_CFG, "aligned", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_REP_ALIGNED, vsn(1, 0, 0), NULL, 0, NULL,
 	"Align columns in report output.\n")
 
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index cd5d121..8ab1fde 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -201,6 +201,8 @@
 #define DEFAULT_REP_LIST_ITEM_SEPARATOR ","
 #define DEFAULT_TIME_FORMAT "%Y-%m-%d %T %z"
 
+#define DEFAULT_COMPACT_OUTPUT_COLS ""
+
 #define DEFAULT_LVS_COLS "lv_name,vg_name,lv_attr,lv_size,pool_lv,origin,data_percent,metadata_percent,move_pv,mirror_log,copy_percent,convert_lv"
 #define DEFAULT_VGS_COLS "vg_name,pv_count,lv_count,snap_count,vg_attr,vg_size,vg_free"
 #define DEFAULT_PVS_COLS "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free"
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 1a2036b..fcbf7cf 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -2552,7 +2552,7 @@ int dm_report_compact_fields(struct dm_report *rh);
  * The same as dm_report_compact_fields, but for selected fields only.
  * The "fields" arg is comma separated list of field names (the same format
  * as used for "output_fields" arg in dm_report_init fn).
-*/
+ */
 int dm_report_compact_given_fields(struct dm_report *rh, const char *fields);
 
 /*
diff --git a/tools/reporter.c b/tools/reporter.c
index 8f7a272..6c93739 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -618,6 +618,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	unsigned args_are_pvs;
 	int lv_info_needed, lv_segment_status_needed;
 	int lock_global = 0;
+	const char *fields_to_compact;
 
 	aligned = find_config_tree_bool(cmd, report_aligned_CFG, NULL);
 	buffered = find_config_tree_bool(cmd, report_buffered_CFG, NULL);
@@ -817,9 +818,13 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		break;
 	}
 
-	if (find_config_tree_bool(cmd, report_compact_output_CFG, NULL) &&
-	    !dm_report_compact_fields(report_handle))
-		log_error("Failed to compact report output.");
+	if (find_config_tree_bool(cmd, report_compact_output_CFG, NULL)) {
+		if (!dm_report_compact_fields(report_handle))
+			log_error("Failed to compact report output.");
+	} else if ((fields_to_compact = find_config_tree_str_allow_empty(cmd, report_compact_output_cols_CFG, NULL))) {
+		if (!dm_report_compact_given_fields(report_handle, fields_to_compact))
+			log_error("Failed to compact given columns in report output.");
+	}
 
 	dm_report_output(report_handle);
 


