From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Jan 2007 23:14:35 -0000
Subject: LVM2 tools/vgreduce.c ./WHATS_NEW
Message-ID: <20070109231435.11073.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-09 23:14:35

Modified files:
	tools          : vgreduce.c 
	.              : WHATS_NEW 

Log message:
	Avoid vgreduce error when mirror code removes the log LV.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.530&r2=1.531

--- LVM2/tools/vgreduce.c	2006/11/30 23:11:42	1.54
+++ LVM2/tools/vgreduce.c	2007/01/09 23:14:34	1.55
@@ -347,7 +347,9 @@
 		list_iterate_items(lvl, &lvs_changed) {
 			log_verbose("Removing LV %s from VG %s", lvl->lv->name,
 				    lvl->lv->vg->name);
-			if (!lv_remove(lvl->lv)) {
+				/* Skip LVs already removed by mirror code */
+				if (find_lv_in_vg(vg, lvl->lv->name) &&
+				    !lv_remove(lvl->lv)) {
 				stack;
 				return 0;
 			}
--- LVM2/WHATS_NEW	2007/01/09 22:07:20	1.530
+++ LVM2/WHATS_NEW	2007/01/09 23:14:35	1.531
@@ -1,5 +1,6 @@
 Version 2.02.18 -
 ====================================
+  Avoid vgreduce error when mirror code removes the log LV.
   Remove 3 redundant AC_MSG_RESULTs from configure.in.
   Free memory in _raw_read_mda_header() error paths.
   Fix ambiguous vgsplit error message for split LV.


