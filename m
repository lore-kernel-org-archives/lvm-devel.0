From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Nov 2016 16:00:06 +0000 (UTC)
Subject: master - tests: avoid using polling
Message-ID: <20161111160006.C7526601A6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=de3d054f7803bad12e395cb0bd099c0c9c396668
Commit:        de3d054f7803bad12e395cb0bd099c0c9c396668
Parent:        4a2250f9cea300598fff8dbfee8700ac7aa81f89
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 11 15:56:11 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 11 16:58:20 2016 +0100

tests: avoid using polling

---
 test/shell/snapshot-merge-stack.sh |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/test/shell/snapshot-merge-stack.sh b/test/shell/snapshot-merge-stack.sh
index 6ed9c95..3ee9eaa 100644
--- a/test/shell/snapshot-merge-stack.sh
+++ b/test/shell/snapshot-merge-stack.sh
@@ -40,13 +40,14 @@ snap_and_merge() {
 	kill $SLEEP_PID
 
 	aux delay_dev "$dev1"  0 200 $(get first_extent_sector "$dev1"):
-	lvchange --refresh $vg/$lv1
+	lvchange --poll n --refresh $vg/$lv1
 	dmsetup table
 	lvs -a -o+lv_merging,lv_merge_failed $vg
 	sleep 1
 	check lv_attr_bit state $vg/$lv1 "a"
 	check lv_attr_bit state $vg/$lv2 "a"
 	aux error_dev "$dev2" $(get first_extent_sector "$dev2"):
+	aux enable_dev "$dev1"
 	# delay to let snapshot merge 'discover' failing COW device
 	sleep 1
 	sync
@@ -56,7 +57,7 @@ snap_and_merge() {
 	check lv_attr_bit state $vg/$lv2 "m"
 
 	# device OK and running in full speed
-	aux enable_dev "$dev1" "$dev2"
+	aux enable_dev "$dev2"
 
 	# reactivate so merge can finish
 	lvchange -an $vg


