From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Apr 2008 11:47:22 -0000
Subject: LVM2 lib/format1/import-export.c ./WHATS_NEW
Message-ID: <20080422114722.13233.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-22 11:47:22

Modified files:
	lib/format1    : import-export.c 
	.              : WHATS_NEW 

Log message:
	Fix metadata corruption writing lvm1-formatted metadata with snapshots.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.855&r2=1.856

--- LVM2/lib/format1/import-export.c	2008/04/10 17:09:31	1.96
+++ LVM2/lib/format1/import-export.c	2008/04/22 11:47:22	1.97
@@ -284,7 +284,7 @@
 		vgd->vg_status |= VG_EXTENDABLE;
 
 	vgd->lv_max = vg->max_lv;
-	vgd->lv_cur = vg->lv_count;
+	vgd->lv_cur = vg->lv_count + vg->snapshot_count;
 
 	vgd->pv_max = vg->max_pv;
 	vgd->pv_cur = vg->pv_count;
--- LVM2/WHATS_NEW	2008/04/20 00:15:08	1.855
+++ LVM2/WHATS_NEW	2008/04/22 11:47:22	1.856
@@ -1,5 +1,6 @@
 Version 2.02.36 - 
 =================================
+  Fix metadata corruption writing lvm1-formatted metadata with snapshots.
   Add --prefixes to reporting tools for field name prefix output format.
   Fix lvconvert -m0 allocatable space check.
 


