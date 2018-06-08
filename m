From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 8 Jun 2018 09:25:29 -0400
Subject: master - libdm: Stop libdm/misc/dmlib.h from including lib/misc/lib.h
Message-ID: <201806081325.w58DPTII015615@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c78239d8605f333915543c0e0c3ccf4f4ef5ee8f
Commit:        c78239d8605f333915543c0e0c3ccf4f4ef5ee8f
Parent:        286c1ba3369d1901480425e305e313e8ea365da4
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Jun 8 13:01:41 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri Jun 8 13:01:41 2018 +0100

libdm: Stop libdm/misc/dmlib.h from including lib/misc/lib.h

---
 libdm/misc/dmlib.h |   67 +++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 64 insertions(+), 3 deletions(-)

diff --git a/libdm/misc/dmlib.h b/libdm/misc/dmlib.h
index bc14ece..4c6bcfc 100644
--- a/libdm/misc/dmlib.h
+++ b/libdm/misc/dmlib.h
@@ -14,13 +14,74 @@
  */
 
 /*
- * This file must be included first by every device-mapper library source file.
+ * This file must be included first by every library source file.
  */
 #ifndef _DM_LIB_H
 #define _DM_LIB_H
 
-#define DM
+#include "configure.h"
 
-#include "lib/misc/lib.h"
+#define _REENTRANT
+#define _GNU_SOURCE
+
+/*
+ * Symbol export control macros
+ *
+ *   DM_EXPORT_SYMBOL(func,ver)
+ *   DM_EXPORT_SYMBOL_BASE(func,ver)
+ *
+ * For functions that have multiple implementations these macros control
+ * symbol export and versioning.
+ *
+ * Function definitions that exist in only one version never need to use
+ * these macros.
+ *
+ * Backwards compatible implementations must include a version tag of
+ * the form "_v1_02_104" as a suffix to the function name and use the
+ * macro DM_EXPORT_SYMBOL to export the function and bind it to the
+ * specified version string.
+ *
+ * Since versioning is only available when compiling with GCC the entire
+ * compatibility version should be enclosed in '#if defined(__GNUC__)',
+ * for example:
+ *
+ *   int dm_foo(int bar)
+ *   {
+ *     return bar;
+ *   }
+ *
+ *   #if defined(__GNUC__)
+ *   // Backward compatible dm_foo() version 1.02.104
+ *   int dm_foo_v1_02_104(void);
+ *   int dm_foo_v1_02_104(void)
+ *   {
+ *     return 0;
+ *   }
+ *   DM_EXPORT_SYMBOL(dm_foo,1_02_104)
+ *   #endif
+ *
+ * A prototype for the compatibility version is required as these
+ * functions must not be declared static.
+ *
+ * The DM_EXPORT_SYMBOL_BASE macro is only used to export the base
+ * versions of library symbols prior to the introduction of symbol
+ * versioning: it must never be used for new symbols.
+ */
+#if defined(__GNUC__)
+#define DM_EXPORT_SYMBOL(func, ver) \
+	__asm__(".symver " #func "_v" #ver ", " #func "@DM_" #ver )
+#define DM_EXPORT_SYMBOL_BASE(func) \
+	__asm__(".symver " #func "_base, " #func "@Base" )
+#else
+#define DM_EXPORT_SYMBOL(func, ver)
+#define DM_EXPORT_SYMBOL_BASE(func)
+#endif
+
+#include "lib/misc/util.h"
+
+#include "libdm/libdevmapper.h"
+#include "libdm/misc/dm-logging.h"
+
+#include <unistd.h>
 
 #endif


