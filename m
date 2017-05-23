From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 May 2017 08:03:22 -0400
Subject: master - tests: fix test for fsadm
Message-ID: <201705231203.v4NC3Mbi009017@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5e8beb4023642eb3aabee0b9f9e54047044b0cb8
Commit:        5e8beb4023642eb3aabee0b9f9e54047044b0cb8
Parent:        1fe4f80e45a6bfcceed5aaab97fc0e27dfcf2b88
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 23 13:59:29 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 23 14:02:43 2017 +0200

tests: fix test for fsadm

Avoid mountinfo
Pass 'y'  - since ATM lvresize cannot pass --yes to fsadm.
---
 test/shell/fsadm-renamed.sh |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/test/shell/fsadm-renamed.sh b/test/shell/fsadm-renamed.sh
index b2c3e0f..3444840 100644
--- a/test/shell/fsadm-renamed.sh
+++ b/test/shell/fsadm-renamed.sh
@@ -73,7 +73,7 @@ mount | grep $vg
 # fails on renamed LV
 fail lvresize -L+10M -r $vg_lv_ren
 
-# fials on unknown mountpoint  (FIXME: umount)
+# fails on unknown mountpoint  (FIXME: umount)
 not umount "$dev_vg_lv"
 
 lvcreate -L20 -n $lv1 $vg
@@ -81,13 +81,14 @@ lvcreate -L20 -n $lv1 $vg
 
 mount "$dev_vg_lv" "$mount_dolar_dir"
 
-cat /proc/self/mountinfo
+mount | grep $vg
 
 not lvresize -L+10M -r $vg_lv_ren
 
 umount "$mount_dir"
 
-lvresize -L+10M -r $vg_lv
+# FIXME:  lvresize  CANNOT handle/propagage '--yes' to fsadm
+echo y | lvresize -L+10M -vvvv -r $vg_lv
 
 umount "$mount_dolar_dir"
 


