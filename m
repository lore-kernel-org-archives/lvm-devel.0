From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 24 May 2018 05:34:56 -0400
Subject: master - tests: checking scanning correctness
Message-ID: <201805240934.w4O9Yurw002270@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a90de76fd8502644e8b42daf88fe055c82fb2abc
Commit:        a90de76fd8502644e8b42daf88fe055c82fb2abc
Parent:        f865e1bf87b474a0795e5b38456ebbeef406351c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 24 11:21:49 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 24 11:22:32 2018 +0200

tests: checking scanning correctness

---
 test/shell/pvcreate-md-fake-hdr.sh |   93 ++++++++++++++++++++++++++++++++++++
 1 files changed, 93 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvcreate-md-fake-hdr.sh b/test/shell/pvcreate-md-fake-hdr.sh
new file mode 100644
index 0000000..acd6785
--- /dev/null
+++ b/test/shell/pvcreate-md-fake-hdr.sh
@@ -0,0 +1,93 @@
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
+# TODO: once code get fixed, add matching 'check' calls
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+test -f /proc/mdstat && grep -q raid1 /proc/mdstat || \
+	modprobe raid1 || skip
+
+aux lvmconf 'devices/md_component_detection = 1'
+aux extend_filter_LVMTEST "a|/dev/md|"
+
+aux prepare_devs 4
+
+vgcreate $vg "$dev3" "$dev4"
+
+# create 2 disk MD raid1 array
+# by default using metadata format 1.0 with data at the end of device
+aux prepare_md_dev 1 64 2 "$dev1" "$dev2"
+
+mddev=$(< MD_DEV)
+pvdev=$(< MD_DEV_PV)
+
+mdadm --stop "$mddev"
+
+# copy fake PV/VG header PV3 -> PV2 (which is however md raid1 leg)
+dd if="$dev3"  of="$dev2" bs=64k count=1 conv=fdatasync
+
+# remove VG on PV3 & PV4
+vgremove -f $vg
+
+sleep 3
+aux udev_wait
+# too bad  'dd' wakes up  md array reassembling
+should not mdadm --detail "$mddev"
+should not mdadm --stop "$mddev"
+sleep 3
+
+# print what  blkid thinks about each PV
+for i in "$dev1" "$dev2" "$dev3" "$dev4"
+do
+   blkid "$i"
+done
+
+# expect open count for each PV to be 0
+dmsetup info -c
+
+pvs -vvvv  "$dev2" "$dev3" || true
+
+# still expect open count for each PV to be 0
+dmsetup info -c
+
+pvs -vvvv  "$dev3" "$dev2" || true
+
+# and again we expect open count for each PV to be 0
+dmsetup info -c
+dmsetup table
+
+# even after 3 second of possible hidden raid array assembling
+sleep 3
+dmsetup info -c
+
+# if for any reason array went up - stop it again
+mdadm --detail "$mddev" && {
+	mdadm --stop "$mddev"
+	aux udev_wait
+	should not mdadm --detail "$mddev"
+}
+
+# now reassemble array from  PV1 & PV2 
+mdadm --assemble --verbose "$mddev" "$dev1" "$dev2"
+aux udev_wait
+sleep 1
+
+# and let 'fake hdr' to be fixed from master/primary leg
+mdadm --action=repair "$mddev"
+sleep 1
+
+# should be showing correctly PV3 & PV4
+pvs


