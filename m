From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 21 Apr 2017 14:59:07 -0400
Subject: master - test: add upconvert allocation failure tests
Message-ID: <201704211859.v3LIx7Po031023@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7c7122a3b1482900f71168f7ce0fec176eb36f8a
Commit:        7c7122a3b1482900f71168f7ce0fec176eb36f8a
Parent:        d48b816764fcf2b153d9d4f27244be5b96846227
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Apr 21 20:57:31 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Apr 21 20:57:31 2017 +0200

test: add upconvert allocation failure tests

---
 .../shell/lvconvert-raid-takeover-alloc-failure.sh |   98 ++++++++++++++++++++
 1 files changed, 98 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-raid-takeover-alloc-failure.sh b/test/shell/lvconvert-raid-takeover-alloc-failure.sh
new file mode 100644
index 0000000..7cb8378
--- /dev/null
+++ b/test/shell/lvconvert-raid-takeover-alloc-failure.sh
@@ -0,0 +1,98 @@
+#!/bin/sh
+# Copyright (C) 017 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA2110-1301 USA
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_raid 1 9 1 || skip
+
+aux prepare_vg 6
+
+function check_sub_lvs
+{
+	local vg=$1
+	local lv=$2
+	local end=$3
+
+	for s in `seq 0 $end`
+	do
+		check lv_exists $vg ${lv}_rmeta_$s
+		check lv_exists $vg ${lv}_rimage_$s
+	done
+}
+
+function check_no_sub_lvs
+{
+	local vg=$1
+	local lv=$2
+	local start=$3
+	local end=$4
+
+	for s in `seq $start $end`
+	do
+		check lv_not_exists $vg ${lv}_rmeta_$s
+		check lv_not_exists $vg ${lv}_rimage_$s
+	done
+}
+
+# Check takover upconversion fails allocation errors nicely without leaving image pair remnants behind
+
+# 6-way striped: neither conversion to raid5 nor raid6 possible
+lvcreate --yes --stripes 6 --size 4M --name $lv1 $vg
+not lvconvert --yes --type raid5 $vg/$lv1
+check lv_field $vg/$lv1 segtype "striped"
+check_no_sub_lvs $vg $lv1 0 5
+
+not lvconvert --yes --type raid6 $vg/$lv1
+check lv_field $vg/$lv1 segtype "striped"
+check_no_sub_lvs $vg $lv1 0 5
+
+# raid0_meta conversion is possible
+lvconvert --yes --type raid0_meta $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid0_meta"
+check_sub_lvs $vg $lv1 0 5
+
+lvremove -y $vg
+
+# 5-way striped: conversion to raid5 possible but not to raid6
+lvcreate --yes --stripes 5 --size 4M --name $lv1 $vg
+not lvconvert --yes --type raid6 $vg/$lv1
+check lv_field $vg/$lv1 segtype "striped"
+check_no_sub_lvs $vg $lv1 0 5
+
+lvconvert --yes --type raid5 $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid5_n"
+check lv_field $vg/$lv1 stripes 6
+check lv_field $vg/$lv1 datastripes 5
+check_sub_lvs $vg $lv1 0 5
+
+lvremove -y $vg
+
+# 4-way striped: conversion to raid5 and raid6 possible
+lvcreate --yes --stripes 4 --size 4M --name $lv1 $vg
+lvconvert --yes --type raid5 $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid5_n"
+check lv_field $vg/$lv1 stripes 5
+check lv_field $vg/$lv1 datastripes 4
+check_sub_lvs $vg $lv1 0 4
+check_no_sub_lvs $vg $lv1 5 5
+
+lvremove -y $vg
+lvcreate --yes --stripes 4 --size 4M --name $lv1 $vg
+lvconvert --yes --type raid6 $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid6_n_6"
+check lv_field $vg/$lv1 stripes 6
+check lv_field $vg/$lv1 datastripes 4
+check_sub_lvs $vg $lv1 0 5
+
+vgremove -ff $vg


