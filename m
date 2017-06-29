From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:28:25 -0400
Subject: master - tests: check.sh double quote
Message-ID: <201706292028.v5TKSP9X026797@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=02729202f38825c672412f49e1073d38cdf0772b
Commit:        02729202f38825c672412f49e1073d38cdf0772b
Parent:        491fcd2a921bea6d63bbb243bfd972fda3bb6c67
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 08:23:23 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:17 2017 +0200

tests: check.sh double quote

---
 test/lib/check.sh |  114 ++++++++++++++++++++++++++--------------------------
 1 files changed, 57 insertions(+), 57 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index f2e5ff4..2eb24a5 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -41,17 +41,17 @@ lvdevices() {
 mirror_images_redundant() {
 	local vg=$1
 	local lv=$vg/$2
-	lvs -a $vg -o+devices
-	for i in $(lvdevices $lv); do
+	lvs -a "$vg" -o+devices
+	for i in $(lvdevices "$lv"); do
 		echo "# $i:"
-		lvdevices $vg/$i | sort | uniq
+		lvdevices "$vg/$i" | sort | uniq
 	done > check.tmp.all
 
 	(grep -v ^# check.tmp.all || true) | sort | uniq -d > check.tmp
 
-	test $(cat check.tmp | wc -l) -eq 0 || \
+	test "$(cat check.tmp | wc -l)" -eq 0 || \
 		die "mirror images of $lv expected redundant, but are not:" \
-			$(cat check.tmp.all)
+			"$(cat check.tmp.all)"
 }
 
 lv_err_list_() {
@@ -94,8 +94,8 @@ mirror_images_on() {
 	local vg=$1
 	local lv=$2
 	shift 2
-	for i in $(lvdevices $lv); do
-		lv_on $vg $lv $1
+	for i in $(lvdevices "$lv"); do
+		lv_on "$vg" "$lv" "$1"
 		shift
 	done
 }
@@ -105,46 +105,46 @@ mirror_log_on() {
 	local lv=$2
 	local where=$3
 	if test "$where" = "core"; then
-		get lv_field $vg/$lv mirror_log | not grep mlog
+		get lv_field "$vg/$lv" mirror_log | not grep mlog
 	else
-		lv_on $vg ${lv}_mlog "$where"
+		lv_on "$vg" "${lv}_mlog" "$where"
 	fi
 }
 
 lv_is_contiguous() {
 	local lv=$1/$2
-	test $(lvl --segments $lv | wc -l) -eq 1 || \
+	test "$(lvl --segments "$lv" | wc -l)" -eq 1 || \
 		die "LV $lv expected to be contiguous, but is not:" \
-			$(lvl --segments $lv)
+			"$(lvl --segments "$lv")"
 }
 
 lv_is_clung() {
 	local lv=$1/$2
-	test $(lvdevices $lv | sort | uniq | wc -l) -eq 1 || \
+	test "$(lvdevices "$lv" | sort | uniq | wc -l)" -eq 1 || \
 		die "LV $lv expected to be clung, but is not:" \
-			$(lvdevices $lv | sort | uniq)
+			"$(lvdevices "$lv" | sort | uniq)"
 }
 
 mirror_images_contiguous() {
-	for i in $(lvdevices $1/$2); do
-		lv_is_contiguous $1 $i
+	for i in $(lvdevices "$1/$2"); do
+		lv_is_contiguous "$1" "$i"
 	done
 }
 
 mirror_images_clung() {
-	for i in $(lvdevices $1/$2); do
-		lv_is_clung $1 $i
+	for i in $(lvdevices "$1/$2"); do
+		lv_is_clung "$1" "$i"
 	done
 }
 
 mirror() {
 	mirror_nonredundant "$@"
-	mirror_images_redundant $1 $2
+	mirror_images_redundant "$1" "$2"
 }
 
 mirror_nonredundant() {
-	local lv=$1/$2
-	local attr=$(get lv_field $lv attr)
+	local lv="$1/$2"
+	local attr=$(get lv_field "$lv" attr)
 	(echo "$attr" | grep "^......m...$" >/dev/null) || {
 		if (echo "$attr" | grep "^o.........$" >/dev/null) &&
 		   lvs -a | fgrep "[${2}_mimage" >/dev/null; then
@@ -152,30 +152,30 @@ mirror_nonredundant() {
 			echo "assuming it is actually a mirror"
 		else
 			die "$lv expected a mirror, but is not:" \
-				$(lvs $lv)
+				"$(lvs "$lv")"
 		fi
 	}
-	test -z "$3" || mirror_log_on $1 $2 "$3"
+	test -z "$3" || mirror_log_on "$1" "$2" "$3"
 }
 
 mirror_legs() {
-	local expect=$3
-	test "$expect" -eq $(lvdevices $1/$2 | wc -w)
+	local expect_legs=$3
+	test "$expect_legs" -eq "$(lvdevices "$1/$2" | wc -w)"
 }
 
 mirror_no_temporaries() {
 	local vg=$1
 	local lv=$2
-	(lvl -o name $vg | grep $lv | not grep "tmp") || \
+	(lvl -o name "$vg" | grep "$lv" | not grep "tmp") || \
 		die "$lv has temporary mirror images unexpectedly:" \
-			$(lvl $vg | grep $lv)
+			"$(lvl "$vg" | grep "$lv")"
 }
 
 linear() {
-	local lv=$1/$2
-	test $(get lv_field $lv stripes -a) -eq 1 || \
+	local lv="$1/$2"
+	test "$(get lv_field "$lv" stripes -a)" -eq 1 || \
 		die "$lv expected linear, but is not:" \
-			$(lvl $lv -o+devices)
+			"$(lvl "$lv" -o+devices)"
 }
 
 # in_sync <VG> <LV> <ignore 'a'>
@@ -188,25 +188,25 @@ in_sync() {
 	local snap=""
 	local lvm_name="$1/$2"
 	local ignore_a="$3"
-	local dm_name=$(echo $lvm_name | sed s:-:--: | sed s:/:-:)
+	local dm_name=$(echo "$lvm_name" | sed s:-:--: | sed s:/:-:)
 
 	[ -z "$ignore_a" ] && ignore_a=0
 
-	a=( $(dmsetup status $dm_name) )  || \
+	a=( $(dmsetup status "$dm_name") )  || \
 		die "Unable to get sync status of $1"
 
-	if [ ${a[2]} = "snapshot-origin" ]; then
-		a=( $(dmsetup status ${dm_name}-real) ) || \
+	if [ "${a[2]}" = "snapshot-origin" ]; then
+		a=( $(dmsetup status "${dm_name}-real") ) || \
 			die "Unable to get sync status of $1"
 		snap=": under snapshot"
 	fi
 
-	case ${a[2]} in
+	case "${a[2]}" in
 	"raid")
 		# 6th argument is the sync ratio for RAID
 		idx=6
 		type=${a[3]}
-		if [ ${a[$(($idx + 1))]} != "idle" ]; then
+		if [ "${a[$(($idx + 1))]}" != "idle" ]; then
 			echo "$lvm_name ($type$snap) is not in-sync"
 			return 1
 		fi
@@ -221,9 +221,9 @@ in_sync() {
 		;;
 	esac
 
-	b=( $(echo ${a[$idx]} | sed s:/:' ':) )
+	b=( $(echo "${a[$idx]}" | sed s:/:' ':) )
 
-	if [ ${b[0]} -eq 0 -o ${b[0]} != ${b[1]} ]; then
+	if [ "${b[0]}" -eq 0 -o "${b[0]}" != "${b[1]}" ]; then
 		echo "$lvm_name ($type$snap) is not in-sync"
 		return 1
 	fi
@@ -239,20 +239,20 @@ in_sync() {
 }
 
 active() {
-	local lv=$1/$2
-	(get lv_field $lv attr | grep "^....a.....$" >/dev/null) || \
+	local lv="$1/$2"
+	(get lv_field "$lv" attr | grep "^....a.....$" >/dev/null) || \
 		die "$lv expected active, but lvs says it's not:" \
-			$(lvl $lv -o+devices)
-	dmsetup info $1-$2 >/dev/null ||
+			"$(lvl "$lv" -o+devices)"
+	dmsetup info "$1-$2" >/dev/null ||
 		die "$lv expected active, lvs thinks it is but there are no mappings!"
 }
 
 inactive() {
-	local lv=$1/$2
-	(get lv_field $lv attr | grep "^....[-isd].....$" >/dev/null) || \
+	local lv="$1/$2"
+	(get lv_field "$lv" attr | grep "^....[-isd].....$" >/dev/null) || \
 		die "$lv expected inactive, but lvs says it's not:" \
-			$(lvl $lv -o+devices)
-	not dmsetup info $1-$2 2>/dev/null || \
+			"$(lvl "$lv" -o+devices)"
+	not dmsetup info "$1-$2" 2>/dev/null || \
 		die "$lv expected inactive, lvs thinks it is but there are mappings!"
 }
 
@@ -265,20 +265,20 @@ lv_exists() {
 		lv="$lv $vg/$1"
 	done
 	test -n "$lv" || lv=$vg
-	lvl $lv &>/dev/null || \
+	lvl "$lv" &>/dev/null || \
 		die "$lv expected to exist but does not"
 }
 
 lv_not_exists() {
 	local vg=$1
 	if test $# -le 1 ; then
-		if lvl $vg &>/dev/null ; then
+		if lvl "$vg" &>/dev/null ; then
 			die "$vg expected to not exist but it does!"
 		fi
 	else
 		while [ $# -gt 1 ]; do
 			shift
-			not lvl $vg/$1 &>/dev/null || die "$vg/$1 expected to not exist but it does!"
+			not lvl "$vg/$1" &>/dev/null || die "$vg/$1 expected to not exist but it does!"
 		done
 	fi
 	rm -f debug.log
@@ -371,8 +371,8 @@ compare_vg_field() {
 	local vg1=$1
 	local vg2=$2
 	local field=$3
-	local val1=$(vgs --noheadings -o "$field" $vg1)
-	local val2=$(vgs --noheadings -o "$field" $vg2)
+	local val1=$(vgs --noheadings -o "$field" "$vg1")
+	local val2=$(vgs --noheadings -o "$field" "$vg2")
 	test "$val1" = "$val2" || \
 		die "compare_vg_field: $vg1: $val1, $vg2: $val2"
 }
@@ -382,16 +382,16 @@ pvlv_counts() {
 	local num_pvs=$2
 	local num_lvs=$3
 	local num_snaps=$4
-	lvs -o+devices $local_vg
-	vg_field $local_vg pv_count $num_pvs
-	vg_field $local_vg lv_count $num_lvs
-	vg_field $local_vg snap_count $num_snaps
+	lvs -o+devices "$local_vg"
+	vg_field "$local_vg" pv_count "$num_pvs"
+	vg_field "$local_vg" lv_count "$num_lvs"
+	vg_field "$local_vg" snap_count "$num_snaps"
 }
 
 # Compare md5 check generated from get dev_md5sum
 dev_md5sum() {
 	md5sum -c "md5.$1-$2" || \
-		(get lv_field $1/$2 "name,size,seg_pe_ranges"
+		(get lv_field "$1/$2" "name,size,seg_pe_ranges"
 		 die "LV $1/$2 has different MD5 check sum!")
 }
 
@@ -407,14 +407,14 @@ sysfs() {
 
 # check raid_leg_status $vg $lv "Aaaaa"
 raid_leg_status() {
-	local st=$(dmsetup status $1-$2)
+	local st=$(dmsetup status "$1-$2")
 	local val=$(echo "$st" | cut -d ' ' -f 6)
 	test "$val" = "$3" || \
 		die "$1-$2 status $val != $3  ($st)"
 }
 
 grep_dmsetup() {
-	dmsetup $1 $2 | tee out
+	dmsetup "$1" "$2" | tee out
 	grep -q "${@:3}" out || die "Expected output \"${@:3}\" from dmsetup $1 not found!"
 }
 


