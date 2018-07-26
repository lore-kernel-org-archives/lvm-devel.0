From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 26 Jul 2018 09:18:14 -0400
Subject: 2018-06-01-stable - test: Check flavour is used and exists
Message-ID: <201807261318.w6QDIEXp021369@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=48594d007a88791c4e2dedbddd40fca97bcf5ed2
Commit:        48594d007a88791c4e2dedbddd40fca97bcf5ed2
Parent:        50a603de6fd860fc9009e512978b8899407c4980
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Jul 26 15:01:50 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Jul 26 15:04:16 2018 +0200

test: Check flavour is used and exists

(cherry picked from commit 9cd05d1f1eef6ceb2dd0b18f792730f711334578)
---
 test/lib/inittest.sh |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index c48ea13..967fc1f 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -25,6 +25,8 @@ TESTNAME=${0##*/}
 PS4='#${BASH_SOURCE[0]##*/}:${LINENO}+ '
 export TESTNAME PS4
 
+LVM_TEST_FLAVOUR=${LVM_TEST_FLAVOUR-}
+
 LVM_TEST_BACKING_DEVICE=${LVM_TEST_BACKING_DEVICE-}
 LVM_TEST_DEVDIR=${LVM_TEST_DEVDIR-}
 LVM_TEST_NODEBUG=${LVM_TEST_NODEBUG-}
@@ -49,9 +51,9 @@ SKIP_WITH_LVMPOLLD=${SKIP_WITH_LVMPOLLD-}
 SKIP_WITH_LVMLOCKD=${SKIP_WITH_LVMLOCKD-}
 SKIP_ROOT_DM_CHECK=${SKIP_ROOT_DM_CHECK-}
 
-if test -n "$LVM_TEST_FLAVOUR"; then
-	. "lib/flavour-$LVM_TEST_FLAVOUR"
-fi
+test -n "$LVM_TEST_FLAVOUR" || { echo "NOTE: Empty flavour">&2; initskip; }
+test -f "lib/flavour-$LVM_TEST_FLAVOUR" || { echo "NOTE: Flavour '$LVM_TEST_FLAVOUR' does not exist">&2; initskip; }
+. "lib/flavour-$LVM_TEST_FLAVOUR"
 
 test -n "$SKIP_WITHOUT_CLVMD" && test "$LVM_TEST_LOCKING" -ne 3 && initskip
 test -n "$SKIP_WITH_CLVMD" && test "$LVM_TEST_LOCKING" = 3 && initskip


