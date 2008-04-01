From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 1 Apr 2008 22:15:17 -0000
Subject: LVM2 ./WHATS_NEW tools/lvresize.c
Message-ID: <20080401221517.12825.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-01 22:15:16

Modified files:
	.              : WHATS_NEW 
	tools          : lvresize.c 

Log message:
	Fix redundant lvresize message if vg doesn't exist.
	
	BEFORE:
	tools/lvm lvresize -l +4 vg22/lv1linear
	Volume group "vg22" not found
	Volume group vg22 doesn't exist
	
	AFTER:
	tools/lvm lvresize -l +4 vg22/lv1linear
	Volume group "vg22" not found

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.813&r2=1.814
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94

--- LVM2/WHATS_NEW	2008/04/01 15:01:30	1.813
+++ LVM2/WHATS_NEW	2008/04/01 22:15:16	1.814
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Fix redundant lvresize message if vg doesn't exist.
   Fix another allocation bug with clvmd and large node IDs.
   Add find_lv_in_lv_list() and find_pv_in_pv_list().
   Fix uninitialised variable in clvmd that could cause odd hangs.
--- LVM2/tools/lvresize.c	2008/02/06 12:45:32	1.93
+++ LVM2/tools/lvresize.c	2008/04/01 22:15:16	1.94
@@ -654,10 +654,8 @@
 	log_verbose("Finding volume group %s", lp.vg_name);
 	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, NULL, LCK_VG_WRITE,
 				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				    CORRECT_INCONSISTENT))) {
-		log_error("Volume group %s doesn't exist", lp.vg_name);
+				    CORRECT_INCONSISTENT)))
 		return ECMD_FAILED;
-	}
 
 	if (!(r = _lvresize(cmd, vg, &lp)))
 		stack;


