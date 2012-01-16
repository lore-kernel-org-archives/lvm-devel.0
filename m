From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 16 Jan 2012 05:09:17 -0000
Subject: LVM2/daemons/common daemon-shared.c
Message-ID: <20120116050917.21695.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-01-16 05:09:16

Modified files:
	daemons/common : daemon-shared.c 

Log message:
	Fix a boundary condition in read_buffer in daemon-shared.c.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-shared.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/daemons/common/daemon-shared.c	2012/01/15 11:17:16	1.7
+++ LVM2/daemons/common/daemon-shared.c	2012/01/16 05:09:16	1.8
@@ -30,20 +30,19 @@
 		if (result < 0 && errno != EAGAIN && errno != EWOULDBLOCK)
 			goto fail;
 
+		if ((!strncmp((*buffer) + bytes - 4, "\n##\n", 4))) {
+			*(*buffer + bytes - 4) = 0;
+			break; /* success, we have the full message now */
+		}
+
 		if (bytes == buffersize) {
 			buffersize += 1024;
 			if (!(new = realloc(*buffer, buffersize + 1)))
 				goto fail;
 
 			*buffer = new;
-		} else {
-			(*buffer)[bytes] = 0;
-			if ((end = strstr((*buffer) + bytes - 4, "\n##\n"))) {
-				*end = 0;
-				break; /* success, we have the full message now */
-			}
-			/* TODO call select here if we encountered EAGAIN/EWOULDBLOCK */
 		}
+		/* TODO call select here if we encountered EAGAIN/EWOULDBLOCK */
 	}
 	return 1;
 fail:


