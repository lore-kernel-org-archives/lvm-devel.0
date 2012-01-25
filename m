From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 21:30:28 -0000
Subject: LVM2/daemons/common daemon-server.c
Message-ID: <20120125213028.3306.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 21:30:28

Modified files:
	daemons/common : daemon-server.c 

Log message:
	Check and print perror for syscalls

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/daemons/common/daemon-server.c	2012/01/15 10:33:41	1.15
+++ LVM2/daemons/common/daemon-server.c	2012/01/25 21:30:27	1.16
@@ -129,8 +129,10 @@
 
 error:
 	if (fd >= 0) {
-		close(fd);
-		unlink(s.socket_path);
+		if (close(fd))
+			perror("close failed");
+		if (unlink(s.socket_path))
+			perror("unlink failed");
 		fd = -1;
 	}
 	goto out;
@@ -364,7 +366,8 @@
 	}
 
 	if (s.socket_fd >= 0)
-		unlink(s.socket_path);
+		if (unlink(s.socket_path))
+			perror("unlink error");
 
 	if (s.daemon_fini)
 		s.daemon_fini(&s);


