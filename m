From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Jun 2013 12:09:14 +0000 (UTC)
Subject: master - tests: extend harness
Message-ID: <20130611120914.B6F6560DC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4937df4aed699a5e3bc3c860e897fa0e448cfc6b
Commit:        4937df4aed699a5e3bc3c860e897fa0e448cfc6b
Parent:        c888c925b8d561158c3cea6d4f5ea4e173848c00
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 8 22:23:39 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 11 14:07:51 2013 +0200

tests: extend harness

Add limit for buffer so if the test is running in some loop
and generating lots of output, the output log gets too large
for browser to display  (at least Firefox is quite confused
to display 300MB logs).

For now limit max output of one test to 32MB.
If there is need to see full log set LVM_TEST_UNLIMITED to
disable interruption of test.

harness now also prints max memory used during test,
it user and system time and amount of read/write operations.
---
 test/Makefile.in   |    3 +-
 test/lib/harness.c |  163 ++++++++++++++++++++++++++++++++++------------------
 2 files changed, 110 insertions(+), 56 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index b799f83..89092d0 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -63,6 +63,7 @@ help:
 	@echo "  LVM_TEST_NODEBUG	Do not debug lvm commands."
 	@echo "  LVM_TEST_PARALLEL	May skip agresive wipe of LVMTEST resources."
 	@echo "  LVM_TEST_RESULTS	Where to create result files [results]."
+	@echo "  LVM_TEST_UNLIMITED	Set to get unlimited test log (>32MB)"
 	@echo "  LVM_VERIFY_UDEV	Default verify state for lvm.conf."
 	@echo "  S			Skip given test (regex)."
 	@echo "  T			Run given test (regex)."
@@ -124,7 +125,7 @@ CMDS = lvm $(shell cat $(top_builddir)/tools/.commands)
 			ln -sf $(abs_top_srcdir)/test/$$f $$f; \
 		done; \
 	fi
-	$(MKDIR_P) -m a=rwx $(LVM_TEST_RESULTS)
+	@$(MKDIR_P) -m a=rwx $(LVM_TEST_RESULTS)
 	touch $@
 
 .lib-dir-stamp:
diff --git a/test/lib/harness.c b/test/lib/harness.c
index 2377116..696d011 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2010-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2010-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -14,20 +14,24 @@
 
 #define _GNU_SOURCE
 #include <fcntl.h>
-#include <string.h>
+#include <limits.h>
 #include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/resource.h> /* rusage */
+#include <sys/select.h>
 #include <sys/socket.h>
+#include <sys/time.h>
+#include <sys/types.h>
 #include <sys/wait.h>
-#include <unistd.h>
-#include <stdlib.h>
 #include <time.h>
-#include <sys/time.h>
-#include <limits.h>
+#include <unistd.h>
 
 static pid_t pid;
 static int fds[2];
 
 #define MAX 1024
+#define MAX_LOG_SIZE (32*1024*1024) /* Default max size of test log */
 
 struct stats {
 	int nfailed;
@@ -35,6 +39,7 @@ struct stats {
 	int npassed;
 	int nknownfail;
 	int nwarned;
+	int ninterrupted;
 	int status[MAX];
 };
 
@@ -47,6 +52,7 @@ static int die = 0;
 static int verbose = 0; /* >1 with timestamps */
 static int interactive = 0; /* disable all redirections */
 static const char *results;
+static unsigned fullbuffer = 0;
 
 static FILE *outfile = NULL;
 
@@ -64,6 +70,7 @@ enum {
 	FAILED,
 	WARNED,
 	KNOWNFAIL,
+	INTERRUPTED,
 };
 
 static void handler( int sig ) {
@@ -156,6 +163,12 @@ static int64_t _get_time_us(void)
 static void _append_buf(const char *buf, size_t len)
 {
 	if ((readbuf_used + len) >= readbuf_sz) {
+		if ((readbuf_sz >= MAX_LOG_SIZE) &&
+		    !getenv("LVM_TEST_UNLIMITED")) {
+			if (fullbuffer++ ==  0)
+				kill(pid, SIGINT);
+			return;
+		}
 		readbuf_sz = readbuf_sz ? 2 * readbuf_sz : 4096;
 		readbuf = realloc(readbuf, readbuf_sz);
 	}
@@ -212,9 +225,10 @@ static void drain(void) {
 	static int outfile_last = -1, outfile_counter = 0;
 
 	while ((sz = read(fds[1], buf, sizeof(buf) - 1)) > 0) {
+		if (fullbuffer)
+			continue;
 		buf[sz] = '\0';
 		bp = (verbose < 2) ? buf : _append_with_stamp(buf, stamp);
-
 		if (sz > (bp - buf)) {
 			_append_buf(bp, sz - (bp - buf));
 			stamp = -1; /* unfinished line */
@@ -230,28 +244,49 @@ static void drain(void) {
 	}
 }
 
-static const char *duration(time_t start)
+static const char *duration(time_t start, const struct rusage *usage)
 {
-	static char buf[16];
+	static char buf[100];
 	int t = (int)(time(NULL) - start);
 
-	sprintf(buf, "%2d:%02d", t / 60, t % 60);
+	int p = sprintf(buf, "%2d:%02d", t / 60, t % 60);
+
+	if (usage)
+		sprintf(buf + p, "   %2ld:%02ld.%03ld/%ld:%02ld.%03ld%5ld%8ld/%ld",
+			usage->ru_utime.tv_sec / 60, usage->ru_utime.tv_sec % 60,
+			usage->ru_utime.tv_usec / 1000,
+			usage->ru_stime.tv_sec / 60, usage->ru_stime.tv_sec % 60,
+			usage->ru_stime.tv_usec / 1000,
+			usage->ru_maxrss / 1024,
+			usage->ru_inblock, usage->ru_oublock);
+
 	return buf;
 }
 
-static void passed(int i, char *f, time_t t) {
+static void passed(int i, char *f, time_t t, const struct rusage *usage) {
 	if (readbuf && strstr(readbuf, "TEST EXPECT FAIL")) {
 		++ s.npassed;
 		s.status[i] = PASSED;
-		printf("passed (UNEXPECTED). %s\n", duration(t));
+		printf("passed (UNEXPECTED). %s\n", duration(t, usage));
 	} else if (readbuf && strstr(readbuf, "TEST WARNING")) {
 		++s.nwarned;
 		s.status[i] = WARNED;
-		printf("warnings  %s\n", duration(t));
+		printf("warnings  %s\n", duration(t, usage));
 	} else {
 		++ s.npassed;
 		s.status[i] = PASSED;
-		printf("passed.   %s\n", duration(t));
+		printf("passed.   %s\n", duration(t, usage));
+	}
+}
+
+static void interrupted(int i, char *f) {
+	++ s.ninterrupted;
+	s.status[i] = INTERRUPTED;
+	printf("\ninterrupted.\n");
+	if (!verbose && fullbuffer) {
+		printf("-- Interrupted %s ------------------------------------\n", f);
+		dump();
+		printf("\n-- Interrupted %s (end) ------------------------------\n", f);
 	}
 }
 
@@ -271,12 +306,8 @@ static void failed(int i, char *f, int st) {
 
 	++ s.nfailed;
 	s.status[i] = FAILED;
-	if(die == 2) {
-		printf("interrupted.\n");
-		return;
-	}
 	printf("FAILED.\n");
-	if (!verbose) {
+	if (!verbose && readbuf) {
 		printf("-- FAILED %s ------------------------------------\n", f);
 		dump();
 		printf("-- FAILED %s (end) ------------------------------\n", f);
@@ -284,6 +315,7 @@ static void failed(int i, char *f, int st) {
 }
 
 static void run(int i, char *f) {
+	struct rusage usage;
 	char flavour[512], script[512];
 
 	pid = fork();
@@ -306,45 +338,64 @@ static void run(int i, char *f) {
 		} else {
 			strcpy(script, f);
 		}
-		execlp("bash", "bash", script, NULL);
+		execlp("bash", "bash", "-noprofile", "-norc", script, NULL);
 		perror("execlp");
 		fflush(stderr);
 		_exit(202);
 	} else {
-		int st, w;
+		int st = -1, w;
 		time_t start = time(NULL);
 		char buf[128];
 		char outpath[PATH_MAX];
 		char *c = outpath + strlen(results) + 1;
+		struct timeval timeout;
+		fd_set master_set, copy_set;
+
 		snprintf(buf, sizeof(buf), "%s ...", f);
 		printf("Running %-60s ", buf);
 		fflush(stdout);
 		snprintf(outpath, sizeof(outpath), "%s/%s.txt", results, f);
 		while ((c = strchr(c, '/')))
 			*c = '_';
-		if ((outfile = fopen(outpath, "w"))) {
-			while ((w = waitpid(pid, &st, WNOHANG)) == 0) {
-				drain();
-				usleep(20000);
-			}
-			if (w != pid) {
-				perror("waitpid");
-				exit(206);
-			}
+		if (!(outfile = fopen(outpath, "w")))
+			perror("fopen");
+
+		FD_ZERO(&master_set);
+		FD_SET(fds[1], &master_set);
+		while ((w = wait4(pid, &st, WNOHANG, &usage)) == 0) {
+			if (fullbuffer && fullbuffer++ == 8000)
+				/* Output doesn't won't to stop... */
+				kill(pid, SIGKILL);
+			memcpy(&copy_set, &master_set, sizeof(master_set));
+			timeout.tv_sec = 0;
+			timeout.tv_usec = 500000;
+			if (select(fds[1] + 1, &copy_set, NULL, NULL, &timeout) <= 0)
+				continue;
 			drain();
-			if (WIFEXITED(st)) {
-				if (WEXITSTATUS(st) == 0)
-					passed(i, f, start);
-				else if (WEXITSTATUS(st) == 200)
-					skipped(i, f);
-				else
-					failed(i, f, st);
-			} else
+		}
+		if (w != pid) {
+			perror("waitpid");
+			exit(206);
+		}
+		drain();
+		if (fullbuffer || (die == 2))
+			interrupted(i, f);
+		else if (WIFEXITED(st)) {
+			if (WEXITSTATUS(st) == 0)
+				passed(i, f, start, &usage);
+			else if (WEXITSTATUS(st) == 200)
+				skipped(i, f);
+			else
 				failed(i, f, st);
-
-			clear();
+		} else
+			failed(i, f, st);
+		clear();
+		if (outfile)
 			fclose(outfile);
-		}
+		if (fullbuffer)
+			printf("\nTest was interrupted, output has got too large (>%u) (loop:%u)\n"
+			       "Set LVM_TEST_UNLIMITED=1 for unlimited log.\n",
+			       (unsigned) readbuf_sz, fullbuffer);
 	}
 }
 
@@ -368,16 +419,15 @@ int main(int argc, char **argv) {
 	if (be_interactive)
 		interactive = atoi(be_interactive);
 
-	if (!(results = getenv("LVM_TEST_RESULTS")))
-		results = "results";
-	snprintf(results_list, sizeof(results_list), "%s/list", results);
+	results = getenv("LVM_TEST_RESULTS") ? : "results";
+	(void) snprintf(results_list, sizeof(results_list), "%s/list", results);
 
 	if (socketpair(PF_UNIX, SOCK_STREAM, 0, fds)) {
 		perror("socketpair");
 		return 201;
 	}
 
-        if ( fcntl( fds[1], F_SETFL, O_NONBLOCK ) == -1 ) {
+	if (fcntl(fds[1], F_SETFL, O_NONBLOCK ) == -1) {
 		perror("fcntl on socket");
 		return 202;
 	}
@@ -390,16 +440,15 @@ int main(int argc, char **argv) {
 	}
 
 	/* run the tests */
-	for (i = 1; i < argc; ++ i) {
+	for (i = 1; !die && i < argc; ++i)
 		run(i, argv[i]);
-		if (die)
-			break;
-	}
 
-	printf("\n## %d tests %s : %d OK, %d warnings, %d failures, %d known failures; %d skipped\n",
-	       s.nwarned + s.npassed + s.nfailed + s.nskipped,
-	       duration(start),
-	       s.npassed, s.nwarned, s.nfailed, s.nknownfail, s.nskipped);
+	printf("\n## %d tests %s : %d OK, %d warnings, %d failures, %d known failures; "
+	       "%d skipped, %d interrupted\n",
+	       s.nwarned + s.npassed + s.nfailed + s.nskipped + s.ninterrupted,
+	       duration(start, NULL),
+	       s.npassed, s.nwarned, s.nfailed, s.nknownfail,
+	       s.nskipped, s.ninterrupted);
 
 	/* dump a list to results */
 	if ((list = fopen(results_list, "w"))) {
@@ -409,6 +458,7 @@ int main(int argc, char **argv) {
 			case FAILED: result = "failed"; break;
 			case SKIPPED: result = "skipped"; break;
 			case WARNED: result = "warnings"; break;
+			case INTERRUPTED: result = "interrupted"; break;
 			default: result = "unknown"; break;
 			}
 			fprintf(list, "%s %s\n", argv[i], result);
@@ -418,7 +468,7 @@ int main(int argc, char **argv) {
 		perror("fopen result");
 
 	/* print out a summary */
-	if (s.nfailed || s.nskipped || s.nknownfail) {
+	if (s.nfailed || s.nskipped || s.nknownfail || s.ninterrupted) {
 		for (i = 1; i < argc; ++ i) {
 			switch (s.status[i]) {
 			case FAILED:
@@ -430,11 +480,14 @@ int main(int argc, char **argv) {
 			case SKIPPED:
 				printf("skipped: %s\n", argv[i]);
 				break;
+			case INTERRUPTED:
+				printf("interrupted: %s\n", argv[i]);
+				break;
 			default: /* do nothing */ ;
 			}
 		}
 		printf("\n");
-		return s.nfailed > 0 || die;
+		return (s.nfailed > 0) || (s.ninterrupted > 0) || die;
 	}
 
 	free(readbuf);


