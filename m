From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  9 Apr 2015 11:19:12 +0000 (UTC)
Subject: master - tests: handle debug.log from clvmd
Message-ID: <20150409111912.40602601DE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1a7c9ce3bd6c80ec043af3dc8b88f63b31035e21
Commit:        1a7c9ce3bd6c80ec043af3dc8b88f63b31035e21
Parent:        073643c9a2f0f92a2e3f236b0017db4bbc7c3a54
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 9 13:13:36 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 9 13:13:36 2015 +0200

tests: handle debug.log from clvmd

When clvmd starts, it starts it's own command logging into debug.log.
This is interferring with our other command debug.log.
As as sideeffect we may experience log from command,
followed but lots of zeros and continued with clvmd log.

Fix it by renaming debug.log and now we could also print this trace
to get full list of clvmd activity nicely.

Also improve some post-mortem prints from udevadm and dmsetup to
make the output more usable.
---
 test/lib/aux.sh         |    4 +++-
 test/lib/lvm-wrapper.sh |    3 +++
 test/lib/utils.sh       |   15 +++++++++++----
 3 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 37a9a9a..f471fa4 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -48,9 +48,11 @@ prepare_clvmd() {
 
 	for i in $(seq 1 100) ; do
 		test $i -eq 100 && die "Startup of clvmd is too slow."
-		test -e "$CLVMD_PIDFILE" && break
+		test -e "$CLVMD_PIDFILE" -a -e debug.log && break
 		sleep .2
 	done
+	# Keep log of clvmd in separate debug file
+	mv debug.log clvmddebug.log
 }
 
 prepare_dmeventd() {
diff --git a/test/lib/lvm-wrapper.sh b/test/lib/lvm-wrapper.sh
index 8bc96a2..cbc60d3 100644
--- a/test/lib/lvm-wrapper.sh
+++ b/test/lib/lvm-wrapper.sh
@@ -38,6 +38,9 @@ case "$CMD" in
 	test ${LVM_DEBUG_LEVEL:-0} -lt 1 && RUN_DBG= ;;
 esac
 
+# Capture parallel users of debug.log file
+test -z "$(fuser debug.log 2>/dev/null)" || { echo "Test suite problem: \"debug.log\" is still in use!" >&2 ; return 1 ; }
+
 # the exec is important, because otherwise fatal signals inside "not" go unnoticed
 if test -n "$abs_top_builddir"; then
     exec $RUN_DBG "$abs_top_builddir/tools/lvm" $CMD "$@"
diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 401a862..b06bf87 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -100,6 +100,11 @@ mkdtemp() {
 	die "$err"
 }
 
+# Like grep, just always print 1st. line
+grep1_() {
+	awk -v pattern="${1}" 'NR==1 || $0~pattern' "${@:2}"
+}
+
 STACKTRACE() {
 	trap - ERR
 	local i=0
@@ -129,9 +134,11 @@ STACKTRACE() {
 
 	test -z "$LVM_TEST_NODEBUG" -a -f debug.log && {
 		sed -e "s,^,## DEBUG: ,;s,$top_srcdir/\?,," < debug.log
+		echo "========= CLVMD debug log ========="
+		test -e clvmddebug.log && sed -e "s,^,## CLVMD: ,;s,$top_srcdir/\?,," < clvmddebug.log
 		test -e strace.log && sed -e "s,^,## STRACE: ,;s,$top_srcdir/\?,," < strace.log
 		echo "========= Info ==========="
-		dmsetup info -c | grep "$PREFIX"
+		dmsetup info -c | grep1_ "$PREFIX"
 		echo "========= Active table ==========="
 		dmsetup table | grep "$PREFIX"
 		echo "======== Inactive table =========="
@@ -141,9 +148,9 @@ STACKTRACE() {
 		echo "======== Tree =========="
 		dmsetup ls --tree
 		echo "======== Recursive list of $DM_DEV_DIR =========="
-		ls -Rla "$DM_DEV_DIR"
-		for i in "/sys/block/dm-* /sys/block/loop*" ; do
-			udevadm info --export-db "$i" || true
+		ls -Rl --hide=shm --hide=bus --hide=snd --hide=input "$DM_DEV_DIR"
+		for i in /sys/block/dm-* /sys/block/loop* ; do
+			udevadm info -p "$i" || true
 		done
 	}
 


