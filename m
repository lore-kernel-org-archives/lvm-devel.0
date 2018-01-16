From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 15 Jan 2018 22:17:32 -0500
Subject: master - device: Move buffer allocation nearer to the I/O.
Message-ID: <201801160317.w0G3HWSq025432@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c26458339ee3b3bdd0e49127e887c0417cbc1438
Commit:        c26458339ee3b3bdd0e49127e887c0417cbc1438
Parent:        081902b4c115c465b123c13e9d8287a75f9d7b2a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jan 16 01:12:08 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jan 16 01:12:08 2018 +0000

device: Move buffer allocation nearer to the I/O.

Don't allocate memory until it's needed - later we'll add
some of the I/O to an internal queue instead of issuing it
immediately.
---
 lib/device/dev-io.c |   19 ++++++++++++-------
 1 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index d995452..2150b0d 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -153,6 +153,13 @@ static int _io(struct device_buffer *devbuf)
 		return 0;
 	}
 
+#ifndef DEBUG_MEM
+	if (!devbuf->buf && !(devbuf->malloc_address = devbuf->buf = dm_malloc_aligned((size_t) devbuf->where.size, 0))) {
+		log_error("Bounce buffer malloc failed");
+		return 0;
+	}
+#endif
+
 	log_debug_io("%s %s(fd %d):%8" PRIu64 " bytes (sync) at %" PRIu64 "%s (for %s)",
 		     devbuf->write ? "Write" : "Read ", dev_name(where->dev), fd,
 		     where->size, (uint64_t) where->start,
@@ -305,17 +312,15 @@ static int _aligned_io(struct device_area *where, char *write_buffer,
 	/* Store location of requested data relative to start of buf */
 	devbuf->data_offset = where->start - devbuf->where.start;
 
-	if (should_write && !buffer_was_widened && !((uintptr_t) write_buffer & mask)) {
+	if (should_write && !buffer_was_widened && !((uintptr_t) write_buffer & mask))
 		/* Perform the I/O directly. */
 		devbuf->buf = write_buffer;
-		devbuf->malloc_address = NULL;
+	else
 #ifndef DEBUG_MEM
-	} else if (!(devbuf->malloc_address = devbuf->buf = dm_malloc_aligned((size_t) devbuf->where.size, 0))) {
-		log_error("Bounce buffer malloc failed");
-		return 0;
-	}
+		/* Postpone buffer allocation until we're about to issue the I/O */
+		devbuf->buf = NULL;
 #else
-	} else {
+	else {
 		/* Allocate a bounce buffer with an extra block */
 		if (!(devbuf->malloc_address = devbuf->buf = dm_malloc((size_t) devbuf->where.size + block_size))) {
 			log_error("Bounce buffer malloc failed");


