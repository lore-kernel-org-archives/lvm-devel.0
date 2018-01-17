From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Jan 2018 08:47:02 -0500
Subject: master - tests: longer startup timeout for daemons with valgrind
Message-ID: <201801171347.w0HDl24Z030078@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5baf2de8986ceeb353c39ccf0503f9fefcb6eb92
Commit:        5baf2de8986ceeb353c39ccf0503f9fefcb6eb92
Parent:        8ebd45fde759c438e854d6b4f02f0e9803094fea
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 15 16:26:34 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 17 14:45:48 2018 +0100

tests: longer startup timeout for daemons with valgrind

It's getting noticable somewhat slower...
---
 test/lib/aux.sh |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index fa9a1a2..fbba84b 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -180,8 +180,8 @@ prepare_clvmd() {
 	LVM_LOG_FILE_EPOCH=CLVMD LVM_LOG_FILE_MAX_LINES=1000000 LVM_BINARY=$(which lvm) $run_valgrind clvmd -Isinglenode -d 1 -f &
 	echo $! > LOCAL_CLVMD
 
-	for i in {1..100} ; do
-		test "$i" -eq 100 && die "Startup of clvmd is too slow."
+	for i in {200..0} ; do
+		test "$i" -eq 0 && die "Startup of clvmd is too slow."
 		test -e "$CLVMD_PIDFILE" && test -e "${CLVMD_PIDFILE%/*}/lvm/clvmd.sock" && break
 		echo -n .
 		sleep .1
@@ -205,8 +205,8 @@ prepare_dmeventd() {
 	echo $! > LOCAL_DMEVENTD
 
 	# FIXME wait for pipe in /var/run instead
-	for i in {1..100} ; do
-		test "$i" -eq 100 && die "Startup of dmeventd is too slow."
+	for i in {200..0} ; do
+		test "$i" -eq 0 && die "Startup of dmeventd is too slow."
 		test -e "${DMEVENTD_PIDFILE}" && break
 		echo -n .
 		sleep .1
@@ -230,8 +230,8 @@ prepare_lvmetad() {
 	$run_valgrind lvmetad -f "$@" -s "$TESTDIR/lvmetad.socket" \
 		${LVM_TEST_LVMETAD_DEBUG_OPTS--l all} &
 	echo $! > LOCAL_LVMETAD
-	for i in {1..100} ; do
-		test "$i" -eq 100 && die "Startup of lvmetad is too slow."
+	for i in {200..0} ; do
+		test "$i" -eq 0 && die "Startup of lvmetad is too slow."
 		test -e "$TESTDIR/lvmetad.socket" && break
 		echo -n .
 		sleep .1;
@@ -280,8 +280,8 @@ prepare_lvmpolld() {
 	echo -n "## preparing lvmpolld..."
 	$run_valgrind lvmpolld -f "$@" -s "$TESTDIR/lvmpolld.socket" -B "$TESTDIR/lib/lvm" -l all &
 	echo $! > LOCAL_LVMPOLLD
-	for i in {1..100} ; do
-		test "$i" -eq 100 && die "Startup of lvmpolld is too slow."
+	for i in {200..0} ; do
+		test "$i" -eq 0 && die "Startup of lvmpolld is too slow."
 		test -e "$TESTDIR/lvmpolld.socket" && break
 		echo -n .;
 		sleep .1;


