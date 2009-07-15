From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 15 Jul 2009 12:23:01 -0000
Subject: LVM2/tools toollib.c
Message-ID: <20090715122301.19975.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-15 12:22:59

Modified files:
	tools          : toollib.c 

Log message:
	Fix memory leak in process_each_pv path.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.163&r2=1.164

--- LVM2/tools/toollib.c	2009/07/15 12:15:36	1.163
+++ LVM2/tools/toollib.c	2009/07/15 12:22:59	1.164
@@ -723,6 +723,7 @@
 				vg = vg_read(cmd, sll->str, NULL, flags);
 				if (vg_read_error(vg)) {
 					ret_max = ECMD_FAILED;
+					vg_release(vg);
 					continue;
 				}
 


