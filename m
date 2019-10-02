From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 2 Oct 2019 09:28:59 -0400
Subject: master - test: add RAID lvextend resynchronization test
Message-ID: <201910021328.x92DSxxD030920@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=242e2dccc3ba9f4f465a539159269623a357fe72
Commit:        242e2dccc3ba9f4f465a539159269623a357fe72
Parent:        c4aba47dd0ce47f9f72ae4bd05be03e264a91ca2
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Oct 2 14:54:00 2019 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Oct 2 15:25:41 2019 +0200

test: add RAID lvextend resynchronization test

Due to a dm-raid target flaw fixed in target version 1.15.0,
extents of raid sets don't get resynchronized when new MD bitmp
pages have to be allocated due to the extension.

Introduce lvextend-raid.sh to test this flaw.

Related: rhbz1671964
---
 test/shell/lvextend-raid.sh |   65 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 65 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvextend-raid.sh b/test/shell/lvextend-raid.sh
new file mode 100644
index 0000000..8988411
--- /dev/null
+++ b/test/shell/lvextend-raid.sh
@@ -0,0 +1,65 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2019 Red Hat, Inc. All rights reserved.
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
+v1_15_0=0
+aux have_raid 1 15 0 && v1_15_0=1
+
+# Use smallest regionsize to save VG space
+regionsize=`getconf PAGESIZE` # in bytes
+let pageregions=regionsize*8  # number of regions per MD bitmap page
+
+# in KiB
+let regionsize=regionsize/1024
+
+# in MiB
+let lvsz=pageregions*regionsize/1024
+let lvext=lvsz/8
+
+aux prepare_pvs 2 $(($lvsz + 3 * $lvext))
+get_devs
+vgcreate -s 4k $vg ${DEVICES[@]}
+
+aux delay_dev "$dev1"  0 50
+
+# Create raid1 LV consuming 1 MD bitmap page
+lvcreate --yes --type raid1 --regionsize ${regionsize}K -L$(($lvsz-$lvext))M -n $lv1 $vg
+not check lv_field $vg/$lv1 sync_percent "100.00"
+check lv_field $vg/$lv1 size "$(($lvsz-$lvext)).00m" $vg/$lv1
+aux wait_for_sync $vg $lv1
+check lv_field $vg/$lv1 sync_percent "100.00"
+check lv_field $vg/$lv1 region_size "4.00k"
+
+# Extend so that full MD bitmap page is consumed
+lvextend -y -L+${lvext}M $vg/$lv1
+not check lv_field $vg/$lv1 sync_percent "100.00"
+check lv_field $vg/$lv1 size "$(($lvsz)).00m" $vg/$lv1
+aux wait_for_sync $vg $lv1
+check lv_field $vg/$lv1 sync_percent "100.00"
+
+# Extend so that another MD bitmap page is allocated
+lvextend -y -L+${lvext}M $vg/$lv1
+if [ $v1_15_0 -eq 1 ]
+then
+	not check lv_field $vg/$lv1 sync_percent "100.00"
+else
+	check lv_field $vg/$lv1 sync_percent "100.00"
+fi
+aux wait_for_sync $vg $lv1
+check lv_field $vg/$lv1 sync_percent "100.00"
+check lv_field $vg/$lv1 size "$(($lvsz+$lvext)).00m" $vg/$lv1
+
+vgremove -ff $vg


