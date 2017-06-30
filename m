From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 30 Jun 2017 06:14:08 -0400
Subject: master - tests: aux prepares lvmdbusd
Message-ID: <201706301014.v5UAE8XO020392@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9348ad4f164a2d8806b08f28a937aaa1041b4f6b
Commit:        9348ad4f164a2d8806b08f28a937aaa1041b4f6b
Parent:        674a93ffe3db8a21534c9b10d6fcb407258e191a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 30 12:07:30 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 30 12:12:16 2017 +0200

tests: aux prepares lvmdbusd

Correctly skip the test when lvmdbusd is found already running.
For pgrep usage we need to add '-f -l' options to get python3 name
printed.
Remove no longer used 'pids' local var.
---
 test/lib/aux.sh |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 99e8a6d..ed969e2 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -309,9 +309,8 @@ prepare_lvmdbusd() {
 
         # FIXME: This is not correct! Daemon is auto started.
 	echo "checking lvmdbusd is NOT running..."
-	if pgrep lvmdbusd | grep python3; then
-		echo "Cannot run while existing lvmdbusd process exists"
-		return 1
+	if pgrep -f -l lvmdbusd | grep python3 ; then
+		skip "Cannot run while existing lvmdbusd process exists"
 	fi
 	echo ok
 
@@ -320,7 +319,7 @@ prepare_lvmdbusd() {
 		# NOTE: this is always present - additional checks are needed:
 		daemon="$abs_top_builddir/daemons/lvmdbusd/lvmdbusd"
 		# Setup the python path so we can run
-		export PYTHONPATH=$abs_top_builddir/daemons
+		export PYTHONPATH="$abs_top_builddir/daemons"
 	else
 		daemon=$(which lvmdbusd || :)
 	fi
@@ -343,7 +342,7 @@ prepare_lvmdbusd() {
 
 	sleep 1
 	echo "checking lvmdbusd IS running..."
-	if ! pgrep lvmdbusd | grep python3; then
+	if ! pgrep -f -l lvmdbusd | grep python3; then
 		echo "Failed to start lvmdbusd daemon"
 		return 1
 	fi
@@ -496,7 +495,6 @@ count_processes_with_tag() {
 
 kill_tagged_processes() {
 	local pid
-	local pids
 	local wait
 
 	# read uses all vars within pipe subshell


