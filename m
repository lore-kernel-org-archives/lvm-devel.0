From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 May 2010 11:58:58 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20100512115858.4203.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-05-12 11:58:54

Modified files:
	test           : test-utils.sh 

Log message:
	Bump the debug.log level from 4 to 9 (the numbering is different from verbose).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/test/test-utils.sh	2010/05/12 11:23:16	1.41
+++ LVM2/test/test-utils.sh	2010/05/12 11:58:51	1.42
@@ -371,7 +371,7 @@
   log {
     syslog = 0
     indent = 1
-    level = 4
+    level = 9
     file = "$TESTDIR/debug.log"
     overwrite = 1
   }


