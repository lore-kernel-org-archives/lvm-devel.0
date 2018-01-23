From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 Jan 2018 07:38:13 -0500
Subject: master - dev_io: fix writes for unaligned buffers
Message-ID: <201801231238.w0NCcDic016742@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a1cfef9f26a47bf414240b8c87865caf6ac15092
Commit:        a1cfef9f26a47bf414240b8c87865caf6ac15092
Parent:        102926ed9fb231fbe54d020dcc5873bf97c09e51
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 23 13:36:12 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 23 13:36:12 2018 +0100

dev_io: fix writes for unaligned buffers

Actually the removed code is necessary - since not all writes are
getting alligned buffer - older compilers seems to be not able
to create 4K aligned buffers on stack - this the aligning code still
need to be present for write path.
---
 lib/device/dev-io.c |   17 ++++++++++++++---
 1 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index c466612..3af4236 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -153,12 +153,10 @@ static int _io(struct device_buffer *devbuf, unsigned ioflags)
 		return 0;
 	}
 
-#ifndef DEBUG_MEM
 	if (!devbuf->buf && !(devbuf->malloc_address = devbuf->buf = dm_malloc_aligned((size_t) devbuf->where.size, 0))) {
 		log_error("Bounce buffer malloc failed");
 		return 0;
 	}
-#endif
 
 	log_debug_io("%s %s(fd %d):%8" PRIu64 " bytes (sync) at %" PRIu64 "%s (for %s)",
 		     devbuf->write ? "Write" : "Read ", dev_name(where->dev), fd,
@@ -316,9 +314,22 @@ static int _aligned_io(struct device_area *where, char *write_buffer,
 	if (should_write && !buffer_was_widened && !((uintptr_t) write_buffer & mask))
 		/* Perform the I/O directly. */
 		devbuf->buf = write_buffer;
-	else
+	else if (!should_write)
 		/* Postpone buffer allocation until we're about to issue the I/O */
 		devbuf->buf = NULL;
+	else {
+		/* Allocate a bounce buffer with an extra block */
+		if (!(devbuf->malloc_address = devbuf->buf = dm_malloc((size_t) devbuf->where.size + block_size))) {
+			log_error("Bounce buffer malloc failed");
+			return 0;
+		}
+
+		/*
+		 * Realign start of bounce buffer (using the extra sector)
+		 */
+		if (((uintptr_t) devbuf->buf) & mask)
+			devbuf->buf = (char *) ((((uintptr_t) devbuf->buf) + mask) & ~mask);
+	}
 
 	devbuf->write = 0;
 


