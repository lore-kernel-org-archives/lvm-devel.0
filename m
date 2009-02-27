From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Feb 2009 23:55:16 -0000
Subject: LVM2/tools lvresize.c
Message-ID: <20090227235516.5457.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-02-27 23:55:15

Modified files:
	tools          : lvresize.c 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103

--- LVM2/tools/lvresize.c	2009/02/27 23:40:12	1.102
+++ LVM2/tools/lvresize.c	2009/02/27 23:55:15	1.103
@@ -579,7 +579,7 @@
 	if ((lp->resizefs || (lp->resize == LV_REDUCE)) &&
 	    !_request_confirmation(cmd, vg, lv, lp)) {
 		stack;
-		// return ECMD_FAILED;
+		return ECMD_FAILED;
 	}
 
 	if (lp->resizefs) {


