From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:19 +0000 (UTC)
Subject: master - cleanup: reduce inclusion of unnecessary headers
Message-ID: <20140418145519.140C360F54@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=559c003ee248704e758dec63cf480447d4de6cd7
Commit:        559c003ee248704e758dec63cf480447d4de6cd7
Parent:        589983a257cd2f92489f41d2d7ec62784bf357e7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 17 10:48:55 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:38:50 2014 +0200

cleanup: reduce inclusion of unnecessary headers

Remove those file which are not needed by .c files
or already include because the headers already needs them.
---
 lib/commands/toolcontext.h      |    1 -
 lib/config/config.h             |    3 +--
 lib/config/config_settings.h    |    1 +
 lib/datastruct/lvm-types.h      |    3 ---
 lib/format_text/import-export.h |    1 -
 lib/mirror/mirrored.c           |    1 -
 lib/misc/lib.h                  |    5 -----
 lib/misc/lvm-string.h           |    6 +++---
 lib/raid/raid.c                 |    2 --
 lib/report/properties.c         |    1 -
 lib/snapshot/snapshot.c         |    2 --
 lib/thin/thin.c                 |    6 ------
 lib/unknown/unknown.c           |    2 --
 lib/zero/zero.c                 |    1 -
 14 files changed, 5 insertions(+), 30 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 0cd9a2f..7694ee2 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -19,7 +19,6 @@
 #include "dev-cache.h"
 #include "dev-type.h"
 
-#include <stdio.h>
 #include <limits.h>
 
 /*
diff --git a/lib/config/config.h b/lib/config/config.h
index a61d285..b258d55 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -16,8 +16,7 @@
 #ifndef _LVM_CONFIG_H
 #define _LVM_CONFIG_H
 
-#include "lvm-types.h"
-#include "defaults.h"
+#include "libdevmapper.h"
 
 /* 16 bits: 3 bits for major, 4 bits for minor, 9 bits for patchlevel */
 /* FIXME Max LVM version supported: 7.15.511. Extend bits when needed. */
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 932ba2e..3792238 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -65,6 +65,7 @@
  *			that parent nodes are consistent with versioning, no check done
  *			if parent node is older or the same age as any child node!)
  */
+#include "defaults.h"
 
 cfg_section(root_CFG_SECTION, "(root)", root_CFG_SECTION, 0, vsn(0, 0, 0), NULL)
 
diff --git a/lib/datastruct/lvm-types.h b/lib/datastruct/lvm-types.h
index de144bd..b38798f 100644
--- a/lib/datastruct/lvm-types.h
+++ b/lib/datastruct/lvm-types.h
@@ -16,9 +16,6 @@
 #ifndef _LVM_TYPES_H
 #define _LVM_TYPES_H
 
-#include <sys/types.h>
-#include <inttypes.h>
-
 #include "libdevmapper.h"
 
 struct str_list {
diff --git a/lib/format_text/import-export.h b/lib/format_text/import-export.h
index 6a4afed..d4e25f0 100644
--- a/lib/format_text/import-export.h
+++ b/lib/format_text/import-export.h
@@ -17,7 +17,6 @@
 #define _LVM_TEXT_IMPORT_EXPORT_H
 
 #include "config.h"
-#include "lvm-types.h"
 #include "metadata.h"
 
 #include <stdio.h>
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index e35a372..afb047e 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -21,7 +21,6 @@
 #include "text_export.h"
 #include "text_import.h"
 #include "config.h"
-#include "defaults.h"
 #include "lvm-string.h"
 #include "targets.h"
 #include "activate.h"
diff --git a/lib/misc/lib.h b/lib/misc/lib.h
index f0dba25..5bd968a 100644
--- a/lib/misc/lib.h
+++ b/lib/misc/lib.h
@@ -43,11 +43,6 @@
 #  include "lvm-types.h"
 #endif
 
-#include <errno.h>
-#include <stdio.h>
-#include <stdlib.h>
-#include <string.h>
 #include <unistd.h>
-#include <sys/stat.h>
 
 #endif
diff --git a/lib/misc/lvm-string.h b/lib/misc/lvm-string.h
index 82ebb12..a4f112f 100644
--- a/lib/misc/lvm-string.h
+++ b/lib/misc/lvm-string.h
@@ -16,12 +16,12 @@
 #ifndef _LVM_STRING_H
 #define _LVM_STRING_H
 
-#include <stdio.h>
-#include <stdarg.h>
-
 #define NAME_LEN 128
 #define UUID_PREFIX "LVM-"
 
+#include <sys/types.h>
+
+struct dm_pool;
 struct pool;
 struct logical_volume;
 
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 0869ff4..815c6f7 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -13,7 +13,6 @@
  */
 
 #include "lib.h"
-#include "toolcontext.h"
 #include "segtype.h"
 #include "display.h"
 #include "text_export.h"
@@ -25,7 +24,6 @@
 #include "activate.h"
 #include "metadata.h"
 #include "lv_alloc.h"
-#include "defaults.h"
 
 static const char *_raid_name(const struct lv_segment *seg)
 {
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 8c48de1..c6ccb72 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -15,7 +15,6 @@
 #include "lib.h"
 #include "properties.h"
 #include "activate.h"
-#include "lvm-types.h"
 #include "metadata.h"
 
 
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 64919b0..7ee0365 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -14,14 +14,12 @@
  */
 
 #include "lib.h"
-#include "toolcontext.h"
 #include "metadata.h"
 #include "segtype.h"
 #include "text_export.h"
 #include "config.h"
 #include "activate.h"
 #include "str_list.h"
-#include "defaults.h"
 
 #define SEG_LOG_ERROR(t, p...) \
 	log_error(t " segment %s of logical volume %s.", ## p, \
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index d4bde8b..b717603 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -13,18 +13,12 @@
  */
 
 #include "lib.h"
-#include "toolcontext.h"
 #include "metadata.h"
 #include "segtype.h"
 #include "text_export.h"
 #include "config.h"
 #include "activate.h"
 #include "str_list.h"
-#include "defaults.h"
-
-#ifdef DMEVENTD
-#  include "libdevmapper-event.h"
-#endif
 
 /* Dm kernel module name for thin provisiong */
 static const char _thin_pool_module[] = "thin-pool";
diff --git a/lib/unknown/unknown.c b/lib/unknown/unknown.c
index 848a369..9e433cf 100644
--- a/lib/unknown/unknown.c
+++ b/lib/unknown/unknown.c
@@ -15,10 +15,8 @@
 #include "lib.h"
 #include "toolcontext.h"
 #include "segtype.h"
-#include "display.h"
 #include "text_export.h"
 #include "config.h"
-#include "activate.h"
 
 static const char *_unknown_name(const struct lv_segment *seg)
 {
diff --git a/lib/zero/zero.c b/lib/zero/zero.c
index 473daa0..555c570 100644
--- a/lib/zero/zero.c
+++ b/lib/zero/zero.c
@@ -13,7 +13,6 @@
  */
 
 #include "lib.h"
-#include "toolcontext.h"
 #include "segtype.h"
 #include "display.h"
 #include "config.h"


