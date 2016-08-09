From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Tue,  9 Aug 2016 12:17:51 +0000 (UTC)
Subject: master - test: add lvconvert-raid-takeover.sh
Message-ID: <20160809121751.553CA61C16@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3d3f62e10acee60bd61a401b76f009a611d22f9e
Commit:        3d3f62e10acee60bd61a401b76f009a611d22f9e
Parent:        e5a5fd3669914337f85fc5c12e867680eb3f58a9
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Aug 9 14:17:26 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Aug 9 14:17:26 2016 +0200

test: add lvconvert-raid-takeover.sh

Commit 76ef2d15d839106adac4d82005d517be05a657eb introduced
raid0 <-> raid4 takeover and full mirror <-> raid1 support.

Add tests for these conversions.

Tests exposed a kernel semantics change freezing resynchronization
on conversions from raid0[_meta] -> raid4 or adding raid1 legs
because kernel kept the RAID mapped device in 'frozen' state unless
an 'idle' message was sent or the table was reloaded (kernel patch pending).
---
 test/shell/lvconvert-raid-takeover.sh |  126 +++++++++++++++++++++++++++++++++
 1 files changed, 126 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
new file mode 100644
index 0000000..2ead582
--- /dev/null
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -0,0 +1,126 @@
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
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_raid 1 9 0 || skip
+
+aux prepare_vg 9 288
+
+# Delay 1st leg so that rebuilding status characters
+#  can be read before resync finished too quick.
+# aux delay_dev "$dev1" 0 1
+
+# Create 3-way mirror
+lvcreate --yes --type mirror -m 2 -L 256M -n $lv1 $vg
+check lv_field $vg/$lv1 segtype "mirror"
+check lv_field $vg/$lv1 stripes 3
+echo y | mkfs -t ext4 /dev/mapper/$vg-$lv1
+aux wait_for_sync $vg $lv1
+fsck -fn  /dev/mapper/$vg-$lv1
+
+# Convert 3-way to 4-way mirror
+lvconvert -m 3 $vg/$lv1
+check lv_field $vg/$lv1 segtype "mirror"
+check lv_field $vg/$lv1 stripes 4
+fsck -fn  /dev/mapper/$vg-$lv1
+aux wait_for_sync $vg $lv1
+fsck -fn  /dev/mapper/$vg-$lv1
+
+# Takeover 4-way mirror to raid1
+lvconvert --yes --type raid1 $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid1"
+check lv_field $vg/$lv1 stripes 4
+fsck -fn  /dev/mapper/$vg-$lv1
+
+## Convert 4-way raid1 to 5-way
+lvconvert -m 4 $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid1"
+check lv_field $vg/$lv1 stripes 5
+fsck -fn  /dev/mapper/$vg-$lv1
+aux wait_for_sync $vg $lv1
+fsck -fn  /dev/mapper/$vg-$lv1
+
+# FIXME: enable once lvconvert rejects early
+## Try converting 4-way raid1 to 9-way
+#not lvconvert --yes -m 8 $vg/$lv1
+#check lv_field $vg/$lv1 segtype "raid1"
+#check lv_field $vg/$lv1 stripes 4
+
+# Convert 5-way raid1 to 2-way
+lvconvert --yes -m 1 $vg/$lv1
+lvs $vg/$lv1
+dmsetup status $vg-$lv1
+dmsetup table $vg-$lv1
+check lv_field $vg/$lv1 segtype "raid1"
+check lv_field $vg/$lv1 stripes 2
+fsck -fn  /dev/mapper/$vg-$lv1
+
+# Convert 2-way raid1 to mirror
+lvconvert --yes --type mirror $vg/$lv1
+check lv_field $vg/$lv1 segtype "mirror"
+check lv_field $vg/$lv1 stripes 2
+aux wait_for_sync $vg $lv1
+fsck -fn  /dev/mapper/$vg-$lv1
+aux wait_for_sync $vg $lv1
+
+# Clean up
+lvremove --yes $vg/$lv1
+
+# Create 3-way raid0
+lvcreate -y --type raid0 -i 3 -L 256M -n $lv1 $vg
+check lv_field $vg/$lv1 segtype "raid0"
+check lv_field $vg/$lv1 stripes 3
+echo y | mkfs -t ext4 /dev/mapper/$vg-$lv1
+fsck -fn  /dev/mapper/$vg-$lv1
+
+# Convert raid0 -> raid4
+lvconvert -y --ty raid4 $vg/$lv1
+lvchange --refresh $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid4"
+check lv_field $vg/$lv1 stripes 4
+fsck -fn  /dev/mapper/$vg-$lv1
+aux wait_for_sync $vg $lv1
+fsck -fn  /dev/mapper/$vg-$lv1
+
+# Convert raid4 -> raid0_meta
+lvconvert -y --ty raid0_meta $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid0_meta"
+check lv_field $vg/$lv1 stripes 3
+fsck -fn  /dev/mapper/$vg-$lv1
+
+# Convert raid0_meta -> raid4
+lvconvert -y --ty raid4 $vg/$lv1
+fsck -fn  /dev/mapper/$vg-$lv1
+check lv_field $vg/$lv1 segtype "raid4"
+check lv_field $vg/$lv1 stripes 4
+aux wait_for_sync $vg $lv1
+fsck -fn  /dev/mapper/$vg-$lv1
+
+# Convert raid4 -> raid0
+lvconvert -y --ty raid0 $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid0"
+check lv_field $vg/$lv1 stripes 3
+fsck -fn  /dev/mapper/$vg-$lv1
+
+# Convert raid0 -> raid4
+lvconvert -y --ty raid4 $vg/$lv1
+lvchange --refresh $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid4"
+check lv_field $vg/$lv1 stripes 4
+fsck -fn  /dev/mapper/$vg-$lv1
+aux wait_for_sync $vg $lv1
+fsck -fn  /dev/mapper/$vg-$lv1
+
+vgremove -ff $vg


