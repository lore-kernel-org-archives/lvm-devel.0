From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:47 +0000 (GMT)
Subject: dev-next - tests: add aux remove_dm_devs
Message-ID: <20210331214947.AAA573857C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d9b97510324e7c16cf8ec61f511b6f5d71bff767
Commit:        d9b97510324e7c16cf8ec61f511b6f5d71bff767
Parent:        0ddbc4c5cdbef0cc57b79c164b22b34c0bc6a27a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 28 13:29:44 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 28 14:22:11 2021 +0200

tests: add aux remove_dm_devs

Add function to remove DM devices and dies
if some device can't be removed.
---
 test/lib/aux.sh | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 38191842d..6177de4d4 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1110,6 +1110,28 @@ enable_dev() {
 	finish_udev_transaction
 }
 
+# Try to remove list of DM device from table
+remove_dm_devs() {
+	local remove=( "$@" )
+	local held
+	local i
+
+	for i in {1..50}; do
+		held=()
+		for d in "${remove[@]}" ; do
+			dmsetup remove "$d" 2>/dev/null || {
+				dmsetup info -c "$d" 2>/dev/null && {
+					held+=( "$d" )
+					dmsetup status "$d"
+				}
+			}
+		done
+		test ${#held[@]} -eq 0 && return
+		remove=( "${held[@]}" )
+	done
+	die "Can't remove device(s) ${held[@]}"
+}
+
 # Throttle down performance of kcopyd when mirroring i.e. disk image
 throttle_sys="/sys/module/dm_mirror/parameters/raid1_resync_throttle"
 throttle_dm_mirror() {


