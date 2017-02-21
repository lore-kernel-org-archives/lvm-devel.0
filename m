From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 21 Feb 2017 08:43:58 +0000 (UTC)
Subject: master - tests: ensure first call is version test
Message-ID: <20170221084358.0B22E60D3F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a65e2d49e9056bfe291f291c70f1ba9ec72e2e7
Commit:        2a65e2d49e9056bfe291f291c70f1ba9ec72e2e7
Parent:        7c14004f69f18aeb6fbb022f0ef81f109177022c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 21 09:38:49 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 21 09:38:49 2017 +0100

tests: ensure first call is version test

Check 'dmsetup version'  is called before starting any more
advanced logic in $DM_DEV_DIR.

Call also replaces mkdir as it creates needed path with control node.
---
 test/lib/inittest.sh |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index dcc1304..b75eddc 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -77,6 +77,11 @@ find "$TESTOLDPWD/lib" ! \( -name '*.sh' -o -name '*.[cdo]' \
 DM_DEFAULT_NAME_MANGLING_MODE=none
 DM_DEV_DIR="$TESTDIR/dev"
 LVM_SYSTEM_DIR="$TESTDIR/etc"
+# abort on the internal dm errors in the tests (allowing test user override)
+DM_ABORT_ON_INTERNAL_ERRORS=${DM_ABORT_ON_INTERNAL_ERRORS:-1}
+
+export DM_DEFAULT_NAME_MANGLING_MODE DM_DEV_DIR LVM_SYSTEM_DIR DM_ABORT_ON_INTERNAL_ERRORS
+
 mkdir "$LVM_SYSTEM_DIR" "$DM_DEV_DIR"
 if test -n "$LVM_TEST_DEVDIR" ; then
 	test -d "$LVM_TEST_DEVDIR" || die "Test device directory LVM_TEST_DEVDIR=\"$LVM_TEST_DEVDIR\" is not valid."
@@ -85,14 +90,11 @@ else
 	mknod "$DM_DEV_DIR/testnull" c 1 3 || die "mknod failed"
 	echo >"$DM_DEV_DIR/testnull" || \
 		die "Filesystem does support devices in $DM_DEV_DIR (mounted with nodev?)"
-	mkdir "$DM_DEV_DIR/mapper"
+	# dmsetup makes here needed control entry if still missing
+	dmsetup version || \
+		die "Dmsetup in $DM_DEV_DIR can't report version?"
 fi
 
-# abort on the internal dm errors in the tests (allowing test user override)
-DM_ABORT_ON_INTERNAL_ERRORS=${DM_ABORT_ON_INTERNAL_ERRORS:-1}
-
-export DM_DEFAULT_NAME_MANGLING_MODE DM_DEV_DIR LVM_SYSTEM_DIR DM_ABORT_ON_INTERNAL_ERRORS
-
 echo "$TESTNAME" >TESTNAME
 
 echo "Kernel is $(uname -a)"


