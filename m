From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 22 Mar 2021 21:53:51 +0000 (GMT)
Subject: main - tests: new aux mdadm_create
Message-ID: <20210322215351.C8BFA3858D29@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ada99f939fe24e23994244fdbe960014b355fd44
Commit:        ada99f939fe24e23994244fdbe960014b355fd44
Parent:        77432ee13742d09af5e8b1f8813d65bda3556a1d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 22 18:54:54 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 22 22:42:52 2021 +0100

tests: new aux mdadm_create

Add generic wrapper for mdadm --create which takes
normal 'mdadm' args - but allows us to handle differences of
mdadm usage across various version of mdadm tool.

Resulting MD device is availalble in  $(< MD_DEV).

Automatic cleaning is made through   cleanup_md_dev

Calling of mdadm_create cleans previous MD dev if it exists.
---
 test/lib/aux.sh | 91 ++++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 81 insertions(+), 10 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index ae173b8da..2bc3da2c9 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -776,8 +776,80 @@ prepare_md_dev() {
 	printf "%s\n" "${@:4}" > MD_DEVICES
 }
 
+mdadm_create() {
+	local mddev
+	local maj=
+	local mdname="md_lvm_test0"
+	local mddir="md/"
+	local mddevdir="$DM_DEV_DIR/$mddir"
+
+	maj=$(mdadm --version 2>&1) || skip "mdadm tool is missing!"
+
+	cleanup_md_dev
+	rm -f debug.log strace.log
+
+	# Have MD use a non-standard name to avoid colliding with an existing MD device
+	# - mdadm >= 3.0 requires that non-standard device names be in /dev/md/
+	# - newer mdadm _completely_ defers to udev to create the associated device node
+	maj=${maj##*- v}
+	maj=${maj%%.*}
+	[ "$maj" -ge 3 ] || mddir=""
+
+	mddev="/dev/${mddir}$mdname"
+	name=$1
+
+	mdadm --create "$mddev" "$@" || {
+		# Some older 'mdadm' version managed to open and close devices internaly
+		# and reporting non-exclusive access on such device
+		# let's just skip the test if this happens.
+		# Note: It's pretty complex to get rid of consequences
+		#       the following sequence avoid leaks on f19
+		# TODO: maybe try here to recreate few times....
+		mdadm --stop "$mddev" || true
+		udev_wait
+		while  [ "$#" -ne 0 ] ; do
+			case "$1" in
+			*"$PREFIX"*) mdadm --zero-superblock "$1" || true ;;
+			esac
+			shift
+		done
+		udev_wait
+		skip "Test skipped, unreliable mdadm detected!"
+	}
+
+	for i in {10..0} ; do
+		test -e "$mddev" && break
+		echo "Waiting for $mddev."
+		sleep .5
+	done
+
+	# LVM/DM will see this device
+	case "$DM_DEV_DIR" in
+	"/dev") readlink -f "$mddev" > MD_DEV_PV ;;
+	*)	mkdir -p "$mddevdir"
+		rm -f "$mddevdir/$mdname"
+		cp -LR "$mddev" "$mddevdir"
+		echo "${mddevdir}${mdname}" > MD_DEV_PV ;;
+	esac
+
+	mddev=$(readlink -f "$mddev")
+	test -b "$mddev" || skip "mdadm has not created device!"
+	echo "$mddev" > MD_DEV
+	rm -f MD_DEVICES
+	while  [ "$#" -ne 0 ] ; do
+		case "$1" in
+		*"$PREFIX"*) echo "$1" >> MD_DEVICES ;;
+		esac
+		shift
+	done
+}
+
 cleanup_md_dev() {
 	test -f MD_DEV || return 0
+	grep -q "$(basename $(< MD_DEV) )" /proc/mdstat || {
+		rm -f MD_DEV
+		return 0
+	}
 
 	local IFS=$IFS_NL
 	local dev
@@ -785,21 +857,20 @@ cleanup_md_dev() {
 	local mddev_pv
 	mddev=$(< MD_DEV)
 	mddev_pv=$(< MD_DEV_PV)
-	udev_wait
-	mdadm --stop "$mddev" || true
-	udev_wait  # wait till events are process, not zeroing to early
+
+	for i in {10..0} ; do
+		udev_wait
+		mdadm --stop "$mddev" || true
+		udev_wait  # wait till events are process, not zeroing to early
+		grep -q "$(basename $(< MD_DEV) )" /proc/mdstat || break
+		sleep .1
+		echo "$mddev is still present, stopping again"
+	done
 	test "$DM_DEV_DIR" != "/dev" && rm -rf "${mddev_pv%/*}"
 	for dev in $(< MD_DEVICES); do
 		mdadm --zero-superblock "$dev" || true
 	done
 	udev_wait
-	if [ -b "$mddev" ]; then
-		# mdadm doesn't always cleanup the device node
-		# sleeps offer hack to defeat: 'md: md127 still in use'
-		# see: https://bugzilla.redhat.com/show_bug.cgi?id=509908#c25
-		sleep 2
-		rm -f "$mddev"
-	fi
 	rm -f MD_DEV MD_DEVICES MD_DEV_PV
 }
 


