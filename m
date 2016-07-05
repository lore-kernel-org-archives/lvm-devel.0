From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:55:07 +0000 (UTC)
Subject: master - dmstats: convert 'print' to dm_stats_foreach_region()
Message-ID: <20160705185507.6D186613E3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=01cc11d9f85dc624ee2536120d7e1e1fabeadbe5
Commit:        01cc11d9f85dc624ee2536120d7e1e1fabeadbe5
Parent:        2047b8e5658a0f6816d2e940b82e1684b5698aa6
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Jul 5 11:09:38 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:53:16 2016 +0100

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
 


