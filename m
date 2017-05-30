From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 30 May 2017 10:19:58 -0400
Subject: master - tests: drop extra debug vvvv
Message-ID: <201705301419.v4UEJwMK026890@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=de663f48a15bf8934b616c8dd7f736e3d2b65b2d
Commit:        de663f48a15bf8934b616c8dd7f736e3d2b65b2d
Parent:        888994036549ed0201e1d6fd6f84a0127ce27cbe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 30 12:58:32 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 30 16:19:01 2017 +0200

tests: drop extra debug vvvv

Also show output of mount so when it fails we can check the state.
---
 test/shell/fsadm-renamed.sh |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/test/shell/fsadm-renamed.sh b/test/shell/fsadm-renamed.sh
index 3444840..5142e51 100644
--- a/test/shell/fsadm-renamed.sh
+++ b/test/shell/fsadm-renamed.sh
@@ -68,7 +68,8 @@ mount "$dev_vg_lv" "$mount_dir"
 
 lvrename $vg_lv $vg_lv_ren
 
-mount | grep $vg
+mount | tee out
+grep $vg out
 
 # fails on renamed LV
 fail lvresize -L+10M -r $vg_lv_ren
@@ -88,7 +89,7 @@ not lvresize -L+10M -r $vg_lv_ren
 umount "$mount_dir"
 
 # FIXME:  lvresize  CANNOT handle/propagage '--yes' to fsadm
-echo y | lvresize -L+10M -vvvv -r $vg_lv
+echo y | lvresize -L+10M -r $vg_lv
 
 umount "$mount_dolar_dir"
 


