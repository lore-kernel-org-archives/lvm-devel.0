From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 23 Feb 2016 20:03:13 +0000 (UTC)
Subject: master - tests: updates for check_lvmlockd
Message-ID: <20160223200313.0FC1B60DAC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0236a34224d31a6ad7b48e451183672e907b15d3
Commit:        0236a34224d31a6ad7b48e451183672e907b15d3
Parent:        42da7a6c38ece2a9dca6492af1ba66ebaa9b6231
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 23 13:58:22 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 23 14:00:28 2016 -0600

tests: updates for check_lvmlockd

Move the lvmlockd-related setup functions into aux.

For check_lvmlockd_test, start a new instance of
lvmlockd --test for each shell test.
---
 test/Makefile.in                          |    2 +-
 test/lib/aux.sh                           |  137 +++++++++++++++++++++++++++++
 test/lib/inittest.sh                      |    9 ++
 test/shell/aa-lvmlockd-dlm-prepare.sh     |   73 +---------------
 test/shell/aa-lvmlockd-sanlock-prepare.sh |   45 +---------
 test/shell/aa-lvmlockd-test-prepare.sh    |   44 ---------
 test/shell/dlm-hello-world.sh             |   27 ------
 test/shell/lvmlockd-hello-world.sh        |   25 +++++
 test/shell/sanlock-hello-world.sh         |   27 ------
 test/shell/zz-lvmlockd-test-remove.sh     |   23 -----
 10 files changed, 176 insertions(+), 236 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 19a0214..6ed9b9e 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -161,7 +161,7 @@ ifeq ("@BUILD_LVMLOCKD@", "yes")
 check_lvmlockd_test: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir results \
-		--flavours udev-lvmlockd-test --only shell/aa-lvmlockd-test-prepare.sh,$(T),shell/zz-lvmlockd-test-remove.sh --skip $(S)
+		--flavours udev-lvmlockd-test --only $(T) --skip $(S)
 endif
 
 DATADIR = $(datadir)/lvm2-testsuite
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 12316aa..cfd3620 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -21,6 +21,133 @@ expect_failure() {
         echo "TEST EXPECT FAILURE"
 }
 
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
+prepare_dlm() {
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
+}
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
+prepare_sanlock() {
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
+}
+
+# FIXME: add option to allow --test with sanlock
+LVM_TEST_LVMLOCKD_TEST_DLM=1
+
+prepare_lvmlockd() {
+	if pgrep lvmlockd ; then
+		echo "Cannot run while existing lvmlockd process exists"
+		exit 1
+	fi
+
+	if test -n "$LVM_TEST_LOCK_TYPE_SANLOCK"; then
+		# make check_lvmlockd_sanlock
+		echo "starting lvmlockd for sanlock"
+		lvmlockd -o 2
+
+	elif test -n "$LVM_TEST_LOCK_TYPE_DLM"; then
+		# make check_lvmlockd_dlm
+		echo "starting lvmlockd for dlm"
+		lvmlockd
+
+	elif test -n "$LVM_TEST_LVMLOCKD_TEST_DLM"; then
+		# make check_lvmlockd_test
+		echo "starting lvmlockd --test (dlm)"
+		lvmlockd --test -g dlm
+
+	elif test -n "$LVM_TEST_LVMLOCKD_TEST_SANLOCK"; then
+		# FIXME: add option for this combination of --test and sanlock
+		echo "starting lvmlockd --test (sanlock)"
+		lvmlockd --test -g sanlock -o 2
+	else
+		echo "not starting lvmlockd"
+		exit 0
+	fi
+
+	sleep 1
+	if ! pgrep lvmlockd; then
+		echo "Failed to start lvmlockd"
+		exit 1
+	fi
+}
+
 prepare_clvmd() {
 	rm -f debug.log strace.log
 	test "${LVM_TEST_LOCKING:-0}" -ne 3 && return # not needed
@@ -317,6 +444,16 @@ teardown() {
 
 	kill_tagged_processes
 
+	if test -n "$LVM_TEST_LVMLOCKD_TEST" ; then
+		echo ""
+		echo "stopping lvmlockd in teardown"
+		killall lvmlockd
+		sleep 1
+		killall lvmlockd || true
+		sleep 1
+		killall -9 lvmlockd || true
+	fi
+
 	kill_sleep_kill_ LOCAL_LVMETAD ${LVM_VALGRIND_LVMETAD:-0}
 
 	dm_table | not egrep -q "$vg|$vg1|$vg2|$vg3|$vg4" || {
diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 4531e66..a2dcf01 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -128,9 +128,18 @@ if test -n "$LVM_TEST_LVMLOCKD" ; then
 	if test -n "$LVM_TEST_LOCK_TYPE_SANLOCK" ; then
 		aux lvmconf 'local/host_id = 1'
 	fi
+
 	export SHARED="--shared"
 fi
 
+# for check_lvmlockd_test, lvmlockd is restarted for each shell test.
+# for check_lvmlockd_{sanlock,dlm}, lvmlockd is started once by
+# aa-lvmlockd-{sanlock,dlm}-prepare.sh and left running for all shell tests.
+
+if test -n "$LVM_TEST_LVMLOCKD_TEST" ; then
+	aux prepare_lvmlockd
+fi
+
 echo "<======== Processing test: \"$TESTNAME\" ========>"
 
 set -vx
diff --git a/test/shell/aa-lvmlockd-dlm-prepare.sh b/test/shell/aa-lvmlockd-dlm-prepare.sh
index e1e1a73..bc30bb7 100644
--- a/test/shell/aa-lvmlockd-dlm-prepare.sh
+++ b/test/shell/aa-lvmlockd-dlm-prepare.sh
@@ -16,75 +16,6 @@ test_description='Set up things to run tests with dlm'
 
 [ -z "$LVM_TEST_LOCK_TYPE_DLM" ] && skip;
 
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
+aux prepare_dlm
+aux prepare_lvmlockd
 
diff --git a/test/shell/aa-lvmlockd-sanlock-prepare.sh b/test/shell/aa-lvmlockd-sanlock-prepare.sh
index 22127ad..75b94e7 100644
--- a/test/shell/aa-lvmlockd-sanlock-prepare.sh
+++ b/test/shell/aa-lvmlockd-sanlock-prepare.sh
@@ -16,48 +16,6 @@ test_description='Set up things to run tests with sanlock'
 
 [ -z "$LVM_TEST_LOCK_TYPE_SANLOCK" ] && skip;
 
-SANLOCK_CONF="/etc/sanlock/sanlock.conf"
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
-	systemctl start sanlock
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
 # Create a device and a VG that are both outside the scope of
 # the standard lvm test suite so that they will not be removed
 # and will remain in place while all the tests are run.
@@ -77,7 +35,8 @@ dd if=/dev/zero of="$GL_FILE" bs=$((1024*1024)) count=1024 2> /dev/null
 GL_LOOP=$(losetup -f "$GL_FILE" --show)
 echo "0 `blockdev --getsize $GL_LOOP` linear $GL_LOOP 0" | dmsetup create GL_DEV
 
-prepare_lvmlockd_sanlock
+aux prepare_sanlock
+aux prepare_lvmlockd
 
 vgcreate --config 'devices { global_filter=["a|GL_DEV|", "r|.*|"] filter=["a|GL_DEV|", "r|.*|"]}' --lock-type sanlock glvg $GL_DEV
 
diff --git a/test/shell/aa-lvmlockd-test-prepare.sh b/test/shell/aa-lvmlockd-test-prepare.sh
deleted file mode 100644
index 99ec86f..0000000
--- a/test/shell/aa-lvmlockd-test-prepare.sh
+++ /dev/null
@@ -1,44 +0,0 @@
-#!/bin/sh
-# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-
-test_description='Set up things to run tests with lvmlockd'
-
-. lib/utils
-. lib/inittest
-
-[ -z "$LVM_TEST_LVMLOCKD_TEST" ] && skip;
-
-# TODO: allow this to be configured sanlock/dlm
-LVM_TEST_LVMLOCKD_TEST_DLM=1
-
-prepare_lvmlockd_test() {
-	if pgrep lvmlockd ; then
-		echo "Cannot run while existing lvmlockd process exists"
-		exit 1
-	fi
-
-	if test -n "$LVM_TEST_LVMLOCKD_TEST_SANLOCK"; then
-		lvmlockd --test -g sanlock
-	fi
-
-	if test -n "$LVM_TEST_LVMLOCKD_TEST_DLM"; then
-		lvmlockd --test -g dlm
-	fi
-
-	sleep 1
-	if ! pgrep lvmlockd ; then
-		echo "Failed to start lvmlockd"
-		exit 1
-	fi
-}
-
-prepare_lvmlockd_test
-
diff --git a/test/shell/dlm-hello-world.sh b/test/shell/dlm-hello-world.sh
deleted file mode 100644
index 9ee3b14..0000000
--- a/test/shell/dlm-hello-world.sh
+++ /dev/null
@@ -1,27 +0,0 @@
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
-test_description='Hello world for vgcreate with lvmlockd and dlm'
-
-. lib/inittest
-
-[ -z "$LVM_TEST_LOCK_TYPE_DLM" ] && skip;
-
-aux prepare_devs 1
-
-vgcreate $SHARED $vg "$dev1"
-
-vgs -o+locktype,lockargs $vg
-
-check vg_field $vg vg_locktype dlm
-
-vgremove $vg
-
diff --git a/test/shell/lvmlockd-hello-world.sh b/test/shell/lvmlockd-hello-world.sh
new file mode 100644
index 0000000..01e1c56
--- /dev/null
+++ b/test/shell/lvmlockd-hello-world.sh
@@ -0,0 +1,25 @@
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
+test_description='Hello world for vgcreate with lvmlockd and sanlock'
+
+. lib/inittest
+
+[ -z "$LVM_TEST_LVMLOCKD" ] && skip;
+
+aux prepare_pvs 1
+
+vgcreate $SHARED $vg "$dev1"
+
+vgs -o+locktype,lockargs $vg
+
+vgremove $vg
+
diff --git a/test/shell/sanlock-hello-world.sh b/test/shell/sanlock-hello-world.sh
deleted file mode 100644
index fb95faa..0000000
--- a/test/shell/sanlock-hello-world.sh
+++ /dev/null
@@ -1,27 +0,0 @@
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
-test_description='Hello world for vgcreate with lvmlockd and sanlock'
-
-. lib/inittest
-
-[ -z "$LVM_TEST_LOCK_TYPE_SANLOCK" ] && skip;
-
-aux prepare_pvs 1
-
-vgcreate $SHARED $vg "$dev1"
-
-vgs -o+locktype,lockargs $vg
-
-check vg_field $vg vg_locktype sanlock
-
-vgremove $vg
-
diff --git a/test/shell/zz-lvmlockd-test-remove.sh b/test/shell/zz-lvmlockd-test-remove.sh
deleted file mode 100644
index 44749f0..0000000
--- a/test/shell/zz-lvmlockd-test-remove.sh
+++ /dev/null
@@ -1,23 +0,0 @@
-#!/bin/sh
-# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-
-test_description='Remove the dlm test setup'
-
-. lib/inittest
-
-[ -z "$LVM_TEST_LVMLOCKD_TEST" ] && skip;
-
-killall lvmlockd
-sleep 1
-killall lvmlockd || true
-sleep 1
-killall -9 lvmlockd || true
-


