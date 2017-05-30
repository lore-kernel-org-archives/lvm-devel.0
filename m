From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 30 May 2017 12:44:37 -0400
Subject: master - tests: drop extra debug vvvv
Message-ID: <201705301644.v4UGiboK014248@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b876e8c915a9434fa947ceb447dab32d5ecc74d3
Commit:        b876e8c915a9434fa947ceb447dab32d5ecc74d3
Parent:        7c84c5c421806d5ee3fbe885862839a27df7b36a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 30 12:58:32 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue May 30 18:43:56 2017 +0200

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
 


