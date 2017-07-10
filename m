From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:27:03 -0400
Subject: master - tests: drop unneeded cat
Message-ID: <201707101227.v6ACR39m021622@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2d96b758e4d127d144fdeb92b487cdc5f86de340
Commit:        2d96b758e4d127d144fdeb92b487cdc5f86de340
Parent:        eba96a9720add0120b029a34fe8641297cd1e904
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 6 19:42:15 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: drop unneeded cat

---
 test/shell/snapshot-autoumount-dmeventd.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/snapshot-autoumount-dmeventd.sh b/test/shell/snapshot-autoumount-dmeventd.sh
index 5ef3969..8e2781e 100644
--- a/test/shell/snapshot-autoumount-dmeventd.sh
+++ b/test/shell/snapshot-autoumount-dmeventd.sh
@@ -38,7 +38,7 @@ mount -o errors=remount-ro "$DM_DEV_DIR/mapper/$vg-snap" "$mntdir"
 
 test "$(dmsetup info -c --noheadings -o open $vg-snap)" -eq 1
 
-cat /proc/mounts | grep "$mntdir"
+grep "$mntdir" /proc/mounts
 
 # overfill 4M snapshot (with metadata)
 not dd if=/dev/zero of="$mntdir/file$1" bs=1M count=4 conv=fdatasync
@@ -52,6 +52,6 @@ for i in {1..100}; do
 	test "$(dmsetup info -c --noheadings -o open $vg-snap)" -eq 0 && break
 done
 
-cat /proc/mounts | not grep "$mntdir"
+not grep "$mntdir" /proc/mounts
 
 vgremove -f $vg


