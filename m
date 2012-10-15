From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 15 Oct 2012 20:47:22 +0000 (UTC)
Subject: master - TEST: Re-add testing of lvconvert-raid for kernels < 3.2
Message-ID: <20121015204722.C0AB423AB@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=831ce3cda941f02556dd8c4a407754397df17997
Commit:        831ce3cda941f02556dd8c4a407754397df17997
Parent:        67379a3ffdafa69a2830a1155fe9b4689bbf71cb
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Oct 15 15:43:15 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Oct 15 15:43:15 2012 -0500

TEST:  Re-add testing of lvconvert-raid for kernels < 3.2

I'm not sure what 'BUG's were being encountered when the restriction
to limit lvconvert-raid.sh tests to kernels > 3.2 was added.  I do know
that there were BUG's that could be triggered when testing snapshots and
some of the earliest DM RAID available in the kernel.  I've taken out
the 3.2 kernel restriction and added a dm-raid >= 1.2 restriction instead.
This will allow the test to run on patched production kernels.
---
 test/shell/lvconvert-raid.sh |   18 +++---------------
 1 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 4fa766d..59c8bdb 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -22,8 +22,7 @@ get_image_pvs() {
 ########################################################
 # MAIN
 ########################################################
-aux target_at_least dm-raid 1 1 0 || skip
-aux kernel_at_least 3 2 0 || skip
+aux target_at_least dm-raid 1 2 0 || skip
 
 # 9 PVs needed for RAID10 testing (3-stripes/2-mirror - replacing 3 devs)
 aux prepare_pvs 9 80
@@ -33,8 +32,8 @@ vgcreate -c n -s 256k $vg $(cat DEVICES)
 # RAID1 convert tests
 ###########################################
 for under_snap in false true; do
-for i in 1 2 3 4; do
-	for j in 1 2 3 4; do
+for i in 1 2 3; do
+	for j in 1 2 3; do
 		if [ $i -eq 1 ]; then
 			from="linear"
 		else
@@ -121,17 +120,6 @@ check linear $vg $lv2
 # FIXME: ensure no residual devices
 lvremove -ff $vg
 
-# 3-way to linear/2-way
-lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg
-aux wait_for_sync $vg $lv1
-# FIXME: Can't split off a RAID1 from a RAID1 yet
-# 'should' results in "warnings"
-should lvconvert --splitmirrors 2 -n $lv2 $vg/$lv1
-#check linear $vg $lv1
-#check lv_exists $vg $lv2
-# FIXME: ensure no residual devices
-lvremove -ff $vg
-
 ###########################################
 # RAID1 split + trackchanges / merge
 ###########################################


