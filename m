From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 13 Apr 2015 14:39:32 +0000 (UTC)
Subject: master - tests: sections in test separated
Message-ID: <20150413143932.62DED60F0C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0457224febdf1eb3ddc66369d39808a6f2d6ec26
Commit:        0457224febdf1eb3ddc66369d39808a6f2d6ec26
Parent:        f080ebc123a050eff1de3995d7da8c835c4dc6e7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 13 16:30:17 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 13 16:38:31 2015 +0200

tests: sections in test separated

Use  <========  to separate sections.
Use ##  to prefix these outputs.
Drop $top_srcdir from sed  (it's been replacing '..')
Hide more /dev  dirs.
---
 test/lib/aux.sh      |    3 +-
 test/lib/inittest.sh |    1 +
 test/lib/utils.sh    |   51 ++++++++++++++++++++++++++++++++-----------------
 3 files changed, 36 insertions(+), 19 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index a5d620a..1b97bdc 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -43,6 +43,7 @@ prepare_clvmd() {
 	local run_valgrind=
 	test "${LVM_VALGRIND_CLVMD:-0}" -eq 0 || run_valgrind="run_valgrind"
 	rm -f "$CLVMD_PIDFILE"
+	echo "<======== Starting CLVMD ========>"
 	$run_valgrind clvmd -Isinglenode -d 1 -f &
 	echo $! > LOCAL_CLVMD
 
@@ -695,7 +696,7 @@ EOF
 		done
 		echo "}"
 		echo
-	done | tee "$config"
+	done | tee "$config" | sed -e "s,^,## LVMCONF: ,"
 }
 
 lvmconf() {
diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index e3d874b..067c3d4 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -97,5 +97,6 @@ test -n "$LVM_TEST_LVMETAD" && {
 # Vars for harness
 echo "@TESTDIR=$TESTDIR"
 echo "@PREFIX=$PREFIX"
+echo "<======== Processing test: \"$TESTNAME\" ========>"
 
 set -vx
diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index b06bf87..488e338 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -133,25 +133,40 @@ STACKTRACE() {
 	fi
 
 	test -z "$LVM_TEST_NODEBUG" -a -f debug.log && {
-		sed -e "s,^,## DEBUG: ,;s,$top_srcdir/\?,," < debug.log
-		echo "========= CLVMD debug log ========="
-		test -e clvmddebug.log && sed -e "s,^,## CLVMD: ,;s,$top_srcdir/\?,," < clvmddebug.log
-		test -e strace.log && sed -e "s,^,## STRACE: ,;s,$top_srcdir/\?,," < strace.log
-		echo "========= Info ==========="
-		dmsetup info -c | grep1_ "$PREFIX"
-		echo "========= Active table ==========="
-		dmsetup table | grep "$PREFIX"
-		echo "======== Inactive table =========="
-		dmsetup table --inactive  | grep "$PREFIX"
-		echo "======== Status =========="
-		dmsetup status | grep "$PREFIX"
-		echo "======== Tree =========="
-		dmsetup ls --tree
-		echo "======== Recursive list of $DM_DEV_DIR =========="
-		ls -Rl --hide=shm --hide=bus --hide=snd --hide=input "$DM_DEV_DIR"
-		for i in /sys/block/dm-* /sys/block/loop* ; do
-			udevadm info -p "$i" || true
+		IDX=
+		for i in debug.log* ; do
+			echo "<======== Last traced lvm2 command $i ========>"
+			sed -e "s,^,## DEBUG${IDX}: ," $i
+			IDX=$(($IDX + 1))
 		done
+		test -e clvmddebug.log && {
+			echo "<======== CLVMD debug log ========>"
+			sed -e "s,^,## CLVMD: ," clvmddebug.log
+		}
+		test -e strace.log && {
+			echo "<======== Strace debug log ========>"
+			sed -e "s,^,## STRACE: ," strace.log
+		}
+		echo "<======== Info ========>"
+		dmsetup info -c | grep1_ "$PREFIX" | sed -e "s,^,## DMINFO:   ,"
+		echo "<======== Active table ========>"
+		dmsetup table | grep "$PREFIX" | sed -e "s,^,## DMTABLE:  ,"
+		echo "<======== Inactive table ========>"
+		dmsetup table --inactive  | grep "$PREFIX" | sed -e "s,^,## DMITABLE: ,"
+		echo "<======== Status ========>"
+		dmsetup status | grep "$PREFIX" | sed -e "s,^,## DMSTATUS: ,"
+		echo "<======== Tree ========>"
+		dmsetup ls --tree | sed -e "s,^,## DMTREE:   ,"
+		echo "<======== Recursive list of $DM_DEV_DIR ========>"
+		ls -Rl --hide=shm --hide=bus --hide=snd --hide=input --hide=dri \
+		       --hide=net --hide=hugepages --hide=mqueue --hide=pts \
+		       "$DM_DEV_DIR" | sed -e "s,^,## LSLR:     ,"
+		echo "<======== Udev DB content ========>"
+		for i in /sys/block/dm-* /sys/block/loop* ; do
+			udevadm info --path "$i" || true
+		done | sed -e "s,^,## UDEV:     ,"
+		echo "<======== Script file \"$(< TESTNAME)\" ========>"
+		awk '{print "## Line:", NR, "\t", $0}' "$TESTOLDPWD/$0"
 	}
 
 	test -f SKIP_THIS_TEST && exit 200


