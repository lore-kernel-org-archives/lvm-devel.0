From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 Nov 2011 17:02:57 -0000
Subject: LVM2/test/lib harness.c
Message-ID: <20111107170257.17489.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-11-07 17:02:57

Modified files:
	test/lib       : harness.c 

Log message:
	Do not repeat a failed test's output when VERBOSE is in effect.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/harness.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/test/lib/harness.c	2011/09/24 21:12:35	1.8
+++ LVM2/test/lib/harness.c	2011/11/07 17:02:56	1.9
@@ -180,9 +180,11 @@
 		return;
 	}
 	printf("FAILED.\n");
-	printf("-- FAILED %s ------------------------------------\n", f);
-	dump();
-	printf("-- FAILED %s (end) ------------------------------\n", f);
+	if (!verbose) {
+		printf("-- FAILED %s ------------------------------------\n", f);
+		dump();
+		printf("-- FAILED %s (end) ------------------------------\n", f);
+	}
 }
 
 static void run(int i, char *f) {


