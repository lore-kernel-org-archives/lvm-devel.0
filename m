From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  8 Apr 2015 21:20:34 +0000 (UTC)
Subject: master - tests: use single lvmconf call
Message-ID: <20150408212034.CE6D26055A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ebde60beab2d3421892a37780eacf7ed1459d8b9
Commit:        ebde60beab2d3421892a37780eacf7ed1459d8b9
Parent:        a5b34f0f1bf38807bdbed2855516f9b2ceebf7b7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 8 22:44:16 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 8 23:19:37 2015 +0200

tests: use single lvmconf call

---
 test/lib/aux.sh                         |    4 +-
 test/shell/lvconvert-repair-policy.sh   |    4 +-
 test/shell/lvconvert-repair-raid.sh     |    4 +-
 test/shell/lvconvert-repair-replace.sh  |    4 +-
 test/shell/lvconvert-repair-snapshot.sh |    4 +-
 test/shell/lvcreate-mirror.sh           |    4 +-
 test/shell/lvcreate-pvtags.sh           |    4 +-
 test/shell/pvcreate-bootloaderarea.sh   |    3 +-
 test/shell/system_id.sh                 |  100 +++++++++++++++---------------
 9 files changed, 65 insertions(+), 66 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 3232074..37a9a9a 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -85,8 +85,8 @@ prepare_lvmetad() {
 	# skip if we don't have our own lvmetad...
 	(which lvmetad 2>/dev/null | grep "$abs_builddir") || skip
 
-	lvmconf "global/use_lvmetad = 1"
-	lvmconf "devices/md_component_detection = 0"
+	lvmconf "global/use_lvmetad = 1" \
+		"devices/md_component_detection = 0"
 
 	local run_valgrind=
 	test "${LVM_VALGRIND_LVMETAD:-0}" -eq 0 || run_valgrind="run_valgrind"
diff --git a/test/shell/lvconvert-repair-policy.sh b/test/shell/lvconvert-repair-policy.sh
index ace52fc..96a69d0 100644
--- a/test/shell/lvconvert-repair-policy.sh
+++ b/test/shell/lvconvert-repair-policy.sh
@@ -12,8 +12,8 @@
 . lib/inittest
 
 aux prepare_vg 4
-aux lvmconf 'allocation/maximise_cling = 0'
-aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
+aux lvmconf 'allocation/maximise_cling = 0' \
+	    'allocation/mirror_logs_require_separate_pvs = 1'
 
 # Clean-up and create a 2-way mirror, where the the
 # leg devices are always on $dev[12] and the log
diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index 4f0175a..6b1e51f 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -14,8 +14,8 @@
 aux have_raid 1 3 0 || skip
 aux raid456_replace_works || skip
 
-aux lvmconf 'allocation/maximise_cling = 0'
-aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
+aux lvmconf 'allocation/maximise_cling = 0' \
+	    'allocation/mirror_logs_require_separate_pvs = 1'
 
 aux prepare_vg 8
 
diff --git a/test/shell/lvconvert-repair-replace.sh b/test/shell/lvconvert-repair-replace.sh
index 3c0dc53..8a3567c 100644
--- a/test/shell/lvconvert-repair-replace.sh
+++ b/test/shell/lvconvert-repair-replace.sh
@@ -12,8 +12,8 @@
 . lib/inittest
 
 aux prepare_vg 6
-aux lvmconf 'allocation/maximise_cling = 0'
-aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
+aux lvmconf 'allocation/maximise_cling = 0' \
+	    'allocation/mirror_logs_require_separate_pvs = 1'
 
 # 3-way, disk log
 # multiple failures, full replace
diff --git a/test/shell/lvconvert-repair-snapshot.sh b/test/shell/lvconvert-repair-snapshot.sh
index 473d561..a0c0399 100644
--- a/test/shell/lvconvert-repair-snapshot.sh
+++ b/test/shell/lvconvert-repair-snapshot.sh
@@ -12,8 +12,8 @@
 . lib/inittest
 
 aux prepare_vg 5
-aux lvmconf 'allocation/maximise_cling = 0'
-aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
+aux lvmconf 'allocation/maximise_cling = 0' \
+	    'allocation/mirror_logs_require_separate_pvs = 1'
 
 lvcreate -aey --type mirror -m 3 --ignoremonitoring -L 2M -n 4way $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5":0
 lvcreate -s $vg/4way -L 2M -n snap
diff --git a/test/shell/lvcreate-mirror.sh b/test/shell/lvcreate-mirror.sh
index a151126..f62bee7 100644
--- a/test/shell/lvcreate-mirror.sh
+++ b/test/shell/lvcreate-mirror.sh
@@ -11,8 +11,8 @@
 
 . lib/inittest
 aux prepare_vg 5 80
-aux lvmconf 'allocation/maximise_cling = 0'
-aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
+aux lvmconf 'allocation/maximise_cling = 0' \
+	    'allocation/mirror_logs_require_separate_pvs = 1'
 
 # 2-way mirror with corelog, 2 PVs
 lvcreate -aey -l2 --type mirror -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
diff --git a/test/shell/lvcreate-pvtags.sh b/test/shell/lvcreate-pvtags.sh
index b7c814f..6bfb55b 100644
--- a/test/shell/lvcreate-pvtags.sh
+++ b/test/shell/lvcreate-pvtags.sh
@@ -12,8 +12,8 @@
 . lib/inittest
 
 aux prepare_pvs 3
-aux lvmconf 'allocation/maximise_cling = 0'
-aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
+aux lvmconf 'allocation/maximise_cling = 0' \
+	    'allocation/mirror_logs_require_separate_pvs = 1'
 
 # not required, just testing
 aux pvcreate --metadatacopies 0 "$dev1"
diff --git a/test/shell/pvcreate-bootloaderarea.sh b/test/shell/pvcreate-bootloaderarea.sh
index 53a9839..6dd45f5 100644
--- a/test/shell/pvcreate-bootloaderarea.sh
+++ b/test/shell/pvcreate-bootloaderarea.sh
@@ -14,8 +14,7 @@ test_description='Test pvcreate bootloader area support'
 . lib/inittest
 
 aux prepare_devs 1
-aux lvmconf 'global/suffix=0'
-aux lvmconf 'global/units="b"'
+aux lvmconf 'global/suffix=0' 'global/units="b"'
 
 #COMM 'pvcreate sets/aligns bootloader area correctly'
 pvcreate --dataalignment 262144b --bootloaderareasize 614400b "$dev1"
diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index e1d8967..ff03e14 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -89,8 +89,8 @@ SID=sidfoofile
 SIDFILE=etc/lvm_test.conf
 rm -f $SIDFILE
 echo "$SID" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 vgcreate $vg1 "$dev1"
 vgs -o+systemid $vg1
 check vg_field $vg1 systemid $SID
@@ -104,8 +104,8 @@ SID2=sidfoofile2
 SIDFILE=etc/lvm_test.conf
 rm -f $SIDFILE
 echo "$SID1" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 # create a vg, overriding the local system_id so the vg looks foreign
 vgcreate --systemid $SID2 $vg1 "$dev1"
 # normal vgs is not an error and does not see the vg
@@ -136,8 +136,8 @@ SID2=sidfoofile2
 SIDFILE=etc/lvm_test.conf
 rm -f $SIDFILE
 echo "$SID1" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
 vgcreate $vg1 "$dev1"
 # normal vgs sees the vg
@@ -165,8 +165,8 @@ SID2=sidfoofile2
 SIDFILE=etc/lvm_test.conf
 rm -f $SIDFILE
 echo "$SID1" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
 vgcreate $vg1 "$dev1"
 # normal vgs sees the vg
@@ -196,8 +196,8 @@ SID2=sidfoofile2
 SIDFILE=etc/lvm_test.conf
 rm -f $SIDFILE
 echo "$SID1" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
 vgcreate $vg1 "$dev1"
 lvcreate -n $lv1 -l 2 $vg1
@@ -229,8 +229,8 @@ SID1=sidfoofile1
 SIDFILE=etc/lvm_test.conf
 rm -f $SIDFILE
 echo "$SID1" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
 vgcreate $vg1 "$dev1"
 aux lvmconf "global/system_id_source = none"
@@ -255,8 +255,8 @@ vgcreate $vg1 "$dev1"
 check vg_field $vg1 systemid ""
 # set a local system_id
 echo "$SID1" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 # check we can see and use the vg with no system_id
 vgs >err
 grep $vg1 err
@@ -271,8 +271,8 @@ SID1=sidfoofile1
 SIDFILE=etc/lvm_test.conf
 rm -f $SIDFILE
 echo "$SID1" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
 vgcreate $vg1 "$dev1"
 # normal vgs sees the vg
@@ -298,8 +298,8 @@ SID1=sidfoofile1
 SIDFILE=etc/lvm_test.conf
 rm -f $SIDFILE
 echo "$SID1" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
 vgcreate $vg1 "$dev1"
 # normal vgs sees the vg
@@ -332,8 +332,8 @@ SID2=012345678901234567890123456789012345678901234567890123456789012345678901234
 # max len system_id should appear normally
 rm -f $SIDFILE
 echo "$SID1" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
 vgcreate $vg1 "$dev1"
 # normal vgs sees the vg
@@ -346,8 +346,8 @@ rm -f $SIDFILE
 # max+1 len system_id should be missing the last character
 rm -f $SIDFILE
 echo "$SID2" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
 vgcreate $vg1 "$dev1"
 # normal vgs sees the vg
@@ -367,8 +367,8 @@ SID1=012345678901234567890123456789012345678901234567890123456789012345678901234
 SID2=012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789abcdefg
 rm -f $SIDFILE
 echo "$SID1" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
 vgcreate $vg1 "$dev1"
 # normal vgs sees the vg
@@ -386,8 +386,8 @@ SID2=A.1
 
 rm -f $SIDFILE
 echo "$SID1" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
 vgcreate $vg1 "$dev1"
 # normal vgs sees the vg
@@ -407,8 +407,8 @@ SID2=sidfoofile2
 SIDFILE=etc/lvm_test.conf
 rm -f $SIDFILE
 echo "$SID1" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
 vgcreate $vg1 "$dev1"
 # normal pvs sees the vg and pv
@@ -438,8 +438,8 @@ SID2=sidfoofile2
 SIDFILE=etc/lvm_test.conf
 rm -f $SIDFILE
 echo "$SID1" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
 vgcreate $vg1 "$dev1"
 lvcreate -n $lv1 -l 2 $vg1
@@ -473,8 +473,8 @@ LVMLOCAL=etc/lvmlocal.conf
 rm -f $LVMLOCAL
 rm -f $SIDFILE
 echo "$SID1" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
 vgcreate $vg1 "$dev1"
 # normal vgs sees the vg
@@ -503,8 +503,8 @@ SID1=sidfoofile1
 SIDFILE=etc/lvm_test.conf
 rm -f $SIDFILE
 echo "$SID1" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
 vgcreate --systemid "" $vg1 "$dev1"
 # normal vgs sees the vg
@@ -521,8 +521,8 @@ SID1=sidfoofile1
 SIDFILE=etc/lvm_test.conf
 rm -f $SIDFILE
 echo "$SID1" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
 vgcreate $vg1 "$dev1"
 # normal vgs sees the vg
@@ -549,8 +549,8 @@ SIDFILE=etc/lvm_test.conf
 rm -f $LVMLOCAL
 rm -f $SIDFILE
 echo "$SID1" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
 vgcreate $vg1 "$dev1"
 # normal vgs sees the vg
@@ -580,8 +580,8 @@ SIDFILE=etc/lvm_test.conf
 rm -f $LVMLOCAL
 rm -f $SIDFILE
 echo "$SID1" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
 vgcreate $vg1 "$dev1"
 # normal vgs sees the vg
@@ -677,8 +677,8 @@ rm -f $SIDFILE
 SID=""
 SIDFILE=etc/lvm_test.conf
 rm -f $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 vgcreate $vg1 "$dev1" |& tee err
 vgs -o+systemid $vg1
 check vg_field $vg1 systemid $SID
@@ -700,8 +700,8 @@ SID2=sidfoofile2
 SIDFILE=etc/lvm_test.conf
 rm -f $SIDFILE
 echo "$SID1" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 # create a vg with an lv
 vgcreate $vg1 "$dev1"
 lvcreate -n $lv1 -l 2 -an $vg1
@@ -741,8 +741,8 @@ SID2=sidfoofile2
 SIDFILE=etc/lvm_test.conf
 rm -f $SIDFILE
 echo "$SID1" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 # create a vg with an lv
 vgcreate $vg1 "$dev1"
 lvcreate -n $lv1 -l 2 -an $vg1
@@ -781,8 +781,8 @@ SID2=sidfoofile2
 SIDFILE=etc/lvm_test.conf
 rm -f $SIDFILE
 echo "$SID1" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 # create a vg with an lv
 vgcreate $vg1 "$dev1"
 lvcreate -n $lv1 -l 2 -an $vg1
@@ -833,8 +833,8 @@ SID2=sidfoofile2
 SIDFILE=etc/lvm_test.conf
 rm -f $SIDFILE
 echo "$SID1" > $SIDFILE
-aux lvmconf "global/system_id_source = file"
-aux lvmconf "global/system_id_file = $SIDFILE"
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
 # create a vg with an lv
 vgcreate $vg1 "$dev1"
 lvcreate -n $lv1 -l 2 -an $vg1


