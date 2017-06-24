From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 24 Jun 2017 17:03:35 -0400
Subject: master - tests: slightly longer delay
Message-ID: <201706242103.v5OL3ZuA031857@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1b9bf5ce9e65c22e5e06025ca9700cecd8addc68
Commit:        1b9bf5ce9e65c22e5e06025ca9700cecd8addc68
Parent:        c465ca6a3acd2b01ddacac2275bd965bde2b4167
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 24 22:58:08 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jun 24 22:58:08 2017 +0200

tests: slightly longer delay

Try to avoid race with slightly longer delay.
---
 test/shell/lvconvert-cache-abort.sh |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-cache-abort.sh b/test/shell/lvconvert-cache-abort.sh
index 899fa42..17b5d27 100644
--- a/test/shell/lvconvert-cache-abort.sh
+++ b/test/shell/lvconvert-cache-abort.sh
@@ -39,11 +39,13 @@ done
 # Delay dev to ensure we have some time to 'capture' interrupt in flush
 aux delay_dev "$dev1" 0 500 $(get first_extent_sector "$dev1"):
 
+lvdisplay --maps $vg
+sync
 dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=4k count=100 conv=fdatasync
 
 LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -v --splitcache $vg/$lv1 >log 2>&1 &
 PID_CONVERT=$!
-sleep 0.1
+sleep 0.2
 kill -INT $PID_CONVERT
 aux enable_dev "$dev1"
 wait


