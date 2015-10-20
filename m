From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 20 Oct 2015 09:01:15 +0000 (UTC)
Subject: master - conf: clarify compact output settings
Message-ID: <20151020090115.DC84860D8F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a5c4c4efbd18809320f49d7ed60c58883140259c
Commit:        a5c4c4efbd18809320f49d7ed60c58883140259c
Parent:        83d475626a4d9ecaa2084f349cb2cee4f0f3a719
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 20 11:01:09 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Oct 20 11:01:09 2015 +0200

conf: clarify compact output settings

---
 conf/example.conf.in         |   21 ++++++++++++---------
 lib/config/config_settings.h |   21 ++++++++++++---------
 2 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index e96f03f..b8c0407 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1494,19 +1494,22 @@ activation {
 # report {
 
 	# Configuration option report/compact_output.
-	# Do not print empty report fields.
-	# Fields that don't have a value set for any of the rows reported are
-	# skipped and not printed. Compact output is applicable only if
-	# report/buffered is enabled.
+	# Do not print empty values for all report fields.
+	# If enabled, all fields that don't have a value set for any of the
+	# rows reported are skipped and not printed. Compact output is
+	# applicable only if report/buffered is enabled. If you need to
+	# compact only specified fields, use compact_output=0 and define
+	# report/compact_output_cols configuration setting instead.
 	# This configuration option has an automatic default value.
 	# compact_output = 0
 
 	# Configuration option report/compact_output_cols.
-	# Do not print empty values for given report fields.
-	# The same as compact_output setting, but the compaction is not done
-	# globally for all fields in report but only for given fields. If both
-	# compact_output and compact_output_cols is used at the same time,
-	# the compact_output setting prevails.
+	# Do not print empty values for specified report fields.
+	# If defined, specified fields that don't have a value set for any
+	# of the rows reported are skipped and not printed. Compact output
+	# is applicable only if report/buffered is enabled. If you need to
+	# compact all fields, use compact_output=1 instead in which case
+	# the compact_output_cols setting is then ignored.
 	# This configuration option has an automatic default value.
 	# compact_output_cols = ""
 
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 1a261a2..dd2b407 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1416,17 +1416,20 @@ cfg(disk_area_size_CFG, "size", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_
 cfg(disk_area_id_CFG, "id", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL, NULL)
 
 cfg(report_compact_output_CFG, "compact_output", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_REP_COMPACT_OUTPUT, vsn(2, 2, 115), NULL, 0, NULL,
-	"Do not print empty report fields.\n"
-	"Fields that don't have a value set for any of the rows reported are\n"
-	"skipped and not printed. Compact output is applicable only if\n"
-	"report/buffered is enabled.\n")
+	"Do not print empty values for all report fields.\n"
+	"If enabled, all fields that don't have a value set for any of the\n"
+	"rows reported are skipped and not printed. Compact output is\n"
+	"applicable only if report/buffered is enabled. If you need to\n"
+	"compact only specified fields, use compact_output=0 and define\n"
+	"report/compact_output_cols configuration setting instead.\n")
 
 cfg(report_compact_output_cols_CFG, "compact_output_cols", report_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_COMPACT_OUTPUT_COLS, vsn(2, 2, 133), NULL, 0, NULL,
-	"Do not print empty values for given report fields.\n"
-	"The same as compact_output setting, but the compaction is not done\n"
-	"globally for all fields in report but only for given fields. If both\n"
-	"compact_output and compact_output_cols is used at the same time,\n"
-	"the compact_output setting prevails.\n")
+	"Do not print empty values for specified report fields.\n"
+	"If defined, specified fields that don't have a value set for any\n"
+	"of the rows reported are skipped and not printed. Compact output\n"
+	"is applicable only if report/buffered is enabled. If you need to\n"
+	"compact all fields, use compact_output=1 instead in which case\n"
+	"the compact_output_cols setting is then ignored.\n")
 
 cfg(report_aligned_CFG, "aligned", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_REP_ALIGNED, vsn(1, 0, 0), NULL, 0, NULL,
 	"Align columns in report output.\n")


