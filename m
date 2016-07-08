From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 18:26:57 +0000 (UTC)
Subject: master - dmstats: allow --bounds with 'create --filemap'
Message-ID: <20160708182657.69465610E4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bce1bc4ca34a72389f78e10e968417c8d60ef856
Commit:        bce1bc4ca34a72389f78e10e968417c8d60ef856
Parent:        4bb57341bd99a7d1af1a6a9ed84122369f362ba0
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Jul 7 09:48:09 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 17:27:52 2016 +0100

dmstats: allow --bounds with 'create --filemap'

---
 tools/dmsetup.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 637a82a..b31788c 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4882,7 +4882,9 @@ static char *_get_abspath(const char *path)
 static int _stats_create_file(CMD_ARGS)
 {
 	const char *alias, *program_id = DM_STATS_PROGRAM_ID;
+	const char *histogram = _string_args[BOUNDS_ARG];
 	uint64_t *regions, *region, count = 0;
+	struct dm_histogram *bounds = NULL;
 	char *path, *abspath = NULL;
 	int group, fd, precise;
 	struct dm_stats *dms;
@@ -4907,11 +4909,6 @@ static int _stats_create_file(CMD_ARGS)
 		return 0;
 	}
 
-	if (_switches[BOUNDS_ARG]) {
-		log_error("--bounds is not yet supported with --filemap.");
-		return 0;
-	}
-
 	/* _stats_create_file does not use _process_all() */
 	if (names) {
 		log_error("Device argument not compatible with --filemap.");
@@ -4945,6 +4942,9 @@ static int _stats_create_file(CMD_ARGS)
 		}
 	}
 
+	if (histogram && !(bounds = dm_histogram_bounds_from_string(histogram)))
+		return_0;
+
 	if (_switches[PROGRAM_ID_ARG])
 		program_id = _string_args[PROGRAM_ID_ARG];
 	if (!strlen(program_id) && !_switches[FORCE_ARG])
@@ -4988,7 +4988,7 @@ static int _stats_create_file(CMD_ARGS)
 	}
 
 	regions = dm_stats_create_regions_from_fd(dms, fd, group, precise,
-						  NULL, alias);
+						  bounds, alias);
 
 	if (close(fd))
 		log_error("Error closing %s", path);


