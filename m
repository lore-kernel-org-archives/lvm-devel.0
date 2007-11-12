From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Nov 2007 21:50:22 -0000
Subject: LVM2/tools lvcreate.c toollib.c
Message-ID: <20071112215022.16375.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-12 21:50:21

Modified files:
	tools          : lvcreate.c toollib.c 

Log message:
	fix precedence

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.157&r2=1.158
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114

--- LVM2/tools/lvcreate.c	2007/11/12 20:51:54	1.157
+++ LVM2/tools/lvcreate.c	2007/11/12 21:50:21	1.158
@@ -918,7 +918,7 @@
 
 revert_new_lv:
 	/* FIXME Better to revert to backup of metadata? */
-	if (!lv_remove(lv) || !vg_write(vg) || backup(vg), !vg_commit(vg))
+	if (!lv_remove(lv) || !vg_write(vg) || (backup(vg), !vg_commit(vg)))
 		log_error("Manual intervention may be required to remove "
 			  "abandoned LV(s) before retrying.");
 	return 0;
--- LVM2/tools/toollib.c	2007/11/12 20:51:54	1.113
+++ LVM2/tools/toollib.c	2007/11/12 21:50:21	1.114
@@ -1415,7 +1415,7 @@
 	}
 
 revert_new_lv:
-	if (!lv_remove(log_lv) || !vg_write(vg) || backup(vg), !vg_commit(vg))
+	if (!lv_remove(log_lv) || !vg_write(vg) || (backup(vg), !vg_commit(vg)))
 		log_error("Manual intervention may be required to remove "
 			  "abandoned log LV before retrying.");
 	return NULL;


