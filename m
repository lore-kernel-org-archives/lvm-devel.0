From: agk@sourceware.org <agk@sourceware.org>
Date: 4 Nov 2007 15:43:51 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/import_vsn1.c
Message-ID: <20071104154351.31209.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-04 15:43:51

Modified files:
	.              : WHATS_NEW 
	lib/format_text: import_vsn1.c 

Log message:
	Fix error message when fixing up PV size in lvm2 metadata (2.02.11).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.725&r2=1.726
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/WHATS_NEW	2007/11/02 20:40:04	1.725
+++ LVM2/WHATS_NEW	2007/11/04 15:43:50	1.726
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Fix error message when fixing up PV size in lvm2 metadata (2.02.11).
   Fix orphan-related locking in pvdisplay and pvs.
   Fix missing VG unlocks in some pvchange error paths.
   Add some missing validation of VG names.
--- LVM2/lib/format_text/import_vsn1.c	2007/10/12 14:29:32	1.42
+++ LVM2/lib/format_text/import_vsn1.c	2007/11/04 15:43:50	1.43
@@ -221,7 +221,7 @@
                         log_error("%s: Couldn't get size.", pv_dev_name(pv));
                         return 0;
                 }
-                log_verbose("Fixing up missing format1 size (%s) "
+                log_verbose("Fixing up missing size (%s) "
                             "for PV %s", display_size(fid->fmt->cmd, pv->size),
                             pv_dev_name(pv));
                 if (vg) {


