From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 23 Sep 2020 12:59:35 +0000 (GMT)
Subject: master - tests: a bit bigger mirrors
Message-ID: <20200923125935.93566398E478@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cfc4dd4c7cb39354525866c9cd1b3c6442a6f558
Commit:        cfc4dd4c7cb39354525866c9cd1b3c6442a6f558
Parent:        90c50c1b537dd89b62dad3047e27420d411293f5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 23 14:06:19 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 23 14:47:30 2020 +0200

tests: a bit bigger mirrors

Seems even with throttling we occasinally need slightly more.
---
 test/shell/lvconvert-mirror.sh | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 7cf498de4..160b086f6 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -323,7 +323,7 @@ SHOULD=
 aux throttle_dm_mirror || SHOULD=should
 
 # Use large enough mirror that takes time to sychronize with small regionsize
-lvcreate -aey -L20 -Zn -Wn --type mirror --regionsize 16k -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:$DEVRANGE"
+lvcreate -aey -L30 -Zn -Wn --type mirror --regionsize 16k -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:$DEVRANGE"
 $SHOULD not lvconvert -m-1 $vg/$lv1 "$dev1" 2>&1 | tee out
 aux restore_dm_mirror
 grep "not in-sync" out
@@ -341,7 +341,7 @@ lvremove -ff $vg
 aux throttle_dm_mirror || :
 # No parallel lvconverts on a single LV please
 # Use big enough mirror size and small regionsize to run on all test machines succesfully
-lvcreate -aey -Zn -Wn -L20 --type mirror --regionsize 16k -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-8"
+lvcreate -aey -Zn -Wn -L30 --type mirror --regionsize 16k -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-8"
 check mirror $vg $lv1
 check mirror_legs $vg $lv1 2
 


