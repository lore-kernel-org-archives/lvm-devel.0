From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 30 Jun 2017 06:14:04 -0400
Subject: master - tests: aux do not specify bitmap for raid0
Message-ID: <201706301014.v5UAE4Yp020380@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=674a93ffe3db8a21534c9b10d6fcb407258e191a
Commit:        674a93ffe3db8a21534c9b10d6fcb407258e191a
Parent:        596cf2c6fabefb67c4d42d8aad055272b7c452b6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 30 11:45:07 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 30 12:09:10 2017 +0200

tests: aux do not specify bitmap for raid0

---
 test/lib/aux.sh |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 4e2b246..99e8a6d 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -697,7 +697,8 @@ prepare_md_dev() {
 	local level=$1
 	local rchunk=$2
 	local rdevs=$3
-
+	local with_bitmap="--bitmap=internal"
+	local coption="--chunk"
 	local maj
 	local mddev
 	maj=$(mdadm --version 2>&1) || skip "mdadm tool is missing!"
@@ -706,8 +707,10 @@ prepare_md_dev() {
 
 	rm -f debug.log strace.log MD_DEV MD_DEV_PV MD_DEVICES
 
-	coption="--chunk"
-	test "$level" = "1" && coption="--bitmap-chunk"
+	case "$level" in
+	"1")  coption="--bitmap-chunk" ;;
+	"0")  unset with_bitmap ;;
+	esac
 	# Have MD use a non-standard name to avoid colliding with an existing MD device
 	# - mdadm >= 3.0 requires that non-standard device names be in /dev/md/
 	# - newer mdadm _completely_ defers to udev to create the associated device node
@@ -717,7 +720,7 @@ prepare_md_dev() {
 		mddev=/dev/md/md_lvm_test0 || \
 		mddev=/dev/md_lvm_test0
 
-	mdadm --create --metadata=1.0 "$mddev" --auto=md --level "$level" --bitmap=internal "$coption"="$rchunk" --raid-devices="$rdevs" "${@:4}" || {
+	mdadm --create --metadata=1.0 "$mddev" --auto=md --level "$level" $with_bitmap "$coption"="$rchunk" --raid-devices="$rdevs" "${@:4}" || {
 		# Some older 'mdadm' version managed to open and close devices internaly
 		# and reporting non-exclusive access on such device
 		# let's just skip the test if this happens.


