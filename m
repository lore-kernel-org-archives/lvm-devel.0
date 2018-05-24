From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 24 May 2018 05:34:56 -0400
Subject: master - tests: aux improve for mdadm support
Message-ID: <201805240934.w4O9YuYH002271@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=76a45424a7b4d2e903bcb41b45b4f8cf131183ce
Commit:        76a45424a7b4d2e903bcb41b45b4f8cf131183ce
Parent:        c46dbfb14e00beaa143871dbcefc23612a63f4e0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 24 11:03:47 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 24 11:03:47 2018 +0200

tests: aux improve for mdadm support

Correcting some symlink handling.
---
 test/lib/aux.sh |   28 ++++++++++++++++++----------
 1 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index f6206ce..bf766f2 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -755,11 +755,14 @@ prepare_md_dev() {
 	local coption="--chunk"
 	local maj
 	local mddev
+	local mddir="md/"
+	local mdname
+	local mddevdir
 	maj=$(mdadm --version 2>&1) || skip "mdadm tool is missing!"
 
 	cleanup_md_dev
 
-	rm -f debug.log strace.log MD_DEV MD_DEV_PV MD_DEVICES
+	rm -f debug.log strace.log
 
 	case "$level" in
 	"1")  coption="--bitmap-chunk" ;;
@@ -770,9 +773,11 @@ prepare_md_dev() {
 	# - newer mdadm _completely_ defers to udev to create the associated device node
 	maj=${maj##*- v}
 	maj=${maj%%.*}
-	[ "$maj" -ge 3 ] && \
-		mddev=/dev/md/md_lvm_test0 || \
-		mddev=/dev/md_lvm_test0
+	[ "$maj" -ge 3 ] || mddir=""
+
+	mdname="md_lvm_test0"
+	mddev="/dev/${mddir}$mdname"
+	mddevdir="$DM_DEV_DIR/$mddir"
 
 	mdadm --create --metadata=1.0 "$mddev" --auto=md --level "$level" $with_bitmap "$coption"="$rchunk" --raid-devices="$rdevs" "${@:4}" || {
 		# Some older 'mdadm' version managed to open and close devices internaly
@@ -791,10 +796,11 @@ prepare_md_dev() {
 
 	# LVM/DM will see this device
 	case "$DM_DEV_DIR" in
-	"/dev") readlink -f "$mddev" ;;
-	*)	cp -LR "$mddev" "$DM_DEV_DIR"
-		echo "$DM_DEV_DIR/md_lvm_test0" ;;
-	esac > MD_DEV_PV
+	"/dev") readlink -f "$mddev" > MD_DEV_PV ;;
+	*)	mkdir -p "$mddevdir"
+		cp -LR "$mddev" "$mddevdir"
+		echo "${mddevdir}${mdname}" > MD_DEV_PV ;;
+	esac
 	echo "$mddev" > MD_DEV
 	notify_lvmetad "$(< MD_DEV_PV)"
 	printf "%s\n" "${@:4}" > MD_DEVICES
@@ -809,12 +815,14 @@ cleanup_md_dev() {
 	local IFS=$IFS_NL
 	local dev
 	local mddev
+	local mddev_pv
 	mddev=$(< MD_DEV)
+	mddev_pv=$(< MD_DEV_PV)
 	udev_wait
 	mdadm --stop "$mddev" || true
-	test "$DM_DEV_DIR" != "/dev" && rm -f "$DM_DEV_DIR/$(basename "$mddev")"
-	notify_lvmetad "$(< MD_DEV_PV)"
+	notify_lvmetad "$mddev_pv"
 	udev_wait  # wait till events are process, not zeroing to early
+	test "$DM_DEV_DIR" != "/dev" && rm -rf "${mddev_pv%/*}"
 	for dev in $(< MD_DEVICES); do
 		mdadm --zero-superblock "$dev" || true
 		notify_lvmetad "$dev"


