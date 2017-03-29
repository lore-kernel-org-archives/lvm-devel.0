From: Bryn Reeves <bmr@sourceware.org>
Date: Wed, 29 Mar 2017 16:16:57 -0400
Subject: master - dmsetup: always close fd when leaving _stats_update_file() (coverity)
Message-ID: <201703292016.v2TKGvJc000887@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5994ed9df218d4201415855b9bd6defa6f371c74
Commit:        5994ed9df218d4201415855b9bd6defa6f371c74
Parent:        11749e7adbafc36452451de0f73a6a5197c73810
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 18:27:11 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Mar 29 18:34:57 2017 +0100

dmsetup: always close fd when leaving _stats_update_file() (coverity)

---
 tools/dmsetup.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index a6ed172..5f07ab6 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -5730,11 +5730,6 @@ fallback:
 	 */
 	regions = dm_stats_update_regions_from_fd(dms, fd, group_id);
 
-	if (close(fd))
-		log_error("Error closing %s", abspath);
-
-	fd = -1;
-
 	if (!regions) {
 		log_error("Could not update regions from file %s", abspath);
 		goto bad;
@@ -5753,6 +5748,9 @@ fallback:
 	       path, group_id, count);
 
 out:
+	if (close(fd))
+		log_error("Error closing %s", abspath);
+
 	dm_free(regions);
 	dm_free(abspath);
 	dm_stats_destroy(dms);


