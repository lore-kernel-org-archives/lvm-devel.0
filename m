From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:35:49 -0400
Subject: master - tests: initial vdo tests
Message-ID: <201807091335.w69DZnbg030875@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c47655f23154c5483c6f097cdd1918deb9fe2f89
Commit:        c47655f23154c5483c6f097cdd1918deb9fe2f89
Parent:        faa126882a9cf2fb64dd143bb96414399e30edf2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jun 24 20:06:59 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:29:16 2018 +0200

tests: initial vdo tests

Basic functionality of lvcreate, lvchange.
---
 test/lib/aux.sh             |    8 +++
 test/shell/lvchange-vdo.sh  |  142 +++++++++++++++++++++++++++++++++++++++++++
 test/shell/lvconvert-vdo.sh |   72 ++++++++++++++++++++++
 test/shell/lvcreate-vdo.sh  |   83 +++++++++++++++++++++++++
 test/shell/profiles-vdo.sh  |   50 +++++++++++++++
 5 files changed, 355 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 4eb9260..f72c851 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1552,6 +1552,14 @@ have_thin() {
 	fi
 }
 
+have_vdo() {
+	lvm segtypes 2>/dev/null | grep -q vdo$ || {
+		echo "VDO is not built-in." >&2
+		return 1
+	}
+	target_at_least dm-vdo "$@"
+}
+
 have_raid() {
 	target_at_least dm-raid "$@"
 
diff --git a/test/shell/lvchange-vdo.sh b/test/shell/lvchange-vdo.sh
new file mode 100644
index 0000000..6d2b451
--- /dev/null
+++ b/test/shell/lvchange-vdo.sh
@@ -0,0 +1,142 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_vdo 6 2 0 || skip
+
+aux prepare_vg 2 6400
+
+lvcreate --vdo -L5G -n $lv1 $vg/vdopool
+
+# deduplication_ARG  (default is 'yes')
+# compression_ARG  (default is 'yes')
+
+# Wait till index gets openned
+for i in {1..10} ; do
+	sleep .1
+	check grep_dmsetup status $vg-vdopool " online online " || continue
+	break
+done
+
+
+# compression_ARG
+lvchange --compression n $vg/vdopool
+check grep_dmsetup status $vg-vdopool " online offline "
+lvchange --compression y $vg/vdopool
+check grep_dmsetup status $vg-vdopool " online online "
+
+# dedulication_ARG
+lvchange --deduplication n $vg/vdopool
+check grep_dmsetup status $vg-vdopool " offline online "
+lvchange --deduplication y $vg/vdopool
+check grep_dmsetup status $vg-vdopool " online online "
+
+
+lvchange --compression n --deduplication n $vg/vdopool
+check grep_dmsetup status $vg-vdopool " offline offline "
+
+
+lvchange -an $vg/$lv1
+
+# Test activation
+lvchange -aly $vg/$lv1
+check active $vg $lv1
+
+lvchange -aln $vg/$lv1
+check inactive $vg $lv1
+
+# Test for allowable changes
+#
+# contiguous_ARG
+lvchange -C y $vg/$lv1
+lvchange -C n $vg/$lv1
+
+# permission_ARG
+lvchange -p r $vg/$lv1
+lvchange -p rw $vg/$lv1
+
+# FIXME
+#should lvchange -p r $vg/vdopool
+#should lvchange -p rw $vg/vdopool
+
+# readahead_ARG
+lvchange -r none $vg/$lv1
+lvchange -r auto $vg/$lv1
+# FIXME
+# Think about more support
+
+# minor_ARG
+lvchange --yes -M y --minor 234 --major 253 $vg/$lv1
+lvchange -M n $vg/$lv1
+
+# cannot change major minor for pools
+not lvchange --yes -M y --minor 235 --major 253 $vg/vdopool
+not lvchange -M n $vg/vdopool
+
+# addtag_ARG
+lvchange --addtag foo $vg/$lv1
+lvchange --addtag foo $vg/vdopool
+
+# deltag_ARG
+lvchange --deltag foo $vg/$lv1
+lvchange --deltag foo $vg/vdopool
+
+
+#
+# Test for disallowed metadata changes
+#
+# resync_ARG
+not lvchange --resync $vg/$lv1
+
+# alloc_ARG
+#not lvchange --alloc anywhere $vg/$lv1
+
+# discards_ARG
+not lvchange --discards ignore $vg/$lv1
+
+# zero_ARG
+not lvchange --zero y $vg/$lv1
+
+
+#
+# Ensure that allowed args don't cause disallowed args to get through
+#
+not lvchange --resync -ay $vg/$lv1
+not lvchange --resync --addtag foo $vg/$lv1
+
+#
+# Play with tags and activation
+#
+TAG=$(uname -n)
+aux lvmconf "activation/volume_list = [ \"$vg/$lv2\", \"@mytag\" ]"
+
+lvchange -ay $vg/$lv1
+check inactive $vg $lv1
+
+lvchange --addtag mytag $vg/$lv1
+
+lvchange -ay @mytag_fake
+check inactive $vg $lv1
+
+lvchange -ay $vg/$lv1
+# Volume has matching tag
+check active $vg $lv1
+lvchange -an $vg/$lv1
+
+lvchange -ay @mytag
+check active $vg $lv1
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-vdo.sh b/test/shell/lvconvert-vdo.sh
new file mode 100644
index 0000000..529f325
--- /dev/null
+++ b/test/shell/lvconvert-vdo.sh
@@ -0,0 +1,72 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
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
+#
+# Main
+#
+aux have_vdo 6 2 0 || skip
+
+aux prepare_vg 2 6400
+
+# Conversion to vdo-pool
+lvcreate -L5G -n $lv1 $vg
+# Check there is big prompting warning
+not lvconvert --type vdo-pool $vg/$lv1 |& tee out
+grep "WARNING" out
+
+
+lvconvert -y --type vdo-pool $vg/$lv1
+lvremove -f $vg
+
+
+# 
+lvcreate -L5G -n $lv1 $vg
+lvconvert -y --vdopool $vg/$lv1
+lvremove -f $vg
+
+
+lvcreate -L5G -n $lv1 $vg
+lvconvert -y --vdopool $vg/$lv1 -n $lv2
+check lv_field $vg/$lv1 segtype vdo-pool
+check lv_field $vg/${lv1}_vdata segtype linear -a
+check lv_field $vg/$lv2 segtype vdo
+lvremove -f $vg
+
+
+lvcreate -L5G -n $lv1 $vg
+lvconvert -y --type vdo-pool $vg/$lv1 -n $lv2 -V10G
+lvremove -f $vg
+
+
+lvcreate -L5G -n $lv1 $vg
+lvconvert -y --vdopool $vg/$lv1 -n $lv2 -V10G --compression n --deduplication n
+check lv_field $vg/$lv1 size "5.00g"
+check lv_field $vg/${lv1}_vdata size "5.00g" -a
+check lv_field $vg/$lv2 size "10.00g"
+lvremove -f $vg
+
+
+# Simple stacking works...
+# Just be sure test do not try to synchronize 5G of mirror!!
+lvcreate -L5G --type mirror --nosync -n $lv1 $vg
+lvconvert -y --vdopool $vg/$lv1 -n $lv2
+lvs -a $vg
+check lv_field $vg/${lv1}_vdata segtype mirror -a
+lvremove -f $vg
+
+
+vgremove -ff $vg
diff --git a/test/shell/lvcreate-vdo.sh b/test/shell/lvcreate-vdo.sh
new file mode 100644
index 0000000..64377cd
--- /dev/null
+++ b/test/shell/lvcreate-vdo.sh
@@ -0,0 +1,83 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+
+SKIP_WITH_LVMPOLLD=1
+
+
+. lib/inittest
+
+#
+# Main
+#
+aux have_vdo 6 2 0 || skip
+which mkfs.ext4 || skip
+
+aux prepare_pvs 2 6400
+get_devs
+
+#aux lvmconf 'allocation/vdo_use_read_cache = 1' 'allocation/vdo_read_cache_size_mb = 64'
+
+#aux lvmconf 'allocation/vdo_use_compression = 0' 'allocation/vdo_use_deduplication = 0'
+
+#aux lvmconf 'allocation/vdo_hash_zone_threads = 0' \
+#	'allocation/vdo_logical_threads = 0' \
+#	'allocation/vdo_physical_threads = 0' \
+#	'allocation/vdo_cpu_threads = 1'
+
+aux lvmconf 'allocation/vdo_slab_size_mb = 128'
+
+
+vgcreate $SHARED -s 64K "$vg" "${DEVICES[@]}"
+
+# Create VDO device  (vdo-pool is ATM internal volume type)
+lvcreate --type vdo -L4G -n $lv1 $vg/$lv2
+check lv_field $vg/$lv1 size "1.24g"
+check lv_field $vg/${lv2} size "4.00g"
+check lv_field $vg/${lv2}_vdata size "4.00g"
+lvremove -ff $vg
+
+
+lvcreate --vdo -L4G -V8G -n $lv1 $vg/$lv2
+check lv_field $vg/$lv1 size "8.00g"
+check lv_field $vg/${lv2} size "4.00g"
+check lv_field $vg/${lv2}_vdata size "4.00g"
+lvs -a $vg
+
+dmsetup table | grep $vg
+dmsetup status | grep $vg
+
+# Resize not yet supported
+not lvresize -y $vg/$lv1
+not lvresize -y $vg/${lv2}
+not lvresize -y $vg/${lv2}_vdata
+
+# Discard is very slow with VDO ATM so try to avoid it
+#time blkdiscard "$DM_DEV_DIR/$vg/$lv1"
+time mkfs.ext4 -E nodiscard "$DM_DEV_DIR/$vg/$lv1"
+#time mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+fsck -n "$DM_DEV_DIR/$vg/$lv1"
+
+# vpool itself is NOT usable filesystem
+not fsck -n "$DM_DEV_DIR/mapper/$vg-${lv2}"
+# not usable even when there is no linear mapping on top of it
+dmsetup remove ${vg}-$lv1
+not fsck -n "$DM_DEV_DIR/mapper/$vg-${lv2}"
+
+lvremove -ff $vg
+
+
+lvcreate --type vdo -L10G -V1T -n $lv1 $vg
+lvs -a $vg
+lvremove -ff $vg
+
+vgremove -ff $vg
diff --git a/test/shell/profiles-vdo.sh b/test/shell/profiles-vdo.sh
new file mode 100644
index 0000000..4a0f07e
--- /dev/null
+++ b/test/shell/profiles-vdo.sh
@@ -0,0 +1,50 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Exercise obtaining cache parameter from various sources
+# Either commmand line or metadata profile or implicit default...
+
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_cache 1 8 0 || skip
+
+PDIR="$LVM_SYSTEM_DIR/profile"
+PFILE="vdo-test"
+
+aux prepare_profiles
+
+cat <<EOF > "$PDIR/${PFILE}.profile"
+allocation {
+	vdo_use_compression = 0
+	vdo_use_deduplication = 0
+	vdo_slab_size_mb = 128
+}
+EOF
+
+aux prepare_vg 2 1000000
+
+# Check chunk_size is grabbed from configuration
+lvcreate --vdo -L5G --config 'allocation/vdo_use_compression=0' $vg/vdopool
+lvdisplay -m $vg/vdopool | tee out
+grep "Compression.*no" out
+lvremove -f $vg
+
+# Without profile using 128MB slab it would NOT even pass
+lvcreate --vdo -L4G --metadataprofile "$PFILE" $vg/vdopool
+lvdisplay -m $vg/vdopool | tee out
+grep "Compression.*no" out
+lvremove -f $vg
+
+vgremove -ff $vg


