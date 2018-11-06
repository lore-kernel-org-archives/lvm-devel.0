From: David Teigland <teigland@sourceware.org>
Date: Tue, 6 Nov 2018 17:36:40 -0500
Subject: master - devices: reuse bcache fd when getting block size
Message-ID: <201811062236.wA6MaeL5013526@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1dc5603f73940bc59d09afa67c2e8c4da0ce8526
Commit:        1dc5603f73940bc59d09afa67c2e8c4da0ce8526
Parent:        3ae55695708b5d702f21daf776607d30cebe69c3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 6 16:03:17 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 6 16:36:18 2018 -0600

devices: reuse bcache fd when getting block size

This avoids an unnecessary open() on the device.
---
 lib/device/dev-io.c |   27 +++++++++++++++++++--------
 1 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index dc95131..4460e55 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -148,16 +148,27 @@ static int _io(struct device_area *where, char *buffer, int should_write, dev_io
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
@@ -168,7 +179,7 @@ int dev_get_block_size(struct device *dev, unsigned int *physical_block_size, un
 #ifdef BLKPBSZGET
 	/* BLKPBSZGET is available in kernel >= 2.6.32 only */
 	if (dev->phys_block_size == -1) {
-		if (ioctl(dev_fd(dev), BLKPBSZGET, &dev->phys_block_size) < 0) {
+		if (ioctl(fd, BLKPBSZGET, &dev->phys_block_size) < 0) {
 			log_sys_error("ioctl BLKPBSZGET", name);
 			r = 0;
 			goto out;
@@ -178,7 +189,7 @@ int dev_get_block_size(struct device *dev, unsigned int *physical_block_size, un
 #elif defined (BLKSSZGET)
 	/* if we can't get physical block size, just use logical block size instead */
 	if (dev->phys_block_size == -1) {
-		if (ioctl(dev_fd(dev), BLKSSZGET, &dev->phys_block_size) < 0) {
+		if (ioctl(fd, BLKSSZGET, &dev->phys_block_size) < 0) {
 			log_sys_error("ioctl BLKSSZGET", name);
 			r = 0;
 			goto out;
@@ -196,7 +207,7 @@ int dev_get_block_size(struct device *dev, unsigned int *physical_block_size, un
 	*physical_block_size = (unsigned int) dev->phys_block_size;
 	*block_size = (unsigned int) dev->block_size;
 out:
-	if (needs_open && !dev_close_immediate(dev))
+	if (do_close && !dev_close_immediate(dev))
 		stack;
 
 	return r;


