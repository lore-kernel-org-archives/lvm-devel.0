From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  4 Sep 2015 16:04:09 +0000 (UTC)
Subject: master - dev-cache: fix use of uninitialized device status if reading outdated .cache record
Message-ID: <20150904160409.A610060FCE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=55c13f3de4a8b709b950297369182cd81a6c738f
Commit:        55c13f3de4a8b709b950297369182cd81a6c738f
Parent:        96948540825d8b3f8e89cbf22527a2d3d8435667
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Sep 4 18:00:29 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Sep 4 18:00:29 2015 +0200

dev-cache: fix use of uninitialized device status if reading outdated .cache record

As part of fix that came with cf700151eba483aeedbf790fd66ce1c44e19c707,
I forgot to add the check whether the result of stat was successful or
not. This bug caused uninitialized buffer to be used for entries
from .cache file which are no longer valid.

This bug may have caused these uninitialized values to be used further,
for example (see the unreal (2567,590944) representing major:minor
pair):

$ pvs
  /dev/abc: stat failed: No such file or directory
  Path /dev/abc no longer valid for device(2567,590944)
  PV               VG   Fmt  Attr PSize   PFree
  /dev/mapper/test      lvm2 ---  104.00m 104.00m
  /dev/vda2        rhel lvm2 a--    9.51g      0
---
 WHATS_NEW              |    1 +
 lib/device/dev-cache.c |    6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 887fafd..9ff1ce2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.130 - 
 ===================================
+  Fix use of uninitialized device status if reading outdated .cache record.
   Restore support for --monitor option in lvcreate (2.02.112).
   Read thin-pool data and metadata percent without flush.
   Detect blocked thin-pool and avoid scanning their thin volumes.
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 4ed0130..b9d4271 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -948,6 +948,7 @@ struct device *dev_cache_get(const char *name, struct dev_filter *f)
 {
 	struct stat buf;
 	struct device *d = (struct device *) dm_hash_lookup(_cache.names, name);
+	int info_available = 0;
 
 	if (d && (d->flags & DEV_REGULAR))
 		return d;
@@ -958,7 +959,8 @@ struct device *dev_cache_get(const char *name, struct dev_filter *f)
 			dm_hash_remove(_cache.names, name);
 		log_sys_very_verbose("stat", name);
 		d = NULL;
-	}
+	} else
+		info_available = 1;
 
 	if (d && (buf.st_rdev != d->dev)) {
 		dm_hash_remove(_cache.names, name);
@@ -966,7 +968,7 @@ struct device *dev_cache_get(const char *name, struct dev_filter *f)
 	}
 
 	if (!d) {
-		_insert(name, &buf, 0, obtain_device_list_from_udev());
+		_insert(name, info_available ? &buf : NULL, 0, obtain_device_list_from_udev());
 		d = (struct device *) dm_hash_lookup(_cache.names, name);
 		if (!d) {
 			_full_scan(0);


