From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 18 Dec 2018 03:55:21 -0500
Subject: master - tests: Remove unsupported mirrored mirrorlog
Message-ID: <201812180855.wBI8tLFf020966@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=07fc4866f040a382c39577fb739e010734d83e42
Commit:        07fc4866f040a382c39577fb739e010734d83e42
Parent:        e82303fd6abc3ae43168f8032806c7c17d181a3e
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Dec 18 08:48:25 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Dec 18 09:54:42 2018 +0100

tests: Remove unsupported mirrored mirrorlog

---
 test/shell/lvconvert-mirror-basic.sh   |    8 +----
 test/shell/lvconvert-mirror.sh         |   12 -------
 test/shell/lvconvert-repair-replace.sh |   30 ------------------
 test/shell/lvconvert-repair.sh         |   11 -------
 test/shell/lvconvert-twostep.sh        |    6 ----
 test/shell/lvcreate-operation.sh       |   22 -------------
 test/shell/snapshots-of-mirrors.sh     |    9 -----
 test/shell/vgsplit-operation.sh        |   52 --------------------------------
 8 files changed, 2 insertions(+), 148 deletions(-)

diff --git a/test/shell/lvconvert-mirror-basic.sh b/test/shell/lvconvert-mirror-basic.sh
index 8166613..e295561 100644
--- a/test/shell/lvconvert-mirror-basic.sh
+++ b/test/shell/lvconvert-mirror-basic.sh
@@ -122,15 +122,11 @@ test_lvconvert() {
 aux prepare_vg 5 5
 get_devs
 
-MIRRORED="mirrored"
-# FIXME: Cluster is not supporting exlusive activation of mirrored log
-test -e LOCAL_CLVMD && MIRRORED=
-
 test_many() {
 	i=$1
 	for j in $(seq 0 3); do
-		for k in core disk $MIRRORED; do
-			for l in core disk $MIRRORED; do
+		for k in core disk; do
+			for l in core disk; do
 				if test "$i" -eq "$j" && test "$k" = "$l"; then continue; fi
 				: ----------------------------------------------------
 				: "Testing mirror conversion -m$i/$k -> -m$j/$l"
diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 7cf498d..a422557 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -243,18 +243,6 @@ not lvconvert --type mirror -m1 --corelog --stripes 2 $vg/$lv1
 lvremove -ff $vg
 
 
-# Linear to mirror with mirrored log using --alloc anywhere
-lvcreate -aey -l2 -n $lv1 $vg "$dev1"
-if test -e LOCAL_CLVMD; then
-# This is not supposed to work in cluster
-not lvconvert --type mirror -m +1 --mirrorlog mirrored --alloc anywhere $vg/$lv1 "$dev1" "$dev2"
-else
-lvconvert --type mirror -m +1 --mirrorlog mirrored --alloc anywhere $vg/$lv1 "$dev1" "$dev2"
-check mirror $vg $lv1
-fi
-lvremove -ff $vg
-
-
 if test -e LOCAL_CLVMD; then
 : # FIXME - cases which needs to be fixed to work in cluster
 else
diff --git a/test/shell/lvconvert-repair-replace.sh b/test/shell/lvconvert-repair-replace.sh
index 3cd1fac..cd17e0b 100644
--- a/test/shell/lvconvert-repair-replace.sh
+++ b/test/shell/lvconvert-repair-replace.sh
@@ -71,33 +71,3 @@ lvconvert -y --repair $vg/mirror2
 check mirror $vg mirror2
 vgs $vg
 vgremove -ff $vg
-
-if aux kernel_at_least 3 0 0; then
-	# 2-way, mirrored log
-	# Double log failure, full replace
-	vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
-	lvcreate -aey --mirrorlog mirrored --type mirror -m 1 --ignoremonitoring --nosync -L 1 -n 2way $vg \
-	    "$dev1" "$dev2" "$dev3":0 "$dev4":0
-	aux disable_dev "$dev3" "$dev4"
-	lvconvert -y --repair $vg/2way 2>&1 | tee 2way.out
-	lvs -a -o +devices $vg | not grep unknown
-	not grep "WARNING: Failed" 2way.out
-	vgreduce --removemissing $vg
-	check mirror $vg 2way
-	aux enable_dev "$dev3" "$dev4"
-	vgremove -ff $vg
-fi
-
-# 3-way, mirrored log
-# Single log failure, replace
-vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
-lvcreate -aey --mirrorlog mirrored --type mirror -m 2 --ignoremonitoring --nosync -L 1 -n 3way $vg \
-    "$dev1" "$dev2" "$dev3" "$dev4":0 "$dev5":0
-aux disable_dev "$dev4"
-lvconvert -y --repair $vg/3way 2>&1 | tee 3way.out
-lvs -a -o +devices $vg | not grep unknown
-not grep "WARNING: Failed" 3way.out
-vgreduce --removemissing $vg
-check mirror $vg 3way
-aux enable_dev "$dev4"
-vgremove -ff $vg
diff --git a/test/shell/lvconvert-repair.sh b/test/shell/lvconvert-repair.sh
index ae8fa7e..06470c4 100644
--- a/test/shell/lvconvert-repair.sh
+++ b/test/shell/lvconvert-repair.sh
@@ -69,17 +69,6 @@ _check_mlog
 vgreduce --removemissing $vg
 aux enable_dev "$dev4"
 
-# 3-way, mirrored log => 3-way, core log
-recreate_vg_
-lvcreate -aey --type mirror -m 2 --mirrorlog mirrored --ignoremonitoring -L 1 -n 3way $vg \
-    "$dev1" "$dev2" "$dev3" "$dev4":0 "$dev5":0
-aux disable_dev "$dev4" "$dev5"
-echo n | lvconvert --repair $vg/3way
-check mirror $vg 3way core
-_check_mlog
-vgreduce --removemissing $vg
-aux enable_dev "$dev4" "$dev5"
-
 # 2-way, disk log => 2-way, core log
 recreate_vg_
 lvcreate -aey --type mirror -m 1 --ignoremonitoring -L 1 -n 2way $vg "$dev1" "$dev2" "$dev3":0
diff --git a/test/shell/lvconvert-twostep.sh b/test/shell/lvconvert-twostep.sh
index afc9d47..7487d51 100644
--- a/test/shell/lvconvert-twostep.sh
+++ b/test/shell/lvconvert-twostep.sh
@@ -27,10 +27,4 @@ lvconvert --mirrorlog core $vg/mirror
 not lvconvert -m 1 --mirrorlog disk $vg/mirror "$dev3" 2>&1 | tee errs
 grep "two steps" errs
 
-if test ! -e LOCAL_CLVMD ; then
-# FIXME  mirrored unsupported in cluster
-not lvconvert -m 1 --mirrorlog mirrored $vg/mirror "$dev3" "$dev4" 2>&1 | tee errs
-grep "two steps" errs
-fi
-
 vgremove -ff $vg
diff --git a/test/shell/lvcreate-operation.sh b/test/shell/lvcreate-operation.sh
index 568af36..807f176 100644
--- a/test/shell/lvcreate-operation.sh
+++ b/test/shell/lvcreate-operation.sh
@@ -38,26 +38,4 @@ lvcreate -n$lv2 -l4 -s $vg/$lv1
 lvcreate -n$lv3 -l4 --permission r -s $vg/$lv1
 cleanup_lvs
 
-# Skip the rest for cluster
-if test -e LOCAL_CLVMD; then
-
-# ---
-# Create mirror on two devices with mirrored log using --alloc anywhere - should always fail in cluster
-not lvcreate --type mirror -m 1 -l4 -n $lv1 --mirrorlog mirrored $vg --alloc anywhere "$dev1" "$dev2"
-cleanup_lvs
-
-else
-
-# ---
-# Create mirror on two devices with mirrored log using --alloc anywhere
-lvcreate --type mirror -m 1 -l4 -n $lv1 --mirrorlog mirrored $vg --alloc anywhere "$dev1" "$dev2"
-cleanup_lvs
-
-# --
-# Create mirror on one dev with mirrored log using --alloc anywhere, should fail
-not lvcreate --type mirror -m 1 -l4 -n $lv1 --mirrorlog mirrored $vg --alloc anywhere "$dev1"
-cleanup_lvs
-
-fi
-
 vgremove -ff $vg
diff --git a/test/shell/snapshots-of-mirrors.sh b/test/shell/snapshots-of-mirrors.sh
index f2f2943..1f2c393 100644
--- a/test/shell/snapshots-of-mirrors.sh
+++ b/test/shell/snapshots-of-mirrors.sh
@@ -38,15 +38,6 @@ not lvconvert -m2 $vg/lv
 # Log conversion (disk -> core)
 lvconvert --mirrorlog core $vg/lv
 
-# Log conversion (core -> mirrored)
-# FIXME on cluster
-SHOULD=""
-test -e LOCAL_CLVMD && SHOULD=should
-$SHOULD lvconvert --mirrorlog mirrored $vg/lv
-
-# Log conversion (mirrored -> core)
-lvconvert --mirrorlog core $vg/lv
-
 # Log conversion (core -> disk)
 lvconvert --mirrorlog disk $vg/lv
 
diff --git a/test/shell/vgsplit-operation.sh b/test/shell/vgsplit-operation.sh
index eb24a58..36b75f5 100644
--- a/test/shell/vgsplit-operation.sh
+++ b/test/shell/vgsplit-operation.sh
@@ -122,58 +122,6 @@ COMM "vgsplit correctly splits mirror (log+leg on same dev) into $i VG ($j args)
 		lvremove -f $vg2/$lv1
 		vgremove -f $vg1 $vg2
 
-# Can't use mirrored log without cmirrord
-# TODO: Should work for inactive device, needs some fixes....
-if test ! -e LOCAL_CLVMD ; then
-COMM "vgsplit correctly splits mirror LV with mirrored log into $i VG ($j args)"
-		create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
-		test $i = existing && create_vg_ $vg2 "$dev5"
-
-		lvcreate -an -Zn -l 64 --mirrorlog mirrored --type mirror -m1 -n $lv1 $vg1 \
-		    "$dev1" "$dev2" "$dev3" "$dev4"
-
-		if [ $j = PV ]; then
-		  # FIXME: Not an exhaustive check of possible bad combinations
-		  not vgsplit $vg1 $vg2 "$dev1" "$dev2"
-		  not vgsplit $vg1 $vg2 "$dev3" "$dev4"
-		  not vgsplit $vg1 $vg2 "$dev1" "$dev3"
-		  not vgsplit $vg1 $vg2 "$dev2" "$dev4"
-		  vgsplit $vg1 $vg2 "$dev1" "$dev2" "$dev3" "$dev4"
-		else
-		  vgsplit -n $lv1 $vg1 $vg2
-		fi
-		if [ $i = existing ]; then
-		  check pvlv_counts $vg2 5 1 0
-		else
-		  check pvlv_counts $vg2 4 1 0
-		fi
-		lvremove -f $vg2/$lv1
-		vgremove -f $vg2
-
-# RHBZ 875903
-COMM "vgsplit correctly splits mirror LV with mirrored log on same devs into $i VG ($j args)"
-		create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
-		test $i = existing && create_vg_ $vg2 "$dev5"
-
-		lvcreate -an -Zn -l 64 --mirrorlog mirrored --type mirror -m1 -n $lv1 $vg1 \
-		    "$dev1" "$dev2"
-
-		if [ $j = PV ]; then
-		  not vgsplit $vg1 $vg2 "$dev1"
-		  not vgsplit $vg1 $vg2 "$dev2"
-		  vgsplit $vg1 $vg2 "$dev1" "$dev2"
-		else
-		  vgsplit -n $lv1 $vg1 $vg2
-		fi
-		if [ $i = existing ]; then
-		  check pvlv_counts $vg2 3 1 0
-		else
-		  check pvlv_counts $vg2 2 1 0
-		fi
-		lvremove -f $vg2/$lv1
-		vgremove -f $vg1 $vg2
-fi
-
 COMM "vgsplit correctly splits origin and snapshot LV into $i VG ($j args)"
 		create_vg_ $vg1 "$dev1" "$dev2"
 		test $i = existing && create_vg_ $vg2 "$dev3" "$dev4"


