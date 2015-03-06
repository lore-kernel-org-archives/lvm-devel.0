From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  6 Mar 2015 13:31:31 +0000 (UTC)
Subject: master - devices: avoid extra open() syscall
Message-ID: <20150306133131.7816B606F1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6f68f4364b537cf52a27b5e53bb7f10de5a938fe
Commit:        6f68f4364b537cf52a27b5e53bb7f10de5a938fe
Parent:        b48ff3b94e7cd771bbaf42f38b546054d02bc0f2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 3 15:37:17 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 6 13:17:39 2015 +0100

devices: avoid extra open() syscall

If the device is already opened by lvm's device cache,
avoid extra syscall opening devices for obtaining its size.
---
 WHATS_NEW           |    1 +
 lib/device/dev-io.c |   17 +++++++----------
 lib/device/device.h |    2 +-
 lib/report/report.c |    2 +-
 4 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 46783e1..b62a632 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.118 - 
 =================================
+  Save extra device open/close when scanning device for size.
   Fix seg_monitor field to report status also for mirrors and thick snapshots.
 
 Version 2.02.117 - 4th March 2015
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 122b616..d712f31 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -289,25 +289,22 @@ static int _dev_get_size_file(const struct device *dev, uint64_t *size)
 	return 1;
 }
 
-static int _dev_get_size_dev(const struct device *dev, uint64_t *size)
+static int _dev_get_size_dev(struct device *dev, uint64_t *size)
 {
-	int fd;
 	const char *name = dev_name(dev);
 
-	if ((fd = open(name, O_RDONLY)) < 0) {
-		log_sys_error("open", name);
-		return 0;
-	}
+	if (!dev_open_readonly(dev))
+		return_0;
 
-	if (ioctl(fd, BLKGETSIZE64, size) < 0) {
+	if (ioctl(dev_fd(dev), BLKGETSIZE64, size) < 0) {
 		log_sys_error("ioctl BLKGETSIZE64", name);
-		if (close(fd))
+		if (!dev_close(dev))
 			log_sys_error("close", name);
 		return 0;
 	}
 
 	*size >>= BLKSIZE_SHIFT;	/* Convert to sectors */
-	if (close(fd))
+	if (!dev_close(dev))
 		log_sys_error("close", name);
 
 	log_very_verbose("%s: size is %" PRIu64 " sectors", name, *size);
@@ -377,7 +374,7 @@ static int _dev_discard_blocks(struct device *dev, uint64_t offset_bytes, uint64
  * Public functions
  *---------------------------------------------------------------*/
 
-int dev_get_size(const struct device *dev, uint64_t *size)
+int dev_get_size(struct device *dev, uint64_t *size)
 {
 	if (!dev)
 		return 0;
diff --git a/lib/device/device.h b/lib/device/device.h
index 0d38f96..dcc3713 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -94,7 +94,7 @@ int dev_ext_release(struct device *dev);
  * All io should use these routines.
  */
 int dev_get_block_size(struct device *dev, unsigned int *phys_block_size, unsigned int *block_size);
-int dev_get_size(const struct device *dev, uint64_t *size);
+int dev_get_size(struct device *dev, uint64_t *size);
 int dev_get_read_ahead(struct device *dev, uint32_t *read_ahead);
 int dev_discard_blocks(struct device *dev, uint64_t offset_bytes, uint64_t size_bytes);
 
diff --git a/lib/report/report.c b/lib/report/report.c
index 4ef2b04..86b0a54 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -965,7 +965,7 @@ static int _devsize_disp(struct dm_report *rh, struct dm_pool *mem,
 			 struct dm_report_field *field,
 			 const void *data, void *private)
 {
-	const struct device *dev = *(const struct device * const *) data;
+	struct device *dev = *(struct device * const *) data;
 	uint64_t size;
 
 	if (!dev || !dev->dev || !dev_get_size(dev, &size))


