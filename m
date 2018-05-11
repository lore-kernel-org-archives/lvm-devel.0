From: David Teigland <teigland@sourceware.org>
Date: Fri, 11 May 2018 14:55:07 -0400
Subject: master - dev_cache: fix close in dev_get_block_size
Message-ID: <201805111855.w4BIt7XS027035@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ccab54677c9f92cf1bd11895251799c043a57602
Commit:        ccab54677c9f92cf1bd11895251799c043a57602
Parent:        bbb8040456a07a0c9076d45a8eee5e5f7fcde0ec
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 11 13:53:19 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 11 13:53:19 2018 -0500

dev_cache: fix close in dev_get_block_size

---
 lib/device/dev-io.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 903c582..8028306 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -198,7 +198,7 @@ int dev_get_block_size(struct device *dev, unsigned int *physical_block_size, un
 	*physical_block_size = (unsigned int) dev->phys_block_size;
 	*block_size = (unsigned int) dev->block_size;
 out:
-	if (needs_open && !dev_close(dev))
+	if (needs_open && !dev_close_immediate(dev))
 		stack;
 
 	return r;


