From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 5 Mar 2019 08:53:18 -0500
Subject: stable-2.02 - cov: shutdown warning
Message-ID: <201903051353.x25DrI2g006680@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f0f68791f31c8cf0ca2c4f0bbee86dd37a69494f
Commit:        f0f68791f31c8cf0ca2c4f0bbee86dd37a69494f
Parent:        b39c26ddc335e308c10777ea423f341cb9e783b8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 16 21:46:44 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Mar 5 12:15:40 2019 +0100

cov: shutdown warning

Since previous patch reverted coverity patch as this case is intentional,
provide override this coverity warning.

(cherry picked from commit 05b57748274492aa76e530e4513e5f8e9a39a735)
---
 libdm/libdm-stats.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 6b4e3d8..3078596 100644
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


