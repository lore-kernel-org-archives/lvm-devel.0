From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:55:57 -0400
Subject: master - tests: vgck now exits with error for bad vg
Message-ID: <201804231355.w3NDtv5s001869@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a01a8d71723740577e5fe9635412940d941b5da9
Commit:        a01a8d71723740577e5fe9635412940d941b5da9
Parent:        a9b0aa5c178a6d8bb708ed35f833c648f7437ae3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 9 13:18:38 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:48 2018 -0500

tests: vgck now exits with error for bad vg

---
 test/shell/vgck.sh |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/shell/vgck.sh b/test/shell/vgck.sh
index 2f3fba4..186704c 100644
--- a/test/shell/vgck.sh
+++ b/test/shell/vgck.sh
@@ -22,18 +22,18 @@ dd if=/dev/urandom bs=512 seek=2 count=32 of="$dev2"
 
 # TODO: aux lvmconf "global/locking_type = 4"
 
-vgscan 2>&1 | tee vgscan.out
+vgscan 2>&1 | tee vgscan.out || true
 
 if test -e LOCAL_LVMETAD; then
-    not grep "Inconsistent metadata found for VG $vg" vgscan.out
+    not grep "Failed" vgscan.out
 else
-    grep "Inconsistent metadata found for VG $vg" vgscan.out
+    grep "Failed" vgscan.out
 fi
 
 dd if=/dev/urandom bs=512 seek=2 count=32 of="$dev2"
 aux notify_lvmetad "$dev2"
 
-vgck $vg 2>&1 | tee vgck.out
+vgck $vg 2>&1 | tee vgck.out || true
 grep Incorrect vgck.out
 
 vgremove -ff $vg


