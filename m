From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:34:11 -0400
Subject: master - build: add vdo configuration option --with-vdo=
Message-ID: <201807091334.w69DYBpA030586@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4a90b0c4c92564adb1569824f22dc0d9a1badf5e
Commit:        4a90b0c4c92564adb1569824f22dc0d9a1badf5e
Parent:        2e05f6018bc3cbc8104ea53fb8a3e041ef5f899a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 29 13:38:18 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:28:35 2018 +0200

build: add vdo configuration option --with-vdo=

Checks whether VDO support is enabled.
Detects presence of 'vdoformat' tool which is required for to format VDO pool.

ATM build of VDO is NOT automatically enabled (None is default).
To enable build of LVM with VDO support use:

configure --with-vdo=internal

TODO: Maybe future version may switch to link some small VDO library for formating
(would require linking and package dependency).
---
 configure              |  172 ++++++++++++++++++++++++++++++++++++++++++++++++
 configure.ac           |   54 +++++++++++++++
 device_mapper/Makefile |    3 +
 include/configure.h.in |    6 ++
 make.tmpl.in           |    1 +
 5 files changed, 236 insertions(+), 0 deletions(-)

diff --git a/configure b/configure
index fc5783d..a96de76 100755
--- a/configure
+++ b/configure
@@ -641,6 +641,9 @@ LVMPOLLD_PIDFILE
 LVMETAD_PIDFILE
 DMEVENTD_PIDFILE
 WRITE_INSTALL
+VDO_LIB
+VDO_INCLUDE
+VDO
 VALGRIND_POOL
 USRSBINDIR
 SILENT_RULES
@@ -791,6 +794,7 @@ PKGCONFIGINIT_CFLAGS
 PKG_CONFIG_LIBDIR
 PKG_CONFIG_PATH
 PKG_CONFIG
+VDO_FORMAT_CMD
 CACHE_RESTORE_CMD
 CACHE_REPAIR_CMD
 CACHE_DUMP_CMD
@@ -912,6 +916,8 @@ with_cache_dump
 with_cache_repair
 with_cache_restore
 enable_cache_check_needs_check
+with_vdo
+with_vdo_format
 enable_readline
 enable_realtime
 enable_ocf
@@ -1708,6 +1714,8 @@ Optional Packages:
                           cache_repair tool: [autodetect]
   --with-cache-restore=PATH
                           cache_restore tool: [autodetect]
+  --with-vdo=TYPE         vdo support: internal/none [internal]
+  --with-vdo-format=PATH  vdoformat tool: [autodetect]
   --with-ocfdir=DIR       install OCF files in
                           [PREFIX/lib/ocf/resource.d/lvm2]
   --with-default-pid-dir=PID_DIR
@@ -9545,6 +9553,165 @@ cat >>confdefs.h <<_ACEOF
 _ACEOF
 
 
+################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include vdo" >&5
+$as_echo_n "checking whether to include vdo... " >&6; }
+
+# Check whether --with-vdo was given.
+if test "${with_vdo+set}" = set; then :
+  withval=$with_vdo; VDO=$withval
+else
+  VDO="none"
+fi
+
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $VDO" >&5
+$as_echo "$VDO" >&6; }
+
+
+# Check whether --with-vdo-format was given.
+if test "${with_vdo_format+set}" = set; then :
+  withval=$with_vdo_format; VDO_FORMAT_CMD=$withval
+else
+  VDO_FORMAT_CMD="autodetect"
+fi
+
+case "$VDO" in
+ none) ;;
+ internal)
+
+$as_echo "#define VDO_INTERNAL 1" >>confdefs.h
+
+	if test "$VDO_FORMAT_CMD" = "autodetect"; then
+		if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}vdoformat", so it can be a program name with args.
+set dummy ${ac_tool_prefix}vdoformat; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_VDO_FORMAT_CMD+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $VDO_FORMAT_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_VDO_FORMAT_CMD="$VDO_FORMAT_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_VDO_FORMAT_CMD="$as_dir/$ac_word$ac_exec_ext"
+    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
+
+  ;;
+esac
+fi
+VDO_FORMAT_CMD=$ac_cv_path_VDO_FORMAT_CMD
+if test -n "$VDO_FORMAT_CMD"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $VDO_FORMAT_CMD" >&5
+$as_echo "$VDO_FORMAT_CMD" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+fi
+if test -z "$ac_cv_path_VDO_FORMAT_CMD"; then
+  ac_pt_VDO_FORMAT_CMD=$VDO_FORMAT_CMD
+  # Extract the first word of "vdoformat", so it can be a program name with args.
+set dummy vdoformat; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_ac_pt_VDO_FORMAT_CMD+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_VDO_FORMAT_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_VDO_FORMAT_CMD="$ac_pt_VDO_FORMAT_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_VDO_FORMAT_CMD="$as_dir/$ac_word$ac_exec_ext"
+    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
+
+  ;;
+esac
+fi
+ac_pt_VDO_FORMAT_CMD=$ac_cv_path_ac_pt_VDO_FORMAT_CMD
+if test -n "$ac_pt_VDO_FORMAT_CMD"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_VDO_FORMAT_CMD" >&5
+$as_echo "$ac_pt_VDO_FORMAT_CMD" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_pt_VDO_FORMAT_CMD" = x; then
+    VDO_FORMAT_CMD=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    VDO_FORMAT_CMD=$ac_pt_VDO_FORMAT_CMD
+  fi
+else
+  VDO_FORMAT_CMD="$ac_cv_path_VDO_FORMAT_CMD"
+fi
+
+		if test -z "$VDO_FORMAT_CMD"; then
+			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: vdoformat not found in path $PATH" >&5
+$as_echo "$as_me: WARNING: vdoformat not found in path $PATH" >&2;}
+			VDO_FORMAT_CMD=/usr/bin/vdoformat
+			VDO_CONFIGURE_WARN=y
+		fi
+	fi
+	;;
+ *) as_fn_error $? "--with-vdo parameter invalid" "$LINENO" 5 ;;
+esac
+
+
+cat >>confdefs.h <<_ACEOF
+#define VDO_FORMAT_CMD "$VDO_FORMAT_CMD"
+_ACEOF
+
+#
+# Do we need to use the API??
+# Do we want to link lvm2 with a big library for vdoformating ?
+#
+#AC_ARG_WITH(vdo-include,
+#	    AC_HELP_STRING([--with-vdo-include=PATH],
+#			   [vdo support: Path to utils headers: [/usr/include/vdo/utils]]),
+#			   VDO_INCLUDE=$withval, VDO_INCLUDE="/usr/include/vdo/utils")
+#AC_MSG_RESULT($VDO_INCLUDE)
+#
+#AC_ARG_WITH(vdo-lib,
+#            AC_HELP_STRING([--with-vdo-lib=PATH],
+#                           [vdo support: Path to utils lib: [/usr/lib]]),
+#                           VDO_LIB=$withval, VDO_LIB="/usr/lib")
+#AC_MSG_RESULT($VDO_LIB)
 
 ################################################################################
 # Check whether --enable-readline was given.
@@ -15043,6 +15210,11 @@ if test -n "$CACHE_CHECK_VERSION_WARN"; then :
 $as_echo "$as_me: WARNING: You should install latest cache_check vsn 0.7.0 to use lvm2 cache metadata format 2" >&2;}
 fi
 
+if test -n "$VDO_CONFIGURE_WARN"; then :
+  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: unrecognized 'vdoformat' tool is REQUIRED for VDO logical volume creation!" >&5
+$as_echo "$as_me: WARNING: unrecognized 'vdoformat' tool is REQUIRED for VDO logical volume creation!" >&2;}
+fi
+
 
 if test "$ODIRECT" != yes; then :
   { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&5
diff --git a/configure.ac b/configure.ac
index 21ff52c..ab0c770 100644
--- a/configure.ac
+++ b/configure.ac
@@ -592,6 +592,53 @@ AC_DEFINE_UNQUOTED([CACHE_REPAIR_CMD], ["$CACHE_REPAIR_CMD"],
 AC_DEFINE_UNQUOTED([CACHE_RESTORE_CMD], ["$CACHE_RESTORE_CMD"],
 		   [The path to 'cache_restore', if available.])
 
+################################################################################
+dnl -- cache inclusion type
+AC_MSG_CHECKING(whether to include vdo)
+AC_ARG_WITH(vdo,
+	    AC_HELP_STRING([--with-vdo=TYPE],
+			   [vdo support: internal/none [internal]]),
+			   VDO=$withval, VDO="none")
+
+AC_MSG_RESULT($VDO)
+
+AC_ARG_WITH(vdo-format,
+	    AC_HELP_STRING([--with-vdo-format=PATH],
+			   [vdoformat tool: [autodetect]]),
+			   VDO_FORMAT_CMD=$withval, VDO_FORMAT_CMD="autodetect")
+case "$VDO" in
+ none) ;;
+ internal) 
+	AC_DEFINE([VDO_INTERNAL], 1, [Define to 1 to include built-in support for vdo.])
+	if test "$VDO_FORMAT_CMD" = "autodetect"; then
+		AC_PATH_TOOL(VDO_FORMAT_CMD, vdoformat, [], [$PATH])
+		if test -z "$VDO_FORMAT_CMD"; then
+			AC_MSG_WARN([vdoformat not found in path $PATH])
+			VDO_FORMAT_CMD=/usr/bin/vdoformat
+			VDO_CONFIGURE_WARN=y
+		fi
+	fi
+	;;
+ *) AC_MSG_ERROR([--with-vdo parameter invalid]) ;;
+esac
+
+AC_DEFINE_UNQUOTED([VDO_FORMAT_CMD], ["$VDO_FORMAT_CMD"],
+		   [The path to 'vdoformat', if available.])
+#
+# Do we need to use the API??
+# Do we want to link lvm2 with a big library for vdoformating ?
+#
+#AC_ARG_WITH(vdo-include,
+#	    AC_HELP_STRING([--with-vdo-include=PATH],
+#			   [vdo support: Path to utils headers: [/usr/include/vdo/utils]]),
+#			   VDO_INCLUDE=$withval, VDO_INCLUDE="/usr/include/vdo/utils")
+#AC_MSG_RESULT($VDO_INCLUDE)
+#
+#AC_ARG_WITH(vdo-lib,
+#            AC_HELP_STRING([--with-vdo-lib=PATH],
+#                           [vdo support: Path to utils lib: [/usr/lib]]),
+#                           VDO_LIB=$withval, VDO_LIB="/usr/lib") 
+#AC_MSG_RESULT($VDO_LIB)
 
 ################################################################################
 dnl -- Disable readline
@@ -1739,6 +1786,10 @@ AC_SUBST(USE_TRACKING)
 AC_SUBST(SILENT_RULES)
 AC_SUBST(USRSBINDIR)
 AC_SUBST(VALGRIND_POOL)
+AC_SUBST(VDO)
+AC_SUBST(VDO_FORMAT_CMD)
+AC_SUBST(VDO_INCLUDE)
+AC_SUBST(VDO_LIB)
 AC_SUBST(WRITE_INSTALL)
 AC_SUBST(DMEVENTD_PIDFILE)
 AC_SUBST(LVMETAD_PIDFILE)
@@ -1840,6 +1891,9 @@ AS_IF([test -n "$CACHE_CONFIGURE_WARN"],
 AS_IF([test -n "$CACHE_CHECK_VERSION_WARN"],
       [AC_MSG_WARN([You should install latest cache_check vsn 0.7.0 to use lvm2 cache metadata format 2])])
 
+AS_IF([test -n "$VDO_CONFIGURE_WARN"],
+      [AC_MSG_WARN([unrecognized 'vdoformat' tool is REQUIRED for VDO logical volume creation!])])
+
 
 AS_IF([test "$ODIRECT" != yes],
       [AC_MSG_WARN([O_DIRECT disabled: low-memory pvmove may lock up])])
diff --git a/device_mapper/Makefile b/device_mapper/Makefile
index 0a06a8b..30717b6 100644
--- a/device_mapper/Makefile
+++ b/device_mapper/Makefile
@@ -30,6 +30,9 @@ DEVICE_MAPPER_DEPENDS=$(addprefix $(top_builddir)/,$(subst .c,.d,$(DEVICE_MAPPER
 DEVICE_MAPPER_OBJECTS=$(addprefix $(top_builddir)/,$(subst .c,.o,$(DEVICE_MAPPER_SOURCE)))
 CLEAN_TARGETS+=$(DEVICE_MAPPER_DEPENDS) $(DEVICE_MAPPER_OBJECTS)
 
+#$(DEVICE_MAPPER_DEPENDS): INCLUDES+=$(VDO_INCLUDES)
+#$(DEVICE_MAPPER_OBJECTS): INCLUDES+=$(VDO_INCLUDES)
+
 ifeq ("$(USE_TRACKING)","yes")
 ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov \
  help check check_local check_cluster check_lvmetad check_lvmpolld))
diff --git a/include/configure.h.in b/include/configure.h.in
index 50e35f7..f68b092 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -672,6 +672,12 @@
 /* Enable a valgrind aware build of pool */
 #undef VALGRIND_POOL
 
+/* The path to 'vdoformat', if available. */
+#undef VDO_FORMAT_CMD
+
+/* Define to 1 to include built-in support for vdo. */
+#undef VDO_INTERNAL
+
 /* Define for Solaris 2.5.1 so the uint32_t typedef from <sys/synch.h>,
    <pthread.h>, or <semaphore.h> is not used. If the typedef were allowed, the
    #define below would cause a syntax error. */
diff --git a/make.tmpl.in b/make.tmpl.in
index dcdc093..a6642f2 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -311,6 +311,7 @@ LIB_VERSION_APP := $(shell $(AWK) -F '[(). ]' '{printf "%s.%s",$$1,$$4}' $(top_s
 
 INCLUDES += -I$(top_srcdir) -I$(srcdir) -I$(top_builddir)/include
 
+#VDO_INCLUDES=-I at VDO_INCLUDE@
 
 DEPS = $(top_builddir)/make.tmpl $(top_srcdir)/VERSION \
        $(top_builddir)/Makefile


