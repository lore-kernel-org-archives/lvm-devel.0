From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Mar 2014 11:27:06 +0000 (UTC)
Subject: master - cleanup: clvmd simplify loops
Message-ID: <20140310112706.CE801603FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=109564d6a50eaf3ece1bf38a6422dc2d2f642cf7
Commit:        109564d6a50eaf3ece1bf38a6422dc2d2f642cf7
Parent:        3d23404081b264c7bfdd0668ee72fd3aa692c935
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 10 12:15:41 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 10 12:24:09 2014 +0100

cleanup: clvmd simplify loops

Rewrite write loops to be more readable.
---
 daemons/clvmd/clvmd.c |   26 ++++++++------------------
 1 files changed, 8 insertions(+), 18 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index c7ad2da..9ee5998 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1771,16 +1771,11 @@ static __attribute__ ((noreturn)) void *pre_and_post_thread(void *arg)
 		DEBUGLOG("Writing status %d down pipe %d\n", status, pipe_fd);
 
 		/* Tell the parent process we have finished this bit */
-		do {
-			write_status = write(pipe_fd, &status, sizeof(int));
-			if (write_status == sizeof(int))
+		while ((write_status = write(pipe_fd, &status, sizeof(int))) != sizeof(int))
+			if (write_status >=0 || (errno != EINTR && errno != EAGAIN)) {
+				log_error("Error sending to pipe: %m\n");
 				break;
-			if (write_status < 0 &&
-			    (errno == EINTR || errno == EAGAIN))
-				continue;
-			log_error("Error sending to pipe: %m\n");
-			break;
-		} while(1);
+			}
 
 		if (status) {
 			client->bits.localsock.state = POST_COMMAND;
@@ -1803,16 +1798,11 @@ static __attribute__ ((noreturn)) void *pre_and_post_thread(void *arg)
 		status = 0;
 		do_post_command(client);
 
-		do {
-			write_status = write(pipe_fd, &status, sizeof(int));
-			if (write_status == sizeof(int))
+		while ((write_status = write(pipe_fd, &status, sizeof(int))) != sizeof(int))
+			if (write_status >=0 || (errno != EINTR && errno != EAGAIN)) {
+				log_error("Error sending to pipe: %m\n");
 				break;
-			if (write_status < 0 &&
-			    (errno == EINTR || errno == EAGAIN))
-				continue;
-			log_error("Error sending to pipe: %m\n");
-			break;
-		} while(1);
+			}
 next_pre:
 		DEBUGLOG("Waiting for next pre command\n");
 


