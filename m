From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Feb 2016 13:41:46 +0000 (UTC)
Subject: master - gcc: logical-op warning go away
Message-ID: <20160223134146.F0B3261098@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c0b836e316c20b8ed4325331cf33ef36815eb233
Commit:        c0b836e316c20b8ed4325331cf33ef36815eb233
Parent:        05cc1b87a952995c54ad99b8e9a0da9479bb56a5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 13:16:55 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 14:41:24 2016 +0100

gcc: logical-op warning go away

Don't be too much inventive and shutdown gcc6 warning:
https://gcc.gnu.org/bugzilla/show_bug.cgi?id=69602
---
 lib/device/dev-md.c          |    4 ++--
 libdaemon/client/daemon-io.c |   10 ++++++----
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index b6ee59f..3dbe831 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -38,8 +38,8 @@ static int _dev_has_md_magic(struct device *dev, uint64_t sb_offset)
 
 	/* Version 1 is little endian; version 0.90.0 is machine endian */
 	if (dev_read(dev, sb_offset, sizeof(uint32_t), &md_magic) &&
-	    ((md_magic == xlate32(MD_SB_MAGIC)) ||
-	     (md_magic == MD_SB_MAGIC)))
+	    ((md_magic == MD_SB_MAGIC) ||
+	     ((MD_SB_MAGIC != xlate32(MD_SB_MAGIC)) && (md_magic == xlate32(MD_SB_MAGIC)))))
 		return 1;
 
 	return 0;
diff --git a/libdaemon/client/daemon-io.c b/libdaemon/client/daemon-io.c
index f072764..5419d40 100644
--- a/libdaemon/client/daemon-io.c
+++ b/libdaemon/client/daemon-io.c
@@ -49,8 +49,9 @@ int buffer_read(int fd, struct buffer *buffer) {
 		} else if (result == 0) {
 			errno = ECONNRESET;
 			return 0; /* we should never encounter EOF here */
-		} else if (result < 0 && ( errno == EAGAIN || errno == EWOULDBLOCK ||
-					   errno == EINTR || errno == EIO)) {
+		} else if (result < 0 && (errno == EAGAIN ||
+					  (EWOULDBLOCK != EAGAIN && errno == EWOULDBLOCK) ||
+					  errno == EINTR || errno == EIO)) {
 			fd_set in;
 			FD_ZERO(&in);
 			FD_SET(fd, &in);
@@ -78,8 +79,9 @@ int buffer_write(int fd, const struct buffer *buffer) {
 			result = write(fd, use->mem + written, use->used - written);
 			if (result > 0)
 				written += result;
-			else if (result < 0 && ( errno == EAGAIN || errno == EWOULDBLOCK ||
-						 errno == EINTR || errno == EIO)) {
+			else if (result < 0 && (errno == EAGAIN ||
+						(EWOULDBLOCK != EAGAIN && errno == EWOULDBLOCK) ||
+						errno == EINTR || errno == EIO)) {
 				fd_set out;
 				FD_ZERO(&out);
 				FD_SET(fd, &out);


