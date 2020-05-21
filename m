From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 21 May 2020 14:05:41 +0000 (GMT)
Subject: master - tests: also udev wait on clean-up path
Message-ID: <20200521140541.438C83840C37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bb41ca86fa962dd5d90c2b5498e93bb8a3aa2f91
Commit:        bb41ca86fa962dd5d90c2b5498e93bb8a3aa2f91
Parent:        53803821de166109131c4d4e5396116f89dbb082
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 21 15:19:31 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 21 16:03:41 2020 +0200

tests: also udev wait on clean-up path

---
 test/shell/thin-foreign-repair.sh | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/test/shell/thin-foreign-repair.sh b/test/shell/thin-foreign-repair.sh
index 8b4018e4e..55e9f62c6 100644
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
@@ -56,9 +62,7 @@ dmsetup create "$THIN" --table "0 40960 thin $DM_DEV_DIR/mapper/$POOL 0"
 
 mkfs.ext4 "$DM_DEV_DIR/mapper/$THIN"
 
-aux udev_wait
-
-dmsetup remove "$THIN" || { sleep .5 ; dmsetup remove "$THIN" }
+clean_thin_
 
 lvchange -an $vg/pool
 
@@ -72,3 +76,5 @@ lvchange -ay $vg/pool
 dmsetup create "$THIN" --table "0 40960 thin $DM_DEV_DIR/mapper/$POOL 0"
 
 fsck -n "$DM_DEV_DIR/mapper/$THIN"
+
+# exit calls cleanup_mounted_and_teardown


