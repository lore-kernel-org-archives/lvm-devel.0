From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:14 +0000 (UTC)
Subject: master - libdaemon: header cleanup
Message-ID: <20140418145514.DF90060F54@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b7741f0a831ef9dfd4fda19abba6ca8e91baa378
Commit:        b7741f0a831ef9dfd4fda19abba6ca8e91baa378
Parent:        e552824dc046b90f201de8041730f2dbf6969aa0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 17 10:40:35 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:38:49 2014 +0200

libdaemon: header cleanup

Ensure  daemon-io.h is used as a generic header included
with configure defines before other headers.
(In future all lvm2 libraries should settle on a single lib.h header)
Rename couple defines to better match header file names.
---
 libdaemon/client/config-util.c   |    7 +++----
 libdaemon/client/config-util.h   |    3 +--
 libdaemon/client/daemon-client.c |    2 --
 libdaemon/client/daemon-client.h |    4 ++--
 libdaemon/client/daemon-io.c     |    6 +++---
 libdaemon/client/daemon-io.h     |    6 +++---
 libdaemon/server/daemon-server.c |    1 -
 libdaemon/server/daemon-server.h |    4 ++--
 8 files changed, 14 insertions(+), 19 deletions(-)

diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index d40e94c..e5f4e22 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -12,15 +12,14 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#include "daemon-io.h"
+#include "dm-logging.h"
+
 #include <errno.h>
 #include <stdio.h>
 #include <string.h>
 #include <unistd.h>
 
-#include "dm-logging.h"
-#include "config-util.h"
-#include "libdevmapper.h"
-
 int buffer_append_vf(struct buffer *buf, va_list ap)
 {
 	char *append;
diff --git a/libdaemon/client/config-util.h b/libdaemon/client/config-util.h
index f03bcab..47fab6b 100644
--- a/libdaemon/client/config-util.h
+++ b/libdaemon/client/config-util.h
@@ -15,7 +15,6 @@
 #ifndef _LVM_DAEMON_CONFIG_UTIL_H
 #define _LVM_DAEMON_CONFIG_UTIL_H
 
-#include "configure.h"
 #include "libdevmapper.h"
 
 #include <stdarg.h>
@@ -64,4 +63,4 @@ struct dm_config_node *config_make_nodes(struct dm_config_tree *cft,
 					 struct dm_config_node *pre_sib,
 					 ...);
 
-#endif /* _LVM_DAEMON_SHARED_H */
+#endif /* _LVM_DAEMON_CONFIG_UTIL_H */
diff --git a/libdaemon/client/daemon-client.c b/libdaemon/client/daemon-client.c
index a821cf3..a11b604 100644
--- a/libdaemon/client/daemon-client.c
+++ b/libdaemon/client/daemon-client.c
@@ -13,7 +13,6 @@
  */
 
 #include "daemon-io.h"
-#include "config-util.h"
 #include "daemon-client.h"
 #include "dm-logging.h"
 
@@ -208,4 +207,3 @@ void daemon_request_destroy(daemon_request r) {
 		dm_config_destroy(r.cft);
 	buffer_destroy(&r.buffer);
 }
-
diff --git a/libdaemon/client/daemon-client.h b/libdaemon/client/daemon-client.h
index 8a44f8b..ae3be91 100644
--- a/libdaemon/client/daemon-client.h
+++ b/libdaemon/client/daemon-client.h
@@ -12,8 +12,8 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#ifndef _LVM_DAEMON_COMMON_CLIENT_H
-#define _LVM_DAEMON_COMMON_CLIENT_H
+#ifndef _LVM_DAEMON_CLIENT_H
+#define _LVM_DAEMON_CLIENT_H
 
 #include "libdevmapper.h"
 #include "config-util.h"
diff --git a/libdaemon/client/daemon-io.c b/libdaemon/client/daemon-io.c
index e2c5180..6d81ed8 100644
--- a/libdaemon/client/daemon-io.c
+++ b/libdaemon/client/daemon-io.c
@@ -12,14 +12,14 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#include "daemon-io.h"
+#include "libdevmapper.h"
+
 #include <errno.h>
 #include <stdio.h>
 #include <string.h>
 #include <unistd.h>
 
-#include "daemon-io.h"
-#include "libdevmapper.h"
-
 /*
  * Read a single message from a (socket) filedescriptor. Messages are delimited
  * by blank lines. This call will block until all of a message is received. The
diff --git a/libdaemon/client/daemon-io.h b/libdaemon/client/daemon-io.h
index 52aaa9c..b48acca 100644
--- a/libdaemon/client/daemon-io.h
+++ b/libdaemon/client/daemon-io.h
@@ -16,16 +16,16 @@
 #define _LVM_DAEMON_IO_H
 
 #include "configure.h"
-#include "config-util.h"
-#include "libdevmapper.h"
 
 #define _REENTRANT
 #define _GNU_SOURCE
 #define _FILE_OFFSET_BITS 64
 
+#include "config-util.h"
+
 /* TODO function names */
 
 int buffer_read(int fd, struct buffer *buffer);
 int buffer_write(int fd, const struct buffer *buffer);
 
-#endif /* _LVM_DAEMON_SHARED_H */
+#endif /* _LVM_DAEMON_IO_H */
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 914b803..919f7df 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -11,7 +11,6 @@
  */
 
 #include "daemon-io.h"
-#include "config-util.h"
 #include "daemon-server.h"
 #include "daemon-log.h"
 
diff --git a/libdaemon/server/daemon-server.h b/libdaemon/server/daemon-server.h
index eb6df43..ad41372 100644
--- a/libdaemon/server/daemon-server.h
+++ b/libdaemon/server/daemon-server.h
@@ -12,8 +12,8 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#ifndef _LVM_DAEMON_COMMON_SERVER_H
-#define _LVM_DAEMON_COMMON_SERVER_H
+#ifndef _LVM_DAEMON_SERVER_H
+#define _LVM_DAEMON_SERVER_H
 
 #include "daemon-client.h"
 


