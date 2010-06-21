From: agk@sourceware.org <agk@sourceware.org>
Date: 21 Jun 2010 15:57:04 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-cman.c da ...
Message-ID: <20100621155704.20581.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-06-21 15:57:00

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-cman.c clvmd-command.c clvmd-corosync.c 
	                 clvmd-gulm.c clvmd-openais.c clvmd-singlenode.c 
	                 clvmd.c lvm-functions.c refresh_clvmd.c 
	                 tcp-comms.c 
	lib/log        : log.h 
	man            : dmeventd.8.in lvextend.8.in lvmconf.8.in 
	                 lvreduce.8.in lvresize.8.in 
Added files:
	daemons/clvmd  : clvmd-common.h 

Log message:
	Various cleanups following recent commits.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1621&r2=1.1622
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-common.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-cman.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-corosync.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-gulm.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-openais.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-singlenode.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/refresh_clvmd.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/tcp-comms.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.h.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmeventd.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvextend.8.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvmconf.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvreduce.8.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvresize.8.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/WHATS_NEW	2010/06/21 10:45:15	1.1621
+++ LVM2/WHATS_NEW	2010/06/21 15:56:57	1.1622
@@ -1,16 +1,18 @@
 Version 2.02.68 -
 ===============================
-  Add workaround for clvmd -S (socket closed too early and server drops the command).
+  Sleep to workaround clvmd -S race: socket closed early and server drops cmd.
   Use early udev synchronisation and update of dev nodes for clustered mirrors.
-  Unneeded kdev_t.h reference causing harm for cmirrord on some archs.
-  Add man pages for lvmconf and unsupported lvmsadc and lvmsar tools.
-  Fix exit code when requesting help using documented -o help option.
+  Remove incorrect inclusion of kdev_t.h from cmirrord/functions.h.
+  Add man pages for lvmconf and non-existent lvmsadc and lvmsar tools.
+  Exit successfully when using -o help (but not -o +help) with LVM reports.
   Do not use internal DLM lock definitions in generic LVM2 clvmd code.
   Add dmeventd man page.
-  Update lvresize/extend/reduce manpages with --nofsck, --resizefs options.
+  Add --force, --nofsck and --resizefs to lvresize/extend/reduce man pages.
   Fix lvm2cmd example in documentation.
-  Allow use of lvm2app and lvm2cmd headers in C++ mode.
-  Fix wrong lvm path creation from configure introduced in previous release.
+  Allow use of lvm2app and lvm2cmd headers in C++ code.
+  Remove some unused #includes from clvmd files.
+  Use #include "" for libdevmapper.h and configure.h throughout tree.
+  Fix 'make exec_prefix' with LVM_PATH / DMEVENTD_PATH. (2.02.67)
   Fix segfault in clvmd -R if no response from daemon received.
 
 Version 2.02.67 - 4th June 2010
/cvs/lvm2/LVM2/daemons/clvmd/clvmd-common.h,v  -->  standard output
revision 1.1
--- LVM2/daemons/clvmd/clvmd-common.h
+++ -	2010-06-21 15:57:00.489877000 +0000
@@ -0,0 +1,33 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+/*
+ * This file must be included first by every clvmd source file.
+ */
+#ifndef _LVM_CLVMD_COMMON_H
+#define _LVM_CLVMD_COMMON_H
+
+#include "configure.h"
+
+#define _GNU_SOURCE
+#define _FILE_OFFSET_BITS 64
+
+#include "libdevmapper.h"
+
+#include "lvm-logging.h"
+
+#include <unistd.h>
+#include <sys/stat.h>
+
+#endif
--- LVM2/daemons/clvmd/clvmd-cman.c	2010/06/15 11:00:44	1.27
+++ LVM2/daemons/clvmd/clvmd-cman.c	2010/06/21 15:56:58	1.28
@@ -17,38 +17,19 @@
  * CMAN communication layer for clvmd.
  */
 
-#define _GNU_SOURCE
-#define _FILE_OFFSET_BITS 64
+#include "clvmd-common.h"
 
-#include "configure.h"
 #include <pthread.h>
-#include <sys/types.h>
-#include <sys/stat.h>
-#include <sys/socket.h>
-#include <sys/uio.h>
-#include <sys/un.h>
-#include <sys/time.h>
-#include <sys/ioctl.h>
-#include <sys/utsname.h>
-#include <syslog.h>
-#include <netinet/in.h>
-#include <stdio.h>
-#include <stdlib.h>
-#include <stddef.h>
-#include <signal.h>
-#include <unistd.h>
-#include <fcntl.h>
-#include <getopt.h>
-#include <errno.h>
-#include "libdevmapper.h"
-#include <libdlm.h>
 
 #include "clvmd-comms.h"
 #include "clvm.h"
-#include "lvm-logging.h"
 #include "clvmd.h"
 #include "lvm-functions.h"
 
+#include <libdlm.h>
+
+#include <syslog.h>
+
 #define LOCKSPACE_NAME "clvmd"
 
 struct clvmd_node
--- LVM2/daemons/clvmd/clvmd-command.c	2010/06/17 12:48:55	1.38
+++ LVM2/daemons/clvmd/clvmd-command.c	2010/06/21 15:56:58	1.39
@@ -50,32 +50,18 @@
 
 */
 
-#define _GNU_SOURCE
-#define _FILE_OFFSET_BITS 64
+#include "clvmd-common.h"
 
-#include "configure.h"
 #include <pthread.h>
-#include <sys/types.h>
-#include <sys/utsname.h>
-#include <sys/ioctl.h>
-#include <sys/socket.h>
-#include <sys/stat.h>
-#include <stdio.h>
-#include <stdlib.h>
-#include <stdint.h>
-#include <fcntl.h>
-#include <string.h>
-#include <stddef.h>
-#include <unistd.h>
-#include <errno.h>
-#include "libdevmapper.h"
 
-#include "locking.h"
-#include "lvm-logging.h"
-#include "lvm-functions.h"
 #include "clvmd-comms.h"
 #include "clvm.h"
 #include "clvmd.h"
+#include "lvm-functions.h"
+
+#include "locking.h"
+
+#include <sys/utsname.h>
 
 extern debug_t debug;
 extern struct cluster_ops *clops;
--- LVM2/daemons/clvmd/clvmd-corosync.c	2010/06/15 11:00:45	1.13
+++ LVM2/daemons/clvmd/clvmd-corosync.c	2010/06/21 15:56:58	1.14
@@ -17,46 +17,23 @@
  * and lock manager.
  */
 
-#define _GNU_SOURCE
-#define _FILE_OFFSET_BITS 64
+#include "clvmd-common.h"
 
-#include "configure.h"
 #include <pthread.h>
-#include <sys/types.h>
-#include <sys/utsname.h>
-#include <sys/ioctl.h>
-#include <sys/socket.h>
-#include <sys/stat.h>
-#include <sys/file.h>
-#include <sys/socket.h>
-#include <netinet/in.h>
-#include <stdio.h>
-#include <stdlib.h>
-#include <stdint.h>
-#include <signal.h>
-#include <fcntl.h>
-#include <string.h>
-#include <stddef.h>
-#include <stdint.h>
-#include <unistd.h>
-#include <errno.h>
-#include <utmpx.h>
-#include <syslog.h>
-#include <assert.h>
-#include "libdevmapper.h"
 
-#include <corosync/corotypes.h>
+#include "clvm.h"
+#include "clvmd-comms.h"
+#include "clvmd.h"
+#include "lvm-functions.h"
+
+#include "locking.h"
+
 #include <corosync/cpg.h>
 #include <corosync/quorum.h>
 #include <corosync/confdb.h>
 #include <libdlm.h>
 
-#include "locking.h"
-#include "lvm-logging.h"
-#include "clvm.h"
-#include "clvmd-comms.h"
-#include "lvm-functions.h"
-#include "clvmd.h"
+#include <syslog.h>
 
 /* Timeout value for several corosync calls */
 #define LOCKSPACE_NAME "clvmd"
--- LVM2/daemons/clvmd/clvmd-gulm.c	2010/06/17 12:48:55	1.30
+++ LVM2/daemons/clvmd/clvmd-gulm.c	2010/06/21 15:56:58	1.31
@@ -24,35 +24,27 @@
  * on the cluster nodes. That is done in tcp-comms.c
  */
 
-#include "configure.h"
+#include "clvmd-common.h"
+
 #include <pthread.h>
-#include <sys/types.h>
 #include <sys/utsname.h>
 #include <sys/ioctl.h>
 #include <sys/socket.h>
-#include <sys/stat.h>
 #include <sys/file.h>
 #include <sys/socket.h>
 #include <netinet/in.h>
-#include <stdio.h>
-#include <stdlib.h>
 #include <stdint.h>
 #include <signal.h>
 #include <fcntl.h>
-#include <string.h>
 #include <stddef.h>
 #include <stdint.h>
-#include <unistd.h>
-#include <errno.h>
 #include <utmpx.h>
 #include <syslog.h>
 #include <assert.h>
-#include "libdevmapper.h"
 #include <ccs.h>
 #include <libgulm.h>
 
 #include "locking.h"
-#include "lvm-logging.h"
 #include "clvm.h"
 #include "clvmd-comms.h"
 #include "lvm-functions.h"
--- LVM2/daemons/clvmd/clvmd-openais.c	2010/06/15 11:00:45	1.14
+++ LVM2/daemons/clvmd/clvmd-openais.c	2010/06/21 15:56:58	1.15
@@ -17,33 +17,11 @@
  * and lock manager.
  */
 
-#define _GNU_SOURCE
-#define _FILE_OFFSET_BITS 64
+#include "clvmd-common.h"
 
-#include "configure.h"
 #include <pthread.h>
-#include <sys/types.h>
-#include <sys/utsname.h>
-#include <sys/ioctl.h>
-#include <sys/socket.h>
-#include <sys/stat.h>
-#include <sys/file.h>
-#include <sys/socket.h>
-#include <netinet/in.h>
-#include <stdio.h>
-#include <stdlib.h>
-#include <stdint.h>
-#include <signal.h>
 #include <fcntl.h>
-#include <string.h>
-#include <stddef.h>
-#include <stdint.h>
-#include <unistd.h>
-#include <errno.h>
-#include <utmpx.h>
 #include <syslog.h>
-#include <assert.h>
-#include "libdevmapper.h"
 
 #include <openais/saAis.h>
 #include <openais/saLck.h>
@@ -52,7 +30,6 @@
 #include <corosync/cpg.h>
 
 #include "locking.h"
-#include "lvm-logging.h"
 #include "clvm.h"
 #include "clvmd-comms.h"
 #include "lvm-functions.h"
--- LVM2/daemons/clvmd/clvmd-singlenode.c	2010/06/15 11:00:45	1.3
+++ LVM2/daemons/clvmd/clvmd-singlenode.c	2010/06/21 15:56:58	1.4
@@ -12,26 +12,20 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#define _GNU_SOURCE
-#define _FILE_OFFSET_BITS 64
-
-#include "configure.h"
-#include <netinet/in.h>
-#include <sys/un.h>
-#include <sys/socket.h>
-#include <unistd.h>
-#include <fcntl.h>
-#include "libdevmapper.h"
+#include "clvmd-common.h"
 
 #include <pthread.h>
 
 #include "locking.h"
-#include "lvm-logging.h"
 #include "clvm.h"
 #include "clvmd-comms.h"
 #include "lvm-functions.h"
 #include "clvmd.h"
 
+#include <sys/un.h>
+#include <sys/socket.h>
+#include <fcntl.h>
+
 static const char SINGLENODE_CLVMD_SOCKNAME[] = "\0singlenode_clvmd";
 static int listen_fd = -1;
 
--- LVM2/daemons/clvmd/clvmd.c	2010/06/15 11:00:45	1.71
+++ LVM2/daemons/clvmd/clvmd.c	2010/06/21 15:56:58	1.72
@@ -17,44 +17,28 @@
  * CLVMD: Cluster LVM daemon
  */
 
-#define _GNU_SOURCE
-#define _FILE_OFFSET_BITS 64
-
-#include "configure.h"
-#include "libdevmapper.h"
+#include "clvmd-common.h"
 
 #include <pthread.h>
-#include <sys/types.h>
-#include <sys/stat.h>
-#include <sys/socket.h>
-#include <sys/uio.h>
-#include <sys/un.h>
-#include <sys/time.h>
-#include <sys/ioctl.h>
-#include <sys/utsname.h>
-#include <netinet/in.h>
-#include <stdio.h>
-#include <stdlib.h>
-#include <stddef.h>
-#include <stdarg.h>
-#include <signal.h>
-#include <unistd.h>
-#include <fcntl.h>
-#include <getopt.h>
-#include <syslog.h>
-#include <errno.h>
-#include <limits.h>
-#ifdef HAVE_COROSYNC_CONFDB_H
-#include <corosync/confdb.h>
-#endif
 
 #include "clvmd-comms.h"
-#include "lvm-functions.h"
 #include "clvm.h"
-#include "lvm-version.h"
 #include "clvmd.h"
+#include "lvm-functions.h"
+#include "lvm-version.h"
 #include "refresh_clvmd.h"
-#include "lvm-logging.h"
+
+#ifdef HAVE_COROSYNC_CONFDB_H
+#include <corosync/confdb.h>
+#endif
+
+#include <fcntl.h>
+#include <netinet/in.h>
+#include <signal.h>
+#include <stddef.h>
+#include <syslog.h>
+#include <sys/un.h>
+#include <sys/utsname.h>
 
 #ifndef TRUE
 #define TRUE 1
--- LVM2/daemons/clvmd/lvm-functions.c	2010/06/17 12:48:55	1.93
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/06/21 15:56:58	1.94
@@ -13,28 +13,9 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#define _GNU_SOURCE
-#define _FILE_OFFSET_BITS 64
+#include "clvmd-common.h"
 
-#include "configure.h"
 #include <pthread.h>
-#include <sys/types.h>
-#include <sys/utsname.h>
-#include <sys/ioctl.h>
-#include <sys/socket.h>
-#include <sys/stat.h>
-#include <stdio.h>
-#include <stdlib.h>
-#include <stdint.h>
-#include <fcntl.h>
-#include <string.h>
-#include <stddef.h>
-#include <stdint.h>
-#include <unistd.h>
-#include <errno.h>
-#include <syslog.h>
-#include <assert.h>
-#include "libdevmapper.h"
 
 #include "lvm-types.h"
 #include "clvm.h"
@@ -45,14 +26,13 @@
 /* LVM2 headers */
 #include "toolcontext.h"
 #include "lvmcache.h"
-#include "lvm-logging.h"
 #include "lvm-globals.h"
 #include "activate.h"
-#include "locking.h"
 #include "archiver.h"
-#include "defaults.h"
 #include "memlock.h"
 
+#include <syslog.h>
+
 static struct cmd_context *cmd = NULL;
 static struct dm_hash_table *lv_hash = NULL;
 static pthread_mutex_t lv_hash_lock;
--- LVM2/daemons/clvmd/refresh_clvmd.c	2010/06/21 10:45:16	1.11
+++ LVM2/daemons/clvmd/refresh_clvmd.c	2010/06/21 15:56:58	1.12
@@ -17,22 +17,14 @@
  * Send a command to a running clvmd from the command-line
  */
 
-#define _GNU_SOURCE
-#define _FILE_OFFSET_BITS 64
+#include "clvmd-common.h"
+
+#include "clvm.h"
+#include "refresh_clvmd.h"
 
-#include "configure.h"
 #include <stddef.h>
 #include <sys/socket.h>
 #include <sys/un.h>
-#include <errno.h>
-#include <unistd.h>
-#include "libdevmapper.h"
-#include <stdint.h>
-#include <stdio.h>
-#include <limits.h>
-
-#include "clvm.h"
-#include "refresh_clvmd.h"
 
 typedef struct lvm_response {
 	char node[255];
--- LVM2/daemons/clvmd/tcp-comms.c	2010/06/15 11:00:45	1.21
+++ LVM2/daemons/clvmd/tcp-comms.c	2010/06/21 15:56:58	1.22
@@ -20,31 +20,22 @@
  * It can also make outgoing connnections to the other clvmd nodes.
  */
 
-#define _GNU_SOURCE
-#define _FILE_OFFSET_BITS 64
+#include "clvmd-common.h"
 
-#include "configure.h"
 #include <pthread.h>
-#include <sys/types.h>
 #include <sys/utsname.h>
 #include <sys/ioctl.h>
 #include <sys/socket.h>
-#include <sys/stat.h>
 #include <sys/socket.h>
 #include <netinet/in.h>
-#include <stdio.h>
-#include <stdlib.h>
 #include <stdint.h>
 #include <fcntl.h>
-#include <string.h>
 #include <stddef.h>
 #include <stdint.h>
-#include <unistd.h>
 #include <errno.h>
 #include <syslog.h>
 #include <netdb.h>
 #include <assert.h>
-#include "libdevmapper.h"
 
 #include "clvm.h"
 #include "clvmd-comms.h"
--- LVM2/lib/log/log.h	2010/05/05 22:37:53	1.49
+++ LVM2/lib/log/log.h	2010/06/21 15:56:59	1.50
@@ -16,8 +16,6 @@
 #ifndef _LVM_LOG_H
 #define _LVM_LOG_H
 
-#include <errno.h>
-
 /*
  * printf()-style macros to use for messages:
  *
--- LVM2/man/dmeventd.8.in	2010/06/17 12:14:43	1.1
+++ LVM2/man/dmeventd.8.in	2010/06/21 15:56:59	1.2
@@ -3,29 +3,28 @@
 dmeventd \- Device-mapper event daemon
 .SH SYNOPSIS
 .B dmeventd
-[\-V]
 [\-d]
 [\-f]
 [\-h]
+[\-V]
 [\-?]
 .SH DESCRIPTION
 dmeventd is the event monitoring daemon for device-mapper devices.
-Plugins are supported.
-
-.br
-LVM plugins:
-.TP
-Snapshot: monitor the filling of snapshot and emits a warning through 
-syslog, when the use of snapshot exceedes 80%.
-The warning is repeated when 85%, 90% and 95% of the snapshot are filled.
-(see \fBlvm.conf\fP)
-.TP
-Mirror: attempts to recover from failures (see \fBlvm.conf\fP).
+Library plugins can register and carry out actions triggered when
+particular events occur.
+.SH
+LVM PLUGINS
+.TP
+.I Mirror
+Attempts to handle device failure automatically.  See \fBlvm.conf\fP).
+.TP
+.I Snapshot
+Monitors how full a snapshot is becoming and emits a warning to
+syslog when it exceeds 80% full.
+The warning is repeated when 85%, 90% and 95% of the snapshot is filled.
+See \fBlvm.conf\fP.
 .SH OPTIONS
 .TP
-.I \-V
-Show version of dmeventd.
-.TP
 .I \-d
 Repeat from 1 to 3 times (-d, -dd, -ddd) to increase the detail of
 debug messages sent to syslog.
@@ -36,6 +35,9 @@
 .TP
 .I \-h, \-?
 Show help information.
+.TP
+.I \-V
+Show version of dmeventd.
 
 .SH SEE ALSO
 .BR lvm (8),
--- LVM2/man/lvextend.8.in	2010/06/17 11:25:43	1.7
+++ LVM2/man/lvextend.8.in	2010/06/21 15:56:59	1.8
@@ -65,7 +65,7 @@
 StripeSize must be 2^n (n = 2 to 9)
 .TP
 .I \-f, \-\-force
-Force size extension without any question.
+Proceed with size extension without prompting.
 .TP
 .I \-n, \-\-nofsck
 Do not perform fsck before extending filesystem when filesystem
@@ -73,8 +73,8 @@
 this option.
 .TP
 .I \-r, \-\-resizefs
-Resize underlying filesystem together with logical volume size.
-\fBfsadm\fR tool is used for filesystem resize.
+Resize underlying filesystem together with the logical volume using 
+\fBfsadm\fR(8).
 .SH Examples
 "lvextend -L +54 /dev/vg01/lvol10 /dev/sdk3" tries to extend the size of
 that logical volume by 54MB on physical volume /dev/sdk3.
--- LVM2/man/lvmconf.8.in	2010/06/18 10:19:30	1.1
+++ LVM2/man/lvmconf.8.in	2010/06/21 15:56:59	1.2
@@ -6,33 +6,31 @@
 
 .SH "SYNOPSIS"
 .B lvmconf
-[\-\-enable-cluster]
 [\-\-disable-cluster]
-[\-\-lockinglibdir <dir>]
-[\-\-lockinglib <lib>]
+[\-\-enable-cluster]
 [\-\-file <configfile>]
+[\-\-lockinglib <lib>]
+[\-\-lockinglibdir <dir>]
 
 .SH "DESCRIPTION"
 .B lvmconf
-is a helper tool to modify cluster locking in \fBlvm.conf\fP(5).
+is a script that modifies the locking configuration in an lvm configuration file. See \fBlvm.conf\fP(5).
 
 .SH "OPTIONS"
 .TP
 .BR \-\-disable-cluster
-Set the default non-cluster \fBlocking_type\fR.
+Set \fBlocking_type\fR to the default non-clustered type.
 .TP
 .BR \-\-enable-cluster
-Set a cluster-wide \fBlocking_type\fR available on the system.
+Set \fBlocking_type\fR to the default clustered type on this system.
 .TP
-.BR \-\-lockinglibdir " " \fI<dir>\fR
-Set \fBlocking_dir\fR directory where LVM2 places its files locks.
+.BR \-\-file " " \fI<configfile>\fR
+Apply the changes to \fBconfigfile\fR instead of the default \fB#DEFAULT_SYS_DIR#/lvm.conf\fR.
 .TP
 .BR \-\-lockinglib " " \fI<lib>\fR
-Set external \fBlocking_library\fR locking library to load.
+Set external \fBlocking_library\fR locking library to load if an external locking type is used.
 .TP
-.BR \-\-file " " \fI<configfile>\fR
-Use non-default \fBconfigfile\fR instead of \fB#DEFAULT_SYS_DIR#/lvm.conf\fR.
-
+.BR \-\-lockinglibdir " " \fI<dir>\fR
 .SH FILES
 .I #DEFAULT_SYS_DIR#/lvm.conf
 
--- LVM2/man/lvreduce.8.in	2010/06/17 11:25:43	1.7
+++ LVM2/man/lvreduce.8.in	2010/06/21 15:56:59	1.8
@@ -37,7 +37,7 @@
 See \fBlvm\fP for common options.
 .TP
 .I \-f, \-\-force
-Force size reduction without any question.
+Force size reduction without prompting even when it may cause data loss.
 .TP
 .I \-\-noudevsync
 Disable udev synchronisation. The
@@ -70,11 +70,11 @@
 .I \-n, \-\-nofsck
 Do not perform fsck before resizing filesystem when filesystem
 requires it. You may need to use \fB--force\fR to proceed with 
-this option. Note: using this option is dangerous.
+this option.
 .TP
 .I \-r, \-\-resizefs
-Resize underlying filesystem together with logical volume size.
-\fBfsadm\fR tool is used for filesystem resize.
+Resize underlying filesystem together with the logical volume using 
+\fBfsadm\fR(8).
 .SH Example
 "lvreduce -l -3 vg00/lvol1" reduces the size of logical volume lvol1
 in volume group vg00 by 3 logical extents.
--- LVM2/man/lvresize.8.in	2010/06/17 11:25:43	1.8
+++ LVM2/man/lvresize.8.in	2010/06/21 15:56:59	1.9
@@ -29,12 +29,8 @@
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
-.I \-\-noudevsync
-Disable udev synchronisation. The
-process will not wait for notification from udev.
-It will continue irrespective of any possible udev processing
-in the background.  You should only use this if udev is not running
-or has rules that ignore the devices LVM2 creates.
+.I \-f, \-\-force
+Force resize without prompting even when it may cause data loss.
 .TP
 .I \-l, \-\-extents [+|-]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}]
 Change or set the logical volume size in units of logical extents.
@@ -48,6 +44,22 @@
 Volume Group with the suffix %FREE, or (for a snapshot) as a percentage
 of the total space in the Origin Logical Volume with the suffix %ORIGIN.
 .TP
+.I \-n, \-\-nofsck
+Do not perform fsck before resizing filesystem when filesystem
+requires it. You may need to use \fB--force\fR to proceed with 
+this option.
+.TP
+.I \-\-noudevsync
+Disable udev synchronisation. The
+process will not wait for notification from udev.
+It will continue irrespective of any possible udev processing
+in the background.  You should only use this if udev is not running
+or has rules that ignore the devices LVM2 creates.
+.TP
+.I \-r, \-\-resizefs
+Resize underlying filesystem together with the logical volume using 
+\fBfsadm\fR(8).
+.TP
 .I \-L, \-\-size [+|-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]
 Change or set the logical volume size in units of megabytes.
 A size suffix of M for megabytes,
@@ -70,18 +82,6 @@
 must use a single value throughout.
 .br
 StripeSize must be 2^n (n = 2 to 9)
-.TP
-.I \-f, \-\-force
-Force resize without any question.
-.TP
-.I \-n, \-\-nofsck
-Do not perform fsck before resizing filesystem when filesystem
-requires it. You may need to use \fB--force\fR to proceed with 
-this option.
-.TP
-.I \-r, \-\-resizefs
-Resize underlying filesystem together with logical volume size.
-\fBfsadm\fR tool is used for filesystem resize.
 .SH Examples
 .br
 "lvresize -L+16M vg1/lv1 /dev/sda:0-1 /dev/sdb:0-1"


