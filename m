From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Jul 2010 10:25:17 -0000
Subject: LVM2/lib/commands toolcontext.c
Message-ID: <20100702102517.31074.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-02 10:25:16

Modified files:
	lib/commands   : toolcontext.c 

Log message:
	remove unneeded header

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102

--- LVM2/lib/commands/toolcontext.c	2010/07/02 02:09:57	1.101
+++ LVM2/lib/commands/toolcontext.c	2010/07/02 10:25:16	1.102
@@ -24,7 +24,6 @@
 #include "filter-md.h"
 #include "filter-persistent.h"
 #include "filter-regex.h"
-#include "filter-suspended.h"
 #include "filter-sysfs.h"
 #include "label.h"
 #include "lvm-file.h"


