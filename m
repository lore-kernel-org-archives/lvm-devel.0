From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 15 Jan 2018 22:17:09 -0500
Subject: master - device: Add reason to devbuf.
Message-ID: <201801160317.w0G3H9Ep025358@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c90582344d4c04d020899a8ff8857f09368e0a98
Commit:        c90582344d4c04d020899a8ff8857f09368e0a98
Parent:        1f01eaa61200bb1144bb6f424d8df2c77a8b8307
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jan 15 19:38:18 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jan 15 19:38:18 2018 +0000

device: Add reason to devbuf.

---
 lib/device/dev-io.c |    9 +++++----
 lib/device/device.h |    1 +
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 38127c7..514aaca 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -142,7 +142,7 @@ static int _io_sync(struct device_buffer *devbuf)
 	return (total == (size_t) where->size);
 }
 
-static int _io(struct device_buffer *devbuf, dev_io_reason_t reason)
+static int _io(struct device_buffer *devbuf)
 {
 	struct device_area *where = &devbuf->where;
 	int fd = dev_fd(where->dev);
@@ -156,7 +156,7 @@ static int _io(struct device_buffer *devbuf, dev_io_reason_t reason)
 	log_debug_io("%s %s(fd %d):%8" PRIu64 " bytes (sync) at %" PRIu64 "%s (for %s)",
 		     devbuf->write ? "Write" : "Read ", dev_name(where->dev), fd,
 		     where->size, (uint64_t) where->start,
-		     (devbuf->write && test_mode()) ? " (test mode - suppressed)" : "", _reason_text(reason));
+		     (devbuf->write && test_mode()) ? " (test mode - suppressed)" : "", _reason_text(devbuf->reason));
 
 	/*
 	 * Skip all writes in test mode.
@@ -327,10 +327,11 @@ static int _aligned_io(struct device_area *where, char *buffer,
 	devbuf->where.start = widened.start;
 	devbuf->where.size = widened.size;
 	devbuf->write = 0;
+	devbuf->reason = reason;
 
 	/* Do we need to read into the bounce buffer? */
 	if ((!should_write || buffer_was_widened) &&
-	    !_io(devbuf, reason)) {
+	    !_io(devbuf)) {
 		if (!should_write)
 			goto_bad;
 		/* FIXME Handle errors properly! */
@@ -348,7 +349,7 @@ static int _aligned_io(struct device_area *where, char *buffer,
 
 		/* ... then we write */
 		devbuf->write = 1;
-		if (!(r = _io(devbuf, reason)))
+		if (!(r = _io(devbuf)))
 			goto_bad;
 			
 		_release_devbuf(devbuf);
diff --git a/lib/device/device.h b/lib/device/device.h
index 2a05fd4..d70d3aa 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -90,6 +90,7 @@ struct device_buffer {
 	void *malloc_address;	/* Start of allocated memory */
 	void *buf;		/* Aligned buffer that contains data within it */
 	struct device_area where;	/* Location of buf */
+	dev_io_reason_t reason;
 	unsigned write:1;	/* 1 if write; 0 if read */
 };
 


