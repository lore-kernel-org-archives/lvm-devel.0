From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Apr 2007 17:46:18 -0000
Subject: LVM2 ./WHATS_NEW ./make.tmpl.in daemons/clvmd/ ...
Message-ID: <20070427174618.18491.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-04-27 18:46:16

Modified files:
	.              : WHATS_NEW make.tmpl.in 
	daemons/clvmd  : clvmd-cman.c clvmd-command.c clvmd-gulm.c 
	                 clvmd.c lvm-functions.c system-lv.c tcp-comms.c 
	dmeventd/mirror: dmeventd_mirror.c 
	lib/activate   : activate.c 
	lib/misc       : lib.h 

Log message:
	Change some #include lines to search only standard system directories.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.607&r2=1.608
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-cman.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-gulm.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/system-lv.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/tcp-comms.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.121&r2=1.122
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lib.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW	2007/04/26 16:44:57	1.607
+++ LVM2/WHATS_NEW	2007/04/27 17:46:15	1.608
@@ -1,5 +1,6 @@
 Version 2.02.25 -
 =================================
+  Change some #include lines to search only standard system directories.
   Add devices/preferred_names config regex list for displayed device names.
   Free a temporary dir string in fcntl_lock_file() after use.
   Fix a dm_pool_destroy() in matcher_create().
--- LVM2/make.tmpl.in	2007/01/11 17:12:26	1.47
+++ LVM2/make.tmpl.in	2007/04/27 17:46:15	1.48
@@ -94,7 +94,7 @@
 LIB_VERSION := $(shell cat $(top_srcdir)/VERSION | \
 		 awk -F '.' '{printf "%s.%s",$$1,$$2}')
 
-INCLUDES += -I. -I$(top_srcdir)/include
+INCLUDES += -I$(top_srcdir)/include
 
 ifneq ("@DMDIR@", "")
   INCLUDES += -I at DMDIR@/include
--- LVM2/daemons/clvmd/clvmd-cman.c	2007/04/23 14:55:28	1.17
+++ LVM2/daemons/clvmd/clvmd-cman.c	2007/04/27 17:46:16	1.18
@@ -36,10 +36,10 @@
 #include <fcntl.h>
 #include <getopt.h>
 #include <errno.h>
+#include <libdlm.h>
 
 #include "clvmd-comms.h"
 #include "clvm.h"
-#include "libdlm.h"
 #include "log.h"
 #include "clvmd.h"
 #include "lvm-functions.h"
--- LVM2/daemons/clvmd/clvmd-command.c	2006/12/11 14:00:26	1.14
+++ LVM2/daemons/clvmd/clvmd-command.c	2007/04/27 17:46:16	1.15
@@ -64,8 +64,9 @@
 #include <stddef.h>
 #include <unistd.h>
 #include <errno.h>
+#include <libdevmapper.h>
+#include <libdlm.h>
 
-#include "libdevmapper.h"
 #include "list.h"
 #include "locking.h"
 #include "log.h"
@@ -73,7 +74,6 @@
 #include "clvmd-comms.h"
 #include "clvm.h"
 #include "clvmd.h"
-#include "libdlm.h"
 
 extern struct cluster_ops *clops;
 
--- LVM2/daemons/clvmd/clvmd-gulm.c	2006/12/11 14:00:26	1.20
+++ LVM2/daemons/clvmd/clvmd-gulm.c	2007/04/27 17:46:16	1.21
@@ -40,9 +40,10 @@
 #include <utmpx.h>
 #include <syslog.h>
 #include <assert.h>
+#include <libdevmapper.h>
+#include <ccs.h>
+#include <libgulm.h>
 
-#include "libdevmapper.h"
-#include "ccs.h"
 #include "list.h"
 #include "locking.h"
 #include "log.h"
@@ -51,7 +52,6 @@
 #include "lvm-functions.h"
 #include "clvmd.h"
 #include "clvmd-gulm.h"
-#include "libgulm.h"
 
 /* Hash list of nodes in the cluster */
 static struct dm_hash_table *node_hash;
--- LVM2/daemons/clvmd/clvmd.c	2007/03/29 13:59:33	1.34
+++ LVM2/daemons/clvmd/clvmd.c	2007/04/27 17:46:16	1.35
@@ -37,6 +37,7 @@
 #include <getopt.h>
 #include <syslog.h>
 #include <errno.h>
+#include <libdlm.h>
 
 #include "clvmd-comms.h"
 #include "lvm-functions.h"
@@ -44,7 +45,6 @@
 #include "version.h"
 #include "clvmd.h"
 #include "refresh_clvmd.h"
-#include "libdlm.h"
 #include "system-lv.h"
 #include "list.h"
 #include "log.h"
--- LVM2/daemons/clvmd/lvm-functions.c	2007/04/24 15:13:13	1.29
+++ LVM2/daemons/clvmd/lvm-functions.c	2007/04/27 17:46:16	1.30
@@ -30,11 +30,11 @@
 #include <errno.h>
 #include <syslog.h>
 #include <assert.h>
+#include <libdevmapper.h>
+#include <libdlm.h>
 
-#include "libdevmapper.h"
 #include "list.h"
 #include "lvm-types.h"
-#include "libdlm.h"
 #include "clvm.h"
 #include "clvmd-comms.h"
 #include "clvmd.h"
--- LVM2/daemons/clvmd/system-lv.c	2005/01/13 13:24:02	1.2
+++ LVM2/daemons/clvmd/system-lv.c	2007/04/27 17:46:16	1.3
@@ -36,8 +36,11 @@
 #include <dirent.h>
 #include <errno.h>
 #include <mntent.h>
+#include <libdlm.h>
+#ifdef HAVE_CCS
+#include <ccs.h>
+#endif
 
-#include "libdlm.h"
 #include "log.h"
 #include "list.h"
 #include "locking.h"
@@ -45,9 +48,6 @@
 #include "clvm.h"
 #include "clvmd-comms.h"
 #include "clvmd.h"
-#ifdef HAVE_CCS
-#include "ccs.h"
-#endif
 
 #define SYSTEM_LV_FILESYSTEM "ext2"
 #define SYSTEM_LV_MOUNTPOINT "/tmp/.clvmd-XXXXXX"
--- LVM2/daemons/clvmd/tcp-comms.c	2006/05/09 21:23:49	1.15
+++ LVM2/daemons/clvmd/tcp-comms.c	2007/04/27 17:46:16	1.16
@@ -34,8 +34,8 @@
 #include <syslog.h>
 #include <netdb.h>
 #include <assert.h>
+#include <libdevmapper.h>
 
-#include "libdevmapper.h"
 #include "clvm.h"
 #include "clvmd-comms.h"
 #include "clvmd.h"
--- LVM2/dmeventd/mirror/dmeventd_mirror.c	2007/01/25 23:32:29	1.17
+++ LVM2/dmeventd/mirror/dmeventd_mirror.c	2007/04/27 17:46:16	1.18
@@ -12,10 +12,10 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "libdevmapper.h"
-#include "libdevmapper-event.h"
 #include "lvm2cmd.h"
 
+#include <libdevmapper.h>
+#include <libdevmapper-event.h>
 #include <errno.h>
 #include <signal.h>
 #include <string.h>
--- LVM2/lib/activate/activate.c	2007/03/08 21:08:25	1.121
+++ LVM2/lib/activate/activate.c	2007/04/27 17:46:16	1.122
@@ -168,7 +168,7 @@
 {
 	return 0;
 }
-int lvs_in_vg_activated_by_uuid_only(struct volume_group *vg);
+int lvs_in_vg_activated_by_uuid_only(struct volume_group *vg)
 {
 	return 0;
 }
--- LVM2/lib/misc/lib.h	2006/08/17 18:23:44	1.10
+++ LVM2/lib/misc/lib.h	2007/04/27 17:46:16	1.11
@@ -19,7 +19,7 @@
 #ifndef _LVM_LIB_H
 #define _LVM_LIB_H
 
-#include <configure.h>
+#include "configure.h"
 
 #define _REENTRANT
 #define _GNU_SOURCE


