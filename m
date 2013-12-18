From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 18 Dec 2013 12:53:04 +0000 (UTC)
Subject: master - device: if BLKPBSZGET is unavailable, try to use BLKSSZGET with fallback to 512b
Message-ID: <20131218125304.77EA160F4A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f270bbd442b3c36115ea490ec838cf29277a46d2
Commit:        f270bbd442b3c36115ea490ec838cf29277a46d2
Parent:        359291b41cdeb1ca886e018aa44c67882da10252
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Dec 18 13:52:01 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Dec 18 13:52:01 2013 +0100

device: if BLKPBSZGET is unavailable, try to use BLKSSZGET with fallback to 512b

---
 lib/device/dev-io.c |   23 ++++++++++++++++++-----
 1 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 1bfac1d..82cc2fc 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -155,13 +155,26 @@ int dev_get_block_size(struct device *dev, unsigned int *physical_block_size, un
 		}
 		log_debug_devs("%s: physical block size is %u bytes", name, dev->phys_block_size);
 	}
-#else
+#elif BLKSSZGET
 	/* if we can't get physical block size, just use logical block size instead */
-	// FIXME block_size is typically 4096b while phys_block_size is 512b
-	dev->phys_block_size = 512;// dev->block_size;
-	log_debug_devs("%s: physical block size can't be determined, using logical "
-		       "block size of %u bytes instead", name, dev->phys_block_size);
+	if (dev->phys_block_size == -1) {
+		if (ioctl(dev_fd(dev), BLKSSZGET, &dev->phys_block_size) < 0) {
+			log_sys_error("ioctl BLKSSZGET", name);
+			r = 0;
+			goto out;
+		}
+		log_debug_devs("%s: physical block size can't be determined, using logical "
+			       "block size of %u bytes", name, dev->phys_block_size);
+	}
+#else
+	/* if even BLKSSZGET is not available, use default 512b */
+	if (dev->phys_block_size == -1) {
+		dev->phys_block_size = 512;
+		log_debug_devs("%s: physical block size can't be determined, using block "
+			       "size of %u bytes instead", name, dev->phys_block_size);
+	}
 #endif
+
 	*physical_block_size = (unsigned int) dev->phys_block_size;
 	*block_size = (unsigned int) dev->block_size;
 out:


