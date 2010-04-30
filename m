From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Apr 2010 14:33:40 -0000
Subject: LVM2/test Makefile.in harness.c not.c
Message-ID: <20100430143340.21085.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-30 14:33:39

Modified files:
	test           : Makefile.in harness.c not.c 

Log message:
	Add a "should" alongside "not" to the test utilities. When a "should" command
	fails, the test will carry on but will issue a warning. The harness detects
	such warnings from tests and marks tests that passed with warnings with a
	special status.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/harness.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/not.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/Makefile.in	2010/04/13 13:28:53	1.38
+++ LVM2/test/Makefile.in	2010/04/30 14:33:39	1.39
@@ -62,6 +62,7 @@
 
 bin/not: $(srcdir)/not.c .bin-dir-stamp
 	$(CC) -o bin/not $<
+	ln -sf not bin/should
 
 bin/harness: $(srcdir)/harness.c .bin-dir-stamp
 	$(CC) -o bin/harness $<
--- LVM2/test/harness.c	2010/04/13 07:34:19	1.10
+++ LVM2/test/harness.c	2010/04/30 14:33:39	1.11
@@ -15,6 +15,7 @@
 	int nfailed;
 	int nskipped;
 	int npassed;
+	int nwarned;
 	int status[MAX];
 };
 
@@ -29,6 +30,7 @@
 #define PASSED 0
 #define SKIPPED 1
 #define FAILED 2
+#define WARNED 3
 
 void handler( int s ) {
 	signal( s, SIG_DFL );
@@ -59,13 +61,20 @@
 			exit(205);
 		memcpy(readbuf + readbuf_used, buf, sz);
 		readbuf_used += sz;
+		readbuf[readbuf_used] = 0;
 	}
 }
 
 void passed(int i, char *f) {
-	++ s.npassed;
-	s.status[i] = PASSED;
-	printf("passed.\n");
+	if (strstr(readbuf, "TEST WARNING")) {
+		++s.nwarned;
+		s.status[i] = WARNED;
+		printf("warnings\n");
+	} else {
+		++ s.npassed;
+		s.status[i] = PASSED;
+		printf("passed.\n");
+	}
 }
 
 void skipped(int i, char *f) {
@@ -140,7 +149,7 @@
 		exit(1);
 	}
 
-	s.nfailed = s.npassed = s.nskipped = 0;
+	s.nwarned = s.nfailed = s.npassed = s.nskipped = 0;
 
 	char *config = getenv("LVM_TEST_CONFIG"),
 	     *config_debug;
@@ -178,8 +187,9 @@
 		}
 	}
 
-	printf("\n## %d tests: %d OK, %d failed, %d skipped\n",
-	       s.npassed + s.nfailed + s.nskipped, s.npassed, s.nfailed, s.nskipped);
+	printf("\n## %d tests: %d OK, %d warnings, %d failures; %d skipped\n",
+	       s.nwarned + s.npassed + s.nfailed + s.nskipped,
+	       s.npassed, s.nwarned, s.nfailed, s.nskipped);
 
 	/* print out a summary */
 	if (s.nfailed || s.nskipped) {
--- LVM2/test/not.c	2009/02/17 19:37:28	1.2
+++ LVM2/test/not.c	2010/04/30 14:33:39	1.3
@@ -4,6 +4,16 @@
 #include <sys/types.h>
 #include <sys/wait.h>
 
+int finished(const char *cmd, int status) {
+	if (!strcmp(cmd, "not"))
+		return !status;
+	if (!strcmp(cmd, "should")) {
+		fprintf(stderr, "TEST WARNING: Ignoring command failure.\n");
+		return 0;
+	}
+	return 6;
+}
+
 int main(int args, char **argv) {
 	pid_t pid;
 	int status;
@@ -32,8 +42,8 @@
 			/* did not exit correctly */
 			return FAILURE;
 		}
-		/* return the opposite */
-		return !WEXITSTATUS(status);
+
+		return finished(argv[0], WEXITSTATUS(status));
 	}
 	/* not accessible */
 	return FAILURE;


