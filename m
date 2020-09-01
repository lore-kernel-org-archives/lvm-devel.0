From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  1 Sep 2020 21:41:37 +0000 (GMT)
Subject: master - tests: slightly faster
Message-ID: <20200901214137.4788C386F823@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fa1290f40e17c82030d23c21af1f318688631759
Commit:        fa1290f40e17c82030d23c21af1f318688631759
Parent:        38d460ed6eb386325b708aa3668ffd8899947450
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 1 23:05:11 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 1 23:40:24 2020 +0200

tests: slightly faster

Use lvm shell to agregrate lots of lvm commands
Reduce initial zeroing.
---
 test/shell/pvck-dump.sh | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/test/shell/pvck-dump.sh b/test/shell/pvck-dump.sh
index 327731295..8892152b2 100644
--- a/test/shell/pvck-dump.sh
+++ b/test/shell/pvck-dump.sh
@@ -16,10 +16,10 @@
 aux prepare_devs 4 128
 get_devs
 
-dd if=/dev/zero of="$dev1" bs=1M count=32 || true
-dd if=/dev/zero of="$dev2" bs=1M count=32 || true
-dd if=/dev/zero of="$dev3" bs=1M count=32 || true
-dd if=/dev/zero of="$dev4" bs=1M count=32 || true
+dd if=/dev/zero of="$dev1" bs=1M count=2 || true
+dd if=/dev/zero of="$dev2" bs=1M count=2 || true
+dd if=/dev/zero of="$dev3" bs=1M count=2 || true
+dd if=/dev/zero of="$dev4" bs=1M count=2 || true
 # clear entire dev to cover mda2
 dd if=/dev/zero of="$dev3" || true
 
@@ -146,7 +146,7 @@ pvcreate --pvmetadatacopies 2 --metadatasize 32M "$dev1"
 
 vgcreate $SHARED -s 512K --metadatasize 32M $vg "$dev1" "$dev2" "$dev3" "$dev4"
 
-for i in `seq 1 500`; do lvcreate -an -n lv$i -l1 $vg; done
+for i in $(seq 1 500); do echo "lvcreate -an -n lv$i -l1 $vg"; done | lvm
 
 pvck --dump headers "$dev1" > h1
 


