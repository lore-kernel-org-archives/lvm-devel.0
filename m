From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2023 18:25:01 +0000 (GMT)
Subject: main - vdo: lvm_import_vdo correct parsing output
Message-ID: <20230629182501.7C86D3858412@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8b75bbe47d2a2961b0fb029ad7a01dc37ee6a8e5
Commit:        8b75bbe47d2a2961b0fb029ad7a01dc37ee6a8e5
Parent:        e48c9826e3069b06a5aa31e1e59200dce4915983
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 13:06:18 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 13:10:42 2023 +0200

vdo: lvm_import_vdo correct parsing output

Output from vdo manager may actually indent output with spaces,
so trim leading and ending space.

Also add support for verbosity flag for vdo conversion tool.
---
 scripts/lvm_import_vdo.sh | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/scripts/lvm_import_vdo.sh b/scripts/lvm_import_vdo.sh
index 307233429..319bcb33d 100755
--- a/scripts/lvm_import_vdo.sh
+++ b/scripts/lvm_import_vdo.sh
@@ -370,7 +370,7 @@ convert_non_lv_() {
 	fi
 
 	verbose "Moving VDO header."
-	output=$(dry "$VDO" convert $VDOCONF --force --name "$VDONAME")
+	output=$(dry "$VDO" convert $VDOCONF $VERB --force --name "$VDONAME")
 
 	if [ "$ABORT_AFTER_VDO_CONVERT" != "0" ] ; then
 		verbose "Aborting VDO coversion after moving VDO, volume is useless!"
@@ -384,7 +384,8 @@ convert_non_lv_() {
 	local vdo_offset=0
 	local vdo_non_converted=0
 	while IFS=  read -r line ; do
-		case "$line" in
+		# trim leading spaces
+		case "$(echo $line)" in
 		"Non converted"*) vdo_non_converted=1 ;;
 		"Length"*) vdo_length=${line##* = } ;;
 		"Conversion completed"*)
@@ -579,7 +580,7 @@ EOF
 	verbose "VDO conversion parameters: $VDO_ALLOCATION_PARAMS"
 
 	verbose "Stopping VDO volume."
-	dry "$VDO" stop $VDOCONF --name "$VDONAME"
+	dry "$VDO" stop $VDOCONF --name "$VDONAME" $VERB
 
 	# If user has not provided '--yes', prompt before conversion
 	if [ -z "$YES" ] && [ "$USE_VDO_DM_SNAPSHOT" != "1" ]; then

