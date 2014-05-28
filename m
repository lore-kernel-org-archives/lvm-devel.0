From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 28 May 2014 13:36:02 +0000 (UTC)
Subject: master - tests: raid syncaction activation race
Message-ID: <20140528133602.7D12760D38@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ba3e6e7c323a48b64720f7a182d5c8eca0a5613c
Commit:        ba3e6e7c323a48b64720f7a182d5c8eca0a5613c
Parent:        a67774c1fa315e248504a51804cef9f9bc709b2e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 28 15:23:46 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 28 15:33:41 2014 +0200

tests: raid syncaction activation race

Demonstrace problem of syncaction being called right after activation.
---
 test/shell/lvchange-syncaction-raid.sh |   63 ++++++++++++++++++++++++++++++++
 1 files changed, 63 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvchange-syncaction-raid.sh b/test/shell/lvchange-syncaction-raid.sh
new file mode 100644
index 0000000..a27b885
--- /dev/null
+++ b/test/shell/lvchange-syncaction-raid.sh
@@ -0,0 +1,63 @@
+#!/bin/sh
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# test activation race for raid's --syncaction check
+
+. lib/test
+
+aux have_raid 1 5 0 || skip
+aux prepare_vg 3
+
+lvcreate -n $lv1 $vg -l1 --type raid1
+
+START=$(get pv_field "$dev2" pe_start --units 1k)
+METASIZE=$(get lv_field $vg/${lv1}_rmeta_1 size -a --units 1k)
+SEEK=$((${START%\.00k} + ${METASIZE%\.00k}))
+# Overwrite some portion of  _rimage_1
+dd if=/dev/urandom of="$dev2" bs=1K count=1 seek=$SEEK
+
+lvchange --syncaction check $vg/$lv1
+
+# hmmm it's still in 'dd' buffer and not on real disk ??
+# anyway skip over with 'should'
+should check lv_field $vg/$lv1 raid_mismatch_count "128"
+
+# Ensure it's all on disk now
+sync
+
+lvchange --syncaction check $vg/$lv1
+check lv_field $vg/$lv1 raid_mismatch_count "128"
+
+# Let's deactivate
+lvchange -an $vg/$lv1
+
+# Slow down write by 100ms
+aux delay_dev "$dev2" 0 100
+lvchange -ay $vg/$lv1
+# noone has it open and target is read & running
+dmsetup info -c
+
+#sleep 10 < "$DM_DEV_DIR/$vg/$lv1" &
+# "check" should find discrepancies but not change them
+# 'lvs' should show results
+
+# FIXME
+# this looks like some race with 'write' during activation
+# and syncaction...
+# For now it fails with:
+# device-mapper: message ioctl on  failed: Device or resource busy
+#
+lvchange --syncaction check $vg/$lv1
+
+aux enable_dev "$dev2"
+lvs -o+raid_mismatch_count -a $vg
+
+vgremove -ff $vg


