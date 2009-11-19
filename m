From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 19 Nov 2009 12:09:53 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20091119120953.2123.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-11-19 12:09:53

Modified files:
	lib/metadata   : mirror.c 

Log message:
	Add a missing #include (fix compiler warning).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94

--- LVM2/lib/metadata/mirror.c	2009/11/18 18:23:46	1.93
+++ LVM2/lib/metadata/mirror.c	2009/11/19 12:09:53	1.94
@@ -24,6 +24,7 @@
 #include "lvm-string.h"
 #include "str_list.h"
 #include "locking.h"	/* FIXME Should not be used in this file */
+#include "memlock.h"
 
 #include "defaults.h" /* FIXME: should this be defaults.h? */
 


