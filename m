From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  3 Apr 2015 12:55:34 +0000 (UTC)
Subject: master - tests: delay only data area
Message-ID: <20150403125534.5083B610FF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ce3c61c4af4622674d8ebd4301d4fd24c4cb8886
Commit:        ce3c61c4af4622674d8ebd4301d4fd24c4cb8886
Parent:        385457de236022b3afb1cc20cd99445a59340831
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 3 14:39:05 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 3 14:54:22 2015 +0200

tests: delay only data area

---
 test/shell/pvmove-abort-all.sh |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/test/shell/pvmove-abort-all.sh b/test/shell/pvmove-abort-all.sh
index 3b561eb..cf0985d 100644
--- a/test/shell/pvmove-abort-all.sh
+++ b/test/shell/pvmove-abort-all.sh
@@ -34,18 +34,16 @@ lvcreate -an -Zn -l30 -n $lv1 $vg1 "$dev4"
 lvextend -l+30 -n $vg1/$lv1 "$dev5"
 
 # Slowdown writes
-aux delay_dev "$dev3" 0 300
-aux delay_dev "$dev6" 0 300
+aux delay_dev "$dev3" 100 100 $(get first_extent_sector "$dev3"):
+aux delay_dev "$dev6" 100 100 $(get first_extent_sector "$dev6"):
 
 pvmove -i1 $backgroundarg "$dev1" "$dev3" $mode &
 aux wait_pvmove_lv_ready "$vg-pvmove0" 300
 pvmove -i1 $backgroundarg "$dev2" "$dev3" $mode &
 aux wait_pvmove_lv_ready "$vg-pvmove1" 300
-aux delay_dev "$dev3" 0 1000
 
 pvmove -i1 $backgroundarg -n $vg1/$lv1 "$dev4" "$dev6" $mode &
 aux wait_pvmove_lv_ready "$vg1-pvmove0" 300
-aux delay_dev "$dev6" 0 1000
 
 # test removal of all pvmove LVs
 pvmove  --abort
@@ -60,12 +58,10 @@ not grep "^\[pvmove" out
 aux enable_dev "$dev3"
 aux enable_dev "$dev6"
 
-lvremove -ff $vg
-lvremove -ff $vg1
+lvremove -ff $vg $vg1
 
 wait
 done
 done
 
-vgremove -ff $vg
-vgremove -ff $vg1
+vgremove -ff $vg $vg1


