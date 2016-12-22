From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Dec 2016 22:38:36 +0000 (UTC)
Subject: master - tests: use hold_device_open
Message-ID: <20161222223836.6B5DC611D0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=62be9c8de430a054d5de9b652949f58a684a0cf6
Commit:        62be9c8de430a054d5de9b652949f58a684a0cf6
Parent:        e1943fc07f81e1c824757ccdac45c1e43a57af28
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 22 23:31:22 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 22 23:37:07 2016 +0100

tests: use hold_device_open

---
 test/shell/snapshot-merge-stack.sh     |    4 +---
 test/shell/snapshot-usage.sh           |   15 +--------------
 test/shell/thin-autoumount-dmeventd.sh |    6 +++---
 3 files changed, 5 insertions(+), 20 deletions(-)

diff --git a/test/shell/snapshot-merge-stack.sh b/test/shell/snapshot-merge-stack.sh
index bfafe71..2fdfaa4 100644
--- a/test/shell/snapshot-merge-stack.sh
+++ b/test/shell/snapshot-merge-stack.sh
@@ -29,9 +29,7 @@ snap_and_merge() {
 	sync
 	lvs -a $vg
 
-	# keep device open to prevent instant merge
-	sleep 20 < "$DM_DEV_DIR/$vg/$lv1" &
-	SLEEP_PID=$!
+	SLEEP_PID=$(aux hold_device_open $vg $lv1 20)
 
 	# initiate background merge
 	lvconvert -b --merge $vg/$lv2
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index 042b4bf..a780664 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -24,16 +24,6 @@ fill() {
 		die "Snapshot does not fit $1"
 }
 
-# Wait until device is opened
-wait_for_open_() {
-	for i in $(seq 1 50) ; do
-		test $(dmsetup info --noheadings -c -o open $1) -ne 0 && return
-		sleep 0.1
-	done
-
-	die "$1 expected to be openned, but it's not!"
-}
-
 cleanup_tail()
 {
 	test -z "$SLEEP_PID" || kill $SLEEP_PID || true
@@ -125,10 +115,7 @@ lvchange -ay $vg1
 check lv_field $vg1/$lv1 lv_active "$CHECK_ACTIVE"
 
 # Test removal of opened (but unmounted) snapshot (device busy) for a while
-sleep 120 < "$DM_DEV_DIR/$vg1/$lv1" &
-SLEEP_PID=$!
-
-wait_for_open_ "$vg1-$lv1"
+SLEEP_PID=$(aux hold_device_open $vg1 $lv1 60)
 
 # Opened virtual snapshot device is not removable
 # it should retry device removal for a few seconds
diff --git a/test/shell/thin-autoumount-dmeventd.sh b/test/shell/thin-autoumount-dmeventd.sh
index 3729e18..40dd75f 100644
--- a/test/shell/thin-autoumount-dmeventd.sh
+++ b/test/shell/thin-autoumount-dmeventd.sh
@@ -72,18 +72,18 @@ touch "$mntusedir/file$$"
 sync
 
 # Running 'keeper' process sleep holds the block device still in use
-sleep 60 < "$mntusedir/file$$" &
+sleep 60 < "$mntusedir/file$$" >/dev/null 2>&1 &
 PID_SLEEP=$!
 
 lvs -a $vg
 # Fill pool above 95%  (to cause 'forced lazy umount)
 dd if=/dev/zero of="$mntdir/file$$" bs=256K count=20 conv=fdatasync
-sync
+
 lvs -a $vg
 
 # Could loop here for a few secs so dmeventd can do some work
 # In the worst case check only happens every 10 seconds :(
-# With low water mark it should react way faster
+# With low water mark it quickly discovers overflow and umounts $vg/$lv1
 for i in $(seq 1 12) ; do
 	is_lv_opened_ "$vg/$lv1" || break
 	test $i -lt 12 || die "$mntdir should have been unmounted by dmeventd!"


