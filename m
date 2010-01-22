From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Jan 2010 00:43:29 -0000
Subject: LVM2/daemons/cmirrord functions.c
Message-ID: <20100122004329.22256.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-01-22 00:43:28

Modified files:
	daemons/cmirrord: functions.c 

Log message:
	missing header

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/daemons/cmirrord/functions.c	2010/01/20 02:43:19	1.17
+++ LVM2/daemons/cmirrord/functions.c	2010/01/22 00:43:28	1.18
@@ -17,6 +17,7 @@
 #include <fcntl.h>
 #include <linux/kdev_t.h>
 #include <signal.h>
+#include <sys/stat.h>
 #include <time.h>
 #include <unistd.h>
 


