From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 10 Jan 2011 14:56:59 -0600
Subject: [PATCH 4 of 4] LVM: mirrored log testing
Message-ID: <201101102056.p0AKuxIZ012109@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-mirrored-log-testing.patch

This patch updates the mirror conversion tests to include
converting mirror logs from disk -> mirrored.

Index: LVM2/test/t-lvconvert-mirror-basic.sh
===================================================================
--- LVM2.orig/test/t-lvconvert-mirror-basic.sh
+++ LVM2/test/t-lvconvert-mirror-basic.sh
@@ -54,12 +54,6 @@ test_lvconvert()
 	local active=true
 	local i
 
-	if [ "$start_log_type" = "disk" ] &&
-		[ "$finish_log_type" = "mirrored" ]; then
-		echo "FIXME:  disk -> mirrored log conversion not yet supported by LVM"
-		return 0
-	fi
-
 	test "$5" = "active" && active=false
 	#test $finish_count -gt $start_count && up=true
 
Index: LVM2/test/t-lvconvert-repair-replace.sh
===================================================================
--- LVM2.orig/test/t-lvconvert-repair-replace.sh
+++ LVM2/test/t-lvconvert-repair-replace.sh
@@ -13,6 +13,7 @@
 
 aux prepare_vg 6
 
+# 3-way, disk log
 # multiple failures, full replace
 lvcreate --mirrorlog disk -m 2 --ig -L 1 -n 3way $vg $dev1 $dev2 $dev3 $dev4:0-1
 aux disable_dev $dev1 $dev2
@@ -23,8 +24,37 @@ vgreduce --removemissing $vg
 check mirror $vg 3way
 aux enable_dev $dev1 $dev2
 
+vgremove -ff $vg; vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4 $dev5 $dev6
+
+# 2-way, mirrored log
+# Double log failure, full replace
+lvcreate --mirrorlog mirrored -m 1 --ig -L 1 -n 2way $vg \
+    $dev1 $dev2 $dev3:0 $dev4:0
+aux disable_dev $dev3 $dev4
+echo y | lvconvert --repair $vg/2way 2>&1 | tee 2way.out
+lvs -a -o +devices | not grep unknown
+not grep "WARNING: Failed" 2way.out
+vgreduce --removemissing $vg
+check mirror $vg 2way
+aux enable_dev $dev3 $dev4
+
+vgremove -ff $vg; vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4 $dev5 $dev6
+
+# 3-way, mirrored log
+# Single log failure, replace
+lvcreate --mirrorlog mirrored -m 2 --ig -L 1 -n 3way $vg \
+    $dev1 $dev2 $dev3 $dev4:0 $dev5:0
+aux disable_dev $dev4
+echo y | lvconvert --repair $vg/3way 2>&1 | tee 3way.out
+lvs -a -o +devices | not grep unknown
+not grep "WARNING: Failed" 3way.out
+vgreduce --removemissing $vg
+check mirror $vg 3way
+aux enable_dev $dev4
+
 vgremove -ff $vg; vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4 $dev5
 
+# 3-way, disk log
 # multiple failures, partial replace
 lvcreate --mirrorlog disk -m 2 --ig -L 1 -n 3way $vg $dev1 $dev2 $dev3 $dev4
 aux disable_dev $dev1 $dev2
Index: LVM2/test/t-lvconvert-repair.sh
===================================================================
--- LVM2.orig/test/t-lvconvert-repair.sh
+++ LVM2/test/t-lvconvert-repair.sh
@@ -14,6 +14,7 @@
 
 # fail multiple devices
 
+# 4-way, disk log => 2-way, disk log
 aux prepare_vg 5
 lvcreate -m 3 --ig -L 1 -n 4way $vg $dev1 $dev2 $dev3 $dev4 $dev5:0
 aux disable_dev $dev2 $dev4
@@ -23,6 +24,7 @@ vgreduce --removemissing $vg
 aux enable_dev $dev2 $dev4
 check mirror $vg 4way $dev5
 
+# 3-way, disk log => linear
 aux prepare_vg 5
 lvcreate -m 2 --ig -L 1 -n 3way $vg
 aux disable_dev $dev1 $dev2
@@ -37,6 +39,7 @@ check linear $vg 3way
 
 # fail just log and get it removed
 
+# 3-way, disk log => 3-way, core log
 aux prepare_vg 5
 lvcreate -m 2 --ig -L 1 -n 3way $vg $dev1 $dev2 $dev3 $dev4:0
 aux disable_dev $dev4
@@ -48,6 +51,20 @@ dmsetup ls | grep $PREFIX | not grep mlo
 vgreduce --removemissing $vg
 aux enable_dev $dev4
 
+# 3-way, mirrored log => 3-way, core log
+aux prepare_vg 5
+lvcreate -m 2 --mirrorlog mirrored --ig -L 1 -n 3way $vg \
+    $dev1 $dev2 $dev3 $dev4:0 $dev5:0
+aux disable_dev $dev4 $dev5
+echo n | lvconvert --repair $vg/3way
+check mirror $vg 3way core
+lvs -a -o +devices | not grep unknown
+lvs -a -o +devices | not grep mlog
+dmsetup ls | grep $PREFIX | not grep mlog
+vgreduce --removemissing $vg
+aux enable_dev $dev4 $dev5
+
+# 2-way, disk log => 2-way, core log
 aux prepare_vg 5
 lvcreate -m 1 --ig -L 1 -n 2way $vg $dev1 $dev2 $dev3:0
 aux disable_dev $dev3
Index: LVM2/test/t-lvconvert-twostep.sh
===================================================================
--- LVM2.orig/test/t-lvconvert-twostep.sh
+++ LVM2/test/t-lvconvert-twostep.sh
@@ -12,10 +12,15 @@
 . lib/test
 
 aux prepare_vg 4
+
 lvcreate -m 1 --mirrorlog disk --ig -L 1 -n mirror $vg
 not lvconvert -m 2 --mirrorlog core $vg/mirror $dev3 2>&1 | tee errs
 grep "two steps" errs
+
 lvconvert -m 2 $vg/mirror $dev3
 lvconvert --mirrorlog core $vg/mirror
 not lvconvert -m 1 --mirrorlog disk $vg/mirror $dev3 2>&1 | tee errs
 grep "two steps" errs
+
+not lvconvert -m 1 --mirrorlog mirrored $vg/mirror $dev3 $dev4 2>&1 | tee errs
+grep "two steps" errs


