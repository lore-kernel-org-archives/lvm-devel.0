From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Jun 2010 11:00:49 -0000
Subject: LVM2 daemons/clvmd/clvmd-cman.c daemons/clvmd/ ...
Message-ID: <20100615110049.8399.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-06-15 11:00:46

Modified files:
	daemons/clvmd  : clvmd-cman.c clvmd-command.c clvmd-corosync.c 
	                 clvmd-gulm.c clvmd-openais.c clvmd-singlenode.c 
	                 clvmd.c lvm-functions.c refresh_clvmd.c 
	                 tcp-comms.c 
	daemons/cmirrord: logging.h 
	tools          : tools.h 

Log message:
	Use "" instead of <> for  configure.h and libdevmapper.h
	Move configure.h as the first header for clvmd source files.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-cman.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-corosync.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-gulm.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-openais.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-singlenode.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/refresh_clvmd.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/tcp-comms.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/logging.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.67&r2=1.68

--- LVM2/daemons/clvmd/clvmd-cman.c	2009/04/21 13:11:28	1.26
+++ LVM2/daemons/clvmd/clvmd-cman.c	2010/06/15 11:00:44	1.27
@@ -20,7 +20,7 @@
 #define _GNU_SOURCE
 #define _FILE_OFFSET_BITS 64
 
-#include <configure.h>
+#include "configure.h"
 #include <pthread.h>
 #include <sys/types.h>
 #include <sys/stat.h>
@@ -40,7 +40,7 @@
 #include <fcntl.h>
 #include <getopt.h>
 #include <errno.h>
-#include <libdevmapper.h>
+#include "libdevmapper.h"
 #include <libdlm.h>
 
 #include "clvmd-comms.h"
--- LVM2/daemons/clvmd/clvmd-command.c	2010/06/04 12:59:30	1.36
+++ LVM2/daemons/clvmd/clvmd-command.c	2010/06/15 11:00:45	1.37
@@ -53,7 +53,7 @@
 #define _GNU_SOURCE
 #define _FILE_OFFSET_BITS 64
 
-#include <configure.h>
+#include "configure.h"
 #include <pthread.h>
 #include <sys/types.h>
 #include <sys/utsname.h>
@@ -68,7 +68,7 @@
 #include <stddef.h>
 #include <unistd.h>
 #include <errno.h>
-#include <libdevmapper.h>
+#include "libdevmapper.h"
 #include <libdlm.h>
 
 #include "locking.h"
--- LVM2/daemons/clvmd/clvmd-corosync.c	2009/09/15 12:51:28	1.12
+++ LVM2/daemons/clvmd/clvmd-corosync.c	2010/06/15 11:00:45	1.13
@@ -20,7 +20,7 @@
 #define _GNU_SOURCE
 #define _FILE_OFFSET_BITS 64
 
-#include <configure.h>
+#include "configure.h"
 #include <pthread.h>
 #include <sys/types.h>
 #include <sys/utsname.h>
@@ -43,7 +43,7 @@
 #include <utmpx.h>
 #include <syslog.h>
 #include <assert.h>
-#include <libdevmapper.h>
+#include "libdevmapper.h"
 
 #include <corosync/corotypes.h>
 #include <corosync/cpg.h>
--- LVM2/daemons/clvmd/clvmd-gulm.c	2009/09/15 12:51:28	1.28
+++ LVM2/daemons/clvmd/clvmd-gulm.c	2010/06/15 11:00:45	1.29
@@ -24,6 +24,7 @@
  * on the cluster nodes. That is done in tcp-comms.c
  */
 
+#include "configure.h"
 #include <pthread.h>
 #include <sys/types.h>
 #include <sys/utsname.h>
@@ -46,7 +47,7 @@
 #include <utmpx.h>
 #include <syslog.h>
 #include <assert.h>
-#include <libdevmapper.h>
+#include "libdevmapper.h"
 #include <ccs.h>
 #include <libgulm.h>
 
--- LVM2/daemons/clvmd/clvmd-openais.c	2009/09/15 12:51:28	1.13
+++ LVM2/daemons/clvmd/clvmd-openais.c	2010/06/15 11:00:45	1.14
@@ -20,7 +20,7 @@
 #define _GNU_SOURCE
 #define _FILE_OFFSET_BITS 64
 
-#include <configure.h>
+#include "configure.h"
 #include <pthread.h>
 #include <sys/types.h>
 #include <sys/utsname.h>
@@ -43,7 +43,7 @@
 #include <utmpx.h>
 #include <syslog.h>
 #include <assert.h>
-#include <libdevmapper.h>
+#include "libdevmapper.h"
 
 #include <openais/saAis.h>
 #include <openais/saLck.h>
--- LVM2/daemons/clvmd/clvmd-singlenode.c	2010/03/26 15:45:36	1.2
+++ LVM2/daemons/clvmd/clvmd-singlenode.c	2010/06/15 11:00:45	1.3
@@ -15,13 +15,13 @@
 #define _GNU_SOURCE
 #define _FILE_OFFSET_BITS 64
 
+#include "configure.h"
 #include <netinet/in.h>
 #include <sys/un.h>
 #include <sys/socket.h>
 #include <unistd.h>
 #include <fcntl.h>
-#include <configure.h>
-#include <libdevmapper.h>
+#include "libdevmapper.h"
 
 #include <pthread.h>
 
--- LVM2/daemons/clvmd/clvmd.c	2010/04/20 14:07:38	1.70
+++ LVM2/daemons/clvmd/clvmd.c	2010/06/15 11:00:45	1.71
@@ -20,8 +20,8 @@
 #define _GNU_SOURCE
 #define _FILE_OFFSET_BITS 64
 
-#include <configure.h>
-#include <libdevmapper.h>
+#include "configure.h"
+#include "libdevmapper.h"
 
 #include <pthread.h>
 #include <sys/types.h>
--- LVM2/daemons/clvmd/lvm-functions.c	2010/06/04 12:59:30	1.91
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/06/15 11:00:45	1.92
@@ -16,7 +16,7 @@
 #define _GNU_SOURCE
 #define _FILE_OFFSET_BITS 64
 
-#include <configure.h>
+#include "configure.h"
 #include <pthread.h>
 #include <sys/types.h>
 #include <sys/utsname.h>
@@ -34,7 +34,7 @@
 #include <errno.h>
 #include <syslog.h>
 #include <assert.h>
-#include <libdevmapper.h>
+#include "libdevmapper.h"
 #include <libdlm.h>
 
 #include "lvm-types.h"
--- LVM2/daemons/clvmd/refresh_clvmd.c	2010/06/07 13:52:53	1.9
+++ LVM2/daemons/clvmd/refresh_clvmd.c	2010/06/15 11:00:45	1.10
@@ -20,13 +20,13 @@
 #define _GNU_SOURCE
 #define _FILE_OFFSET_BITS 64
 
-#include <configure.h>
+#include "configure.h"
 #include <stddef.h>
 #include <sys/socket.h>
 #include <sys/un.h>
 #include <errno.h>
 #include <unistd.h>
-#include <libdevmapper.h>
+#include "libdevmapper.h"
 #include <stdint.h>
 #include <stdio.h>
 #include <limits.h>
--- LVM2/daemons/clvmd/tcp-comms.c	2009/09/15 12:51:28	1.20
+++ LVM2/daemons/clvmd/tcp-comms.c	2010/06/15 11:00:45	1.21
@@ -23,7 +23,7 @@
 #define _GNU_SOURCE
 #define _FILE_OFFSET_BITS 64
 
-#include <configure.h>
+#include "configure.h"
 #include <pthread.h>
 #include <sys/types.h>
 #include <sys/utsname.h>
@@ -44,7 +44,7 @@
 #include <syslog.h>
 #include <netdb.h>
 #include <assert.h>
-#include <libdevmapper.h>
+#include "libdevmapper.h"
 
 #include "clvm.h"
 #include "clvmd-comms.h"
--- LVM2/daemons/cmirrord/logging.h	2010/01/18 21:07:24	1.5
+++ LVM2/daemons/cmirrord/logging.h	2010/06/15 11:00:45	1.6
@@ -16,7 +16,7 @@
 #define _GNU_SOURCE
 #define _FILE_OFFSET_BITS 64
 
-#include <configure.h>
+#include "configure.h"
 #include <stdio.h>
 #include <stdint.h>
 #include <syslog.h>
--- LVM2/tools/tools.h	2010/04/29 01:38:14	1.67
+++ LVM2/tools/tools.h	2010/06/15 11:00:46	1.68
@@ -19,9 +19,9 @@
 #define _GNU_SOURCE
 #define _FILE_OFFSET_BITS 64
 
-#include <configure.h>
+#include "configure.h"
 #include <assert.h>
-#include <libdevmapper.h>
+#include "libdevmapper.h"
 
 #include "lvm-types.h"
 #include "lvm-logging.h"


