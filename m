From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Feb 2012 01:31:10 -0000
Subject: LVM2/test/lib harness.c
Message-ID: <20120215013110.2840.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-15 01:31:10

Modified files:
	test/lib       : harness.c 

Log message:
	In the test harness, do the back-substitution (@TESTDIR@, @PREFIX@) also on the
	live VERBOSE output, not just the post-mortem dumps.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/harness.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/test/lib/harness.c	2011/11/23 14:56:47	1.10
+++ LVM2/test/lib/harness.c	2012/02/15 01:31:10	1.11
@@ -119,6 +119,14 @@
 	}
 }
 
+static void trickle() {
+	static int counter_last = -1, counter = 0;
+	while ( counter < readbuf_used && counter != counter_last ) {
+		counter_last = counter;
+		counter = outline( readbuf, counter, 1 );
+	}
+}
+
 static void clear(void) {
 	readbuf_used = 0;
 }
@@ -131,12 +139,12 @@
 		sz = read(fds[1], buf, sizeof(buf));
 		if (sz <= 0)
 			return;
-		if (verbose)
-			write(1, buf, sz);
 		if (readbuf_used + sz >= readbuf_sz) {
 			readbuf_sz = readbuf_sz ? 2 * readbuf_sz : 4096;
 			readbuf = realloc(readbuf, readbuf_sz);
 		}
+		if (verbose)
+			trickle();
 		if (!readbuf)
 			exit(205);
 		memcpy(readbuf + readbuf_used, buf, sz);


