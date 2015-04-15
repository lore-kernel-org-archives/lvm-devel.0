From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 15 Apr 2015 11:38:17 +0000 (UTC)
Subject: master - tests: no tables for no devices
Message-ID: <20150415113817.979A760DD2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1a7dd13e70e32bc519b27b509b67b0de8f86e631
Commit:        1a7dd13e70e32bc519b27b509b67b0de8f86e631
Parent:        f5466fe43597bfacb7fc70e0a61d569b6c5198c4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 14 14:56:15 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 15 13:35:42 2015 +0200

tests: no tables for no devices

If dm table does't contain any PREFIX device, don't bother
to call other commands

No tracing if test is skipped.
---
 test/lib/utils.sh |   51 +++++++++++++++++++++++++++------------------------
 1 files changed, 27 insertions(+), 24 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 1713cc9..e2b257d 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -132,6 +132,8 @@ STACKTRACE() {
 		done
 	fi
 
+	test -f SKIP_THIS_TEST && exit 200
+
 	test -z "$LVM_TEST_NODEBUG" -a -f debug.log && {
 		IDX=
 		for i in debug.log* ; do
@@ -139,39 +141,40 @@ STACKTRACE() {
 			sed -e "s,^,## DEBUG${IDX}: ," $i
 			IDX=$(($IDX + 1))
 		done
-		test -e clvmddebug.log && {
+		if test -e clvmddebug.log ; then
 			echo "<======== CLVMD debug log ========>"
 			sed -e "s,^,## CLVMD: ," clvmddebug.log
-		}
-		test -e strace.log && {
+		fi
+		if test -e strace.log ; then
 			echo "<======== Strace debug log ========>"
 			sed -e "s,^,## STRACE: ," strace.log
-		}
-		echo "<======== Info ========>"
-		dmsetup info -c | grep1_ "$PREFIX" | sed -e "s,^,## DMINFO:   ,"
-		echo "<======== Active table ========>"
-		dmsetup table | grep "$PREFIX" | sed -e "s,^,## DMTABLE:  ,"
-		echo "<======== Inactive table ========>"
-		dmsetup table --inactive  | grep "$PREFIX" | sed -e "s,^,## DMITABLE: ,"
-		echo "<======== Status ========>"
-		dmsetup status | grep "$PREFIX" | sed -e "s,^,## DMSTATUS: ,"
-		echo "<======== Tree ========>"
-		dmsetup ls --tree | sed -e "s,^,## DMTREE:   ,"
-		echo "<======== Recursive list of $DM_DEV_DIR ========>"
-		ls -Rl --hide=shm --hide=bus --hide=snd --hide=input --hide=dri \
-		       --hide=net --hide=hugepages --hide=mqueue --hide=pts \
-		       "$DM_DEV_DIR" | sed -e "s,^,## LSLR:     ,"
-		echo "<======== Udev DB content ========>"
-		for i in /sys/block/dm-* /sys/block/loop* ; do
-			udevadm info --path "$i" || true
-		done | sed -e "s,^,## UDEV:     ,"
+		fi
+		dmsetup info -c | grep1_ "$PREFIX" > out
+		if test $(wc -l < out) -gt 1 ; then
+			echo "<======== Info ========>"
+			sed -e "s,^,## DMINFO:   ," out
+			echo "<======== Active table ========>"
+			dmsetup table | grep "$PREFIX" | sed -e "s,^,## DMTABLE:  ,"
+			echo "<======== Inactive table ========>"
+			dmsetup table --inactive  | grep "$PREFIX" | sed -e "s,^,## DMITABLE: ,"
+			echo "<======== Status ========>"
+			dmsetup status | grep "$PREFIX" | sed -e "s,^,## DMSTATUS: ,"
+			echo "<======== Tree ========>"
+			dmsetup ls --tree | sed -e "s,^,## DMTREE:   ,"
+			echo "<======== Recursive list of $DM_DEV_DIR ========>"
+			ls -Rl --hide=shm --hide=bus --hide=snd --hide=input --hide=dri \
+			       --hide=net --hide=hugepages --hide=mqueue --hide=pts \
+			       "$DM_DEV_DIR" | sed -e "s,^,## LSLR:	,"
+			echo "<======== Udev DB content ========>"
+			for i in /sys/block/dm-* /sys/block/loop* ; do
+				udevadm info --query=all --path "$i" || true
+			done | sed -e "s,^,## UDEV:	,"
+		fi
 		echo "<======== Script file \"$(< TESTNAME)\" ========>"
 		local script=$0
 		test -f "$script" || script="$TESTOLDPWD/$0"
 		awk '{print "## Line:", NR, "\t", $0}' "$script"
 	}
-
-	test -f SKIP_THIS_TEST && exit 200
 }
 
 init_udev_transaction() {


