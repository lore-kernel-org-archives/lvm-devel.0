From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 May 2010 05:55:44 -0000
Subject: LVM2/test not.c
Message-ID: <20100512055544.5426.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-05-12 05:55:42

Modified files:
	test           : not.c 

Log message:
	The "should" testing utility should actually only give a warning when the
	command fails.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/not.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/not.c	2010/04/30 14:33:39	1.3
+++ LVM2/test/not.c	2010/05/12 05:55:42	1.4
@@ -8,7 +8,8 @@
 	if (!strcmp(cmd, "not"))
 		return !status;
 	if (!strcmp(cmd, "should")) {
-		fprintf(stderr, "TEST WARNING: Ignoring command failure.\n");
+		if (status)
+			fprintf(stderr, "TEST WARNING: Ignoring command failure.\n");
 		return 0;
 	}
 	return 6;


