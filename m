From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue, 27 Aug 2013 21:52:49 +0000 (UTC)
Subject: master - TEST: Add tests for lvchange actions of RAID under thin
Message-ID: <20130827215249.D326A61058@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e72b2d047dd64fca941cc6853c72dfe6b8e52399
Commit:        e72b2d047dd64fca941cc6853c72dfe6b8e52399
Parent:        0799e81ee08a76c877d774b2f7df75ad3ec29897
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Aug 27 16:46:40 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Aug 27 16:46:40 2013 -0500

TEST: Add tests for lvchange actions of RAID under thin

Patch includes RAID1,4,5,6,10 tests for:
- setting writemostly/writebehind
* syncaction changes (i.e. scrubbing operations)
- refresh (i.e. reviving devices after transient failures)
- setting recovery rate (sync I/O throttling)
while the RAID LVs are under a thin-pool (both data and metadata)

* not fully tested because I haven't found a way to force bad
  blocks to be noticed in the testsuite yet.  Works just fine
  when dealing with "real" devices.
---
 test/shell/lvchange-raid.sh |  315 +++++++++++++++++++++++++++----------------
 1 files changed, 197 insertions(+), 118 deletions(-)

diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 715df15..38b9c4c 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -11,6 +11,8 @@
 
 . lib/test
 
+THIN_POSTFIX=""
+
 # Writemostly has been in every version since the begining
 # Device refresh in 1.5.1 upstream and 1.3.4 < x < 1.4.0 in RHEL6
 # Sync action    in 1.5.0 upstream and 1.3.3 < x < 1.4.0 in RHEL6
@@ -21,102 +23,106 @@ aux target_at_least dm-raid 1 3 5 &&
   ! aux target_at_least dm-raid 1 4 0 ||
   aux target_at_least dm-raid 1 5 2 || skip
 
+# DEVICE "$dev6" is reserved for non-RAID LVs that
+# will not undergo failure
 aux prepare_vg 6
 
 # run_writemostly_check <VG> <LV>
 run_writemostly_check() {
 	local d0
 	local d1
+	local vg=$1
+	local lv=${2}${THIN_POSTFIX}
 
 	printf "#\n#\n#\n# %s/%s (%s): run_writemostly_check\n#\n#\n#\n" \
-		$1 $2 `lvs --noheadings -o segtype $1/$2`
-	d0=`lvs -a --noheadings -o devices $1/${2}_rimage_0 | sed s/\(.\)//`
+		$vg $lv `lvs -a --noheadings -o segtype $vg/$lv`
+	d0=`lvs -a --noheadings -o devices $vg/${lv}_rimage_0 | sed s/\(.\)//`
 	d0=$(sed s/^[[:space:]]*// <<< "$d0")
-	d1=`lvs -a --noheadings -o devices $1/${2}_rimage_1 | sed s/\(.\)//`
+	d1=`lvs -a --noheadings -o devices $vg/${lv}_rimage_1 | sed s/\(.\)//`
 	d1=$(sed s/^[[:space:]]*// <<< "$d1")
 
 	# No writemostly flag should be there yet.
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-.$'
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*-.$'
+	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*-.$'
+	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_1 | grep '.*-.$'
 
-	if [ `lvs --noheadings -o segtype $1/$2` != "raid1" ]; then
-		not lvchange --writemostly $d0 $1/$2
+	if [ `lvs -a --noheadings -o segtype $vg/$lv` != "raid1" ]; then
+		not lvchange --writemostly $d0 $vg/$lv
 		return
 	fi
 
 	# Set the flag
-	lvchange --writemostly $d0 $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w.$'
+	lvchange --writemostly $d0 $vg/$lv
+	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*w.$'
 
 	# Running again should leave it set (not toggle)
-	lvchange --writemostly $d0 $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w.$'
+	lvchange --writemostly $d0 $vg/$lv
+	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*w.$'
 
 	# Running again with ':y' should leave it set
-	lvchange --writemostly $d0:y $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w.$'
+	lvchange --writemostly $d0:y $vg/$lv
+	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*w.$'
 
 	# ':n' should unset it
-	lvchange --writemostly $d0:n $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-.$'
+	lvchange --writemostly $d0:n $vg/$lv
+	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*-.$'
 
 	# ':n' again should leave it unset
-	lvchange --writemostly $d0:n $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-.$'
+	lvchange --writemostly $d0:n $vg/$lv
+	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*-.$'
 
 	# ':t' toggle to set
-	lvchange --writemostly $d0:t $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w.$'
+	lvchange --writemostly $d0:t $vg/$lv
+	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*w.$'
 
 	# ':t' toggle to unset
-	lvchange --writemostly $d0:t $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-.$'
+	lvchange --writemostly $d0:t $vg/$lv
+	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*-.$'
 
 	# ':y' to set
-	lvchange --writemostly $d0:y $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w.$'
+	lvchange --writemostly $d0:y $vg/$lv
+	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*w.$'
 
 	# Toggle both at once
-	lvchange --writemostly $d0:t --writemostly $d1:t $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-.$'
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*w.$'
+	lvchange --writemostly $d0:t --writemostly $d1:t $vg/$lv
+	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*-.$'
+	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_1 | grep '.*w.$'
 
 	# Toggle both@once again
-	lvchange --writemostly $d0:t --writemostly $d1:t $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w.$'
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*-.$'
+	lvchange --writemostly $d0:t --writemostly $d1:t $vg/$lv
+	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*w.$'
+	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_1 | grep '.*-.$'
 
 	# Toggle one, unset the other
-	lvchange --writemostly $d0:n --writemostly $d1:t $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-.$'
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*w.$'
+	lvchange --writemostly $d0:n --writemostly $d1:t $vg/$lv
+	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*-.$'
+	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_1 | grep '.*w.$'
 
 	# Toggle one, set the other
-	lvchange --writemostly $d0:y --writemostly $d1:t $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w.$'
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*-.$'
+	lvchange --writemostly $d0:y --writemostly $d1:t $vg/$lv
+	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*w.$'
+	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_1 | grep '.*-.$'
 
 	# Partial flag supercedes writemostly flag
 	aux disable_dev $d0
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*p.$'
+	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*p.$'
 	aux enable_dev $d0
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w.$'
+	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*w.$'
 
 	# Catch Bad writebehind values
-	not lvchange --writebehind "invalid" $1/$2
-	not lvchange --writebehind -256 $1/$2
+	not lvchange --writebehind "invalid" $vg/$lv
+	not lvchange --writebehind -256 $vg/$lv
 
 	# Set writebehind
-	[ ! `lvs --noheadings -o raid_write_behind $1/$2` ]
-	lvchange --writebehind 512 $1/$2
-	[ `lvs --noheadings -o raid_write_behind $1/$2` -eq 512 ]
+	[ ! `lvs --noheadings -o raid_write_behind $vg/$lv` ]
+	lvchange --writebehind 512 $vg/$lv
+	[ `lvs --noheadings -o raid_write_behind $vg/$lv` -eq 512 ]
 
 	# Converting to linear should clear flags and writebehind
-	lvconvert -m 0 $1/$2 $d1
-	lvconvert --type raid1 -m 1 $1/$2 $d1
-	[ ! `lvs --noheadings -o raid_write_behind $1/$2` ]
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-.$'
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*-.$'
+	lvconvert -m 0 $vg/$lv $d1
+	lvconvert --type raid1 -m 1 $vg/$lv $d1
+	[ ! `lvs --noheadings -o raid_write_behind $vg/$lv` ]
+	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*-.$'
+	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_1 | grep '.*-.$'
 }
 
 # run_syncaction_check <VG> <LV>
@@ -125,15 +131,17 @@ run_syncaction_check() {
 	local seek
 	local size
 	local tmp
+	local vg=$1
+	local lv=${2}${THIN_POSTFIX}
 
 	printf "#\n#\n#\n# %s/%s (%s): run_syncaction_check\n#\n#\n#\n" \
-		$1 $2 `lvs --noheadings -o segtype $1/$2`
-	aux wait_for_sync $1 $2
+		$vg $lv `lvs -a --noheadings -o segtype $vg/$lv`
+	aux wait_for_sync $vg $lv
 
-	device=`lvs -a --noheadings -o devices $1/${2}_rimage_1 | sed s/\(.\)//`
+	device=`lvs -a --noheadings -o devices $vg/${lv}_rimage_1 | sed s/\(.\)//`
 	device=$(sed s/^[[:space:]]*// <<< "$device")
 
-	size=`lvs -a --noheadings -o size --units 1k $1/${2}_rimage_1 | sed s/\.00k//`
+	size=`lvs -a --noheadings -o size --units 1k $vg/${lv}_rimage_1 | sed s/\.00k//`
 	size=$(sed s/^[[:space:]]*// <<< "$size")
 	size=$(($size / 2))
 
@@ -141,116 +149,182 @@ run_syncaction_check() {
 	tmp=$(sed s/^[[:space:]]*// <<< "$tmp")
 	seek=$tmp  # Jump over MDA
 
-	tmp=`lvs -a --noheadings -o size --units 1k $1/${2}_rmeta_1 | sed s/\.00k//`
+	tmp=`lvs -a --noheadings -o size --units 1k $vg/${lv}_rmeta_1 | sed s/\.00k//`
 	tmp=$(sed s/^[[:space:]]*// <<< "$tmp")
 	seek=$(($seek + $tmp))  # Jump over RAID metadata image
 
 	seek=$(($seek + $size)) # Jump halfway through the RAID image
 
-	lvs --noheadings -o lv_attr $1/$2 | grep '.*-.$'
-	[ `lvs --noheadings -o raid_mismatch_count $1/$2` == 0 ]
+	lvs --noheadings -o lv_attr $vg/$lv | grep '.*-.$'
+	[ `lvs --noheadings -o raid_mismatch_count $vg/$lv` == 0 ]
 
 	# Overwrite the last half of one of the PVs with crap
 	dd if=/dev/urandom of=$device bs=1k count=$size seek=$seek
 
-	# FIXME: Why is this necessary?  caching effects?
-	# I don't need to do this when testing "real" devices...
-	lvchange -an $1/$2; lvchange -ay $1/$2
+	if [ ! -z $THIN_POSTFIX ]; then
+		#
+		# Seems to work fine on real devices,
+		# but can't make the system notice the bad blocks
+		# in the testsuite - especially when thin is layered
+		# on top of RAID.  In other cases, I can deactivate
+		# and reactivate and it works.  Here, even that doesn't
+		# work.
+		return 0
+		lvchange -an $vg/$2
+		lvchange -ay $vg/$2
+	else
+		lvchange -an $vg/$lv
+		lvchange -ay $vg/$lv
+	fi
 
 	# "check" should find discrepancies but not change them
 	# 'lvs' should show results
-	lvchange --syncaction check $1/$2
-	aux wait_for_sync $1 $2
-	lvs --noheadings -o lv_attr $1/$2 | grep '.*m.$'
-	[ `lvs --noheadings -o raid_mismatch_count $1/$2` != 0 ]
+	lvchange --syncaction check $vg/$lv
+	aux wait_for_sync $vg $lv
+	if ! lvs --noheadings -o lv_attr $vg/$lv | grep '.*m.$'; then
+		lvs --noheadings -o lv_attr $vg/$lv
+		dmsetup status | grep $vg
+		false
+	fi
+	[ `lvs --noheadings -o raid_mismatch_count $vg/$lv` != 0 ]
 
 	# "repair" will fix discrepancies
-	lvchange --syncaction repair $1/$2
-	aux wait_for_sync $1 $2
+	lvchange --syncaction repair $vg/$lv
+	aux wait_for_sync $vg $lv
 
 	# Final "check" should show no mismatches
 	# 'lvs' should show results
-	lvchange --syncaction check $1/$2
-	aux wait_for_sync $1 $2
-	lvs --noheadings -o lv_attr $1/$2 | grep '.*-.$'
-	[ `lvs --noheadings -o raid_mismatch_count $1/$2` == 0 ]
+	lvchange --syncaction check $vg/$lv
+	aux wait_for_sync $vg $lv
+	lvs --noheadings -o lv_attr $vg/$lv | grep '.*-.$'
+	[ `lvs --noheadings -o raid_mismatch_count $vg/$lv` == 0 ]
 }
 
 # run_refresh_check <VG> <LV>
 #   Assumes "$dev2" is in the array
 run_refresh_check() {
 	local size
+	local vg=$1
+	local lv=${2}${THIN_POSTFIX}
 
 	printf "#\n#\n#\n# %s/%s (%s): run_refresh_check\n#\n#\n#\n" \
-		$1 $2 `lvs --noheadings -o segtype $1/$2`
+		$vg $lv `lvs -a --noheadings -o segtype $vg/$lv`
 
-	aux wait_for_sync $1 $2
+	aux wait_for_sync $vg $lv
 
-	size=`lvs -a --noheadings -o size --units 1k $1/$2 | sed s/\.00k//`
+	if [ -z $THIN_POSTFIX ]; then
+		size=`lvs -a --noheadings -o size --units 1k $vg/$lv | sed s/\.00k//`
+	else
+		size=`lvs -a --noheadings -o size --units 1k $vg/thinlv | sed s/\.00k//`
+	fi
 	size=$(sed s/^[[:space:]]*// <<< "$size")
 
 	# Disable dev2 and do some I/O to make the kernel notice
 	aux disable_dev "$dev2"
-	dd if=/dev/urandom of=/dev/$1/$2 bs=1k count=$size
+	if [ -z $THIN_POSTFIX ]; then
+		dd if=/dev/urandom of=/dev/$vg/$lv bs=1k count=$size
+	else
+		dd if=/dev/urandom of=/dev/$vg/thinlv bs=1k count=$size
+		sync; sync; sync
+	fi
 
 	# Check for 'p'artial flag
-	lvs --noheadings -o lv_attr $1/$2 | grep '.*p.$'
+	lvs --noheadings -o lv_attr $vg/$lv | grep '.*p.$'
+	dmsetup status
+	lvs -a -o name,attr,devices $vg
 
 	aux enable_dev "$dev2"
 
+	dmsetup status
+	lvs -a -o name,attr,devices $vg
+
 	# Check for 'r'efresh flag
-	lvs --noheadings -o lv_attr $1/$2 | grep '.*r.$'
+	lvs --noheadings -o lv_attr $vg/$lv | grep '.*r.$'
 
-	lvchange --refresh $1/$2
-	aux wait_for_sync $1 $2
-	lvs --noheadings -o lv_attr $1/$2 | grep '.*-.$'
+	lvchange --refresh $vg/$lv
+	aux wait_for_sync $vg $lv
+	lvs --noheadings -o lv_attr $vg/$lv | grep '.*-.$'
 
 	# Writing random data above should mean that the devices
 	# were out-of-sync.  The refresh should have taken care
-	# of properly reintegrating the device.  If any mismatches
-	# are repaired, it will show up in the 'lvs' output.
-	lvchange --syncaction repair $1/$2
-	aux wait_for_sync $1 $2
-	lvs --noheadings -o lv_attr $1/$2 | grep '.*-.$'
+	# of properly reintegrating the device.
+	lvchange --syncaction repair $vg/$lv
+	aux wait_for_sync $vg $lv
+	lvs --noheadings -o lv_attr $vg/$lv | grep '.*-.$'
 }
 
 # run_recovery_rate_check <VG> <LV>
 #   Assumes "$dev2" is in the array
 run_recovery_rate_check() {
+	local vg=$1
+	local lv=${2}${THIN_POSTFIX}
+
 	printf "#\n#\n#\n# %s/%s (%s): run_recovery_rate_check\n#\n#\n#\n" \
-		$1 $2 `lvs --noheadings -o segtype $1/$2`
+		$vg $lv `lvs -a --noheadings -o segtype $vg/$lv`
 
-	lvchange --minrecoveryrate 50 $1/$2
-	lvchange --maxrecoveryrate 100 $1/$2
+	lvchange --minrecoveryrate 50 $vg/$lv
+	lvchange --maxrecoveryrate 100 $vg/$lv
 
-	[ `lvs --noheadings -o raid_min_recovery_rate $1/$2` == "50" ]
-	[ `lvs --noheadings -o raid_max_recovery_rate $1/$2` == "100" ]
+	[ `lvs --noheadings -o raid_min_recovery_rate $vg/$lv` == "50" ]
+	[ `lvs --noheadings -o raid_max_recovery_rate $vg/$lv` == "100" ]
 }
 
-# run_checks <VG> <LV> [snapshot_dev]
+# run_checks <VG> <LV> <"-"|snapshot_dev|"thinpool_data"|"thinpool_meta">
 run_checks() {
-	# Without snapshots
-	run_writemostly_check $1 $2
+	THIN_POSTFIX=""
 
-	run_syncaction_check $1 $2
+	if [ -z $3 ]; then
+		printf "#\n#\n# run_checks: Too few arguments\n#\n#\n"
+		return 1
+	elif [ '-' == $3 ]; then
+		printf "#\n#\n# run_checks: Simple check\n#\n#\n"
 
-	run_refresh_check $1 $2
-
-	run_recovery_rate_check $1 $2
+		run_writemostly_check $1 $2
+		run_syncaction_check $1 $2
+		run_refresh_check $1 $2
+		run_recovery_rate_check $1 $2
+	elif [ 'thinpool_data' == $3 ]; then
+		aux target_at_least dm-thin-pool 1 8 0 || return 0
+		printf "#\n#\n# run_checks: RAID as thinpool data\n#\n#\n"
 
-	# With snapshots
-	if [ ! -z $3 ]; then
-		lvcreate -s $1/$2 -l 4 -n snap $3
+# Hey, specifying devices for thin allocation doesn't work
+#		lvconvert --thinpool $1/$2 "$dev6"
+		lvcreate -L 2M -n ${2}_meta $1 "$dev6"
+		lvconvert --thinpool $1/$2 --poolmetadata ${2}_meta
+		lvcreate -T $1/$2 -V 1 -n thinlv
+		THIN_POSTFIX="_tdata"
 
 		run_writemostly_check $1 $2
-
 		run_syncaction_check $1 $2
+		run_refresh_check $1 $2
+		run_recovery_rate_check $1 $2
+	elif [ 'thinpool_meta' == $3 ]; then
+		aux target_at_least dm-thin-pool 1 8 0 || return 0
+		printf "#\n#\n# run_checks: RAID as thinpool metadata\n#\n#\n"
 
+		lvrename $1/$2 ${2}_meta
+		lvcreate -L 2M -n $2 $1 "$dev6"
+		lvconvert --thinpool $1/$2 --poolmetadata ${2}_meta
+		lvcreate -T $1/$2 -V 1 -n thinlv
+		THIN_POSTFIX="_tmeta"
+
+		run_writemostly_check $1 $2
+		run_syncaction_check $1 $2
 		run_refresh_check $1 $2
+		run_recovery_rate_check $1 $2
+	elif [ 'snapshot' == $3 ]; then
+		printf "#\n#\n# run_checks: RAID under snapshot\n#\n#\n"
+		lvcreate -s $1/$2 -l 4 -n snap "$dev6"
 
+		run_writemostly_check $1 $2
+		run_syncaction_check $1 $2
+		run_refresh_check $1 $2
 		run_recovery_rate_check $1 $2
 
 		lvremove -ff $1/snap
+	else
+		printf "#\n#\n# run_checks: Invalid argument\n#\n#\n"
+		return 1
 	fi
 }
 
@@ -258,24 +332,29 @@ run_checks() {
 # MAIN
 ########################################################
 
-lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg "$dev1" "$dev2"
-run_checks $vg $lv1 "$dev3"
-lvremove -ff $vg
-
-lvcreate --type raid4 -i 2 -l 4 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev4"
-run_checks $vg $lv1 "$dev5"
-lvremove -ff $vg
-
-lvcreate --type raid5 -i 2 -l 4 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev4"
-run_checks $vg $lv1 "$dev5"
-lvremove -ff $vg
-
-lvcreate --type raid6 -i 3 -l 6 -n $lv1 $vg \
-		"$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
-run_checks $vg $lv1 "$dev6"
-lvremove -ff $vg
-
-lvcreate --type raid10 -m 1 -i 2 -l 4 -n $lv1 $vg \
-		"$dev1" "$dev2" "$dev3" "$dev4"
-run_checks $vg $lv1 "$dev5"
-lvremove -ff $vg
+for i in "-" "snapshot" "thinpool_data" "thinpool_meta"; do
+	lvcreate --type raid1 -m 1 -L 2M -n $lv1 $vg \
+			"$dev1" "$dev2"
+	run_checks $vg $lv1 $i
+	lvremove -ff $vg
+
+	lvcreate --type raid4 -i 2 -L 2M -n $lv1 $vg \
+			"$dev1" "$dev2" "$dev3" "$dev4"
+	run_checks $vg $lv1 $i
+	lvremove -ff $vg
+
+	lvcreate --type raid5 -i 2 -L 2M -n $lv1 $vg \
+			"$dev1" "$dev2" "$dev3" "$dev4"
+	run_checks $vg $lv1 $i
+	lvremove -ff $vg
+
+	lvcreate --type raid6 -i 3 -L 2M -n $lv1 $vg \
+			"$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+	run_checks $vg $lv1 $i
+	lvremove -ff $vg
+
+	lvcreate --type raid10 -m 1 -i 2 -L 2M -n $lv1 $vg \
+			"$dev1" "$dev2" "$dev3" "$dev4"
+	run_checks $vg $lv1 $i
+	lvremove -ff $vg
+done


