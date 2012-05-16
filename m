From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 16 May 2012 10:43:42 -0000
Subject: LVM2/test/lib aux.sh harness.c
Message-ID: <20120516104342.27708.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-05-16 10:43:42

Modified files:
	test/lib       : aux.sh harness.c 

Log message:
	Add provisions to flag tests that we know will fail, without flagging the build
	(i.e. an expected failure).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/harness.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/test/lib/aux.sh	2012/03/28 11:10:09	1.49
+++ LVM2/test/lib/aux.sh	2012/05/16 10:43:41	1.50
@@ -17,6 +17,10 @@
 	exec "${VALGRIND:-valg}" "$@"
 }
 
+expect_failure() {
+        echo "TEST EXPECT FAILURE"
+}
+
 prepare_clvmd() {
 	test "${LVM_TEST_LOCKING:-0}" -ne 3 && return # not needed
 
--- LVM2/test/lib/harness.c	2012/03/12 14:24:15	1.12
+++ LVM2/test/lib/harness.c	2012/05/16 10:43:41	1.13
@@ -32,6 +32,7 @@
 	int nfailed;
 	int nskipped;
 	int npassed;
+	int nknownfail;
 	int nwarned;
 	int status[MAX];
 };
@@ -55,6 +56,7 @@
 #define SKIPPED 1
 #define FAILED 2
 #define WARNED 3
+#define KNOWNFAIL 4
 
 static void handler( int sig ) {
 	signal( sig, SIG_DFL );
@@ -227,7 +229,11 @@
 }
 
 static void passed(int i, char *f, time_t t) {
-	if (readbuf && strstr(readbuf, "TEST WARNING")) {
+	if (readbuf && strstr(readbuf, "TEST EXPECT FAIL")) {
+		++ s.npassed;
+		s.status[i] = PASSED;
+		printf("passed (UNEXPECTED). %s\n", duration(t));
+	} else if (readbuf && strstr(readbuf, "TEST WARNING")) {
 		++s.nwarned;
 		s.status[i] = WARNED;
 		printf("warnings  %s\n", duration(t));
@@ -245,6 +251,13 @@
 }
 
 static void failed(int i, char *f, int st) {
+	if (readbuf && strstr(readbuf, "TEST EXPECT FAIL")) {
+		printf("FAILED (expected).\n");
+		s.status[i] = KNOWNFAIL;
+		++ s.nknownfail;
+		return;
+	}
+
 	++ s.nfailed;
 	s.status[i] = FAILED;
 	if(die == 2) {
@@ -343,18 +356,21 @@
 			break;
 	}
 
-	printf("\n## %d tests %s : %d OK, %d warnings, %d failures; %d skipped\n",
+	printf("\n## %d tests %s : %d OK, %d warnings, %d failures, %d known failures; %d skipped\n",
 	       s.nwarned + s.npassed + s.nfailed + s.nskipped,
 	       duration(start),
-	       s.npassed, s.nwarned, s.nfailed, s.nskipped);
+	       s.npassed, s.nwarned, s.nfailed, s.nknownfail, s.nskipped);
 
 	/* print out a summary */
-	if (s.nfailed || s.nskipped) {
+	if (s.nfailed || s.nskipped || s.nknownfail) {
 		for (i = 1; i < argc; ++ i) {
 			switch (s.status[i]) {
 			case FAILED:
 				printf("FAILED: %s\n", argv[i]);
 				break;
+			case KNOWNFAIL:
+				printf("FAILED (expected): %s\n", argv[i]);
+				break;
 			case SKIPPED:
 				printf("skipped: %s\n", argv[i]);
 				break;


