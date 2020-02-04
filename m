From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 4 Feb 2020 11:22:46 -0500
Subject: master - cov: unused header file removal
Message-ID: <04165.120020411223201709@us-mta-311.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=de43527f94c172223d25f849411f435ad359ce77
Commit:        de43527f94c172223d25f849411f435ad359ce77
Parent:        c5e5ae4c95e5d02bfa5d018364954281053a9440
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 30 11:03:27 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 4 17:22:06 2020 +0100

cov: unused header file removal

cov: unused header removed
Also ensure library header file with config settings goes first.
Move inclusion of format-text.h into layout.h
---
 lib/format_text/layout.h        | 3 +--
 lib/label/hints.c               | 3 +--
 lib/label/label.c               | 3 +--
 lib/metadata/writecache_manip.c | 1 -
 tools/pvscan.c                  | 1 -
 5 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index 7ec699e..c3dfe8e 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -18,11 +18,10 @@
 
 #include "lib/config/config.h"
 #include "lib/metadata/metadata.h"
+#include "lib/format_text/format-text.h"
 #include "lib/cache/lvmcache.h"
 #include "lib/uuid/uuid.h"
 
-/* disk_locn and data_area_list are defined in format-text.h */
-
 /*
  * PV header extension versions:
  *   - version 1: bootloader area support
diff --git a/lib/label/hints.c b/lib/label/hints.c
index f8e8f45..f1a1519 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -135,11 +135,10 @@
  *
  */
 
-#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
+#include "base/memory/zalloc.h"
 #include "lib/label/label.h"
 #include "lib/misc/crc.h"
-#include "lib/mm/xlate.h"
 #include "lib/cache/lvmcache.h"
 #include "lib/device/bcache.h"
 #include "lib/commands/toolcontext.h"
diff --git a/lib/label/label.c b/lib/label/label.c
index 680630b..328e4e7 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -13,8 +13,8 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
+#include "base/memory/zalloc.h"
 #include "lib/label/label.h"
 #include "lib/misc/crc.h"
 #include "lib/mm/xlate.h"
@@ -24,7 +24,6 @@
 #include "lib/activate/activate.h"
 #include "lib/label/hints.h"
 #include "lib/metadata/metadata.h"
-#include "lib/format_text/format-text.h"
 #include "lib/format_text/layout.h"
 
 #include <sys/stat.h>
diff --git a/lib/metadata/writecache_manip.c b/lib/metadata/writecache_manip.c
index 5a5a759..0122025 100644
--- a/lib/metadata/writecache_manip.c
+++ b/lib/metadata/writecache_manip.c
@@ -21,7 +21,6 @@
 #include "lib/metadata/segtype.h"
 #include "lib/activate/activate.h"
 #include "lib/config/defaults.h"
-#include "lib/activate/dev_manager.h"
 
 int lv_is_writecache_origin(const struct logical_volume *lv)
 {
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 312a633..1bf543c 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -20,7 +20,6 @@
 #include "lib/label/hints.h"
 
 #include <dirent.h>
-#include <sys/file.h>
 
 struct pvscan_params {
 	int new_pvs_found;



