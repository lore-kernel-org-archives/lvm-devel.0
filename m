From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 11:42:23 -0400
Subject: master - tests: avoid using readarray
Message-ID: <201707101542.v6AFgNop022972@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e9a544b94281a500bf58930c63d15aedcde961ed
Commit:        e9a544b94281a500bf58930c63d15aedcde961ed
Parent:        d71b738c171bfd93eabdca3c388a637a1aa55a6c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 10 17:40:31 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 17:40:31 2017 +0200

tests: avoid using readarray

Real bashman can live without readarray.

Support older tested machines with bash <4.0....
---
 test/lib/check.sh                           |    6 ++-
 test/shell/mirror-vgreduce-removemissing.sh |   63 +++++++++++++++++++++------
 2 files changed, 54 insertions(+), 15 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 76015b8..a61eb81 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -98,7 +98,11 @@ mirror_images_on() {
 	local lv=$2
 	shift 2
 	local mimages=()
-	readarray -t mimages <<< "$(get lv_field_lv_ "$vg" lv_name -a | grep "${lv}_mimage_" )"
+	local line
+
+	while IFS= read -r line ; do
+		mimages+=( "$line" )
+	done < <( get lv_field_lv_ "$vg" lv_name -a | grep "${lv}_mimage_" )
 
 	for i in  "${mimages[@]}"; do
 		lv_on "$vg" "$i" "$1"
diff --git a/test/shell/mirror-vgreduce-removemissing.sh b/test/shell/mirror-vgreduce-removemissing.sh
index 2707059..4068f09 100644
--- a/test/shell/mirror-vgreduce-removemissing.sh
+++ b/test/shell/mirror-vgreduce-removemissing.sh
@@ -49,8 +49,10 @@ mimages_are_on_ ()
 	echo "Check if mirror images of $lv are on PVs" "${list_pvs[@]}"
 	printf "%s\n" "${list_pvs[@]}" | sort | uniq > out1
 
-	get lv_field_lv_ "$vg" lv_name -a | grep "${lv}_mimage_" | tr -d [] | tee lvs_log
-	readarray -t mimages < lvs_log
+	get lv_field_lv_ "$vg" lv_name -a | grep "${lv}_mimage_" | tee lvs_log
+	while IFS= read -r i ; do
+		mimages+=( "$i" )
+	done < lvs_log
 
 	for i in "${mimages[@]}"; do
 		echo "Checking $vg/$i"
@@ -161,7 +163,11 @@ test_3way_mirror_fail_1_()
 	mirrorlog_is_on_ $lv1 "$dev4"
 	eval aux disable_dev "\$dev$index"
 	vgreduce --removemissing --force $vg
-	readarray -t list_pvs <<< "$(rest_pvs_ "$index" 3)"
+
+	list_pvs=(); while IFS= read -r line ; do
+		list_pvs+=( "$line" )
+	done < <( rest_pvs_ "$index" 3 )
+
 	mimages_are_on_ "$lv1" "${list_pvs[@]}"
 	mirrorlog_is_on_ $lv1 "$dev4"
 }
@@ -186,7 +192,10 @@ test_3way_mirror_fail_2_()
 	mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3"
 	mirrorlog_is_on_ $lv1 "$dev4"
 
-	readarray -t list_pvs <<< "$(rest_pvs_ "$index" 3)"
+	list_pvs=(); while IFS= read -r line ; do
+		list_pvs+=( "$line" )
+	done < <( rest_pvs_ "$index" 3 )
+
 	aux disable_dev "${list_pvs[@]}"
 	vgreduce --force --removemissing $vg
 	lv_is_linear_ $lv1
@@ -197,7 +206,11 @@ for n in $(seq 1 3); do
 	#COMM fail mirror images other than mirror image $(($n - 1)) of 3-way mirrored LV
 	prepare_lvs_
 	test_3way_mirror_fail_2_ $n
-	readarray -t list_pvs <<< "$(rest_pvs_ "$n" 3)"
+
+	list_pvs=(); while IFS= read -r line ; do
+		list_pvs+=( "$line" )
+	done < <( rest_pvs_ "$n" 3 )
+
 	recover_vg_ "${list_pvs[@]}"
 done
 
@@ -215,10 +228,12 @@ test_3way_mirror_plus_1_fail_1_()
 	check mirror_images_on $vg $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
 	check mirror_log_on $vg $lv1 "$dev5"
 	eval aux disable_dev \$dev$index
-        lvs -a -o +devices
 	vgreduce --removemissing --force $vg
-	lvs -a -o+devices # $vg
-	readarray -t list_pvs <<< "$(rest_pvs_ "$index" 4)"
+
+	list_pvs=(); while IFS= read -r line ; do
+		list_pvs+=( "$line" )
+	done < <( rest_pvs_ "$index" 4 )
+
 	check mirror_images_on $vg $lv1 "${list_pvs[@]}"
 	check mirror_log_on $vg $lv1 "$dev5"
 }
@@ -244,8 +259,11 @@ test_3way_mirror_plus_1_fail_3_()
 	lvconvert -m+1 $vg/$lv1 "$dev4"
 	check mirror_images_on $vg $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
 	check mirror_log_on $vg $lv1 "$dev5"
-	lvs -a -o+devices $vg
-	readarray -t list_pvs <<< "$(rest_pvs_ "$index" 4)"
+
+	list_pvs=(); while IFS= read -r line ; do
+		list_pvs+=( "$line" )
+	done < <( rest_pvs_ "$index" 4 )
+
 	aux disable_dev "${list_pvs[@]}"
 	vgreduce --removemissing --force $vg
 	lvs -a -o+devices $vg
@@ -258,7 +276,11 @@ for n in $(seq 1 4); do
 	#COMM "fail mirror images other than mirror image $(($n - 1)) of 4-way (1 converting) mirrored LV"
 	prepare_lvs_
 	test_3way_mirror_plus_1_fail_3_ $n
-	readarray -t list_pvs <<< "$(rest_pvs_ "$n" 4)"
+
+	list_pvs=(); while IFS= read -r line ; do
+		list_pvs+=( "$line" )
+	done < <( rest_pvs_ "$n" 4 )
+
 	recover_vg_ "${list_pvs[@]}"
 done
 
@@ -277,7 +299,11 @@ test_2way_mirror_plus_2_fail_1_()
 	mirrorlog_is_on_ $lv1 "$dev5"
 	eval aux disable_dev \$dev$n
 	vgreduce --removemissing --force $vg
-	readarray -t list_pvs <<< "$(rest_pvs_ "$index" 4)"
+
+	list_pvs=(); while IFS= read -r line ; do
+		list_pvs+=( "$line" )
+	done < <( rest_pvs_ "$index" 4 )
+
 	mimages_are_on_ "$lv1" "${list_pvs[@]}"
 	mirrorlog_is_on_ $lv1 "$dev5"
 }
@@ -303,7 +329,12 @@ test_2way_mirror_plus_2_fail_3_()
 	lvconvert -m+2 $vg/$lv1 "$dev3" "$dev4"
 	mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
 	mirrorlog_is_on_ $lv1 "$dev5"
-	readarray -t list_pvs <<< "$(rest_pvs_ "$index" 4)"
+
+
+	list_pvs=(); while IFS= read -r line ; do
+		list_pvs+=( "$line" )
+	done < <( rest_pvs_ "$index" 4 )
+
 	aux disable_dev "${list_pvs[@]}"
 	vgreduce --removemissing --force $vg
 	lvs -a -o+devices $vg
@@ -316,7 +347,11 @@ for n in $(seq 1 4); do
 	#COMM "fail mirror images other than mirror image $(($n - 1)) of 4-way (2 converting) mirrored LV"
 	prepare_lvs_
 	test_2way_mirror_plus_2_fail_3_ $n
-	readarray -t list_pvs <<< "$(rest_pvs_ "$n" 4)"
+
+	list_pvs=(); while IFS= read -r line ; do
+		list_pvs+=( "$line" )
+	done < <( rest_pvs_ "$n" 4 )
+
 	recover_vg_ "${list_pvs[@]}"
 done
 


