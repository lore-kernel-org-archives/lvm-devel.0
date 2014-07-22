From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 22 Jul 2014 21:44:14 +0000 (UTC)
Subject: master - tests: use exclusive activation
Message-ID: <20140722214414.16A3C61125@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3a8bb8d3a4ef379298e97ca5f087a1c8908841ed
Commit:        3a8bb8d3a4ef379298e97ca5f087a1c8908841ed
Parent:        ab1887fe4719a296c2bd4b4778348f55f1b7a49a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 22 23:43:26 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 22 23:44:06 2014 +0200

tests: use exclusive activation

---
 test/shell/lvconvert-raid-allocation.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-raid-allocation.sh b/test/shell/lvconvert-raid-allocation.sh
index aef786c..bd2cab5 100644
--- a/test/shell/lvconvert-raid-allocation.sh
+++ b/test/shell/lvconvert-raid-allocation.sh
@@ -18,7 +18,7 @@ vgcreate -s 256k $vg $(cat DEVICES)
 
 # Start with linear on 2 PV and ensure that converting to
 # RAID is not allowed to reuse PVs for different images.  (Bug 1113180)
-lvcreate -l 4 -n $lv1 $vg "$dev1:0-1" "$dev2:0-1"
+lvcreate -aey -l 4 -n $lv1 $vg "$dev1:0-1" "$dev2:0-1"
 not lvconvert --type raid1 -m 1 $vg/$lv1 "$dev1" "$dev2"
 not lvconvert --type raid1 -m 1 $vg/$lv1 "$dev1" "$dev3:0-2"
 lvconvert --type raid1 -m 1 $vg/$lv1 "$dev3"


