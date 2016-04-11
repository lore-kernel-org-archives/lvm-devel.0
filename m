From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 11 Apr 2016 08:35:23 +0000 (UTC)
Subject: master - devcache: do not insert devices without device node
Message-ID: <20160411083523.B87D660F5C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fe65a86cbc98bb38014b238266a7732de42d0aa1
Commit:        fe65a86cbc98bb38014b238266a7732de42d0aa1
Parent:        07a60b59f789e089761170f977defbd38defacef
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 11 10:08:16 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 11 10:33:14 2016 +0200

devcache: do not insert devices without device node

When not obtaining device from udev, we are doing deep devdir scan,
and at the same time we try to insert everything what /sys/dev/block
knows about. However in case  lvm2 is configured to use nonstardard
devdir this way it will see (and scan) devices from a real system.

lvm2 test suite is using its own test devdir with its
own device nodes. To avoid touching real /dev  devices, validate
the device node exist in give dir and do not insert such device
into a cache.

With obtain list from udev this patch has no effect
(the normal user path).
---
 WHATS_NEW              |    1 +
 lib/device/dev-cache.c |    9 +++++++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 777c44e..f4eb6ad 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.151
 =================================
+  When not obtaining devs from udev, check they exist before caching them.
   Detect device mismatch also when compiling without udev support.
 
 Version 2.02.150 - 9th April 2016
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 84471ab..6abb6a7 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -433,6 +433,8 @@ static struct dm_list *_get_or_add_list_by_index_key(struct dm_hash_table *idx,
 
 static struct device *_insert_sysfs_dev(dev_t devno, const char *devname)
 {
+	static struct device _fake_dev = { .flags = DEV_USED_FOR_LV };
+	struct stat stat0;
 	char path[PATH_MAX];
 	char *path_copy;
 	struct device *dev;
@@ -442,6 +444,13 @@ static struct device *_insert_sysfs_dev(dev_t devno, const char *devname)
 		return NULL;
 	}
 
+	if (lstat(path, &stat0) < 0) {
+		/* When device node does not exist return fake entry.
+		 * This may happen when i.e. lvm2 device dir != /dev */
+		log_debug("%s: Not available device node", path);
+		return &_fake_dev;
+	}
+
 	if (!(dev = _dev_create(devno)))
 		return_NULL;
 


