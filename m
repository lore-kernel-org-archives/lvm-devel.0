From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Feb 2014 20:28:21 +0000 (UTC)
Subject: master - tests: check locking is not lost during thin_check
Message-ID: <20140218202821.0E8F760CFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fdcd95a3b3dd92ed219571467fdc235e1a6cb0b6
Commit:        fdcd95a3b3dd92ed219571467fdc235e1a6cb0b6
Parent:        417e52c13a8156b11c25c411d44bda8b32bf87e4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 18 14:58:41 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 18 14:58:41 2014 +0100

tests: check locking is not lost during thin_check

---
 test/shell/thin-vglock.sh |   51 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 51 insertions(+), 0 deletions(-)

diff --git a/test/shell/thin-vglock.sh b/test/shell/thin-vglock.sh
new file mode 100644
index 0000000..083fcd8
--- /dev/null
+++ b/test/shell/thin-vglock.sh
@@ -0,0 +1,51 @@
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
+# Test locking works and doesn't update metadata
+# RHBZ: https://bugzilla.redhat.com/show_bug.cgi?id=1063542
+
+. lib/test
+
+MKFS=mkfs.ext2
+which $MKFS || skip
+
+aux have_thin 1 0 0 || skip
+aux prepare_vg
+
+lvcreate -L10 -T -V5 -n $lv1 $vg/pool
+lvcreate -an -V10 -T $vg/pool
+
+$MKFS "$DM_DEV_DIR/$vg/$lv1"
+mkdir mnt
+mount "$DM_DEV_DIR/$vg/$lv1" mnt
+
+lvcreate -s -n snap $vg/$lv1
+check lv_field $vg/snap thin_id "3"
+
+lvconvert --merge $vg/snap
+
+umount mnt
+vgchange -an $vg
+
+# Check reboot case
+vgchange -ay --sysinit $vg
+# Metadata are still not updated (--poll n)
+check lv_field $vg/$lv1 thin_id "1"
+check lv_field $vg/pool transaction_id "3"
+
+# Check the metadata are updated after refresh
+vgchange --refresh $vg
+check lv_field $vg/$lv1 thin_id "3"
+check lv_field $vg/pool transaction_id "4"
+
+#lvs -a -o+transaction_id,thin_id $vg
+
+vgremove -f $vg


