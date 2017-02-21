From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 21 Feb 2017 11:27:20 +0000 (UTC)
Subject: master - dmsetup: Indicate device repetition in usage summaries.
Message-ID: <20170221112720.A75BC60E47@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d2dbe71fb3e6210b252db94ec214cee6df2ddb4f
Commit:        d2dbe71fb3e6210b252db94ec214cee6df2ddb4f
Parent:        1c1ce2739ed40d02ae2d41cb9e9de54d0948967c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Feb 21 11:25:18 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Feb 21 11:25:18 2017 +0000

dmsetup: Indicate device repetition in usage summaries.

---
 man/dmsetup.8.in |   20 ++++++++++----------
 tools/dmsetup.c  |   45 ++++++++++++++++++++++-----------------------
 2 files changed, 32 insertions(+), 33 deletions(-)

diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index bd26efa..4261fc4 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -41,7 +41,7 @@ dmsetup \(em low level logical volume management
 .  BR deps
 .  RB [ \-o
 .  IR options ]
-.  RI [ device_name ]
+.  RI [ device_name ...]
 .  ad b
 ..
 .CMD_DEPS
@@ -58,7 +58,7 @@ dmsetup \(em low level logical volume management
 .B dmsetup
 .de CMD_INFO
 .  BR info
-.  RI [ device_name ]
+.  RI [ device_name ...]
 ..
 .CMD_INFO
 .
@@ -117,7 +117,7 @@ dmsetup \(em low level logical volume management
 .B dmsetup
 .de CMD_MANGLE
 .  BR mangle
-.  RI [ device_name ]
+.  RI [ device_name ...]
 ..
 .CMD_MANGLE
 .
@@ -135,7 +135,7 @@ dmsetup \(em low level logical volume management
 .B dmsetup
 .de CMD_MKNODES
 .  BR mknodes
-.  RI [ device_name ]
+.  RI [ device_name ...]
 ..
 .CMD_MKNODES
 .
@@ -159,7 +159,7 @@ dmsetup \(em low level logical volume management
 .  RB [ \-f | \-\-force ]
 .  RB [ \-\-retry ]
 .  RB [ \-\-deferred ]
-.  IR device_name
+.  IR device_name ...
 .  ad b
 ..
 .CMD_REMOVE
@@ -197,7 +197,7 @@ dmsetup \(em low level logical volume management
 .de CMD_RESUME
 .  ad l
 .  BR resume
-.  IR device_name
+.  IR device_name ...
 .  RB [ \-\-addnodeoncreate | \-\-addnodeonresume ]
 .  RB [ \-\-noflush ]
 .  RB [ \-\-nolockfs ]
@@ -247,7 +247,7 @@ dmsetup \(em low level logical volume management
 .  RB [ \-\-target
 .  IR target_type ]
 .  RB [ \-\-noflush ]
-.  RI [ device_name ]
+.  RI [ device_name ...]
 .  ad b
 ..
 .CMD_STATUS
@@ -259,7 +259,7 @@ dmsetup \(em low level logical volume management
 .  BR suspend
 .  RB [ \-\-nolockfs ]
 .  RB [ \-\-noflush ]
-.  IR device_name
+.  IR device_name ...
 .  ad b
 ..
 .CMD_SUSPEND
@@ -272,7 +272,7 @@ dmsetup \(em low level logical volume management
 .  RB [ \-\-target
 .  IR target_type ]
 .  RB [ \-\-showkeys ]
-.  RI [ device_name ]
+.  RI [ device_name ...]
 .  ad b
 ..
 .CMD_TABLE
@@ -354,7 +354,7 @@ dmsetup \(em low level logical volume management
 .de CMD_WIPE_TABLE
 .  ad l
 .  BR wipe_table
-.  IR device_name
+.  IR device_name ...
 .  RB [ \-f | \-\-force ]
 .  RB [ \-\-noflush ]
 .  RB [ \-\-nolockfs ]
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 6464069..549a8c5 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -5726,32 +5726,32 @@ static int _stats_help(CMD_ARGS);
  * dmsetup stats <cmd> [options] [device_name]
  * dmstats <cmd> [options] [device_name]
  *
- *   clear [--allregions|--regionid id] [--alldevices|<device...>]
+ *   clear [--allregions|--regionid id] [--alldevices|<device>...]
  *   create [--start <start> [--length <len>]
  *       [--areas <nr_areas>] [--areasize <size>]
  *       [--programid <id>] [--userdata <data> ]
  *       [--bounds histogram_boundaries] [--precise]
- *       [--alldevices|<device...>]
+ *       [--alldevices|<device>...]
  *   create --filemap [--nogroup]
  *       [--programid <id>] [--userdata <data> ]
  *       [--bounds histogram_boundaries] [--precise] [<file_path>]
  *   delete [--allprograms|--programid id]
  *       [--allregions|--regionid id]
- *       [--alldevices|<device...>]
+ *       [--alldevices|<device>...]
  *   group [--alias NAME] --regions <regions>
- *       [--allprograms|--programid id] [--alldevices|<device...>]
+ *       [--allprograms|--programid id] [--alldevices|<device>...]
  *   list [--allprograms|--programid id] [--allregions|--regionid id]
  *   print [--clear] [--allprograms|--programid id]
  *       [--allregions|--regionid id]
- *       [--alldevices|<device...>]
+ *       [--alldevices|<device>...]
  *   report [--interval <seconds>] [--count <cnt>]
  *       [--units <u>] [--programid <id>] [--regionid <id>]
  *       [-o <fields>] [-O|--sort <sort_fields>]
  *       [-S|--select <selection>] [--nameprefixes]
  *       [--noheadings] [--separator <separator>]
- *       [--allprograms|--programid id] [<device...>]
+ *       [--allprograms|--programid id] [<device>...]
  *   ungroup --groupid <id> [--allprograms|--programid id]
- *       [--alldevices|<device...>]
+ *       [--alldevices|<device>...]
  */
 
 #define INDENT "\n\t    "
@@ -5766,7 +5766,7 @@ static int _stats_help(CMD_ARGS);
 #define EXTRA_OPTS HIST_OPTS PRECISE_OPTS
 #define ALL_PROGS_OPT "[--allprograms|--programid id] "
 #define ALL_REGIONS_OPT "[--allregions|--regionid id] "
-#define ALL_DEVICES_OPT "[--alldevices|<device...>] "
+#define ALL_DEVICES_OPT "[--alldevices|<device>...] "
 #define ALL_PROGS_REGIONS_DEVICES ALL_PROGS_OPT INDENT ALL_REGIONS_OPT INDENT ALL_DEVICES_OPT
 #define FIELD_OPTS "[-o <fields>] [-O|--sort <sort_fields>]"
 #define DM_REPORT_OPTS FIELD_OPTS INDENT "[-S|--select <selection>] [--nameprefixes]" INDENT \
@@ -5795,7 +5795,7 @@ static struct command _stats_subcommands[] = {
 	{"group", GROUP_OPTS, 1, -1, 1, 0, _stats_group},
 	{"list", ALL_PROGS_OPT ALL_REGIONS_OPT, 0, -1, 1, 0, _stats_report},
 	{"print", PRINT_OPTS, 0, -1, 1, 0, _stats_print},
-	{"report", REPORT_OPTS "[<device...>]", 0, -1, 1, 0, _stats_report},
+	{"report", REPORT_OPTS "[<device>...]", 0, -1, 1, 0, _stats_report},
 	{"ungroup", "--groupid <id> " UNGROUP_OPTS, 1, -1, 1, 0, _stats_ungroup},
 	{"update_filemap", "--groupid <id> <file_path>", 1, 1, 0, 0, _stats_update_file},
 	{"version", "", 0, -1, 1, 0, _version},
@@ -5832,27 +5832,27 @@ static struct command _dmsetup_commands[] = {
 	  "\t    [-u|uuid <uuid>] [--addnodeonresume|--addnodeoncreate]\n"
 	  "\t    [--readahead {[+]<sectors>|auto|none}]\n"
 	  "\t    [-n|--notable|--table {<table>|<table_file>}]", 1, 2, 0, 0, _create},
-	{"remove", "[--deferred] [-f|--force] [--retry] <device>", 0, -1, 1, 0, _remove},
+	{"remove", "[--deferred] [-f|--force] [--retry] <device>...", 0, -1, 1, 0, _remove},
 	{"remove_all", "[-f|--force]", 0, 0, 0, 0, _remove_all},
-	{"suspend", "[--noflush] [--nolockfs] <device>", 0, -1, 1, 0, _suspend},
-	{"resume", "[--noflush] [--nolockfs] <device>\n"
+	{"suspend", "[--noflush] [--nolockfs] <device>...", 0, -1, 1, 0, _suspend},
+	{"resume", "[--noflush] [--nolockfs] <device>...\n"
 	  "\t       [--addnodeonresume|--addnodeoncreate]\n"
 	  "\t       [--readahead {[+]<sectors>|auto|none}]", 0, -1, 1, 0, _resume},
 	  {"load", "<device> [<table>|<table_file>]", 0, 2, 0, 0, _load},
 	{"clear", "<device>", 0, -1, 1, 0, _clear},
 	{"reload", "<device> [<table>|<table_file>]", 0, 2, 0, 0, _load},
-	{"wipe_table", "[-f|--force] [--noflush] [--nolockfs] <device>", 1, -1, 1, 0, _error_device},
+	{"wipe_table", "[-f|--force] [--noflush] [--nolockfs] <device>...", 1, -1, 1, 0, _error_device},
 	{"rename", "<device> [--setuuid] <new_name_or_uuid>", 1, 2, 0, 0, _rename},
 	{"message", "<device> <sector> <message>", 2, -1, 0, 0, _message},
 	{"ls", "[--target <target_type>] [--exec <command>] [-o <options>] [--tree]", 0, 0, 0, 0, _ls},
-	{"info", "[<device>]", 0, -1, 1, 0, _info},
-	{"deps", "[-o <options>] [<device>]", 0, -1, 1, 0, _deps},
-	{"stats", "<command> [<options>] [<devices>]", 1, -1, 1, 1, _stats},
-	{"status", "[<device>] [--noflush] [--target <target_type>]", 0, -1, 1, 0, _status},
-	{"table", "[<device>] [--target <target_type>] [--showkeys]", 0, -1, 1, 0, _status},
+	{"info", "[<device>...]", 0, -1, 1, 0, _info},
+	{"deps", "[-o <options>] [<device>...]", 0, -1, 1, 0, _deps},
+	{"stats", "<command> [<options>] [<device>...]", 1, -1, 1, 1, _stats},
+	{"status", "[<device>...] [--noflush] [--target <target_type>]", 0, -1, 1, 0, _status},
+	{"table", "[<device>...] [--target <target_type>] [--showkeys]", 0, -1, 1, 0, _status},
 	{"wait", "<device> [<event_nr>] [--noflush]", 0, 2, 0, 0, _wait},
-	{"mknodes", "[<device>]", 0, -1, 1, 0, _mknodes},
-	{"mangle", "[<device>]", 0, -1, 1, 0, _mangle},
+	{"mknodes", "[<device>...]", 0, -1, 1, 0, _mknodes},
+	{"mangle", "[<device>...]", 0, -1, 1, 0, _mangle},
 	{"udevcreatecookie", "", 0, 0, 0, 0, _udevcreatecookie},
 	{"udevreleasecookie", "[<cookie>]", 0, 1, 0, 0, _udevreleasecookie},
 	{"udevflags", "<cookie>", 1, 1, 0, 0, _udevflags},
@@ -5894,8 +5894,7 @@ static void _stats_usage(FILE *out)
 	for (i = 0; _stats_subcommands[i].name; i++)
 		fprintf(out, "\t%s %s\n", _stats_subcommands[i].name, _stats_subcommands[i].help);
 
-	fprintf(out, "\n<device> may be device name or -u <uuid> or "
-		     "-j <major> -m <minor>\n");
+	fprintf(out, "\n<device> may be device name or (if only one) -u <uuid> or -j <major> -m <minor>\n");
 	fprintf(out, "<fields> are comma-separated.  Use 'help -c' for list.\n");
 	fprintf(out, "\n");
 }
@@ -5920,7 +5919,7 @@ static void _dmsetup_usage(FILE *out)
 	for (i = 0; _dmsetup_commands[i].name; i++)
 		fprintf(out, "\t%s %s\n", _dmsetup_commands[i].name, _dmsetup_commands[i].help);
 
-	fprintf(out, "\n<device> may be device name or -u <uuid> or "
+	fprintf(out, "\n<device> may be device name or (if only one) -u <uuid> or "
 		     "-j <major> -m <minor>\n");
 	fprintf(out, "<mangling_mode> is one of 'none', 'auto' and 'hex'.\n");
 	fprintf(out, "<fields> are comma-separated.  Use 'help -c' for list.\n");


