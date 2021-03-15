From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:24 +0000 (GMT)
Subject: main - tests: wait till fs is synchronized
Message-ID: <20210315101424.164BA3857C5E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=800a93d4ac78e2736c43cb2cf8099cf68b68b341
Commit:        800a93d4ac78e2736c43cb2cf8099cf68b68b341
Parent:        78406ef6174b20ba2ee3e6405b8ed39804990482
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 11 10:46:31 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 15 11:13:24 2021 +0100

tests: wait till fs is synchronized

Adding full filesystem sync, trying to fight with strange error from losetup:

losetup: loopa: failed to set up loop device: Resource temporarily unavailable

loop0: detected capacity change from 0 to 4096
loop_set_block_size: loop0 () has still dirty pages (nrpages=13)

Also reuse internal aux wipefs_a
---
 test/shell/allow-mixed-block-sizes.sh | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/allow-mixed-block-sizes.sh b/test/shell/allow-mixed-block-sizes.sh
index efab1302a..a094338cb 100644
--- a/test/shell/allow-mixed-block-sizes.sh
+++ b/test/shell/allow-mixed-block-sizes.sh
@@ -16,10 +16,10 @@ SKIP_WITH_LVMPOLLD=1
 
 losetup -h | grep sector-size || skip
 which fallocate || skip
-which wipefs || skip
 
 fallocate -l 2M loopa
 fallocate -l 2M loopb
+sync
 LOOP1=$(losetup -f loopa --sector-size 4096 --show)
 LOOP2=$(losetup -f loopb --show)
 
@@ -40,7 +40,7 @@ vgcreate --config 'devices/allow_mixed_block_sizes=1' $vg "$dev1" "$dev2"
 vgs --config 'devices/allow_mixed_block_sizes=1' $vg
 
 for i in "$dev1" "$dev2" ; do
-	wipefs -a "$i"
+	aux wipefs_a "$i"
 	# FIXME - we are not missing notification for hinting
 	# likely in more places - as the test should be able to work without
 	# system's udev working only on real /dev dir.


