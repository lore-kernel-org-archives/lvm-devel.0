From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 13 Aug 2015 12:11:17 +0000 (UTC)
Subject: master - dmsetup: Use #define for command names.
Message-ID: <20150813121117.9BFD7609E3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b22b7d7ba9208c5ead5ea6d7353cd903ebb3c075
Commit:        b22b7d7ba9208c5ead5ea6d7353cd903ebb3c075
Parent:        7995eedd3581407b030b0864202068b51dd1ef45
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Aug 13 13:10:23 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Aug 13 13:10:23 2015 +0100

dmsetup: Use #define for command names.

---
 tools/dmsetup.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index dd2f153..4a1a396 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -108,6 +108,11 @@ extern char *optarg;
 /* program_id used for dmstats-managed statistics regions */
 #define DM_STATS_PROGRAM_ID "dmstats"
 
+#define DMSETUP_CMD_NAME "dmsetup"
+#define LOSETUP_CMD_NAME "losetup"
+#define DMLOSETUP_CMD_NAME "dmlosetup"
+#define DMSTATS_CMD_NAME "dmstats"
+
 /*
  * We have only very simple switches ATM.
  */
@@ -4818,7 +4823,7 @@ static void _dmsetup_usage(FILE *out)
 	int i;
 
 	fprintf(out, "Usage:\n\n");
-	fprintf(out, "dmsetup [--version] [-h|--help [-c|-C|--columns]]\n"
+	fprintf(out, DMSETUP_CMD_NAME " [--version] [-h|--help [-c|-C|--columns]]\n"
 		"        [-v|--verbose [-v|--verbose ...]]\n"
 		"        [--checks] [--manglename <mangling_mode>]\n"
 		"        [-r|--readonly] [--noopencount] [--nolockfs] [--inactive]\n"
@@ -4843,7 +4848,7 @@ static void _dmsetup_usage(FILE *out)
 static void _losetup_usage(FILE *out)
 {
 	fprintf(out, "Usage:\n\n");
-	fprintf(out, "losetup [-d|-a] [-e encryption] "
+	fprintf(out, LOSETUP_CMD_NAME " [-d|-a] [-e encryption] "
 		     "[-o offset] [-f|loop_device] [file]\n\n");
 }
 
@@ -5110,7 +5115,7 @@ static int _loop_table(char *table, size_t tlen, char *file,
 	sectors = size >> SECTOR_SHIFT;
 
 	if (_switches[VERBOSE_ARG])
-		fprintf(stderr, "losetup: set loop size to %llukB "
+		fprintf(stderr, LOSETUP_CMD_NAME ": set loop size to %llukB "
 			"(%llu sectors)\n", (long long unsigned) sectors >> 1,
 			(long long unsigned) sectors);
 
@@ -5413,13 +5418,13 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		return 1;
 	}
 
-	if (!strcmp(base, "losetup") || !strcmp(base, "dmlosetup")){
+	if (!strcmp(base, LOSETUP_CMD_NAME) || !strcmp(base, DMLOSETUP_CMD_NAME)){
 		r = _process_losetup_switches(base, argcp, argvp, dev_dir);
 		free(namebase);
 		return r;
 	}
 
-	if (!strcmp(base, "dmstats")) {
+	if (!strcmp(base, DMSTATS_CMD_NAME)) {
 		/* save the offset to the 'stats' in 'dmstats' */
 		stats_p = (*argvp)[0] + strlen(namebase) - strlen(base) + 2;
 		stats_c = (*argvp)[1]; /* stats command */


