From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 4 Dec 2017 20:03:01 -0500
Subject: master - device: Skip read-modify-write if replacing whole block.
Message-ID: <201712050103.vB5131vs024389@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7195df5acace29e77add6aa2f3df9c684e44694a
Commit:        7195df5acace29e77add6aa2f3df9c684e44694a
Parent:        e4805e48830c66e5fdcabf162a09cc27d6b73bc1
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Dec 5 01:00:38 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Dec 5 01:00:38 2017 +0000

device: Skip read-modify-write if replacing whole block.

---
 WHATS_NEW           |    1 +
 lib/device/dev-io.c |   22 +++++++++++++---------
 2 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 541d764..674e7f1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Skip read-modify-write when entire block is replaced.
   Categorise I/O with reason annotations in debug messages.
   Command will lock memory only when suspending volumes.
   Merge segments when pvmove is finished.
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index e108437..f77494f 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -231,6 +231,7 @@ static int _aligned_io(struct device_area *where, char *buffer,
 	char *bounce, *bounce_buf;
 	unsigned int physical_block_size = 0;
 	unsigned int block_size = 0;
+	unsigned buffer_was_widened = 0;
 	uintptr_t mask;
 	struct device_area widened;
 	int r = 0;
@@ -241,18 +242,19 @@ static int _aligned_io(struct device_area *where, char *buffer,
 
 	if (!block_size)
 		block_size = lvm_getpagesize();
+	mask = block_size - 1;
 
 	_widen_region(block_size, where, &widened);
 
-	/* Do we need to use a bounce buffer? */
-	mask = block_size - 1;
-	if (!memcmp(where, &widened, sizeof(widened)) &&
-	    !((uintptr_t) buffer & mask))
+	/* Did we widen the buffer?  When writing, this means means read-modify-write. */
+	if (where->size != widened.size || where->start != widened.start) {
+		buffer_was_widened = 1;
+		log_debug_io("Widening request for %" PRIu64 " bytes at %" PRIu64 " to %" PRIu64 " bytes at %" PRIu64 " on %s (for %s)",
+			     where->size, (uint64_t) where->start, widened.size, (uint64_t) widened.start, dev_name(where->dev), _reason_text(reason));
+	} else if (!((uintptr_t) buffer & mask))
+		/* Perform the I/O directly. */
 		return _io(where, buffer, should_write, reason);
 
-	log_debug_io("Widening request for %" PRIu64 " bytes at %" PRIu64 " to %" PRIu64 " bytes at %" PRIu64 " on %s (for %s)",
-		     where->size, (uint64_t) where->start, widened.size, (uint64_t) widened.start, dev_name(where->dev), _reason_text(reason));
-
 	/* Allocate a bounce buffer with an extra block */
 	if (!(bounce_buf = bounce = dm_malloc((size_t) widened.size + block_size))) {
 		log_error("Bounce buffer malloc failed");
@@ -265,10 +267,12 @@ static int _aligned_io(struct device_area *where, char *buffer,
 	if (((uintptr_t) bounce) & mask)
 		bounce = (char *) ((((uintptr_t) bounce) + mask) & ~mask);
 
-	/* channel the io through the bounce buffer */
-	if (!_io(&widened, bounce, 0, reason)) {
+	/* Do we need to read into the bounce buffer? */
+	if ((!should_write || buffer_was_widened) &&
+	    !_io(&widened, bounce, 0, reason)) {
 		if (!should_write)
 			goto_out;
+		/* FIXME Handle errors properly! */
 		/* FIXME pre-extend the file */
 		memset(bounce, '\n', widened.size);
 	}


