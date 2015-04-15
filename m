From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 15 Apr 2015 11:38:15 +0000 (UTC)
Subject: master - tests: preserve "" around dev
Message-ID: <20150415113815.764DC60612@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f5466fe43597bfacb7fc70e0a61d569b6c5198c4
Commit:        f5466fe43597bfacb7fc70e0a61d569b6c5198c4
Parent:        1a814af46b6c8163c6b9b60932f9d700583914b0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 14 14:15:52 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 15 13:35:42 2015 +0200

tests: preserve "" around dev

---
 test/shell/pvmove-abort-all.sh |    7 ++++---
 test/shell/pvmove-abort.sh     |    5 +++--
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/test/shell/pvmove-abort-all.sh b/test/shell/pvmove-abort-all.sh
index 3166965..e6e65e5 100644
--- a/test/shell/pvmove-abort-all.sh
+++ b/test/shell/pvmove-abort-all.sh
@@ -37,9 +37,10 @@ lvcreate -an -Zn -l30 -n $lv2 $vg "$dev2"
 lvcreate -an -Zn -l30 -n $lv1 $vg1 "$dev4"
 lvextend -l+30 -n $vg1/$lv1 "$dev5"
 
-cmd1=$(echo pvmove -i1 $backgroundarg "$dev1" "$dev3" $mode)
-cmd2=$(echo pvmove -i1 $backgroundarg "$dev2" "$dev3" $mode)
-cmd3=$(echo pvmove -i1 $backgroundarg -n $vg1/$lv1 "$dev4" "$dev6" $mode)
+cmd1="pvmove -i1 $backgroundarg \"$dev1\" \"$dev3\" $mode"
+cmd2="pvmove -i1 $backgroundarg \"$dev2\" \"$dev3\" $mode"
+cmd3="pvmove -i1 $backgroundarg -n $vg1/$lv1 \"$dev4\" \"$dev6\" $mode"
+
 if test -z "$backgroundarg" ; then
 	$cmd1 &
 	aux wait_pvmove_lv_ready "$vg-pvmove0"
diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index 39360a0..2c32f32 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -31,8 +31,9 @@ do
 lvcreate -an -Zn -l30 -n $lv1 $vg "$dev1"
 lvcreate -an -Zn -l30 -n $lv2 $vg "$dev2"
 
-cmd1=$(echo pvmove -i1 $backgroundarg "$dev1" "$dev3" $mode)
-cmd2=$(echo pvmove -i1 $backgroundarg "$dev2" "$dev3" $mode)
+cmd1="pvmove -i1 $backgroundarg \"$dev1\" \"$dev3\" $mode"
+cmd2="pvmove -i1 $backgroundarg \"$dev2\" \"$dev3\" $mode"
+
 if test -z "$backgroundarg" ; then
 	$cmd1 &
 	aux wait_pvmove_lv_ready "$vg-pvmove0"


