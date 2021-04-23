From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:05:40 +0000 (GMT)
Subject: main - dev-cache: change message level to debug
Message-ID: <20210423210540.36554394480D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cfe26470e350580249f03025ae6bafbf2ab8e60b
Commit:        cfe26470e350580249f03025ae6bafbf2ab8e60b
Parent:        2b90466f78892c1e578c830a72566662d137dace
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 23 21:58:06 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 22:58:45 2021 +0200

dev-cache: change message level to debug

This case happens when i.e. we convert LV to another type,
when we change existing LV into a different type - so change
to debug level and avoid confusing users with message about
Device path  not match.

We may eventually enhnace caching code to drop cached info
after taking lock and reading VG.
---
 lib/device/dev-cache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 112296a81..aa93b5758 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1490,7 +1490,7 @@ struct device *dev_cache_get(struct cmd_context *cmd, const char *name, struct d
 	 * Remove incorrect info and then add new dev-cache entry.
 	 */
 	if (dev && (st.st_rdev != dev->dev)) {
-		log_print("Device path %s does not match %d:%d %s.",
+		log_debug("Device path %s does not match %d:%d %s.",
 			  name, (int)MAJOR(dev->dev), (int)MINOR(dev->dev), dev_name(dev));
 
 		dm_hash_remove(_cache.names, name);


