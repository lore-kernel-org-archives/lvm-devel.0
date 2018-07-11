From: David Teigland <teigland@sourceware.org>
Date: Wed, 11 Jul 2018 12:28:40 -0400
Subject: master - tests: remove lvmetad tests
Message-ID: <201807111628.w6BGSeir009386@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=63ec42f428e010dcc638d887a5089d491b36b0e9
Commit:        63ec42f428e010dcc638d887a5089d491b36b0e9
Parent:        117160b27e510dceb1ed6acf995115c040acd88d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jul 10 14:40:48 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 11 11:27:54 2018 -0500

tests: remove lvmetad tests

---
 test/Makefile.in                    |   67 +++-------------------
 test/shell/lvmetad-ambiguous.sh     |   73 ------------------------
 test/shell/lvmetad-autoshutdown.sh  |   58 -------------------
 test/shell/lvmetad-client-filter.sh |   22 -------
 test/shell/lvmetad-disabled.sh      |  107 -----------------------------------
 test/shell/lvmetad-dump.sh          |   26 ---------
 test/shell/lvmetad-lvscan-cache.sh  |   35 -----------
 test/shell/lvmetad-no-cluster.sh    |   24 --------
 test/shell/lvmetad-override.sh      |   54 ------------------
 test/shell/lvmetad-pvs.sh           |   25 --------
 test/shell/lvmetad-pvscan-filter.sh |   57 ------------------
 test/shell/lvmetad-pvscan-md.sh     |   38 ------------
 test/shell/lvmetad-pvscan-nomda.sh  |   59 -------------------
 test/shell/lvmetad-restart.sh       |   29 ---------
 test/shell/lvmetad-sysinit.sh       |   92 ------------------------------
 test/shell/lvmetad-test.sh          |   38 ------------
 16 files changed, 8 insertions(+), 796 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 5b7578c..5185322 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -38,7 +38,7 @@ CLEAN_TARGETS += $(RUN_BASE) $(addprefix lib/,$(LIB_LVMLOCKD_CONF) $(LIB_MKE2FS_
 endif
 
 CLEAN_TARGETS += .lib-dir-stamp .tests-stamp $(LIB) $(addprefix lib/,\
-	$(CMDS) clvmd dmeventd dmsetup dmstats lvmetad lvmpolld \
+	$(CMDS) clvmd dmeventd dmsetup dmstats lvmpolld \
 	harness lvmdbusd.profile thin-performance.profile fsadm \
 	dm-version-expected version-expected \
 	paths-installed paths-installed-t paths-common paths-common-t)
@@ -54,16 +54,10 @@ comma = ,
 RUN := $(shell find -L $(srcdir) -regextype posix-egrep \( -path \*/shell/\*.sh -or -path \*/unit/\*.sh \) -and -regex "$(srcdir)/.*($(subst $(comma),|,$(T))).*" -and -not -regex "$(srcdir)/.*($(subst $(comma),|,$(S))).*" | $(SORT))
 RUN_BASE = $(subst $(srcdir)/,,$(RUN))
 
-ifeq ("@BUILD_LVMETAD@", "yes")
-LVMETAD_RUN_BASE = $(RUN_BASE)
-LVMETAD_NDEV_FLAVOUR = ,ndev-lvmetad
-LVMETAD_UDEV_FLAVOUR = ,udev-lvmetad
-endif
-
 ifeq ("@BUILD_LVMPOLLD@", "yes")
 LVMPOLLD_RUN_BASE = $(RUN_BASE)
-LVMPOLLD_NDEV_FLAVOUR = ,ndev-lvmpolld,ndev-cluster-lvmpolld,ndev-lvmetad-lvmpolld
-LVMPOLLD_UDEV_FLAVOUR = ,udev-lvmpolld,udev-cluster-lvmpolld,udev-lvmetad-lvmpolld
+LVMPOLLD_NDEV_FLAVOUR = ,ndev-lvmpolld
+LVMPOLLD_UDEV_FLAVOUR = ,udev-lvmpolld
 endif
 
 ifeq ("@BUILD_LVMLOCKD@", "yes")
@@ -85,17 +79,12 @@ help:
 	@echo "  all			Default target, run check."
 	@echo "  check			Run all tests."
 	@echo "  check_system		Run all tests using udev."
-	@echo "  check_local		Run tests without clvmd and lvmetad."
-	@echo "  check_cluster		Run tests with cluster daemon."
-	@echo "  check_lvmetad		Run tests with lvmetad daemon."
+	@echo "  check_local		Run tests."
 	@echo "  check_lvmpolld         Run tests with lvmpolld daemon."
-	@echo "  check_cluster_lvmpolld Run tests with clvmd and lvmpolld daemon."
-	@echo "  check_lvmetad_lvmpolld Run tests with lvmetad and lvmpolld daemon."
 	@echo "  check_all_lvmpolld     Run all tests with lvmpolld daemon."
 	@echo "  check_lvmlockd_sanlock Run tests with lvmlockd and sanlock."
 	@echo "  check_lvmlockd_dlm     Run tests with lvmlockd and dlm."
 	@echo "  check_lvmlockd_test    Run tests with lvmlockd --test."
-	@echo "  check_lvmlockd_test_lvmetad Run tests with lvmlockd --test and lvmetad."
 	@echo "  run-unit-test          Run only unit tests (root not needed)."
 	@echo "  clean			Clean dir."
 	@echo "  help			Display callable targets."
@@ -107,7 +96,6 @@ help:
 	@echo "  LVM_TEST_PREFER_BRD	Prefer using brd (ramdisk) over loop for testing [1]."
 	@echo "  LVM_TEST_DIR		Where to create test files  [$(LVM_TEST_DIR)]."
 	@echo "  LVM_TEST_LOCKING	Normal (1), Cluster (3)."
-	@echo "  LVM_TEST_LVMETAD	Start lvmetad (1)."
 	@echo "  LVM_TEST_LVMETAD_DEBUG_OPTS  Allows to override debug opts [-l all]."
 	@echo "  LVM_TEST_LVMPOLLD	Start lvmpolld"
 	@echo "  LVM_TEST_NODEBUG	Do not debug lvm commands."
@@ -124,7 +112,6 @@ help:
 	@echo "  LVM_TEST_UNLIMITED	Set to get unlimited test log (>32MB)"
 	@echo "  LVM_VALGRIND		Enable valgrind testing, execs $$"VALGRIND.
 	@echo "  LVM_VALGRIND_DMEVENTD	Enable valgrind testing of dmeventd (1)."
-	@echo "  LVM_VALGRIND_LVMETAD	Enable valgrind testing of lvmetad (1)."
 	@echo "  LVM_STRACE		Enable strace logging."
 	@echo "  LVM_DEBUG_LEVEL	Sets debuging level for valgrind/strace (use > 0)."
 	@echo "  LVM_VERIFY_UDEV	Default verify state for lvm.conf."
@@ -136,50 +123,28 @@ help:
 check: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir $(LVM_TEST_RESULTS) \
-		--flavours ndev-vanilla,ndev-cluster$(LVMETAD_NDEV_FLAVOUR)$(LVMPOLLD_NDEV_FLAVOUR) --only $(T) --skip $(S)
+		--flavours ndev-vanilla,$(LVMETAD_NDEV_FLAVOUR)$(LVMPOLLD_NDEV_FLAVOUR) --only $(T) --skip $(S)
 
 check_system: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir $(LVM_TEST_RESULTS) \
-		--flavours udev-vanilla,udev-cluster$(LVMETAD_UDEV_FLAVOUR)$(LVMPOLLD_UDEV_FLAVOUR)$(LVMLOCKD_UDEV_FLAVOUR) --only $(T) --skip $(S)
-
-check_cluster: .tests-stamp
-	VERBOSE=$(VERBOSE) ./lib/runner \
-		--testdir . --outdir $(LVM_TEST_RESULTS) \
-		--flavours ndev-cluster --only $(T) --skip $(S)
+		--flavours udev-vanilla,$(LVMETAD_UDEV_FLAVOUR)$(LVMPOLLD_UDEV_FLAVOUR)$(LVMLOCKD_UDEV_FLAVOUR) --only $(T) --skip $(S)
 
 check_local: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir $(LVM_TEST_RESULTS) \
 		--flavours ndev-vanilla --only $(T) --skip $(S)
 
-ifeq ("@BUILD_LVMETAD@", "yes")
-check_lvmetad: .tests-stamp
-	VERBOSE=$(VERBOSE) ./lib/runner \
-		--testdir . --outdir $(LVM_TEST_RESULTS) \
-		--flavours ndev-lvmetad --only $(T) --skip $(S)
-endif
-
 ifeq ("@BUILD_LVMPOLLD@", "yes")
 check_lvmpolld: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir results \
 		--flavours ndev-lvmpolld --only $(T) --skip $(S)
 
-check_cluster_lvmpolld: .tests-stamp
-	VERBOSE=$(VERBOSE) ./lib/runner \
-		--testdir . --outdir results \
-		--flavours ndev-cluster-lvmpolld --only $(T) --skip $(S)
-
-check_lvmetad_lvmpolld: .tests-stamp
-	VERBOSE=$(VERBOSE) ./lib/runner \
-		--testdir . --outdir results \
-		--flavours ndev-lvmetad-lvmpolld --only $(T) --skip $(S)
-
 check_all_lvmpolld: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir results \
-		--flavours ndev-lvmpolld,ndev-cluster-lvmpolld,ndev-lvmetad-lvmpolld --only $(T) --skip $(S)
+		--flavours ndev-lvmpolld --only $(T) --skip $(S)
 endif
 
 ifeq ("@BUILD_LVMLOCKD@", "yes")
@@ -203,13 +168,6 @@ check_lvmlockd_test: .tests-stamp
 		--flavours udev-lvmlockd-test --only $(T) --skip $(S)
 endif
 
-ifeq ("@BUILD_LVMLOCKD@", "yes")
-check_lvmlockd_test_lvmetad: .tests-stamp
-	VERBOSE=$(VERBOSE) ./lib/runner \
-		--testdir . --outdir results \
-		--flavours udev-lvmlockd-test-lvmetad --only $(T) --skip $(S)
-endif
-
 run-unit-test unit-test:
 	$(MAKE) -C unit $(@)
 
@@ -217,21 +175,12 @@ DATADIR = $(datadir)/lvm2-testsuite
 EXECDIR = $(libexecdir)/lvm2-testsuite
 
 LIB_FLAVOURS = \
- flavour-ndev-cluster-lvmpolld\
- flavour-ndev-cluster\
- flavour-ndev-lvmetad-lvmpolld\
- flavour-ndev-lvmetad\
  flavour-ndev-lvmpolld\
  flavour-ndev-vanilla\
- flavour-udev-cluster-lvmpolld\
- flavour-udev-cluster\
- flavour-udev-lvmetad-lvmpolld\
- flavour-udev-lvmetad\
  flavour-udev-lvmpolld\
  flavour-udev-lvmlockd-sanlock\
  flavour-udev-lvmlockd-dlm\
  flavour-udev-lvmlockd-test\
- flavour-udev-lvmlockd-test-lvmetad\
  flavour-udev-vanilla
 
 LIB_LVMLOCKD_CONF = \
@@ -362,7 +311,7 @@ LIB = $(addprefix lib/, $(LIB_SHARED) $(LIB_LOCAL) $(LIB_NOT) $(LIB_LINK_NOT) $(
 	$(RM) lib/clvmd
 	for i in $(CMDS); do $(LN_S) -f lvm-wrapper lib/$$i; done
 	for i in daemons/dmeventd/dmeventd \
-		libdm/dm-tools/dmsetup daemons/lvmetad/lvmetad \
+		libdm/dm-tools/dmsetup \
 		daemons/lvmpolld/lvmpolld ; do \
 		$(LN_S) -f $(abs_top_builddir)/$$i lib/; done
 	$(LN_S) -f $(abs_top_builddir)/libdm/dm-tools/dmsetup lib/dmstats
diff --git a/test/shell/lvmetad-ambiguous.sh b/test/shell/lvmetad-ambiguous.sh
deleted file mode 100644
index 4b69c13..0000000
--- a/test/shell/lvmetad-ambiguous.sh
+++ /dev/null
@@ -1,73 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITHOUT_LVMETAD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-aux prepare_pvs 2
-
-# flip the devices around
-init_udev_transaction
-dmsetup remove "$dev1"
-dmsetup remove "$dev2"
-dmsetup create -u TEST-${PREFIX}pv1 ${PREFIX}pv2 ${PREFIX}pv2.table
-dmsetup create -u TEST-${PREFIX}pv2 ${PREFIX}pv1 ${PREFIX}pv1.table
-finish_udev_transaction
-dmsetup info -c
-
-# re-scan them
-pvscan --cache "$dev1" || true
-pvscan --cache "$dev2" || true
-
-# expect both to be there
-pvs -a -o name | tee out
-grep "$dev1" out
-grep "$dev2" out
-
-aux lvmetad_dump
-
-# flip the devices 2nd. time around
-init_udev_transaction
-dmsetup remove "$dev1"
-dmsetup remove "$dev2"
-dmsetup create -u TEST-${PREFIX}pv2 ${PREFIX}pv2 ${PREFIX}pv2.table
-dmsetup create -u TEST-${PREFIX}pv1 ${PREFIX}pv1 ${PREFIX}pv1.table
-finish_udev_transaction
-
-# re-scan them
-pvscan --cache "$dev1" || true
-pvscan --cache "$dev2" || true
-
-# expect both to be there
-pvs -a -o name | tee out
-grep "$dev1" out
-grep "$dev2" out
-
-aux lvmetad_dump
-
-# flip the devices 2nd. time around
-dmsetup remove -f "$dev1"
-dmsetup remove -f "$dev2"
-dmsetup create -u TEST-${PREFIX}pv1 ${PREFIX}pv2 ${PREFIX}pv2.table
-dmsetup create -u TEST-${PREFIX}pv2 ${PREFIX}pv1 ${PREFIX}pv1.table
-
-# re-scan them
-pvscan --cache "$dev1" || true
-pvscan --cache "$dev2" || true
-
-# expect both to be there
-pvs -a -o name | tee out
-grep "$dev1" out
-grep "$dev2" out
diff --git a/test/shell/lvmetad-autoshutdown.sh b/test/shell/lvmetad-autoshutdown.sh
deleted file mode 100644
index c8a5c0c..0000000
--- a/test/shell/lvmetad-autoshutdown.sh
+++ /dev/null
@@ -1,58 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITHOUT_LVMETAD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-kill -0 "$(< LOCAL_LVMETAD)" || die "lvmetad is already dead"
-
-lvmetad_timeout=3
-
-aux prepare_pvs 1
-
-vgcreate $vg1 "$dev1"
-
-kill "$(< LOCAL_LVMETAD)"
-aux prepare_lvmetad -t $lvmetad_timeout
-
-sleep $lvmetad_timeout
-
-# lvmetad should die after timeout, but give it some time to do so
-i=0
-while kill -0 "$(< LOCAL_LVMETAD)" 2>/dev/null; do
-	test $i -ge $((lvmetad_timeout*10)) && die "lvmetad didn't shutdown with optional timeout: $lvmetad_timeout seconds"
-	sleep .1
-	i=$((i+1))
-done
-
-aux prepare_lvmetad -t 0
-sleep 1
-# lvmetad must not die with -t 0 option
-kill -0 "$(< LOCAL_LVMETAD)" || die "lvmetad died"
-
-kill "$(< LOCAL_LVMETAD)"
-aux prepare_lvmetad -t $lvmetad_timeout
-
-sleep 1
-vgs
-sleep 1
-vgs
-sleep 1
-vgs
-
-# check that connection to lvmetad resets the timeout
-kill -0 "$(< LOCAL_LVMETAD)" || die "lvmetad died too soon"
-
-vgremove -ff $vg1
diff --git a/test/shell/lvmetad-client-filter.sh b/test/shell/lvmetad-client-filter.sh
deleted file mode 100644
index 095099b..0000000
--- a/test/shell/lvmetad-client-filter.sh
+++ /dev/null
@@ -1,22 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITHOUT_LVMETAD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-aux prepare_pvs 2
-
-pvs --config 'devices { filter = [ "r%.*%" ] }' 2>&1 | grep rejected
-pvs --config 'devices { filter = [ "r%.*%" ] }' 2>&1 | not grep 'No device found'
diff --git a/test/shell/lvmetad-disabled.sh b/test/shell/lvmetad-disabled.sh
deleted file mode 100644
index 84d7b54..0000000
--- a/test/shell/lvmetad-disabled.sh
+++ /dev/null
@@ -1,107 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITHOUT_LVMETAD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-aux prepare_devs 2
-
-kill "$(< LOCAL_LVMETAD)"
-for i in {200..0} ; do
-	test -e "$TESTDIR/lvmetad.socket" || break
-	test "$i" -eq 0 && die "Too slow closing of lvmetad.socket. Aborting test."
-	echo -n .; sleep .1;
-done # wait for the socket close
-test ! -e "$LVM_LVMETAD_PIDFILE"
-
-aux lvmconf "global/use_lvmetad = 0"
-
-pvcreate "$dev1"
-pvcreate "$dev2"
-vgcreate $vg1 "$dev1"
-vgcreate $vg2 "$dev2"
-
-lvcreate -n $lv1 -l1 $vg1
-
-pvs 2>&1 | tee out
-grep "$dev1" out
-grep "$dev2" out
-
-vgs 2>&1 | tee out
-grep $vg1 out
-grep $vg2 out
-
-aux lvmconf "global/use_lvmetad = 1"
-lvmetad
-while ! test -e "$TESTDIR/lvmetad.socket"; do echo -n .; sleep .1; done # wait for the socket
-test -e "$LVM_LVMETAD_PIDFILE"
-cp "$LVM_LVMETAD_PIDFILE" LOCAL_LVMETAD
-
-pvscan --cache
-pvs 2>&1 | tee out
-grep "$dev1" out
-grep "$dev2" out
-not grep "WARNING: Not using lvmetad" out
-
-# We don't care about the repair, and we know it's
-# not valid on this lv.  We are just running repair
-# because we know one side effect is to disable lvmetad.
-# FIXME: we should install lvmetactl so that we can
-# use that to directly disable lvmetad for tests like this.
-not lvconvert --repair $vg1/$lv1 2>&1 | tee out
-grep "WARNING: Disabling lvmetad cache" out
-
-pvs  -vvvv 2>&1 | tee out
-grep "$dev1" out
-grep "$dev2" out
-grep "WARNING: Not using lvmetad" out
-
-vgs  2>&1 | tee out
-grep $vg1 out
-grep $vg2 out
-grep "WARNING: Not using lvmetad" out
-
-vgchange -an $vg1
-vgremove -y $vg1 2>&1 | tee out
-grep "WARNING: Not using lvmetad" out
-
-pvremove "$dev1" 2>&1 | tee out
-grep "WARNING: Not using lvmetad" out
-
-pvscan --cache  2>&1 | tee out
-not grep "WARNING: Disabling lvmetad cache" out
-
-pvs 2>&1 | tee out
-not grep "$dev1" out
-grep "$dev2" out
-not grep "WARNING: Not using lvmetad" out
-
-vgs 2>&1 | tee out
-not grep $vg1 out
-grep $vg2 out
-not grep "WARNING: Not using lvmetad" out
-
-pvs --config 'global/use_lvmetad=0' 2>&1 | tee out
-not grep "$dev1" out
-grep "$dev2" out
-grep "WARNING: Not using lvmetad" out
-grep "use_lvmetad=0" out
-
-vgs --config 'global/use_lvmetad=0' 2>&1 | tee out
-not grep $vg1 out
-grep $vg2 out
-grep "WARNING: Not using lvmetad" out
-grep "use_lvmetad=0" out
-
diff --git a/test/shell/lvmetad-dump.sh b/test/shell/lvmetad-dump.sh
deleted file mode 100644
index 8c9e74f..0000000
--- a/test/shell/lvmetad-dump.sh
+++ /dev/null
@@ -1,26 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITHOUT_LVMETAD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-aux prepare_vg 2
-lvcreate -n bar -l 1 $vg
-
-aux lvmetad_dump | tee lvmetad.txt
-
-grep $vg lvmetad.txt
-
-vgremove -ff $vg
diff --git a/test/shell/lvmetad-lvscan-cache.sh b/test/shell/lvmetad-lvscan-cache.sh
deleted file mode 100644
index 28b62fd..0000000
--- a/test/shell/lvmetad-lvscan-cache.sh
+++ /dev/null
@@ -1,35 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITHOUT_LVMETAD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-aux prepare_pvs 2
-
-vgcreate $vg1 "$dev1" "$dev2"
-lvcreate -n testlv --type mirror -m 1 -l 1 $vg1
-vgs | grep $vg1
-
-lvscan --cache $vg1/testlv
-
-vgs | grep $vg1
-
-aux disable_dev "$dev2"
-
-# pvscan --cache already ran for the disabled device above, this should be a
-# no-op (but should not segfault!)
-lvscan --cache $vg1/testlv
-
-vgremove -ff $vg1
diff --git a/test/shell/lvmetad-no-cluster.sh b/test/shell/lvmetad-no-cluster.sh
deleted file mode 100644
index d5eb23b..0000000
--- a/test/shell/lvmetad-no-cluster.sh
+++ /dev/null
@@ -1,24 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITHOUT_CLVMD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-aux prepare_vg 2
-aux prepare_lvmetad
-vgs 2>&1 | tee out
-grep "WARNING: Not using lvmetad because locking_type is 3" out
-
-vgremove -ff $vg
diff --git a/test/shell/lvmetad-override.sh b/test/shell/lvmetad-override.sh
deleted file mode 100644
index 91367ff..0000000
--- a/test/shell/lvmetad-override.sh
+++ /dev/null
@@ -1,54 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITHOUT_LVMETAD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-aux prepare_pvs 2
-
-vgcreate $vg1 "$dev1" "$dev2"
-lvcreate -an -l1 --zero n -n $lv1 $vg1
-
-lvchange -ay $vg1 2>&1 | tee out
-not grep "WARNING: Failed to connect" out
-check active $vg1 $lv1
-lvchange -an $vg1
-check inactive $vg1 $lv1
-
-kill "$(< LOCAL_LVMETAD)"
-
-lvchange -ay $vg1 2>&1 | tee out
-grep "WARNING: Failed to connect" out
-check active $vg1 $lv1
-lvchange -an $vg1
-check inactive $vg1 $lv1
-
-lvchange -ay --config global/use_lvmetad=0 $vg1 2>&1 | tee out
-# FIXME: this warning appears when the command tries to connect to
-# lvmetad during refresh at the end after the --config is cleared.
-should not grep "WARNING: Failed to connect" out
-check active $vg1 $lv1
-lvchange -an $vg1
-check inactive $vg1 $lv1
-
-aux lvmconf "global/use_lvmetad = 0"
-
-lvchange -ay --config global/use_lvmetad=1 $vg1 2>&1 | tee out
-grep "WARNING: Failed to connect" out
-check active $vg1 $lv1
-lvchange -an $vg1
-check inactive $vg1 $lv1
-
-vgremove -ff $vg1
diff --git a/test/shell/lvmetad-pvs.sh b/test/shell/lvmetad-pvs.sh
deleted file mode 100644
index dc4189d..0000000
--- a/test/shell/lvmetad-pvs.sh
+++ /dev/null
@@ -1,25 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-aux prepare_pvs 1 20000
-get_devs
-
-pvs "${DEVICES[@]}" | grep "$dev1"
-
-# check for PV size overflows
-pvs "${DEVICES[@]}" | grep 19.53g
-pvs "${DEVICES[@]}" | not grep 16.00e
diff --git a/test/shell/lvmetad-pvscan-filter.sh b/test/shell/lvmetad-pvscan-filter.sh
deleted file mode 100644
index 677b35f..0000000
--- a/test/shell/lvmetad-pvscan-filter.sh
+++ /dev/null
@@ -1,57 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITHOUT_LVMETAD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-aux prepare_pvs 2
-
-maj=$(($(stat -L --printf=0x%t "$dev2")))
-min=$(($(stat -L --printf=0x%T "$dev2")))
-
-# Filter out device, pvscan should trigger
-# clearing of the device from lvmetad cache.
-
-# We can't use aux hide_dev here because that
-# changes the global_filter which triggers a
-# token mismatch rescan by subsequent pvscan
-# commands instead of the single-dev scans
-# that are testing here.
-
-mv "$dev2" "$dev2-HIDDEN"
-
-pvscan --cache "$dev2" 2>&1 | tee out || true
-grep "not found" out
-
-# pvscan with --major/--minor does not fail: lvmetad needs to
-# be notified about device removal on REMOVE uevent, hence
-# this should not fail so udev does not grab a "failed" state
-# incorrectly. We notify device addition and removal with
-# exactly the same command "pvscan --cache" - in case of removal,
-# this is detected by nonexistence of the device itself.
-
-pvscan --cache --major $maj --minor $min 2>&1 | tee out || true
-grep "not found" out
-
-# aux unhide_dev "$dev2"
-mv "$dev2-HIDDEN" "$dev2"
-
-pvscan --cache "$dev2" 2>&1 | tee out || true
-not grep "not found" out
-
-pvscan --cache --major $maj --minor $min 2>&1 | tee out || true
-not grep "not found" out
-
-pvs | grep "$dev2"
diff --git a/test/shell/lvmetad-pvscan-md.sh b/test/shell/lvmetad-pvscan-md.sh
deleted file mode 100644
index 5fb4d50..0000000
--- a/test/shell/lvmetad-pvscan-md.sh
+++ /dev/null
@@ -1,38 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2014-2015 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITHOUT_LVMETAD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
-	modprobe raid0 || skip
-
-aux prepare_devs 2
-
-# create 2 disk MD raid0 array (stripe_width=128K)
-aux prepare_md_dev 0 64 2 "$dev1" "$dev2"
-
-aux lvmconf 'devices/md_component_detection = 1'
-aux extend_filter_LVMTEST "a|/dev/md|"
-
-pvdev=$(< MD_DEV_PV)
-
-pvcreate "$pvdev"
-
-# ensure that lvmetad can only see the toplevel MD device
-pvs | tee out
-grep "$pvdev" out
-not grep "$dev1" out
-not grep "$dev2" out
diff --git a/test/shell/lvmetad-pvscan-nomda.sh b/test/shell/lvmetad-pvscan-nomda.sh
deleted file mode 100644
index c28d984..0000000
--- a/test/shell/lvmetad-pvscan-nomda.sh
+++ /dev/null
@@ -1,59 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITHOUT_LVMETAD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-kill "$(< LOCAL_LVMETAD)"
-rm LOCAL_LVMETAD
-
-aux prepare_devs 2
-
-pvcreate --metadatacopies 0 "$dev1"
-pvcreate --metadatacopies 1 "$dev2"
-vgcreate $vg1 "$dev1" "$dev2"
-lvcreate -n foo -l 1 -an --zero n $vg1
-
-# start lvmetad but make sure it doesn't know about $dev1 or $dev2
-aux disable_dev "$dev1" "$dev2"
-aux prepare_lvmetad
-lvs
-mv LOCAL_LVMETAD XXX
-aux enable_dev "$dev2" "$dev1"
-mv XXX LOCAL_LVMETAD
-
-aux lvmconf 'global/use_lvmetad = 0'
-check inactive $vg1 foo
-aux lvmconf 'global/use_lvmetad = 1'
-
-# Tell lvmetad about dev2, but the VG is not complete with
-# only dev2, so the -aay should not yet activate the LV.
-
-pvscan --cache -aay "$dev2"
-
-aux lvmconf 'global/use_lvmetad = 0'
-check inactive $vg1 foo
-aux lvmconf 'global/use_lvmetad = 1'
-
-# Tell lvmetad about dev1, now the VG is complete with
-# both devs, so the -aay should activate the LV.
-
-pvscan --cache -aay "$dev1"
-
-aux lvmconf 'global/use_lvmetad = 0'
-check active $vg1 foo
-aux lvmconf 'global/use_lvmetad = 1'
-
-vgremove -ff $vg1
diff --git a/test/shell/lvmetad-restart.sh b/test/shell/lvmetad-restart.sh
deleted file mode 100644
index 2e49f75..0000000
--- a/test/shell/lvmetad-restart.sh
+++ /dev/null
@@ -1,29 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITHOUT_LVMETAD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-aux prepare_pvs 2
-
-vgcreate $vg1 "$dev1" "$dev2"
-vgs | grep $vg1
-
-kill "$(< LOCAL_LVMETAD)"
-aux prepare_lvmetad
-
-vgs | grep $vg1
-
-vgremove -ff $vg1
diff --git a/test/shell/lvmetad-sysinit.sh b/test/shell/lvmetad-sysinit.sh
deleted file mode 100644
index 8116e51..0000000
--- a/test/shell/lvmetad-sysinit.sh
+++ /dev/null
@@ -1,92 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITHOUT_LVMETAD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-aux prepare_pvs 2
-
-#
-# lvchange/vgchange -aay --sysinit should not activate LVs
-# if lvmetad is configured and running.
-#
-
-vgcreate $vg1 "$dev1" "$dev2"
-lvcreate -an -l1 --zero n -n $lv1 $vg1
-
-#
-# lvmetad is configured and running
-#
-
-lvchange -ay $vg1 2>&1 | tee out
-not grep "WARNING: Failed to connect" out
-not grep "WARNING: lvmetad is active, skipping direct activation during sysinit" out
-check active $vg1 $lv1
-lvchange -an $vg1
-check inactive $vg1 $lv1
-
-lvchange -aay --sysinit $vg1 2>&1 | tee out
-not grep "WARNING: Failed to connect" out
-grep "WARNING: lvmetad is active, skipping direct activation during sysinit" out
-check inactive $vg1 $lv1
-
-lvchange -ay --sysinit $vg1 2>&1 | tee out
-not grep "WARNING: Failed to connect" out
-not grep "WARNING: lvmetad is active, skipping direct activation during sysinit" out
-check active $vg1 $lv1
-lvchange -an $vg1
-check inactive $vg1 $lv1
-
-#
-# lvmetad is configured and not running
-#
-
-kill "$(< LOCAL_LVMETAD)"
-
-lvchange -ay $vg1 2>&1 | tee out
-grep "WARNING: Failed to connect" out
-not grep "WARNING: lvmetad is active, skipping direct activation during sysinit" out
-check active $vg1 $lv1
-lvchange -an $vg1
-check inactive $vg1 $lv1
-
-lvchange -aay --sysinit $vg1 2>&1 | tee out
-grep "WARNING: Failed to connect" out
-not grep "WARNING: lvmetad is active, skipping direct activation during sysinit" out
-check active $vg1 $lv1
-lvchange -an $vg1
-check inactive $vg1 $lv1
-
-#
-# lvmetad is not configured and not running
-#
-
-aux lvmconf 'global/use_lvmetad = 0'
-
-lvchange -ay $vg1 2>&1 | tee out
-not grep "WARNING: Failed to connect" out
-not grep "WARNING: lvmetad is active, skipping direct activation during sysinit" out
-check active $vg1 $lv1
-lvchange -an $vg1
-check inactive $vg1 $lv1
-
-lvchange -aay $vg1 --sysinit 2>&1 | tee out
-not grep "WARNING: Failed to connect"
-not grep "WARNING: lvmetad is active, skipping direct activation during sysinit" out
-check active $vg1 $lv1
-lvchange -an $vg1
-check inactive $vg1 $lv1
-
-vgremove -ff $vg1
diff --git a/test/shell/lvmetad-test.sh b/test/shell/lvmetad-test.sh
deleted file mode 100644
index 0daf1e4..0000000
--- a/test/shell/lvmetad-test.sh
+++ /dev/null
@@ -1,38 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-aux prepare_pvs 2
-
-vgcreate $vg1 "$dev1" "$dev2" --test
-vgs | not grep $vg1
-vgcreate $vg1 "$dev1" "$dev2"
-vgs | grep $vg1
-
-lvcreate -n bar -l 1 $vg1 --test
-lvs | not grep bar
-lvcreate -n bar -l 1 $vg1
-lvs | grep bar
-
-lvremove $vg1/bar -f --test
-lvs | grep bar
-lvremove $vg1/bar -f
-lvs | not grep bar
-
-vgremove $vg1 --test
-vgs | grep $vg1
-vgremove $vg1
-vgs | not grep $vg1


