From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 11 Aug 2022 11:06:09 +0000 (GMT)
Subject: main - config: recognize 'json_std' for report/output_format config setting
Message-ID: <20220811110609.C245D3858C74@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6cba28a335284de9dd68d84b4dd660f6e744eba5
Commit:        6cba28a335284de9dd68d84b4dd660f6e744eba5
Parent:        73ec3c954b21522352b6f5cce9a700d6bf30ccf4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 4 16:42:54 2022 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 11 11:10:11 2022 +0200

config: recognize 'json_std' for report/output_format config setting

---
 lib/config/config_settings.h | 9 ++++++++-
 tools/reporter.c             | 8 ++++++--
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index d2811df2b..b172c7c5f 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1806,7 +1806,14 @@ cfg(report_output_format_CFG, "output_format", report_CFG_SECTION, CFG_PROFILABL
 	"    one report per command, each report is prefixed with report's\n"
 	"    name for identification.\n"
 	"  json\n"
-	"    JSON format.\n")
+	"    JSON format.\n"
+	"  json_std\n"
+	"    JSON format that is more compliant with JSON standard.\n"
+        "    Compared to original \"json\" format:\n"
+        "      - it does not use double quotes around numeric values,\n"
+        "      - it uses 'null' for undefined numeric values,\n"
+        "      - it prints string list as proper JSON array of strings instead of a single string."
+	"\n")
 
 cfg(report_compact_output_CFG, "compact_output", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_REP_COMPACT_OUTPUT, vsn(2, 2, 115), NULL, 0, NULL,
 	"Do not print empty values for all report fields.\n"
diff --git a/tools/reporter.c b/tools/reporter.c
index eafba4fec..b31f1891e 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -1455,6 +1455,7 @@ int devtypes(struct cmd_context *cmd, int argc, char **argv)
 
 #define REPORT_FORMAT_NAME_BASIC "basic"
 #define REPORT_FORMAT_NAME_JSON "json"
+#define REPORT_FORMAT_NAME_JSON_STD "json_std"
 
 int report_format_init(struct cmd_context *cmd)
 {
@@ -1475,11 +1476,14 @@ int report_format_init(struct cmd_context *cmd)
 										: DM_REPORT_GROUP_SINGLE;
 	} else if (!strcmp(format_str, REPORT_FORMAT_NAME_JSON)) {
 		args.report_group_type = DM_REPORT_GROUP_JSON;
+	} else if (!strcmp(format_str, REPORT_FORMAT_NAME_JSON_STD)) {
+		args.report_group_type = DM_REPORT_GROUP_JSON_STD;
 	} else {
 		log_error("%s: unknown report format.", format_str);
-		log_error("Supported report formats: %s, %s.",
+		log_error("Supported report formats: %s, %s, %s.",
 			  REPORT_FORMAT_NAME_BASIC,
-			  REPORT_FORMAT_NAME_JSON);
+			  REPORT_FORMAT_NAME_JSON,
+			  REPORT_FORMAT_NAME_JSON_STD);
 		return 0;
 	}
 

