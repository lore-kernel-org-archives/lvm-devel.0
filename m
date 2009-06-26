From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Jun 2009 09:04:01 -0000
Subject: LVM2 ./WHATS_NEW tools/lvconvert.c
Message-ID: <20090626090401.26420.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-06-26 09:04:00

Modified files:
	.              : WHATS_NEW 
	tools          : lvconvert.c 

Log message:
	Abort operation if automatic metadata correction in lvconvert fails.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1153&r2=1.1154
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83

--- LVM2/WHATS_NEW	2009/06/17 20:55:24	1.1153
+++ LVM2/WHATS_NEW	2009/06/26 09:03:59	1.1154
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Abort operation if automatic metadata correction in lvconvert fails.
   Explicitly request fallback to default major number in device mapper.
   Ignore suspended devices during repair.
   Call vgreduce --removemissing automatically to clean up bad PVs in dmeventd.
--- LVM2/tools/lvconvert.c	2009/06/15 14:47:39	1.82
+++ LVM2/tools/lvconvert.c	2009/06/26 09:04:00	1.83
@@ -940,7 +940,7 @@
 
 	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, NULL, LCK_VG_WRITE,
 				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				    CORRECT_INCONSISTENT)))
+				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
 		goto out;
 
 	if (!(lvl = find_lv_in_vg(vg, lp.lv_name))) {


