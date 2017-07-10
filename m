From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:28:30 -0400
Subject: master - tests: fix working with devs in array
Message-ID: <201707101228.v6ACSUfm022081@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bc10d0373ad7c2e9997896c72e0740bd71bc8e46
Commit:        bc10d0373ad7c2e9997896c72e0740bd71bc8e46
Parent:        fdbb680531b08e03dba2dc3d2f22381bf55abbb0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 8 18:23:47 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: fix working with devs in array

Also fixes one instance of invalid  'mirror_image_on' test
and places there correct indexed set of PVs.
---
 test/shell/mirror-vgreduce-removemissing.sh |   82 +++++++++++++++-----------
 1 files changed, 47 insertions(+), 35 deletions(-)

diff --git a/test/shell/mirror-vgreduce-removemissing.sh b/test/shell/mirror-vgreduce-removemissing.sh
index 7f0c190..2707059 100644
--- a/test/shell/mirror-vgreduce-removemissing.sh
+++ b/test/shell/mirror-vgreduce-removemissing.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008-2017 Red Hat, Inc. All rights reserved.
 # Copyright (C) 2007 NEC Corporation
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -20,18 +20,20 @@ export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
 
 . lib/inittest
 
+list_pvs=()
+
 lv_is_on_ ()
 {
 	local lv=$vg/$1
 	shift
-	local pvs=$@
+	local list_pvs=( "$@" )
 
-	echo "Check if $lv is exactly on PVs $pvs"
+	echo "Check if $lv is exactly on PVs" "${list_pvs[@]}"
 	rm -f out1 out2
-	echo $pvs | sed 's/ /\n/g' | sort | uniq > out1
+	printf "%s\n" "${list_pvs[@]}" | sort | uniq > out1
 
 	lvs -a -o+devices $lv
-	get lv_devices $lv | sed 's/ /\n/g' | sort | uniq > out2 || true
+	get lv_devices "$lv" | sort | uniq > out2
 
 	diff --ignore-blank-lines out1 out2
 }
@@ -40,24 +42,25 @@ mimages_are_on_ ()
 {
 	local lv=$1
 	shift
-	local pvs=$@
-	local mimages
+	local list_pvs=( "$@" )
+	local mimages=()
 	local i
 
-	echo "Check if mirror images of $lv are on PVs $pvs"
-	rm -f out1 out2
-	echo $pvs | sed 's/ /\n/g' | sort | uniq > out1
-	lvs --noheadings -a -o lv_name $vg | tee lvs_log
-	mimages=$(grep "${lv}_mimage_" lvs_log | \
-		sed 's/\[//g; s/\]//g' || true)
+	echo "Check if mirror images of $lv are on PVs" "${list_pvs[@]}"
+	printf "%s\n" "${list_pvs[@]}" | sort | uniq > out1
 
-	for i in $mimages; do
+	get lv_field_lv_ "$vg" lv_name -a | grep "${lv}_mimage_" | tr -d [] | tee lvs_log
+	readarray -t mimages < lvs_log
+
+	for i in "${mimages[@]}"; do
 		echo "Checking $vg/$i"
-		lvs -a -o+devices $vg/$i
-		lvs -a -odevices --noheadings $vg/$i | tee lvs_log
-		sed 's/([^)]*)//g; s/ //g; s/,/ /g' lvs_log | sort | uniq >> out2 || true
+		lvs -a -o+devices "$vg/$i"
 	done
 
+	for i in "${mimages[@]}"; do
+		get lv_devices "$vg/$i"
+	done | sort | uniq > out2
+
 	diff --ignore-blank-lines out1 out2
 }
 
@@ -79,16 +82,16 @@ rest_pvs_()
 {
 	local index=$1
 	local num=$2
-	local rem=
+	local rem=()
 	local n
 	local dev
 
 	for n in $(seq 1 $(( index - 1 )) ) $(seq $(( index + 1 )) $num); do
-		eval dev=$\dev$n
-		rem="$rem $dev"
+		eval "dev=\$dev$n"
+		rem+=( "$dev" )
 	done
 
-	echo "$rem"
+	printf "%s\n" "${rem[@]}"
 }
 
 # ---------------------------------------------------------------------
@@ -156,9 +159,10 @@ test_3way_mirror_fail_1_()
 	lvcreate -an -Zn -l2 --type mirror -m2 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev4":$BLOCKS
 	mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3"
 	mirrorlog_is_on_ $lv1 "$dev4"
-	eval aux disable_dev \$dev$index
+	eval aux disable_dev "\$dev$index"
 	vgreduce --removemissing --force $vg
-	mimages_are_on_ $lv1 $(rest_pvs_ $index 3)
+	readarray -t list_pvs <<< "$(rest_pvs_ "$index" 3)"
+	mimages_are_on_ "$lv1" "${list_pvs[@]}"
 	mirrorlog_is_on_ $lv1 "$dev4"
 }
 
@@ -166,7 +170,7 @@ for n in $(seq 1 3); do
 	#COMM fail mirror image $(($n - 1)) of 3-way mirrored LV"
 	prepare_lvs_
 	test_3way_mirror_fail_1_ $n
-	eval recover_vg_ \$dev$n
+	eval recover_vg_ "\$dev$n"
 done
 
 # ---------------------------------------------------------------------
@@ -181,18 +185,20 @@ test_3way_mirror_fail_2_()
 	lvcreate -an -Zn -l2 --type mirror -m2 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev4":$BLOCKS
 	mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3"
 	mirrorlog_is_on_ $lv1 "$dev4"
-	rest_pvs_ $index 3
-	aux disable_dev $(rest_pvs_ $index 3)
+
+	readarray -t list_pvs <<< "$(rest_pvs_ "$index" 3)"
+	aux disable_dev "${list_pvs[@]}"
 	vgreduce --force --removemissing $vg
 	lv_is_linear_ $lv1
-	eval lv_is_on_ $lv1 \$dev$n
+	eval lv_is_on_ $lv1 "\$dev$n"
 }
 
 for n in $(seq 1 3); do
 	#COMM fail mirror images other than mirror image $(($n - 1)) of 3-way mirrored LV
 	prepare_lvs_
 	test_3way_mirror_fail_2_ $n
-	recover_vg_ $(rest_pvs_ $n 3)
+	readarray -t list_pvs <<< "$(rest_pvs_ "$n" 3)"
+	recover_vg_ "${list_pvs[@]}"
 done
 
 # ---------------------------------------------------------------------
@@ -212,7 +218,8 @@ test_3way_mirror_plus_1_fail_1_()
         lvs -a -o +devices
 	vgreduce --removemissing --force $vg
 	lvs -a -o+devices # $vg
-	check mirror_images_on $vg $lv1 "$dev5" # $(rest_pvs_ $index 4)
+	readarray -t list_pvs <<< "$(rest_pvs_ "$index" 4)"
+	check mirror_images_on $vg $lv1 "${list_pvs[@]}"
 	check mirror_log_on $vg $lv1 "$dev5"
 }
 
@@ -238,7 +245,8 @@ test_3way_mirror_plus_1_fail_3_()
 	check mirror_images_on $vg $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
 	check mirror_log_on $vg $lv1 "$dev5"
 	lvs -a -o+devices $vg
-	aux disable_dev $(rest_pvs_ $index 4)
+	readarray -t list_pvs <<< "$(rest_pvs_ "$index" 4)"
+	aux disable_dev "${list_pvs[@]}"
 	vgreduce --removemissing --force $vg
 	lvs -a -o+devices $vg
 	eval dev=\$dev$n
@@ -250,7 +258,8 @@ for n in $(seq 1 4); do
 	#COMM "fail mirror images other than mirror image $(($n - 1)) of 4-way (1 converting) mirrored LV"
 	prepare_lvs_
 	test_3way_mirror_plus_1_fail_3_ $n
-	recover_vg_ $(rest_pvs_ $n 4)
+	readarray -t list_pvs <<< "$(rest_pvs_ "$n" 4)"
+	recover_vg_ "${list_pvs[@]}"
 done
 
 # ---------------------------------------------------------------------
@@ -268,7 +277,8 @@ test_2way_mirror_plus_2_fail_1_()
 	mirrorlog_is_on_ $lv1 "$dev5"
 	eval aux disable_dev \$dev$n
 	vgreduce --removemissing --force $vg
-	mimages_are_on_ $lv1 $(rest_pvs_ $index 4)
+	readarray -t list_pvs <<< "$(rest_pvs_ "$index" 4)"
+	mimages_are_on_ "$lv1" "${list_pvs[@]}"
 	mirrorlog_is_on_ $lv1 "$dev5"
 }
 
@@ -276,7 +286,7 @@ for n in $(seq 1 4); do
 	#COMM "fail mirror image $(($n - 1)) of 4-way (2 converting) mirrored LV"
 	prepare_lvs_
 	test_2way_mirror_plus_2_fail_1_ $n
-	eval recover_vg_ \$dev$n
+	eval recover_vg_ "\$dev$n"
 done
 
 # ---------------------------------------------------------------------
@@ -293,7 +303,8 @@ test_2way_mirror_plus_2_fail_3_()
 	lvconvert -m+2 $vg/$lv1 "$dev3" "$dev4"
 	mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
 	mirrorlog_is_on_ $lv1 "$dev5"
-	aux disable_dev $(rest_pvs_ $index 4)
+	readarray -t list_pvs <<< "$(rest_pvs_ "$index" 4)"
+	aux disable_dev "${list_pvs[@]}"
 	vgreduce --removemissing --force $vg
 	lvs -a -o+devices $vg
 	eval dev=\$dev$n
@@ -305,7 +316,8 @@ for n in $(seq 1 4); do
 	#COMM "fail mirror images other than mirror image $(($n - 1)) of 4-way (2 converting) mirrored LV"
 	prepare_lvs_
 	test_2way_mirror_plus_2_fail_3_ $n
-	recover_vg_ $(rest_pvs_ $n 4)
+	readarray -t list_pvs <<< "$(rest_pvs_ "$n" 4)"
+	recover_vg_ "${list_pvs[@]}"
 done
 
 # ---------------------------------------------------------------------


