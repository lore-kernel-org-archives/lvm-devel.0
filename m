From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Dec 2018 15:46:15 -0500
Subject: master - configure: avoid repeative inclusion of configure.h
Message-ID: <201812212046.wBLKkFpR021002@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=18aa541ca270d70899ab7ec6095075b70a21fb09
Commit:        18aa541ca270d70899ab7ec6095075b70a21fb09
Parent:        a7034fa4200d63207daa45290150159dd02cf01f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 21 19:11:49 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 21 19:19:50 2018 +0100

configure: avoid repeative inclusion of configure.h

Since configure.h is a generated header and it's missing traditional
ifdefs preambule - it can be included & parsed multiple times.
Normally compiler is fine when defines have same value and there is
no warning - yet we don't need to parse this several times
and by adding -include  directive we can ensure every file
in the package is rightly compile with configure.h as the
first header file.
---
 base/data-struct/radix-tree.h         |    2 --
 base/memory/zalloc.h                  |    1 -
 daemons/cmirrord/logging.h            |    1 -
 daemons/dmeventd/dmeventd.c           |    1 -
 daemons/dmeventd/libdevmapper-event.c |    1 -
 device_mapper/all.h                   |    2 --
 device_mapper/vdo/status.c            |    2 --
 libdm/dm-tools/dmsetup.c              |    1 -
 libdm/make.tmpl.in                    |    4 ++--
 libdm/misc/dmlib.h                    |    2 --
 make.tmpl.in                          |    4 ++--
 test/lib/brick-shelltest.h            |    2 --
 test/lib/harness.c                    |    2 --
 test/unit/framework.h                 |    1 -
 tools/tool.h                          |    2 --
 15 files changed, 4 insertions(+), 24 deletions(-)

diff --git a/base/data-struct/radix-tree.h b/base/data-struct/radix-tree.h
index 685b828..5d4d04c 100644
--- a/base/data-struct/radix-tree.h
+++ b/base/data-struct/radix-tree.h
@@ -13,8 +13,6 @@
 #ifndef BASE_DATA_STRUCT_RADIX_TREE_H
 #define BASE_DATA_STRUCT_RADIX_TREE_H
 
-#include "configure.h"
-
 #include <stdbool.h>
 #include <stdint.h>
 #include <stdio.h>
diff --git a/base/memory/zalloc.h b/base/memory/zalloc.h
index 069c599..2509bf4 100644
--- a/base/memory/zalloc.h
+++ b/base/memory/zalloc.h
@@ -13,7 +13,6 @@
 #ifndef BASE_MEMORY_ZALLOC_H
 #define BASE_MEMORY_ZALLOC_H
 
-#include "configure.h"
 #include <stdlib.h>
 
 //----------------------------------------------------------------
diff --git a/daemons/cmirrord/logging.h b/daemons/cmirrord/logging.h
index 5f640cf..82ebab1 100644
--- a/daemons/cmirrord/logging.h
+++ b/daemons/cmirrord/logging.h
@@ -13,7 +13,6 @@
 #ifndef _LVM_CLOG_LOGGING_H
 #define _LVM_CLOG_LOGGING_H
 
-#include "configure.h"
 #include <stdio.h>
 #include <stdint.h>
 #include <syslog.h>
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 4a58449..33859ef 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -17,7 +17,6 @@
  */
 
 
-#include "configure.h"
 #include "libdevmapper-event.h"
 #include "dmeventd.h"
 
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 6465f64..491374e 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -12,7 +12,6 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "configure.h"
 #include "libdevmapper-event.h"
 #include "dmeventd.h"
 #include "libdm/misc/dm-logging.h"
diff --git a/device_mapper/all.h b/device_mapper/all.h
index 9539442..05cd83b 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -17,8 +17,6 @@
 #ifndef LIB_DEVICE_MAPPER_H
 #define LIB_DEVICE_MAPPER_H
 
-#include "configure.h"
-
 #include "base/data-struct/list.h"
 #include "base/data-struct/hash.h"
 #include "vdo/target.h"
diff --git a/device_mapper/vdo/status.c b/device_mapper/vdo/status.c
index a34029d..adb5a9b 100644
--- a/device_mapper/vdo/status.c
+++ b/device_mapper/vdo/status.c
@@ -15,8 +15,6 @@
 /* Note: this object is also used by VDO dmeventd plugin for parsing status */
 /* File could be included by VDO plugin and can use original libdm library */
 #ifndef LIB_DMEVENT_H
-#include "configure.h"
-// For DM_ARRAY_SIZE!
 #include "device_mapper/all.h"
 #endif
 
diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index efeb978..2feb419 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -17,7 +17,6 @@
  */
 
 // For canonicalize_file_name()
-#include "configure.h"
 #include "libdm/misc/dm-logging.h"
 #include "libdm/dm-tools/util.h"
 
diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index 92f2f55..26e3dba 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -275,11 +275,11 @@ LIB_VERSION_LVM := $(shell $(AWK) -F '.' '{printf "%s.%s",$$1,$$2}' $(top_srcdir
 
 LIB_VERSION_DM := $(shell $(AWK) -F '.' '{printf "%s.%s",$$1,$$2}' $(top_srcdir)/VERSION_DM)
 
-INCLUDES += -I$(srcdir) -I$(top_srcdir) -I$(top_builddir)/include
+INCLUDES += -I$(srcdir) -I$(top_srcdir) -I$(top_builddir)/include -include configure.h
 
 
 DEPS = $(top_builddir)/libdm/make.tmpl $(top_srcdir)/VERSION \
-       $(top_builddir)/libdm/Makefile
+       $(top_builddir)/libdm/Makefile $(top_builddir)/include/configure.h
 
 OBJECTS = $(SOURCES:%.c=%.o) $(CXXSOURCES:%.cpp=%.o)
 POTFILES = $(SOURCES:%.c=%.pot)
diff --git a/libdm/misc/dmlib.h b/libdm/misc/dmlib.h
index 60787fe..2ea05c1 100644
--- a/libdm/misc/dmlib.h
+++ b/libdm/misc/dmlib.h
@@ -19,8 +19,6 @@
 #ifndef _DM_LIB_H
 #define _DM_LIB_H
 
-#include "configure.h"
-
 /*
  * Symbol export control macros
  *
diff --git a/make.tmpl.in b/make.tmpl.in
index 9158f0e..f3332e9 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -294,12 +294,12 @@ LIB_VERSION_DM := $(shell $(AWK) -F '.' '{printf "%s.%s",$$1,$$2}' $(top_srcdir)
 
 LIB_VERSION_APP := $(shell $(AWK) -F '[(). ]' '{printf "%s.%s",$$1,$$4}' $(top_srcdir)/VERSION)
 
-INCLUDES += -I$(srcdir) -I$(top_srcdir) -I$(top_builddir)/include
+INCLUDES += -I$(srcdir) -I$(top_srcdir) -I$(top_builddir)/include -include configure.h
 
 #VDO_INCLUDES=-I at VDO_INCLUDE@
 
 DEPS = $(top_builddir)/make.tmpl $(top_srcdir)/VERSION \
-       $(top_builddir)/Makefile
+       $(top_builddir)/Makefile $(top_builddir)/include/configure.h
 
 OBJECTS = $(SOURCES:%.c=%.o) $(CXXSOURCES:%.cpp=%.o)
 POTFILES = $(SOURCES:%.c=%.pot)
diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 7c5b601..56429c7 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -80,8 +80,6 @@
 #include <unistd.h>
 #endif
 
-#include "configure.h"
-
 /*  Timeout for the whole test suite in hours */
 static const time_t TEST_SUITE_TIMEOUT = 4;
 
diff --git a/test/lib/harness.c b/test/lib/harness.c
index d1274ed..a97f5db 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -12,8 +12,6 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "configure.h"
-
 #include <errno.h>
 #include <fcntl.h>
 #include <limits.h>
diff --git a/test/unit/framework.h b/test/unit/framework.h
index d5a2cdd..0c45596 100644
--- a/test/unit/framework.h
+++ b/test/unit/framework.h
@@ -1,7 +1,6 @@
 #ifndef TEST_UNIT_FRAMEWORK_H
 #define TEST_UNIT_FRAMEWORK_H
 
-#include "configure.h"
 #include "device_mapper/all.h"
 
 #include <stdbool.h>
diff --git a/tools/tool.h b/tools/tool.h
index 6fd4da0..d78c042 100644
--- a/tools/tool.h
+++ b/tools/tool.h
@@ -18,8 +18,6 @@
 #ifndef _LVM_TOOL_H
 #define _LVM_TOOL_H
 
-#include "configure.h"
-
 #include "base/memory/zalloc.h"
 #include "device_mapper/all.h"
 #include "lib/misc/util.h"


