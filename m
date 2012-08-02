From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Thu,  2 Aug 2012 14:52:37 +0000 (UTC)
Subject: master - [lvmetad] Continue reading/writing on EINTR
Message-ID: <20120802145237.7E8F3127E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3843f54974ea7c3bbe51fcd681a55fc23f4e7736
Commit:        3843f54974ea7c3bbe51fcd681a55fc23f4e7736
Parent:        55c9286dea6b7d77338b4663d67337ca5a7b2b55
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Aug 2 16:40:21 2012 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Aug 2 16:50:37 2012 +0200

[lvmetad] Continue reading/writing on EINTR

---
 libdaemon/client/daemon-shared.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/libdaemon/client/daemon-shared.c b/libdaemon/client/daemon-shared.c
index f90deb4..b767794 100644
--- a/libdaemon/client/daemon-shared.c
+++ b/libdaemon/client/daemon-shared.c
@@ -56,9 +56,9 @@ int read_buffer(int fd, char **buffer) {
 			errno = ECONNRESET;
 			goto fail; /* we should never encounter EOF here */
 		}
-		if (result < 0 && errno != EAGAIN && errno != EWOULDBLOCK)
+		if (result < 0 && errno != EAGAIN && errno != EWOULDBLOCK && errno != EINTR)
 			goto fail;
-		/* TODO call select here if we encountered EAGAIN/EWOULDBLOCK */
+		/* TODO call select here if we encountered EAGAIN/EWOULDBLOCK/EINTR */
 	}
 	return 1;
 fail:
@@ -71,7 +71,7 @@ fail:
  * Write a buffer to a filedescriptor. Keep trying. Blocks (even on
  * SOCK_NONBLOCK) until all of the write went through.
  *
- * TODO use select on EWOULDBLOCK/EAGAIN to avoid useless spinning
+ * TODO use select on EWOULDBLOCK/EAGAIN/EINTR to avoid useless spinning
  */
 int write_buffer(int fd, const char *buffer, int length) {
 	static const char terminate[] = "\n##\n";
@@ -82,7 +82,7 @@ write:
 		int result = write(fd, buffer + written, length - written);
 		if (result > 0)
 			written += result;
-		if (result < 0 && errno != EWOULDBLOCK && errno != EAGAIN)
+		if (result < 0 && errno != EWOULDBLOCK && errno != EAGAIN && errno != EINTR)
 			return 0; /* too bad */
 		if (written == length) {
 			if (done)


