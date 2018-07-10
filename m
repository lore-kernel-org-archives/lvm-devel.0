From: David Teigland <teigland@sourceware.org>
Date: Tue, 10 Jul 2018 11:51:22 -0400
Subject: master - tests: autoactivation tests for use without lvmetad
Message-ID: <201807101551.w6AFpMwE002099@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=06439a256217b5d37ef33833051fc322a58b4859
Commit:        06439a256217b5d37ef33833051fc322a58b4859
Parent:        db741e75a21bd9327ed1478e42495f2b0a419be9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jul 10 09:58:22 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jul 10 10:49:34 2018 -0500

tests: autoactivation tests for use without lvmetad

Adjust a few lvmetad pvscan/autoactivation tests to be
used without lvmetad, and add a test to cover some cases
that have not been tested before.
---
 .../shell/lvmetad-pvscan-autoactivation-polling.sh |   75 ----------
 test/shell/lvmetad-pvscan-cache.sh                 |   63 ---------
 test/shell/lvmetad-pvscan-nomda-bg.sh              |   59 --------
 test/shell/pvscan-autoactivate.sh                  |  143 ++++++++++++++++++++
 test/shell/pvscan-autoactivation-polling.sh        |   74 ++++++++++
 test/shell/pvscan-cache.sh                         |   62 +++++++++
 test/shell/pvscan-nomda-bg.sh                      |   41 ++++++
 7 files changed, 320 insertions(+), 197 deletions(-)

diff --git a/test/shell/lvmetad-pvscan-autoactivation-polling.sh b/test/shell/lvmetad-pvscan-autoactivation-polling.sh
deleted file mode 100644
index 46c454b..0000000
--- a/test/shell/lvmetad-pvscan-autoactivation-polling.sh
+++ /dev/null
@@ -1,75 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
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
-
-. lib/inittest
-
-# test if snapshot-merge target is available
-aux target_at_least dm-snapshot-merge 1 0 0 || skip
-
-which mkfs.ext3 || skip
-
-lvdev_() {
-    echo "$DM_DEV_DIR/$1/$2"
-}
-
-snap_lv_name_() {
-    echo ${1}_snap
-}
-
-setup_merge_() {
-    local VG_NAME=$1
-    local LV_NAME=$2
-    local NUM_EXTRA_SNAPS=${3:-0}
-    local BASE_SNAP_LV_NAME
-
-    BASE_SNAP_LV_NAME=$(snap_lv_name_ $LV_NAME)
-
-    lvcreate -aey -n $LV_NAME -l 50%FREE $VG_NAME
-    lvs
-    lvcreate -s -n $BASE_SNAP_LV_NAME -l 20%FREE ${VG_NAME}/${LV_NAME}
-    mkfs.ext3 "$(lvdev_ $VG_NAME $LV_NAME)"
-
-    if [ $NUM_EXTRA_SNAPS -gt 0 ]; then
-	for i in $(seq 1 $NUM_EXTRA_SNAPS); do
-	    lvcreate -s -n ${BASE_SNAP_LV_NAME}_${i} -l 20%ORIGIN ${VG_NAME}/${LV_NAME}
-	done
-    fi
-}
-
-aux prepare_pvs 1 50
-
-vgcreate $vg1 "$dev1"
-mkdir test_mnt
-
-setup_merge_ $vg1 $lv1
-mount "$(lvdev_ $vg1 $lv1)" test_mnt
-lvconvert --merge "$vg1/$(snap_lv_name_ "$lv1")"
-umount test_mnt
-vgchange -an $vg1
-
-# check snapshot get removed on autoactivation
-pvscan --cache -aay "$dev1"
-
-check active $vg1 $lv1
-i=100
-while ! check lv_not_exists "$vg1/$(snap_lv_name_ "$lv1")"; do
-	test $i -lt 0 && fail "Background polling failed to remove merged snapshot LV"
-	sleep .1
-	i=$((i-1))
-done
-
-# TODO: add similar simple tests for other interrupted/unfinished polling operation
-
-vgremove -ff $vg1
diff --git a/test/shell/lvmetad-pvscan-cache.sh b/test/shell/lvmetad-pvscan-cache.sh
deleted file mode 100644
index 367220e..0000000
--- a/test/shell/lvmetad-pvscan-cache.sh
+++ /dev/null
@@ -1,63 +0,0 @@
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
-pvscan --cache
-
-vgs | grep $vg1
-
-# Check that an LV cannot be activated by lvchange while VG is exported
-lvcreate -n $lv1 -l 4 -a n $vg1
-check lv_exists $vg1
-vgexport $vg1
-fail lvs $vg1
-fail lvchange -ay $vg1/$lv1
-vgimport $vg1
-check lv_exists $vg1
-check lv_field $vg1/$lv1 lv_active ""
-
-# Check that an LV cannot be activated by pvscan while VG is exported
-vgexport $vg1
-not pvscan --cache -aay "$dev1"
-not pvscan --cache -aay "$dev2"
-vgimport $vg1
-check lv_exists $vg1
-check lv_field $vg1/$lv1 lv_active ""
-pvscan --cache -aay "$dev1"
-pvscan --cache -aay "$dev2"
-check lv_field $vg1/$lv1 lv_active "active"
-lvchange -an $vg1/$lv1
-
-# When MDA is ignored on PV, do not read any VG
-# metadata from such PV as it may contain old
-# metadata which hasn't been updated for some
-# time and also since the MDA is marked as ignored,
-# it should really be *ignored*!
-pvchange --metadataignore y "$dev1"
-aux disable_dev "$dev2"
-pvscan --cache
-check pv_field "$dev1" vg_name "[unknown]"
-aux enable_dev "$dev2"
-pvscan --cache
-check pv_field "$dev1" vg_name "$vg1"
-
-vgremove -ff $vg1
diff --git a/test/shell/lvmetad-pvscan-nomda-bg.sh b/test/shell/lvmetad-pvscan-nomda-bg.sh
deleted file mode 100644
index 351e446..0000000
--- a/test/shell/lvmetad-pvscan-nomda-bg.sh
+++ /dev/null
@@ -1,59 +0,0 @@
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
-pvscan --cache --background "$dev2" -aay
-
-aux lvmconf 'global/use_lvmetad = 0'
-# FIXME: inconclusive. may be a timing issue
-check inactive $vg1 foo
-aux lvmconf 'global/use_lvmetad = 1'
-
-pvscan --cache --background "$dev1" -aay
-
-aux lvmconf 'global/use_lvmetad = 0'
-i=100
-while ! check active $vg1 foo; do
-	test $i -lt 0 && fail "Failed to autoactivate"
-	sleep .1
-	i=$((i-1))
-done
-aux lvmconf 'global/use_lvmetad = 1'
-
-vgremove -ff $vg1
diff --git a/test/shell/pvscan-autoactivate.sh b/test/shell/pvscan-autoactivate.sh
new file mode 100644
index 0000000..af6f2b2
--- /dev/null
+++ b/test/shell/pvscan-autoactivate.sh
@@ -0,0 +1,143 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_pvs 2
+
+vgcreate $vg1 "$dev1" "$dev2"
+lvcreate -n $lv1 -l 4 -a n $vg1
+
+# the first pvscan scans all devs 
+
+rm /run/lvm/pvs_online/*
+
+pvscan --cache -aay
+check lv_field $vg1/$lv1 lv_active "active"
+lvchange -an $vg1
+
+# the first pvscan scans all devs even when
+# only one device is specified
+
+rm /run/lvm/pvs_online/*
+
+pvscan --cache -aay "$dev1"
+check lv_field $vg1/$lv1 lv_active "active"
+lvchange -an $vg1
+
+# touch foo to disable first-pvscan case,
+# then check pvscan with no args scans all
+
+rm /run/lvm/pvs_online/*
+touch /run/lvm/pvs_online/foo
+
+pvscan --cache -aay
+check lv_field $vg1/$lv1 lv_active "active"
+lvchange -an $vg1
+
+# touch foo to disable first-pvscan case,
+# then check that vg is activated only after
+# both devs appear separately
+
+rm /run/lvm/pvs_online/*
+touch /run/lvm/pvs_online/foo
+
+pvscan --cache -aay "$dev1"
+check lv_field $vg1/$lv1 lv_active ""
+pvscan --cache -aay "$dev2"
+check lv_field $vg1/$lv1 lv_active "active"
+lvchange -an $vg1
+
+# touch foo to disable first-pvscan case,
+# then check that vg is activated when both
+# devs appear together
+
+rm /run/lvm/pvs_online/*
+touch /run/lvm/pvs_online/foo
+
+pvscan --cache -aay "$dev1" "$dev2"
+check lv_field $vg1/$lv1 lv_active "active"
+lvchange -an $vg1
+
+# Set up tests where one dev has no metadata
+
+vgchange -an $vg1
+vgremove -ff $vg1
+pvremove "$dev1"
+pvremove "$dev2"
+pvcreate --metadatacopies 0 "$dev1"
+pvcreate --metadatacopies 1 "$dev2"
+vgcreate $vg1 "$dev1" "$dev2"
+lvcreate -n $lv1 -l 4 -a n $vg1
+
+# touch foo to disable first-pvscan case,
+# test case where dev with metadata appears first
+
+rm /run/lvm/pvs_online/*
+touch /run/lvm/pvs_online/foo
+
+pvscan --cache -aay "$dev2"
+check lv_field $vg1/$lv1 lv_active ""
+pvscan --cache -aay "$dev1"
+check lv_field $vg1/$lv1 lv_active "active"
+lvchange -an $vg1
+
+# touch foo to disable first-pvscan case,
+# test case where dev without metadata
+# appears first which triggers scanning all
+
+rm /run/lvm/pvs_online/*
+touch /run/lvm/pvs_online/foo
+
+pvscan --cache -aay "$dev1"
+check lv_field $vg1/$lv1 lv_active "active"
+pvscan --cache -aay "$dev2"
+check lv_field $vg1/$lv1 lv_active "active"
+lvchange -an $vg1
+
+# dev without metadata is scanned, but
+# first-pvscan case scans all devs
+
+rm /run/lvm/pvs_online/*
+
+pvscan --cache -aay "$dev1"
+check lv_field $vg1/$lv1 lv_active "active"
+lvchange -an $vg1
+
+# use the --cache option to record a dev
+# is online without the -aay option to
+# activate until after they are online
+
+rm /run/lvm/pvs_online/*
+touch /run/lvm/pvs_online/foo
+
+pvscan --cache "$dev1"
+check lv_field $vg1/$lv1 lv_active ""
+pvscan --cache "$dev2"
+check lv_field $vg1/$lv1 lv_active ""
+pvscan --cache -aay
+check lv_field $vg1/$lv1 lv_active "active"
+lvchange -an $vg1
+
+# like previous
+
+rm /run/lvm/pvs_online/*
+touch /run/lvm/pvs_online/foo
+
+pvscan --cache "$dev1"
+check lv_field $vg1/$lv1 lv_active ""
+pvscan --cache -aay "$dev2"
+check lv_field $vg1/$lv1 lv_active "active"
+lvchange -an $vg1
+
diff --git a/test/shell/pvscan-autoactivation-polling.sh b/test/shell/pvscan-autoactivation-polling.sh
new file mode 100644
index 0000000..53adf51
--- /dev/null
+++ b/test/shell/pvscan-autoactivation-polling.sh
@@ -0,0 +1,74 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMLOCKD=1
+
+. lib/inittest
+
+# test if snapshot-merge target is available
+aux target_at_least dm-snapshot-merge 1 0 0 || skip
+
+which mkfs.ext3 || skip
+
+lvdev_() {
+    echo "$DM_DEV_DIR/$1/$2"
+}
+
+snap_lv_name_() {
+    echo ${1}_snap
+}
+
+setup_merge_() {
+    local VG_NAME=$1
+    local LV_NAME=$2
+    local NUM_EXTRA_SNAPS=${3:-0}
+    local BASE_SNAP_LV_NAME
+
+    BASE_SNAP_LV_NAME=$(snap_lv_name_ $LV_NAME)
+
+    lvcreate -aey -n $LV_NAME -l 50%FREE $VG_NAME
+    lvs
+    lvcreate -s -n $BASE_SNAP_LV_NAME -l 20%FREE ${VG_NAME}/${LV_NAME}
+    mkfs.ext3 "$(lvdev_ $VG_NAME $LV_NAME)"
+
+    if [ $NUM_EXTRA_SNAPS -gt 0 ]; then
+	for i in $(seq 1 $NUM_EXTRA_SNAPS); do
+	    lvcreate -s -n ${BASE_SNAP_LV_NAME}_${i} -l 20%ORIGIN ${VG_NAME}/${LV_NAME}
+	done
+    fi
+}
+
+aux prepare_pvs 1 50
+
+vgcreate $vg1 "$dev1"
+mkdir test_mnt
+
+setup_merge_ $vg1 $lv1
+mount "$(lvdev_ $vg1 $lv1)" test_mnt
+lvconvert --merge "$vg1/$(snap_lv_name_ "$lv1")"
+umount test_mnt
+vgchange -an $vg1
+
+# check snapshot get removed on autoactivation
+pvscan --cache -aay "$dev1"
+
+check active $vg1 $lv1
+i=100
+while ! check lv_not_exists "$vg1/$(snap_lv_name_ "$lv1")"; do
+	test $i -lt 0 && fail "Background polling failed to remove merged snapshot LV"
+	sleep .1
+	i=$((i-1))
+done
+
+# TODO: add similar simple tests for other interrupted/unfinished polling operation
+
+vgremove -ff $vg1
diff --git a/test/shell/pvscan-cache.sh b/test/shell/pvscan-cache.sh
new file mode 100644
index 0000000..c272c6c
--- /dev/null
+++ b/test/shell/pvscan-cache.sh
@@ -0,0 +1,62 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_pvs 2
+
+vgcreate $vg1 "$dev1" "$dev2"
+vgs | grep $vg1
+
+pvscan --cache
+
+vgs | grep $vg1
+
+# Check that an LV cannot be activated by lvchange while VG is exported
+lvcreate -n $lv1 -l 4 -a n $vg1
+check lv_exists $vg1
+vgexport $vg1
+fail lvs $vg1
+fail lvchange -ay $vg1/$lv1
+vgimport $vg1
+check lv_exists $vg1
+check lv_field $vg1/$lv1 lv_active ""
+
+# Check that an LV cannot be activated by pvscan while VG is exported
+vgexport $vg1
+not pvscan --cache -aay "$dev1"
+not pvscan --cache -aay "$dev2"
+vgimport $vg1
+check lv_exists $vg1
+check lv_field $vg1/$lv1 lv_active ""
+pvscan --cache -aay "$dev1"
+pvscan --cache -aay "$dev2"
+check lv_field $vg1/$lv1 lv_active "active"
+lvchange -an $vg1/$lv1
+
+# When MDA is ignored on PV, do not read any VG
+# metadata from such PV as it may contain old
+# metadata which hasn't been updated for some
+# time and also since the MDA is marked as ignored,
+# it should really be *ignored*!
+pvchange --metadataignore y "$dev1"
+aux disable_dev "$dev2"
+pvscan --cache
+check pv_field "$dev1" vg_name "[unknown]"
+aux enable_dev "$dev2"
+pvscan --cache
+check pv_field "$dev1" vg_name "$vg1"
+
+vgremove -ff $vg1
diff --git a/test/shell/pvscan-nomda-bg.sh b/test/shell/pvscan-nomda-bg.sh
new file mode 100644
index 0000000..f8ecc08
--- /dev/null
+++ b/test/shell/pvscan-nomda-bg.sh
@@ -0,0 +1,41 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_devs 2
+
+pvcreate --metadatacopies 0 "$dev1"
+pvcreate --metadatacopies 1 "$dev2"
+vgcreate $vg1 "$dev1" "$dev2"
+lvcreate -n foo -l 1 -an --zero n $vg1
+
+check inactive $vg1 foo
+
+# create a file in pvs_online to disable the pvscan init
+# case which scans everything when the first dev appears.
+mkdir /run/lvm/pvs_online/
+touch /run/lvm/pvs_online/foo
+
+pvscan --cache --background "$dev2" -aay
+
+check inactive $vg1 foo
+
+pvscan --cache --background "$dev1" -aay
+
+check active $vg1 foo
+
+rm /run/lvm/pvs_online/foo
+vgremove -ff $vg1


