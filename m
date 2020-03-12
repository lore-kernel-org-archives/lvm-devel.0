From: David Teigland <teigland@sourceware.org>
Date: Thu, 12 Mar 2020 15:22:21 +0000 (GMT)
Subject: master - reduce device path error messsages
Message-ID: <20200312152221.A85D439450E9@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=957904933b2b0f94eddc6204ca2fa61e2df741a0
Commit:        957904933b2b0f94eddc6204ca2fa61e2df741a0
Parent:        fbdcc45255497e2f926ac28ba33aa819d53f5c7c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 12 10:18:51 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 12 10:18:51 2020 -0500

reduce device path error messsages

When /dev entries or sysfs entries are changing
due to concurrent lvm commands, it can cause
warning/error messages about missing paths.
---
 lib/device/dev-cache.c | 9 +++++++--
 lib/device/dev-io.c    | 8 +++++---
 lib/device/dev-type.c  | 2 +-
 3 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index e17b13f01..6af559cab 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -357,12 +357,14 @@ static int _get_sysfs_value(const char *path, char *buf, size_t buf_size, int er
 	int r = 0;
 
 	if (!(fp = fopen(path, "r"))) {
-		log_sys_error("fopen", path);
+		if (error_if_no_value)
+			log_sys_error("fopen", path);
 		return 0;
 	}
 
 	if (!fgets(buf, buf_size, fp)) {
-		log_sys_error("fgets", path);
+		if (error_if_no_value)
+			log_sys_error("fgets", path);
 		goto out;
 	}
 
@@ -1460,6 +1462,7 @@ struct device *dev_cache_get(struct cmd_context *cmd, const char *name, struct d
 		_insert(name, info_available ? &buf : NULL, 0, obtain_device_list_from_udev());
 		d = (struct device *) dm_hash_lookup(_cache.names, name);
 		if (!d) {
+			log_debug_devs("Device name not found in dev_cache repeat dev_cache_scan for %s", name);
 			dev_cache_scan();
 			d = (struct device *) dm_hash_lookup(_cache.names, name);
 		}
@@ -1535,6 +1538,8 @@ struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t dev, struct
 			}
 		}
 
+		log_debug_devs("Device num not found in dev_cache repeat dev_cache_scan for %d:%d",
+				(int)MAJOR(dev), (int)MINOR(dev));
 		dev_cache_scan();
 		d = _dev_cache_seek_devt(dev);
 	}
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index dd65c3d2e..735441f19 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -94,7 +94,7 @@ static int _dev_get_size_dev(struct device *dev, uint64_t *size)
 	}
 
 	if (fd <= 0) {
-		if (!dev_open_readonly(dev))
+		if (!dev_open_readonly_quiet(dev))
 			return_0;
 		fd = dev_fd(dev);
 		do_close = 1;
@@ -128,8 +128,10 @@ static int _dev_read_ahead_dev(struct device *dev, uint32_t *read_ahead)
 		return 1;
 	}
 
-	if (!dev_open_readonly(dev))
+	if (!dev_open_readonly_quiet(dev)) {
+		log_error("Failed to open to get readahead %s", dev_name(dev));
 		return_0;
+	}
 
 	if (ioctl(dev->fd, BLKRAGET, &read_ahead_long) < 0) {
 		log_sys_error("ioctl BLKRAGET", dev_name(dev));
@@ -194,7 +196,7 @@ int dev_get_direct_block_sizes(struct device *dev, unsigned int *physical_block_
 	}
 
 	if (fd <= 0) {
-		if (!dev_open_readonly(dev))
+		if (!dev_open_readonly_quiet(dev))
 			return 0;
 		fd = dev_fd(dev);
 		do_close = 1;
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index fba4dc917..d225d4d90 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -86,7 +86,7 @@ int dev_is_lv(struct device *dev)
 		return 0;
 
 	if (!fgets(buffer, sizeof(buffer), fp))
-		log_warn("Failed to read %s.", path);
+		log_debug("Failed to read %s.", path);
 	else if (!strncmp(buffer, "LVM-", 4))
 		ret = 1;
 



