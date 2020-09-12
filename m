From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 Sep 2020 11:24:49 +0000 (GMT)
Subject: master - cov: drop checking for EWOULDBLOCK
Message-ID: <20200912112449.02FF0388C014@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a940979ff78e06b24a6a059e5da3a35b7e4ab16d
Commit:        a940979ff78e06b24a6a059e5da3a35b7e4ab16d
Parent:        740d5bf6cd39015aac086ddca98a089ba6028d72
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 12 13:15:12 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Sep 12 13:24:03 2020 +0200

cov: drop checking for EWOULDBLOCK

Reduce cov warning and remove this really ancient define
as lvm2 was never compilable on such platform.
---
 libdaemon/client/daemon-io.c     | 2 --
 libdaemon/server/daemon-server.c | 3 +--
 2 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/libdaemon/client/daemon-io.c b/libdaemon/client/daemon-io.c
index 1f9d84053..6b7437ecc 100644
--- a/libdaemon/client/daemon-io.c
+++ b/libdaemon/client/daemon-io.c
@@ -48,7 +48,6 @@ int buffer_read(int fd, struct buffer *buffer) {
 			errno = ECONNRESET;
 			return 0; /* we should never encounter EOF here */
 		} else if (result < 0 && (errno == EAGAIN ||
-					  (EWOULDBLOCK != EAGAIN && errno == EWOULDBLOCK) ||
 					  errno == EINTR || errno == EIO)) {
 			fd_set in;
 			FD_ZERO(&in);
@@ -78,7 +77,6 @@ int buffer_write(int fd, const struct buffer *buffer) {
 			if (result > 0)
 				written += result;
 			else if (result < 0 && (errno == EAGAIN ||
-						(EWOULDBLOCK != EAGAIN && errno == EWOULDBLOCK) ||
 						errno == EINTR || errno == EIO)) {
 				fd_set out;
 				FD_ZERO(&out);
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 0368a9446..7c1b1cf89 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -677,8 +677,7 @@ void daemon_start(daemon_state s)
 			perror("sigprocmask error");
 
 		if (ret < 0) {
-			if (errno != EINTR && errno != EAGAIN &&
-			    (EWOULDBLOCK == EAGAIN || errno != EWOULDBLOCK))
+			if ((errno != EINTR) && (errno != EAGAIN))
 				perror("select error");
 			continue;
 		}


