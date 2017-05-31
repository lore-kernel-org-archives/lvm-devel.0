From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 31 May 2017 08:01:44 -0400
Subject: master - tests: add some extra udev waits
Message-ID: <201705311201.v4VC1igD028376@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=42b87c23e2e5745eba0f66328319b541303db3aa
Commit:        42b87c23e2e5745eba0f66328319b541303db3aa
Parent:        091c55a13fbd385f5ea230bcc9bc2b2f0e29af9f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 31 13:23:34 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 31 13:23:34 2017 +0200

tests: add some extra udev waits

To get less random results on older systems with systemd (i.e. fc23)
put few extra udev wait operations to avoid any udev event collision.
---
 test/shell/fsadm-renamed.sh |   18 +++++++++++++++++-
 1 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/test/shell/fsadm-renamed.sh b/test/shell/fsadm-renamed.sh
index 5142e51..9f3cd3c 100644
--- a/test/shell/fsadm-renamed.sh
+++ b/test/shell/fsadm-renamed.sh
@@ -64,8 +64,19 @@ esac
 echo "$i"
 "$i" $MKFS_ARGS "$dev_vg_lv"
 
+# Adding couple udev wait ops as some older systemd
+# might get confused and was 'randomly/racy' umounting
+# devices  just mounted.
+# 
+# See for explanation: 
+#   https://github.com/systemd/systemd/commit/628c89cc68ab96fce2de7ebba5933725d147aecc
+#   https://github.com/systemd/systemd/pull/2017
+aux udev_wait
+
 mount "$dev_vg_lv" "$mount_dir"
 
+aux udev_wait
+
 lvrename $vg_lv $vg_lv_ren
 
 mount | tee out
@@ -80,9 +91,12 @@ not umount "$dev_vg_lv"
 lvcreate -L20 -n $lv1 $vg
 "$i" $MKFS_ARGS "$dev_vg_lv"
 
+aux udev_wait
+
 mount "$dev_vg_lv" "$mount_dolar_dir"
 
-mount | grep $vg
+mount | tee out
+grep $vg out
 
 not lvresize -L+10M -r $vg_lv_ren
 
@@ -91,6 +105,8 @@ umount "$mount_dir"
 # FIXME:  lvresize  CANNOT handle/propagage '--yes' to fsadm
 echo y | lvresize -L+10M -r $vg_lv
 
+aux udev_wait
+
 umount "$mount_dolar_dir"
 
 lvremove -ff $vg


