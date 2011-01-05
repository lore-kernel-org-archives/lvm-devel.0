From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 5 Jan 2011 15:03:44 -0000
Subject: LVM2/test/lib harness.c not.c
Message-ID: <20110105150344.12122.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-05 15:03:43

Modified files:
	test/lib       : harness.c not.c 

Log message:
	Fix gcc warnings for missing headers and prototypes
	
	Add missing header  string.h (strcmp, strndup).
	Add 'static' to fix missing prototypes gcc warning.
	Remove unused variables verbose_off, TESTDIR, PREFIX.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/harness.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/not.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/lib/harness.c	2011/01/05 00:16:21	1.1
+++ LVM2/test/lib/harness.c	2011/01/05 15:03:43	1.2
@@ -19,9 +19,10 @@
 #include <sys/wait.h>
 #include <unistd.h>
 #include <stdlib.h>
+#include <string.h>
 
-pid_t pid;
-int fds[2];
+static pid_t pid;
+static int fds[2];
 
 #define MAX 1024
 
@@ -33,37 +34,33 @@
 	int status[MAX];
 };
 
-struct stats s;
+static struct stats s;
 
-char *readbuf = NULL;
-int readbuf_sz = 0, readbuf_used = 0;
+static char *readbuf = NULL;
+static int readbuf_sz = 0, readbuf_used = 0;
 
-int die = 0;
-int verbose = 0;
-int verbose_off = 0;
+static int die = 0;
+static int verbose = 0;
 
 struct subst {
-        char *key;
+        const char *key;
         char *value;
 };
 
-struct subst subst[2];
-
-char *TESTDIR = NULL;
-char *PREFIX = NULL;
+static struct subst subst[2];
 
 #define PASSED 0
 #define SKIPPED 1
 #define FAILED 2
 #define WARNED 3
 
-void handler( int s ) {
+static void handler( int s ) {
 	signal( s, SIG_DFL );
 	kill( pid, s );
 	die = s;
 }
 
-int outline(char *buf, int start, int force) {
+static int outline(char *buf, int start, int force) {
         char *from = buf + start;
         char *next = strchr(buf + start, '\n');
 
@@ -112,18 +109,18 @@
         return next - buf + (force ? 0 : 1);
 }
 
-void dump() {
+static void dump(void) {
         int counter = 0;
 
         while ( counter < readbuf_used )
                 counter = outline( readbuf, counter, 1 );
 }
 
-void clear() {
+static void clear(void) {
 	readbuf_used = 0;
 }
 
-void drain() {
+static void drain(void) {
 	int sz;
 	char buf[2048];
         memset(buf, 0, 2048);
@@ -146,7 +143,7 @@
 	}
 }
 
-void passed(int i, char *f) {
+static void passed(int i, char *f) {
 	if (strstr(readbuf, "TEST WARNING")) {
 		++s.nwarned;
 		s.status[i] = WARNED;
@@ -158,13 +155,13 @@
 	}
 }
 
-void skipped(int i, char *f) {
+static void skipped(int i, char *f) {
 	++ s.nskipped;
 	s.status[i] = SKIPPED;
 	printf("skipped.\n");
 }
 
-void failed(int i, char *f, int st) {
+static void failed(int i, char *f, int st) {
 	++ s.nfailed;
 	s.status[i] = FAILED;
 	if(die == 2) {
@@ -177,7 +174,7 @@
 	printf("-- FAILED %s (end) ------------------------------\n", f);
 }
 
-void run(int i, char *f) {
+static void run(int i, char *f) {
 	pid = fork();
 	if (pid < 0) {
 		perror("Fork failed.");
--- LVM2/test/lib/not.c	2011/01/05 00:16:21	1.1
+++ LVM2/test/lib/not.c	2011/01/05 15:03:43	1.2
@@ -15,10 +15,11 @@
 #include <unistd.h>
 #include <stdio.h>
 #include <stdarg.h>
+#include <string.h>
 #include <sys/types.h>
 #include <sys/wait.h>
 
-int finished(const char *cmd, int status) {
+static int finished(const char *cmd, int status) {
 	if (!strcmp(cmd, "not"))
 		return !status;
 	if (!strcmp(cmd, "should")) {


