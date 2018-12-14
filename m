From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 14 Dec 2018 09:17:52 -0500
Subject: master - cleanup: some local headers first
Message-ID: <201812141417.wBEEHqqJ010376@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cc5cfb88d70ef7982e66e5ddf8a5fbd69d485fec
Commit:        cc5cfb88d70ef7982e66e5ddf8a5fbd69d485fec
Parent:        73bef5e3ddc962e462b3068fd0b1c7cbccad5176
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 13:10:25 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 14 15:14:48 2018 +0100

cleanup: some local headers first

---
 lib/device/dev-type.c         |    7 +++----
 lib/format_text/export.c      |    2 +-
 lib/format_text/format-text.c |    4 ++--
 3 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 693550a..d96f00b 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -15,15 +15,13 @@
 #include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/device/dev-type.h"
+#include "lib/device/device-types.h"
 #include "lib/mm/xlate.h"
 #include "lib/config/config.h"
 #include "lib/metadata/metadata.h"
 #include "lib/device/bcache.h"
 #include "lib/label/label.h"
 
-#include <libgen.h>
-#include <ctype.h>
-
 #ifdef BLKID_WIPING_SUPPORT
 #include <blkid.h>
 #endif
@@ -33,7 +31,8 @@
 #include "lib/device/dev-ext-udev-constants.h"
 #endif
 
-#include "lib/device/device-types.h"
+#include <libgen.h>
+#include <ctype.h>
 
 /*
  * dev is pmem if /sys/dev/block/<major>:<minor>/queue/dax is 1
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index a9a7e15..48e4c9a 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -16,12 +16,12 @@
 #include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "import-export.h"
+#include "lvm-version.h"
 #include "lib/metadata/metadata.h"
 #include "lib/display/display.h"
 #include "lib/misc/lvm-string.h"
 #include "lib/metadata/segtype.h"
 #include "lib/format_text/text_export.h"
-#include "lvm-version.h"
 #include "lib/commands/toolcontext.h"
 #include "libdaemon/client/config-util.h"
 
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 92a1495..f5bbf9e 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -14,8 +14,9 @@
  */
 
 #include "lib/misc/lib.h"
-#include "lib/format_text/format-text.h"
 #include "import-export.h"
+#include "format-text.h"
+#include "layout.h"
 #include "lib/device/device.h"
 #include "lib/misc/lvm-file.h"
 #include "lib/config/config.h"
@@ -23,7 +24,6 @@
 #include "lib/commands/toolcontext.h"
 #include "lib/misc/lvm-string.h"
 #include "lib/uuid/uuid.h"
-#include "layout.h"
 #include "lib/misc/crc.h"
 #include "lib/mm/xlate.h"
 #include "lib/label/label.h"


