From: David Teigland <teigland@sourceware.org>
Date: Fri, 11 May 2018 15:38:51 -0400
Subject: master - dev_cache: fix close in utility functions
Message-ID: <201805111938.w4BJcpmC002982@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3e3cb22f2a115f71f883a75c7840ab271bd83454
Commit:        3e3cb22f2a115f71f883a75c7840ab271bd83454
Parent:        5c9dcd99fdd63b7113a19b799c69c207199ebdc2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 11 14:25:08 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 11 14:25:08 2018 -0500

dev_cache: fix close in utility functions

All these functions are now used as utilities,
e.g. for ioctl (not for io), and need to
open/close the device each time they are called.
(Many of the opens can probably be eliminated by
just using the bcache fd for the ioctl.)
---
 lib/device/dev-io.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 8028306..3a39ae5 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -348,7 +348,7 @@ static int _dev_get_size_dev(struct device *dev, uint64_t *size)
 
 	if (ioctl(fd, BLKGETSIZE64, size) < 0) {
 		log_sys_error("ioctl BLKGETSIZE64", name);
-		if (do_close && !dev_close(dev))
+		if (do_close && !dev_close_immediate(dev))
 			log_sys_error("close", name);
 		return 0;
 	}
@@ -359,7 +359,7 @@ static int _dev_get_size_dev(struct device *dev, uint64_t *size)
 
 	log_very_verbose("%s: size is %" PRIu64 " sectors", name, *size);
 
-	if (do_close && !dev_close(dev))
+	if (do_close && !dev_close_immediate(dev))
 		log_sys_error("close", name);
 
 	return 1;
@@ -379,7 +379,7 @@ static int _dev_read_ahead_dev(struct device *dev, uint32_t *read_ahead)
 
 	if (ioctl(dev->fd, BLKRAGET, &read_ahead_long) < 0) {
 		log_sys_error("ioctl BLKRAGET", dev_name(dev));
-		if (!dev_close(dev))
+		if (!dev_close_immediate(dev))
 			stack;
 		return 0;
 	}
@@ -390,7 +390,7 @@ static int _dev_read_ahead_dev(struct device *dev, uint32_t *read_ahead)
 	log_very_verbose("%s: read_ahead is %u sectors",
 			 dev_name(dev), *read_ahead);
 
-	if (!dev_close(dev))
+	if (!dev_close_immediate(dev))
 		stack;
 
 	return 1;
@@ -411,13 +411,13 @@ static int _dev_discard_blocks(struct device *dev, uint64_t offset_bytes, uint64
 	if (ioctl(dev->fd, BLKDISCARD, &discard_range) < 0) {
 		log_error("%s: BLKDISCARD ioctl@offset %" PRIu64 " size %" PRIu64 " failed: %s.",
 			  dev_name(dev), offset_bytes, size_bytes, strerror(errno));
-		if (!dev_close(dev))
+		if (!dev_close_immediate(dev))
 			stack;
 		/* It doesn't matter if discard failed, so return success. */
 		return 1;
 	}
 
-	if (!dev_close(dev))
+	if (!dev_close_immediate(dev))
 		stack;
 
 	return 1;


