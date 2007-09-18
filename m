From: meyering@sourceware.org <meyering@sourceware.org>
Date: 18 Sep 2007 14:02:24 -0000
Subject: LVM2/test Makefile.in lvm-utils.sh mkdtemp t00 ...
Message-ID: <20070918140224.6791.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-09-18 14:02:22

Modified files:
	test           : Makefile.in lvm-utils.sh mkdtemp t0000-basic.sh 
	                 t1000-lvcreate-usage.sh 
	                 t3000-lvcreate-pvtags.sh 
	                 t4000-pv-range-overflow.sh test-lib.sh 

Log message:
	Clean-up and wording changes; add copyright notices.
	
	* test/Makefile.in (srcdir, top_srcdir): Use @srcdir@, etc.
	(top_builddir, abs_srcdir, abs_top_builddir, abs_top_srcdir): Likewise.
	(so_name): Remove definition.
	(.bin-dir-stamp): No longer create symlink in $(DMDIR) tree.
	Prompted by suggestions from Alasdair Kergon.
	* test/t1000-lvcreate-usage.sh (cleanup_): Redirect to a file,
	rather than to /dev/null.
	Change wording of some test titles.
	Suggestions from Alasdair Kergon.
	
	* test/Makefile.in: Add a copyright notice.
	* test/lvm-utils.sh: Likewise.
	* test/mkdtemp: Likewise.
	* test/t0000-basic.sh: Likewise.
	* test/t1000-lvcreate-usage.sh: Likewise.
	* test/t3000-lvcreate-pvtags.sh: Likewise.
	* test/t4000-pv-range-overflow.sh: Likewise.
	* test/test-lib.sh: Likewise.
	
	Author: Jim Meyering <jim@meyering.net>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/mkdtemp.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t0000-basic.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t1000-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t3000-lvcreate-pvtags.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t4000-pv-range-overflow.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-lib.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/Makefile.in	2007/09/18 14:01:46	1.3
+++ LVM2/test/Makefile.in	2007/09/18 14:02:22	1.4
@@ -1,3 +1,15 @@
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 #TEST_OPTS=--verbose --debug
 SHELL_PATH ?= $(SHELL)
 TAR ?= $(TAR)
@@ -5,14 +17,12 @@
 
 subdir := $(shell pwd|sed 's,.*/,,')
 
-srcdir = .
-top_srcdir = ..
-top_builddir = ..
-abs_srcdir := $(shell cd $(srcdir) && pwd)
-abs_top_builddir := $(shell cd $(top_srcdir) && pwd)
-abs_top_srcdir = $(abs_top_builddir)
-# FIXME: for now, we assume top_srcdir == top_builddir,
-# but to permit non-srcdir builds, that will change.
+srcdir = @srcdir@
+top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
+abs_srcdir = @abs_srcdir@
+abs_top_builddir = @abs_top_builddir@
+abs_top_srcdir = @abs_top_srcdir@
 
 all: init.sh
 init.sh: Makefile.in .bin-dir-stamp
@@ -43,13 +53,7 @@
 	@echo "*** $@ ***"; '$(SHELL_PATH_SQ)' \
 	  $(TESTS_ENVIRONMENT) $@ $(GIT_TEST_OPTS)
 
-so_name = @DMDIR@/lib/ioctl/libdevmapper.so.1.02
-
-# Having to create this symlink is an ugly kludge,
-# and a major argument for including device-mapper in lvm.
 .bin-dir-stamp: lvm-wrapper
-	test -n "@DMDIR@" \
-	  && ln -fs libdevmapper.so $(so_name)
 	rm -rf bin
 	mkdir bin
 	for i in lvm $$(cat $(top_srcdir)/tools/.commands); do \
@@ -59,12 +63,12 @@
 
 lvm-wrapper: Makefile
 	rm -f $@-t $@
-	echo '#!/bin/sh' >> $@-t
+	echo '#!/bin/sh'                                          >  $@-t
 	test -n "@DMDIR@" \
-	  && echo 'export LD_LIBRARY_PATH="@DMDIR@/lib/ioctl"' >> $@-t
-	echo 'cmd=$$(echo ./$$0|sed "s,.*/,,")' >> $@-t
-	echo 'test "$$cmd" = lvm &&' >> $@-t
-	echo 'exec "$(abs_top_builddir)/tools/lvm"         "$$@"' >> $@-t
+	  && echo 'export LD_LIBRARY_PATH="@DMDIR@/lib/ioctl"'    >> $@-t
+	echo 'cmd=$$(echo ./$$0|sed "s,.*/,,")'                   >> $@-t
+	echo 'test "$$cmd" = lvm &&'                              >> $@-t
+	echo 'exec "$(abs_top_builddir)/tools/lvm" "$$@"'         >> $@-t
 	echo 'exec "$(abs_top_builddir)/tools/lvm" "$$cmd" "$$@"' >> $@-t
 	chmod a-w,a+x $@-t
 	mv $@-t $@
--- LVM2/test/lvm-utils.sh	2007/09/18 14:00:42	1.1
+++ LVM2/test/lvm-utils.sh	2007/09/18 14:02:22	1.2
@@ -1,12 +1,21 @@
 # Put lvm-related utilities here.
 # This file is sourced from test-lib.sh.
 
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
 export LVM_SUPPRESS_FD_WARNINGS=1
 
 ME=$(basename "$0")
 warn() { echo >&2 "$ME: $@"; }
 
-
 unsafe_losetup_()
 {
   f=$1
--- LVM2/test/mkdtemp	2007/09/18 14:00:42	1.1
+++ LVM2/test/mkdtemp	2007/09/18 14:02:22	1.2
@@ -1,5 +1,18 @@
 #!/bin/sh
 # Create a temporary directory, sort of like mktemp -d does.
+
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
+# Written by Jim Meyering.
+
 # Usage: mkdtemp /tmp phoey.XXXXXXXXXX
 
 # First, try to use the mktemp program.
--- LVM2/test/t0000-basic.sh	2007/09/18 14:00:42	1.1
+++ LVM2/test/t0000-basic.sh	2007/09/18 14:02:22	1.2
@@ -1,4 +1,13 @@
 #!/bin/sh
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='Basics: see if tools are built, etc.'
 
--- LVM2/test/t1000-lvcreate-usage.sh	2007/09/18 14:01:46	1.1
+++ LVM2/test/t1000-lvcreate-usage.sh	2007/09/18 14:02:22	1.2
@@ -1,4 +1,13 @@
 #!/bin/sh
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='Exercise some lvcreate diagnostics'
 privileges_required_=1
@@ -11,7 +20,7 @@
     vgchange -an "$vg"
     lvremove -ff "$vg"
     vgremove "$vg"
-  } > /dev/null
+  } > "$test_dir_/cleanup.log"
   test -n "$d1" && losetup -d "$d1"
   test -n "$d2" && losetup -d "$d2"
   rm -f "$f1" "$f2"
@@ -28,12 +37,12 @@
 lv=lvcreate-usage-$$
 
 test_expect_success \
-  'lvcreate w/negative stripesize must fail' \
+  'lvcreate rejects a negative stripesize' \
   'lvcreate -L 64M -n $lv -i2 --stripesize -4 $vg 2>err; test $? = 3 &&
    grep "^  Negative stripesize is invalid\$" err'
 
 test_expect_success \
-  'lvcreate w/too-large stripesize must fail' \
+  'lvcreate rejects a too-large stripesize' \
   'lvcreate -L 64M -n $lv -i2 --stripesize 4294967291 $vg 2>err; test $? = 3 &&
    grep "^  Stripe size cannot be larger than 512.00 GB\$" err'
 
@@ -53,13 +62,13 @@
    lvremove -ff $vg'
 
 test_expect_success \
-  'lvcreate w/invalid number of stripes must fail' \
+  'lvcreate rejects an invalid number of stripes' \
   'lvcreate -L 64M -n $lv -i129 $vg 2>err; test $? = 3 &&
    grep "^  Number of stripes (129) must be between 1 and 128\$" err'
 
 # The case on lvdisplay output is to verify that the LV was not created.
 test_expect_success \
-  'lvcreate w/invalid stripe size must fail' \
+  'lvcreate rejects an invalid stripe size' \
   'lvcreate -L 64M -n $lv -i2 --stripesize 3 $vg 2>err; test $? = 3 &&
    grep "^  Invalid stripe size 3\.00 KB\$" err &&
    case "$(lvdisplay $vg)" in "") true ;; *) false ;; esac'
--- LVM2/test/t3000-lvcreate-pvtags.sh	2007/09/18 14:00:42	1.1
+++ LVM2/test/t3000-lvcreate-pvtags.sh	2007/09/18 14:02:22	1.2
@@ -1,4 +1,13 @@
 #!/bin/sh
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='Ensure that pvmove diagnoses PE-range values 2^32 and larger.'
 privileges_required_=1
--- LVM2/test/t4000-pv-range-overflow.sh	2007/09/18 14:00:42	1.1
+++ LVM2/test/t4000-pv-range-overflow.sh	2007/09/18 14:02:22	1.2
@@ -1,4 +1,13 @@
 #!/bin/sh
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='Ensure that pvmove diagnoses PE-range values 2^32 and larger.'
 privileges_required_=1
--- LVM2/test/test-lib.sh	2007/09/18 14:00:42	1.1
+++ LVM2/test/test-lib.sh	2007/09/18 14:02:22	1.2
@@ -1,5 +1,13 @@
 #!/bin/sh
 # Derived from git's t/test-lib.sh, which is Copyright (c) 2005 Junio C Hamano
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 # For repeatability, reset the environment to known value.
 LANG=C


