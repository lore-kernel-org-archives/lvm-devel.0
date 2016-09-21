From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed, 21 Sep 2016 09:09:32 +0000 (UTC)
Subject: master - dmsetup: ensure --filemap histogram bounds are freed
Message-ID: <20160921090932.9BBB6607C6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7ea5758c919022e6bca9ebe15aec160fd5ef2430
Commit:        7ea5758c919022e6bca9ebe15aec160fd5ef2430
Parent:        5d455b28fce16fce20f33279fe3b1b682c57e619
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Sep 14 15:44:51 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Sep 21 10:09:20 2016 +0100

dmsetup: ensure --filemap histogram bounds are freed

Make sure that the temporary dm_histogram used for the bounds
argument is freed in the case that the user provided a --bounds
argument on the command line.
---
 tools/dmsetup.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index ff42a9e..5f4c192 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4951,12 +4951,12 @@ static char *_get_abspath(const char *path)
 static int _stats_create_file(CMD_ARGS)
 {
 	const char *alias, *program_id = DM_STATS_PROGRAM_ID;
-	const char *histogram = _string_args[BOUNDS_ARG];
+	const char *bounds_str = _string_args[BOUNDS_ARG];
 	uint64_t *regions, *region, count = 0;
 	struct dm_histogram *bounds = NULL;
 	char *path, *abspath = NULL;
+	struct dm_stats *dms = NULL;
 	int group, fd, precise;
-	struct dm_stats *dms;
 
 	if (_switches[AREAS_ARG] || _switches[AREA_SIZE_ARG]) {
 		log_error("--filemap is incompatible with --areas and --area-size.");
@@ -5017,7 +5017,8 @@ static int _stats_create_file(CMD_ARGS)
 		return 0;
 	}
 
-	if (histogram && !(bounds = dm_histogram_bounds_from_string(histogram))) {
+	if (bounds_str
+	    && !(bounds = dm_histogram_bounds_from_string(bounds_str))) {
 		dm_free(abspath);
 		return_0;
 	}
@@ -5031,7 +5032,7 @@ static int _stats_create_file(CMD_ARGS)
 	group = !_switches[NOGROUP_ARG];
 
 	if (!(dms = dm_stats_create(DM_STATS_PROGRAM_ID)))
-		return_0;
+		goto_bad;
 
 	fd = open(abspath, O_RDONLY);
 
@@ -5087,16 +5088,20 @@ static int _stats_create_file(CMD_ARGS)
 
 	dm_free(regions);
 	dm_free(abspath);
+	dm_free(bounds);
 	dm_stats_destroy(dms);
 	return 1;
 
 bad:
 	dm_free(abspath);
+	dm_free(bounds);
 
 	if ((fd > -1) && close(fd))
 		log_error("Error closing %s", path);
 
-	dm_stats_destroy(dms);
+	if (dms)
+		dm_stats_destroy(dms);
+
 	return 0;
 }
 


