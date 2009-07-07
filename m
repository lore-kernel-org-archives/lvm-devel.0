From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 7 Jul 2009 01:51:00 -0000
Subject: LVM2/tools lvmcmdline.c
Message-ID: <20090707015100.2312.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-07 01:51:00

Modified files:
	tools          : lvmcmdline.c 

Log message:
	Fix compile warning in lvmcmdline.c - use C99 PRIu64 for uint64_t.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98

--- LVM2/tools/lvmcmdline.c	2009/07/06 19:13:26	1.97
+++ LVM2/tools/lvmcmdline.c	2009/07/07 01:51:00	1.98
@@ -285,7 +285,7 @@
 			if (adjustment) {
 				v_tmp += (512 - adjustment);
 				log_error("Size is not a multiple of 512. "
-					  "Try using %lu or %lu.",
+					  "Try using %"PRIu64" or %"PRIu64".",
 					  v_tmp - 512, v_tmp);
 				return 0;
 			}


