From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 Apr 2010 09:41:34 -0000
Subject: LVM2/test harness.c
Message-ID: <20100407094134.29008.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-07 09:41:34

Modified files:
	test           : harness.c 

Log message:
	Keep the testsuite stats correct in spite of failed-test repetition.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/harness.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/harness.c	2010/03/31 23:11:12	1.6
+++ LVM2/test/harness.c	2010/04/07 09:41:33	1.7
@@ -8,10 +8,18 @@
 
 pid_t pid;
 int fds[2];
-int *status;
-int nfailed = 0;
-int nskipped = 0;
-int npassed = 0;
+
+#define MAX 1024
+
+struct stats {
+	int nfailed;
+	int nskipped;
+	int npassed;
+	int status[MAX];
+};
+
+struct stats s;
+struct stats backup;
 
 char *readbuf = NULL;
 int readbuf_sz = 0, readbuf_used = 0;
@@ -55,20 +63,20 @@
 }
 
 void passed(int i, char *f) {
-	++ npassed;
-	status[i] = PASSED;
+	++ s.npassed;
+	s.status[i] = PASSED;
 	printf("passed.\n");
 }
 
 void skipped(int i, char *f) {
-	++ nskipped;
-	status[i] = SKIPPED;
+	++ s.nskipped;
+	s.status[i] = SKIPPED;
 	printf("skipped.\n");
 }
 
 void failed(int i, char *f, int st) {
-	++ nfailed;
-	status[i] = FAILED;
+	++ s.nfailed;
+	s.status[i] = FAILED;
 	if(die == 2) {
 		printf("interrupted.\n");
 		return;
@@ -125,7 +133,14 @@
 
 int main(int argc, char **argv) {
 	int i;
-	status = alloca(sizeof(int)*argc);
+
+	if (argc >= MAX) {
+		fprintf(stderr, "Sorry, my head exploded. Please increase MAX.\n");
+		exit(1);
+	}
+
+	s.nfailed = s.npassed = s.nskipped = 0;
+
 	char *config = getenv("LVM_TEST_CONFIG"),
 	     *config_debug;
 	config = config ? config : "";
@@ -153,21 +168,22 @@
 		run(i, argv[i]);
 		if (die)
 			break;
-		if ( status[i] == FAILED ) {
+		if ( s.status[i] == FAILED ) {
+			backup = s;
 			setenv("LVM_TEST_CONFIG", config_debug, 1);
 			run(i, argv[i]);
 			setenv("LVM_TEST_CONFIG", config, 1);
-			status[i] = FAILED; /* just in case */
+			s = backup;
 		}
 	}
 
 	printf("\n## %d tests: %d OK, %d failed, %d skipped\n",
-	       npassed + nfailed + nskipped, npassed, nfailed, nskipped);
+	       s.npassed + s.nfailed + s.nskipped, s.npassed, s.nfailed, s.nskipped);
 
 	/* print out a summary */
-	if (nfailed || nskipped) {
+	if (s.nfailed || s.nskipped) {
 		for (i = 1; i < argc; ++ i) {
-			switch (status[i]) {
+			switch (s.status[i]) {
 			case FAILED:
 				printf("FAILED: %s\n", argv[i]);
 				break;
@@ -177,7 +193,7 @@
 			}
 		}
 		printf("\n");
-		return nfailed > 0 || die;
+		return s.nfailed > 0 || die;
 	}
 	return !die;
 }


