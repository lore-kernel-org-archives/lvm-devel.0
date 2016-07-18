From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 18 Jul 2016 17:49:59 +0000 (UTC)
Subject: master - dmstats: free bounds string in _stats_create_file() (Coverity)
Message-ID: <20160718174959.CA47A60158@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=da146ae9b90b90607324672207d1be37f16b0e7a
Commit:        da146ae9b90b90607324672207d1be37f16b0e7a
Parent:        4ef1f345498045b6757247dc64baad8252260583
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Jul 18 18:17:42 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Jul 18 18:48:34 2016 +0100

dmstats: free bounds string in _stats_create_file() (Coverity)

---
 tools/dmsetup.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index e21d195..a282572 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -5012,8 +5012,15 @@ static int _stats_create_file(CMD_ARGS)
 		}
 	}
 
-	if (histogram && !(bounds = dm_histogram_bounds_from_string(histogram)))
+	if (!(abspath = _get_abspath(path))) {
+		log_error("Could not canonicalize file name: %s", path);
+		return 0;
+	}
+
+	if (histogram && !(bounds = dm_histogram_bounds_from_string(histogram))) {
+		dm_free(abspath);
 		return_0;
+	}
 
 	if (_switches[PROGRAM_ID_ARG])
 		program_id = _string_args[PROGRAM_ID_ARG];
@@ -5023,11 +5030,6 @@ static int _stats_create_file(CMD_ARGS)
 	precise = _int_args[PRECISE_ARG];
 	group = !_switches[NOGROUP_ARG];
 
-	if (!(abspath = _get_abspath(path))) {
-		log_error("Could not canonicalize file name: %s", path);
-		return 0;
-	}
-
 	if (!(dms = dm_stats_create(DM_STATS_PROGRAM_ID)))
 		return_0;
 
@@ -5089,8 +5091,7 @@ static int _stats_create_file(CMD_ARGS)
 	return 1;
 
 bad:
-	if (abspath)
-		dm_free(abspath);
+	dm_free(abspath);
 
 	if ((fd > -1) && close(fd))
 		log_error("Error closing %s", path);


