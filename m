From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 11 Aug 2022 11:06:10 +0000 (GMT)
Subject: main - args: recognize 'json_std' for --reportformat cmd line arg
Message-ID: <20220811110610.E1F943858C74@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aa7cec61edae849c5fab7e1319684b43fdc439de
Commit:        aa7cec61edae849c5fab7e1319684b43fdc439de
Parent:        6cba28a335284de9dd68d84b4dd660f6e744eba5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 4 16:50:01 2022 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 11 11:10:11 2022 +0200

args: recognize 'json_std' for --reportformat cmd line arg

---
 tools/args.h       | 4 +++-
 tools/lvmcmdline.c | 3 ++-
 tools/vals.h       | 2 +-
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 2f94d4535..9229b8764 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -677,7 +677,9 @@ arg(reportformat_ARG, '\0', "reportformat", reportformat_VAL, 0, 0,
     "\\fBbasic\\fP is the original format with columns and rows.\n"
     "If there is more than one report per command, each report is prefixed\n"
     "with the report name for identification. \\fBjson\\fP produces report\n"
-    "output in JSON format. See \\fBlvmreport\\fP(7) for more information.\n")
+    "output in JSON format. \\fBjson_std\\fP produces report output in\n"
+    "JSON format which is more compliant with JSON standard.\n"
+    "See \\fBlvmreport\\fP(7) for more information.\n")
 
 arg(restorefile_ARG, '\0', "restorefile", string_VAL, 0, 0,
     "In conjunction with --uuid, this reads the file (produced by\n"
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index b052d698f..4fb21074f 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1058,7 +1058,8 @@ int syncaction_arg(struct cmd_context *cmd, struct arg_values *av)
 int reportformat_arg(struct cmd_context *cmd, struct arg_values *av)
 {
 	if (!strcmp(av->value, "basic") ||
-	    !strcmp(av->value, "json"))
+	    !strcmp(av->value, "json") ||
+	    !strcmp(av->value, "json_std"))
 		return 1;
 	return 0;
 }
diff --git a/tools/vals.h b/tools/vals.h
index addbea2f2..590755a1e 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -138,7 +138,7 @@ val(metadatacopies_VAL, metadatacopies_arg, "unused", "unused")
 val(polloperation_VAL, polloperation_arg, "PollOp", "pvmove|convert|merge|merge_thin")
 val(writemostly_VAL, writemostly_arg, "WriteMostlyPV", "PV[:t|n|y]")
 val(syncaction_VAL, syncaction_arg, "SyncAction", "check|repair")
-val(reportformat_VAL, reportformat_arg, "ReportFmt", "basic|json")
+val(reportformat_VAL, reportformat_arg, "ReportFmt", "basic|json|json_std")
 val(configreport_VAL, configreport_arg, "ConfigReport", "log|vg|lv|pv|pvseg|seg")
 val(configtype_VAL, configtype_arg, "ConfigType", "current|default|diff|full|list|missing|new|profilable|profilable-command|profilable-metadata")
 val(repairtype_VAL, repairtype_arg, "RepairType", "pv_header|metadata|label_header")

