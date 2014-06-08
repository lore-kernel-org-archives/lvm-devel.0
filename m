From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun,  8 Jun 2014 19:12:03 +0000 (UTC)
Subject: master - test: Make it possible to enable/disable devices silently.
Message-ID: <20140608191203.9F0A061200@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eda4c3a41d7ca1642ee779af69cb862ba8332e66
Commit:        eda4c3a41d7ca1642ee779af69cb862ba8332e66
Parent:        dba6dec661c6a0193d9d713c6fd0b9b008c0f26a
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 26 14:37:45 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Jun 8 21:10:47 2014 +0200

test: Make it possible to enable/disable devices silently.

---
 test/lib/aux.sh |   40 ++++++++++++++++++++++++++++++++++++----
 1 files changed, 36 insertions(+), 4 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 445bf26..3ececaf 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -406,19 +406,50 @@ delay_dev() {
 
 disable_dev() {
 	local dev
+	local silent
+	local error
+	local notify
+
+	while test -n "$1"; do
+	    if test "$1" = "--silent"; then
+		silent=1
+		shift
+	    elif test "$1" = "--error"; then
+		error=1
+		shift
+	    else
+		break
+	    fi
+	done
 
 	udev_wait
 	for dev in "$@"; do
 		maj=$(($(stat -L --printf=0x%t "$dev")))
 		min=$(($(stat -L --printf=0x%T "$dev")))
 		echo "Disabling device $dev ($maj:$min)"
-		dmsetup remove -f "$dev" 2>/dev/null || true
-		notify_lvmetad --major "$maj" --minor "$min"
+		notify="$notify $maj:$min"
+		if test -n "$error"; then
+		    echo 0 10000000 error | dmsetup load $dev
+		    dmsetup resume $dev
+		else
+		    dmsetup remove -f "$dev" 2>/dev/null || true
+		fi
+	done
+
+	test -n "$silent" || for num in $notify; do
+		notify_lvmetad --major $(echo $num | sed -e "s,:.*,,") \
+		               --minor $(echo $num | sed -e "s,.*:,,")
 	done
 }
 
 enable_dev() {
 	local dev
+	local silent
+
+	if test "$1" = "--silent"; then
+	    silent=1
+	    shift
+	fi
 
 	rm -f debug.log
 	init_udev_transaction
@@ -431,7 +462,7 @@ enable_dev() {
 	done
 	finish_udev_transaction
 
-	for dev in "$@"; do
+	test -n "$silent" || for dev in "$@"; do
 		notify_lvmetad "$dev"
 	done
 }
@@ -450,6 +481,7 @@ error_dev() {
 	local type
 	local pvdev
 	local offset
+	local silent
 
 	read pos size type pvdev offset < $name.table
 
@@ -480,7 +512,7 @@ error_dev() {
 	# using device name (since device path does not exists yet with udev)
 	dmsetup resume "$name"
 	finish_udev_transaction
-	notify_lvmetad "$dev"
+	test -n "$silent" || notify_lvmetad "$dev"
 }
 
 backup_dev() {


