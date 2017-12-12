From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 12 Dec 2017 07:17:25 -0500
Subject: master - test: lvmdbusd is used for process name
Message-ID: <201712121217.vBCCHPpW003864@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2f4c2a43d49d90875ea31b1507cd0dfcdb049e88
Commit:        2f4c2a43d49d90875ea31b1507cd0dfcdb049e88
Parent:        b76c6951aa5c41b19fc34342ea2e946d7e0a3d24
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Dec 12 12:14:15 2017 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Dec 12 13:17:07 2017 +0100

test: lvmdbusd is used for process name

lvmdbusd was started, but the process was not recognized by pgrep.

- configure does not make the script executable - set the flag
  explicitly when running make check,
- process name changed to lvmdbusd. The previous python3 value
  originated from the use of /usr/bin/env.
---
 test/lib/aux.sh |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index de63167..a436f84 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -318,7 +318,7 @@ prepare_lvmdbusd() {
 
         # FIXME: This is not correct! Daemon is auto started.
 	echo -n "## checking lvmdbusd is NOT running..."
-	if pgrep -f -l lvmdbusd | grep python3 ; then
+	if pgrep -f -l lvmdbusd | grep python3 || pgrep -x -l lvmdbusd ; then
 		skip "Cannot run lvmdbusd while existing lvmdbusd process exists"
 	fi
 	echo ok
@@ -327,6 +327,10 @@ prepare_lvmdbusd() {
 	if test -z "${installed_testsuite+varset}"; then
 		# NOTE: this is always present - additional checks are needed:
 		daemon="$abs_top_builddir/daemons/lvmdbusd/lvmdbusd"
+		if ! test -x "$daemon" && chmod ugo+x "$daemon"; then
+			echo "Failed to make '$daemon' executable">&2
+			return 1
+		fi
 		# Setup the python path so we can run
 		export PYTHONPATH="$abs_top_builddir/daemons"
 	else
@@ -351,12 +355,9 @@ prepare_lvmdbusd() {
 
 	sleep 1
 	echo -n "## checking lvmdbusd IS running..."
-	if ! pgrep -f -l lvmdbusd | grep python3; then
-		echo "Failed to start lvmdbusd daemon"
-		return 1
-	fi
+	comm=
 	# TODO: Is there a better check than wait 1 second and check pid?
-	if ! ps -p $pid -o comm= >/dev/null || [[ $(ps -p $pid -o comm=) != python3 ]]; then
+	if ! comm=$(ps -p $pid -o comm=) >/dev/null || [[ $comm != lvmdbusd ]]; then
 		echo "Failed to start lvmdbusd daemon"
 		return 1
 	fi


