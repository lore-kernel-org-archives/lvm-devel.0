From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 27 Oct 2010 11:40:15 -0000
Subject: LVM2/daemons/clvmd clvmd.c
Message-ID: <20101027114015.26986.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-27 11:40:15

Modified files:
	daemons/clvmd  : clvmd.c 

Log message:
	Alasdair correctly pointed out that if the two closes are concurrent (I haven't
	checked, so they *might*), there is still a race possibility with the last
	fix. This patch fixes that.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82

--- LVM2/daemons/clvmd/clvmd.c	2010/10/27 09:13:37	1.81
+++ LVM2/daemons/clvmd/clvmd.c	2010/10/27 11:40:14	1.82
@@ -188,6 +188,14 @@
 	        exit(status);
 }
 
+static void safe_close(int *fd)
+{
+	if (*fd >= 0) {
+		int to_close = *fd;
+		*fd = -1;
+		close(to_close);
+	}
+}
 
 void debuglog(const char *fmt, ...)
 {
@@ -838,10 +846,7 @@
 						lastfd->next = thisfd->next;
 						free_fd = thisfd;
 						thisfd = lastfd;
-						if (free_fd->fd >= 0) {
-							close(free_fd->fd);
-							free_fd->fd = -1;
-						}
+						safe_close(&(free_fd->fd));
 
 						/* Queue cleanup, this also frees the client struct */
 						add_to_lvmqueue(free_fd, NULL, 0, NULL);
@@ -1091,10 +1096,7 @@
 			thisfd->bits.localsock.pipe_client->bits.pipe.client =
 			    NULL;
 
-		if (thisfd->fd >= 0) {
-			close(thisfd->fd);
-			thisfd->fd = -1;
-		}
+		safe_close(&(thisfd->fd));
 		return 0;
 	} else {
 		int comms_pipe[2];


