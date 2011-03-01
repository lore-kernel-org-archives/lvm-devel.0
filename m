From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2011 23:29:15 -0000
Subject: LVM2/test/api test.c
Message-ID: <20110301232915.16876.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-01 23:29:15

Modified files:
	test/api       : test.c 

Log message:
	Invert condition for READLINE check

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/test/api/test.c	2011/03/01 23:18:40	1.35
+++ LVM2/test/api/test.c	2011/03/01 23:29:14	1.36
@@ -21,7 +21,7 @@
 #include "configure.h"
 #include "lvm2app.h"
 
-#ifndef READLINE_SUPPORT
+#ifdef READLINE_SUPPORT
 #include <readline/readline.h>
 
 #define MAX_ARGS 64


