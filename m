From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 13 Mar 2018 08:04:30 -0400
Subject: master - tests: try unfreezeing raids
Message-ID: <201803131204.w2DC4UIl002499@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=90512910e5ecf1a4b1538d9d9165cb0f44e2c291
Commit:        90512910e5ecf1a4b1538d9d9165cb0f44e2c291
Parent:        b1ace8ce195046bddbbcdba08d87b7e9a741cdbc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 8 17:32:47 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 13 12:58:57 2018 +0100

tests: try unfreezeing raids

With problematic kernels raid devices can be occasionaly left with
'frozen' status - try to 'unfreeze' them with idle message on teardown.

Also replace couple greps with 'built-in' dmsetup --select feature.

Note: dmsetup --select  currently reports 'No devices found' on stdout
and return success - looks like a bug to fix.
---
 test/lib/aux.sh   |   55 +++++++++++++++++++++++++++++++---------------------
 test/lib/utils.sh |    4 +++
 2 files changed, 37 insertions(+), 22 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index fbba84b..9f8c8d7 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -396,15 +396,23 @@ teardown_devs_prefixed() {
 	local prefix=$1
 	local stray=${2:-0}
 	local IFS=$IFS_NL
+	local once=1
 	local dm
 
 	rm -rf "$TESTDIR/dev/$prefix*"
 
+	# Send idle message to frozen raids (with hope to unfreeze them)
+	for dm in $(dm_status | egrep "$prefix.*raid.*frozen"); do
+		echo "## unfreezing: dmsetup message \"${dm%:*}\""
+		dmsetup message "${dm%:*}" 0 "idle" &
+	done
+
 	# Resume suspended devices first
-	for dm in $(dm_info suspended,name | grep "^Suspended:.*$prefix"); do
-		echo "dmsetup resume \"${dm#Suspended:}\""
-		dmsetup clear "${dm#Suspended:}"
-		dmsetup resume "${dm#Suspended:}" &
+	for dm in $(dm_info name -S "name=~$PREFIX&&suspended=Suspended"); do
+		test "$dm" != "No devices found" || break
+		echo "## resuming: dmsetup resume \"$dm\""
+		dmsetup clear "$dm"
+		dmsetup resume "$dm" &
 	done
 
 	wait
@@ -425,37 +433,40 @@ teardown_devs_prefixed() {
 
 	# 2nd. loop is trying --force removal which can possibly 'unstuck' some bloked operations
 	for i in 0 1; do
-		local num_remaining_devs=999999
-		local num_devs=0
 		test "$i" = 1 && test "$stray" = 0 && break  # no stray device removal
 
 		while :; do
-			local cnt
 			local sortby="name"
-			local need_udev_wait=0
+			local num_devs=0
 
 			# HACK: sort also by minors - so we try to close 'possibly later' created device first
 			test "$i" = 0 || sortby="-minor"
 
-			# when nothing left for removal, escape both loops...
-			dm_info name,open --separator ' ' --sort open,"$sortby" | grep "$prefix" > out || break 2
-			num_devs=$(wc -l < out)
-			test "$num_devs" -lt "$num_remaining_devs" || break  # not managed to reduce table size anymore
-			test "$i" = 0 || echo "## removing $num_devs stray mapped devices with names beginning with $prefix: "
-			while IFS=' ' read -r dm cnt; do
+			for dm in $(dm_info name,open --separator ';'  --nameprefixes --sort open,"$sortby" -S "name=~$prefix") ; do
+				test "$dm" != "No devices found" || break 2
+				eval "$dm"
+
 				if test "$i" = 0; then
-					test "$cnt" -eq 0 || break  # stop loop with 1st. opened device
-					dmsetup remove "$dm" &>/dev/null || touch REMOVE_FAILED &
+					if test "$once" = 1 ; then
+						once=0
+						echo "## removing stray mapped devices with names beginning with $prefix: "
+					fi
+					test "$DM_OPEN" = 0 || break  # stop loop with 1st. opened device
+					dmsetup remove "$DM_NAME" &>/dev/null || touch REMOVE_FAILED &
 				else
-					dmsetup remove -f "$dm" || true
+					dmsetup remove -f "$DM_NAME" || true
 				fi
-				need_udev_wait=1
-			done < out
-			test "$need_udev_wait" -eq 1 || break
+
+				num_devs=$(( num_devs + 1 ))
+			done
+
+			test "$i" = 0 || break
+
+			test "$num_devs" -gt 0 || break
+
 			udev_wait
 			wait
-			num_remaining_devs=$num_devs
-		done # looping till there are some removed devicess
+		done # looping till there are some removed devices
 	done
 }
 
diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index bf472a4..a1f7a01 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -228,6 +228,10 @@ dm_info() {
 	should dmsetup info --noheadings -c -o "$@"
 }
 
+dm_status() {
+	should dmsetup status --noheadings "$@"
+}
+
 dm_table() {
 	should dmsetup table "$@"
 }


