From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 30 Mar 2017 05:03:56 -0400
Subject: master - dmsetup: simplify branching in _stats_update_file()
Message-ID: <201703300903.v2U93uB6019879@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fe0922b8a6632456d9f20085f1c67d2ddb5b2d88
Commit:        fe0922b8a6632456d9f20085f1c67d2ddb5b2d88
Parent:        803b1775ba06218ad193402a13e6da4b3406511a
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 18:30:16 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Mar 30 09:57:58 2017 +0100

dmsetup: simplify branching in _stats_update_file()

The fallback branch in _stats_update_file() is redundant (since the
branch taken when the daemon starts successfully must jump to the
'out' label anyway): remove it and re-order the conditions to
improve readability.
---
 tools/dmsetup.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 5f07ab6..d25b3bd 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -5716,17 +5716,18 @@ static int _stats_update_file(CMD_ARGS)
 	 * If starting the daemon fails, fall back to a direct update.
 	 */
 	if (!_switches[NOMONITOR_ARG]) {
-		if (!dm_stats_start_filemapd(fd, group_id, abspath, mode,
-					     foreground, verbose)) {
-			log_warn("Failed to start filemap monitoring daemon.");
-			goto fallback;
-		}
-		goto out;
+		if (dm_stats_start_filemapd(fd, group_id, abspath, mode,
+					    foreground, verbose))
+			goto out;
+
+		log_warn("Failed to start filemap monitoring daemon.");
+
+		/* fall back to one-shot update */
 	}
 
-fallback:
 	/*
-	 * --nomonitor case - perform a one-shot update directly from dmstats.
+	 * --nomonitor and fall back case - perform a one-shot update directly
+	 *  from dmsetup.
 	 */
 	regions = dm_stats_update_regions_from_fd(dms, fd, group_id);
 


