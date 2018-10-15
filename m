From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:55:06 -0400
Subject: master - cov: dm stats missed terminating null
Message-ID: <201810151555.w9FFt6X9020540@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=20971f7034cbd329f873e08869bfb7acf3f1ac0e
Commit:        20971f7034cbd329f873e08869bfb7acf3f1ac0e
Parent:        77aa055e8a34eb7f0036b6240f3f93dc429c0c02
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 14:45:16 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:44 2018 +0200

cov: dm stats missed terminating null

Coverity noticed allocating insufficient memory
for the terminating null of the string.
---
 libdm/libdm-stats.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index e9bfa9d..ea8fdf2 100644
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
 


