From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:50 +0000 (GMT)
Subject: dev-next - configure: support builds without versioning
Message-ID: <20210331214950.0401D3857C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1cedbaf13778de02e38b5dc80a7af246b7ec83e5
Commit:        1cedbaf13778de02e38b5dc80a7af246b7ec83e5
Parent:        1a17a5ab80b1699ac086ad34852116e7728cc378
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 29 21:46:12 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 30 13:06:19 2021 +0200

configure: support builds without versioning

Not all libc (like musl, uclibc dietlibc) libraries support full symbol
version resolution in runtime like glibc.
Add support to not generate symbol versions when compiling against them.

Additionally libdevmapper.so was broken when compiled against
uclibc. Runtime linker loader caused calling dm_task_get_info_base()
function recursively, leading to segmentation fault.

Introduce --with-symvers=STYLE option, which allows to choose
between gnu and disabled symbol versioning. By default gnu symbol
versioning is used.
__GNUC__ check is replaced now with GNU_SYMVER.
Additionally ld version script is included only in
case of gnu option, which slightly reduces output size.

Providing --without-symvers to configure script when building against
uclibc library fixes segmentation fault error described above, due to
lack of several versions of the same symbol in libdevmapper.so
library.

Based on:
https://patchwork.kernel.org/project/dm-devel/patch/20180831144817.31207-1-m.niestroj at grinn-global.com/

Suggested-by: Marcin Niestroj <m.niestroj@grinn-global.com>
---
 WHATS_NEW                 |  1 +
 configure                 | 35 ++++++++++++++++++++++++++++++++---
 configure.ac              | 26 +++++++++++++++++++++++---
 include/configure.h.in    |  3 +++
 lib/misc/lib.h            |  4 ++--
 libdm/datastruct/bitset.c |  4 +---
 libdm/ioctl/libdm-iface.c |  2 +-
 libdm/libdm-deptree.c     |  2 +-
 libdm/libdm-stats.c       |  2 +-
 libdm/misc/dmlib.h        |  4 ++--
 10 files changed, 67 insertions(+), 16 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3e086f951..c08864bae 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.12 - 
 ===================================
+  Add configure option --with/out-symvers for non-glibc builds.
   Report error when the filesystem is missing on fsadm resized volume.
   Handle better blockdev with --getsize64 support for fsadm.
   Do not include editline/history.h when using editline library.
diff --git a/configure b/configure
index ff363b046..9fe0c8ddf 100755
--- a/configure
+++ b/configure
@@ -934,6 +934,7 @@ enable_cmirrord
 with_cmirrord_pidfile
 enable_debug
 with_optimisation
+with_symvers
 enable_profiling
 enable_valgrind_pool
 enable_devmapper
@@ -1749,6 +1750,8 @@ Optional Packages:
   --with-cmirrord-pidfile=PATH
                           cmirrord pidfile [PID_DIR/cmirrord.pid]
   --with-optimisation=OPT C optimisation flag [OPT=-O2]
+  --with-symvers=STYLE    use symbol versioning of the shared library
+                          [default=gnu]
   --with-lvmlockd-pidfile=PATH
                           lvmlockd pidfile [PID_DIR/lvmlockd.pid]
   --with-lvmpolld-pidfile=PATH
@@ -3103,13 +3106,11 @@ if test -z "$CFLAGS"; then :
 fi
 case "$host_os" in
 	linux*)
-		CLDFLAGS="${CLDFLAGS-"$LDFLAGS"} -Wl,--version-script,.export.sym"
 		# equivalent to -rdynamic
 		ELDFLAGS="-Wl,--export-dynamic"
 		# FIXME Generate list and use --dynamic-list=.dlopen.sym
 		CLDWHOLEARCHIVE="-Wl,-whole-archive"
 		CLDNOWHOLEARCHIVE="-Wl,-no-whole-archive"
-		LDDEPS="$LDDEPS .export.sym"
 		LIB_SUFFIX=so
 		DEVMAPPER=yes
 		BUILD_LVMPOLLD=no
@@ -3124,7 +3125,6 @@ case "$host_os" in
 		;;
 	darwin*)
 		CFLAGS="$CFLAGS -no-cpp-precomp -fno-common"
-		CLDFLAGS="${CLDFLAGS-"$LDFLAGS"}"
 		ELDFLAGS=
 		CLDWHOLEARCHIVE="-all_load"
 		CLDNOWHOLEARCHIVE=
@@ -10393,6 +10393,35 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $COPTIMISE_FLAG" >&5
 $as_echo "$COPTIMISE_FLAG" >&6; }
 
+################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to use symbol versioning" >&5
+$as_echo_n "checking whether to use symbol versioning... " >&6; }
+
+# Check whether --with-symvers was given.
+if test "${with_symvers+set}" = set; then :
+  withval=$with_symvers;  case "$withval" in
+				gnu|no) symvers=$withval ;;
+				*) as_fn_error $? "Unknown argument to with-symvers" "$LINENO" 5 ;;
+			     esac
+else
+  symvers=gnu
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $symvers" >&5
+$as_echo "$symvers" >&6; }
+
+if test "$GCC" = "yes" && test "$symvers" = "gnu" ; then
+
+$as_echo "#define GNU_SYMVER 1" >>confdefs.h
+
+		   case "$host_os" in
+			linux*)
+			CLDFLAGS="${CLDFLAGS-"$LDFLAGS"} -Wl,--version-script,.export.sym"
+			LDDEPS="$LDDEPS .export.sym"
+			;;
+		   esac
+fi
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to gather gcov profiling data" >&5
 $as_echo_n "checking whether to gather gcov profiling data... " >&6; }
diff --git a/configure.ac b/configure.ac
index b92be0db3..21a1d311e 100644
--- a/configure.ac
+++ b/configure.ac
@@ -30,13 +30,11 @@ AC_CANONICAL_TARGET([])
 AS_IF([test -z "$CFLAGS"], [COPTIMISE_FLAG="-O2"])
 case "$host_os" in
 	linux*)
-		CLDFLAGS="${CLDFLAGS-"$LDFLAGS"} -Wl,--version-script,.export.sym"
 		# equivalent to -rdynamic
 		ELDFLAGS="-Wl,--export-dynamic"
 		# FIXME Generate list and use --dynamic-list=.dlopen.sym
 		CLDWHOLEARCHIVE="-Wl,-whole-archive"
 		CLDNOWHOLEARCHIVE="-Wl,-no-whole-archive"
-		LDDEPS="$LDDEPS .export.sym"
 		LIB_SUFFIX=so
 		DEVMAPPER=yes
 		BUILD_LVMPOLLD=no
@@ -51,7 +49,6 @@ case "$host_os" in
 		;;
 	darwin*)
 		CFLAGS="$CFLAGS -no-cpp-precomp -fno-common"
-		CLDFLAGS="${CLDFLAGS-"$LDFLAGS"}"
 		ELDFLAGS=
 		CLDWHOLEARCHIVE="-all_load"
 		CLDNOWHOLEARCHIVE=
@@ -825,6 +822,29 @@ AC_ARG_WITH(optimisation,
 	    COPTIMISE_FLAG=$withval)
 AC_MSG_RESULT($COPTIMISE_FLAG)
 
+################################################################################
+dnl -- Symbol versioning
+AC_MSG_CHECKING(whether to use symbol versioning)
+AC_ARG_WITH(symvers,
+	    AC_HELP_STRING([--with-symvers=STYLE],
+			   [use symbol versioning of the shared library [default=gnu]]),
+			   [ case "$withval" in
+				gnu|no) symvers=$withval ;;
+				*) AC_MSG_ERROR(Unknown argument to with-symvers) ;;
+			     esac], symvers=gnu)
+AC_MSG_RESULT($symvers)
+
+if test "$GCC" = "yes" && test "$symvers" = "gnu" ; then
+	AC_DEFINE(GNU_SYMVER, 1,
+		  [Define to use GNU versioning in the shared library.])
+		   case "$host_os" in
+			linux*)
+			CLDFLAGS="${CLDFLAGS-"$LDFLAGS"} -Wl,--version-script,.export.sym"
+			LDDEPS="$LDDEPS .export.sym"
+			;;
+		   esac
+fi
+
 ################################################################################
 dnl -- Enable profiling
 AC_MSG_CHECKING(whether to gather gcov profiling data)
diff --git a/include/configure.h.in b/include/configure.h.in
index b8d95833a..671d201b2 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -132,6 +132,9 @@
 /* Path to fsadm binary. */
 #undef FSADM_PATH
 
+/* Define to use GNU versioning in the shared library. */
+#undef GNU_SYMVER
+
 /* Define to 1 if you have the `alarm' function. */
 #undef HAVE_ALARM
 
diff --git a/lib/misc/lib.h b/lib/misc/lib.h
index c14f437a0..a4d109fb4 100644
--- a/lib/misc/lib.h
+++ b/lib/misc/lib.h
@@ -37,7 +37,7 @@
  * specified version string.
  *
  * Since versioning is only available when compiling with GCC the entire
- * compatibility version should be enclosed in '#if defined(__GNUC__)',
+ * compatibility version should be enclosed in '#if defined(GNU_SYMVER)',
  * for example:
  *
  *   int dm_foo(int bar)
@@ -62,7 +62,7 @@
  * versions of library symbols prior to the introduction of symbol
  * versioning: it must never be used for new symbols.
  */
-#if defined(__GNUC__)
+#if defined(GNU_SYMVER)
 #define DM_EXPORT_SYMBOL(func, ver) \
 	__asm__(".symver " #func "_v" #ver ", " #func "@DM_" #ver )
 #define DM_EXPORT_SYMBOL_BASE(func) \
diff --git a/libdm/datastruct/bitset.c b/libdm/datastruct/bitset.c
index 06bd31a9d..8f36ec715 100644
--- a/libdm/datastruct/bitset.c
+++ b/libdm/datastruct/bitset.c
@@ -242,7 +242,7 @@ bad:
 	return NULL;
 }
 
-#if defined(__GNUC__)
+#if defined(GNU_SYMVER)
 /*
  * Maintain backward compatibility with older versions that did not
  * accept a 'min_num_bits' argument to dm_bitset_parse_list().
@@ -254,6 +254,4 @@ dm_bitset_t dm_bitset_parse_list_v1_02_129(const char *str, struct dm_pool *mem)
 }
 DM_EXPORT_SYMBOL(dm_bitset_parse_list, 1_02_129);
 
-#else /* if defined(__GNUC__) */
-
 #endif
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index f35ddeb07..e459db88d 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -2188,7 +2188,7 @@ void dm_lib_exit(void)
 	_version_checked = 0;
 }
 
-#if defined(__GNUC__)
+#if defined(GNU_SYMVER)
 /*
  * Maintain binary backward compatibility.
  * Version script mechanism works with 'gcc' compatible compilers only.
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index bf027ee81..e4cb6e5c0 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -3849,7 +3849,7 @@ void dm_tree_node_set_callback(struct dm_tree_node *dnode,
 	dnode->callback_data = data;
 }
 
-#if defined(__GNUC__)
+#if defined(GNU_SYMVER)
 /*
  * Backward compatible implementations.
  *
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index f8d79d807..49d06802e 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -5069,7 +5069,7 @@ int dm_stats_start_filemapd(int fd, uint64_t group_id, const char *path,
  * current dm_stats_create_region() version.
  */
 
-#if defined(__GNUC__)
+#if defined(GNU_SYMVER)
 int dm_stats_create_region_v1_02_106(struct dm_stats *dms, uint64_t *region_id,
 				     uint64_t start, uint64_t len, int64_t step,
 				     int precise, const char *program_id,
diff --git a/libdm/misc/dmlib.h b/libdm/misc/dmlib.h
index 2ea05c1fa..22328696b 100644
--- a/libdm/misc/dmlib.h
+++ b/libdm/misc/dmlib.h
@@ -37,7 +37,7 @@
  * specified version string.
  *
  * Since versioning is only available when compiling with GCC the entire
- * compatibility version should be enclosed in '#if defined(__GNUC__)',
+ * compatibility version should be enclosed in '#if defined(GNU_SYMVER)',
  * for example:
  *
  *   int dm_foo(int bar)
@@ -62,7 +62,7 @@
  * versions of library symbols prior to the introduction of symbol
  * versioning: it must never be used for new symbols.
  */
-#if defined(__GNUC__)
+#if defined(GNU_SYMVER)
 #define DM_EXPORT_SYMBOL(func, ver) \
 	__asm__(".symver " #func "_v" #ver ", " #func "@DM_" #ver )
 #define DM_EXPORT_SYMBOL_BASE(func) \


