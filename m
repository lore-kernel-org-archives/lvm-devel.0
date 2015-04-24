From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Apr 2015 22:42:23 +0000 (UTC)
Subject: master - tests: add double quotes around add_to_kill_list parms
Message-ID: <20150424224223.0887D60F5F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d9176782feab130c3e94030f64bf67ca25f41e11
Commit:        d9176782feab130c3e94030f64bf67ca25f41e11
Parent:        d7888e83169ac1a7a962ffd66502995792879244
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri Apr 24 11:42:26 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Apr 25 00:40:02 2015 +0200

tests: add double quotes around add_to_kill_list parms

---
 test/shell/pvmove-abort-all.sh |    6 +++---
 test/shell/pvmove-abort.sh     |    4 ++--
 test/shell/pvmove-basic.sh     |    6 +++---
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/test/shell/pvmove-abort-all.sh b/test/shell/pvmove-abort-all.sh
index 0398c75..de6d8c9 100644
--- a/test/shell/pvmove-abort-all.sh
+++ b/test/shell/pvmove-abort-all.sh
@@ -51,11 +51,11 @@ if test -z "$backgroundarg" ; then
         lvs -a $vg $vg1
 else
 	"${cmd1[@]}"
-	aux add_to_kill_list ${cmd1[*]} -P 1
+	aux add_to_kill_list "${cmd1[*]}" -P 1
 	"${cmd2[@]}"
-	aux add_to_kill_list ${cmd2[*]} -P 1
+	aux add_to_kill_list "${cmd2[*]}" -P 1
 	"${cmd3[@]}"
-	aux add_to_kill_list ${cmd3[*]} -P 1
+	aux add_to_kill_list "${cmd3[*]}" -P 1
 fi
 
 # test removal of all pvmove LVs
diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index 72f6f96..3165c6f 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -41,9 +41,9 @@ if test -z "$backgroundarg" ; then
 	aux wait_pvmove_lv_ready "$vg-pvmove1"
 else
 	"${cmd1[@]}"
-	aux add_to_kill_list ${cmd1[*]} -P 1
+	aux add_to_kill_list "${cmd1[*]}" -P 1
 	"${cmd2[@]}"
-	aux add_to_kill_list ${cmd2[*]} -P 1
+	aux add_to_kill_list "${cmd2[*]}" -P 1
 fi
 
 # remove specific device
diff --git a/test/shell/pvmove-basic.sh b/test/shell/pvmove-basic.sh
index e93a04e..d5b7845 100644
--- a/test/shell/pvmove-basic.sh
+++ b/test/shell/pvmove-basic.sh
@@ -334,9 +334,9 @@ check_and_cleanup_lvs_
 
 #COMM "pvmove abort"
 restore_lvs_
-cmd=$(echo -n pvmove $mode -i100 -b "$dev1" "$dev3")
-$cmd
-aux add_to_kill_list "$cmd" "-P 1"
+cmd=(pvmove $mode -i100 -b "$dev1" "$dev3")
+"${cmd[@]}"
+aux add_to_kill_list "${cmd[*]}" -P 1
 pvmove --abort
 check_and_cleanup_lvs_
 


