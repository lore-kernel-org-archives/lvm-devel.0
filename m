From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat,  1 Jun 2013 22:51:46 +0000 (UTC)
Subject: master - tests: collect all test results in files
Message-ID: <20130601225146.BA5B6613D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=65a0650135bef9bae9ce3a168e9ab2a8d9b70673
Commit:        65a0650135bef9bae9ce3a168e9ab2a8d9b70673
Parent:        7c89cbf03a15fe30de520d50c214cd3878518e45
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 27 04:26:33 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 2 00:50:09 2013 +0200

tests: collect all test results in files

Use files  for later processing with suffix .txt
to avoid mime type confusion.
---
 test/Makefile.in   |    1 +
 test/lib/harness.c |   53 ++++++++++++++++++++++++++++++++++++++-------------
 2 files changed, 40 insertions(+), 14 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 938dc1d..1bd1dbd 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -122,6 +122,7 @@ CMDS = lvm $(shell cat $(top_builddir)/tools/.commands)
 			ln -sf $(abs_top_srcdir)/test/$$f $$f; \
 		done; \
 	fi
+	mkdir -p results
 	touch $@
 
 .lib-dir-stamp:
diff --git a/test/lib/harness.c b/test/lib/harness.c
index d610bf8..e80efbf 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -46,6 +46,8 @@ static int die = 0;
 static int verbose = 0; /* >1 with timestamps */
 static int interactive = 0; /* disable all redirections */
 
+static FILE *outfile = NULL;
+
 struct subst {
 	const char *key;
 	char *value;
@@ -65,7 +67,7 @@ static void handler( int sig ) {
 	die = sig;
 }
 
-static int outline(char *buf, int start, int force) {
+static int outline(FILE *out, char *buf, int start, int force) {
 	char *from = buf + start;
 	char *next = strchr(buf + start, '\n');
 
@@ -100,11 +102,11 @@ static int outline(char *buf, int start, int force) {
 					}
 				}
 			}
-			fwrite(a, 1, b - a, stdout);
+			fwrite(a, 1, b - a, out);
 			a = b;
 
 			if ( idx >= 0 ) {
-				fprintf(stdout, "%s", subst[idx].key);
+				fprintf(out, "%s", subst[idx].key);
 				a += strlen(subst[idx].value);
 			}
 		} while (b < line + strlen(line));
@@ -119,20 +121,18 @@ static void dump(void) {
 
 	while ( counter < readbuf_used && counter != counter_last ) {
 		counter_last = counter;
-		counter = outline( readbuf, counter, 1 );
+		counter = outline( stdout, readbuf, counter, 1 );
 	}
 }
 
-static void trickle(void) {
-	static int counter_last = -1, counter = 0;
-
-	if (counter_last > readbuf_used) {
-		counter_last = -1;
-		counter = 0;
+static void trickle(FILE *out, int *last, int *counter) {
+	if (*last > readbuf_used) {
+		*last = -1;
+		*counter = 0;
 	}
-	while ( counter < readbuf_used && counter != counter_last ) {
-		counter_last = counter;
-		counter = outline( readbuf, counter, 1 );
+	while ( *counter < readbuf_used && *counter != *last ) {
+		*last = *counter;
+		*counter = outline( out, readbuf, *counter, 1 );
 	}
 }
 
@@ -203,6 +203,9 @@ static void drain(void) {
 	int stamp = 0;
 	int sz;
 
+	static int stdout_last = -1, stdout_counter = 0;
+	static int outfile_last = -1, outfile_counter = 0;
+
 	while ((sz = read(fds[1], buf, sizeof(buf) - 1)) > 0) {
 		buf[sz] = '\0';
 		bp = (verbose < 2) ? buf : _append_with_stamp(buf, stamp);
@@ -216,7 +219,9 @@ static void drain(void) {
 		readbuf[readbuf_used] = 0;
 
 		if (verbose)
-			trickle();
+			trickle(stdout, &stdout_last, &stdout_counter);
+		if (outfile)
+			trickle(outfile, &outfile_last, &outfile_counter);
 	}
 }
 
@@ -307,6 +312,11 @@ static void run(int i, char *f) {
 		buf[127] = 0;
 		printf("Running %-50s ", buf);
 		fflush(stdout);
+		char outpath[512];
+		sprintf(outpath, "results/%s.txt", f);
+		while (strchr(outpath + 8, '/'))
+			*strchr(outpath + 8, '/') = '_';
+		outfile = fopen(outpath, "w");
 		while ((w = waitpid(pid, &st, WNOHANG)) == 0) {
 			drain();
 			usleep(20000);
@@ -328,6 +338,7 @@ static void run(int i, char *f) {
 			failed(i, f, st);
 		}
 		clear();
+		fclose(outfile);
 	}
 }
 
@@ -377,6 +388,20 @@ int main(int argc, char **argv) {
 	       duration(start),
 	       s.npassed, s.nwarned, s.nfailed, s.nknownfail, s.nskipped);
 
+	/* dump a list to results */
+	FILE *list = fopen("results/list", "w");
+	for (i = 1; i < argc; ++ i) {
+		const char *result = "unknown";
+		switch (s.status[i]) {
+		case PASSED: result = "passed"; break;
+		case FAILED: result = "failed"; break;
+		case SKIPPED: result = "skipped"; break;
+		case WARNED: result = "warnings"; break;
+		}
+		fprintf(list, "%s %s\n", argv[i], result);
+	}
+	fclose(list);
+
 	/* print out a summary */
 	if (s.nfailed || s.nskipped || s.nknownfail) {
 		for (i = 1; i < argc; ++ i) {


