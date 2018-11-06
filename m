From: David Teigland <teigland@sourceware.org>
Date: Tue, 6 Nov 2018 17:42:19 -0500
Subject: 2018-06-01-stable - devices: reuse bcache fd when getting block size
Message-ID: <201811062242.wA6MgJFU014494@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9799c8da07b77844451c64bcbbce0d9d43ce2552
Commit:        9799c8da07b77844451c64bcbbce0d9d43ce2552
Parent:        613466aa8f315468d34f45a75c662335abbdab2f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 6 16:03:17 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 6 16:41:04 2018 -0600

devices: reuse bcache fd when getting block size

This avoids an unnecessary open() on the device.
---
 lib/device/dev-io.c |   27 +++++++++++++++++++--------
 1 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 2a4967f..2a83a96 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -149,16 +149,27 @@ static int _io(struct device_area *where, char *buffer, int should_write, dev_io
 int dev_get_block_size(struct device *dev, unsigned int *physical_block_size, unsigned int *block_size)
 {
 	const char *name = dev_name(dev);
-	int needs_open;
+	int fd = dev->bcache_fd;
+	int do_close = 0;
 	int r = 1;
 
-	needs_open = (!dev->open_count && (dev->phys_block_size == -1 || dev->block_size == -1));
+	if ((dev->phys_block_size > 0) && (dev->block_size > 0)) {
+		*physical_block_size = (unsigned int)dev->phys_block_size;
+		*block_size = (unsigned int)dev->block_size;
+		return 1;
+	}
 
-	if (needs_open && !dev_open_readonly(dev))
-		return_0;
+	if (fd <= 0) {
+		if (!dev->open_count) {
+			if (!dev_open_readonly(dev))
+				return_0;
+			do_close = 1;
+		}
+		fd = dev_fd(dev);
+	}
 
 	if (dev->block_size == -1) {
-		if (ioctl(dev_fd(dev), BLKBSZGET, &dev->block_size) < 0) {
+		if (ioctl(fd, BLKBSZGET, &dev->block_size) < 0) {
 			log_sys_error("ioctl BLKBSZGET", name);
 			r = 0;
 			goto out;
@@ -169,7 +180,7 @@ int dev_get_block_size(struct device *dev, unsigned int *physical_block_size, un
 #ifdef BLKPBSZGET
 	/* BLKPBSZGET is available in kernel >= 2.6.32 only */
 	if (dev->phys_block_size == -1) {
-		if (ioctl(dev_fd(dev), BLKPBSZGET, &dev->phys_block_size) < 0) {
+		if (ioctl(fd, BLKPBSZGET, &dev->phys_block_size) < 0) {
 			log_sys_error("ioctl BLKPBSZGET", name);
 			r = 0;
 			goto out;
@@ -179,7 +190,7 @@ int dev_get_block_size(struct device *dev, unsigned int *physical_block_size, un
 #elif defined (BLKSSZGET)
 	/* if we can't get physical block size, just use logical block size instead */
 	if (dev->phys_block_size == -1) {
-		if (ioctl(dev_fd(dev), BLKSSZGET, &dev->phys_block_size) < 0) {
+		if (ioctl(fd, BLKSSZGET, &dev->phys_block_size) < 0) {
 			log_sys_error("ioctl BLKSSZGET", name);
 			r = 0;
 			goto out;
@@ -197,7 +208,7 @@ int dev_get_block_size(struct device *dev, unsigned int *physical_block_size, un
 	*physical_block_size = (unsigned int) dev->phys_block_size;
 	*block_size = (unsigned int) dev->block_size;
 out:
-	if (needs_open && !dev_close_immediate(dev))
+	if (do_close && !dev_close_immediate(dev))
 		stack;
 
 	return r;


