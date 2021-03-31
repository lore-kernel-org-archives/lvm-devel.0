From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:48:58 +0000 (GMT)
Subject: dev-next - tests: use prefix for VG name
Message-ID: <20210331214858.62BA43858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d0644fb2c346414ae138369557bbd898d5feac6f
Commit:        d0644fb2c346414ae138369557bbd898d5feac6f
Parent:        712f7dfb4cdb729609de230e41255c5af0526860
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 23 14:38:54 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 23 14:38:54 2021 +0100

tests: use prefix for VG name

---
 test/shell/losetup-partscan.sh | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/losetup-partscan.sh b/test/shell/losetup-partscan.sh
index 98b2677f8..aa752064c 100644
--- a/test/shell/losetup-partscan.sh
+++ b/test/shell/losetup-partscan.sh
@@ -37,7 +37,7 @@ aux extend_filter "a|$LOOP|"
 
 # creation should fail for 'partitioned' loop device
 not pvcreate -y "$LOOP"
-not vgcreate $SHARED vg "$LOOP"
+not vgcreate $SHARED ${PREFIX}vg "$LOOP"
 
 aux teardown_devs
 
@@ -61,4 +61,4 @@ aux extend_filter "a|$LOOP|"
 # creation should pass for 'non-partitioned' loop device
 pvcreate -y "$LOOP"
 
-vgcreate $SHARED vg "$LOOP"
+vgcreate $SHARED ${PREFIX}vg "$LOOP"


