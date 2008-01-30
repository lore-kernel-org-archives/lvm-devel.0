From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Jan 2008 14:17:30 -0000
Subject: LVM2 lib/metadata/lv_manip.c tools/vgreduce.c
Message-ID: <20080130141730.29298.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-30 14:17:29

Modified files:
	lib/metadata   : lv_manip.c 
	tools          : vgreduce.c 

Log message:
	undo a few 'stack' moves

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.149&r2=1.150
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78

--- LVM2/lib/metadata/lv_manip.c	2008/01/30 14:00:00	1.149
+++ LVM2/lib/metadata/lv_manip.c	2008/01/30 14:17:29	1.150
@@ -1752,13 +1752,15 @@
 	backup(vg);
 
 	if (!suspend_lv(cmd, lv)) {
+		stack;
 		vg_revert(vg);
-		return_0;
+		return 0;
 	}
 
 	if (!vg_commit(vg)) {
+		stack;
 		resume_lv(cmd, lv);
-		return_0;
+		return 0;
 	}
 
 	resume_lv(cmd, lv);
--- LVM2/tools/vgreduce.c	2008/01/30 14:00:02	1.77
+++ LVM2/tools/vgreduce.c	2008/01/30 14:17:29	1.78
@@ -211,9 +211,10 @@
 			/* Suspend lvs_changed */
 			init_partial(1);
 			if (!suspend_lvs(cmd, &lvs_changed)) {
+				stack;
 				init_partial(0);
 				vg_revert(vg);
-				return_0;
+				return 0;
 			}
 			init_partial(0);
 		}


