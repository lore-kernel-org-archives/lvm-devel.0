From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Jul 2009 14:06:32 -0000
Subject: LVM2/test/api test.c vgtest.c
Message-ID: <20090729140632.9906.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-29 14:06:32

Modified files:
	test/api       : test.c vgtest.c 

Log message:
	renamed include files

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/vgtest.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/test/api/test.c	2009/07/28 14:12:29	1.23
+++ LVM2/test/api/test.c	2009/07/29 14:06:31	1.24
@@ -16,7 +16,8 @@
 #include <string.h>
 #include <stdlib.h>
 #include <readline/readline.h>
-#include "lvm.h"
+
+#include "lvm2app.h"
 
 #define MAX_ARGS 64
 
--- LVM2/test/api/vgtest.c	2009/07/28 11:03:29	1.8
+++ LVM2/test/api/vgtest.c	2009/07/29 14:06:31	1.9
@@ -20,7 +20,8 @@
 #include <stdio.h>
 #include <unistd.h>
 #include <inttypes.h>
-#include "lvm.h"
+
+#include "lvm2app.h"
 
 lvm_t handle;
 vg_t *vg;


