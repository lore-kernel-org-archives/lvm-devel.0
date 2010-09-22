From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Sep 2010 22:31:46 -0000
Subject: LVM2 ./WHATS_NEW lib/device/dev-io.c
Message-ID: <20100922223146.17341.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-09-22 22:31:46

Modified files:
	.              : WHATS_NEW 
	lib/device     : dev-io.c 

Log message:
	Replace alloca with dm_malloc in _aligned_io.
	
	(This section of code dates from 2.4 and could be written more efficiently nowadays.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1733&r2=1.1734
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70

--- LVM2/WHATS_NEW	2010/09/22 13:45:21	1.1733
+++ LVM2/WHATS_NEW	2010/09/22 22:31:45	1.1734
@@ -1,5 +1,6 @@
 Version 2.02.74 - 
 =====================================
+  Replace alloca with dm_malloc in _aligned_io.
   Fix partial mode operations for lvm1 metadata format.
   Track recursive filter iteration to avoid refreshing while in use. (2.02.56)
   Revert to old glibc vsnprintf behaviour in emit_to_buffer() to catch overflow.
--- LVM2/lib/device/dev-io.c	2010/07/09 15:34:42	1.69
+++ LVM2/lib/device/dev-io.c	2010/09/22 22:31:46	1.70
@@ -164,10 +164,11 @@
 static int _aligned_io(struct device_area *where, void *buffer,
 		       int should_write)
 {
-	void *bounce;
+	void *bounce, *bounce_buf;
 	unsigned int block_size = 0;
 	uintptr_t mask;
 	struct device_area widened;
+	int r = 0;
 
 	if (!(where->dev->flags & DEV_REGULAR) &&
 	    !_get_block_size(where->dev, &block_size))
@@ -185,8 +186,8 @@
 		return _io(where, buffer, should_write);
 
 	/* Allocate a bounce buffer with an extra block */
-	if (!(bounce = alloca((size_t) widened.size + block_size))) {
-		log_error("Bounce buffer alloca failed");
+	if (!(bounce_buf = bounce = dm_malloc((size_t) widened.size + block_size))) {
+		log_error("Bounce buffer malloc failed");
 		return 0;
 	}
 
@@ -199,7 +200,7 @@
 	/* channel the io through the bounce buffer */
 	if (!_io(&widened, bounce, 0)) {
 		if (!should_write)
-			return_0;
+			goto_out;
 		/* FIXME pre-extend the file */
 		memset(bounce, '\n', widened.size);
 	}
@@ -209,13 +210,18 @@
 		       (size_t) where->size);
 
 		/* ... then we write */
-		return _io(&widened, bounce, 1);
+		r = _io(&widened, bounce, 1);
+		goto_out;
 	}
 
 	memcpy(buffer, bounce + (where->start - widened.start),
 	       (size_t) where->size);
 
-	return 1;
+	r = 1;
+
+out:
+	dm_free(bounce_buf);
+	return r;
 }
 
 static int _dev_get_size_file(const struct device *dev, uint64_t *size)


