From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:10:39 +0000 (GMT)
Subject: stable-2.02 - tests: add wait on udev processing
Message-ID: <20201016191039.225BC396EC06@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3388779570924154e5e4f657889e121a4bd10e87
Commit:        3388779570924154e5e4f657889e121a4bd10e87
Parent:        3b995b8018435ebb51026b57ac536db2d535ec26
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 15 16:56:40 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 16:02:05 2020 +0200

tests: add wait on udev processing

Trying to avoid collision with udev watch rule preventing to
succeed 'dmsetup remove' because it keeps device open.
---
 test/shell/thin-foreign-repair.sh | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/test/shell/thin-foreign-repair.sh b/test/shell/thin-foreign-repair.sh
index 147a9a073..55e9f62c6 100644
--- a/test/shell/thin-foreign-repair.sh
+++ b/test/shell/thin-foreign-repair.sh
@@ -17,9 +17,15 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+clean_thin_()
+{
+	aux udev_wait
+	dmsetup remove "$THIN" || { sleep .5 ; dmsetup remove "$THIN" ; }
+}
+
 cleanup_mounted_and_teardown()
 {
-	dmsetup remove $THIN || true
+	clean_thin_ || true
 	vgremove -ff $vg
 	aux teardown
 }
@@ -56,7 +62,7 @@ dmsetup create "$THIN" --table "0 40960 thin $DM_DEV_DIR/mapper/$POOL 0"
 
 mkfs.ext4 "$DM_DEV_DIR/mapper/$THIN"
 
-dmsetup remove "$THIN"
+clean_thin_
 
 lvchange -an $vg/pool
 
@@ -70,3 +76,5 @@ lvchange -ay $vg/pool
 dmsetup create "$THIN" --table "0 40960 thin $DM_DEV_DIR/mapper/$POOL 0"
 
 fsck -n "$DM_DEV_DIR/mapper/$THIN"
+
+# exit calls cleanup_mounted_and_teardown


