From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:35:23 +0000 (UTC)
Subject: master - dmstats: convert 'print' to dm_stats_foreach_region()
Message-ID: <20160705183523.DCFB561241@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c54da5e82a8a968f42c6876e7b7cacff5fa713b4
Commit:        c54da5e82a8a968f42c6876e7b7cacff5fa713b4
Parent:        4b02aa2548d6ce136606b1c740f3c42a8c5ec7ad
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Jul 5 11:09:38 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:29:50 2016 +0100

dmstats: convert 'print' to dm_stats_foreach_region()

---
 tools/dmsetup.c |   43 +++++++++++++++++++++++++++++--------------
 1 files changed, 29 insertions(+), 14 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index c121f45..9d3d0a5 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -5051,6 +5051,23 @@ out:
 	return r;
 }
 
+static int _stats_print_one_region(struct dm_stats *dms, int clear,
+				   uint64_t region_id)
+{
+	char *stbuff = NULL;
+
+	/*FIXME: line control for large regions */
+	if (!(stbuff = dm_stats_print_region(dms, region_id, 0, 0, clear))) {
+		log_error("Could not print statistics region.");
+		return 0;
+	}
+
+	printf("%s", stbuff);
+	dm_stats_buffer_destroy(dms, stbuff);
+
+	return 1;
+}
+
 static int _stats_print(CMD_ARGS)
 {
 	struct dm_stats *dms;
@@ -5079,8 +5096,6 @@ static int _stats_print(CMD_ARGS)
 		name = argv[0];
 	}
 
-	region_id = (uint64_t) _int_args[REGION_ID_ARG];
-
 	if (!(dms = dm_stats_create(DM_STATS_PROGRAM_ID)))
 		return_0;
 
@@ -5095,15 +5110,18 @@ static int _stats_print(CMD_ARGS)
 		goto out;
 	}
 
-	dm_stats_walk_init(dms, DM_STATS_WALK_REGION);
-	dm_stats_walk_do(dms) {
-		if (_switches[ALL_REGIONS_ARG])
-			region_id = dm_stats_get_current_region(dms);
+	if (!allregions) {
+		region_id = (uint64_t) _int_args[REGION_ID_ARG];
+		if (!_stats_print_one_region(dms, clear, region_id))
+			goto_out;
+		r = 1;
+		goto out;
+	}
 
-		if (!dm_stats_region_present(dms, region_id)) {
-			log_error("No such region: %"PRIu64".", region_id);
-			goto out;
-		}
+	dm_stats_foreach_region(dms) {
+		region_id = dm_stats_get_current_region(dms);
+		if (!_stats_print_one_region(dms, clear, region_id))
+			goto_out;
 
 		/*FIXME: line control for large regions */
 		if (!(stbuff = dm_stats_print_region(dms, region_id, 0, 0, clear))) {
@@ -5112,11 +5130,8 @@ static int _stats_print(CMD_ARGS)
 		}
 
 		printf("%s", stbuff);
-
 		dm_stats_buffer_destroy(dms, stbuff);
-		dm_stats_walk_next(dms);
-
-	} dm_stats_walk_while(dms);
+	}
 
 	r = 1;
 


