From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:56:16 -0400
Subject: master - cov: drop uneeded header files
Message-ID: <201810151556.w9FFuGqk020764@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fdd76da33dabcb6bd696f22413a692b9900d5bcc
Commit:        fdd76da33dabcb6bd696f22413a692b9900d5bcc
Parent:        c4f39decc8d6fb213af21f16d99b460362ce295f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 15:08:09 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:44 2018 +0200

cov: drop uneeded header files

---
 device_mapper/libdm-deptree.c |    1 -
 lib/activate/activate.c       |    1 -
 lib/device/bcache.c           |    1 -
 lib/device/dev-cache.c        |    1 -
 lib/device/dev-io.c           |    1 -
 lib/format_text/format-text.c |    2 --
 lib/label/label.c             |    1 -
 lib/locking/file_locking.c    |    1 -
 lib/metadata/vdo_manip.c      |    2 --
 lib/metadata/vg.c             |    1 -
 lib/mirror/mirrored.c         |    1 -
 11 files changed, 0 insertions(+), 13 deletions(-)

diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 26251f8..5c5f12f 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -21,7 +21,6 @@
 
 #include <stdarg.h>
 #include <string.h>
-#include <sys/param.h>
 #include <sys/utsname.h>
 
 #define MAX_TARGET_PARAMSIZE 500000
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index ead3b8d..93448d3 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -28,7 +28,6 @@
 #include "lib/config/config.h"
 #include "lib/metadata/segtype.h"
 #include "lib/misc/sharedlib.h"
-#include "lib/cache/lvmcache.h"
 #include "lib/metadata/metadata.h"
 
 #include <limits.h>
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 8b2c7f8..5e957fe 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -31,7 +31,6 @@
 #include <libaio.h>
 #include <unistd.h>
 #include <linux/fs.h>
-#include <sys/ioctl.h>
 #include <sys/user.h>
 
 #define SECTOR_SHIFT 9L
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index f83ccda..9b141fe 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -25,7 +25,6 @@
 #include <libudev.h>
 #endif
 #include <unistd.h>
-#include <sys/param.h>
 #include <dirent.h>
 
 struct dev_iter {
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index a3643c4..dc95131 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -17,7 +17,6 @@
 #include "lib/device/device.h"
 #include "lib/metadata/metadata.h"
 #include "lib/mm/memlock.h"
-#include "lib/locking/locking.h"
 
 #include <limits.h>
 #include <sys/stat.h>
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 99945b1..5d8355e 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -28,10 +28,8 @@
 #include "lib/mm/xlate.h"
 #include "lib/label/label.h"
 #include "lib/cache/lvmcache.h"
-#include "lib/mm/memlock.h"
 
 #include <unistd.h>
-#include <sys/param.h>
 #include <limits.h>
 #include <dirent.h>
 #include <ctype.h>
diff --git a/lib/label/label.c b/lib/label/label.c
index 6c074d6..22b6bc2 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -28,7 +28,6 @@
 #include <sys/stat.h>
 #include <fcntl.h>
 #include <unistd.h>
-#include <sys/time.h>
 #include <sys/types.h>
 
 /* FIXME Allow for larger labels?  Restricted to single sector currently */
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 8e08b08..8f808c8 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -16,7 +16,6 @@
 #include "lib/misc/lib.h"
 #include "lib/locking/locking.h"
 #include "locking_types.h"
-#include "lib/activate/activate.h"
 #include "lib/config/config.h"
 #include "lib/config/defaults.h"
 #include "lib/misc/lvm-string.h"
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index c0446ad..b5bbbe2 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -21,8 +21,6 @@
 #include "lib/metadata/segtype.h"
 #include "lib/activate/activate.h"
 #include "lib/config/defaults.h"
-#include "lib/metadata/lv_alloc.h"
-#include "lib/misc/lvm-signal.h"
 #include "lib/misc/lvm-exec.h"
 
 const char *get_vdo_compression_state_name(enum dm_vdo_compression_state state)
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index a9cb541..aca4fe7 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -18,7 +18,6 @@
 #include "lib/display/display.h"
 #include "lib/activate/activate.h"
 #include "lib/commands/toolcontext.h"
-#include "lib/cache/lvmcache.h"
 #include "lib/format_text/archiver.h"
 
 struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 1ca4037..7fa8714 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -16,7 +16,6 @@
 #include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/commands/toolcontext.h"
-#include "lib/metadata/metadata.h"
 #include "lib/metadata/segtype.h"
 #include "lib/display/display.h"
 #include "lib/format_text/text_export.h"


