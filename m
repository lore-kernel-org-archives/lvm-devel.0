From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 15 Apr 2015 13:10:48 +0000 (UTC)
Subject: master - tests: move print of replaced vars
Message-ID: <20150415131048.4D8F4610C8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=43a6f9e726295eaf200e7acb19d7e35b0af4aabb
Commit:        43a6f9e726295eaf200e7acb19d7e35b0af4aabb
Parent:        53c2c4562555cbc00b2b78cb4394ee3f2b7f0729
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 15 14:31:28 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 15 15:09:45 2015 +0200

tests: move print of replaced vars

---
 test/lib/inittest.sh |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index f55938f..3a0d332 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -86,6 +86,10 @@ prepare_test_vars
 
 test -n "$BASH" && set -eE -o pipefail
 
+# Vars for harness
+echo "@TESTDIR=$TESTDIR"
+echo "@PREFIX=$PREFIX"
+
 if test -n "$LVM_TEST_LVMETAD" ; then
 	export LVM_LVMETAD_SOCKET="$TESTDIR/lvmetad.socket"
 	export LVM_LVMETAD_PIDFILE="$TESTDIR/lvmetad.pid"
@@ -96,9 +100,6 @@ else
 	aux prepare_clvmd
 fi
 
-# Vars for harness
-echo "@TESTDIR=$TESTDIR"
-echo "@PREFIX=$PREFIX"
 echo "<======== Processing test: \"$TESTNAME\" ========>"
 
 set -vx


