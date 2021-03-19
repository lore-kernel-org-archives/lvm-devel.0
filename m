From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 19 Mar 2021 23:17:21 +0000 (GMT)
Subject: main - tests: copy more data
Message-ID: <20210319231721.7D4A7385783D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ed90a3d9b4247130794ed515b9547e9b4dbbf2dc
Commit:        ed90a3d9b4247130794ed515b9547e9b4dbbf2dc
Parent:        fe3ef6867fc585a26bf9950f66b4f190993f457c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 19 00:52:06 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 20 00:05:01 2021 +0100

tests: copy more data

Give pvmove --abort bigger aborting window.
---
 test/shell/pvmove-abort.sh | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index 14457991c..f5744d430 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -22,7 +22,7 @@ aux target_at_least dm-mirror 1 10 0 || skip
 # Throttle mirroring
 aux throttle_dm_mirror || skip
 
-aux prepare_pvs 3 60
+aux prepare_pvs 3 90
 
 vgcreate -s 512k $vg "$dev1" "$dev2"
 pvcreate --metadatacopies 0 "$dev3"
@@ -34,8 +34,8 @@ for backgroundarg in "-b" "" ;
 do
 
 # Create multisegment LV
-lvcreate -an -Zn -l40 -n $lv1 $vg "$dev1"
-lvcreate -an -Zn -l50 -n $lv2 $vg "$dev2"
+lvcreate -an -Zn -l60 -n $lv1 $vg "$dev1"
+lvcreate -an -Zn -l80 -n $lv2 $vg "$dev2"
 
 cmd1=(pvmove -i1 $backgroundarg $mode "$dev1" "$dev3")
 cmd2=(pvmove -i1 $backgroundarg $mode "$dev2" "$dev3")


