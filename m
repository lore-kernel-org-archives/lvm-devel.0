From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  5 Dec 2016 16:15:36 +0000 (UTC)
Subject: master - tests: more snaps
Message-ID: <20161205161536.D551760528@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0ce9ae3cda9411f8f2a5491b07a6c4f06ab44da1
Commit:        0ce9ae3cda9411f8f2a5491b07a6c4f06ab44da1
Parent:        3f6ade4b0d5901bb01bcbdfdb926823415a01703
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 4 22:27:57 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 5 17:12:42 2016 +0100

tests: more snaps

Check lvs reports 'origin' not openned.
---
 test/shell/snapshot-merge-stack.sh |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/test/shell/snapshot-merge-stack.sh b/test/shell/snapshot-merge-stack.sh
index 3ee9eaa..bfafe71 100644
--- a/test/shell/snapshot-merge-stack.sh
+++ b/test/shell/snapshot-merge-stack.sh
@@ -37,14 +37,17 @@ snap_and_merge() {
 	lvconvert -b --merge $vg/$lv2
 
 	lvs -a -o+lv_merging,lv_merge_failed $vg
+	get lv_field $vg/$lv1 lv_attr | grep "Owi-ao"
+	get lv_field $vg/$lv2 lv_attr | grep "Swi-a-s---"
 	kill $SLEEP_PID
 
 	aux delay_dev "$dev1"  0 200 $(get first_extent_sector "$dev1"):
 	lvchange --poll n --refresh $vg/$lv1
 	dmsetup table
-	lvs -a -o+lv_merging,lv_merge_failed $vg
+	lvs -av -o+lv_merging,lv_merge_failed $vg
+	# Origin is closed and snapshot merge could run
+	get lv_field $vg/$lv1 lv_attr | grep "Owi-a-"
 	sleep 1
-	check lv_attr_bit state $vg/$lv1 "a"
 	check lv_attr_bit state $vg/$lv2 "a"
 	aux error_dev "$dev2" $(get first_extent_sector "$dev2"):
 	aux enable_dev "$dev1"


