From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sun, 18 Dec 2016 13:10:02 +0000 (UTC)
Subject: master - dmstats: improve tool help output and option coverage
Message-ID: <20161218131002.1725A60EB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=68ec42ebaf288911b1cb95882678ca778b795953
Commit:        68ec42ebaf288911b1cb95882678ca778b795953
Parent:        4f9d901c7142a0f2a73eb0353db992407187a144
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Dec 18 10:53:27 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sun Dec 18 11:51:13 2016 +0000

dmstats: improve tool help output and option coverage

---
 tools/dmsetup.c |  104 +++++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 78 insertions(+), 26 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index f068293..1be19d5 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -5608,48 +5608,100 @@ static int _stats_help(CMD_ARGS);
  * dmsetup stats <cmd> [options] [device_name]
  * dmstats <cmd> [options] [device_name]
  *
- *    clear [--regionid id] <device_name>
- *    create [--areas nr_areas] [--areasize size]
- *           [ [--start start] [--length len] | [--segments]]
- *           [--userdata data] [--programid id] [<device_name>]
- *    delete [--regionid] <device_name>
- *    delete_all [--programid id]
- *    group [--alias name] [--alldevices] [--regions <regions>] [<device_name>]
- *    list [--programid id] [<device_name>]
- *    print [--clear] [--programid id] [--regionid id] [<device_name>]
- *    report [--interval seconds] [--count count] [--units units] [--regionid id]
- *           [--programid id] [<device>]
- *    ungroup [--alldevices] [--groupid id] [<device_name>]
+ *   clear [--allregions|--regionid id] [--alldevices|<device...>]
+ *   create [--start <start> [--length <len>]
+ *       [--areas <nr_areas>] [--areasize <size>]
+ *       [--programid <id>] [--userdata <data> ]
+ *       [--bounds histogram_boundaries] [--precise]
+ *       [--alldevices|<device...>]
+ *   create --filemap [--nogroup]
+ *       [--programid <id>] [--userdata <data> ]
+ *       [--bounds histogram_boundaries] [--precise] [<file_path>]
+ *   delete [--allprograms|--programid id]
+ *       [--allregions|--regionid id]
+ *       [--alldevices|<device...>]
+ *   group [--alias NAME] --regions <regions>
+ *       [--allprograms|--programid id] [--alldevices|<device...>]
+ *   list [--allprograms|--programid id] [--allregions|--regionid id]
+ *   print [--clear] [--allprograms|--programid id]
+ *       [--allregions|--regionid id]
+ *       [--alldevices|<device...>]
+ *   report [--interval <seconds>] [--count <cnt>]
+ *       [--units <u>] [--programid <id>] [--regionid <id>]
+ *       [-o <fields>] [-O|--sort <sort_fields>]
+ *       [-S|--select <selection>] [--nameprefixes]
+ *       [--noheadings] [--separator <separator>]
+ *       [--allprograms|--programid id] [<device...>]
+ *   ungroup --groupid <id> [--allprograms|--programid id]
+ *       [--alldevices|<device...>]
  */
 
+#define INDENT "\n\t    "
+/* groups of commonly used options */
 #define AREA_OPTS "[--areas <nr_areas>] [--areasize <size>] "
-#define CREATE_OPTS "[--start <start> [--length <len>]]\n\t\t" AREA_OPTS
+#define REGION_OPTS "[--start <start> [--length <len>]" INDENT AREA_OPTS
 #define ID_OPTS "[--programid <id>] [--userdata <data> ] "
 #define SELECT_OPTS "[--programid <id>] [--regionid <id>] "
-#define PRINT_OPTS "[--clear] " SELECT_OPTS
-#define REPORT_OPTS "[--interval <seconds>] [--count <cnt>]\n\t\t[--units <u>]" SELECT_OPTS
-#define GROUP_OPTS "[--alias NAME] --regions <regions>"
+#define HIST_OPTS "[--bounds histogram_boundaries] "
+#define PRECISE_OPTS "[--precise] "
+#define SEGMENTS_OPT "[--segments] "
+#define EXTRA_OPTS HIST_OPTS PRECISE_OPTS
+#define ALL_PROGS_OPT "[--allprograms|--programid id] "
+#define ALL_REGIONS_OPT "[--allregions|--regionid id] "
+#define ALL_DEVICES_OPT "[--alldevices|<device...>] "
+#define ALL_PROGS_REGIONS_DEVICES ALL_PROGS_OPT INDENT ALL_REGIONS_OPT INDENT ALL_DEVICES_OPT
+#define FIELD_OPTS "[-o <fields>] [-O|--sort <sort_fields>]"
+#define DM_REPORT_OPTS FIELD_OPTS INDENT "[-S|--select <selection>] [--nameprefixes]" INDENT \
+"[--noheadings] [--separator <separator>]"
+
+/* command options */
+#define CREATE_OPTS REGION_OPTS INDENT ID_OPTS INDENT EXTRA_OPTS INDENT SEGMENTS_OPT
+#define FILEMAP_OPTS "--filemap [--nogroup]" INDENT ID_OPTS INDENT EXTRA_OPTS
+#define PRINT_OPTS "[--clear] " ALL_PROGS_REGIONS_DEVICES
+#define REPORT_OPTS "[--interval <seconds>] [--count <cnt>]" INDENT \
+"[--units <u>] " SELECT_OPTS INDENT DM_REPORT_OPTS INDENT ALL_PROGS_OPT
+#define GROUP_OPTS "[--alias NAME] --regions <regions>" INDENT ALL_PROGS_OPT ALL_DEVICES_OPT
+#define UNGROUP_OPTS ALL_PROGS_OPT INDENT ALL_DEVICES_OPT
 
+/*
+ * The 'create' command has two entries in the table, to allow for the
+ * the fact that 'create' and 'create --filemap' have largely disjoint
+ * sets of options.
+ */
 static struct command _stats_subcommands[] = {
 	{"help", "", 0, 0, 0, 0, _stats_help},
-	{"clear", "--regionid <id> [<device>]", 0, -1, 1, 0, _stats_clear},
-	{"create", CREATE_OPTS "\n\t\t" ID_OPTS "[<device>]", 0, -1, 1, 0, _stats_create},
-	{"delete", "--regionid <id> <device>", 1, -1, 1, 0, _stats_delete},
+	{"clear", ALL_REGIONS_OPT ALL_DEVICES_OPT, 0, -1, 1, 0, _stats_clear},
+	{"create", CREATE_OPTS ALL_DEVICES_OPT, 0, -1, 1, 0, _stats_create},
+	{"create", FILEMAP_OPTS "[<file_path>]", 0, -1, 1, 0, _stats_create},
+	{"delete", ALL_PROGS_REGIONS_DEVICES, 1, -1, 1, 0, _stats_delete},
 	{"group", GROUP_OPTS, 1, -1, 1, 0, _stats_group},
-	{"list", "[--programid <id>] [<device>]", 0, -1, 1, 0, _stats_report},
-	{"print", PRINT_OPTS "[<device>]", 0, -1, 1, 0, _stats_print},
-	{"report", REPORT_OPTS "[<device>]", 0, -1, 1, 0, _stats_report},
-	{"ungroup", "--groupid <id> [device]", 1, -1, 1, 0, _stats_ungroup},
+	{"list", ALL_PROGS_OPT ALL_REGIONS_OPT, 0, -1, 1, 0, _stats_report},
+	{"print", PRINT_OPTS, 0, -1, 1, 0, _stats_print},
+	{"report", REPORT_OPTS "[<device...>]", 0, -1, 1, 0, _stats_report},
+	{"ungroup", "--groupid <id> " UNGROUP_OPTS, 1, -1, 1, 0, _stats_ungroup},
 	{"version", "", 0, -1, 1, 0, _version},
 	{NULL, NULL, 0, 0, 0, 0, NULL}
 };
 
 #undef AREA_OPTS
-#undef CREATE_OPTS
+#undef REGION_OPTS
 #undef ID_OPTS
+#undef SELECT_OPTS
+#undef HIST_OPTS
+#undef PRECISE_OPTS
+#undef EXTRA_OPTS
+#undef ALL_PROGS_OPT
+#undef ALL_REGIONS_OPT
+#undef ALL_DEVICES_OPT
+#undef ALL_PROGS_REGIONS_DEVICES
+#undef FIELD_OPTS
+#undef DM_REPORT_OPTS
+#undef CREATE_OPTS
+#undef FILEMAP_OPTS
 #undef PRINT_OPTS
 #undef REPORT_OPTS
-#undef SELECT_OPTS
+#undef GROUP_OPTS
+#undef UNGROUP_OPTS
 
 static int _dmsetup_help(CMD_ARGS);
 
@@ -5723,7 +5775,7 @@ static void _stats_usage(FILE *out)
 	for (i = 0; _stats_subcommands[i].name; i++)
 		fprintf(out, "\t%s %s\n", _stats_subcommands[i].name, _stats_subcommands[i].help);
 
-	fprintf(out, "<device> may be device name or -u <uuid> or "
+	fprintf(out, "\n<device> may be device name or -u <uuid> or "
 		     "-j <major> -m <minor>\n");
 	fprintf(out, "<fields> are comma-separated.  Use 'help -c' for list.\n");
 	fprintf(out, "\n");


