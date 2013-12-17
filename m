From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 17 Dec 2013 14:17:36 +0000 (UTC)
Subject: master - device: use BLKPBSZGET for physical block size only if the op is available, otherwise use logical block size
Message-ID: <20131217141736.3BB1161018@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3652083f38ca21276c8467f54eeaa8f1365ec6fe
Commit:        3652083f38ca21276c8467f54eeaa8f1365ec6fe
Parent:        24639be558a9d4561a34f2b76485b227aed8e9c3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Dec 17 15:16:25 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Dec 17 15:17:28 2013 +0100

device: use BLKPBSZGET for physical block size only if the op is available, otherwise use logical block size

Older kernels < 2.6.32 don't have BLKPBSZGET defined.
---
 lib/device/dev-io.c |   25 ++++++++++++++++---------
 1 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 45700e5..766d9af 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -136,15 +136,6 @@ int dev_get_block_size(struct device *dev, unsigned int *physical_block_size, un
 	if (needs_open && !dev_open_readonly(dev))
 		return_0;
 
-	if (dev->phys_block_size == -1) {
-		if (ioctl(dev_fd(dev), BLKPBSZGET, &dev->phys_block_size) < 0) {
-			log_sys_error("ioctl BLKPBSZGET", name);
-			r = 0;
-			goto out;
-		}
-		log_debug_devs("%s: physical block size is %u bytes", name, dev->phys_block_size);
-	}
-
 	if (dev->block_size == -1) {
 		if (ioctl(dev_fd(dev), BLKBSZGET, &dev->block_size) < 0) {
 			log_sys_error("ioctl BLKBSZGET", name);
@@ -154,6 +145,22 @@ int dev_get_block_size(struct device *dev, unsigned int *physical_block_size, un
 		log_debug_devs("%s: block size is %u bytes", name, dev->block_size);
 	}
 
+#ifdef BLKPBSZGET
+	/* BLKPBSZGET is available in kernel >= 2.6.32 only */
+	if (dev->phys_block_size == -1) {
+		if (ioctl(dev_fd(dev), BLKPBSZGET, &dev->phys_block_size) < 0) {
+			log_sys_error("ioctl BLKPBSZGET", name);
+			r = 0;
+			goto out;
+		}
+		log_debug_devs("%s: physical block size is %u bytes", name, dev->phys_block_size);
+	}
+#else
+	/* if we can't get physical block size, just use logical block size instead */
+	dev->phys_block_size = dev->block_size;
+	log_debug_devs("%s: physical block size can't be determined, using logical "
+		       "block size of %u bytes instead", name, dev->phys_block_size);
+#endif
 	*physical_block_size = (unsigned int) dev->phys_block_size;
 	*block_size = (unsigned int) dev->block_size;
 out:


