From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:35:15 +0000 (UTC)
Subject: master - dmstats: accept --groupid for 'dmstats delete'
Message-ID: <20160705183515.995C860FDE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e25c27e5c2bda1fc8b87e52bb921aed22204d1f2
Commit:        e25c27e5c2bda1fc8b87e52bb921aed22204d1f2
Parent:        4ebc6b75cb2446f7b65e9d34febe216414247bc5
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Jul 1 13:15:43 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:29:50 2016 +0100

dmstats: accept --groupid for 'dmstats delete'

Allow deletion of a group and all the regions it contains with a
single 'dmstats delete' command.
---
 tools/dmsetup.c |   23 ++++++++++++++++++-----
 1 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 8932921..4a37f2b 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4957,7 +4957,7 @@ bad:
 static int _stats_delete(CMD_ARGS)
 {
 	struct dm_stats *dms;
-	uint64_t region_id;
+	uint64_t region_id, group_id;
 	char *name = NULL;
 	const char *program_id = DM_STATS_PROGRAM_ID;
 	int allregions = _switches[ALL_REGIONS_ARG];
@@ -4969,8 +4969,13 @@ static int _stats_delete(CMD_ARGS)
 		_report = NULL;
 	}
 
-	if (!_switches[REGION_ID_ARG] && !allregions) {
-		err("Please specify a --regionid or use --allregions.");
+	if (_switches[REGION_ID_ARG] && _switches[GROUP_ID_ARG]) {
+		err("Please use one of --regionid and --groupid.");
+		return 0;
+	}
+
+	if (!_switches[REGION_ID_ARG] && !allregions && !_switches[GROUP_ID_ARG]) {
+		err("Please specify a --regionid or --groupid, or use --allregions.");
 		return 0;
 	}
 
@@ -4992,6 +4997,7 @@ static int _stats_delete(CMD_ARGS)
 		program_id = DM_STATS_ALL_PROGRAMS;
 
 	region_id = (uint64_t) _int_args[REGION_ID_ARG];
+	group_id = (uint64_t) _int_args[GROUP_ID_ARG];
 
 	if (!(dms = dm_stats_create(program_id)))
 		return_0;
@@ -4999,7 +5005,9 @@ static int _stats_delete(CMD_ARGS)
 	if (!_bind_stats_device(dms, name))
 		goto_out;
 
-	if (allregions && !dm_stats_list(dms, program_id))
+	/* allregions and group delete require a listed handle */
+	if ((allregions || _switches[GROUP_ID_ARG])
+	    && !dm_stats_list(dms, program_id))
 		goto_out;
 
 	if (allregions && !dm_stats_get_nr_regions(dms)) {
@@ -5008,7 +5016,12 @@ static int _stats_delete(CMD_ARGS)
 		goto out;
 	}
 
-	if (_switches[ALL_REGIONS_ARG]) {
+	if (_switches[GROUP_ID_ARG]) {
+		if (!dm_stats_delete_group(dms, group_id, 1)) {
+			log_error("Could not delete statistics group.");
+			goto out;
+		}
+	} else if (_switches[ALL_REGIONS_ARG]) {
 		dm_stats_walk_init(dms, DM_STATS_WALK_REGION);
 		dm_stats_walk_do(dms) {
 			region_id = dm_stats_get_current_region(dms);


