From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  1 Sep 2020 21:41:36 +0000 (GMT)
Subject: master - tests: set skipping autoactivation
Message-ID: <20200901214136.25D643870874@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=38d460ed6eb386325b708aa3668ffd8899947450
Commit:        38d460ed6eb386325b708aa3668ffd8899947450
Parent:        ada5728c72e4620c54e4786f31ca5e45cf75d1b0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 1 22:45:17 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 1 23:40:24 2020 +0200

tests: set skipping autoactivation

On test system with 'default' filter  (aka accept all) test
after enabling device can suffer from automatic system
activation - so for created LVs setup skipping this automatic
activation. This should prevent getting LVs into table
with pvscan service.
---
 test/shell/duplicate-vgrename.sh | 32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/test/shell/duplicate-vgrename.sh b/test/shell/duplicate-vgrename.sh
index 86282206f..873195713 100644
--- a/test/shell/duplicate-vgrename.sh
+++ b/test/shell/duplicate-vgrename.sh
@@ -16,7 +16,7 @@ aux prepare_devs 4
 # a. 0 local, 1 foreign
 # setup
 vgcreate $vg1 "$dev1"
-lvcreate -n $lv1 -l1 -an $vg1
+lvcreate -n $lv1 -l1 -ky -an $vg1
 UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
 vgchange -y --systemid "other" $vg1
 
@@ -34,12 +34,12 @@ aux wipefs_a "$dev1"
 # b. 0 local, 2 foreign
 # setup
 vgcreate $vg1 "$dev1"
-lvcreate -n $lv1 -l1 -an $vg1
+lvcreate -n $lv1 -l1 -ky -an $vg1
 UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
 vgchange -y --systemid "other" $vg1
 aux disable_dev "$dev1"
 vgcreate $vg1 "$dev2"
-lvcreate -n $lv1 -l1 -an $vg1
+lvcreate -n $lv1 -l1 -ky -an $vg1
 UUID2=$(vgs --noheading -o vg_uuid $vg1 | xargs)
 vgchange -y --systemid "other2" $vg1
 aux enable_dev "$dev1"
@@ -67,11 +67,11 @@ aux wipefs_a "$dev2"
 # c. 1 local, 1 foreign
 # setup
 vgcreate $vg1 "$dev1"
-lvcreate -n $lv1 -l1 -an $vg1
+lvcreate -n $lv1 -l1 -ky -an $vg1
 UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
 aux disable_dev "$dev1"
 vgcreate $vg1 "$dev2"
-lvcreate -n $lv1 -l1 -an $vg1
+lvcreate -n $lv1 -l1 -ky -an $vg1
 UUID2=$(vgs --noheading -o vg_uuid $vg1 | xargs)
 vgchange -y --systemid "other" $vg1
 aux enable_dev "$dev1"
@@ -99,16 +99,16 @@ aux wipefs_a "$dev2"
 # d. 1 local, 2 foreign
 # setup
 vgcreate $vg1 "$dev1"
-lvcreate -n $lv1 -l1 -an $vg1
+lvcreate -n $lv1 -l1 -ky -an $vg1
 UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
 aux disable_dev "$dev1"
 vgcreate $vg1 "$dev2"
-lvcreate -n $lv1 -l1 -an $vg1
+lvcreate -n $lv1 -l1 -ky -an $vg1
 UUID2=$(vgs --noheading -o vg_uuid $vg1 | xargs)
 vgchange -y --systemid "other" $vg1
 aux disable_dev "$dev2"
 vgcreate $vg1 "$dev3"
-lvcreate -n $lv1 -l1 -an $vg1
+lvcreate -n $lv1 -l1 -ky -an $vg1
 UUID3=$(vgs --noheading -o vg_uuid $vg1 | xargs)
 vgchange -y --systemid "other2" $vg1
 aux enable_dev "$dev1"
@@ -140,11 +140,11 @@ aux wipefs_a "$dev3"
 # e. 2 local, 0 foreign
 # setup
 vgcreate $vg1 "$dev1"
-lvcreate -n $lv1 -l1 -an $vg1
+lvcreate -n $lv1 -l1 -ky -an $vg1
 UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
 aux disable_dev "$dev1"
 vgcreate $vg1 "$dev2"
-lvcreate -n ${lv1}_b -l1 -an $vg1
+lvcreate -n ${lv1}_b -l1 -ky -an $vg1
 UUID2=$(vgs --noheading -o vg_uuid $vg1 | xargs)
 aux enable_dev "$dev1"
 
@@ -178,15 +178,15 @@ aux wipefs_a "$dev2"
 # f. 2 local, 1 foreign
 # setup
 vgcreate $vg1 "$dev1"
-lvcreate -n $lv1 -l1 -an $vg1
+lvcreate -n $lv1 -l1 -ky -an $vg1
 UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
 aux disable_dev "$dev1"
 vgcreate $vg1 "$dev2"
-lvcreate -n ${lv1}_b -l1 -an $vg1
+lvcreate -n ${lv1}_b -l1 -ky -an $vg1
 UUID2=$(vgs --noheading -o vg_uuid $vg1 | xargs)
 aux disable_dev "$dev2"
 vgcreate $vg1 "$dev3"
-lvcreate -n $lv1 -l1 -an $vg1
+lvcreate -n $lv1 -l1 -ky -an $vg1
 UUID3=$(vgs --noheading -o vg_uuid $vg1 | xargs)
 vgchange -y --systemid "other" $vg1
 aux enable_dev "$dev1"
@@ -246,15 +246,15 @@ aux wipefs_a "$dev3"
 # g. 3 local, 0 foreign
 # setup
 vgcreate $vg1 "$dev1"
-lvcreate -n $lv1 -l1 -an $vg1
+lvcreate -n $lv1 -l1 -ky -an $vg1
 UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
 aux disable_dev "$dev1"
 vgcreate $vg1 "$dev2"
-lvcreate -n ${lv1}_b -l1 -an $vg1
+lvcreate -n ${lv1}_b -l1 -ky -an $vg1
 UUID2=$(vgs --noheading -o vg_uuid $vg1 | xargs)
 aux disable_dev "$dev2"
 vgcreate $vg1 "$dev3"
-lvcreate -n ${lv1}_c -l1 -an $vg1
+lvcreate -n ${lv1}_c -l1 -ky -an $vg1
 UUID3=$(vgs --noheading -o vg_uuid $vg1 | xargs)
 aux enable_dev "$dev1"
 aux enable_dev "$dev2"


