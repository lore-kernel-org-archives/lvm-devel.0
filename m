From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 18 Mar 2010 15:52:56 -0500
Subject: [PATCH 1 of 12] LVM: testsuite fixes
Message-ID: <201003182052.o2IKquKo024380@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-testsuite-fixes.patch

t-lvconvert-repair-policy.sh fails and readds devices as necesary
for its tests.  When the devices are re-added to the VG, their
ordering in the allocation list changes.  So, the ordering of
mirror devices and logs for successive iterations will change.
Thus, "$dev1" will not always be the first leg of a mirror.  This
property was; however, being assumed.  Tests were failing because
they were not testing what they though they were testing.

This patch makes it so that the creation of mirrors will always
lay them down in exactly the same way.

[I still have my concerns about the way only one of the two
 available policy specifications is stated when 'repair' is
 called.  This means we really don't know what the policy is
 for the one that isn't specified.]


Index: LVM2/test/t-lvconvert-repair-policy.sh
===================================================================
--- LVM2.orig/test/t-lvconvert-repair-policy.sh
+++ LVM2/test/t-lvconvert-repair-policy.sh
@@ -13,12 +13,15 @@
 
 prepare_vg 4
 
+# Clean-up and create a 2-way mirror, where the the
+# leg devices are always on $dev[12] and the log
+# is always on $dev3.  ($dev4 behaves as a spare)
 cleanup() {
 	vgreduce --removemissing $vg
 	for d in "$@"; do enable_dev $d; done
 	for d in "$@"; do vgextend $vg $d; done
 	lvremove -ff $vg/mirror
-	lvcreate -m 1 -L 1 -n mirror $vg
+	lvcreate -m 1 -L 1 -n mirror $vg $dev1 $dev2 $dev3:0
 }
 
 repair() {
@@ -28,34 +31,42 @@ repair() {
 lvcreate -m 1 -L 1 -n mirror $vg
 lvchange -a n $vg/mirror
 
+# Fail a leg of a mirror.
+# Expected result: linear
 disable_dev $dev1
 lvchange --partial -a y $vg/mirror
 repair 'activation { mirror_image_fault_policy = "remove" }'
 lvs | grep -- -wi-a- # non-mirror
 cleanup $dev1
 
+# Fail a leg of a mirror.
+# Expected result: Mirror (leg replaced)
 disable_dev $dev1
 repair 'activation { mirror_image_fault_policy = "replace" }'
 lvs | grep -- mwi-a- # mirror
 lvs | grep mirror_mlog
 cleanup $dev1
 
+# Fail a leg of a mirror (use old name for policy specification)
+# Expected result: Mirror (leg replaced)
 disable_dev $dev1
 repair 'activation { mirror_device_fault_policy = "replace" }'
 lvs | grep -- mwi-a- # mirror
 lvs | grep mirror_mlog
 cleanup $dev1
 
+# Fail a leg of a mirror w/ no available spare
+# Expected result: linear
 disable_dev $dev2 $dev4
-# no room for repair, downconversion should happen
 repair 'activation { mirror_image_fault_policy = "replace" }'
 lvs | grep -- -wi-a-
 cleanup $dev2 $dev4
 
-disable_dev $dev2 $dev4
-# no room for new log, corelog conversion should happen
+# Fail the log device of a mirror w/ no available spare
+# Expected result: mirror w/ corelog
+disable_dev $dev3 $dev4
 repair 'activation { mirror_image_fault_policy = "replace" }'
 lvs
 lvs | grep -- mwi-a-
 lvs | not grep mirror_mlog
-cleanup $dev2 $dev4
+cleanup $dev3 $dev4


