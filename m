From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Jun 2013 20:14:07 +0000 (UTC)
Subject: master - cleanup: easier to read loop code
Message-ID: <20130618201407.99F3D60ECB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c5957ee2ffc2cfce1f1304349e2304bd489c5903
Commit:        c5957ee2ffc2cfce1f1304349e2304bd489c5903
Parent:        155841c349c58e2332802d85f3c39b8933cdd761
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 18 11:59:22 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 18 22:13:41 2013 +0200

cleanup: easier to read loop code

buffer_write now accepts const pointer
Simplify loops and drop goto when not needed.
---
 libdaemon/client/daemon-io.c |   65 ++++++++++++++++++------------------------
 libdaemon/client/daemon-io.h |    2 +-
 2 files changed, 29 insertions(+), 38 deletions(-)

diff --git a/libdaemon/client/daemon-io.c b/libdaemon/client/daemon-io.c
index 6ede8a8..906f375 100644
--- a/libdaemon/client/daemon-io.c
+++ b/libdaemon/client/daemon-io.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2011-2012 Red Hat, Inc.
+ * Copyright (C) 2011-2013 Red Hat, Inc.
  *
  * This file is part of LVM2.
  *
@@ -29,34 +29,32 @@
  * See also write_buffer about blocking (read_buffer has identical behaviour).
  */
 int buffer_read(int fd, struct buffer *buffer) {
+	int result;
+
 	if (!buffer_realloc(buffer, 32)) /* ensure we have some space */
-		goto fail;
+		return 0;
 
 	while (1) {
-		int result = read(fd, buffer->mem + buffer->used, buffer->allocated - buffer->used);
+		result = read(fd, buffer->mem + buffer->used, buffer->allocated - buffer->used);
 		if (result > 0) {
 			buffer->used += result;
 			if (!strncmp((buffer->mem) + buffer->used - 4, "\n##\n", 4)) {
-				*(buffer->mem + buffer->used - 4) = 0;
 				buffer->used -= 4;
+				buffer->mem[buffer->used] = 0;
 				break; /* success, we have the full message now */
 			}
-			if (buffer->allocated - buffer->used < 32)
-				if (!buffer_realloc(buffer, 1024))
-					goto fail;
-			continue;
-		}
-		if (result == 0) {
+			if ((buffer->allocated - buffer->used < 32) &&
+			    !buffer_realloc(buffer, 1024))
+				return 0;
+		} else if (result == 0) {
 			errno = ECONNRESET;
-			goto fail; /* we should never encounter EOF here */
-		}
-		if (result < 0 && errno != EAGAIN && errno != EWOULDBLOCK && errno != EINTR)
-			goto fail;
+			return 0; /* we should never encounter EOF here */
+		} else if (result < 0 && errno != EAGAIN && errno != EWOULDBLOCK && errno != EINTR)
+			return 0;
 		/* TODO call select here if we encountered EAGAIN/EWOULDBLOCK/EINTR */
 	}
+
 	return 1;
-fail:
-	return 0;
 }
 
 /*
@@ -65,28 +63,21 @@ fail:
  *
  * TODO use select on EWOULDBLOCK/EAGAIN/EINTR to avoid useless spinning
  */
-int buffer_write(int fd, struct buffer *buffer) {
-	struct buffer terminate = { .mem = (char *) "\n##\n", .used = 4 };
-	int done = 0;
-	int written = 0;
-	struct buffer *use = buffer;
-write:
-	while (1) {
-		int result = write(fd, use->mem + written, use->used - written);
-		if (result > 0)
-			written += result;
-		if (result < 0 && errno != EWOULDBLOCK && errno != EAGAIN && errno != EINTR)
-			return 0; /* too bad */
-		if (written == use->used) {
-			if (done)
-				return 1;
-			else
-				break; /* done */
+int buffer_write(int fd, const struct buffer *buffer) {
+	static const struct buffer _terminate = { .mem = (char *) "\n##\n", .used = 4 };
+	const struct buffer *use;
+	int done, written, result;
+
+	for (done = 0; done < 2; ++done) {
+		use = (done == 0) ? buffer : &_terminate;
+		for (written = 0; written < use->used;) {
+			result = write(fd, use->mem + written, use->used - written);
+			if (result > 0)
+				written += result;
+			else if (result < 0 && errno != EWOULDBLOCK && errno != EAGAIN && errno != EINTR)
+				return 0; /* too bad */
 		}
 	}
 
-	use = &terminate;
-	written = 0;
-	done = 1;
-	goto write;
+	return 1;
 }
diff --git a/libdaemon/client/daemon-io.h b/libdaemon/client/daemon-io.h
index 1f55af7..52aaa9c 100644
--- a/libdaemon/client/daemon-io.h
+++ b/libdaemon/client/daemon-io.h
@@ -26,6 +26,6 @@
 /* TODO function names */
 
 int buffer_read(int fd, struct buffer *buffer);
-int buffer_write(int fd, struct buffer *buffer);
+int buffer_write(int fd, const struct buffer *buffer);
 
 #endif /* _LVM_DAEMON_SHARED_H */


