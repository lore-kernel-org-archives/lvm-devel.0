From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Jul 2017 09:03:47 -0400
Subject: master - tests: aux.sh some backward compatible updates
Message-ID: <201707171303.v6HD3lGX005044@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5a5553bcec2141382407d27781cbade2f6966fe1
Commit:        5a5553bcec2141382407d27781cbade2f6966fe1
Parent:        3c32883cec807a8759dfa98bf258ed6e10ca997f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 17 15:01:44 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 17 15:01:44 2017 +0200

tests: aux.sh some backward compatible updates

Older bash does not take empty array as bounded variable
(except for $@)
---
 test/lib/aux.sh |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index da367aa..b385129 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -526,6 +526,8 @@ kill_tagged_processes() {
 		pids+=( "$pid" )
 	done < <(print_procs_by_tag_ "$@")
 
+	test ${#pids[@]} -eq 0 && return
+
 	# wait if process exited and eventually -KILL
 	wait=0
 	for pid in "${pids[@]}" ; do
@@ -619,7 +621,7 @@ teardown() {
 
 prepare_loop() {
 	local size=${1=32}
-	local losetup_params=( ${@:2} )
+	shift # all other params are directly passed to all 'losetup' calls
 	local i
 	local slash
 
@@ -644,9 +646,9 @@ prepare_loop() {
 	local LOOPFILE="$PWD/test.img"
 	rm -f "$LOOPFILE"
 	dd if=/dev/zero of="$LOOPFILE" bs=$((1024*1024)) count=0 seek=$(( size + 1 )) 2> /dev/null
-	if LOOP=$(losetup "${losetup_params[@]}" -s -f "$LOOPFILE" 2>/dev/null); then
+	if LOOP=$(losetup "$@" -s -f "$LOOPFILE" 2>/dev/null); then
 		:
-	elif LOOP=$(losetup -f) && losetup "${losetup_params[@]}" "$LOOP" "$LOOPFILE"; then
+	elif LOOP=$(losetup -f) && losetup "$@" "$LOOP" "$LOOPFILE"; then
 		# no -s support
 		:
 	else
@@ -657,7 +659,7 @@ prepare_loop() {
 				local dev="$DM_DEV_DIR/loop$slash$i"
 				! losetup "$dev" >/dev/null 2>&1 || continue
 				# got a free
-				losetup "${losetup_params[@]}" "$dev" "$LOOPFILE"
+				losetup "$@" "$dev" "$LOOPFILE"
 				LOOP=$dev
 				break
 			done
@@ -1215,7 +1217,7 @@ EOF
 			echo "$s {"
 			local k
 			for k in $(grep ^"$s"/ "$config_values" | cut -f1 -d= | sed -e 's, *$,,' | sort | uniq); do
-				grep "^$k" "$config_values" | tail -n 1 | sed -e "s,^$s/,	 ,"
+				grep "^$k" "$config_values" | tail -n 1 | sed -e "s,^$s/,	 ," || true
 			done
 			echo "}"
 			echo


