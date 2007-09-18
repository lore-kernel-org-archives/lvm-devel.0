From: meyering@sourceware.org <meyering@sourceware.org>
Date: 18 Sep 2007 14:00:44 -0000
Subject: LVM2 ./Makefile.in ./configure ./configure.in ...
Message-ID: <20070918140044.4600.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-09-18 14:00:42

Modified files:
	.              : Makefile.in configure configure.in 
Added files:
	test           : .gitignore Makefile.in lvm-utils.sh mkdtemp 
	                 t0000-basic.sh t3000-lvcreate-pvtags.sh 
	                 t4000-pv-range-overflow.sh test-lib.sh 

Log message:
	Add testing framework, along with first few tests.
	
	* Makefile.in (check): New target.
	* configure.in (AC_CONFIG_FILES): Add test/Makefile.
	* configure: Regenerate.
	* test/.gitignore: New file.
	* test/Makefile.in: New file.
	* test/lvm-utils.sh: New script.
	* test/mkdtemp (die, rand_bytes, mkdtemp): New script.
	* test/t0000-basic.sh: New tests.
	* test/t3000-lvcreate-pvtags.sh: New, failing test.
	Derived from a script by Jun'ichi Nomura.
	* test/t4000-pv-range-overflow.sh: New test.
	* test/test-lib.sh: Testing framework, based on the one from git.
	
	Author: Jim Meyering <jim@meyering.net>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/.gitignore.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/mkdtemp.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t0000-basic.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t3000-lvcreate-pvtags.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t4000-pv-range-overflow.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-lib.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/Makefile.in	2007/08/20 20:55:24	1.18
+++ LVM2/Makefile.in	2007/09/18 14:00:41	1.19
@@ -68,3 +68,6 @@
 	@CSCOPE_CMD@ -b -R
 all: cscope.out
 endif
+
+check: all
+	$(MAKE) -C test all
--- LVM2/configure	2007/09/12 18:23:02	1.61
+++ LVM2/configure	2007/09/18 14:00:41	1.62
@@ -11591,7 +11591,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile dmeventd/Makefile dmeventd/mirror/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile man/Makefile po/Makefile scripts/Makefile tools/Makefile tools/version.h tools/fsadm/Makefile test/mm/Makefile test/device/Makefile test/format1/Makefile test/regex/Makefile test/filters/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile dmeventd/Makefile dmeventd/mirror/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile man/Makefile po/Makefile scripts/Makefile tools/Makefile tools/version.h tools/fsadm/Makefile test/mm/Makefile test/device/Makefile test/format1/Makefile test/regex/Makefile test/filters/Makefile test/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -12206,6 +12206,7 @@
     "test/format1/Makefile") CONFIG_FILES="$CONFIG_FILES test/format1/Makefile" ;;
     "test/regex/Makefile") CONFIG_FILES="$CONFIG_FILES test/regex/Makefile" ;;
     "test/filters/Makefile") CONFIG_FILES="$CONFIG_FILES test/filters/Makefile" ;;
+    "test/Makefile") CONFIG_FILES="$CONFIG_FILES test/Makefile" ;;
 
   *) { { $as_echo "$as_me:$LINENO: error: invalid argument: $ac_config_target" >&5
 $as_echo "$as_me: error: invalid argument: $ac_config_target" >&2;}
--- LVM2/configure.in	2007/09/12 16:54:23	1.59
+++ LVM2/configure.in	2007/09/18 14:00:41	1.60
@@ -1,6 +1,6 @@
 ##
 ## Copyright (C) 2000-2004 Sistina Software, Inc. All rights reserved.
-## Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+## Copyright (C) 2004, 2007 Red Hat, Inc. All rights reserved.
 ##
 ## This file is part of the LVM2.
 ##
@@ -649,6 +649,7 @@
 lib/locking/Makefile							\
 lib/mirror/Makefile							\
 lib/snapshot/Makefile							\
+test/Makefile                                                           \
 man/Makefile							 	\
 po/Makefile								\
 scripts/Makefile								\
/cvs/lvm2/LVM2/test/.gitignore,v  -->  standard output
revision 1.1
--- LVM2/test/.gitignore
+++ -	2007-09-18 14:00:43.602140000 +0000
@@ -0,0 +1,4 @@
+.bin-dir-stamp
+Makefile
+bin
+init.sh
/cvs/lvm2/LVM2/test/Makefile.in,v  -->  standard output
revision 1.1
--- LVM2/test/Makefile.in
+++ -	2007-09-18 14:00:43.688053000 +0000
@@ -0,0 +1,75 @@
+#TEST_OPTS=--verbose --debug
+SHELL_PATH ?= $(SHELL)
+TAR ?= $(TAR)
+RM ?= rm -f
+
+subdir := $(shell pwd|sed 's,.*/,,')
+
+srcdir = .
+top_srcdir = ..
+top_builddir = ..
+abs_srcdir := $(shell cd $(srcdir) && pwd)
+abs_top_builddir := $(shell cd $(top_srcdir) && pwd)
+abs_top_srcdir = $(abs_top_builddir)
+# FIXME: for now, we assume top_srcdir == top_builddir,
+# but to permit non-srcdir builds, that will change.
+
+all: init.sh
+init.sh: Makefile.in .bin-dir-stamp
+	rm -f $@-t $@
+	echo 'top_srcdir=$(top_srcdir)' >> $@-t
+	echo 'abs_top_builddir=$(abs_top_builddir)' >> $@-t
+	echo 'abs_top_srcdir=$(abs_top_builddir)' >> $@-t
+	echo 'PATH=$(abs_top_builddir)/test/bin:$$PATH' >> $@-t
+	echo 'abs_srcdir=$(abs_srcdir)' >> $@-t
+	echo 'export PATH' >> $@-t
+	chmod a-w $@-t
+	mv $@-t $@
+
+# Shell quote;
+SHELL_PATH_SQ = $(subst ','\'',$(SHELL_PATH))
+
+# T = $(wildcard t[0-9][0-9][0-9][0-9]-*.sh)
+T = \
+  t0000-basic.sh \
+  t3000-lvcreate-pvtags.sh \
+  t4000-pv-range-overflow.sh
+
+Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
+	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@
+
+$(T): init.sh
+	@echo "*** $@ ***"; '$(SHELL_PATH_SQ)' \
+	  $(TESTS_ENVIRONMENT) $@ $(GIT_TEST_OPTS)
+
+dmdir = $(abs_top_srcdir)/../device-mapper
+so_name = $(dmdir)/lib/ioctl/libdevmapper.so.1.02
+
+# Having to create this link is a huge kludge,
+# and a major argument for including device-mapper in lvm.
+.bin-dir-stamp: lvm-wrapper
+	ln -fs libdevmapper.so $(so_name)
+	rm -rf bin
+	mkdir bin
+	for i in lvm $$(cat $(top_srcdir)/tools/.commands); do \
+	  ln -s ../lvm-wrapper bin/$$i; \
+	done
+	touch $@
+
+lvm-wrapper: Makefile
+	rm -f $@-t $@
+	echo '#!/bin/sh' >> $@-t
+	echo 'export LD_LIBRARY_PATH="$(dmdir)/lib/ioctl"' >> $@-t
+	echo 'cmd=$$(echo ./$$0|sed "s,.*/,,")' >> $@-t
+	echo 'test "$$cmd" = lvm &&' >> $@-t
+	echo 'exec "$(abs_top_builddir)/tools/lvm"         "$$@"' >> $@-t
+	echo 'exec "$(abs_top_builddir)/tools/lvm" "$$cmd" "$$@"' >> $@-t
+	chmod a-w,a+x $@-t
+	mv $@-t $@
+
+clean:
+	rm -rf init.sh lvm-wrapper bin .bin-dir-stamp
+
+all: $(T)
+.PHONY: $(T) clean
+.NOTPARALLEL:
/cvs/lvm2/LVM2/test/lvm-utils.sh,v  -->  standard output
revision 1.1
--- LVM2/test/lvm-utils.sh
+++ -	2007-09-18 14:00:43.774512000 +0000
@@ -0,0 +1,47 @@
+# Put lvm-related utilities here.
+# This file is sourced from test-lib.sh.
+
+export LVM_SUPPRESS_FD_WARNINGS=1
+
+ME=$(basename "$0")
+warn() { echo >&2 "$ME: $@"; }
+
+
+unsafe_losetup_()
+{
+  f=$1
+  # Prefer the race-free losetup from recent util-linux-ng.
+  dev=$(losetup --find --show "$f" 2>/dev/null) \
+      && { echo "$dev"; return 0; }
+
+  # If that fails, try to use util-linux-ng's -f "find-device" option.
+  dev=$(losetup -f 2>/dev/null) \
+      && losetup "$dev" "$f" \
+      && { echo "$dev"; return 0; }
+
+  # Last resort: iterate through /dev/loop{,/}{0,1,2,3,4,5,6,7,8,9}
+  for slash in '' /; do
+    for i in 0 1 2 3 4 5 6 7 8 9; do
+      dev=/dev/loop$slash$i
+      losetup $dev > /dev/null 2>&1 && continue;
+      losetup "$dev" "$f" > /dev/null && { echo "$dev"; return 0; }
+      break
+    done
+  done
+
+  return 1
+}
+
+loop_setup_()
+{
+  file=$1
+  dd if=/dev/zero of="$file" bs=1M count=1 seek=1000 > /dev/null 2>&1 \
+    || { warn "loop_setup_ failed: Unable to create tmp file $file"; return 1; }
+
+  # NOTE: this requires a new enough version of losetup
+  dev=$(unsafe_losetup_ "$file" 2>/dev/null) \
+    || { warn "loop_setup_ failed: Unable to create loopback device"; return 1; }
+
+  echo "$dev"
+  return 0;
+}
/cvs/lvm2/LVM2/test/mkdtemp,v  -->  standard output
revision 1.1
--- LVM2/test/mkdtemp
+++ -	2007-09-18 14:00:43.862371000 +0000
@@ -0,0 +1,107 @@
+#!/bin/sh
+# Create a temporary directory, sort of like mktemp -d does.
+# Usage: mkdtemp /tmp phoey.XXXXXXXXXX
+
+# First, try to use the mktemp program.
+# Failing that, we'll roll our own mktemp-like function:
+#  - try to get random bytes from /dev/urandom
+#  - failing that, generate output from a combination of quickly-varying
+#      sources and gzip.  Ignore non-varying gzip header, and extract
+#      "random" bits from there.
+#  - given those bits, map to file-name bytes using tr, and try to create
+#      the desired directory.
+#  - make only $MAX_TRIES attempts
+
+ME=$(basename "$0")
+die() { echo >&2 "$ME: $@"; exit 1; }
+
+MAX_TRIES=4
+
+rand_bytes()
+{
+  n=$1
+
+  chars=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789
+
+  dev_rand=/dev/urandom
+  if test -r "$dev_rand"; then
+    # Note: 256-length($chars) == 194; 3 copies of $chars is 186 + 8 = 194.
+    head -c$n "$dev_rand" | tr -c $chars 01234567$chars$chars$chars
+    return
+  fi
+
+  cmds='date; date +%N; free; who -a; w; ps auxww; ps ef; netstat -n'
+  data=$( (eval "$cmds") 2>&1 | gzip )
+
+  n_plus_50=$(expr $n + 50)
+
+  # Ensure that $data has length at least 50+$n
+  while :; do
+    len=$(echo "$data"|wc -c)
+    test $n_plus_50 -le $len && break;
+    data=$( (echo "$data"; eval "$cmds") 2>&1 | gzip )
+  done
+
+  echo "$data" \
+    | dd bs=1 skip=50 count=$n 2>/dev/null \
+    | tr -c $chars 01234567$chars$chars$chars
+}
+
+mkdtemp()
+{
+  case $# in
+  2);;
+  *) die "Usage: $ME DIR TEMPLATE";;
+  esac
+
+  destdir=$1
+  template=$2
+
+  case $template in
+  *XXXX) ;;
+  *) die "invalid template: $template (must have a suffix of at least 4 X's)";;
+  esac
+
+  fail=0
+
+  # First, try to use mktemp.
+  d=$(env -u TMPDIR mktemp -d -t -p "$destdir" "$template" 2>/dev/null) \
+    || fail=1
+
+  # The resulting name must be in the specified directory.
+  case $d in "$destdir"*);; *) fail=1;; esac
+
+  # It must have created the directory.
+  test -d "$d" || fail=1
+
+  # It must have 0700 permissions.
+  perms=$(ls -dgo "$d" 2>/dev/null) || fail=1
+  case $perms in drwx------*) ;; *) fail=1;; esac
+
+  test $fail = 0 && {
+    echo "$d"
+    return
+  }
+
+  # If we reach this point, we'll have to create a directory manually.
+
+  # Get a copy of the template without its suffix of X's.
+  base_template=$(echo "$template"|sed 's/XX*$//')
+
+  # Calculate how many X's we've just removed.
+  nx=$(expr length "$template" - length "$base_template")
+
+  err=
+  i=1
+  while :; do
+    X=$(rand_bytes $nx)
+    candidate_dir="$destdir/$base_template$X"
+    err=$(mkdir -m 0700 "$candidate_dir" 2>&1) \
+      && { echo "$candidate_dir"; return; }
+    test $MAX_TRIES -le $i && break;
+    i=$(expr $i + 1)
+  done
+  die "$err"
+}
+
+mkdtemp "$@"
/cvs/lvm2/LVM2/test/t0000-basic.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t0000-basic.sh
+++ -	2007-09-18 14:00:43.968067000 +0000
@@ -0,0 +1,26 @@
+#!/bin/sh
+
+test_description='Basics: see if tools are built, etc.'
+
+. ./test-lib.sh
+
+lvm >/dev/null 2>&1
+if test $? != 3; then
+    echo >&2 'You do not seem to have built lvm yet.'
+    exit 1
+fi
+
+v=$abs_top_srcdir/tools/version.h
+test_expect_success \
+  "get version string from $v" \
+  'sed -n "/#define LVM_VERSION ./s///p" '"$v"'|sed "s/ .*//" > expected'
+
+test_expect_success \
+  'get version of a just-built binary, ensuring PATH is set properly' \
+  'lvm pvmove --version|sed -n "1s/.*: *\([0-9][^ ]*\) .*/\1/p" > actual'
+
+test_expect_success \
+  'ensure they are the same' \
+  'diff -u actual expected'
+
+test_done
/cvs/lvm2/LVM2/test/t3000-lvcreate-pvtags.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t3000-lvcreate-pvtags.sh
+++ -	2007-09-18 14:00:44.083137000 +0000
@@ -0,0 +1,70 @@
+#!/bin/sh
+
+test_description='Ensure that pvmove diagnoses PE-range values 2^32 and larger.'
+privileges_required_=1
+
+. ./test-lib.sh
+
+cleanup_()
+{
+  test -n "$vg" && {
+    lvremove -ff $vg
+    vgremove $vg
+  } > /dev/null
+  test -n "$pvs" && {
+    pvremove $pvs > /dev/null
+    for d in $pvs; do
+      dmsetup remove $(basename $d)
+    done
+  }
+  losetup -d $lodev
+  rm -f $lofile
+}
+
+nr_pvs=3
+pvsize=$((200 * 1024 * 2))
+
+test_expect_success \
+  'set up temp file and loopback device' \
+  'lofile="$(pwd)/lofile" && lodev=$(loop_setup_ "$lofile")'
+
+offset=0
+pvs=
+for n in $(seq 1 $nr_pvs); do
+  test_expect_success \
+      "create pv$n" \
+      'echo "0 $pvsize linear $lodev $offset" > in &&
+       dmsetup create pv$n < in'
+  offset=$(($offset + $pvsize))
+done
+
+for n in $(seq 1 $nr_pvs); do
+  pvs="$pvs /dev/mapper/pv$n"
+done
+
+test_expect_success \
+  "Run this: pvcreate $pvs" \
+  'pvcreate $pvs'
+
+vg=lvcreate-pvtags-vg-$$
+test_expect_success "Run this: vgcreate $vg $pvs" \
+  'vgcreate $vg $pvs'
+test_expect_success "Run this: pvchange --addtag fast $pvs" \
+  'pvchange --addtag fast $pvs'
+
+test_expect_success t 'lvcreate -l3 -i3 $vg @fast'
+test_expect_failure u 'lvcreate -l4 -i4 $vg @fast'
+test_expect_failure v 'lvcreate -l2 -i2 $vg /dev/mapper/pv1'
+
+test_expect_success 'lvcreate mirror'           \
+  'lvcreate -l1 -m1 $vg @fast'
+test_expect_success 'lvcreate mirror corelog'   \
+  'lvcreate -l1 -m2 --corelog $vg @fast'
+test_expect_failure 'lvcreate mirror'           \
+  'lvcreate -l1 -m2 $vg @fast'
+test_expect_failure 'lvcreate mirror (corelog)' \
+  'lvcreate -l1 -m3 --corelog $vg @fast'
+test_expect_failure 'lvcreate mirror'           \
+  'lvcreate -l1 -m1 --corelog $vg /dev/mapper/pv1'
+
+test_done
/cvs/lvm2/LVM2/test/t4000-pv-range-overflow.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t4000-pv-range-overflow.sh
+++ -	2007-09-18 14:00:44.216992000 +0000
@@ -0,0 +1,52 @@
+#!/bin/sh
+
+test_description='Ensure that pvmove diagnoses PE-range values 2^32 and larger.'
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
+  } > /dev/null
+  test -n "$d1" && losetup -d "$d1"
+  test -n "$d2" && losetup -d "$d2"
+  rm -f "$f1" "$f2"
+}
+
+test_expect_success \
+  'set up temp files, loopback devices, PVs, VG, LV' \
+  'f1="$(pwd)/1" && d1=$(loop_setup_ "$f1") &&
+   f2="$(pwd)/2" && d2=$(loop_setup_ "$f2") &&
+   pvcreate $d1 $d2              &&
+   vg=pvmove-demo-vg-$$          &&
+   vgcreate "$vg" $d1 $d2        &&
+   lv=lv1                        &&
+   lvcreate -L4 -n"$lv" "$vg"'
+
+# Test for the bogus diagnostic reported in BZ 284771
+# http://bugzilla.redhat.com/284771.  Once the BZ is fixed,
+# update the code below to expect an improved diagnostic.
+test_expect_success \
+  'run pvmove with an unrecognized LV name to show bad diagnostic' \
+  'pvmove -v -nbogus $d1 $d2 2> err
+   test $? = 5 &&
+   tail -n1 err > out &&
+   echo "  No data to move for $vg" > expected &&
+   diff -u out expected'
+
+# With lvm-2.02.28 and earlier, on a system with 64-bit "long int",
+# the PE range parsing code would accept values up to 2^64-1, but would
+# silently truncate them to int32_t.  I.e., $d1:$(echo 2^32|bc) would be
+# treated just like $d1:0.
+test_expect_failure \
+  'run the offending pvmove command' \
+  'pvmove -v -n$lv $d1:4294967296 $d2'
+
+test_done
+# Local Variables:
+# indent-tabs-mode: nil
+# End:
/cvs/lvm2/LVM2/test/test-lib.sh,v  -->  standard output
revision 1.1
--- LVM2/test/test-lib.sh
+++ -	2007-09-18 14:00:44.326477000 +0000
@@ -0,0 +1,251 @@
+#!/bin/sh
+# Derived from git's t/test-lib.sh, which is Copyright (c) 2005 Junio C Hamano
+
+# For repeatability, reset the environment to known value.
+LANG=C
+LC_ALL=C
+TZ=UTC
+export LANG LC_ALL TZ
+
+. ./init.sh || { echo >&2 you must run make first; exit 1; }
+
+# Protect ourselves from common misconfiguration to export
+# CDPATH into the environment
+unset CDPATH
+
+# Each test should start with something like this, after copyright notices:
+#
+# test_description='Description of this test...
+# This test checks if command xyzzy does the right thing...
+# '
+# . ./test-lib.sh
+
+error () {
+	echo "* error: $*"
+	exit 1
+}
+
+say () {
+	echo "* $*"
+}
+
+this_test_() { expr "./$0" : '.*/\(t[0-9]*\)-[^/]*$'; }
+
+test "${test_description}" != "" ||
+error "Test script did not set test_description."
+
+while test "$#" -ne 0
+do
+	case "$1" in
+	-d|--d|--de|--deb|--debu|--debug)
+		debug=t; shift ;;
+	-i|--i|--im|--imm|--imme|--immed|--immedi|--immedia|--immediat|--immediate)
+		immediate=t; shift ;;
+	-h|--h|--he|--hel|--help)
+		echo "$test_description"
+		exit 0 ;;
+	-v|--v|--ve|--ver|--verb|--verbo|--verbos|--verbose)
+		verbose=t; shift ;;
+	esac
+done
+
+exec 5>&1
+if test "$verbose" = "t"
+then
+	exec 4>&2 3>&1
+else
+	exec 4>/dev/null 3>/dev/null
+fi
+
+test_failure=0
+test_count=0
+
+trap 'echo >&5 "FATAL: Unexpected exit with code $?"; exit 1' exit
+
+# You are not expected to call test_ok_ and test_failure_ directly, use
+# the text_expect_* functions instead.
+
+test_ok_ () {
+	test_count=$(expr "$test_count" + 1)
+	say "  ok $test_count: $@"
+}
+
+test_failure_ () {
+	test_count=$(expr "$test_count" + 1)
+	test_failure=$(expr "$test_failure" + 1);
+	say "FAIL $test_count: $1"
+	shift
+	echo "$@" | sed -e 's/^/	/'
+	test "$immediate" = "" || exit 1
+}
+
+test_debug () {
+	test "$debug" = "" || eval "$1"
+}
+
+test_run_ () {
+	eval >&3 2>&4 "$1"
+	eval_ret="$?"
+	return 0
+}
+
+test_skip () {
+	this_test=$(this_test_)
+	this_test="$this_test.$(expr "$test_count" + 1)"
+	to_skip=
+	for skp in $SKIP_TESTS
+	do
+		case "$this_test" in
+		$skp)
+			to_skip=t
+		esac
+	done
+	case "$to_skip" in
+	t)
+		say >&3 "skipping test: $@"
+		test_count=$(expr "$test_count" + 1)
+		say "skip $test_count: $1"
+		: true
+		;;
+	*)
+		false
+		;;
+	esac
+}
+
+test_expect_failure () {
+	test "$#" = 2 ||
+	error "bug in the test script: not 2 parameters to test-expect-failure"
+	if ! test_skip "$@"
+	then
+		say >&3 "expecting failure: $2"
+		test_run_ "$2"
+		if [ "$?" = 0 -a "$eval_ret" != 0 -a "$eval_ret" -lt 129 ]
+		then
+			test_ok_ "$1"
+		else
+			test_failure_ "$@"
+		fi
+	fi
+	echo >&3 ""
+}
+
+test_expect_success () {
+	test "$#" = 2 ||
+	error "bug in the test script: not 2 parameters to test-expect-success"
+	if ! test_skip "$@"
+	then
+		say >&3 "expecting success: $2"
+		test_run_ "$2"
+		if [ "$?" = 0 -a "$eval_ret" = 0 ]
+		then
+			test_ok_ "$1"
+		else
+			test_failure_ "$@"
+		fi
+	fi
+	echo >&3 ""
+}
+
+test_expect_code () {
+	test "$#" = 3 ||
+	error "bug in the test script: not 3 parameters to test-expect-code"
+	if ! test_skip "$@"
+	then
+		say >&3 "expecting exit code $1: $3"
+		test_run_ "$3"
+		if [ "$?" = 0 -a "$eval_ret" = "$1" ]
+		then
+			test_ok_ "$2"
+		else
+			test_failure_ "$@"
+		fi
+	fi
+	echo >&3 ""
+}
+
+test_done () {
+	case "$test_failure" in
+	0)
+		# We could:
+		# cd .. && rm -fr trash
+		# but that means we forbid any tests that use their own
+		# subdirectory from calling test_done without coming back
+		# to where they started from.
+		# The Makefile provided will clean this test area so
+		# we will leave things as they are.
+
+		say "passed all $test_count test(s)"
+		exit 0 ;;
+
+	*)
+		say "failed $test_failure among $test_count test(s)"
+		exit 1 ;;
+
+	esac
+}
+
+. lvm-utils.sh
+
+this_test=$(this_test_)
+
+skip_=0
+# If $privileges_required_ is nonempty, non-root skips this test.
+if test "$privileges_required_" != ''; then
+    uid=`id -u` || error 'failed to run "id -u"'
+    if test "$uid" != 0; then
+	SKIP_TESTS="$SKIP_TESTS $this_test"
+	say "you have insufficient privileges for test $this_test"
+	skip_=1
+    fi
+fi
+
+# Test the binaries we have just built.
+abs_top_srcdir=$(cd .. && pwd)
+pwd_=`pwd`
+
+test_dir_=${LVM_TEST_DIR-.}
+test "$test_dir_" = . && test_dir_=$pwd_
+
+# This is a stub function that is run upon trap (upon regular exit and
+# interrupt).  Override it with a per-test function, e.g., to unmount
+# a partition, or to undo any other global state changes.
+cleanup_() { :; }
+
+for skp in $SKIP_TESTS
+do
+	to_skip=
+	for skp in $SKIP_TESTS
+	do
+		case "$this_test" in
+		$skp)
+			to_skip=t
+		esac
+	done
+	case "$to_skip" in
+	t)
+		say >&3 "skipping test $this_test altogether"
+		say "skip all tests in $this_test"
+		trap - exit
+		test_done
+	esac
+done
+
+t0=$($abs_srcdir/mkdtemp $test_dir_ lvm-$this_test.XXXXXXXXXX) \
+    || error "failed to create temporary directory in $test_dir_"
+
+# Run each test from within a temporary sub-directory named after the
+# test itself, and arrange to remove it upon exception or normal exit.
+trap 'st=$?; cleanup_; d='"$t0"';
+    cd '"$test_dir_"' && chmod -R u+rwx "$d" && rm -rf "$d" && exit $st' 0
+trap '(exit $?); exit $?' 1 2 13 15
+
+cd $t0 || error "failed to cd to $t0"
+
+if ( diff --version < /dev/null 2>&1 | grep GNU ) 2>&1 > /dev/null; then
+  compare='diff -u'
+elif ( cmp --version < /dev/null 2>&1 | grep GNU ) 2>&1 > /dev/null; then
+  compare='cmp -s'
+else
+  compare=cmp
+fi


