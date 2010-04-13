From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 13 Apr 2010 07:34:20 -0000
Subject: LVM2/test harness.c
Message-ID: <20100413073420.21389.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-13 07:34:19

Modified files:
	test           : harness.c 

Log message:
	Fix a reversed exit status from test harness.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/harness.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/test/harness.c	2010/04/13 07:33:34	1.9
+++ LVM2/test/harness.c	2010/04/13 07:34:19	1.10
@@ -196,5 +196,5 @@
 		printf("\n");
 		return s.nfailed > 0 || die;
 	}
-	return !die;
+	return die;
 }


