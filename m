From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 12 Mar 2008 17:34:58 -0000
Subject: LVM2/test t-mdata-strings.sh
Message-ID: <20080312173458.28336.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-03-12 17:34:58

Added files:
	test           : t-mdata-strings.sh 

Log message:
	Add metadata test for escaping double quotes in device names (bz431474).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mdata-strings.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/test/t-mdata-strings.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-mdata-strings.sh
+++ -	2008-03-12 17:34:58.833097000 +0000
@@ -0,0 +1,51 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Test for proper escaping of strings in metadata (bz431474)'
+privileges_required_=1
+
+. ./test-lib.sh
+
+cleanup_()
+{
+  test -n "$vg" && {
+    vgchange -an "$vg"
+    vgremove "$vg"
+  } > "$test_dir_/cleanup.log"
+  test -n "$d1" && losetup -d "$d1"
+  rm -f "$f1"
+}
+
+pv_suffix="__\"!@#\$%^&*()'\\\"__"
+
+test_expect_success \
+  'set up temp files, loopback devices' \
+  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
+  mv "$d1" "$d1$pv_suffix"                &&
+  d1=$d1$pv_suffix'
+
+test_expect_success \
+  'pvcreate, vgcreate on filename with backslashed chars' \
+  'pvcreate "$d1"                          &&
+  vg=$(this_test_)-test-vg-$$              &&
+  vgcreate $vg $d1'
+  
+test_expect_success \
+  'no parse errors and VG really exists' \
+  'vgs 2>err                                    &&
+  grep "Parse error" err;
+  status=$?; echo status=$?; test $status -ne 0 &&
+  vgs $vg'
+
+test_done
+# Local Variables:
+# indent-tabs-mode: nil
+# End:


