From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:10 +0000 (GMT)
Subject: dev-next - tests: check fsadm with missing filesystem
Message-ID: <20210331214910.F237A3858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2151b71819ffd45e71f2565aa2c0d2cb9685e2c0
Commit:        2151b71819ffd45e71f2565aa2c0d2cb9685e2c0
Parent:        28865f971e0b23f4d1a4117e0e0fdb61bd21d836
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 24 16:33:16 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 24 16:38:12 2021 +0100

tests: check fsadm with missing filesystem

---
 test/shell/fsadm.sh | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/test/shell/fsadm.sh b/test/shell/fsadm.sh
index 987b1a1a9..c5b3774c2 100644
--- a/test/shell/fsadm.sh
+++ b/test/shell/fsadm.sh
@@ -99,6 +99,10 @@ fsadm
 # check needs arg
 not fsadm check
 
+# check needs arg
+not fsadm resize "$dev_vg_lv" 30M |& tee out
+grep "Cannot get FSTYPE" out
+
 if check_missing ext2; then
 	mkfs.ext2 -b4096 -j "$dev_vg_lv"
 


