From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:06 +0000 (UTC)
Subject: master - test: Use the new flavour setup files in lib/inittest.
Message-ID: <20150205134106.8F89460A54@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=569895394895ea4354a3ab8de919f99acf5a5e87
Commit:        569895394895ea4354a3ab8de919f99acf5a5e87
Parent:        9752ee8ed2322b9f35f16e259c87b525796d4b2d
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 00:58:28 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:17 2015 +0100

test: Use the new flavour setup files in lib/inittest.

---
 test/lib/inittest.sh |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 731cd7a..7f49b02 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -39,19 +39,23 @@ test -n "$BASH" && trap 'set +vx; STACKTRACE; set -vx' ERR
 trap 'aux teardown' EXIT # don't forget to clean up
 
 cd "$TESTDIR"
+mkdir lib
+
+# Setting up symlink from $i to $TESTDIR/lib
+test -n "$abs_top_builddir" && \
+    find "$abs_top_builddir/daemons/dmeventd/plugins/" -name '*.so' \
+    -exec ln -s -t lib "{}" +
+find "$TESTOLDPWD/lib" ! \( -name '*.sh' -o -name '*.[cdo]' \
+    -o -name '*~' \)  -exec ln -s -t lib "{}" +
 
 if test -n "$LVM_TEST_FLAVOUR"; then
-	touch flavour_overrides
-	env | grep ^${LVM_TEST_FLAVOUR} | while read var; do
-		(echo -n "export "; echo $var | sed -e s,^${LVM_TEST_FLAVOUR}_,,) >> flavour_overrides
-	done
-	. flavour_overrides
+	. lib/flavour-$LVM_TEST_FLAVOUR
 fi
 
 DM_DEFAULT_NAME_MANGLING_MODE=none
 DM_DEV_DIR="$TESTDIR/dev"
 LVM_SYSTEM_DIR="$TESTDIR/etc"
-mkdir "$LVM_SYSTEM_DIR" "$TESTDIR/lib" "$DM_DEV_DIR"
+mkdir "$LVM_SYSTEM_DIR" "$DM_DEV_DIR"
 if test -n "$LVM_TEST_DEVDIR" ; then
 	DM_DEV_DIR=$LVM_TEST_DEVDIR
 else
@@ -76,12 +80,6 @@ else
 	echo "Selinux mode is not installed."
 fi
 
-# Setting up symlink from $i to $TESTDIR/lib
-find "$abs_top_builddir/daemons/dmeventd/plugins/" -name '*.so' \
-	-exec ln -s -t lib "{}" +
-find "$abs_top_builddir/test/lib" ! \( -name '*.sh' -o -name '*.[cdo]' \
-	-o -name '*~' \)  -exec ln -s -t lib "{}" +
-
 # Set vars from utils now that we have TESTDIR/PREFIX/...
 prepare_test_vars
 


