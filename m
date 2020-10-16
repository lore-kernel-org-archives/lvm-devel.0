From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:24 +0000 (GMT)
Subject: stable-2.02 - cov: drop checking for EWOULDBLOCK
Message-ID: <20201016191124.A953E396EC5D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ff75d40298dfe8dcfa222e2c0842d413dc68b228
Commit:        ff75d40298dfe8dcfa222e2c0842d413dc68b228
Parent:        92ee7e4c1fe1e6bc5be2fdd54a80d59da07d1fcd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 12 13:15:12 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:58 2020 +0200

cov: drop checking for EWOULDBLOCK

Reduce cov warning and remove this really ancient define
as lvm2 was never compilable on such platform.
---
 libdaemon/client/daemon-io.c     | 2 --
 libdaemon/server/daemon-server.c | 3 +--
 2 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/libdaemon/client/daemon-io.c b/libdaemon/client/daemon-io.c
index 5419d4053..1d7becf5e 100644
--- a/libdaemon/client/daemon-io.c
+++ b/libdaemon/client/daemon-io.c
@@ -50,7 +50,6 @@ int buffer_read(int fd, struct buffer *buffer) {
 			errno = ECONNRESET;
 			return 0; /* we should never encounter EOF here */
 		} else if (result < 0 && (errno == EAGAIN ||
-					  (EWOULDBLOCK != EAGAIN && errno == EWOULDBLOCK) ||
 					  errno == EINTR || errno == EIO)) {
 			fd_set in;
 			FD_ZERO(&in);
@@ -80,7 +79,6 @@ int buffer_write(int fd, const struct buffer *buffer) {
 			if (result > 0)
 				written += result;
 			else if (result < 0 && (errno == EAGAIN ||
-						(EWOULDBLOCK != EAGAIN && errno == EWOULDBLOCK) ||
 						errno == EINTR || errno == EIO)) {
 				fd_set out;
 				FD_ZERO(&out);
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 940844010..ef6ea0f19 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -686,8 +686,7 @@ void daemon_start(daemon_state s)
 			perror("sigprocmask error");
 
 		if (ret < 0) {
-			if (errno != EINTR && errno != EAGAIN &&
-			    (EWOULDBLOCK == EAGAIN || errno != EWOULDBLOCK))
+			if ((errno != EINTR) && (errno != EAGAIN))
 				perror("select error");
 			continue;
 		}


