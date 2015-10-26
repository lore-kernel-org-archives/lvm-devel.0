From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 26 Oct 2015 22:58:34 +0000 (UTC)
Subject: master - tests: support skip flags
Message-ID: <20151026225834.B752B610E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a2dd1f6e191de8d0ba1292e01338d480958c5a0a
Commit:        a2dd1f6e191de8d0ba1292e01338d480958c5a0a
Parent:        c301cc5d3840e1badd015164e0dcabfacc8f9599
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 26 20:09:47 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 26 23:57:47 2015 +0100

tests: support skip flags

---
 test/lib/inittest.sh |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 28bc4e8..beb0210 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -25,6 +25,15 @@ unset CDPATH
 # grab some common utilities
 . lib/utils
 
+if test -n "$LVM_TEST_FLAVOUR"; then
+	. lib/flavour-$LVM_TEST_FLAVOUR
+fi
+
+test -n "$SKIP_WITHOUT_CLVMD" && test "$LVM_TEST_LOCKING" -ne 3 && skip
+test -n "$SKIP_WITHOUT_LVMETAD" && test -z "$LVM_TEST_LVMETAD" && skip
+test -n "$SKIP_WITH_LVMPOLLD" && test -n "$LVM_TEST_LVMPOLLD" && skip
+
+
 TESTOLDPWD=$(pwd)
 COMMON_PREFIX="LVMTEST"
 PREFIX="${COMMON_PREFIX}$$"
@@ -54,10 +63,6 @@ test -n "$abs_top_builddir" && \
 find "$TESTOLDPWD/lib" ! \( -name '*.sh' -o -name '*.[cdo]' \
     -o -name '*~' \)  -exec ln -s -t lib "{}" +
 
-if test -n "$LVM_TEST_FLAVOUR"; then
-	. lib/flavour-$LVM_TEST_FLAVOUR
-fi
-
 DM_DEFAULT_NAME_MANGLING_MODE=none
 DM_DEV_DIR="$TESTDIR/dev"
 LVM_SYSTEM_DIR="$TESTDIR/etc"


