From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  5 Dec 2014 11:01:12 +0000 (UTC)
Subject: master - config: add report/compact_output lvm.conf setting to enable or isable field compacting
Message-ID: <20141205110112.1DCA86112E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=00d53d5fc172ee396ea835a110126f83202724d5
Commit:        00d53d5fc172ee396ea835a110126f83202724d5
Parent:        5edf6a56c4077edd238bf08bf369e7d82bca4ecf
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Dec 5 11:46:26 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Dec 5 12:00:28 2014 +0100

config: add report/compact_output lvm.conf setting to enable or isable field compacting

$ lvm dumpconfig report/compact_output
compact_output=0

$ lvs vg
  LV    VG   Attr       LSize Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lvol0 vg   owi-a-s--- 4.00m
  lvol1 vg   -wi-a----- 4.00m
  lvol2 vg   swi-a-s--- 4.00m      lvol0  0.00

$ lvm dumpconfig report/compact_output
compact_output=1

$ lvs vg
  LV    VG   Attr       LSize Origin Data%
  lvol0 vg   owi-a-s--- 4.00m
  lvol1 vg   -wi-a----- 4.00m
  lvol2 vg   swi-a-s--- 4.00m lvol0  0.00
---
 WHATS_NEW                    |    1 +
 conf/example.conf.in         |    4 ++++
 lib/config/config_settings.h |    1 +
 lib/config/defaults.h        |    1 +
 tools/reporter.c             |    5 +++++
 5 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 54e46d9..11fa6e1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.115 -
 =====================================
+  Add report/compact_output to lvm.conf to enable/disable compact report output.
   Still restrict mirror region size to power of 2 when VG extent size is not.
 
 Version 2.02.114 - 28th November 2014
diff --git a/conf/example.conf.in b/conf/example.conf.in
index d1a1397..5ed2b92 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1104,6 +1104,10 @@ activation {
 # Report settings.
 #
 # report {
+    # If compact output is enabled, fields which don't have value
+    # set for any of the rows reported are skipped on output.
+    # compact_output=0
+
     # Align columns on report output.
     # aligned=1
 
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index e944b81..6de948e 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -234,6 +234,7 @@ cfg(disk_area_start_sector_CFG, "start_sector", disk_area_CFG_SUBSECTION, CFG_AD
 cfg(disk_area_size_CFG, "size", disk_area_CFG_SUBSECTION, CFG_ADVANCED | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL)
 cfg(disk_area_id_CFG, "id", disk_area_CFG_SUBSECTION, CFG_ADVANCED | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
 
+cfg(report_compact_output_CFG, "compact_output", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_COMPACT_OUTPUT, vsn(2, 2, 115), NULL)
 cfg(report_aligned_CFG, "aligned", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_ALIGNED, vsn(1, 0, 0), NULL)
 cfg(report_buffered_CFG, "buffered", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_BUFFERED, vsn(1, 0, 0), NULL)
 cfg(report_headings_CFG, "headings", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_HEADINGS, vsn(1, 0, 0), NULL)
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index cbc95fb..e15926c 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -176,6 +176,7 @@
 
 #define DEFAULT_MAX_ERROR_COUNT	NO_DEV_ERROR_COUNT_LIMIT
 
+#define DEFAULT_REP_COMPACT_OUTPUT 0
 #define DEFAULT_REP_ALIGNED 1
 #define DEFAULT_REP_BUFFERED 1
 #define DEFAULT_REP_COLUMNS_AS_ROWS 0
diff --git a/tools/reporter.c b/tools/reporter.c
index eec9948..b312568 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -410,6 +410,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 
 	args_are_pvs = (report_type == PVS ||
 			report_type == LABEL ||
+
 			report_type == PVSEGS) ? 1 : 0;
 
 	/*
@@ -614,6 +615,10 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		break;
 	}
 
+	if (find_config_tree_bool(cmd, report_compact_output_CFG, NULL) &&
+	    !dm_report_compact_fields(report_handle))
+		log_error("Failed to compact report output.");
+
 	dm_report_output(report_handle);
 
 	dm_report_free(report_handle);


