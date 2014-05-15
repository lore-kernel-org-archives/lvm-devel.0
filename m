From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 15 May 2014 10:14:19 +0000 (UTC)
Subject: master - tests: speedup
Message-ID: <20140515101419.A525C60DC4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=76c06c72523201bdb478bd1735b2fcfbe49d3d38
Commit:        76c06c72523201bdb478bd1735b2fcfbe49d3d38
Parent:        309201a53bcbbd4967f380214e688c520b957fdf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 15 10:25:25 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 15 12:08:35 2014 +0200

tests: speedup

Avoid some expencive raid/mirror synchronization when testing
just allocation sizes.
Use lv_attr_bit
---
 test/shell/lvchange-raid.sh          |   62 ++++++++++++++--------------
 test/shell/lvconvert-mirror-basic.sh |    2 +-
 test/shell/lvcreate-pvtags.sh        |    4 +-
 test/shell/lvcreate-raid.sh          |   74 +++++++++++++++------------------
 test/shell/lvcreate-raid10.sh        |   16 +++-----
 test/shell/snapshots-of-mirrors.sh   |    4 +-
 test/shell/vgsplit-operation.sh      |    6 +-
 7 files changed, 79 insertions(+), 89 deletions(-)

diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index afa2431..8ef6c33 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -37,8 +37,8 @@ run_writemostly_check() {
 		$vg $lv $segtype
 
 	# No writemostly flag should be there yet.
-	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*-.$'
-	get lv_field $vg/${lv}_rimage_1 lv_attr -a | grep '.*-.$'
+	check lv_attr_bit health $vg/${lv}_rimage_0 "-"
+	check lv_attr_bit health $vg/${lv}_rimage_1 "-"
 
 	if [ "$segtype" != "raid1" ]; then
 		not lvchange --writemostly $d0 $vg/$lv
@@ -47,71 +47,71 @@ run_writemostly_check() {
 
 	# Set the flag
 	lvchange --writemostly $d0 $vg/$lv
-	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*w.$'
+	check lv_attr_bit health $vg/${lv}_rimage_0 "w"
 
 	# Running again should leave it set (not toggle)
 	lvchange --writemostly $d0 $vg/$lv
-	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*w.$'
+	check lv_attr_bit health $vg/${lv}_rimage_0 "w"
 
 	# Running again with ':y' should leave it set
 	lvchange --writemostly $d0:y $vg/$lv
-	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*w.$'
+	check lv_attr_bit health $vg/${lv}_rimage_0 "w"
 
 	# ':n' should unset it
 	lvchange --writemostly $d0:n $vg/$lv
-	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*-.$'
+	check lv_attr_bit health $vg/${lv}_rimage_0 "-"
 
 	# ':n' again should leave it unset
 	lvchange --writemostly $d0:n $vg/$lv
-	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*-.$'
+	check lv_attr_bit health $vg/${lv}_rimage_0 "-"
 
 	# ':t' toggle to set
 	lvchange --writemostly $d0:t $vg/$lv
-	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*w.$'
+	check lv_attr_bit health $vg/${lv}_rimage_0 "w"
 
 	# ':t' toggle to unset
 	lvchange --writemostly $d0:t $vg/$lv
-	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*-.$'
+	check lv_attr_bit health $vg/${lv}_rimage_0 "-"
 
 	# ':y' to set
 	lvchange --writemostly $d0:y $vg/$lv
-	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*w.$'
+	check lv_attr_bit health $vg/${lv}_rimage_0 "w"
 
 	# Toggle both at once
 	lvchange --writemostly $d0:t --writemostly $d1:t $vg/$lv
-	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*-.$'
-	get lv_field $vg/${lv}_rimage_1 lv_attr -a | grep '.*w.$'
+	check lv_attr_bit health $vg/${lv}_rimage_0 "-"
+	check lv_attr_bit health $vg/${lv}_rimage_1 "w"
 
 	# Toggle both at once again
 	lvchange --writemostly $d0:t --writemostly $d1:t $vg/$lv
-	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*w.$'
-	get lv_field $vg/${lv}_rimage_1 lv_attr -a | grep '.*-.$'
+	check lv_attr_bit health $vg/${lv}_rimage_0 "w"
+	check lv_attr_bit health $vg/${lv}_rimage_1 "-"
 
 	# Toggle one, unset the other
 	lvchange --writemostly $d0:n --writemostly $d1:t $vg/$lv
-	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*-.$'
-	get lv_field $vg/${lv}_rimage_1 lv_attr -a | grep '.*w.$'
+	check lv_attr_bit health $vg/${lv}_rimage_0 "-"
+	check lv_attr_bit health $vg/${lv}_rimage_1 "w"
 
 	# Toggle one, set the other
 	lvchange --writemostly $d0:y --writemostly $d1:t $vg/$lv
-	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*w.$'
-	get lv_field $vg/${lv}_rimage_1 lv_attr -a | grep '.*-.$'
+	check lv_attr_bit health $vg/${lv}_rimage_0 "w"
+	check lv_attr_bit health $vg/${lv}_rimage_1 "-"
 
 	# Partial flag supercedes writemostly flag
 	aux disable_dev $d0
-	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*p.$'
+	check lv_attr_bit health $vg/${lv}_rimage_0 "p"
 
 	# It is possible for the kernel to detect the failed device before
 	# we re-enable it.  If so, the field will be set to 'r'efresh since
 	# that also takes precedence over 'w'ritemostly.  If this has happened,
 	# we refresh the LV and then check for 'w'.
 	aux enable_dev $d0
-	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*r.$' && lvchange --refresh $vg/$lv
-	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*w.$'
+	check lv_attr_bit health $vg/${lv}_rimage_0 "r" && lvchange --refresh $vg/$lv
+	check lv_attr_bit health $vg/${lv}_rimage_0 "w"
 
 	# Catch Bad writebehind values
-	not lvchange --writebehind "invalid" $vg/$lv
-	not lvchange --writebehind -256 $vg/$lv
+	invalid lvchange --writebehind "invalid" $vg/$lv
+	invalid lvchange --writebehind -256 $vg/$lv
 
 	# Set writebehind
 	check lv_field $vg/$lv raid_write_behind ""
@@ -122,8 +122,8 @@ run_writemostly_check() {
 	lvconvert -m 0 $vg/$lv $d1
 	lvconvert --type raid1 -m 1 $vg/$lv $d1
 	check lv_field $vg/$lv raid_write_behind ""
-	get lv_field $vg/${lv}_rimage_0 lv_attr -a  | grep '.*-.$'
-	get lv_field $vg/${lv}_rimage_1 lv_attr -a  | grep '.*-.$'
+	check lv_attr_bit health $vg/${lv}_rimage_0 "-"
+	check lv_attr_bit health $vg/${lv}_rimage_1 "-"
 }
 
 # run_syncaction_check <VG> <LV>
@@ -152,7 +152,7 @@ run_syncaction_check() {
 
 	seek=$(($seek + $size)) # Jump halfway through the RAID image
 
-	get lv_field $vg/$lv lv_attr | grep '.*-.$'
+	check lv_attr_bit health $vg/$lv "-"
 	check lv_field $vg/$lv raid_mismatch_count "0"
 
 	# Overwrite the last half of one of the PVs with crap
@@ -192,7 +192,7 @@ run_syncaction_check() {
 	# 'lvs' should show results
 	lvchange --syncaction check $vg/$lv
 	aux wait_for_sync $vg $lv
-	get lv_field $vg/$lv lv_attr | grep '.*-.$'
+	check lv_attr_bit health $vg/$lv "-"
 	check lv_field $vg/$lv raid_mismatch_count "0"
 }
 
@@ -220,7 +220,7 @@ run_refresh_check() {
 	sync
 
 	# Check for 'p'artial flag
-	get lv_field $vg/$lv lv_attr | grep '.*p.$'
+	check lv_attr_bit health $vg/$lv "p"
 	dmsetup status
 	lvs -a -o name,attr,devices $vg
 
@@ -230,18 +230,18 @@ run_refresh_check() {
 	lvs -a -o name,attr,devices $vg
 
 	# Check for 'r'efresh flag
-	get lv_field $vg/$lv lv_attr | grep '.*r.$'
+	check lv_attr_bit health $vg/$lv "r"
 
 	lvchange --refresh $vg/$lv
 	aux wait_for_sync $vg $lv
-	get lv_field $vg/$lv lv_attr | grep '.*-.$'
+	check lv_attr_bit health $vg/$lv "-"
 
 	# Writing random data above should mean that the devices
 	# were out-of-sync.  The refresh should have taken care
 	# of properly reintegrating the device.
 	lvchange --syncaction repair $vg/$lv
 	aux wait_for_sync $vg $lv
-	get lv_field $vg/$lv lv_attr | grep '.*-.$'
+	check lv_attr_bit health $vg/$lv "-"
 }
 
 # run_recovery_rate_check <VG> <LV>
diff --git a/test/shell/lvconvert-mirror-basic.sh b/test/shell/lvconvert-mirror-basic.sh
index 28258b2..49d32aa 100644
--- a/test/shell/lvconvert-mirror-basic.sh
+++ b/test/shell/lvconvert-mirror-basic.sh
@@ -77,7 +77,7 @@ test_lvconvert() {
 		fi
 
 		lvcreate -aey -l2 --type mirror -m $start_count --mirrorlog $start_log_type \
-			-n $lv1 $vg $alloc
+			--nosync -n $lv1 $vg $alloc
 		check mirror_legs $vg $lv1 $start_count_p1
 		# FIXME: check mirror log
 	else
diff --git a/test/shell/lvcreate-pvtags.sh b/test/shell/lvcreate-pvtags.sh
index 340a4f4..1df07fc 100644
--- a/test/shell/lvcreate-pvtags.sh
+++ b/test/shell/lvcreate-pvtags.sh
@@ -31,10 +31,10 @@ not lvcreate -l4 -i4 $vg @fast
 not lvcreate -l2 -i2 $vg "$DM_DEV_DIR/mapper/pv1"
 
 # lvcreate mirror
-lvcreate -aey -l1 --type mirror -m1 $vg @fast
+lvcreate -aey -l1 --type mirror -m1 --nosync $vg @fast
 
 # lvcreate mirror w/corelog
-lvcreate -aey -l1 --type mirror -m2 --corelog $vg @fast
+lvcreate -aey -l1 --type mirror -m2 --corelog --nosync $vg @fast
 
 # lvcreate mirror w/no free PVs
 not lvcreate -aey -l1 --type mirror -m2 $vg @fast
diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index 15cf09f..d0d365f 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -12,11 +12,7 @@
 . lib/test
 
 lv_devices() {
-	local local_vg=$1
-	local local_lv=$2
-	local count=$3
-
-	[ $count == `lvs --noheadings -o devices $local_vg/$local_lv | sed s/,/' '/g | wc -w` ]
+	test $3 -eq $(get lv_devices $1/$2 | wc -w)
 }
 
 ########################################################
@@ -47,10 +43,10 @@ lvremove -ff $vg
 
 # Create RAID1 (explicit 3-way) - Set min/max recovery rate
 lvcreate --type raid1 -m 2 -l 2 \
-	--minrecoveryrate 50 --maxrecoveryrate 100 \
+	--minrecoveryrate 50 --maxrecoveryrate 1M \
 	-n $lv1 $vg
 check lv_field $vg/$lv1 raid_min_recovery_rate 50
-check lv_field $vg/$lv1 raid_max_recovery_rate 100
+check lv_field $vg/$lv1 raid_max_recovery_rate 1024
 aux wait_for_sync $vg $lv1
 lvremove -ff $vg
 
@@ -70,10 +66,10 @@ for i in raid4 \
 	raid6 raid6_zr raid6_nr raid6_nc; do
 
 	lvcreate --type $i -l 3 -i 3 \
-		--minrecoveryrate 50 --maxrecoveryrate 100 \
+		--minrecoveryrate 50 --maxrecoveryrate 1M \
 		-n $lv1 $vg
 	check lv_field $vg/$lv1 raid_min_recovery_rate 50
-	check lv_field $vg/$lv1 raid_max_recovery_rate 100
+	check lv_field $vg/$lv1 raid_max_recovery_rate 1024
 	aux wait_for_sync $vg $lv1
 	lvremove -ff $vg
 done
@@ -83,86 +79,84 @@ done
 # 6 PVs with 18.5m in each PV.
 # 1 metadata LV = 1 extent   = .5m
 # 1 image = 36+37+37 extents = 55.00m = lv_size
-lvcreate --type raid1 -m 1 -l 100%FREE -n raid1 $vg
+lvcreate --type raid1 -m 1 -l 100%FREE -an -Zn -n raid1 $vg
 check lv_field $vg/raid1 size "55.00m"
 lvremove -ff $vg
 
 # 1 metadata LV = 1 extent
 # 1 image = 36 extents
 # 5 images = 180 extents = 90.00m = lv_size
-lvcreate --type raid5 -i 5 -l 100%FREE -n raid5 $vg
+lvcreate --type raid5 -i 5 -l 100%FREE -an -Zn -n raid5 $vg
 should check lv_field $vg/raid5 size "90.00m"
 #FIXME: Currently allocates incorrectly at 87.50m
 lvremove -ff $vg
 
 # 1 image = 36+37 extents
 # 2 images = 146 extents = 73.00m = lv_size
-lvcreate --type raid5 -i 2 -l 100%FREE -n raid5 $vg
+lvcreate --type raid5 -i 2 -l 100%FREE -an -Zn -n raid5 $vg
 check lv_field $vg/raid5 size "73.00m"
 lvremove -ff $vg
 
 # 1 image = 36 extents
 # 4 images = 144 extents = 72.00m = lv_size
-lvcreate --type raid6 -i 4 -l 100%FREE -n raid6 $vg
+lvcreate --type raid6 -i 4 -l 100%FREE -an -Zn -n raid6 $vg
 should check lv_field $vg/raid6 size "72.00m"
 #FIXME: Currnently allocates incorrectly at 70.00m
 lvremove -ff $vg
 
-# Eat 18 of 37 extents from dev1, leaving 19
-lvcreate -l 18 -n lv $vg "$dev1"
+###
+# For following tests eat 18 of 37 extents from dev1, leaving 19
+lvcreate -l 18 -an -Zn -n eat_space $vg "$dev1"
+EAT_SIZE=$(get lv_field $vg/eat_space size)
+
 # Using 100% free should take the rest of dev1 and equal from dev2
 # 1 meta takes 1 extent
 # 1 image = 18 extents = 9.00m = lv_size
-lvcreate --type raid1 -m 1 -l 100%FREE -n raid1 $vg "$dev1" "$dev2"
+lvcreate --type raid1 -m 1 -l 100%FREE -an -Zn -n raid1 $vg "$dev1" "$dev2"
 check lv_field $vg/raid1 size "9.00m"
 # Ensure image size is the same as the RAID1 size
 check lv_field $vg/raid1 size $(get lv_field $vg/raid1_rimage_0 size -a)
 # Amount remaining in dev2 should equal the amount taken by 'lv' in dev1
-check pv_field "$dev2" pv_free $(get lv_field $vg/lv size)
-lvremove -ff $vg
+check pv_field "$dev2" pv_free "$EAT_SIZE"
+lvremove -ff $vg/raid1
 
-# Eat 18 of 37 extents from dev1, leaving 19
-lvcreate -l 18 -n lv $vg "$dev1"
 # Using 100% free should take the rest of dev1 and equal amount from the rest
 # 1 meta takes 1 extent
 # 1 image = 18 extents = 9.00m
 # 5 images = 90 extents = 45.00m = lv_size
-lvcreate --type raid5 -i 5 -l 100%FREE -n raid5 $vg
+lvcreate --type raid5 -i 5 -l 100%FREE -an -Zn -n raid5 $vg
 check lv_field $vg/raid5 size "45.00m"
 # Amount remaining in dev6 should equal the amount taken by 'lv' in dev1
-check pv_field "$dev6" pv_free `lvs --noheadings -o size $vg/lv`
-lvremove -ff $vg
+check pv_field "$dev6" pv_free "$EAT_SIZE"
+lvremove -ff $vg/raid5
 
-# Eat 18 of 37 extents from dev1, leaving 19
-lvcreate -l 18 -n lv $vg "$dev1"
 # Using 100% free should take the rest of dev1, an equal amount
 # from 2 more devs, and all extents from 3 additional devs
 # 1 meta takes 1 extent
 # 1 image = 18+37 extents
 # 2 images = 110 extents = 55.00m = lv_size
-lvcreate --type raid5 -i 2 -l 100%FREE -n raid5 $vg
+lvcreate --type raid5 -i 2 -l 100%FREE -an -Zn -n raid5 $vg
 check lv_field $vg/raid5 size "55.00m"
-lvremove -ff $vg
+lvremove -ff $vg/raid5
 
 # Let's do some stripe tests too
-# Eat 18 of 37 extents from dev1, leaving 19
-lvcreate -l 18 -n lv $vg "$dev1"
 # Using 100% free should take the rest of dev1 and an equal amount from rest
 # 1 image = 19 extents
 # 6 images = 114 extents = 57.00m = lv_size
-lvcreate -i 6 -l 100%FREE -n stripe $vg
+lvcreate -i 6 -l 100%FREE -an -Zn -n stripe $vg
 check lv_field $vg/stripe size "57.00m"
-lvremove -ff $vg
+lvremove -ff $vg/stripe
 
-# Eat 18 of 37 extents from dev1, leaving 19
-lvcreate -l 18 -n lv $vg "$dev1"
 # Using 100% free should take the rest of dev1, an equal amount from
 #  one more dev, and all of the remaining 4
 # 1 image = 19+37+37 extents
 # 2 images = 186 extents = 93.00m = lv_size
-lvcreate -i 2 -l 100%FREE -n stripe $vg
+lvcreate -i 2 -l 100%FREE -an -Zn -n stripe $vg
 check lv_field $vg/stripe size "93.00m"
+
 lvremove -ff $vg
+# end of use of '$vg/eat_space'
+###
 
 # Create RAID (implicit stripe count based on PV count)
 #######################################################
@@ -173,20 +167,20 @@ not lvcreate --type raid5 -l2 $vg "$dev1" "$dev2"
 not lvcreate --type raid6 -l3 $vg "$dev1" "$dev2" "$dev3" "$dev4"
 
 # Implicit count comes from #PVs given (always 2 for mirror though)
-lvcreate --type raid1 -l1 -n raid1 $vg "$dev1" "$dev2"
+lvcreate --type raid1 -l1 -an -Zn -n raid1 $vg "$dev1" "$dev2"
 lv_devices $vg raid1 2
-lvcreate --type raid5 -l2 -n raid5 $vg "$dev1" "$dev2" "$dev3"
+lvcreate --type raid5 -l2 -an -Zn -n raid5 $vg "$dev1" "$dev2" "$dev3"
 lv_devices $vg raid5 3
-lvcreate --type raid6 -l3 -n raid6 $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+lvcreate --type raid6 -l3 -an -Zn -n raid6 $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 lv_devices $vg raid6 5
 lvremove -ff $vg
 
 # Implicit count comes from total #PVs in VG (always 2 for mirror though)
-lvcreate --type raid1 -l1 -n raid1 $vg
+lvcreate --type raid1 -l1 -an -Zn -n raid1 $vg
 lv_devices $vg raid1 2
-lvcreate --type raid5 -l2 -n raid5 $vg
+lvcreate --type raid5 -l2 -an -Zn -n raid5 $vg
 lv_devices $vg raid5 6
-lvcreate --type raid6 -l3 -n raid6 $vg
+lvcreate --type raid6 -l3 -an -Zn -n raid6 $vg
 lv_devices $vg raid6 6
 
 vgremove -ff $vg
diff --git a/test/shell/lvcreate-raid10.sh b/test/shell/lvcreate-raid10.sh
index 7ce8100..a521794 100644
--- a/test/shell/lvcreate-raid10.sh
+++ b/test/shell/lvcreate-raid10.sh
@@ -12,11 +12,7 @@
 . lib/test
 
 lv_devices() {
-	local local_vg=$1
-	local local_lv=$2
-	local count=$3
-
-	[ $count == `lvs --noheadings -o devices $local_vg/$local_lv | sed s/,/' '/g | wc -w` ]
+	test $3 -eq $(get lv_devices $1/$2 | wc -w)
 }
 
 ########################################################
@@ -41,10 +37,10 @@ lvremove -ff $vg/$lv1
 
 # 2-way mirror, 2-stripes - Set min/max recovery rate
 lvcreate --type raid10 -m 1 -i 2 -l 2 \
-	--minrecoveryrate 50 --maxrecoveryrate 100 \
+	--minrecoveryrate 50 --maxrecoveryrate 1M \
 	-n $lv1 $vg
 check lv_field $vg/$lv1 raid_min_recovery_rate 50
-check lv_field $vg/$lv1 raid_max_recovery_rate 100
+check lv_field $vg/$lv1 raid_max_recovery_rate 1024
 aux wait_for_sync $vg $lv1
 
 # 2-way mirror, 3-stripes
@@ -57,7 +53,7 @@ lvremove -ff $vg
 # 37 extents / device
 # 1 image = 36 extents (1 for meta)
 # 3 images = 108 extents = 54.00m
-lvcreate --type raid10 -i 3 -l 100%FREE -n raid10 $vg
+lvcreate --type raid10 -i 3 -l 100%FREE -an -Zn -n raid10 $vg
 check lv_field $vg/raid10 size "54.00m"
 lvremove -ff $vg
 
@@ -68,12 +64,12 @@ lvremove -ff $vg
 not lvcreate --type raid10 -l2 $vg "$dev1" "$dev2" "$dev3"
 
 # Implicit count comes from #PVs given (always 2-way mirror)
-lvcreate --type raid10 -l2 -n raid10 $vg "$dev1" "$dev2" "$dev3" "$dev4"
+lvcreate --type raid10 -l2 -an -Zn -n raid10 $vg "$dev1" "$dev2" "$dev3" "$dev4"
 lv_devices $vg raid10 4
 lvremove -ff $vg
 
 # Implicit count comes from total #PVs in VG (always 2 for mirror though)
-lvcreate --type raid10 -l2 -n raid10 $vg
+lvcreate --type raid10 -l2 -an -Zn -n raid10 $vg
 lv_devices $vg raid10 6
 lvremove -ff $vg
 
diff --git a/test/shell/snapshots-of-mirrors.sh b/test/shell/snapshots-of-mirrors.sh
index cfb0792..ac5cf85 100644
--- a/test/shell/snapshots-of-mirrors.sh
+++ b/test/shell/snapshots-of-mirrors.sh
@@ -13,9 +13,9 @@
 
 aux prepare_vg 4
 
-# Attempt to create snapshot of a mirror origin - should fail
-lvcreate -aey --type mirror -m 1 -L 10M -n lv $vg
+lvcreate -aey --type mirror -m 1 -L 10M --nosync -n lv $vg
 
+# Create snapshot of a mirror origin
 lvcreate -s $vg/lv -L 10M -n snap
 
 # Down-convert (mirror -> linear) under a snapshot
diff --git a/test/shell/vgsplit-operation.sh b/test/shell/vgsplit-operation.sh
index 201ad17..4291dd4 100644
--- a/test/shell/vgsplit-operation.sh
+++ b/test/shell/vgsplit-operation.sh
@@ -278,7 +278,7 @@ vgremove -ff $vg1
 
 COMM "vgsplit fails splitting 1 mirror + 1 striped LV, only striped LV specified"
 create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
-lvcreate -an -Zn -l 16 -n $lv1 --type mirror -m1 $vg1 "$dev1" "$dev2" "$dev3"
+lvcreate -an -Zn -l 16 -n $lv1 --type mirror --nosync -m1 $vg1 "$dev1" "$dev2" "$dev3"
 lvcreate -an -Zn -l 16 -n $lv2 -i 2 $vg1 "$dev3" "$dev4"
 check pvlv_counts $vg1 4 2 0
 not vgsplit -n $lv2 $vg1 $vg2 2>err
@@ -289,7 +289,7 @@ vgremove -f $vg1
 #
 COMM "vgsplit fails, active mirror involved in split"
 create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
-lvcreate -aey -l 16 -n $lv1 --type mirror -m1 $vg1 "$dev1" "$dev2" "$dev3"
+lvcreate -aey -l 16 -n $lv1 --type mirror --nosync -m1 $vg1 "$dev1" "$dev2" "$dev3"
 lvcreate -l 16 -n $lv2 $vg1 "$dev4"
 lvchange -an $vg1/$lv2
 check pvlv_counts $vg1 4 2 0
@@ -299,7 +299,7 @@ vgremove -f $vg1
 
 COMM "vgsplit succeeds, active mirror not involved in split"
 create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
-lvcreate -aey -l 16 -n $lv1 --type mirror -m1 $vg1 "$dev1" "$dev2" "$dev3"
+lvcreate -aey -l 16 -n $lv1 --type mirror --nosync -m1 $vg1 "$dev1" "$dev2" "$dev3"
 lvcreate -l 16 -n $lv2 $vg1 "$dev4"
 lvchange -an $vg1/$lv2
 check pvlv_counts $vg1 4 2 0


