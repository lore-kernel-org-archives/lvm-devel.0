From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 14 Jun 2023 11:50:00 +0000 (GMT)
Subject: main - tests: Skip integrity tests if target not present
Message-ID: <20230614115000.4354C3858D1E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f0b48a23d9d8b5d858be1772ea5c9083d235b3b3
Commit:        f0b48a23d9d8b5d858be1772ea5c9083d235b3b3
Parent:        4cf005d3959fdee5f78948164f22a0f0aff25173
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Jun 14 13:48:51 2023 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Jun 14 13:48:51 2023 +0200

tests: Skip integrity tests if target not present

---
 test/shell/snapshot-raid.sh | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/test/shell/snapshot-raid.sh b/test/shell/snapshot-raid.sh
index 757bf911e..7b045d79e 100644
--- a/test/shell/snapshot-raid.sh
+++ b/test/shell/snapshot-raid.sh
@@ -348,6 +348,9 @@ test_extend_snap
 test_fill_snap
 lvremove -y $vg/$lv1
 
+# INTEGRITY TESTS FOLLOWING:
+if aux have_integrity 1 5 0; then
+
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -L128M $vg "$dev1" "$dev2"
 _wait_sync $vg/${lv1}_rimage_0
 _wait_sync $vg/${lv1}_rimage_1
@@ -437,5 +440,7 @@ umount "$mount_dir"
 lvremove -y $vg/snap
 lvremove -y $vg/$lv1
 
+fi # INTEGRITY TESTS SKIPPED
+
 vgremove -ff $vg
 

