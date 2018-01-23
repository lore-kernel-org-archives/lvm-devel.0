From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 Jan 2018 05:46:32 -0500
Subject: master - debug: drop DEBUG_MEM path
Message-ID: <201801231046.w0NAkWpi027010@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6e9148e7ab8d073c448ed56c5e2e019751feff88
Commit:        6e9148e7ab8d073c448ed56c5e2e019751feff88
Parent:        2ee105089a261f5db2ba8b93c30708ba66dd1a01
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 23 11:41:53 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 23 11:45:18 2018 +0100

debug: drop DEBUG_MEM path

Memory is not allocated so no DEBUG_MEM part is needed.
---
 lib/device/dev-io.c |   18 +-----------------
 1 files changed, 1 insertions(+), 17 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 0137d5d..c466612 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -303,7 +303,7 @@ static int _aligned_io(struct device_area *where, char *write_buffer,
 	} 
 
 	devbuf = DEV_DEVBUF(where->dev, reason);
- 	_release_devbuf(devbuf);
+	_release_devbuf(devbuf);
 	devbuf->where.dev = where->dev;
 	devbuf->where.start = widened.start;
 	devbuf->where.size = widened.size;
@@ -317,24 +317,8 @@ static int _aligned_io(struct device_area *where, char *write_buffer,
 		/* Perform the I/O directly. */
 		devbuf->buf = write_buffer;
 	else
-#ifndef DEBUG_MEM
 		/* Postpone buffer allocation until we're about to issue the I/O */
 		devbuf->buf = NULL;
-#else
-	else {
-		/* Allocate a bounce buffer with an extra block */
-		if (!(devbuf->malloc_address = devbuf->buf = dm_malloc((size_t) devbuf->where.size + block_size))) {
-			log_error("Bounce buffer malloc failed");
-			return 0;
-		}
-
-		/*
-		 * Realign start of bounce buffer (using the extra sector)
-		 */
-		if (((uintptr_t) devbuf->buf) & mask)
-			devbuf->buf = (char *) ((((uintptr_t) devbuf->buf) + mask) & ~mask);
-	}
-#endif
 
 	devbuf->write = 0;
 


