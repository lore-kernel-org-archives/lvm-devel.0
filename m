From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 21 Apr 2016 23:18:40 +0000 (UTC)
Subject: master - coverity: use wider type for whole expression
Message-ID: <20160421231840.C7A69616D8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=447daa9179d94f86a972598e42eaab8b6913f3f7
Commit:        447daa9179d94f86a972598e42eaab8b6913f3f7
Parent:        edcb3e65c6398d4c4c70812b8209c8400c374099
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 22 00:14:40 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 22 01:12:34 2016 +0200

coverity: use wider type for whole expression

Coverity likes when the types are same through the whole expression.
And since dev_t is 64b - widen int type early.
---
 lib/device/dev-cache.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 7a124d0..06d44ce 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -491,7 +491,7 @@ static struct device *_get_device_for_sysfs_dev_name_using_devno(const char *dev
 		return NULL;
 	}
 
-	devno = MKDEV(major, minor);
+	devno = MKDEV((dev_t)major, (dev_t)minor);
 	if (!(dev = (struct device *) btree_lookup(_cache.devices, (uint32_t) devno))) {
 		/*
 		 * If we get here, it means the device is referenced in sysfs, but it's not yet in /dev.
@@ -851,7 +851,7 @@ static int _dev_cache_iterate_sysfs_for_index(const char *path)
 			continue;
 		}
 
-		devno = MKDEV(major, minor);
+		devno = MKDEV((dev_t)major, (dev_t)minor);
 		if (!(dev = (struct device *) btree_lookup(_cache.devices, (uint32_t) devno)) &&
 		    !(dev = (struct device *) btree_lookup(_cache.sysfs_only_devices, (uint32_t) devno))) {
 			if (!dm_device_get_name(major, minor, 1, devname, sizeof(devname)) ||


