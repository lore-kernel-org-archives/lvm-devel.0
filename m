From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 18 Oct 2020 21:02:44 +0000 (GMT)
Subject: stable-2.02 - debug: update messages
Message-ID: <20201018210244.27371384A87E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5ad30c57b3415150f6b71b0828eedc3d92ea49a8
Commit:        5ad30c57b3415150f6b71b0828eedc3d92ea49a8
Parent:        b8454b59e1901404d184f6198c87307711f35471
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 29 23:48:45 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 18 21:28:13 2020 +0200

debug: update messages

---
 lib/device/dev-io.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 0289a1768..0c9829a03 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -412,7 +412,7 @@ static int _dev_get_size_dev(struct device *dev, uint64_t *size)
 	if (ioctl(fd, BLKGETSIZE64, size) < 0) {
 		log_sys_error("ioctl BLKGETSIZE64", name);
 		if (do_close && !dev_close_immediate(dev))
-			log_sys_error("close", name);
+			stack;
 		return 0;
 	}
 
@@ -423,7 +423,7 @@ static int _dev_get_size_dev(struct device *dev, uint64_t *size)
 	log_very_verbose("%s: size is %" PRIu64 " sectors", name, *size);
 
 	if (do_close && !dev_close_immediate(dev))
-		log_sys_error("close", name);
+		stack;
 
 	return 1;
 }
@@ -713,7 +713,7 @@ int dev_test_excl(struct device *dev)
 static void _close(struct device *dev)
 {
 	if (close(dev->fd))
-		log_sys_error("close", dev_name(dev));
+		log_sys_debug("close", dev_name(dev));
 	dev->fd = -1;
 	dev->phys_block_size = -1;
 	dev->block_size = -1;


