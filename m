From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 19 Mar 2021 23:17:23 +0000 (GMT)
Subject: main - tests: aux reject /dev as testing dir
Message-ID: <20210319231723.C1809385783D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d5b37f24f4f8914b2ab12c9fb352b2b84ca87c16
Commit:        d5b37f24f4f8914b2ab12c9fb352b2b84ca87c16
Parent:        e27baa791f0e28e9df539c97e25a0a8b1b1c20f7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 19 10:39:00 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 20 00:05:01 2021 +0100

tests: aux reject /dev as testing dir

If LVM_TEST_DIR would be set to /dev, reject such selection.
---
 test/lib/inittest.sh | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index ee049fb79..58fa2e5e6 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -78,9 +78,11 @@ if test -z "$SKIP_ROOT_DM_CHECK" ; then
 	dmsetup table | not grep "${PREFIX}[^0-9]" || die "DM table already has devices with prefix $PREFIX!"
 fi
 
-if test -z "$LVM_TEST_DIR"; then LVM_TEST_DIR=$TMPDIR; fi
-TESTDIR=$(mkdtemp "${LVM_TEST_DIR:-/tmp}" "$PREFIX.XXXXXXXXXX") || \
-	die "failed to create temporary directory in ${LVM_TEST_DIR:-$TESTOLDPWD}"
+test -n "$LVM_TEST_DIR" || LVM_TEST_DIR=${TMPDIR:-/tmp}
+test "$LVM_TEST_DIR" = "/dev" || die "Setting LVM_TEST_DIR=/dev is not supported"
+
+TESTDIR=$(mkdtemp "$LVM_TEST_DIR" "$PREFIX.XXXXXXXXXX") || \
+	die "failed to create temporary directory in \"$LVM_TEST_DIR\""
 RUNNING_DMEVENTD=$(pgrep dmeventd || true)
 
 export TESTOLDPWD TESTDIR COMMON_PREFIX PREFIX RUNNING_DMEVENTD


