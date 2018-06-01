From: David Teigland <teigland@sourceware.org>
Date: Fri, 1 Jun 2018 14:16:11 -0400
Subject: master - devs: clear coverity warning about null info
Message-ID: <201806011816.w51IGB54002050@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0625c7f372a8481e21752b1fc930984ba7c900db
Commit:        0625c7f372a8481e21752b1fc930984ba7c900db
Parent:        09177b53dddadf89f976ad72ec293c61d0eee9ba
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 1 10:15:48 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 1 13:15:22 2018 -0500

devs: clear coverity warning about null info

a theoretical possibility.
---
 lib/cache/lvmcache.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 68170d8..527f0a6 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1010,7 +1010,8 @@ static void _filter_duplicate_devs(struct cmd_context *cmd)
 
 	dm_list_iterate_items_safe(devl, devl2, &_unused_duplicate_devs) {
 
-		info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0);
+		if (!(info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0)))
+			continue;
 
 		if (MAJOR(info->dev->dev) == dt->md_major) {
 			log_debug_devs("Ignoring md component duplicate %s", dev_name(devl->dev));
@@ -1038,7 +1039,8 @@ static void _warn_duplicate_devs(struct cmd_context *cmd)
 
 	dm_list_iterate_items_safe(devl, devl2, &_unused_duplicate_devs) {
 		/* info for the preferred device that we're actually using */
-		info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0);
+		if (!(info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0)))
+			continue;
 
 		if (!id_write_format((const struct id *)info->dev->pvid, uuid, sizeof(uuid)))
 			stack;


