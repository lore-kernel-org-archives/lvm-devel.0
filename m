From: David Teigland <teigland@sourceware.org>
Date: Wed, 8 Mar 2017 14:53:38 -0500
Subject: master - tests: add test for relative option values
Message-ID: <201703081953.v28JrbLB031510@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=14c7912f45ec9df0fc72e1e3844f04faf6590edf
Commit:        14c7912f45ec9df0fc72e1e3844f04faf6590edf
Parent:        a6a2788e7cb3a7bce73b03644351f15f26a6ad36
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 8 13:51:33 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 8 13:51:33 2017 -0600

tests: add test for relative option values

Combinations of: lvcreate/lvresize/lvextend/lvreduce,
--size/--extents/--poolmetadatasize, +/-/nosign.
---
 test/shell/relative-sign-options.sh |   80 +++++++++++++++++++++++++++++++++++
 1 files changed, 80 insertions(+), 0 deletions(-)

diff --git a/test/shell/relative-sign-options.sh b/test/shell/relative-sign-options.sh
new file mode 100644
index 0000000..00f5791
--- /dev/null
+++ b/test/shell/relative-sign-options.sh
@@ -0,0 +1,80 @@
+#!/bin/sh
+# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+test_description='Exercise toollib process_each_lv'
+SKIP_WITH_LVMPOLLD=1
+
+# disable lvmetad logging as it bogs down test systems
+export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
+
+. lib/inittest
+
+aux prepare_vg 1 256
+
+lvcreate -an -n $lv1 -l4 $vg
+lvcreate -an -n $lv2 -L4 $vg
+lvcreate -an -n $lv3 -l+4 $vg
+lvcreate -an -n $lv4 -L+4 $vg
+not lvcreate -n $lv5 -l-4 $vg
+not lvcreate -n $lv5 -L-4 $vg
+
+lvremove $vg/$lv1
+lvremove $vg/$lv2
+lvremove $vg/$lv3
+lvremove $vg/$lv4
+
+lvcreate -an -n $lv1 -l4 $vg
+lvresize -y -l8 $vg/$lv1
+lvresize -y -L16 $vg/$lv1
+lvresize -y -l+1 $vg/$lv1
+lvresize -y -L+1 $vg/$lv1
+lvresize -y -l-1 $vg/$lv1
+lvresize -y -L-1 $vg/$lv1
+
+lvcreate -an -n $lv2 -l4 $vg
+lvextend -y -l8 $vg/$lv2
+lvextend -y -L16 $vg/$lv2
+lvextend -y -l+1 $vg/$lv2
+lvextend -y -L+1 $vg/$lv2
+not lvextend -y -l-1 $vg/$lv2
+not lvextend -y -L-1 $vg/$lv2
+
+lvcreate -an -n $lv3 -l64 $vg
+lvreduce -y -l32 $vg/$lv3
+lvreduce -y -L8 $vg/$lv3
+lvreduce -y -l-1 $vg/$lv3
+lvreduce -y -L-1 $vg/$lv3
+not lvreduce -y -l+1 $vg/$lv3
+not lvreduce -y -L+1 $vg/$lv3
+
+# relative with percent extents
+
+lvcreate -an -n $lv6 -l+100%FREE $vg
+lvremove $vg/$lv6
+
+lvcreate -an -n $lv6 -l1 $vg
+lvextend -y -l+100%FREE $vg/$lv6
+lvremove $vg/$lv6
+
+lvcreate -an -n $lv6 -l1 $vg
+lvresize -y -l+100%FREE $vg/$lv6
+lvremove $vg/$lv6
+
+# relative poolmetadatasize
+
+lvcreate --type thin-pool -L64 --poolmetadatasize 32 -n $lv7 $vg
+lvresize --poolmetadatasize 64 $vg/$lv7
+lvresize --poolmetadatasize +8 $vg/$lv7
+not lvresize -y --poolmetadatasize -8 $vg/$lv7
+
+lvextend --poolmetadatasize +8 $vg/$lv7
+
+vgremove -y $vg


