From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Jun 2009 09:19:14 -0000
Subject: LVM2 ./WHATS_NEW tools/lvcreate.c tools/lvrena ...
Message-ID: <20090626091914.11220.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-06-26 09:19:13

Modified files:
	.              : WHATS_NEW 
	tools          : lvcreate.c lvrename.c lvresize.c pvchange.c 

Log message:
	Abort if automatic metadata correction fails when reading VG to update it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1154&r2=1.1155
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.193&r2=1.194
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvrename.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67

--- LVM2/WHATS_NEW	2009/06/26 09:03:59	1.1154
+++ LVM2/WHATS_NEW	2009/06/26 09:19:13	1.1155
@@ -1,6 +1,6 @@
 Version 2.02.48 - 
 ===============================
-  Abort operation if automatic metadata correction in lvconvert fails.
+  Abort if automatic metadata correction fails when reading VG to update it.
   Explicitly request fallback to default major number in device mapper.
   Ignore suspended devices during repair.
   Call vgreduce --removemissing automatically to clean up bad PVs in dmeventd.
--- LVM2/tools/lvcreate.c	2009/06/06 22:06:54	1.193
+++ LVM2/tools/lvcreate.c	2009/06/26 09:19:13	1.194
@@ -996,7 +996,7 @@
 	log_verbose("Finding volume group \"%s\"", lp.vg_name);
 	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, NULL, LCK_VG_WRITE,
 				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				    CORRECT_INCONSISTENT)))
+				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
 		return ECMD_FAILED;
 
 	if (!_lvcreate(cmd, vg, &lp))
--- LVM2/tools/lvrename.c	2009/05/21 03:04:53	1.50
+++ LVM2/tools/lvrename.c	2009/06/26 09:19:13	1.51
@@ -104,7 +104,7 @@
 	log_verbose("Checking for existing volume group \"%s\"", vg_name);
 	if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_WRITE,
 				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				    CORRECT_INCONSISTENT)))
+				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
 		return ECMD_FAILED;
 
 	if (!(lvl = find_lv_in_vg(vg, lv_name_old))) {
--- LVM2/tools/lvresize.c	2009/05/21 03:04:53	1.109
+++ LVM2/tools/lvresize.c	2009/06/26 09:19:13	1.110
@@ -673,7 +673,7 @@
 	log_verbose("Finding volume group %s", lp.vg_name);
 	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, NULL, LCK_VG_WRITE,
 				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				    CORRECT_INCONSISTENT))) {
+				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
 		stack;
 		return ECMD_FAILED;
 	}
--- LVM2/tools/pvchange.c	2009/05/21 03:04:53	1.66
+++ LVM2/tools/pvchange.c	2009/06/26 09:19:13	1.67
@@ -59,7 +59,7 @@
 			    vg_name, pv_name);
 		if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_WRITE,
 					    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-					    CORRECT_INCONSISTENT)))
+					    CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
 			return_0;
 
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {


