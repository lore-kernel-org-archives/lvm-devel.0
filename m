From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 28 Aug 2013 12:53:57 +0000 (UTC)
Subject: master - test: Check for flavoured variables earlier.
Message-ID: <20130828125357.B273360FCD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b516a72b117eeee627f469369fadf56caf3041a7
Commit:        b516a72b117eeee627f469369fadf56caf3041a7
Parent:        d07cf851e5e9f501a034ac69d9f544e7426ec82c
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Aug 23 10:06:14 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Aug 28 14:53:23 2013 +0200

test: Check for flavoured variables earlier.

This is necessary to make LVM_TEST_DEVDIR flavourable, and in turn have flavours
that use the global /dev (which can in turn be managed by udev).
---
 test/lib/test.sh |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/test/lib/test.sh b/test/lib/test.sh
index 20da059..563ef59 100644
--- a/test/lib/test.sh
+++ b/test/lib/test.sh
@@ -38,6 +38,16 @@ export TESTOLDPWD TESTDIR COMMON_PREFIX PREFIX RUNNING_DMEVENTD
 test -n "$BASH" && trap 'set +vx; STACKTRACE; set -vx' ERR
 trap 'aux teardown' EXIT # don't forget to clean up
 
+cd "$TESTDIR"
+
+if test -n "$LVM_TEST_FLAVOUR"; then
+	touch flavour_overrides
+	env | grep ^$LVM_TEST_FLAVOUR | while read var; do
+		(echo -n "export "; echo $var | sed -e s,^${LVM_TEST_FLAVOUR}_,,) >> flavour_overrides
+	done
+	. flavour_overrides
+fi
+
 DM_DEV_DIR="$TESTDIR/dev"
 LVM_SYSTEM_DIR="$TESTDIR/etc"
 mkdir "$LVM_SYSTEM_DIR" "$TESTDIR/lib" "$DM_DEV_DIR"
@@ -55,18 +65,8 @@ DM_ABORT_ON_INTERNAL_ERRORS=${DM_ABORT_ON_INTERNAL_ERRORS:-1}
 
 export DM_DEV_DIR LVM_SYSTEM_DIR DM_ABORT_ON_INTERNAL_ERRORS
 
-cd "$TESTDIR"
-
 echo "$TESTNAME" >TESTNAME
 
-if test -n "$LVM_TEST_FLAVOUR"; then
-	touch flavour_overrides
-	env | grep ^$LVM_TEST_FLAVOUR | while read var; do
-		(echo -n "export "; echo $var | sed -e s,^${LVM_TEST_FLAVOUR}_,,) >> flavour_overrides
-	done
-	. flavour_overrides
-fi
-
 # Setting up symlink from $i to $TESTDIR/lib
 find "$abs_top_builddir/daemons/dmeventd/plugins/" -name '*.so' \
 	-exec ln -s -t lib "{}" +


