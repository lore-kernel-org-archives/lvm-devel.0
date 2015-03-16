From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Mar 2015 14:06:50 +0000 (UTC)
Subject: master - tests: add ""
Message-ID: <20150316140650.60F9B60F91@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ff5217f85079fa8cc969e0a81a66f1e1bd6490b5
Commit:        ff5217f85079fa8cc969e0a81a66f1e1bd6490b5
Parent:        36bcbeadd08adf83740e123a475b4a30f4d4c456
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 16 14:57:14 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 16 15:06:05 2015 +0100

tests: add ""

Add missing "" around 'devs' (since they could
theoritically constain spaces in its name - not
likely supported with udev these day but anyway....)
---
 test/shell/pvremove-warnings.sh |    4 +-
 test/shell/select-tools.sh      |   92 +++++++++++++++++++-------------------
 test/shell/system_id.sh         |    6 +-
 3 files changed, 51 insertions(+), 51 deletions(-)

diff --git a/test/shell/pvremove-warnings.sh b/test/shell/pvremove-warnings.sh
index 865a31e..c561483 100644
--- a/test/shell/pvremove-warnings.sh
+++ b/test/shell/pvremove-warnings.sh
@@ -16,6 +16,6 @@ pvremove "$dev1" "$dev2" 2>&1 | tee pvremove.txt
 not grep "No physical" pvremove.txt
 
 pvcreate "$dev1" "$dev2"
-vgcreate bla $dev1 $dev2
-pvremove -ff -y $dev1 $dev2 2>&1 | tee pvremove.txt
+vgcreate bla "$dev1" "$dev2"
+pvremove -ff -y "$dev1" "$dev2" 2>&1 | tee pvremove.txt
 not grep "device missing" pvremove.txt
diff --git a/test/shell/select-tools.sh b/test/shell/select-tools.sh
index 1738a45..d04ed0a 100644
--- a/test/shell/select-tools.sh
+++ b/test/shell/select-tools.sh
@@ -28,7 +28,7 @@ lvcreate -l1 -n "lv3" $vg2 "$dev3"
 # vg2/lv4 mapped onto dev3
 lvcreate -l1 -n "lv4" $vg2 "$dev3" "$dev4"
 
-# vg2/lv1 mapped onto $dev4 (same LV name as vg1/lv1)
+# vg2/lv1 mapped onto "$dev4" (same LV name as vg1/lv1)
 lvcreate -l1 -n "lv1" $vg2 "$dev4"
 
 ###########################################
@@ -63,7 +63,7 @@ check vg_field $vg2 vg_tags 105
 vgchange --deltag 105
 
 # select contains PVS field
-vgchange --addtag 106 -S "pv_name=$dev1"
+vgchange --addtag 106 -S "pv_name="$dev1""
 check vg_field $vg1 vg_tags 106
 not check vg_field $vg2 vg_tags 106
 vgchange --deltag 106
@@ -141,7 +141,7 @@ not check lv_field $vg2/lv1 lv_tags 204
 lvchange --deltag 204 $vg1 $vg2
 
 # select contains PVS field - COMBINATION NOT ALLOWED!
-lvchange --addtag 205 -S "pv_name=$dev1" 2>err
+lvchange --addtag 205 -S pv_name="$dev1" 2>err
 grep "Can't report LV and PV fields at the same time" err
 grep "Selection failed for LV" err
 not check lv_field $vg1/lv1 lv_tags 205
@@ -198,70 +198,70 @@ lvchange --deltag 210 --deltag tag $vg1 $vg2
 
 # select contains VGS field
 pvchange --addtag 301 -S "vg_name=$vg1"
-check pv_field $dev1 pv_tags 301
-check pv_field $dev2 pv_tags 301
-not check pv_field $dev3 pv_tags 301
-not check pv_field $dev4 pv_tags 301
+check pv_field "$dev1" pv_tags 301
+check pv_field "$dev2" pv_tags 301
+not check pv_field "$dev3" pv_tags 301
+not check pv_field "$dev4" pv_tags 301
 pvchange -a --deltag 301
 
 # select contains LVS field
 pvchange --addtag 302 -S "lv_name=lv2"
-check pv_field $dev1 pv_tags 302
-check pv_field $dev2 pv_tags 302
-not check pv_field $dev3 pv_tags 302
-not check pv_field $dev4 pv_tags 302
+check pv_field "$dev1" pv_tags 302
+check pv_field "$dev2" pv_tags 302
+not check pv_field "$dev3" pv_tags 302
+not check pv_field "$dev4" pv_tags 302
 pvchange -a --deltag 302
 
 # select contains SEGS field
 pvchange --addtag 303 -S "seg_start=8m"
-check pv_field $dev1 pv_tags 303
-not check pv_field $dev2 pv_tags 303
-not check pv_field $dev3 pv_tags 303
-not check pv_field $dev4 pv_tags 303
+check pv_field "$dev1" pv_tags 303
+not check pv_field "$dev2" pv_tags 303
+not check pv_field "$dev3" pv_tags 303
+not check pv_field "$dev4" pv_tags 303
 pvchange -a --deltag 303
 
 # select contains PVS field
-pvchange --addtag 304 -S "pv_name=$dev1"
-check pv_field $dev1 pv_tags 304
-not check pv_field $dev2 pv_tags 304
-not check pv_field $dev3 pv_tags 304
-not check pv_field $dev4 pv_tags 304
+pvchange --addtag 304 -S pv_name="$dev1"
+check pv_field "$dev1" pv_tags 304
+not check pv_field "$dev2" pv_tags 304
+not check pv_field "$dev3" pv_tags 304
+not check pv_field "$dev4" pv_tags 304
 pvchange -a --deltag 304
 
 # select contains PVSEGS field
 pvchange --addtag 305 -S "pvseg_size=2"
-not check pv_field $dev1 pv_tags 305
-check pv_field $dev2 pv_tags 305
-not check pv_field $dev3 pv_tags 305
-not check pv_field $dev4 pv_tags 305
+not check pv_field "$dev1" pv_tags 305
+check pv_field "$dev2" pv_tags 305
+not check pv_field "$dev3" pv_tags 305
+not check pv_field "$dev4" pv_tags 305
 pvchange -a --deltag 305
 
 # if PV name or tag is supplied together with the
 # selection, the result is an intersection of both
-pvchange --addtag 306 -S "pv_name=$dev1" $dev2
-not check pv_field $dev1 pv_tags 306
-not check pv_field $dev2 pv_tags 306
-not check pv_field $dev3 pv_tags 306
-not check pv_field $dev4 pv_tags 306
+pvchange --addtag 306 -S pv_name="$dev1" "$dev2"
+not check pv_field "$dev1" pv_tags 306
+not check pv_field "$dev2" pv_tags 306
+not check pv_field "$dev3" pv_tags 306
+not check pv_field "$dev4" pv_tags 306
 pvchange -a --deltag 306
-pvchange --addtag 307 -S "pv_name=$dev1" $dev1
-check pv_field $dev1 pv_tags 307
-not check pv_field $dev2 pv_tags 307
-not check pv_field $dev3 pv_tags 307
-not check pv_field $dev4 pv_tags 307
+pvchange --addtag 307 -S pv_name="$dev1" "$dev1"
+check pv_field "$dev1" pv_tags 307
+not check pv_field "$dev2" pv_tags 307
+not check pv_field "$dev3" pv_tags 307
+not check pv_field "$dev4" pv_tags 307
 pvchange -a --deltag 307
-pvchange --addtag "tag" $dev1
-pvchange --addtag 308 -S "pv_name=$dev2" @tag
-not check pv_field $dev1 pv_tags "308,tag"
-not check pv_field $dev2 pv_tags "308,tag"
-not check pv_field $dev3 pv_tags "308,tag"
-not check pv_field $dev4 pv_tags "308,tag"
-pvchange --deltag 308 $dev1
-pvchange --addtag 309 -S "pv_name=$dev1" @tag
-check pv_field $dev1 pv_tags "309,tag"
-not check pv_field $dev2 pv_tags "309,tag"
-not check pv_field $dev3 pv_tags "309,tag"
-not check pv_field $dev4 pv_tags "309,tag"
+pvchange --addtag "tag" "$dev1"
+pvchange --addtag 308 -S pv_name="$dev2" @tag
+not check pv_field "$dev1" pv_tags "308,tag"
+not check pv_field "$dev2" pv_tags "308,tag"
+not check pv_field "$dev3" pv_tags "308,tag"
+not check pv_field "$dev4" pv_tags "308,tag"
+pvchange --deltag 308 "$dev1"
+pvchange --addtag 309 -S pv_name="$dev1" @tag
+check pv_field "$dev1" pv_tags "309,tag"
+not check pv_field "$dev2" pv_tags "309,tag"
+not check pv_field "$dev3" pv_tags "309,tag"
+not check pv_field "$dev4" pv_tags "309,tag"
 pvchange -a --deltag 309 --deltag tag
 
 #########################
diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index 6aa367b..d866675 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -394,17 +394,17 @@ vgcreate $vg1 "$dev1"
 # normal pvs sees the vg and pv
 pvs >err
 grep $vg1 err
-grep $dev1 err
+grep "$dev1" err
 # change the local system_id, making the vg foreign
 echo "$SID2" > $SIDFILE
 # normal pvs does not see the vg or pv
 pvs >err
 not grep $vg1 err
-not grep $dev1 err
+not grep "$dev1" err
 # pvs --foreign does see the vg and pv
 pvs --foreign >err
 grep $vg1 err
-grep $dev1 err
+grep "$dev1" err
 # change the local system_id back so the vg can be removed
 echo "$SID1" > $SIDFILE
 vgremove $vg1


