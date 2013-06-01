From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat,  1 Jun 2013 22:51:44 +0000 (UTC)
Subject: master - tests: run all the test flavours in a single batch
Message-ID: <20130601225144.AA27D613D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7c89cbf03a15fe30de520d50c214cd3878518e45
Commit:        7c89cbf03a15fe30de520d50c214cd3878518e45
Parent:        53fbf2bea3e992f1c21f5f77eacc687ce01143f5
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 27 03:12:03 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 2 00:50:09 2013 +0200

tests: run all the test flavours in a single batch

This means that a test failure in one flavour no longer prevents all the
subsequent flavours from running. We also get an aggregate summary at
the end of the entire batch, instead of summaries interspersed with
progress output. Do not fail when flavour overrides are empty
---
 test/Makefile.in   |    8 +++++++-
 test/lib/harness.c |   11 ++++++++++-
 test/lib/test.sh   |    8 ++++++++
 3 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 5bbd1d6..938dc1d 100644
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
+		      $(patsubst %,cluster:%,$(RUN_BASE)) \
+		      $(patsubst %,lvmetad:%,$(RUN_BASE))
 
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
index 3729749..9a56a0f 100644
--- a/test/lib/test.sh
+++ b/test/lib/test.sh
@@ -56,6 +56,14 @@ cd "$TESTDIR"
 
 echo "$TESTNAME" >TESTNAME
 
+if test -n "$LVM_TEST_FLAVOUR"; then
+	touch flavour_overrides
+	env | grep ^$LVM_TEST_FLAVOUR | while read var; do
+		(echo -n "export "; echo $var | sed -e s,^${LVM_TEST_FLAVOUR}_,,) >> flavour_overrides
+	done
+	. flavour_overrides
+fi
+
 # Setting up symlink from $i to $TESTDIR/lib
 find "$abs_top_builddir/daemons/dmeventd/plugins/" -name '*.so' \
 	-exec ln -s -t lib "{}" +


