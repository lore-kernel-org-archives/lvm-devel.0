From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:32:17 +0000 (UTC)
Subject: master - tests: wait for clvmd.pid file
Message-ID: <20140321213217.AEF7F60DD7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c0c55846b0a08454c913758f2709888301835bef
Commit:        c0c55846b0a08454c913758f2709888301835bef
Parent:        8b1916fd5a5640f357ea50b806840d3981661de6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 21 11:38:20 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:28 2014 +0100

tests: wait for clvmd.pid file

Just like with dmeventd and lvmetad.
Do few indent changes around.
---
 test/Makefile.in |    1 +
 test/lib/aux.sh  |   38 ++++++++++++++++++--------------------
 2 files changed, 19 insertions(+), 20 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 4bd90c7..15cdf7e 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -141,6 +141,7 @@ lib/paths: $(srcdir)/Makefile.in .lib-dir-stamp
 	echo 'export THIN=@THIN@' >> $@-t
 	echo 'export LVMETAD_PIDFILE="@LVMETAD_PIDFILE@"' >> $@-t
 	echo 'export DMEVENTD_PIDFILE="@DMEVENTD_PIDFILE@"' >> $@-t
+	echo 'export CLVMD_PIDFILE="@CLVMD_PIDFILE@"' >> $@-t
 	mv $@-t $@
 
 LIB = lib/not lib/should lib/harness \
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 42ac0a5..502ed84 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -22,6 +22,7 @@ expect_failure() {
 }
 
 prepare_clvmd() {
+	rm -f debug.log
 	test "${LVM_TEST_LOCKING:-0}" -ne 3 && return # not needed
 
 	if pgrep clvmd ; then
@@ -34,25 +35,26 @@ prepare_clvmd() {
 	# lvs is executed from clvmd - use our version
 	export LVM_BINARY=$(which lvm)
 
-	# skip if we singlenode is not compiled in
+	# skip if singlenode is not compiled in
 	(clvmd --help 2>&1 | grep "Available cluster managers" | grep "singlenode") || skip
 
 #	lvmconf "activation/monitoring = 1"
 	local run_valgrind=
 	test "${LVM_VALGRIND_CLVMD:-0}" -eq 0 || run_valgrind="run_valgrind"
+	rm -f "$CLVMD_PIDFILE"
 	$run_valgrind lib/clvmd -Isinglenode -d 1 -f &
-	local local_clvmd=$!
-	sleep .3
-	# extra sleep for slow valgrind
-	test -z "$run_valgrind" || sleep 7
-	# check that it is really running now
-	ps $local_clvmd || die
-	echo $local_clvmd > LOCAL_CLVMD
+	echo $! > LOCAL_CLVMD
+
+	for i in $(seq 1 100) ; do
+		test $i -eq 100 && die "Startup of clvmd is too slow."
+		test -e "$CLVMD_PIDFILE" && break
+		sleep .2
+	done
 }
 
 prepare_dmeventd() {
+	rm -f debug.log
 	if pgrep dmeventd ; then
-		rm -f debug.log
 		echo "Cannot test dmeventd with real dmeventd ($(pgrep dmeventd)) running."
 		skip
 	fi
@@ -77,6 +79,7 @@ prepare_dmeventd() {
 }
 
 prepare_lvmetad() {
+	rm -f debug.log
 	# skip if we don't have our own lvmetad...
 	(which lvmetad 2>/dev/null | grep "$abs_builddir") || skip
 
@@ -111,7 +114,7 @@ lvmetad_talk() {
 }
 
 lvmetad_dump() {
-    (echo 'request="dump"'; echo '##') | lvmetad_talk "$@"
+	(echo 'request="dump"'; echo '##') | lvmetad_talk "$@"
 }
 
 notify_lvmetad() {
@@ -713,8 +716,7 @@ wait_for_sync() {
 }
 
 # Check if tests are running on 64bit architecture
-can_use_16T()
-{
+can_use_16T() {
 	test "$(getconf LONG_BIT)" -eq 64
 }
 
@@ -725,8 +727,7 @@ can_use_16T()
 # [dm-]target-name major minor revision
 #
 # i.e.   dm_target_at_least  dm-thin-pool  1 0
-target_at_least()
-{
+target_at_least() {
 	rm -f debug.log
 	case "$1" in
 	  dm-*) modprobe "$1" || true ;;
@@ -759,8 +760,7 @@ target_at_least()
 	test "$revision" -ge "$3" 2>/dev/null || return 1
 }
 
-have_thin()
-{
+have_thin() {
 	target_at_least dm-thin-pool "$@" || exit 1
 	test "$THIN" = shared || test "$THIN" = internal || exit 1
 
@@ -769,13 +769,11 @@ have_thin()
 }
 
 # check if lvm shell is build-in  (needs readline)
-have_readline()
-{
+have_readline() {
 	echo version | lvm &>/dev/null
 }
 
-dmsetup_wrapped()
-{
+dmsetup_wrapped() {
 	udev_wait
 	dmsetup "$@"
 }


