From: David Teigland <teigland@sourceware.org>
Date: Tue, 10 Dec 2019 12:07:44 -0500
Subject: master - pvck: show specific dump option values
Message-ID: <84731.119121012074002161@us-mta-251.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2da6f01c1544a0b94bd06abc691fe0ac59268700
Commit:        2da6f01c1544a0b94bd06abc691fe0ac59268700
Parent:        4a52855899bdbd8bc570a667a03394872667e754
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Dec 10 11:06:45 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 10 11:07:07 2019 -0600

pvck: show specific dump option values

---
 tools/args.h           |    2 +-
 tools/command-lines.in |    2 +-
 tools/command.c        |    1 +
 tools/lvmcmdline.c     |   12 ++++++++++++
 tools/tools.h          |    1 +
 tools/vals.h           |    1 +
 6 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index e0bd42a..999d891 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -213,7 +213,7 @@ arg(driverloaded_ARG, '\0', "driverloaded", bool_VAL, 0, 0,
     "If set to no, the command will not attempt to use device-mapper.\n"
     "For testing and debugging.\n")
 
-arg(dump_ARG, '\0', "dump", string_VAL, 0, 0,
+arg(dump_ARG, '\0', "dump", dumptype_VAL, 0, 0,
     "Dump headers and metadata from a PV for debugging and repair.\n"
     "Option values include: \\fBheaders\\fP to print and check LVM headers,\n"
     "\\fBmetadata\\fP to print or save the current text metadata,\n"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 10165ea..37a01cb 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1436,7 +1436,7 @@ OO: --labelsector Number
 ID: pvck_general
 DESC: Check for metadata on a device
 
-pvck --dump String PV
+pvck --dump DumpType PV
 OO: --settings String, --file String,
 --pvmetadatacopies MetadataCopiesPV, --labelsector Number
 ID: pvck_dump
diff --git a/tools/command.c b/tools/command.c
index 7bad98d..0cbd877 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -123,6 +123,7 @@ static inline int reportformat_arg(struct cmd_context *cmd __attribute__((unused
 static inline int configreport_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
 static inline int configtype_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
 static inline int repairtype_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
+static inline int dumptype_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
 
 /* needed to include commands.h when building man page generator */
 #define CACHE_VGMETADATA        0x00000001
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 3d79e97..f147be3 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1086,6 +1086,18 @@ int repairtype_arg(struct cmd_context *cmd, struct arg_values *av)
 	return 0;
 }
 
+int dumptype_arg(struct cmd_context *cmd, struct arg_values *av)
+{
+	if (!strcmp(av->value, "headers") ||
+	    !strcmp(av->value, "metadata") ||
+	    !strcmp(av->value, "metadata_all") ||
+	    !strcmp(av->value, "metadata_search") ||
+	    !strcmp(av->value, "metadata_area") ||
+	    !strcmp(av->value, "backup_to_raw"))
+		return 1;
+	return 0;
+}
+
 /*
  * FIXME: there's been a confusing mixup among:
  * resizeable, resizable, allocatable, allocation.
diff --git a/tools/tools.h b/tools/tools.h
index a2baaa5..3cf4293 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -185,6 +185,7 @@ int reportformat_arg(struct cmd_context *cmd __attribute__((unused)), struct arg
 int configreport_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
 int configtype_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
 int repairtype_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
+int dumptype_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
 
 /* we use the enums to access the switches */
 unsigned arg_count(const struct cmd_context *cmd, int a);
diff --git a/tools/vals.h b/tools/vals.h
index 317e498..7040443 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -142,6 +142,7 @@ val(reportformat_VAL, reportformat_arg, "ReportFmt", "basic|json")
 val(configreport_VAL, configreport_arg, "ConfigReport", "log|vg|lv|pv|pvseg|seg")
 val(configtype_VAL, configtype_arg, "ConfigType", "current|default|diff|full|list|missing|new|profilable|profilable-command|profilable-metadata")
 val(repairtype_VAL, repairtype_arg, "RepairType", "pv_header|metadata|label_header")
+val(dumptype_VAL, dumptype_arg, "DumpType", "headers|metadata|metadata_all|metadata_search")
 
 /* this should always be last */
 val(VAL_COUNT, NULL, NULL, NULL)



