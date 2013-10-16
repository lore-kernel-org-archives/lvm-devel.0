From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 16 Oct 2013 08:56:17 +0000 (UTC)
Subject: master - tests: test repairability of thin pool
Message-ID: <20131016085617.F2213603F2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=73971e1e7b1164f4f7c677afc17aabbd09e11252
Commit:        73971e1e7b1164f4f7c677afc17aabbd09e11252
Parent:        7ab5f29a9cf94ef41e54e47f7f00898d44a700e3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 16 10:17:17 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 16 10:54:59 2013 +0200

tests: test repairability of thin pool

Initial testing of thin pool's metadata with thin repairing tools.
Try to use tools from configuration settings, but allow them
to be overriden by settings of these variables:
LVM_TEST_THIN_CHECK_CMD,
LVM_TEST_THIN_DUMP_CMD,
LVM_TEST_THIN_REPAIR_CMD

FIXME: test reveals some more important bugs:
  pvremove -ff also needs --yes
  vgremove -ff doesn not remove metadata when there are no real LVs.
  vgreduce is not able to reduce VG with pool without pool's PVs
---
 test/Makefile.in                    |    8 ++-
 test/shell/lvconvert-repair-thin.sh |  117 +++++++++++++++++++++++++++++++++++
 2 files changed, 124 insertions(+), 1 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 5685544..961eb9e 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -25,6 +25,9 @@ abs_top_builddir = "@abs_top_builddir@"
 abs_top_srcdir = "@abs_top_srcdir@"
 
 LVM_TEST_RESULTS ?= results
+LVM_TEST_THIN_DUMP_CMD ?= "@THIN_DUMP_CMD@"
+LVM_TEST_THIN_CHECK_CMD ?= "@THIN_CHECK_CMD@"
+LVM_TEST_THIN_REPAIR_CMD ?= "@THIN_REPAIR_CMD@"
 SUBDIRS = api unit
 SOURCES = lib/not.c lib/harness.c
 
@@ -58,12 +61,15 @@ help:
 	@echo "  help			Display callable targets."
 	@echo -e "\nSupported variables:"
 	@echo "  LVM_TEST_DEVDIR	Set to '/dev' to run on real /dev."
-	@echo "  LVM_TEST_DIR		Where to create test files [TMPDIR]."
+	@echo "  LVM_TEST_DIR		Where to create test files [$(LVM_TEST_DIR)]."
 	@echo "  LVM_TEST_LOCKING	Normal (1), Cluster (3)."
 	@echo "  LVM_TEST_LVMETAD	Start lvmetad (1)."
 	@echo "  LVM_TEST_NODEBUG	Do not debug lvm commands."
 	@echo "  LVM_TEST_PARALLEL	May skip agresive wipe of LVMTEST resources."
 	@echo "  LVM_TEST_RESULTS	Where to create result files [results]."
+	@echo "  LVM_TEST_THIN_CHECK_CMD  Command for thin_check  [$(LVM_TEST_THIN_CHECK_CMD)]."
+	@echo "  LVM_TEST_THIN_DUMP_CMD   Command for thin_dump   [$(LVM_TEST_THIN_DUMP_CMD)]."
+	@echo "  LVM_TEST_THIN_REPAIR_CMD Command for thin_repair [$(LVM_TEST_THIN_REPAIR_CMD)]."
 	@echo "  LVM_TEST_UNLIMITED	Set to get unlimited test log (>32MB)"
 	@echo "  LVM_VERIFY_UDEV	Default verify state for lvm.conf."
 	@echo "  S			Skip given test (regex)."
diff --git a/test/shell/lvconvert-repair-thin.sh b/test/shell/lvconvert-repair-thin.sh
new file mode 100644
index 0000000..f7687d4
--- /dev/null
+++ b/test/shell/lvconvert-repair-thin.sh
@@ -0,0 +1,117 @@
+#!/bin/sh
+
+# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Test repairing of broken thin pool metadata 
+
+. lib/test
+
+# Set tools from configuration (set by Makefile)
+# Allow user override to take tools from unusual places
+LVM_TEST_THIN_CHECK_CMD=${LVM_TEST_THIN_CHECK_CMD:-thin_check}
+LVM_TEST_THIN_DUMP_CMD=${LVM_TEST_THIN_DUMP_CMD:-thin_dump}
+LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD:-thin_repair}
+
+which mkfs.ext2 || skip
+
+# Maybe check also version of the tools here??
+which $LVM_TEST_THIN_CHECK_CMD || skip
+which $LVM_TEST_THIN_DUMP_CMD || skip
+which $LVM_TEST_THIN_REPAIR_CMD || skip
+
+#
+# Main
+#
+aux have_thin 1 0 0 || skip
+
+aux prepare_vg 4
+
+# Create LV
+lvcreate -T -L20 -V10 -n $lv1 $vg/pool  "$dev1" "$dev2"
+lvcreate -T -V10 -n $lv2 $vg/pool
+
+mkfs.ext2 $DM_DEV_DIR/$vg/$lv1
+mkfs.ext2 $DM_DEV_DIR/$vg/$lv2
+
+lvcreate -L20 -n repair $vg
+lvcreate -L2 -n fixed $vg
+
+lvs -a -o+seg_pe_ranges $vg
+#aux error_dev "$dev2" 2050:1
+
+# Make some repairable metadata damage??
+vgchange -an $vg
+
+lvconvert --repair $vg/pool
+
+lvs -a $vg
+
+# Test swapping - swap out thin-pool's metadata with our repair volume
+lvconvert -y -f --poolmetadata $vg/repair --thinpool $vg/pool
+
+lvchange -aey $vg/repair $vg/fixed
+
+#dd if=$DM_DEV_DIR/$vg/repair of=back bs=1M
+
+# Make some 'repairable' damage??
+dd if=/dev/zero of=$DM_DEV_DIR/$vg/repair bs=1 seek=40960 count=1
+
+#dd if=$DM_DEV_DIR/$vg/repair of=back_trashed bs=1M
+#not vgchange -ay $vg
+
+#lvconvert --repair $vg/pool
+
+# Using now SHOULD - since thin tools currently do not seem to work
+should not $THIN_CHECK $DM_DEV_DIR/$vg/repair
+
+should not $LVM_TEST_THIN_DUMP_CMD $DM_DEV_DIR/$vg/repair | tee dump
+
+should $LVM_TEST_THIN_REPAIR_CMD -i $DM_DEV_DIR/$vg/repair -o $DM_DEV_DIR/$vg/fixed
+
+should $THIN_CHECK $DM_DEV_DIR/$vg/fixed
+
+# Swap repaired metadata back
+lvconvert -y -f --poolmetadata $vg/fixed --thinpool $vg/pool
+lvs -a $vg
+
+# Activate pool - this should now work
+should vgchange -ay $vg
+
+lvs -a -o+devices $vg 
+dmsetup table
+dmsetup info -c
+dmsetup ls --tree
+
+# Currently in troubles - we can't remove thin volume from broken pool
+lvchange -an $vg/repair
+lvchange -an $vg/fixed
+lvchange -an $vg/pool_tmeta0
+dmsetup remove $vg-pool_tdata
+dmsetup remove $vg-pool_tmeta
+
+
+dmsetup table
+
+# FIXME: needs  also --yes with double force 
+pvremove --yes -ff "$dev1"
+pvremove --yes -ff "$dev2"
+
+# FIXME: pv1 & pv2 are removed so pv3 & pv4 have no real LVs,
+# yet vgremove is refusing to do its jobs and suggest --partial??
+should vgremove -ff  $vg
+
+# FIXME: stressing even more - there are no pool PV, we do not pass...
+should vgreduce --removemissing -f $vg
+should vgremove -ff  $vg
+
+# Let's do a final forced cleanup
+pvremove --yes -ff "$dev3"
+pvremove --yes -ff "$dev4"


