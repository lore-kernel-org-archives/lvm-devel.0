From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:35:40 +0000 (UTC)
Subject: master - dmstats: rename --auxdata to --userdata
Message-ID: <20160705183540.8510561277@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ced707df28a5950c26af9d5529a3c05e10bf217e
Commit:        ced707df28a5950c26af9d5529a3c05e10bf217e
Parent:        6fb39fce2189476fd77ad8259c7664c208748571
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Jul 5 15:54:02 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:29:51 2016 +0100

dmstats: rename --auxdata to --userdata

---
 man/dmstats.8.in |    8 ++++----
 tools/dmsetup.c  |   20 ++++++++++----------
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index 2175097..8530cae 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -87,8 +87,8 @@ dmstats \(em device-mapper statistics management
 .  IR start_sector
 .  BR \-\-length
 .  IR length | \fB\-\-segments ]
-.  RB \%[ \-\-auxdata
-.  IR data ]
+.  RB \%[ \-\-userdata
+.  IR user_data ]
 .  RB [ \-\-programid
 .  IR id ]
 .  ad b
@@ -268,8 +268,8 @@ optional suffix selects units of:
 .HELP_UNITS
 .
 .HP
-.BR \-\-auxdata
-.IR aux_data
+.BR \-\-userdata
+.IR user_data
 .br
 Specify user data (a word) to be stored with a new region. The value
 is added to any internal auxilliary data (for example, group
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index b468fee..3ee9ed8 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -163,7 +163,6 @@ enum {
 	AREA_ARG,
 	AREAS_ARG,
 	AREA_SIZE_ARG,
-	AUX_DATA_ARG,
 	BOUNDS_ARG,
 	CHECKS_ARG,
 	CLEAR_ARG,
@@ -220,6 +219,7 @@ enum {
 	UNBUFFERED_ARG,
 	UNITS_ARG,
 	UNQUOTED_ARG,
+	USER_DATA_ARG,
 	UUID_ARG,
 	VERBOSE_ARG,
 	VERIFYUDEV_ARG,
@@ -4925,8 +4925,8 @@ static int _stats_create(CMD_ARGS)
 	if (!strlen(program_id) && !_switches[FORCE_ARG])
 		program_id = DM_STATS_PROGRAM_ID;
 
-	if (_switches[AUX_DATA_ARG])
-		user_data = _string_args[AUX_DATA_ARG];
+	if (_switches[USER_DATA_ARG])
+		user_data = _string_args[USER_DATA_ARG];
 
 	if (!(dms = dm_stats_create(DM_STATS_PROGRAM_ID)))
 		return_0;
@@ -5327,7 +5327,7 @@ static int _stats_help(CMD_ARGS);
  *    clear [--regionid id] <device_name>
  *    create [--areas nr_areas] [--areasize size]
  *           [ [--start start] [--length len] | [--segments]]
- *           [--auxdata data] [--programid id] [<device_name>]
+ *           [--userdata data] [--programid id] [<device_name>]
  *    delete [--regionid] <device_name>
  *    delete_all [--programid id]
  *    group [--alias name] [--alldevices] [--regions <regions>] [<device_name>]
@@ -5340,7 +5340,7 @@ static int _stats_help(CMD_ARGS);
 
 #define AREA_OPTS "[--areas <nr_areas>] [--areasize <size>] "
 #define CREATE_OPTS "[--start <start> [--length <len>]]\n\t\t" AREA_OPTS
-#define ID_OPTS "[--programid <id>] [--auxdata <data> ] "
+#define ID_OPTS "[--programid <id>] [--userdata <data> ] "
 #define SELECT_OPTS "[--programid <id>] [--regionid <id>] "
 #define PRINT_OPTS "[--clear] " SELECT_OPTS
 #define REPORT_OPTS "[--interval <seconds>] [--count <cnt>]\n\t\t[--units <u>]" SELECT_OPTS
@@ -5429,7 +5429,7 @@ static void _stats_usage(FILE *out)
 	fprintf(out, "        [-h|--help]\n");
 	fprintf(out, "        [-v|--verbose [-v|--verbose ...]]\n");
 	fprintf(out, "        [--areas <nr_areas>] [--areasize <size>]\n");
-	fprintf(out, "        [--auxdata <data>] [--clear]\n");
+	fprintf(out, "        [--userdata <data>] [--clear]\n");
 	fprintf(out, "        [--count <count>] [--interval <seconds>]\n");
 	fprintf(out, "        [-o <fields>] [-O|--sort <sort_fields>]\n");
 	fprintf(out, "	      [--programid <id>]\n");
@@ -5973,7 +5973,6 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"area", 0, &ind, AREA_ARG},
 		{"areas", 1, &ind, AREAS_ARG},
 		{"areasize", 1, &ind, AREA_SIZE_ARG},
-		{"auxdata", 1, &ind, AUX_DATA_ARG},
 		{"bounds", 1, &ind, BOUNDS_ARG},
 		{"checks", 0, &ind, CHECKS_ARG},
 		{"clear", 0, &ind, CLEAR_ARG},
@@ -6031,6 +6030,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"uuid", 1, &ind, UUID_ARG},
 		{"unbuffered", 0, &ind, UNBUFFERED_ARG},
 		{"unquoted", 0, &ind, UNQUOTED_ARG},
+		{"userdata", 1, &ind, USER_DATA_ARG},
 		{"verbose", 1, &ind, VERBOSE_ARG},
 		{"verifyudev", 0, &ind, VERIFYUDEV_ARG},
 		{"version", 0, &ind, VERSION_ARG},
@@ -6128,9 +6128,9 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[AREA_SIZE_ARG]++;
 			_string_args[AREA_SIZE_ARG] = optarg;
 		}
-		if (ind == AUX_DATA_ARG) {
-			_switches[AUX_DATA_ARG]++;
-			_string_args[AUX_DATA_ARG] = optarg;
+		if (ind == USER_DATA_ARG) {
+			_switches[USER_DATA_ARG]++;
+			_string_args[USER_DATA_ARG] = optarg;
 		}
 		if (c == ':' || c == '?')
 			return_0;


