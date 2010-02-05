From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 5 Feb 2010 14:37:05 -0600
Subject: [PATCH 12 of 12] LVM: testsuite additions for mirrored log
Message-ID: <201002052037.o15Kb56h017031@hydrogen.msp.redhat.com>
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
@@ -251,6 +251,29 @@ mirrorlog_is_on_ $vg/$lv1 $dev3 
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
 # check polldaemon restarts
 
 # convert inactive mirror and start polling


