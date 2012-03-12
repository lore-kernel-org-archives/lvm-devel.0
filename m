From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 12 Mar 2012 14:24:15 -0000
Subject: LVM2/test/lib harness.c
Message-ID: <20120312142415.26208.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-12 14:24:15

Modified files:
	test/lib       : harness.c 

Log message:
	Improve harness code
	
	Support timestamping with harness -  using VERBOSE=2
	Fix also logging in several situation
	(i.e. continue logging multiple test in VERBOSE mode,
	do not coredump with empty output).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/harness.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/test/lib/harness.c	2012/02/15 01:31:10	1.11
+++ LVM2/test/lib/harness.c	2012/03/12 14:24:15	1.12
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2010-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2010-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -21,6 +21,7 @@
 #include <unistd.h>
 #include <stdlib.h>
 #include <time.h>
+#include <sys/time.h>
 
 static pid_t pid;
 static int fds[2];
@@ -41,7 +42,7 @@
 static int readbuf_sz = 0, readbuf_used = 0;
 
 static int die = 0;
-static int verbose = 0;
+static int verbose = 0; /* >1 with timestamps */
 
 struct subst {
 	const char *key;
@@ -119,8 +120,13 @@
 	}
 }
 
-static void trickle() {
+static void trickle(void) {
 	static int counter_last = -1, counter = 0;
+
+	if (counter_last > readbuf_used) {
+		counter_last = -1;
+		counter = 0;
+	}
 	while ( counter < readbuf_used && counter != counter_last ) {
 		counter_last = counter;
 		counter = outline( readbuf, counter, 1 );
@@ -131,25 +137,83 @@
 	readbuf_used = 0;
 }
 
+static int64_t _get_time_us(void)
+{
+       struct timeval tv;
+
+       (void) gettimeofday(&tv, 0);
+       return (int64_t) tv.tv_sec * 1000000 + (int64_t) tv.tv_usec;
+}
+
+static void _append_buf(const char *buf, size_t len)
+{
+	if ((readbuf_used + len) >= readbuf_sz) {
+		readbuf_sz = readbuf_sz ? 2 * readbuf_sz : 4096;
+		readbuf = realloc(readbuf, readbuf_sz);
+	}
+
+	if (!readbuf)
+		exit(205);
+
+	memcpy(readbuf + readbuf_used, buf, len);
+	readbuf_used += len;
+}
+
+static const char *_append_with_stamp(const char *buf, int stamp)
+{
+	static const char spaces[] = "                 ";
+	static int64_t t_last;
+	static int64_t t_start = 0;
+	int64_t t_now;
+	char stamp_buf[32]; /* Bigger to always fit both numbers */
+	const char *be;
+	const char *bb = buf;
+	size_t len;
+
+	while ((be = strchr(bb, '\n'))) {
+		if (stamp++ == 0) {
+			t_now = _get_time_us();
+			if (!t_start)
+				t_start = t_last = t_now;
+			len = snprintf(stamp_buf, sizeof(stamp_buf),
+				       "%8.3f%8.4f ",
+				       (t_now - t_start) / 1000000.f,
+				       (t_now - t_last) / 1000000.f);
+			_append_buf(stamp_buf, (len < (sizeof(spaces) - 1)) ?
+				    len : (sizeof(spaces) - 1));
+			t_last = t_now;
+		}
+
+		_append_buf(bb, be + 1 - bb);
+		bb = be + 1;
+
+		if (stamp > 0 && bb[0])
+			_append_buf(spaces, sizeof(spaces) - 1);
+	}
+
+	return bb;
+}
+
 static void drain(void) {
+	char buf[4096];
+	const char *bp;
+	int stamp = 0;
 	int sz;
-	char buf[2048];
 
-	while (1) {
-		sz = read(fds[1], buf, sizeof(buf));
-		if (sz <= 0)
-			return;
-		if (readbuf_used + sz >= readbuf_sz) {
-			readbuf_sz = readbuf_sz ? 2 * readbuf_sz : 4096;
-			readbuf = realloc(readbuf, readbuf_sz);
-		}
+	while ((sz = read(fds[1], buf, sizeof(buf) - 1)) > 0) {
+		buf[sz] = '\0';
+		bp = (verbose < 2) ? buf : _append_with_stamp(buf, stamp);
+
+		if (sz > (bp - buf)) {
+			_append_buf(bp, sz - (bp - buf));
+			stamp = -1; /* unfinished line */
+		} else
+			stamp = 0;
+
+		readbuf[readbuf_used] = 0;
+
 		if (verbose)
 			trickle();
-		if (!readbuf)
-			exit(205);
-		memcpy(readbuf + readbuf_used, buf, sz);
-		readbuf_used += sz;
-		readbuf[readbuf_used] = 0;
 	}
 }
 
@@ -163,7 +227,7 @@
 }
 
 static void passed(int i, char *f, time_t t) {
-	if (strstr(readbuf, "TEST WARNING")) {
+	if (readbuf && strstr(readbuf, "TEST WARNING")) {
 		++s.nwarned;
 		s.status[i] = WARNED;
 		printf("warnings  %s\n", duration(t));
@@ -252,8 +316,8 @@
 		exit(1);
 	}
 
-	if (be_verbose && atoi(be_verbose))
-		verbose = 1; // XXX
+	if (be_verbose)
+		verbose = atoi(be_verbose);
 
 	if (socketpair(PF_UNIX, SOCK_STREAM, 0, fds)) {
 		perror("socketpair");


