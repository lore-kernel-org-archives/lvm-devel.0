From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:12:12 +0000 (GMT)
Subject: stable-2.02 - tests: a bit bigger mirrors
Message-ID: <20201016191212.A78EE396EC8E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e05c882ab5a2ef55ff86fc326f845220c34504b0
Commit:        e05c882ab5a2ef55ff86fc326f845220c34504b0
Parent:        d76b5f43083cd0667c3f55b5dd72edd134144a3d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 23 14:06:19 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 18:09:55 2020 +0200

tests: a bit bigger mirrors

Seems even with throttling we occasinally need slightly more.
---
 test/shell/lvconvert-mirror.sh | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 87993dab1..0456f62f8 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -324,7 +324,7 @@ SHOULD=
 aux throttle_dm_mirror || SHOULD=should
 
 # Use large enough mirror that takes time to sychronize with small regionsize
-lvcreate -aey -L20 -Zn -Wn --type mirror --regionsize 16k -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:$DEVRANGE"
+lvcreate -aey -L30 -Zn -Wn --type mirror --regionsize 16k -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:$DEVRANGE"
 $SHOULD not lvconvert -m-1 $vg/$lv1 "$dev1" 2>&1 | tee out
 aux restore_dm_mirror
 grep "not in-sync" out
@@ -342,7 +342,7 @@ lvremove -ff $vg
 aux throttle_dm_mirror || :
 # No parallel lvconverts on a single LV please
 # Use big enough mirror size and small regionsize to run on all test machines succesfully
-lvcreate -aey -Zn -Wn -L20 --type mirror --regionsize 16k -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-8"
+lvcreate -aey -Zn -Wn -L30 --type mirror --regionsize 16k -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-8"
 check mirror $vg $lv1
 check mirror_legs $vg $lv1 2
 


