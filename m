From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:54:46 +0000 (UTC)
Subject: master - dmstats: add group alias support
Message-ID: <20160705185446.A1F47612CA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b55daa28e89ebc19da1292baaeeed437501aaeec
Commit:        b55daa28e89ebc19da1292baaeeed437501aaeec
Parent:        0761863e28ec3184c0884b8f11f42f10a1374b9e
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Mar 7 18:16:22 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:53:16 2016 +0100

dmstats: add group alias support

---
 tools/dmsetup.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 36058c8..9f63608 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -156,6 +156,7 @@ enum {
 	READ_ONLY = 0,
 	ADD_NODE_ON_CREATE_ARG,
 	ADD_NODE_ON_RESUME_ARG,
+	ALIAS_ARG,
 	ALL_DEVICES_ARG,
 	ALL_PROGRAMS_ARG,
 	ALL_REGIONS_ARG,
@@ -5092,7 +5093,7 @@ out:
 
 static int _stats_group(CMD_ARGS)
 {
-	char *name, *regions = NULL;
+	char *name, *alias = NULL, *regions = NULL;
 	struct dm_stats *dms;
 	uint64_t group_id;
 	int r = 0;
@@ -5124,6 +5125,9 @@ static int _stats_group(CMD_ARGS)
 		name = argv[0];
 	}
 
+	if (_switches[ALIAS_ARG])
+		alias = _string_args[ALIAS_ARG];
+
 	if (!(dms = dm_stats_create(DM_STATS_PROGRAM_ID)))
 		return_0;
 
@@ -5133,7 +5137,7 @@ static int _stats_group(CMD_ARGS)
 	if (!dm_stats_list(dms, NULL))
 		goto_out;
 
-	if(!dm_stats_create_group(dms, regions, NULL, &group_id)) {
+	if(!dm_stats_create_group(dms, regions, alias, &group_id)) {
 		log_error("Could not create group on %s: %s", name, regions);
 		goto out;
 	}
@@ -5841,6 +5845,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 #ifdef HAVE_GETOPTLONG
 	static struct option long_options[] = {
 		{"readonly", 0, &ind, READ_ONLY},
+		{"alias", 1, &ind, ALIAS_ARG},
 		{"alldevices", 0, &ind, ALL_DEVICES_ARG},
 		{"allprograms", 0, &ind, ALL_PROGRAMS_ARG},
 		{"allregions", 0, &ind, ALL_REGIONS_ARG},
@@ -5979,6 +5984,10 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 	optind = OPTIND_INIT;
 	while ((ind = -1, c = GETOPTLONG_FN(*argcp, *argvp, "cCfG:hj:m:M:no:O:rS:u:U:vy",
 					    long_options, NULL)) != -1) {
+		if (ind == ALIAS_ARG) {
+			_switches[ALIAS_ARG]++;
+			_string_args[ALIAS_ARG] = optarg;
+		}
 		if (ind == ALL_DEVICES_ARG)
 			_switches[ALL_DEVICES_ARG]++;
 		if (ind == ALL_PROGRAMS_ARG)


