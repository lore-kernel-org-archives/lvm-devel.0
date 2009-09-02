From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Sep 2009 21:26:02 -0000
Subject: LVM2/tools vgsplit.c
Message-ID: <20090902212602.11988.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-02 21:26:02

Modified files:
	tools          : vgsplit.c 

Log message:
	Refactor vgsplit - remove bad2 label.
	
	No functional change.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87

--- LVM2/tools/vgsplit.c	2009/09/02 21:25:44	1.86
+++ LVM2/tools/vgsplit.c	2009/09/02 21:26:01	1.87
@@ -287,7 +287,8 @@
 		if (vg_read_error(vg_to)) {
 			vg_release(vg_to);
 			stack;
-			goto bad2;
+			unlock_and_release_vg(cmd, vg_from, vg_name_from);
+			return ECMD_FAILED;
 		}
 
 	} else if (vg_read_error(vg_to) == SUCCESS) {
@@ -427,7 +428,6 @@
 
 bad:
 	unlock_and_release_vg(cmd, vg_to, vg_name_to);
-bad2:
 	unlock_and_release_vg(cmd, vg_from, vg_name_from);
 	return r;
 }


