From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 21 Jan 2017 16:46:22 +0000 (UTC)
Subject: master - tests: enusure units in TiB
Message-ID: <20170121164622.ABE9B60797@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=47c11c7b1c364a2d2fd257aaa191816e146d3602
Commit:        47c11c7b1c364a2d2fd257aaa191816e146d3602
Parent:        2e0605d6db9723d4bea472b21352d398f29e226e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jan 21 16:20:41 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jan 21 17:42:19 2017 +0100

tests: enusure units in TiB

---
 test/shell/lvcreate-large.sh |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvcreate-large.sh b/test/shell/lvcreate-large.sh
index 81c612a..6fc4c5e 100644
--- a/test/shell/lvcreate-large.sh
+++ b/test/shell/lvcreate-large.sh
@@ -32,15 +32,15 @@ pvcreate "$DM_DEV_DIR/$vg/$lv"
 vgcreate $vg1 "$DM_DEV_DIR/$vg/$lv"
 
 lvcreate -l 100%FREE -n $lv1 $vg1
-check lv_field $vg1/$lv1 size "1024.00t"
+check lv_field $vg1/$lv1 size "1024.00t" --units t
 lvresize -f -l 72%VG $vg1/$lv1
-check lv_field $vg1/$lv1 size "737.28t"
+check lv_field $vg1/$lv1 size "737.28t" --units t
 lvremove -ff $vg1/$lv1
 
 lvcreate -l 100%VG -n $lv1 $vg1
-check lv_field $vg1/$lv1 size "1024.00t"
+check lv_field $vg1/$lv1 size "1024.00t" --units t
 lvresize -f -l 72%VG $vg1/$lv1
-check lv_field $vg1/$lv1 size "737.28t"
+check lv_field $vg1/$lv1 size "737.28t" --units t
 lvremove -ff $vg1/$lv1
 
 lvremove -ff $vg/$lv


