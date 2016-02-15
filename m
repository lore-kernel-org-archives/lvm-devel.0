From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:57 +0000 (UTC)
Subject: master - tests: add pv-ext-flags.sh test
Message-ID: <20160215120857.5F24160DEE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a4e25f4381284967467a1103d67e3cdbdd2cdf82
Commit:        a4e25f4381284967467a1103d67e3cdbdd2cdf82
Parent:        2f00d57e6f7e1066448f93af0b67a378da29a4d0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Apr 7 13:50:54 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:46 2016 +0100

tests: add pv-ext-flags.sh test

Testing PV extension flags. Currently, there's only one PV extension
flag present - the PV_EXT_USED flag (marking PV as used in a VG).
---
 test/shell/pv-ext-flags.sh |  163 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 163 insertions(+), 0 deletions(-)

diff --git a/test/shell/pv-ext-flags.sh b/test/shell/pv-ext-flags.sh
new file mode 100644
index 0000000..072ec2c
--- /dev/null
+++ b/test/shell/pv-ext-flags.sh
@@ -0,0 +1,163 @@
+#!/bin/sh
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
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_devs 2
+
+# PV_EXT_USED flag
+MARKED_AS_USED_MSG="marked as belonging to a VG but its metadata is missing"
+
+######################################
+### CHECK PV WITH 0 METADATA AREAS ###
+######################################
+
+pvcreate -ff -y --metadatacopies 0 "$dev1"
+pvcreate -ff -y --metadatacopies 1 "$dev2"
+
+# $dev1 and $dev2 not in any VG - pv_in_use field should be blank
+check pv_field "$dev1" pv_in_use ""
+check pv_field "$dev2" pv_in_use ""
+
+# $dev1 and $dev now in a VG - pv_in_use should display "used"
+vgcreate $vg1 "$dev1" "$dev2"
+check pv_field "$dev1" pv_in_use "used"
+check pv_field "$dev2" pv_in_use "used"
+
+# disable $dev2 and dev1 with 0 MDAs remains, but still
+# marked as used, so pvcreate/vgcreate/pvremove should fail
+aux disable_dev "$dev2"
+pvscan --cache
+
+check pv_field "$dev1" pv_in_use "used"
+not pvcreate "$dev1" 2>err
+cat err
+grep "$MARKED_AS_USED_MSG" err
+not pvchange -u "$dev1" 2>err
+grep "$MARKED_AS_USED_MSG" err
+not vgcreate $vg2 "$dev1" 2>err
+grep "$MARKED_AS_USED" err
+not pvremove "$dev1" 2>err
+grep "$MARKED_AS_USED_MSG" err
+
+# save PV signature from dev1 for reuse later on in this
+# test so we don't need to initialize all the VG stuff again
+dd if="$dev1" of=dev1_backup bs=1M
+
+# pvcreate and pvremove can be forced even if the PV is marked as used
+pvremove -ff "$dev1"
+dd if=dev1_backup of="$dev1" bs=1M
+pvcreate -ff "$dev1"
+dd if=dev1_backup of="$dev1" bs=1M
+
+# prepare a VG with $dev1 and $dev both having 1 MDA
+aux enable_dev "$dev2"
+vgremove -ff $vg1
+pvcreate --metadatacopies 1 "$dev1"
+vgcreate $vg1 "$dev1" "$dev2"
+
+# disable $dev1, then repair the VG - $dev1 is removed from VG
+aux disable_dev "$dev1"
+vgreduce --removemissing $vg1
+# now, enable $dev1, automatic repair will happen on pvs call
+# (or any other lvm command that does vg_read with repair inside)
+aux enable_dev "$dev1"
+
+# FIXME: once persistent cache does not cause races with timestamps
+#        causing LVM tools to not see the VG inconsistency and once
+#        VG repair is always done, delete this line which removes
+#        persistent .cache as a workaround
+rm -f $TESTDIR/etc/.cache
+
+vgck $vg1
+# check $dev1 does not contain the PV_EXT_FLAG anymore - it
+# should be removed as part of the repaid during vg_read since
+# $dev1 is not part of $vg1 anymore
+check pv_field "$dev1" pv_in_use ""
+
+#############################################
+### CHECK PV WITH DISABLED METADATA AREAS ###
+#############################################
+
+pvcreate -ff -y --metadatacopies 1 "$dev1"
+pvcreate -ff -y --metadatacopies 1 "$dev2"
+
+# $dev1 and $dev2 not in any VG - pv_in_use field should be blank
+check pv_field "$dev1" pv_in_use ""
+check pv_field "$dev2" pv_in_use ""
+
+# $dev1 and $dev now in a VG - pv_in_use should display "used"
+vgcreate $vg1 "$dev1" "$dev2"
+check pv_field "$dev1" pv_in_use "used"
+check pv_field "$dev2" pv_in_use "used"
+
+pvchange --metadataignore y "$dev1"
+aux disable_dev "$dev2"
+pvscan --cache
+
+check pv_field "$dev1" pv_in_use "used"
+not pvcreate "$dev1" 2>err
+grep "$MARKED_AS_USED_MSG" err
+not pvchange -u "$dev1" 2>err
+grep "$MARKED_AS_USED_MSG" err
+not vgcreate $vg2 "$dev1" 2>err
+grep "$MARKED_AS_USED" err
+not pvremove "$dev1" 2>err
+grep "$MARKED_AS_USED_MSG" err
+
+# save PV signature from dev1 for reuse later on in this
+# test so we don't need to initialize all the VG stuff again
+dd if="$dev1" of=dev1_backup bs=1M
+
+# pvcreate and pvremove can be forced even if the PV is marked as used
+pvremove -ff "$dev1"
+dd if=dev1_backup of="$dev1" bs=1M
+pvcreate -ff "$dev1"
+dd if=dev1_backup of="$dev1" bs=1M
+
+# prepare a VG with $dev1 and $dev both having 1 MDA
+aux enable_dev "$dev2"
+vgremove -ff $vg1
+pvcreate --metadatacopies 1 "$dev1"
+vgcreate $vg1 "$dev1" "$dev2"
+
+# disable $dev1, then repair the VG - $dev1 is removed from VG
+aux disable_dev "$dev1"
+vgreduce --removemissing $vg1
+# now, enable $dev1, automatic repair will happen on pvs call
+# (or any other lvm command that does vg_read with repair inside)
+aux enable_dev "$dev1"
+
+# FIXME: once persistent cache does not cause races with timestamps
+#        causing LVM tools to not see the VG inconsistency and once
+#        VG repair is always done, delete this line which removes
+#        persistent .cache as a workaround
+rm -f $TESTDIR/etc/.cache
+
+vgck $vg1
+# check $dev1 does not contain the PV_EXT_FLAG anymore - it
+# should be removed as part of the repaid during vg_read since
+# $dev1 is not part of $vg1 anymore
+check pv_field "$dev1" pv_in_use ""
+
+###########################
+# OTHER PV-RELATED CHECKS #
+###########################
+
+# vgcfgrestore should also set PV_EXT_FLAG on PVs where VG is restored
+vgcfgbackup -f vg_backup $vg1
+check pv_field "$dev2" pv_in_use "used"
+vgremove -ff $vg1
+check pv_field "$dev2" pv_in_use ""
+vgcfgrestore -f vg_backup $vg1
+check pv_field "$dev2" pv_in_use "used"


