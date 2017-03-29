From: Bryn Reeves <bmr@sourceware.org>
Date: Wed, 29 Mar 2017 16:16:52 -0400
Subject: master - dmsetup: do not start dmfilemapd if region creation fails (coverity)
Message-ID: <201703292016.v2TKGqJX000877@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=11749e7adbafc36452451de0f73a6a5197c73810
Commit:        11749e7adbafc36452451de0f73a6a5197c73810
Parent:        6740eb1c2b8cde6aabce0d9b0847c01b69210065
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 18:21:17 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Mar 29 18:34:51 2017 +0100

dmsetup: do not start dmfilemapd if region creation fails (coverity)

---
 tools/dmsetup.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 94787dc..a6ed172 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -5110,6 +5110,11 @@ static int _stats_create_file(CMD_ARGS)
 	regions = dm_stats_create_regions_from_fd(dms, fd, group, precise,
 						  bounds, alias);
 
+	if (!regions) {
+		log_error("Could not create regions from file %s", abspath);
+		goto bad;
+	}
+
 	if (!_switches[NOMONITOR_ARG] && group) {
 		if (!dm_stats_start_filemapd(fd, regions[0], abspath, mode,
 					     foreground, verbose))
@@ -5121,11 +5126,6 @@ static int _stats_create_file(CMD_ARGS)
 
 	fd = -1;
 
-	if (!regions) {
-		log_error("Could not create regions from file %s", abspath);
-		goto bad;
-	}
-
 	for (region = regions; *region != DM_STATS_REGIONS_ALL; region++)
 		count++;
 


