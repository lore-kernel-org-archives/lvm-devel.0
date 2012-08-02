From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Thu,  2 Aug 2012 14:52:32 +0000 (UTC)
Subject: master - lvmetad: Skip redundant checks on no input
Message-ID: <20120802145232.66189127E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=49ae67cba364e7fba0d0715c4350f28239d42a68
Commit:        49ae67cba364e7fba0d0715c4350f28239d42a68
Parent:        9952331d5d58a4cc2580eddec34defa9cfe141c9
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Aug 1 16:06:32 2012 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Aug 2 16:50:37 2012 +0200

lvmetad: Skip redundant checks on no input

---
 libdaemon/client/daemon-shared.c |   27 +++++++++++++--------------
 1 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/libdaemon/client/daemon-shared.c b/libdaemon/client/daemon-shared.c
index 33ff48f..f90deb4 100644
--- a/libdaemon/client/daemon-shared.c
+++ b/libdaemon/client/daemon-shared.c
@@ -38,27 +38,26 @@ int read_buffer(int fd, char **buffer) {
 
 	while (1) {
 		int result = read(fd, (*buffer) + bytes, buffersize - bytes);
-		if (result > 0)
+		if (result > 0) {
 			bytes += result;
+			if (!strncmp((*buffer) + bytes - 4, "\n##\n", 4)) {
+				*(*buffer + bytes - 4) = 0;
+				break; /* success, we have the full message now */
+			}
+			if (bytes == buffersize) {
+				buffersize += 1024;
+				if (!(new = realloc(*buffer, buffersize + 1)))
+					goto fail;
+				*buffer = new;
+			}
+			continue;
+		}
 		if (result == 0) {
 			errno = ECONNRESET;
 			goto fail; /* we should never encounter EOF here */
 		}
 		if (result < 0 && errno != EAGAIN && errno != EWOULDBLOCK)
 			goto fail;
-
-		if (!strncmp((*buffer) + bytes - 4, "\n##\n", 4)) {
-			*(*buffer + bytes - 4) = 0;
-			break; /* success, we have the full message now */
-		}
-
-		if (bytes == buffersize) {
-			buffersize += 1024;
-			if (!(new = realloc(*buffer, buffersize + 1)))
-				goto fail;
-
-			*buffer = new;
-		}
 		/* TODO call select here if we encountered EAGAIN/EWOULDBLOCK */
 	}
 	return 1;


