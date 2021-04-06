From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  6 Apr 2021 20:07:33 +0000 (GMT)
Subject: main - lib: remove unused macros
Message-ID: <20210406200733.146EC384607A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b99f7d0df95e24ee367ce0973924ebfdd62a207a
Commit:        b99f7d0df95e24ee367ce0973924ebfdd62a207a
Parent:        e86cd9c5ba5f675798d2553359632b44d2fe237f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 3 21:25:26 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 6 22:02:31 2021 +0200

lib: remove unused macros

Internally lvm2 is not using versioning for device-mapper.
---
 lib/misc/lib.h | 54 ------------------------------------------------------
 1 file changed, 54 deletions(-)

diff --git a/lib/misc/lib.h b/lib/misc/lib.h
index a4d109fb4..a3a11bad2 100644
--- a/lib/misc/lib.h
+++ b/lib/misc/lib.h
@@ -19,60 +19,6 @@
 #ifndef _LVM_LIB_H
 #define _LVM_LIB_H
 
-/*
- * Symbol export control macros
- *
- *   DM_EXPORT_SYMBOL(func,ver)
- *   DM_EXPORT_SYMBOL_BASE(func,ver)
- *
- * For functions that have multiple implementations these macros control
- * symbol export and versioning.
- *
- * Function definitions that exist in only one version never need to use
- * these macros.
- *
- * Backwards compatible implementations must include a version tag of
- * the form "_v1_02_104" as a suffix to the function name and use the
- * macro DM_EXPORT_SYMBOL to export the function and bind it to the
- * specified version string.
- *
- * Since versioning is only available when compiling with GCC the entire
- * compatibility version should be enclosed in '#if defined(GNU_SYMVER)',
- * for example:
- *
- *   int dm_foo(int bar)
- *   {
- *     return bar;
- *   }
- *
- *   #if defined(__GNUC__)
- *   // Backward compatible dm_foo() version 1.02.104
- *   int dm_foo_v1_02_104(void);
- *   int dm_foo_v1_02_104(void)
- *   {
- *     return 0;
- *   }
- *   DM_EXPORT_SYMBOL(dm_foo,1_02_104)
- *   #endif
- *
- * A prototype for the compatibility version is required as these
- * functions must not be declared static.
- *
- * The DM_EXPORT_SYMBOL_BASE macro is only used to export the base
- * versions of library symbols prior to the introduction of symbol
- * versioning: it must never be used for new symbols.
- */
-#if defined(GNU_SYMVER)
-#define DM_EXPORT_SYMBOL(func, ver) \
-	__asm__(".symver " #func "_v" #ver ", " #func "@DM_" #ver )
-#define DM_EXPORT_SYMBOL_BASE(func) \
-	__asm__(".symver " #func "_base, " #func "@Base" )
-#else
-#define DM_EXPORT_SYMBOL(func, ver)
-#define DM_EXPORT_SYMBOL_BASE(func)
-#endif
-
-
 #include "device_mapper/all.h"
 #include "base/memory/zalloc.h"
 #include "lib/misc/intl.h"


