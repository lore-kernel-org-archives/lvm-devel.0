From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Feb 2009 19:43:42 -0000
Subject: LVM2/tools lvresize.c
Message-ID: <20090228194342.24252.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-02-28 19:43:42

Modified files:
	tools          : lvresize.c 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105

--- LVM2/tools/lvresize.c	2009/02/28 00:54:07	1.104
+++ LVM2/tools/lvresize.c	2009/02/28 19:43:42	1.105
@@ -579,7 +579,7 @@
 	if ((lp->resizefs || (lp->resize == LV_REDUCE)) &&
 	    !_request_confirmation(cmd, vg, lv, lp)) {
 		stack;
-		// return ECMD_FAILED;
+		return ECMD_FAILED;
 	}
 
 	if (lp->resizefs) {


