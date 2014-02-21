From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 21 Feb 2014 19:16:51 +0000 (UTC)
Subject: master - test: Only try raid10 on dm-raid versions that support it.
Message-ID: <20140221191651.7730860E25@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=294671fa629fb1d2e3580a411cc3ada3acce6626
Commit:        294671fa629fb1d2e3580a411cc3ada3acce6626
Parent:        84d02542bd1e52e2f8721a56b0d98d23c478205e
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Fri Feb 21 19:46:31 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 21 19:47:06 2014 +0100

test: Only try raid10 on dm-raid versions that support it.

---
 test/shell/lvcreate-raid.sh |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index 3f467f5..6587f23 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -170,7 +170,9 @@ lvremove -ff $vg
 not lvcreate --type raid1 -l1 $vg $dev1
 not lvcreate --type raid5 -l2 $vg $dev1 $dev2
 not lvcreate --type raid6 -l3 $vg $dev1 $dev2 $dev3 $dev4
-not lvcreate --type raid10 -l2 $vg $dev1 $dev2 $dev3
+if aux target_at_least dm-raid 1 4 1; then
+    not lvcreate --type raid10 -l2 $vg $dev1 $dev2 $dev3
+fi
 
 # Implicit count comes from #PVs given (always 2 for mirror though)
 lvcreate --type raid1 -l1 -n raid1 $vg $dev1 $dev2
@@ -179,8 +181,10 @@ lvcreate --type raid5 -l2 -n raid5 $vg $dev1 $dev2 $dev3
 lv_devices $vg raid5 3
 lvcreate --type raid6 -l3 -n raid6 $vg $dev1 $dev2 $dev3 $dev4 $dev5
 lv_devices $vg raid6 5
-lvcreate --type raid10 -l2 -n raid10 $vg $dev1 $dev2 $dev3 $dev4
-lv_devices $vg raid10 4
+if aux target_at_least dm-raid 1 4 1; then
+    lvcreate --type raid10 -l2 -n raid10 $vg $dev1 $dev2 $dev3 $dev4
+    lv_devices $vg raid10 4
+fi
 lvremove -ff $vg
 
 # Implicit count comes from total #PVs in VG (always 2 for mirror though)
@@ -190,6 +194,9 @@ lvcreate --type raid5 -l2 -n raid5 $vg
 lv_devices $vg raid5 6
 lvcreate --type raid6 -l3 -n raid6 $vg
 lv_devices $vg raid6 6
-lvcreate --type raid10 -l2 -n raid10 $vg
-lv_devices $vg raid10 6
+
+if aux target_at_least dm-raid 1 4 1; then
+    lvcreate --type raid10 -l2 -n raid10 $vg
+    lv_devices $vg raid10 6
+fi
 lvremove -ff $vg


