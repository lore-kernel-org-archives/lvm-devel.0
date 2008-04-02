From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Apr 2008 12:17:31 -0000
Subject: LVM2 tools/lvresize.c test/t-lvresize-usage.sh
Message-ID: <20080402121731.26629.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-02 12:17:31

Modified files:
	tools          : lvresize.c 
Added files:
	test           : t-lvresize-usage.sh 

Log message:
	Fix lvresize to dump stack if vg_lock_and_read() fails.
	
	Necessary because vg_lock_and_read() may fail silently if the vg_check_status() call fails.
	
	Also add lvresize tests.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvresize-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95

/cvs/lvm2/LVM2/test/t-lvresize-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvresize-usage.sh
+++ -	2008-04-02 12:17:31.542123000 +0000
@@ -0,0 +1,55 @@
+#!/bin/sh
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Test lvresize command options for validity'
+privileges_required_=1
+
+. ./test-lib.sh
+
+cleanup_()
+{
+  test -n "$vg" && {
+    vgchange -an "$vg"
+    lvremove -ff "$vg"
+    vgremove "$vg"
+  } > "$test_dir_/cleanup.log"
+  test -n "$d1" && losetup -d "$d1"
+  test -n "$d2" && losetup -d "$d2"
+  rm -f "$f1" "$f2"
+}
+
+test_expect_success \
+  'set up temp files, loopback devices, PVs, and a VG' \
+  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
+   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
+   pvcreate $d1 $d2                       &&
+   vg=$(this_test_)-test-vg-$$            &&
+   vgcreate $vg $d1 $d2'
+
+lv=lvresize-usage-$$
+
+test_expect_success \
+  'lvresize normal operation succeeds' \
+  'lvcreate -L 64M -n $lv -i2 $vg &&
+   lvresize -l +4 $vg/$lv && 
+   lvremove -ff $vg'
+
+test_expect_success \
+  'lvresize rejects an invalid vgname' \
+  'lvcreate -L 64M -n $lv -i2 $vg &&
+   lvresize -v -l +4 xxx/$lv &&
+   echo status=$?; test $? = 5 &&
+   lvremove -ff $vg'
+
+test_done
+# Local Variables:
+# indent-tabs-mode: nil
+# End:
--- LVM2/tools/lvresize.c	2008/04/01 22:15:16	1.94
+++ LVM2/tools/lvresize.c	2008/04/02 12:17:30	1.95
@@ -654,8 +654,10 @@
 	log_verbose("Finding volume group %s", lp.vg_name);
 	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, NULL, LCK_VG_WRITE,
 				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				    CORRECT_INCONSISTENT)))
+				    CORRECT_INCONSISTENT))) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	if (!(r = _lvresize(cmd, vg, &lp)))
 		stack;


