From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 13 Jun 2013 12:52:02 +0000 (UTC)
Subject: master - tests: harness updates
Message-ID: <20130613125202.B289361469@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fa5d4bc7807c8ab84e65304e52532ee05ee4e172
Commit:        fa5d4bc7807c8ab84e65304e52532ee05ee4e172
Parent:        036d4f2982e8b1c34a7594307c6d2ae98cd36237
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 12 14:16:25 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 13 14:51:02 2013 +0200

tests: harness updates

---
 test/lib/harness.c |   23 +++++++++++++++--------
 1 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index 696d011..cea9a15 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -93,9 +93,11 @@ static int outline(FILE *out, char *buf, int start, int force) {
 
 	if (!strncmp(from, "@TESTDIR=", 9)) {
 		subst[0].key = "@TESTDIR@";
+		free(subst[0].value);
 		subst[0].value = strndup(from + 9, next - from - 9 - 1);
 	} else if (!strncmp(from, "@PREFIX=", 8)) {
 		subst[1].key = "@PREFIX@";
+		free(subst[1].value);
 		subst[1].value = strndup(from + 8, next - from - 8 - 1);
 	} else {
 		char *line = strndup(from, next - from);
@@ -150,6 +152,7 @@ static void trickle(FILE *out, int *last, int *counter) {
 
 static void clear(void) {
 	readbuf_used = 0;
+	fullbuffer = 0;
 }
 
 static int64_t _get_time_us(void)
@@ -389,13 +392,14 @@ static void run(int i, char *f) {
 				failed(i, f, st);
 		} else
 			failed(i, f, st);
-		clear();
+
 		if (outfile)
 			fclose(outfile);
 		if (fullbuffer)
 			printf("\nTest was interrupted, output has got too large (>%u) (loop:%u)\n"
 			       "Set LVM_TEST_UNLIMITED=1 for unlimited log.\n",
 			       (unsigned) readbuf_sz, fullbuffer);
+		clear();
 	}
 }
 
@@ -433,16 +437,21 @@ int main(int argc, char **argv) {
 	}
 
 	/* set up signal handlers */
-	for (i = 0; i <= 32; ++i) {
-		if (i == SIGCHLD || i == SIGWINCH || i == SIGURG)
-			continue;
-		signal(i, handler);
-	}
+	for (i = 0; i <= 32; ++i)
+		switch (i) {
+		case SIGCHLD: case SIGWINCH: case SIGURG:
+		case SIGKILL: case SIGSTOP: break;
+		default: signal(i, handler);
+		}
 
 	/* run the tests */
 	for (i = 1; !die && i < argc; ++i)
 		run(i, argv[i]);
 
+	free(subst[0].value);
+	free(subst[1].value);
+	free(readbuf);
+
 	printf("\n## %d tests %s : %d OK, %d warnings, %d failures, %d known failures; "
 	       "%d skipped, %d interrupted\n",
 	       s.nwarned + s.npassed + s.nfailed + s.nskipped + s.ninterrupted,
@@ -490,7 +499,5 @@ int main(int argc, char **argv) {
 		return (s.nfailed > 0) || (s.ninterrupted > 0) || die;
 	}
 
-	free(readbuf);
-
 	return die;
 }


