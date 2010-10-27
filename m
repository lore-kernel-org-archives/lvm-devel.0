From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 27 Oct 2010 09:13:38 -0000
Subject: LVM2/daemons/clvmd clvmd.c
Message-ID: <20101027091338.19803.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-27 09:13:37

Modified files:
	daemons/clvmd  : clvmd.c 

Log message:
	Fix a double close in clvmd.
	
	The management threads (main_loop, the socket thread) could close a single fd
	twice in a row sometimes. At least one other thread can be running at the same
	time as the threads doing the double close. That one running thread also
	happens to do some IO (namely, open /proc/devices, read from it, close it). If
	there was enough "demand" for the local socket, this could happen:
	
	- a connection to clvmd is about to finish, let's say the fd is 13 (it often
	happens to be in my test script, don't ask why)
	- the local_sock thread calls close(13)
	- the lvm thread calls open("/proc/devices"...) and gets 13
	- the main_loop thread calls close(13) [OOPS!]
	- new connection arrives, and is accept'd by a (new) local_sock thread
	- the accept gives an fd of 13 (since it's the lowest free fd at this point)
	- the lvm thread gets around to read from it's /proc/devices handle... 13,
	again
	- the lvm thread hangs forever trying to read from the socket instead of
	/proc/devices
	
	Signed-off-by: Petr Rockai <prockai@redhat.com>
	Reviewed-by: Milan Broz <mbroz@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81

--- LVM2/daemons/clvmd/clvmd.c	2010/10/26 09:57:03	1.80
+++ LVM2/daemons/clvmd/clvmd.c	2010/10/27 09:13:37	1.81
@@ -838,7 +838,10 @@
 						lastfd->next = thisfd->next;
 						free_fd = thisfd;
 						thisfd = lastfd;
-						close(free_fd->fd);
+						if (free_fd->fd >= 0) {
+							close(free_fd->fd);
+							free_fd->fd = -1;
+						}
 
 						/* Queue cleanup, this also frees the client struct */
 						add_to_lvmqueue(free_fd, NULL, 0, NULL);
@@ -1088,7 +1091,10 @@
 			thisfd->bits.localsock.pipe_client->bits.pipe.client =
 			    NULL;
 
-		close(thisfd->fd);
+		if (thisfd->fd >= 0) {
+			close(thisfd->fd);
+			thisfd->fd = -1;
+		}
 		return 0;
 	} else {
 		int comms_pipe[2];


