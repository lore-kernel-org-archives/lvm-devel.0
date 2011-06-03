From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 3 Jun 2011 09:05:31 -0000
Subject: LVM2/daemons/clvmd clvmd-command.c lvm-functions.c
Message-ID: <20110603090531.32297.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-06-03 09:05:31

Modified files:
	daemons/clvmd  : clvmd-command.c lvm-functions.c 

Log message:
	Fix a few compile warnings.
	
	clvmd-command.c:84:2: warning: implicit declaration of function ???init_test???
	lvm-functions.c:141:3: warning: too many arguments for format

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118

--- LVM2/daemons/clvmd/clvmd-command.c	2011/06/01 21:16:56	1.55
+++ LVM2/daemons/clvmd/clvmd-command.c	2011/06/03 09:05:30	1.56
@@ -57,6 +57,7 @@
 #include "clvmd-comms.h"
 #include "clvm.h"
 #include "clvmd.h"
+#include "lvm-globals.h"
 #include "lvm-functions.h"
 
 #include "locking.h"
--- LVM2/daemons/clvmd/lvm-functions.c	2011/06/01 21:16:56	1.117
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/06/03 09:05:30	1.118
@@ -132,7 +132,7 @@
 	static char buf[128];
 	int len;
 
-	len = sprintf(buf, "0x%x ( %s%s%s%s%s)", flags,
+	len = sprintf(buf, "0x%x ( %s%s%s%s%s%s)", flags,
 		flags & LCK_PARTIAL_MODE	  ? "PARTIAL_MODE|" : "",
 		flags & LCK_MIRROR_NOSYNC_MODE	  ? "MIRROR_NOSYNC|" : "",
 		flags & LCK_DMEVENTD_MONITOR_MODE ? "DMEVENTD_MONITOR|" : "",


