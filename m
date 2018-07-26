From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 26 Jul 2018 09:03:52 -0400
Subject: master - test: Check flavour is used and exists
Message-ID: <201807261303.w6QD3qp4018309@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9cd05d1f1eef6ceb2dd0b18f792730f711334578
Commit:        9cd05d1f1eef6ceb2dd0b18f792730f711334578
Parent:        7f49d463d6c362a472d3ba721f91558602901a33
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Jul 26 15:01:50 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Jul 26 15:01:50 2018 +0200

test: Check flavour is used and exists

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


