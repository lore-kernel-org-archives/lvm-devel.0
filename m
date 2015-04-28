From: okozina <okozina@fedoraproject.org>
Date: Tue, 28 Apr 2015 20:32:48 +0000 (UTC)
Subject: master - tests: simplify removal of dangling bg procs
Message-ID: <20150428203248.4843F61383@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8c9ab2a4dd827b575a7a8b501c5ca3474508f964
Commit:        8c9ab2a4dd827b575a7a8b501c5ca3474508f964
Parent:        3f0434057b8b77efd63fe0c502a962bc9dd13223
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Mon Apr 27 10:33:45 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Apr 28 22:31:40 2015 +0200

tests: simplify removal of dangling bg procs

some tests left dangling bg processes originating in
lvm2 commands being able to spawn any bg polling process
(lvchange, vgchange, pvmove, lvconvert...)

Initial fn 'add_to_kill_list' should collect processes with
specific parameters (proc's command line and parent processes ID).
After testing finishes the fn kill_listed_processes should remove these
listed by 'add_to_kill_list'.

Unfortunately it proved to be prone to an error especially in scenarios
where cmd line of initiating command contained characters required to
be espaced before passing to shell script to make it work correctly.
(Or if cmd spawned more than one bg process with same cmd line. i.e.:
vgchange or lvchange).

The new implementation is much simpler. It uses env. variable (LVM_TEST_TAG)
for marking a process desired to be killed later or during test env. teardown.
(i.e.: LVM_TEST_TAG=kill_me_$PREFIX to kill only processes related to
current test environment)
---
 test/lib/aux.sh                |   26 +++++++++-----------------
 test/shell/pvmove-abort-all.sh |    9 +++------
 test/shell/pvmove-abort.sh     |    6 ++----
 test/shell/pvmove-basic.sh     |    4 +---
 test/shell/pvmove-restart.sh   |    3 ++-
 5 files changed, 17 insertions(+), 31 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 0e59d6e..24be323 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -233,26 +233,18 @@ kill_sleep_kill_() {
 	fi
 }
 
-# $1 cmd line
-# $2 optional parms for pgrep
-add_to_kill_list() {
-	local p=$(pgrep ${@:2} -f "$1" 2>/dev/null)
-	test -z "$p" || echo "$p:$1" >> kill_list
+print_procs_by_tag_() {
+	ps -o pid=,args= ehax 2>/dev/null | grep -weLVM_TEST_TAG=${1:-kill_me_$PREFIX} 2>/dev/null || true
+}
+
+count_processes_with_tag() {
+	print_procs_by_tag_ | wc -l
 }
 
 kill_listed_processes() {
-	local tmp
-	local pid
-	local cmd
-	test -f kill_list || return 0
-	while read tmp; do
-		pid=${tmp%%:*}
-		cmd=${tmp##*:}
-		for tmp in $(pgrep -f "$cmd" -d ' '); do
-			test "$tmp" = "$pid" && kill -9 "$tmp"
-		done
-	done < kill_list
-	rm -f kill_list
+	while read pid b; do
+		test -z "$pid" || kill -9 $pid
+	done <<< $(print_procs_by_tag_ $@)
 }
 
 teardown() {
diff --git a/test/shell/pvmove-abort-all.sh b/test/shell/pvmove-abort-all.sh
index de6d8c9..5bca8a2 100644
--- a/test/shell/pvmove-abort-all.sh
+++ b/test/shell/pvmove-abort-all.sh
@@ -50,12 +50,9 @@ if test -z "$backgroundarg" ; then
 	aux wait_pvmove_lv_ready "$vg1-pvmove0"
         lvs -a $vg $vg1
 else
-	"${cmd1[@]}"
-	aux add_to_kill_list "${cmd1[*]}" -P 1
-	"${cmd2[@]}"
-	aux add_to_kill_list "${cmd2[*]}" -P 1
-	"${cmd3[@]}"
-	aux add_to_kill_list "${cmd3[*]}" -P 1
+	LVM_TEST_TAG="kill_me_$PREFIX" "${cmd1[@]}"
+	LVM_TEST_TAG="kill_me_$PREFIX" "${cmd2[@]}"
+	LVM_TEST_TAG="kill_me_$PREFIX" "${cmd3[@]}"
 fi
 
 # test removal of all pvmove LVs
diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index 3165c6f..2332521 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -40,10 +40,8 @@ if test -z "$backgroundarg" ; then
 	"${cmd2[@]}" &
 	aux wait_pvmove_lv_ready "$vg-pvmove1"
 else
-	"${cmd1[@]}"
-	aux add_to_kill_list "${cmd1[*]}" -P 1
-	"${cmd2[@]}"
-	aux add_to_kill_list "${cmd2[*]}" -P 1
+	LVM_TEST_TAG="kill_me_$PREFIX" "${cmd1[@]}"
+	LVM_TEST_TAG="kill_me_$PREFIX" "${cmd2[@]}"
 fi
 
 # remove specific device
diff --git a/test/shell/pvmove-basic.sh b/test/shell/pvmove-basic.sh
index d5b7845..f7830da 100644
--- a/test/shell/pvmove-basic.sh
+++ b/test/shell/pvmove-basic.sh
@@ -334,9 +334,7 @@ check_and_cleanup_lvs_
 
 #COMM "pvmove abort"
 restore_lvs_
-cmd=(pvmove $mode -i100 -b "$dev1" "$dev3")
-"${cmd[@]}"
-aux add_to_kill_list "${cmd[*]}" -P 1
+LVM_TEST_TAG="kill_me_$PREFIX" pvmove $mode -i100 -b "$dev1" "$dev3"
 pvmove --abort
 check_and_cleanup_lvs_
 
diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index 88dfebe..b91f624 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -79,7 +79,7 @@ dmsetup table
 
 # Restart pvmove
 # use exclusive activation to have usable pvmove without cmirrord
-vgchange -aey $vg
+LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey $vg
 aux wait_pvmove_lv_ready "$vg-pvmove0"
 dmsetup table
 
@@ -90,6 +90,7 @@ pvmove --abort
 lvs -a -o+devices $vg
 
 lvremove -ff $vg
+aux kill_listed_processes
 done
 
 # Restore delayed device back


