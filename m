From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:15 +0000 (UTC)
Subject: master - test: Make lvm-wrapper available in the installed testsuite, too.
Message-ID: <20150205134315.09FD960E22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a6d006d9db033e8251fd58848f8876b3e3d0fe90
Commit:        a6d006d9db033e8251fd58848f8876b3e3d0fe90
Parent:        41c2e07a8dee3d3e5212c7c1939ddbd4624d3bed
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Sep 30 17:08:34 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:50:33 2015 +0100

test: Make lvm-wrapper available in the installed testsuite, too.

---
 test/Makefile.in        |    1 +
 test/lib/lvm-wrapper.sh |    7 ++++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 690e7e4..e0652e1 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -145,6 +145,7 @@ install: .tests-stamp lib/paths-installed
 	$(INSTALL_DATA) lib/paths-installed $(DATADIR)/lib/paths
 	$(INSTALL_DATA) $(LIB_FLAVOURS) $(DATADIR)/lib/
 	$(INSTALL_SCRIPT) $(LIB_SHARED) $(DATADIR)/lib/
+	for i in $(CMDS); do (cd $(DATADIR)/lib && ln -fs lvm-wrapper $$i); done
 
 	$(INSTALL_DIR) $(EXECDIR)
 	$(INSTALL_PROGRAM) $(LIB_EXEC) $(EXECDIR)
diff --git a/test/lib/lvm-wrapper.sh b/test/lib/lvm-wrapper.sh
index 082c640..013bc13 100644
--- a/test/lib/lvm-wrapper.sh
+++ b/test/lib/lvm-wrapper.sh
@@ -36,4 +36,9 @@ if test -n "$LVM_VALGRIND"; then
 fi
 
 # the exec is important, because otherwise fatal signals inside "not" go unnoticed
-exec $RUN_VALGRIND "$abs_top_builddir/tools/lvm" $CMD "$@"
+if test -n "$abs_top_builddir"; then
+    exec $RUN_DBG "$abs_top_builddir/tools/lvm" $CMD "$@"
+else # we are testing the lvm on $PATH
+    PATH=`echo $PATH | sed -e s,[^:]*lvm2-testsuite[^:]*:,,g`
+    exec $RUN_DBG lvm $CMD "$@"
+fi


