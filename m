From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  7 Oct 2014 14:33:37 +0000 (UTC)
Subject: master - test: Fix lvconvert-raid-allocation's use of lvconvert --repair.
Message-ID: <20141007143337.C04B460FFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d623034e62a5fe0ba541e6d1e543f43ae90a834f
Commit:        d623034e62a5fe0ba541e6d1e543f43ae90a834f
Parent:        88959032f7efb9229632c74a3738aae171f0c460
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Oct 7 16:09:43 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Oct 7 16:12:04 2014 +0200

test: Fix lvconvert-raid-allocation's use of lvconvert --repair.

---
 test/shell/lvconvert-raid-allocation.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-raid-allocation.sh b/test/shell/lvconvert-raid-allocation.sh
index bd2cab5..a1b1c39 100644
--- a/test/shell/lvconvert-raid-allocation.sh
+++ b/test/shell/lvconvert-raid-allocation.sh
@@ -63,7 +63,7 @@ lvcreate --type raid1 -m 1 -l 3 -n $lv1 $vg \
     "$dev1:0-1" "$dev2:0-1" "$dev3:0-1" "$dev4:0-1"
 aux wait_for_sync $vg $lv1
 aux disable_dev "$dev1"
-lvconvert --repair -y $vg/$lv1 "$dev1" "$dev2" "$dev3" "$dev4"
+lvconvert --repair -y $vg/$lv1 "$dev2" "$dev3" "$dev4"
 #FIXME: ensure non-overlapping images (they should not share PVs)
 aux enable_dev "$dev1"
 lvremove -ff $vg


