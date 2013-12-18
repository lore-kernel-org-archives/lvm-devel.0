From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 18 Dec 2013 09:57:08 +0000 (UTC)
Subject: master - device: if BLKPBSZGET is unavailable, enforce 512
Message-ID: <20131218095708.E4F9D60559@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3c818c89467f9b54bc94d9919a127dd912d96c24
Commit:        3c818c89467f9b54bc94d9919a127dd912d96c24
Parent:        434d95cef31c4d95b6468e02397e1fedbdca9928
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 18 10:52:09 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 18 10:52:09 2013 +0100

device: if BLKPBSZGET is unavailable, enforce 512

If there is no define for BLKPBSZGET - we have hard time how to
decrypt physical block size - we can't use here block_size,
since this is usually 4k while we need to use 512b.

FIXME: find some better way, until that enforce value 512.
Eventually we could also try to put in:

+#ifndef BLKPBSZGET
+# define BLKPBSZGET _IO(0x12,123)
+#endif

but this will still not work well on old kernels.
---
 lib/device/dev-io.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 766d9af..1bfac1d 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -157,7 +157,8 @@ int dev_get_block_size(struct device *dev, unsigned int *physical_block_size, un
 	}
 #else
 	/* if we can't get physical block size, just use logical block size instead */
-	dev->phys_block_size = dev->block_size;
+	// FIXME block_size is typically 4096b while phys_block_size is 512b
+	dev->phys_block_size = 512;// dev->block_size;
 	log_debug_devs("%s: physical block size can't be determined, using logical "
 		       "block size of %u bytes instead", name, dev->phys_block_size);
 #endif


