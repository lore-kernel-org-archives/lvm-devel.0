From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Apr 2021 07:55:37 +0000 (GMT)
Subject: main - configure: make aio optional
Message-ID: <20210412075537.12A3839FCC4C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=57b5bc9c87ba090e198c9e5ec679ad81db88a093
Commit:        57b5bc9c87ba090e198c9e5ec679ad81db88a093
Parent:        744afec6c06d83049ed9fa3c700db2ccffeb146e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 10 22:09:32 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 12 09:54:15 2021 +0200

configure: make aio optional

Add support for external AIO_CFLAGS and AIO_LIBS so user
can point to his own build - this might be useful when
user wants to use own libaio library.
---
 configure    | 34 ++++++++++++++++++++++++++++++++--
 configure.ac | 15 ++++++++++++---
 make.tmpl.in |  2 ++
 3 files changed, 46 insertions(+), 5 deletions(-)

diff --git a/configure b/configure
index 154862bcc..95c1d2758 100755
--- a/configure
+++ b/configure
@@ -795,6 +795,8 @@ PKGCONFIGINIT_CFLAGS
 PKG_CONFIG_LIBDIR
 PKG_CONFIG_PATH
 PKG_CONFIG
+AIO_LIBS
+AIO_CFLAGS
 VDO_FORMAT_CMD
 CACHE_RESTORE_CMD
 CACHE_REPAIR_CMD
@@ -998,6 +1000,8 @@ CXX
 CXXFLAGS
 CCC
 CPP
+AIO_CFLAGS
+AIO_LIBS
 PKG_CONFIG
 PKG_CONFIG_PATH
 PKG_CONFIG_LIBDIR
@@ -1797,6 +1801,8 @@ Some influential environment variables:
   CXX         C++ compiler command
   CXXFLAGS    C++ compiler flags
   CPP         C preprocessor
+  AIO_CFLAGS  C compiler flags for AIO
+  AIO_LIBS    linker flags for AIO
   PKG_CONFIG  path to pkg-config utility
   PKG_CONFIG_PATH
               directories to add to pkg-config's search path
@@ -6088,7 +6094,7 @@ fi
 
 
 for ac_header in assert.h ctype.h dirent.h errno.h fcntl.h float.h \
-  getopt.h inttypes.h langinfo.h libaio.h libgen.h limits.h locale.h paths.h \
+  getopt.h inttypes.h langinfo.h libgen.h limits.h locale.h paths.h \
   signal.h stdarg.h stddef.h stdio.h stdlib.h string.h sys/file.h \
   sys/ioctl.h syslog.h sys/mman.h sys/param.h sys/resource.h sys/stat.h \
   sys/time.h sys/types.h sys/utsname.h sys/wait.h time.h \
@@ -6121,6 +6127,19 @@ fi
 
 done
 
+for ac_header in libaio.h
+do :
+  ac_fn_c_check_header_mongrel "$LINENO" "libaio.h" "ac_cv_header_libaio_h" "$ac_includes_default"
+if test "x$ac_cv_header_libaio_h" = xyes; then :
+  cat >>confdefs.h <<_ACEOF
+#define HAVE_LIBAIO_H 1
+_ACEOF
+ LVM_NEEDS_LIBAIO_WARN=
+else
+  LVM_NEEDS_LIBAIO_WARN=y
+fi
+
+done
 
 case "$host_os" in
 	linux*)
@@ -9813,6 +9832,14 @@ $as_echo "#define INTEGRITY_INTERNAL 1" >>confdefs.h
  *) as_fn_error $? "--with-integrity parameter invalid" "$LINENO" 5 ;;
 esac
 
+################################################################################
+# Allow users to override default location for libaio
+# there seems to be no pkg-config support available
+AIO_CFLAGS=
+AIO_LIBS=${AIO_LIBS:--laio}
+
+
+
 ################################################################################
 # Check whether --enable-readline was given.
 if test "${enable_readline+set}" = set; then :
@@ -10759,7 +10786,6 @@ cat >>confdefs.h <<_ACEOF
 _ACEOF
 
 
-
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable valgrind awareness of pools" >&5
 $as_echo_n "checking whether to enable valgrind awareness of pools... " >&6; }
@@ -15524,6 +15550,10 @@ if test -n "$VDO_CONFIGURE_WARN"; then :
 $as_echo "$as_me: WARNING: Unrecognized 'vdoformat' tool is REQUIRED for VDO logical volume creation!" >&2;}
 fi
 
+if test -n "$LVM_NEEDS_LIBAIO_WARN"; then :
+  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Only libdm part can be build without libaio:  make [install_]device-mapper" >&5
+$as_echo "$as_me: WARNING: Only libdm part can be build without libaio:  make [install_]device-mapper" >&2;}
+fi
 
 if test "$ODIRECT" != yes; then :
   { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&5
diff --git a/configure.ac b/configure.ac
index 60b9c1043..33a691e01 100644
--- a/configure.ac
+++ b/configure.ac
@@ -101,14 +101,14 @@ AC_HEADER_SYS_WAIT
 AC_HEADER_TIME
 
 AC_CHECK_HEADERS([assert.h ctype.h dirent.h errno.h fcntl.h float.h \
-  getopt.h inttypes.h langinfo.h libaio.h libgen.h limits.h locale.h paths.h \
+  getopt.h inttypes.h langinfo.h libgen.h limits.h locale.h paths.h \
   signal.h stdarg.h stddef.h stdio.h stdlib.h string.h sys/file.h \
   sys/ioctl.h syslog.h sys/mman.h sys/param.h sys/resource.h sys/stat.h \
   sys/time.h sys/types.h sys/utsname.h sys/wait.h time.h \
   unistd.h], , [AC_MSG_ERROR(bailing out)])
 
 AC_CHECK_HEADERS(termios.h sys/statvfs.h sys/timerfd.h sys/vfs.h linux/magic.h linux/fiemap.h)
-
+AC_CHECK_HEADERS(libaio.h,LVM_NEEDS_LIBAIO_WARN=,LVM_NEEDS_LIBAIO_WARN=y)
 case "$host_os" in
 	linux*)
 		AC_CHECK_HEADERS(asm/byteorder.h linux/fs.h malloc.h,,AC_MSG_ERROR(bailing out)) ;;
@@ -684,6 +684,14 @@ case "$INTEGRITY" in
  *) AC_MSG_ERROR([--with-integrity parameter invalid]) ;;
 esac
 
+################################################################################
+# Allow users to override default location for libaio
+# there seems to be no pkg-config support available
+AIO_CFLAGS=
+AIO_LIBS=${AIO_LIBS:--laio}
+AC_ARG_VAR([AIO_CFLAGS], [C compiler flags for AIO])
+AC_ARG_VAR([AIO_LIBS], [linker flags for AIO])
+
 ################################################################################
 dnl -- Disable readline
 AC_ARG_ENABLE([readline],
@@ -881,7 +889,6 @@ TESTSUITE_DATA='${datarootdir}/lvm2-testsuite'
 # double eval needed ${datarootdir} -> ${prefix}/share -> real path
 AC_DEFINE_UNQUOTED(TESTSUITE_DATA, ["$(eval echo $(eval echo $TESTSUITE_DATA))"], [Path to testsuite data])
 
-
 ################################################################################
 dnl -- Enable valgrind awareness of memory pools
 AC_MSG_CHECKING(whether to enable valgrind awareness of pools)
@@ -1977,6 +1984,8 @@ AS_IF([test -n "$CACHE_CHECK_VERSION_WARN"],
 AS_IF([test -n "$VDO_CONFIGURE_WARN"],
       [AC_MSG_WARN([Unrecognized 'vdoformat' tool is REQUIRED for VDO logical volume creation!])])
 
+AS_IF([test -n "$LVM_NEEDS_LIBAIO_WARN"],
+      [AC_MSG_WARN([Only libdm part can be build without libaio:  make [[install_]]device-mapper])])
 
 AS_IF([test "$ODIRECT" != yes],
       [AC_MSG_WARN([O_DIRECT disabled: low-memory pvmove may lock up])])
diff --git a/make.tmpl.in b/make.tmpl.in
index 14557c4c4..73bf298c7 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -76,6 +76,8 @@ LIB_SUFFIX = @LIB_SUFFIX@
 DL_LIBS = @DL_LIBS@
 RT_LIBS = @RT_LIBS@
 M_LIBS = @M_LIBS@
+AIO_LIBS = @AIO_LIBS@
+AIO_CFLAGS = @AIO_CFLAGS@
 PTHREAD_LIBS = @PTHREAD_LIBS@
 READLINE_LIBS = @READLINE_LIBS@
 EDITLINE_LIBS = @EDITLINE_LIBS@


