From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Sep 2011 21:12:36 -0000
Subject: LVM2/test/lib harness.c
Message-ID: <20110924211236.3175.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-24 21:12:35

Modified files:
	test/lib       : harness.c 

Log message:
	Avoid sending garbage to terminal in verbose mode.
	
	When read in drain returned <0 value, terminal content has been trashed.
	Remove unneeded  memset() and use whole buffer.
	Free  readbuf before exit (valgrind).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/harness.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/test/lib/harness.c	2011/03/10 14:47:22	1.7
+++ LVM2/test/lib/harness.c	2011/09/24 21:12:35	1.8
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2010-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -126,14 +126,13 @@
 static void drain(void) {
 	int sz;
 	char buf[2048];
-	memset(buf, 0, 2048);
 
 	while (1) {
-		sz = read(fds[1], buf, 2047);
-		if (verbose)
-			write(1, buf, sz);
+		sz = read(fds[1], buf, sizeof(buf));
 		if (sz <= 0)
 			return;
+		if (verbose)
+			write(1, buf, sz);
 		if (readbuf_used + sz >= readbuf_sz) {
 			readbuf_sz = readbuf_sz ? 2 * readbuf_sz : 4096;
 			readbuf = realloc(readbuf, readbuf_sz);
@@ -291,5 +290,7 @@
 		return s.nfailed > 0 || die;
 	}
 
+	free(readbuf);
+
 	return die;
 }


