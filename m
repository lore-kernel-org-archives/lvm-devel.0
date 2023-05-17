From: David Teigland <teigland@sourceware.org>
Date: Wed, 17 May 2023 16:12:13 +0000 (GMT)
Subject: main - tests: integrity: snapshots now work on raid+integrity
Message-ID: <20230517161213.853983858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3a757047560d75a28d7e4c7d9a5253a72d786544
Commit:        3a757047560d75a28d7e4c7d9a5253a72d786544
Parent:        3b4e7d1625ddc48dd9393f03a59cc6b74113275a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 17 11:10:45 2023 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 17 11:10:45 2023 -0500

tests: integrity: snapshots now work on raid+integrity

---
 test/shell/integrity.sh | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index 1ba75d230..61229c83a 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -585,7 +585,6 @@ not lvconvert --splitmirrors 1 -n tmp -y $vg/$lv1
 not lvconvert --splitmirrors 1 --trackchanges -y $vg/$lv1
 not lvchange --syncaction repair $vg/$lv1
 not lvreduce -L4M $vg/$lv1
-not lvcreate -s -n snap -L4M $vg/$lv1
 not pvmove -n $vg/$lv1 "$dev1"
 not pvmove "$dev1"
 _verify_data_on_mnt
@@ -769,11 +768,4 @@ not lvconvert --raidintegrity y $vg/${lv2}_cpool_cdata
 not lvconvert --raidintegrity y $vg/${lv2}_cpool_cmeta
 lvremove -y $vg/$lv1
 
-# cannot add integrity to raid that has a snapshot
-
-lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
-lvcreate -s -n $lv2 -l 8 $vg/$lv1
-not lvconvert --raidintegrity y $vg/$lv1
-lvremove -y $vg/$lv1
-
 vgremove -ff $vg

