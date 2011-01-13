From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Jan 2011 11:02:56 -0000
Subject: LVM2/test/lib harness.c
Message-ID: <20110113110256.13782.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-13 11:02:55

Modified files:
	test/lib       : harness.c 

Log message:
	Hotfix to stop harness busylooping
	
	Harness seems to be able to busyloop in while cycle and not moving forward
	for certain buffer - so check whethere there was some progress.
	This fix allows to continue after failed cluster test.
	
	Fix gcc warning for hiding global variable 's' -> sig.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/harness.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/lib/harness.c	2011/01/10 13:25:22	1.3
+++ LVM2/test/lib/harness.c	2011/01/13 11:02:55	1.4
@@ -54,10 +54,10 @@
 #define FAILED 2
 #define WARNED 3
 
-static void handler( int s ) {
-	signal( s, SIG_DFL );
-	kill( pid, s );
-	die = s;
+static void handler( int sig ) {
+	signal( sig, SIG_DFL );
+	kill( pid, sig );
+	die = sig;
 }
 
 static int outline(char *buf, int start, int force) {
@@ -110,10 +110,12 @@
 }
 
 static void dump(void) {
-        int counter = 0;
+	int counter_last, counter = 0;
 
-        while ( counter < readbuf_used )
-                counter = outline( readbuf, counter, 1 );
+	while ( counter < readbuf_used && counter != counter_last ) {
+		counter_last = counter;
+		counter = outline( readbuf, counter, 1 );
+	}
 }
 
 static void clear(void) {


