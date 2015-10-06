From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  6 Oct 2015 13:25:21 +0000 (UTC)
Subject: master - tests: check devices with prefix aren't in use
Message-ID: <20151006132521.5D2B260F6B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=277dd0aa7a9013697ae99164900d8d8ec12a2850
Commit:        277dd0aa7a9013697ae99164900d8d8ec12a2850
Parent:        ded9452174664b7e204f5ce266bbd5c770714474
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 6 14:55:24 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 6 15:23:55 2015 +0200

tests: check devices with prefix aren't in use

Avoid running tests, when prefix already exist in the system.
As prefix just uses  PID number, we may hit a case for long
running tests, where devices from some previous runs were not
properly cleared away - detect this and fail early.
(Such machine should be inspected and fixed).
---
 test/lib/inittest.sh |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index a5eeb57..4ed8d20 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -29,6 +29,9 @@ TESTOLDPWD=$(pwd)
 COMMON_PREFIX="LVMTEST"
 PREFIX="${COMMON_PREFIX}$$"
 
+# Check we are not conflickting with some exiting setup
+dmsetup table | not grep "$PREFIX" || die "DM table already has devices with prefix $PREFIX!"
+
 if test -z "$LVM_TEST_DIR"; then LVM_TEST_DIR=$TMPDIR; fi
 TESTDIR=$(mkdtemp "${LVM_TEST_DIR:-/tmp}" "$PREFIX.XXXXXXXXXX") || \
 	die "failed to create temporary directory in ${LVM_TEST_DIR:-$TESTOLDPWD}"


