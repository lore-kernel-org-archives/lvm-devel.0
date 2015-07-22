From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 22 Jul 2015 22:13:20 +0000 (UTC)
Subject: master - libdm: Use wrappers for all malloc functions.
Message-ID: <20150722221320.297CC60EE6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1612c570b6412b68349b055ba3a6dab1796b8f35
Commit:        1612c570b6412b68349b055ba3a6dab1796b8f35
Parent:        b92e5026957c5ca72e6e88304feaf7527ca80af1
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jul 22 23:03:32 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jul 22 23:11:48 2015 +0100

libdm: Use wrappers for all malloc functions.

Move the DEBUG_MEM decision inside libdevmapper.so instead of exposing
it in libdevmapper.h which causes failures if the binary and library
were compiled with opposite debugging settings.
---
 WHATS_NEW_DM                        |    1 +
 libdm/.exported_symbols             |    9 +++
 libdm/.exported_symbols.DM_1_02_103 |    7 +++
 libdm/libdevmapper.h                |   52 +++++++------------
 libdm/mm/dbg_malloc.c               |   95 +++++++++++++++++++++++++++++++++++
 5 files changed, 130 insertions(+), 34 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 57edd8d..3dba5b8 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.103 -
 ================================
+  Introduce libdevmapper wrappers for all malloc-related functions.
 
 Version 1.02.102 - 7th July 2015
 ================================
diff --git a/libdm/.exported_symbols b/libdm/.exported_symbols
index 2b85343..6000686 100644
--- a/libdm/.exported_symbols
+++ b/libdm/.exported_symbols
@@ -1,3 +1,12 @@
+dm_bounds_check_debug
+dm_dump_memory_debug
+dm_free_aux
 dm_log
 dm_log_with_errno
+dm_malloc_aux
+dm_malloc_aux_debug
+dm_realloc_aux
+dm_strdup_aux
 dm_task_get_info_with_deferred_remove
+dm_zalloc_aux
+dm_zalloc_aux_debug
diff --git a/libdm/.exported_symbols.DM_1_02_103 b/libdm/.exported_symbols.DM_1_02_103
new file mode 100644
index 0000000..5dea5ea
--- /dev/null
+++ b/libdm/.exported_symbols.DM_1_02_103
@@ -0,0 +1,7 @@
+dm_bounds_check_wrapper
+dm_dump_memory_wrapper
+dm_free_wrapper
+dm_malloc_wrapper
+dm_realloc_wrapper
+dm_strdup_wrapper
+dm_zalloc_wrapper
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index aad2971..6523c70 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -962,44 +962,28 @@ uint32_t dm_tree_get_cookie(struct dm_tree_node *node);
  * Memory management
  *******************/
 
-void *dm_malloc_aux(size_t s, const char *file, int line)
+/*
+ * Never use these functions directly - use the macros following instead.
+ */
+void *dm_malloc_wrapper(size_t s, const char *file, int line)
 	__attribute__((__malloc__)) __attribute__((__warn_unused_result__));
-void *dm_malloc_aux_debug(size_t s, const char *file, int line)
-	__attribute__((__warn_unused_result__));
-void *dm_zalloc_aux(size_t s, const char *file, int line)
+void *dm_zalloc_wrapper(size_t s, const char *file, int line)
 	__attribute__((__malloc__)) __attribute__((__warn_unused_result__));
-void *dm_zalloc_aux_debug(size_t s, const char *file, int line)
+void *dm_realloc_wrapper(void *p, unsigned int s, const char *file, int line)
 	__attribute__((__warn_unused_result__));
-char *dm_strdup_aux(const char *str, const char *file, int line)
-	__attribute__((__malloc__)) __attribute__((__warn_unused_result__));
-void dm_free_aux(void *p);
-void *dm_realloc_aux(void *p, unsigned int s, const char *file, int line)
+void dm_free_wrapper(void *ptr);
+char *dm_strdup_wrapper(const char *s, const char *file, int line)
 	__attribute__((__warn_unused_result__));
-int dm_dump_memory_debug(void);
-void dm_bounds_check_debug(void);
-
-#ifdef DEBUG_MEM
-
-#  define dm_malloc(s) dm_malloc_aux_debug((s), __FILE__, __LINE__)
-#  define dm_zalloc(s) dm_zalloc_aux_debug((s), __FILE__, __LINE__)
-#  define dm_strdup(s) dm_strdup_aux((s), __FILE__, __LINE__)
-#  define dm_free(p) dm_free_aux(p)
-#  define dm_realloc(p, s) dm_realloc_aux(p, s, __FILE__, __LINE__)
-#  define dm_dump_memory() dm_dump_memory_debug()
-#  define dm_bounds_check() dm_bounds_check_debug()
-
-#else
-
-#  define dm_malloc(s) dm_malloc_aux((s), __FILE__, __LINE__)
-#  define dm_zalloc(s) dm_zalloc_aux((s), __FILE__, __LINE__)
-#  define dm_strdup(s) strdup(s)
-#  define dm_free(p) free(p)
-#  define dm_realloc(p, s) realloc(p, s)
-#  define dm_dump_memory() {}
-#  define dm_bounds_check() {}
-
-#endif
-
+int dm_dump_memory_wrapper(void);
+void dm_bounds_check_wrapper(void);
+
+#define dm_malloc(s) dm_malloc_wrapper((s), __FILE__, __LINE__)
+#define dm_zalloc(s) dm_zalloc_wrapper((s), __FILE__, __LINE__)
+#define dm_strdup(s) dm_strdup_wrapper((s), __FILE__, __LINE__)
+#define dm_free(p) dm_free_wrapper(p)
+#define dm_realloc(p, s) dm_realloc_wrapper((p), (s), __FILE__, __LINE__)
+#define dm_dump_memory() dm_dump_memory_wrapper()
+#define dm_bounds_check() dm_bounds_check_wrapper()
 
 /*
  * The pool allocator is useful when you are going to allocate
diff --git a/libdm/mm/dbg_malloc.c b/libdm/mm/dbg_malloc.c
index e26f05e..ac71480 100644
--- a/libdm/mm/dbg_malloc.c
+++ b/libdm/mm/dbg_malloc.c
@@ -22,6 +22,22 @@
 #include <assert.h>
 #include <stdarg.h>
 
+void *dm_malloc_aux(size_t s, const char *file, int line)
+        __attribute__((__malloc__)) __attribute__((__warn_unused_result__));
+void *dm_malloc_aux_debug(size_t s, const char *file, int line)
+        __attribute__((__malloc__)) __attribute__((__warn_unused_result__));
+void *dm_zalloc_aux(size_t s, const char *file, int line)
+        __attribute__((__malloc__)) __attribute__((__warn_unused_result__));
+void *dm_zalloc_aux_debug(size_t s, const char *file, int line)
+        __attribute__((__malloc__)) __attribute__((__warn_unused_result__));
+void *dm_realloc_aux(void *p, unsigned int s, const char *file, int line)
+        __attribute__((__warn_unused_result__));
+void dm_free_aux(void *p);
+char *dm_strdup_aux(const char *str, const char *file, int line)
+        __attribute__((__warn_unused_result__));
+int dm_dump_memory_debug(void);
+void dm_bounds_check_debug(void);
+
 char *dm_strdup_aux(const char *str, const char *file, int line)
 {
 	char *ret;
@@ -279,3 +295,82 @@ void *dm_zalloc_aux(size_t s, const char *file, int line)
 
 	return ptr;
 }
+
+#ifdef DEBUG_MEM
+
+void *dm_malloc_wrapper(size_t s, const char *file, int line)
+{
+	return dm_malloc_aux_debug(s, file, line);
+}
+
+void *dm_zalloc_wrapper(size_t s, const char *file, int line)
+{
+	return dm_zalloc_aux_debug(s, file, line);
+}
+
+char *dm_strdup_wrapper(const char *str, const char *file, int line)
+{
+	return dm_strdup_aux(str, file, line);
+}
+
+void dm_free_wrapper(void *ptr)
+{
+	dm_free_aux(ptr);
+}
+
+void *dm_realloc_wrapper(void *p, unsigned int s, const char *file, int line)
+{
+	return dm_realloc_aux(p, s, file, line);
+}
+
+int dm_dump_memory_wrapper(void)
+{
+	return dm_dump_memory_debug();
+}
+
+void dm_bounds_check_wrapper(void)
+{
+	dm_bounds_check_debug();
+}
+
+#else /* !DEBUG_MEM */
+
+void *dm_malloc_wrapper(size_t s, const char *file, int line)
+{
+	return dm_malloc_aux(s, file, line);
+}
+
+void *dm_zalloc_wrapper(size_t s, const char *file, int line)
+{
+	return dm_zalloc_aux(s, file, line);
+}
+
+char *dm_strdup_wrapper(const char *str,
+			const char *file __attribute__((unused)),
+			int line __attribute__((unused)))
+{
+	return strdup(str);
+}
+
+void dm_free_wrapper(void *ptr)
+{
+	free(ptr);
+}
+
+void *dm_realloc_wrapper(void *p, unsigned int s, 
+			 const char *file __attribute__((unused)),
+			 int line __attribute__((unused)))
+{
+	return realloc(p, s);
+}
+
+int dm_dump_memory_wrapper(void)
+{
+	return 1;
+}
+
+void dm_bounds_check_wrapper(void)
+{
+}
+
+#endif /* DEBUG_MEM */


