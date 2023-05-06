From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat,  6 May 2023 20:46:14 +0000 (GMT)
Subject: main - aux: wipefs_a takes list of devices
Message-ID: <20230506204614.47C603858D35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=87eae82195d5272808614b14843c302e7bed80d5
Commit:        87eae82195d5272808614b14843c302e7bed80d5
Parent:        534269d0fb834fb9a3b115bf859319fc1acb2275
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 6 20:36:28 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 6 22:40:23 2023 +0200

aux: wipefs_a takes list of devices

Enhance function to take list of device so set of devices
can be wiped with a single call:

aux wipefs_a  "$dev1" "$dev2"
---
 test/lib/aux.sh | 48 ++++++++++++++++++++++++------------------------
 1 file changed, 24 insertions(+), 24 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 241bbd595..c6b6ac1cc 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -872,37 +872,37 @@ cleanup_md_dev() {
 }
 
 wipefs_a() {
-	local dev=$1
-	local have_wipefs=1
-	shift
-
-	if test -n "$LVM_TEST_DEVICES_FILE"; then
-		lvmdevices --deldev "$dev" || true
-	fi
+	local have_wipefs=
 
-	if test -f HAVE_WIPEFS ; then
+	if test -e HAVE_WIPEFS; then
 		have_wipefs=$(< HAVE_WIPEFS)
 	else
-		wipefs -V >/dev/null 2>&1 || have_wipefs=0
-		echo "$have_wipefs" > HAVE_WIPEFS
+		wipefs -V >HAVE_WIPEFS 2>/dev/null && have_wipefs=yes
 	fi
 
 	udev_wait
-	if [ "$have_wipefs" = "1" ] ; then
-		wipefs -a "$dev" || {
-			echo "$dev: device in-use, retrying wipe again."
-			sleep 1
-			udev_wait
-			wipefs -a "$dev"
-		}
-	else
-		dd if=/dev/zero of="$dev" bs=4096 count=8 oflag=direct >/dev/null || true
-		mdadm --zero-superblock "$dev" 2>/dev/null || true
-	fi
 
-	if test -n "$LVM_TEST_DEVICES_FILE"; then
-		lvmdevices --adddev "$dev" || true
-	fi
+	for dev in "$@"; do
+		if test -n "$LVM_TEST_DEVICES_FILE"; then
+			lvmdevices --deldev "$dev" || true
+		fi
+
+		if test -n "$have_wipefs"; then
+			wipefs -a "$dev" || {
+				echo "$dev: device in-use, retrying wipe again."
+				sleep .1
+				udev_wait
+				wipefs -a "$dev"
+			}
+		else
+			dd if=/dev/zero of="$dev" bs=4096 count=8 oflag=direct >/dev/null || true
+			mdadm --zero-superblock "$dev" 2>/dev/null || true
+		fi
+
+		if test -n "$LVM_TEST_DEVICES_FILE"; then
+			lvmdevices --adddev "$dev" || true
+		fi
+	done
 
 	udev_wait
 }

