From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Jun 2020 16:40:12 +0000 (GMT)
Subject: master - tests: cachevol-cachedevice
Message-ID: <20200622164012.2EB0D3851C07@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ae5634a8be3eedb556325a4b81540896fa6cac16
Commit:        ae5634a8be3eedb556325a4b81540896fa6cac16
Parent:        2aed2a41f7602e9168613a0c37d8dd557e7dba9b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 10 16:59:16 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 22 11:23:58 2020 -0500

tests: cachevol-cachedevice

---
 test/shell/cachevol-cachedevice.sh | 212 +++++++++++++++++++++++++++++++++++++
 1 file changed, 212 insertions(+)

diff --git a/test/shell/cachevol-cachedevice.sh b/test/shell/cachevol-cachedevice.sh
new file mode 100644
index 000000000..11a37d9cd
--- /dev/null
+++ b/test/shell/cachevol-cachedevice.sh
@@ -0,0 +1,212 @@
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
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_cache 1 10 0 || skip
+aux have_writecache 1 0 0 || skip
+
+aux prepare_devs 4 64
+
+vgcreate $SHARED $vg "$dev1" "$dev2"
+
+## cache
+
+# use existing cachevol
+lvcreate -n $lv1 -l8 -an $vg "$dev1"
+lvcreate --type cache -n $lv2 -L40M --cachevol $lv1 -y $vg "$dev2"
+check lv_field $vg/$lv2 segtype cache
+check lv_field $vg/${lv1}_cvol segtype linear -a
+lvremove -y $vg/$lv2
+
+# use entire cachedevice for cachevol
+lvcreate --type cache -n $lv2 -L40M --cachedevice "$dev1" -y $vg "$dev2"
+check lv_field $vg/$lv2 segtype cache
+check lv_field $vg/${lv2}_cache_cvol segtype linear -a
+lvremove -y $vg/$lv2
+
+# use part of cachedevice for cachevol
+lvcreate --type cache -n $lv2 -L20M --cachedevice "$dev1" --cachesize 16M -y $vg "$dev2"
+check lv_field $vg/$lv2 segtype cache
+check lv_field $vg/${lv2}_cache_cvol segtype linear -a
+lvcreate --type cache -n $lv3 -L20M --cachedevice "$dev1" --cachesize 16M -y $vg "$dev2"
+check lv_field $vg/$lv3 segtype cache
+check lv_field $vg/${lv3}_cache_cvol segtype linear -a
+lvremove -y $vg/$lv2
+lvremove -y $vg/$lv3
+
+## writecache
+
+# use existing cachevol
+lvcreate -n $lv1 -l8 -an $vg "$dev1"
+lvcreate --type writecache -n $lv2 -L40M --cachevol $lv1 -y $vg "$dev2"
+check lv_field $vg/$lv2 segtype writecache
+check lv_field $vg/${lv1}_cvol segtype linear -a
+lvremove -y $vg/$lv2
+
+# use entire cachedevice for cachevol
+lvcreate --type writecache -n $lv2 -L40M --cachedevice "$dev1" -y $vg "$dev2"
+check lv_field $vg/$lv2 segtype writecache
+check lv_field $vg/${lv2}_cache_cvol segtype linear -a
+lvremove -y $vg/$lv2
+
+# use part of cachedevice for cachevol
+lvcreate --type writecache -n $lv2 -L20M --cachedevice "$dev1" --cachesize 16M -y $vg "$dev2"
+check lv_field $vg/$lv2 segtype writecache
+check lv_field $vg/${lv2}_cache_cvol segtype linear -a
+lvcreate --type writecache -n $lv3 -L20M --cachedevice "$dev1" --cachesize 16M -y $vg "$dev2"
+check lv_field $vg/$lv3 segtype writecache
+check lv_field $vg/${lv3}_cache_cvol segtype linear -a
+lvremove -y $vg/$lv2
+lvremove -y $vg/$lv3
+
+## multiple cachedevs
+
+vgextend $vg "$dev3" "$dev4"
+
+lvcreate --type writecache -n $lv2 -L100M --cachedevice "$dev1" --cachedevice "$dev3" -y $vg "$dev2" "$dev4"
+check lv_field $vg/${lv2}_cache_cvol lv_size "120.00m"
+lvremove -y $vg/$lv2
+
+lvcreate --type writecache -n $lv2 -L100M --cachedevice "$dev1" --cachedevice "$dev3" --cachesize 80M -y $vg "$dev2" "$dev4"
+check lv_field $vg/${lv2}_cache_cvol lv_size "80.00m"
+lvremove -y $vg/$lv2
+
+pvchange --addtag slow "$dev2"
+pvchange --addtag slow "$dev4"
+pvchange --addtag fast "$dev1"
+pvchange --addtag fast "$dev3"
+
+lvcreate --type writecache -n $lv2 -L100M --cachedevice @fast --cachesize 80M -y $vg @slow
+check lv_field $vg/${lv2}_cache_cvol lv_size "80.00m"
+lvremove -y $vg/$lv2
+
+lvcreate --type cache -n $lv2 -L100M --cachedevice @fast --cachesize 80M -y $vg @slow
+check lv_field $vg/${lv2}_cache_cvol lv_size "80.00m"
+lvremove -y $vg/$lv2
+
+## error cases
+
+# cachevol doesn't exist
+not lvcreate --type cache -n $lv2 -l8 --cachevol asdf -y $vg "$dev2"
+not lvs $vg/$lv1
+not lvs $vg/$lv2
+
+# cachedevice doesn't exist
+not lvcreate --type cache -n $lv2 -l8 --cachedevice asdf -y $vg "$dev2"
+not lvs $vg/$lv1
+not lvs $vg/$lv2
+
+# cachevol doesn't exist
+not lvcreate --type writecache -n $lv2 -l8 --cachevol asdf -y $vg "$dev2"
+not lvs $vg/$lv1
+not lvs $vg/$lv2
+
+# cachedevice doesn't exist
+not lvcreate --type writecache -n $lv2 -l8 --cachedevice asdf -y $vg "$dev2"
+not lvs $vg/$lv1
+not lvs $vg/$lv2
+
+# when cachedevice is already being used, cachesize is required to use a part of it
+lvcreate -n asdf -l1 $vg "$dev1"
+not lvcreate --type writecache -n $lv2 -l8 --cachedevice "$dev1" -y $vg "$dev2"
+not lvcreate --type writecache -n $lv2 -l8 --cachedevice "$dev1" --cachedevice "$dev3" -y $vg "$dev2"
+not lvs $vg/$lv1
+not lvs $vg/$lv2
+lvcreate --type writecache -n $lv2 -l8 --cachedevice "$dev1" --cachesize 8M -y $vg "$dev2"
+lvs $vg/$lv2
+check lv_field $vg/${lv2}_cache_cvol lv_size "8.00m"
+lvremove -y $vg/$lv2
+
+vgremove -ff $vg
+
+# lvconvert single step cachevol creation and attachment
+# . cache and writecache
+# . one or two cachedevices
+# . with or without --cachesize
+# . using tags for devices
+
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4"
+
+lvcreate -n $lv1 -l8 -an $vg "$dev1"
+lvconvert -y --type cache --cachedevice "$dev2" $vg/$lv1
+check lv_field $vg/$lv1 segtype cache
+check lv_field $vg/${lv1}_cache_cvol segtype linear -a
+check lv_field $vg/${lv1}_cache_cvol lv_size "60.00m"
+lvchange -ay $vg/$lv1
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+
+lvcreate -n $lv1 -l8 -an $vg "$dev1"
+lvconvert -y --type cache --cachedevice "$dev2" --cachedevice "$dev3" $vg/$lv1
+check lv_field $vg/$lv1 segtype cache
+check lv_field $vg/${lv1}_cache_cvol lv_size "120.00m"
+lvchange -ay $vg/$lv1
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+
+lvcreate -n $lv1 -l8 -an $vg "$dev1"
+lvconvert -y --type cache --cachedevice "$dev2" --cachedevice "$dev3" --cachesize 8M $vg/$lv1
+check lv_field $vg/$lv1 segtype cache
+check lv_field $vg/${lv1}_cache_cvol lv_size "8.00m"
+lvchange -ay $vg/$lv1
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+
+lvcreate -n $lv1 -l8 -an $vg "$dev1"
+lvconvert -y --type writecache --cachedevice "$dev2" $vg/$lv1
+check lv_field $vg/$lv1 segtype writecache
+check lv_field $vg/${lv1}_cache_cvol lv_size "60.00m"
+lvchange -ay $vg/$lv1
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+
+lvcreate -n $lv1 -l8 -an $vg "$dev1"
+lvconvert -y --type writecache --cachedevice "$dev2" --cachedevice "$dev3" $vg/$lv1
+check lv_field $vg/$lv1 segtype writecache
+check lv_field $vg/${lv1}_cache_cvol lv_size "120.00m"
+lvchange -ay $vg/$lv1
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+
+lvcreate -n $lv1 -l8 -an $vg "$dev1"
+lvconvert -y --type writecache --cachedevice "$dev2" --cachedevice "$dev3" --cachesize 8M $vg/$lv1
+check lv_field $vg/$lv1 segtype writecache
+check lv_field $vg/${lv1}_cache_cvol lv_size "8.00m"
+lvchange -ay $vg/$lv1
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+
+pvchange --addtag slow "$dev1"
+pvchange --addtag fast "$dev2"
+pvchange --addtag fast "$dev3"
+
+lvcreate -n $lv1 -l8 -an $vg @slow
+lvconvert -y --type cache --cachedevice @fast --cachesize 8M $vg/$lv1
+check lv_field $vg/$lv1 segtype cache
+check lv_field $vg/${lv1}_cache_cvol lv_size "8.00m"
+lvchange -ay $vg/$lv1
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+
+lvcreate -n $lv1 -l8 -an $vg @slow
+lvconvert -y --type writecache --cachedevice @fast --cachesize 8M $vg/$lv1
+check lv_field $vg/$lv1 segtype writecache
+check lv_field $vg/${lv1}_cache_cvol lv_size "8.00m"
+lvchange -ay $vg/$lv1
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+
+vgremove -ff $vg
+


