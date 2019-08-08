From: David Teigland <teigland@sourceware.org>
Date: Thu, 8 Aug 2019 16:45:33 -0400
Subject: master - devices: put ifdef around BLKPBSZGET
Message-ID: <201908082045.x78KjXNQ013825@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=eb6aa5fefee0793bf4122640a2a53ed70602e4cc
Commit:        eb6aa5fefee0793bf4122640a2a53ed70602e4cc
Parent:        09bc2d0fd15a5bbb5d1e8d6ce79bd786ffed42b3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 8 15:43:09 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 8 15:45:03 2019 -0500

devices: put ifdef around BLKPBSZGET

BLKPBSZGET is not defined before kernel version 2.6.32
(e.g. rhel5)
---
 lib/device/dev-io.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 8a9ed5c..dd65c3d 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -200,6 +200,7 @@ int dev_get_direct_block_sizes(struct device *dev, unsigned int *physical_block_
 		do_close = 1;
 	}
 
+#ifdef BLKPBSZGET /* not defined before kernel version 2.6.32 (e.g. rhel5) */
 	/*
 	 * BLKPBSZGET from kernel comment for blk_queue_physical_block_size:
 	 * "the lowest possible sector size that the hardware can operate on
@@ -209,6 +210,7 @@ int dev_get_direct_block_sizes(struct device *dev, unsigned int *physical_block_
 		stack;
 		pbs = 0;
 	}
+#endif
 
 	/*
 	 * BLKSSZGET from kernel comment for blk_queue_logical_block_size:


