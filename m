From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:28 +0000 (UTC)
Subject: master - NIX: Use IDE drive emulation instead of virtio.
Message-ID: <20150205134228.6D9636036E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eaa9f3554057aafd2e521aed12c9918b71501a0d
Commit:        eaa9f3554057aafd2e521aed12c9918b71501a0d
Parent:        c2aa918c534cd939fa064a777141bde0425ba840
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 21 01:54:42 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:20 2015 +0100

NIX: Use IDE drive emulation instead of virtio.

---
 nix/default.nix |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 809debe..fb386e8 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -28,7 +28,7 @@ let
 
          dmsetup targets
 
-         export LVM_TEST_BACKING_DEVICE=/dev/vdb
+         export LVM_TEST_BACKING_DEVICE=/dev/sdb
 
          lvm2-testsuite --batch --outdir /tmp/xchg/results-ndev --continue \
              --fatal-timeouts --heartbeat /tmp/xchg/heartbeat \
@@ -64,7 +64,8 @@ let
        #!${pkgs.bash}/bin/bash
        . $stdenv/setup
 
-       export QEMU_OPTS="-drive file=/dev/shm/testdisk.img,if=virtio -m 256M"
+       export QEMU_OPTS="-drive file=/dev/shm/testdisk.img,if=ide -m 256M"
+       export QEMU_DRIVE_OPTS=",if=ide"
        export KERNEL_OPTS="log_buf_len=131072 loglevel=1"
        export mountDisk=1
 


