From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:29 +0000 (UTC)
Subject: master - test: Make killing local (test) daemons more robust.
Message-ID: <20150205134329.BEE1E60BBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=210a66fbf85fcb16ad645950b18d4ef631af3d53
Commit:        210a66fbf85fcb16ad645950b18d4ef631af3d53
Parent:        17575403d487d8f0deeceea78520f53b68c8573c
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 1 08:53:27 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:51:06 2015 +0100

test: Make killing local (test) daemons more robust.

---
 test/lib/aux.sh   |   17 ++++++++++++-----
 test/lib/utils.sh |    2 +-
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 88b821a..3ef2da0 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -210,11 +210,18 @@ teardown_devs() {
 }
 
 kill_sleep_kill_() {
-	if test -s "$1" ; then
-		if kill -TERM "$(< $1)" ; then
-			if test "$2" -eq 0 ; then sleep .1 ; else sleep 1 ; fi
-			kill -KILL "$(< $1)" 2>/dev/null || true
-		fi
+	pidfile=$1
+	slow=$2
+	if test -s $pidfile ; then
+		pid=$(< $pidfile)
+		kill -TERM $pid
+		if test $slow -eq 0 ; then sleep .1 ; else sleep 1 ; fi
+		kill -KILL $pid 2>/dev/null || true
+		wait=0
+		while ps $pid > /dev/null && test $wait -le 10; do
+			sleep .5
+			wait=$(($wait + 1))
+		done
 	fi
 }
 
diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 0599f4d..2f7dc65 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -112,7 +112,7 @@ STACKTRACE() {
 
 	test "${LVM_TEST_PARALLEL:-0}" -eq 1 -o -n "$RUNNING_DMEVENTD" -o -f LOCAL_DMEVENTD || {
 		pgrep dmeventd &>/dev/null && \
-			die "** During test dmeventd has been started!"
+			die "ERROR: The test started dmeventd unexpectedly."
 	}
 
 	# Get backtraces from coredumps


