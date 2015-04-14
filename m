From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 14 Apr 2015 08:12:02 +0000 (UTC)
Subject: master - tests: avoid dup of lvm.conf
Message-ID: <20150414081202.2DFD160E5E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c969e05aabb00b400d24e44c09c720f1cdebb351
Commit:        c969e05aabb00b400d24e44c09c720f1cdebb351
Parent:        ee6fc17663c777f7276c56fd224fd3cecc0f77e4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 14 09:47:14 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 14 10:11:35 2015 +0200

tests: avoid dup of lvm.conf

When running lvmetad test - avoid duplicate create of lvm.conf
Also as lvmetad cannot be used with cluster make it as 2 code paths.
---
 test/lib/inittest.sh |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 067c3d4..f55938f 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -86,13 +86,15 @@ prepare_test_vars
 
 test -n "$BASH" && set -eE -o pipefail
 
-aux lvmconf
-aux prepare_clvmd
-test -n "$LVM_TEST_LVMETAD" && {
+if test -n "$LVM_TEST_LVMETAD" ; then
 	export LVM_LVMETAD_SOCKET="$TESTDIR/lvmetad.socket"
 	export LVM_LVMETAD_PIDFILE="$TESTDIR/lvmetad.pid"
 	aux prepare_lvmetad
-}
+else
+	# lvmetad prepares its own lvmconf
+	aux lvmconf
+	aux prepare_clvmd
+fi
 
 # Vars for harness
 echo "@TESTDIR=$TESTDIR"


