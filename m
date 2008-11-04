From: agk@sourceware.org <agk@sourceware.org>
Date: 4 Nov 2008 15:07:48 -0000
Subject: LVM2 daemons/clvmd/clvmd-command.c daemons/clv ...
Message-ID: <20081104150748.7570.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-04 15:07:45

Modified files:
	daemons/clvmd  : clvmd-command.c clvmd-gulm.c clvmd-openais.c 
	                 clvmd.c lvm-functions.c 
	daemons/dmeventd: dmeventd.c 
	lib/format_pool: disk_rep.c 
	lib/locking    : cluster_locking.c locking.c 
	lib/metadata   : pv_map.c 
	lib/uuid       : uuid.c 
	libdm          : libdevmapper.h libdm-common.c libdm-deptree.c 
	libdm/datastruct: list.c 

Log message:
	more fixes

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-gulm.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-openais.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/disk_rep.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_map.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/uuid/uuid.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/datastruct/list.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/daemons/clvmd/clvmd-command.c	2008/05/09 19:26:58	1.24
+++ LVM2/daemons/clvmd/clvmd-command.c	2008/11/04 15:07:44	1.25
@@ -67,7 +67,6 @@
 #include <libdevmapper.h>
 #include <libdlm.h>
 
-#include "list.h"
 #include "locking.h"
 #include "log.h"
 #include "lvm-functions.h"
--- LVM2/daemons/clvmd/clvmd-gulm.c	2008/06/20 10:58:28	1.23
+++ LVM2/daemons/clvmd/clvmd-gulm.c	2008/11/04 15:07:44	1.24
@@ -44,7 +44,6 @@
 #include <ccs.h>
 #include <libgulm.h>
 
-#include "list.h"
 #include "locking.h"
 #include "log.h"
 #include "clvm.h"
--- LVM2/daemons/clvmd/clvmd-openais.c	2008/06/20 12:46:21	1.7
+++ LVM2/daemons/clvmd/clvmd-openais.c	2008/11/04 15:07:44	1.8
@@ -39,7 +39,6 @@
 #include <openais/saLck.h>
 #include <openais/cpg.h>
 
-#include "list.h"
 #include "locking.h"
 #include "log.h"
 #include "clvm.h"
--- LVM2/daemons/clvmd/clvmd.c	2008/11/03 22:14:26	1.49
+++ LVM2/daemons/clvmd/clvmd.c	2008/11/04 15:07:44	1.50
@@ -46,7 +46,6 @@
 #include "version.h"
 #include "clvmd.h"
 #include "refresh_clvmd.h"
-#include "list.h"
 #include "log.h"
 
 #ifndef TRUE
--- LVM2/daemons/clvmd/lvm-functions.c	2008/09/19 15:44:03	1.46
+++ LVM2/daemons/clvmd/lvm-functions.c	2008/11/04 15:07:44	1.47
@@ -33,7 +33,6 @@
 #include <libdevmapper.h>
 #include <libdlm.h>
 
-#include "list.h"
 #include "lvm-types.h"
 #include "clvm.h"
 #include "clvmd-comms.h"
--- LVM2/daemons/dmeventd/dmeventd.c	2008/11/03 23:01:21	1.53
+++ LVM2/daemons/dmeventd/dmeventd.c	2008/11/04 15:07:44	1.54
@@ -22,7 +22,6 @@
 #include "configure.h"
 #include "libdevmapper.h"
 #include "libdevmapper-event.h"
-#include "list.h"
 #include "dmeventd.h"
 //#include "libmultilog.h"
 #include "dm-logging.h"
--- LVM2/lib/format_pool/disk_rep.c	2008/11/03 22:14:28	1.14
+++ LVM2/lib/format_pool/disk_rep.c	2008/11/04 15:07:44	1.15
@@ -19,9 +19,10 @@
 #include "lvmcache.h"
 #include "filter.h"
 #include "xlate.h"
-
 #include "disk_rep.h"
 
+#include <assert.h>
+
 /* FIXME: memcpy might not be portable */
 #define CPIN_8(x, y, z) {memcpy((x), (y), (z));}
 #define CPOUT_8(x, y, z) {memcpy((y), (x), (z));}
--- LVM2/lib/locking/cluster_locking.c	2008/09/19 06:41:58	1.30
+++ LVM2/lib/locking/cluster_locking.c	2008/11/04 15:07:44	1.31
@@ -25,6 +25,7 @@
 #include "locking.h"
 #include "locking_types.h"
 
+#include <assert.h>
 #include <stddef.h>
 #include <sys/socket.h>
 #include <sys/un.h>
--- LVM2/lib/locking/locking.c	2008/11/03 22:14:29	1.52
+++ LVM2/lib/locking/locking.c	2008/11/04 15:07:44	1.53
@@ -23,6 +23,7 @@
 #include "defaults.h"
 #include "lvmcache.h"
 
+#include <assert.h>
 #include <signal.h>
 #include <sys/stat.h>
 #include <limits.h>
--- LVM2/lib/metadata/pv_map.c	2008/11/03 22:14:29	1.32
+++ LVM2/lib/metadata/pv_map.c	2008/11/04 15:07:44	1.33
@@ -17,6 +17,8 @@
 #include "pv_map.h"
 #include "pv_alloc.h"
 
+#include <assert.h>
+
 /*
  * Areas are maintained in size order, largest first.
  *
--- LVM2/lib/uuid/uuid.c	2008/08/29 00:49:46	1.27
+++ LVM2/lib/uuid/uuid.c	2008/11/04 15:07:45	1.28
@@ -16,6 +16,7 @@
 #include "lib.h"
 #include "uuid.h"
 
+#include <assert.h>
 #include <sys/stat.h>
 #include <fcntl.h>
 #include <unistd.h>
--- LVM2/libdm/libdevmapper.h	2008/11/04 14:57:06	1.85
+++ LVM2/libdm/libdevmapper.h	2008/11/04 15:07:45	1.86
@@ -799,7 +799,7 @@
  * The containing structure should be the same type as 'v'.
  * The list should be 'struct dm_list list' within the containing structure.
  */
-#define dm_list_iterate_back_items(v, head) list_iterate_back_items_gen(v, (head), list)
+#define dm_list_iterate_back_items(v, head) dm_list_iterate_back_items_gen(v, (head), list)
 
 /*
  * Return the number of elements in a list by walking it.
--- LVM2/libdm/libdm-common.c	2008/11/03 22:14:29	1.62
+++ LVM2/libdm/libdm-common.c	2008/11/04 15:07:45	1.63
@@ -16,7 +16,6 @@
 #include "dmlib.h"
 #include "libdm-targets.h"
 #include "libdm-common.h"
-#include "list.h"
 #include "kdev_t.h"
 #include "dm-ioctl.h"
 
--- LVM2/libdm/libdm-deptree.c	2008/11/03 22:14:29	1.46
+++ LVM2/libdm/libdm-deptree.c	2008/11/04 15:07:45	1.47
@@ -15,7 +15,6 @@
 #include "dmlib.h"
 #include "libdm-targets.h"
 #include "libdm-common.h"
-#include "list.h"
 #include "kdev_t.h"
 #include "dm-ioctl.h"
 
--- LVM2/libdm/datastruct/list.c	2008/11/03 22:14:30	1.5
+++ LVM2/libdm/datastruct/list.c	2008/11/04 15:07:45	1.6
@@ -14,6 +14,7 @@
  */
 
 #include "lib.h"
+#include <assert.h>
 
 /*
  * Initialise a list before use.


