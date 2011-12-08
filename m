From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Dec 2011 18:06:34 -0000
Subject: LVM2/tools pvmove.c
Message-ID: <20111208180634.3013.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-12-08 18:06:34

Modified files:
	tools          : pvmove.c 

Log message:
	reinstate !first_time check
	(recovery from first_time failure would need different code)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92

--- LVM2/tools/pvmove.c	2011/10/11 08:51:02	1.91
+++ LVM2/tools/pvmove.c	2011/12/08 18:06:33	1.92
@@ -370,8 +370,8 @@
 
 	if (!_suspend_lvs(cmd, first_time, lv_mirr, lvs_changed, vg)) {
 		log_error("ABORTING: Volume group metadata update failed. (first_time: %d)", first_time);
-		//FIXME:  - currently this check breaks pvmove testing
-		if (/*!first_time &&*/ !revert_lv(cmd, lv_mirr))
+		/* FIXME Add a recovery path for first time too. */
+		if (!first_time && !revert_lv(cmd, lv_mirr))
 			stack;
 		return 0;
 	}


