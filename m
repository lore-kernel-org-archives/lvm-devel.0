From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:06:05 +0000 (GMT)
Subject: main - shellcheck: updates
Message-ID: <20210423210605.628DD39450F4@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f678052385dd7fe04e4d4c3681b7dd58b1bca64b
Commit:        f678052385dd7fe04e4d4c3681b7dd58b1bca64b
Parent:        6a099707c433f0b3f2644c52f7773751832693a4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 23:22:01 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

shellcheck: updates

Ehance some shellcheck reported issues.
---
 scripts/fsadm.sh         |  2 +-
 scripts/lvmdump.sh.in    |  2 +-
 scripts/vgimportclone.sh | 12 ++++++------
 test/api/dbustest.sh     |  2 +-
 test/lib/aux.sh          | 20 ++++++++++----------
 test/lib/check.sh        |  6 +++---
 test/lib/utils.sh        |  2 +-
 7 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 3e1f3d405..9ae422f55 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -383,7 +383,7 @@ detect_device_size() {
 		test -n "$DEVSIZE" || error "Cannot read size of device \"$VOLUME\"."
 		SSSIZE=$("$BLOCKDEV" --getss "$VOLUME" || true)
 		test -n "$SSSIZE" || error "Cannot read sector size of device \"$VOLUME\"."
-		DEVSIZE=$(( $DEVSIZE * $SSSIZE ))
+		DEVSIZE=$(( DEVSIZE * SSSIZE ))
 	fi
 }
 
diff --git a/scripts/lvmdump.sh.in b/scripts/lvmdump.sh.in
index 8507151d8..0685d85fb 100644
--- a/scripts/lvmdump.sh.in
+++ b/scripts/lvmdump.sh.in
@@ -163,7 +163,7 @@ if (( clustered )); then
 
 	{
 	for i in nodes status services; do
-		cap_i=$(echo "$i"|tr a-z A-Z)
+		cap_i=$(echo "$i"|tr "[:lower:]" "[:upper:]")
 		echo "$cap_i:"
 		echo "----------------------------------"
 		log "cman_tool $i 2>> \"$log\""
diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index d56827f1e..3d795048a 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -18,11 +18,11 @@
 
 # following external commands are used throughout the script
 # echo and test are internal in bash at least
-RM=rm
-BASENAME=basename
-MKTEMP=mktemp
-READLINK=readlink
-GETOPT=getopt
+RM="rm"
+BASENAME="basename"
+MKTEMP="mktemp"
+READLINK="readlink"
+GETOPT="getopt"
 
 # user may override lvm location by setting LVM_BINARY
 LVM=${LVM_BINARY:-lvm}
@@ -145,7 +145,7 @@ do
             shift
             ;;
         -v|--verbose)
-            let VERBOSE_COUNT=VERBOSE_COUNT+1
+            VERBOSE_COUNT=$(( VERBOSE_COUNT + 1 ))
             if [ -z "$VERBOSE" ]
             then
                 VERBOSE="-v"
diff --git a/test/api/dbustest.sh b/test/api/dbustest.sh
index 622022277..f4c9c9c2a 100644
--- a/test/api/dbustest.sh
+++ b/test/api/dbustest.sh
@@ -18,7 +18,7 @@ SKIP_WITH_CLVMD=1
 . lib/inittest
 
 # Unsupported with valgrid testing
-test ${LVM_VALGRIND:-0} -eq 0 || skip "Unsupported with valgrind"
+test "${LVM_VALGRIND:-0}" -eq 0 || skip "Unsupported with valgrind"
 
 # NOTE: Some tests, namely anything with vdo, and
 # api/dbus_test_lv_interface_cache_lv.sh, require larger PVs
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 5cdbe1302..1a1f11a1d 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -586,7 +586,7 @@ teardown() {
 	}
 
 	# Remove any metadata archives and backups from this test on system
-	rm -f /etc/lvm/archive/${PREFIX}* /etc/lvm/backup/${PREFIX}*
+	rm -f /etc/lvm/archive/"${PREFIX}"* /etc/lvm/backup/"${PREFIX}"*
 
 	echo "ok"
 }
@@ -669,7 +669,7 @@ prepare_real_devs() {
 			aux extend_filter "a|$path|"
 			dd if=/dev/zero of="$path" bs=32k count=1
 			wipefs -a "$path" 2>/dev/null || true
-		done < $LVM_TEST_DEVICE_LIST
+		done < "$LVM_TEST_DEVICE_LIST"
 	fi
 	printf "%s\\n" "${REAL_DEVICES[@]}" > REAL_DEVICES
 }
@@ -810,9 +810,9 @@ cleanup_md_dev() {
 	# try to find and remove any DM device on top of cleaned MD
 	# assume  /dev/mdXXX is  9:MINOR
 	local minor=${mddev##/dev/md}
-	for i in $(dmsetup table | grep 9:$minor | cut -d: -f1) ; do
-		dmsetup remove $i || {
-			dmsetup --force remove $i || true
+	for i in $(dmsetup table | grep 9:"$minor" | cut -d: -f1) ; do
+		dmsetup remove "$i" || {
+			dmsetup --force remove "$i" || true
 		}
 	done
 
@@ -842,7 +842,7 @@ wipefs_a() {
 	shift
 
 	if test -n "$LVM_TEST_DEVICES_FILE"; then
-		lvmdevices --deldev $dev || true
+		lvmdevices --deldev "$dev" || true
 	fi
 
 	if test -f HAVE_WIPEFS ; then
@@ -866,7 +866,7 @@ wipefs_a() {
 	fi
 
 	if test -n "$LVM_TEST_DEVICES_FILE"; then
-		lvmdevices --adddev $dev || true
+		lvmdevices --adddev "$dev" || true
 	fi
 
 	udev_wait
@@ -954,10 +954,10 @@ prepare_devs() {
 	done
 
 	if test -n "$LVM_TEST_DEVICES_FILE"; then
-		mkdir -p $TESTDIR/etc/lvm/devices || true
-		rm $TESTDIR/etc/lvm/devices/system.devices || true
+		mkdir -p "$TESTDIR/etc/lvm/devices" || true
+		rm "$TESTDIR/etc/lvm/devices/system.devices" || true
 		for d in "${DEVICES[@]}"; do
-			lvmdevices --adddev $dev || true
+			lvmdevices --adddev "$dev" || true
 		done
 	fi
 
diff --git a/test/lib/check.sh b/test/lib/check.sh
index 5b119430d..8493bde83 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -157,7 +157,7 @@ mirror_nonredundant() {
 	attr=$(get lv_field "$lv" attr)
 	(echo "$attr" | grep "^......m...$" >/dev/null) || {
 		if (echo "$attr" | grep "^o.........$" >/dev/null) &&
-		   lvs -a $1 | grep -F "[${2}_mimage" >/dev/null; then
+		   lvs -a "$1" | grep -F "[${2}_mimage" >/dev/null; then
 			echo "TEST WARNING: $lv is a snapshot origin and looks like a mirror,"
 			echo "assuming it is actually a mirror"
 		else
@@ -439,7 +439,7 @@ raid_leg_status() {
 
 	# Ignore inconsisten raid status 0/xxxxx idle
 	for i in {100..0} ; do
-		st=( $(dmsetup status $1-$2) ) || die "Unable to get status of $vg/$lv1"
+		st=( $(dmsetup status "$1-$2") ) || die "Unable to get status of $vg/$lv1"
 		b=( $(echo "${st[6]}" | sed s:/:' ':) )
 		[ "${b[0]}" = "0" ] || {
 			test "${st[5]}" = "$3" || break
@@ -448,7 +448,7 @@ raid_leg_status() {
 		sleep .1
 	done
 
-	die "$1-$2 status ${st[5]} != $3  ($st)"
+	die "$1-$2 status ${st[5]} != $3  (${st[*]})"
 }
 
 grep_dmsetup() {
diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 400cacd0c..0e41589bd 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -279,7 +279,7 @@ prepare_test_vars() {
 		while read path; do
 			count=$((  count + 1 ))
 			eval "dev$count=\"$path\""
-		done < $LVM_TEST_DEVICE_LIST
+		done < "$LVM_TEST_DEVICE_LIST"
 	else
 		for i in {1..16}; do
 			eval "dev$i=\"$DM_DEV_DIR/mapper/${PREFIX}pv$i\""


