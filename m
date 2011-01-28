From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Jan 2011 16:05:38 -0000
Subject: LVM2/test/lib harness.c
Message-ID: <20110128160538.27414.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-28 16:05:38

Modified files:
	test/lib       : harness.c 

Log message:
	Display duration of tests when it passed.
	
	Enhance output with info about the test duration.
	Cleanup few declarations in the code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/harness.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/test/lib/harness.c	2011/01/13 15:03:28	1.5
+++ LVM2/test/lib/harness.c	2011/01/28 16:05:38	1.6
@@ -20,6 +20,7 @@
 #include <sys/wait.h>
 #include <unistd.h>
 #include <stdlib.h>
+#include <time.h>
 
 static pid_t pid;
 static int fds[2];
@@ -82,9 +83,9 @@
                 char *line = strndup(from, next - from);
                 char *a = line, *b;
                 do {
-                        b = line + strlen(line);
                         int idx = -1;
                         int i;
+                        b = line + strlen(line);
                         for ( i = 0; i < 2; ++i ) {
                                 if (subst[i].key) {
                                         // printf("trying: %s -> %s\n", subst[i].value, subst[i].key);
@@ -145,15 +146,24 @@
 	}
 }
 
-static void passed(int i, char *f) {
+static const char *duration(time_t start)
+{
+	static char buf[16];
+	int t = (int)(time(NULL) - start);
+
+	sprintf(buf, "%2d:%02d", t / 60, t % 60);
+	return buf;
+}
+
+static void passed(int i, char *f, time_t t) {
 	if (strstr(readbuf, "TEST WARNING")) {
 		++s.nwarned;
 		s.status[i] = WARNED;
-		printf("warnings\n");
+		printf("warnings  %s\n", duration(t));
 	} else {
 		++ s.npassed;
 		s.status[i] = PASSED;
-		printf("passed.\n");
+		printf("passed.   %s\n", duration(t));
 	}
 }
 
@@ -192,12 +202,13 @@
 		fflush(stderr);
 		_exit(202);
 	} else {
+		int st, w;
+		time_t start = time(NULL);
 		char buf[128];
 		snprintf(buf, 128, "%s ...", f);
 		buf[127] = 0;
 		printf("Running %-40s ", buf);
 		fflush(stdout);
-		int st, w;
 		while ((w = waitpid(pid, &st, WNOHANG)) == 0) {
 			drain();
 			usleep(20000);
@@ -209,7 +220,7 @@
 		drain();
 		if (WIFEXITED(st)) {
 			if (WEXITSTATUS(st) == 0) {
-				passed(i, f);
+				passed(i, f, start);
 			} else if (WEXITSTATUS(st) == 200) {
 				skipped(i, f);
 			} else {
@@ -223,6 +234,8 @@
 }
 
 int main(int argc, char **argv) {
+	const char *be_verbose = getenv("VERBOSE");
+	time_t start = time(NULL);
 	int i;
 
 	if (argc >= MAX) {
@@ -230,9 +243,6 @@
 		exit(1);
 	}
 
-	s.nwarned = s.nfailed = s.npassed = s.nskipped = 0;
-
-	char *be_verbose = getenv("VERBOSE");
 	if (be_verbose && atoi(be_verbose))
 		verbose = 1; // XXX
 
@@ -260,8 +270,9 @@
 			break;
 	}
 
-	printf("\n## %d tests: %d OK, %d warnings, %d failures; %d skipped\n",
+	printf("\n## %d tests %s : %d OK, %d warnings, %d failures; %d skipped\n",
 	       s.nwarned + s.npassed + s.nfailed + s.nskipped,
+	       duration(start),
 	       s.npassed, s.nwarned, s.nfailed, s.nskipped);
 
 	/* print out a summary */
@@ -279,5 +290,6 @@
 		printf("\n");
 		return s.nfailed > 0 || die;
 	}
+
 	return die;
 }


