From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:32:36 -0400
Subject: master - tests: aux.sh double quote
Message-ID: <201707101232.v6ACWaf5022616@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=32c0dc35493c36b1f4d79264af1ad09a6150b198
Commit:        32c0dc35493c36b1f4d79264af1ad09a6150b198
Parent:        84e83ac37e652baa686648f1bfb4215e2c0dd206
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 6 23:58:28 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: aux.sh double quote

---
 test/lib/aux.sh |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index e31c4d7..3f54dbb 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -351,7 +351,7 @@ prepare_lvmdbusd() {
 		echo "Failed to start lvmdbusd daemon"
 		return 1
 	fi
-	echo $pid > LOCAL_LVMDBUSD
+	echo "$pid" > LOCAL_LVMDBUSD
 	echo ok
 }
 
@@ -384,7 +384,7 @@ teardown_devs_prefixed() {
 	local IFS=$IFS_NL
 	local dm
 
-	rm -rf "$TESTDIR/dev/$prefix"*
+	rm -rf "$TESTDIR/dev/$prefix*"
 
 	# Resume suspended devices first
 	for dm in $(dm_info suspended,name | grep "^Suspended:.*$prefix"); do
@@ -642,7 +642,7 @@ prepare_loop() {
 		done
 	fi
 	test -n "$LOOP" # confirm or fail
-	BACKING_DEV="$LOOP"
+	BACKING_DEV=$LOOP
 	echo "$LOOP" > LOOP
 	echo "$LOOP" > BACKING_DEV
 	echo "ok ($LOOP)"
@@ -1040,7 +1040,7 @@ backup_dev() {
 	local dev
 
 	for dev in "$@"; do
-		dd if="$dev" of="$dev.backup" bs=1024
+		dd if="$dev" of="${dev}.backup" bs=1024
 	done
 }
 
@@ -1048,9 +1048,9 @@ restore_dev() {
 	local dev
 
 	for dev in "$@"; do
-		test -e "$dev.backup" || \
+		test -e "${dev}.backup" || \
 			die "Internal error: $dev not backed up, can't restore!"
-		dd of="$dev" if="$dev.backup" bs=1024
+		dd of="$dev" if="${dev}.backup" bs=1024
 	done
 }
 
@@ -1232,7 +1232,7 @@ lvmconf() {
 
 profileconf() {
 	local pdir="$LVM_SYSTEM_DIR/profile"
-	profile_name="$1"
+	local profile_name=$1
 	shift
 	generate_config "$@"
 	mkdir -p "$pdir"
@@ -1598,7 +1598,7 @@ test -z "$LVM_TEST_AUX_TRACE" || set -x
 
 test -f DEVICES && devs=$(< DEVICES)
 
-if test "$1" = dmsetup; then
+if test "$1" = "dmsetup" ; then
     shift
     dmsetup_wrapped "$@"
 else


