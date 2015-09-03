From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Sep 2015 12:39:04 +0000 (UTC)
Subject: master - dev-cache: append (major:minor) to debug messages about adding device or its alias to cache
Message-ID: <20150903123904.0858960D25@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d1d00fdeec04b1c856dfbe2d1ad8914e0968acfb
Commit:        d1d00fdeec04b1c856dfbe2d1ad8914e0968acfb
Parent:        00b610e5429582a4a62cdd2d475064dafab6fe87
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Sep 3 14:36:15 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Sep 3 14:36:15 2015 +0200

dev-cache: append (major:minor) to debug messages about adding device or its alias to cache

device/dev-cache.c:350         /dev/sda: Added to device cache (8:0)
device/dev-cache.c:346         /dev/disk/by-id/lvm-pv-uuid-5nPovF-EWp4-vBwd-ylCJ-9Y0B-yzHQ-ek1li2: Aliased to /dev/sda in device cache (8:0)
...
---
 lib/device/dev-cache.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 043a722..4ed0130 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -341,11 +341,13 @@ static int _add_alias(struct device *dev, const char *path)
 	if (!dm_list_empty(&dev->aliases)) {
 		oldpath = dm_list_item(dev->aliases.n, struct dm_str_list)->str;
 		prefer_old = _compare_paths(path, oldpath);
-		log_debug_devs("%s: Aliased to %s in device cache%s",
-			       path, oldpath, prefer_old ? "" : " (preferred name)");
+		log_debug_devs("%s: Aliased to %s in device cache%s (%d:%d)",
+			       path, oldpath, prefer_old ? "" : " (preferred name)",
+			       (int) MAJOR(dev->dev), (int) MINOR(dev->dev));
 
 	} else
-		log_debug_devs("%s: Added to device cache", path);
+		log_debug_devs("%s: Added to device cache (%d:%d)", path,
+			       (int) MAJOR(dev->dev), (int) MINOR(dev->dev));
 
 	if (prefer_old)
 		dm_list_add(&dev->aliases, &sl->list);


