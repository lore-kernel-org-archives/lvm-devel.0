From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  1 Feb 2021 11:47:43 +0000 (GMT)
Subject: main - tests: check 16G thin pool metadata size
Message-ID: <20210201114743.195453836C02@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b17b556e26e83bd9dadf711c5fba1d0d8939499f
Commit:        b17b556e26e83bd9dadf711c5fba1d0d8939499f
Parent:        9fa4c099fb036883ee4abec200406824687372b8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jan 30 13:13:34 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 1 12:13:49 2021 +0100

tests: check 16G thin pool metadata size

---
 test/shell/thin-16g.sh | 88 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 88 insertions(+)

diff --git a/test/shell/thin-16g.sh b/test/shell/thin-16g.sh
new file mode 100644
index 000000000..ee7e22ed2
--- /dev/null
+++ b/test/shell/thin-16g.sh
@@ -0,0 +1,88 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2021 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Test usability of 16g thin pool metadata  LV
+
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_thin 1 0 0 || skip
+
+aux prepare_vg 1 50000
+
+lvcreate -T -L10 --poolmetadatasize 16g $vg/pool
+check lv_field $vg/pool_tmeta size "<15.88g"
+lvremove -f $vg
+
+# Cropped way
+lvcreate -T -L10 --poolmetadatasize 16g --config 'allocation/thin_pool_crop_metadata=1' $vg/pool
+check lv_field $vg/pool_tmeta size "15.81g"
+lvremove -f $vg
+
+lvcreate -L16G -n meta $vg
+lvcreate -L10  -n pool $vg
+lvconvert --yes --thinpool $vg/pool --poolmetadata meta
+# Uncropped size 33554432 sectors - 16GiB
+dmsetup table ${vg}-pool_tmeta | grep 33554432
+lvremove -f $vg
+
+# Uses 20G metadata volume, but crops the size in DM table
+lvcreate -L20G -n meta $vg
+lvcreate -L10  -n pool $vg
+lvconvert --yes --thinpool $vg/pool --poolmetadata meta --config 'allocation/thin_pool_crop_metadata=1'
+check lv_field $vg/lvol0_pmspare size "16.00g"
+# Size should be cropped to 33161216 sectors  ~15.81GiB
+dmsetup table ${vg}-pool_tmeta | grep 33161216
+
+# Also size remains unchanged with activation has no cropping,
+# but metadata have no CROP_METADATA flag set
+lvchange -an $vg
+lvchange -ay $vg
+# Size still stays cropped to 33161216 sectors  ~15.81GiB
+dmsetup table ${vg}-pool_tmeta | grep 33161216
+lvremove -f $vg
+
+# Minimal size is 2M
+lvcreate -L1M -n meta $vg
+lvcreate -L10 -n pool $vg
+not lvconvert --yes --thinpool $vg/pool --poolmetadata meta
+lvremove -f $vg
+
+# Uses 20G metadata volume, but crops the size in DM table
+lvcreate -L1 --poolmetadatasize 10G -T $vg/pool
+lvresize -L+10G $vg/pool_tmeta --config 'allocation/thin_pool_crop_metadata=1'
+check lv_field $vg/lvol0_pmspare size "15.81g"
+# Size should be cropped to 33161216 sectors  ~15.81GiB
+dmsetup table ${vg}-pool_tmeta | grep 33161216
+
+# Without cropping we can grop to ~15.88GiB
+lvresize -L+10G $vg/pool_tmeta
+check lv_field $vg/lvol0_pmspare size "<15.88g"
+lvremove -f $vg
+
+# User has already 'bigger' metadata and wants them uncropped
+lvcreate -L16G -n meta $vg
+lvcreate -L10  -n pool $vg
+lvconvert --yes --thinpool $vg/pool --poolmetadata meta --config 'allocation/thin_pool_crop_metadata=1'
+
+# No change with cropping
+lvresize -l+1 $vg/pool_tmeta --config 'allocation/thin_pool_crop_metadata=1'
+dmsetup table ${vg}-pool_tmeta | grep 33161216
+
+# Resizes to 'uncropped' size 16GiB with ANY size
+lvresize -l+1 $vg/pool_tmeta
+dmsetup table ${vg}-pool_tmeta | grep 33554432
+check lv_field $vg/pool_tmeta size "16.00g"
+
+vgremove -ff $vg


