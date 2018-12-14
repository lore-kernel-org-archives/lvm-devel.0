From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 14 Dec 2018 09:17:15 -0500
Subject: master - headers: use configure.h as 1st. header
Message-ID: <201812141417.wBEEHFjT010277@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0b19387dae782b33bb341e58ab3c7ff804ca4f14
Commit:        0b19387dae782b33bb341e58ab3c7ff804ca4f14
Parent:        3c377643339be97940554323909d51b12c933f9e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 3 18:14:26 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 14 15:09:13 2018 +0100

headers: use configure.h as 1st. header

Ensure configure.h is always 1st. included header.
Maybe we could eventually introduce gcc -include option, but for now
this better uses dependency tracking.

Also move _REENTRANT and _GNU_SOURCE into configure.h so it
doesn't need to be present in various source files.
This ensures consistent compilation of headers like stdio.h since
it may produce different declaration.
---
 base/data-struct/radix-tree-adaptive.c |    1 +
 base/data-struct/radix-tree.h          |    2 ++
 base/memory/zalloc.h                   |    2 +-
 configure                              |    9 +++++++++
 configure.ac                           |    5 +++++
 daemons/cmirrord/logging.h             |    2 --
 daemons/lvmlockd/lvmlockd-core.c       |    1 -
 daemons/lvmpolld/lvmpolld-common.h     |    2 --
 device_mapper/all.h                    |    2 ++
 device_mapper/ioctl/libdm-iface.c      |    1 -
 device_mapper/misc/dmlib.h             |    5 -----
 include/configure.h.in                 |    6 ++++++
 lib/device/bcache.c                    |    2 --
 lib/device/bcache.h                    |    1 -
 lib/label/label.c                      |    2 --
 lib/misc/lib.h                         |    9 ++-------
 libdaemon/client/config-util.c         |    4 +---
 libdaemon/client/daemon-client.c       |    6 ++----
 libdaemon/client/daemon-io.c           |    4 +---
 libdaemon/server/daemon-log.c          |    2 --
 libdaemon/server/daemon-server.c       |    4 +---
 libdm/dm-tools/dmsetup.c               |    2 --
 libdm/misc/dmlib.h                     |    3 ---
 test/lib/harness.c                     |    3 ++-
 test/unit/bcache_utils_t.c             |    2 --
 test/unit/io_engine_t.c                |    2 --
 tools/tool.h                           |    6 ++----
 27 files changed, 37 insertions(+), 53 deletions(-)

diff --git a/base/data-struct/radix-tree-adaptive.c b/base/data-struct/radix-tree-adaptive.c
index 5e065b6..b9ba417 100644
--- a/base/data-struct/radix-tree-adaptive.c
+++ b/base/data-struct/radix-tree-adaptive.c
@@ -18,6 +18,7 @@
 #include <assert.h>
 #include <stdlib.h>
 #include <stdio.h>
+#include <string.h>
 
 //----------------------------------------------------------------
 
diff --git a/base/data-struct/radix-tree.h b/base/data-struct/radix-tree.h
index 5d4d04c..685b828 100644
--- a/base/data-struct/radix-tree.h
+++ b/base/data-struct/radix-tree.h
@@ -13,6 +13,8 @@
 #ifndef BASE_DATA_STRUCT_RADIX_TREE_H
 #define BASE_DATA_STRUCT_RADIX_TREE_H
 
+#include "configure.h"
+
 #include <stdbool.h>
 #include <stdint.h>
 #include <stdio.h>
diff --git a/base/memory/zalloc.h b/base/memory/zalloc.h
index 4f6df54..069c599 100644
--- a/base/memory/zalloc.h
+++ b/base/memory/zalloc.h
@@ -13,8 +13,8 @@
 #ifndef BASE_MEMORY_ZALLOC_H
 #define BASE_MEMORY_ZALLOC_H
 
+#include "configure.h"
 #include <stdlib.h>
-#include <string.h>
 
 //----------------------------------------------------------------
 
diff --git a/configure b/configure
index 66acdb2..53f5023 100755
--- a/configure
+++ b/configure
@@ -6623,6 +6623,15 @@ fi
 
 
 
+
+
+$as_echo "#define _GNU_SOURCE 1" >>confdefs.h
+
+
+$as_echo "#define _REENTRANT 1" >>confdefs.h
+
+
+
 ################################################################################
 for ac_func in ftruncate gethostname getpagesize gettimeofday localtime_r \
   memchr memset mkdir mkfifo munmap nl_langinfo realpath rmdir setenv \
diff --git a/configure.ac b/configure.ac
index 2b29210..2ece3f9 100644
--- a/configure.ac
+++ b/configure.ac
@@ -144,6 +144,11 @@ AC_TYPE_UINT64_T
 AX_GCC_BUILTIN([__builtin_clz])
 AX_GCC_BUILTIN([__builtin_clzll])
 
+
+AC_DEFINE([_GNU_SOURCE], 1, [Define to get access to GNU/Linux extension])
+AC_DEFINE([_REENTRANT], 1, [Define to use re-entrant thread safe versions])
+
+
 ################################################################################
 dnl -- Check for functions
 AC_CHECK_FUNCS([ftruncate gethostname getpagesize gettimeofday localtime_r \
diff --git a/daemons/cmirrord/logging.h b/daemons/cmirrord/logging.h
index 13e6b39..5f640cf 100644
--- a/daemons/cmirrord/logging.h
+++ b/daemons/cmirrord/logging.h
@@ -13,8 +13,6 @@
 #ifndef _LVM_CLOG_LOGGING_H
 #define _LVM_CLOG_LOGGING_H
 
-#define _GNU_SOURCE
-
 #include "configure.h"
 #include <stdio.h>
 #include <stdint.h>
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 5bdbefe..dd52270 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -10,7 +10,6 @@
 
 #define _XOPEN_SOURCE 500  /* pthread */
 #define _ISOC99_SOURCE
-#define _REENTRANT
 
 #include "tools/tool.h"
 
diff --git a/daemons/lvmpolld/lvmpolld-common.h b/daemons/lvmpolld/lvmpolld-common.h
index 4ada581..ccd9b13 100644
--- a/daemons/lvmpolld/lvmpolld-common.h
+++ b/daemons/lvmpolld/lvmpolld-common.h
@@ -18,8 +18,6 @@
 #ifndef _LVM_LVMPOLLD_COMMON_H
 #define _LVM_LVMPOLLD_COMMON_H
 
-#define _REENTRANT
-
 #include "tools/tool.h"
 
 #include "lvmpolld-cmd-utils.h"
diff --git a/device_mapper/all.h b/device_mapper/all.h
index 0c1dc29..8c17c09 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -17,6 +17,8 @@
 #ifndef LIB_DEVICE_MAPPER_H
 #define LIB_DEVICE_MAPPER_H
 
+#include "configure.h"
+
 #include "base/data-struct/list.h"
 #include "base/data-struct/hash.h"
 #include "vdo/target.h"
diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index f86d3b3..d333426 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -19,7 +19,6 @@
 #include "device_mapper/ioctl/libdm-targets.h"
 #include "device_mapper/libdm-common.h"
 
-#include <stdio.h>  /* getline() */
 #include <stddef.h>
 #include <fcntl.h>
 #include <dirent.h>
diff --git a/device_mapper/misc/dmlib.h b/device_mapper/misc/dmlib.h
index fe64bd7..51fe5a3 100644
--- a/device_mapper/misc/dmlib.h
+++ b/device_mapper/misc/dmlib.h
@@ -21,11 +21,6 @@
 
 // FIXME: get rid of this whole file
  
-#include "configure.h"
-
-#define _REENTRANT
-#define _GNU_SOURCE
-
 #include "device_mapper/all.h"
 #include "lib/misc/util.h"
 #include "dm-logging.h"
diff --git a/include/configure.h.in b/include/configure.h.in
index c66b37b..dde55fe 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -669,6 +669,12 @@
 /* Define to 1 to include built-in support for writecache. */
 #undef WRITECACHE_INTERNAL
 
+/* Define to get access to GNU/Linux extension */
+#undef _GNU_SOURCE
+
+/* Define to use re-entrant thread safe versions */
+#undef _REENTRANT
+
 /* Define for Solaris 2.5.1 so the uint32_t typedef from <sys/synch.h>,
    <pthread.h>, or <semaphore.h> is not used. If the typedef were allowed, the
    #define below would cause a syntax error. */
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 18ffcf0..d646d2b 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -12,8 +12,6 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#define _GNU_SOURCE
-
 #include "lib/device/bcache.h"
 
 #include "base/data-struct/radix-tree.h"
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index 2edc54a..8c16caa 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -15,7 +15,6 @@
 #ifndef BCACHE_H
 #define BCACHE_H
 
-#include "configure.h"
 #include "device_mapper/all.h"
 
 #include <linux/fs.h>
diff --git a/lib/label/label.c b/lib/label/label.c
index 0517312..6fe1e41 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -13,8 +13,6 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#define _GNU_SOURCE
-
 #include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/label/label.h"
diff --git a/lib/misc/lib.h b/lib/misc/lib.h
index f7baf9d..c14f437 100644
--- a/lib/misc/lib.h
+++ b/lib/misc/lib.h
@@ -19,11 +19,6 @@
 #ifndef _LVM_LIB_H
 #define _LVM_LIB_H
 
-#include "configure.h"
-
-#define _REENTRANT
-#define _GNU_SOURCE
-
 /*
  * Symbol export control macros
  *
@@ -78,10 +73,10 @@
 #endif
 
 
-#include "lib/misc/intl.h"
 #include "device_mapper/all.h"
-#include "lib/misc/util.h"
 #include "base/memory/zalloc.h"
+#include "lib/misc/intl.h"
+#include "lib/misc/util.h"
 
 #ifdef DM
 #  include "libdm/misc/dm-logging.h"
diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index bdbdd3a..3f27f31 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -12,11 +12,9 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#define _REENTRANT
-
 #include "tools/tool.h"
 
-#include "libdaemon/client/daemon-io.h"
+#include "daemon-io.h"
 #include "device_mapper/misc/dm-logging.h"
 
 #include <math.h>  /* fabs() */
diff --git a/libdaemon/client/daemon-client.c b/libdaemon/client/daemon-client.c
index 53f4495..8049686 100644
--- a/libdaemon/client/daemon-client.c
+++ b/libdaemon/client/daemon-client.c
@@ -12,12 +12,10 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#define _REENTRANT
-
 #include "tools/tool.h"
 
-#include "libdaemon/client/daemon-io.h"
-#include "libdaemon/client/daemon-client.h"
+#include "daemon-io.h"
+#include "daemon-client.h"
 #include "device_mapper/misc/dm-logging.h"
 
 #include <sys/un.h>
diff --git a/libdaemon/client/daemon-io.c b/libdaemon/client/daemon-io.c
index bd24cdb..1f9d840 100644
--- a/libdaemon/client/daemon-io.c
+++ b/libdaemon/client/daemon-io.c
@@ -12,11 +12,9 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#define _REENTRANT
-
 #include "tools/tool.h"
 
-#include "libdaemon/client/daemon-io.h"
+#include "daemon-io.h"
 
 #include <errno.h>
 
diff --git a/libdaemon/server/daemon-log.c b/libdaemon/server/daemon-log.c
index 864f504..7198c29 100644
--- a/libdaemon/server/daemon-log.c
+++ b/libdaemon/server/daemon-log.c
@@ -10,8 +10,6 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#define _REENTRANT
-
 #include "tools/tool.h"
 
 #include "daemon-server.h"
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 78c8221..a2216ac 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -10,13 +10,11 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#define _REENTRANT
-
 #include "tools/tool.h"
 
-#include "libdaemon/client/daemon-io.h"
 #include "daemon-server.h"
 #include "daemon-log.h"
+#include "libdaemon/client/daemon-io.h"
 
 #include <dlfcn.h>
 #include <errno.h>
diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index 4b14a23..efeb978 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -17,8 +17,6 @@
  */
 
 // For canonicalize_file_name()
-#define _GNU_SOURCE
-
 #include "configure.h"
 #include "libdm/misc/dm-logging.h"
 #include "libdm/dm-tools/util.h"
diff --git a/libdm/misc/dmlib.h b/libdm/misc/dmlib.h
index 4c6bcfc..60787fe 100644
--- a/libdm/misc/dmlib.h
+++ b/libdm/misc/dmlib.h
@@ -21,9 +21,6 @@
 
 #include "configure.h"
 
-#define _REENTRANT
-#define _GNU_SOURCE
-
 /*
  * Symbol export control macros
  *
diff --git a/test/lib/harness.c b/test/lib/harness.c
index ace3f5a..d1274ed 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -12,7 +12,8 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#define _GNU_SOURCE
+#include "configure.h"
+
 #include <errno.h>
 #include <fcntl.h>
 #include <limits.h>
diff --git a/test/unit/bcache_utils_t.c b/test/unit/bcache_utils_t.c
index 2e08320..d022c51 100644
--- a/test/unit/bcache_utils_t.c
+++ b/test/unit/bcache_utils_t.c
@@ -12,8 +12,6 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#define _GNU_SOURCE
-
 #include "units.h"
 #include "lib/device/bcache.h"
 
diff --git a/test/unit/io_engine_t.c b/test/unit/io_engine_t.c
index bac9c38..44e93e0 100644
--- a/test/unit/io_engine_t.c
+++ b/test/unit/io_engine_t.c
@@ -12,8 +12,6 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#define _GNU_SOURCE
-
 #include "units.h"
 #include "lib/device/bcache.h"
 
diff --git a/tools/tool.h b/tools/tool.h
index fb6cab8..6fd4da0 100644
--- a/tools/tool.h
+++ b/tools/tool.h
@@ -18,14 +18,12 @@
 #ifndef _LVM_TOOL_H
 #define _LVM_TOOL_H
 
-#define _GNU_SOURCE
-
 #include "configure.h"
 
-#include <unistd.h>
-
 #include "base/memory/zalloc.h"
 #include "device_mapper/all.h"
 #include "lib/misc/util.h"
 
+#include <unistd.h>
+
 #endif	/* _LVM_TOOL_H */


