From: David Teigland <teigland@sourceware.org>
Date: Tue, 24 Sep 2019 16:56:00 -0400
Subject: master - tests: update cache-single-split
Message-ID: <201909242056.x8OKu0q1015829@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3b36de573ec53a3e616594903ff3ca64ee2dcafa
Commit:        3b36de573ec53a3e616594903ff3ca64ee2dcafa
Parent:        f27625f005f5a96a7ed44d2dbc9f71cfcc981c54
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 24 13:17:40 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 24 15:51:05 2019 -0500

tests: update cache-single-split

add some uncache commands
---
 test/shell/cache-single-split.sh |  125 +++++++++++++++++++++++++++++++++++++-
 1 files changed, 124 insertions(+), 1 deletions(-)

diff --git a/test/shell/cache-single-split.sh b/test/shell/cache-single-split.sh
index 90c3ddb..3224ea1 100644
--- a/test/shell/cache-single-split.sh
+++ b/test/shell/cache-single-split.sh
@@ -289,5 +289,128 @@ lvs $vg
 vgchange -an $vg
 vgextend --restoremissing $vg "$dev3"
 
-vgremove -ff $vg
+#
+# uncache when no devs are missing
+# while inactive
+# both cachemodes work the same
+#
+
+lvremove $vg/$lv1
+lvremove $vg/$lv2
+
+lvcreate -n $lv1 -l 16 -an $vg "$dev1" "$dev4"
+lvcreate -n $lv2 -l 4 -an $vg "$dev2"
+
+lvconvert -y --type cache --cachevol $lv2 --cachemode writethrough $vg/$lv1
+
+mkfs_mount_umount $lv1
+
+lvconvert --uncache $vg/$lv1
+lvs -o segtype $vg/$lv1 | grep linear
+
+lvcreate -n $lv2 -l 4 -an $vg "$dev2"
+
+lvconvert -y --type cache --cachevol $lv2 --cachemode writeback $vg/$lv1
+
+mkfs_mount_umount $lv1
+
+lvconvert --uncache $vg/$lv1
+lvs -o segtype $vg/$lv1 | grep linear
+
+mount_umount $lv1
+
+#
+# uncache when no devs are missing
+# while active
+# both cachemodes work the same
+#
+
+lvremove $vg/$lv1
+
+lvcreate -n $lv1 -l 16 -an $vg "$dev1" "$dev4"
+lvcreate -n $lv2 -l 4 -an $vg "$dev2"
+
+lvconvert -y --type cache --cachevol $lv2 --cachemode writethrough $vg/$lv1
+
+mkfs_mount_umount $lv1
+
+lvchange -ay $vg/$lv1
+
+lvconvert --uncache $vg/$lv1
+lvs -o segtype $vg/$lv1 | grep linear
+
+lvcreate -n $lv2 -l 4 -an $vg "$dev2"
+
+lvconvert -y --type cache --cachevol $lv2 --cachemode writeback $vg/$lv1
+
+lvchange -an $vg/$lv1
+
+mkfs_mount_umount $lv1
+
+lvchange -ay $vg/$lv1
+
+lvconvert --uncache $vg/$lv1
+lvs -o segtype $vg/$lv1 | grep linear
+
+mount_umount $lv1
+
+#
+# uncache while cachevol is missing
+# writethrough
+#
+
+lvremove $vg/$lv1
+
+lvcreate -n $lv1 -l 16 -an $vg "$dev1" "$dev4"
+lvcreate -n $lv2 -l 4 -an $vg "$dev2"
+
+lvconvert -y --type cache --cachevol $lv2 --cachemode writethrough $vg/$lv1
+
+mkfs_mount_umount $lv1
+
+aux disable_dev "$dev2"
+
+lvconvert --uncache $vg/$lv1
+
+lvs -o segtype $vg/$lv1 | grep linear
+
+aux enable_dev "$dev2"
+
+not lvs -o segtype $vg/$lv2
+
+vgck --updatemetadata $vg
+lvs $vg
+
+vgchange -an $vg
+
+mount_umount $lv1
+
+#
+# uncache while cachevol is missing
+# writeback
+#
 
+lvremove $vg/$lv1
+
+lvcreate -n $lv1 -l 16 -an $vg "$dev1" "$dev4"
+lvcreate -n $lv2 -l 4 -an $vg "$dev2"
+
+lvconvert -y --type cache --cachevol $lv2 --cachemode writeback $vg/$lv1
+
+mkfs_mount_umount $lv1
+
+aux disable_dev "$dev2"
+
+not lvconvert --uncache $vg/$lv1
+lvconvert --uncache --force --yes $vg/$lv1
+
+lvs -o segtype $vg/$lv1 | grep linear
+
+aux enable_dev "$dev2"
+
+not lvs -o segtype $vg/$lv2
+
+vgck --updatemetadata $vg
+lvs $vg
+
+vgremove -ff $vg


