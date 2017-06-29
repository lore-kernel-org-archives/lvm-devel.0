From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:28:30 -0400
Subject: master - tests: check.sh assign separately
Message-ID: <201706292028.v5TKSU8R026807@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=810f856c2490eb1d5db858f26a26621c4a3477e0
Commit:        810f856c2490eb1d5db858f26a26621c4a3477e0
Parent:        02729202f38825c672412f49e1073d38cdf0772b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 08:39:21 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:17 2017 +0200

tests: check.sh assign separately

Declare and assign separately to avoid masking return values.
---
 test/lib/check.sh |   57 +++++++++++++++++++++++++++++++++++-----------------
 1 files changed, 38 insertions(+), 19 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 2eb24a5..0ad48a9 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -144,7 +144,8 @@ mirror() {
 
 mirror_nonredundant() {
 	local lv="$1/$2"
-	local attr=$(get lv_field "$lv" attr)
+	local attr
+	attr=$(get lv_field "$lv" attr)
 	(echo "$attr" | grep "^......m...$" >/dev/null) || {
 		if (echo "$attr" | grep "^o.........$" >/dev/null) &&
 		   lvs -a | fgrep "[${2}_mimage" >/dev/null; then
@@ -188,8 +189,9 @@ in_sync() {
 	local snap=""
 	local lvm_name="$1/$2"
 	local ignore_a="$3"
-	local dm_name=$(echo "$lvm_name" | sed s:-:--: | sed s:/:-:)
+	local dm_name
 
+	dm_name=$(echo "$lvm_name" | sed s:-:--: | sed s:/:-:)
 	[ -z "$ignore_a" ] && ignore_a=0
 
 	a=( $(dmsetup status "$dm_name") )  || \
@@ -285,20 +287,23 @@ lv_not_exists() {
 }
 
 pv_field() {
-	local actual=$(get pv_field "$1" "$2" "${@:4}")
+	local actual
+	actual=$(get pv_field "$1" "$2" "${@:4}")
 	test "$actual" = "$3" || \
 		die "pv_field: PV=\"$1\", field=\"$2\", actual=\"$actual\", expected=\"$3\""
 }
 
 vg_field() {
-	local actual=$(get vg_field "$1" "$2" "${@:4}")
+	local actual
+	actual=$(get vg_field "$1" "$2" "${@:4}")
 	test "$actual" = "$3" || \
 		die "vg_field: vg=$1, field=\"$2\", actual=\"$actual\", expected=\"$3\""
 }
 
 vg_attr_bit() {
-	local actual=$(get vg_field "$2" vg_attr "${@:4}")
+	local actual
 	local offset=$1
+	actual=$(get vg_field "$2" vg_attr "${@:4}")
 	case "$offset" in
 	  perm*) offset=0 ;;
 	  resiz*) offset=1 ;;
@@ -312,32 +317,37 @@ vg_attr_bit() {
 }
 
 lv_field() {
-	local actual=$(get lv_field "$1" "$2" "${@:4}")
+	local actual
+	actual=$(get lv_field "$1" "$2" "${@:4}")
 	test "$actual" = "$3" || \
 		die "lv_field: lv=$1, field=\"$2\", actual=\"$actual\", expected=\"$3\""
 }
 
 lv_first_seg_field() {
-	local actual=$(get lv_first_seg_field "$1" "$2" "${@:4}")
+	local actual
+	actual=$(get lv_first_seg_field "$1" "$2" "${@:4}")
 	test "$actual" = "$3" || \
 		die "lv_field: lv=$1, field=\"$2\", actual=\"$actual\", expected=\"$3\""
 }
 
 lvh_field() {
-	local actual=$(get lvh_field "$1" "$2" "${@:4}")
+	local actual
+	actual=$(get lvh_field "$1" "$2" "${@:4}")
 	test "$actual" = "$3" || \
 		die "lvh_field: lv=$1, field=\"$2\", actual=\"$actual\", expected=\"$3\""
 }
 
 lva_field() {
-	local actual=$(get lva_field "$1" "$2" "${@:4}")
+	local actual
+	actual=$(get lva_field "$1" "$2" "${@:4}")
 	test "$actual" = "$3" || \
 		die "lva_field: lv=$1, field=\"$2\", actual=\"$actual\", expected=\"$3\""
 }
 
 lv_attr_bit() {
-	local actual=$(get lv_field "$2" lv_attr "${@:4}")
+	local actual
 	local offset=$1
+	actual=$(get lv_field "$2" lv_attr "${@:4}")
 	case "$offset" in
 	  type) offset=0 ;;
 	  perm*) offset=1 ;;
@@ -361,8 +371,10 @@ compare_fields() {
 	local cmd2=$4
 	local obj2=$5
 	local field2=$6
-	local val1=$($cmd1 --noheadings -o "$field1" "$obj1")
-	local val2=$($cmd2 --noheadings -o "$field2" "$obj2")
+	local val1
+	local val2
+	val1=$($cmd1 --noheadings -o "$field1" "$obj1")
+	val2=$($cmd2 --noheadings -o "$field2" "$obj2")
 	test "$val1" = "$val2" || \
 		die "compare_fields $obj1($field1): $val1 $obj2($field2): $val2"
 }
@@ -371,8 +383,10 @@ compare_vg_field() {
 	local vg1=$1
 	local vg2=$2
 	local field=$3
-	local val1=$(vgs --noheadings -o "$field" "$vg1")
-	local val2=$(vgs --noheadings -o "$field" "$vg2")
+	local val1
+	local val2
+	val1=$(vgs --noheadings -o "$field" "$vg1")
+	val2=$(vgs --noheadings -o "$field" "$vg2")
 	test "$val1" = "$val2" || \
 		die "compare_vg_field: $vg1: $val1, $vg2: $val2"
 }
@@ -397,18 +411,23 @@ dev_md5sum() {
 
 sysfs() {
 	# read maj min and also convert hex to decimal
-	local maj=$(($(stat -L --printf=0x%t "$1")))
-	local min=$(($(stat -L --printf=0x%T "$1")))
+	local maj
+	local min
 	local P="/sys/dev/block/$maj:$min/$2"
-	local val=$(< "$P") || return 0 # no sysfs ?
+	local val
+	maj=$(($(stat -L --printf=0x%t "$1")))
+	min=$(($(stat -L --printf=0x%T "$1")))
+	val=$(< "$P") || return 0 # no sysfs ?
 	test "$val" -eq "$3" || \
 		die "$1: $P = $val differs from expected value $3!"
 }
 
 # check raid_leg_status $vg $lv "Aaaaa"
 raid_leg_status() {
-	local st=$(dmsetup status "$1-$2")
-	local val=$(echo "$st" | cut -d ' ' -f 6)
+	local st
+	local val
+	st=$(dmsetup status "$1-$2")
+	val=$(echo "$st" | cut -d ' ' -f 6)
 	test "$val" = "$3" || \
 		die "$1-$2 status $val != $3  ($st)"
 }


