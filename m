From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 Mar 2021 00:23:38 +0000 (GMT)
Subject: main - tests: enhance mdadm_create
Message-ID: <20210323002338.C73DF3858004@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=370749a4b859dae834ca5ce514a701a3c3abc75b
Commit:        370749a4b859dae834ca5ce514a701a3c3abc75b
Parent:        7575c7ae5c012c4a20bd4c2563640880f522789c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 23 01:16:21 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 23 01:16:21 2021 +0100

tests: enhance mdadm_create

For older mdadm its hard to support new names - to simplify things
keep using  /dev/mdXXX name which is automatically selected.
---
 test/lib/aux.sh | 67 ++++++++++++++++++++++++++-------------------------------
 1 file changed, 31 insertions(+), 36 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index e26aa9912..a982ca162 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -710,26 +710,22 @@ cleanup_scsi_debug_dev() {
 }
 
 mdadm_create() {
+	local devid
 	local mddev
-	local maj=
-	local mdname="md_lvm_test0"
-	local mddir="md/"
-	local mddevdir="$DM_DEV_DIR/$mddir"
 
-	maj=$(mdadm --version 2>&1) || skip "mdadm tool is missing!"
+	which mdadm >/dev/null || skip "mdadm tool is missing!"
 
 	cleanup_md_dev
 	rm -f debug.log strace.log
 
-	# Have MD use a non-standard name to avoid colliding with an existing MD device
-	# - mdadm >= 3.0 requires that non-standard device names be in /dev/md/
-	# - newer mdadm _completely_ defers to udev to create the associated device node
-	maj=${maj##*- v}
-	maj=${maj%%.*}
-	[ "$maj" -ge 3 ] || mddir=""
-
-	mddev="/dev/${mddir}$mdname"
-	name=$1
+	# try to find free MD node
+	# using the old naming /dev/mdXXX
+        # if we need more MD arrays test suite more likely leaked them
+	for devid in {127..150} ; do
+		test -b /dev/md${devid} || break
+	done
+	test "$devid" -lt "150" || skip "Cannot find free /dev/mdXXX node!"
+	mddev=/dev/md${devid}
 
 	mdadm --create "$mddev" "$@" || {
 		# Some older 'mdadm' version managed to open and close devices internaly
@@ -756,18 +752,17 @@ mdadm_create() {
 		sleep .5
 	done
 
+	test -b "$mddev" || skip "mdadm has not created device!"
+	echo "$mddev" > MD_DEV
+
 	# LVM/DM will see this device
 	case "$DM_DEV_DIR" in
-	"/dev") readlink -f "$mddev" > MD_DEV_PV ;;
-	*)	mkdir -p "$mddevdir"
-		rm -f "$mddevdir/$mdname"
-		cp -LR "$mddev" "$mddevdir"
-		echo "${mddevdir}${mdname}" > MD_DEV_PV ;;
+	"/dev") echo "$mddev" > MD_DEV_PV ;;
+	*)	rm -f "$DM_DEV_DIR/md${devid}"
+		cp -LR "$mddev" "$DM_DEV_DIR"
+		echo "${DM_DEV_DIR}/md${devid}" > MD_DEV_PV ;;
 	esac
 
-	mddev=$(readlink -f "$mddev")
-	test -b "$mddev" || skip "mdadm has not created device!"
-	echo "$mddev" > MD_DEV
 	rm -f MD_DEVICES
 	while  [ "$#" -ne 0 ] ; do
 		case "$1" in
@@ -778,28 +773,28 @@ mdadm_create() {
 }
 
 cleanup_md_dev() {
-	test -f MD_DEV || return 0
-	grep -q "$(basename $(< MD_DEV) )" /proc/mdstat || {
-		rm -f MD_DEV
-		return 0
-	}
-
 	local IFS=$IFS_NL
+	local i
 	local dev
+	local base
 	local mddev
-	local mddev_pv
+
+	test -f MD_DEV || return 0
 	mddev=$(< MD_DEV)
-	mddev_pv=$(< MD_DEV_PV)
+	base=$(basename "$mddev")
 
-	for i in {10..0} ; do
-		udev_wait
+	for i in {0..10} ; do
+		grep -q "$base" /proc/mdstat || break
+		test "$i" = 0 || {
+			sleep .1
+			echo "$mddev is still present, stopping again"
+		}
 		mdadm --stop "$mddev" || true
 		udev_wait  # wait till events are process, not zeroing to early
-		grep -q "$(basename $(< MD_DEV) )" /proc/mdstat || break
-		sleep .1
-		echo "$mddev is still present, stopping again"
 	done
-	test "$DM_DEV_DIR" != "/dev" && rm -rf "${mddev_pv%/*}"
+
+	test "$DM_DEV_DIR" != "/dev" && rm -f "$(< MD_DEV_PV)"
+
 	for dev in $(< MD_DEVICES); do
 		mdadm --zero-superblock "$dev" || true
 	done


