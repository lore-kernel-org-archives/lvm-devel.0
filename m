From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Feb 2016 15:37:03 +0000 (UTC)
Subject: master - test: add make check_lvmlockd_test
Message-ID: <20160222153703.1084D60ED1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=161ae36363f5fa1b1469fd3a42c096c878002b31
Commit:        161ae36363f5fa1b1469fd3a42c096c878002b31
Parent:        ed5e5c38b5ac4b7c8cb7e809d9d35c72f087e29e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 14 16:12:46 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 22 09:36:35 2016 -0600

test: add make check_lvmlockd_test

Which runs lvmlockd in --test mode, without
any lock manager.

Also make some adjustments to the check_lvmlockd
variations using the lock managds.
---
 daemons/lvmlockd/lvmlockd-core.c          |    5 ++
 test/Makefile.in                          |   21 +++----
 test/lib/flavour-udev-lvmlockd-test.sh    |    6 ++
 test/lib/test-sanlock-conf                |    2 +-
 test/shell/aa-lvmlockd-dlm-prepare.sh     |   90 +++++++++++++++++++++++++++++
 test/shell/aa-lvmlockd-sanlock-prepare.sh |   85 +++++++++++++++++++++++++++
 test/shell/aa-lvmlockd-test-prepare.sh    |   44 ++++++++++++++
 test/shell/dlm-prepare.sh                 |   90 -----------------------------
 test/shell/dlm-remove.sh                  |   24 --------
 test/shell/lvmlockd-lv-types.sh           |    6 ++
 test/shell/sanlock-prepare.sh             |   87 ----------------------------
 test/shell/sanlock-remove.sh              |   39 ------------
 test/shell/zz-lvmlockd-dlm-remove.sh      |   24 ++++++++
 test/shell/zz-lvmlockd-sanlock-remove.sh  |   41 +++++++++++++
 test/shell/zz-lvmlockd-test-remove.sh     |   23 +++++++
 15 files changed, 334 insertions(+), 253 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 292d19c..76a7650 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -3365,6 +3365,11 @@ static void *worker_thread_main(void *arg_in)
 			int run_sanlock = lm_is_running_sanlock();
 			int run_dlm = lm_is_running_dlm();
 
+			if (daemon_test) {
+				run_sanlock = gl_use_sanlock;
+				run_dlm = gl_use_dlm;
+			}
+
 			if (run_sanlock && run_dlm)
 				act->result = -EXFULL;
 			else if (!run_sanlock && !run_dlm)
diff --git a/test/Makefile.in b/test/Makefile.in
index 742399b..19a0214 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -74,6 +74,7 @@ help:
 	@echo "  check_lvmpolld         Run tests with lvmpolld daemon."
 	@echo "  check_lvmlockd_sanlock Run tests with lvmlockd and sanlock."
 	@echo "  check_lvmlockd_dlm     Run tests with lvmlockd and dlm."
+	@echo "  check_lvmlockd_test    Run tests with lvmlockd --test."
 	@echo "  clean			Clean dir."
 	@echo "  help			Display callable targets."
 	@echo -e "\nSupported variables:"
@@ -146,26 +147,21 @@ ifeq ("@BUILD_LVMLOCKD@", "yes")
 check_lvmlockd_sanlock: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir results \
-		--flavours udev-lvmlockd-sanlock --only shell/sanlock-prepare.sh
-	VERBOSE=$(VERBOSE) ./lib/runner \
-		--testdir . --outdir results \
-		--flavours udev-lvmlockd-sanlock --only $(T) --skip $(S)
-	VERBOSE=$(VERBOSE) ./lib/runner \
-		--testdir . --outdir results \
-		--flavours udev-lvmlockd-sanlock --only shell/sanlock-remove.sh
+		--flavours udev-lvmlockd-sanlock --only shell/aa-lvmlockd-sanlock-prepare.sh,$(T),shell/zz-lvmlockd-sanlock-remove.sh --skip $(S)
 endif
 
 ifeq ("@BUILD_LVMLOCKD@", "yes")
 check_lvmlockd_dlm: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir results \
-		--flavours udev-lvmlockd-dlm --only shell/dlm-prepare.sh
-	VERBOSE=$(VERBOSE) ./lib/runner \
-		--testdir . --outdir results \
-		--flavours udev-lvmlockd-dlm --only $(T) --skip $(S)
+		--flavours udev-lvmlockd-dlm --only shell/aa-lvmlockd-dlm-prepare.sh,$(T),shell/zz-lvmlockd-dlm-remove.sh --skip $(S)
+endif
+
+ifeq ("@BUILD_LVMLOCKD@", "yes")
+check_lvmlockd_test: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir results \
-		--flavours udev-lvmlockd-dlm --only shell/dlm-remove.sh
+		--flavours udev-lvmlockd-test --only shell/aa-lvmlockd-test-prepare.sh,$(T),shell/zz-lvmlockd-test-remove.sh --skip $(S)
 endif
 
 DATADIR = $(datadir)/lvm2-testsuite
@@ -185,6 +181,7 @@ LIB_FLAVOURS = \
  flavour-udev-lvmpolld\
  flavour-udev-lvmlockd-sanlock\
  flavour-udev-lvmlockd-dlm\
+ flavour-udev-lvmlockd-test\
  flavour-udev-vanilla
 
 LIB_LVMLOCKD_CONF = \
diff --git a/test/lib/flavour-udev-lvmlockd-test.sh b/test/lib/flavour-udev-lvmlockd-test.sh
new file mode 100644
index 0000000..60b67b1
--- /dev/null
+++ b/test/lib/flavour-udev-lvmlockd-test.sh
@@ -0,0 +1,6 @@
+export LVM_TEST_LOCKING=1
+export LVM_TEST_LVMETAD=1
+export LVM_TEST_LVMPOLLD=1
+export LVM_TEST_LVMLOCKD=1
+export LVM_TEST_LVMLOCKD_TEST=1
+export LVM_TEST_DEVDIR=/dev
diff --git a/test/lib/test-sanlock-conf b/test/lib/test-sanlock-conf
index d1df598..6285d63 100644
--- a/test/lib/test-sanlock-conf
+++ b/test/lib/test-sanlock-conf
@@ -1,2 +1,2 @@
 # created by lvm test suite
-SANLOCKOPTS="-U sanlock -G sanlock -w 0"
+use_watchdog=0
diff --git a/test/shell/aa-lvmlockd-dlm-prepare.sh b/test/shell/aa-lvmlockd-dlm-prepare.sh
new file mode 100644
index 0000000..e1e1a73
--- /dev/null
+++ b/test/shell/aa-lvmlockd-dlm-prepare.sh
@@ -0,0 +1,90 @@
+#!/bin/sh
+# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+test_description='Set up things to run tests with dlm'
+
+. lib/utils
+. lib/inittest
+
+[ -z "$LVM_TEST_LOCK_TYPE_DLM" ] && skip;
+
+COROSYNC_CONF="/etc/corosync/corosync.conf"
+COROSYNC_NODE="$(hostname)"
+create_corosync_conf() {
+	if test -a $COROSYNC_CONF; then
+		if ! grep "created by lvm test suite" $COROSYNC_CONF; then
+			rm $COROSYNC_CONF
+		else
+			mv $COROSYNC_CONF $COROSYNC_CONF.prelvmtest
+		fi
+	fi
+
+	sed -e "s/@LOCAL_NODE@/$COROSYNC_NODE/" lib/test-corosync-conf > $COROSYNC_CONF
+	echo "created new $COROSYNC_CONF"
+}
+
+DLM_CONF="/etc/dlm/dlm.conf"
+create_dlm_conf() {
+	if test -a $DLM_CONF; then
+		if ! grep "created by lvm test suite" $DLM_CONF; then
+			rm $DLM_CONF
+		else
+			mv $DLM_CONF $DLM_CONF.prelvmtest
+		fi
+	fi
+
+	cp lib/test-dlm-conf $DLM_CONF
+	echo "created new $DLM_CONF"
+}
+
+prepare_lvmlockd_dlm() {
+	if pgrep lvmlockd ; then
+		echo "Cannot run while existing lvmlockd process exists"
+		exit 1
+	fi
+
+	if pgrep dlm_controld ; then
+		echo "Cannot run while existing dlm_controld process exists"
+		exit 1
+	fi
+
+	if pgrep corosync; then
+		echo "Cannot run while existing corosync process exists"
+		exit 1
+	fi
+
+	create_corosync_conf
+	create_dlm_conf
+
+	systemctl start corosync
+	sleep 1
+	if ! pgrep corosync; then
+		echo "Failed to start corosync"
+		exit 1
+	fi
+
+	systemctl start dlm
+	sleep 1
+	if ! pgrep dlm_controld; then
+		echo "Failed to start dlm"
+		exit 1
+	fi
+
+	lvmlockd
+	sleep 1
+	if ! pgrep lvmlockd ; then
+		echo "Failed to start lvmlockd"
+		exit 1
+	fi
+}
+
+prepare_lvmlockd_dlm
+
diff --git a/test/shell/aa-lvmlockd-sanlock-prepare.sh b/test/shell/aa-lvmlockd-sanlock-prepare.sh
new file mode 100644
index 0000000..22127ad
--- /dev/null
+++ b/test/shell/aa-lvmlockd-sanlock-prepare.sh
@@ -0,0 +1,85 @@
+#!/bin/sh
+# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+test_description='Set up things to run tests with sanlock'
+
+. lib/utils
+. lib/inittest
+
+[ -z "$LVM_TEST_LOCK_TYPE_SANLOCK" ] && skip;
+
+SANLOCK_CONF="/etc/sanlock/sanlock.conf"
+create_sanlock_conf() {
+	if test -a $SANLOCK_CONF; then
+		if ! grep "created by lvm test suite" $SANLOCK_CONF; then
+			rm $SANLOCK_CONF
+		else
+			mv $SANLOCK_CONF $SANLOCK_CONF.prelvmtest
+		fi
+	fi
+
+	cp lib/test-sanlock-conf $SANLOCK_CONF
+	echo "created new $SANLOCK_CONF"
+}
+
+prepare_lvmlockd_sanlock() {
+	if pgrep lvmlockd ; then
+		echo "Cannot run while existing lvmlockd process exists"
+		exit 1
+	fi
+
+	if pgrep sanlock ; then
+		echo "Cannot run while existing sanlock process exists"
+		exit 1
+	fi
+
+	create_sanlock_conf
+
+	systemctl start sanlock
+	if ! pgrep sanlock; then
+		echo "Failed to start sanlock"
+		exit 1
+	fi
+
+	# FIXME: use 'systemctl start lvm2-lvmlockd' once we can pass -o 2
+	lvmlockd -o 2
+	sleep 1
+	if ! pgrep lvmlockd; then
+		echo "Failed to start lvmlockd"
+		exit 1
+	fi
+}
+
+# Create a device and a VG that are both outside the scope of
+# the standard lvm test suite so that they will not be removed
+# and will remain in place while all the tests are run.
+#
+# Use this VG to hold the sanlock global lock which will be used
+# by lvmlockd during other tests.
+#
+# This script will be run before any standard tests are run.
+# After all the tests are run, another script will be run
+# to remove this VG and device.
+
+GL_DEV="/dev/mapper/GL_DEV"
+GL_FILE="$PWD/gl_file.img"
+dmsetup remove GL_DEV || true
+rm -f "$GL_FILE"
+dd if=/dev/zero of="$GL_FILE" bs=$((1024*1024)) count=1024 2> /dev/null
+GL_LOOP=$(losetup -f "$GL_FILE" --show)
+echo "0 `blockdev --getsize $GL_LOOP` linear $GL_LOOP 0" | dmsetup create GL_DEV
+
+prepare_lvmlockd_sanlock
+
+vgcreate --config 'devices { global_filter=["a|GL_DEV|", "r|.*|"] filter=["a|GL_DEV|", "r|.*|"]}' --lock-type sanlock glvg $GL_DEV
+
+vgs --config 'devices { global_filter=["a|GL_DEV|", "r|.*|"] filter=["a|GL_DEV|", "r|.*|"]}' -o+locktype,lockargs glvg
+
diff --git a/test/shell/aa-lvmlockd-test-prepare.sh b/test/shell/aa-lvmlockd-test-prepare.sh
new file mode 100644
index 0000000..99ec86f
--- /dev/null
+++ b/test/shell/aa-lvmlockd-test-prepare.sh
@@ -0,0 +1,44 @@
+#!/bin/sh
+# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Set up things to run tests with lvmlockd'
+
+. lib/utils
+. lib/inittest
+
+[ -z "$LVM_TEST_LVMLOCKD_TEST" ] && skip;
+
+# TODO: allow this to be configured sanlock/dlm
+LVM_TEST_LVMLOCKD_TEST_DLM=1
+
+prepare_lvmlockd_test() {
+	if pgrep lvmlockd ; then
+		echo "Cannot run while existing lvmlockd process exists"
+		exit 1
+	fi
+
+	if test -n "$LVM_TEST_LVMLOCKD_TEST_SANLOCK"; then
+		lvmlockd --test -g sanlock
+	fi
+
+	if test -n "$LVM_TEST_LVMLOCKD_TEST_DLM"; then
+		lvmlockd --test -g dlm
+	fi
+
+	sleep 1
+	if ! pgrep lvmlockd ; then
+		echo "Failed to start lvmlockd"
+		exit 1
+	fi
+}
+
+prepare_lvmlockd_test
+
diff --git a/test/shell/dlm-prepare.sh b/test/shell/dlm-prepare.sh
deleted file mode 100644
index e1e1a73..0000000
--- a/test/shell/dlm-prepare.sh
+++ /dev/null
@@ -1,90 +0,0 @@
-#!/bin/sh
-# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-test_description='Set up things to run tests with dlm'
-
-. lib/utils
-. lib/inittest
-
-[ -z "$LVM_TEST_LOCK_TYPE_DLM" ] && skip;
-
-COROSYNC_CONF="/etc/corosync/corosync.conf"
-COROSYNC_NODE="$(hostname)"
-create_corosync_conf() {
-	if test -a $COROSYNC_CONF; then
-		if ! grep "created by lvm test suite" $COROSYNC_CONF; then
-			rm $COROSYNC_CONF
-		else
-			mv $COROSYNC_CONF $COROSYNC_CONF.prelvmtest
-		fi
-	fi
-
-	sed -e "s/@LOCAL_NODE@/$COROSYNC_NODE/" lib/test-corosync-conf > $COROSYNC_CONF
-	echo "created new $COROSYNC_CONF"
-}
-
-DLM_CONF="/etc/dlm/dlm.conf"
-create_dlm_conf() {
-	if test -a $DLM_CONF; then
-		if ! grep "created by lvm test suite" $DLM_CONF; then
-			rm $DLM_CONF
-		else
-			mv $DLM_CONF $DLM_CONF.prelvmtest
-		fi
-	fi
-
-	cp lib/test-dlm-conf $DLM_CONF
-	echo "created new $DLM_CONF"
-}
-
-prepare_lvmlockd_dlm() {
-	if pgrep lvmlockd ; then
-		echo "Cannot run while existing lvmlockd process exists"
-		exit 1
-	fi
-
-	if pgrep dlm_controld ; then
-		echo "Cannot run while existing dlm_controld process exists"
-		exit 1
-	fi
-
-	if pgrep corosync; then
-		echo "Cannot run while existing corosync process exists"
-		exit 1
-	fi
-
-	create_corosync_conf
-	create_dlm_conf
-
-	systemctl start corosync
-	sleep 1
-	if ! pgrep corosync; then
-		echo "Failed to start corosync"
-		exit 1
-	fi
-
-	systemctl start dlm
-	sleep 1
-	if ! pgrep dlm_controld; then
-		echo "Failed to start dlm"
-		exit 1
-	fi
-
-	lvmlockd
-	sleep 1
-	if ! pgrep lvmlockd ; then
-		echo "Failed to start lvmlockd"
-		exit 1
-	fi
-}
-
-prepare_lvmlockd_dlm
-
diff --git a/test/shell/dlm-remove.sh b/test/shell/dlm-remove.sh
deleted file mode 100644
index 3848c0e..0000000
--- a/test/shell/dlm-remove.sh
+++ /dev/null
@@ -1,24 +0,0 @@
-#!/bin/sh
-# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-test_description='Remove the dlm test setup'
-
-. lib/inittest
-
-[ -z "$LVM_TEST_LOCK_TYPE_DLM" ] && skip;
-
-# FIXME: collect debug logs (only if a test failed?)
-# lvmlockctl -d > lvmlockd-debug.txt
-# dlm_tool dump > dlm-debug.txt
-
-systemctl stop dlm
-systemctl stop corosync
-killall lvmlockd
diff --git a/test/shell/lvmlockd-lv-types.sh b/test/shell/lvmlockd-lv-types.sh
index 70c856e..8e12776 100644
--- a/test/shell/lvmlockd-lv-types.sh
+++ b/test/shell/lvmlockd-lv-types.sh
@@ -27,6 +27,12 @@ LOCKARGS2="dlm"
 LOCKARGS3="dlm"
 fi
 
+if test -n "$LVM_TEST_LVMLOCKD_TEST" ; then
+LOCKARGS1="dlm"
+LOCKARGS2="dlm"
+LOCKARGS3="dlm"
+fi
+
 aux prepare_devs 5
 
 vgcreate --shared $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
diff --git a/test/shell/sanlock-prepare.sh b/test/shell/sanlock-prepare.sh
deleted file mode 100644
index aabd9f6..0000000
--- a/test/shell/sanlock-prepare.sh
+++ /dev/null
@@ -1,87 +0,0 @@
-#!/bin/sh
-# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-test_description='Set up things to run tests with sanlock'
-
-. lib/utils
-. lib/inittest
-
-[ -z "$LVM_TEST_LOCK_TYPE_SANLOCK" ] && skip;
-
-SANLOCK_CONF="/etc/sysconfig/sanlock"
-create_sanlock_conf() {
-	if test -a $SANLOCK_CONF; then
-		if ! grep "created by lvm test suite" $SANLOCK_CONF; then
-			rm $SANLOCK_CONF
-		else
-			mv $SANLOCK_CONF $SANLOCK_CONF.prelvmtest
-		fi
-	fi
-
-	cp lib/test-sanlock-conf $SANLOCK_CONF
-	echo "created new $SANLOCK_CONF"
-}
-
-prepare_lvmlockd_sanlock() {
-	if pgrep lvmlockd ; then
-		echo "Cannot run while existing lvmlockd process exists"
-		exit 1
-	fi
-
-	if pgrep sanlock ; then
-		echo "Cannot run while existing sanlock process exists"
-		exit 1
-	fi
-
-	create_sanlock_conf
-
-	# FIXME: use 'systemctl start sanlock' once we can pass options
-	sanlock daemon -U sanlock -G sanlock -w 0 -e testhostname
-	sleep 1
-	if ! pgrep sanlock; then
-		echo "Failed to start sanlock"
-		exit 1
-	fi
-
-	# FIXME: use 'systemctl start lvm2-lvmlockd' once we can pass -o 2
-	lvmlockd -o 2
-	sleep 1
-	if ! pgrep lvmlockd; then
-		echo "Failed to start lvmlockd"
-		exit 1
-	fi
-}
-
-# Create a device and a VG that are both outside the scope of
-# the standard lvm test suite so that they will not be removed
-# and will remain in place while all the tests are run.
-#
-# Use this VG to hold the sanlock global lock which will be used
-# by lvmlockd during other tests.
-#
-# This script will be run before any standard tests are run.
-# After all the tests are run, another script will be run
-# to remove this VG and device.
-
-GL_DEV="/dev/mapper/GL_DEV"
-GL_FILE="$PWD/gl_file.img"
-dmsetup remove GL_DEV || true
-rm -f "$GL_FILE"
-dd if=/dev/zero of="$GL_FILE" bs=$((1024*1024)) count=1024 2> /dev/null
-GL_LOOP=$(losetup -f "$GL_FILE" --show)
-echo "0 `blockdev --getsize $GL_LOOP` linear $GL_LOOP 0" | dmsetup create GL_DEV
-
-prepare_lvmlockd_sanlock
-
-vgcreate --config 'devices { global_filter=["a|GL_DEV|", "r|.*|"] filter=["a|GL_DEV|", "r|.*|"]}' --lock-type sanlock glvg $GL_DEV
-
-vgs --config 'devices { global_filter=["a|GL_DEV|", "r|.*|"] filter=["a|GL_DEV|", "r|.*|"]}' -o+locktype,lockargs glvg
-
diff --git a/test/shell/sanlock-remove.sh b/test/shell/sanlock-remove.sh
deleted file mode 100644
index e22aae8..0000000
--- a/test/shell/sanlock-remove.sh
+++ /dev/null
@@ -1,39 +0,0 @@
-#!/bin/sh
-# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-test_description='Remove the sanlock test setup'
-
-. lib/inittest
-
-[ -z "$LVM_TEST_LOCK_TYPE_SANLOCK" ] && skip;
-
-# FIMXME: get this to run after a test fails
-
-# Removes the VG with the global lock that was created by
-# the corresponding create script.
-
-vgremove --config 'devices { global_filter=["a|GL_DEV|", "r|.*|"] filter=["a|GL_DEV|", "r|.*|"]}' glvg
-
-# FIXME: collect debug logs (only if a test failed?)
-# lvmlockctl -d > lvmlockd-debug.txt
-# sanlock log_dump > sanlock-debug.txt
-
-killall lvmlockd
-killall sanlock
-
-killall -9 lvmlockd
-killall -9 sanlock
-
-# FIXME: dmsetup remove LVMTEST*-lvmlock
-
-dmsetup remove glvg-lvmlock || true
-dmsetup remove GL_DEV || true
-
diff --git a/test/shell/zz-lvmlockd-dlm-remove.sh b/test/shell/zz-lvmlockd-dlm-remove.sh
new file mode 100644
index 0000000..3848c0e
--- /dev/null
+++ b/test/shell/zz-lvmlockd-dlm-remove.sh
@@ -0,0 +1,24 @@
+#!/bin/sh
+# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+test_description='Remove the dlm test setup'
+
+. lib/inittest
+
+[ -z "$LVM_TEST_LOCK_TYPE_DLM" ] && skip;
+
+# FIXME: collect debug logs (only if a test failed?)
+# lvmlockctl -d > lvmlockd-debug.txt
+# dlm_tool dump > dlm-debug.txt
+
+systemctl stop dlm
+systemctl stop corosync
+killall lvmlockd
diff --git a/test/shell/zz-lvmlockd-sanlock-remove.sh b/test/shell/zz-lvmlockd-sanlock-remove.sh
new file mode 100644
index 0000000..ae5bdef
--- /dev/null
+++ b/test/shell/zz-lvmlockd-sanlock-remove.sh
@@ -0,0 +1,41 @@
+#!/bin/sh
+# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+test_description='Remove the sanlock test setup'
+
+. lib/inittest
+
+[ -z "$LVM_TEST_LOCK_TYPE_SANLOCK" ] && skip;
+
+# FIMXME: get this to run after a test fails
+
+# Removes the VG with the global lock that was created by
+# the corresponding create script.
+
+vgremove --config 'devices { global_filter=["a|GL_DEV|", "r|.*|"] filter=["a|GL_DEV|", "r|.*|"]}' glvg
+
+# FIXME: collect debug logs (only if a test failed?)
+# lvmlockctl -d > lvmlockd-debug.txt
+# sanlock log_dump > sanlock-debug.txt
+
+killall lvmlockd
+sleep 1
+killall sanlock
+sleep 1
+
+killall -9 lvmlockd || true
+killall -9 sanlock || true
+
+# FIXME: dmsetup remove LVMTEST*-lvmlock
+
+dmsetup remove glvg-lvmlock || true
+dmsetup remove GL_DEV || true
+
diff --git a/test/shell/zz-lvmlockd-test-remove.sh b/test/shell/zz-lvmlockd-test-remove.sh
new file mode 100644
index 0000000..44749f0
--- /dev/null
+++ b/test/shell/zz-lvmlockd-test-remove.sh
@@ -0,0 +1,23 @@
+#!/bin/sh
+# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Remove the dlm test setup'
+
+. lib/inittest
+
+[ -z "$LVM_TEST_LVMLOCKD_TEST" ] && skip;
+
+killall lvmlockd
+sleep 1
+killall lvmlockd || true
+sleep 1
+killall -9 lvmlockd || true
+


