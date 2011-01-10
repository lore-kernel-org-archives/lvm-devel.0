From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Jan 2011 19:49:43 -0000
Subject: LVM2/lib/misc lvm-exec.c
Message-ID: <20110110194943.31864.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-10 19:49:42

Modified files:
	lib/misc       : lvm-exec.c 

Log message:
	Fix missing declaration for fs_unlock

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-exec.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/lib/misc/lvm-exec.c	2011/01/10 19:31:02	1.9
+++ LVM2/lib/misc/lvm-exec.c	2011/01/10 19:49:42	1.10
@@ -18,6 +18,7 @@
 #include "locking.h"
 #include "lvm-exec.h"
 #include "toolcontext.h"
+#include "activate.h"
 
 #include <unistd.h>
 #include <sys/wait.h>


