From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:28:05 -0400
Subject: master - tests: aux.sh separately assign
Message-ID: <201706292028.v5TKS5hn026732@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8a912d6dbcc34ce2b76a0104c39de7aa0480c512
Commit:        8a912d6dbcc34ce2b76a0104c39de7aa0480c512
Parent:        4f63b7e9c130ce1de12c38fb794fe7b3142dc9bd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 12:07:34 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:17 2017 +0200

tests: aux.sh separately assign

Declare and assign separately to avoid masking return values.
---
 test/lib/aux.sh |   25 ++++++++++++++++---------
 1 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index b130560..e82d698 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -695,8 +695,9 @@ prepare_md_dev() {
 	local rchunk=$2
 	local rdevs=$3
 
-	local maj=$(mdadm --version 2>&1) || skip "mdadm tool is missing!"
+	local maj
 	local mddev
+	maj=$(mdadm --version 2>&1) || skip "mdadm tool is missing!"
 
 	cleanup_md_dev
 
@@ -746,8 +747,8 @@ cleanup_md_dev() {
 	test -f MD_DEV || return 0
 
 	local IFS=$IFS_NL
-	local dev=$(< MD_DEV)
-
+	local dev
+	dev=$(< MD_DEV)
 	udev_wait
 	mdadm --stop "$dev" || true
 	test "$DM_DEV_DIR" != "/dev" && rm -f "$DM_DEV_DIR/$(basename "$dev")"
@@ -972,7 +973,8 @@ enable_dev() {
 	rm -f debug.log strace.log
 	init_udev_transaction
 	for dev in "$@"; do
-		local name=$(echo "$dev" | sed -e 's,.*/,,')
+		local name
+		name=$(echo "$dev" | sed -e 's,.*/,,')
 		dmsetup create -u "TEST-$name" "$name" "$name.table" 2>/dev/null || \
 			dmsetup load "$name" "$name.table"
 		# using device name (since device path does not exists yes with udev)
@@ -999,7 +1001,8 @@ restore_from_devtable() {
 	rm -f debug.log strace.log
 	init_udev_transaction
 	for dev in "$@"; do
-		local name=$(echo "$dev" | sed -e 's,.*/,,')
+		local name
+		name=$(echo "$dev" | sed -e 's,.*/,,')
 		dmsetup load "$name" "$name.devtable"
 		dmsetup resume "$name"
 	done
@@ -1381,7 +1384,8 @@ target_at_least() {
 		esac
 	fi
 
-	local version=$(dmsetup targets 2>/dev/null | grep "${1##dm-} " 2>/dev/null)
+	local version
+	version=$(dmsetup targets 2>/dev/null | grep "${1##dm-} " 2>/dev/null)
 	version=${version##* v}
 
 	version_at_least "$version" "${@:2}" || {
@@ -1397,7 +1401,8 @@ target_at_least() {
 # e.g. driver_at_least 4 33
 #
 driver_at_least() {
-	local version=$(dmsetup version | tail -1 2>/dev/null)
+	local version
+	version=$(dmsetup version | tail -1 2>/dev/null)
 	version=${version##*:}
 	version_at_least "$version" "$@" || {
 		echo "Found driver version $version, but requested" "$@" "." >&2
@@ -1478,7 +1483,8 @@ have_cache() {
 }
 
 have_tool_at_least() {
-	local version=$($1 -V 2>/dev/null)
+	local version
+	version=$("$1" -V 2>/dev/null)
 	version=${version%%-*}
 	shift
 
@@ -1515,7 +1521,8 @@ awk_parse_init_count_in_lvmpolld_dump() {
 }
 
 check_lvmpolld_init_rq_count() {
-	local ret=$(awk -v vvalue="$2" -v vkey="${3:-lvname}" "$(awk_parse_init_count_in_lvmpolld_dump)" lvmpolld_dump.txt)
+	local ret
+	ret=$(awk -v vvalue="$2" -v vkey="${3:-lvname}" "$(awk_parse_init_count_in_lvmpolld_dump)" lvmpolld_dump.txt)
 	test "$ret" -eq "$1" || {
 		echo "check_lvmpolld_init_rq_count failed. Expected $1, got $ret"
 		return 1


