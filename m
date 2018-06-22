From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 22 Jun 2018 17:38:41 -0400
Subject: master - build: include configure.h
Message-ID: <201806222138.w5MLcffx018633@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c728d88e11ffed97f8a5b96e1c0595a2462c5edc
Commit:        c728d88e11ffed97f8a5b96e1c0595a2462c5edc
Parent:        086f1ef4a0f59ee247067e850b9b9ef0cdf5b1c3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 19 20:43:31 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 22 23:11:44 2018 +0200

build: include configure.h

It's important to consistenly include  configure.h as the 1st. header.
It containts #defines influencing behavior of other included header
files.
---
 daemons/dmeventd/dmeventd.c           |    1 +
 daemons/dmeventd/libdevmapper-event.c |    2 +-
 device_mapper/all.h                   |    6 +++---
 device_mapper/libdm-common.c          |    6 +++---
 device_mapper/vdo/status.c            |    1 +
 lib/device/bcache.h                   |    1 +
 libdm/dm-tools/dmsetup.c              |    4 ++--
 test/unit/activation-generator_t.c    |    3 +--
 test/unit/bcache_t.c                  |    7 +++----
 test/unit/bcache_utils_t.c            |    3 +--
 test/unit/framework.h                 |    1 +
 test/unit/io_engine_t.c               |    7 +++----
 test/unit/radix_tree_t.c              |    3 +--
 test/unit/vdo_t.c                     |    3 +--
 14 files changed, 23 insertions(+), 25 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 3ad81ce..dcc743d 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -16,6 +16,7 @@
  * dmeventd - dm event daemon to monitor active mapped devices
  */
 
+#include "device_mapper/misc/dmlib.h"
 #include "base/memory/zalloc.h"
 #include "device_mapper/misc/dm-logging.h"
 
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 157b5f1..e58a0ce 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -12,9 +12,9 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "device_mapper/misc/dmlib.h"
 #include "base/memory/zalloc.h"
 #include "device_mapper/misc/dm-logging.h"
-#include "device_mapper/misc/dmlib.h"
 #include "daemons/dmeventd/libdevmapper-event.h"
 #include "dmeventd.h"
 #include "lib/misc/intl.h"
diff --git a/device_mapper/all.h b/device_mapper/all.h
index 8dcb38c..602b7ba 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -17,6 +17,9 @@
 #ifndef LIB_DEVICE_MAPPER_H
 #define LIB_DEVICE_MAPPER_H
 
+#include "base/data-struct/list.h"
+#include "base/data-struct/hash.h"
+
 #include <inttypes.h>
 #include <stdarg.h>
 #include <sys/types.h>
@@ -31,9 +34,6 @@
 #include <stdlib.h>
 #include <stdio.h>
 
-#include "base/data-struct/list.h"
-#include "base/data-struct/hash.h"
-
 #ifndef __GNUC__
 # define __typeof__ typeof
 #endif
diff --git a/device_mapper/libdm-common.c b/device_mapper/libdm-common.c
index d46d4b0..111fff6 100644
--- a/device_mapper/libdm-common.c
+++ b/device_mapper/libdm-common.c
@@ -13,12 +13,12 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "base/memory/zalloc.h"
-#include "device_mapper/misc/dmlib.h"
-#include "ioctl/libdm-targets.h"
+#include "misc/dmlib.h"
 #include "libdm-common.h"
+#include "ioctl/libdm-targets.h"
 #include "misc/kdev_t.h"
 #include "misc/dm-ioctl.h"
+#include "base/memory/zalloc.h"
 
 #include <stdarg.h>
 #include <sys/param.h>
diff --git a/device_mapper/vdo/status.c b/device_mapper/vdo/status.c
index 7a26e1a..f423ca1 100644
--- a/device_mapper/vdo/status.c
+++ b/device_mapper/vdo/status.c
@@ -1,3 +1,4 @@
+#include "configure.h"
 #include "target.h"
 
 // For DM_ARRAY_SIZE!
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index cb36c30..ae5e69c 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -15,6 +15,7 @@
 #ifndef BCACHE_H
 #define BCACHE_H
 
+#include "configure.h"
 #include "device_mapper/all.h"
 
 #include <linux/fs.h>
diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index 83786f4..44386a6 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -18,11 +18,10 @@
 
 // For canonicalize_file_name()
 #define _GNU_SOURCE
-#include <stdlib.h>
 
+#include "configure.h"
 #include "libdm/misc/dm-logging.h"
 #include "libdm/dm-tools/util.h"
-#include "configure.h"
 
 #include <ctype.h>
 #include <dirent.h>
@@ -35,6 +34,7 @@
 #include <sys/wait.h>
 #include <time.h>
 #include <unistd.h>
+#include <stdlib.h>
 
 #ifdef UDEV_SYNC_SUPPORT
 #  include <sys/types.h>
diff --git a/test/unit/activation-generator_t.c b/test/unit/activation-generator_t.c
index 9f6b661..cff0968 100644
--- a/test/unit/activation-generator_t.c
+++ b/test/unit/activation-generator_t.c
@@ -12,9 +12,8 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "scripts/generator-internals.c"
-#include "framework.h"
 #include "units.h"
+#include "scripts/generator-internals.c"
 
 #include "device_mapper/all.h"
 
diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index 5e07005..92c2d57 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -12,15 +12,14 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "units.h"
+#include "lib/device/bcache.h"
+
 #include <errno.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include <unistd.h>
 
-#include "lib/device/bcache.h"
-#include "framework.h"
-#include "units.h"
-
 #define SHOW_MOCK_CALLS 0
 
 /*----------------------------------------------------------------
diff --git a/test/unit/bcache_utils_t.c b/test/unit/bcache_utils_t.c
index 66780ea..2e08320 100644
--- a/test/unit/bcache_utils_t.c
+++ b/test/unit/bcache_utils_t.c
@@ -14,9 +14,8 @@
 
 #define _GNU_SOURCE
 
-#include "lib/device/bcache.h"
-#include "framework.h"
 #include "units.h"
+#include "lib/device/bcache.h"
 
 #include <errno.h>
 #include <stdio.h>
diff --git a/test/unit/framework.h b/test/unit/framework.h
index 0c45596..d5a2cdd 100644
--- a/test/unit/framework.h
+++ b/test/unit/framework.h
@@ -1,6 +1,7 @@
 #ifndef TEST_UNIT_FRAMEWORK_H
 #define TEST_UNIT_FRAMEWORK_H
 
+#include "configure.h"
 #include "device_mapper/all.h"
 
 #include <stdbool.h>
diff --git a/test/unit/io_engine_t.c b/test/unit/io_engine_t.c
index 1a4f638..bac9c38 100644
--- a/test/unit/io_engine_t.c
+++ b/test/unit/io_engine_t.c
@@ -14,6 +14,9 @@
 
 #define _GNU_SOURCE
 
+#include "units.h"
+#include "lib/device/bcache.h"
+
 #include <errno.h>
 #include <stdio.h>
 #include <stdlib.h>
@@ -22,10 +25,6 @@
 #include <fcntl.h>
 #include <unistd.h>
 
-#include "lib/device/bcache.h"
-#include "framework.h"
-#include "units.h"
-
 //----------------------------------------------------------------
 
 #define SECTOR_SIZE 512
diff --git a/test/unit/radix_tree_t.c b/test/unit/radix_tree_t.c
index 2fba15f..e5d3e98 100644
--- a/test/unit/radix_tree_t.c
+++ b/test/unit/radix_tree_t.c
@@ -10,11 +10,10 @@
 // along with this program; if not, write to the Free Software Foundation,
 // Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  
+#include "units.h"
 #include "base/data-struct/radix-tree.h"
 #include "base/memory/container_of.h"
 
-#include "units.h"
-
 #include <stdio.h>
 #include <stdlib.h>
 
diff --git a/test/unit/vdo_t.c b/test/unit/vdo_t.c
index 9c41887..a26c0b9 100644
--- a/test/unit/vdo_t.c
+++ b/test/unit/vdo_t.c
@@ -12,9 +12,8 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "device_mapper/vdo/target.h"
-#include "framework.h"
 #include "units.h"
+#include "device_mapper/vdo/target.h"
 
 //----------------------------------------------------------------
 


