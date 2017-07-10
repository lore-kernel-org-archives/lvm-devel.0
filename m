From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:32:55 -0400
Subject: master - tests: math drop uncessary $/${}
Message-ID: <201707101232.v6ACWtoe022712@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=146bfb2417de3e6cd719b5aef900bf927a39a0cd
Commit:        146bfb2417de3e6cd719b5aef900bf927a39a0cd
Parent:        72e82b42a9c07293fdfae7ec0a98dd9fe5a0c868
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 6 19:27:04 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: math drop uncessary $/${}

$/${} is unnecessary on arithmetic variables.

Use $((..)) instead of deprecated $[..]
---
 test/shell/lvchange-raid.sh                 |    6 +-
 test/shell/lvconvert-mirror-basic.sh        |    8 +-
 test/shell/lvconvert-raid.sh                |    4 +-
 test/shell/lvconvert-raid456.sh             |    2 +-
 test/shell/metadata-balance.sh              |   84 +++++++++++++-------------
 test/shell/mirror-vgreduce-removemissing.sh |    2 +-
 test/shell/pvcreate-bootloaderarea.sh       |    4 +-
 test/shell/pvcreate-operation-md.sh         |    2 +-
 test/shell/pvcreate-usage.sh                |    8 +-
 test/shell/pvmove-restart.sh                |    2 +-
 test/shell/read-ahead.sh                    |    2 +-
 test/shell/topology-support.sh              |    2 +-
 test/shell/vgextend-usage.sh                |    4 +-
 13 files changed, 65 insertions(+), 65 deletions(-)

diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 2fe011a..ce29768 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -152,15 +152,15 @@ run_syncaction_check() {
 	device=$(get lv_devices $vg/${lv}_rimage_1)
 
 	size=$(get lv_field $vg/${lv}_rimage_1 size -a --units 1k)
-	size=$((${size%\.00k} / 2))
+	size=$(( ${size%\.00k} / 2 ))
 
 	tmp=$(get pv_field "$device" mda_size --units 1k)
 	seek=${tmp%\.00k} # Jump over MDA
 
 	tmp=$(get lv_field $vg/${lv}_rmeta_1 size -a --units 1k)
-	seek=$(($seek + ${tmp%\.00k}))  # Jump over RAID metadata image
+	seek=$(( seek + ${tmp%\.00k} ))  # Jump over RAID metadata image
 
-	seek=$(($seek + $size)) # Jump halfway through the RAID image
+	seek=$(( seek + size )) # Jump halfway through the RAID image
 
 	check lv_attr_bit health $vg/$lv "-"
 	check lv_field $vg/$lv raid_mismatch_count "0"
diff --git a/test/shell/lvconvert-mirror-basic.sh b/test/shell/lvconvert-mirror-basic.sh
index 0b73d8c..0959af8 100644
--- a/test/shell/lvconvert-mirror-basic.sh
+++ b/test/shell/lvconvert-mirror-basic.sh
@@ -44,10 +44,10 @@ log_name_to_count() {
 
 test_lvconvert() {
 	local start_count=$1
-	local start_count_p1=$(($start_count + 1))
+	local start_count_p1=$(( start_count + 1 ))
 	local start_log_type=$2
 	local finish_count=$3
-	local finish_count_p1=$(($finish_count + 1))
+	local finish_count_p1=$(( finish_count + 1 ))
 	local finish_log_type=$4
 	local dev_array=( "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" )
 	local start_log_count
@@ -78,7 +78,7 @@ test_lvconvert() {
 
 	if [ $start_count -gt 0 ]; then
 		# Are there extra devices for the log or do we overlap
-		if [ $(($start_count_p1 + $start_log_count)) -gt ${#dev_array[@]} ]; then
+		if [ $(( start_count_p1 + start_log_count )) -gt ${#dev_array[@]} ]; then
 			alloc="--alloc anywhere"
 		fi
 
@@ -94,7 +94,7 @@ test_lvconvert() {
 	test $active || lvchange -an $vg/$lv1
 
 	# Are there extra devices for the log or do we overlap
-	if [ $(($finish_count_p1 + $finish_log_count)) -gt ${#dev_array[@]} ]; then
+	if [ $(( finish_count_p1 +  finish_log_count )) -gt ${#dev_array[@]} ]; then
 		alloc="--alloc anywhere"
 	fi
 
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index a110ac5..8b4ebf4 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -65,7 +65,7 @@ for i in 1 2 3; do
 
 			lvcreate -aey -l 2 -n $lv1 $vg
 		else
-			lvcreate --type raid1 -m $(($i - 1)) -l 2 -n $lv1 $vg
+			lvcreate --type raid1 -m $(( i - 1 )) -l 2 -n $lv1 $vg
 			aux wait_for_sync $vg $lv1
 		fi
 
@@ -299,7 +299,7 @@ for i in {1..3}; do
 		devices=( $(get_image_pvs $vg $lv1) )
 
 		for k in $(seq "$j"); do
-			index=$((($k + $o) % ($i + 1)))
+			index=$(( ( k +  o ) % ( i + 1 ) ))
 			replace="$replace --replace ${devices[$index]}"
 		done
 		aux wait_for_sync $vg $lv1
diff --git a/test/shell/lvconvert-raid456.sh b/test/shell/lvconvert-raid456.sh
index 0e3f378..43fe503 100644
--- a/test/shell/lvconvert-raid456.sh
+++ b/test/shell/lvconvert-raid456.sh
@@ -53,7 +53,7 @@ for i in $levels; do
 		devices=( $(get_image_pvs $vg $lv1) )
 
 		for k in $(seq $j); do
-			index=$((($k + $o) % $dev_cnt))
+			index=$(( ( k + o ) % dev_cnt ))
 			replace="$replace --replace ${devices[$index]}"
 		done
 		aux wait_for_sync $vg $lv1
diff --git a/test/shell/metadata-balance.sh b/test/shell/metadata-balance.sh
index 3855b88..fe94aed 100644
--- a/test/shell/metadata-balance.sh
+++ b/test/shell/metadata-balance.sh
@@ -31,7 +31,7 @@ for mdacp in 1 2; do
 	check pv_field "$dev2" pv_mda_count $mdacp
 	check pv_field "$dev2" pv_mda_used_count $mdacp
 	if [ $pv_in_vg = 1 ]; then
-		check vg_field $vg vg_mda_count $(($mdacp * 2))
+		check vg_field $vg vg_mda_count $(( mdacp * 2 ))
 		check vg_field $vg vg_mda_used_count $mdacp
 		check vg_field $vg vg_mda_copies unmanaged
 	fi
@@ -39,8 +39,8 @@ for mdacp in 1 2; do
 	check pv_field "$dev1" pv_mda_count $mdacp
 	check pv_field "$dev1" pv_mda_used_count $mdacp
 	if [ $pv_in_vg = 1 ]; then
-		check vg_field $vg vg_mda_count $(($mdacp * 2))
-		check vg_field $vg vg_mda_used_count $(($mdacp * 2))
+		check vg_field $vg vg_mda_count $(( mdacp * 2 ))
+		check vg_field $vg vg_mda_used_count $(( mdacp * 2 ))
 		check vg_field $vg vg_mda_copies unmanaged
 		vgremove -f $vg
 	fi
@@ -75,18 +75,18 @@ for mdacp in 1 2; do
 	vgcreate $vg "$dev1" "$dev2" "$dev3"
 	check vg_field $vg vg_mda_copies unmanaged
 	echo ensure both --vgmetadatacopies and --metadatacopies accepted
-	vgchange --metadatacopies $(($mdacp * 1)) $vg
+	vgchange --metadatacopies $(( mdacp * 1 )) $vg
 	echo --vgmetadatacopies is persistent on disk
 	echo --vgmetadatacopies affects underlying pv mda ignore
-	check vg_field $vg vg_mda_copies $(($mdacp * 1))
-	check vg_field $vg vg_mda_used_count $(($mdacp * 1))
-	vgchange --vgmetadatacopies $(($mdacp * 2)) $vg
-	check vg_field $vg vg_mda_copies $(($mdacp * 2))
-	check vg_field $vg vg_mda_used_count $(($mdacp * 2))
+	check vg_field $vg vg_mda_copies $(( mdacp * 1 ))
+	check vg_field $vg vg_mda_used_count $(( mdacp * 1 ))
+	vgchange --vgmetadatacopies $(( mdacp * 2 )) $vg
+	check vg_field $vg vg_mda_copies $(( mdacp * 2 ))
+	check vg_field $vg vg_mda_used_count $(( mdacp * 2 ))
 	echo allow setting metadatacopies larger than number of PVs
-	vgchange --vgmetadatacopies $(($mdacp * 5)) $vg
-	check vg_field $vg vg_mda_copies $(($mdacp * 5))
-	check vg_field $vg vg_mda_used_count $(($mdacp * 2))
+	vgchange --vgmetadatacopies $(( mdacp * 5 )) $vg
+	check vg_field $vg vg_mda_copies $(( mdacp * 5 ))
+	check vg_field $vg vg_mda_used_count $(( mdacp * 2 ))
 	echo setting to 0 disables automatic balancing
 	vgchange --vgmetadatacopies unmanaged $vg
 	check vg_field $vg vg_mda_copies unmanaged
@@ -99,15 +99,15 @@ for mdacp in 1 2; do
 	check vg_field $vg vg_mda_copies unmanaged
 	vgremove -f $vg
 	echo vgcreate succeeds with a specific number of metadata copies
-	vgcreate --vgmetadatacopies $(($mdacp * 2)) $vg "$dev1" "$dev2"
-	check vg_field $vg vg_mda_copies $(($mdacp * 2))
+	vgcreate --vgmetadatacopies $(( mdacp * 2 )) $vg "$dev1" "$dev2"
+	check vg_field $vg vg_mda_copies $(( mdacp * 2 ))
 	vgremove -f $vg
-	vgcreate --vgmetadatacopies $(($mdacp * 1)) $vg "$dev1" "$dev2"
-	check vg_field $vg vg_mda_copies $(($mdacp * 1))
+	vgcreate --vgmetadatacopies $(( mdacp * 1 )) $vg "$dev1" "$dev2"
+	check vg_field $vg vg_mda_copies $(( mdacp * 1 ))
 	vgremove -f $vg
 	echo vgcreate succeeds with a larger value than total metadatacopies
-	vgcreate --vgmetadatacopies $(($mdacp * 5)) $vg "$dev1" "$dev2"
-	check vg_field $vg vg_mda_copies $(($mdacp * 5))
+	vgcreate --vgmetadatacopies $(( mdacp * 5 )) $vg "$dev1" "$dev2"
+	check vg_field $vg vg_mda_copies $(( mdacp * 5 ))
 	vgremove -f $vg
 	echo vgcreate succeeds with --vgmetadatacopies unmanaged
 	vgcreate --vgmetadatacopies unmanaged $vg "$dev1" "$dev2"
@@ -120,7 +120,7 @@ for mdacp in 1 2; do
 	echo vgcreate succeds with small value of --metadatacopies, ignores mdas
 	vgcreate --vgmetadatacopies 1 $vg "$dev1" "$dev2" "$dev4" "$dev5"
 	check vg_field $vg vg_mda_copies 1
-	check vg_field $vg vg_mda_count $(($mdacp * 4))
+	check vg_field $vg vg_mda_count $(( mdacp * 4 ))
 	check vg_field $vg vg_mda_used_count 1
 	echo Setting a larger value should trigger non-ignore of mdas
 	vgchange --metadatacopies 3 $vg
@@ -128,9 +128,9 @@ for mdacp in 1 2; do
 	check vg_field $vg vg_mda_used_count 3
 	echo Setting all should trigger unignore of all mdas
 	vgchange --vgmetadatacopies all $vg
-	check vg_field $vg vg_mda_count $(($mdacp * 4))
+	check vg_field $vg vg_mda_count $(( mdacp * 4 ))
 	check vg_field $vg vg_mda_copies unmanaged
-	check vg_field $vg vg_mda_used_count $(($mdacp * 4))
+	check vg_field $vg vg_mda_used_count $(( mdacp * 4 ))
 	echo --vgmetadatacopies 0 should be unmanaged for vgchange and vgcreate
 	vgchange --vgmetadatacopies 0 $vg
 	check vg_field $vg vg_mda_copies unmanaged
@@ -145,8 +145,8 @@ for mdacp in 1 2; do
 	pvcreate --metadatacopies $mdacp "$dev1" "$dev2" "$dev4" "$dev5"
 	pvcreate --metadatacopies 0 "$dev3"
 	echo Set a large value of vgmetadatacopies
-	vgcreate --vgmetadatacopies $(($mdacp * 5)) $vg "$dev1" "$dev2" "$dev3"
-	check vg_field $vg vg_mda_copies $(($mdacp * 5))
+	vgcreate --vgmetadatacopies $(( mdacp * 5 )) $vg "$dev1" "$dev2" "$dev3"
+	check vg_field $vg vg_mda_copies $(( mdacp * 5 ))
 	echo Ignore mdas on devices to be used for vgextend
 	echo Large value of vgetadatacopies should automatically un-ignore mdas
 	pvchange --metadataignore y "$dev4" "$dev5"
@@ -156,8 +156,8 @@ for mdacp in 1 2; do
 	check pv_field "$dev5" pv_mda_used_count $mdacp
 	vgremove -f $vg
 	echo Set a small value of vgmetadatacopies
-	vgcreate --vgmetadatacopies $(($mdacp * 1)) $vg "$dev1" "$dev2" "$dev3"
-	check vg_field $vg vg_mda_copies $(($mdacp * 1))
+	vgcreate --vgmetadatacopies $(( mdacp * 1 )) $vg "$dev1" "$dev2" "$dev3"
+	check vg_field $vg vg_mda_copies $(( mdacp * 1 ))
 	echo Ignore mdas on devices to be used for vgextend
 	echo Small value of vgetadatacopies should leave mdas as ignored
 	pvchange --metadataignore y "$dev4" "$dev5"
@@ -172,15 +172,15 @@ for mdacp in 1 2; do
 	echo vgreduce of un-ignored pv w/mda should trigger un-ignore on an mda
 	vgreduce $vg "$dev1" "$dev2" "$dev3"
 	check pv_field "$dev5" pv_mda_used_count $mdacp
-	check vg_field $vg vg_mda_copies $(($mdacp * 1))
+	check vg_field $vg vg_mda_copies $(( mdacp * 1 ))
 	pvunignore_ "$dev1"
 	pvunignore_ "$dev2"
 	echo setting vgmetadatacopies to unmanaged should allow vgextend to add w/out balancing
 	vgchange --vgmetadatacopies unmanaged $vg
 	vgextend $vg "$dev1" "$dev2"
 	check vg_field $vg vg_mda_copies unmanaged
-	check vg_field $vg vg_mda_count $(($mdacp * 3))
-	check vg_field $vg vg_mda_used_count $((mdacp * 3))
+	check vg_field $vg vg_mda_count $(( mdacp * 3 ))
+	check vg_field $vg vg_mda_used_count $(( mdacp * 3 ))
 	check pv_field "$dev1" pv_mda_used_count $mdacp
 	check pv_field "$dev2" pv_mda_used_count $mdacp
 	vgremove -f $vg
@@ -190,18 +190,18 @@ echo Test special situations, vgsplit, vgmerge, etc
 for mdacp in 1 2; do
 	pvcreate --metadatacopies $mdacp "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 	vgcreate --vgmetadatacopies 2 $vg1 "$dev1" "$dev2" "$dev3"
-	vgcreate --vgmetadatacopies $(($mdacp * 1)) $vg2 "$dev4" "$dev5"
+	vgcreate --vgmetadatacopies $(( mdacp * 1 )) $vg2 "$dev4" "$dev5"
 	echo vgsplit/vgmerge preserves value of metadata copies
 	check vg_field $vg1 vg_mda_copies 2
-	check vg_field $vg2 vg_mda_copies $(($mdacp * 1))
+	check vg_field $vg2 vg_mda_copies $(( mdacp * 1 ))
 	vgsplit $vg1 $vg2 "$dev1"
-	check vg_field $vg2 vg_mda_copies $(($mdacp * 1))
+	check vg_field $vg2 vg_mda_copies $(( mdacp * 1 ))
 	vgmerge $vg1 $vg2
 	check vg_field $vg1 vg_mda_copies 2
-	check vg_field $vg1 vg_mda_count $(($mdacp * 5))
+	check vg_field $vg1 vg_mda_count $(( mdacp * 5 ))
 	echo vgsplit into new vg sets proper value of vgmetadatacopies
-	vgsplit --vgmetadatacopies $(($mdacp * 2)) $vg1 $vg2 "$dev1" "$dev2"
-	check vg_field $vg2 vg_mda_copies $(($mdacp * 2))
+	vgsplit --vgmetadatacopies $(( mdacp * 2 )) $vg1 $vg2 "$dev1" "$dev2"
+	check vg_field $vg2 vg_mda_copies $(( mdacp * 2 ))
 	echo vgchange fails if given both vgmetadatacopies and metadatacopies
 	not vgchange --vgmetadatacopies 5 --metadatacopies 7 $vg2
 	vgremove -f $vg1 $vg2
@@ -210,27 +210,27 @@ done
 echo Test combination of --vgmetadatacopies and pvchange --metadataignore
 for mdacp in 1 2; do
 	pvcreate --metadatacopies $mdacp "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
-	vgcreate --vgmetadatacopies $(($mdacp * 1)) $vg1 "$dev1" "$dev2"
-	check vg_field $vg1 vg_mda_copies $(($mdacp * 1))
-	check vg_field $vg1 vg_mda_used_count $(($mdacp * 1))
+	vgcreate --vgmetadatacopies $(( mdacp * 1 )) $vg1 "$dev1" "$dev2"
+	check vg_field $vg1 vg_mda_copies $(( mdacp * 1 ))
+	check vg_field $vg1 vg_mda_used_count $(( mdacp * 1 ))
 	pvignore_ "$dev3"
 	echo Ensure vgextend of PVs with ignored MDAs does not add to vg_mda_used_count
 	vgextend $vg1 "$dev3"
-	check vg_field $vg1 vg_mda_used_count $(($mdacp * 1))
+	check vg_field $vg1 vg_mda_used_count $(( mdacp * 1 ))
 	echo Using pvchange to unignore should update vg_mda_used_count
 	pvchange -f --metadataignore n "$dev3"
 	check pv_field "$dev3" pv_mda_used_count $mdacp
-	check vg_field $vg1 vg_mda_used_count $(($mdacp * 2))
+	check vg_field $vg1 vg_mda_used_count $(( mdacp * 2 ))
 	echo Set unmanaged on the vg should keep ignore bits the same during vgextend
 	vgchange --vgmetadatacopies unmanaged $vg1
-	check vg_field $vg1 vg_mda_used_count $(($mdacp * 2))
+	check vg_field $vg1 vg_mda_used_count $(( mdacp * 2 ))
 	pvunignore_ "$dev4"
 	vgextend $vg1 "$dev4"
 	check pv_field "$dev4" pv_mda_used_count $mdacp
-	check vg_field $vg1 vg_mda_used_count $(($mdacp * 3))
+	check vg_field $vg1 vg_mda_used_count $(( mdacp * 3 ))
 	echo Using pvchange to ignore should update vg_mda_used_count
 	pvchange -f --metadataignore y "$dev4"
 	check pv_field "$dev4" pv_mda_used_count 0
-	check vg_field $vg1 vg_mda_used_count $(($mdacp * 2))
+	check vg_field $vg1 vg_mda_used_count $(( mdacp * 2 ))
 	vgremove -f $vg1
 done
diff --git a/test/shell/mirror-vgreduce-removemissing.sh b/test/shell/mirror-vgreduce-removemissing.sh
index ac7303f..3d9ecd5 100644
--- a/test/shell/mirror-vgreduce-removemissing.sh
+++ b/test/shell/mirror-vgreduce-removemissing.sh
@@ -83,7 +83,7 @@ rest_pvs_()
 	local n
 	local dev
 
-	for n in $(seq 1 $(($index - 1))) $(seq $(($index + 1)) $num); do
+	for n in $(seq 1 $(( index - 1 )) ) $(seq $(( index + 1 )) $num); do
 		eval dev=$\dev$n
 		rem="$rem $dev"
 	done
diff --git a/test/shell/pvcreate-bootloaderarea.sh b/test/shell/pvcreate-bootloaderarea.sh
index 258c4cb..1147a3b 100644
--- a/test/shell/pvcreate-bootloaderarea.sh
+++ b/test/shell/pvcreate-bootloaderarea.sh
@@ -30,7 +30,7 @@ check pv_field "$dev1" pe_start "1048576"
 
 #COMM 'pvcreate with booloader area size - test corner cases'
 dev_size=$(pvs -o pv_size --noheadings "$dev1")
-pv_size=$[dev_size - 1048576] # device size - 1m pe_start = area for data
+pv_size=$(( dev_size - 1048576 )) # device size - 1m pe_start = area for data
 
 # try to use the whole data area for bootloader area, remaining data area is zero then (pe_start = pv_size)
 pvcreate --bootloaderareasize ${pv_size}b --dataalignment 1048576b "$dev1"
@@ -39,7 +39,7 @@ check pv_field "$dev1" ba_start 1048576
 check pv_field "$dev1" ba_size $pv_size
 
 # try to use the whole data area for bootloader area only and add one more byte - this must error out
-not pvcreate --bootloaderareasize $[pv_size + 1] --dataalignment 1048576b "$dev1" 2>err
+not pvcreate --bootloaderareasize $(( pv_size + 1 )) --dataalignment 1048576b "$dev1" 2>err
 grep "Bootloader area with data-aligned start must not exceed device size" err
 
 # restoring the PV should also restore the bootloader area correctly
diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index 447b15e..d228ada 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -96,7 +96,7 @@ EOF
 		alignment_offset=0
 
 	# default alignment is 1M, add alignment_offset
-	pv_align=$((1048576+$alignment_offset))
+	pv_align=$(( 1048576 + alignment_offset ))
 	check pv_field "${pvdev}p1" pe_start $pv_align --units b --nosuffix
 
 	pvremove "${pvdev}p1"
diff --git a/test/shell/pvcreate-usage.sh b/test/shell/pvcreate-usage.sh
index 97342ba..f0e6ee6 100644
--- a/test/shell/pvcreate-usage.sh
+++ b/test/shell/pvcreate-usage.sh
@@ -15,7 +15,7 @@ SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 PAGESIZE=$(getconf PAGESIZE)
 # MDA_SIZE_MIN defined in lib/format_text/layout.h
-MDA_SIZE_MIN=$((8*$PAGESIZE))
+MDA_SIZE_MIN=$(( 8 * PAGESIZE ))
 
 . lib/inittest
 
@@ -28,7 +28,7 @@ not pvcreate --setphysicalvolumesize -1024 "$dev1"
 not pvcreate --metadatasize -1024 "$dev1"
 
 #COMM 'pvcreate rejects metadatasize that is less than minimum size'
-not pvcreate --dataalignment $((${MDA_SIZE_MIN}/2))b --metadatasize $((${MDA_SIZE_MIN}/2))b "$dev1" 2>err
+not pvcreate --dataalignment $(( MDA_SIZE_MIN / 2 ))b --metadatasize $(( MDA_SIZE_MIN / 2 ))b "$dev1" 2>err
 grep "Metadata area size too small" err
 
 #COMM 'pvcreate accepts metadatasize that is at least the minimum size'
@@ -193,11 +193,11 @@ for ignore in y n; do
 	echo "vgcreate has proper vg_mda_count and vg_mda_used_count"
 	if [ $pv_in_vg = 1 ]; then
 		vgcreate $vg "$dev1" "$dev2"
-		check vg_field $vg vg_mda_count "$(($mdacp * 2))"
+		check vg_field $vg vg_mda_count $(( mdacp * 2 ))
 		if [ $ignore = y ]; then
 			check vg_field $vg vg_mda_used_count "1"
 		else
-			check vg_field $vg vg_mda_used_count "$(($mdacp * 2))"
+			check vg_field $vg vg_mda_used_count "$(( mdacp * 2 ))"
 		fi
 		check vg_field $vg vg_mda_copies "unmanaged"
 		vgremove $vg
diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index 14806cb..abdcd86 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -55,7 +55,7 @@ j=0
 for i in $lv1 pvmove0 pvmove0_mimage_0 pvmove0_mimage_1 ; do
 	while dmsetup status "$vg-$i"; do
 		dmsetup remove "$vg-$i" || {
-			j=$(($j + 1))
+			j=$(( j + 1 ))
 			test $j -le 100 || die "Cannot take down devices."
 			sleep .1;
 		}
diff --git a/test/shell/read-ahead.sh b/test/shell/read-ahead.sh
index f21c52c..9045de8 100644
--- a/test/shell/read-ahead.sh
+++ b/test/shell/read-ahead.sh
@@ -25,7 +25,7 @@ aux prepare_vg 5
 #COMM "test various read ahead settings (bz450922)"
 lvcreate -l 100%FREE -i5 -I512 -n $lv $vg
 ra=$(get lv_field $vg/$lv lv_kernel_read_ahead --units s --nosuffix)
-test $(( ( $ra / 5 ) * 5 )) -le $ra
+test $(( ( ra / 5 ) * 5 )) -le $ra
 not lvchange -r auto $vg/$lv 2>&1 | grep auto
 check lv_field $vg/$lv lv_read_ahead auto
 lvchange -r 640 $vg/$lv
diff --git a/test/shell/topology-support.sh b/test/shell/topology-support.sh
index 1cb0f49..ffa3fe6 100644
--- a/test/shell/topology-support.sh
+++ b/test/shell/topology-support.sh
@@ -45,7 +45,7 @@ test_snapshot_mount() {
 
 NUM_DEVS=1
 PER_DEV_SIZE=34
-DEV_SIZE=$(($NUM_DEVS*$PER_DEV_SIZE))
+DEV_SIZE=$(( NUM_DEVS * PER_DEV_SIZE ))
 
 # ---------------------------------------------
 # Create "desktop-class" 4K drive
diff --git a/test/shell/vgextend-usage.sh b/test/shell/vgextend-usage.sh
index a3bfa2a..178df4d 100644
--- a/test/shell/vgextend-usage.sh
+++ b/test/shell/vgextend-usage.sh
@@ -127,11 +127,11 @@ for ignore in y n; do
 		check pv_field "$dev2" pv_mda_used_count $mdacp
 	fi
 	echo vg has proper vg_mda_count and vg_mda_used_count
-	check vg_field $vg vg_mda_count $(($mdacp * 2 + 1))
+	check vg_field $vg vg_mda_count $(( mdacp * 2 + 1 ))
 	if [ $ignore = y ]; then
 		check vg_field $vg vg_mda_used_count 1
 	else
-		check vg_field $vg vg_mda_used_count $(($mdacp * 2 + 1))
+		check vg_field $vg vg_mda_used_count $(( mdacp * 2 + 1 ))
 	fi
 	check vg_field $vg vg_mda_copies unmanaged
 	vgremove $vg


