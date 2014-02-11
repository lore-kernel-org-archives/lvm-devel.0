From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Feb 2014 18:01:42 +0000 (UTC)
Subject: master - tests: utilize check and get
Message-ID: <20140211180142.E88CC60E0B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d68e5d5ab9a27fd2dcc70097e0764d335a6e1b90
Commit:        d68e5d5ab9a27fd2dcc70097e0764d335a6e1b90
Parent:        177db48c11d1ac0794d805384b68de70703465b0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 31 13:32:25 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 11 19:00:07 2014 +0100

tests: utilize check and get

Replace some in-test use of lvs commands with their check
and get equivalent.

Advantage is these 'checking' commands are not necessarily always
valiadated via extensive valgrind testing and also the output noice
is significantly reduces since the output of check/get is suppressed.
---
 test/shell/lvchange-raid.sh   |  146 +++++------
 test/shell/process-each-lv.sh |  545 +++++++++--------------------------------
 2 files changed, 187 insertions(+), 504 deletions(-)

diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 91c8e8d..0ee5290 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -19,7 +19,7 @@ THIN_POSTFIX=""
 # Proper mismatch count 1.5.2 upstream,1.3.5 < x < 1.4.0 in RHEL6
 #
 # We will simplify and simple test for 1.5.2 and 1.3.5 < x < 1.4.0
-aux target_at_least dm-raid 1 3 5 && 
+aux target_at_least dm-raid 1 3 5 &&
   ! aux target_at_least dm-raid 1 4 0 ||
   aux target_at_least dm-raid 1 5 2 || skip
 
@@ -29,108 +29,103 @@ aux prepare_vg 6
 
 # run_writemostly_check <VG> <LV>
 run_writemostly_check() {
-	local d0
-	local d1
 	local vg=$1
 	local lv=${2}${THIN_POSTFIX}
+	local segtype=$(get lv_field $vg/$lv segtype -a)
+	local d0=$(get lv_devices $vg/${lv}_rimage_0)
+	local d1=$(get lv_devices $vg/${lv}_rimage_1)
 
 	printf "#\n#\n#\n# %s/%s (%s): run_writemostly_check\n#\n#\n#\n" \
-		$vg $lv `lvs -a --noheadings -o segtype $vg/$lv`
-	d0=`lvs -a --noheadings -o devices $vg/${lv}_rimage_0 | sed s/\(.\)//`
-	d0=$(sed s/^[[:space:]]*// <<< "$d0")
-	d1=`lvs -a --noheadings -o devices $vg/${lv}_rimage_1 | sed s/\(.\)//`
-	d1=$(sed s/^[[:space:]]*// <<< "$d1")
+		$vg $lv $segtype
 
 	# No writemostly flag should be there yet.
-	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*-.$'
-	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_1 | grep '.*-.$'
+	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*-.$'
+	get lv_field $vg/${lv}_rimage_1 lv_attr -a | grep '.*-.$'
 
-	if [ `lvs -a --noheadings -o segtype $vg/$lv` != "raid1" ]; then
+	if [ "$segtype" != "raid1" ]; then
 		not lvchange --writemostly $d0 $vg/$lv
 		return
 	fi
 
 	# Set the flag
 	lvchange --writemostly $d0 $vg/$lv
-	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*w.$'
+	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*w.$'
 
 	# Running again should leave it set (not toggle)
 	lvchange --writemostly $d0 $vg/$lv
-	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*w.$'
+	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*w.$'
 
 	# Running again with ':y' should leave it set
 	lvchange --writemostly $d0:y $vg/$lv
-	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*w.$'
+	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*w.$'
 
 	# ':n' should unset it
 	lvchange --writemostly $d0:n $vg/$lv
-	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*-.$'
+	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*-.$'
 
 	# ':n' again should leave it unset
 	lvchange --writemostly $d0:n $vg/$lv
-	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*-.$'
+	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*-.$'
 
 	# ':t' toggle to set
 	lvchange --writemostly $d0:t $vg/$lv
-	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*w.$'
+	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*w.$'
 
 	# ':t' toggle to unset
 	lvchange --writemostly $d0:t $vg/$lv
-	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*-.$'
+	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*-.$'
 
 	# ':y' to set
 	lvchange --writemostly $d0:y $vg/$lv
-	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*w.$'
+	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*w.$'
 
 	# Toggle both at once
 	lvchange --writemostly $d0:t --writemostly $d1:t $vg/$lv
-	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*-.$'
-	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_1 | grep '.*w.$'
+	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*-.$'
+	get lv_field $vg/${lv}_rimage_1 lv_attr -a | grep '.*w.$'
 
 	# Toggle both@once again
 	lvchange --writemostly $d0:t --writemostly $d1:t $vg/$lv
-	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*w.$'
-	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_1 | grep '.*-.$'
+	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*w.$'
+	get lv_field $vg/${lv}_rimage_1 lv_attr -a | grep '.*-.$'
 
 	# Toggle one, unset the other
 	lvchange --writemostly $d0:n --writemostly $d1:t $vg/$lv
-	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*-.$'
-	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_1 | grep '.*w.$'
+	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*-.$'
+	get lv_field $vg/${lv}_rimage_1 lv_attr -a | grep '.*w.$'
 
 	# Toggle one, set the other
 	lvchange --writemostly $d0:y --writemostly $d1:t $vg/$lv
-	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*w.$'
-	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_1 | grep '.*-.$'
+	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*w.$'
+	get lv_field $vg/${lv}_rimage_1 lv_attr -a | grep '.*-.$'
 
 	# Partial flag supercedes writemostly flag
 	aux disable_dev $d0
-	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*p.$'
+	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*p.$'
 
 	# It is possible for the kernel to detect the failed device before
 	# we re-enable it.  If so, the field will be set to 'r'efresh since
 	# that also takes precedence over 'w'ritemostly.  If this has happened,
 	# we refresh the LV and then check for 'w'.
 	aux enable_dev $d0
-	if lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*r.$'; then
-		lvchange --refresh $vg/$lv
-	fi
-	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*w.$'
+	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*r.$' && lvchange --refresh $vg/$lv
+	get lv_field $vg/${lv}_rimage_0 lv_attr -a | grep '.*w.$'
 
 	# Catch Bad writebehind values
 	not lvchange --writebehind "invalid" $vg/$lv
 	not lvchange --writebehind -256 $vg/$lv
 
 	# Set writebehind
-	[ ! `lvs --noheadings -o raid_write_behind $vg/$lv` ]
+	check lv_field $vg/$lv raid_write_behind ""
 	lvchange --writebehind 512 $vg/$lv
-	[ `lvs --noheadings -o raid_write_behind $vg/$lv` -eq 512 ]
+	check lv_field $vg/$lv raid_write_behind "512"
 
 	# Converting to linear should clear flags and writebehind
 	lvconvert -m 0 $vg/$lv $d1
 	lvconvert --type raid1 -m 1 $vg/$lv $d1
-	[ ! `lvs --noheadings -o raid_write_behind $vg/$lv` ]
-	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*-.$'
-	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_1 | grep '.*-.$'
+	check lv_field $vg/$lv raid_write_behind ""
+	get lv_field $vg/${lv}_rimage_0 lv_attr -a  | grep '.*-.$'
+	get lv_field $vg/${lv}_rimage_1 lv_attr -a  | grep '.*-.$'
 }
 
 # run_syncaction_check <VG> <LV>
@@ -143,33 +138,29 @@ run_syncaction_check() {
 	local lv=${2}${THIN_POSTFIX}
 
 	printf "#\n#\n#\n# %s/%s (%s): run_syncaction_check\n#\n#\n#\n" \
-		$vg $lv `lvs -a --noheadings -o segtype $vg/$lv`
+		$vg $lv $(get lv_field $vg/$lv segtype -a)
 	aux wait_for_sync $vg $lv
 
-	device=`lvs -a --noheadings -o devices $vg/${lv}_rimage_1 | sed s/\(.\)//`
-	device=$(sed s/^[[:space:]]*// <<< "$device")
+	device=$(get lv_devices $vg/${lv}_rimage_1)
 
-	size=`lvs -a --noheadings -o size --units 1k $vg/${lv}_rimage_1 | sed s/\.00k//`
-	size=$(sed s/^[[:space:]]*// <<< "$size")
-	size=$(($size / 2))
+	size=$(get lv_field $vg/${lv}_rimage_1 size -a --units 1k)
+	size=$((${size%\.00k} / 2))
 
-	tmp=`pvs --noheadings -o mda_size --units 1k $device | sed s/\.00k//`
-	tmp=$(sed s/^[[:space:]]*// <<< "$tmp")
-	seek=$tmp  # Jump over MDA
+	tmp=$(get pv_field $device mda_size --units 1k)
+	seek=${tmp%\.00k} # Jump over MDA
 
-	tmp=`lvs -a --noheadings -o size --units 1k $vg/${lv}_rmeta_1 | sed s/\.00k//`
-	tmp=$(sed s/^[[:space:]]*// <<< "$tmp")
-	seek=$(($seek + $tmp))  # Jump over RAID metadata image
+	tmp=$(get lv_field $vg/${lv}_rmeta_1 size -a --units 1k)
+	seek=$(($seek + ${tmp%\.00k}))  # Jump over RAID metadata image
 
 	seek=$(($seek + $size)) # Jump halfway through the RAID image
 
-	lvs --noheadings -o lv_attr $vg/$lv | grep '.*-.$'
-	[ `lvs --noheadings -o raid_mismatch_count $vg/$lv` == 0 ]
+	get lv_field $vg/$lv lv_attr | grep '.*-.$'
+	check lv_field $vg/$lv raid_mismatch_count "0"
 
 	# Overwrite the last half of one of the PVs with crap
 	dd if=/dev/urandom of=$device bs=1k count=$size seek=$seek
 
-	if [ ! -z $THIN_POSTFIX ]; then
+	if [ -n "$THIN_POSTFIX" ]; then
 		#
 		# Seems to work fine on real devices,
 		# but can't make the system notice the bad blocks
@@ -189,12 +180,11 @@ run_syncaction_check() {
 	# 'lvs' should show results
 	lvchange --syncaction check $vg/$lv
 	aux wait_for_sync $vg $lv
-	if ! lvs --noheadings -o lv_attr $vg/$lv | grep '.*m.$'; then
-		lvs --noheadings -o lv_attr $vg/$lv
+	if ! get lv_field $vg/$lv lv_attr -a | grep '.*m.$'; then
 		dmsetup status | grep $vg
 		false
 	fi
-	[ `lvs --noheadings -o raid_mismatch_count $vg/$lv` != 0 ]
+	not check lv_field $vg/$lv raid_mismatch_count "0"
 
 	# "repair" will fix discrepancies
 	lvchange --syncaction repair $vg/$lv
@@ -204,40 +194,35 @@ run_syncaction_check() {
 	# 'lvs' should show results
 	lvchange --syncaction check $vg/$lv
 	aux wait_for_sync $vg $lv
-	lvs --noheadings -o lv_attr $vg/$lv | grep '.*-.$'
-	[ `lvs --noheadings -o raid_mismatch_count $vg/$lv` == 0 ]
+	get lv_field $vg/$lv lv_attr | grep '.*-.$'
+	check lv_field $vg/$lv raid_mismatch_count "0"
 }
 
 # run_refresh_check <VG> <LV>
 #   Assumes "$dev2" is in the array
 run_refresh_check() {
 	local size
+	local sizelv
 	local vg=$1
 	local lv=${2}${THIN_POSTFIX}
 
 	printf "#\n#\n#\n# %s/%s (%s): run_refresh_check\n#\n#\n#\n" \
-		$vg $lv `lvs -a --noheadings -o segtype $vg/$lv`
+		$vg $lv $(get lv_field $vg/$lv segtype -a)
 
 	aux wait_for_sync $vg $lv
 
-	if [ -z $THIN_POSTFIX ]; then
-		size=`lvs -a --noheadings -o size --units 1k $vg/$lv | sed s/\.00k//`
-	else
-		size=`lvs -a --noheadings -o size --units 1k $vg/thinlv | sed s/\.00k//`
-	fi
-	size=$(sed s/^[[:space:]]*// <<< "$size")
+	sizelv=$vg/$lv
+	test -z "$THIN_POSTFIX" || sizelv=$vg/thinlv
+	size=$(get lv_field $sizelv size --units 1k)
+	size=${size%\.00k}
 
 	# Disable dev2 and do some I/O to make the kernel notice
 	aux disable_dev "$dev2"
-	if [ -z $THIN_POSTFIX ]; then
-		dd if=/dev/urandom of=/dev/$vg/$lv bs=1k count=$size
-	else
-		dd if=/dev/urandom of=/dev/$vg/thinlv bs=1k count=$size
-		sync; sync; sync
-	fi
+	dd if=/dev/urandom of=/dev/$sizelv bs=1k count=$size
+	sync
 
 	# Check for 'p'artial flag
-	lvs --noheadings -o lv_attr $vg/$lv | grep '.*p.$'
+	get lv_field $vg/$lv lv_attr | grep '.*p.$'
 	dmsetup status
 	lvs -a -o name,attr,devices $vg
 
@@ -247,18 +232,18 @@ run_refresh_check() {
 	lvs -a -o name,attr,devices $vg
 
 	# Check for 'r'efresh flag
-	lvs --noheadings -o lv_attr $vg/$lv | grep '.*r.$'
+	get lv_field $vg/$lv lv_attr | grep '.*r.$'
 
 	lvchange --refresh $vg/$lv
 	aux wait_for_sync $vg $lv
-	lvs --noheadings -o lv_attr $vg/$lv | grep '.*-.$'
+	get lv_field $vg/$lv lv_attr | grep '.*-.$'
 
 	# Writing random data above should mean that the devices
 	# were out-of-sync.  The refresh should have taken care
 	# of properly reintegrating the device.
 	lvchange --syncaction repair $vg/$lv
 	aux wait_for_sync $vg $lv
-	lvs --noheadings -o lv_attr $vg/$lv | grep '.*-.$'
+	get lv_field $vg/$lv lv_attr | grep '.*-.$'
 }
 
 # run_recovery_rate_check <VG> <LV>
@@ -267,14 +252,13 @@ run_recovery_rate_check() {
 	local vg=$1
 	local lv=${2}${THIN_POSTFIX}
 
-	printf "#\n#\n#\n# %s/%s (%s): run_recovery_rate_check\n#\n#\n#\n" \
-		$vg $lv `lvs -a --noheadings -o segtype $vg/$lv`
-
+	printf "#\n#\n#\n# %s/%s $(%s): run_recovery_rate_check\n#\n#\n#\n" \
+		 $vg $lv $(get lv_field $vg/$lv segtype -a)
 	lvchange --minrecoveryrate 50 $vg/$lv
 	lvchange --maxrecoveryrate 100 $vg/$lv
 
-	[ `lvs --noheadings -o raid_min_recovery_rate $vg/$lv` == "50" ]
-	[ `lvs --noheadings -o raid_max_recovery_rate $vg/$lv` == "100" ]
+	check lv_field $vg/$lv raid_min_recovery_rate "50"
+	check lv_field $vg/$lv raid_max_recovery_rate "100"
 }
 
 # run_checks <VG> <LV> <"-"|snapshot_dev|"thinpool_data"|"thinpool_meta">
@@ -292,7 +276,7 @@ run_checks() {
 		run_refresh_check $1 $2
 		run_recovery_rate_check $1 $2
 	elif [ 'thinpool_data' == $3 ]; then
-		aux target_at_least dm-thin-pool 1 8 0 || return 0
+		aux have_thin 1 8 0 || return 0
 
 		# RAID works EX in cluster
 		# thinpool works EX in cluster
@@ -313,7 +297,7 @@ run_checks() {
 		run_refresh_check $1 $2
 		run_recovery_rate_check $1 $2
 	elif [ 'thinpool_meta' == $3 ]; then
-		aux target_at_least dm-thin-pool 1 8 0 || return 0
+		aux have_thin 1 8 0 || return 0
 		test -e LOCAL_CLVMD && return 0
 		printf "#\n#\n# run_checks: RAID as thinpool metadata\n#\n#\n"
 
diff --git a/test/shell/process-each-lv.sh b/test/shell/process-each-lv.sh
index 0140c26..207f1ba 100644
--- a/test/shell/process-each-lv.sh
+++ b/test/shell/process-each-lv.sh
@@ -36,139 +36,88 @@ aux prepare_devs 10
 # test lvremove vg|lv names
 #
 
-# set up vgs/lvs that we will remove
-vgcreate $vg1 "$dev1" "$dev2"
-vgcreate $vg2 "$dev3" "$dev4"
-vgcreate $vg3 "$dev5" "$dev6"
-vgcreate $vg4 "$dev7" "$dev8"
-vgcreate $vg5 "$dev9" "$dev10"
-lvcreate -l 2 -n $lv1 $vg1
-lvcreate -l 2 -n $lv1 $vg2
-lvcreate -l 2 -n $lv2 $vg2
-lvcreate -l 2 -n $lv1 $vg3
-lvcreate -l 2 -n $lv2 $vg3
-lvcreate -l 2 -n $lv3 $vg3
-lvcreate -l 2 -n $lv1 $vg5
-lvcreate -l 2 -n $lv2 $vg5
-lvcreate -l 2 -n $lv3 $vg5
-lvcreate -l 2 -n $lv4 $vg5
-lvcreate -l 2 -n $lv5 $vg5
-vgchange -an $vg1
-vgchange -an $vg2
-vgchange -an $vg3
-vgchange -an $vg4
-vgchange -an $vg5
+prepare_vgs_() {
+	# set up vgs/lvs that we will remove
+	vgcreate $vg1 "$dev1" "$dev2"
+	vgcreate $vg2 "$dev3" "$dev4"
+	vgcreate $vg3 "$dev5" "$dev6"
+	vgcreate $vg4 "$dev7" "$dev8"
+	vgcreate $vg5 "$dev9" "$dev10"
+	lvcreate -Zn -an -l 2 -n $lv1 $vg1
+	lvcreate -Zn -an -l 2 -n $lv1 $vg2
+	lvcreate -Zn -an -l 2 -n $lv2 $vg2
+	lvcreate -Zn -an -l 2 -n $lv1 $vg3
+	lvcreate -Zn -an -l 2 -n $lv2 $vg3
+	lvcreate -Zn -an -l 2 -n $lv3 $vg3
+	lvcreate -Zn -an -l 2 -n $lv1 $vg5
+	lvcreate -Zn -an -l 2 -n $lv2 $vg5
+	lvcreate -Zn -an -l 2 -n $lv3 $vg5
+	lvcreate -Zn -an -l 2 -n $lv4 $vg5
+	lvcreate -Zn -an -l 2 -n $lv5 $vg5
+}
+
+#
+#
+#
+prepare_vgs_
 
 not lvremove
 not lvremove garbage
 not lvremove $vg1/garbage
 
 lvremove $vg1
-lvs $vg1
-not lvs $vg1/$lv1
+check lv_exists $vg1
+check lv_not_exists $vg1 $lv1
 vgremove $vg1
 
 lvremove $vg2
-lvs $vg2
-not lvs $vg2/$lv1
-not lvs $vg2/$lv2
+check lv_exists $vg2
+check lv_not_exists $vg2 $lv1 $lv2
 vgremove $vg2
 
 lvremove $vg3/$lv1
 lvremove $vg3/$lv2 $vg3/$lv3
-lvs $vg3
-not lvs $vg3/$lv1
-not lvs $vg3/$lv2
-not lvs $vg3/$lv3
+check lv_exists $vg3
+check lv_not_exists $vg3 $lv1 $lv2 $lv3
 vgremove $vg3
 
 lvremove $vg4
-lvs $vg4
+check lv_exists $vg4
 vgremove $vg4
 
 lvremove $vg5/$lv1 $vg5 $vg5/$lv3
-not lvs $vg5/$lv1
-not lvs $vg5/$lv2
-not lvs $vg5/$lv3
-not lvs $vg5/$lv4
-not lvs $vg5/$lv5
+check lv_not_exists $vg5 $lv1 $lv2 $lv3 $lv4 $lv5
 vgremove $vg5
 
 
 #
 # test lvremove vg|lv names from multiple vgs
 #
-
-# set up vgs/lvs that we will remove
-vgcreate $vg1 "$dev1" "$dev2"
-vgcreate $vg2 "$dev3" "$dev4"
-vgcreate $vg3 "$dev5" "$dev6"
-vgcreate $vg4 "$dev7" "$dev8"
-vgcreate $vg5 "$dev9" "$dev10"
-lvcreate -l 2 -n $lv1 $vg1
-lvcreate -l 2 -n $lv1 $vg2
-lvcreate -l 2 -n $lv2 $vg2
-lvcreate -l 2 -n $lv1 $vg3
-lvcreate -l 2 -n $lv2 $vg3
-lvcreate -l 2 -n $lv3 $vg3
-lvcreate -l 2 -n $lv1 $vg5
-lvcreate -l 2 -n $lv2 $vg5
-lvcreate -l 2 -n $lv3 $vg5
-lvcreate -l 2 -n $lv4 $vg5
-lvcreate -l 2 -n $lv5 $vg5
-vgchange -an $vg1
-vgchange -an $vg2
-vgchange -an $vg3
-vgchange -an $vg4
-vgchange -an $vg5
+prepare_vgs_
 
 lvremove $vg2 $vg3/$lv3 $vg5/$lv1
-not lvs $vg2/$lv1
-not lvs $vg2/$lv2
-not lvs $vg3/$lv3
-not lvs $vg5/$lv1
+check lv_not_exists $vg2 $lv1 $lv2
+check lv_not_exists $vg3 $lv3
+check lv_not_exists $vg5 $lv1
 
 lvremove $vg2 $vg1
-not lvs $vg1/$lv1
+check lv_not_exists $vg1 $lv1
 
 lvremove $vg3/$lv1 $vg3 $vg4 $vg5/$lv2
-not lvs $vg3/$lv1
-not lvs $vg3/$lv2
-not lvs $vg5/$lv2
+check lv_not_exists $vg3 $lv1 $lv2
+check lv_not_exists $vg5 $lv2
 
 lvremove $vg5 $vg1 $vg5/$lv3
-not lvs $vg5/$lv3
-not lvs $vg5/$lv4
-not lvs $vg5/$lv5
+check lv_not_exists $vg5 $lv3 $lv4 $lv5
 
-vgremove $vg1
-vgremove $vg2
-vgremove $vg3
-vgremove $vg4
-vgremove $vg5
+vgremove $vg1 $vg2 $vg3 $vg4 $vg5
 
 
 #
 # test lvremove @lvtags
 #
+prepare_vgs_
 
-# set up vgs/lvs that we will remove
-vgcreate $vg1 "$dev1" "$dev2"
-vgcreate $vg2 "$dev3" "$dev4"
-vgcreate $vg3 "$dev5" "$dev6"
-vgcreate $vg4 "$dev7" "$dev8"
-vgcreate $vg5 "$dev9" "$dev10"
-lvcreate -l 2 -n $lv1 $vg1
-lvcreate -l 2 -n $lv1 $vg2
-lvcreate -l 2 -n $lv2 $vg2
-lvcreate -l 2 -n $lv1 $vg3
-lvcreate -l 2 -n $lv2 $vg3
-lvcreate -l 2 -n $lv3 $vg3
-lvcreate -l 2 -n $lv1 $vg5
-lvcreate -l 2 -n $lv2 $vg5
-lvcreate -l 2 -n $lv3 $vg5
-lvcreate -l 2 -n $lv4 $vg5
-lvcreate -l 2 -n $lv5 $vg5
 lvchange --addtag V1L1 $vg1/$lv1
 lvchange --addtag V2L1 $vg2/$lv1
 lvchange --addtag V2L2 $vg2/$lv2
@@ -185,99 +134,52 @@ lvchange --addtag V5L234 $vg5/$lv2
 lvchange --addtag V5L234 $vg5/$lv3
 lvchange --addtag V5L234 $vg5/$lv4
 lvchange --addtag V5L5   $vg5/$lv5
-vgchange -an $vg1
-vgchange -an $vg2
-vgchange -an $vg3
-vgchange -an $vg4
-vgchange -an $vg5
+vgchange -an $vg1 $vg2 $vg3 $vg4 $vg5
 
 # verify all exist
-lvs $vg1/$lv1
-lvs $vg2/$lv1
-lvs $vg2/$lv2
-lvs $vg3/$lv1
-lvs $vg3/$lv2
-lvs $vg3/$lv3
-lvs $vg5/$lv1
-lvs $vg5/$lv2
-lvs $vg5/$lv3
-lvs $vg5/$lv4
-lvs $vg5/$lv5
+check lv_exists $vg1 $lv1
+check lv_exists $vg2 $lv1 $lv2
+check lv_exists $vg3 $lv1 $lv2 $lv3
+check lv_exists $vg5 $lv1 $lv2 $lv3 $lv4 $lv5
 
 lvremove @garbage
 
 lvremove @V3L3A
-not lvs $vg3/$lv3
+check lv_not_exists $vg3 $lv3
 # verify unremoved still exist
-lvs $vg1/$lv1
-lvs $vg2/$lv1
-lvs $vg2/$lv2
-lvs $vg3/$lv1
-lvs $vg3/$lv2
-lvs $vg5/$lv1
-lvs $vg5/$lv2
-lvs $vg5/$lv3
-lvs $vg5/$lv4
-lvs $vg5/$lv5
+check lv_exists $vg1 $lv1
+check lv_exists $vg2 $lv1 $lv2
+check lv_exists $vg3 $lv1 $lv2
+check lv_exists $vg5 $lv1 $lv2 $lv3 $lv4 $lv5
 
 lvremove @V5L234
-not lvs $vg5/$lv2
-not lvs $vg5/$lv3
-not lvs $vg5/$lv4
+check lv_not_exists $vg5 $lv2 $lv3 $lv4
 # verify unremoved still exist
-lvs $vg1/$lv1
-lvs $vg2/$lv1
-lvs $vg2/$lv2
-lvs $vg3/$lv1
-lvs $vg3/$lv2
-lvs $vg5/$lv1
-lvs $vg5/$lv5
+check lv_exists $vg1 $lv1
+check lv_exists $vg2 $lv1 $lv2
+check lv_exists $vg3 $lv1 $lv2
+check lv_exists $vg5 $lv1 $lv5
 
 lvremove @V5L1 @V5L5
-not lvs $vg5/$lv1
-not lvs $vg5/$lv5
+check lv_not_exists $vg5 $lv1 $lv5
 # verify unremoved still exist
-lvs $vg1/$lv1
-lvs $vg2/$lv1
-lvs $vg2/$lv2
-lvs $vg3/$lv1
-lvs $vg3/$lv2
+check lv_exists $vg1 $lv1
+check lv_exists $vg2 $lv1 $lv2
+check lv_exists $vg3 $lv1 $lv2
 
 lvremove @V23 @V1L1 @V3L2
-not lvs $vg1/$lv1
-not lvs $vg2/$lv1
-not lvs $vg2/$lv2
-not lvs $vg3/$lv1
-not lvs $vg3/$lv2
+check lv_not_exists $vg1 $lv1
+check lv_not_exists $vg2 $lv1 $lv2
+check lv_not_exists $vg3 $lv1 $lv2
 
-vgremove $vg1
-vgremove $vg2
-vgremove $vg3
-vgremove $vg4
-vgremove $vg5
+vgremove $vg1 $vg2 $vg3 $vg4 $vg5
 
 
 #
 # test lvremove @vgtags
 #
+prepare_vgs_
 
-# set up vgs/lvs that we will remove
-vgcreate $vg1 "$dev1" "$dev2"
-vgcreate $vg2 "$dev3" "$dev4"
-vgcreate $vg3 "$dev5" "$dev6"
-vgcreate $vg4 "$dev7" "$dev8"
-vgcreate $vg5 "$dev9" "$dev10"
-lvcreate -l 2 -n $lv1 $vg1
-lvcreate -l 2 -n $lv1 $vg2
-lvcreate -l 2 -n $lv2 $vg2
-lvcreate -l 2 -n $lv1 $vg3
-lvcreate -l 2 -n $lv2 $vg3
-lvcreate -l 2 -n $lv3 $vg3
-lvcreate -l 2 -n $lv1 $vg5
-lvcreate -l 2 -n $lv2 $vg5
-lvcreate -l 2 -n $lv3 $vg5
-lvcreate -l 2 -n $lv4 $vg5
-lvcreate -l 2 -n $lv5 $vg5
 vgchange --addtag V1  $vg1
 vgchange --addtag V23 $vg2
 vgchange --addtag V23 $vg3
@@ -285,71 +187,34 @@ vgchange --addtag V35 $vg3
 vgchange --addtag V4  $vg4
 vgchange --addtag V35 $vg5
 vgchange --addtag V5  $vg5
-vgchange -an $vg1
-vgchange -an $vg2
-vgchange -an $vg3
-vgchange -an $vg4
-vgchange -an $vg5
+vgchange -an $vg1 $vg2 $vg3 $vg4 $vg5
 
 lvremove @V4
 # verify unremoved exist
-lvs $vg1/$lv1
-lvs $vg2/$lv1
-lvs $vg2/$lv2
-lvs $vg3/$lv1
-lvs $vg3/$lv2
-lvs $vg3/$lv3
-lvs $vg5/$lv1
-lvs $vg5/$lv2
-lvs $vg5/$lv3
-lvs $vg5/$lv4
-lvs $vg5/$lv5
+check lv_exists $vg1 $lv1
+check lv_exists $vg2 $lv1 $lv2
+check lv_exists $vg3 $lv1 $lv2 $lv3
+check lv_exists $vg5 $lv1 $lv2 $lv3 $lv4 $lv5
 
 lvremove @V5
-not lvs $vg5/$lv1
-not lvs $vg5/$lv2
-not lvs $vg5/$lv3
-not lvs $vg5/$lv4
-not lvs $vg5/$lv5
+check lv_not_exists $vg5 $lv1 $lv2 $lv3 $lv4 $lv5
 # verify unremoved exist
-lvs $vg1/$lv1
-lvs $vg2/$lv1
-lvs $vg2/$lv2
-lvs $vg3/$lv1
-lvs $vg3/$lv2
-lvs $vg3/$lv3
+check lv_exists $vg1 $lv1
+check lv_exists $vg2 $lv1 $lv2
+check lv_exists $vg3 $lv1 $lv2 $lv3
 
 lvremove @V1 @V23
-not lvs $vg1/$lv1
-not lvs $vg2/$lv1
-not lvs $vg2/$lv2
-not lvs $vg3/$lv1
-not lvs $vg3/$lv2
-not lvs $vg3/$lv3
+check lv_not_exists $vg1 $lv1
+check lv_not_exists $vg2 $lv1 $lv2
+check lv_not_exists $vg3 $lv1 $lv2 $lv3
 
-vgremove $vg1
-vgremove $vg2
-vgremove $vg3
-vgremove $vg4
-vgremove $vg5
+vgremove $vg1 $vg2 $vg3 $vg4 $vg5
+
+#
+#
+#
+prepare_vgs_
 
-# set up vgs/lvs that we will remove
-vgcreate $vg1 "$dev1" "$dev2"
-vgcreate $vg2 "$dev3" "$dev4"
-vgcreate $vg3 "$dev5" "$dev6"
-vgcreate $vg4 "$dev7" "$dev8"
-vgcreate $vg5 "$dev9" "$dev10"
-lvcreate -l 2 -n $lv1 $vg1
-lvcreate -l 2 -n $lv1 $vg2
-lvcreate -l 2 -n $lv2 $vg2
-lvcreate -l 2 -n $lv1 $vg3
-lvcreate -l 2 -n $lv2 $vg3
-lvcreate -l 2 -n $lv3 $vg3
-lvcreate -l 2 -n $lv1 $vg5
-lvcreate -l 2 -n $lv2 $vg5
-lvcreate -l 2 -n $lv3 $vg5
-lvcreate -l 2 -n $lv4 $vg5
-lvcreate -l 2 -n $lv5 $vg5
 vgchange --addtag V1  $vg1
 vgchange --addtag V23 $vg2
 vgchange --addtag V23 $vg3
@@ -357,59 +222,26 @@ vgchange --addtag V35 $vg3
 vgchange --addtag V4  $vg4
 vgchange --addtag V35 $vg5
 vgchange --addtag V5  $vg5
-vgchange -an $vg1
-vgchange -an $vg2
-vgchange -an $vg3
-vgchange -an $vg4
-vgchange -an $vg5
 
 lvremove @V35 @V5
-not lvs $vg3/$lv1
-not lvs $vg3/$lv2
-not lvs $vg3/$lv3
-not lvs $vg5/$lv1
-not lvs $vg5/$lv2
-not lvs $vg5/$lv3
-not lvs $vg5/$lv4
-not lvs $vg5/$lv5
+check lv_not_exists $vg3 $lv1 $lv2 /$lv3
+check lv_not_exists $vg5 $lv1 $lv2 $lv3 $lv4 $lv5
 # verify unremoved exist
-lvs $vg1/$lv1
-lvs $vg2/$lv1
-lvs $vg2/$lv2
+check lv_exists $vg1 $lv1
+check lv_exists $vg2 $lv1 $lv2
 
 lvremove @V1 @V23
-not lvs $vg1/$lv1
-not lvs $vg2/$lv1
-not lvs $vg2/$lv2
+check lv_not_exists $vg1 $lv1
+check lv_not_exists $vg2 $lv1 $lv2
 
-vgremove $vg1
-vgremove $vg2
-vgremove $vg3
-vgremove $vg4
-vgremove $vg5
+vgremove $vg1 $vg2 $vg3 $vg4 $vg5
 
 
 #
 # test lvremove vg|lv names and @lvtags
 #
+prepare_vgs_
 
-# set up vgs/lvs that we will remove
-vgcreate $vg1 "$dev1" "$dev2"
-vgcreate $vg2 "$dev3" "$dev4"
-vgcreate $vg3 "$dev5" "$dev6"
-vgcreate $vg4 "$dev7" "$dev8"
-vgcreate $vg5 "$dev9" "$dev10"
-lvcreate -l 2 -n $lv1 $vg1
-lvcreate -l 2 -n $lv1 $vg2
-lvcreate -l 2 -n $lv2 $vg2
-lvcreate -l 2 -n $lv1 $vg3
-lvcreate -l 2 -n $lv2 $vg3
-lvcreate -l 2 -n $lv3 $vg3
-lvcreate -l 2 -n $lv1 $vg5
-lvcreate -l 2 -n $lv2 $vg5
-lvcreate -l 2 -n $lv3 $vg5
-lvcreate -l 2 -n $lv4 $vg5
-lvcreate -l 2 -n $lv5 $vg5
 lvchange --addtag V1L1 $vg1/$lv1
 lvchange --addtag V2L1 $vg2/$lv1
 lvchange --addtag V2L2 $vg2/$lv2
@@ -426,56 +258,27 @@ lvchange --addtag V5L234 $vg5/$lv2
 lvchange --addtag V5L234 $vg5/$lv3
 lvchange --addtag V5L234 $vg5/$lv4
 lvchange --addtag V5L5   $vg5/$lv5
-vgchange -an $vg1
-vgchange -an $vg2
-vgchange -an $vg3
-vgchange -an $vg4
-vgchange -an $vg5
+vgchange -an $vg1 $vg2 $vg3 $vg4 $vg5
 
 lvremove $vg1/$lv1 @V3L2 @V5L234
-not lvs $vg1/$lv1
-not lvs $vg3/$lv2
-not lvs $vg5/$lv2
-not lvs $vg5/$lv3
-not lvs $vg5/$lv4
+check lv_not_exists $vg1 $lv1
+check lv_not_exists $vg3 $lv2
+check lv_not_exists $vg5 $lv2 $lv3 $lv4
 # verify unremoved exist
-lvs $vg2/$lv1
-lvs $vg2/$lv2
-lvs $vg3/$lv1
-lvs $vg3/$lv3
-lvs $vg5/$lv1
-lvs $vg5/$lv5
+check lv_exists $vg2 $lv1 $lv2
+check lv_exists $vg3 $lv1 $lv3
+check lv_exists $vg5 $lv1 $lv5
 
 lvremove $vg2/$lv1 @V23 $vg5/$lv1 @V5L5
 
-vgremove $vg1
-vgremove $vg2
-vgremove $vg3
-vgremove $vg4
-vgremove $vg5
+vgremove $vg1 $vg2 $vg3 $vg4 $vg5
 
 
 #
 # test lvremove vg|lv names and @vgtags
 #
+prepare_vgs_
 
-# set up vgs/lvs that we will remove
-vgcreate $vg1 "$dev1" "$dev2"
-vgcreate $vg2 "$dev3" "$dev4"
-vgcreate $vg3 "$dev5" "$dev6"
-vgcreate $vg4 "$dev7" "$dev8"
-vgcreate $vg5 "$dev9" "$dev10"
-lvcreate -l 2 -n $lv1 $vg1
-lvcreate -l 2 -n $lv1 $vg2
-lvcreate -l 2 -n $lv2 $vg2
-lvcreate -l 2 -n $lv1 $vg3
-lvcreate -l 2 -n $lv2 $vg3
-lvcreate -l 2 -n $lv3 $vg3
-lvcreate -l 2 -n $lv1 $vg5
-lvcreate -l 2 -n $lv2 $vg5
-lvcreate -l 2 -n $lv3 $vg5
-lvcreate -l 2 -n $lv4 $vg5
-lvcreate -l 2 -n $lv5 $vg5
 vgchange --addtag V1  $vg1
 vgchange --addtag V23 $vg2
 vgchange --addtag V23 $vg3
@@ -483,56 +286,24 @@ vgchange --addtag V35 $vg3
 vgchange --addtag V4  $vg4
 vgchange --addtag V35 $vg5
 vgchange --addtag V5  $vg5
-vgchange -an $vg1
-vgchange -an $vg2
-vgchange -an $vg3
-vgchange -an $vg4
-vgchange -an $vg5
 
 lvremove $vg1/$lv1 @V35
-not lvs $vg1/$lv1
-not lvs $vg3/$lv1
-not lvs $vg3/$lv2
-not lvs $vg3/$lv3
-not lvs $vg5/$lv1
-not lvs $vg5/$lv2
-not lvs $vg5/$lv3
-not lvs $vg5/$lv4
-not lvs $vg5/$lv5
+check lv_not_exists $vg1 $lv1
+check lv_not_exists $vg3 $lv1 $lv2 $lv3
+check lv_not_exists $vg5 $lv1 $lv2 $lv3not $lv4 $lv5
 # verify unremoved exist
-lvs $vg2/$lv1
-lvs $vg2/$lv2
+check lv_exists $vg2 $lv1 $lv2
 
 lvremove $vg2/$lv1 @V23 $vg2/$lv2
 
-vgremove $vg1
-vgremove $vg2
-vgremove $vg3
-vgremove $vg4
-vgremove $vg5
+vgremove $vg1 $vg2 $vg3 $vg4 $vg5
 
 
 #
 # test lvremove @lvtags and @vgtags
 #
+prepare_vgs_
 
-# set up vgs/lvs that we will remove
-vgcreate $vg1 "$dev1" "$dev2"
-vgcreate $vg2 "$dev3" "$dev4"
-vgcreate $vg3 "$dev5" "$dev6"
-vgcreate $vg4 "$dev7" "$dev8"
-vgcreate $vg5 "$dev9" "$dev10"
-lvcreate -l 2 -n $lv1 $vg1
-lvcreate -l 2 -n $lv1 $vg2
-lvcreate -l 2 -n $lv2 $vg2
-lvcreate -l 2 -n $lv1 $vg3
-lvcreate -l 2 -n $lv2 $vg3
-lvcreate -l 2 -n $lv3 $vg3
-lvcreate -l 2 -n $lv1 $vg5
-lvcreate -l 2 -n $lv2 $vg5
-lvcreate -l 2 -n $lv3 $vg5
-lvcreate -l 2 -n $lv4 $vg5
-lvcreate -l 2 -n $lv5 $vg5
 lvchange --addtag V1L1 $vg1/$lv1
 lvchange --addtag V2L1 $vg2/$lv1
 lvchange --addtag V2L2 $vg2/$lv2
@@ -557,57 +328,25 @@ vgchange --addtag V35 $vg3
 vgchange --addtag V4  $vg4
 vgchange --addtag V35 $vg5
 vgchange --addtag V5  $vg5
-vgchange -an $vg1
-vgchange -an $vg2
-vgchange -an $vg3
-vgchange -an $vg4
-vgchange -an $vg5
 
 lvremove @V23 @V35
-not lvs $vg2/$lv1
-not lvs $vg2/$lv2
-not lvs $vg3/$lv1
-not lvs $vg3/$lv2
-not lvs $vg3/$lv3
-not lvs $vg5/$lv1
-not lvs $vg5/$lv2
-not lvs $vg5/$lv3
-not lvs $vg5/$lv4
-not lvs $vg5/$lv5
+check lv_not_exists $vg2 $lv1 $lv2
+check lv_not_exists $vg3 $lv1 $lv2 $lv3
+check lv_not_exists $vg5 $lv1 $lv2 $lv3 $lv4 $lv5
 # verify unremoved exist
-lvs $vg1/$lv1
+check lv_exists $vg1 $lv1
 
 lvremove @V1 @V1L1
-not lvs $vg1/$lv1
+check lv_not_exists $vg1 $lv1
 
-vgremove $vg1
-vgremove $vg2
-vgremove $vg3
-vgremove $vg4
-vgremove $vg5
+vgremove $vg1 $vg2 $vg3 $vg4 $vg5
 
 
 #
 # test lvremove vg|lv names and @lvtags and @vgtags
 #
+prepare_vgs_
 
-# set up vgs/lvs that we will remove
-vgcreate $vg1 "$dev1" "$dev2"
-vgcreate $vg2 "$dev3" "$dev4"
-vgcreate $vg3 "$dev5" "$dev6"
-vgcreate $vg4 "$dev7" "$dev8"
-vgcreate $vg5 "$dev9" "$dev10"
-lvcreate -l 2 -n $lv1 $vg1
-lvcreate -l 2 -n $lv1 $vg2
-lvcreate -l 2 -n $lv2 $vg2
-lvcreate -l 2 -n $lv1 $vg3
-lvcreate -l 2 -n $lv2 $vg3
-lvcreate -l 2 -n $lv3 $vg3
-lvcreate -l 2 -n $lv1 $vg5
-lvcreate -l 2 -n $lv2 $vg5
-lvcreate -l 2 -n $lv3 $vg5
-lvcreate -l 2 -n $lv4 $vg5
-lvcreate -l 2 -n $lv5 $vg5
 lvchange --addtag V1L1 $vg1/$lv1
 lvchange --addtag V2L1 $vg2/$lv1
 lvchange --addtag V2L2 $vg2/$lv2
@@ -632,60 +371,26 @@ vgchange --addtag V35 $vg3
 vgchange --addtag V4  $vg4
 vgchange --addtag V35 $vg5
 vgchange --addtag V5  $vg5
-vgchange -an $vg1
-vgchange -an $vg2
-vgchange -an $vg3
-vgchange -an $vg4
-vgchange -an $vg5
 
 lvremove $vg1/$lv1 @V23 @V5L5
-not lvs $vg1/$lv1
-not lvs $vg2/$lv1
-not lvs $vg2/$lv2
-not lvs $vg3/$lv1
-not lvs $vg3/$lv2
-not lvs $vg3/$lv3
-not lvs $vg5/$lv5
+check lv_not_exists $vg1 $lv1
+check lv_not_exists $vg2 $lv1 $lv2
+check lv_not_exists $vg3 $lv1 $lv2 $lv3
+check lv_not_exists $vg5 $lv5
 # verify unremoved exist
-lvs $vg5/$lv1
-lvs $vg5/$lv2
-lvs $vg5/$lv3
-lvs $vg5/$lv4
+check lv_exists $vg5 $lv1 $lv2 $lv3 $lv4
 
 lvremove $vg5/$lv2 @V5L234 @V5
-not lvs $vg5/$lv1
-not lvs $vg5/$lv2
-not lvs $vg5/$lv3
-not lvs $vg5/$lv4
+check lv_not_exists $vg5 $lv1 $lv2 $lv3 $lv4
 
-vgremove $vg1
-vgremove $vg2
-vgremove $vg3
-vgremove $vg4
-vgremove $vg5
+vgremove $vg1 $vg2 $vg3 $vg4 $vg5
 
 
 #
 # test lvs: empty, vg(s), lv(s), vgtag(s), lvtag(s), garbage, combinations
 #
+prepare_vgs_
 
-# set up vgs/lvs that we will remove
-vgcreate $vg1 "$dev1" "$dev2"
-vgcreate $vg2 "$dev3" "$dev4"
-vgcreate $vg3 "$dev5" "$dev6"
-vgcreate $vg4 "$dev7" "$dev8"
-vgcreate $vg5 "$dev9" "$dev10"
-lvcreate -l 2 -n $lv1 $vg1
-lvcreate -l 2 -n $lv1 $vg2
-lvcreate -l 2 -n $lv2 $vg2
-lvcreate -l 2 -n $lv1 $vg3
-lvcreate -l 2 -n $lv2 $vg3
-lvcreate -l 2 -n $lv3 $vg3
-lvcreate -l 2 -n $lv1 $vg5
-lvcreate -l 2 -n $lv2 $vg5
-lvcreate -l 2 -n $lv3 $vg5
-lvcreate -l 2 -n $lv4 $vg5
-lvcreate -l 2 -n $lv5 $vg5
 lvchange --addtag V1L1 $vg1/$lv1
 lvchange --addtag V2L1 $vg2/$lv1
 lvchange --addtag V2L2 $vg2/$lv2
@@ -709,11 +414,6 @@ vgchange --addtag V35 $vg3
 vgchange --addtag V4  $vg4
 vgchange --addtag V35 $vg5
 vgchange --addtag V5  $vg5
-vgchange -an $vg1
-vgchange -an $vg2
-vgchange -an $vg3
-vgchange -an $vg4
-vgchange -an $vg5
 
 # empty
 lvs -o vg_name,lv_name --separator '-' >err
@@ -951,4 +651,3 @@ not grep $vg5-$lv2 err
 not grep $vg5-$lv3 err
 not grep $vg5-$lv4 err
 not grep $vg5-$lv5 err
-


