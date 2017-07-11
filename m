From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 11 Jul 2017 11:22:41 -0400
Subject: master - tests: hardening - no unbound vars
Message-ID: <201707111522.v6BFMfq6015641@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a87860965e99ae2d11f2c2496adb33fff050f4d4
Commit:        a87860965e99ae2d11f2c2496adb33fff050f4d4
Parent:        41e11e0f210bf1c423e39a836dfcb7c4fa3c8032
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 11 11:23:34 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 11 16:48:25 2017 +0200

tests: hardening - no unbound vars

Dissallow usage of any unbound shell variable in tests.
All vars needs to have some defined value.
---
 test/lib/inittest.sh |   22 +++++++++++++++++++++-
 1 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 1dad2eb..e32b044 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -25,6 +25,24 @@ TESTNAME=${0##*/}
 PS4='#${BASH_SOURCE[0]##*/}:${LINENO}+ '
 export TESTNAME PS4
 
+LVM_TEST_NODEBUG=${LVM_TEST_NODEBUG-}
+
+LVM_TEST_LVMETAD=${LVM_TEST_LVMETAD-}
+LVM_TEST_LVMLOCKD=${LVM_TEST_LVMLOCKD-}
+LVM_TEST_LVMLOCKD_TEST=${LVM_TEST_LVMLOCKD_TEST-}
+LVM_TEST_LVMPOLLD=${LVM_TEST_LVMPOLLD-}
+LVM_TEST_LOCK_TYPE_DLM=${LVM_TEST_LOCK_TYPE_DLM-}
+LVM_TEST_LOCK_TYPE_SANLOCK=${LVM_TEST_LOCK_TYPE_SANLOCK-}
+
+SKIP_WITHOUT_CLVMD=${SKIP_WITHOUT_CLVMD-}
+SKIP_WITH_CLVMD=${SKIP_WITH_CLVMD-}
+
+SKIP_WITHOUT_LVMETAD=${SKIP_WITHOUT_LVMETAD-}
+SKIP_WITH_LVMETAD=${SKIP_WITH_LVMETAD-}
+
+SKIP_WITH_LVMPOLLD=${SKIP_WITH_LVMPOLLD-}
+SKIP_WITH_LVMLOCKD=${SKIP_WITH_LVMLOCKD-}
+
 if test -n "$LVM_TEST_FLAVOUR"; then
 	. "lib/flavour-$LVM_TEST_FLAVOUR"
 fi
@@ -106,7 +124,9 @@ free -m || true
 # Set vars from utils now that we have TESTDIR/PREFIX/...
 prepare_test_vars
 
-test -n "$BASH" && set -eE -o pipefail
+# Set strict shell mode
+# see: http://redsymbol.net/articles/unofficial-bash-strict-mode
+test -n "$BASH" && set -euE -o pipefail
 
 # Vars for harness
 echo "@TESTDIR=$TESTDIR"


