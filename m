From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:26:16 -0400
Subject: master - tests: inittest compare string
Message-ID: <201805121626.w4CGQGhe008114@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0221ebfd64541ee8598fc7f936f8267505b1bfae
Commit:        0221ebfd64541ee8598fc7f936f8267505b1bfae
Parent:        a7a23e7dd2f7fde59760a3d3f7c980d7a8f657a7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 12 00:06:44 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 18:05:50 2018 +0200

tests: inittest compare string

Avoid logging warning when compared string is empty with -eq.
---
 test/lib/inittest.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 62ec494..b6a1a3a 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -53,7 +53,7 @@ if test -n "$LVM_TEST_FLAVOUR"; then
 fi
 
 test -n "$SKIP_WITHOUT_CLVMD" && test "$LVM_TEST_LOCKING" -ne 3 && initskip
-test -n "$SKIP_WITH_CLVMD" && test "$LVM_TEST_LOCKING" -eq 3 && initskip
+test -n "$SKIP_WITH_CLVMD" && test "$LVM_TEST_LOCKING" = 3 && initskip
 
 test -n "$SKIP_WITHOUT_LVMETAD" && test -z "$LVM_TEST_LVMETAD" && initskip
 test -n "$SKIP_WITH_LVMETAD" && test -n "$LVM_TEST_LVMETAD" && initskip


