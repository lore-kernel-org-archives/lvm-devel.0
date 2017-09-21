From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 21 Sep 2017 11:17:32 -0400
Subject: master - blkdeactivate: add blkdeactivate -r wait option to wait for MD resync/recovery/reshape
Message-ID: <201709211517.v8LFHWwU021450@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=95087c8f96c784cb91bda1433599abe75d917b80
Commit:        95087c8f96c784cb91bda1433599abe75d917b80
Parent:        7fa0d5226297a9ef57b8bce986e7a17ce948beb3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Sep 21 15:04:45 2017 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Sep 21 17:10:15 2017 +0200

blkdeactivate: add blkdeactivate -r wait option to wait for MD resync/recovery/reshape

The new blkdeactivate -r|mdraidoption wait causes blkdeactivate to wait
for any resync/recovery/reshape that is currently in progress before
deactivating the device.

If this option is used, blkdeactivate calls mdadm -W|--wait before
mdadm -S|--stop.
---
 WHATS_NEW_DM                |    1 +
 man/blkdeactivate.8_main    |    9 ++++++++
 scripts/blkdeactivate.sh.in |   49 ++++++++++++++++++++++++++++++++++++------
 3 files changed, 52 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 576e308..783a542 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.144 - 
 ======================================
+  Add blkdeactivate -r wait option to wait for MD resync/recovery/reshape.
   Fix blkdeactivate regression with failing DM/MD devs deactivation (1.02.142).
   Fix typo in blkdeactivate's '--{dm,lvm,mpath}options' option name.
   Correct return value testing when get reserved values for reporting.
diff --git a/man/blkdeactivate.8_main b/man/blkdeactivate.8_main
index 80235ca..0aa9c2a 100644
--- a/man/blkdeactivate.8_main
+++ b/man/blkdeactivate.8_main
@@ -8,6 +8,7 @@ blkdeactivate \(em utility to deactivate block devices
 .RB [ -h ]
 .RB [ -l \  \fIlvm_options\fP ]
 .RB [ -m \  \fImpath_options\fP ]
+.RB [ -r \  \fImdraid_options\fP ]
 .RB [ -u ]
 .RB [ -v ]
 .RI [ device ]
@@ -62,6 +63,14 @@ all the paths are unavailable for any underlying device-mapper multipath
 device.
 .RE
 .TP
+.BR -r ", " --mdraidoption \ \fImdraid_options\fP
+Comma-separated list of MD RAID specific options:
+.RS
+.IP \fIwait\fP
+Wait MD device's resync, recovery or reshape action to complete
+before deactivation.
+.RE
+.TP
 .BR -u ", " --umount
 Unmount a mounted device before trying to deactivate it.
 Without this option used, a device that is mounted is not deactivated.
diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index a7606b5..71cc241 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -71,6 +71,9 @@ LVM_DO_WHOLE_VG=0
 # Do not retry LV deactivation by default.
 LVM_CONFIG="activation{retry_deactivation=0}"
 
+# Do not wait for MD RAID device resync, recovery or reshape.
+MDRAID_DO_WAIT=0
+
 # Do not disable queueing if set on multipath devices.
 MPATHD_DO_DISABLEQUEUEING=0
 
@@ -113,13 +116,14 @@ usage() {
 	echo "      If devices are specified, deactivate only supplied devices and their holders."
 	echo
 	echo "  Options:"
-	echo "    -e | --errors                     Show errors reported from tools"
-	echo "    -h | --help                       Show this help message"
-	echo "    -d | --dmoptions    DM_OPTIONS    Comma separated DM specific options"
-	echo "    -l | --lvmoptions   LVM_OPTIONS   Comma separated LVM specific options"
-	echo "    -m | --mpathoptions MPATH_OPTIONS Comma separated DM-multipath specific options"
-	echo "    -u | --umount                     Unmount the device if mounted"
-	echo "    -v | --verbose                    Verbose mode (also implies -e)"
+	echo "    -e | --errors                       Show errors reported from tools"
+	echo "    -h | --help                         Show this help message"
+	echo "    -d | --dmoptions     DM_OPTIONS     Comma separated DM specific options"
+	echo "    -l | --lvmoptions    LVM_OPTIONS    Comma separated LVM specific options"
+	echo "    -m | --mpathoptions  MPATH_OPTIONS  Comma separated DM-multipath specific options"
+	echo "    -r | --mdraidoptions MDRAID_OPTIONS Comma separated MD RAID specific options"
+	echo "    -u | --umount                       Unmount the device if mounted"
+	echo "    -v | --verbose                      Verbose mode (also implies -e)"
 	echo
 	echo "  Device specific options:"
 	echo "    DM_OPTIONS:"
@@ -128,6 +132,8 @@ usage() {
 	echo "    LVM_OPTIONS:"
 	echo "      retry           retry removal several times in case of failure"
 	echo "      wholevg         deactivate the whole VG when processing an LV"
+	echo "    MDRAID_OPTIONS:"
+	echo "      wait            wait for resync, recovery or reshape to complete first"
 	echo "    MPATH_OPTIONS:"
 	echo "      disablequeueing disable queueing on all DM-multipath devices first"
 
@@ -275,6 +281,7 @@ deactivate_lvm () {
 
 deactivate_md () {
 	local name=$(printf "%s" "$name")
+	local sync_action
 	test -b "$DEV_DIR/$name" || return 0
 	test -z "${SKIP_DEVICE_LIST["$kname"]}" || return 1
 
@@ -287,6 +294,19 @@ deactivate_md () {
 	deactivate_holders "$DEV_DIR/$name" || return 1
 
 	echo -n "  [MD]: deactivating $devtype device $kname... "
+
+	test "$MDRAID_DO_WAIT" -eq 1 && {
+		sync_action="$(cat $SYS_BLK_DIR/$kname/md/sync_action)"
+		test "$sync_action" != "idle" && {
+			echo -n "$sync_action action in progress... "
+			if eval "$MDADM" $MDADM_OPTS -W "$DEV_DIR/$kname" "$OUT" "$ERR"; then
+				echo -n "complete... "
+			else
+				test $? -ne 1 && echo -n "failed to wait for $sync_action action... "
+			fi
+		}
+	}
+
 	if eval "$MDADM" $MDADM_OPTS -S "$name" "$OUT" "$ERR"; then
 		echo "done"
 	else
@@ -427,6 +447,20 @@ get_lvmopts() {
 	IFS=$ORIG_IFS
 }
 
+get_mdraidopts() {
+	ORIG_IFS=$IFS; IFS=','
+
+	for opt in $1; do
+		case "$opt" in
+			"") ;;
+			"wait") MDRAID_DO_WAIT=1 ;;
+			*) echo "$opt: unknown MD RAID option"
+		esac
+	done
+
+	IFS=$ORIG_IFS
+}
+
 get_mpathopts() {
 	ORIG_IFS=$IFS; IFS=','
 
@@ -489,6 +523,7 @@ while test $# -ne 0; do
 		"-d"|"--dmoptions") get_dmopts "$2" ; shift ;;
 		"-l"|"--lvmoptions") get_lvmopts "$2" ; shift ;;
 		"-m"|"--mpathoptions") get_mpathopts "$2" ; shift ;;
+		"-r"|"--mdraidoptions") get_mdraidopts "$2"; shift ;;
 		"-u"|"--umount") DO_UMOUNT=1 ;;
 		"-v"|"--verbose") VERBOSE=1 ; ERRORS=1 ;;
 		"-vv") VERBOSE=1 ; ERRORS=1 ; set -x ;;


