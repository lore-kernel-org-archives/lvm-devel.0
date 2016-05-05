From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 May 2016 22:01:44 +0000 (UTC)
Subject: master - tests: update aux raid support
Message-ID: <20160505220144.193CC60C97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=07c1694ff59fd760a602fb1425c5c99bc0bd33ca
Commit:        07c1694ff59fd760a602fb1425c5c99bc0bd33ca
Parent:        7bb39af03630beb91acd457b9d949f7ecfa0e75e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 5 21:00:42 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 5 23:55:20 2016 +0200

tests: update aux raid support

For raid1  use chunksize as bitmap-chunk specification.
Always enforce usage of bitmap - getting comparable outcome
as lvm2 raid support uses.
Add udev_wait after stopping  md array - as in fact leg-device
are still in use by target even command has finished.

(mdadm --stop causes WATCH rule wakeup, and
ioctl(STOP_ARRAY) returns IMHO to early - it should finish
and fsync work on leg devices first).
---
 test/lib/aux.sh |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 08187b5..3bb469b 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -659,6 +659,8 @@ prepare_md_dev() {
 
 	rm -f debug.log strace.log MD_DEV MD_DEV_PV MD_DEVICES
 
+	coption="--chunk"
+	test "$level" = "1" && coption="--bitmap-chunk"
 	# Have MD use a non-standard name to avoid colliding with an existing MD device
 	# - mdadm >= 3.0 requires that non-standard device names be in /dev/md/
 	# - newer mdadm _completely_ defers to udev to create the associated device node
@@ -668,7 +670,7 @@ prepare_md_dev() {
 		mddev=/dev/md/md_lvm_test0 || \
 		mddev=/dev/md_lvm_test0
 
-	mdadm --create --metadata=1.0 "$mddev" --auto=md --level $level --chunk $rchunk --raid-devices=$rdevs "${@:4}" || {
+	mdadm --create --metadata=1.0 "$mddev" --auto=md --level $level --bitmap=internal $coption=$rchunk --raid-devices=$rdevs "${@:4}" || {
 		# Some older 'mdadm' version managed to open and close devices internaly
 		# and reporting non-exclusive access on such device
 		# let's just skip the test if this happens.
@@ -707,6 +709,7 @@ cleanup_md_dev() {
 	mdadm --stop "$dev" || true
 	test "$DM_DEV_DIR" != "/dev" && rm -f "$DM_DEV_DIR/$(basename $dev)"
 	notify_lvmetad $(< MD_DEV_PV)
+	udev_wait  # wait till events are process, not zeroing to early
 	for dev in $(< MD_DEVICES); do
 		mdadm --zero-superblock "$dev" || true
 		notify_lvmetad "$dev"


