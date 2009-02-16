From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 16 Feb 2009 16:49:22 -0000
Subject: LVM2/test harness.c
Message-ID: <20090216164922.25304.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-02-16 16:49:22

Modified files:
	test           : harness.c 

Log message:
	Only fail when tests have failed, but not when they have been just skipped.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/harness.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/harness.c	2009/02/12 19:54:45	1.1
+++ LVM2/test/harness.c	2009/02/16 16:49:21	1.2
@@ -153,7 +153,7 @@
 	       npassed + nfailed + nskipped, npassed, nfailed, nskipped);
 
 	/* print out a summary */
-	if (nfailed || nskipped ) {
+	if (nfailed || nskipped) {
 		for (i = 1; i < argc; ++ i) {
 			switch (status[i]) {
 			case FAILED:
@@ -165,7 +165,7 @@
 			}
 		}
 		printf("\n");
-		return 1;
+		return nfailed > 0 || die;
 	}
 	return !die;
 }


