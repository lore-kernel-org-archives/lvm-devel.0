From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 5 Mar 2019 08:53:18 -0500
Subject: stable-2.02 - revert "cov: dm stats missed terminating null"
Message-ID: <201903051353.x25DrIiU006685@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b39c26ddc335e308c10777ea423f341cb9e783b8
Commit:        b39c26ddc335e308c10777ea423f341cb9e783b8
Parent:        d1ae1455b48fb09c4530b3b823bf02df50450b18
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 16 19:13:34 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Mar 5 12:15:16 2019 +0100

revert "cov: dm stats missed terminating null"

This reverts commit 20971f7034cbd329f873e08869bfb7acf3f1ac0e
as the parsing of 'dmstatus' started to fail on present \0 char.

(cherry picked from commit 6179cab877442aac884a0bfcd5c5541396980cdf)
---
 libdm/libdm-stats.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 479861e..6b4e3d8 100644
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
 


