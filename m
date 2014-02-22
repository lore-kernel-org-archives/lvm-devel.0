From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Sat, 22 Feb 2014 00:32:26 +0000 (UTC)
Subject: master - test: move RAID10 tests from lvcreate-raid.sh to lvcreate-raid10.sh
Message-ID: <20140222003226.9F47A6008C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=46223c4284552b23cac7c49c49dc1612b45bb66e
Commit:        46223c4284552b23cac7c49c49dc1612b45bb66e
Parent:        13c3f53f55288fcd2dbab1cfc0dd30380521e1cf
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Feb 21 18:26:47 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Feb 21 18:28:16 2014 -0600

test: move RAID10 tests from lvcreate-raid.sh to lvcreate-raid10.sh

---
 test/shell/lvcreate-raid.sh   |   12 ------------
 test/shell/lvcreate-raid10.sh |   25 ++++++++++++++++++++++++-
 2 files changed, 24 insertions(+), 13 deletions(-)

diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index 6587f23..2053d04 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -170,9 +170,6 @@ lvremove -ff $vg
 not lvcreate --type raid1 -l1 $vg $dev1
 not lvcreate --type raid5 -l2 $vg $dev1 $dev2
 not lvcreate --type raid6 -l3 $vg $dev1 $dev2 $dev3 $dev4
-if aux target_at_least dm-raid 1 4 1; then
-    not lvcreate --type raid10 -l2 $vg $dev1 $dev2 $dev3
-fi
 
 # Implicit count comes from #PVs given (always 2 for mirror though)
 lvcreate --type raid1 -l1 -n raid1 $vg $dev1 $dev2
@@ -181,10 +178,6 @@ lvcreate --type raid5 -l2 -n raid5 $vg $dev1 $dev2 $dev3
 lv_devices $vg raid5 3
 lvcreate --type raid6 -l3 -n raid6 $vg $dev1 $dev2 $dev3 $dev4 $dev5
 lv_devices $vg raid6 5
-if aux target_at_least dm-raid 1 4 1; then
-    lvcreate --type raid10 -l2 -n raid10 $vg $dev1 $dev2 $dev3 $dev4
-    lv_devices $vg raid10 4
-fi
 lvremove -ff $vg
 
 # Implicit count comes from total #PVs in VG (always 2 for mirror though)
@@ -194,9 +187,4 @@ lvcreate --type raid5 -l2 -n raid5 $vg
 lv_devices $vg raid5 6
 lvcreate --type raid6 -l3 -n raid6 $vg
 lv_devices $vg raid6 6
-
-if aux target_at_least dm-raid 1 4 1; then
-    lvcreate --type raid10 -l2 -n raid10 $vg
-    lv_devices $vg raid10 6
-fi
 lvremove -ff $vg
diff --git a/test/shell/lvcreate-raid10.sh b/test/shell/lvcreate-raid10.sh
index 0ee18b8..ba35fdf 100644
--- a/test/shell/lvcreate-raid10.sh
+++ b/test/shell/lvcreate-raid10.sh
@@ -11,6 +11,14 @@
 
 . lib/test
 
+lv_devices() {
+	local local_vg=$1
+	local local_lv=$2
+	local count=$3
+
+	[ $count == `lvs --noheadings -o devices $local_vg/$local_lv | sed s/,/' '/g | wc -w` ]
+}
+
 ########################################################
 # MAIN
 ########################################################
@@ -23,7 +31,6 @@ vgcreate -s 512k $vg $(cat DEVICES)
 # Create RAID10:
 #
 
-
 # Should not allow more than 2-way mirror
 not lvcreate --type raid10 -m 2 -i 2 -l 2 -n $lv1 $vg
 
@@ -54,6 +61,22 @@ lvcreate --type raid10 -i 3 -l 100%FREE -n raid10 $vg
 check lv_field $vg/raid10 size "54.00m"
 lvremove -ff $vg
 
+# Create RAID (implicit stripe count based on PV count)
+#######################################################
+
+# Not enough drives
+not lvcreate --type raid10 -l2 $vg $dev1 $dev2 $dev3
+
+# Implicit count comes from #PVs given (always 2-way mirror)
+lvcreate --type raid10 -l2 -n raid10 $vg $dev1 $dev2 $dev3 $dev4
+lv_devices $vg raid10 4
+lvremove -ff $vg
+
+# Implicit count comes from total #PVs in VG (always 2 for mirror though)
+lvcreate --type raid10 -l2 -n raid10 $vg
+lv_devices $vg raid10 6
+lvremove -ff $vg
+
 #
 # FIXME: Add tests that specify particular PVs to use for creation
 #


