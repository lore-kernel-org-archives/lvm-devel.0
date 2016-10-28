From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 28 Oct 2016 19:54:22 +0000 (UTC)
Subject: master - test: add raid4 checks to respective tests
Message-ID: <20161028195422.6F3D5610D0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a9651adc84210d88828f9c3c82a0f382a899a650
Commit:        a9651adc84210d88828f9c3c82a0f382a899a650
Parent:        e611f82a11fb9c489e73de8c05447ebe2cc26d9a
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Oct 28 21:54:10 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Oct 28 21:54:10 2016 +0200

test: add raid4 checks to respective tests

Add missing checks for valid raid4 mapping to tests.
---
 test/lib/aux.sh                    |    9 +++++++++
 test/shell/lvchange-raid456.sh     |    2 +-
 test/shell/lvconvert-raid456.sh    |    5 ++++-
 test/shell/lvcreate-large-raid.sh  |    5 ++++-
 test/shell/lvcreate-raid-nosync.sh |    5 ++++-
 test/shell/lvcreate-raid.sh        |    7 +++++--
 test/shell/lvresize-raid.sh        |    7 +++++--
 7 files changed, 32 insertions(+), 8 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index e523123..7187975 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1376,6 +1376,15 @@ have_raid() {
 	esac
 }
 
+have_raid4 () {
+	local r=1
+
+	have_raid 1 8 0 && r=0
+	have_raid 1 9 1 && r=1
+
+	return $r
+}
+
 have_cache() {
 	test "$CACHE" = shared -o "$CACHE" = internal || {
 		echo "Cache is not built-in." >&2
diff --git a/test/shell/lvchange-raid456.sh b/test/shell/lvchange-raid456.sh
index 13b19dd..5cdcbde 100644
--- a/test/shell/lvchange-raid456.sh
+++ b/test/shell/lvchange-raid456.sh
@@ -16,7 +16,7 @@ TEST_RAID=raid456
 aux raid456_replace_works || skip
 aux have_raid 1 5 2 || skip
 
-run_types raid4 -i 2 "$dev1" "$dev2" "$dev3" "$dev4"
+aux have_raid4 && run_types raid4 -i 2 "$dev1" "$dev2" "$dev3" "$dev4"
 run_types raid5 -i 2 "$dev1" "$dev2" "$dev3" "$dev4"
 run_types raid6 -i 3 "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 
diff --git a/test/shell/lvconvert-raid456.sh b/test/shell/lvconvert-raid456.sh
index f7e6e56..358ceec 100644
--- a/test/shell/lvconvert-raid456.sh
+++ b/test/shell/lvconvert-raid456.sh
@@ -31,8 +31,11 @@ aux have_raid 1 3 0 || skip
 aux prepare_pvs 7  # 7 devices for 2 dev replacement of 5-dev RAID6
 vgcreate -s 256k $vg $(cat DEVICES)
 
+levels="5 6"
+aux have_raid4 && levels="4 5 6"
+
 # RAID 4/5/6 (can replace up to 'parity' devices)
-for i in 4 5 6; do
+for i in $levels; do
 	lvcreate --type raid$i -i 3 -l 3 -n $lv1 $vg
 
 	if [ $i -eq 6 ]; then
diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index 11a69d4..4e68b2c 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -21,6 +21,9 @@ aux can_use_16T || skip
 
 aux have_raid 1 3 0 || skip
 
+segtypes="raid5"
+aux have_raid4 && segtypes="raid4 raid5"
+
 # Prepare 5x ~1P sized devices
 aux prepare_pvs 5 1000000000
 
@@ -53,7 +56,7 @@ check raid_leg_status $vg1 $lv1 "AA"
 lvremove -ff $vg1
 
 # 750 TiB raid4/5
-for segtype in raid4 raid5; do
+for segtype in $segtypes; do
         lvcreate --type $segtype -i 3 -L 750T -n $lv1 $vg1 --nosync
         check lv_field $vg1/$lv1 size "750.00t"
         check raid_leg_status $vg1 $lv1 "AAAA"
diff --git a/test/shell/lvcreate-raid-nosync.sh b/test/shell/lvcreate-raid-nosync.sh
index fdb4f68..1343e8f 100644
--- a/test/shell/lvcreate-raid-nosync.sh
+++ b/test/shell/lvcreate-raid-nosync.sh
@@ -16,6 +16,9 @@ SKIP_WITH_LVMPOLLD=1
 
 aux have_raid 1 7 0 || skip
 
+segtypes=raid5
+aux have_raid4 && segtypes="raid4 raid5"
+
 aux prepare_vg 6
 
 
@@ -43,7 +46,7 @@ lvcreate --yes --type raid1 --nosync -m 2 -l 1 -n $lv1 $vg
 check raid_leg_status $vg $lv1 "AAA"
 lvremove --yes $vg/$lv1
 
-for r in raid4 raid5
+for r in $segtypes
 do 
 	# raid4/5 support resynchronization
 	lvcreate --yes --type $r -i 3 -l 2 -n $lv1 $vg
diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index 66434b0..f1a4a68 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -23,6 +23,9 @@ lv_devices() {
 ########################################################
 aux have_raid 1 3 0 || skip
 
+RAID4=""
+aux have_raid4 && RAID4=raid4
+
 aux prepare_pvs 6 20  # 6 devices for RAID10 (2-mirror,3-stripe) test
 vgcreate -s 512k $vg $(cat DEVICES)
 
@@ -54,7 +57,7 @@ aux wait_for_sync $vg $lv1
 lvremove -ff $vg
 
 # Create RAID 4/5/6 (explicit 3-stripe + parity devs)
-for i in raid4 \
+for i in $RAID4 \
 	raid5 raid5_ls raid5_la raid5_rs raid5_ra \
 	raid6 raid6_zr raid6_nr raid6_nc; do
 
@@ -64,7 +67,7 @@ for i in raid4 \
 done
 
 # Create RAID 4/5/6 (explicit 3-stripe + parity devs) - Set min/max recovery
-for i in raid4 \
+for i in $RAID4 \
 	raid5 raid5_ls raid5_la raid5_rs raid5_ra \
 	raid6 raid6_zr raid6_nr raid6_nc; do
 
diff --git a/test/shell/lvresize-raid.sh b/test/shell/lvresize-raid.sh
index 98eef28..4eabe4c 100644
--- a/test/shell/lvresize-raid.sh
+++ b/test/shell/lvresize-raid.sh
@@ -16,6 +16,9 @@ SKIP_WITH_LVMPOLLD=1
 
 aux have_raid 1 3 0 || skip
 
+levels="5 6"
+aux have_raid4 && levels="4 5 6"
+
 aux prepare_pvs 6 80
 
 vgcreate -s 256K $vg $(cat DEVICES)
@@ -37,7 +40,7 @@ for deactivate in true false; do
 	#check raid_images_contiguous $vg $lv1
 
 # Extend and reduce 3-striped RAID 4/5/6
-	for i in 4 5 6 ; do
+	for i in $levels ; do
 		lvcreate --type raid$i -i 3 -l 3 -n $lv2 $vg
 
 		test $deactivate && {
@@ -59,7 +62,7 @@ done
 
 # Bug 1005434
 # Ensure extend is contiguous
-lvcreate --type raid4 -l 2 -i 2 -n $lv1 $vg "$dev4" "$dev5" "$dev6"
+lvcreate --type raid5 -l 2 -i 2 -n $lv1 $vg "$dev4" "$dev5" "$dev6"
 lvextend -l +2 --alloc contiguous $vg/$lv1
 check lv_tree_on $vg $lv1 "$dev4" "$dev5" "$dev6"
 


