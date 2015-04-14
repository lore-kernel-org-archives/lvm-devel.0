From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 14 Apr 2015 11:31:35 +0000 (UTC)
Subject: master - tests: update pvmove tests
Message-ID: <20150414113135.1FACE60D12@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d1a770107d9525c24fc17522be450e28e1463e45
Commit:        d1a770107d9525c24fc17522be450e28e1463e45
Parent:        75454c2b32c7f9dfd7c75a04ca2926fbf44ebb9e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 14 13:29:19 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 14 13:29:43 2015 +0200

tests: update pvmove tests

Put in pvmove background process into list quickly.
Update API for aux add_to_kill_list()/kill_listed_processes().
Run on 'background' (&) only non-background pvmoves.
---
 test/lib/aux.sh                |   24 ++++++++++++++----------
 test/shell/pvmove-abort-all.sh |   28 ++++++++++++++++++----------
 test/shell/pvmove-abort.sh     |   18 ++++++++++++------
 3 files changed, 44 insertions(+), 26 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 8e729a7..479c3f0 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -232,25 +232,29 @@ kill_sleep_kill_() {
 # $1 cmd line
 # $2 optional parms for pgrep
 add_to_kill_list() {
-	local p=$(pgrep $2 -f "$1" 2>/dev/null)
-	test -z $p || echo $p:$1 >> kill_list
-}
-
-kill_remaining_processes() {
-	local line
-	while read line; do
-		local pid=$(echo $line | awk -F':' '{ print $1 }')
-		local cmd=$(echo $line | awk -F':' '{ print $2 }')
+	local p=$(pgrep ${@:2} -f "$1" 2>/dev/null)
+	test -z "$p" || echo "$p:$1" >> kill_list
+}
+
+kill_listed_processes() {
+	local tmp
+	local pid
+	local cmd
+	test -f kill_list || return 0
+	while read tmp; do
+		pid=${tmp%%:*}
+		cmd=${tmp##*:}
 		for tmp in $(pgrep -f "$cmd" -d ' '); do
-			test $tmp = $pid && kill -9 $tmp
+			test "$tmp" = "$pid" && kill -9 "$tmp"
 		done
-	done
+	done < kill_list
+	rm -f kill_list
 }
 
 teardown() {
 	echo -n "## teardown..."
 
-	test -f kill_list && kill_remaining_processes < kill_list
+	kill_listed_processes
 
 	kill_sleep_kill_ LOCAL_LVMETAD ${LVM_VALGRIND_LVMETAD:-0}
 
diff --git a/test/shell/pvmove-abort-all.sh b/test/shell/pvmove-abort-all.sh
index 0fd9659..3166965 100644
--- a/test/shell/pvmove-abort-all.sh
+++ b/test/shell/pvmove-abort-all.sh
@@ -38,17 +38,26 @@ lvcreate -an -Zn -l30 -n $lv1 $vg1 "$dev4"
 lvextend -l+30 -n $vg1/$lv1 "$dev5"
 
 cmd1=$(echo pvmove -i1 $backgroundarg "$dev1" "$dev3" $mode)
-$cmd1 &
-aux wait_pvmove_lv_ready "$vg-pvmove0"
 cmd2=$(echo pvmove -i1 $backgroundarg "$dev2" "$dev3" $mode)
-$cmd2 &
-aux wait_pvmove_lv_ready "$vg-pvmove1"
-
-pvmove -i1 $backgroundarg -n $vg1/$lv1 "$dev4" "$dev6" $mode &
-aux wait_pvmove_lv_ready "$vg1-pvmove0"
+cmd3=$(echo pvmove -i1 $backgroundarg -n $vg1/$lv1 "$dev4" "$dev6" $mode)
+if test -z "$backgroundarg" ; then
+	$cmd1 &
+	aux wait_pvmove_lv_ready "$vg-pvmove0"
+	$cmd2 &
+	aux wait_pvmove_lv_ready "$vg-pvmove1"
+	$cmd3 &
+	aux wait_pvmove_lv_ready "$vg1-pvmove0"
+else
+	$cmd1
+	aux add_to_kill_list "$cmd1" -P 1
+	$cmd2
+	aux add_to_kill_list "$cmd2" -P 1
+	$cmd3
+	aux add_to_kill_list "$cmd3" -P 1
+fi
 
 # test removal of all pvmove LVs
-pvmove  --abort
+pvmove --abort
 
 # check if proper pvmove was canceled
 get lv_field $vg name -a | tee out
@@ -59,8 +68,7 @@ not grep "^\[pvmove" out
 lvremove -ff $vg $vg1
 
 wait
-aux add_to_kill_list "$cmd1" "-P 1"
-aux add_to_kill_list "$cmd2" "-P 1"
+aux kill_listed_processes
 done
 done
 
diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index da98a34..39360a0 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -32,11 +32,18 @@ lvcreate -an -Zn -l30 -n $lv1 $vg "$dev1"
 lvcreate -an -Zn -l30 -n $lv2 $vg "$dev2"
 
 cmd1=$(echo pvmove -i1 $backgroundarg "$dev1" "$dev3" $mode)
-$cmd1 &
-aux wait_pvmove_lv_ready "$vg-pvmove0"
 cmd2=$(echo pvmove -i1 $backgroundarg "$dev2" "$dev3" $mode)
-$cmd2 &
-aux wait_pvmove_lv_ready "$vg-pvmove1"
+if test -z "$backgroundarg" ; then
+	$cmd1 &
+	aux wait_pvmove_lv_ready "$vg-pvmove0"
+	$cmd2 &
+	aux wait_pvmove_lv_ready "$vg-pvmove1"
+else
+	$cmd1
+	aux add_to_kill_list "$cmd1" -P 1
+	$cmd2
+	aux add_to_kill_list "$cmd2" -P 1
+fi
 
 # remove specific device
 pvmove --abort "$dev1"
@@ -52,8 +59,7 @@ pvmove --abort
 lvremove -ff $vg
 
 wait
-aux add_to_kill_list "$cmd1" "-P 1"
-aux add_to_kill_list "$cmd2" "-P 1"
+aux kill_listed_processes
 done
 done
 


