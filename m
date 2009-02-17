From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 17 Feb 2009 19:36:16 -0000
Subject: LVM2/test harness.c
Message-ID: <20090217193616.10984.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-02-17 19:36:16

Modified files:
	test           : harness.c 

Log message:
	Fix test output collection in harness.c.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/harness.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/harness.c	2009/02/16 16:49:21	1.2
+++ LVM2/test/harness.c	2009/02/17 19:36:16	1.3
@@ -106,6 +106,7 @@
 			perror("waitpid");
 			exit(206);
 		}
+		drain();
 		if (WIFEXITED(st)) {
 			if (WEXITSTATUS(st) == 0) {
 				passed(i, f);


