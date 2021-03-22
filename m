From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 22 Mar 2021 21:53:57 +0000 (GMT)
Subject: main - tests: remove unused wait_md_create
Message-ID: <20210322215357.86D3D3858D29@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=077040199d98e939446d4b51597eeeae84ae28d5
Commit:        077040199d98e939446d4b51597eeeae84ae28d5
Parent:        7166bbd9c26cf5d06067cfb85eb86352b4152c3c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 22 22:07:23 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 22 22:51:24 2021 +0100

tests: remove unused wait_md_create

---
 test/lib/aux.sh | 80 ---------------------------------------------------------
 1 file changed, 80 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index e406e47ce..e26aa9912 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -421,16 +421,9 @@ teardown_devs() {
 	teardown_udev_cookies
 
 	test ! -f MD_DEV || cleanup_md_dev
-
-	test ! -f WAIT_MD_DEV || mddev=$(< WAIT_MD_DEV)
-	udev_wait
-	test ! -f WAIT_MD_DEV || mdadm --stop $mddev || true
-	udev_wait
 	test ! -f DEVICES || teardown_devs_prefixed "$PREFIX"
 	test ! -f RAMDISK || { modprobe -r brd || true ; }
 
-	test ! -f WAIT_MD_DEV || mdadm --stop $mddev || true
-
 	# NOTE: SCSI_DEBUG_DEV test must come before the LOOP test because
 	# prepare_scsi_debug_dev() also sets LOOP to short-circuit prepare_loop()
 	if test -f SCSI_DEBUG_DEV; then
@@ -716,64 +709,6 @@ cleanup_scsi_debug_dev() {
 	rm -f SCSI_DEBUG_DEV LOOP
 }
 
-prepare_md_dev() {
-	local level=$1
-	local rchunk=$2
-	local rdevs=$3
-	local with_bitmap="--bitmap=internal"
-	local coption="--chunk"
-	local maj
-	local mddev
-	local mddir="md/"
-	local mdname
-	local mddevdir
-	maj=$(mdadm --version 2>&1) || skip "mdadm tool is missing!"
-
-	cleanup_md_dev
-
-	rm -f debug.log strace.log
-
-	case "$level" in
-	"1")  coption="--bitmap-chunk" ;;
-	"0")  with_bitmap="" ;;
-	esac
-	# Have MD use a non-standard name to avoid colliding with an existing MD device
-	# - mdadm >= 3.0 requires that non-standard device names be in /dev/md/
-	# - newer mdadm _completely_ defers to udev to create the associated device node
-	maj=${maj##*- v}
-	maj=${maj%%.*}
-	[ "$maj" -ge 3 ] || mddir=""
-
-	mdname="md_lvm_test0"
-	mddev="/dev/${mddir}$mdname"
-	mddevdir="$DM_DEV_DIR/$mddir"
-
-	mdadm --create --metadata=1.0 "$mddev" --auto=md --level "$level" $with_bitmap "$coption"="$rchunk" --raid-devices="$rdevs" "${@:4}" || {
-		# Some older 'mdadm' version managed to open and close devices internaly
-		# and reporting non-exclusive access on such device
-		# let's just skip the test if this happens.
-		# Note: It's pretty complex to get rid of consequences
-		#       the following sequence avoid leaks on f19
-		# TODO: maybe try here to recreate few times....
-		mdadm --stop "$mddev" || true
-		udev_wait
-		mdadm --zero-superblock "${@:4}" || true
-		udev_wait
-		skip "Test skipped, unreliable mdadm detected!"
-	}
-	test -b "$mddev" || skip "mdadm has not created device!"
-
-	# LVM/DM will see this device
-	case "$DM_DEV_DIR" in
-	"/dev") readlink -f "$mddev" > MD_DEV_PV ;;
-	*)	mkdir -p "$mddevdir"
-		cp -LR "$mddev" "$mddevdir"
-		echo "${mddevdir}${mdname}" > MD_DEV_PV ;;
-	esac
-	echo "$mddev" > MD_DEV
-	printf "%s\n" "${@:4}" > MD_DEVICES
-}
-
 mdadm_create() {
 	local mddev
 	local maj=
@@ -872,21 +807,6 @@ cleanup_md_dev() {
 	rm -f MD_DEV MD_DEVICES MD_DEV_PV
 }
 
-wait_md_create() {
-	local md=$1
-
-	while :; do
-		if ! grep "$(basename $md)" /proc/mdstat; then
-			echo "$md not ready"
-			cat /proc/mdstat
-			sleep 2
-		else
-			break
-		fi
-	done
-	echo "$md" > WAIT_MD_DEV
-}
-
 wipefs_a() {
 	local dev=$1
 	shift


