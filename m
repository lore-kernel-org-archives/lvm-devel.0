From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 16 Oct 2018 15:56:59 -0400
Subject: master - revert "cov: dm stats missed terminating null"
Message-ID: <201810161956.w9GJuxLQ002184@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6179cab877442aac884a0bfcd5c5541396980cdf
Commit:        6179cab877442aac884a0bfcd5c5541396980cdf
Parent:        2217d6396aa6f6b8bc6421487ed6686d94668c2e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 16 19:13:34 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 16 21:34:23 2018 +0200

revert "cov: dm stats missed terminating null"

This reverts commit 20971f7034cbd329f873e08869bfb7acf3f1ac0e
as the parsing of 'dmstatus' started to fail on present \0 char.
---
 libdm/libdm-stats.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index ea8fdf2..e9bfa9d 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1009,7 +1009,7 @@ static int _stats_parse_list(struct dm_stats *dms, const char *resp)
 	 * dm_task_get_message_response() returns a 'const char *' but
 	 * since fmemopen also permits "w" it expects a 'char *'.
 	 */
-	if (!(list_rows = fmemopen((char *)resp, strlen(resp) + 1, "r")))
+	if (!(list_rows = fmemopen((char *)resp, strlen(resp), "r")))
 		return_0;
 
 	/* begin region table */
@@ -1240,7 +1240,7 @@ static int _stats_parse_region(struct dm_stats *dms, const char *resp,
 	 * dm_task_get_message_response() returns a 'const char *' but
 	 * since fmemopen also permits "w" it expects a 'char *'.
 	 */
-	stats_rows = fmemopen((char *)resp, strlen(resp) + 1, "r");
+	stats_rows = fmemopen((char *)resp, strlen(resp), "r");
 	if (!stats_rows)
 		goto_bad;
 


