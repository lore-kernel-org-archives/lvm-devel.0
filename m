From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 27 Mar 2014 23:41:38 +0000 (UTC)
Subject: master - tests: updates
Message-ID: <20140327234138.36FB7608FD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a512ea6a6a887e807736fe49fa14b1be791f0e38
Commit:        a512ea6a6a887e807736fe49fa14b1be791f0e38
Parent:        bd805ff0482b96b21076f9507cedf82c142cdebc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 28 00:39:55 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 28 00:41:19 2014 +0100

tests: updates

---
 test/shell/lvconvert-repair-thin.sh |    1 -
 test/shell/lvconvert-repair.sh      |    4 ++--
 test/shell/lvcreate-raid.sh         |    4 ++--
 test/shell/lvmcache-exercise.sh     |    4 ++--
 test/shell/pvchange-usage.sh        |   26 ++++++++++++--------------
 5 files changed, 18 insertions(+), 21 deletions(-)

diff --git a/test/shell/lvconvert-repair-thin.sh b/test/shell/lvconvert-repair-thin.sh
index 30cd76d..8b0f117 100644
--- a/test/shell/lvconvert-repair-thin.sh
+++ b/test/shell/lvconvert-repair-thin.sh
@@ -78,7 +78,6 @@ should "$LVM_TEST_THIN_CHECK_CMD" "$DM_DEV_DIR/$vg/fixed"
 
 # Swap repaired metadata back
 lvconvert -y -f --poolmetadata $vg/fixed --thinpool $vg/pool
-lvs -a $vg
 
 # Activate pool - this should now work
 should vgchange -ay $vg
diff --git a/test/shell/lvconvert-repair.sh b/test/shell/lvconvert-repair.sh
index a3c46b1..db24710 100644
--- a/test/shell/lvconvert-repair.sh
+++ b/test/shell/lvconvert-repair.sh
@@ -26,8 +26,8 @@ _check_mlog()
 	not grep mlog out
 }
 
-aux lvmconf 'allocation/maximise_cling = 0'
-aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
+aux lvmconf "allocation/maximise_cling = 0" \
+	    "allocation/mirror_logs_require_separate_pvs = 1"
 
 # fail multiple devices
 
diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index 77b2347..15cf09f 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -116,9 +116,9 @@ lvcreate -l 18 -n lv $vg "$dev1"
 lvcreate --type raid1 -m 1 -l 100%FREE -n raid1 $vg "$dev1" "$dev2"
 check lv_field $vg/raid1 size "9.00m"
 # Ensure image size is the same as the RAID1 size
-check lv_field $vg/raid1 size `lvs --noheadings -o size $vg/raid1_rimage_0`
+check lv_field $vg/raid1 size $(get lv_field $vg/raid1_rimage_0 size -a)
 # Amount remaining in dev2 should equal the amount taken by 'lv' in dev1
-check pv_field "$dev2" pv_free `lvs --noheadings -o size $vg/lv`
+check pv_field "$dev2" pv_free $(get lv_field $vg/lv size)
 lvremove -ff $vg
 
 # Eat 18 of 37 extents from dev1, leaving 19
diff --git a/test/shell/lvmcache-exercise.sh b/test/shell/lvmcache-exercise.sh
index 09522e3..682d582 100644
--- a/test/shell/lvmcache-exercise.sh
+++ b/test/shell/lvmcache-exercise.sh
@@ -20,7 +20,7 @@ aux disable_dev "$dev1"
 pvscan
 vgcreate $vg1 "$dev2"
 aux enable_dev "$dev1"
-pvs
+pvs $(cat DEVICES)
 
 # reappearing device (rhbz 995440)
 lvcreate -aey -m2 --type mirror -l4 --alloc anywhere --corelog -n $lv1 $vg2
@@ -30,7 +30,7 @@ lvconvert --yes --repair $vg2/$lv1
 aux enable_dev "$dev3"
 
 # here it should fix any reappeared devices
-lvs
+lvs $vg1 $vg1
 
 lvs -a $vg2 -o+devices 2>&1 | tee out
 not grep reappeared out
diff --git a/test/shell/pvchange-usage.sh b/test/shell/pvchange-usage.sh
index 8506747..e25230c 100644
--- a/test/shell/pvchange-usage.sh
+++ b/test/shell/pvchange-usage.sh
@@ -45,29 +45,27 @@ done
 pvcreate --metadatacopies 0 "$dev1"
 pvcreate --metadatacopies 2 "$dev2"
 vgcreate $vg1 "$dev1" "$dev2"
+
 pvchange -u "$dev1"
 pvchange -u "$dev2"
-check pvlv_counts $vg1 2 0 0
-
-# -a needs more params
-not pvchange -a
-# -a is searching for devs, so passing it some is error
-not pvchange -a "$dev1"
-not pvchange -u "$dev1-notfound"
-
+UUID=$(get pv_field "$dev1" uuid)
 pvchange -u --all
+# Checking for different UUID after pvchange
+test "$UUID" != "$(get pv_field "$dev1" uuid)" || die "UUID has not changed!"
 check pvlv_counts $vg1 2 0 0
 
-# "pvchange rejects uuid change under an active lv"
+# '-a' needs more params
+invalid pvchange -a
+# '-a' is searching for devs, so specifying device is invalid
+invalid pvchange -a "$dev1"
+fail pvchange -u "$dev1-notfound"
+
+# pvchange rejects uuid change under an active lv
 lvcreate -l 16 -i 2 -n $lv --alloc anywhere $vg1
 check pvlv_counts $vg1 2 1 0
 not pvchange -u "$dev1"
-lvchange -an $vg1/$lv
-pvchange -u "$dev1"
 
-# "cleanup"
-lvremove -f $vg1/$lv
-vgremove $vg1
+vgremove -f $vg1
 
 # "pvchange reject --addtag to lvm1 pv"
 pvcreate -M1 "$dev1"


