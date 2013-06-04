From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  4 Jun 2013 13:58:36 +0000 (UTC)
Subject: master - tests: configurable LVM_TEST_RESULTS
Message-ID: <20130604135836.7B4336031C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=325ca748bb1abf1ff41cbd83f96b27ee020b4304
Commit:        325ca748bb1abf1ff41cbd83f96b27ee020b4304
Parent:        9b2be901ed55ff309da8e94879cacb560f21dc2b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 3 12:07:31 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 4 15:57:18 2013 +0200

tests: configurable  LVM_TEST_RESULTS

Make LVM_TEST_RESULTS configurable
Cleanup results dir on 'make clean'
---
 test/Makefile.in   |    7 +++-
 test/lib/harness.c |   85 +++++++++++++++++++++++++++++----------------------
 2 files changed, 53 insertions(+), 39 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 1bd1dbd..b799f83 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -1,4 +1,4 @@
-# Copyright (C) 2007-2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2013 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -24,6 +24,7 @@ abs_builddir = "@abs_builddir@"
 abs_top_builddir = "@abs_top_builddir@"
 abs_top_srcdir = "@abs_top_srcdir@"
 
+LVM_TEST_RESULTS ?= results
 SUBDIRS = api unit
 SOURCES = lib/not.c lib/harness.c
 
@@ -61,6 +62,7 @@ help:
 	@echo "  LVM_TEST_LVMETAD	Start lvmetad (1)."
 	@echo "  LVM_TEST_NODEBUG	Do not debug lvm commands."
 	@echo "  LVM_TEST_PARALLEL	May skip agresive wipe of LVMTEST resources."
+	@echo "  LVM_TEST_RESULTS	Where to create result files [results]."
 	@echo "  LVM_VERIFY_UDEV	Default verify state for lvm.conf."
 	@echo "  S			Skip given test (regex)."
 	@echo "  T			Run given test (regex)."
@@ -122,7 +124,7 @@ CMDS = lvm $(shell cat $(top_builddir)/tools/.commands)
 			ln -sf $(abs_top_srcdir)/test/$$f $$f; \
 		done; \
 	fi
-	mkdir -p results
+	$(MKDIR_P) -m a=rwx $(LVM_TEST_RESULTS)
 	touch $@
 
 .lib-dir-stamp:
@@ -138,6 +140,7 @@ CMDS = lvm $(shell cat $(top_builddir)/tools/.commands)
 
 clean:
 	test "$(srcdir)" = . || $(RM) $(RUN_BASE)
+	$(RM) -r $(LVM_TEST_RESULTS)
 
 CLEAN_TARGETS += .lib-dir-stamp .tests-stamp $(LIB) $(addprefix lib/,$(CMDS)) \
 	lib/clvmd lib/dmeventd lib/dmsetup lib/lvmetad lib/fsadm lib/vgimportclone
diff --git a/test/lib/harness.c b/test/lib/harness.c
index e98c7d6..ece36ec 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -22,6 +22,7 @@
 #include <stdlib.h>
 #include <time.h>
 #include <sys/time.h>
+#include <limits.h>
 
 static pid_t pid;
 static int fds[2];
@@ -45,6 +46,7 @@ static int readbuf_sz = 0, readbuf_used = 0;
 static int die = 0;
 static int verbose = 0; /* >1 with timestamps */
 static int interactive = 0; /* disable all redirections */
+static const char *results;
 
 static FILE *outfile = NULL;
 
@@ -308,45 +310,48 @@ static void run(int i, char *f) {
 		int st, w;
 		time_t start = time(NULL);
 		char buf[128];
-		snprintf(buf, 128, "%s ...", f);
-		buf[127] = 0;
+		char outpath[PATH_MAX];
+		char *c = outpath + strlen(results) + 1;
+		snprintf(buf, sizeof(buf), "%s ...", f);
 		printf("Running %-60s ", buf);
 		fflush(stdout);
-		char outpath[512];
-		sprintf(outpath, "results/%s.txt", f);
-		while (strchr(outpath + 8, '/'))
-			*strchr(outpath + 8, '/') = '_';
-		outfile = fopen(outpath, "w");
-		while ((w = waitpid(pid, &st, WNOHANG)) == 0) {
+		snprintf(outpath, sizeof(outpath), "%s/%s.txt", results, f);
+		while ((c = strchr(c, '/')))
+			*c = '_';
+		if ((outfile = fopen(outpath, "w"))) {
+			while ((w = waitpid(pid, &st, WNOHANG)) == 0) {
+				drain();
+				usleep(20000);
+			}
+			if (w != pid) {
+				perror("waitpid");
+				exit(206);
+			}
 			drain();
-			usleep(20000);
-		}
-		if (w != pid) {
-			perror("waitpid");
-			exit(206);
-		}
-		drain();
-		if (WIFEXITED(st)) {
-			if (WEXITSTATUS(st) == 0) {
-				passed(i, f, start);
-			} else if (WEXITSTATUS(st) == 200) {
-				skipped(i, f);
-			} else {
+			if (WIFEXITED(st)) {
+				if (WEXITSTATUS(st) == 0)
+					passed(i, f, start);
+				else if (WEXITSTATUS(st) == 200)
+					skipped(i, f);
+				else
+					failed(i, f, st);
+			} else
 				failed(i, f, st);
-			}
-		} else {
-			failed(i, f, st);
+
+			clear();
+			fclose(outfile);
 		}
-		clear();
-		fclose(outfile);
 	}
 }
 
 int main(int argc, char **argv) {
+	char results_list[PATH_MAX];
+	const char *result;
 	const char *be_verbose = getenv("VERBOSE"),
 		   *be_interactive = getenv("INTERACTIVE");
 	time_t start = time(NULL);
 	int i;
+	FILE *list;
 
 	if (argc >= MAX) {
 		fprintf(stderr, "Sorry, my head exploded. Please increase MAX.\n");
@@ -359,6 +364,10 @@ int main(int argc, char **argv) {
 	if (be_interactive)
 		interactive = atoi(be_interactive);
 
+	if (!(results = getenv("LVM_TEST_RESULTS")))
+		results = "results";
+	snprintf(results_list, sizeof(results_list), "%s/list", results);
+
 	if (socketpair(PF_UNIX, SOCK_STREAM, 0, fds)) {
 		perror("socketpair");
 		return 201;
@@ -389,18 +398,20 @@ int main(int argc, char **argv) {
 	       s.npassed, s.nwarned, s.nfailed, s.nknownfail, s.nskipped);
 
 	/* dump a list to results */
-	FILE *list = fopen("results/list", "w");
-	for (i = 1; i < argc; ++ i) {
-		const char *result = "unknown";
-		switch (s.status[i]) {
-		case PASSED: result = "passed"; break;
-		case FAILED: result = "failed"; break;
-		case SKIPPED: result = "skipped"; break;
-		case WARNED: result = "warnings"; break;
+	if ((list = fopen(results_list, "w"))) {
+		for (i = 1; i < argc; ++ i) {
+			switch (s.status[i]) {
+			case PASSED: result = "passed"; break;
+			case FAILED: result = "failed"; break;
+			case SKIPPED: result = "skipped"; break;
+			case WARNED: result = "warnings"; break;
+			default: result = "unknown"; break;
+			}
+			fprintf(list, "%s %s\n", argv[i], result);
 		}
-		fprintf(list, "%s %s\n", argv[i], result);
-	}
-	fclose(list);
+		fclose(list);
+	} else
+		perror("fopen result");
 
 	/* print out a summary */
 	if (s.nfailed || s.nskipped || s.nknownfail) {


