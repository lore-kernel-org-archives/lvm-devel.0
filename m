From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 14 Jul 2017 07:54:55 -0400
Subject: master - tests: aux.sh integrate both teardown loops
Message-ID: <201707141154.v6EBstqD003950@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cd4e6c9b1780672f1a68f85123e0e9a1cc39ddca
Commit:        cd4e6c9b1780672f1a68f85123e0e9a1cc39ddca
Parent:        8a2448a4ed60deae8919e90edd6f4e94e450d19a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 14 13:22:15 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 14 13:22:15 2017 +0200

tests: aux.sh integrate both teardown loops

Use 1 logic for 2 loops tearing down left device.
First loops tries to remove all closed devices with 'normal' remove.
Second loop tries to replace those left devices with 'error' target.
---
 test/lib/aux.sh |   59 +++++++++++++++++++++++++++++-------------------------
 1 files changed, 32 insertions(+), 27 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index de2e2ac..a0e05ff 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -414,36 +414,41 @@ teardown_devs_prefixed() {
 	rm -f REMOVE_FAILED
 	#local listdevs=( $(dm_info name,open --sort open,name | grep "$prefix.*:0") )
 	#dmsetup remove --deferred ${listdevs[@]%%:0} || touch REMOVE_FAILED
-	for i in {1..100}; do
-		local need_udev_wait=0
-		local cnt
-		while IFS=' ' read -r dm cnt; do
-			test "$cnt" -eq 0 || break
-			dmsetup remove "$dm" &>/dev/null || touch REMOVE_FAILED &
-			need_udev_wait=1
-		done < <(dm_info name,open --separator ' ' --sort open,name | grep "$prefix")
-		test "$need_udev_wait" -eq 1 || break
-		udev_wait
-		test -f REMOVE_FAILED && break
-	done # looping till there are some removed devicess
 
-	wait
+	# 2nd. loop is trying --force removal which can possibly 'unstuck' some bloked operations
+	for i in 0 1; do
+		local num_remaining_devs=999999
+		local num_devs=0
+		test "$i" = 1 && test "$stray" = 0 && break  # no stray device removal
+
+		while :; do
+			local cnt
+			local sortby="name"
+			local need_udev_wait=0
 
-	if test -f REMOVE_FAILED; then
-		local num_devs
-		local num_remaining_devs=999
-		while num_devs=$(dm_table | grep -c "$prefix") && \
-		    test "$num_devs" -lt "$num_remaining_devs" -a "$num_devs" -ne 0; do
-			test "$stray" -eq 0 || echo "## removing $num_devs stray mapped devices with names beginning with $prefix: "
 			# HACK: sort also by minors - so we try to close 'possibly later' created device first
-			for dm in $(dm_info name --sort open,-minor | grep "$prefix") ; do
-				dmsetup remove -f "$dm" || true
-			done
+			test "$i" = 0 || sortby="-minor"
+
+			# when nothing left for removal, escape both loops...
+			dm_info name,open --separator ' ' --sort open,"$sortby" | grep "$prefix" > out || break 2
+			num_devs=$(wc -l < out)
+			test "$num_devs" -lt "$num_remaining_devs" || break  # not managed to reduce table size anymore
+			test "$i" = 0 || echo "## removing $num_devs stray mapped devices with names beginning with $prefix: "
+			while IFS=' ' read -r dm cnt; do
+				if test "$i" = 0; then
+					test "$cnt" -eq 0 || break  # stop loop with 1st. opened device
+					dmsetup remove "$dm" &>/dev/null || touch REMOVE_FAILED &
+				else
+					dmsetup remove -f "$dm" || true
+				fi
+				need_udev_wait=1
+			done < out
+			test "$need_udev_wait" -eq 1 || break
+			udev_wait
+			wait
 			num_remaining_devs=$num_devs
-		done
-	fi
-
-	udev_wait
+		done # looping till there are some removed devicess
+	done
 }
 
 teardown_devs() {
@@ -684,7 +689,7 @@ prepare_scsi_debug_dev() {
 	# last param wins.. so num_tgts=1 is imposed
 	touch SCSI_DEBUG_DEV
 	modprobe scsi_debug dev_size_mb="$DEV_SIZE" "${SCSI_DEBUG_PARAMS[@]}" num_tgts=1 || skip
-	
+
 	for i in {1..20} ; do
 		DEBUG_DEV="/dev/$(grep -H scsi_debug /sys/block/*/device/model | cut -f4 -d /)"
 		test -b "$DEBUG_DEV" && break


