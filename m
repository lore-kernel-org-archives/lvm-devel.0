From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Oct 2011 08:51:03 -0000
Subject: LVM2/tools pvmove.c
Message-ID: <20111011085103.22510.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-11 08:51:02

Modified files:
	tools          : pvmove.c 

Log message:
	Remove test for first_time with FIXME
	
	Workaround for the current code with big FIXME,
	since proper solution for pvmove needs to be developed.
	
	Commiting this only for the purpose to get cluster testing covered.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91

--- LVM2/tools/pvmove.c	2011/09/27 22:43:42	1.90
+++ LVM2/tools/pvmove.c	2011/10/11 08:51:02	1.91
@@ -369,8 +369,9 @@
 	}
 
 	if (!_suspend_lvs(cmd, first_time, lv_mirr, lvs_changed, vg)) {
-		log_error("ABORTING: Volume group metadata update failed.");
-		if (!first_time && !revert_lv(cmd, lv_mirr))
+		log_error("ABORTING: Volume group metadata update failed. (first_time: %d)", first_time);
+		//FIXME:  - currently this check breaks pvmove testing
+		if (/*!first_time &&*/ !revert_lv(cmd, lv_mirr))
 			stack;
 		return 0;
 	}


