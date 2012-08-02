From: Marian Csontos <mcsontos@redhat.com>
Date: Thu,  2 Aug 2012 12:24:16 +0200
Subject: [PATCH] lvmetad: Skip redundant checks on no input
Message-ID: <1343903056-32012-1-git-send-email-mcsontos@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

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
-- 
1.7.1


