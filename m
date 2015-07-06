From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  6 Jul 2015 16:35:08 +0000 (UTC)
Subject: master - include: Standardise around new tool.h.
Message-ID: <20150706163508.5E2D0610B9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dfe3eb12d074eb25063ce62a913825cfbc90a37b
Commit:        dfe3eb12d074eb25063ce62a913825cfbc90a37b
Parent:        d3605b81f36d0e534172ab376466308042142ab8
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jul 6 17:30:18 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jul 6 17:30:18 2015 +0100

include: Standardise around new tool.h.

---
 WHATS_NEW_DM                          |    1 +
 daemons/clvmd/clvmd-common.h          |    9 ++-------
 daemons/dmeventd/dmeventd.c           |   16 ++++------------
 daemons/dmeventd/libdevmapper-event.c |    5 -----
 daemons/lvmetad/lvmetad-core.c        |    8 ++++----
 daemons/lvmetad/testclient.c          |   15 +++++++++++++++
 daemons/lvmlockd/lvmlockctl.c         |   10 ++--------
 daemons/lvmlockd/lvmlockd-core.c      |   13 +++++--------
 daemons/lvmlockd/lvmlockd-dlm.c       |   32 ++++++++++++--------------------
 daemons/lvmlockd/lvmlockd-sanlock.c   |   23 ++++++++---------------
 daemons/lvmpolld/lvmpolld-common.h    |    7 +------
 include/.symlinks.in                  |    1 +
 lib/log/log.h                         |    2 --
 libdaemon/client/config-util.c        |   10 ++++------
 libdaemon/client/config-util.h        |    4 ----
 libdaemon/client/daemon-client.c      |    8 ++++----
 libdaemon/client/daemon-client.h      |    1 -
 libdaemon/client/daemon-io.c          |    8 ++++----
 libdaemon/client/daemon-io.h          |    6 ------
 libdaemon/server/daemon-log.c         |   17 +++++++++++++++++
 libdaemon/server/daemon-server.c      |    6 ++++--
 tools/dmsetup.c                       |    9 +--------
 tools/lvchange.c                      |    1 +
 tools/lvconvert.c                     |    1 +
 tools/lvconvert_poll.c                |    4 ++--
 tools/lvm-static.c                    |    1 +
 tools/lvm.c                           |    1 +
 tools/lvmcmdlib.c                     |    1 +
 tools/lvmcmdline.c                    |    1 +
 tools/lvpoll.c                        |    1 +
 tools/polldaemon.c                    |    5 +++--
 tools/pvmove.c                        |    1 +
 tools/pvmove_poll.c                   |    3 ++-
 tools/reporter.c                      |    1 +
 tools/tool.h                          |   31 +++++++++++++++++++++++++++++++
 tools/toollib.c                       |    1 +
 tools/tools.h                         |   12 ++----------
 37 files changed, 139 insertions(+), 137 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index fe3b5de..728290f 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.102 -
 ================================
+  Include tool.h for default non-library use.
   Introduce format macros with embedded % such as FMTu64.
 
 Version 1.02.101 - 3rd July 2015
diff --git a/daemons/clvmd/clvmd-common.h b/daemons/clvmd/clvmd-common.h
index 3070e49..6df1eb2 100644
--- a/daemons/clvmd/clvmd-common.h
+++ b/daemons/clvmd/clvmd-common.h
@@ -18,15 +18,10 @@
 #ifndef _LVM_CLVMD_COMMON_H
 #define _LVM_CLVMD_COMMON_H
 
-#include "configure.h"
-
 #define _REENTRANT
-#define _GNU_SOURCE
-#define _FILE_OFFSET_BITS 64
 
-#include "libdevmapper.h"
-#include "lvm-logging.h"
+#include "tool.h"
 
-#include <unistd.h>
+#include "lvm-logging.h"
 
 #endif
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index fcfa423..1ff5bf9 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -16,26 +16,21 @@
  * dmeventd - dm event daemon to monitor active mapped devices
  */
 
-#define _GNU_SOURCE
-#define _FILE_OFFSET_BITS 64
+#include "tool.h"
 
-#include "configure.h"
-#include "libdevmapper.h"
-#include "libdevmapper-event.h"
-#include "dmeventd.h"
 //#include "libmultilog.h"
 #include "dm-logging.h"
 
-#include <stdarg.h>
+#include "libdevmapper-event.h"
+#include "dmeventd.h"
+
 #include <dlfcn.h>
-#include <errno.h>
 #include <pthread.h>
 #include <sys/file.h>
 #include <sys/stat.h>
 #include <sys/wait.h>
 #include <sys/time.h>
 #include <sys/resource.h>
-#include <unistd.h>
 #include <signal.h>
 #include <arpa/inet.h>		/* for htonl, ntohl */
 #include <fcntl.h>		/* for musl libc */
@@ -1567,9 +1562,6 @@ static void _process_request(struct dm_event_fifos *fifos)
 {
 	int die;
 	struct dm_event_daemon_message msg = { 0 };
-#ifdef DEBUG
-	const char *cmd;
-#endif
 
 	/*
 	 * Read the request from the client (client_read, client_write
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 6e41b0a..81f18c9 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -17,15 +17,10 @@
 //#include "libmultilog.h"
 #include "dmeventd.h"
 
-#include <errno.h>
 #include <fcntl.h>
-#include <stdio.h>
-#include <stdlib.h>
-#include <string.h>
 #include <sys/file.h>
 #include <sys/types.h>
 #include <sys/stat.h>
-#include <unistd.h>
 #include <sys/wait.h>
 #include <arpa/inet.h>		/* for htonl, ntohl */
 
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 7f2405c..f4e77b7 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -14,17 +14,17 @@
 
 #define _XOPEN_SOURCE 500  /* pthread */
 
-#include "configure.h"
+#define _REENTRANT
+
+#include "tool.h"
+
 #include "daemon-io.h"
-#include "config-util.h"
 #include "daemon-server.h"
 #include "daemon-log.h"
 #include "lvm-version.h"
 
 #include <assert.h>
 #include <pthread.h>
-#include <stdint.h>
-#include <unistd.h>
 
 #define LVMETAD_SOCKET DEFAULT_RUN_DIR "/lvmetad.socket"
 
diff --git a/daemons/lvmetad/testclient.c b/daemons/lvmetad/testclient.c
index 8ea068d..fbf7b65 100644
--- a/daemons/lvmetad/testclient.c
+++ b/daemons/lvmetad/testclient.c
@@ -1,3 +1,18 @@
+/*
+ * Copyright (C) 2011-2014 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+#include "tool.h"
+
 #include "lvmetad-client.h"
 #include "label.h"
 #include "lvmcache.h"
diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index 9349ced..5a4f3f5 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -8,21 +8,15 @@
  * of the GNU Lesser General Public License v.2.1.
  */
 
-#define _GNU_SOURCE
-#include "configure.h"
+#include "tool.h"
+
 #include "lvmlockd-client.h"
 
-#include <stdio.h>
-#include <stdint.h>
 #include <stddef.h>
-#include <stdlib.h>
-#include <unistd.h>
 #include <getopt.h>
-#include <string.h>
 #include <signal.h>
 #include <errno.h>
 #include <fcntl.h>
-#include <sys/types.h>
 #include <sys/wait.h>
 #include <sys/socket.h>
 #include <sys/un.h>
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 87daaaf..649c9aa 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -10,25 +10,22 @@
 
 #define _XOPEN_SOURCE 500  /* pthread */
 #define _ISOC99_SOURCE
-#define _GNU_SOURCE
+#define _REENTRANT
+
+#include "tool.h"
 
-#include "configure.h"
 #include "daemon-io.h"
 #include "daemon-server.h"
 #include "daemon-log.h"
-#include "config-util.h"
 #include "lvm-version.h"
 #include "lvmetad-client.h"
 #include "lvmlockd-client.h"
 
-#include <assert.h>
+/* #include <assert.h> */
+#include <errno.h>
 #include <pthread.h>
-#include <stdint.h>
 #include <stddef.h>
-#include <stdlib.h>
-#include <unistd.h>
 #include <poll.h>
-#include <errno.h>
 #include <signal.h>
 #include <getopt.h>
 #include <syslog.h>
diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index 4b4f433..de19532 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -10,28 +10,9 @@
 
 #define _XOPEN_SOURCE 500  /* pthread */
 #define _ISOC99_SOURCE
-#define _GNU_SOURCE
 
-#include <assert.h>
-#include <pthread.h>
-#include <stdint.h>
-#include <stddef.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <stdio.h>
-#include <poll.h>
-#include <errno.h>
-#include <string.h>
-#include <endian.h>
-#include <fcntl.h>
-#include <byteswap.h>
-#include <syslog.h>
-#include <dirent.h>
-#include <sys/types.h>
-#include <sys/stat.h>
-#include <sys/socket.h>
+#include "tool.h"
 
-#include "configure.h"
 #include "daemon-server.h"
 #include "daemon-log.h"
 #include "xlate.h"
@@ -45,6 +26,17 @@
  */
 #include "libdlm.h"
 
+#include <pthread.h>
+#include <stddef.h>
+#include <poll.h>
+#include <errno.h>
+#include <endian.h>
+#include <fcntl.h>
+#include <byteswap.h>
+#include <syslog.h>
+#include <dirent.h>
+#include <sys/socket.h>
+
 struct lm_dlm {
 	dlm_lshandle_t *dh;
 };
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 5a31edd..f52528f 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -10,23 +10,9 @@
 
 #define _XOPEN_SOURCE 500  /* pthread */
 #define _ISOC99_SOURCE
-#define _GNU_SOURCE
 
-#include <assert.h>
-#include <pthread.h>
-#include <stdint.h>
-#include <stddef.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <stdio.h>
-#include <poll.h>
-#include <errno.h>
-#include <string.h>
-#include <syslog.h>
-#include <sys/types.h>
-#include <sys/socket.h>
+#include "tool.h"
 
-#include "configure.h"
 #include "daemon-server.h"
 #include "daemon-log.h"
 #include "xlate.h"
@@ -39,6 +25,13 @@
 #include "sanlock_admin.h"
 #include "sanlock_resource.h"
 
+#include <pthread.h>
+#include <stddef.h>
+#include <poll.h>
+#include <errno.h>
+#include <syslog.h>
+#include <sys/socket.h>
+
 /*
  * If access to the pv containing the vg's leases is lost, sanlock cannot renew
  * the leases we have acquired for locked LVs.  This means that we could soon
diff --git a/daemons/lvmpolld/lvmpolld-common.h b/daemons/lvmpolld/lvmpolld-common.h
index 81423f0..16f7642 100644
--- a/daemons/lvmpolld/lvmpolld-common.h
+++ b/daemons/lvmpolld/lvmpolld-common.h
@@ -18,19 +18,14 @@
 #ifndef _LVM_LVMPOLLD_COMMON_H
 #define _LVM_LVMPOLLD_COMMON_H
 
-#include "configure.h"
-
 #define _REENTRANT
-#define _GNU_SOURCE
-#define _FILE_OFFSET_BITS 64
 
-#include "libdevmapper.h"
+#include "tool.h"
 
 #include "lvmpolld-cmd-utils.h"
 #include "lvmpolld-protocol.h"
 
 #include <assert.h>
 #include <errno.h>
-#include <unistd.h>
 
 #endif	/* _LVM_LVMPOLLD_COMMON_H */
diff --git a/include/.symlinks.in b/include/.symlinks.in
index dc4456a..e78072a 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -76,3 +76,4 @@
 @top_srcdir@/libdm/misc/kdev_t.h
 @top_srcdir@/po/pogen.h
 @top_srcdir@/tools/lvm2cmd.h
+ at top_srcdir@/tools/tool.h
diff --git a/lib/log/log.h b/lib/log/log.h
index 79e7d77..cb6b0bc 100644
--- a/lib/log/log.h
+++ b/lib/log/log.h
@@ -37,8 +37,6 @@
  *
  */
 
-#include <stdio.h>		/* FILE */
-#include <string.h>		/* strerror() */
 #include <errno.h>
 
 #define EUNCLASSIFIED -1	/* Generic error code */
diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index c417def..895815c 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -12,14 +12,12 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#define _REENTRANT
+
+#include "tool.h"
+
 #include "daemon-io.h"
 #include "dm-logging.h"
-#include "util.h"
-
-#include <errno.h>
-#include <stdio.h>
-#include <string.h>
-#include <unistd.h>
 
 #include <math.h>  /* fabs() */
 #include <float.h> /* DBL_EPSILON */
diff --git a/libdaemon/client/config-util.h b/libdaemon/client/config-util.h
index 3e0a23f..0e7de7e 100644
--- a/libdaemon/client/config-util.h
+++ b/libdaemon/client/config-util.h
@@ -15,10 +15,6 @@
 #ifndef _LVM_DAEMON_CONFIG_UTIL_H
 #define _LVM_DAEMON_CONFIG_UTIL_H
 
-#include "libdevmapper.h"
-
-#include <stdarg.h>
-
 struct buffer {
 	int allocated;
 	int used;
diff --git a/libdaemon/client/daemon-client.c b/libdaemon/client/daemon-client.c
index 991bf8a..39a6401 100644
--- a/libdaemon/client/daemon-client.c
+++ b/libdaemon/client/daemon-client.c
@@ -12,16 +12,16 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#define _REENTRANT
+
+#include "tool.h"
+
 #include "daemon-io.h"
 #include "daemon-client.h"
 #include "dm-logging.h"
 
 #include <sys/un.h>
 #include <sys/socket.h>
-#include <string.h>
-#include <stdio.h>
-#include <unistd.h>
-#include <errno.h> // ENOMEM
 
 daemon_handle daemon_open(daemon_info i)
 {
diff --git a/libdaemon/client/daemon-client.h b/libdaemon/client/daemon-client.h
index e1445c1..7f8d2d4 100644
--- a/libdaemon/client/daemon-client.h
+++ b/libdaemon/client/daemon-client.h
@@ -15,7 +15,6 @@
 #ifndef _LVM_DAEMON_CLIENT_H
 #define _LVM_DAEMON_CLIENT_H
 
-#include "libdevmapper.h"
 #include "config-util.h"
 
 typedef struct {
diff --git a/libdaemon/client/daemon-io.c b/libdaemon/client/daemon-io.c
index 5ce9dde..a9da68f 100644
--- a/libdaemon/client/daemon-io.c
+++ b/libdaemon/client/daemon-io.c
@@ -12,13 +12,13 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#define _REENTRANT
+
+#include "tool.h"
+
 #include "daemon-io.h"
-#include "libdevmapper.h"
 
 #include <errno.h>
-#include <stdio.h>
-#include <string.h>
-#include <unistd.h>
 
 /*
  * Read a single message from a (socket) filedescriptor. Messages are delimited
diff --git a/libdaemon/client/daemon-io.h b/libdaemon/client/daemon-io.h
index b48acca..482f033 100644
--- a/libdaemon/client/daemon-io.h
+++ b/libdaemon/client/daemon-io.h
@@ -15,12 +15,6 @@
 #ifndef _LVM_DAEMON_IO_H
 #define _LVM_DAEMON_IO_H
 
-#include "configure.h"
-
-#define _REENTRANT
-#define _GNU_SOURCE
-#define _FILE_OFFSET_BITS 64
-
 #include "config-util.h"
 
 /* TODO function names */
diff --git a/libdaemon/server/daemon-log.c b/libdaemon/server/daemon-log.c
index c1765de..5ea5cdc 100644
--- a/libdaemon/server/daemon-log.c
+++ b/libdaemon/server/daemon-log.c
@@ -1,5 +1,22 @@
+/*
+ * Copyright (C) 2011-2012 Red Hat, Inc.
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
+#define _REENTRANT
+
+#include "tool.h"
+
 #include "daemon-server.h"
 #include "daemon-log.h"
+
 #include <syslog.h>
 
 struct backend {
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 8eda8cf..4f34aaf 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -10,6 +10,10 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#define _REENTRANT
+
+#include "tool.h"
+
 #include "daemon-io.h"
 #include "daemon-server.h"
 #include "daemon-log.h"
@@ -78,8 +82,6 @@ static void _exit_handler(int sig __attribute__((unused)))
 #  define SD_LISTEN_FDS_START 3
 #  define SD_FD_SOCKET_SERVER SD_LISTEN_FDS_START
 
-#  include <stdio.h>
-
 static int _is_idle(daemon_state s)
 {
 	return s.idle && s.idle->is_idle && !s.threads->next;
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 067a677..e6cc44f 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -16,19 +16,12 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#define _GNU_SOURCE
-#define _FILE_OFFSET_BITS 64
+#include "tool.h"
 
-#include "configure.h"
-#include "util.h"
 #include "dm-logging.h"
 
-#include <stdio.h>
-#include <stdlib.h>
-#include <string.h>
 #include <ctype.h>
 #include <dirent.h>
-#include <errno.h>
 #include <sys/wait.h>
 #include <sys/param.h>
 #include <locale.h>
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 2a57abb..939614e 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -14,6 +14,7 @@
  */
 
 #include "tools.h"
+
 #include "memlock.h"
 
 static int _lvchange_permission(struct cmd_context *cmd,
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index f967ae4..c7e797b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -13,6 +13,7 @@
  */
 
 #include "tools.h"
+
 #include "polldaemon.h"
 #include "lv_alloc.h"
 #include "lvconvert_poll.h"
diff --git a/tools/lvconvert_poll.c b/tools/lvconvert_poll.c
index 72c8df8..e3a3709 100644
--- a/tools/lvconvert_poll.c
+++ b/tools/lvconvert_poll.c
@@ -12,10 +12,10 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "libdevmapper.h"
-#include "lvconvert_poll.h"
 #include "tools.h"
 
+#include "lvconvert_poll.h"
+
 int lvconvert_mirror_finish(struct cmd_context *cmd,
 			    struct volume_group *vg,
 			    struct logical_volume *lv,
diff --git a/tools/lvm-static.c b/tools/lvm-static.c
index 1be4c24..920127b 100644
--- a/tools/lvm-static.c
+++ b/tools/lvm-static.c
@@ -14,6 +14,7 @@
  */
 
 #include "tools.h"
+
 #include "lvm2cmdline.h"
 
 int main(int argc, char **argv)
diff --git a/tools/lvm.c b/tools/lvm.c
index f9ab438..63cc0b4 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -14,6 +14,7 @@
  */
 
 #include "tools.h"
+
 #include "lvm2cmdline.h"
 
 int main(int argc, char **argv)
diff --git a/tools/lvmcmdlib.c b/tools/lvmcmdlib.c
index 6b641c2..76576c2 100644
--- a/tools/lvmcmdlib.c
+++ b/tools/lvmcmdlib.c
@@ -14,6 +14,7 @@
  */
 
 #include "tools.h"
+
 #include "lvm2cmdline.h"
 #include "label.h"
 #include "memlock.h"
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 7808c12..c4a78b0 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -14,6 +14,7 @@
  */
 
 #include "tools.h"
+
 #include "lvm2cmdline.h"
 #include "label.h"
 #include "lvm-version.h"
diff --git a/tools/lvpoll.c b/tools/lvpoll.c
index 178392e..c040b60 100644
--- a/tools/lvpoll.c
+++ b/tools/lvpoll.c
@@ -13,6 +13,7 @@
  */
 
 #include "tools.h"
+
 #include "polldaemon.h"
 #include "pvmove_poll.h"
 #include "lvconvert_poll.h"
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index d7ba417..da890dc 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -13,13 +13,14 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include <time.h>
-
 #include "tools.h"
+
 #include "polldaemon.h"
 #include "lvm2cmdline.h"
 #include "lvmpolld-client.h"
 
+#include <time.h>
+
 #define WAIT_AT_LEAST_NANOSECS 100000
 
 progress_t poll_mirror_progress(struct cmd_context *cmd,
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 8efa6b0..17416d4 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -14,6 +14,7 @@
  */
 
 #include "tools.h"
+
 #include "polldaemon.h"
 #include "display.h"
 #include "pvmove_poll.h"
diff --git a/tools/pvmove_poll.c b/tools/pvmove_poll.c
index df896b5..0f071dc 100644
--- a/tools/pvmove_poll.c
+++ b/tools/pvmove_poll.c
@@ -13,9 +13,10 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "pvmove_poll.h"
 #include "tools.h"
 
+#include "pvmove_poll.h"
+
 static int _is_pvmove_image_removable(struct logical_volume *mimage_lv,
 				      void *baton)
 {
diff --git a/tools/reporter.c b/tools/reporter.c
index c7a927b..8f7a272 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -14,6 +14,7 @@
  */
 
 #include "tools.h"
+
 #include "report.h"
 
 static int _process_each_devtype(struct cmd_context *cmd, int argc,
diff --git a/tools/tool.h b/tools/tool.h
new file mode 100644
index 0000000..04c51ee
--- /dev/null
+++ b/tools/tool.h
@@ -0,0 +1,31 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
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
+/* Most source files should include this file or lib.h or dmlib.h */
+
+#ifndef _LVM_TOOL_H
+#define _LVM_TOOL_H
+
+#define _GNU_SOURCE
+#define _FILE_OFFSET_BITS 64
+
+#include "configure.h"
+
+#include <unistd.h>
+
+#include "libdevmapper.h"
+#include "util.h"
+
+#endif	/* _LVM_TOOL_H */
diff --git a/tools/toollib.c b/tools/toollib.c
index 6b8ce22..15bfa51 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -14,6 +14,7 @@
  */
 
 #include "tools.h"
+
 #include <sys/stat.h>
 #include <signal.h>
 #include <sys/wait.h>
diff --git a/tools/tools.h b/tools/tools.h
index 675867d..5ee5786 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -16,14 +16,10 @@
 #ifndef _LVM_TOOLS_H
 #define _LVM_TOOLS_H
 
-#define _GNU_SOURCE
-#define _FILE_OFFSET_BITS 64
-
-#include "configure.h"
-#include <assert.h>
-#include "libdevmapper.h"
+#include "tool.h"
 
 #include "lvm-logging.h"
+
 #include "activate.h"
 #include "archiver.h"
 #include "lvmcache.h"
@@ -47,11 +43,7 @@
 #include "toolcontext.h"
 #include "toollib.h"
 
-#include <stdlib.h>
-#include <unistd.h>
 #include <ctype.h>
-#include <limits.h>
-#include <stdarg.h>
 #include <sys/types.h>
 
 #define CMD_LEN 256


