From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:02:58 -0400
Subject: master - tests: update mirror test
Message-ID: <201804201102.w3KB2wUp031438@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ac18005de93de30db445e5fde6abdb801ee6e2a6
Commit:        ac18005de93de30db445e5fde6abdb801ee6e2a6
Parent:        fa5ba7e42d409532ddeea97c5802f042e40935b2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 20 10:13:21 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:17:01 2018 +0200

tests: update mirror test

Since lvconvert again is able to wait on mirror synchronization,
drop 'should'.

Also add FIXME about  'lvreduce' and too big region size.
---
 test/shell/lvconvert-mirror.sh |   43 +++++++++++++++++++++++----------------
 1 files changed, 25 insertions(+), 18 deletions(-)

diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 76ff166..4e18212 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -86,11 +86,15 @@ offset=$(get first_extent_sector "$dev2")
 offset=$(( offset + 2 ))
 # put 1 single slowing delayed sector
 # update in case  mirror ever gets faster and allows parallel read
-aux delay_dev "$dev2" 0 2000 ${offset}:1
-lvcreate -aey -l5 -Zn -Wn --type mirror --regionsize 16K -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:$DEVRANGE"
-should not lvconvert -m-1 $vg/$lv1 "$dev1"
+aux delay_dev "$dev2" 0 10 ${offset}:1
+
+lvcreate -aey -l10 -Zn -Wn --type mirror --regionsize 16k -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:$DEVRANGE"
+lvs -a -o+seg_pe_ranges $vg
+not lvconvert -m-1 $vg/$lv1 "$dev1"
+lvconvert $vg/$lv1 # wait
+lvs -a $vg
 aux enable_dev "$dev2"
-should lvconvert $vg/$lv1 # wait
+lvconvert $vg/$lv1 # wait
 lvconvert -m2 $vg/$lv1 "$dev1" "$dev2" "$dev4" "$dev3:0" # If the above "should" failed...
 
 aux wait_for_sync $vg $lv1
@@ -114,9 +118,9 @@ aux delay_dev "$dev4" 0 2000 ${offset}:
 LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 
 # Next convert should fail b/c we can't have 2 at once
-should not lvconvert -m+1 $vg/$lv1 "$dev5"
+not lvconvert -m+1 $vg/$lv1 "$dev5"
 aux enable_dev "$dev4"
-should lvconvert $vg/$lv1 # wait
+lvconvert $vg/$lv1 # wait
 lvconvert -m2 $vg/$lv1 # In case the above "should" actually failed
 
 check mirror $vg $lv1 "$dev3"
@@ -159,7 +163,7 @@ lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE
 lvchange -an $vg/$lv1
 lvconvert -m+1 $vg/$lv1 "$dev4"
 lvchange -aey $vg/$lv1
-should lvconvert $vg/$lv1 # wait
+lvconvert $vg/$lv1 # wait
 check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
 lvremove -ff $vg
@@ -171,7 +175,7 @@ lvremove -ff $vg
 lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
 LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 lvconvert -m-1 $vg/$lv1 "$dev4"
-should lvconvert $vg/$lv1 # wait
+lvconvert $vg/$lv1 # wait
 
 check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
@@ -182,7 +186,7 @@ lvremove -ff $vg
 lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
 LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+2 -b $vg/$lv1 "$dev4" "$dev5"
 lvconvert -m-1 $vg/$lv1 "$dev4"
-should lvconvert $vg/$lv1 # wait
+lvconvert $vg/$lv1 # wait
 
 check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
@@ -195,9 +199,9 @@ LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 # FIXME: Extra wait here for mirror upconvert synchronization
 # otherwise we may fail her on parallel upconvert and downconvert
 # lvconvert-mirror-updown.sh tests this errornous case separately
-should lvconvert $vg/$lv1
+lvconvert $vg/$lv1
 lvconvert -m-1 $vg/$lv1 "$dev2"
-should lvconvert $vg/$lv1
+lvconvert $vg/$lv1
 
 check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
@@ -210,9 +214,9 @@ LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 # FIXME: Extra wait here for mirror upconvert synchronization
 # otherwise we may fail her on parallel upconvert and downconvert
 # lvconvert-mirror-updown.sh tests this errornous case separately
-should lvconvert $vg/$lv1
+lvconvert $vg/$lv1
 lvconvert -m-1 $vg/$lv1 "$dev2"
-should lvconvert $vg/$lv1
+lvconvert $vg/$lv1
 
 check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
@@ -225,9 +229,9 @@ LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 # FIXME: Extra wait here for mirror upconvert synchronization
 # otherwise we may fail her on parallel upconvert and downconvert
 # lvconvert-mirror-updown.sh tests this errornous case separately
-should lvconvert --startpoll $vg/$lv1
+lvconvert $vg/$lv1
 lvconvert -m-1 $vg/$lv1 "$dev2"
-should lvconvert --startpoll $vg/$lv1
+lvconvert $vg/$lv1
 
 check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
@@ -255,7 +259,8 @@ lvremove -ff $vg
 lvcreate -aey -l 8 -n $lv1 $vg "$dev1:0-3" "$dev2:0-3"
 lvconvert --type mirror -m1 $vg/$lv1
 
-should check mirror $vg $lv1
+# FIXME: lvm should be able to make legs redundant
+#should check mirror $vg $lv1
 check mirror_legs $vg $lv1 2
 lvremove -ff $vg
 
@@ -283,7 +288,9 @@ lvremove -ff $vg
 
 # simple mirrored stripe
 lvcreate -aey -i2 -l10 -n $lv1 $vg
-lvconvert --type mirror -m1 -i1 $vg/$lv1
+# FIXME: ATM reduce LV still must be bigger then region size!
+#        LVM should do a better job here
+lvconvert --type mirror -m1 -i1 --regionsize 16k $vg/$lv1
 lvreduce -f -l1 $vg/$lv1
 lvextend -f -l10 $vg/$lv1
 lvremove -ff $vg/$lv1
@@ -300,7 +307,7 @@ if test -e LOCAL_CLVMD; then
 not lvconvert --type mirror -m +1 --mirrorlog mirrored --alloc anywhere $vg/$lv1 "$dev1" "$dev2"
 else
 lvconvert --type mirror -m +1 --mirrorlog mirrored --alloc anywhere $vg/$lv1 "$dev1" "$dev2"
-should check mirror $vg $lv1
+check mirror $vg $lv1
 fi
 lvremove -ff $vg
 


