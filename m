From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 18 Mar 2021 18:15:08 +0000 (GMT)
Subject: main - tests: aux always shift emulated devices by 1MiB
Message-ID: <20210318181508.5C14D3848011@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1880b573f3b69deb561251dea003b5be7ff59ab3
Commit:        1880b573f3b69deb561251dea003b5be7ff59ab3
Parent:        8e7690b7980ad3bc6e7c38d6e2028f885751c355
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 18 13:32:48 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 18 18:57:45 2021 +0100

tests: aux always shift emulated devices by 1MiB

Always shift created virtual PVs on backing device by 1MiB
and leave 1MiB free space at the end of device.

This way the system doesn't see same PV headers at multiple devices.
---
 test/lib/aux.sh | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 53975301a..8c727e8c6 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -696,7 +696,7 @@ prepare_scsi_debug_dev() {
 	# NOTE: it will _never_ make sense to pass num_tgts param;
 	# last param wins.. so num_tgts=1 is imposed
 	touch SCSI_DEBUG_DEV
-	modprobe scsi_debug dev_size_mb="$DEV_SIZE" "$@" num_tgts=1 || skip
+	modprobe scsi_debug dev_size_mb="$(( DEV_SIZE + 2 ))" "$@" num_tgts=1 || skip
 
 	for i in {1..20} ; do
 		sleep .1 # allow for async Linux SCSI device registration
@@ -874,7 +874,7 @@ prepare_devs() {
 	local n=${1:-3}
 	local devsize=${2:-34}
 	local pvname=${3:-pv}
-	local shift=0
+	local header_shift=1 # shift header from begin & end of device by 1MiB
 
 	# sanlock requires more space for the internal sanlock lv
 	# This could probably be lower, but what are the units?
@@ -883,9 +883,7 @@ prepare_devs() {
 	fi
 
 	touch DEVICES
-	prepare_backing_dev $(( n * devsize ))
-	# shift start of PV devices on /dev/loopXX by 1M
-	not diff LOOP BACKING_DEV >/dev/null 2>&1 || shift=2048
+	prepare_backing_dev $(( n * devsize + 2 * header_shift ))
 	blkdiscard "$BACKING_DEV" 2>/dev/null || true
 	echo -n "## preparing $n devices..."
 
@@ -898,7 +896,7 @@ prepare_devs() {
 		local dev="$DM_DEV_DIR/mapper/$name"
 		DEVICES[$count]=$dev
 		count=$((  count + 1 ))
-		echo 0 $size linear "$BACKING_DEV" $(( ( i - 1 ) * size + shift )) > "$name.table"
+		echo 0 $size linear "$BACKING_DEV" $(( ( i - 1 ) * size + ( header_shift * 2048 ) )) > "$name.table"
 		dmsetup create -u "TEST-$name" "$name" "$name.table" || touch CREATE_FAILED &
 		test -f CREATE_FAILED && break;
 	done


