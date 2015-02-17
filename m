From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Feb 2015 12:42:37 +0000 (UTC)
Subject: master - cleanup: drop unused val
Message-ID: <20150217124237.8D76B60090@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cb144c0097fe111d9881457de7c686c190c07944
Commit:        cb144c0097fe111d9881457de7c686c190c07944
Parent:        cd1a76a49222feb975b440199881d7c70faf103a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 17 13:39:26 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 17 13:39:26 2015 +0100

cleanup: drop unused val

---
 libdaemon/client/daemon-io.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/libdaemon/client/daemon-io.c b/libdaemon/client/daemon-io.c
index d19acd6..5ce9dde 100644
--- a/libdaemon/client/daemon-io.c
+++ b/libdaemon/client/daemon-io.c
@@ -51,10 +51,7 @@ int buffer_read(int fd, struct buffer *buffer) {
 			return 0; /* we should never encounter EOF here */
 		} else if (result < 0 && ( errno == EAGAIN || errno == EWOULDBLOCK ||
 					   errno == EINTR || errno == EIO)) {
-			struct timeval tval;
 			fd_set in;
-			tval.tv_sec = 1;
-			tval.tv_usec = 0;
 			FD_ZERO(&in);
 			FD_SET(fd, &in);
 			/* ignore the result, this is just a glorified sleep */
@@ -83,10 +80,7 @@ int buffer_write(int fd, const struct buffer *buffer) {
 				written += result;
 			else if (result < 0 && ( errno == EAGAIN || errno == EWOULDBLOCK ||
 						 errno == EINTR || errno == EIO)) {
-				struct timeval tval;
 				fd_set out;
-				tval.tv_sec = 1;
-				tval.tv_usec = 0;
 				FD_ZERO(&out);
 				FD_SET(fd, &out);
 				/* ignore the result, this is just a glorified sleep */


