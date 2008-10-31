From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Oct 2008 22:41:52 -0000
Subject: LVM2 include/.symlinks lib/snapshot/snapshot.c ...
Message-ID: <20081031224152.1178.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-10-31 22:41:51

Modified files:
	include        : .symlinks 
	lib/snapshot   : snapshot.c 
	lib/mirror     : mirrored.c 

Log message:
	add libdevmapper-event.h

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/include/.symlinks	2008/10/31 22:22:04	1.51
+++ LVM2/include/.symlinks	2008/10/31 22:41:51	1.52
@@ -1,4 +1,5 @@
 ../daemons/clvmd/clvm.h
+../daemons/dmeventd/libdevmapper-event.h
 ../lib/activate/activate.h
 ../lib/activate/targets.h
 ../lib/cache/lvmcache.h
--- LVM2/lib/snapshot/snapshot.c	2008/07/15 00:25:52	1.31
+++ LVM2/lib/snapshot/snapshot.c	2008/10/31 22:41:51	1.32
@@ -23,7 +23,7 @@
 #include "str_list.h"
 #ifdef DMEVENTD
 #  include "sharedlib.h"
-#  include <libdevmapper-event.h>
+#  include "libdevmapper-event.h"
 #endif
 
 static const char *_snap_name(const struct lv_segment *seg)
--- LVM2/lib/mirror/mirrored.c	2008/07/31 14:43:39	1.57
+++ LVM2/lib/mirror/mirrored.c	2008/10/31 22:41:51	1.58
@@ -29,7 +29,7 @@
 #include "str_list.h"
 
 #ifdef DMEVENTD
-#  include <libdevmapper-event.h>
+#  include "libdevmapper-event.h"
 #endif
 
 static int _block_on_error_available = 0;


