From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  1 May 2015 13:08:35 +0000 (UTC)
Subject: master - tests: rename kill_tagged_processes
Message-ID: <20150501130835.E590F60366@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=16e8006eb05a3fd18d1efeb58f79ffbb41ba61e2
Commit:        16e8006eb05a3fd18d1efeb58f79ffbb41ba61e2
Parent:        c18e969e30a44ec392f40414e1f134ff70cecb38
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 30 18:42:31 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 1 15:07:58 2015 +0200

tests: rename kill_tagged_processes

Better name for aux function.
First use normal -TERM, and only after a while use -KILL
(leaving some time to correctly finish)
Print INFO about killed processes.
---
 test/lib/aux.sh                      |   31 +++++++++++++++++++++++++------
 test/shell/pvmove-abort-all.sh       |    2 +-
 test/shell/pvmove-abort.sh           |    2 +-
 test/shell/pvmove-restart.sh         |    2 +-
 test/shell/pvmove-resume-1.sh        |    2 +-
 test/shell/pvmove-resume-2.sh        |    2 +-
 test/shell/pvmove-resume-multiseg.sh |    2 +-
 7 files changed, 31 insertions(+), 12 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index e20b6b0..716d596 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -233,17 +233,36 @@ kill_sleep_kill_() {
 }
 
 print_procs_by_tag_() {
-	ps -o pid=,args= ehax 2>/dev/null | grep -weLVM_TEST_TAG=${1:-kill_me_$PREFIX} 2>/dev/null || true
+	(ps -o pid,args ehax | grep -we"LVM_TEST_TAG=${1:-kill_me_$PREFIX}") || true
 }
 
 count_processes_with_tag() {
 	print_procs_by_tag_ | wc -l
 }
 
-kill_listed_processes() {
-	while read pid b; do
-		test -z "$pid" || kill -9 $pid
-	done <<< $(print_procs_by_tag_ $@)
+kill_tagged_processes() {
+	local pid
+	local pids
+	local wait
+
+	# read uses all vars within pipe subshell
+	print_procs_by_tag_ "$@" | while read -r pid wait; do
+		if test -n "$pid" ; then
+			echo "Killing tagged process: $pid ${wait:0:120}..."
+			kill -TERM $pid 2>/dev/null || true
+		fi
+		pids="$pids $pid"
+	done
+
+	# wait if process exited and eventually -KILL
+	wait=0
+	for pid in $pids ; do
+		while ps $pid > /dev/null && test $wait -le 10; do
+			sleep .2
+			wait=$(($wait + 1))
+		done
+		test $wait -le 10 || kill -KILL $pid 2>/dev/null || true
+	done
 }
 
 teardown() {
@@ -252,7 +271,7 @@ teardown() {
 
 	if test -f TESTNAME ; then
 
-	kill_listed_processes
+	kill_tagged_processes
 
 	kill_sleep_kill_ LOCAL_LVMETAD ${LVM_VALGRIND_LVMETAD:-0}
 
diff --git a/test/shell/pvmove-abort-all.sh b/test/shell/pvmove-abort-all.sh
index 5bca8a2..da43da6 100644
--- a/test/shell/pvmove-abort-all.sh
+++ b/test/shell/pvmove-abort-all.sh
@@ -67,7 +67,7 @@ not grep "^\[pvmove" out
 lvremove -ff $vg $vg1
 
 wait
-aux kill_listed_processes
+aux kill_tagged_processes
 done
 done
 
diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index 2332521..6b807ac 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -58,7 +58,7 @@ pvmove --abort
 lvremove -ff $vg
 
 wait
-aux kill_listed_processes
+aux kill_tagged_processes
 done
 done
 
diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index b91f624..1496b35 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -90,7 +90,7 @@ pvmove --abort
 lvs -a -o+devices $vg
 
 lvremove -ff $vg
-aux kill_listed_processes
+aux kill_tagged_processes
 done
 
 # Restore delayed device back
diff --git a/test/shell/pvmove-resume-1.sh b/test/shell/pvmove-resume-1.sh
index 9825e76..acf35ee 100644
--- a/test/shell/pvmove-resume-1.sh
+++ b/test/shell/pvmove-resume-1.sh
@@ -98,7 +98,7 @@ test_pvmove_resume() {
 		i=$((i + 1))
 	done
 
-	aux kill_listed_processes
+	aux kill_tagged_processes
 
 	lvremove -ff $vg $vg1
 }
diff --git a/test/shell/pvmove-resume-2.sh b/test/shell/pvmove-resume-2.sh
index dee82cc..37a552d 100644
--- a/test/shell/pvmove-resume-2.sh
+++ b/test/shell/pvmove-resume-2.sh
@@ -80,7 +80,7 @@ test_pvmove_resume() {
 		i=$((i + 1))
 	done
 
-	aux kill_listed_processes
+	aux kill_tagged_processes
 
 	lvremove -ff $vg
 }
diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index d70662d..be21d56 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -92,7 +92,7 @@ test_pvmove_resume() {
 		i=$((i + 1))
 	done
 
-	aux kill_listed_processes
+	aux kill_tagged_processes
 
 	lvremove -ff $vg
 }


