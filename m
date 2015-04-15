From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 15 Apr 2015 13:10:50 +0000 (UTC)
Subject: master - tests: shell-fu
Message-ID: <20150415131050.774A1610C8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=191f3cf52a0ada3aba9ac340cbab464fb05efe89
Commit:        191f3cf52a0ada3aba9ac340cbab464fb05efe89
Parent:        43a6f9e726295eaf200e7acb19d7e35b0af4aabb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 15 15:07:49 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 15 15:09:45 2015 +0200

tests: shell-fu

Preserve quotes for devs and use  shell arrays to pass things around.
---
 test/shell/pvmove-abort-all.sh |   25 +++++++++++++------------
 test/shell/pvmove-abort.sh     |   16 ++++++++--------
 2 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/test/shell/pvmove-abort-all.sh b/test/shell/pvmove-abort-all.sh
index e6e65e5..0398c75 100644
--- a/test/shell/pvmove-abort-all.sh
+++ b/test/shell/pvmove-abort-all.sh
@@ -37,24 +37,25 @@ lvcreate -an -Zn -l30 -n $lv2 $vg "$dev2"
 lvcreate -an -Zn -l30 -n $lv1 $vg1 "$dev4"
 lvextend -l+30 -n $vg1/$lv1 "$dev5"
 
-cmd1="pvmove -i1 $backgroundarg \"$dev1\" \"$dev3\" $mode"
-cmd2="pvmove -i1 $backgroundarg \"$dev2\" \"$dev3\" $mode"
-cmd3="pvmove -i1 $backgroundarg -n $vg1/$lv1 \"$dev4\" \"$dev6\" $mode"
+cmd1=(pvmove -i1 $backgroundarg $mode "$dev1" "$dev3")
+cmd2=(pvmove -i1 $backgroundarg $mode "$dev2" "$dev3")
+cmd3=(pvmove -i1 $backgroundarg $mode -n $vg1/$lv1 "$dev4" "$dev6")
 
 if test -z "$backgroundarg" ; then
-	$cmd1 &
+	"${cmd1[@]}" &
 	aux wait_pvmove_lv_ready "$vg-pvmove0"
-	$cmd2 &
+	"${cmd2[@]}" &
 	aux wait_pvmove_lv_ready "$vg-pvmove1"
-	$cmd3 &
+	"${cmd3[@]}" &
 	aux wait_pvmove_lv_ready "$vg1-pvmove0"
+        lvs -a $vg $vg1
 else
-	$cmd1
-	aux add_to_kill_list "$cmd1" -P 1
-	$cmd2
-	aux add_to_kill_list "$cmd2" -P 1
-	$cmd3
-	aux add_to_kill_list "$cmd3" -P 1
+	"${cmd1[@]}"
+	aux add_to_kill_list ${cmd1[*]} -P 1
+	"${cmd2[@]}"
+	aux add_to_kill_list ${cmd2[*]} -P 1
+	"${cmd3[@]}"
+	aux add_to_kill_list ${cmd3[*]} -P 1
 fi
 
 # test removal of all pvmove LVs
diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index 2c32f32..3417e77 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -31,19 +31,19 @@ do
 lvcreate -an -Zn -l30 -n $lv1 $vg "$dev1"
 lvcreate -an -Zn -l30 -n $lv2 $vg "$dev2"
 
-cmd1="pvmove -i1 $backgroundarg \"$dev1\" \"$dev3\" $mode"
-cmd2="pvmove -i1 $backgroundarg \"$dev2\" \"$dev3\" $mode"
+cmd1=(pvmove -i1 $backgroundarg $mode "$dev1" "$dev3")
+cmd2=(pvmove -i1 $backgroundarg $mode "$dev2" "$dev3")
 
 if test -z "$backgroundarg" ; then
-	$cmd1 &
+	"${cmd1[@]}" &
 	aux wait_pvmove_lv_ready "$vg-pvmove0"
-	$cmd2 &
+	"${cmd2[@]}" &
 	aux wait_pvmove_lv_ready "$vg-pvmove1"
 else
-	$cmd1
-	aux add_to_kill_list "$cmd1" -P 1
-	$cmd2
-	aux add_to_kill_list "$cmd2" -P 1
+	"${cmd1[@]}"
+	aux add_to_kill_list ${cmd1[*]} -P 1
+	"${cmd2[@]}"
+	aux add_to_kill_list ${cmd2[*]} -P 1
 fi
 
 # remove specific device


