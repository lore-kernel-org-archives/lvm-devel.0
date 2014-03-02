From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  2 Mar 2014 20:55:56 +0000 (UTC)
Subject: master - tests: report selinux mode
Message-ID: <20140302205556.AF7EC611B2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=75b5855ca1b4d524cb30a4373d1d2fe81d7b21f2
Commit:        75b5855ca1b4d524cb30a4373d1d2fe81d7b21f2
Parent:        a2af5855c5b7e6360d246b802dadafbe79a6d5e4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 2 19:15:52 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 2 21:27:26 2014 +0100

tests: report selinux mode

---
 test/lib/test.sh |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/test/lib/test.sh b/test/lib/test.sh
index 71ad55d..3dc0dfb 100644
--- a/test/lib/test.sh
+++ b/test/lib/test.sh
@@ -67,6 +67,13 @@ export DM_DEV_DIR LVM_SYSTEM_DIR DM_ABORT_ON_INTERNAL_ERRORS
 
 echo "$TESTNAME" >TESTNAME
 
+# Report SELinux mode
+if which getenforce &>/dev/null ; then
+	echo "Selinux mode is \"$(getenforce 2>/dev/null)\"."
+else
+	echo "Selinux mode is not installed."
+fi
+
 # Setting up symlink from $i to $TESTDIR/lib
 find "$abs_top_builddir/daemons/dmeventd/plugins/" -name '*.so' \
 	-exec ln -s -t lib "{}" +
@@ -85,6 +92,8 @@ test -n "$LVM_TEST_LVMETAD" && {
 	export LVM_LVMETAD_PIDFILE="$TESTDIR/lvmetad.pid"
 	aux prepare_lvmetad
 }
+
+# Vars for harness
 echo "@TESTDIR=$TESTDIR"
 echo "@PREFIX=$PREFIX"
 


