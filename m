From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 11 Sep 2020 19:53:53 +0000 (GMT)
Subject: master - tests: reduce disk space usage by pvck-dump
Message-ID: <20200911195353.2CB023986420@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f84a7266bc991d22572381671ced88e93dcb0a68
Commit:        f84a7266bc991d22572381671ced88e93dcb0a68
Parent:        c9b40083fc34b5e2a1bfc7b251b38c0b8737483f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 11 14:44:05 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 11 21:52:55 2020 +0200

tests: reduce disk space usage by pvck-dump

Lower disk usage for 'dd'.
---
 test/shell/pvck-dump.sh | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/test/shell/pvck-dump.sh b/test/shell/pvck-dump.sh
index 8892152b2..3b6344d93 100644
--- a/test/shell/pvck-dump.sh
+++ b/test/shell/pvck-dump.sh
@@ -12,16 +12,16 @@
 
 . lib/inittest
 
-# 4 devs each 128MB
-aux prepare_devs 4 128
+SIZE_MB=80
+# 4 devs each $SIZE_MB
+aux prepare_devs 4 $SIZE_MB
 get_devs
 
-dd if=/dev/zero of="$dev1" bs=1M count=2 || true
-dd if=/dev/zero of="$dev2" bs=1M count=2 || true
-dd if=/dev/zero of="$dev3" bs=1M count=2 || true
-dd if=/dev/zero of="$dev4" bs=1M count=2 || true
+dd if=/dev/zero of="$dev1" bs=1M count=2 conv=fdatasync
+dd if=/dev/zero of="$dev2" bs=1M count=2 conv=fdatasync
 # clear entire dev to cover mda2
-dd if=/dev/zero of="$dev3" || true
+dd if=/dev/zero of="$dev3" bs=1M count=$SIZE_MB conv=fdatasync
+dd if=/dev/zero of="$dev4" bs=1M count=2 conv=fdatasync
 
 pvcreate "$dev1"
 pvcreate "$dev2"
@@ -135,16 +135,15 @@ diff area1 area3b
 vgremove -ff $vg
 
 
-dd if=/dev/zero of="$dev1" bs=1M count=32 || true
-dd if=/dev/zero of="$dev2" bs=1M count=32 || true
-dd if=/dev/zero of="$dev3" bs=1M count=32 || true
-dd if=/dev/zero of="$dev4" bs=1M count=32 || true
 # clear entire dev to cover mda2
-dd if=/dev/zero of="$dev1" || true
+dd if=/dev/zero of="$dev1" bs=1M count=$SIZE_MB conv=fdatasync
+dd if=/dev/zero of="$dev2" bs=1M count=32 conv=fdatasync
+dd if=/dev/zero of="$dev3" bs=1M count=32 conv=fdatasync
+dd if=/dev/zero of="$dev4" bs=1M count=32 conv=fdatasync
 
 pvcreate --pvmetadatacopies 2 --metadatasize 32M "$dev1"
 
-vgcreate $SHARED -s 512K --metadatasize 32M $vg "$dev1" "$dev2" "$dev3" "$dev4"
+vgcreate $SHARED -s 64K --metadatasize 32M $vg "$dev1" "$dev2" "$dev3" "$dev4"
 
 for i in $(seq 1 500); do echo "lvcreate -an -n lv$i -l1 $vg"; done | lvm
 


