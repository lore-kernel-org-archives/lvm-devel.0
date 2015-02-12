From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Feb 2015 14:42:09 +0000 (UTC)
Subject: master - tests: respect LVM_TEST_DIR
Message-ID: <20150212144209.A23596010E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=65d95caad5cb7410286b1c2b189cfedb69fcbe7d
Commit:        65d95caad5cb7410286b1c2b189cfedb69fcbe7d
Parent:        d95c6154ffe19e629a1403b45f6e8371f9dc6d70
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 12 10:33:48 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 12 15:38:50 2015 +0100

tests: respect LVM_TEST_DIR

Check for empty LVM_TEST_DIR
(regression from 48275c78361578672f5f3f5c29737404cf159f6d)
---
 test/lib/inittest.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 5b3ad87..e3d874b 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -29,7 +29,7 @@ TESTOLDPWD=$(pwd)
 COMMON_PREFIX="LVMTEST"
 PREFIX="${COMMON_PREFIX}$$"
 
-if test -n "$LVM_TEST_DIR"; then LVM_TEST_DIR=$TMPDIR; fi
+if test -z "$LVM_TEST_DIR"; then LVM_TEST_DIR=$TMPDIR; fi
 TESTDIR=$(mkdtemp "${LVM_TEST_DIR:-/tmp}" "$PREFIX.XXXXXXXXXX") || \
 	die "failed to create temporary directory in ${LVM_TEST_DIR:-$TESTOLDPWD}"
 RUNNING_DMEVENTD=$(pgrep dmeventd) || true


