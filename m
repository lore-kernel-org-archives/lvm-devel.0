From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Sep 2013 09:23:18 +0000 (UTC)
Subject: master - tests: enhance pvmove testing
Message-ID: <20130916092318.6018360DBE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fbb732bd8eb5308eeb1dc7cc6d747552844018ac
Commit:        fbb732bd8eb5308eeb1dc7cc6d747552844018ac
Parent:        47b7cc6850091aac9d32070ad3c3a727bae5f188
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 16 11:18:31 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 16 11:22:04 2013 +0200

tests: enhance pvmove testing

Rewrite check lv_on  and add new  lv_tree_on
Move more pvmove test unrelated code out to check & get sections
(so they do not obfuscate trace output unnecesserily)

Use new lv_tree_on()
NOTE: unsure how the snapshot origin should be accounted here.

Split pmove-all-segments into separate tests for raid and thins
(so the test output properly shows what has been skipped in test)
---
 test/lib/check.sh                  |   40 ++++-
 test/lib/get.sh                    |   34 ++++
 test/shell/pvmove-all-segtypes.sh  |  300 +++++-----------------------------
 test/shell/pvmove-basic.sh         |  311 ++++++++++++++++--------------------
 test/shell/pvmove-raid-segtypes.sh |   79 +++++++++
 test/shell/pvmove-thin-segtypes.sh |   83 ++++++++++
 6 files changed, 410 insertions(+), 437 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index d3678a9..4847de1 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -1,5 +1,5 @@
 #!/usr/bin/env bash
-# Copyright (C) 2010-2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2010-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -54,14 +54,38 @@ mirror_images_redundant() {
 			$(cat check.tmp.all)
 }
 
+lv_err_list_() {
+	(echo "$2" | not grep -m 1 -q "$1") || \
+		echo "$3 on [ $(echo "$2" | grep "$1" | cut -b3- | tr '\n' ' ')] "
+}
+
+lv_on_diff_() {
+	declare -a devs=("${!1}") # pass in shell array
+	local expect=( "${@:4}" ) # make an array starting from 4th args...
+	local diff_e
+
+	# Find diff between 2 shell arrays, print them as stdin files
+	diff_e=$(diff <(printf "%s\n" "${expect[@]}" | sort | uniq ) <(printf "%s\n" "${devs[@]}") ) ||
+		die "LV $2/$3 $(lv_err_list_ "^>" "${diff_e}" found)$(lv_err_list_ "^<" "${diff_e}" "not found")."
+}
+
+# list devices for given LV
 lv_on() {
-	local lv=$1/$2
-	(lvdevices $lv | grep -F "$3") || \
-		die "LV $lv expected on $3 but is not:" \
-			$(lvdevices $lv)
-	test $(lvdevices $lv | grep -vF "$3" | wc -l) -eq 0 || \
-		die "LV $lv contains unexpected devices:" \
-			$(lvdevices $lv)
+	local devs
+
+	devs=( $(lvdevices "$1/$2" | sort | uniq ) )
+
+	lv_on_diff_ devs[@] "${@}"
+}
+
+# list devices for given LV and all its subdevices
+lv_tree_on() {
+	local devs
+
+	# Get sorted list of devices
+	devs=( $(get lv_tree_devices "$1" "$2") )
+
+	lv_on_diff_ devs[@] "${@}"
 }
 
 mirror_images_on() {
diff --git a/test/lib/get.sh b/test/lib/get.sh
index 7d7c3d2..7b97c06 100644
--- a/test/lib/get.sh
+++ b/test/lib/get.sh
@@ -43,6 +43,40 @@ lv_devices() {
 	lv_field "$1" devices -a "${@:2}" | sed 's/([^)]*)//g; s/,/\n/g'
 }
 
+lv_field_lv_() {
+	lv_field "$1" "$2" -a --unbuffered | sed 's/\[//; s/]//'
+}
+
+lv_tree_devices_() {
+	local lv="$1/$2"
+	local type=$(lv_field "$lv" segtype -a --unbuffered | head -n 1)
+	local orig=$(lv_field_lv_ "$lv" origin)
+	# FIXME: should we count in also origins ?
+	#test -z "$orig" || lv_tree_devices_ $1 $orig
+	case "$type" in
+	linear|striped)
+		lv_devices "$lv"
+		;;
+	mirror|raid*)
+		local log=$(lv_field_lv_ "$lv" mirror_log)
+		test -z "$log" || lv_tree_devices_ "$1" "$log"
+		for i in $(lv_devices "$lv")
+			do lv_tree_devices_ "$1" "$i"; done
+		;;
+	thin)
+		lv_tree_devices_ "$1" "$(lv_field_lv_ $lv pool_lv)"
+		;;
+	thin-pool)
+		lv_tree_devices_ "$1" "$(lv_field_lv_ $lv data_lv)"
+		lv_tree_devices_ "$1" "$(lv_field_lv_ $lv metadata_lv)"
+		;;
+	esac
+}
+
+lv_tree_devices() {
+	lv_tree_devices_ "$@" | sort | uniq
+}
+
 #set -x
 unset LVM_VALGRIND
 "$@"
diff --git a/test/shell/pvmove-all-segtypes.sh b/test/shell/pvmove-all-segtypes.sh
index 8ea9d39..fcd8913 100644
--- a/test/shell/pvmove-all-segtypes.sh
+++ b/test/shell/pvmove-all-segtypes.sh
@@ -9,115 +9,16 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description="ensure pvmove works with all segment types"
+test_description="ensure pvmove works with all common segment types"
 
 . lib/test
 
+test -e LOCAL_CLVMD && skip
 which mkfs.ext2 || skip
 which md5sum || skip
-test -e LOCAL_CLVMD && skip
-
-# ---------------------------------------------------------------------
-# Utilities
-lvdev_() {
-	echo "$DM_DEV_DIR/$1/$2"
-}
-
-# lv_is_on_pvs <VG> <LV> <PV1> <PV2> ...
-lv_is_on_pvs() {
-	local vg=$1
-	local lv_list=( $2 )
-	local new_lv_list=()
-	local run_again=true
-
-	shift 2
-
-	while $run_again; do
-		run_again=false
-		for tmplv in ${lv_list[*]}; do
-			if [[ $(lvs -a --noheadings -o attr $vg/$tmplv) =~ ^[[:space:]]*r.* ]] ||
-			   [[ $(lvs -a --noheadings -o attr $vg/$tmplv) =~ ^[[:space:]]*R.* ]]; then
-				# Expand RAID
-				echo "$tmplv is a RAID LV"
-				new_lv_list=( ${new_lv_list[*]} `lvs -a --noheadings -o name | grep ${tmplv}_r` )
-				run_again=true
-			elif [[ $(lvs -a --noheadings -o attr $vg/$tmplv) =~ ^[[:space:]]*m.* ]] ||
-			     [[ $(lvs -a --noheadings -o attr $vg/$tmplv) =~ ^[[:space:]]*M.* ]]; then
-				# Expand Mirror
-				echo "$tmplv is a mirror LV"
-				new_lv_list=( ${new_lv_list[*]} `lvs -a --noheadings -o devices $vg/$tmplv | sed s/,/' '/g` )
-				new_lv_list=( ${new_lv_list[*]} `lvs -a --noheadings -o mirror_log $vg/$tmplv | sed s/,/' '/g` )
-				run_again=true
-			elif [[ $(lvs -a --noheadings -o attr $vg/$tmplv) =~ ^[[:space:]]*t.* ]]; then
-				# Expand Thin Pool
-				echo "$tmplv is a thin-pool LV"
-				new_lv_list=( ${new_lv_list[*]} `lvs -a --noheadings -o data_lv,metadata_lv $vg/$tmplv | sed s/,/' '/g` )
-				run_again=true
-			elif [[ $(lvs -a --noheadings -o attr $vg/$tmplv) =~ ^[[:space:]]*V.* ]]; then
-				# Expand Thin-LV
-				echo "$tmplv is a thin-LV"
-				new_lv_list=( ${new_lv_list[*]} `lvs -a --noheadings -o pool_lv $vg/$tmplv | sed s/,/' '/g` )
-				run_again=true
-			elif [[ $(lvs -a --noheadings -o attr $vg/$tmplv) =~ ^[[:space:]]*e.* ]] &&
-			     lvs -a --noheadings -o devices $vg/$tmplv | grep $tmplv; then
-				# Expand Thin Pool Meta, which is also RAID
-				echo "$tmplv is a thinpool (RAID) metadata"
-				new_lv_list=( ${new_lv_list[*]} `lvs -a --noheadings -o name | grep ${tmplv}_r` )
-				run_again=true
-			else
-				new_lv_list=( ${new_lv_list[*]} $tmplv )
-			fi
-		done
-		printf "\nOld LV list: ${lv_list[*]}\n\n"
-
-		lv_list=()
-		for tmplv in ${new_lv_list[*]}; do
-			lv_list=( ${lv_list[*]} $(echo $tmplv | sed s/\(.*\)/''/ | sed s/\\[/''/ | sed s/]/''/) )
-		done
-		printf "\nExpanded LV list: ${lv_list[*]}\n\n"
-
-		new_lv_list=()
-	done
-
-	[ -e out-$$ ] && rm out-$$
-	for tmplv in ${lv_list[*]}; do
-		lvs -a -odevices --noheadings $vg/$tmplv | sed 's/,/\n/g' >> out-$$
-	done
-
-	#is on all specified devs
-	for d in $*; do
-		if ! grep "$d(" out-$$; then
-			cat out-$$
-			false
-		fi
-	done
-
-	#isn't on any other dev (we are set -e remember)
-	cat out-$$
-	[ -e tmp-$$ ] && rm tmp-$$
-	for d in $*; do
-		echo "Removing $d"
-		! grep -v "$d(" out-$$ >> tmp-$$
-		mv tmp-$$ out-$$
-		cat out-$$
-	done
-	# out-$$ must be empty - no additional devs allowed
-	[ ! -s out-$$ ]
 
-	rm out-$$
-	return 0
-}
-
-save_dev_sum_() {
-  mkfs.ext2 $1 > /dev/null && md5sum $1 > md5.$(basename $1)
-}
-
-check_dev_sum_() {
-  md5sum -c md5.$(basename $1)
-}
-# ---------------------------------------------------------------------
-
-aux prepare_vg 5 30
+aux prepare_pvs 5 20
+vgcreate -c n -s 256k $vg $(cat DEVICES)
 
 # Each of the following tests does:
 # 1) Create two LVs - one linear and one other segment type
@@ -125,181 +26,68 @@ aux prepare_vg 5 30
 # 2) Move both LVs together
 # 3) Move only the second LV by name
 
-printf "##\n# Testing pvmove of linear LV\n##\n"
+# Testing pvmove of linear LV
 lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
 lvcreate -l 2 -n $lv1 $vg "$dev1"
-lv_is_on_pvs $vg ${lv1}_foo "$dev1"
-lv_is_on_pvs $vg $lv1 "$dev1"
-save_dev_sum_ $(lvdev_ $vg $lv1)
+check lv_tree_on $vg ${lv1}_foo "$dev1"
+check lv_tree_on $vg $lv1 "$dev1"
+aux mkdev_md5sum $vg $lv1
 pvmove "$dev1" "$dev5"
-lv_is_on_pvs $vg ${lv1}_foo "$dev5"
-lv_is_on_pvs $vg $lv1 "$dev5"
-check_dev_sum_ $(lvdev_ $vg $lv1)
+check lv_tree_on $vg ${lv1}_foo "$dev5"
+check lv_tree_on $vg $lv1 "$dev5"
+check dev_md5sum $vg $lv1
 pvmove -n $lv1 "$dev5" "$dev4"
-lv_is_on_pvs $vg $lv1 "$dev4"
-lv_is_on_pvs $vg ${lv1}_foo "$dev5"
-check_dev_sum_ $(lvdev_ $vg $lv1)
+check lv_tree_on $vg $lv1 "$dev4"
+check lv_tree_on $vg ${lv1}_foo "$dev5"
+check dev_md5sum $vg $lv1
 lvremove -ff $vg
 
-printf "##\n# Testing pvmove of stripe LV\n##\n"
+# Testing pvmove of stripe LV
 lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
 lvcreate -l 4 -i 2 -n $lv1 $vg "$dev1" "$dev2"
-lv_is_on_pvs $vg ${lv1}_foo "$dev1"
-lv_is_on_pvs $vg $lv1 "$dev1" "$dev2"
-save_dev_sum_ $(lvdev_ $vg $lv1)
+check lv_tree_on $vg ${lv1}_foo "$dev1"
+check lv_tree_on $vg $lv1 "$dev1" "$dev2"
+aux mkdev_md5sum $vg $lv1
 pvmove "$dev1" "$dev5"
-lv_is_on_pvs $vg ${lv1}_foo "$dev5"
-lv_is_on_pvs $vg $lv1 "$dev2" "$dev5"
-check_dev_sum_ $(lvdev_ $vg $lv1)
+check lv_tree_on $vg ${lv1}_foo "$dev5"
+check lv_tree_on $vg $lv1 "$dev2" "$dev5"
+check dev_md5sum $vg $lv1
 pvmove -n $lv1 "$dev5" "$dev4"
-lv_is_on_pvs $vg $lv1 "$dev2" "$dev4"
-lv_is_on_pvs $vg ${lv1}_foo "$dev5"
-check_dev_sum_ $(lvdev_ $vg $lv1)
+check lv_tree_on $vg $lv1 "$dev2" "$dev4"
+check lv_tree_on $vg ${lv1}_foo "$dev5"
+check dev_md5sum $vg $lv1
 lvremove -ff $vg
 
-printf "##\n# Testing pvmove of mirror LV\n##\n"
+# Testing pvmove of mirror LV
 lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
 lvcreate -l 2 --type mirror -m 1 -n $lv1 $vg "$dev1" "$dev2"
-lv_is_on_pvs $vg ${lv1}_foo "$dev1"
-lv_is_on_pvs $vg $lv1 "$dev1" "$dev2"
-save_dev_sum_ $(lvdev_ $vg $lv1)
+check lv_tree_on $vg ${lv1}_foo "$dev1"
+check lv_tree_on $vg $lv1 "$dev1" "$dev2"
+aux mkdev_md5sum $vg $lv1
 pvmove "$dev1" "$dev5"
-lv_is_on_pvs $vg ${lv1}_foo "$dev5"
-lv_is_on_pvs $vg $lv1 "$dev2" "$dev5"
-check_dev_sum_ $(lvdev_ $vg $lv1)
+check lv_tree_on $vg ${lv1}_foo "$dev5"
+check lv_tree_on $vg $lv1 "$dev2" "$dev5"
+check dev_md5sum $vg $lv1
 pvmove -n $lv1 "$dev5" "$dev4"
-lv_is_on_pvs $vg $lv1 "$dev2" "$dev4"
-lv_is_on_pvs $vg ${lv1}_foo "$dev5"
-check_dev_sum_ $(lvdev_ $vg $lv1)
+check lv_tree_on $vg $lv1 "$dev2" "$dev4"
+check lv_tree_on $vg ${lv1}_foo "$dev5"
+check dev_md5sum $vg $lv1
 lvremove -ff $vg
 
 # Dummy LV and snap share dev1, while origin is on dev2
-printf "##\n# Testing pvmove of snapshot LV\n##\n"
+# Testing pvmove of snapshot LV
 lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
 lvcreate -l 2 -n $lv1 $vg "$dev2"
 lvcreate -s $vg/$lv1 -l 2 -n snap "$dev1"
-lv_is_on_pvs $vg ${lv1}_foo "$dev1"
-lv_is_on_pvs $vg snap "$dev1"
-save_dev_sum_ $(lvdev_ $vg snap)
+check lv_tree_on $vg ${lv1}_foo "$dev1"
+check lv_tree_on $vg snap "$dev1"
+aux mkdev_md5sum $vg snap
 pvmove "$dev1" "$dev5"
-lv_is_on_pvs $vg ${lv1}_foo "$dev5"
-lv_is_on_pvs $vg snap "$dev5"
-check_dev_sum_ $(lvdev_ $vg snap)
+check lv_tree_on $vg ${lv1}_foo "$dev5"
+check lv_tree_on $vg snap "$dev5"
+check dev_md5sum $vg snap
 pvmove -n snap "$dev5" "$dev4"
-lv_is_on_pvs $vg snap "$dev4"
-lv_is_on_pvs $vg ${lv1}_foo "$dev5"
-check_dev_sum_ $(lvdev_ $vg snap)
+check lv_tree_on $vg snap "$dev4"
+check lv_tree_on $vg ${lv1}_foo "$dev5"
+check dev_md5sum $vg snap
 lvremove -ff $vg
-
-##
-# RAID
-##
-if aux target_at_least dm-raid 1 3 5; then
-	printf "##\n# Testing pvmove of RAID1 LV\n##\n"
-	lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
-	lvcreate -l 2 --type raid1 -m 1 -n $lv1 $vg "$dev1" "$dev2"
-	lv_is_on_pvs $vg ${lv1}_foo "$dev1"
-	lv_is_on_pvs $vg $lv1 "$dev1" "$dev2"
-	save_dev_sum_ $(lvdev_ $vg $lv1)
-	pvmove "$dev1" "$dev5"
-	lv_is_on_pvs $vg ${lv1}_foo "$dev5"
-	lv_is_on_pvs $vg $lv1 "$dev2" "$dev5"
-	check_dev_sum_ $(lvdev_ $vg $lv1)
-	pvmove -n $lv1 "$dev5" "$dev4"
-	lv_is_on_pvs $vg $lv1 "$dev2" "$dev4"
-	lv_is_on_pvs $vg ${lv1}_foo "$dev5"
-	check_dev_sum_ $(lvdev_ $vg $lv1)
-	lvremove -ff $vg
-
-	printf "##\n# Testing pvmove of RAID10 LV\n##\n"
-	lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
-	lvcreate -l 4 --type raid10 -i 2 -m 1 -n $lv1 $vg \
-			"$dev1" "$dev2" "$dev3" "$dev4"
-	lv_is_on_pvs $vg ${lv1}_foo "$dev1"
-	lv_is_on_pvs $vg $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
-	save_dev_sum_ $(lvdev_ $vg $lv1)
-	pvmove "$dev1" "$dev5"
-	lv_is_on_pvs $vg ${lv1}_foo "$dev5"
-	lv_is_on_pvs $vg $lv1 "$dev2" "$dev3" "$dev4" "$dev5"
-	check_dev_sum_ $(lvdev_ $vg $lv1)
-	pvmove -n $lv1 "$dev5" "$dev1"
-	lv_is_on_pvs $vg $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
-	lv_is_on_pvs $vg ${lv1}_foo "$dev5"
-	check_dev_sum_ $(lvdev_ $vg $lv1)
-	lvremove -ff $vg
-
-	printf "##\n# Testing pvmove of RAID5 LV\n##\n"
-	lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
-	lvcreate -l 4 --type raid5 -i 2 -n $lv1 $vg \
-			"$dev1" "$dev2" "$dev3"
-	lv_is_on_pvs $vg ${lv1}_foo "$dev1"
-	lv_is_on_pvs $vg $lv1 "$dev1" "$dev2" "$dev3"
-	save_dev_sum_ $(lvdev_ $vg $lv1)
-	pvmove "$dev1" "$dev5"
-	lv_is_on_pvs $vg ${lv1}_foo "$dev5"
-	lv_is_on_pvs $vg $lv1 "$dev2" "$dev3" "$dev5"
-	check_dev_sum_ $(lvdev_ $vg $lv1)
-	pvmove -n $lv1 "$dev5" "$dev4"
-	lv_is_on_pvs $vg $lv1 "$dev2" "$dev3" "$dev4"
-	lv_is_on_pvs $vg ${lv1}_foo "$dev5"
-	check_dev_sum_ $(lvdev_ $vg $lv1)
-	lvremove -ff $vg
-fi
-
-##
-# Thin
-##
-if aux target_at_least dm-thin-pool 1 8 0; then
-
-	printf "##\n# Testing pvmove of thin-pool LV\n##\n"
-	lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
-	lvcreate -T $vg/$lv1 -l 4 "$dev1"
-	lv_is_on_pvs $vg ${lv1}_foo "$dev1"
-	lv_is_on_pvs $vg $lv1 "$dev1"
-	save_dev_sum_ $(lvdev_ $vg $lv1)
-	pvmove "$dev1" "$dev5"
-	lv_is_on_pvs $vg ${lv1}_foo "$dev5"
-	lv_is_on_pvs $vg $lv1 "$dev5"
-	check_dev_sum_ $(lvdev_ $vg $lv1)
-	pvmove -n $lv1 "$dev5" "$dev4"
-	lv_is_on_pvs $vg $lv1 "$dev4"
-	lv_is_on_pvs $vg ${lv1}_foo "$dev5"
-	check_dev_sum_ $(lvdev_ $vg $lv1)
-	lvremove -ff $vg
-
-	printf "##\n# Testing pvmove of thin LV\n##\n"
-	lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
-	lvcreate -T $vg/${lv1}_pool -l 4 -V 8 -n $lv1 "$dev1"
-	lv_is_on_pvs $vg ${lv1}_foo "$dev1"
-	lv_is_on_pvs $vg $lv1 "$dev1"
-	save_dev_sum_ $(lvdev_ $vg $lv1)
-	pvmove "$dev1" "$dev5"
-	lv_is_on_pvs $vg ${lv1}_foo "$dev5"
-	lv_is_on_pvs $vg $lv1 "$dev5"
-	check_dev_sum_ $(lvdev_ $vg $lv1)
-	pvmove -n $lv1 "$dev5" "$dev4"
-	lv_is_on_pvs $vg $lv1 "$dev4"
-	lv_is_on_pvs $vg ${lv1}_foo "$dev5"
-	check_dev_sum_ $(lvdev_ $vg $lv1)
-	lvremove -ff $vg
-
-	printf "##\n# Testing pvmove of thin LV on RAID\n##\n"
-	lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
-	lvcreate --type raid1 -m 1 -l 4 -n ${lv1}_raid1_pool $vg "$dev1" "$dev2"
-	lvcreate --type raid1 -m 1 -l 4 -n ${lv1}_raid1_meta $vg "$dev1" "$dev2"
-	lvconvert --thinpool $vg/${lv1}_raid1_pool \
-		--poolmetadata ${lv1}_raid1_meta
-	lvcreate -T $vg/${lv1}_raid1_pool -V 8 -n $lv1
-	lv_is_on_pvs $vg ${lv1}_foo "$dev1"
-	lv_is_on_pvs $vg $lv1 "$dev1" "$dev2"
-	save_dev_sum_ $(lvdev_ $vg $lv1)
-	pvmove "$dev1" "$dev5"
-	lv_is_on_pvs $vg ${lv1}_foo "$dev5"
-	lv_is_on_pvs $vg $lv1 "$dev2" "$dev5"
-	check_dev_sum_ $(lvdev_ $vg $lv1)
-	pvmove -n $lv1 "$dev5" "$dev4"
-	lv_is_on_pvs $vg $lv1 "$dev2" "$dev4"
-	lv_is_on_pvs $vg ${lv1}_foo "$dev5"
-	check_dev_sum_ $(lvdev_ $vg $lv1)
-	lvremove -ff $vg
-fi
diff --git a/test/shell/pvmove-basic.sh b/test/shell/pvmove-basic.sh
index e95fc36..69244be 100644
--- a/test/shell/pvmove-basic.sh
+++ b/test/shell/pvmove-basic.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
 # Copyright (C) 2007 NEC Corporation
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -20,83 +20,67 @@ which md5sum || skip
 # ---------------------------------------------------------------------
 # Utilities
 
-lvdev_() {
-  echo "$DM_DEV_DIR/$1/$2"
+create_vg_() {
+	vgcreate -c n -s 128k $vg $(cat DEVICES)
 }
 
-lv_is_on_() {
-  local lv=$1 #allready vg/lv
-  shift 1
-  lvs -a -odevices --noheadings $lv | sed 's/,/\n/g' > out
-#is on all specified devs
-  for d in $*; do grep "$d(" out; done
-#isn't on any other dev (we are set -e remember)
-  for d in $*; do ! grep -v "$d(" out; done
-  return 0
+# ---------------------------------------------------------------------
+# Common environment setup/cleanup for each sub testcases
+prepare_lvs_() {
+	lvcreate -l2 -n $lv1 $vg "$dev1"
+	check lv_on $vg $lv1 "$dev1"
+	lvcreate -l9 -i3 -n $lv2 $vg "$dev2" "$dev3" "$dev4"
+	check lv_on $vg $lv2 "$dev2" "$dev3" "$dev4"
+	lvextend -l+2 $vg/$lv1 "$dev2"
+	check lv_on $vg $lv1 "$dev1" "$dev2"
+	lvextend -l+2 $vg/$lv1 "$dev3"
+	lvextend -l+2 $vg/$lv1 "$dev1"
+	check lv_on $vg $lv1 "$dev1" "$dev2" "$dev3"
+	lvcreate -l1 -n $lv3 $vg "$dev2"
+	check lv_on $vg $lv3 "$dev2"
+	aux mkdev_md5sum $vg $lv1
+	aux mkdev_md5sum $vg $lv2
+	aux mkdev_md5sum $vg $lv3
+	get lv_devices "$vg/$lv1" > "${lv1}_devs"
+	get lv_devices "$vg/$lv2" > "${lv2}_devs"
+	get lv_devices "$vg/$lv3" > "${lv3}_devs"
+	lvs -a -o name,size,seg_pe_ranges $vg
+	vgcfgbackup -f bak-$$ $vg
 }
 
-save_dev_sum_() {
-  mkfs.ext2 $1 > /dev/null && md5sum $1 > md5.$(basename $1)
+# Restore metadata content, since data are pvmove-ed
+# original content should be preserved
+restore_lvs_() {
+	vgcfgrestore -f bak-$$ $vg
+	vgchange -ay $vg
 }
 
-check_dev_sum_() {
-  md5sum -c md5.$(basename $1)
+lvs_not_changed_() {
+	for i in "${@}"; do
+		get lv_devices "$vg/$i" | tee out
+		diff "${i}_devs" out || \
+			(cat "${i}_devs"; die "Devices for LV $vg/$i differs!")
+	done
 }
 
-create_vg_() {
-  vgcreate -c n -s 128k $vg $(cat DEVICES)
+check_and_cleanup_lvs_() {
+	check dev_md5sum $vg $lv1
+	check dev_md5sum $vg $lv2
+	check dev_md5sum $vg $lv3
+	get lv_field $vg name >out
+	not grep ^pvmove out
+	vgchange -an $vg
+	lvremove -ff $vg
+	(dm_table | not grep $vg) || \
+	      die "ERROR: lvremove did leave some some mappings in DM behind!"
 }
+
 # ---------------------------------------------------------------------
 # Initialize PVs and VGs
 
-#aux prepare_vg 5 30
 aux prepare_pvs 5 5
 create_vg_
 
-# ---------------------------------------------------------------------
-# Common environment setup/cleanup for each sub testcases
-FIRST=""
-
-prepare_lvs_() {
-  lvcreate -l2 -n $lv1 $vg "$dev1"
-    test -z "$FIRST" && lv_is_on_ $vg/$lv1 "$dev1"
-  lvcreate -l9 -i3 -n $lv2 $vg "$dev2" "$dev3" "$dev4"
-    test -z "$FIRST" && lv_is_on_ $vg/$lv2 "$dev2" "$dev3" "$dev4"
-  lvextend -l+2 $vg/$lv1 "$dev2"
-    test -z "$FIRST" && lv_is_on_ $vg/$lv1 "$dev1" "$dev2"
-  lvextend -l+2 $vg/$lv1 "$dev3"
-    test -z "$FIRST" && lv_is_on_ $vg/$lv1 "$dev1" "$dev2" "$dev3"
-  lvextend -l+2 $vg/$lv1 "$dev1"
-    test -z "$FIRST" && lv_is_on_ $vg/$lv1 "$dev1" "$dev2" "$dev3" "$dev1"
-  lvcreate -l1 -n $lv3 $vg "$dev2"
-    test -z "$FIRST" && lv_is_on_ $vg/$lv3 "$dev2"
-  save_dev_sum_ $(lvdev_ $vg $lv1)
-  save_dev_sum_ $(lvdev_ $vg $lv2)
-  save_dev_sum_ $(lvdev_ $vg $lv3)
-  if test -z "$FIRST" ; then
-    get lv_field $vg/$lv1 devices > ${lv1}_devs
-    get lv_field $vg/$lv2 devices > ${lv2}_devs
-    get lv_field $vg/$lv3 devices > ${lv3}_devs
-  fi
-  FIRST=done
-}
-
-lv_not_changed_() {
-  get lv_field $1 devices > out
-  diff $(basename $1)_devs out
-}
-
-check_and_cleanup_lvs_() {
-  lvs -a -o+devices $vg
-  check_dev_sum_ $(lvdev_ $vg $lv1)
-  check_dev_sum_ $(lvdev_ $vg $lv2)
-  check_dev_sum_ $(lvdev_ $vg $lv3)
-  lvs -a -o name $vg > out && ! grep ^pvmove out
-  lvremove -ff $vg
-  (dm_table | not grep $vg) || \
-	die "ERROR: lvremove did leave some some mappings in DM behind!"
-}
-
 #COMM "check environment setup/cleanup"
 prepare_lvs_
 check_and_cleanup_lvs_
@@ -108,262 +92,243 @@ check_and_cleanup_lvs_
 # filter by LV
 
 #COMM "only specified LV is moved: from pv2 to pv5 only for lv1"
-prepare_lvs_
+restore_lvs_
 pvmove -i1 -n $vg/$lv1 "$dev2" "$dev5"
-lv_is_on_ $vg/$lv1 "$dev1" "$dev5" "$dev3" "$dev1"
-lv_not_changed_ $vg/$lv2
-lv_not_changed_ $vg/$lv3
+check lv_on $vg $lv1 "$dev1" "$dev5" "$dev3"
+lvs_not_changed_ $lv2 $lv3
 check_and_cleanup_lvs_
 
 # ---
 # segments in a LV
 
 #COMM "the 1st seg of 3-segs LV is moved: from pv1 of lv1 to pv4"
-prepare_lvs_
+restore_lvs_
 pvmove -i0 -n $vg/$lv1 "$dev1" "$dev4"
-lv_is_on_ $vg/$lv1 "$dev4" "$dev2" "$dev3" "$dev4"
-lv_not_changed_ $vg/$lv2
-lv_not_changed_ $vg/$lv3
+check lv_on $vg $lv1 "$dev4" "$dev2" "$dev3"
+lvs_not_changed_ $lv2 $lv3
 check_and_cleanup_lvs_
 
 #COMM "the 2nd seg of 3-segs LV is moved: from pv2 of lv1 to pv4"
-prepare_lvs_
+restore_lvs_
 pvmove -i0 -n $vg/$lv1 "$dev2" "$dev4"
-lv_is_on_ $vg/$lv1 "$dev1" "$dev4" "$dev3" "$dev1"
-lv_not_changed_ $vg/$lv2
-lv_not_changed_ $vg/$lv3
+check lv_on $vg $lv1 "$dev1" "$dev4" "$dev3"
+lvs_not_changed_ $lv2 $lv3
 check_and_cleanup_lvs_
 
 #COMM "the 3rd seg of 3-segs LV is moved: from pv3 of lv1 to pv4"
-prepare_lvs_
+restore_lvs_
 pvmove -i0 -n $vg/$lv1 "$dev3" "$dev4"
-lv_is_on_ $vg/$lv1 "$dev1" "$dev2" "$dev4" "$dev1"
-lv_not_changed_ $vg/$lv2
-lv_not_changed_ $vg/$lv3
+check lv_on $vg $lv1 "$dev1" "$dev2" "$dev4"
+lvs_not_changed_ $lv2 $lv3
 check_and_cleanup_lvs_
 
 # ---
 # multiple LVs matching
 
 #COMM "1 out of 3 LVs is moved: from pv4 to pv5"
-prepare_lvs_
+restore_lvs_
 pvmove -i0 "$dev4" "$dev5"
-lv_not_changed_ $vg/$lv1
-lv_is_on_ $vg/$lv2 "$dev2" "$dev3" "$dev5"
-lv_not_changed_ $vg/$lv3
+check lv_on $vg $lv2 "$dev2" "$dev3" "$dev5"
+lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
 
 #COMM "2 out of 3 LVs are moved: from pv3 to pv5"
-prepare_lvs_
+restore_lvs_
 pvmove -i0 "$dev3" "$dev5"
-lv_is_on_ $vg/$lv1 "$dev1" "$dev2" "$dev5" "$dev1"
-lv_is_on_ $vg/$lv2 "$dev2" "$dev5" "$dev4"
-lv_not_changed_ $vg/$lv3
+check lv_on $vg $lv1 "$dev1" "$dev2" "$dev5"
+check lv_on $vg $lv2 "$dev2" "$dev5" "$dev4"
+lvs_not_changed_ $lv3
 check_and_cleanup_lvs_
 
 #COMM "3 out of 3 LVs are moved: from pv2 to pv5"
-prepare_lvs_
+restore_lvs_
 pvmove -i0 "$dev2" "$dev5"
-lv_is_on_ $vg/$lv1 "$dev1" "$dev5" "$dev3" "$dev1"
-lv_is_on_ $vg/$lv2 "$dev5" "$dev3" "$dev4"
-lv_is_on_ $vg/$lv3 "$dev5"
+check lv_on $vg $lv1 "$dev1" "$dev5" "$dev3"
+check lv_on $vg $lv2 "$dev5" "$dev3" "$dev4"
+check lv_on $vg $lv3 "$dev5"
 check_and_cleanup_lvs_
 
 # ---
 # areas of striping
 
 #COMM "move the 1st stripe: from pv2 of lv2 to pv1"
-prepare_lvs_
+restore_lvs_
 pvmove -i0 -n $vg/$lv2 "$dev2" "$dev1"
-lv_not_changed_ $vg/$lv1
-lv_is_on_ $vg/$lv2 "$dev1" "$dev3" "$dev4"
-lv_not_changed_ $vg/$lv3
+check lv_on $vg $lv2 "$dev1" "$dev3" "$dev4"
+lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
 
 #COMM "move the 2nd stripe: from pv3 of lv2 to pv1"
-prepare_lvs_
+restore_lvs_
 pvmove -i0 -n $vg/$lv2 "$dev3" "$dev1"
-lv_not_changed_ $vg/$lv1
-lv_is_on_ $vg/$lv2 "$dev2" "$dev1" "$dev4"
-lv_not_changed_ $vg/$lv3
+check lv_on $vg $lv2 "$dev2" "$dev1" "$dev4"
+lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
 
 #COMM "move the 3rd stripe: from pv4 of lv2 to pv1"
-prepare_lvs_
+restore_lvs_
 pvmove -i0 -n $vg/$lv2 "$dev4" "$dev1"
-lv_not_changed_ $vg/$lv1
-lv_is_on_ $vg/$lv2 "$dev2" "$dev3" "$dev1"
-lv_not_changed_ $vg/$lv3
+check lv_on $vg $lv2 "$dev2" "$dev3" "$dev1"
+lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
 
 # ---
 # partial segment match (source segment splitted)
 
 #COMM "match to the start of segment:from pv2:0-0 to pv5"
-prepare_lvs_
+restore_lvs_
 pvmove -i0 "$dev2":0-0 "$dev5"
-lv_not_changed_ $vg/$lv1
-lv_is_on_ $vg/$lv2 "$dev5" "$dev2" "$dev3" "$dev4"
-lv_not_changed_ $vg/$lv3
+check lv_on $vg $lv2 "$dev5" "$dev2" "$dev3" "$dev4"
+lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
-
+#exit 0
 #COMM "match to the middle of segment: from pv2:1-1 to pv5"
-prepare_lvs_
+restore_lvs_
 pvmove -i0 "$dev2":1-1 "$dev5"
-lv_not_changed_ $vg/$lv1
-lv_is_on_ $vg/$lv2 "$dev2" "$dev5" "$dev2" "$dev3" "$dev4"
-lv_not_changed_ $vg/$lv3
+check lv_on $vg $lv2 "$dev2" "$dev3" "$dev4" "$dev5"
+lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
 
 #COMM "match to the end of segment: from pv2:2-2 to pv5"
-prepare_lvs_
+restore_lvs_
 pvmove -i0 "$dev2":2-2 "$dev5"
-lv_not_changed_ $vg/$lv1
-lv_is_on_ $vg/$lv2 "$dev2" "$dev5" "$dev3" "$dev4"
-lv_not_changed_ $vg/$lv3
+check lv_on $vg $lv2 "$dev2" "$dev5" "$dev3" "$dev4"
+lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
 
 # ---
 # destination segment splitted
 
 #COMM "no destination split: from pv2:0-2 to pv5"
-prepare_lvs_
+restore_lvs_
 pvmove -i0 "$dev2":0-2 "$dev5"
-lv_not_changed_ $vg/$lv1
-lv_is_on_ $vg/$lv2 "$dev5" "$dev3" "$dev4"
-lv_not_changed_ $vg/$lv3
+check lv_on $vg $lv2 "$dev5" "$dev3" "$dev4"
+lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
 
 #COMM "destination split into 2: from pv2:0-2 to pv5:5-5 and pv4:5-6"
-prepare_lvs_
+restore_lvs_
 pvmove -i0 --alloc anywhere "$dev2":0-2 "$dev5":5-5 "$dev4":5-6
-lv_not_changed_ $vg/$lv1
-lv_is_on_ $vg/$lv2 "$dev5" "$dev4" "$dev3" "$dev4"
-lv_not_changed_ $vg/$lv3
+check lv_on $vg $lv2 "$dev5" "$dev4" "$dev3"
+lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
 
 #COMM "destination split into 3: from pv2:0-2 to {pv3,4,5}:5-5"
-prepare_lvs_
+restore_lvs_
 pvmove -i0 --alloc anywhere "$dev2":0-2 "$dev3":5-5 "$dev4":5-5 "$dev5":5-5
-lv_not_changed_ $vg/$lv1
-lv_is_on_ $vg/$lv2 "$dev3" "$dev4" "$dev5" "$dev3" "$dev4"
-lv_not_changed_ $vg/$lv3
+check lv_on $vg $lv2 "$dev3" "$dev4" "$dev5"
+lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
 
 # ---
 # alloc policy (anywhere, contiguous) with both success and failure cases
 
 #COMM "alloc normal on same PV for source and destination: from pv3:0-2 to pv3:5-7"
-prepare_lvs_
+restore_lvs_
 not pvmove -i0 "$dev3":0-2 "$dev3":5-7
 # "(cleanup previous test)"
-lv_not_changed_ $vg/$lv1
-lv_not_changed_ $vg/$lv2
-lv_not_changed_ $vg/$lv3
+lvs_not_changed_ $lv1 $lv2 $lv3
 check_and_cleanup_lvs_
 
 #COMM "alloc anywhere on same PV for source and destination: from pv3:0-2 to pv3:5-7"
-prepare_lvs_
+restore_lvs_
 pvmove -i0 --alloc anywhere "$dev3":0-2 "$dev3":5-7
-lv_not_changed_ $vg/$lv1
-lv_is_on_ $vg/$lv2 "$dev2" "$dev3" "$dev4"
-lv_not_changed_ $vg/$lv3
+check lv_on $vg $lv2 "$dev2" "$dev3" "$dev4"
+lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
 
 #COMM "alloc anywhere but better area available: from pv3:0-2 to pv3:5-7 or pv5:5-6,pv4:5-5"
-prepare_lvs_
+restore_lvs_
+#lvs -a -o name,size,seg_pe_ranges $vg
+#LV2    1.12m @TESTDIR@/dev/mapper/@PREFIX at pv2:0-2 @TESTDIR@/dev/mapper/@PREFIX at pv3:0-2 @TESTDIR@/dev/mapper/@PREFIX at pv4:0-2
+
 pvmove -i0 --alloc anywhere "$dev3":0-2 "$dev3":5-7 "$dev5":5-6 "$dev4":5-5
-lv_not_changed_ $vg/$lv1
-#lv_is_on_ $vg/$lv2 "$dev2" "$dev5" "$dev4" "$dev4"
-lv_not_changed_ $vg/$lv3
+
+#lvs -a -o name,size,seg_pe_ranges $vg
+# Hmm is this correct ? - why pv2 is split
+#LV2    1.12m @TESTDIR@/dev/mapper/@PREFIX at pv2:0-1 @TESTDIR@/dev/mapper/@PREFIX at pv5:5-6 @TESTDIR@/dev/mapper/@PREFIX at pv4:0-1
+#LV2    1.12m @TESTDIR@/dev/mapper/@PREFIX at pv2:2-2 @TESTDIR@/dev/mapper/@PREFIX at pv3:5-5 @TESTDIR@/dev/mapper/@PREFIX at pv4:2-2
+check lv_on $vg $lv2 "$dev2" "$dev3" "$dev4" "$dev5"
+lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
 
 #COMM "alloc contiguous but area not available: from pv2:0-2 to pv5:5-5 and pv4:5-6"
-prepare_lvs_
+restore_lvs_
 not pvmove -i0 --alloc contiguous "$dev2":0-2 "$dev5":5-5 "$dev4":5-6
 # "(cleanup previous test)"
-lv_not_changed_ $vg/$lv1
-lv_not_changed_ $vg/$lv2
-lv_not_changed_ $vg/$lv3
+lvs_not_changed_ $lv1 $lv2 $lv3
 check_and_cleanup_lvs_
 
 #COMM "alloc contiguous and contiguous area available: from pv2:0-2 to pv5:0-0,pv5:3-5 and pv4:5-6"
-prepare_lvs_
+restore_lvs_
 pvmove -i0 --alloc contiguous "$dev2":0-2 "$dev5":0-0 "$dev5":3-5 "$dev4":5-6
-lv_not_changed_ $vg/$lv1
-lv_is_on_ $vg/$lv2 "$dev5" "$dev3" "$dev4"
-lv_not_changed_ $vg/$lv3
+check lv_on $vg $lv2 "$dev5" "$dev3" "$dev4"
+lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
 
 # ---
 # multiple segments in a LV
 
 #COMM "multiple source LVs: from pv3 to pv5"
-prepare_lvs_
+restore_lvs_
 pvmove -i0 "$dev3" "$dev5"
-lv_is_on_ $vg/$lv1 "$dev1" "$dev2" "$dev5"
-lv_is_on_ $vg/$lv2 "$dev2" "$dev5" "$dev4"
-lv_not_changed_ $vg/$lv3
+check lv_on $vg $lv1 "$dev1" "$dev2" "$dev5"
+check lv_on $vg $lv2 "$dev2" "$dev5" "$dev4"
+lvs_not_changed_ $lv3
 check_and_cleanup_lvs_
 
 # ---
 # move inactive LV
 
 #COMM "move inactive LV: from pv2 to pv5"
-prepare_lvs_
+restore_lvs_
 lvchange -an $vg/$lv1
 lvchange -an $vg/$lv3
 pvmove -i0 "$dev2" "$dev5"
-lv_is_on_ $vg/$lv1 "$dev1" "$dev5" "$dev3"
-lv_is_on_ $vg/$lv2 "$dev5" "$dev3" "$dev4"
-lv_is_on_ $vg/$lv3 "$dev5"
+check lv_on $vg $lv1 "$dev1" "$dev5" "$dev3"
+check lv_on $vg $lv2 "$dev5" "$dev3" "$dev4"
+check lv_on $vg $lv3 "$dev5"
 check_and_cleanup_lvs_
 
 # ---
 # other failure cases
 
 #COMM "no PEs to move: from pv3 to pv1"
-prepare_lvs_
+restore_lvs_
 pvmove -i0 "$dev3" "$dev1"
 not pvmove -i0 "$dev3" "$dev1"
 # "(cleanup previous test)"
-lv_is_on_ $vg/$lv1 "$dev1" "$dev2" "$dev1"
-lv_is_on_ $vg/$lv2 "$dev2" "$dev1" "$dev4"
-lv_not_changed_ $vg/$lv3
+check lv_on $vg $lv1 "$dev1" "$dev2" "$dev1"
+check lv_on $vg $lv2 "$dev2" "$dev1" "$dev4"
+lvs_not_changed_ $lv3
 check_and_cleanup_lvs_
 
 #COMM "no space available: from pv2:0-0 to pv1:0-0"
-prepare_lvs_
+restore_lvs_
 not pvmove -i0 "$dev2":0-0 "$dev1":0-0
 # "(cleanup previous test)"
-lv_not_changed_ $vg/$lv1
-lv_not_changed_ $vg/$lv2
-lv_not_changed_ $vg/$lv3
+lvs_not_changed_ $lv1 $lv2 $lv3
 check_and_cleanup_lvs_
 
 #COMM 'same source and destination: from pv1 to pv1'
-prepare_lvs_
+restore_lvs_
 not pvmove -i0 "$dev1" "$dev1"
 #"(cleanup previous test)"
-lv_not_changed_ $vg/$lv1
-lv_not_changed_ $vg/$lv2
-lv_not_changed_ $vg/$lv3
+lvs_not_changed_ $lv1 $lv2 $lv3
 check_and_cleanup_lvs_
 
 #COMM "sum of specified destination PEs is large enough, but it includes source PEs and the free PEs are not enough"
-prepare_lvs_
+restore_lvs_
 not pvmove --alloc anywhere "$dev1":0-2 "$dev1":0-2 "$dev5":0-0 2> err
 #"(cleanup previous test)"
 grep "Insufficient free space" err
-lv_not_changed_ $vg/$lv1
-lv_not_changed_ $vg/$lv2
-lv_not_changed_ $vg/$lv3
+lvs_not_changed_ $lv1 $lv2 $lv3
 check_and_cleanup_lvs_
 
 # ---------------------------------------------------------------------
 
 #COMM "pvmove abort"
-prepare_lvs_
+restore_lvs_
 pvmove -i100 -b "$dev1" "$dev3"
 pvmove --abort
 check_and_cleanup_lvs_
diff --git a/test/shell/pvmove-raid-segtypes.sh b/test/shell/pvmove-raid-segtypes.sh
new file mode 100644
index 0000000..4b720bb
--- /dev/null
+++ b/test/shell/pvmove-raid-segtypes.sh
@@ -0,0 +1,79 @@
+#!/bin/sh
+# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description="ensure pvmove works with raid segment types"
+
+. lib/test
+
+test -e LOCAL_CLVMD && skip
+which mkfs.ext2 || skip
+which md5sum || skip
+
+aux target_at_least dm-raid 1 3 5 || skip
+
+aux prepare_pvs 5 20
+vgcreate -c n -s 128k $vg $(cat DEVICES)
+
+# Each of the following tests does:
+# 1) Create two LVs - one linear and one other segment type
+#    The two LVs will share a PV.
+# 2) Move both LVs together
+# 3) Move only the second LV by name
+
+# Testing pvmove of RAID1 LV
+lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate -l 2 --type raid1 -m 1 -n $lv1 $vg "$dev1" "$dev2"
+check lv_tree_on $vg ${lv1}_foo "$dev1"
+check lv_tree_on $vg $lv1 "$dev1" "$dev2"
+aux mkdev_md5sum $vg $lv1
+pvmove "$dev1" "$dev5"
+check lv_tree_on $vg ${lv1}_foo "$dev5"
+check lv_tree_on $vg $lv1 "$dev2" "$dev5"
+check dev_md5sum $vg $lv1
+pvmove -n $lv1 "$dev5" "$dev4"
+check lv_tree_on $vg $lv1 "$dev2" "$dev4"
+check lv_tree_on $vg ${lv1}_foo "$dev5"
+check dev_md5sum $vg $lv1
+lvremove -ff $vg
+
+# Testing pvmove of RAID10 LV
+lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate -l 4 --type raid10 -i 2 -m 1 -n $lv1 $vg \
+                "$dev1" "$dev2" "$dev3" "$dev4"
+check lv_tree_on $vg ${lv1}_foo "$dev1"
+check lv_tree_on $vg $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
+aux mkdev_md5sum $vg $lv1
+pvmove "$dev1" "$dev5"
+check lv_tree_on $vg ${lv1}_foo "$dev5"
+check lv_tree_on $vg $lv1 "$dev2" "$dev3" "$dev4" "$dev5"
+check dev_md5sum $vg $lv1
+pvmove -n $lv1 "$dev5" "$dev1"
+check lv_tree_on $vg $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
+check lv_tree_on $vg ${lv1}_foo "$dev5"
+check dev_md5sum $vg $lv1
+lvremove -ff $vg
+
+# Testing pvmove of RAID5 LV
+lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate -l 4 --type raid5 -i 2 -n $lv1 $vg \
+                "$dev1" "$dev2" "$dev3"
+check lv_tree_on $vg ${lv1}_foo "$dev1"
+check lv_tree_on $vg $lv1 "$dev1" "$dev2" "$dev3"
+aux mkdev_md5sum $vg $lv1
+pvmove "$dev1" "$dev5"
+check lv_tree_on $vg ${lv1}_foo "$dev5"
+check lv_tree_on $vg $lv1 "$dev2" "$dev3" "$dev5"
+check dev_md5sum $vg $lv1
+pvmove -n $lv1 "$dev5" "$dev4"
+check lv_tree_on $vg $lv1 "$dev2" "$dev3" "$dev4"
+check lv_tree_on $vg ${lv1}_foo "$dev5"
+check dev_md5sum $vg $lv1
+lvremove -ff $vg
diff --git a/test/shell/pvmove-thin-segtypes.sh b/test/shell/pvmove-thin-segtypes.sh
new file mode 100644
index 0000000..fe07288
--- /dev/null
+++ b/test/shell/pvmove-thin-segtypes.sh
@@ -0,0 +1,83 @@
+#!/bin/sh
+# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description="ensure pvmove works with thin segment types"
+
+. lib/test
+test -e LOCAL_CLVMD && skip
+which mkfs.ext2 || skip
+which md5sum || skip
+
+aux target_at_least dm-thin-pool 1 8 0 || skip
+# for stacking
+aux target_at_least dm-raid 1 3 5 || skip
+
+aux prepare_pvs 5 20
+vgcreate -c n -s 128k $vg $(cat DEVICES)
+
+# Each of the following tests does:
+# 1) Create two LVs - one linear and one other segment type
+#    The two LVs will share a PV.
+# 2) Move both LVs together
+# 3) Move only the second LV by name
+
+
+# Testing pvmove of thin-pool LV
+lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate -T $vg/$lv1 -l 4 "$dev1"
+check lv_tree_on $vg ${lv1}_foo "$dev1"
+check lv_tree_on $vg $lv1 "$dev1"
+aux mkdev_md5sum $vg $lv1
+pvmove "$dev1" "$dev5"
+check lv_tree_on $vg ${lv1}_foo "$dev5"
+check lv_tree_on $vg $lv1 "$dev5"
+check dev_md5sum $vg $lv1
+pvmove -n $lv1 "$dev5" "$dev4"
+check lv_tree_on $vg $lv1 "$dev4"
+check lv_tree_on $vg ${lv1}_foo "$dev5"
+check dev_md5sum $vg $lv1
+lvremove -ff $vg
+
+# Testing pvmove of thin LV
+lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate -T $vg/${lv1}_pool -l 4 -V 8 -n $lv1 "$dev1"
+check lv_tree_on $vg ${lv1}_foo "$dev1"
+check lv_tree_on $vg $lv1 "$dev1"
+aux mkdev_md5sum $vg $lv1
+pvmove "$dev1" "$dev5"
+check lv_tree_on $vg ${lv1}_foo "$dev5"
+check lv_tree_on $vg $lv1 "$dev5"
+check dev_md5sum $vg $lv1
+pvmove -n $lv1 "$dev5" "$dev4"
+check lv_tree_on $vg $lv1 "$dev4"
+check lv_tree_on $vg ${lv1}_foo "$dev5"
+check dev_md5sum $vg $lv1
+lvremove -ff $vg
+
+# Testing pvmove of thin LV on RAID
+lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate --type raid1 -m 1 -l 4 -n ${lv1}_raid1_pool $vg "$dev1" "$dev2"
+lvcreate --type raid1 -m 1 -L 2 -n ${lv1}_raid1_meta $vg "$dev1" "$dev2"
+lvconvert --thinpool $vg/${lv1}_raid1_pool \
+        --poolmetadata ${lv1}_raid1_meta
+lvcreate -T $vg/${lv1}_raid1_pool -V 8 -n $lv1
+check lv_tree_on $vg ${lv1}_foo "$dev1"
+check lv_tree_on $vg $lv1 "$dev1" "$dev2"
+aux mkdev_md5sum $vg $lv1
+pvmove "$dev1" "$dev5"
+check lv_tree_on $vg ${lv1}_foo "$dev5"
+check lv_tree_on $vg $lv1 "$dev2" "$dev5"
+check dev_md5sum $vg $lv1
+pvmove -n $lv1 "$dev5" "$dev4"
+check lv_tree_on $vg $lv1 "$dev2" "$dev4"
+check lv_tree_on $vg ${lv1}_foo "$dev5"
+check dev_md5sum $vg $lv1
+lvremove -ff $vg


