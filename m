From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 2 Aug 2009 21:59:21 -0000
Subject: LVM2 ./WHATS_NEW test/t-mirror-lvconvert.sh to ...
Message-ID: <20090802215921.13790.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-08-02 21:59:21

Modified files:
	.              : WHATS_NEW 
	test           : t-mirror-lvconvert.sh 
	tools          : lvconvert.c 

Log message:
	Make lvconvert honour log mirror options combined with downconversion.
	(RHBZ 463272)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1227&r2=1.1228
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91

--- LVM2/WHATS_NEW	2009/08/02 21:03:09	1.1227
+++ LVM2/WHATS_NEW	2009/08/02 21:59:21	1.1228
@@ -1,5 +1,6 @@
 Version 2.02.51 - 
 ================================
+  Make lvconvert honour log mirror options combined with downconversion.
   Allow LV suspend while --ignorelockingfailure is in force.
   Update synopsis in lvconvert manpage to mention --repair.
   Set cookies in activation code and wait for udev to complete processing.
--- LVM2/test/t-mirror-lvconvert.sh	2009/06/01 14:43:28	1.10
+++ LVM2/test/t-mirror-lvconvert.sh	2009/08/02 21:59:21	1.11
@@ -321,3 +321,9 @@
 check_mirror_count_ $vg/$lv1 2
 check_mirror_log_ $vg/$lv1
 check_and_cleanup_lvs_
+
+# BZ 463272: disk log mirror convert option is lost if downconvert option is also given
+prepare_lvs_
+lvcreate -l1 -m2 --corelog -n $lv1 $vg
+lvconvert -m1 --mirrorlog disk $vg/$lv1
+check_mirror_log_ $vg/$lv1
--- LVM2/tools/lvconvert.c	2009/08/02 21:56:29	1.90
+++ LVM2/tools/lvconvert.c	2009/08/02 21:59:21	1.91
@@ -673,6 +673,9 @@
 				       (corelog || lp->mirrors == 1) ? 1U : 0U,
 				       remove_pvs, 0))
 			return_0;
+		if (lp->mirrors > 1 &&
+		    !_lv_update_log_type(cmd, lp, lv, corelog))
+			return_0;
 	} else if (!(lv->status & MIRRORED)) {
 		/*
 		 * Converting from linear to mirror


