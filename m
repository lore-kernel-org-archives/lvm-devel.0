From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2023 18:25:02 +0000 (GMT)
Subject: main - lvm_import_vdo: spelling fixes
Message-ID: <20230629182502.9DA313858426@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8a07f57ba478c16ca5d5eacf778ee2708109aa65
Commit:        8a07f57ba478c16ca5d5eacf778ee2708109aa65
Parent:        8b75bbe47d2a2961b0fb029ad7a01dc37ee6a8e5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 13:05:55 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 13:10:42 2023 +0200

lvm_import_vdo: spelling fixes

---
 scripts/lvm_import_vdo.sh | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/scripts/lvm_import_vdo.sh b/scripts/lvm_import_vdo.sh
index 319bcb33d..b5e1a9e16 100755
--- a/scripts/lvm_import_vdo.sh
+++ b/scripts/lvm_import_vdo.sh
@@ -52,7 +52,7 @@ DM_DEV_DIR="${DM_DEV_DIR:-/dev}"
 DM_UUID_PREFIX="${DM_UUID_PREFIX:-}"
 DM_VG_NAME=
 DM_LV_NAME=
-VDO_CONFIG=${VDO_CONFIG:-}   # can be overriden with --vdo-config
+VDO_CONFIG=${VDO_CONFIG:-}   # can be overridden with --vdo-config
 VDOCONF=
 test -n "$VDO_CONFIG" && VDOCONF="-f $VDO_CONFIG"
 
@@ -150,7 +150,7 @@ snapshot_create_() {
 
 snapshot_merge_() {
 	local status
-	local inital_status
+	local initial_status
 
 	initial_status=( $("$DMSETUP" status "$VDO_DM_SNAPSHOT_NAME") )
 	"$DMSETUP" reload "$VDO_DM_SNAPSHOT_NAME" --table "$(snapshot_target_line_ "$1" "$VDO_SNAPSHOT_LOOP" -merge)"
@@ -165,7 +165,7 @@ snapshot_merge_() {
 	#du -h "$TEMPDIR/$VDO_DM_SNAPSHOT_NAME"
 
 	# Loop for a while, till the snapshot is merged.
-	# Should be nearly instantenious.
+	# Should be nearly instantaneous.
         # FIXME: Recovery when something prevents merging is hard
 	for i in $(seq 1 20) ; do
 		status=( $("$DMSETUP" status "$VDO_DM_SNAPSHOT_NAME") )
@@ -231,7 +231,7 @@ get_largest_extent_size_() {
 }
 
 # detect LV on the given device
-# dereference device name if it is symbolic link
+# deference device name if it is symbolic link
 detect_lv_() {
 	local DEVICE=$1
 	local SYSVOLUME
@@ -315,7 +315,7 @@ parse_yaml_() {
 # Currently this enforces a user to reduce the VG extent size to the smaller size (up to 4KiB).
 #
 # TODO: We may eventually relax this condition just like we are doing rounding for convert_non_lv_()
-#       Let's if there would be any singly user requiring this feauture.
+#       Let's if there would be any singly user requiring this feature.
 #       It may allow to better use larger VDO volume size (in TiB ranges).
 #
 convert_lv_() {
@@ -351,7 +351,7 @@ convert_lv_() {
 # Convert VDO volume on a device to VG with VDOPool LV
 #
 # Convert device with the use of snapshot on top of original VDO volume (can be optionally disabled)
-# Once the whole conversion is finished, snapshot is merged (During the short periof time of merging
+# Once the whole conversion is finished, snapshot is merged (During the short period time of merging
 # user must ensure there will be no power-off!)
 #
 # For best use the latest version of  vdoprepareforlvm tool is required.
@@ -373,12 +373,12 @@ convert_non_lv_() {
 	output=$(dry "$VDO" convert $VDOCONF $VERB --force --name "$VDONAME")
 
 	if [ "$ABORT_AFTER_VDO_CONVERT" != "0" ] ; then
-		verbose "Aborting VDO coversion after moving VDO, volume is useless!"
+		verbose "Aborting VDO conversion after moving VDO header, volume is useless!"
 		cleanup 0
 	fi
 
 	# Parse result from VDO preparation/conversion tool
-	# New version of the tool provides output with alingment and offset
+	# New version of the tool provides output with alignment and offset
 	local vdo_length=0
 	local vdo_aligned=0
 	local vdo_offset=0
@@ -432,7 +432,7 @@ convert_non_lv_() {
 	verbose "Converting to VDO pool."
 	dry "$LVM" lvconvert $YES $VERB $FORCE --devices "$devices" --config "$VDO_ALLOCATION_PARAMS" -Zn -V "${vdo_logicalSizeRounded}k" -n "$LVNAME" --type vdo-pool "$VGNAME/${LVNAME}_vpool"
 	if [ "$vdo_logicalSizeRounded" -lt "$vdo_logicalSize" ] ; then
-		# need to extend virtal size to be covering all the converted area
+		# need to extend virtual size to be covering all the converted area
 		# let lvm2 to round to the proper virtual size of VDO LV
 		dry "$LVM" lvextend $YES $VERB --fs ignore --devices "$devices" -L "$vdo_logicalSize"k "$VGNAME/$LVNAME"
 	fi
@@ -512,7 +512,7 @@ convert2lvm_() {
 
 	"$MKDIR" -p -m 0000 "$TEMPDIR" || error "Failed to create $TEMPDIR."
 
-	# TODO: might use directly  /etc/vdoconf.yml (avoding need of 'vdo' manager)
+	# TODO: might use directly  /etc/vdoconf.yml (avoiding need of 'vdo' manager)
 	verbose "Getting YAML VDO configuration."
 	"$VDO" printConfigFile $VDOCONF >"$TEMPDIR/vdoconf.yml"
 	test -s "$TEMPDIR/vdoconf.yml" || error "Cannot work without VDO configuration"

