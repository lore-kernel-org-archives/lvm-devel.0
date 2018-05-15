From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 15 May 2018 16:05:17 -0400
Subject: master - tests: drop junk
Message-ID: <201805152005.w4FK5HTd001427@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b5da4fdfcebb5a9c2c32b64b27a12f6480829a97
Commit:        b5da4fdfcebb5a9c2c32b64b27a12f6480829a97
Parent:        be154e30e895bf08e00a8cf32ceb79b7c0f4b5a6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 15 21:51:35 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 15 22:02:41 2018 +0200

tests: drop junk

---
 test/shell/lvconvert-mirror.sh |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 91b8490..3fd4822 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -360,10 +360,6 @@ check mirror_no_temporaries $vg $lv1
 check mirror_legs $vg $lv1 3
 lvremove -ff $vg
 
-lvs -a $vg
-dmsetup table
-losetup -a
-ls -lRa $PWD
 
 # "rhbz440405: lvconvert -m0 incorrectly fails if all PEs allocated"
 lvcreate -aey -l "$(get pv_field "$dev1" pe_count)" --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
@@ -373,5 +369,4 @@ lvconvert -m0 $vg/$lv1 "$dev1"
 check linear $vg $lv1
 lvremove -ff $vg
 
-
 vgremove -ff $vg


