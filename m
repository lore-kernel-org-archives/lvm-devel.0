From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 27 May 2013 01:16:51 +0000 (UTC)
Subject: dev-mornfall-nix - test: Run all the test flavours in a single batch.
Message-ID: <20130527011651.E315460D17@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5e7e63cfee749a5d60997a3c6220f6410b79b959
Commit:        5e7e63cfee749a5d60997a3c6220f6410b79b959
Parent:        0e3a2d44241d3b688714025f862700ad2dfdcf69
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 27 03:12:03 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon May 27 03:15:26 2013 +0200

test: Run all the test flavours in a single batch.

This means that a test failure in one flavour no longer prevents all the
subsequent flavours from running. We also get an aggregate summary at the end of
the entire batch, instead of summaries interspersed with progress output.
---
 test/Makefile.in   |    8 +++++++-
 test/lib/harness.c |   11 ++++++++++-
 test/lib/test.sh   |    7 +++++++
 3 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 5bbd1d6..d75bdf6 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -66,7 +66,13 @@ help:
 	@echo "  T			Run given test (regex)."
 	@echo "  VERBOSE		Verbose output (1), timing (2)."
 
-check: check_local check_cluster check_lvmetad
+check: .tests-stamp
+	VERBOSE=$(VEROSE) \
+	cluster_LVM_TEST_LOCKING=3 \
+	lvmetad_LVM_TEST_LVMETAD=1 \
+	./lib/harness $(patsubst %,normal:%,$(RUN_BASE)) \
+                      $(patsubst %,cluster:%,$(RUN_BASE)) \
+                      $(patsubst %,lvmetad:%,$(RUN_BASE))
 
 check_cluster: .tests-stamp
 	@echo Testing with locking_type 3
diff --git a/test/lib/harness.c b/test/lib/harness.c
index 929bfc8..d610bf8 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -286,7 +286,16 @@ static void run(int i, char *f) {
 			close(fds[0]);
 			close(fds[1]);
 		}
-		execlp("bash", "bash", f, NULL);
+		char flavour[512], script[512];
+		if (strchr(f, ':')) {
+			strcpy(flavour, f);
+			*strchr(flavour, ':') = 0;
+			setenv("LVM_TEST_FLAVOUR", flavour, 1);
+			strcpy(script, strchr(f, ':') + 1);
+		} else {
+			strcpy(script, f);
+		}
+		execlp("bash", "bash", script, NULL);
 		perror("execlp");
 		fflush(stderr);
 		_exit(202);
diff --git a/test/lib/test.sh b/test/lib/test.sh
index 3729749..7b92814 100644
--- a/test/lib/test.sh
+++ b/test/lib/test.sh
@@ -56,6 +56,13 @@ cd "$TESTDIR"
 
 echo "$TESTNAME" >TESTNAME
 
+if test -n "$LVM_TEST_FLAVOUR"; then
+    env | grep ^$LVM_TEST_FLAVOUR | while read var; do
+	(echo -n "export "; echo $var | sed -e s,^${LVM_TEST_FLAVOUR}_,,) >> flavour_overrides
+    done
+    . flavour_overrides
+fi
+
 # Setting up symlink from $i to $TESTDIR/lib
 find "$abs_top_builddir/daemons/dmeventd/plugins/" -name '*.so' \
 	-exec ln -s -t lib "{}" +


