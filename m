From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 5 Mar 2019 08:53:03 -0500
Subject: stable-2.02 - cov: dm stats missed terminating null
Message-ID: <201903051353.x25Dr31j006633@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ece117ee102684dc5380d30b73e4b992689eb85f
Commit:        ece117ee102684dc5380d30b73e4b992689eb85f
Parent:        590a1ebcf78b8aae2a1e5ebaba1ac24a54435690
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 14:45:16 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Mar 5 12:10:36 2019 +0100

cov: dm stats missed terminating null

Coverity noticed allocating insufficient memory
for the terminating null of the string.

(cherry picked from commit 20971f7034cbd329f873e08869bfb7acf3f1ac0e)
---
 libdm/libdm-stats.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 6b4e3d8..479861e 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1009,7 +1009,7 @@ static int _stats_parse_list(struct dm_stats *dms, const char *resp)
 	 * dm_task_get_message_response() returns a 'const char *' but
 	 * since fmemopen also permits "w" it expects a 'char *'.
 	 */
-	if (!(list_rows = fmemopen((char *)resp, strlen(resp), "r")))
+	if (!(list_rows = fmemopen((char *)resp, strlen(resp) + 1, "r")))
 		return_0;
 
 	/* begin region table */
@@ -1240,7 +1240,7 @@ static int _stats_parse_region(struct dm_stats *dms, const char *resp,
 	 * dm_task_get_message_response() returns a 'const char *' but
 	 * since fmemopen also permits "w" it expects a 'char *'.
 	 */
-	stats_rows = fmemopen((char *)resp, strlen(resp), "r");
+	stats_rows = fmemopen((char *)resp, strlen(resp) + 1, "r");
 	if (!stats_rows)
 		goto_bad;
 


