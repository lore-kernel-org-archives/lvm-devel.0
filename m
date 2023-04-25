From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 25 Apr 2023 17:55:39 +0000 (GMT)
Subject: main - tests: utils now print also df_h
Message-ID: <20230425175539.0BFE53858D32@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7f2939d328cf273f7f086a2ddf6cfaab86cf07c1
Commit:        7f2939d328cf273f7f086a2ddf6cfaab86cf07c1
Parent:        7b88c9f6199499692c8b4b47488dffd0f187b9f7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 25 15:07:46 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 25 19:02:39 2023 +0200

tests: utils now print also df_h

Add info about space usage on devices after the test.

Add some more skipped dirs.
---
 test/lib/utils.sh | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 5e462605f..427bc6112 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -189,15 +189,19 @@ STACKTRACE() {
 			echo "<======== Tree ========>"
 			dmsetup ls --tree | sed -e "s,^,## DMTREE:   ,"
 			echo "<======== Recursive list of $DM_DEV_DIR ========>"
-			ls -Rl --hide=shm --hide=bus --hide=snd --hide=input --hide=dri \
-				--hide=net --hide=hugepages --hide=mqueue --hide=pts \
-				--hide=tty?*  --hide=vcs?* --hide=usb --hide=char \
-			       "$DM_DEV_DIR" | sed -e "s,^,## LSLR:	,"
+			ls -lR -I bsg -I bus -I char -Idma_heap -I dri \
+			   -I hugepages -I input -I mqueue \
+			   -I net -I pts -I shm -I snd \
+			   -I tty?* -I usb -I vfio -I vcs?* \
+			   -I virtio-ports \
+			   "$DM_DEV_DIR" | sed -e "s,^,## LS_LR:	,"
 			echo "<======== Udev DB content ========>"
 			for i in /sys/block/dm-* /sys/block/loop* ; do
 				udevadm info --query=all --path "$i" 2>/dev/null || true
 			done | sed -e "s,^,## UDEV:	,"
 		fi
+		echo "<======== Free space ========>"
+		df -h | sed -e "s,^,## DF_H:	,"
 		echo "<======== Script file \"$(< TESTNAME)\" ========>"
 		local script=$0
 		test -f "$script" || script="$TESTOLDPWD/$0"

