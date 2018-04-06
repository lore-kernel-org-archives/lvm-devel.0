From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 6 Apr 2018 09:27:29 -0400
Subject: master - test: add lvcreate-raid-volume_list
Message-ID: <201804061327.w36DRTCa026673@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bc286910ecb9a1a5962b93618852d1ed4a7ca7dc
Commit:        bc286910ecb9a1a5962b93618852d1ed4a7ca7dc
Parent:        3a48fb47b771c3f4db4222f0fdaf5eb462803ac5
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Apr 6 15:25:46 2018 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Apr 6 15:26:38 2018 +0200

test: add lvcreate-raid-volume_list

Test that no (Sub)LV remnants persist if the volume group is
not listed in configuration variable activation/volume_list,
hence not activatable thus causing initialization of rmeta
SubLVs to fail.

Related: rhbz1161347
---
 WHATS_NEW                               |    1 +
 test/shell/lvcreate-raid-volume_list.sh |   42 +++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3750341..e5d34dc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Add test for activation/volume_list (Sub)LV remnants.
   Disallow usage of cache format 2 with mq cache policy.
   Again accept striped LV as COW LV with lvconvert -s (2.02.169).
   Fix raid target version testing for supported features.
diff --git a/test/shell/lvcreate-raid-volume_list.sh b/test/shell/lvcreate-raid-volume_list.sh
new file mode 100644
index 0000000..a47b961
--- /dev/null
+++ b/test/shell/lvcreate-raid-volume_list.sh
@@ -0,0 +1,42 @@
+#!/usr/bin/env bash
+#
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
+# bz1161347 - When raid creation is aborted, left-over devices appear
+
+. lib/inittest
+
+########################################################
+# MAIN
+########################################################
+aux have_raid 1 3 0 || skip
+
+aux prepare_pvs 2 # 2 devices for RAID1
+get_devs
+vgcreate -s 512k "$vg" "${DEVICES[@]}"
+
+aux lvmconf "activation/volume_list = [ \"vg_not_exist\" ]"
+
+##########################################################
+# Create 2-way raid1 which fails due to $vg not listed on
+# activation/volume_list.  Check for any (Sub)LV remnants.
+##########################################################
+not lvcreate --yes --type raid1 -l 2 -n $lv $vg
+check lv_not_exists $vg/${lv}_rmeta_0
+check lv_not_exists $vg/${lv}_rmeta_1
+check lv_not_exists $vg/${lv}_rimage_0
+check lv_not_exists $vg/${lv}_rimage_1
+check lv_not_exists $vg/$lv
+
+vgremove -ff $vg


