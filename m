From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 16 Oct 2018 15:57:07 -0400
Subject: master - cov: shutdown warning
Message-ID: <201810161957.w9GJv7JM002214@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=05b57748274492aa76e530e4513e5f8e9a39a735
Commit:        05b57748274492aa76e530e4513e5f8e9a39a735
Parent:        6179cab877442aac884a0bfcd5c5541396980cdf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 16 21:46:44 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 16 21:55:19 2018 +0200

cov: shutdown warning

Since previous patch reverted coverity patch as this case is intentional,
provide override this coverity warning.
---
 libdm/libdm-stats.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index e9bfa9d..0143957 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1009,6 +1009,7 @@ static int _stats_parse_list(struct dm_stats *dms, const char *resp)
 	 * dm_task_get_message_response() returns a 'const char *' but
 	 * since fmemopen also permits "w" it expects a 'char *'.
 	 */
+	/* coverity[alloc_strlen] intentional */
 	if (!(list_rows = fmemopen((char *)resp, strlen(resp), "r")))
 		return_0;
 
@@ -1240,6 +1241,7 @@ static int _stats_parse_region(struct dm_stats *dms, const char *resp,
 	 * dm_task_get_message_response() returns a 'const char *' but
 	 * since fmemopen also permits "w" it expects a 'char *'.
 	 */
+	/* coverity[alloc_strlen] intentional */
 	stats_rows = fmemopen((char *)resp, strlen(resp), "r");
 	if (!stats_rows)
 		goto_bad;


