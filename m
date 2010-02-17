From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 17 Feb 2010 11:57:38 -0600
Subject: [PATCH 12 of 13] LVM: testsuite additions for mirrored log
Message-ID: <201002171757.o1HHvccf005202@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-testsuite-additions-for-mirrored-log.patch

Testsuite additions for 'mirrored' log type.

Index: LVM2/test/t-snapshots-of-mirrors.sh
===================================================================
--- LVM2.orig/test/t-snapshots-of-mirrors.sh
+++ LVM2/test/t-snapshots-of-mirrors.sh
@@ -21,11 +21,11 @@ not lvconvert -m2 $vg/lv
 # Log conversion (disk -> core)
 lvconvert --mirrorlog core $vg/lv
 
-# Log conversion (core -> redundant)
-not lvconvert --mirrorlog redundant $vg/lv
+# Log conversion (core -> mirrored)
+lvconvert --mirrorlog mirrored $vg/lv
 
-# Log conversion (redundant -> core)
-# lvconvert --mirrorlog core $vg/lv
+# Log conversion (mirrored -> core)
+lvconvert --mirrorlog core $vg/lv
 
 # Log conversion (core -> disk)
 lvconvert --mirrorlog disk $vg/lv
Index: LVM2/test/t-mirror-lvconvert.sh
===================================================================
--- LVM2.orig/test/t-mirror-lvconvert.sh
+++ LVM2/test/t-mirror-lvconvert.sh
@@ -251,6 +251,38 @@ mirrorlog_is_on_ $vg/$lv1 $dev3 
 check_and_cleanup_lvs_
 
 # ---
+# core log to mirrored log
+
+# change the log type from 'core' to 'mirrored'
+prepare_lvs_
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
+check_mirror_count_ $vg/$lv1 2
+not_sh check_mirror_log_ $vg/$lv1
+lvconvert --mirrorlog mirrored -i1 $vg/$lv1 $dev3 $dev4
+check_no_tmplvs_ $vg/$lv1
+check_mirror_log_ $vg/$lv1
+mimages_are_redundant_ $vg $lv1
+
+# ---
+# mirrored log to core log
+
+# change the log type from 'mirrored' to 'core'
+lvconvert --mirrorlog core -i1 $vg/$lv1 $dev3 $dev4
+check_no_tmplvs_ $vg/$lv1
+not_sh check_mirror_log_ $vg/$lv1
+mimages_are_redundant_ $vg $lv1
+check_and_cleanup_lvs_
+
+# ---
+# Linear to mirror with mirrored log using --alloc anywhere
+prepare_lvs_
+lvcreate -l2 -n $lv1 $vg $dev1
+lvconvert -m +1 --mirrorlog mirrored $vg/$lv1 $dev1 $dev2 --alloc anywhere
+mimages_are_redundant_ $vg $lv1
+check_and_cleanup_lvs_
+
+
+# ---
 # check polldaemon restarts
 
 # convert inactive mirror and start polling
Index: LVM2/test/t-lvcreate-operation.sh
===================================================================
--- LVM2.orig/test/t-lvcreate-operation.sh
+++ LVM2/test/t-lvcreate-operation.sh
@@ -25,9 +25,18 @@ aux prepare_pvs 2
 aux pvcreate --metadatacopies 0 $dev1
 aux vgcreate -c n $vg $devs
 
-#COMM create snapshots of LVs on --metadatacopies 0 PV (bz450651)
+# ---
+# Create snapshots of LVs on --metadatacopies 0 PV (bz450651)
 lvcreate -n$lv1 -l4 $vg $dev1
 lvcreate -n$lv2 -l4 -s $vg/$lv1
-#lvremove -f $vg/$lv2
 cleanup_lvs
 
+# ---
+# Create mirror on two devices with mirrored log using --alloc anywhere
+lvcreate -m 1 -l4 -n $lv1 --mirrorlog mirrored $vg --alloc anywhere $dev1 $dev2
+cleanup_lvs
+
+# --
+# Create mirror on one dev with mirrored log using --alloc anywhere, should fail
+lvcreate -m 1 -l4 -n $lv1 --mirrorlog mirrored $vg --alloc anywhere $dev1
+cleanup_lvs


