From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 12 Jul 2013 19:39:11 +0000 (UTC)
Subject: master - tests: fix tests to cope with latest changes
Message-ID: <20130712193911.1B9A9612BC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=55d418fb2045e715a2ad5689fac48c32089d016a
Commit:        55d418fb2045e715a2ad5689fac48c32089d016a
Parent:        8d1e5113638dbca6a32166bb2d6691b11c37f0d4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jul 12 13:07:40 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 12 20:54:17 2013 +0200

tests: fix tests to cope with latest changes

- lvs -o lv_attr has now 10 indicator bits
- use '--ignoremonitoring' instead of the shortcut '--ig' used before (since
it would be ambiguous with new '--ignoreactivationskip')
---
 test/lib/check.sh                                 |    8 +-
 test/shell/dmeventd-restart.sh                    |    4 +-
 test/shell/lvchange-raid.sh                       |   62 ++++++++++----------
 test/shell/lvconvert-repair-dmeventd.sh           |    2 +-
 test/shell/lvconvert-repair-policy.sh             |    2 +-
 test/shell/lvconvert-repair-replace.sh            |   12 ++--
 test/shell/lvconvert-repair-snapshot.sh           |    2 +-
 test/shell/lvconvert-repair-transient-dmeventd.sh |    2 +-
 test/shell/lvconvert-repair-transient.sh          |    2 +-
 test/shell/lvconvert-repair.sh                    |   12 ++--
 test/shell/lvconvert-twostep.sh                   |    2 +-
 11 files changed, 55 insertions(+), 55 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 8db0c65..8b2cfce 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -118,8 +118,8 @@ mirror() {
 mirror_nonredundant() {
 	local lv=$1/$2
 	local attr=$(get lv_field $lv attr)
-	(echo "$attr" | grep "^......m..$" >/dev/null) || {
-		if (echo "$attr" | grep "^o........$" >/dev/null) &&
+	(echo "$attr" | grep "^......m...$" >/dev/null) || {
+		if (echo "$attr" | grep "^o.........$" >/dev/null) &&
 		   lvs -a | fgrep "[${2}_mimage" >/dev/null; then
 			echo "TEST WARNING: $lv is a snapshot origin and looks like a mirror,"
 			echo "assuming it is actually a mirror"
@@ -200,7 +200,7 @@ in_sync() {
 
 active() {
 	local lv=$1/$2
-	(get lv_field $lv attr | grep "^....a....$" >/dev/null) || \
+	(get lv_field $lv attr | grep "^....a.....$" >/dev/null) || \
 		die "$lv expected active, but lvs says it's not:" \
 			$(lvl $lv -o+devices)
 	dmsetup info $1-$2 >/dev/null ||
@@ -209,7 +209,7 @@ active() {
 
 inactive() {
 	local lv=$1/$2
-	(get lv_field $lv attr | grep "^....[-isd]....$" >/dev/null) || \
+	(get lv_field $lv attr | grep "^....[-isd].....$" >/dev/null) || \
 		die "$lv expected inactive, but lvs says it's not:" \
 			$(lvl $lv -o+devices)
 	not dmsetup info $1-$2 2>/dev/null || \
diff --git a/test/shell/dmeventd-restart.sh b/test/shell/dmeventd-restart.sh
index 726f97f..a90b7c7 100644
--- a/test/shell/dmeventd-restart.sh
+++ b/test/shell/dmeventd-restart.sh
@@ -15,9 +15,9 @@ aux prepare_dmeventd
 
 aux prepare_vg 5
 
-lvcreate -aey -m 3 --nosync --ig -l1 -n 4way $vg
+lvcreate -aey -m 3 --nosync --ignoremonitoring -l1 -n 4way $vg
 lvchange --monitor y $vg/4way
-lvcreate -aey -m 2 --nosync --ig -l1 -n 3way $vg
+lvcreate -aey -m 2 --nosync --ignoremonitoring -l1 -n 3way $vg
 lvchange --monitor y $vg/3way
 
 dmeventd -R -f &
diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 1dbd42a..d7878a7 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -29,8 +29,8 @@ run_writemostly_check() {
 	d1=$(sed s/^[[:space:]]*// <<< "$d1")
 
 	# No writemostly flag should be there yet.
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-$'
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*-$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-.$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*-.$'
 
 	if [ `lvs --noheadings -o segtype $1/$2` != "raid1" ]; then
 		not lvchange --writemostly $d0 $1/$2
@@ -39,61 +39,61 @@ run_writemostly_check() {
 
 	# Set the flag
 	lvchange --writemostly $d0 $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w.$'
 
 	# Running again should leave it set (not toggle)
 	lvchange --writemostly $d0 $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w.$'
 
 	# Running again with ':y' should leave it set
 	lvchange --writemostly $d0:y $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w.$'
 
 	# ':n' should unset it
 	lvchange --writemostly $d0:n $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-.$'
 
 	# ':n' again should leave it unset
 	lvchange --writemostly $d0:n $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-.$'
 
 	# ':t' toggle to set
 	lvchange --writemostly $d0:t $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w.$'
 
 	# ':t' toggle to unset
 	lvchange --writemostly $d0:t $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-.$'
 
 	# ':y' to set
 	lvchange --writemostly $d0:y $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w.$'
 
 	# Toggle both at once
 	lvchange --writemostly $d0:t --writemostly $d1:t $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-$'
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*w$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-.$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*w.$'
 
 	# Toggle both@once again
 	lvchange --writemostly $d0:t --writemostly $d1:t $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*-$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w.$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*-.$'
 
 	# Toggle one, unset the other
 	lvchange --writemostly $d0:n --writemostly $d1:t $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-$'
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*w$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-.$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*w.$'
 
 	# Toggle one, set the other
 	lvchange --writemostly $d0:y --writemostly $d1:t $1/$2
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*-$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w.$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*-.$'
 
 	# Partial flag supercedes writemostly flag
 	aux disable_dev $d0
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*p$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*p.$'
 	aux enable_dev $d0
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w.$'
 
 	# Catch Bad writebehind values
 	not lvchange --writebehind "invalid" $1/$2
@@ -108,8 +108,8 @@ run_writemostly_check() {
 	lvconvert -m 0 $1/$2 $d1
 	lvconvert --type raid1 -m 1 $1/$2 $d1
 	[ ! `lvs --noheadings -o writebehind $1/$2` ]
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-$'
-	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*-$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-.$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*-.$'
 }
 
 # run_syncaction_check <VG> <LV>
@@ -141,7 +141,7 @@ run_syncaction_check() {
 	seek=$(($seek + $size)) # Jump halfway through the RAID image
 
 	# Check all is normal
-	if ! lvs --noheadings -o lv_attr $1/$2 | grep '.*-$' ||
+	if ! lvs --noheadings -o lv_attr $1/$2 | grep '.*-.$' ||
 		[ `lvs --noheadings -o mismatches $1/$2` != 0 ]; then
 
 		# I think this is a kernel bug.  It happens randomly after
@@ -159,7 +159,7 @@ run_syncaction_check() {
 		sync
 	fi
 
-	lvs --noheadings -o lv_attr $1/$2 | grep '.*-$'
+	lvs --noheadings -o lv_attr $1/$2 | grep '.*-.$'
 	[ `lvs --noheadings -o mismatches $1/$2` == 0 ]
 
 	# Overwrite the last half of one of the PVs with crap
@@ -173,20 +173,20 @@ run_syncaction_check() {
 	# 'lvs' should show results
 	lvchange --syncaction check $1/$2
 	aux wait_for_sync $1 $2
-	lvs --noheadings -o lv_attr $1/$2 | grep '.*m$'
+	lvs --noheadings -o lv_attr $1/$2 | grep '.*m.$'
 	[ `lvs --noheadings -o mismatches $1/$2` != 0 ]
 
 	# "repair" will fix discrepancies and record number fixed
 	lvchange --syncaction repair $1/$2
 	aux wait_for_sync $1 $2
-	lvs --noheadings -o lv_attr $1/$2 | grep '.*m$'
+	lvs --noheadings -o lv_attr $1/$2 | grep '.*m.$'
 	[ `lvs --noheadings -o mismatches $1/$2` != 0 ]
 
 	# Final "check" should show no mismatches
 	# 'lvs' should show results
 	lvchange --syncaction check $1/$2
 	aux wait_for_sync $1 $2
-	lvs --noheadings -o lv_attr $1/$2 | grep '.*-$'
+	lvs --noheadings -o lv_attr $1/$2 | grep '.*-.$'
 	[ `lvs --noheadings -o mismatches $1/$2` == 0 ]
 }
 
@@ -208,16 +208,16 @@ run_refresh_check() {
 	dd if=/dev/urandom of=/dev/$1/$2 bs=1k count=$size
 
 	# Check for 'p'artial flag
-	lvs --noheadings -o lv_attr $1/$2 | grep '.*p$'
+	lvs --noheadings -o lv_attr $1/$2 | grep '.*p.$'
 
 	aux enable_dev "$dev2"
 
 	# Check for 'r'efresh flag
-	lvs --noheadings -o lv_attr $1/$2 | grep '.*r$'
+	lvs --noheadings -o lv_attr $1/$2 | grep '.*r.$'
 
 	lvchange --refresh $1/$2
 	aux wait_for_sync $1 $2
-	lvs --noheadings -o lv_attr $1/$2 | grep '.*-$'
+	lvs --noheadings -o lv_attr $1/$2 | grep '.*-.$'
 
 	# Writing random data above should mean that the devices
 	# were out-of-sync.  The refresh should have taken care
@@ -225,7 +225,7 @@ run_refresh_check() {
 	# are repaired, it will show up in the 'lvs' output.
 	lvchange --syncaction repair $1/$2
 	aux wait_for_sync $1 $2
-	lvs --noheadings -o lv_attr $1/$2 | grep '.*-$'
+	lvs --noheadings -o lv_attr $1/$2 | grep '.*-.$'
 }
 
 # run_checks <VG> <LV> [snapshot_dev]
diff --git a/test/shell/lvconvert-repair-dmeventd.sh b/test/shell/lvconvert-repair-dmeventd.sh
index a1a1669..bde30d7 100644
--- a/test/shell/lvconvert-repair-dmeventd.sh
+++ b/test/shell/lvconvert-repair-dmeventd.sh
@@ -16,7 +16,7 @@ which mkfs.ext2 || skip
 aux prepare_vg 5
 aux prepare_dmeventd
 
-lvcreate -aey -m 3 --ig -L 1 -n 4way $vg
+lvcreate -aey -m 3 --ignoremonitoring -L 1 -n 4way $vg
 lvchange --monitor y $vg/4way
 aux disable_dev "$dev2" "$dev4"
 mkfs.ext2 $DM_DEV_DIR/$vg/4way
diff --git a/test/shell/lvconvert-repair-policy.sh b/test/shell/lvconvert-repair-policy.sh
index 8c60e94..695c27d 100644
--- a/test/shell/lvconvert-repair-policy.sh
+++ b/test/shell/lvconvert-repair-policy.sh
@@ -23,7 +23,7 @@ cleanup() {
 	for d in "$@"; do aux enable_dev "$d"; done
 	for d in "$@"; do vgextend $vg "$d"; done
 	lvremove -ff $vg/mirror
-	lvcreate -aey -m 1 --ig -l 2 -n mirror $vg "$dev1" "$dev2" "$dev3":0
+	lvcreate -aey -m 1 --ignoremonitoring -l 2 -n mirror $vg "$dev1" "$dev2" "$dev3":0
 }
 
 repair() {
diff --git a/test/shell/lvconvert-repair-replace.sh b/test/shell/lvconvert-repair-replace.sh
index 4ef3687..1666b78 100644
--- a/test/shell/lvconvert-repair-replace.sh
+++ b/test/shell/lvconvert-repair-replace.sh
@@ -17,7 +17,7 @@ aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 
 # 3-way, disk log
 # multiple failures, full replace
-lvcreate -aey --mirrorlog disk -m 2 --ig --nosync -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4":0-1
+lvcreate -aey --mirrorlog disk -m 2 --ignoremonitoring --nosync -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4":0-1
 aux disable_dev "$dev1" "$dev2"
 lvconvert -y --repair $vg/3way 2>&1 | tee 3way.out
 lvs -a -o +devices $vg | not grep unknown
@@ -30,7 +30,7 @@ vgremove -ff $vg
 # 3-way, disk log
 # multiple failures, partial replace
 vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
-lvcreate -aey --mirrorlog disk -m 2 --ig --nosync -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4"
+lvcreate -aey --mirrorlog disk -m 2 --ignoremonitoring --nosync -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4"
 aux disable_dev "$dev1" "$dev2"
 lvconvert -y --repair $vg/3way 2>&1 | tee 3way.out
 grep "WARNING: Failed" 3way.out
@@ -41,7 +41,7 @@ aux enable_dev "$dev1" "$dev2"
 vgremove -ff $vg
 
 vgcreate $vg "$dev1" "$dev2" "$dev3"
-lvcreate -aey --mirrorlog disk -m 1 --ig --nosync -l 1 -n 2way $vg "$dev1" "$dev2" "$dev3"
+lvcreate -aey --mirrorlog disk -m 1 --ignoremonitoring --nosync -l 1 -n 2way $vg "$dev1" "$dev2" "$dev3"
 aux disable_dev "$dev1"
 lvconvert -y --repair $vg/2way 2>&1 | tee 2way.out
 grep "WARNING: Failed" 2way.out
@@ -54,7 +54,7 @@ vgremove -ff $vg
 # Test repair of inactive mirror with log failure
 #  Replacement should fail, but convert should succeed (switch to corelog)
 vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4"
-lvcreate -aey -m 2 --ig --nosync -l 2 -n mirror2 $vg "$dev1" "$dev2" "$dev3" "$dev4":0
+lvcreate -aey -m 2 --ignoremonitoring --nosync -l 2 -n mirror2 $vg "$dev1" "$dev2" "$dev3" "$dev4":0
 vgchange -a n $vg
 pvremove -ff -y "$dev4"
 lvconvert -y --repair $vg/mirror2
@@ -69,7 +69,7 @@ if kernel_at_least 3 0 0; then
 	# 2-way, mirrored log
 	# Double log failure, full replace
 	vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
-	lvcreate -aey --mirrorlog mirrored -m 1 --ig --nosync -L 1 -n 2way $vg \
+	lvcreate -aey --mirrorlog mirrored -m 1 --ignoremonitoring --nosync -L 1 -n 2way $vg \
 	    "$dev1" "$dev2" "$dev3":0 "$dev4":0
 	aux disable_dev "$dev3" "$dev4"
 	lvconvert -y --repair $vg/2way 2>&1 | tee 2way.out
@@ -84,7 +84,7 @@ fi
 # 3-way, mirrored log
 # Single log failure, replace
 vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
-lvcreate -aey --mirrorlog mirrored -m 2 --ig --nosync -L 1 -n 3way $vg \
+lvcreate -aey --mirrorlog mirrored -m 2 --ignoremonitoring --nosync -L 1 -n 3way $vg \
     "$dev1" "$dev2" "$dev3" "$dev4":0 "$dev5":0
 aux disable_dev "$dev4"
 lvconvert -y --repair $vg/3way 2>&1 | tee 3way.out
diff --git a/test/shell/lvconvert-repair-snapshot.sh b/test/shell/lvconvert-repair-snapshot.sh
index 5c47be8..218ec0b 100644
--- a/test/shell/lvconvert-repair-snapshot.sh
+++ b/test/shell/lvconvert-repair-snapshot.sh
@@ -15,7 +15,7 @@ aux prepare_vg 5
 aux lvmconf 'allocation/maximise_cling = 0'
 aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 
-lvcreate -aey -m 3 --ig -L 2M -n 4way $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5":0
+lvcreate -aey -m 3 --ignoremonitoring -L 2M -n 4way $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5":0
 lvcreate -s $vg/4way -L 2M -n snap
 
 aux disable_dev "$dev2" "$dev4"
diff --git a/test/shell/lvconvert-repair-transient-dmeventd.sh b/test/shell/lvconvert-repair-transient-dmeventd.sh
index 8d1a2f1..835c6b4 100644
--- a/test/shell/lvconvert-repair-transient-dmeventd.sh
+++ b/test/shell/lvconvert-repair-transient-dmeventd.sh
@@ -14,7 +14,7 @@
 aux prepare_vg 5
 aux prepare_dmeventd
 
-lvcreate -aey -m 3 --ig -L 1 -n 4way $vg
+lvcreate -aey -m 3 --ignoremonitoring -L 1 -n 4way $vg
 lvchange --monitor y $vg/4way
 aux disable_dev "$dev2" "$dev4"
 mkfs.ext3 $DM_DEV_DIR/$vg/4way
diff --git a/test/shell/lvconvert-repair-transient.sh b/test/shell/lvconvert-repair-transient.sh
index 58d4889..a87bdb3 100644
--- a/test/shell/lvconvert-repair-transient.sh
+++ b/test/shell/lvconvert-repair-transient.sh
@@ -13,7 +13,7 @@
 
 aux prepare_vg 5
 
-lvcreate -aey -m 3 --ig -L 1 -n 4way $vg
+lvcreate -aey -m 3 --ignoremonitoring -L 1 -n 4way $vg
 aux disable_dev "$dev2" "$dev4"
 mkfs.ext3 $DM_DEV_DIR/$vg/4way &
 sleep 1
diff --git a/test/shell/lvconvert-repair.sh b/test/shell/lvconvert-repair.sh
index 37c3b00..0113ec4 100644
--- a/test/shell/lvconvert-repair.sh
+++ b/test/shell/lvconvert-repair.sh
@@ -33,7 +33,7 @@ aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 
 # 4-way, disk log => 2-way, disk log
 aux prepare_vg 8
-lvcreate -aey -m 3 --ig -L 1 -n 4way $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5":0
+lvcreate -aey -m 3 --ignoremonitoring -L 1 -n 4way $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5":0
 aux disable_dev "$dev2" "$dev4"
 echo n | lvconvert --repair $vg/4way 2>&1 | tee 4way.out
 lvs -a -o +devices $vg | not grep unknown
@@ -43,7 +43,7 @@ check mirror $vg 4way "$dev5"
 
 # 3-way, disk log => linear
 recreate_vg_
-lvcreate -aey -m 2 --ig -L 1 -n 3way $vg
+lvcreate -aey -m 2 --ignoremonitoring -L 1 -n 3way $vg
 aux disable_dev "$dev1" "$dev2"
 echo n | lvconvert --repair $vg/3way
 check linear $vg 3way
@@ -56,7 +56,7 @@ check linear $vg 3way
 
 # 3-way, disk log => 3-way, core log
 recreate_vg_
-lvcreate -aey -m 2 --ig -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4":0
+lvcreate -aey -m 2 --ignoremonitoring -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4":0
 aux disable_dev "$dev4"
 echo n | lvconvert --repair $vg/3way
 check mirror $vg 3way core
@@ -66,7 +66,7 @@ aux enable_dev "$dev4"
 
 # 3-way, mirrored log => 3-way, core log
 recreate_vg_ -c n
-lvcreate -aey -m 2 --mirrorlog mirrored --ig -L 1 -n 3way $vg \
+lvcreate -aey -m 2 --mirrorlog mirrored --ignoremonitoring -L 1 -n 3way $vg \
     "$dev1" "$dev2" "$dev3" "$dev4":0 "$dev5":0
 aux disable_dev "$dev4" "$dev5"
 echo n | lvconvert --repair $vg/3way
@@ -77,7 +77,7 @@ aux enable_dev "$dev4" "$dev5"
 
 # 2-way, disk log => 2-way, core log
 recreate_vg_
-lvcreate -aey -m 1 --ig -L 1 -n 2way $vg "$dev1" "$dev2" "$dev3":0
+lvcreate -aey -m 1 --ignoremonitoring -L 1 -n 2way $vg "$dev1" "$dev2" "$dev3":0
 aux disable_dev "$dev3"
 echo n | lvconvert --repair $vg/2way
 check mirror $vg 2way core
@@ -90,7 +90,7 @@ aux enable_dev "$dev3"
 recreate_vg_
 vgreduce $vg "$dev4"
 
-lvcreate -aey -m 1 --ig -L 1 -n mirror $vg
+lvcreate -aey -m 1 --ignoremonitoring -L 1 -n mirror $vg
 lvchange -a n $vg/mirror
 vgextend $vg "$dev4"
 aux disable_dev "$dev1"
diff --git a/test/shell/lvconvert-twostep.sh b/test/shell/lvconvert-twostep.sh
index 08a26b0..e785a22 100644
--- a/test/shell/lvconvert-twostep.sh
+++ b/test/shell/lvconvert-twostep.sh
@@ -13,7 +13,7 @@
 
 aux prepare_vg 4
 
-lvcreate -aey -m 1 --mirrorlog disk --ig -L 1 -n mirror $vg
+lvcreate -aey -m 1 --mirrorlog disk --ignoremonitoring -L 1 -n mirror $vg
 not lvconvert -m 2 --mirrorlog core $vg/mirror "$dev3" 2>&1 | tee errs
 grep "two steps" errs
 


