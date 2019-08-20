From: David Teigland <teigland@sourceware.org>
Date: Tue, 20 Aug 2019 10:32:57 -0400
Subject: stable-2.02 - devices: put ifdef around BLKPBSZGET
Message-ID: <201908201432.x7KEWvPq029295@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f55b8e387fbff3697fccf42cbc29e17e96da22fb
Commit:        f55b8e387fbff3697fccf42cbc29e17e96da22fb
Parent:        53fcd4fd8fdca852bd8db079f943594c4deeded5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Aug 20 09:32:26 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Aug 20 09:32:26 2019 -0500

devices: put ifdef around BLKPBSZGET

BLKPBSZGET is not defined before kernel version 2.6.32
(e.g. rhel5)
---
 lib/device/dev-io.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index fd8d349..0289a17 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -156,6 +156,7 @@ int dev_get_direct_block_sizes(struct device *dev, unsigned int *physical_block_
 		do_close = 1;
 	}
 
+#ifdef BLKPBSZGET /* not defined before kernel version 2.6.32 (e.g. rhel5) */
 	/*
 	 * BLKPBSZGET from kernel comment for blk_queue_physical_block_size:
 	 * "the lowest possible sector size that the hardware can operate on
@@ -165,6 +166,7 @@ int dev_get_direct_block_sizes(struct device *dev, unsigned int *physical_block_
 		stack;
 		pbs = 0;
 	}
+#endif
 
 	/*
 	 * BLKSSZGET from kernel comment for blk_queue_logical_block_size:


