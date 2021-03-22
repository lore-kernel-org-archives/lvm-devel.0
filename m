From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:45 +0000 (GMT)
Subject: dev-next - tests: fix condition for exclusion of /dev
Message-ID: <20210322153945.082CE3854808@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=edcc410835641c9ea7bd15810657e0d16608c00f
Commit:        edcc410835641c9ea7bd15810657e0d16608c00f
Parent:        d5b37f24f4f8914b2ab12c9fb352b2b84ca87c16
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 20 00:28:13 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 20 00:28:13 2021 +0100

tests: fix condition for exclusion of /dev

---
 test/lib/inittest.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 58fa2e5e6..0014a8cfd 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -79,7 +79,7 @@ if test -z "$SKIP_ROOT_DM_CHECK" ; then
 fi
 
 test -n "$LVM_TEST_DIR" || LVM_TEST_DIR=${TMPDIR:-/tmp}
-test "$LVM_TEST_DIR" = "/dev" || die "Setting LVM_TEST_DIR=/dev is not supported"
+test "$LVM_TEST_DIR" = "/dev" && die "Setting LVM_TEST_DIR=/dev is not supported!"
 
 TESTDIR=$(mkdtemp "$LVM_TEST_DIR" "$PREFIX.XXXXXXXXXX") || \
 	die "failed to create temporary directory in \"$LVM_TEST_DIR\""


