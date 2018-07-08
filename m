From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 8 Jul 2018 18:36:51 -0400
Subject: 2018-06-01-stable - dev_io: no discard in testmode
Message-ID: <201807082236.w68MapYa017271@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b8a7f6ba3de6aed38c2969693b6064a943ea8799
Commit:        b8a7f6ba3de6aed38c2969693b6064a943ea8799
Parent:        0851ee5301ca69bf7038f529d2335c93833db758
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 8 21:11:01 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 00:35:34 2018 +0200

dev_io: no discard in testmode

When lvm2 command is executed in test mode, discard ioctl is skipped.
This may cause even data-loose in case, issuing discard for released
areas was enabled and user 'tested'  lvreduce.
---
 lib/device/dev-io.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 145093f..2a4967f 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -411,9 +411,11 @@ static int _dev_discard_blocks(struct device *dev, uint64_t offset_bytes, uint64
 	discard_range[0] = offset_bytes;
 	discard_range[1] = size_bytes;
 
-	log_debug_devs("Discarding %" PRIu64 " bytes offset %" PRIu64 " bytes on %s.",
-		       size_bytes, offset_bytes, dev_name(dev));
-	if (ioctl(dev->fd, BLKDISCARD, &discard_range) < 0) {
+	log_debug_devs("Discarding %" PRIu64 " bytes offset %" PRIu64 " bytes on %s. %s",
+		       size_bytes, offset_bytes, dev_name(dev),
+		       test_mode() ? " (test mode - suppressed)" : "");
+
+	if (!test_mode() && ioctl(dev->fd, BLKDISCARD, &discard_range) < 0) {
 		log_error("%s: BLKDISCARD ioctl@offset %" PRIu64 " size %" PRIu64 " failed: %s.",
 			  dev_name(dev), offset_bytes, size_bytes, strerror(errno));
 		if (!dev_close_immediate(dev))


