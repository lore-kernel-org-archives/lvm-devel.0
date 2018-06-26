From: David Teigland <teigland@sourceware.org>
Date: Tue, 26 Jun 2018 13:16:59 -0400
Subject: 2018-06-01-stable - devs: use bcache fd for read ahead ioctl
Message-ID: <201806261716.w5QHGxu0005710@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f7ffba204e06ae432ae2c7943cb41eec5b8e8bb1
Commit:        f7ffba204e06ae432ae2c7943cb41eec5b8e8bb1
Parent:        90e419c645ac5ad3b82044fd3422f956442935a6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 26 12:05:39 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 26 12:15:43 2018 -0500

devs: use bcache fd for read ahead ioctl

to avoid an unnecessary open of the device in
most cases.
---
 lib/device/dev-io.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 9a03d3a..145093f 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -367,18 +367,24 @@ static int _dev_get_size_dev(struct device *dev, uint64_t *size)
 static int _dev_read_ahead_dev(struct device *dev, uint32_t *read_ahead)
 {
 	long read_ahead_long;
+	int fd = dev->bcache_fd;
+	int do_close = 0;
 
 	if (dev->read_ahead != -1) {
 		*read_ahead = (uint32_t) dev->read_ahead;
 		return 1;
 	}
 
-	if (!dev_open_readonly(dev))
-		return_0;
+	if (fd <= 0) {
+		if (!dev_open_readonly(dev))
+			return_0;
+		fd = dev_fd(dev);
+		do_close = 1;
+	}
 
-	if (ioctl(dev->fd, BLKRAGET, &read_ahead_long) < 0) {
+	if (ioctl(fd, BLKRAGET, &read_ahead_long) < 0) {
 		log_sys_error("ioctl BLKRAGET", dev_name(dev));
-		if (!dev_close_immediate(dev))
+		if (do_close && !dev_close_immediate(dev))
 			stack;
 		return 0;
 	}
@@ -389,8 +395,8 @@ static int _dev_read_ahead_dev(struct device *dev, uint32_t *read_ahead)
 	log_very_verbose("%s: read_ahead is %u sectors",
 			 dev_name(dev), *read_ahead);
 
-	if (!dev_close_immediate(dev))
-		stack;
+	if (do_close && !dev_close_immediate(dev))
+		log_sys_error("close", dev_name(dev));
 
 	return 1;
 }


