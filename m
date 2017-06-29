From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:28:12 -0400
Subject: master - tests: aux.sh array assing
Message-ID: <201706292028.v5TKSCiL026743@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ec02307e952ef29d4a28fe134c807ac79a61908a
Commit:        ec02307e952ef29d4a28fe134c807ac79a61908a
Parent:        8a912d6dbcc34ce2b76a0104c39de7aa0480c512
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 20:45:46 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:17 2017 +0200

tests: aux.sh array assing

Assigning an array to a string! Assign as array, or use * instead of @ to concatenate.
---
 test/lib/aux.sh |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index e82d698..5e7340e 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -595,7 +595,7 @@ teardown() {
 
 prepare_loop() {
 	local size=${1=32}
-	local losetup_params=${@:2}
+	local losetup_params=( ${@:2} )
 	local i
 	local slash
 
@@ -620,9 +620,9 @@ prepare_loop() {
 	local LOOPFILE="$PWD/test.img"
 	rm -f "$LOOPFILE"
 	dd if=/dev/zero of="$LOOPFILE" bs=$((1024*1024)) count=0 seek=$(( size + 1 )) 2> /dev/null
-	if LOOP=$(losetup ${losetup_params} -s -f "$LOOPFILE" 2>/dev/null); then
+	if LOOP=$(losetup "${losetup_params[@]}" -s -f "$LOOPFILE" 2>/dev/null); then
 		:
-	elif LOOP=$(losetup -f) && losetup ${losetup_params} "$LOOP" "$LOOPFILE"; then
+	elif LOOP=$(losetup -f) && losetup "${losetup_params[@]}" "$LOOP" "$LOOPFILE"; then
 		# no -s support
 		:
 	else
@@ -633,7 +633,7 @@ prepare_loop() {
 				local dev="$DM_DEV_DIR/loop$slash$i"
 				! losetup "$dev" >/dev/null 2>&1 || continue
 				# got a free
-				losetup ${losetup_params} "$dev" "$LOOPFILE"
+				losetup "${losetup_params[@]}" "$dev" "$LOOPFILE"
 				LOOP=$dev
 				break
 			done
@@ -652,7 +652,7 @@ prepare_loop() {
 # - scripts must take care not to use a DEV_SIZE that will enduce OOM-killer
 prepare_scsi_debug_dev() {
 	local DEV_SIZE=$1
-	local SCSI_DEBUG_PARAMS=${@:2}
+	local SCSI_DEBUG_PARAMS=( ${@:2} )
 	local DEBUG_DEV
 
 	rm -f debug.log strace.log
@@ -668,7 +668,7 @@ prepare_scsi_debug_dev() {
 	# NOTE: it will _never_ make sense to pass num_tgts param;
 	# last param wins.. so num_tgts=1 is imposed
 	touch SCSI_DEBUG_DEV
-	modprobe scsi_debug dev_size_mb="$DEV_SIZE" $SCSI_DEBUG_PARAMS num_tgts=1 || skip
+	modprobe scsi_debug dev_size_mb="$DEV_SIZE" "${SCSI_DEBUG_PARAMS[@]}" num_tgts=1 || skip
 	
 	for i in {1..20} ; do
 		DEBUG_DEV="/dev/$(grep -H scsi_debug /sys/block/*/device/model | cut -f4 -d /)"
@@ -861,14 +861,14 @@ common_dev_() {
 	delay)
 		read_ms=${3:-0}
 		write_ms=${4:-0}
-		offsets=${@:5}
+		offsets=( ${@:5} )
 		if test "$read_ms" -eq 0 -a "$write_ms" -eq 0 ; then
-			offsets=
+			offsets=( )
 		else
-			test -z "${offsets[@]}" && offsets="0:"
+			test -z "${offsets[@]}" && offsets=( "0:" )
 		fi ;;
-	error|zero)  offsets=${@:3}
-		test -z "${offsets[@]}" && offsets="0:" ;;
+	error|zero)  offsets=( ${@:3} )
+		test -z "${offsets[@]}" && offsets=( "0:" ) ;;
 	esac
 
 	local pos


