From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 24 Aug 2015 19:04:14 +0000 (UTC)
Subject: master - macros: fix default symbol export control
Message-ID: <20150824190414.720DF61551@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=82a27a85b54b68277e79de2fa9b4fadb01330497
Commit:        82a27a85b54b68277e79de2fa9b4fadb01330497
Parent:        ba898b9ab6f02153eb3fa44d1e893f6b49424652
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Aug 21 21:15:10 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Aug 24 20:03:21 2015 +0100

macros: fix default symbol export control

Fix the version export macros to make it possible to export two
different DM_* versions of a symbol: currently it is only possible for a
DM_* symbol to override a symbol in Base. Attempting to export two
symbols at different DM_* version levels (e.g. DM_1_02_104 and
DM_1_02_106) leads to a linker error due to a duplicate symbol
definition.

This is because the DM_EXPORTED_SYMBOL macro makes each exported symbol
the default (@@VERSION):

       __asm__(".symver " #func "_v" #ver ", " #func "@@DM_" #ver )

Fix the macro to use a single '@' for a symbols exported in multiple
versions and rename the macros to DM_EXPORT_*:

  DM_EXPORT_SYMBOL(func,ver)
  DM_EXPORT_SYMBOL_BASE(func,ver)

For functions that have multiple implementations these macros control
symbol export and versioning.

Function definitions that exist in only one version never need to use
these macros.

Backwards compatible implementations must include a version tag of
the form "_v1_02_104" as a suffix to the function name and use the
macro DM_EXPORT_SYMBOL to export the function and bind it to the
specified version string.

Since versioning is only available when compiling with GCC the entire
compatibility version should be enclosed in '#if defined(__GNUC__)',
for example:

  int dm_foo(int bar)
  {
    return bar;
  }

  #if defined(__GNUC__)
  // Backward compatible dm_foo() version 1.02.104
  int dm_foo_v1_02_104(void);
  int dm_foo_v1_02_104(void)
  {
    return 0;
  }
  DM_EXPORT_SYMBOL(dm_foo,1_02_104)
  #endif

A prototype for the compatibility version is required as these
functions must not be declared static.

The DM_EXPORT_SYMBOL_BASE macro is only used to export the base
versions of library symbols prior to the introduction of symbol
versioning: it must never be used for new symbols.
---
 lib/misc/lib.h               |   53 ++++++++++++++++++++++++++++++++++++++----
 libdm/.exported_symbols.Base |    1 -
 libdm/ioctl/libdm-iface.c    |   12 ++-------
 3 files changed, 51 insertions(+), 15 deletions(-)

diff --git a/lib/misc/lib.h b/lib/misc/lib.h
index 63f60a2..5e76e54 100644
--- a/lib/misc/lib.h
+++ b/lib/misc/lib.h
@@ -25,14 +25,57 @@
 #define _GNU_SOURCE
 #define _FILE_OFFSET_BITS 64
 
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
 #if defined(__GNUC__)
-#define DM_EXPORTED_SYMBOL(func, ver) \
-	__asm__(".symver " #func "_v" #ver ", " #func "@@DM_" #ver )
-#define DM_EXPORTED_SYMBOL_BASE(func) \
+#define DM_EXPORT_SYMBOL(func, ver) \
+	__asm__(".symver " #func "_v" #ver ", " #func "@DM_" #ver )
+#define DM_EXPORT_SYMBOL_BASE(func) \
 	__asm__(".symver " #func "_base, " #func "@Base" )
 #else
-#define DM_EXPORTED_SYMBOL(func, ver)
-#define DM_EXPORTED_SYMBOL_BASE(func)
+#define DM_EXPORT_SYMBOL(func, ver)
+#define DM_EXPORT_SYMBOL_BASE(func)
 #endif
 
 
diff --git a/libdm/.exported_symbols.Base b/libdm/.exported_symbols.Base
index 865a6a8..f9c3cb1 100644
--- a/libdm/.exported_symbols.Base
+++ b/libdm/.exported_symbols.Base
@@ -179,7 +179,6 @@ dm_task_destroy
 dm_task_enable_checks
 dm_task_get_deps
 dm_task_get_driver_version
-dm_task_get_info
 dm_task_get_info_with_deferred_remove
 dm_task_get_message_response
 dm_task_get_name
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index fe0bffa..e9566c2 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -681,13 +681,7 @@ int dm_format_dev(char *buf, int bufsize, uint32_t dev_major,
 	return 1;
 }
 
-#if defined(__GNUC__)
-int dm_task_get_info_v1_02_97(struct dm_task *dmt, struct dm_info *info);
-DM_EXPORTED_SYMBOL(dm_task_get_info, 1_02_97);
-int dm_task_get_info_v1_02_97(struct dm_task *dmt, struct dm_info *info)
-#else
 int dm_task_get_info(struct dm_task *dmt, struct dm_info *info)
-#endif
 {
 	if (!dmt->dmi.v4)
 		return 0;
@@ -2140,12 +2134,12 @@ void dm_lib_exit(void)
  */
 
 int dm_task_get_info_base(struct dm_task *dmt, struct dm_info *info);
-DM_EXPORTED_SYMBOL_BASE(dm_task_get_info);
+DM_EXPORT_SYMBOL_BASE(dm_task_get_info);
 int dm_task_get_info_base(struct dm_task *dmt, struct dm_info *info)
 {
 	struct dm_info new_info;
 
-	if (!dm_task_get_info_v1_02_97(dmt, &new_info))
+	if (!dm_task_get_info(dmt, &new_info))
 		return 0;
 
 	memcpy(info, &new_info, offsetof(struct dm_info, deferred_remove));
@@ -2158,7 +2152,7 @@ int dm_task_get_info_with_deferred_remove(struct dm_task *dmt, struct dm_info *i
 {
 	struct dm_info new_info;
 
-	if (!dm_task_get_info_v1_02_97(dmt, &new_info))
+	if (!dm_task_get_info(dmt, &new_info))
 		return 0;
 
 	memcpy(info, &new_info, offsetof(struct dm_info, internal_suspend));


