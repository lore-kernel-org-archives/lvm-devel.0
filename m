From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  4 Dec 2013 20:38:38 +0000 (UTC)
Subject: master - tests: drop RUN... already have this var elsewhere
Message-ID: <20131204203838.55E94602C2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=76ca82df827c83c475a4eb8edb7bb670528cf6e7
Commit:        76ca82df827c83c475a4eb8edb7bb670528cf6e7
Parent:        d9461ae89bd725c24448ce84c7e5c7ea9cb7e29e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 4 21:37:33 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 4 21:37:33 2013 +0100

tests: drop RUN... already have this var elsewhere

---
 test/lib/harness.c |    4 +---
 test/lib/test.sh   |    1 -
 2 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index bcc6b97..4b7686d 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -98,13 +98,11 @@ static int outline(FILE *out, char *buf, int start, int force) {
 		subst[0].key = "@TESTDIR@";
 		free(subst[0].value);
 		subst[0].value = strndup(from + 9, next - from - 9 - 1);
+		snprintf(testdirdebug, sizeof(testdirdebug), "%s/debug.log", subst[0].value);
 	} else if (!strncmp(from, "@PREFIX=", 8)) {
 		subst[1].key = "@PREFIX@";
 		free(subst[1].value);
 		subst[1].value = strndup(from + 8, next - from - 8 - 1);
-	} else if (!testdirdebug[0] && !strncmp(from, "RUNTESTDIR=", 11)) {
-		from[strlen(from) - 1] = '\0'; /* Cut \n */
-		snprintf(testdirdebug, sizeof(testdirdebug), "%s/debug.log", from + 11);
 	} else {
 		char *line = strndup(from, next - from);
 		char *a = line, *b;
diff --git a/test/lib/test.sh b/test/lib/test.sh
index 9e25e26..265d61d 100644
--- a/test/lib/test.sh
+++ b/test/lib/test.sh
@@ -39,7 +39,6 @@ test -n "$BASH" && trap 'set +vx; STACKTRACE; set -vx' ERR
 trap 'aux teardown' EXIT # don't forget to clean up
 
 cd "$TESTDIR"
-echo "RUNTESTDIR=$TESTDIR"
 
 if test -n "$LVM_TEST_FLAVOUR"; then
 	touch flavour_overrides


