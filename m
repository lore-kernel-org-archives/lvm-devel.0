From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Mar 2014 11:27:04 +0000 (UTC)
Subject: master - cleanup: clvmd rewrite send_message
Message-ID: <20140310112704.B9CFD603FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3d23404081b264c7bfdd0668ee72fd3aa692c935
Commit:        3d23404081b264c7bfdd0668ee72fd3aa692c935
Parent:        cbca815dc44e805d6e4cc138c28af73f1e47432a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 8 23:14:46 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 10 12:24:09 2014 +0100

cleanup: clvmd rewrite send_message

Improve readability of code and make it clear what it tries
to achieve.
---
 daemons/clvmd/clvmd.c |   57 +++++++++++++++++-------------------------------
 1 files changed, 20 insertions(+), 37 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index e8375a8..c7ad2da 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -2024,8 +2024,8 @@ static void send_version_message(void)
 static int send_message(void *buf, int msglen, const char *csid, int fd,
 			const char *errtext)
 {
-	int len = 0;
-	int saved_errno = 0;
+	int len;
+	int ptr;
 	struct timespec delay;
 	struct timespec remtime;
 
@@ -2035,43 +2035,26 @@ static int send_message(void *buf, int msglen, const char *csid, int fd,
 	if (csid == NULL || !ISLOCAL_CSID(csid)) {
 		hton_clvm((struct clvm_header *) buf);
 		return clops->cluster_send_message(buf, msglen, csid, errtext);
-	} else {
-		int ptr = 0;
-
-		/* Make sure it all goes */
-		do {
-			if (retry_cnt > MAX_RETRIES)
-			{
-				errno = saved_errno;
-				log_error("%s", errtext);
-				errno = saved_errno;
-				break;
-			}
-
-			len = write(fd, (char*)buf + ptr, msglen - ptr);
-
-			if (len <= 0) {
-				if (errno == EINTR)
-					continue;
-				if (errno == EAGAIN ||
-				    errno == EIO ||
-				    errno == ENOSPC) {
-					saved_errno = errno;
-					retry_cnt++;
-
-					delay.tv_sec = 0;
-					delay.tv_nsec = 100000;
-					remtime.tv_sec = 0;
-					remtime.tv_nsec = 0;
-					(void) nanosleep (&delay, &remtime);
+	}
 
-					continue;
-				}
-				log_error("%s", errtext);
-				break;
+	/* Make sure it all goes */
+	for (ptr = 0; ptr < msglen;) {
+		if ((len = write(fd, (char*)buf + ptr, msglen - ptr)) <= 0) {
+			if (errno == EINTR)
+				continue;
+			if ((errno == EAGAIN || errno == EIO || errno == ENOSPC) &&
+			    ++retry_cnt < MAX_RETRIES) {
+				delay.tv_sec = 0;
+				delay.tv_nsec = 100000;
+				remtime.tv_sec = 0;
+				remtime.tv_nsec = 0;
+				(void) nanosleep (&delay, &remtime);
+				continue;
 			}
-			ptr += len;
-		} while (ptr < msglen);
+			log_error("%s", errtext);
+			break;
+		}
+		ptr += len;
 	}
 	return len;
 }


