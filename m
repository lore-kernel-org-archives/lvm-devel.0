From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jun 2019 17:09:18 -0400
Subject: master - tests: add missing-pv missing-pv-unused
Message-ID: <201906072109.x57L9IBG005387@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d3636ff8322f17bac66ac6fe79e2c0710d645260
Commit:        d3636ff8322f17bac66ac6fe79e2c0710d645260
Parent:        a3a676e0e790b5e76aa57a4d2bb1dadedcf6bb5a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 12 10:55:19 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 7 15:54:04 2019 -0500

tests: add missing-pv missing-pv-unused

---
 test/shell/missing-pv-unused.sh |   86 ++++++++++++++++++++++
 test/shell/missing-pv.sh        |  152 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 238 insertions(+), 0 deletions(-)

diff --git a/test/shell/missing-pv-unused.sh b/test/shell/missing-pv-unused.sh
new file mode 100644
index 0000000..2265a5b
--- /dev/null
+++ b/test/shell/missing-pv-unused.sh
@@ -0,0 +1,86 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2008-2013,2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+. lib/inittest
+
+aux prepare_devs 3
+get_devs
+
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
+
+lvcreate -n $lv1 -L8M $vg "$dev2"
+lvcreate -n $lv2 -L8M $vg "$dev3"
+lvcreate -n $lv3 -L8M $vg "$dev2"
+lvcreate -n $lv4 -L8M $vg "$dev3"
+
+vgchange -an $vg
+
+pvs
+vgs
+lvs -a -o+devices
+
+# Fail device that is not used by any LVs.
+aux disable_dev "$dev1"
+
+pvs
+vgs
+lvs -a -o+devices
+
+# Cannot do normal activation of LVs not using failed PV.
+lvchange -ay $vg/$lv1
+lvchange -ay $vg/$lv2
+
+vgchange -an $vg
+
+# Check that MISSING flag is not set in ondisk metadata.
+pvck --dump metadata "$dev2" > meta
+not grep MISSING meta
+rm meta
+
+pvs
+vgs
+lvs -a -o+devices
+
+# lvremove is one of the few commands that is allowed to run
+# when PVs are missing.  The vg_write from this command sets
+# the MISSING flag on the PV in the ondisk metadata.
+# (this could be changed, the MISSING flag wouldn't need
+# to be set in the first place since the PV isn't used.)
+lvremove $vg/$lv1
+
+# Check that MISSING flag is set in ondisk metadata.
+pvck --dump metadata "$dev2" > meta
+grep MISSING meta
+rm meta
+
+# with MISSING flag in metadata, restrictions apply
+not lvcreate -l1 $vg
+
+aux enable_dev "$dev1"
+
+# No LVs are using the PV with MISSING flag, so no restrictions
+# are applied, and the vg_write here clears the MISSING flag on disk.
+lvcreate -l1 $vg
+
+# Check that MISSING flag is not set in ondisk metadata.
+pvck --dump metadata "$dev2" > meta
+not grep MISSING meta
+rm meta
+
+
+pvs
+vgs
+lvs -a -o+devices
+
+vgchange -an $vg
+vgremove -ff $vg
+
diff --git a/test/shell/missing-pv.sh b/test/shell/missing-pv.sh
new file mode 100644
index 0000000..74cc43b
--- /dev/null
+++ b/test/shell/missing-pv.sh
@@ -0,0 +1,152 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2008-2013,2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+. lib/inittest
+
+aux prepare_devs 3
+get_devs
+
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
+
+lvcreate -n $lv1 -L8M --type mirror -m 1 $vg
+lvcreate -n $lv2 -L8M --type mirror -m 1 $vg
+
+vgchange -an $vg
+
+pvs
+vgs
+lvs -a -o+devices
+
+# Fail one leg of each mirror LV.
+aux disable_dev "$dev1"
+
+pvs
+vgs
+lvs -a -o+devices
+
+# Cannot do normal activate of either LV with a failed leg.
+not lvchange -ay $vg/$lv1
+not lvchange -ay $vg/$lv2
+
+# Can activate with partial option.
+lvchange -ay --activationmode partial $vg/$lv1
+lvchange -ay --activationmode partial $vg/$lv2
+
+pvs
+vgs
+lvs -a -o+devices
+
+# Repair lv1 so it no longer uses failed dev.
+lvconvert --repair --yes $vg/$lv1
+
+# Check that MISSING flag is set in ondisk metadata,
+# it should have been written by the lvconvert since the
+# missing PV is still used by lv2.
+pvck --dump metadata "$dev2" > meta
+grep MISSING meta
+rm meta
+
+pvs
+vgs
+lvs -a -o+devices
+
+# Verify normal activation is possible of lv1 since it's
+# not using any failed devs, and partial activation is
+# required for lv2 since it's still using the failed dev.
+vgchange -an $vg
+lvchange -ay $vg/$lv1
+not lvchange -ay $vg/$lv2
+vgchange -an $vg
+
+aux enable_dev "$dev1"
+
+pvs
+vgs
+lvs -a -o+devices
+
+# TODO: check that lv2 has partial flag, lv1 does not
+# (there's no partial reporting option, only attr p.)
+
+# Check that MISSING flag is still set in ondisk
+# metadata since the previously missing dev is still
+# used by lv2.
+pvck --dump metadata "$dev2" > meta
+grep MISSING meta
+rm meta
+
+
+# The missing pv restrictions still apply even after
+# the dev has reappeared since it has the MISSING flag.
+not lvchange -ay $vg/$lv2
+not lvcreate -l1 $vg
+
+# Update old metadata on the previously missing PV.
+# This should not clear the MISSING flag because the
+# previously missing PV is still used by lv2.
+# This would be done by any command that writes
+# metadata, e.g. lvcreate, but since we are in a
+# state with a missing pv, most commands that write
+# metadata are restricted, so use a command that
+# explicitly writes/fixes metadata.
+vgck --updatemetadata $vg
+
+pvs
+vgs
+lvs -a -o+devices
+
+# Check that MISSING flag is still set in ondisk
+# metadata since the previously missing dev is still
+# used by lv2.
+pvck --dump metadata "$dev2" > meta
+grep MISSING meta
+rm meta
+
+
+# The missing pv restrictions still apply since it
+# has the MISSING flag.
+not lvchange -ay $vg/$lv2
+not lvcreate -l1 $vg
+
+lvchange -ay --activationmode partial  $vg/$lv2
+
+# After repair, no more LVs will be using the previously
+# missing PV.
+lvconvert --repair --yes $vg/$lv2
+
+pvs
+vgs
+lvs -a -o+devices
+
+vgchange -an $vg
+
+# The next write of the metadata will clear the MISSING
+# flag in ondisk metadata because the previously missing
+# PV is no longer used by any LVs.
+
+# Run a command to write ondisk metadata, which should clear
+# the MISSING flag, could also use vgck --updatemetadata vg.
+lvcreate -l1 $vg
+
+# Check that the MISSING flag is no longer set
+# in the ondisk metadata.
+pvck --dump metadata "$dev2" > meta
+not grep MISSING meta
+rm meta
+
+
+pvs
+vgs
+lvs -a -o+devices
+
+vgchange -an $vg
+vgremove -ff $vg
+


