From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:26:44 -0400
Subject: master - tests: aux.sh tweaks
Message-ID: <201707101226.v6ACQi39021594@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=72e82b42a9c07293fdfae7ec0a98dd9fe5a0c868
Commit:        72e82b42a9c07293fdfae7ec0a98dd9fe5a0c868
Parent:        73cb5b486a906779b408b27567d8717617acb3f6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 10 13:01:33 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: aux.sh  tweaks

Some improvements.
---
 test/lib/aux.sh |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 6059b6a..aa5f0a0 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -513,7 +513,7 @@ kill_tagged_processes() {
 		echo "$pid" >> PIDS
 	done
 
-	test -f PIDS || return 0
+	test -s PIDS || return 0
 
 	# wait if process exited and eventually -KILL
 	wait=0
@@ -527,6 +527,7 @@ kill_tagged_processes() {
 }
 
 teardown() {
+	local TEST_LEAKED_DEVICES
 	echo -n "## teardown..."
 	unset LVM_LOG_FILE_EPOCH
 
@@ -597,7 +598,9 @@ teardown() {
 
 	echo "ok"
 
-	test "${LVM_TEST_PARALLEL:-0}" -eq 1 -o -n "$RUNNING_DMEVENTD" || not pgrep dmeventd #&>/dev/null
+	if test "${LVM_TEST_PARALLEL:-0}" = 1 || test -n "$RUNNING_DMEVENTD"; then
+		not pgrep dmeventd #&>/dev/null
+	fi
 }
 
 prepare_loop() {
@@ -872,7 +875,7 @@ common_dev_() {
 		read_ms=${3:-0}
 		write_ms=${4:-0}
 		offsets=( ${@:5} )
-		if test "$read_ms" -eq 0 -a "$write_ms" -eq 0 ; then
+		if test "$read_ms" -eq 0 && test "$write_ms" -eq 0 ; then
 			offsets=( )
 		else
 			test -z "${offsets[@]}" && offsets=( "0:" )
@@ -928,8 +931,8 @@ common_dev_() {
 delay_dev() {
 	if test ! -f HAVE_DM_DELAY ; then
 		target_at_least dm-delay 1 1 0 || return 0
+		touch HAVE_DM_DELAY
 	fi
-	touch HAVE_DM_DELAY
 	common_dev_ delay "$@"
 }
 
@@ -1187,10 +1190,9 @@ EOF
 		}
 	}
 
+	# append all parameters  (avoid adding empty \n)
 	local v
-	for v in "$@"; do
-	    echo "$v"
-	done >> "$config_values"
+	test $# -gt 0 && printf "%s\n" "$@" >> "$config_values"
 
 	declare -A CONF 2>/dev/null || {
 		# Associative arrays is not available
@@ -1259,6 +1261,7 @@ profileconf() {
 
 prepare_profiles() {
 	local pdir="$LVM_SYSTEM_DIR/profile"
+	local profile_name
 	mkdir -p "$pdir"
 	for profile_name in "$@"; do
 		test -L "lib/$profile_name.profile" || skip


