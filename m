From: agk@sourceware.org <agk@sourceware.org>
Date: 18 Jan 2010 21:07:26 -0000
Subject: LVM2/daemons/cmirrord clogd.c cluster.c cluste ...
Message-ID: <20100118210726.16463.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-01-18 21:07:24

Modified files:
	daemons/cmirrord: clogd.c cluster.c cluster.h common.h compat.c 
	                  compat.h functions.c functions.h link_mon.c 
	                  link_mon.h local.c local.h logging.c logging.h 

Log message:
	Clean up include files.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/clogd.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/cluster.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/cluster.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/common.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/compat.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/compat.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/link_mon.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/link_mon.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/local.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/local.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/logging.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/logging.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/daemons/cmirrord/clogd.c	2010/01/18 20:08:44	1.7
+++ LVM2/daemons/cmirrord/clogd.c	2010/01/18 21:07:24	1.8
@@ -9,33 +9,17 @@
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
+#include "logging.h"
+#include "common.h"
+#include "functions.h"
+#include "link_mon.h"
+#include "local.h"
 
-#include "configure.h"
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <stdint.h>
-#include <string.h>
 #include <errno.h>
-#include <sched.h>
-#include <sys/types.h>
-#include <sys/wait.h>
-#include <sys/stat.h>
-#include <signal.h>
-#include <unistd.h>
 #include <fcntl.h>
-#include <linux/types.h>
 #include <sys/socket.h>
-#include <linux/netlink.h>
-#include <linux/dm-ioctl.h>
-
-#include "dm-log-userspace.h"
-#include "functions.h"
-#include "local.h"
-#include "cluster.h"
-#include "common.h"
-#include "logging.h"
-#include "link_mon.h"
+#include <sys/wait.h>
+#include <unistd.h>
 
 static int exit_now = 0;
 static sigset_t signal_mask;
--- LVM2/daemons/cmirrord/cluster.c	2010/01/18 20:08:44	1.11
+++ LVM2/daemons/cmirrord/cluster.c	2010/01/18 21:07:24	1.12
@@ -9,34 +9,22 @@
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
-#include <errno.h>
-#include <string.h>
-#include <sys/types.h>
-#include <unistd.h>
-#include <stdint.h>
-#include <stdlib.h>
-#include <signal.h>
-#include <sys/socket.h> /* These are for OpenAIS CPGs */
-#include <sys/select.h>
-#include <sys/un.h>
-#include <netinet/in.h>
-#include <arpa/inet.h>
-#include <corosync/corotypes.h>
-#include <corosync/cpg.h>
-#include <openais/saAis.h>
-#include <openais/saCkpt.h>
-
-#include "dm-log-userspace.h"
-#include "libdevmapper.h"
-#include "functions.h"
-#include "local.h"
-#include "common.h"
 #include "logging.h"
-#include "link_mon.h"
 #include "cluster.h"
+#include "common.h"
 #include "compat.h"
+#include "functions.h"
+#include "link_mon.h"
+#include "local.h"
 #include "xlate.h"
 
+#include <corosync/cpg.h>
+#include <errno.h>
+#include <openais/saAis.h>
+#include <openais/saCkpt.h>
+#include <signal.h>
+#include <unistd.h>
+
 /* Open AIS error codes */
 #define str_ais_error(x)						\
 	((x) == SA_AIS_OK) ? "SA_AIS_OK" :				\
--- LVM2/daemons/cmirrord/cluster.h	2010/01/15 19:49:36	1.6
+++ LVM2/daemons/cmirrord/cluster.h	2010/01/18 21:07:24	1.7
@@ -9,11 +9,11 @@
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
-#ifndef __CLUSTER_LOG_CLUSTER_DOT_H__
-#define __CLUSTER_LOG_CLUSTER_DOT_H__
+#ifndef _LVM_CLOG_CLUSTER_H
+#define _LVM_CLOG_CLUSTER_H
 
-#include "libdevmapper.h"
 #include "dm-log-userspace.h"
+#include "libdevmapper.h"
 
 #define DM_ULOG_RESPONSE 0x1000 /* in last byte of 32-bit value */
 #define DM_ULOG_CHECKPOINT_READY 21
@@ -73,4 +73,4 @@
 
 int cluster_send(struct clog_request *rq);
 
-#endif /* __CLUSTER_LOG_CLUSTER_DOT_H__ */
+#endif /* _LVM_CLOG_CLUSTER_H */
--- LVM2/daemons/cmirrord/common.h	2010/01/15 19:49:36	1.4
+++ LVM2/daemons/cmirrord/common.h	2010/01/18 21:07:24	1.5
@@ -9,8 +9,8 @@
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
-#ifndef __CLUSTER_LOG_COMMON_DOT_H__
-#define __CLUSTER_LOG_COMMON_DOT_H__
+#ifndef _LVM_CLOG_COMMON_H
+#define _LVM_CLOG_COMMON_H
 
 /*
  * If there are problems when forking off to become a daemon,
@@ -30,4 +30,4 @@
 
 #define DM_ULOG_REQUEST_SIZE 1024
 
-#endif /* __CLUSTER_LOG_COMMON_DOT_H__ */
+#endif /* _LVM_CLOG_COMMON_H */
--- LVM2/daemons/cmirrord/compat.c	2010/01/18 20:58:50	1.3
+++ LVM2/daemons/cmirrord/compat.c	2010/01/18 21:07:24	1.4
@@ -5,16 +5,12 @@
  * modify, copy, or redistribute it subject to the terms and conditions
  * of the GNU Lesser General Public License v.2.1.
  */
-#include <stdlib.h>
-#include <errno.h>
-#include <stdint.h>
-#include <string.h>
-#include "dm-log-userspace.h"
 #include "logging.h"
 #include "cluster.h"
+#include "compat.h"
 #include "xlate.h"
 
-#include "compat.h"
+#include <errno.h>
 
 /*
  * Older versions of the log daemon communicate with different
@@ -201,7 +197,7 @@
 		if (data_len < (COMPAT_OFFSET + sizeof(*rq)))
 			return -ENOSPC;
 
-		rq = data + COMPAT_OFFSET;
+		rq = (struct clog_request *)((char *)data + COMPAT_OFFSET);
 		break;
 	default:
 		LOG_ERROR("Unable to process cluster message: "
--- LVM2/daemons/cmirrord/compat.h	2010/01/15 19:49:36	1.1
+++ LVM2/daemons/cmirrord/compat.h	2010/01/18 21:07:24	1.2
@@ -5,8 +5,8 @@
  * modify, copy, or redistribute it subject to the terms and conditions
  * of the GNU Lesser General Public License v.2.1.
  */
-#ifndef __COMPAT_DOT_H__
-#define __COMPAT_DOT_H__
+#ifndef _LVM_CLOG_COMPAT_H
+#define _LVM_CLOG_COMPAT_H
 
 /*
  * The intermachine communication structure version are:
@@ -22,4 +22,4 @@
 int clog_request_to_network(struct clog_request *rq);
 int clog_request_from_network(void *data, size_t data_len);
 
-#endif /* __COMPAT_DOT_H__ */
+#endif /* _LVM_CLOG_COMPAT_H */
--- LVM2/daemons/cmirrord/functions.c	2010/01/18 20:58:50	1.13
+++ LVM2/daemons/cmirrord/functions.c	2010/01/18 21:07:24	1.14
@@ -9,27 +9,16 @@
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
-#define _GNU_SOURCE
-#define _FILE_OFFSET_BITS 64
+#include "logging.h"
+#include "functions.h"
 
-#include <stdint.h>
-#include <errno.h>
-#include <string.h>
-#include <sys/types.h>
-#include <sys/stat.h>
 #include <dirent.h>
-#include <unistd.h>
-#include <signal.h>
-#include <linux/kdev_t.h>
-//#define __USE_GNU /* for O_DIRECT */
+#include <errno.h>
 #include <fcntl.h>
+#include <linux/kdev_t.h>
+#include <signal.h>
 #include <time.h>
-#include "libdevmapper.h"
-#include "dm-log-userspace.h"
-#include "functions.h"
-#include "common.h"
-#include "cluster.h"
-#include "logging.h"
+#include <unistd.h>
 
 #define BYTE_SHIFT 3
 
--- LVM2/daemons/cmirrord/functions.h	2009/08/13 16:34:07	1.5
+++ LVM2/daemons/cmirrord/functions.h	2010/01/18 21:07:24	1.6
@@ -9,8 +9,8 @@
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
-#ifndef __CLOG_FUNCTIONS_DOT_H__
-#define __CLOG_FUNCTIONS_DOT_H__
+#ifndef _LVM_CLOG_FUNCTIONS_H
+#define _LVM_CLOG_FUNCTIONS_H
 
 #include "dm-log-userspace.h"
 #include "cluster.h"
@@ -31,4 +31,4 @@
 int log_status(void);
 void log_debug(void);
 
-#endif /* __CLOG_FUNCTIONS_DOT_H__ */
+#endif /* _LVM_CLOG_FUNCTIONS_H */
--- LVM2/daemons/cmirrord/link_mon.c	2010/01/18 20:08:44	1.3
+++ LVM2/daemons/cmirrord/link_mon.c	2010/01/18 21:07:24	1.4
@@ -9,13 +9,13 @@
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
-#include <stdlib.h>
-#include <errno.h>
-#include <poll.h>
-
 #include "logging.h"
 #include "link_mon.h"
 
+#include <errno.h>
+#include <poll.h>
+#include <stdlib.h>
+
 struct link_callback {
 	int fd;
 	const char *name;
--- LVM2/daemons/cmirrord/link_mon.h	2010/01/18 20:08:44	1.3
+++ LVM2/daemons/cmirrord/link_mon.h	2010/01/18 21:07:24	1.4
@@ -9,12 +9,12 @@
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
-#ifndef __LINK_MON_DOT_H__
-#define __LINK_MON_DOT_H__
+#ifndef _LVM_CLOG_LINK_MON_H
+#define _LVM_CLOG_LINK_MON_H
 
 int links_register(int fd, const char *name, int (*callback)(void *data), void *data);
 int links_unregister(int fd);
 int links_monitor(void);
 int links_issue_callbacks(void);
 
-#endif /* __LINK_MON_DOT_H__ */
+#endif /* _LVM_CLOG_LINK_MON_H */
--- LVM2/daemons/cmirrord/local.c	2010/01/18 20:58:50	1.6
+++ LVM2/daemons/cmirrord/local.c	2010/01/18 21:07:24	1.7
@@ -9,23 +9,17 @@
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
-#include <unistd.h>
+#include "logging.h"
+#include "common.h"
+#include "functions.h"
+#include "link_mon.h"
+#include "local.h"
+
 #include <errno.h>
-#include <string.h>
-#include <stdint.h>
-#include <sys/types.h>
 #include <sys/socket.h>
-#include <sys/poll.h>
 #include <linux/connector.h>
 #include <linux/netlink.h>
-
-#include "dm-log-userspace.h"
-#include "functions.h"
-#include "cluster.h"
-#include "common.h"
-#include "logging.h"
-#include "link_mon.h"
-#include "local.h"
+#include <unistd.h>
 
 #ifndef CN_IDX_DM
 /* Kernel 2.6.31 is required to run this code */
--- LVM2/daemons/cmirrord/local.h	2009/08/13 16:34:07	1.3
+++ LVM2/daemons/cmirrord/local.h	2010/01/18 21:07:24	1.4
@@ -9,12 +9,12 @@
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
-#ifndef __CLUSTER_LOG_LOCAL_DOT_H__
-#define __CLUSTER_LOG_LOCAL_DOT_H__
+#ifndef _LVM_CLOG_LOCAL_H
+#define _LVM_CLOG_LOCAL_H
 
 int init_local(void);
 void cleanup_local(void);
 
 int kernel_send(struct dm_ulog_request *rq);
 
-#endif /* __CLUSTER_LOG_LOCAL_DOT_H__ */
+#endif /* _LVM_CLOG_LOCAL_H */
--- LVM2/daemons/cmirrord/logging.c	2010/01/18 20:08:44	1.4
+++ LVM2/daemons/cmirrord/logging.c	2010/01/18 21:07:24	1.5
@@ -9,8 +9,7 @@
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
-#include <stdio.h>
-#include <syslog.h>
+#include "logging.h"
 
 const char *__rq_types_off_by_one[] = {
 	"DM_ULOG_CTR",
--- LVM2/daemons/cmirrord/logging.h	2009/08/13 16:34:07	1.4
+++ LVM2/daemons/cmirrord/logging.h	2010/01/18 21:07:24	1.5
@@ -10,16 +10,21 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#ifndef __CLUSTER_LOG_LOGGING_DOT_H__
-#define __CLUSTER_LOG_LOGGING_DOT_H__
+#ifndef _LVM_CLOG_LOGGING_H
+#define _LVM_CLOG_LOGGING_H
 
+#define _GNU_SOURCE
+#define _FILE_OFFSET_BITS 64
+
+#include <configure.h>
 #include <stdio.h>
+#include <stdint.h>
 #include <syslog.h>
 
 /* SHORT_UUID - print last 8 chars of a string */
 #define SHORT_UUID(x) (strlen(x) > 8) ? ((x) + (strlen(x) - 8)) : (x)
 
-extern char *__rq_types_off_by_one[];
+extern const char *__rq_types_off_by_one[];
 #define RQ_TYPE(x) __rq_types_off_by_one[(x) - 1]
 
 extern int log_tabbing;
@@ -69,4 +74,4 @@
 #define LOG_PRINT(f, arg...) LOG_OUTPUT(LOG_NOTICE, f, ## arg)
 #define LOG_ERROR(f, arg...) LOG_OUTPUT(LOG_ERR, f, ## arg)
 
-#endif /* __CLUSTER_LOG_LOGGING_DOT_H__ */
+#endif /* _LVM_CLOG_LOGGING_H */


