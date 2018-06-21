From: David Teigland <teigland@sourceware.org>
Date: Thu, 21 Jun 2018 10:22:56 -0400
Subject: 2018-06-01-stable - coverity warnings about null info in lvmcache.c
Message-ID: <201806211422.w5LEMu79006166@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dd075e93c1fa0f5686432b71290ffa340f74c28d
Commit:        dd075e93c1fa0f5686432b71290ffa340f74c28d
Parent:        d4fd39f64c64fb180606b8b9202119fa9c11b35d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 21 09:21:25 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 21 09:22:05 2018 -0500

coverity warnings about null info in lvmcache.c

---
 lib/cache/lvmcache.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 1b405e7..4f1ae1b 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1015,7 +1015,8 @@ static void _filter_duplicate_devs(struct cmd_context *cmd)
 
 	dm_list_iterate_items_safe(devl, devl2, &_unused_duplicate_devs) {
 
-		info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0);
+		if (!(info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0)))
+			continue;
 
 		if (MAJOR(info->dev->dev) == dt->md_major) {
 			log_debug_devs("Ignoring md component duplicate %s", dev_name(devl->dev));
@@ -1043,7 +1044,8 @@ static void _warn_duplicate_devs(struct cmd_context *cmd)
 
 	dm_list_iterate_items_safe(devl, devl2, &_unused_duplicate_devs) {
 		/* info for the preferred device that we're actually using */
-		info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0);
+		if (!(info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0)))
+			continue;
 
 		if (!id_write_format((const struct id *)info->dev->pvid, uuid, sizeof(uuid)))
 			stack;


