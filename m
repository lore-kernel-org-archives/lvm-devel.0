From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 25 Aug 2016 12:58:18 +0000 (UTC)
Subject: master - conf: fix typo in report/columns_as_rows config option name recognition
Message-ID: <20160825125818.1BF7260F67@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e758d722c7719fba91ae62122fb0359a395f0327
Commit:        e758d722c7719fba91ae62122fb0359a395f0327
Parent:        b0e07d516eab26699b824d5d499a8662e1ab2152
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 25 14:53:32 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 25 14:53:32 2016 +0200

conf: fix typo in report/columns_as_rows config option name recognition

Commit e947c362dd0ae1da2d76925fe6b38244c5f46d25 introduced
config_settings.h file for central place to store all definitions for
config options. By mistake, it used report/colums_as_rows instead
of report/columns_as_rows (missing "n" in "columns").
---
 WHATS_NEW                                |    1 +
 conf/command_profile_template.profile.in |    2 +-
 lib/config/config_settings.h             |    2 +-
 tools/reporter.c                         |    2 +-
 4 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 60e052e..99d31be 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.165 - 
 ===================================
+  Fix typo in report/columns_as_rows config option name recognition (2.02.99).
   Avoid PV tags when checking allocation against parallel PVs.
   Disallow mirror conversions of raid10 volumes.
   Fix dmeventd unmonitoring when segment type (and dso) changes.
diff --git a/conf/command_profile_template.profile.in b/conf/command_profile_template.profile.in
index 156dc0d..83a2c35 100644
--- a/conf/command_profile_template.profile.in
+++ b/conf/command_profile_template.profile.in
@@ -39,7 +39,7 @@ report {
 	list_item_separator=","
 	prefixes=0
 	quoted=1
-	colums_as_rows=0
+	columns_as_rows=0
 	binary_values_as_numeric=0
 	time_format="%Y-%m-%d %T %z"
 	devtypes_sort="devtype_name"
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index fa6a01e..7401725 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1571,7 +1571,7 @@ cfg(report_prefixes_CFG, "prefixes", report_CFG_SECTION, CFG_PROFILABLE | CFG_DE
 cfg(report_quoted_CFG, "quoted", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_REP_QUOTED, vsn(2, 2, 39), NULL, 0, NULL,
 	"Quote field values when using field name prefixes.\n")
 
-cfg(report_colums_as_rows_CFG, "colums_as_rows", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_REP_COLUMNS_AS_ROWS, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(report_columns_as_rows_CFG, "columns_as_rows", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_REP_COLUMNS_AS_ROWS, vsn(1, 0, 0), NULL, 0, NULL,
 	"Output each column as a row.\n"
 	"If set, this also implies report/prefixes=1.\n")
 
diff --git a/tools/reporter.c b/tools/reporter.c
index 4a622ed..0df22ff 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -1237,7 +1237,7 @@ static int _config_report(struct cmd_context *cmd, struct report_args *args, str
 	args->separator = find_config_tree_str(cmd, report_separator_CFG, NULL);
 	args->field_prefixes = find_config_tree_bool(cmd, report_prefixes_CFG, NULL);
 	args->quoted = find_config_tree_bool(cmd, report_quoted_CFG, NULL);
-	args->columns_as_rows = find_config_tree_bool(cmd, report_colums_as_rows_CFG, NULL);
+	args->columns_as_rows = find_config_tree_bool(cmd, report_columns_as_rows_CFG, NULL);
 
 	/* Check PV specifics and do extra changes/actions if needed. */
 	_check_pv_list(cmd, args, single_args);


