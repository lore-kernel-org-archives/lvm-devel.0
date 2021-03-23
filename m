From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 Mar 2021 10:37:12 +0000 (GMT)
Subject: main - tests: aux updates
Message-ID: <20210323103712.E27EB385BF9E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b19e036918cf1c2ac2995e07809a28c06bd1f34a
Commit:        b19e036918cf1c2ac2995e07809a28c06bd1f34a
Parent:        370749a4b859dae834ca5ce514a701a3c3abc75b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 23 09:48:03 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 23 09:48:03 2021 +0100

tests: aux updates

Select unused md from /proc/mdstat
Check for wipefs once.
---
 test/lib/aux.sh | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index a982ca162..617d0b3a4 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -722,7 +722,7 @@ mdadm_create() {
 	# using the old naming /dev/mdXXX
         # if we need more MD arrays test suite more likely leaked them
 	for devid in {127..150} ; do
-		test -b /dev/md${devid} || break
+		grep -q "md${devid}" /proc/mdstat || break
 	done
 	test "$devid" -lt "150" || skip "Cannot find free /dev/mdXXX node!"
 	mddev=/dev/md${devid}
@@ -793,10 +793,10 @@ cleanup_md_dev() {
 		udev_wait  # wait till events are process, not zeroing to early
 	done
 
-	test "$DM_DEV_DIR" != "/dev" && rm -f "$(< MD_DEV_PV)"
+	test "$DM_DEV_DIR" = "/dev" || rm -f "$(< MD_DEV_PV)"
 
 	for dev in $(< MD_DEVICES); do
-		mdadm --zero-superblock "$dev" || true
+		mdadm --zero-superblock "$dev" 2>/dev/null
 	done
 	udev_wait
 	rm -f MD_DEV MD_DEVICES MD_DEV_PV
@@ -804,17 +804,25 @@ cleanup_md_dev() {
 
 wipefs_a() {
 	local dev=$1
+	local have_wipefs=1
 	shift
 
 	if test -n "$LVM_TEST_DEVICES_FILE"; then
 		lvmdevices --deldev $dev || true
 	fi
 
-	if wipefs -V >/dev/null; then
+	if test -f HAVE_WIPEFS ; then
+		have_wipefs=$(< HAVE_WIPEFS)
+	else
+		wipefs -V >/dev/null 2>&1 || have_wipefs=0
+		echo "$have_wipefs" > HAVE_WIPEFS
+	fi
+
+	if [ "$have_wipefs" = "1" ] ; then
 		wipefs -a "$dev"
 	else
-		dd if=/dev/zero of="$dev" bs=4096 count=8 || true
-		mdadm --zero-superblock "$dev" || true
+		dd if=/dev/zero of="$dev" bs=4096 count=8 >/dev/null || true
+		mdadm --zero-superblock "$dev" 2>/dev/null || true
 	fi
 
 	if test -n "$LVM_TEST_DEVICES_FILE"; then


