From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 17 Feb 2009 19:37:28 -0000
Subject: LVM2/test not.c
Message-ID: <20090217193728.11776.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-02-17 19:37:28

Modified files:
	test           : not.c 

Log message:
	In testsuite's not.c, print a notice when program dies of a fatal signal.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/not.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/not.c	2009/01/12 18:45:44	1.1
+++ LVM2/test/not.c	2009/02/17 19:37:28	1.2
@@ -25,6 +25,10 @@
 	} else {		/* parent */
 		waitpid(pid, &status, 0);
 		if (!WIFEXITED(status)) {
+			if (WIFSIGNALED(status))
+				fprintf(stderr,
+					"Process %d died of signal %d.\n",
+					pid, WTERMSIG(status));
 			/* did not exit correctly */
 			return FAILURE;
 		}


