From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Mar 2010 14:05:19 -0000
Subject: LVM2/daemons/cmirrord clogd.c
Message-ID: <20100329140519.16365.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-29 14:05:17

Modified files:
	daemons/cmirrord: clogd.c 

Log message:
	Fixing compilation warning: implicit declaration of function ???umask???

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/clogd.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/daemons/cmirrord/clogd.c	2010/01/19 15:58:45	1.9
+++ LVM2/daemons/cmirrord/clogd.c	2010/03/29 14:05:17	1.10
@@ -18,6 +18,7 @@
 #include <errno.h>
 #include <fcntl.h>
 #include <sys/socket.h>
+#include <sys/stat.h>
 #include <sys/wait.h>
 #include <unistd.h>
 


