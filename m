From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 23 Aug 2007 12:44:11 -0000
Subject: LVM2/daemons/clvmd lvm-functions.c
Message-ID: <20070823124411.7901.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2007-08-23 12:44:10

Modified files:
	daemons/clvmd  : lvm-functions.c 

Log message:
	Force a device scan after init_full_scan_done() per agk.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/daemons/clvmd/lvm-functions.c	2007/08/23 12:19:13	1.32
+++ LVM2/daemons/clvmd/lvm-functions.c	2007/08/23 12:44:09	1.33
@@ -42,6 +42,7 @@
 
 /* LVM2 headers */
 #include "toolcontext.h"
+#include "lvmcache.h"
 #include "log.h"
 #include "activate.h"
 #include "locking.h"
@@ -448,6 +449,7 @@
 
 	ret = refresh_toolcontext(cmd);
 	init_full_scan_done(0);
+	lvmcache_label_scan(cmd, 2);
 
 	return ret==1?0:-1;
 }


