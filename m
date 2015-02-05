From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:29 +0000 (UTC)
Subject: master - test: Run in /tmp if LVM_TEST_DIR is unset.
Message-ID: <20150205134129.98C1260F11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=48275c78361578672f5f3f5c29737404cf159f6d
Commit:        48275c78361578672f5f3f5c29737404cf159f6d
Parent:        246fecee277cbabe6d377b80c43dee22485e3872
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 23:16:49 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:18 2015 +0100

test: Run in /tmp if LVM_TEST_DIR is unset.

---
 test/lib/inittest.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 7f49b02..5b3ad87 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -29,7 +29,8 @@ TESTOLDPWD=$(pwd)
 COMMON_PREFIX="LVMTEST"
 PREFIX="${COMMON_PREFIX}$$"
 
-TESTDIR=$(mkdtemp "${LVM_TEST_DIR:-$TESTOLDPWD}" "$PREFIX.XXXXXXXXXX") || \
+if test -n "$LVM_TEST_DIR"; then LVM_TEST_DIR=$TMPDIR; fi
+TESTDIR=$(mkdtemp "${LVM_TEST_DIR:-/tmp}" "$PREFIX.XXXXXXXXXX") || \
 	die "failed to create temporary directory in ${LVM_TEST_DIR:-$TESTOLDPWD}"
 RUNNING_DMEVENTD=$(pgrep dmeventd) || true
 


