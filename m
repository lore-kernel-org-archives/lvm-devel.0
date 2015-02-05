From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:26 +0000 (UTC)
Subject: master - libdaemon: Use select to yield CPU on a blocked read or write.
Message-ID: <20150205134226.4E1C76036E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c2aa918c534cd939fa064a777141bde0425ba840
Commit:        c2aa918c534cd939fa064a777141bde0425ba840
Parent:        19bb62e2ece4d2455bd2a06cb02dda59856382ee
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 21 01:53:48 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:20 2015 +0100

libdaemon: Use select to yield CPU on a blocked read or write.

---
 libdaemon/client/daemon-io.c |   27 ++++++++++++++++++++++-----
 1 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/libdaemon/client/daemon-io.c b/libdaemon/client/daemon-io.c
index 6d81ed8..d19acd6 100644
--- a/libdaemon/client/daemon-io.c
+++ b/libdaemon/client/daemon-io.c
@@ -49,9 +49,18 @@ int buffer_read(int fd, struct buffer *buffer) {
 		} else if (result == 0) {
 			errno = ECONNRESET;
 			return 0; /* we should never encounter EOF here */
-		} else if (result < 0 && errno != EAGAIN && errno != EWOULDBLOCK && errno != EINTR)
+		} else if (result < 0 && ( errno == EAGAIN || errno == EWOULDBLOCK ||
+					   errno == EINTR || errno == EIO)) {
+			struct timeval tval;
+			fd_set in;
+			tval.tv_sec = 1;
+			tval.tv_usec = 0;
+			FD_ZERO(&in);
+			FD_SET(fd, &in);
+			/* ignore the result, this is just a glorified sleep */
+			select(FD_SETSIZE, &in, NULL, NULL, NULL);
+		} else if (result < 0)
 			return 0;
-		/* TODO call select here if we encountered EAGAIN/EWOULDBLOCK/EINTR */
 	}
 
 	return 1;
@@ -60,8 +69,6 @@ int buffer_read(int fd, struct buffer *buffer) {
 /*
  * Write a buffer to a filedescriptor. Keep trying. Blocks (even on
  * SOCK_NONBLOCK) until all of the write went through.
- *
- * TODO use select on EWOULDBLOCK/EAGAIN/EINTR to avoid useless spinning
  */
 int buffer_write(int fd, const struct buffer *buffer) {
 	static const struct buffer _terminate = { .mem = (char *) "\n##\n", .used = 4 };
@@ -74,7 +81,17 @@ int buffer_write(int fd, const struct buffer *buffer) {
 			result = write(fd, use->mem + written, use->used - written);
 			if (result > 0)
 				written += result;
-			else if (result < 0 && errno != EWOULDBLOCK && errno != EAGAIN && errno != EINTR)
+			else if (result < 0 && ( errno == EAGAIN || errno == EWOULDBLOCK ||
+						 errno == EINTR || errno == EIO)) {
+				struct timeval tval;
+				fd_set out;
+				tval.tv_sec = 1;
+				tval.tv_usec = 0;
+				FD_ZERO(&out);
+				FD_SET(fd, &out);
+				/* ignore the result, this is just a glorified sleep */
+				select(FD_SETSIZE, NULL, &out, NULL, NULL);
+			} else if (result < 0)
 				return 0; /* too bad */
 		}
 	}


