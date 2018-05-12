From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:26:10 -0400
Subject: master - tests: drop delaying
Message-ID: <201805121626.w4CGQArw007889@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ec0f5c2bf67df53072196f1630f3407501384397
Commit:        ec0f5c2bf67df53072196f1630f3407501384397
Parent:        86c8f0f01f07a1516f5a3f20e2a3c282b52c25dc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 12 18:04:06 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 18:05:50 2018 +0200

tests: drop delaying

Here seem delaying dev has no use.
---
 test/shell/mirror-names.sh |   16 ++--------------
 1 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/test/shell/mirror-names.sh b/test/shell/mirror-names.sh
index 899d63d..a3bc80f 100644
--- a/test/shell/mirror-names.sh
+++ b/test/shell/mirror-names.sh
@@ -51,18 +51,6 @@ lv_convert_lv_() {
 	get lv_field "$1" convert_lv | tr -d []
 }
 
-enable_devs() {
-	for i in "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" ; do
-		aux enable_dev "$i"
-	done
-}
-
-delay_devs() {
-	for i in "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" ; do
-		aux delay_dev "$i" 0 1000 "$(get first_extent_sector "$i"):"
-	done
-}
-
 # ---------------------------------------------------------------------
 # Common environment setup/cleanup for each sub testcases
 
@@ -122,14 +110,14 @@ check_and_cleanup_lvs_
 
 #COMM "converting mirror names is ${lv1}_mimagetmp_2"
 lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg
-delay_devs
+# Use large enough polling interval so mirror is keeping mimagetmp
 LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -i+40 -b $vg/$lv1
 convlv=$(lv_convert_lv_ $vg/$lv1)
 test "$convlv" = "${lv1}_mimagetmp_2"
 lv_devices_ $vg/$lv1 $convlv ${lv1}_mimage_2
 lv_devices_ $vg/$convlv ${lv1}_mimage_0 ${lv1}_mimage_1
 lv_mirror_log_ $vg/$convlv ${lv1}_mlog
-enable_devs
+check lv_exists $vg ${lv1}_mimagetmp_2
 
 #COMM "mirror log name after re-adding is ${lv1}_mlog"
 lvconvert -f --mirrorlog core $vg/$lv1


