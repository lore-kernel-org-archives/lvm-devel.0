From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jun 2023 16:09:39 +0000 (GMT)
Subject: main - lvm_import_vdo: correct the converted virtual size
Message-ID: <20230623160939.10D783857728@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=657dde6208ddc8172b7d0e1466751046c8ddaeaa
Commit:        657dde6208ddc8172b7d0e1466751046c8ddaeaa
Parent:        ea6b5b694bf0886052b048b2e04b941ec65d90f9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 23 18:01:32 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 23 18:05:03 2023 +0200

lvm_import_vdo: correct the converted virtual size

Ensure the volume after conversion has the properly aligned size to the
volume group extent size. This would be visible when using virtual size,
that cannot be divided by extent size.

Before the user had to manually adjust the size after conversion to get
access to all data stored on VDO volume.
---
 scripts/lvm_import_vdo.sh | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/scripts/lvm_import_vdo.sh b/scripts/lvm_import_vdo.sh
index bae4b52d1..13197c6fb 100755
--- a/scripts/lvm_import_vdo.sh
+++ b/scripts/lvm_import_vdo.sh
@@ -357,6 +357,7 @@ convert_lv_() {
 # For best use the latest version of  vdoprepareforlvm tool is required.
 convert_non_lv_() {
 	local vdo_logicalSize=$1
+	local vdo_logicalSizeRounded
 	local extent_size
 	local output
 	local pvfree
@@ -417,7 +418,7 @@ convert_non_lv_() {
 	# Round virtual size to the LOWER size expressed in extent units.
 	# lvm is parsing VDO metadata and can read real full size and use it instead of this smaller value.
 	# To precisely byte-synchronize the size of VDO LV, user can lvresize such VDO LV later.
-	vdo_logicalSize=$(( ( vdo_logicalSize / extent_size ) * extent_size ))
+	vdo_logicalSizeRounded=$(( ( vdo_logicalSize / extent_size ) * extent_size ))
 
 	verbose "Creating VG \"${NAME%/*}\" with extent size $extent_size KiB."
 	dry "$LVM" vgcreate $YES $VERB --devices "$devices" -s "${extent_size}k" "$VGNAME" "$devices" || {
@@ -428,7 +429,12 @@ convert_non_lv_() {
 	dry "$LVM" lvcreate -Zn -Wn -an $YES $VERB --devices "$devices" -l100%VG -n "${LVNAME}_vpool" "$VGNAME" "$devices"
 
 	verbose "Converting to VDO pool."
-	dry "$LVM" lvconvert $YES $VERB $FORCE --devices "$devices" --config "$VDO_ALLOCATION_PARAMS" -Zn -V "${vdo_logicalSize}k" -n "$LVNAME" --type vdo-pool "$VGNAME/${LVNAME}_vpool"
+	dry "$LVM" lvconvert $YES $VERB $FORCE --devices "$devices" --config "$VDO_ALLOCATION_PARAMS" -Zn -V "${vdo_logicalSizeRounded}k" -n "$LVNAME" --type vdo-pool "$VGNAME/${LVNAME}_vpool"
+	if [ "$vdo_logicalSizeRounded" -lt "$vdo_logicalSize" ] ; then
+		# need to extend virtal size to be covering all the converted area
+		# let lvm2 to round to the proper virtual size of VDO LV
+		dry "$LVM" lvextend $YES $VERB --fs ignore --devices "$devices" -L "$vdo_logicalSize"k "$VGNAME/$LVNAME"
+	fi
 
 	dry "$LVM" vgchange -an $VERB $FORCE --devices "$devices" "$VGNAME"
 

