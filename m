From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Jun 2013 22:16:36 +0000 (UTC)
Subject: master - tests: more test run in cluster mode
Message-ID: <20130615221636.1ED0260D69@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=362d8ead64baa4ca520a8b39db99d223a7b54a2c
Commit:        362d8ead64baa4ca520a8b39db99d223a7b54a2c
Parent:        5d73c0c674502bc1cf4962ee958511adf53fd720
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 15 11:21:03 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 16 00:07:33 2013 +0200

tests: more test run in cluster mode

aux updates:

prepare_vg now created clustered VG for cluster tests.

since dm-raid doesn't work in cluster, skip the cluster
test when someone checks for dm-raid target until fixed.
---
 test/lib/aux.sh                                   |    5 +-
 test/shell/activate-missing.sh                    |   12 ++--
 test/shell/activate-partial.sh                    |    8 +-
 test/shell/dmeventd-restart.sh                    |    4 +-
 test/shell/inconsistent-metadata.sh               |   18 ++----
 test/shell/lvchange-mirror.sh                     |    8 ++-
 test/shell/lvchange-raid.sh                       |    3 +
 test/shell/lvconvert-repair-dmeventd.sh           |    2 +-
 test/shell/lvconvert-repair-policy.sh             |    8 +-
 test/shell/lvconvert-repair-raid.sh               |    1 -
 test/shell/lvconvert-repair-replace.sh            |   12 ++--
 test/shell/lvconvert-repair-snapshot.sh           |    2 +-
 test/shell/lvconvert-repair-transient-dmeventd.sh |   11 ++-
 test/shell/lvconvert-repair-transient.sh          |    5 +-
 test/shell/lvconvert-repair.sh                    |   25 +++++----
 test/shell/lvconvert-twostep.sh                   |    4 +-
 test/shell/lvcreate-mirror.sh                     |   27 ++++-----
 test/shell/lvcreate-raid.sh                       |    2 -
 test/shell/lvcreate-raid10.sh                     |    9 +--
 test/shell/lvcreate-striped-mirror.sh             |   48 ++++++----------
 test/shell/lvextend-percent-extents.sh            |    5 +-
 test/shell/lvextend-snapshot-dmeventd.sh          |    2 +-
 test/shell/lvextend-snapshot-policy.sh            |    4 +-
 test/shell/lvresize-mirror.sh                     |   44 ++++++++-------
 test/shell/lvresize-raid.sh                       |   51 +++--------------
 test/shell/lvresize-raid10.sh                     |   17 +-----
 test/shell/lvresize-rounding.sh                   |   18 +++---
 test/shell/lvresize-thin-metadata.sh              |   15 +++--
 test/shell/mirror-names.sh                        |   10 ++--
 test/shell/mirror-vgreduce-removemissing.sh       |   63 ++++++++-------------
 test/shell/nomda-restoremissing.sh                |    6 +-
 test/shell/snapshot-autoumount-dmeventd.sh        |    6 +-
 test/shell/snapshot-merge.sh                      |    8 +-
 test/shell/snapshots-of-mirrors.sh                |    6 +-
 test/shell/snapshots-usage.sh                     |    3 +-
 test/shell/unknown-segment.sh                     |    6 +-
 test/shell/unlost-pv.sh                           |    4 +-
 test/shell/vgextend-restoremissing.sh             |    7 +-
 test/shell/vgsplit-operation.sh                   |   38 +++++--------
 39 files changed, 231 insertions(+), 296 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index dc8a823..f481db5 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -445,7 +445,7 @@ prepare_vg() {
 	teardown_devs
 
 	prepare_pvs "$@"
-	vgcreate -c n $vg $devs
+	vgcreate -s 512K $vg $devs
 }
 
 extend_filter() {
@@ -583,6 +583,9 @@ wait_for_sync() {
 # i.e.   dm_target_at_least  dm-thin-pool  1 0
 target_at_least()
 {
+	# Raid target does not work in cluster
+	test -e LOCAL_CLVMD -a "$1" = "dm-raid" && return 1
+
 	case "$1" in
 	  dm-*) modprobe "$1" || true ;;
 	esac
diff --git a/test/shell/activate-missing.sh b/test/shell/activate-missing.sh
index 4676ee1..8f5a949 100644
--- a/test/shell/activate-missing.sh
+++ b/test/shell/activate-missing.sh
@@ -24,11 +24,11 @@ lvcreate -l1 -n linear1 $vg "$dev1"
 lvcreate -l1 -n linear2 $vg "$dev2"
 lvcreate -l2 -n linear12 $vg "$dev1":4 "$dev2":4
 
-lvcreate -l1 -n origin1 $vg "$dev1"
+lvcreate -aey -l1 -n origin1 $vg "$dev1"
 lvcreate -s $vg/origin1 -l1 -n s_napshot2 "$dev2"
 
-lvcreate -l1 -m1 -n mirror12 --mirrorlog core $vg "$dev1" "$dev2"
-lvcreate -l1 -m1 -n mirror123 $vg "$dev1" "$dev2" "$dev3"
+lvcreate -aey -l1 -m1 -n mirror12 --mirrorlog core $vg "$dev1" "$dev2"
+lvcreate -aey -l1 -m1 -n mirror123 $vg "$dev1" "$dev2" "$dev3"
 
 vgchange -a n $vg
 aux disable_dev "$dev1"
@@ -46,7 +46,7 @@ check inactive $vg mirror123
 vgchange -a n $vg
 aux enable_dev "$dev1"
 aux disable_dev "$dev2"
-not vgchange -a y $vg
+not vgchange -aey $vg
 not vgck $vg
 
 check active $vg linear1
@@ -60,7 +60,7 @@ check inactive $vg mirror123
 vgchange -a n $vg
 aux enable_dev "$dev2"
 aux disable_dev "$dev3"
-not vgchange -a y $vg
+not vgchange -aey $vg
 not vgck $vg
 
 check active $vg origin1
@@ -74,7 +74,7 @@ check active $vg mirror12
 vgchange -a n $vg
 aux enable_dev "$dev3"
 aux disable_dev "$dev4"
-vgchange -a y $vg
+vgchange -aey $vg
 not vgck $vg
 
 check active $vg origin1
diff --git a/test/shell/activate-partial.sh b/test/shell/activate-partial.sh
index 4a06fc1..bc01f72 100644
--- a/test/shell/activate-partial.sh
+++ b/test/shell/activate-partial.sh
@@ -13,19 +13,19 @@
 
 aux prepare_vg 3
 
-lvcreate -m 1 -l 1 -n mirror $vg
+lvcreate -aey -m 1 -l 1 --nosync -n mirror $vg
 lvchange -a n $vg/mirror
 aux disable_dev "$dev1"
 
 not vgreduce --removemissing $vg
-not lvchange -v -a y $vg/mirror
-lvchange -v --partial -a y $vg/mirror
+not lvchange -v -aey $vg/mirror
+lvchange -v --partial -aey $vg/mirror
 not lvchange -v --refresh $vg/mirror
 lvchange -v --refresh --partial $vg/mirror
 
 # also check that vgchange works
 vgchange -a n --partial $vg
-vgchange -a y --partial $vg
+vgchange -aey --partial $vg
 
 # check vgremove
 vgremove -f $vg
diff --git a/test/shell/dmeventd-restart.sh b/test/shell/dmeventd-restart.sh
index fa9db46..726f97f 100644
--- a/test/shell/dmeventd-restart.sh
+++ b/test/shell/dmeventd-restart.sh
@@ -15,9 +15,9 @@ aux prepare_dmeventd
 
 aux prepare_vg 5
 
-lvcreate -m 3 --ig -L 1 -n 4way $vg
+lvcreate -aey -m 3 --nosync --ig -l1 -n 4way $vg
 lvchange --monitor y $vg/4way
-lvcreate -m 2 --ig -L 1 -n 3way $vg
+lvcreate -aey -m 2 --nosync --ig -l1 -n 3way $vg
 lvchange --monitor y $vg/3way
 
 dmeventd -R -f &
diff --git a/test/shell/inconsistent-metadata.sh b/test/shell/inconsistent-metadata.sh
index 4894861..7cf177a 100644
--- a/test/shell/inconsistent-metadata.sh
+++ b/test/shell/inconsistent-metadata.sh
@@ -13,7 +13,7 @@
 
 aux prepare_vg 3 12
 
-lvcreate -m 1 -l 1 -n mirror $vg
+lvcreate -aye -m 1 -l 1 -n mirror $vg
 lvcreate -l 1 -n resized $vg
 lvchange -a n $vg/mirror
 
@@ -21,17 +21,11 @@ aux backup_dev $(cat DEVICES)
 
 init() {
 	aux restore_dev $(cat DEVICES)
-	lvs -o lv_name,lv_size --units k $vg | tee lvs.out
-	grep resized lvs.out | not grep 8192
+	not check lv_field $vg/resized lv_size "8.00m"
 	lvresize -L 8192K $vg/resized
 	aux restore_dev "$dev1"
 }
 
-check() {
-	lvs -o lv_name,lv_size --units k $vg | tee lvs.out
-	grep resized lvs.out | grep 8192
-}
-
 # vgscan fixes up metadata (needs --cache option for direct scan if lvmetad is used)
 test -e LOCAL_LVMETAD && cache="--cache"
 init
@@ -40,7 +34,7 @@ grep "Inconsistent metadata found for VG $vg" cmd.out
 test -e LOCAL_LVMETAD && vgrename $vg foo && vgrename foo $vg # trigger a write
 vgscan $cache 2>&1 | tee cmd.out
 not grep "Inconsistent metadata found for VG $vg" cmd.out
-check
+check lv_field $vg/resized lv_size "8.00m"
 
 # only vgscan would have noticed metadata inconsistencies when lvmetad is active
 if test ! -e LOCAL_LVMETAD; then
@@ -50,7 +44,7 @@ if test ! -e LOCAL_LVMETAD; then
 	grep "Inconsistent metadata found for VG $vg" cmd.out
 	vgdisplay $vg 2>&1 | tee cmd.out
 	not grep "Inconsistent metadata found for VG $vg" cmd.out
-	check
+	check lv_field $vg/resized lv_size "8.00m"
 
 	# lvs fixes up
 	init
@@ -58,7 +52,7 @@ if test ! -e LOCAL_LVMETAD; then
 	grep "Inconsistent metadata found for VG $vg" cmd.out
 	vgdisplay $vg 2>&1 | tee cmd.out
 	not grep "Inconsistent metadata found for VG $vg" cmd.out
-	check
+	check lv_field $vg/resized lv_size "8.00m"
 
 	# vgs fixes up as well
 	init
@@ -66,7 +60,7 @@ if test ! -e LOCAL_LVMETAD; then
 	grep "Inconsistent metadata found for VG $vg" cmd.out
 	vgs $vg 2>&1 | tee cmd.out
 	not grep "Inconsistent metadata found for VG $vg" cmd.out
-	check
+	check lv_field $vg/resized lv_size "8.00m"
 fi
 
 echo Check auto-repair of failed vgextend - metadata written to original pv but not new pv
diff --git a/test/shell/lvchange-mirror.sh b/test/shell/lvchange-mirror.sh
index 9f4d190..7036210 100644
--- a/test/shell/lvchange-mirror.sh
+++ b/test/shell/lvchange-mirror.sh
@@ -11,18 +11,22 @@
 
 . lib/test
 
+# FIXME RESYNC doesn't work in cluster with exclusive activation
+# seriously broken!
+test -e LOCAL_CLVMD && skip
+
 aux prepare_dmeventd
 aux prepare_vg 3
 
 # force resync 2-way active mirror
-lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1
+lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1
 check mirror $vg $lv1 "$dev3"
 lvchange -y --resync $vg/$lv1
 check mirror $vg $lv1 "$dev3"
 lvremove -ff $vg
 
 # force resync 2-way inactive mirror
-lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1
+lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1
 lvchange -an $vg/$lv1
 check mirror $vg $lv1 "$dev3"
 lvchange --resync $vg/$lv1
diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 0ef00b3..b331961 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -139,7 +139,10 @@ run_syncaction_check() {
 
 		# Run "check" should turn up clean
 		lvchange --syncaction check $1/$2
+		aux wait_for_sync $1 $2
+		sync
 	fi
+
 	lvs --noheadings -o lv_attr $1/$2 | grep '.*-$'
 	[ `lvs --noheadings -o mismatches $1/$2` == 0 ]
 
diff --git a/test/shell/lvconvert-repair-dmeventd.sh b/test/shell/lvconvert-repair-dmeventd.sh
index 66e4cc8..a1a1669 100644
--- a/test/shell/lvconvert-repair-dmeventd.sh
+++ b/test/shell/lvconvert-repair-dmeventd.sh
@@ -16,7 +16,7 @@ which mkfs.ext2 || skip
 aux prepare_vg 5
 aux prepare_dmeventd
 
-lvcreate -m 3 --ig -L 1 -n 4way $vg
+lvcreate -aey -m 3 --ig -L 1 -n 4way $vg
 lvchange --monitor y $vg/4way
 aux disable_dev "$dev2" "$dev4"
 mkfs.ext2 $DM_DEV_DIR/$vg/4way
diff --git a/test/shell/lvconvert-repair-policy.sh b/test/shell/lvconvert-repair-policy.sh
index e595d34..8c60e94 100644
--- a/test/shell/lvconvert-repair-policy.sh
+++ b/test/shell/lvconvert-repair-policy.sh
@@ -23,19 +23,19 @@ cleanup() {
 	for d in "$@"; do aux enable_dev "$d"; done
 	for d in "$@"; do vgextend $vg "$d"; done
 	lvremove -ff $vg/mirror
-	lvcreate -m 1 --ig -l 2 -n mirror $vg "$dev1" "$dev2" "$dev3":0
+	lvcreate -aey -m 1 --ig -l 2 -n mirror $vg "$dev1" "$dev2" "$dev3":0
 }
 
 repair() {
 	lvconvert --repair --use-policies --config "$1" $vg/mirror
 }
 
-lvcreate -m 1 -L 1 -n mirror $vg
+lvcreate -aey -m 1 -L 1 -n mirror $vg
 lvchange -a n $vg/mirror
 
 # Fail a leg of a mirror.
 aux disable_dev "$dev1"
-lvchange --partial -a y $vg/mirror
+lvchange --partial -aey $vg/mirror
 repair 'activation { mirror_image_fault_policy = "remove" }'
 check linear $vg mirror
 cleanup "$dev1"
@@ -83,7 +83,7 @@ cleanup "$dev3" "$dev4"
 
 # Fail the log device with a remove policy
 # Expected result: mirror w/ corelog
-lvchange -a y $vg/mirror
+lvchange -aey $vg/mirror
 aux disable_dev "$dev3" "$dev4"
 repair 'activation { mirror_log_fault_policy = "remove" }'
 check mirror $vg mirror core
diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index 31d5116..84e247d 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -11,7 +11,6 @@
 
 . lib/test
 
-test -e LOCAL_CLVMD && skip
 aux target_at_least dm-raid 1 1 0 || skip
 
 aux lvmconf 'allocation/maximise_cling = 0'
diff --git a/test/shell/lvconvert-repair-replace.sh b/test/shell/lvconvert-repair-replace.sh
index 73235a4..4ef3687 100644
--- a/test/shell/lvconvert-repair-replace.sh
+++ b/test/shell/lvconvert-repair-replace.sh
@@ -17,7 +17,7 @@ aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 
 # 3-way, disk log
 # multiple failures, full replace
-lvcreate --mirrorlog disk -m 2 --ig -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4":0-1
+lvcreate -aey --mirrorlog disk -m 2 --ig --nosync -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4":0-1
 aux disable_dev "$dev1" "$dev2"
 lvconvert -y --repair $vg/3way 2>&1 | tee 3way.out
 lvs -a -o +devices $vg | not grep unknown
@@ -30,7 +30,7 @@ vgremove -ff $vg
 # 3-way, disk log
 # multiple failures, partial replace
 vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
-lvcreate -aey --mirrorlog disk -m 2 --ig -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4"
+lvcreate -aey --mirrorlog disk -m 2 --ig --nosync -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4"
 aux disable_dev "$dev1" "$dev2"
 lvconvert -y --repair $vg/3way 2>&1 | tee 3way.out
 grep "WARNING: Failed" 3way.out
@@ -41,7 +41,7 @@ aux enable_dev "$dev1" "$dev2"
 vgremove -ff $vg
 
 vgcreate $vg "$dev1" "$dev2" "$dev3"
-lvcreate -aey --mirrorlog disk -m 1 --ig -L 1 -n 2way $vg "$dev1" "$dev2" "$dev3"
+lvcreate -aey --mirrorlog disk -m 1 --ig --nosync -l 1 -n 2way $vg "$dev1" "$dev2" "$dev3"
 aux disable_dev "$dev1"
 lvconvert -y --repair $vg/2way 2>&1 | tee 2way.out
 grep "WARNING: Failed" 2way.out
@@ -54,7 +54,7 @@ vgremove -ff $vg
 # Test repair of inactive mirror with log failure
 #  Replacement should fail, but convert should succeed (switch to corelog)
 vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4"
-lvcreate -aey -m 2 --ig -l 2 -n mirror2 $vg "$dev1" "$dev2" "$dev3" "$dev4":0
+lvcreate -aey -m 2 --ig --nosync -l 2 -n mirror2 $vg "$dev1" "$dev2" "$dev3" "$dev4":0
 vgchange -a n $vg
 pvremove -ff -y "$dev4"
 lvconvert -y --repair $vg/mirror2
@@ -69,7 +69,7 @@ if kernel_at_least 3 0 0; then
 	# 2-way, mirrored log
 	# Double log failure, full replace
 	vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
-	lvcreate -aey --mirrorlog mirrored -m 1 --ig -L 1 -n 2way $vg \
+	lvcreate -aey --mirrorlog mirrored -m 1 --ig --nosync -L 1 -n 2way $vg \
 	    "$dev1" "$dev2" "$dev3":0 "$dev4":0
 	aux disable_dev "$dev3" "$dev4"
 	lvconvert -y --repair $vg/2way 2>&1 | tee 2way.out
@@ -84,7 +84,7 @@ fi
 # 3-way, mirrored log
 # Single log failure, replace
 vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
-lvcreate -aey --mirrorlog mirrored -m 2 --ig -L 1 -n 3way $vg \
+lvcreate -aey --mirrorlog mirrored -m 2 --ig --nosync -L 1 -n 3way $vg \
     "$dev1" "$dev2" "$dev3" "$dev4":0 "$dev5":0
 aux disable_dev "$dev4"
 lvconvert -y --repair $vg/3way 2>&1 | tee 3way.out
diff --git a/test/shell/lvconvert-repair-snapshot.sh b/test/shell/lvconvert-repair-snapshot.sh
index 786b950..5c47be8 100644
--- a/test/shell/lvconvert-repair-snapshot.sh
+++ b/test/shell/lvconvert-repair-snapshot.sh
@@ -15,7 +15,7 @@ aux prepare_vg 5
 aux lvmconf 'allocation/maximise_cling = 0'
 aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 
-lvcreate -m 3 --ig -L 2M -n 4way $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5":0
+lvcreate -aey -m 3 --ig -L 2M -n 4way $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5":0
 lvcreate -s $vg/4way -L 2M -n snap
 
 aux disable_dev "$dev2" "$dev4"
diff --git a/test/shell/lvconvert-repair-transient-dmeventd.sh b/test/shell/lvconvert-repair-transient-dmeventd.sh
index ac687eb..8d1a2f1 100644
--- a/test/shell/lvconvert-repair-transient-dmeventd.sh
+++ b/test/shell/lvconvert-repair-transient-dmeventd.sh
@@ -14,16 +14,19 @@
 aux prepare_vg 5
 aux prepare_dmeventd
 
-lvcreate -m 3 --ig -L 1 -n 4way $vg
+lvcreate -aey -m 3 --ig -L 1 -n 4way $vg
 lvchange --monitor y $vg/4way
 aux disable_dev "$dev2" "$dev4"
 mkfs.ext3 $DM_DEV_DIR/$vg/4way
 aux enable_dev "$dev2" "$dev4"
 sleep 3
-lvs -a -o +devices $vg | not grep unknown
+lvs -a -o +devices $vg | tee out
+not grep unknown out
 check mirror $vg 4way
 check mirror_legs $vg 4way 2
-lvs -a -o +devices $vg | not grep mimage_1
-lvs -a -o +devices $vg | not grep mimage_3
+lvs -a -o +devices $vg | tee out
+not grep mimage_1 out
+lvs -a -o +devices $vg | tee out
+not grep mimage_3 out
 
 vgremove -f $vg
diff --git a/test/shell/lvconvert-repair-transient.sh b/test/shell/lvconvert-repair-transient.sh
index beacf89..58d4889 100644
--- a/test/shell/lvconvert-repair-transient.sh
+++ b/test/shell/lvconvert-repair-transient.sh
@@ -13,13 +13,14 @@
 
 aux prepare_vg 5
 
-lvcreate -m 3 --ig -L 1 -n 4way $vg
+lvcreate -aey -m 3 --ig -L 1 -n 4way $vg
 aux disable_dev "$dev2" "$dev4"
 mkfs.ext3 $DM_DEV_DIR/$vg/4way &
 sleep 1
 aux enable_dev "$dev2" "$dev4"
 echo n | lvconvert --repair $vg/4way 2>&1 | tee 4way.out
-lvs -a -o +devices | not grep unknown
+lvs -a -o +devices | tee out
+not grep unknown out
 vgreduce --removemissing $vg
 check mirror $vg 4way
 lvchange -a n $vg/4way
diff --git a/test/shell/lvconvert-repair.sh b/test/shell/lvconvert-repair.sh
index 57ba8a5..37c3b00 100644
--- a/test/shell/lvconvert-repair.sh
+++ b/test/shell/lvconvert-repair.sh
@@ -17,6 +17,15 @@ recreate_vg_()
 	vgcreate $vg "$@" $(cat DEVICES)
 }
 
+_check_mlog()
+{
+	lvs -a -o +devices $vg | tee out
+	not grep unknown out
+	not grep mlog out
+	dmsetup ls | grep $PREFIX | tee out
+	not grep mlog out
+}
+
 aux lvmconf 'allocation/maximise_cling = 0'
 aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 
@@ -38,9 +47,7 @@ lvcreate -aey -m 2 --ig -L 1 -n 3way $vg
 aux disable_dev "$dev1" "$dev2"
 echo n | lvconvert --repair $vg/3way
 check linear $vg 3way
-lvs -a -o +devices $vg | not grep unknown
-lvs -a -o +devices $vg | not grep mlog
-dmsetup ls | grep $PREFIX | not grep mlog
+_check_mlog
 vgreduce --removemissing $vg
 aux enable_dev "$dev1" "$dev2"
 check linear $vg 3way
@@ -53,9 +60,7 @@ lvcreate -aey -m 2 --ig -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4":0
 aux disable_dev "$dev4"
 echo n | lvconvert --repair $vg/3way
 check mirror $vg 3way core
-lvs -a -o +devices $vg | not grep unknown
-lvs -a -o +devices $vg | not grep mlog
-dmsetup ls | grep $PREFIX | not grep mlog
+_check_mlog
 vgreduce --removemissing $vg
 aux enable_dev "$dev4"
 
@@ -66,9 +71,7 @@ lvcreate -aey -m 2 --mirrorlog mirrored --ig -L 1 -n 3way $vg \
 aux disable_dev "$dev4" "$dev5"
 echo n | lvconvert --repair $vg/3way
 check mirror $vg 3way core
-lvs -a -o +devices $vg | not grep unknown
-lvs -a -o +devices $vg | not grep mlog
-dmsetup ls | grep $PREFIX | not grep mlog
+_check_mlog
 vgreduce --removemissing $vg
 aux enable_dev "$dev4" "$dev5"
 
@@ -78,8 +81,7 @@ lvcreate -aey -m 1 --ig -L 1 -n 2way $vg "$dev1" "$dev2" "$dev3":0
 aux disable_dev "$dev3"
 echo n | lvconvert --repair $vg/2way
 check mirror $vg 2way core
-lvs -a -o +devices $vg | not grep unknown
-lvs -a -o +devices $vg | not grep mlog
+_check_mlog
 vgreduce --removemissing $vg
 aux enable_dev "$dev3"
 
@@ -111,4 +113,5 @@ lvconvert -y --repair $vg/mirror
 vgreduce --removemissing $vg
 aux enable_dev "$dev3"
 vgextend $vg "$dev3"
+
 vgremove -ff $vg
diff --git a/test/shell/lvconvert-twostep.sh b/test/shell/lvconvert-twostep.sh
index c45e7bc..08a26b0 100644
--- a/test/shell/lvconvert-twostep.sh
+++ b/test/shell/lvconvert-twostep.sh
@@ -13,7 +13,7 @@
 
 aux prepare_vg 4
 
-lvcreate -m 1 --mirrorlog disk --ig -L 1 -n mirror $vg
+lvcreate -aey -m 1 --mirrorlog disk --ig -L 1 -n mirror $vg
 not lvconvert -m 2 --mirrorlog core $vg/mirror "$dev3" 2>&1 | tee errs
 grep "two steps" errs
 
@@ -22,5 +22,7 @@ lvconvert --mirrorlog core $vg/mirror
 not lvconvert -m 1 --mirrorlog disk $vg/mirror "$dev3" 2>&1 | tee errs
 grep "two steps" errs
 
+test -e LOCAL_CLVMD && exit 0
+# FIXME  mirrored unsupported in cluster
 not lvconvert -m 1 --mirrorlog mirrored $vg/mirror "$dev3" "$dev4" 2>&1 | tee errs
 grep "two steps" errs
diff --git a/test/shell/lvcreate-mirror.sh b/test/shell/lvcreate-mirror.sh
index 1f95387..c286445 100644
--- a/test/shell/lvcreate-mirror.sh
+++ b/test/shell/lvcreate-mirror.sh
@@ -15,27 +15,22 @@ aux lvmconf 'allocation/maximise_cling = 0'
 aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 
 # 2-way mirror with corelog, 2 PVs
-lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
+lvcreate -aey -l2 -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
 check mirror_images_redundant $vg $lv1
-lvremove -ff $vg
 
 # 2-way mirror with disklog, 3 PVs
-lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1
-check mirror_images_redundant $vg $lv1
-check mirror_log_on $vg $lv1 "$dev3"
-lvremove -ff $vg
-
-# 3-way mirror with disklog, 4 PVs
-lvcreate -l2 -m2 --mirrorlog disk -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3":0-1
-check mirror_images_redundant $vg $lv1
-check mirror_log_on $vg $lv1 "$dev3"
-lvremove -ff $vg
-
 # lvcreate --nosync is in 100% sync after creation (bz429342)
-lvcreate -l2 -m1 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1 2>out
+lvcreate -aey -l2 -m1 --nosync -n $lv2 $vg "$dev1" "$dev2" "$dev3":0-1 2>&1 | tee out
 grep "New mirror won't be synchronised." out
-lvs -o copy_percent --noheadings $vg/$lv1 | grep 100.00
+check lv_field $vg/$lv2 copy_percent "100.00"
+check mirror_images_redundant $vg $lv2
+check mirror_log_on $vg $lv2 "$dev3"
+
+# 3-way mirror with disklog, 4 PVs
+lvcreate -aey -l2 -m2 --nosync --mirrorlog disk -n $lv3 $vg "$dev1" "$dev2" "$dev4" "$dev3":0-1
+check mirror_images_redundant $vg $lv3
+check mirror_log_on $vg $lv3 "$dev3"
 lvremove -ff $vg
 
 # creating 2-way mirror with disklog from 2 PVs fails
-not lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2"
+not lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2"
diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index 195e4ab..634c518 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -11,8 +11,6 @@
 
 . lib/test
 
-test -e LOCAL_CLVMD && skip
-
 ########################################################
 # MAIN
 ########################################################
diff --git a/test/shell/lvcreate-raid10.sh b/test/shell/lvcreate-raid10.sh
index e9a6ebe..830b390 100644
--- a/test/shell/lvcreate-raid10.sh
+++ b/test/shell/lvcreate-raid10.sh
@@ -11,8 +11,6 @@
 
 . lib/test
 
-test -e LOCAL_CLVMD && skip
-
 ########################################################
 # MAIN
 ########################################################
@@ -32,11 +30,12 @@ not lvcreate --type raid10 -m 2 -i 2 -l 2 -n $lv1 $vg
 # 2-way mirror, 2-stripes
 lvcreate --type raid10 -m 1 -i 2 -l 2 -n $lv1 $vg
 aux wait_for_sync $vg $lv1
-lvremove -ff $vg
 
 # 2-way mirror, 3-stripes
-lvcreate --type raid10 -m 1 -i 3 -l 3 -n $lv1 $vg
-aux wait_for_sync $vg $lv1
+lvcreate --type raid10 -m 1 -i 3 -l 3 -n $lv2 $vg
+aux wait_for_sync $vg $lv2
+
+
 lvremove -ff $vg
 
 #
diff --git a/test/shell/lvcreate-striped-mirror.sh b/test/shell/lvcreate-striped-mirror.sh
index 9a55a97..16ea465 100644
--- a/test/shell/lvcreate-striped-mirror.sh
+++ b/test/shell/lvcreate-striped-mirror.sh
@@ -10,56 +10,46 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . lib/test
+
 aux prepare_vg 9
 
-lvcreate -i2 -l2 -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+lvcreate -aey --nosync -i2 -l2 -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
 not grep "Rounding" log
 check mirror_images_redundant $vg $lv1
-lvremove -ff $vg
 
-lvcreate -i2 -l4 -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+lvcreate -aey --nosync -i2 -l4 -m1 --mirrorlog core -n $lv2 $vg 2>&1 | tee log
 not grep "Rounding" log
-check mirror_images_redundant $vg $lv1
-lvremove -ff $vg
+check mirror_images_redundant $vg $lv2
 
-lvcreate -i3 -l3 -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+lvcreate -aey --nosync -i3 -l3 -m1 --mirrorlog core -n $lv3 $vg 2>&1 | tee log
 not grep "Rounding" log
-check mirror_images_redundant $vg $lv1
-lvremove -ff $vg
+check mirror_images_redundant $vg $lv3
 
-lvcreate -i4 -l4 -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+lvcreate -aey --nosync -i4 -l4 -m1 --mirrorlog core -n $lv4 $vg 2>&1 | tee log
 not grep "Rounding" log
-check mirror_images_redundant $vg $lv1
-lvremove -ff $vg
-
+check mirror_images_redundant $vg $lv4
 
-lvcreate -i2 -l2 -m2 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+lvcreate -aey --nosync -i2 -l2 -m2 --mirrorlog core -n $lv5 $vg 2>&1 | tee log
 not grep "Rounding" log
-check mirror_images_redundant $vg $lv1
-lvremove -ff $vg
+check mirror_images_redundant $vg $lv5
 
-lvcreate -i3 -l3 -m2 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+lvcreate -aey --nosync -i3 -l3 -m2 --mirrorlog core -n $lv6 $vg 2>&1 | tee log
 not grep "Rounding" log
-check mirror_images_redundant $vg $lv1
-lvremove -ff $vg
+check mirror_images_redundant $vg $lv6
 
-lvcreate -i2 -l2 -m3 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+lvcreate -aey --nosync -i2 -l2 -m3 --mirrorlog core -n $lv7 $vg 2>&1 | tee log
 not grep "Rounding" log
-check mirror_images_redundant $vg $lv1
-lvremove -ff $vg
+check mirror_images_redundant $vg $lv7
 
-lvcreate -i3 -l2 -m2 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
-grep "Rounding size (2 extents) up to .* (3 extents)" log
 lvremove -ff $vg
 
-lvcreate -i3 -l4 -m2 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+lvcreate -aey --nosync -i3 -l4 -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
 grep "Rounding size (4 extents) up to .* (6 extents)" log
-lvremove -ff $vg
 
-lvcreate -i3 -l4 -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+lvcreate -aey --nosync -i3 -l4 -m2 --mirrorlog core -n $lv2 $vg 2>&1 | tee log
 grep "Rounding size (4 extents) up to .* (6 extents)" log
-lvremove -ff $vg
 
-lvcreate -i4 -l4 -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
-not grep "Rounding" log
+lvcreate -aey --nosync -i3 -l2 -m2 --mirrorlog core -n $lv3 $vg 2>&1 | tee log
+grep "Rounding size (2 extents) up to .* (3 extents)" log
+
 lvremove -ff $vg
diff --git a/test/shell/lvextend-percent-extents.sh b/test/shell/lvextend-percent-extents.sh
index 1d59082..34654a0 100644
--- a/test/shell/lvextend-percent-extents.sh
+++ b/test/shell/lvextend-percent-extents.sh
@@ -13,9 +13,10 @@
 
 . lib/test
 
-aux prepare_vg 2 128
+aux prepare_pvs 2 128
+vgcreate $vg $(cat DEVICES)
 
-lvcreate -L 64m -n $lv $vg
+lvcreate -L64 -n $lv $vg
 
 # 'lvextend rejects both size and extents without PVs'
 not lvextend -l 10 -L 64m $vg/$lv 2>err
diff --git a/test/shell/lvextend-snapshot-dmeventd.sh b/test/shell/lvextend-snapshot-dmeventd.sh
index 98bec19..2bf552d 100644
--- a/test/shell/lvextend-snapshot-dmeventd.sh
+++ b/test/shell/lvextend-snapshot-dmeventd.sh
@@ -36,7 +36,7 @@ wait_for_change_() {
 aux prepare_dmeventd
 aux prepare_vg 2
 
-lvcreate -L16M -n base $vg
+lvcreate -aey -L16M -n base $vg
 lvcreate -s -L4M -n snap $vg/base
 
 write_ 0 1000
diff --git a/test/shell/lvextend-snapshot-policy.sh b/test/shell/lvextend-snapshot-policy.sh
index 2f5d84b..f396765 100644
--- a/test/shell/lvextend-snapshot-policy.sh
+++ b/test/shell/lvextend-snapshot-policy.sh
@@ -30,10 +30,10 @@ percent() {
 aux prepare_dmeventd
 aux prepare_vg 2
 
-lvcreate -l 8 -n base $vg
+lvcreate -aey -L24 -n base $vg
 mkfs.ext2 "$DM_DEV_DIR/$vg/base"
 
-lvcreate -s -l 4 -n snap $vg/base
+lvcreate -s -L16 -n snap $vg/base
 mkdir mnt
 
 write 1 4096
diff --git a/test/shell/lvresize-mirror.sh b/test/shell/lvresize-mirror.sh
index a10f7cd..1aeb4b8 100644
--- a/test/shell/lvresize-mirror.sh
+++ b/test/shell/lvresize-mirror.sh
@@ -11,29 +11,33 @@
 
 . lib/test
 
-aux prepare_vg 5 80
+aux prepare_vg 5
+
+for deactivate in true false; do
 
 # extend 2-way mirror
-lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1
-lvchange -an $vg/$lv1
-lvextend -l+2 $vg/$lv1
-check mirror $vg $lv1 "$dev3"
-check mirror_images_contiguous $vg $lv1
-lvremove -ff $vg
+	lvcreate -aye -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1
+
+	test $deactivate && lvchange -an $vg/$lv1
+
+	lvextend -l+2 $vg/$lv1
+	check mirror $vg $lv1 "$dev3"
+	check mirror_images_contiguous $vg $lv1
 
 # reduce 2-way mirror
-lvcreate -l4 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1
-lvchange -an $vg/$lv1
-lvreduce -l-2 $vg/$lv1
-check mirror $vg $lv1 "$dev3"
-lvremove -ff $vg
+	lvreduce -f -l-2 $vg/$lv1
+	check mirror $vg $lv1 "$dev3"
 
 # extend 2-way mirror (cling if not contiguous)
-lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1
-lvcreate -l1 -n $lv2 $vg "$dev1"
-lvcreate -l1 -n $lv3 $vg "$dev2"
-lvchange -an $vg/$lv1
-lvextend -l+2 $vg/$lv1
-check mirror $vg $lv1 "$dev3"
-check mirror_images_clung $vg $lv1
-lvremove -ff $vg
+	lvcreate -aye -l2 -m1 -n $lv2 $vg "$dev1" "$dev2" "$dev3":0-1
+	lvcreate -l1 -n $lv3 $vg "$dev1"
+	lvcreate -l1 -n $lv4 $vg "$dev2"
+
+	test $deactivate && lvchange -an $vg/$lv2
+
+	lvextend -l+2 $vg/$lv2
+	check mirror $vg $lv2 "$dev3"
+	check mirror_images_clung $vg $lv2
+
+	lvremove -ff $vg
+done
diff --git a/test/shell/lvresize-raid.sh b/test/shell/lvresize-raid.sh
index f999a31..e61f194 100644
--- a/test/shell/lvresize-raid.sh
+++ b/test/shell/lvresize-raid.sh
@@ -15,63 +15,30 @@ aux target_at_least dm-raid 1 1 0 || skip
 
 aux prepare_vg 5 80
 
-# Extend a 2-way RAID1
 for deactivate in true false; do
+
+# Extend and reduce a 2-way RAID1
 	lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg
 
-	if $deactivate; then
-		lvchange -an $vg/$lv1
-	fi
+	test $deactivate && lvchange -an $vg/$lv1
 
 	lvresize -l +2 $vg/$lv1
 
-	#check raid_images_contiguous $vg $lv1
-
-	lvremove -ff $vg
-done
-
-# Reduce 2-way RAID1
-for deactivate in true false; do
-	lvcreate --type raid1 -m 1 -l 4 -n $lv1 $vg
-
-	if $deactivate; then
-		lvchange -an $vg/$lv1
-	fi
-
 	should lvresize -y -l -2 $vg/$lv1
 
 	#check raid_images_contiguous $vg $lv1
 
-	lvremove -ff $vg
-done
-
-# Extend 3-striped RAID 4/5/6
-for i in 4 5 6 ; do
-	for deactivate in true false; do
-		lvcreate --type raid$i -i 3 -l 3 -n $lv1 $vg
+# Extend and reduce 3-striped RAID 4/5/6
+	for i in 4 5 6 ; do
+		lvcreate --type raid$i -i 3 -l 3 -n $lv2 $vg
 
-		if $deactivate; then
-			lvchange -an $vg/$lv1
-		fi
+		test $deactivate && lvchange -an $vg/$lv2
 
-		lvresize -l +3 $vg/$lv1
+		lvresize -l +3 $vg/$lv2
 
 		#check raid_images_contiguous $vg $lv1
 
-		lvremove -ff $vg
-	done
-done
-
-# Reduce 3-striped RAID 4/5/6
-for i in 4 5 6 ; do
-	for deactivate in true false; do
-		lvcreate --type raid$i -i 3 -l 6 -n $lv1 $vg
-
-		if $deactivate; then
-			lvchange -an $vg/$lv1
-		fi
-
-		should lvresize -y -l -3 $vg/$lv1
+		should lvresize -y -l -3 $vg/$lv2
 
 		#check raid_images_contiguous $vg $lv1
 
diff --git a/test/shell/lvresize-raid10.sh b/test/shell/lvresize-raid10.sh
index 9b71708..306507f 100644
--- a/test/shell/lvresize-raid10.sh
+++ b/test/shell/lvresize-raid10.sh
@@ -13,30 +13,19 @@
 
 aux target_at_least dm-raid 1 3 0 || skip
 
-aux prepare_vg 5 80
+aux prepare_vg 5
 
-# Extend RAID10 (2-stripes, 2-mirror)
 for deactivate in true false; do
+# Extend RAID10 (2-stripes, 2-mirror)
 	lvcreate --type raid10 -m 1 -i 2 -l 2 -n $lv1 $vg
 
-	if $deactivate; then
-		lvchange -an $vg/$lv1
-	fi
+	test $deactivate && lvchange -an $vg/$lv1
 
 	lvresize -l +2 $vg/$lv1
 
 	#check raid_images_contiguous $vg $lv1
 
-	lvremove -ff $vg
-done
-
 # Reduce RAID10 (2-stripes, 2-mirror)
-for deactivate in true false; do
-	lvcreate --type raid10 -m 1 -i 2 -l 4 -n $lv1 $vg
-
-	if $deactivate; then
-		lvchange -an $vg/$lv1
-	fi
 
 	should lvresize -y -l -2 $vg/$lv1
 
diff --git a/test/shell/lvresize-rounding.sh b/test/shell/lvresize-rounding.sh
index 26dfb49..e5425a2 100644
--- a/test/shell/lvresize-rounding.sh
+++ b/test/shell/lvresize-rounding.sh
@@ -15,13 +15,13 @@ aux prepare_pvs 3 22
 
 vgcreate -s 32K $vg "$dev1" "$dev2" "$dev3"
 
-lvcreate -l4 -i3 -I64 $vg
+lvcreate -an -Zn -l4 -i3 -I64 $vg
 
-lvcreate -l8 -i2 -I64 $vg
+lvcreate -an -Zn -l8 -i2 -I64 $vg
 
-lvcreate -l16 $vg
+lvcreate -an -Zn -l16 $vg
 
-lvcreate -l32 -i3 -I64 -n $lv1 $vg
+lvcreate -an -Zn -l32 -i3 -I64 -n $lv1 $vg
 
 lvresize -l+64 -i3 -I64 $vg/$lv1
 
@@ -34,14 +34,14 @@ vgremove -f $vg
 aux prepare_vg 3 22
 
 # Block some extents
-lvcreate -l4 -i3 $vg
-lvcreate -l1 $vg
+lvcreate -an -Zn -l4 -i3 $vg
+lvcreate -an -Zn -l1 $vg
 
-lvcreate -l100%FREE -n $lv1 -i3 $vg
+lvcreate -an -Zn -l100%FREE -n $lv1 -i3 $vg
 check vg_field $vg vg_free_count 2
 lvremove -f $vg/$lv1
 
-lvcreate -l1 -n $lv1 -i3 $vg
+lvcreate -an -Zn -l1 -n $lv1 -i3 $vg
 lvextend -l+100%FREE -i3 $vg/$lv1
 check vg_field $vg vg_free_count 2
 
@@ -54,7 +54,7 @@ vgcreate -s 4M $vg "$dev1" "$dev2" "$dev3"
 check vg_field $vg vg_free_count 15
 
 # Should be rounded to 12 extents
-lvcreate -l10 -n lv -i3 $vg
+lvcreate -an -Zn -l10 -n lv -i3 $vg
 check vg_field $vg vg_free_count 3
 
 # Should want 16 extents
diff --git a/test/shell/lvresize-thin-metadata.sh b/test/shell/lvresize-thin-metadata.sh
index 10dbb4a..d488a43 100644
--- a/test/shell/lvresize-thin-metadata.sh
+++ b/test/shell/lvresize-thin-metadata.sh
@@ -17,19 +17,22 @@ aux prepare_pvs 3
 
 vgcreate -s 1M $vg $(cat DEVICES)
 
-lvcreate -l1 -T $vg/pool
+for deactivate in true false; do
+	lvcreate -l1 -T $vg/pool
+
+	test $deactivate && lvchange -an $vg
 
 # Confirm we have basic 2M metadata
-check lv_field $vg/pool_tmeta size "2.00m"
+	check lv_field $vg/pool_tmeta size "2.00m"
 
-lvresize --poolmetadata +2 $vg/pool
+	lvresize --poolmetadata +2 $vg/pool
 
 # Test it's been resized to 4M
-check lv_field $vg/pool_tmeta size "4.00m"
+	check lv_field $vg/pool_tmeta size "4.00m"
 
 # TODO: Add more tests when kernel is fixed
 
 
 # TODO: Make a full metadata device and test dmeventd support
-
-vgremove -ff $vg
+	lvremove -ff $vg
+done
diff --git a/test/shell/mirror-names.sh b/test/shell/mirror-names.sh
index d6c67ee..d8f711f 100644
--- a/test/shell/mirror-names.sh
+++ b/test/shell/mirror-names.sh
@@ -63,7 +63,7 @@ check_and_cleanup_lvs_
 #COMM "init: lvcreate"
 
 #COMM "mirror images are ${lv1}_mimage_x"
-lvcreate -l2 -m1 -n $lv1 $vg
+lvcreate -an -Zn -l2 -m1 -n $lv1 $vg
 lv_devices_ $vg/$lv1 ${lv1}_mimage_0 ${lv1}_mimage_1
 
 #COMM "mirror log is ${lv1}_mlog"
@@ -74,7 +74,7 @@ check_and_cleanup_lvs_
 
 #COMM "mirror with name longer than 22 characters (bz221322)"
 name="LVwithanamelogerthan22characters_butidontwonttocounthem"
-lvcreate -m1 -l2 -n $name $vg
+lvcreate -an -Zn -m1 -l2 -n $name $vg
 lvs $vg/$name
 check_and_cleanup_lvs_
 
@@ -84,7 +84,7 @@ check_and_cleanup_lvs_
 #COMM "init: lvrename"
 
 #COMM "renamed mirror names: $lv1 to $lv2"
-lvcreate -l2 -m1 -n $lv1 $vg
+lvcreate -an -Zn -l2 -m1 -n $lv1 $vg
 lvrename $vg/$lv1 $vg/$lv2
 lv_devices_ $vg/$lv2 ${lv2}_mimage_0 ${lv2}_mimage_1
 lv_mirror_log_ $vg/$lv2 ${lv2}_mlog
@@ -98,7 +98,7 @@ check_and_cleanup_lvs_
 #COMM "init: lvconvert"
 
 #COMM "converting mirror names is ${lv1}_mimagetmp_2"
-lvcreate -l2 -m1 -n $lv1 $vg
+lvcreate -aey -l2 -m1 -n $lv1 $vg
 lvconvert -m+1 -i+40 -b $vg/$lv1
 convlv=$(lv_convert_lv_ $vg/$lv1)
 test $convlv = ${lv1}_mimagetmp_2
@@ -107,7 +107,7 @@ lv_devices_ $vg/$convlv ${lv1}_mimage_0 ${lv1}_mimage_1
 lv_mirror_log_ $vg/$convlv ${lv1}_mlog
 
 #COMM "mirror log name after re-adding is ${lv1}_mlog" \
-lvconvert --mirrorlog core $vg/$lv1
+lvconvert -f --mirrorlog core $vg/$lv1
 lvconvert --mirrorlog disk $vg/$lv1
 convlv=$(lv_convert_lv_ $vg/$lv1)
 lv_devices_ $vg/$lv1 $convlv ${lv1}_mimage_2
diff --git a/test/shell/mirror-vgreduce-removemissing.sh b/test/shell/mirror-vgreduce-removemissing.sh
index 232c2be..02d6c1c 100644
--- a/test/shell/mirror-vgreduce-removemissing.sh
+++ b/test/shell/mirror-vgreduce-removemissing.sh
@@ -41,14 +41,14 @@ mimages_are_on_ ()
 	echo "Check if mirror images of $lv are on PVs $pvs"
 	rm -f out1 out2
 	echo $pvs | sed 's/ /\n/g' | sort | uniq > out1
-	lvs --noheadings -a -o lv_name $vg > lvs_log
+	lvs --noheadings -a -o lv_name $vg | tee lvs_log
 	mimages=$(grep "${lv}_mimage_" lvs_log | \
 		sed 's/\[//g; s/\]//g' || true)
 
 	for i in $mimages; do
 		echo "Checking $vg/$i"
 		lvs -a -o+devices $vg/$i
-		lvs -a -odevices --noheadings $vg/$i > lvs_log
+		lvs -a -odevices --noheadings $vg/$i | tee lvs_log
 		sed 's/([^)]*)//g; s/ //g; s/,/ /g' lvs_log | sort | uniq >> out2 || true
 	done
 
@@ -65,7 +65,8 @@ mirrorlog_is_on_()
 lv_is_linear_()
 {
 	echo "Check if $1 is linear LV (i.e. not a mirror)"
-	get lv_field $vg/$1 "stripes,attr" | grep "^1 -" >/dev/null
+	get lv_field $vg/$1 "stripes,attr" | tee out
+	grep "^1 -" out >/dev/null
 }
 
 rest_pvs_()
@@ -86,8 +87,11 @@ rest_pvs_()
 # ---------------------------------------------------------------------
 # Initialize PVs and VGs
 
-aux prepare_vg 5
+aux prepare_pvs 5 80
 
+vgcreate -s 64k $vg $(cat DEVICES)
+BLOCKS=0-7
+BLOCKS1=8-15
 # ---------------------------------------------------------------------
 # Common environment setup/cleanup for each sub testcases
 
@@ -121,8 +125,7 @@ check_and_cleanup_lvs_
 
 #COMM "basic: fail the 2nd mirror image of 2-way mirrored LV"
 prepare_lvs_
-lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0
-lvchange -an $vg/$lv1
+lvcreate -an -Zn -l2 -m1 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev3":$BLOCKS
 mimages_are_on_ $lv1 $dev1 $dev2
 mirrorlog_is_on_ $lv1 $dev3
 aux disable_dev "$dev2"
@@ -142,13 +145,11 @@ test_3way_mirror_fail_1_()
 {
 	local index=$1
 
-	lvcreate -l2 -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev4":0
-	lvchange -an $vg/$lv1
+	lvcreate -an -Zn -l2 -m2 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev4":$BLOCKS
 	mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3"
 	mirrorlog_is_on_ $lv1 "$dev4"
 	eval aux disable_dev \$dev$index
 	vgreduce --removemissing --force $vg
-	lvs -a -o+devices $vg
 	mimages_are_on_ $lv1 $(rest_pvs_ $index 3)
 	mirrorlog_is_on_ $lv1 "$dev4"
 }
@@ -169,14 +170,12 @@ test_3way_mirror_fail_2_()
 {
 	local index=$1
 
-	lvcreate -l2 -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev4":0
-	lvchange -an $vg/$lv1
+	lvcreate -an -Zn -l2 -m2 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev4":$BLOCKS
 	mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3"
 	mirrorlog_is_on_ $lv1 "$dev4"
 	rest_pvs_ $index 3
 	aux disable_dev $(rest_pvs_ $index 3)
 	vgreduce --force --removemissing $vg
-	lvs -a -o+devices $vg
 	lv_is_linear_ $lv1
 	eval lv_is_on_ $lv1 \$dev$n
 }
@@ -197,8 +196,7 @@ test_3way_mirror_plus_1_fail_1_()
 {
 	local index=$1
 
-	lvcreate -l2 -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev5":0
-	lvchange -an $vg/$lv1
+	lvcreate -an -Zn -l2 -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev5":$BLOCKS
 	lvconvert -m+1 $vg/$lv1 "$dev4"
 	check mirror_images_on $vg $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
 	check mirror_log_on $vg $lv1 "$dev5"
@@ -226,8 +224,7 @@ test_3way_mirror_plus_1_fail_3_()
 {
 	local index=$1
 
-	lvcreate -l2 -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev5":0
-	lvchange -an $vg/$lv1
+	lvcreate -an -Zn -l2 -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev5":$BLOCKS
 	lvconvert -m+1 $vg/$lv1 "$dev4"
 	check mirror_images_on $vg $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
 	check mirror_log_on $vg $lv1 "$dev5"
@@ -256,14 +253,12 @@ test_2way_mirror_plus_2_fail_1_()
 {
 	local index=$1
 
-	lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":0
-	lvchange -an $vg/$lv1
+	lvcreate -an -Zn -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
 	lvconvert -m+2 $vg/$lv1 "$dev3" "$dev4"
 	mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
 	mirrorlog_is_on_ $lv1 "$dev5"
 	eval aux disable_dev \$dev$n
 	vgreduce --removemissing --force $vg
-	lvs -a -o+devices $vg
 	mimages_are_on_ $lv1 $(rest_pvs_ $index 4)
 	mirrorlog_is_on_ $lv1 "$dev5"
 }
@@ -284,8 +279,7 @@ test_2way_mirror_plus_2_fail_3_()
 {
 	local index=$1
 
-	lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":0
-	lvchange -an $vg/$lv1
+	lvcreate -an -Zn -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
 	lvconvert -m+2 $vg/$lv1 "$dev3" "$dev4"
 	mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
 	mirrorlog_is_on_ $lv1 "$dev5"
@@ -309,8 +303,7 @@ done
 
 #COMM "fail mirror log of 2-way mirrored LV"
 prepare_lvs_
-lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":0
-lvchange -an $vg/$lv1
+lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
 mimages_are_on_ $lv1 "$dev1" "$dev2"
 mirrorlog_is_on_ $lv1 "$dev5"
 aux disable_dev "$dev5"
@@ -321,8 +314,7 @@ recover_vg_ "$dev5"
 
 #COMM "fail mirror log of 3-way (1 converting) mirrored LV"
 prepare_lvs_
-lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":0
-lvchange -an $vg/$lv1
+lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
 lvconvert -m+1 $vg/$lv1 "$dev3"
 mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3"
 mirrorlog_is_on_ $lv1 "$dev5"
@@ -337,8 +329,7 @@ recover_vg_ "$dev5"
 
 #COMM "fail all mirror images of 2-way mirrored LV"
 prepare_lvs_
-lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":0
-lvchange -an $vg/$lv1
+lvcreate -an -Zn -l2 -m1 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
 mimages_are_on_ $lv1 "$dev1" "$dev2"
 mirrorlog_is_on_ $lv1 "$dev5"
 aux disable_dev "$dev1" "$dev2"
@@ -348,8 +339,7 @@ recover_vg_ "$dev1" "$dev2"
 
 #COMM "fail all mirror images of 3-way (1 converting) mirrored LV"
 prepare_lvs_
-lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":0
-lvchange -an $vg/$lv1
+lvcreate -an -Zn -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
 lvconvert -m+1 $vg/$lv1 "$dev3"
 mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3"
 mirrorlog_is_on_ $lv1 "$dev5"
@@ -363,10 +353,8 @@ recover_vg_ "$dev1" "$dev2" "$dev3"
 
 #COMM "fail a mirror image of one of mirrored LV"
 prepare_lvs_
-lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":0
-lvchange -an $vg/$lv1
-lvcreate -l2 -m1 -n $lv2 $vg "$dev3" "$dev4" "$dev5":1
-lvchange -an $vg/$lv2
+lvcreate -an -Zn -l2 -m1 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
+lvcreate -an -Zn -l2 -m1 --nosync -n $lv2 $vg "$dev3" "$dev4" "$dev5":$BLOCKS1
 mimages_are_on_ $lv1 "$dev1" "$dev2"
 mimages_are_on_ $lv2 "$dev3" "$dev4"
 mirrorlog_is_on_ $lv1 "$dev5"
@@ -381,10 +369,8 @@ recover_vg_ "$dev2"
 
 #COMM "fail mirror images, one for each mirrored LV"
 prepare_lvs_
-lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":0
-lvchange -an $vg/$lv1
-lvcreate -l2 -m1 -n $lv2 $vg "$dev3" "$dev4" "$dev5":1
-lvchange -an $vg/$lv2
+lvcreate -an -Zn -l2 -m1 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
+lvcreate -an -Zn -l2 -m1 --nosync -n $lv2 $vg "$dev3" "$dev4" "$dev5":$BLOCKS1
 mimages_are_on_ $lv1 "$dev1" "$dev2"
 mimages_are_on_ $lv2 "$dev3" "$dev4"
 mirrorlog_is_on_ $lv1 "$dev5"
@@ -403,8 +389,7 @@ recover_vg_ "$dev2" "$dev4"
 
 #COMM "no failures"
 prepare_lvs_
-lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":0
-lvchange -an $vg/$lv1
+lvcreate -an -Zn -l2 -m1 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
 mimages_are_on_ $lv1 "$dev1" "$dev2"
 mirrorlog_is_on_ $lv1 "$dev5"
 vgreduce --removemissing --force $vg
diff --git a/test/shell/nomda-restoremissing.sh b/test/shell/nomda-restoremissing.sh
index 8dd71fa..98c5df9 100644
--- a/test/shell/nomda-restoremissing.sh
+++ b/test/shell/nomda-restoremissing.sh
@@ -15,7 +15,7 @@ aux prepare_vg 3
 
 pvchange --metadataignore y $dev1
 
-lvcreate -m 1 -l 1 -n mirror $vg
+lvcreate -aey -m 1 -l 1 -n mirror $vg
 lvchange -a n $vg/mirror
 lvcreate -l 1 -n lv1 $vg "$dev1"
 
@@ -25,7 +25,7 @@ aux disable_dev "$dev1"
 lvremove $vg/mirror
 not vgck $vg 2>&1 | tee log
 grep "missing 1 physical volume" log
-not lvcreate -m 1 -l 1 -n mirror $vg # write operations fail
+not lvcreate -aey -m 1 -l 1 -n mirror $vg # write operations fail
 aux enable_dev "$dev1"
-lvcreate -m 1 -l 1 -n mirror $vg # no MDA => automatically restored
+lvcreate -aey -m 1 -l 1 -n mirror $vg # no MDA => automatically restored
 vgck $vg
diff --git a/test/shell/snapshot-autoumount-dmeventd.sh b/test/shell/snapshot-autoumount-dmeventd.sh
index 3b4b711..ddc41f7 100644
--- a/test/shell/snapshot-autoumount-dmeventd.sh
+++ b/test/shell/snapshot-autoumount-dmeventd.sh
@@ -22,17 +22,17 @@ aux prepare_dmeventd
 aux prepare_vg 2
 mntdir="${PREFIX}mnt"
 
-lvcreate -l 8 -n base $vg
+lvcreate -aey -L8 -n base $vg
 mkfs.ext2 "$DM_DEV_DIR/$vg/base"
 
-lvcreate -s -l 4 -n snap $vg/base
+lvcreate -s -L4 -n snap $vg/base
 lvchange --monitor y $vg/snap
 
 mkdir "$mntdir"
 mount "$DM_DEV_DIR/mapper/$vg-snap" "$mntdir"
 mount
 cat /proc/mounts | grep "$mntdir"
-dd if=/dev/zero of="$mntdir/file$1" bs=1M count=16
+dd if=/dev/zero of="$mntdir/file$1" bs=1M count=5
 sync
 #dmeventd only checks every 10 seconds :(
 for i in {1..10}; do
diff --git a/test/shell/snapshot-merge.sh b/test/shell/snapshot-merge.sh
index a42b6f8..6e59ea7 100644
--- a/test/shell/snapshot-merge.sh
+++ b/test/shell/snapshot-merge.sh
@@ -27,12 +27,12 @@ setup_merge_() {
     local NUM_EXTRA_SNAPS=${3:-0}
     local BASE_SNAP_LV_NAME=$(snap_lv_name_ $LV_NAME)
 
-    lvcreate -n $LV_NAME -l 50%FREE $VG_NAME
+    lvcreate -aey -n $LV_NAME -l 50%FREE $VG_NAME
     lvcreate -s -n $BASE_SNAP_LV_NAME -l 20%FREE ${VG_NAME}/${LV_NAME}
     mkfs.ext3 "$(lvdev_ $VG_NAME $LV_NAME)"
 
     if [ $NUM_EXTRA_SNAPS -gt 0 ]; then
-	for i in `seq 1 $NUM_EXTRA_SNAPS`; do
+	for i in $(seq 1 $NUM_EXTRA_SNAPS); do
 	    lvcreate -s -n ${BASE_SNAP_LV_NAME}_${i} -l 20%FREE ${VG_NAME}/${LV_NAME}
 	done
     fi
@@ -47,7 +47,7 @@ setup_merge_ $vg $lv1
 aux target_at_least snapshot-merge 1 0 0 || skip
 
 # make sure lvconvert --merge requires explicit LV listing
-not lvconvert --merge 2>err
+not lvconvert --merge
 lvconvert --merge $vg/$(snap_lv_name_ $lv1)
 lvremove -f $vg/$lv1
 
@@ -105,7 +105,7 @@ setup_merge_ $vg $lv2
 lvchange --addtag this_is_a_test $vg/$(snap_lv_name_ $lv1)
 lvchange --addtag this_is_a_test $vg/$(snap_lv_name_ $lv2)
 lvconvert --merge @this_is_a_test
-lvs $vg >out
+lvs $vg | tee out
 not grep $(snap_lv_name_ $lv1) out
 not grep $(snap_lv_name_ $lv2) out
 lvremove -f $vg/$lv1 $vg/$lv2
diff --git a/test/shell/snapshots-of-mirrors.sh b/test/shell/snapshots-of-mirrors.sh
index 183d3ac..3bc72bd 100644
--- a/test/shell/snapshots-of-mirrors.sh
+++ b/test/shell/snapshots-of-mirrors.sh
@@ -14,7 +14,7 @@
 aux prepare_vg 4
 
 # Attempt to create snapshot of a mirror origin - should fail
-lvcreate -m 1 -L 10M -n lv $vg
+lvcreate -aey -m 1 -L 10M -n lv $vg
 
 lvcreate -s $vg/lv -L 10M -n snap
 
@@ -34,7 +34,9 @@ not lvconvert -m2 $vg/lv
 lvconvert --mirrorlog core $vg/lv
 
 # Log conversion (core -> mirrored)
-lvconvert --mirrorlog mirrored $vg/lv
+# FIXME on cluster
+test -e LOCAL_CLVMD && SHOULD=should
+$SHOULD lvconvert --mirrorlog mirrored $vg/lv
 
 # Log conversion (mirrored -> core)
 lvconvert --mirrorlog core $vg/lv
diff --git a/test/shell/snapshots-usage.sh b/test/shell/snapshots-usage.sh
index 1507d2a..3c0f457 100644
--- a/test/shell/snapshots-usage.sh
+++ b/test/shell/snapshots-usage.sh
@@ -17,7 +17,8 @@ fill() {
 	dd if=/dev/zero of=$DM_DEV_DIR/$vg1/lvol0 bs=$1 count=1
 }
 
-aux prepare_vg
+aux prepare_pvs 1
+vgcreate -s 4M $vg $(cat DEVICES)
 
 lvcreate -s -l 100%FREE -n $lv $vg --virtualsize 15P
 
diff --git a/test/shell/unknown-segment.sh b/test/shell/unknown-segment.sh
index d6071a1..070c9ff 100644
--- a/test/shell/unknown-segment.sh
+++ b/test/shell/unknown-segment.sh
@@ -13,15 +13,15 @@
 
 aux prepare_vg 4
 
-lvcreate -l 1 -n $lv1 $vg
-lvcreate -l 2 -m 1 -n $lv2 $vg
+lvcreate -an -Zn -l 1 -n $lv1 $vg
+lvcreate -an -Zn -l 2 -m 1 -n $lv2 $vg
 
 vgcfgbackup -f bak0 $vg
 sed -e 's,striped,unstriped,;s,mirror,unmirror,' -i.orig bak0
 vgcfgrestore -f bak0 $vg
 
 # we have on-disk metadata with unknown segments now
-not lvchange -a y $vg/$lv1 # check that activation is refused
+not lvchange -aey $vg/$lv1 # check that activation is refused
 
 vgcfgbackup -f bak1 $vg
 cat bak1
diff --git a/test/shell/unlost-pv.sh b/test/shell/unlost-pv.sh
index 962fe22..73d817c 100644
--- a/test/shell/unlost-pv.sh
+++ b/test/shell/unlost-pv.sh
@@ -20,8 +20,8 @@ check_() {
 
 aux prepare_vg 3
 
-lvcreate -m 1 -l 1 -n mirror $vg
-lvchange -a n $vg
+lvcreate -an -Zn -m 1 -l 1 -n mirror $vg
+#lvchange -a n $vg
 
 # try orphaning a missing PV (bz45867)
 aux disable_dev "$dev1"
diff --git a/test/shell/vgextend-restoremissing.sh b/test/shell/vgextend-restoremissing.sh
index fae68e4..1a16d45 100644
--- a/test/shell/vgextend-restoremissing.sh
+++ b/test/shell/vgextend-restoremissing.sh
@@ -13,8 +13,7 @@
 
 aux prepare_vg 3
 
-lvcreate -m 1 -l 1 -n mirror $vg
-lvchange -a n $vg/mirror
+lvcreate -an -Zn -m 1 -l 1 -n mirror $vg
 lvcreate -l 1 -n lv1 $vg "$dev1"
 
 # try to just change metadata; we expect the new version (with MISSING_PV set
@@ -24,7 +23,7 @@ lvremove $vg/mirror
 aux enable_dev "$dev1"
 not vgck $vg 2>&1 | tee log
 grep "missing 1 physical volume" log
-not lvcreate -m 1 -l 1 -n mirror $vg # write operations fail
+not lvcreate -aey -m 1 -l 1 -n mirror $vg # write operations fail
 vgextend --restore $vg "$dev1" # restore the missing device
 vgck $vg
-lvcreate -m 1 -l 1 -n mirror $vg
+lvcreate -an -Zn -m 1 -l 1 -n mirror $vg
diff --git a/test/shell/vgsplit-operation.sh b/test/shell/vgsplit-operation.sh
index c93a1fc..01a8aa8 100644
--- a/test/shell/vgsplit-operation.sh
+++ b/test/shell/vgsplit-operation.sh
@@ -40,8 +40,7 @@ COMM "vgsplit correctly splits single linear LV into $i VG ($j args)"
 		create_vg_ $vg1 "$dev1" "$dev2"
 		test $i = existing && create_vg_ $vg2 "$dev3" "$dev4"
 
-		lvcreate -l 4 -n $lv1 $vg1 "$dev1"
-		vgchange -an $vg1
+		lvcreate -an -Zn -l 4 -n $lv1 $vg1 "$dev1"
 		if [ $j = PV ]; then
 		  vgsplit $vg1 $vg2 "$dev1"
 		else
@@ -60,8 +59,7 @@ COMM "vgsplit correctly splits single striped LV into $i VG ($j args)"
 		create_vg_ $vg1 "$dev1" "$dev2"
 		test $i = existing && create_vg_ $vg2 "$dev3" "$dev4"
 
-		lvcreate -l 4 -i 2 -n $lv1 $vg1 "$dev1" "$dev2"
-		vgchange -an $vg1
+		lvcreate -an -Zn -l 4 -i 2 -n $lv1 $vg1 "$dev1" "$dev2"
 		if [ $j = PV ]; then
 		  vgsplit $vg1 $vg2 "$dev1" "$dev2"
 		else
@@ -79,8 +77,7 @@ COMM "vgsplit correctly splits mirror LV into $i VG ($j args)"
 		create_vg_ $vg1 "$dev1" "$dev2" "$dev3"
 		test $i = existing && create_vg_ $vg2 "$dev4"
 
-		lvcreate -aey -l 64 -m1 -n $lv1 $vg1 "$dev1" "$dev2" "$dev3"
-		vgchange -an $vg1
+		lvcreate -an -Zn -l 64 -m1 -n $lv1 $vg1 "$dev1" "$dev2" "$dev3"
 		if [ $j = PV ]; then
 		  vgsplit $vg1 $vg2 "$dev1" "$dev2" "$dev3"
 		else
@@ -99,10 +96,9 @@ COMM "vgsplit correctly splits mirror LV with mirrored log into $i VG ($j args)"
 		create_vg_ -c n $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
 		test $i = existing && create_vg_ -c n $vg2 "$dev5"
 
-		lvcreate -aey -l 64 --mirrorlog mirrored -m1 -n $lv1 $vg1 \
+		lvcreate -an -Zn -l 64 --mirrorlog mirrored -m1 -n $lv1 $vg1 \
 		    "$dev1" "$dev2" "$dev3" "$dev4"
 
-		vgchange -an $vg1
 		if [ $j = PV ]; then
 		  vgsplit $vg1 $vg2 "$dev1" "$dev2" "$dev3" "$dev4"
 		else
@@ -167,10 +163,9 @@ COMM "vgsplit correctly splits linear LV but not mirror LV into $i VG ($j args)"
 		create_vg_ $vg1 "$dev1" "$dev2" "$dev3"
 		test $i = existing && create_vg_ $vg2 "$dev5"
 
-		lvcreate -aey -l 64 -m1 -n $lv1 $vg1 "$dev1" "$dev2" "$dev3"
+		lvcreate -an -Zn -l 64 -m1 -n $lv1 $vg1 "$dev1" "$dev2" "$dev3"
 		vgextend $vg1 "$dev4"
-		lvcreate -l 64 -n $lv2 $vg1 "$dev4"
-		vgchange -an $vg1
+		lvcreate -an -Zn -l 64 -n $lv2 $vg1 "$dev4"
 		if [ $j = PV ]; then
 		  vgsplit $vg1 $vg2 "$dev4"
 		else
@@ -194,10 +189,9 @@ done
 #
 COMM "vgsplit fails splitting 3 striped LVs into VG when only 1 LV specified"
 create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
-lvcreate -l 4 -n $lv1 -i 2 $vg1 "$dev1" "$dev2"
-lvcreate -l 4 -n $lv2 -i 2 $vg1 "$dev2" "$dev3"
-lvcreate -l 4 -n $lv3 -i 2 $vg1 "$dev3" "$dev4"
-vgchange -an $vg1
+lvcreate -an -Zn -l 4 -n $lv1 -i 2 $vg1 "$dev1" "$dev2"
+lvcreate -an -Zn -l 4 -n $lv2 -i 2 $vg1 "$dev2" "$dev3"
+lvcreate -an -Zn -l 4 -n $lv3 -i 2 $vg1 "$dev3" "$dev4"
 not vgsplit -n $lv1 $vg1 $vg2
 vgremove -f $vg1
 
@@ -227,18 +221,16 @@ vgremove -f $vg1
 
 COMM "vgsplit fails splitting one mirror LV, only one PV specified"
 create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
-lvcreate -aey -l 16 -n $lv1 -m1 $vg1 "$dev1" "$dev2" "$dev3"
+lvcreate -an -Zn -l 16 -n $lv1 -m1 $vg1 "$dev1" "$dev2" "$dev3"
 check pvlv_counts $vg1 4 1 0
-vgchange -an $vg1
 not vgsplit $vg1 $vg2 "$dev2"
 vgremove -ff $vg1
 
 COMM "vgsplit fails splitting 1 mirror + 1 striped LV, only striped LV specified"
 create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
-lvcreate -aey -l 16 -n $lv1 -m1 $vg1 "$dev1" "$dev2" "$dev3"
-lvcreate -l 16 -n $lv2 -i 2 $vg1 "$dev3" "$dev4"
+lvcreate -an -Zn -l 16 -n $lv1 -m1 $vg1 "$dev1" "$dev2" "$dev3"
+lvcreate -an -Zn -l 16 -n $lv2 -i 2 $vg1 "$dev3" "$dev4"
 check pvlv_counts $vg1 4 2 0
-vgchange -an $vg1
 not vgsplit -n $lv2 $vg1 $vg2 2>err
 vgremove -f $vg1
 
@@ -270,8 +262,7 @@ COMM "vgsplit fails, active snapshot involved in split"
 create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
 lvcreate -aey -l 64 -i 2 -n $lv1 $vg1 "$dev1" "$dev2"
 lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1
-lvcreate -l 64 -i 2 -n $lv3 $vg1 "$dev3" "$dev4"
-lvchange -an $vg1/$lv3
+lvcreate -an -Zn -l 64 -i 2 -n $lv3 $vg1 "$dev3" "$dev4"
 check pvlv_counts $vg1 4 3 1
 not vgsplit -n $lv2 $vg1 $vg2;
 check pvlv_counts $vg1 4 3 1
@@ -283,8 +274,7 @@ create_vg_ $vg1 "$dev1" "$dev2" "$dev3"
 lvcreate -aey -l 64 -i 2 -n $lv1 $vg1 "$dev1" "$dev2"
 lvcreate -l 4 -s -n $lv2 $vg1/$lv1
 vgextend $vg1 "$dev4"
-lvcreate -l 64 -n $lv3 $vg1 "$dev4"
-lvchange -an $vg1/$lv3
+lvcreate -an -Zn -l 64 -n $lv3 $vg1 "$dev4"
 check pvlv_counts $vg1 4 3 1
 vgsplit -n $lv3 $vg1 $vg2
 check pvlv_counts $vg1 3 2 1


