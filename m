From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 21 Feb 2017 00:01:18 +0000 (UTC)
Subject: master - tests: paralelize creation and teardown
Message-ID: <20170221000118.E1DC660C56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d409fec079d27c349b4e570a619bd860ce4fde7e
Commit:        d409fec079d27c349b4e570a619bd860ce4fde7e
Parent:        921d5972e8bfa778f7389c4abdaa8691ce432c70
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 21 00:49:49 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 21 00:52:05 2017 +0100

tests: paralelize creation and teardown

To speedup initial construction and destruction of test devices
(mainly in case more then 1 is needed)  call dmsetup
in parallel.
---
 test/lib/aux.sh |   39 +++++++++++++++++++++++----------------
 1 files changed, 23 insertions(+), 16 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 7c3daa5..10f6f92 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -405,23 +405,25 @@ teardown_devs_prefixed() {
 	fi
 
 	# Remove devices, start with closed (sorted by open count)
-	local remfail=no
+	# Run 'dmsetup remove' in parallel
+	rm -f REMOVE_FAILED
 	local need_udev_wait=0
 	init_udev_transaction
-	for dm in $(dm_info name --sort open | grep "$prefix"); do
-		dmsetup remove "$dm" &>/dev/null || remfail=yes
+	for dm in $(dm_info name --sort open,name | grep "$prefix"); do
+		dmsetup remove "$dm" &>/dev/null || touch REMOVE_FAILED &
 		need_udev_wait=1
 	done
+	wait
 	finish_udev_transaction
 	test $need_udev_wait -eq 0 || udev_wait
 
-	if test $remfail = yes; then
+	if test -f REMOVE_FAILED; then
 		local num_devs
 		local num_remaining_devs=999
 		while num_devs=$(dm_table | grep "$prefix" | wc -l) && \
 		    test $num_devs -lt $num_remaining_devs -a $num_devs -ne 0; do
 			test "$stray" -eq 0 || echo "Removing $num_devs stray mapped devices with names beginning with $prefix: "
-                        # HACK: sort also by minors - so we try to close 'possibly later' created device first
+			# HACK: sort also by minors - so we try to close 'possibly later' created device first
 			for dm in $(dm_info name --sort open,-minor | grep "$prefix") ; do
 				dmsetup remove -f "$dm" || true
 			done
@@ -794,6 +796,7 @@ prepare_devs() {
 
 	local size=$(($devsize*2048)) # sectors
 	local count=0
+	rm -f CREATE_FAILED
 	init_udev_transaction
 	for i in $(seq 1 $n); do
 		local name="${PREFIX}$pvname$i"
@@ -801,17 +804,19 @@ prepare_devs() {
 		DEVICES[$count]=$dev
 		count=$(( $count + 1 ))
 		echo 0 $size linear "$BACKING_DEV" $((($i-1)*$size + $shift)) > "$name.table"
-		if not dmsetup create -u "TEST-$name" "$name" "$name.table" &&
-		   test -n "$LVM_TEST_BACKING_DEVICE";
-		then # maybe the backing device is too small for this test
-		    LVM_TEST_BACKING_DEVICE=
-		    rm -f BACKING_DEV
-		    prepare_devs "$@"
-		    return $?
-		fi
+		dmsetup create -u "TEST-$name" "$name" "$name.table" || touch CREATE_FAILED &
+		test -f CREATE_FAILED && break;
 	done
+	wait
 	finish_udev_transaction
 
+	if test -f CREATE_FAILED -a -n "$LVM_TEST_BACKING_DEVICE"; then
+		LVM_TEST_BACKING_DEVICE=
+		rm -f BACKING_DEV CREATE_FAILED
+		prepare_devs "$@"
+		return $?
+	fi
+
 	# non-ephemeral devices need to be cleared between tests
 	test -f LOOP || for d in ${DEVICES[@]}; do
 		blkdiscard "$d" 2>/dev/null || true
@@ -833,9 +838,11 @@ prepare_devs() {
 #	( IFS=$'\n'; echo "${DEVICES[*]}" ) >DEVICES
 	echo "ok"
 
-	for dev in "${DEVICES[@]}"; do
-		notify_lvmetad "$dev"
-	done
+	if test -e LOCAL_LVMETAD; then
+		for dev in "${DEVICES[@]}"; do
+			notify_lvmetad "$dev"
+		done
+	fi
 }
 
 


