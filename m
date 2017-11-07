From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 7 Nov 2017 18:03:45 -0500
Subject: master - tests: detect racy systemd version
Message-ID: <201711072303.vA7N3jeS030272@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d6473b20183b873d9ea3480e2f34428539ee1fd5
Commit:        d6473b20183b873d9ea3480e2f34428539ee1fd5
Parent:        2172115379386b63fca2f31337dcb0e2e92ac4c0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 7 23:59:04 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 8 00:02:54 2017 +0100

tests: detect racy systemd version

Systemd 222 has a bug - where it's sometimes umount unpredictibly just
mounted device - skip testing when this happens.
---
 test/shell/fsadm-renamed.sh |   22 +++++++++++++++-------
 1 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/test/shell/fsadm-renamed.sh b/test/shell/fsadm-renamed.sh
index 7f3a9fd..e88846a 100644
--- a/test/shell/fsadm-renamed.sh
+++ b/test/shell/fsadm-renamed.sh
@@ -43,6 +43,17 @@ cleanup_mounted_and_teardown()
 	aux teardown
 }
 
+check_mounted()
+{
+	mount | tee out
+	grep $vg out || {
+		# older versions of systemd sometimes umount volume by mistake
+		# skip further test when this case happens
+		systemctl --version | grep "systemd 222" && \
+			skip "System is running old racy systemd version."
+	}
+}
+
 # Test for block sizes != 1024 (rhbz #480022)
 trap 'cleanup_mounted_and_teardown' EXIT
 
@@ -81,11 +92,10 @@ aux udev_wait
 
 lvrename $vg_lv $vg_lv_ren
 
-mount | tee out
-grep $vg out
+check_mounted
 
 # fails on renamed LV
-fail lvresize -L+10M -r $vg_lv_ren
+fail lvresize -y -L+10M -r $vg_lv_ren
 
 # fails on unknown mountpoint  (FIXME: umount)
 not umount "$dev_vg_lv"
@@ -97,15 +107,13 @@ aux udev_wait
 
 mount "$dev_vg_lv" "$mount_dolar_dir"
 
-mount | tee out
-grep $vg out
+check_mounted
 
 not lvresize -L+10M -r $vg_lv_ren
 
 umount "$mount_dir"
 
-# FIXME:  lvresize  CANNOT handle/propagage '--yes' to fsadm
-echo y | lvresize -L+10M -r $vg_lv
+lvresize -y -L+10M -r $vg_lv
 
 aux udev_wait
 


