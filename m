From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Mar 2014 09:31:58 +0000 (UTC)
Subject: master - tests: use check lv_tree_on
Message-ID: <20140318093158.9132960DDE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aed36c12f8ceb55d3290519215adecc03d54978e
Commit:        aed36c12f8ceb55d3290519215adecc03d54978e
Parent:        81166a84be44409ab326eb1c4760cb32a9aee0fe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 18 10:26:42 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 18 10:28:09 2014 +0100

tests: use check lv_tree_on

Use internal /lib function.
Reduce extent size for test to create smaller devices.
---
 test/shell/lvresize-raid.sh |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvresize-raid.sh b/test/shell/lvresize-raid.sh
index 6908635..9b9218d 100644
--- a/test/shell/lvresize-raid.sh
+++ b/test/shell/lvresize-raid.sh
@@ -13,7 +13,9 @@
 
 aux target_at_least dm-raid 1 1 0 || skip
 
-aux prepare_vg 6 80
+aux prepare_pvs 6 80
+
+vgcreate -s 256K $vg $(cat DEVICES)
 
 for deactivate in true false; do
 
@@ -50,6 +52,6 @@ done
 # Ensure extend is contiguous
 lvcreate --type raid4 -l 2 -i 2 -n $lv1 $vg $dev4 $dev5 $dev6
 lvextend -l +2 --alloc contiguous $vg/$lv1
-not $(lvs -a -o devices $vg | egrep "$dev1|$dev2|$dev3")
-lvremove -ff $vg
+check lv_tree_on $vg $lv1 "$dev4" "$dev5" "$dev6"
 
+vgremove -f $vg


