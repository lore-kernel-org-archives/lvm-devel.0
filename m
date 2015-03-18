From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 18 Mar 2015 15:22:13 +0000 (UTC)
Subject: master - pvscan: check sysfs dev entry before rescan
Message-ID: <20150318152214.01540610A3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=32a6c11877946bfc34a7af0821a793fd62f6bb36
Commit:        32a6c11877946bfc34a7af0821a793fd62f6bb36
Parent:        1260b86b2b76f5b1ab5fa6c0c324d8d6f3ba2173
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 18 16:19:58 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 18 16:19:58 2015 +0100

pvscan: check sysfs dev entry before rescan

When pvscan --cache --major --minor command is issued from
udev REMOVE event, it basically resulted into a whole device
scan since the device was missing. So avoid such scan
and first check via /sysfs (when available) if such device actually
exists.
---
 WHATS_NEW              |    1 +
 lib/device/dev-cache.c |   19 +++++++++++++++++++
 2 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 51307cb..7d0038a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.118 - 
 =================================
+  Avoid rescan of all devices when requested pvscan for removed device.
   Measure configuration timestamps with nanoseconds when available.
   Disable lvchange of major and minor of pool LVs.
   Fix pvscan --cache to not scan and read ignored metadata areas on PVs.
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 7ad9fb8..d594dd4 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -986,12 +986,31 @@ static struct device *_dev_cache_seek_devt(dev_t dev)
  */
 struct device *dev_cache_get_by_devt(dev_t dev, struct dev_filter *f)
 {
+	char path[PATH_MAX];
+	const char *sysfs_dir;
+	struct stat info;
 	struct device *d = _dev_cache_seek_devt(dev);
 
 	if (d && (d->flags & DEV_REGULAR))
 		return d;
 
 	if (!d) {
+		sysfs_dir = dm_sysfs_dir();
+		if (sysfs_dir && *sysfs_dir) {
+			/* First check if dev is sysfs to avoid useless scan */
+			if (dm_snprintf(path, sizeof(path), "%s/dev/block/%d:%d",
+					sysfs_dir, (int)MAJOR(dev), (int)MINOR(dev)) < 0) {
+				log_error("dm_snprintf partition failed.");
+				return NULL;
+			}
+
+			if (lstat(path, &info)) {
+				log_debug("No sysfs entry for %d:%d.",
+					  (int)MAJOR(dev), (int)MINOR(dev));
+				return NULL;
+			}
+		}
+
 		_full_scan(0);
 		d = _dev_cache_seek_devt(dev);
 	}


