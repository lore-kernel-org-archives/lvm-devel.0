From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  3 Apr 2015 15:18:37 +0000 (UTC)
Subject: master - tests: delay only data portion of device
Message-ID: <20150403151837.C610660AAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c88ffbf9dfab5c636b45c51fda6ecf1e6f270b85
Commit:        c88ffbf9dfab5c636b45c51fda6ecf1e6f270b85
Parent:        93ab6d51844352d8680d62e68da7973c4bf98346
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 3 16:39:19 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 3 17:18:11 2015 +0200

tests: delay only data portion of device

---
 test/shell/pvmove-restart.sh |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index ca26779..9426d52 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -29,7 +29,8 @@ lvextend -l+5 $vg/$lv1 "$dev1"
 lvextend -l+10 $vg/$lv1 "$dev2"
 
 # Slowdown writes
-aux delay_dev "$dev3" 0 200
+# (FIXME: generates interesting race when not used)
+aux delay_dev "$dev3" 100 100 $(get first_extent_sector "$dev3"):
 
 pvmove -i0 -n $vg/$lv1 "$dev1" "$dev3" $mode &
 PVMOVE=$!
@@ -44,6 +45,8 @@ wait
 # First take down $lv1 then it's pvmove0
 while dmsetup status "$vg-$lv1"; do dmsetup remove "$vg-$lv1" || true; done
 while dmsetup status "$vg-pvmove0"; do dmsetup remove "$vg-pvmove0" || true; done
+while dmsetup status "$vg-pvmove0_mimage_1"; do dmsetup remove "$vg-pvmove0_mimage_1" || true; done
+dmsetup table
 
 # Check we really have pvmove volume
 check lv_attr_bit type $vg/pvmove0 "p"
@@ -77,8 +80,10 @@ dmsetup table
 # Restart pvmove
 # use exclusive activation to have usable pvmove without cmirrord
 vgchange -aey $vg
-#sleep 2
-#pvmove
+aux wait_pvmove_lv_ready "$vg-pvmove0" 300
+dmsetup table
+
+pvmove --abort
 
 pvmove --abort
 


