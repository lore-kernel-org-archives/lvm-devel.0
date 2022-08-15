From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Aug 2022 11:34:15 +0000 (GMT)
Subject: main - autoreconf: support newer archs
Message-ID: <20220815113415.99BFA3858429@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6b2e4ec5dc629c064a4f5472afd283faa233ca32
Commit:        6b2e4ec5dc629c064a4f5472afd283faa233ca32
Parent:        bba96e8680ef7fa567d6361c269c0bfc05ce3d2c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 15 11:22:53 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 15 13:32:55 2022 +0200

autoreconf: support newer archs

Update to more recent version of configure script to support more
new architecture types like RISCV64. Tools in use ATM:

autoconf-2.71-3.fc37.noarch
autoconf-archive-2022.02.11-3.fc37.noarch
automake-1.16.5-9.fc37.noarch

Resolves https://bugzilla.redhat.com/show_bug.cgi?id=2118243
---
 WHATS_NEW              |    1 +
 aclocal.m4             |  272 +-
 autoconf/config.guess  | 1712 +++++----
 autoconf/config.sub    | 2635 +++++++------
 autoconf/install-sh    |  564 +--
 configure              | 9963 +++++++++++++++++++++++++++---------------------
 include/configure.h.in |   30 +-
 7 files changed, 8415 insertions(+), 6762 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6a12e848f..6cd53553b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.17 - 
 ===============================
+  Updates configure with recent autoconf tooling.
   Fix lvconvert --test --type vdo-pool execution.
   Add json_std output format for more JSON standard compliant version of output.
   Fix vdo_slab_size_mb value for converted VDO volume.
diff --git a/aclocal.m4 b/aclocal.m4
index 7524c8313..56c51c7a5 100644
--- a/aclocal.m4
+++ b/aclocal.m4
@@ -1,6 +1,6 @@
-# generated automatically by aclocal 1.16.2 -*- Autoconf -*-
+# generated automatically by aclocal 1.16.5 -*- Autoconf -*-
 
-# Copyright (C) 1996-2020 Free Software Foundation, Inc.
+# Copyright (C) 1996-2021 Free Software Foundation, Inc.
 
 # This file is free software; the Free Software Foundation
 # gives unlimited permission to copy and/or distribute it,
@@ -413,7 +413,7 @@ AS_IF([test "$AS_TR_SH([with_]m4_tolower([$1]))" = "yes"],
         [AC_DEFINE([HAVE_][$1], 1, [Enable ]m4_tolower([$1])[ support])])
 ])dnl PKG_HAVE_DEFINE_WITH_MODULES
 
-# Copyright (C) 1999-2020 Free Software Foundation, Inc.
+# Copyright (C) 1999-2021 Free Software Foundation, Inc.
 #
 # This file is free software; the Free Software Foundation
 # gives unlimited permission to copy and/or distribute it,
@@ -492,7 +492,7 @@ AC_DEFUN([AM_PATH_PYTHON],
   ])
 
   if test "$PYTHON" = :; then
-  dnl Run any user-specified action, or abort.
+    dnl Run any user-specified action, or abort.
     m4_default([$3], [AC_MSG_ERROR([no suitable Python interpreter found])])
   else
 
@@ -501,27 +501,132 @@ AC_DEFUN([AM_PATH_PYTHON],
   dnl trailing zero was eliminated. So now we output just the major
   dnl and minor version numbers, as numbers. Apparently the tertiary
   dnl version is not of interest.
-
+  dnl
   AC_CACHE_CHECK([for $am_display_PYTHON version], [am_cv_python_version],
-    [am_cv_python_version=`$PYTHON -c "import sys; print('%u.%u' % sys.version_info[[:2]])"`])
+    [am_cv_python_version=`$PYTHON -c "import sys; print ('%u.%u' % sys.version_info[[:2]])"`])
   AC_SUBST([PYTHON_VERSION], [$am_cv_python_version])
 
-  dnl Use the values of $prefix and $exec_prefix for the corresponding
-  dnl values of PYTHON_PREFIX and PYTHON_EXEC_PREFIX.  These are made
-  dnl distinct variables so they can be overridden if need be.  However,
-  dnl general consensus is that you shouldn't need this ability.
-
-  AC_SUBST([PYTHON_PREFIX], ['${prefix}'])
-  AC_SUBST([PYTHON_EXEC_PREFIX], ['${exec_prefix}'])
-
-  dnl At times (like when building shared libraries) you may want
+  dnl At times, e.g., when building shared libraries, you may want
   dnl to know which OS platform Python thinks this is.
-
+  dnl
   AC_CACHE_CHECK([for $am_display_PYTHON platform], [am_cv_python_platform],
     [am_cv_python_platform=`$PYTHON -c "import sys; sys.stdout.write(sys.platform)"`])
   AC_SUBST([PYTHON_PLATFORM], [$am_cv_python_platform])
 
-  # Just factor out some code duplication.
+  dnl emacs-page
+  dnl If --with-python-sys-prefix is given, use the values of sys.prefix
+  dnl and sys.exec_prefix for the corresponding values of PYTHON_PREFIX
+  dnl and PYTHON_EXEC_PREFIX. Otherwise, use the GNU ${prefix} and
+  dnl ${exec_prefix} variables.
+  dnl
+  dnl The two are made distinct variables so they can be overridden if
+  dnl need be, although general consensus is that you shouldn't need
+  dnl this separation.
+  dnl
+  dnl Also allow directly setting the prefixes via configure options,
+  dnl overriding any default.
+  dnl
+  if test "x$prefix" = xNONE; then
+    am__usable_prefix=$ac_default_prefix
+  else
+    am__usable_prefix=$prefix
+  fi
+
+  # Allow user to request using sys.* values from Python,
+  # instead of the GNU $prefix values.
+  AC_ARG_WITH([python-sys-prefix],
+  [AS_HELP_STRING([--with-python-sys-prefix],
+                  [use Python's sys.prefix and sys.exec_prefix values])],
+  [am_use_python_sys=:],
+  [am_use_python_sys=false])
+
+  # Allow user to override whatever the default Python prefix is.
+  AC_ARG_WITH([python_prefix],
+  [AS_HELP_STRING([--with-python_prefix],
+                  [override the default PYTHON_PREFIX])],
+  [am_python_prefix_subst=$withval
+   am_cv_python_prefix=$withval
+   AC_MSG_CHECKING([for explicit $am_display_PYTHON prefix])
+   AC_MSG_RESULT([$am_cv_python_prefix])],
+  [
+   if $am_use_python_sys; then
+     # using python sys.prefix value, not GNU
+     AC_CACHE_CHECK([for python default $am_display_PYTHON prefix],
+     [am_cv_python_prefix],
+     [am_cv_python_prefix=`$PYTHON -c "import sys; sys.stdout.write(sys.prefix)"`])
+
+     dnl If sys.prefix is a subdir of $prefix, replace the literal value of
+     dnl $prefix with a variable reference so it can be overridden.
+     case $am_cv_python_prefix in
+     $am__usable_prefix*)
+       am__strip_prefix=`echo "$am__usable_prefix" | sed 's|.|.|g'`
+       am_python_prefix_subst=`echo "$am_cv_python_prefix" | sed "s,^$am__strip_prefix,\\${prefix},"`
+       ;;
+     *)
+       am_python_prefix_subst=$am_cv_python_prefix
+       ;;
+     esac
+   else # using GNU prefix value, not python sys.prefix
+     am_python_prefix_subst='${prefix}'
+     am_python_prefix=$am_python_prefix_subst
+     AC_MSG_CHECKING([for GNU default $am_display_PYTHON prefix])
+     AC_MSG_RESULT([$am_python_prefix])
+   fi])
+  # Substituting python_prefix_subst value.
+  AC_SUBST([PYTHON_PREFIX], [$am_python_prefix_subst])
+
+  # emacs-page Now do it all over again for Python exec_prefix, but with yet
+  # another conditional: fall back to regular prefix if that was specified.
+  AC_ARG_WITH([python_exec_prefix],
+  [AS_HELP_STRING([--with-python_exec_prefix],
+                  [override the default PYTHON_EXEC_PREFIX])],
+  [am_python_exec_prefix_subst=$withval
+   am_cv_python_exec_prefix=$withval
+   AC_MSG_CHECKING([for explicit $am_display_PYTHON exec_prefix])
+   AC_MSG_RESULT([$am_cv_python_exec_prefix])],
+  [
+   # no explicit --with-python_exec_prefix, but if
+   # --with-python_prefix was given, use its value for python_exec_prefix too.
+   AS_IF([test -n "$with_python_prefix"],
+   [am_python_exec_prefix_subst=$with_python_prefix
+    am_cv_python_exec_prefix=$with_python_prefix
+    AC_MSG_CHECKING([for python_prefix-given $am_display_PYTHON exec_prefix])
+    AC_MSG_RESULT([$am_cv_python_exec_prefix])],
+   [
+    # Set am__usable_exec_prefix whether using GNU or Python values,
+    # since we use that variable for pyexecdir.
+    if test "x$exec_prefix" = xNONE; then
+      am__usable_exec_prefix=$am__usable_prefix
+    else
+      am__usable_exec_prefix=$exec_prefix
+    fi
+    #
+    if $am_use_python_sys; then # using python sys.exec_prefix, not GNU
+      AC_CACHE_CHECK([for python default $am_display_PYTHON exec_prefix],
+      [am_cv_python_exec_prefix],
+      [am_cv_python_exec_prefix=`$PYTHON -c "import sys; sys.stdout.write(sys.exec_prefix)"`])
+      dnl If sys.exec_prefix is a subdir of $exec_prefix, replace the
+      dnl literal value of $exec_prefix with a variable reference so it can
+      dnl be overridden.
+      case $am_cv_python_exec_prefix in
+      $am__usable_exec_prefix*)
+        am__strip_prefix=`echo "$am__usable_exec_prefix" | sed 's|.|.|g'`
+        am_python_exec_prefix_subst=`echo "$am_cv_python_exec_prefix" | sed "s,^$am__strip_prefix,\\${exec_prefix},"`
+        ;;
+      *)
+        am_python_exec_prefix_subst=$am_cv_python_exec_prefix
+        ;;
+     esac
+   else # using GNU $exec_prefix, not python sys.exec_prefix
+     am_python_exec_prefix_subst='${exec_prefix}'
+     am_python_exec_prefix=$am_python_exec_prefix_subst
+     AC_MSG_CHECKING([for GNU default $am_display_PYTHON exec_prefix])
+     AC_MSG_RESULT([$am_python_exec_prefix])
+   fi])])
+  # Substituting python_exec_prefix_subst.
+  AC_SUBST([PYTHON_EXEC_PREFIX], [$am_python_exec_prefix_subst])
+
+  # Factor out some code duplication into this shell variable.
   am_python_setup_sysconfig="\
 import sys
 # Prefer sysconfig over distutils.sysconfig, for better compatibility
@@ -541,96 +646,95 @@ try:
 except ImportError:
     pass"
 
-  dnl Set up 4 directories:
+  dnl emacs-page Set up 4 directories:
 
-  dnl pythondir -- where to install python scripts.  This is the
-  dnl   site-packages directory, not the python standard library
-  dnl   directory like in previous automake betas.  This behavior
-  dnl   is more consistent with lispdir.m4 for example.
+  dnl 1. pythondir: where to install python scripts.  This is the
+  dnl    site-packages directory, not the python standard library
+  dnl    directory like in previous automake betas.  This behavior
+  dnl    is more consistent with lispdir.m4 for example.
   dnl Query distutils for this directory.
-  AC_CACHE_CHECK([for $am_display_PYTHON script directory],
-    [am_cv_python_pythondir],
-    [if test "x$prefix" = xNONE
-     then
-       am_py_prefix=$ac_default_prefix
-     else
-       am_py_prefix=$prefix
-     fi
-     am_cv_python_pythondir=`$PYTHON -c "
+  dnl
+  AC_CACHE_CHECK([for $am_display_PYTHON script directory (pythondir)],
+  [am_cv_python_pythondir],
+  [if test "x$am_cv_python_prefix" = x; then
+     am_py_prefix=$am__usable_prefix
+   else
+     am_py_prefix=$am_cv_python_prefix
+   fi
+   am_cv_python_pythondir=`$PYTHON -c "
 $am_python_setup_sysconfig
 if can_use_sysconfig:
-    sitedir = sysconfig.get_path('purelib', vars={'base':'$am_py_prefix'})
+  sitedir = sysconfig.get_path('purelib', vars={'base':'$am_py_prefix'})
 else:
-    from distutils import sysconfig
-    sitedir = sysconfig.get_python_lib(0, 0, prefix='$am_py_prefix')
+  from distutils import sysconfig
+  sitedir = sysconfig.get_python_lib(0, 0, prefix='$am_py_prefix')
 sys.stdout.write(sitedir)"`
-     case $am_cv_python_pythondir in
-     $am_py_prefix*)
-       am__strip_prefix=`echo "$am_py_prefix" | sed 's|.|.|g'`
-       am_cv_python_pythondir=`echo "$am_cv_python_pythondir" | sed "s,^$am__strip_prefix,$PYTHON_PREFIX,"`
-       ;;
-     *)
-       case $am_py_prefix in
-         /usr|/System*) ;;
-         *)
-	  am_cv_python_pythondir=$PYTHON_PREFIX/lib/python$PYTHON_VERSION/site-packages
-	  ;;
-       esac
-       ;;
+   #
+   case $am_cv_python_pythondir in
+   $am_py_prefix*)
+     am__strip_prefix=`echo "$am_py_prefix" | sed 's|.|.|g'`
+     am_cv_python_pythondir=`echo "$am_cv_python_pythondir" | sed "s,^$am__strip_prefix,\\${PYTHON_PREFIX},"`
+     ;;
+   *)
+     case $am_py_prefix in
+       /usr|/System*) ;;
+       *) am_cv_python_pythondir="\${PYTHON_PREFIX}/lib/python$PYTHON_VERSION/site-packages"
+          ;;
      esac
-    ])
+     ;;
+   esac
+  ])
   AC_SUBST([pythondir], [$am_cv_python_pythondir])
 
-  dnl pkgpythondir -- $PACKAGE directory under pythondir.  Was
-  dnl   PYTHON_SITE_PACKAGE in previous betas, but this naming is
-  dnl   more consistent with the rest of automake.
-
+  dnl 2. pkgpythondir: $PACKAGE directory under pythondir.  Was
+  dnl    PYTHON_SITE_PACKAGE in previous betas, but this naming is
+  dnl    more consistent with the rest of automake.
+  dnl
   AC_SUBST([pkgpythondir], [\${pythondir}/$PACKAGE])
 
-  dnl pyexecdir -- directory for installing python extension modules
-  dnl   (shared libraries)
+  dnl 3. pyexecdir: directory for installing python extension modules
+  dnl    (shared libraries).
   dnl Query distutils for this directory.
-  AC_CACHE_CHECK([for $am_display_PYTHON extension module directory],
-    [am_cv_python_pyexecdir],
-    [if test "x$exec_prefix" = xNONE
-     then
-       am_py_exec_prefix=$am_py_prefix
-     else
-       am_py_exec_prefix=$exec_prefix
-     fi
-     am_cv_python_pyexecdir=`$PYTHON -c "
+  dnl
+  AC_CACHE_CHECK([for $am_display_PYTHON extension module directory (pyexecdir)],
+  [am_cv_python_pyexecdir],
+  [if test "x$am_cv_python_exec_prefix" = x; then
+     am_py_exec_prefix=$am__usable_exec_prefix
+   else
+     am_py_exec_prefix=$am_cv_python_exec_prefix
+   fi
+   am_cv_python_pyexecdir=`$PYTHON -c "
 $am_python_setup_sysconfig
 if can_use_sysconfig:
-    sitedir = sysconfig.get_path('platlib', vars={'platbase':'$am_py_prefix'})
+  sitedir = sysconfig.get_path('platlib', vars={'platbase':'$am_py_exec_prefix'})
 else:
-    from distutils import sysconfig
-    sitedir = sysconfig.get_python_lib(1, 0, prefix='$am_py_prefix')
+  from distutils import sysconfig
+  sitedir = sysconfig.get_python_lib(1, 0, prefix='$am_py_exec_prefix')
 sys.stdout.write(sitedir)"`
-     case $am_cv_python_pyexecdir in
-     $am_py_exec_prefix*)
-       am__strip_prefix=`echo "$am_py_exec_prefix" | sed 's|.|.|g'`
-       am_cv_python_pyexecdir=`echo "$am_cv_python_pyexecdir" | sed "s,^$am__strip_prefix,$PYTHON_EXEC_PREFIX,"`
-       ;;
-     *)
-       case $am_py_exec_prefix in
-         /usr|/System*) ;;
-         *)
-	   am_cv_python_pyexecdir=$PYTHON_EXEC_PREFIX/lib/python$PYTHON_VERSION/site-packages
-	   ;;
-       esac
-       ;;
+   #
+   case $am_cv_python_pyexecdir in
+   $am_py_exec_prefix*)
+     am__strip_prefix=`echo "$am_py_exec_prefix" | sed 's|.|.|g'`
+     am_cv_python_pyexecdir=`echo "$am_cv_python_pyexecdir" | sed "s,^$am__strip_prefix,\\${PYTHON_EXEC_PREFIX},"`
+     ;;
+   *)
+     case $am_py_exec_prefix in
+       /usr|/System*) ;;
+       *) am_cv_python_pyexecdir="\${PYTHON_EXEC_PREFIX}/lib/python$PYTHON_VERSION/site-packages"
+          ;;
      esac
-    ])
+     ;;
+   esac
+  ])
   AC_SUBST([pyexecdir], [$am_cv_python_pyexecdir])
 
-  dnl pkgpyexecdir -- $(pyexecdir)/$(PACKAGE)
-
+  dnl 4. pkgpyexecdir: $(pyexecdir)/$(PACKAGE)
+  dnl
   AC_SUBST([pkgpyexecdir], [\${pyexecdir}/$PACKAGE])
 
   dnl Run any user-specified action.
   $2
   fi
-
 ])
 
 
@@ -653,7 +757,7 @@ for i in list(range(0, 4)): minverhex = (minverhex << 8) + minver[[i]]
 sys.exit(sys.hexversion < minverhex)"
   AS_IF([AM_RUN_LOG([$1 -c "$prog"])], [$3], [$4])])
 
-# Copyright (C) 2001-2020 Free Software Foundation, Inc.
+# Copyright (C) 2001-2021 Free Software Foundation, Inc.
 #
 # This file is free software; the Free Software Foundation
 # gives unlimited permission to copy and/or distribute it,
diff --git a/autoconf/config.guess b/autoconf/config.guess
index 4438cd70f..c7f17e8fb 100755
--- a/autoconf/config.guess
+++ b/autoconf/config.guess
@@ -1,12 +1,14 @@
-#! /bin/sh
+#!/usr/bin/sh
 # Attempt to guess a canonical system name.
-#   Copyright 1992-2014 Free Software Foundation, Inc.
+#   Copyright 1992-2022 Free Software Foundation, Inc.
 
-timestamp='2014-01-01'
+# shellcheck disable=SC2006,SC2268 # see below for rationale
+
+timestamp='2022-05-25'
 
 # This file is free software; you can redistribute it and/or modify it
 # under the terms of the GNU General Public License as published by
-# the Free Software Foundation; either version 3 of the License, or
+# the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 #
 # This program is distributed in the hope that it will be useful, but
@@ -15,7 +17,7 @@ timestamp='2014-01-01'
 # General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
-# along with this program; if not, see <http://www.gnu.org/licenses/>.
+# along with this program; if not, see <https://www.gnu.org/licenses/>.
 #
 # As a special exception to the GNU General Public License, if you
 # distribute this file as part of a program that contains a
@@ -24,12 +26,20 @@ timestamp='2014-01-01'
 # program.  This Exception is an additional permission under section 7
 # of the GNU General Public License, version 3 ("GPLv3").
 #
-# Originally written by Per Bothner.
+# Originally written by Per Bothner; maintained since 2000 by Ben Elliston.
 #
 # You can get the latest version of this script from:
-# http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD
+# https://git.savannah.gnu.org/cgit/config.git/plain/config.guess
 #
-# Please send patches with a ChangeLog entry to config-patches at gnu.org.
+# Please send patches to <config-patches@gnu.org>.
+
+
+# The "shellcheck disable" line above the timestamp inhibits complaints
+# about features and limitations of the classic Bourne shell that were
+# superseded or lifted in POSIX.  However, this script identifies a wide
+# variety of pre-POSIX systems that do not have POSIX shells at all, and
+# even some reasonably current systems (Solaris 10 as case-in-point) still
+# have a pre-POSIX /bin/sh.
 
 
 me=`echo "$0" | sed -e 's,.*/,,'`
@@ -39,7 +49,7 @@ Usage: $0 [OPTION]
 
 Output the configuration name of the system \`$me' is run on.
 
-Operation modes:
+Options:
   -h, --help         print this help, then exit
   -t, --time-stamp   print date of last modification, then exit
   -v, --version      print version number, then exit
@@ -50,7 +60,7 @@ version="\
 GNU config.guess ($timestamp)
 
 Originally written by Per Bothner.
-Copyright 1992-2014 Free Software Foundation, Inc.
+Copyright 1992-2022 Free Software Foundation, Inc.
 
 This is free software; see the source for copying conditions.  There is NO
 warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE."
@@ -84,7 +94,8 @@ if test $# != 0; then
   exit 1
 fi
 
-trap 'exit 1' 1 2 15
+# Just in case it came from the environment.
+GUESS=
 
 # CC_FOR_BUILD -- compiler used by this script. Note that the use of a
 # compiler to aid in system detection is discouraged as it requires
@@ -96,66 +107,90 @@ trap 'exit 1' 1 2 15
 
 # Portable tmp directory creation inspired by the Autoconf team.
 
-set_cc_for_build='
-trap "exitcode=\$?; (rm -f \$tmpfiles 2>/dev/null; rmdir \$tmp 2>/dev/null) && exit \$exitcode" 0 ;
-trap "rm -f \$tmpfiles 2>/dev/null; rmdir \$tmp 2>/dev/null; exit 1" 1 2 13 15 ;
-: ${TMPDIR=/tmp} ;
- { tmp=`(umask 077 && mktemp -d "$TMPDIR/cgXXXXXX") 2>/dev/null` && test -n "$tmp" && test -d "$tmp" ; } ||
- { test -n "$RANDOM" && tmp=$TMPDIR/cg$$-$RANDOM && (umask 077 && mkdir $tmp) ; } ||
- { tmp=$TMPDIR/cg-$$ && (umask 077 && mkdir $tmp) && echo "Warning: creating insecure temp directory" >&2 ; } ||
- { echo "$me: cannot create a temporary directory in $TMPDIR" >&2 ; exit 1 ; } ;
-dummy=$tmp/dummy ;
-tmpfiles="$dummy.c $dummy.o $dummy.rel $dummy" ;
-case $CC_FOR_BUILD,$HOST_CC,$CC in
- ,,)    echo "int x;" > $dummy.c ;
-	for c in cc gcc c89 c99 ; do
-	  if ($c -c -o $dummy.o $dummy.c) >/dev/null 2>&1 ; then
-	     CC_FOR_BUILD="$c"; break ;
-	  fi ;
-	done ;
-	if test x"$CC_FOR_BUILD" = x ; then
-	  CC_FOR_BUILD=no_compiler_found ;
-	fi
-	;;
- ,,*)   CC_FOR_BUILD=$CC ;;
- ,*,*)  CC_FOR_BUILD=$HOST_CC ;;
-esac ; set_cc_for_build= ;'
+tmp=
+# shellcheck disable=SC2172
+trap 'test -z "$tmp" || rm -fr "$tmp"' 0 1 2 13 15
+
+set_cc_for_build() {
+    # prevent multiple calls if $tmp is already set
+    test "$tmp" && return 0
+    : "${TMPDIR=/tmp}"
+    # shellcheck disable=SC2039,SC3028
+    { tmp=`(umask 077 && mktemp -d "$TMPDIR/cgXXXXXX") 2>/dev/null` && test -n "$tmp" && test -d "$tmp" ; } ||
+	{ test -n "$RANDOM" && tmp=$TMPDIR/cg$$-$RANDOM && (umask 077 && mkdir "$tmp" 2>/dev/null) ; } ||
+	{ tmp=$TMPDIR/cg-$$ && (umask 077 && mkdir "$tmp" 2>/dev/null) && echo "Warning: creating insecure temp directory" >&2 ; } ||
+	{ echo "$me: cannot create a temporary directory in $TMPDIR" >&2 ; exit 1 ; }
+    dummy=$tmp/dummy
+    case ${CC_FOR_BUILD-},${HOST_CC-},${CC-} in
+	,,)    echo "int x;" > "$dummy.c"
+	       for driver in cc gcc c89 c99 ; do
+		   if ($driver -c -o "$dummy.o" "$dummy.c") >/dev/null 2>&1 ; then
+		       CC_FOR_BUILD=$driver
+		       break
+		   fi
+	       done
+	       if test x"$CC_FOR_BUILD" = x ; then
+		   CC_FOR_BUILD=no_compiler_found
+	       fi
+	       ;;
+	,,*)   CC_FOR_BUILD=$CC ;;
+	,*,*)  CC_FOR_BUILD=$HOST_CC ;;
+    esac
+}
 
 # This is needed to find uname on a Pyramid OSx when run in the BSD universe.
 # (ghazi at noc.rutgers.edu 1994-08-24)
-if (test -f /.attbin/uname) >/dev/null 2>&1 ; then
+if test -f /.attbin/uname ; then
 	PATH=$PATH:/.attbin ; export PATH
 fi
 
 UNAME_MACHINE=`(uname -m) 2>/dev/null` || UNAME_MACHINE=unknown
 UNAME_RELEASE=`(uname -r) 2>/dev/null` || UNAME_RELEASE=unknown
-UNAME_SYSTEM=`(uname -s) 2>/dev/null`  || UNAME_SYSTEM=unknown
+UNAME_SYSTEM=`(uname -s) 2>/dev/null` || UNAME_SYSTEM=unknown
 UNAME_VERSION=`(uname -v) 2>/dev/null` || UNAME_VERSION=unknown
 
-case "${UNAME_SYSTEM}" in
+case $UNAME_SYSTEM in
 Linux|GNU|GNU/*)
-	# If the system lacks a compiler, then just pick glibc.
-	# We could probably try harder.
-	LIBC=gnu
+	LIBC=unknown
 
-	eval $set_cc_for_build
-	cat <<-EOF > $dummy.c
+	set_cc_for_build
+	cat <<-EOF > "$dummy.c"
 	#include <features.h>
 	#if defined(__UCLIBC__)
 	LIBC=uclibc
 	#elif defined(__dietlibc__)
 	LIBC=dietlibc
-	#else
+	#elif defined(__GLIBC__)
 	LIBC=gnu
+	#else
+	#include <stdarg.h>
+	/* First heuristic to detect musl libc.  */
+	#ifdef __DEFINED_va_list
+	LIBC=musl
+	#endif
 	#endif
 	EOF
-	eval `$CC_FOR_BUILD -E $dummy.c 2>/dev/null | grep '^LIBC'`
+	cc_set_libc=`$CC_FOR_BUILD -E "$dummy.c" 2>/dev/null | grep '^LIBC' | sed 's, ,,g'`
+	eval "$cc_set_libc"
+
+	# Second heuristic to detect musl libc.
+	if [ "$LIBC" = unknown ] &&
+	   command -v ldd >/dev/null &&
+	   ldd --version 2>&1 | grep -q ^musl; then
+		LIBC=musl
+	fi
+
+	# If the system lacks a compiler, then just pick glibc.
+	# We could probably try harder.
+	if [ "$LIBC" = unknown ]; then
+		LIBC=gnu
+	fi
 	;;
 esac
 
 # Note: order is significant - the case branches are not exclusive.
 
-case "${UNAME_MACHINE}:${UNAME_SYSTEM}:${UNAME_RELEASE}:${UNAME_VERSION}" in
+case $UNAME_MACHINE:$UNAME_SYSTEM:$UNAME_RELEASE:$UNAME_VERSION in
     *:NetBSD:*:*)
 	# NetBSD (nbsd) targets should (where applicable) match one or
 	# more of the tuples: *-*-netbsdelf*, *-*-netbsdaout*,
@@ -167,22 +202,32 @@ case "${UNAME_MACHINE}:${UNAME_SYSTEM}:${UNAME_RELEASE}:${UNAME_VERSION}" in
 	#
 	# Note: NetBSD doesn't particularly care about the vendor
 	# portion of the name.  We always set it to "unknown".
-	sysctl="sysctl -n hw.machine_arch"
-	UNAME_MACHINE_ARCH=`(/sbin/$sysctl 2>/dev/null || \
-	    /usr/sbin/$sysctl 2>/dev/null || echo unknown)`
-	case "${UNAME_MACHINE_ARCH}" in
+	UNAME_MACHINE_ARCH=`(uname -p 2>/dev/null || \
+	    /sbin/sysctl -n hw.machine_arch 2>/dev/null || \
+	    /usr/sbin/sysctl -n hw.machine_arch 2>/dev/null || \
+	    echo unknown)`
+	case $UNAME_MACHINE_ARCH in
+	    aarch64eb) machine=aarch64_be-unknown ;;
 	    armeb) machine=armeb-unknown ;;
 	    arm*) machine=arm-unknown ;;
 	    sh3el) machine=shl-unknown ;;
 	    sh3eb) machine=sh-unknown ;;
 	    sh5el) machine=sh5le-unknown ;;
-	    *) machine=${UNAME_MACHINE_ARCH}-unknown ;;
+	    earmv*)
+		arch=`echo "$UNAME_MACHINE_ARCH" | sed -e 's,^e\(armv[0-9]\).*$,\1,'`
+		endian=`echo "$UNAME_MACHINE_ARCH" | sed -ne 's,^.*\(eb\)$,\1,p'`
+		machine=${arch}${endian}-unknown
+		;;
+	    *) machine=$UNAME_MACHINE_ARCH-unknown ;;
 	esac
 	# The Operating System including object format, if it has switched
-	# to ELF recently, or will in the future.
-	case "${UNAME_MACHINE_ARCH}" in
+	# to ELF recently (or will in the future) and ABI.
+	case $UNAME_MACHINE_ARCH in
+	    earm*)
+		os=netbsdelf
+		;;
 	    arm*|i386|m68k|ns32k|sh3*|sparc|vax)
-		eval $set_cc_for_build
+		set_cc_for_build
 		if echo __ELF__ | $CC_FOR_BUILD -E - 2>/dev/null \
 			| grep -q __ELF__
 		then
@@ -197,45 +242,80 @@ case "${UNAME_MACHINE}:${UNAME_SYSTEM}:${UNAME_RELEASE}:${UNAME_VERSION}" in
 		os=netbsd
 		;;
 	esac
+	# Determine ABI tags.
+	case $UNAME_MACHINE_ARCH in
+	    earm*)
+		expr='s/^earmv[0-9]/-eabi/;s/eb$//'
+		abi=`echo "$UNAME_MACHINE_ARCH" | sed -e "$expr"`
+		;;
+	esac
 	# The OS release
 	# Debian GNU/NetBSD machines have a different userland, and
 	# thus, need a distinct triplet. However, they do not need
 	# kernel version information, so it can be replaced with a
 	# suitable tag, in the style of linux-gnu.
-	case "${UNAME_VERSION}" in
+	case $UNAME_VERSION in
 	    Debian*)
 		release='-gnu'
 		;;
 	    *)
-		release=`echo ${UNAME_RELEASE}|sed -e 's/[-_].*/\./'`
+		release=`echo "$UNAME_RELEASE" | sed -e 's/[-_].*//' | cut -d. -f1,2`
 		;;
 	esac
 	# Since CPU_TYPE-MANUFACTURER-KERNEL-OPERATING_SYSTEM:
 	# contains redundant information, the shorter form:
 	# CPU_TYPE-MANUFACTURER-OPERATING_SYSTEM is used.
-	echo "${machine}-${os}${release}"
-	exit ;;
+	GUESS=$machine-${os}${release}${abi-}
+	;;
     *:Bitrig:*:*)
 	UNAME_MACHINE_ARCH=`arch | sed 's/Bitrig.//'`
-	echo ${UNAME_MACHINE_ARCH}-unknown-bitrig${UNAME_RELEASE}
-	exit ;;
+	GUESS=$UNAME_MACHINE_ARCH-unknown-bitrig$UNAME_RELEASE
+	;;
     *:OpenBSD:*:*)
 	UNAME_MACHINE_ARCH=`arch | sed 's/OpenBSD.//'`
-	echo ${UNAME_MACHINE_ARCH}-unknown-openbsd${UNAME_RELEASE}
-	exit ;;
+	GUESS=$UNAME_MACHINE_ARCH-unknown-openbsd$UNAME_RELEASE
+	;;
+    *:SecBSD:*:*)
+	UNAME_MACHINE_ARCH=`arch | sed 's/SecBSD.//'`
+	GUESS=$UNAME_MACHINE_ARCH-unknown-secbsd$UNAME_RELEASE
+	;;
+    *:LibertyBSD:*:*)
+	UNAME_MACHINE_ARCH=`arch | sed 's/^.*BSD\.//'`
+	GUESS=$UNAME_MACHINE_ARCH-unknown-libertybsd$UNAME_RELEASE
+	;;
+    *:MidnightBSD:*:*)
+	GUESS=$UNAME_MACHINE-unknown-midnightbsd$UNAME_RELEASE
+	;;
     *:ekkoBSD:*:*)
-	echo ${UNAME_MACHINE}-unknown-ekkobsd${UNAME_RELEASE}
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-ekkobsd$UNAME_RELEASE
+	;;
     *:SolidBSD:*:*)
-	echo ${UNAME_MACHINE}-unknown-solidbsd${UNAME_RELEASE}
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-solidbsd$UNAME_RELEASE
+	;;
+    *:OS108:*:*)
+	GUESS=$UNAME_MACHINE-unknown-os108_$UNAME_RELEASE
+	;;
     macppc:MirBSD:*:*)
-	echo powerpc-unknown-mirbsd${UNAME_RELEASE}
-	exit ;;
+	GUESS=powerpc-unknown-mirbsd$UNAME_RELEASE
+	;;
     *:MirBSD:*:*)
-	echo ${UNAME_MACHINE}-unknown-mirbsd${UNAME_RELEASE}
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-mirbsd$UNAME_RELEASE
+	;;
+    *:Sortix:*:*)
+	GUESS=$UNAME_MACHINE-unknown-sortix
+	;;
+    *:Twizzler:*:*)
+	GUESS=$UNAME_MACHINE-unknown-twizzler
+	;;
+    *:Redox:*:*)
+	GUESS=$UNAME_MACHINE-unknown-redox
+	;;
+    mips:OSF1:*.*)
+	GUESS=mips-dec-osf1
+	;;
     alpha:OSF1:*:*)
+	# Reset EXIT trap before exiting to avoid spurious non-zero exit code.
+	trap '' 0
 	case $UNAME_RELEASE in
 	*4.0)
 		UNAME_RELEASE=`/usr/sbin/sizer -v | awk '{print $3}'`
@@ -249,163 +329,158 @@ case "${UNAME_MACHINE}:${UNAME_SYSTEM}:${UNAME_RELEASE}:${UNAME_VERSION}" in
 	# covers most systems running today.  This code pipes the CPU
 	# types through head -n 1, so we only detect the type of CPU 0.
 	ALPHA_CPU_TYPE=`/usr/sbin/psrinfo -v | sed -n -e 's/^  The alpha \(.*\) processor.*$/\1/p' | head -n 1`
-	case "$ALPHA_CPU_TYPE" in
+	case $ALPHA_CPU_TYPE in
 	    "EV4 (21064)")
-		UNAME_MACHINE="alpha" ;;
+		UNAME_MACHINE=alpha ;;
 	    "EV4.5 (21064)")
-		UNAME_MACHINE="alpha" ;;
+		UNAME_MACHINE=alpha ;;
 	    "LCA4 (21066/21068)")
-		UNAME_MACHINE="alpha" ;;
+		UNAME_MACHINE=alpha ;;
 	    "EV5 (21164)")
-		UNAME_MACHINE="alphaev5" ;;
+		UNAME_MACHINE=alphaev5 ;;
 	    "EV5.6 (21164A)")
-		UNAME_MACHINE="alphaev56" ;;
+		UNAME_MACHINE=alphaev56 ;;
 	    "EV5.6 (21164PC)")
-		UNAME_MACHINE="alphapca56" ;;
+		UNAME_MACHINE=alphapca56 ;;
 	    "EV5.7 (21164PC)")
-		UNAME_MACHINE="alphapca57" ;;
+		UNAME_MACHINE=alphapca57 ;;
 	    "EV6 (21264)")
-		UNAME_MACHINE="alphaev6" ;;
+		UNAME_MACHINE=alphaev6 ;;
 	    "EV6.7 (21264A)")
-		UNAME_MACHINE="alphaev67" ;;
+		UNAME_MACHINE=alphaev67 ;;
 	    "EV6.8CB (21264C)")
-		UNAME_MACHINE="alphaev68" ;;
+		UNAME_MACHINE=alphaev68 ;;
 	    "EV6.8AL (21264B)")
-		UNAME_MACHINE="alphaev68" ;;
+		UNAME_MACHINE=alphaev68 ;;
 	    "EV6.8CX (21264D)")
-		UNAME_MACHINE="alphaev68" ;;
+		UNAME_MACHINE=alphaev68 ;;
 	    "EV6.9A (21264/EV69A)")
-		UNAME_MACHINE="alphaev69" ;;
+		UNAME_MACHINE=alphaev69 ;;
 	    "EV7 (21364)")
-		UNAME_MACHINE="alphaev7" ;;
+		UNAME_MACHINE=alphaev7 ;;
 	    "EV7.9 (21364A)")
-		UNAME_MACHINE="alphaev79" ;;
+		UNAME_MACHINE=alphaev79 ;;
 	esac
 	# A Pn.n version is a patched version.
 	# A Vn.n version is a released version.
 	# A Tn.n version is a released field test version.
 	# A Xn.n version is an unreleased experimental baselevel.
 	# 1.2 uses "1.2" for uname -r.
-	echo ${UNAME_MACHINE}-dec-osf`echo ${UNAME_RELEASE} | sed -e 's/^[PVTX]//' | tr 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' 'abcdefghijklmnopqrstuvwxyz'`
-	# Reset EXIT trap before exiting to avoid spurious non-zero exit code.
-	exitcode=$?
-	trap '' 0
-	exit $exitcode ;;
-    Alpha\ *:Windows_NT*:*)
-	# How do we know it's Interix rather than the generic POSIX subsystem?
-	# Should we change UNAME_MACHINE based on the output of uname instead
-	# of the specific Alpha model?
-	echo alpha-pc-interix
-	exit ;;
-    21064:Windows_NT:50:3)
-	echo alpha-dec-winnt3.5
-	exit ;;
+	OSF_REL=`echo "$UNAME_RELEASE" | sed -e 's/^[PVTX]//' | tr ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz`
+	GUESS=$UNAME_MACHINE-dec-osf$OSF_REL
+	;;
     Amiga*:UNIX_System_V:4.0:*)
-	echo m68k-unknown-sysv4
-	exit ;;
+	GUESS=m68k-unknown-sysv4
+	;;
     *:[Aa]miga[Oo][Ss]:*:*)
-	echo ${UNAME_MACHINE}-unknown-amigaos
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-amigaos
+	;;
     *:[Mm]orph[Oo][Ss]:*:*)
-	echo ${UNAME_MACHINE}-unknown-morphos
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-morphos
+	;;
     *:OS/390:*:*)
-	echo i370-ibm-openedition
-	exit ;;
+	GUESS=i370-ibm-openedition
+	;;
     *:z/VM:*:*)
-	echo s390-ibm-zvmoe
-	exit ;;
+	GUESS=s390-ibm-zvmoe
+	;;
     *:OS400:*:*)
-	echo powerpc-ibm-os400
-	exit ;;
+	GUESS=powerpc-ibm-os400
+	;;
     arm:RISC*:1.[012]*:*|arm:riscix:1.[012]*:*)
-	echo arm-acorn-riscix${UNAME_RELEASE}
-	exit ;;
+	GUESS=arm-acorn-riscix$UNAME_RELEASE
+	;;
     arm*:riscos:*:*|arm*:RISCOS:*:*)
-	echo arm-unknown-riscos
-	exit ;;
+	GUESS=arm-unknown-riscos
+	;;
     SR2?01:HI-UX/MPP:*:* | SR8000:HI-UX/MPP:*:*)
-	echo hppa1.1-hitachi-hiuxmpp
-	exit ;;
+	GUESS=hppa1.1-hitachi-hiuxmpp
+	;;
     Pyramid*:OSx*:*:* | MIS*:OSx*:*:* | MIS*:SMP_DC-OSx*:*:*)
 	# akee at wpdis03.wpafb.af.mil (Earle F. Ake) contributed MIS and NILE.
-	if test "`(/bin/universe) 2>/dev/null`" = att ; then
-		echo pyramid-pyramid-sysv3
-	else
-		echo pyramid-pyramid-bsd
-	fi
-	exit ;;
+	case `(/bin/universe) 2>/dev/null` in
+	    att) GUESS=pyramid-pyramid-sysv3 ;;
+	    *)   GUESS=pyramid-pyramid-bsd   ;;
+	esac
+	;;
     NILE*:*:*:dcosx)
-	echo pyramid-pyramid-svr4
-	exit ;;
+	GUESS=pyramid-pyramid-svr4
+	;;
     DRS?6000:unix:4.0:6*)
-	echo sparc-icl-nx6
-	exit ;;
+	GUESS=sparc-icl-nx6
+	;;
     DRS?6000:UNIX_SV:4.2*:7* | DRS?6000:isis:4.2*:7*)
 	case `/usr/bin/uname -p` in
-	    sparc) echo sparc-icl-nx7; exit ;;
-	esac ;;
+	    sparc) GUESS=sparc-icl-nx7 ;;
+	esac
+	;;
     s390x:SunOS:*:*)
-	echo ${UNAME_MACHINE}-ibm-solaris2`echo ${UNAME_RELEASE}|sed -e 's/[^.]*//'`
-	exit ;;
+	SUN_REL=`echo "$UNAME_RELEASE" | sed -e 's/[^.]*//'`
+	GUESS=$UNAME_MACHINE-ibm-solaris2$SUN_REL
+	;;
     sun4H:SunOS:5.*:*)
-	echo sparc-hal-solaris2`echo ${UNAME_RELEASE}|sed -e 's/[^.]*//'`
-	exit ;;
+	SUN_REL=`echo "$UNAME_RELEASE" | sed -e 's/[^.]*//'`
+	GUESS=sparc-hal-solaris2$SUN_REL
+	;;
     sun4*:SunOS:5.*:* | tadpole*:SunOS:5.*:*)
-	echo sparc-sun-solaris2`echo ${UNAME_RELEASE}|sed -e 's/[^.]*//'`
-	exit ;;
+	SUN_REL=`echo "$UNAME_RELEASE" | sed -e 's/[^.]*//'`
+	GUESS=sparc-sun-solaris2$SUN_REL
+	;;
     i86pc:AuroraUX:5.*:* | i86xen:AuroraUX:5.*:*)
-	echo i386-pc-auroraux${UNAME_RELEASE}
-	exit ;;
+	GUESS=i386-pc-auroraux$UNAME_RELEASE
+	;;
     i86pc:SunOS:5.*:* | i86xen:SunOS:5.*:*)
-	eval $set_cc_for_build
-	SUN_ARCH="i386"
+	set_cc_for_build
+	SUN_ARCH=i386
 	# If there is a compiler, see if it is configured for 64-bit objects.
 	# Note that the Sun cc does not turn __LP64__ into 1 like gcc does.
 	# This test works for both compilers.
-	if [ "$CC_FOR_BUILD" != 'no_compiler_found' ]; then
+	if test "$CC_FOR_BUILD" != no_compiler_found; then
 	    if (echo '#ifdef __amd64'; echo IS_64BIT_ARCH; echo '#endif') | \
-		(CCOPTS= $CC_FOR_BUILD -E - 2>/dev/null) | \
+		(CCOPTS="" $CC_FOR_BUILD -m64 -E - 2>/dev/null) | \
 		grep IS_64BIT_ARCH >/dev/null
 	    then
-		SUN_ARCH="x86_64"
+		SUN_ARCH=x86_64
 	    fi
 	fi
-	echo ${SUN_ARCH}-pc-solaris2`echo ${UNAME_RELEASE}|sed -e 's/[^.]*//'`
-	exit ;;
+	SUN_REL=`echo "$UNAME_RELEASE" | sed -e 's/[^.]*//'`
+	GUESS=$SUN_ARCH-pc-solaris2$SUN_REL
+	;;
     sun4*:SunOS:6*:*)
 	# According to config.sub, this is the proper way to canonicalize
 	# SunOS6.  Hard to guess exactly what SunOS6 will be like, but
 	# it's likely to be more like Solaris than SunOS4.
-	echo sparc-sun-solaris3`echo ${UNAME_RELEASE}|sed -e 's/[^.]*//'`
-	exit ;;
+	SUN_REL=`echo "$UNAME_RELEASE" | sed -e 's/[^.]*//'`
+	GUESS=sparc-sun-solaris3$SUN_REL
+	;;
     sun4*:SunOS:*:*)
-	case "`/usr/bin/arch -k`" in
+	case `/usr/bin/arch -k` in
 	    Series*|S4*)
 		UNAME_RELEASE=`uname -v`
 		;;
 	esac
 	# Japanese Language versions have a version number like `4.1.3-JL'.
-	echo sparc-sun-sunos`echo ${UNAME_RELEASE}|sed -e 's/-/_/'`
-	exit ;;
+	SUN_REL=`echo "$UNAME_RELEASE" | sed -e 's/-/_/'`
+	GUESS=sparc-sun-sunos$SUN_REL
+	;;
     sun3*:SunOS:*:*)
-	echo m68k-sun-sunos${UNAME_RELEASE}
-	exit ;;
+	GUESS=m68k-sun-sunos$UNAME_RELEASE
+	;;
     sun*:*:4.2BSD:*)
 	UNAME_RELEASE=`(sed 1q /etc/motd | awk '{print substr($5,1,3)}') 2>/dev/null`
-	test "x${UNAME_RELEASE}" = "x" && UNAME_RELEASE=3
-	case "`/bin/arch`" in
+	test "x$UNAME_RELEASE" = x && UNAME_RELEASE=3
+	case `/bin/arch` in
 	    sun3)
-		echo m68k-sun-sunos${UNAME_RELEASE}
+		GUESS=m68k-sun-sunos$UNAME_RELEASE
 		;;
 	    sun4)
-		echo sparc-sun-sunos${UNAME_RELEASE}
+		GUESS=sparc-sun-sunos$UNAME_RELEASE
 		;;
 	esac
-	exit ;;
+	;;
     aushp:SunOS:*:*)
-	echo sparc-auspex-sunos${UNAME_RELEASE}
-	exit ;;
+	GUESS=sparc-auspex-sunos$UNAME_RELEASE
+	;;
     # The situation for MiNT is a little confusing.  The machine name
     # can be virtually everything (everything which is not
     # "atarist" or "atariste" at least should have a processor
@@ -415,44 +490,44 @@ case "${UNAME_MACHINE}:${UNAME_SYSTEM}:${UNAME_RELEASE}:${UNAME_VERSION}" in
     # MiNT.  But MiNT is downward compatible to TOS, so this should
     # be no problem.
     atarist[e]:*MiNT:*:* | atarist[e]:*mint:*:* | atarist[e]:*TOS:*:*)
-	echo m68k-atari-mint${UNAME_RELEASE}
-	exit ;;
+	GUESS=m68k-atari-mint$UNAME_RELEASE
+	;;
     atari*:*MiNT:*:* | atari*:*mint:*:* | atarist[e]:*TOS:*:*)
-	echo m68k-atari-mint${UNAME_RELEASE}
-	exit ;;
+	GUESS=m68k-atari-mint$UNAME_RELEASE
+	;;
     *falcon*:*MiNT:*:* | *falcon*:*mint:*:* | *falcon*:*TOS:*:*)
-	echo m68k-atari-mint${UNAME_RELEASE}
-	exit ;;
+	GUESS=m68k-atari-mint$UNAME_RELEASE
+	;;
     milan*:*MiNT:*:* | milan*:*mint:*:* | *milan*:*TOS:*:*)
-	echo m68k-milan-mint${UNAME_RELEASE}
-	exit ;;
+	GUESS=m68k-milan-mint$UNAME_RELEASE
+	;;
     hades*:*MiNT:*:* | hades*:*mint:*:* | *hades*:*TOS:*:*)
-	echo m68k-hades-mint${UNAME_RELEASE}
-	exit ;;
+	GUESS=m68k-hades-mint$UNAME_RELEASE
+	;;
     *:*MiNT:*:* | *:*mint:*:* | *:*TOS:*:*)
-	echo m68k-unknown-mint${UNAME_RELEASE}
-	exit ;;
+	GUESS=m68k-unknown-mint$UNAME_RELEASE
+	;;
     m68k:machten:*:*)
-	echo m68k-apple-machten${UNAME_RELEASE}
-	exit ;;
+	GUESS=m68k-apple-machten$UNAME_RELEASE
+	;;
     powerpc:machten:*:*)
-	echo powerpc-apple-machten${UNAME_RELEASE}
-	exit ;;
+	GUESS=powerpc-apple-machten$UNAME_RELEASE
+	;;
     RISC*:Mach:*:*)
-	echo mips-dec-mach_bsd4.3
-	exit ;;
+	GUESS=mips-dec-mach_bsd4.3
+	;;
     RISC*:ULTRIX:*:*)
-	echo mips-dec-ultrix${UNAME_RELEASE}
-	exit ;;
+	GUESS=mips-dec-ultrix$UNAME_RELEASE
+	;;
     VAX*:ULTRIX*:*:*)
-	echo vax-dec-ultrix${UNAME_RELEASE}
-	exit ;;
+	GUESS=vax-dec-ultrix$UNAME_RELEASE
+	;;
     2020:CLIX:*:* | 2430:CLIX:*:*)
-	echo clipper-intergraph-clix${UNAME_RELEASE}
-	exit ;;
+	GUESS=clipper-intergraph-clix$UNAME_RELEASE
+	;;
     mips:*:*:UMIPS | mips:*:*:RISCos)
-	eval $set_cc_for_build
-	sed 's/^	//' << EOF >$dummy.c
+	set_cc_for_build
+	sed 's/^	//' << EOF > "$dummy.c"
 #ifdef __cplusplus
 #include <stdio.h>  /* for printf() prototype */
 	int main (int argc, char *argv[]) {
@@ -461,95 +536,96 @@ case "${UNAME_MACHINE}:${UNAME_SYSTEM}:${UNAME_RELEASE}:${UNAME_VERSION}" in
 #endif
 	#if defined (host_mips) && defined (MIPSEB)
 	#if defined (SYSTYPE_SYSV)
-	  printf ("mips-mips-riscos%ssysv\n", argv[1]); exit (0);
+	  printf ("mips-mips-riscos%ssysv\\n", argv[1]); exit (0);
 	#endif
 	#if defined (SYSTYPE_SVR4)
-	  printf ("mips-mips-riscos%ssvr4\n", argv[1]); exit (0);
+	  printf ("mips-mips-riscos%ssvr4\\n", argv[1]); exit (0);
 	#endif
 	#if defined (SYSTYPE_BSD43) || defined(SYSTYPE_BSD)
-	  printf ("mips-mips-riscos%sbsd\n", argv[1]); exit (0);
+	  printf ("mips-mips-riscos%sbsd\\n", argv[1]); exit (0);
 	#endif
 	#endif
 	  exit (-1);
 	}
 EOF
-	$CC_FOR_BUILD -o $dummy $dummy.c &&
-	  dummyarg=`echo "${UNAME_RELEASE}" | sed -n 's/\([0-9]*\).*/\1/p'` &&
-	  SYSTEM_NAME=`$dummy $dummyarg` &&
+	$CC_FOR_BUILD -o "$dummy" "$dummy.c" &&
+	  dummyarg=`echo "$UNAME_RELEASE" | sed -n 's/\([0-9]*\).*/\1/p'` &&
+	  SYSTEM_NAME=`"$dummy" "$dummyarg"` &&
 	    { echo "$SYSTEM_NAME"; exit; }
-	echo mips-mips-riscos${UNAME_RELEASE}
-	exit ;;
+	GUESS=mips-mips-riscos$UNAME_RELEASE
+	;;
     Motorola:PowerMAX_OS:*:*)
-	echo powerpc-motorola-powermax
-	exit ;;
+	GUESS=powerpc-motorola-powermax
+	;;
     Motorola:*:4.3:PL8-*)
-	echo powerpc-harris-powermax
-	exit ;;
+	GUESS=powerpc-harris-powermax
+	;;
     Night_Hawk:*:*:PowerMAX_OS | Synergy:PowerMAX_OS:*:*)
-	echo powerpc-harris-powermax
-	exit ;;
+	GUESS=powerpc-harris-powermax
+	;;
     Night_Hawk:Power_UNIX:*:*)
-	echo powerpc-harris-powerunix
-	exit ;;
+	GUESS=powerpc-harris-powerunix
+	;;
     m88k:CX/UX:7*:*)
-	echo m88k-harris-cxux7
-	exit ;;
+	GUESS=m88k-harris-cxux7
+	;;
     m88k:*:4*:R4*)
-	echo m88k-motorola-sysv4
-	exit ;;
+	GUESS=m88k-motorola-sysv4
+	;;
     m88k:*:3*:R3*)
-	echo m88k-motorola-sysv3
-	exit ;;
+	GUESS=m88k-motorola-sysv3
+	;;
     AViiON:dgux:*:*)
 	# DG/UX returns AViiON for all architectures
 	UNAME_PROCESSOR=`/usr/bin/uname -p`
-	if [ $UNAME_PROCESSOR = mc88100 ] || [ $UNAME_PROCESSOR = mc88110 ]
+	if test "$UNAME_PROCESSOR" = mc88100 || test "$UNAME_PROCESSOR" = mc88110
 	then
-	    if [ ${TARGET_BINARY_INTERFACE}x = m88kdguxelfx ] || \
-	       [ ${TARGET_BINARY_INTERFACE}x = x ]
+	    if test "$TARGET_BINARY_INTERFACE"x = m88kdguxelfx || \
+	       test "$TARGET_BINARY_INTERFACE"x = x
 	    then
-		echo m88k-dg-dgux${UNAME_RELEASE}
+		GUESS=m88k-dg-dgux$UNAME_RELEASE
 	    else
-		echo m88k-dg-dguxbcs${UNAME_RELEASE}
+		GUESS=m88k-dg-dguxbcs$UNAME_RELEASE
 	    fi
 	else
-	    echo i586-dg-dgux${UNAME_RELEASE}
+	    GUESS=i586-dg-dgux$UNAME_RELEASE
 	fi
-	exit ;;
+	;;
     M88*:DolphinOS:*:*)	# DolphinOS (SVR3)
-	echo m88k-dolphin-sysv3
-	exit ;;
+	GUESS=m88k-dolphin-sysv3
+	;;
     M88*:*:R3*:*)
 	# Delta 88k system running SVR3
-	echo m88k-motorola-sysv3
-	exit ;;
+	GUESS=m88k-motorola-sysv3
+	;;
     XD88*:*:*:*) # Tektronix XD88 system running UTekV (SVR3)
-	echo m88k-tektronix-sysv3
-	exit ;;
+	GUESS=m88k-tektronix-sysv3
+	;;
     Tek43[0-9][0-9]:UTek:*:*) # Tektronix 4300 system running UTek (BSD)
-	echo m68k-tektronix-bsd
-	exit ;;
+	GUESS=m68k-tektronix-bsd
+	;;
     *:IRIX*:*:*)
-	echo mips-sgi-irix`echo ${UNAME_RELEASE}|sed -e 's/-/_/g'`
-	exit ;;
+	IRIX_REL=`echo "$UNAME_RELEASE" | sed -e 's/-/_/g'`
+	GUESS=mips-sgi-irix$IRIX_REL
+	;;
     ????????:AIX?:[12].1:2)   # AIX 2.2.1 or AIX 2.1.1 is RT/PC AIX.
-	echo romp-ibm-aix     # uname -m gives an 8 hex-code CPU id
-	exit ;;               # Note that: echo "'`uname -s`'" gives 'AIX '
+	GUESS=romp-ibm-aix    # uname -m gives an 8 hex-code CPU id
+	;;                    # Note that: echo "'`uname -s`'" gives 'AIX '
     i*86:AIX:*:*)
-	echo i386-ibm-aix
-	exit ;;
+	GUESS=i386-ibm-aix
+	;;
     ia64:AIX:*:*)
-	if [ -x /usr/bin/oslevel ] ; then
+	if test -x /usr/bin/oslevel ; then
 		IBM_REV=`/usr/bin/oslevel`
 	else
-		IBM_REV=${UNAME_VERSION}.${UNAME_RELEASE}
+		IBM_REV=$UNAME_VERSION.$UNAME_RELEASE
 	fi
-	echo ${UNAME_MACHINE}-ibm-aix${IBM_REV}
-	exit ;;
+	GUESS=$UNAME_MACHINE-ibm-aix$IBM_REV
+	;;
     *:AIX:2:3)
 	if grep bos325 /usr/include/stdio.h >/dev/null 2>&1; then
-		eval $set_cc_for_build
-		sed 's/^		//' << EOF >$dummy.c
+		set_cc_for_build
+		sed 's/^		//' << EOF > "$dummy.c"
 		#include <sys/systemcfg.h>
 
 		main()
@@ -560,76 +636,77 @@ EOF
 			exit(0);
 			}
 EOF
-		if $CC_FOR_BUILD -o $dummy $dummy.c && SYSTEM_NAME=`$dummy`
+		if $CC_FOR_BUILD -o "$dummy" "$dummy.c" && SYSTEM_NAME=`"$dummy"`
 		then
-			echo "$SYSTEM_NAME"
+			GUESS=$SYSTEM_NAME
 		else
-			echo rs6000-ibm-aix3.2.5
+			GUESS=rs6000-ibm-aix3.2.5
 		fi
 	elif grep bos324 /usr/include/stdio.h >/dev/null 2>&1; then
-		echo rs6000-ibm-aix3.2.4
+		GUESS=rs6000-ibm-aix3.2.4
 	else
-		echo rs6000-ibm-aix3.2
+		GUESS=rs6000-ibm-aix3.2
 	fi
-	exit ;;
+	;;
     *:AIX:*:[4567])
 	IBM_CPU_ID=`/usr/sbin/lsdev -C -c processor -S available | sed 1q | awk '{ print $1 }'`
-	if /usr/sbin/lsattr -El ${IBM_CPU_ID} | grep ' POWER' >/dev/null 2>&1; then
+	if /usr/sbin/lsattr -El "$IBM_CPU_ID" | grep ' POWER' >/dev/null 2>&1; then
 		IBM_ARCH=rs6000
 	else
 		IBM_ARCH=powerpc
 	fi
-	if [ -x /usr/bin/oslevel ] ; then
-		IBM_REV=`/usr/bin/oslevel`
+	if test -x /usr/bin/lslpp ; then
+		IBM_REV=`/usr/bin/lslpp -Lqc bos.rte.libc | \
+			   awk -F: '{ print $3 }' | sed s/[0-9]*$/0/`
 	else
-		IBM_REV=${UNAME_VERSION}.${UNAME_RELEASE}
+		IBM_REV=$UNAME_VERSION.$UNAME_RELEASE
 	fi
-	echo ${IBM_ARCH}-ibm-aix${IBM_REV}
-	exit ;;
+	GUESS=$IBM_ARCH-ibm-aix$IBM_REV
+	;;
     *:AIX:*:*)
-	echo rs6000-ibm-aix
-	exit ;;
-    ibmrt:4.4BSD:*|romp-ibm:BSD:*)
-	echo romp-ibm-bsd4.4
-	exit ;;
+	GUESS=rs6000-ibm-aix
+	;;
+    ibmrt:4.4BSD:*|romp-ibm:4.4BSD:*)
+	GUESS=romp-ibm-bsd4.4
+	;;
     ibmrt:*BSD:*|romp-ibm:BSD:*)            # covers RT/PC BSD and
-	echo romp-ibm-bsd${UNAME_RELEASE}   # 4.3 with uname added to
-	exit ;;                             # report: romp-ibm BSD 4.3
+	GUESS=romp-ibm-bsd$UNAME_RELEASE    # 4.3 with uname added to
+	;;                                  # report: romp-ibm BSD 4.3
     *:BOSX:*:*)
-	echo rs6000-bull-bosx
-	exit ;;
+	GUESS=rs6000-bull-bosx
+	;;
     DPX/2?00:B.O.S.:*:*)
-	echo m68k-bull-sysv3
-	exit ;;
+	GUESS=m68k-bull-sysv3
+	;;
     9000/[34]??:4.3bsd:1.*:*)
-	echo m68k-hp-bsd
-	exit ;;
+	GUESS=m68k-hp-bsd
+	;;
     hp300:4.4BSD:*:* | 9000/[34]??:4.3bsd:2.*:*)
-	echo m68k-hp-bsd4.4
-	exit ;;
+	GUESS=m68k-hp-bsd4.4
+	;;
     9000/[34678]??:HP-UX:*:*)
-	HPUX_REV=`echo ${UNAME_RELEASE}|sed -e 's/[^.]*.[0B]*//'`
-	case "${UNAME_MACHINE}" in
-	    9000/31? )            HP_ARCH=m68000 ;;
-	    9000/[34]?? )         HP_ARCH=m68k ;;
+	HPUX_REV=`echo "$UNAME_RELEASE" | sed -e 's/[^.]*.[0B]*//'`
+	case $UNAME_MACHINE in
+	    9000/31?)            HP_ARCH=m68000 ;;
+	    9000/[34]??)         HP_ARCH=m68k ;;
 	    9000/[678][0-9][0-9])
-		if [ -x /usr/bin/getconf ]; then
+		if test -x /usr/bin/getconf; then
 		    sc_cpu_version=`/usr/bin/getconf SC_CPU_VERSION 2>/dev/null`
 		    sc_kernel_bits=`/usr/bin/getconf SC_KERNEL_BITS 2>/dev/null`
-		    case "${sc_cpu_version}" in
-		      523) HP_ARCH="hppa1.0" ;; # CPU_PA_RISC1_0
-		      528) HP_ARCH="hppa1.1" ;; # CPU_PA_RISC1_1
+		    case $sc_cpu_version in
+		      523) HP_ARCH=hppa1.0 ;; # CPU_PA_RISC1_0
+		      528) HP_ARCH=hppa1.1 ;; # CPU_PA_RISC1_1
 		      532)                      # CPU_PA_RISC2_0
-			case "${sc_kernel_bits}" in
-			  32) HP_ARCH="hppa2.0n" ;;
-			  64) HP_ARCH="hppa2.0w" ;;
-			  '') HP_ARCH="hppa2.0" ;;   # HP-UX 10.20
+			case $sc_kernel_bits in
+			  32) HP_ARCH=hppa2.0n ;;
+			  64) HP_ARCH=hppa2.0w ;;
+			  '') HP_ARCH=hppa2.0 ;;   # HP-UX 10.20
 			esac ;;
 		    esac
 		fi
-		if [ "${HP_ARCH}" = "" ]; then
-		    eval $set_cc_for_build
-		    sed 's/^		//' << EOF >$dummy.c
+		if test "$HP_ARCH" = ""; then
+		    set_cc_for_build
+		    sed 's/^		//' << EOF > "$dummy.c"
 
 		#define _HPUX_SOURCE
 		#include <stdlib.h>
@@ -662,13 +739,13 @@ EOF
 		    exit (0);
 		}
 EOF
-		    (CCOPTS= $CC_FOR_BUILD -o $dummy $dummy.c 2>/dev/null) && HP_ARCH=`$dummy`
+		    (CCOPTS="" $CC_FOR_BUILD -o "$dummy" "$dummy.c" 2>/dev/null) && HP_ARCH=`"$dummy"`
 		    test -z "$HP_ARCH" && HP_ARCH=hppa
 		fi ;;
 	esac
-	if [ ${HP_ARCH} = "hppa2.0w" ]
+	if test "$HP_ARCH" = hppa2.0w
 	then
-	    eval $set_cc_for_build
+	    set_cc_for_build
 
 	    # hppa2.0w-hp-hpux* has a 64-bit kernel and a compiler generating
 	    # 32-bit code.  hppa64-hp-hpux* has the same kernel and a compiler
@@ -679,23 +756,23 @@ EOF
 	    # $ CC_FOR_BUILD="cc +DA2.0w" ./config.guess
 	    # => hppa64-hp-hpux11.23
 
-	    if echo __LP64__ | (CCOPTS= $CC_FOR_BUILD -E - 2>/dev/null) |
+	    if echo __LP64__ | (CCOPTS="" $CC_FOR_BUILD -E - 2>/dev/null) |
 		grep -q __LP64__
 	    then
-		HP_ARCH="hppa2.0w"
+		HP_ARCH=hppa2.0w
 	    else
-		HP_ARCH="hppa64"
+		HP_ARCH=hppa64
 	    fi
 	fi
-	echo ${HP_ARCH}-hp-hpux${HPUX_REV}
-	exit ;;
+	GUESS=$HP_ARCH-hp-hpux$HPUX_REV
+	;;
     ia64:HP-UX:*:*)
-	HPUX_REV=`echo ${UNAME_RELEASE}|sed -e 's/[^.]*.[0B]*//'`
-	echo ia64-hp-hpux${HPUX_REV}
-	exit ;;
+	HPUX_REV=`echo "$UNAME_RELEASE" | sed -e 's/[^.]*.[0B]*//'`
+	GUESS=ia64-hp-hpux$HPUX_REV
+	;;
     3050*:HI-UX:*:*)
-	eval $set_cc_for_build
-	sed 's/^	//' << EOF >$dummy.c
+	set_cc_for_build
+	sed 's/^	//' << EOF > "$dummy.c"
 	#include <unistd.h>
 	int
 	main ()
@@ -720,38 +797,38 @@ EOF
 	  exit (0);
 	}
 EOF
-	$CC_FOR_BUILD -o $dummy $dummy.c && SYSTEM_NAME=`$dummy` &&
+	$CC_FOR_BUILD -o "$dummy" "$dummy.c" && SYSTEM_NAME=`"$dummy"` &&
 		{ echo "$SYSTEM_NAME"; exit; }
-	echo unknown-hitachi-hiuxwe2
-	exit ;;
-    9000/7??:4.3bsd:*:* | 9000/8?[79]:4.3bsd:*:* )
-	echo hppa1.1-hp-bsd
-	exit ;;
+	GUESS=unknown-hitachi-hiuxwe2
+	;;
+    9000/7??:4.3bsd:*:* | 9000/8?[79]:4.3bsd:*:*)
+	GUESS=hppa1.1-hp-bsd
+	;;
     9000/8??:4.3bsd:*:*)
-	echo hppa1.0-hp-bsd
-	exit ;;
+	GUESS=hppa1.0-hp-bsd
+	;;
     *9??*:MPE/iX:*:* | *3000*:MPE/iX:*:*)
-	echo hppa1.0-hp-mpeix
-	exit ;;
-    hp7??:OSF1:*:* | hp8?[79]:OSF1:*:* )
-	echo hppa1.1-hp-osf
-	exit ;;
+	GUESS=hppa1.0-hp-mpeix
+	;;
+    hp7??:OSF1:*:* | hp8?[79]:OSF1:*:*)
+	GUESS=hppa1.1-hp-osf
+	;;
     hp8??:OSF1:*:*)
-	echo hppa1.0-hp-osf
-	exit ;;
+	GUESS=hppa1.0-hp-osf
+	;;
     i*86:OSF1:*:*)
-	if [ -x /usr/sbin/sysversion ] ; then
-	    echo ${UNAME_MACHINE}-unknown-osf1mk
+	if test -x /usr/sbin/sysversion ; then
+	    GUESS=$UNAME_MACHINE-unknown-osf1mk
 	else
-	    echo ${UNAME_MACHINE}-unknown-osf1
+	    GUESS=$UNAME_MACHINE-unknown-osf1
 	fi
-	exit ;;
+	;;
     parisc*:Lites*:*:*)
-	echo hppa1.1-hp-lites
-	exit ;;
+	GUESS=hppa1.1-hp-lites
+	;;
     C1*:ConvexOS:*:* | convex:ConvexOS:C1*:*)
-	echo c1-convex-bsd
-	exit ;;
+	GUESS=c1-convex-bsd
+	;;
     C2*:ConvexOS:*:* | convex:ConvexOS:C2*:*)
 	if getsysinfo -f scalar_acc
 	then echo c32-convex-bsd
@@ -759,139 +836,148 @@ EOF
 	fi
 	exit ;;
     C34*:ConvexOS:*:* | convex:ConvexOS:C34*:*)
-	echo c34-convex-bsd
-	exit ;;
+	GUESS=c34-convex-bsd
+	;;
     C38*:ConvexOS:*:* | convex:ConvexOS:C38*:*)
-	echo c38-convex-bsd
-	exit ;;
+	GUESS=c38-convex-bsd
+	;;
     C4*:ConvexOS:*:* | convex:ConvexOS:C4*:*)
-	echo c4-convex-bsd
-	exit ;;
+	GUESS=c4-convex-bsd
+	;;
     CRAY*Y-MP:*:*:*)
-	echo ymp-cray-unicos${UNAME_RELEASE} | sed -e 's/\.[^.]*$/.X/'
-	exit ;;
+	CRAY_REL=`echo "$UNAME_RELEASE" | sed -e 's/\.[^.]*$/.X/'`
+	GUESS=ymp-cray-unicos$CRAY_REL
+	;;
     CRAY*[A-Z]90:*:*:*)
-	echo ${UNAME_MACHINE}-cray-unicos${UNAME_RELEASE} \
+	echo "$UNAME_MACHINE"-cray-unicos"$UNAME_RELEASE" \
 	| sed -e 's/CRAY.*\([A-Z]90\)/\1/' \
 	      -e y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/ \
 	      -e 's/\.[^.]*$/.X/'
 	exit ;;
     CRAY*TS:*:*:*)
-	echo t90-cray-unicos${UNAME_RELEASE} | sed -e 's/\.[^.]*$/.X/'
-	exit ;;
+	CRAY_REL=`echo "$UNAME_RELEASE" | sed -e 's/\.[^.]*$/.X/'`
+	GUESS=t90-cray-unicos$CRAY_REL
+	;;
     CRAY*T3E:*:*:*)
-	echo alphaev5-cray-unicosmk${UNAME_RELEASE} | sed -e 's/\.[^.]*$/.X/'
-	exit ;;
+	CRAY_REL=`echo "$UNAME_RELEASE" | sed -e 's/\.[^.]*$/.X/'`
+	GUESS=alphaev5-cray-unicosmk$CRAY_REL
+	;;
     CRAY*SV1:*:*:*)
-	echo sv1-cray-unicos${UNAME_RELEASE} | sed -e 's/\.[^.]*$/.X/'
-	exit ;;
+	CRAY_REL=`echo "$UNAME_RELEASE" | sed -e 's/\.[^.]*$/.X/'`
+	GUESS=sv1-cray-unicos$CRAY_REL
+	;;
     *:UNICOS/mp:*:*)
-	echo craynv-cray-unicosmp${UNAME_RELEASE} | sed -e 's/\.[^.]*$/.X/'
-	exit ;;
+	CRAY_REL=`echo "$UNAME_RELEASE" | sed -e 's/\.[^.]*$/.X/'`
+	GUESS=craynv-cray-unicosmp$CRAY_REL
+	;;
     F30[01]:UNIX_System_V:*:* | F700:UNIX_System_V:*:*)
-	FUJITSU_PROC=`uname -m | tr 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' 'abcdefghijklmnopqrstuvwxyz'`
-	FUJITSU_SYS=`uname -p | tr 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' 'abcdefghijklmnopqrstuvwxyz' | sed -e 's/\///'`
-	FUJITSU_REL=`echo ${UNAME_RELEASE} | sed -e 's/ /_/'`
-	echo "${FUJITSU_PROC}-fujitsu-${FUJITSU_SYS}${FUJITSU_REL}"
-	exit ;;
+	FUJITSU_PROC=`uname -m | tr ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz`
+	FUJITSU_SYS=`uname -p | tr ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz | sed -e 's/\///'`
+	FUJITSU_REL=`echo "$UNAME_RELEASE" | sed -e 's/ /_/'`
+	GUESS=${FUJITSU_PROC}-fujitsu-${FUJITSU_SYS}${FUJITSU_REL}
+	;;
     5000:UNIX_System_V:4.*:*)
-	FUJITSU_SYS=`uname -p | tr 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' 'abcdefghijklmnopqrstuvwxyz' | sed -e 's/\///'`
-	FUJITSU_REL=`echo ${UNAME_RELEASE} | tr 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' 'abcdefghijklmnopqrstuvwxyz' | sed -e 's/ /_/'`
-	echo "sparc-fujitsu-${FUJITSU_SYS}${FUJITSU_REL}"
-	exit ;;
+	FUJITSU_SYS=`uname -p | tr ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz | sed -e 's/\///'`
+	FUJITSU_REL=`echo "$UNAME_RELEASE" | tr ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz | sed -e 's/ /_/'`
+	GUESS=sparc-fujitsu-${FUJITSU_SYS}${FUJITSU_REL}
+	;;
     i*86:BSD/386:*:* | i*86:BSD/OS:*:* | *:Ascend\ Embedded/OS:*:*)
-	echo ${UNAME_MACHINE}-pc-bsdi${UNAME_RELEASE}
-	exit ;;
+	GUESS=$UNAME_MACHINE-pc-bsdi$UNAME_RELEASE
+	;;
     sparc*:BSD/OS:*:*)
-	echo sparc-unknown-bsdi${UNAME_RELEASE}
-	exit ;;
+	GUESS=sparc-unknown-bsdi$UNAME_RELEASE
+	;;
     *:BSD/OS:*:*)
-	echo ${UNAME_MACHINE}-unknown-bsdi${UNAME_RELEASE}
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-bsdi$UNAME_RELEASE
+	;;
+    arm:FreeBSD:*:*)
+	UNAME_PROCESSOR=`uname -p`
+	set_cc_for_build
+	if echo __ARM_PCS_VFP | $CC_FOR_BUILD -E - 2>/dev/null \
+	    | grep -q __ARM_PCS_VFP
+	then
+	    FREEBSD_REL=`echo "$UNAME_RELEASE" | sed -e 's/[-(].*//'`
+	    GUESS=$UNAME_PROCESSOR-unknown-freebsd$FREEBSD_REL-gnueabi
+	else
+	    FREEBSD_REL=`echo "$UNAME_RELEASE" | sed -e 's/[-(].*//'`
+	    GUESS=$UNAME_PROCESSOR-unknown-freebsd$FREEBSD_REL-gnueabihf
+	fi
+	;;
     *:FreeBSD:*:*)
 	UNAME_PROCESSOR=`/usr/bin/uname -p`
-	case ${UNAME_PROCESSOR} in
+	case $UNAME_PROCESSOR in
 	    amd64)
-		echo x86_64-unknown-freebsd`echo ${UNAME_RELEASE}|sed -e 's/[-(].*//'` ;;
-	    *)
-		echo ${UNAME_PROCESSOR}-unknown-freebsd`echo ${UNAME_RELEASE}|sed -e 's/[-(].*//'` ;;
+		UNAME_PROCESSOR=x86_64 ;;
+	    i386)
+		UNAME_PROCESSOR=i586 ;;
 	esac
-	exit ;;
+	FREEBSD_REL=`echo "$UNAME_RELEASE" | sed -e 's/[-(].*//'`
+	GUESS=$UNAME_PROCESSOR-unknown-freebsd$FREEBSD_REL
+	;;
     i*:CYGWIN*:*)
-	echo ${UNAME_MACHINE}-pc-cygwin
-	exit ;;
+	GUESS=$UNAME_MACHINE-pc-cygwin
+	;;
     *:MINGW64*:*)
-	echo ${UNAME_MACHINE}-pc-mingw64
-	exit ;;
+	GUESS=$UNAME_MACHINE-pc-mingw64
+	;;
     *:MINGW*:*)
-	echo ${UNAME_MACHINE}-pc-mingw32
-	exit ;;
-    i*:MSYS*:*)
-	echo ${UNAME_MACHINE}-pc-msys
-	exit ;;
-    i*:windows32*:*)
-	# uname -m includes "-pc" on this system.
-	echo ${UNAME_MACHINE}-mingw32
-	exit ;;
+	GUESS=$UNAME_MACHINE-pc-mingw32
+	;;
+    *:MSYS*:*)
+	GUESS=$UNAME_MACHINE-pc-msys
+	;;
     i*:PW*:*)
-	echo ${UNAME_MACHINE}-pc-pw32
-	exit ;;
+	GUESS=$UNAME_MACHINE-pc-pw32
+	;;
+    *:SerenityOS:*:*)
+        GUESS=$UNAME_MACHINE-pc-serenity
+        ;;
     *:Interix*:*)
-	case ${UNAME_MACHINE} in
+	case $UNAME_MACHINE in
 	    x86)
-		echo i586-pc-interix${UNAME_RELEASE}
-		exit ;;
+		GUESS=i586-pc-interix$UNAME_RELEASE
+		;;
 	    authenticamd | genuineintel | EM64T)
-		echo x86_64-unknown-interix${UNAME_RELEASE}
-		exit ;;
+		GUESS=x86_64-unknown-interix$UNAME_RELEASE
+		;;
 	    IA64)
-		echo ia64-unknown-interix${UNAME_RELEASE}
-		exit ;;
+		GUESS=ia64-unknown-interix$UNAME_RELEASE
+		;;
 	esac ;;
-    [345]86:Windows_95:* | [345]86:Windows_98:* | [345]86:Windows_NT:*)
-	echo i${UNAME_MACHINE}-pc-mks
-	exit ;;
-    8664:Windows_NT:*)
-	echo x86_64-pc-mks
-	exit ;;
-    i*:Windows_NT*:* | Pentium*:Windows_NT*:*)
-	# How do we know it's Interix rather than the generic POSIX subsystem?
-	# It also conflicts with pre-2.0 versions of AT&T UWIN. Should we
-	# UNAME_MACHINE based on the output of uname instead of i386?
-	echo i586-pc-interix
-	exit ;;
     i*:UWIN*:*)
-	echo ${UNAME_MACHINE}-pc-uwin
-	exit ;;
+	GUESS=$UNAME_MACHINE-pc-uwin
+	;;
     amd64:CYGWIN*:*:* | x86_64:CYGWIN*:*:*)
-	echo x86_64-unknown-cygwin
-	exit ;;
-    p*:CYGWIN*:*)
-	echo powerpcle-unknown-cygwin
-	exit ;;
+	GUESS=x86_64-pc-cygwin
+	;;
     prep*:SunOS:5.*:*)
-	echo powerpcle-unknown-solaris2`echo ${UNAME_RELEASE}|sed -e 's/[^.]*//'`
-	exit ;;
+	SUN_REL=`echo "$UNAME_RELEASE" | sed -e 's/[^.]*//'`
+	GUESS=powerpcle-unknown-solaris2$SUN_REL
+	;;
     *:GNU:*:*)
 	# the GNU system
-	echo `echo ${UNAME_MACHINE}|sed -e 's,[-/].*$,,'`-unknown-${LIBC}`echo ${UNAME_RELEASE}|sed -e 's,/.*$,,'`
-	exit ;;
+	GNU_ARCH=`echo "$UNAME_MACHINE" | sed -e 's,[-/].*$,,'`
+	GNU_REL=`echo "$UNAME_RELEASE" | sed -e 's,/.*$,,'`
+	GUESS=$GNU_ARCH-unknown-$LIBC$GNU_REL
+	;;
     *:GNU/*:*:*)
 	# other systems with GNU libc and userland
-	echo ${UNAME_MACHINE}-unknown-`echo ${UNAME_SYSTEM} | sed 's,^[^/]*/,,' | tr '[A-Z]' '[a-z]'``echo ${UNAME_RELEASE}|sed -e 's/[-(].*//'`-${LIBC}
-	exit ;;
-    i*86:Minix:*:*)
-	echo ${UNAME_MACHINE}-pc-minix
-	exit ;;
+	GNU_SYS=`echo "$UNAME_SYSTEM" | sed 's,^[^/]*/,,' | tr "[:upper:]" "[:lower:]"`
+	GNU_REL=`echo "$UNAME_RELEASE" | sed -e 's/[-(].*//'`
+	GUESS=$UNAME_MACHINE-unknown-$GNU_SYS$GNU_REL-$LIBC
+	;;
+    *:Minix:*:*)
+	GUESS=$UNAME_MACHINE-unknown-minix
+	;;
     aarch64:Linux:*:*)
-	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-linux-$LIBC
+	;;
     aarch64_be:Linux:*:*)
 	UNAME_MACHINE=aarch64_be
-	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-linux-$LIBC
+	;;
     alpha:Linux:*:*)
-	case `sed -n '/^cpu model/s/^.*: \(.*\)/\1/p' < /proc/cpuinfo` in
+	case `sed -n '/^cpu model/s/^.*: \(.*\)/\1/p' /proc/cpuinfo 2>/dev/null` in
 	  EV5)   UNAME_MACHINE=alphaev5 ;;
 	  EV56)  UNAME_MACHINE=alphaev56 ;;
 	  PCA56) UNAME_MACHINE=alphapca56 ;;
@@ -901,172 +987,237 @@ EOF
 	  EV68*) UNAME_MACHINE=alphaev68 ;;
 	esac
 	objdump --private-headers /bin/sh | grep -q ld.so.1
-	if test "$?" = 0 ; then LIBC="gnulibc1" ; fi
-	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
-	exit ;;
-    arc:Linux:*:* | arceb:Linux:*:*)
-	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
-	exit ;;
+	if test "$?" = 0 ; then LIBC=gnulibc1 ; fi
+	GUESS=$UNAME_MACHINE-unknown-linux-$LIBC
+	;;
+    arc:Linux:*:* | arceb:Linux:*:* | arc32:Linux:*:* | arc64:Linux:*:*)
+	GUESS=$UNAME_MACHINE-unknown-linux-$LIBC
+	;;
     arm*:Linux:*:*)
-	eval $set_cc_for_build
+	set_cc_for_build
 	if echo __ARM_EABI__ | $CC_FOR_BUILD -E - 2>/dev/null \
 	    | grep -q __ARM_EABI__
 	then
-	    echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
+	    GUESS=$UNAME_MACHINE-unknown-linux-$LIBC
 	else
 	    if echo __ARM_PCS_VFP | $CC_FOR_BUILD -E - 2>/dev/null \
 		| grep -q __ARM_PCS_VFP
 	    then
-		echo ${UNAME_MACHINE}-unknown-linux-${LIBC}eabi
+		GUESS=$UNAME_MACHINE-unknown-linux-${LIBC}eabi
 	    else
-		echo ${UNAME_MACHINE}-unknown-linux-${LIBC}eabihf
+		GUESS=$UNAME_MACHINE-unknown-linux-${LIBC}eabihf
 	    fi
 	fi
-	exit ;;
+	;;
     avr32*:Linux:*:*)
-	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-linux-$LIBC
+	;;
     cris:Linux:*:*)
-	echo ${UNAME_MACHINE}-axis-linux-${LIBC}
-	exit ;;
+	GUESS=$UNAME_MACHINE-axis-linux-$LIBC
+	;;
     crisv32:Linux:*:*)
-	echo ${UNAME_MACHINE}-axis-linux-${LIBC}
-	exit ;;
+	GUESS=$UNAME_MACHINE-axis-linux-$LIBC
+	;;
+    e2k:Linux:*:*)
+	GUESS=$UNAME_MACHINE-unknown-linux-$LIBC
+	;;
     frv:Linux:*:*)
-	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-linux-$LIBC
+	;;
     hexagon:Linux:*:*)
-	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-linux-$LIBC
+	;;
     i*86:Linux:*:*)
-	echo ${UNAME_MACHINE}-pc-linux-${LIBC}
-	exit ;;
+	GUESS=$UNAME_MACHINE-pc-linux-$LIBC
+	;;
     ia64:Linux:*:*)
-	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-linux-$LIBC
+	;;
+    k1om:Linux:*:*)
+	GUESS=$UNAME_MACHINE-unknown-linux-$LIBC
+	;;
+    loongarch32:Linux:*:* | loongarch64:Linux:*:* | loongarchx32:Linux:*:*)
+	GUESS=$UNAME_MACHINE-unknown-linux-$LIBC
+	;;
     m32r*:Linux:*:*)
-	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-linux-$LIBC
+	;;
     m68*:Linux:*:*)
-	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-linux-$LIBC
+	;;
     mips:Linux:*:* | mips64:Linux:*:*)
-	eval $set_cc_for_build
-	sed 's/^	//' << EOF >$dummy.c
+	set_cc_for_build
+	IS_GLIBC=0
+	test x"${LIBC}" = xgnu && IS_GLIBC=1
+	sed 's/^	//' << EOF > "$dummy.c"
 	#undef CPU
-	#undef ${UNAME_MACHINE}
-	#undef ${UNAME_MACHINE}el
+	#undef mips
+	#undef mipsel
+	#undef mips64
+	#undef mips64el
+	#if ${IS_GLIBC} && defined(_ABI64)
+	LIBCABI=gnuabi64
+	#else
+	#if ${IS_GLIBC} && defined(_ABIN32)
+	LIBCABI=gnuabin32
+	#else
+	LIBCABI=${LIBC}
+	#endif
+	#endif
+
+	#if ${IS_GLIBC} && defined(__mips64) && defined(__mips_isa_rev) && __mips_isa_rev>=6
+	CPU=mipsisa64r6
+	#else
+	#if ${IS_GLIBC} && !defined(__mips64) && defined(__mips_isa_rev) && __mips_isa_rev>=6
+	CPU=mipsisa32r6
+	#else
+	#if defined(__mips64)
+	CPU=mips64
+	#else
+	CPU=mips
+	#endif
+	#endif
+	#endif
+
 	#if defined(__MIPSEL__) || defined(__MIPSEL) || defined(_MIPSEL) || defined(MIPSEL)
-	CPU=${UNAME_MACHINE}el
+	MIPS_ENDIAN=el
 	#else
 	#if defined(__MIPSEB__) || defined(__MIPSEB) || defined(_MIPSEB) || defined(MIPSEB)
-	CPU=${UNAME_MACHINE}
+	MIPS_ENDIAN=
 	#else
-	CPU=
+	MIPS_ENDIAN=
 	#endif
 	#endif
 EOF
-	eval `$CC_FOR_BUILD -E $dummy.c 2>/dev/null | grep '^CPU'`
-	test x"${CPU}" != x && { echo "${CPU}-unknown-linux-${LIBC}"; exit; }
+	cc_set_vars=`$CC_FOR_BUILD -E "$dummy.c" 2>/dev/null | grep '^CPU\|^MIPS_ENDIAN\|^LIBCABI'`
+	eval "$cc_set_vars"
+	test "x$CPU" != x && { echo "$CPU${MIPS_ENDIAN}-unknown-linux-$LIBCABI"; exit; }
+	;;
+    mips64el:Linux:*:*)
+	GUESS=$UNAME_MACHINE-unknown-linux-$LIBC
+	;;
+    openrisc*:Linux:*:*)
+	GUESS=or1k-unknown-linux-$LIBC
+	;;
+    or32:Linux:*:* | or1k*:Linux:*:*)
+	GUESS=$UNAME_MACHINE-unknown-linux-$LIBC
 	;;
-    or1k:Linux:*:*)
-	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
-	exit ;;
-    or32:Linux:*:*)
-	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
-	exit ;;
     padre:Linux:*:*)
-	echo sparc-unknown-linux-${LIBC}
-	exit ;;
+	GUESS=sparc-unknown-linux-$LIBC
+	;;
     parisc64:Linux:*:* | hppa64:Linux:*:*)
-	echo hppa64-unknown-linux-${LIBC}
-	exit ;;
+	GUESS=hppa64-unknown-linux-$LIBC
+	;;
     parisc:Linux:*:* | hppa:Linux:*:*)
 	# Look for CPU level
 	case `grep '^cpu[^a-z]*:' /proc/cpuinfo 2>/dev/null | cut -d' ' -f2` in
-	  PA7*) echo hppa1.1-unknown-linux-${LIBC} ;;
-	  PA8*) echo hppa2.0-unknown-linux-${LIBC} ;;
-	  *)    echo hppa-unknown-linux-${LIBC} ;;
+	  PA7*) GUESS=hppa1.1-unknown-linux-$LIBC ;;
+	  PA8*) GUESS=hppa2.0-unknown-linux-$LIBC ;;
+	  *)    GUESS=hppa-unknown-linux-$LIBC ;;
 	esac
-	exit ;;
+	;;
     ppc64:Linux:*:*)
-	echo powerpc64-unknown-linux-${LIBC}
-	exit ;;
+	GUESS=powerpc64-unknown-linux-$LIBC
+	;;
     ppc:Linux:*:*)
-	echo powerpc-unknown-linux-${LIBC}
-	exit ;;
+	GUESS=powerpc-unknown-linux-$LIBC
+	;;
     ppc64le:Linux:*:*)
-	echo powerpc64le-unknown-linux-${LIBC}
-	exit ;;
+	GUESS=powerpc64le-unknown-linux-$LIBC
+	;;
     ppcle:Linux:*:*)
-	echo powerpcle-unknown-linux-${LIBC}
-	exit ;;
+	GUESS=powerpcle-unknown-linux-$LIBC
+	;;
+    riscv32:Linux:*:* | riscv32be:Linux:*:* | riscv64:Linux:*:* | riscv64be:Linux:*:*)
+	GUESS=$UNAME_MACHINE-unknown-linux-$LIBC
+	;;
     s390:Linux:*:* | s390x:Linux:*:*)
-	echo ${UNAME_MACHINE}-ibm-linux-${LIBC}
-	exit ;;
+	GUESS=$UNAME_MACHINE-ibm-linux-$LIBC
+	;;
     sh64*:Linux:*:*)
-	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-linux-$LIBC
+	;;
     sh*:Linux:*:*)
-	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-linux-$LIBC
+	;;
     sparc:Linux:*:* | sparc64:Linux:*:*)
-	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-linux-$LIBC
+	;;
     tile*:Linux:*:*)
-	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-linux-$LIBC
+	;;
     vax:Linux:*:*)
-	echo ${UNAME_MACHINE}-dec-linux-${LIBC}
-	exit ;;
+	GUESS=$UNAME_MACHINE-dec-linux-$LIBC
+	;;
     x86_64:Linux:*:*)
-	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
-	exit ;;
+	set_cc_for_build
+	CPU=$UNAME_MACHINE
+	LIBCABI=$LIBC
+	if test "$CC_FOR_BUILD" != no_compiler_found; then
+	    ABI=64
+	    sed 's/^	    //' << EOF > "$dummy.c"
+	    #ifdef __i386__
+	    ABI=x86
+	    #else
+	    #ifdef __ILP32__
+	    ABI=x32
+	    #endif
+	    #endif
+EOF
+	    cc_set_abi=`$CC_FOR_BUILD -E "$dummy.c" 2>/dev/null | grep '^ABI' | sed 's, ,,g'`
+	    eval "$cc_set_abi"
+	    case $ABI in
+		x86) CPU=i686 ;;
+		x32) LIBCABI=${LIBC}x32 ;;
+	    esac
+	fi
+	GUESS=$CPU-pc-linux-$LIBCABI
+	;;
     xtensa*:Linux:*:*)
-	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-linux-$LIBC
+	;;
     i*86:DYNIX/ptx:4*:*)
 	# ptx 4.0 does uname -s correctly, with DYNIX/ptx in there.
 	# earlier versions are messed up and put the nodename in both
 	# sysname and nodename.
-	echo i386-sequent-sysv4
-	exit ;;
+	GUESS=i386-sequent-sysv4
+	;;
     i*86:UNIX_SV:4.2MP:2.*)
 	# Unixware is an offshoot of SVR4, but it has its own version
 	# number series starting with 2...
 	# I am not positive that other SVR4 systems won't match this,
 	# I just have to hope.  -- rms.
 	# Use sysv4.2uw... so that sysv4* matches it.
-	echo ${UNAME_MACHINE}-pc-sysv4.2uw${UNAME_VERSION}
-	exit ;;
+	GUESS=$UNAME_MACHINE-pc-sysv4.2uw$UNAME_VERSION
+	;;
     i*86:OS/2:*:*)
 	# If we were able to find `uname', then EMX Unix compatibility
 	# is probably installed.
-	echo ${UNAME_MACHINE}-pc-os2-emx
-	exit ;;
+	GUESS=$UNAME_MACHINE-pc-os2-emx
+	;;
     i*86:XTS-300:*:STOP)
-	echo ${UNAME_MACHINE}-unknown-stop
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-stop
+	;;
     i*86:atheos:*:*)
-	echo ${UNAME_MACHINE}-unknown-atheos
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-atheos
+	;;
     i*86:syllable:*:*)
-	echo ${UNAME_MACHINE}-pc-syllable
-	exit ;;
+	GUESS=$UNAME_MACHINE-pc-syllable
+	;;
     i*86:LynxOS:2.*:* | i*86:LynxOS:3.[01]*:* | i*86:LynxOS:4.[02]*:*)
-	echo i386-unknown-lynxos${UNAME_RELEASE}
-	exit ;;
+	GUESS=i386-unknown-lynxos$UNAME_RELEASE
+	;;
     i*86:*DOS:*:*)
-	echo ${UNAME_MACHINE}-pc-msdosdjgpp
-	exit ;;
-    i*86:*:4.*:* | i*86:SYSTEM_V:4.*:*)
-	UNAME_REL=`echo ${UNAME_RELEASE} | sed 's/\/MP$//'`
+	GUESS=$UNAME_MACHINE-pc-msdosdjgpp
+	;;
+    i*86:*:4.*:*)
+	UNAME_REL=`echo "$UNAME_RELEASE" | sed 's/\/MP$//'`
 	if grep Novell /usr/include/link.h >/dev/null 2>/dev/null; then
-		echo ${UNAME_MACHINE}-univel-sysv${UNAME_REL}
+		GUESS=$UNAME_MACHINE-univel-sysv$UNAME_REL
 	else
-		echo ${UNAME_MACHINE}-pc-sysv${UNAME_REL}
+		GUESS=$UNAME_MACHINE-pc-sysv$UNAME_REL
 	fi
-	exit ;;
+	;;
     i*86:*:5:[678]*)
 	# UnixWare 7.x, OpenUNIX and OpenServer 6.
 	case `/bin/uname -X | grep "^Machine"` in
@@ -1074,12 +1225,12 @@ EOF
 	    *Pentium)	     UNAME_MACHINE=i586 ;;
 	    *Pent*|*Celeron) UNAME_MACHINE=i686 ;;
 	esac
-	echo ${UNAME_MACHINE}-unknown-sysv${UNAME_RELEASE}${UNAME_SYSTEM}${UNAME_VERSION}
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-sysv${UNAME_RELEASE}${UNAME_SYSTEM}${UNAME_VERSION}
+	;;
     i*86:*:3.2:*)
 	if test -f /usr/options/cb.name; then
 		UNAME_REL=`sed -n 's/.*Version //p' </usr/options/cb.name`
-		echo ${UNAME_MACHINE}-pc-isc$UNAME_REL
+		GUESS=$UNAME_MACHINE-pc-isc$UNAME_REL
 	elif /bin/uname -X 2>/dev/null >/dev/null ; then
 		UNAME_REL=`(/bin/uname -X|grep Release|sed -e 's/.*= //')`
 		(/bin/uname -X|grep i80486 >/dev/null) && UNAME_MACHINE=i486
@@ -1089,43 +1240,43 @@ EOF
 			&& UNAME_MACHINE=i686
 		(/bin/uname -X|grep '^Machine.*Pentium Pro' >/dev/null) \
 			&& UNAME_MACHINE=i686
-		echo ${UNAME_MACHINE}-pc-sco$UNAME_REL
+		GUESS=$UNAME_MACHINE-pc-sco$UNAME_REL
 	else
-		echo ${UNAME_MACHINE}-pc-sysv32
+		GUESS=$UNAME_MACHINE-pc-sysv32
 	fi
-	exit ;;
+	;;
     pc:*:*:*)
 	# Left here for compatibility:
 	# uname -m prints for DJGPP always 'pc', but it prints nothing about
 	# the processor, so we play safe by assuming i586.
 	# Note: whatever this is, it MUST be the same as what config.sub
-	# prints for the "djgpp" host, or else GDB configury will decide that
+	# prints for the "djgpp" host, or else GDB configure will decide that
 	# this is a cross-build.
-	echo i586-pc-msdosdjgpp
-	exit ;;
+	GUESS=i586-pc-msdosdjgpp
+	;;
     Intel:Mach:3*:*)
-	echo i386-pc-mach3
-	exit ;;
+	GUESS=i386-pc-mach3
+	;;
     paragon:*:*:*)
-	echo i860-intel-osf1
-	exit ;;
+	GUESS=i860-intel-osf1
+	;;
     i860:*:4.*:*) # i860-SVR4
 	if grep Stardent /usr/include/sys/uadmin.h >/dev/null 2>&1 ; then
-	  echo i860-stardent-sysv${UNAME_RELEASE} # Stardent Vistra i860-SVR4
+	  GUESS=i860-stardent-sysv$UNAME_RELEASE    # Stardent Vistra i860-SVR4
 	else # Add other i860-SVR4 vendors below as they are discovered.
-	  echo i860-unknown-sysv${UNAME_RELEASE}  # Unknown i860-SVR4
+	  GUESS=i860-unknown-sysv$UNAME_RELEASE     # Unknown i860-SVR4
 	fi
-	exit ;;
+	;;
     mini*:CTIX:SYS*5:*)
 	# "miniframe"
-	echo m68010-convergent-sysv
-	exit ;;
+	GUESS=m68010-convergent-sysv
+	;;
     mc68k:UNIX:SYSTEM5:3.51m)
-	echo m68k-convergent-sysv
-	exit ;;
+	GUESS=m68k-convergent-sysv
+	;;
     M680?0:D-NIX:5.3:*)
-	echo m68k-diab-dnix
-	exit ;;
+	GUESS=m68k-diab-dnix
+	;;
     M68*:*:R3V[5678]*:*)
 	test -r /sysV68 && { echo 'm68k-motorola-sysv'; exit; } ;;
     3[345]??:*:4.0:3.0 | 3[34]??A:*:4.0:3.0 | 3[34]??,*:*:4.0:3.0 | 3[34]??/*:*:4.0:3.0 | 4400:*:4.0:3.0 | 4850:*:4.0:3.0 | SKA40:*:4.0:3.0 | SDS2:*:4.0:3.0 | SHG2:*:4.0:3.0 | S7501*:*:4.0:3.0)
@@ -1133,9 +1284,9 @@ EOF
 	test -r /etc/.relid \
 	&& OS_REL=.`sed -n 's/[^ ]* [^ ]* \([0-9][0-9]\).*/\1/p' < /etc/.relid`
 	/bin/uname -p 2>/dev/null | grep 86 >/dev/null \
-	  && { echo i486-ncr-sysv4.3${OS_REL}; exit; }
+	  && { echo i486-ncr-sysv4.3"$OS_REL"; exit; }
 	/bin/uname -p 2>/dev/null | /bin/grep entium >/dev/null \
-	  && { echo i586-ncr-sysv4.3${OS_REL}; exit; } ;;
+	  && { echo i586-ncr-sysv4.3"$OS_REL"; exit; } ;;
     3[34]??:*:4.0:* | 3[34]??,*:*:4.0:*)
 	/bin/uname -p 2>/dev/null | grep 86 >/dev/null \
 	  && { echo i486-ncr-sysv4; exit; } ;;
@@ -1144,238 +1295,287 @@ EOF
 	test -r /etc/.relid \
 	    && OS_REL=.`sed -n 's/[^ ]* [^ ]* \([0-9][0-9]\).*/\1/p' < /etc/.relid`
 	/bin/uname -p 2>/dev/null | grep 86 >/dev/null \
-	    && { echo i486-ncr-sysv4.3${OS_REL}; exit; }
+	    && { echo i486-ncr-sysv4.3"$OS_REL"; exit; }
 	/bin/uname -p 2>/dev/null | /bin/grep entium >/dev/null \
-	    && { echo i586-ncr-sysv4.3${OS_REL}; exit; }
+	    && { echo i586-ncr-sysv4.3"$OS_REL"; exit; }
 	/bin/uname -p 2>/dev/null | /bin/grep pteron >/dev/null \
-	    && { echo i586-ncr-sysv4.3${OS_REL}; exit; } ;;
+	    && { echo i586-ncr-sysv4.3"$OS_REL"; exit; } ;;
     m68*:LynxOS:2.*:* | m68*:LynxOS:3.0*:*)
-	echo m68k-unknown-lynxos${UNAME_RELEASE}
-	exit ;;
+	GUESS=m68k-unknown-lynxos$UNAME_RELEASE
+	;;
     mc68030:UNIX_System_V:4.*:*)
-	echo m68k-atari-sysv4
-	exit ;;
+	GUESS=m68k-atari-sysv4
+	;;
     TSUNAMI:LynxOS:2.*:*)
-	echo sparc-unknown-lynxos${UNAME_RELEASE}
-	exit ;;
+	GUESS=sparc-unknown-lynxos$UNAME_RELEASE
+	;;
     rs6000:LynxOS:2.*:*)
-	echo rs6000-unknown-lynxos${UNAME_RELEASE}
-	exit ;;
+	GUESS=rs6000-unknown-lynxos$UNAME_RELEASE
+	;;
     PowerPC:LynxOS:2.*:* | PowerPC:LynxOS:3.[01]*:* | PowerPC:LynxOS:4.[02]*:*)
-	echo powerpc-unknown-lynxos${UNAME_RELEASE}
-	exit ;;
+	GUESS=powerpc-unknown-lynxos$UNAME_RELEASE
+	;;
     SM[BE]S:UNIX_SV:*:*)
-	echo mips-dde-sysv${UNAME_RELEASE}
-	exit ;;
+	GUESS=mips-dde-sysv$UNAME_RELEASE
+	;;
     RM*:ReliantUNIX-*:*:*)
-	echo mips-sni-sysv4
-	exit ;;
+	GUESS=mips-sni-sysv4
+	;;
     RM*:SINIX-*:*:*)
-	echo mips-sni-sysv4
-	exit ;;
+	GUESS=mips-sni-sysv4
+	;;
     *:SINIX-*:*:*)
 	if uname -p 2>/dev/null >/dev/null ; then
 		UNAME_MACHINE=`(uname -p) 2>/dev/null`
-		echo ${UNAME_MACHINE}-sni-sysv4
+		GUESS=$UNAME_MACHINE-sni-sysv4
 	else
-		echo ns32k-sni-sysv
+		GUESS=ns32k-sni-sysv
 	fi
-	exit ;;
+	;;
     PENTIUM:*:4.0*:*)	# Unisys `ClearPath HMP IX 4000' SVR4/MP effort
 			# says <Richard.M.Bartel@ccMail.Census.GOV>
-	echo i586-unisys-sysv4
-	exit ;;
+	GUESS=i586-unisys-sysv4
+	;;
     *:UNIX_System_V:4*:FTX*)
 	# From Gerald Hewes <hewes@openmarket.com>.
 	# How about differentiating between stratus architectures? -djm
-	echo hppa1.1-stratus-sysv4
-	exit ;;
+	GUESS=hppa1.1-stratus-sysv4
+	;;
     *:*:*:FTX*)
 	# From seanf at swdc.stratus.com.
-	echo i860-stratus-sysv4
-	exit ;;
+	GUESS=i860-stratus-sysv4
+	;;
     i*86:VOS:*:*)
 	# From Paul.Green at stratus.com.
-	echo ${UNAME_MACHINE}-stratus-vos
-	exit ;;
+	GUESS=$UNAME_MACHINE-stratus-vos
+	;;
     *:VOS:*:*)
 	# From Paul.Green at stratus.com.
-	echo hppa1.1-stratus-vos
-	exit ;;
+	GUESS=hppa1.1-stratus-vos
+	;;
     mc68*:A/UX:*:*)
-	echo m68k-apple-aux${UNAME_RELEASE}
-	exit ;;
+	GUESS=m68k-apple-aux$UNAME_RELEASE
+	;;
     news*:NEWS-OS:6*:*)
-	echo mips-sony-newsos6
-	exit ;;
+	GUESS=mips-sony-newsos6
+	;;
     R[34]000:*System_V*:*:* | R4000:UNIX_SYSV:*:* | R*000:UNIX_SV:*:*)
-	if [ -d /usr/nec ]; then
-		echo mips-nec-sysv${UNAME_RELEASE}
+	if test -d /usr/nec; then
+		GUESS=mips-nec-sysv$UNAME_RELEASE
 	else
-		echo mips-unknown-sysv${UNAME_RELEASE}
+		GUESS=mips-unknown-sysv$UNAME_RELEASE
 	fi
-	exit ;;
+	;;
     BeBox:BeOS:*:*)	# BeOS running on hardware made by Be, PPC only.
-	echo powerpc-be-beos
-	exit ;;
+	GUESS=powerpc-be-beos
+	;;
     BeMac:BeOS:*:*)	# BeOS running on Mac or Mac clone, PPC only.
-	echo powerpc-apple-beos
-	exit ;;
+	GUESS=powerpc-apple-beos
+	;;
     BePC:BeOS:*:*)	# BeOS running on Intel PC compatible.
-	echo i586-pc-beos
-	exit ;;
+	GUESS=i586-pc-beos
+	;;
     BePC:Haiku:*:*)	# Haiku running on Intel PC compatible.
-	echo i586-pc-haiku
-	exit ;;
-    x86_64:Haiku:*:*)
-	echo x86_64-unknown-haiku
-	exit ;;
+	GUESS=i586-pc-haiku
+	;;
+    ppc:Haiku:*:*)	# Haiku running on Apple PowerPC
+	GUESS=powerpc-apple-haiku
+	;;
+    *:Haiku:*:*)	# Haiku modern gcc (not bound by BeOS compat)
+	GUESS=$UNAME_MACHINE-unknown-haiku
+	;;
     SX-4:SUPER-UX:*:*)
-	echo sx4-nec-superux${UNAME_RELEASE}
-	exit ;;
+	GUESS=sx4-nec-superux$UNAME_RELEASE
+	;;
     SX-5:SUPER-UX:*:*)
-	echo sx5-nec-superux${UNAME_RELEASE}
-	exit ;;
+	GUESS=sx5-nec-superux$UNAME_RELEASE
+	;;
     SX-6:SUPER-UX:*:*)
-	echo sx6-nec-superux${UNAME_RELEASE}
-	exit ;;
+	GUESS=sx6-nec-superux$UNAME_RELEASE
+	;;
     SX-7:SUPER-UX:*:*)
-	echo sx7-nec-superux${UNAME_RELEASE}
-	exit ;;
+	GUESS=sx7-nec-superux$UNAME_RELEASE
+	;;
     SX-8:SUPER-UX:*:*)
-	echo sx8-nec-superux${UNAME_RELEASE}
-	exit ;;
+	GUESS=sx8-nec-superux$UNAME_RELEASE
+	;;
     SX-8R:SUPER-UX:*:*)
-	echo sx8r-nec-superux${UNAME_RELEASE}
-	exit ;;
+	GUESS=sx8r-nec-superux$UNAME_RELEASE
+	;;
+    SX-ACE:SUPER-UX:*:*)
+	GUESS=sxace-nec-superux$UNAME_RELEASE
+	;;
     Power*:Rhapsody:*:*)
-	echo powerpc-apple-rhapsody${UNAME_RELEASE}
-	exit ;;
+	GUESS=powerpc-apple-rhapsody$UNAME_RELEASE
+	;;
     *:Rhapsody:*:*)
-	echo ${UNAME_MACHINE}-apple-rhapsody${UNAME_RELEASE}
-	exit ;;
+	GUESS=$UNAME_MACHINE-apple-rhapsody$UNAME_RELEASE
+	;;
+    arm64:Darwin:*:*)
+	GUESS=aarch64-apple-darwin$UNAME_RELEASE
+	;;
     *:Darwin:*:*)
-	UNAME_PROCESSOR=`uname -p` || UNAME_PROCESSOR=unknown
-	eval $set_cc_for_build
-	if test "$UNAME_PROCESSOR" = unknown ; then
-	    UNAME_PROCESSOR=powerpc
+	UNAME_PROCESSOR=`uname -p`
+	case $UNAME_PROCESSOR in
+	    unknown) UNAME_PROCESSOR=powerpc ;;
+	esac
+	if command -v xcode-select > /dev/null 2> /dev/null && \
+		! xcode-select --print-path > /dev/null 2> /dev/null ; then
+	    # Avoid executing cc if there is no toolchain installed as
+	    # cc will be a stub that puts up a graphical alert
+	    # prompting the user to install developer tools.
+	    CC_FOR_BUILD=no_compiler_found
+	else
+	    set_cc_for_build
 	fi
-	if test `echo "$UNAME_RELEASE" | sed -e 's/\..*//'` -le 10 ; then
-	    if [ "$CC_FOR_BUILD" != 'no_compiler_found' ]; then
-		if (echo '#ifdef __LP64__'; echo IS_64BIT_ARCH; echo '#endif') | \
-		    (CCOPTS= $CC_FOR_BUILD -E - 2>/dev/null) | \
-		    grep IS_64BIT_ARCH >/dev/null
-		then
-		    case $UNAME_PROCESSOR in
-			i386) UNAME_PROCESSOR=x86_64 ;;
-			powerpc) UNAME_PROCESSOR=powerpc64 ;;
-		    esac
-		fi
+	if test "$CC_FOR_BUILD" != no_compiler_found; then
+	    if (echo '#ifdef __LP64__'; echo IS_64BIT_ARCH; echo '#endif') | \
+		   (CCOPTS="" $CC_FOR_BUILD -E - 2>/dev/null) | \
+		   grep IS_64BIT_ARCH >/dev/null
+	    then
+		case $UNAME_PROCESSOR in
+		    i386) UNAME_PROCESSOR=x86_64 ;;
+		    powerpc) UNAME_PROCESSOR=powerpc64 ;;
+		esac
+	    fi
+	    # On 10.4-10.6 one might compile for PowerPC via gcc -arch ppc
+	    if (echo '#ifdef __POWERPC__'; echo IS_PPC; echo '#endif') | \
+		   (CCOPTS="" $CC_FOR_BUILD -E - 2>/dev/null) | \
+		   grep IS_PPC >/dev/null
+	    then
+		UNAME_PROCESSOR=powerpc
 	    fi
 	elif test "$UNAME_PROCESSOR" = i386 ; then
-	    # Avoid executing cc on OS X 10.9, as it ships with a stub
-	    # that puts up a graphical alert prompting to install
-	    # developer tools.  Any system running Mac OS X 10.7 or
-	    # later (Darwin 11 and later) is required to have a 64-bit
-	    # processor. This is not true of the ARM version of Darwin
-	    # that Apple uses in portable devices.
-	    UNAME_PROCESSOR=x86_64
+	    # uname -m returns i386 or x86_64
+	    UNAME_PROCESSOR=$UNAME_MACHINE
 	fi
-	echo ${UNAME_PROCESSOR}-apple-darwin${UNAME_RELEASE}
-	exit ;;
+	GUESS=$UNAME_PROCESSOR-apple-darwin$UNAME_RELEASE
+	;;
     *:procnto*:*:* | *:QNX:[0123456789]*:*)
 	UNAME_PROCESSOR=`uname -p`
-	if test "$UNAME_PROCESSOR" = "x86"; then
+	if test "$UNAME_PROCESSOR" = x86; then
 		UNAME_PROCESSOR=i386
 		UNAME_MACHINE=pc
 	fi
-	echo ${UNAME_PROCESSOR}-${UNAME_MACHINE}-nto-qnx${UNAME_RELEASE}
-	exit ;;
+	GUESS=$UNAME_PROCESSOR-$UNAME_MACHINE-nto-qnx$UNAME_RELEASE
+	;;
     *:QNX:*:4*)
-	echo i386-pc-qnx
-	exit ;;
-    NEO-?:NONSTOP_KERNEL:*:*)
-	echo neo-tandem-nsk${UNAME_RELEASE}
-	exit ;;
+	GUESS=i386-pc-qnx
+	;;
+    NEO-*:NONSTOP_KERNEL:*:*)
+	GUESS=neo-tandem-nsk$UNAME_RELEASE
+	;;
     NSE-*:NONSTOP_KERNEL:*:*)
-	echo nse-tandem-nsk${UNAME_RELEASE}
-	exit ;;
-    NSR-?:NONSTOP_KERNEL:*:*)
-	echo nsr-tandem-nsk${UNAME_RELEASE}
-	exit ;;
+	GUESS=nse-tandem-nsk$UNAME_RELEASE
+	;;
+    NSR-*:NONSTOP_KERNEL:*:*)
+	GUESS=nsr-tandem-nsk$UNAME_RELEASE
+	;;
+    NSV-*:NONSTOP_KERNEL:*:*)
+	GUESS=nsv-tandem-nsk$UNAME_RELEASE
+	;;
+    NSX-*:NONSTOP_KERNEL:*:*)
+	GUESS=nsx-tandem-nsk$UNAME_RELEASE
+	;;
     *:NonStop-UX:*:*)
-	echo mips-compaq-nonstopux
-	exit ;;
+	GUESS=mips-compaq-nonstopux
+	;;
     BS2000:POSIX*:*:*)
-	echo bs2000-siemens-sysv
-	exit ;;
+	GUESS=bs2000-siemens-sysv
+	;;
     DS/*:UNIX_System_V:*:*)
-	echo ${UNAME_MACHINE}-${UNAME_SYSTEM}-${UNAME_RELEASE}
-	exit ;;
+	GUESS=$UNAME_MACHINE-$UNAME_SYSTEM-$UNAME_RELEASE
+	;;
     *:Plan9:*:*)
 	# "uname -m" is not consistent, so use $cputype instead. 386
 	# is converted to i386 for consistency with other x86
 	# operating systems.
-	if test "$cputype" = "386"; then
+	if test "${cputype-}" = 386; then
 	    UNAME_MACHINE=i386
-	else
-	    UNAME_MACHINE="$cputype"
+	elif test "x${cputype-}" != x; then
+	    UNAME_MACHINE=$cputype
 	fi
-	echo ${UNAME_MACHINE}-unknown-plan9
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-plan9
+	;;
     *:TOPS-10:*:*)
-	echo pdp10-unknown-tops10
-	exit ;;
+	GUESS=pdp10-unknown-tops10
+	;;
     *:TENEX:*:*)
-	echo pdp10-unknown-tenex
-	exit ;;
+	GUESS=pdp10-unknown-tenex
+	;;
     KS10:TOPS-20:*:* | KL10:TOPS-20:*:* | TYPE4:TOPS-20:*:*)
-	echo pdp10-dec-tops20
-	exit ;;
+	GUESS=pdp10-dec-tops20
+	;;
     XKL-1:TOPS-20:*:* | TYPE5:TOPS-20:*:*)
-	echo pdp10-xkl-tops20
-	exit ;;
+	GUESS=pdp10-xkl-tops20
+	;;
     *:TOPS-20:*:*)
-	echo pdp10-unknown-tops20
-	exit ;;
+	GUESS=pdp10-unknown-tops20
+	;;
     *:ITS:*:*)
-	echo pdp10-unknown-its
-	exit ;;
+	GUESS=pdp10-unknown-its
+	;;
     SEI:*:*:SEIUX)
-	echo mips-sei-seiux${UNAME_RELEASE}
-	exit ;;
+	GUESS=mips-sei-seiux$UNAME_RELEASE
+	;;
     *:DragonFly:*:*)
-	echo ${UNAME_MACHINE}-unknown-dragonfly`echo ${UNAME_RELEASE}|sed -e 's/[-(].*//'`
-	exit ;;
+	DRAGONFLY_REL=`echo "$UNAME_RELEASE" | sed -e 's/[-(].*//'`
+	GUESS=$UNAME_MACHINE-unknown-dragonfly$DRAGONFLY_REL
+	;;
     *:*VMS:*:*)
 	UNAME_MACHINE=`(uname -p) 2>/dev/null`
-	case "${UNAME_MACHINE}" in
-	    A*) echo alpha-dec-vms ; exit ;;
-	    I*) echo ia64-dec-vms ; exit ;;
-	    V*) echo vax-dec-vms ; exit ;;
+	case $UNAME_MACHINE in
+	    A*) GUESS=alpha-dec-vms ;;
+	    I*) GUESS=ia64-dec-vms ;;
+	    V*) GUESS=vax-dec-vms ;;
 	esac ;;
     *:XENIX:*:SysV)
-	echo i386-pc-xenix
-	exit ;;
+	GUESS=i386-pc-xenix
+	;;
     i*86:skyos:*:*)
-	echo ${UNAME_MACHINE}-pc-skyos`echo ${UNAME_RELEASE}` | sed -e 's/ .*$//'
-	exit ;;
+	SKYOS_REL=`echo "$UNAME_RELEASE" | sed -e 's/ .*$//'`
+	GUESS=$UNAME_MACHINE-pc-skyos$SKYOS_REL
+	;;
     i*86:rdos:*:*)
-	echo ${UNAME_MACHINE}-pc-rdos
-	exit ;;
-    i*86:AROS:*:*)
-	echo ${UNAME_MACHINE}-pc-aros
-	exit ;;
+	GUESS=$UNAME_MACHINE-pc-rdos
+	;;
+    i*86:Fiwix:*:*)
+	GUESS=$UNAME_MACHINE-pc-fiwix
+	;;
+    *:AROS:*:*)
+	GUESS=$UNAME_MACHINE-unknown-aros
+	;;
     x86_64:VMkernel:*:*)
-	echo ${UNAME_MACHINE}-unknown-esx
-	exit ;;
+	GUESS=$UNAME_MACHINE-unknown-esx
+	;;
+    amd64:Isilon\ OneFS:*:*)
+	GUESS=x86_64-unknown-onefs
+	;;
+    *:Unleashed:*:*)
+	GUESS=$UNAME_MACHINE-unknown-unleashed$UNAME_RELEASE
+	;;
 esac
 
-eval $set_cc_for_build
-cat >$dummy.c <<EOF
+# Do we have a guess based on uname results?
+if test "x$GUESS" != x; then
+    echo "$GUESS"
+    exit
+fi
+
+# No uname command or uname output not recognized.
+set_cc_for_build
+cat > "$dummy.c" <<EOF
 #ifdef _SEQUENT_
-# include <sys/types.h>
-# include <sys/utsname.h>
+#include <sys/types.h>
+#include <sys/utsname.h>
+#endif
+#if defined(ultrix) || defined(_ultrix) || defined(__ultrix) || defined(__ultrix__)
+#if defined (vax) || defined (__vax) || defined (__vax__) || defined(mips) || defined(__mips) || defined(__mips__) || defined(MIPS) || defined(__MIPS__)
+#include <signal.h>
+#if defined(_SIZE_T_) || defined(SIGLOST)
+#include <sys/utsname.h>
+#endif
+#endif
 #endif
 main ()
 {
@@ -1388,20 +1588,12 @@ main ()
 #include <sys/param.h>
   printf ("m68k-sony-newsos%s\n",
 #ifdef NEWSOS4
-	"4"
+  "4"
 #else
-	""
-#endif
-	); exit (0);
-#endif
+  ""
 #endif
-
-#if defined (__arm) && defined (__acorn) && defined (__unix)
-  printf ("arm-acorn-riscix\n"); exit (0);
+  ); exit (0);
 #endif
-
-#if defined (hp300) && !defined (hpux)
-  printf ("m68k-hp-bsd\n"); exit (0);
 #endif
 
 #if defined (NeXT)
@@ -1443,39 +1635,54 @@ main ()
 #endif
 
 #if defined (_SEQUENT_)
-    struct utsname un;
-
-    uname(&un);
-
-    if (strncmp(un.version, "V2", 2) == 0) {
-	printf ("i386-sequent-ptx2\n"); exit (0);
-    }
-    if (strncmp(un.version, "V1", 2) == 0) { /* XXX is V1 correct? */
-	printf ("i386-sequent-ptx1\n"); exit (0);
-    }
-    printf ("i386-sequent-ptx\n"); exit (0);
+  struct utsname un;
 
+  uname(&un);
+  if (strncmp(un.version, "V2", 2) == 0) {
+    printf ("i386-sequent-ptx2\n"); exit (0);
+  }
+  if (strncmp(un.version, "V1", 2) == 0) { /* XXX is V1 correct? */
+    printf ("i386-sequent-ptx1\n"); exit (0);
+  }
+  printf ("i386-sequent-ptx\n"); exit (0);
 #endif
 
 #if defined (vax)
-# if !defined (ultrix)
-#  include <sys/param.h>
-#  if defined (BSD)
-#   if BSD == 43
-      printf ("vax-dec-bsd4.3\n"); exit (0);
-#   else
-#    if BSD == 199006
-      printf ("vax-dec-bsd4.3reno\n"); exit (0);
-#    else
-      printf ("vax-dec-bsd\n"); exit (0);
-#    endif
-#   endif
-#  else
-    printf ("vax-dec-bsd\n"); exit (0);
-#  endif
-# else
-    printf ("vax-dec-ultrix\n"); exit (0);
-# endif
+#if !defined (ultrix)
+#include <sys/param.h>
+#if defined (BSD)
+#if BSD == 43
+  printf ("vax-dec-bsd4.3\n"); exit (0);
+#else
+#if BSD == 199006
+  printf ("vax-dec-bsd4.3reno\n"); exit (0);
+#else
+  printf ("vax-dec-bsd\n"); exit (0);
+#endif
+#endif
+#else
+  printf ("vax-dec-bsd\n"); exit (0);
+#endif
+#else
+#if defined(_SIZE_T_) || defined(SIGLOST)
+  struct utsname un;
+  uname (&un);
+  printf ("vax-dec-ultrix%s\n", un.release); exit (0);
+#else
+  printf ("vax-dec-ultrix\n"); exit (0);
+#endif
+#endif
+#endif
+#if defined(ultrix) || defined(_ultrix) || defined(__ultrix) || defined(__ultrix__)
+#if defined(mips) || defined(__mips) || defined(__mips__) || defined(MIPS) || defined(__MIPS__)
+#if defined(_SIZE_T_) || defined(SIGLOST)
+  struct utsname *un;
+  uname (&un);
+  printf ("mips-dec-ultrix%s\n", un.release); exit (0);
+#else
+  printf ("mips-dec-ultrix\n"); exit (0);
+#endif
+#endif
 #endif
 
 #if defined (alliant) && defined (i860)
@@ -1486,54 +1693,46 @@ main ()
 }
 EOF
 
-$CC_FOR_BUILD -o $dummy $dummy.c 2>/dev/null && SYSTEM_NAME=`$dummy` &&
+$CC_FOR_BUILD -o "$dummy" "$dummy.c" 2>/dev/null && SYSTEM_NAME=`"$dummy"` &&
 	{ echo "$SYSTEM_NAME"; exit; }
 
 # Apollos put the system type in the environment.
+test -d /usr/apollo && { echo "$ISP-apollo-$SYSTYPE"; exit; }
 
-test -d /usr/apollo && { echo ${ISP}-apollo-${SYSTYPE}; exit; }
+echo "$0: unable to guess system type" >&2
 
-# Convex versions that predate uname can use getsysinfo(1)
+case $UNAME_MACHINE:$UNAME_SYSTEM in
+    mips:Linux | mips64:Linux)
+	# If we got here on MIPS GNU/Linux, output extra information.
+	cat >&2 <<EOF
 
-if [ -x /usr/convex/getsysinfo ]
-then
-    case `getsysinfo -f cpu_type` in
-    c1*)
-	echo c1-convex-bsd
-	exit ;;
-    c2*)
-	if getsysinfo -f scalar_acc
-	then echo c32-convex-bsd
-	else echo c2-convex-bsd
-	fi
-	exit ;;
-    c34*)
-	echo c34-convex-bsd
-	exit ;;
-    c38*)
-	echo c38-convex-bsd
-	exit ;;
-    c4*)
-	echo c4-convex-bsd
-	exit ;;
-    esac
-fi
+NOTE: MIPS GNU/Linux systems require a C compiler to fully recognize
+the system type. Please install a C compiler and try again.
+EOF
+	;;
+esac
 
 cat >&2 <<EOF
-$0: unable to guess system type
 
-This script, last modified $timestamp, has failed to recognize
-the operating system you are using. It is advised that you
-download the most up to date version of the config scripts from
+This script (version $timestamp), has failed to recognize the
+operating system you are using. If your script is old, overwrite *all*
+copies of config.guess and config.sub with the latest versions from:
 
-  http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD
+  https://git.savannah.gnu.org/cgit/config.git/plain/config.guess
 and
-  http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD
+  https://git.savannah.gnu.org/cgit/config.git/plain/config.sub
+EOF
 
-If the version you run ($0) is already up to date, please
-send the following data and any information you think might be
-pertinent to <config-patches@gnu.org> in order to provide the needed
-information to handle your system.
+our_year=`echo $timestamp | sed 's,-.*,,'`
+thisyear=`date +%Y`
+# shellcheck disable=SC2003
+script_age=`expr "$thisyear" - "$our_year"`
+if test "$script_age" -lt 3 ; then
+   cat >&2 <<EOF
+
+If $0 has already been updated, send the following data and any
+information you think might be pertinent to config-patches@gnu.org to
+provide the necessary information to handle your system.
 
 config.guess timestamp = $timestamp
 
@@ -1552,16 +1751,17 @@ hostinfo               = `(hostinfo) 2>/dev/null`
 /usr/bin/oslevel       = `(/usr/bin/oslevel) 2>/dev/null`
 /usr/convex/getsysinfo = `(/usr/convex/getsysinfo) 2>/dev/null`
 
-UNAME_MACHINE = ${UNAME_MACHINE}
-UNAME_RELEASE = ${UNAME_RELEASE}
-UNAME_SYSTEM  = ${UNAME_SYSTEM}
-UNAME_VERSION = ${UNAME_VERSION}
+UNAME_MACHINE = "$UNAME_MACHINE"
+UNAME_RELEASE = "$UNAME_RELEASE"
+UNAME_SYSTEM  = "$UNAME_SYSTEM"
+UNAME_VERSION = "$UNAME_VERSION"
 EOF
+fi
 
 exit 1
 
 # Local variables:
-# eval: (add-hook 'write-file-hooks 'time-stamp)
+# eval: (add-hook 'before-save-hook 'time-stamp)
 # time-stamp-start: "timestamp='"
 # time-stamp-format: "%:y-%02m-%02d"
 # time-stamp-end: "'"
diff --git a/autoconf/config.sub b/autoconf/config.sub
index 092cff00e..b41da55df 100755
--- a/autoconf/config.sub
+++ b/autoconf/config.sub
@@ -1,12 +1,14 @@
-#! /bin/sh
+#!/usr/bin/sh
 # Configuration validation subroutine script.
-#   Copyright 1992-2014 Free Software Foundation, Inc.
+#   Copyright 1992-2022 Free Software Foundation, Inc.
 
-timestamp='2014-01-01'
+# shellcheck disable=SC2006,SC2268 # see below for rationale
+
+timestamp='2022-01-03'
 
 # This file is free software; you can redistribute it and/or modify it
 # under the terms of the GNU General Public License as published by
-# the Free Software Foundation; either version 3 of the License, or
+# the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 #
 # This program is distributed in the hope that it will be useful, but
@@ -15,7 +17,7 @@ timestamp='2014-01-01'
 # General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
-# along with this program; if not, see <http://www.gnu.org/licenses/>.
+# along with this program; if not, see <https://www.gnu.org/licenses/>.
 #
 # As a special exception to the GNU General Public License, if you
 # distribute this file as part of a program that contains a
@@ -25,7 +27,7 @@ timestamp='2014-01-01'
 # of the GNU General Public License, version 3 ("GPLv3").
 
 
-# Please send patches with a ChangeLog entry to config-patches at gnu.org.
+# Please send patches to <config-patches@gnu.org>.
 #
 # Configuration subroutine to validate and canonicalize a configuration type.
 # Supply the specified configuration type as an argument.
@@ -33,7 +35,7 @@ timestamp='2014-01-01'
 # Otherwise, we print the canonical config type on stdout and succeed.
 
 # You can get the latest version of this script from:
-# http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD
+# https://git.savannah.gnu.org/cgit/config.git/plain/config.sub
 
 # This file is supposed to be the same for all GNU packages
 # and recognize all the CPU types, system types and aliases
@@ -50,15 +52,21 @@ timestamp='2014-01-01'
 #	CPU_TYPE-MANUFACTURER-KERNEL-OPERATING_SYSTEM
 # It is wrong to echo any other type of specification.
 
+# The "shellcheck disable" line above the timestamp inhibits complaints
+# about features and limitations of the classic Bourne shell that were
+# superseded or lifted in POSIX.  However, this script identifies a wide
+# variety of pre-POSIX systems that do not have POSIX shells at all, and
+# even some reasonably current systems (Solaris 10 as case-in-point) still
+# have a pre-POSIX /bin/sh.
+
 me=`echo "$0" | sed -e 's,.*/,,'`
 
 usage="\
-Usage: $0 [OPTION] CPU-MFR-OPSYS
-       $0 [OPTION] ALIAS
+Usage: $0 [OPTION] CPU-MFR-OPSYS or ALIAS
 
 Canonicalize a configuration name.
 
-Operation modes:
+Options:
   -h, --help         print this help, then exit
   -t, --time-stamp   print date of last modification, then exit
   -v, --version      print version number, then exit
@@ -68,7 +76,7 @@ Report bugs and patches to <config-patches@gnu.org>."
 version="\
 GNU config.sub ($timestamp)
 
-Copyright 1992-2014 Free Software Foundation, Inc.
+Copyright 1992-2022 Free Software Foundation, Inc.
 
 This is free software; see the source for copying conditions.  There is NO
 warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE."
@@ -90,12 +98,12 @@ while test $# -gt 0 ; do
     - )	# Use stdin as input.
        break ;;
     -* )
-       echo "$me: invalid option $1$help"
+       echo "$me: invalid option $1$help" >&2
        exit 1 ;;
 
     *local*)
        # First pass through any local machine types.
-       echo $1
+       echo "$1"
        exit ;;
 
     * )
@@ -111,1211 +119,1186 @@ case $# in
     exit 1;;
 esac
 
-# Separate what the user gave into CPU-COMPANY and OS or KERNEL-OS (if any).
-# Here we must recognize all the valid KERNEL-OS combinations.
-maybe_os=`echo $1 | sed 's/^\(.*\)-\([^-]*-[^-]*\)$/\2/'`
-case $maybe_os in
-  nto-qnx* | linux-gnu* | linux-android* | linux-dietlibc | linux-newlib* | \
-  linux-musl* | linux-uclibc* | uclinux-uclibc* | uclinux-gnu* | kfreebsd*-gnu* | \
-  knetbsd*-gnu* | netbsd*-gnu* | \
-  kopensolaris*-gnu* | \
-  storm-chaos* | os2-emx* | rtmk-nova*)
-    os=-$maybe_os
-    basic_machine=`echo $1 | sed 's/^\(.*\)-\([^-]*-[^-]*\)$/\1/'`
-    ;;
-  android-linux)
-    os=-linux-android
-    basic_machine=`echo $1 | sed 's/^\(.*\)-\([^-]*-[^-]*\)$/\1/'`-unknown
-    ;;
-  *)
-    basic_machine=`echo $1 | sed 's/-[^-]*$//'`
-    if [ $basic_machine != $1 ]
-    then os=`echo $1 | sed 's/.*-/-/'`
-    else os=; fi
-    ;;
-esac
+# Split fields of configuration type
+# shellcheck disable=SC2162
+saved_IFS=$IFS
+IFS="-" read field1 field2 field3 field4 <<EOF
+$1
+EOF
+IFS=$saved_IFS
 
-### Let's recognize common machines as not being operating systems so
-### that things like config.sub decstation-3100 work.  We also
-### recognize some manufacturers as not being operating systems, so we
-### can provide default operating systems below.
-case $os in
-	-sun*os*)
-		# Prevent following clause from handling this invalid input.
-		;;
-	-dec* | -mips* | -sequent* | -encore* | -pc532* | -sgi* | -sony* | \
-	-att* | -7300* | -3300* | -delta* | -motorola* | -sun[234]* | \
-	-unicom* | -ibm* | -next | -hp | -isi* | -apollo | -altos* | \
-	-convergent* | -ncr* | -news | -32* | -3600* | -3100* | -hitachi* |\
-	-c[123]* | -convex* | -sun | -crds | -omron* | -dg | -ultra | -tti* | \
-	-harris | -dolphin | -highlevel | -gould | -cbm | -ns | -masscomp | \
-	-apple | -axis | -knuth | -cray | -microblaze*)
-		os=
-		basic_machine=$1
-		;;
-	-bluegene*)
-		os=-cnk
-		;;
-	-sim | -cisco | -oki | -wec | -winbond)
-		os=
-		basic_machine=$1
-		;;
-	-scout)
-		;;
-	-wrs)
-		os=-vxworks
-		basic_machine=$1
-		;;
-	-chorusos*)
-		os=-chorusos
-		basic_machine=$1
-		;;
-	-chorusrdb)
-		os=-chorusrdb
-		basic_machine=$1
-		;;
-	-hiux*)
-		os=-hiuxwe2
-		;;
-	-sco6)
-		os=-sco5v6
-		basic_machine=`echo $1 | sed -e 's/86-.*/86-pc/'`
-		;;
-	-sco5)
-		os=-sco3.2v5
-		basic_machine=`echo $1 | sed -e 's/86-.*/86-pc/'`
-		;;
-	-sco4)
-		os=-sco3.2v4
-		basic_machine=`echo $1 | sed -e 's/86-.*/86-pc/'`
-		;;
-	-sco3.2.[4-9]*)
-		os=`echo $os | sed -e 's/sco3.2./sco3.2v/'`
-		basic_machine=`echo $1 | sed -e 's/86-.*/86-pc/'`
-		;;
-	-sco3.2v[4-9]*)
-		# Don't forget version if it is 3.2v4 or newer.
-		basic_machine=`echo $1 | sed -e 's/86-.*/86-pc/'`
-		;;
-	-sco5v6*)
-		# Don't forget version if it is 3.2v4 or newer.
-		basic_machine=`echo $1 | sed -e 's/86-.*/86-pc/'`
-		;;
-	-sco*)
-		os=-sco3.2v2
-		basic_machine=`echo $1 | sed -e 's/86-.*/86-pc/'`
-		;;
-	-udk*)
-		basic_machine=`echo $1 | sed -e 's/86-.*/86-pc/'`
-		;;
-	-isc)
-		os=-isc2.2
-		basic_machine=`echo $1 | sed -e 's/86-.*/86-pc/'`
-		;;
-	-clix*)
-		basic_machine=clipper-intergraph
-		;;
-	-isc*)
-		basic_machine=`echo $1 | sed -e 's/86-.*/86-pc/'`
-		;;
-	-lynx*178)
-		os=-lynxos178
-		;;
-	-lynx*5)
-		os=-lynxos5
-		;;
-	-lynx*)
-		os=-lynxos
+# Separate into logical components for further validation
+case $1 in
+	*-*-*-*-*)
+		echo Invalid configuration \`"$1"\': more than four components >&2
+		exit 1
 		;;
-	-ptx*)
-		basic_machine=`echo $1 | sed -e 's/86-.*/86-sequent/'`
+	*-*-*-*)
+		basic_machine=$field1-$field2
+		basic_os=$field3-$field4
 		;;
-	-windowsnt*)
-		os=`echo $os | sed -e 's/windowsnt/winnt/'`
+	*-*-*)
+		# Ambiguous whether COMPANY is present, or skipped and KERNEL-OS is two
+		# parts
+		maybe_os=$field2-$field3
+		case $maybe_os in
+			nto-qnx* | linux-* | uclinux-uclibc* \
+			| uclinux-gnu* | kfreebsd*-gnu* | knetbsd*-gnu* | netbsd*-gnu* \
+			| netbsd*-eabi* | kopensolaris*-gnu* | cloudabi*-eabi* \
+			| storm-chaos* | os2-emx* | rtmk-nova*)
+				basic_machine=$field1
+				basic_os=$maybe_os
+				;;
+			android-linux)
+				basic_machine=$field1-unknown
+				basic_os=linux-android
+				;;
+			*)
+				basic_machine=$field1-$field2
+				basic_os=$field3
+				;;
+		esac
 		;;
-	-psos*)
-		os=-psos
+	*-*)
+		# A lone config we happen to match not fitting any pattern
+		case $field1-$field2 in
+			decstation-3100)
+				basic_machine=mips-dec
+				basic_os=
+				;;
+			*-*)
+				# Second component is usually, but not always the OS
+				case $field2 in
+					# Prevent following clause from handling this valid os
+					sun*os*)
+						basic_machine=$field1
+						basic_os=$field2
+						;;
+					zephyr*)
+						basic_machine=$field1-unknown
+						basic_os=$field2
+						;;
+					# Manufacturers
+					dec* | mips* | sequent* | encore* | pc533* | sgi* | sony* \
+					| att* | 7300* | 3300* | delta* | motorola* | sun[234]* \
+					| unicom* | ibm* | next | hp | isi* | apollo | altos* \
+					| convergent* | ncr* | news | 32* | 3600* | 3100* \
+					| hitachi* | c[123]* | convex* | sun | crds | omron* | dg \
+					| ultra | tti* | harris | dolphin | highlevel | gould \
+					| cbm | ns | masscomp | apple | axis | knuth | cray \
+					| microblaze* | sim | cisco \
+					| oki | wec | wrs | winbond)
+						basic_machine=$field1-$field2
+						basic_os=
+						;;
+					*)
+						basic_machine=$field1
+						basic_os=$field2
+						;;
+				esac
+			;;
+		esac
 		;;
-	-mint | -mint[0-9]*)
-		basic_machine=m68k-atari
-		os=-mint
+	*)
+		# Convert single-component short-hands not valid as part of
+		# multi-component configurations.
+		case $field1 in
+			386bsd)
+				basic_machine=i386-pc
+				basic_os=bsd
+				;;
+			a29khif)
+				basic_machine=a29k-amd
+				basic_os=udi
+				;;
+			adobe68k)
+				basic_machine=m68010-adobe
+				basic_os=scout
+				;;
+			alliant)
+				basic_machine=fx80-alliant
+				basic_os=
+				;;
+			altos | altos3068)
+				basic_machine=m68k-altos
+				basic_os=
+				;;
+			am29k)
+				basic_machine=a29k-none
+				basic_os=bsd
+				;;
+			amdahl)
+				basic_machine=580-amdahl
+				basic_os=sysv
+				;;
+			amiga)
+				basic_machine=m68k-unknown
+				basic_os=
+				;;
+			amigaos | amigados)
+				basic_machine=m68k-unknown
+				basic_os=amigaos
+				;;
+			amigaunix | amix)
+				basic_machine=m68k-unknown
+				basic_os=sysv4
+				;;
+			apollo68)
+				basic_machine=m68k-apollo
+				basic_os=sysv
+				;;
+			apollo68bsd)
+				basic_machine=m68k-apollo
+				basic_os=bsd
+				;;
+			aros)
+				basic_machine=i386-pc
+				basic_os=aros
+				;;
+			aux)
+				basic_machine=m68k-apple
+				basic_os=aux
+				;;
+			balance)
+				basic_machine=ns32k-sequent
+				basic_os=dynix
+				;;
+			blackfin)
+				basic_machine=bfin-unknown
+				basic_os=linux
+				;;
+			cegcc)
+				basic_machine=arm-unknown
+				basic_os=cegcc
+				;;
+			convex-c1)
+				basic_machine=c1-convex
+				basic_os=bsd
+				;;
+			convex-c2)
+				basic_machine=c2-convex
+				basic_os=bsd
+				;;
+			convex-c32)
+				basic_machine=c32-convex
+				basic_os=bsd
+				;;
+			convex-c34)
+				basic_machine=c34-convex
+				basic_os=bsd
+				;;
+			convex-c38)
+				basic_machine=c38-convex
+				basic_os=bsd
+				;;
+			cray)
+				basic_machine=j90-cray
+				basic_os=unicos
+				;;
+			crds | unos)
+				basic_machine=m68k-crds
+				basic_os=
+				;;
+			da30)
+				basic_machine=m68k-da30
+				basic_os=
+				;;
+			decstation | pmax | pmin | dec3100 | decstatn)
+				basic_machine=mips-dec
+				basic_os=
+				;;
+			delta88)
+				basic_machine=m88k-motorola
+				basic_os=sysv3
+				;;
+			dicos)
+				basic_machine=i686-pc
+				basic_os=dicos
+				;;
+			djgpp)
+				basic_machine=i586-pc
+				basic_os=msdosdjgpp
+				;;
+			ebmon29k)
+				basic_machine=a29k-amd
+				basic_os=ebmon
+				;;
+			es1800 | OSE68k | ose68k | ose | OSE)
+				basic_machine=m68k-ericsson
+				basic_os=ose
+				;;
+			gmicro)
+				basic_machine=tron-gmicro
+				basic_os=sysv
+				;;
+			go32)
+				basic_machine=i386-pc
+				basic_os=go32
+				;;
+			h8300hms)
+				basic_machine=h8300-hitachi
+				basic_os=hms
+				;;
+			h8300xray)
+				basic_machine=h8300-hitachi
+				basic_os=xray
+				;;
+			h8500hms)
+				basic_machine=h8500-hitachi
+				basic_os=hms
+				;;
+			harris)
+				basic_machine=m88k-harris
+				basic_os=sysv3
+				;;
+			hp300 | hp300hpux)
+				basic_machine=m68k-hp
+				basic_os=hpux
+				;;
+			hp300bsd)
+				basic_machine=m68k-hp
+				basic_os=bsd
+				;;
+			hppaosf)
+				basic_machine=hppa1.1-hp
+				basic_os=osf
+				;;
+			hppro)
+				basic_machine=hppa1.1-hp
+				basic_os=proelf
+				;;
+			i386mach)
+				basic_machine=i386-mach
+				basic_os=mach
+				;;
+			isi68 | isi)
+				basic_machine=m68k-isi
+				basic_os=sysv
+				;;
+			m68knommu)
+				basic_machine=m68k-unknown
+				basic_os=linux
+				;;
+			magnum | m3230)
+				basic_machine=mips-mips
+				basic_os=sysv
+				;;
+			merlin)
+				basic_machine=ns32k-utek
+				basic_os=sysv
+				;;
+			mingw64)
+				basic_machine=x86_64-pc
+				basic_os=mingw64
+				;;
+			mingw32)
+				basic_machine=i686-pc
+				basic_os=mingw32
+				;;
+			mingw32ce)
+				basic_machine=arm-unknown
+				basic_os=mingw32ce
+				;;
+			monitor)
+				basic_machine=m68k-rom68k
+				basic_os=coff
+				;;
+			morphos)
+				basic_machine=powerpc-unknown
+				basic_os=morphos
+				;;
+			moxiebox)
+				basic_machine=moxie-unknown
+				basic_os=moxiebox
+				;;
+			msdos)
+				basic_machine=i386-pc
+				basic_os=msdos
+				;;
+			msys)
+				basic_machine=i686-pc
+				basic_os=msys
+				;;
+			mvs)
+				basic_machine=i370-ibm
+				basic_os=mvs
+				;;
+			nacl)
+				basic_machine=le32-unknown
+				basic_os=nacl
+				;;
+			ncr3000)
+				basic_machine=i486-ncr
+				basic_os=sysv4
+				;;
+			netbsd386)
+				basic_machine=i386-pc
+				basic_os=netbsd
+				;;
+			netwinder)
+				basic_machine=armv4l-rebel
+				basic_os=linux
+				;;
+			news | news700 | news800 | news900)
+				basic_machine=m68k-sony
+				basic_os=newsos
+				;;
+			news1000)
+				basic_machine=m68030-sony
+				basic_os=newsos
+				;;
+			necv70)
+				basic_machine=v70-nec
+				basic_os=sysv
+				;;
+			nh3000)
+				basic_machine=m68k-harris
+				basic_os=cxux
+				;;
+			nh[45]000)
+				basic_machine=m88k-harris
+				basic_os=cxux
+				;;
+			nindy960)
+				basic_machine=i960-intel
+				basic_os=nindy
+				;;
+			mon960)
+				basic_machine=i960-intel
+				basic_os=mon960
+				;;
+			nonstopux)
+				basic_machine=mips-compaq
+				basic_os=nonstopux
+				;;
+			os400)
+				basic_machine=powerpc-ibm
+				basic_os=os400
+				;;
+			OSE68000 | ose68000)
+				basic_machine=m68000-ericsson
+				basic_os=ose
+				;;
+			os68k)
+				basic_machine=m68k-none
+				basic_os=os68k
+				;;
+			paragon)
+				basic_machine=i860-intel
+				basic_os=osf
+				;;
+			parisc)
+				basic_machine=hppa-unknown
+				basic_os=linux
+				;;
+			psp)
+				basic_machine=mipsallegrexel-sony
+				basic_os=psp
+				;;
+			pw32)
+				basic_machine=i586-unknown
+				basic_os=pw32
+				;;
+			rdos | rdos64)
+				basic_machine=x86_64-pc
+				basic_os=rdos
+				;;
+			rdos32)
+				basic_machine=i386-pc
+				basic_os=rdos
+				;;
+			rom68k)
+				basic_machine=m68k-rom68k
+				basic_os=coff
+				;;
+			sa29200)
+				basic_machine=a29k-amd
+				basic_os=udi
+				;;
+			sei)
+				basic_machine=mips-sei
+				basic_os=seiux
+				;;
+			sequent)
+				basic_machine=i386-sequent
+				basic_os=
+				;;
+			sps7)
+				basic_machine=m68k-bull
+				basic_os=sysv2
+				;;
+			st2000)
+				basic_machine=m68k-tandem
+				basic_os=
+				;;
+			stratus)
+				basic_machine=i860-stratus
+				basic_os=sysv4
+				;;
+			sun2)
+				basic_machine=m68000-sun
+				basic_os=
+				;;
+			sun2os3)
+				basic_machine=m68000-sun
+				basic_os=sunos3
+				;;
+			sun2os4)
+				basic_machine=m68000-sun
+				basic_os=sunos4
+				;;
+			sun3)
+				basic_machine=m68k-sun
+				basic_os=
+				;;
+			sun3os3)
+				basic_machine=m68k-sun
+				basic_os=sunos3
+				;;
+			sun3os4)
+				basic_machine=m68k-sun
+				basic_os=sunos4
+				;;
+			sun4)
+				basic_machine=sparc-sun
+				basic_os=
+				;;
+			sun4os3)
+				basic_machine=sparc-sun
+				basic_os=sunos3
+				;;
+			sun4os4)
+				basic_machine=sparc-sun
+				basic_os=sunos4
+				;;
+			sun4sol2)
+				basic_machine=sparc-sun
+				basic_os=solaris2
+				;;
+			sun386 | sun386i | roadrunner)
+				basic_machine=i386-sun
+				basic_os=
+				;;
+			sv1)
+				basic_machine=sv1-cray
+				basic_os=unicos
+				;;
+			symmetry)
+				basic_machine=i386-sequent
+				basic_os=dynix
+				;;
+			t3e)
+				basic_machine=alphaev5-cray
+				basic_os=unicos
+				;;
+			t90)
+				basic_machine=t90-cray
+				basic_os=unicos
+				;;
+			toad1)
+				basic_machine=pdp10-xkl
+				basic_os=tops20
+				;;
+			tpf)
+				basic_machine=s390x-ibm
+				basic_os=tpf
+				;;
+			udi29k)
+				basic_machine=a29k-amd
+				basic_os=udi
+				;;
+			ultra3)
+				basic_machine=a29k-nyu
+				basic_os=sym1
+				;;
+			v810 | necv810)
+				basic_machine=v810-nec
+				basic_os=none
+				;;
+			vaxv)
+				basic_machine=vax-dec
+				basic_os=sysv
+				;;
+			vms)
+				basic_machine=vax-dec
+				basic_os=vms
+				;;
+			vsta)
+				basic_machine=i386-pc
+				basic_os=vsta
+				;;
+			vxworks960)
+				basic_machine=i960-wrs
+				basic_os=vxworks
+				;;
+			vxworks68)
+				basic_machine=m68k-wrs
+				basic_os=vxworks
+				;;
+			vxworks29k)
+				basic_machine=a29k-wrs
+				basic_os=vxworks
+				;;
+			xbox)
+				basic_machine=i686-pc
+				basic_os=mingw32
+				;;
+			ymp)
+				basic_machine=ymp-cray
+				basic_os=unicos
+				;;
+			*)
+				basic_machine=$1
+				basic_os=
+				;;
+		esac
 		;;
 esac
 
-# Decode aliases for certain CPU-COMPANY combinations.
+# Decode 1-component or ad-hoc basic machines
 case $basic_machine in
-	# Recognize the basic CPU types without company name.
-	# Some are omitted here because they have special meanings below.
-	1750a | 580 \
-	| a29k \
-	| aarch64 | aarch64_be \
-	| alpha | alphaev[4-8] | alphaev56 | alphaev6[78] | alphapca5[67] \
-	| alpha64 | alpha64ev[4-8] | alpha64ev56 | alpha64ev6[78] | alpha64pca5[67] \
-	| am33_2.0 \
-	| arc | arceb \
-	| arm | arm[bl]e | arme[lb] | armv[2-8] | armv[3-8][lb] | armv7[arm] \
-	| avr | avr32 \
-	| be32 | be64 \
-	| bfin \
-	| c4x | c8051 | clipper \
-	| d10v | d30v | dlx | dsp16xx \
-	| epiphany \
-	| fido | fr30 | frv \
-	| h8300 | h8500 | hppa | hppa1.[01] | hppa2.0 | hppa2.0[nw] | hppa64 \
-	| hexagon \
-	| i370 | i860 | i960 | ia64 \
-	| ip2k | iq2000 \
-	| k1om \
-	| le32 | le64 \
-	| lm32 \
-	| m32c | m32r | m32rle | m68000 | m68k | m88k \
-	| maxq | mb | microblaze | microblazeel | mcore | mep | metag \
-	| mips | mipsbe | mipseb | mipsel | mipsle \
-	| mips16 \
-	| mips64 | mips64el \
-	| mips64octeon | mips64octeonel \
-	| mips64orion | mips64orionel \
-	| mips64r5900 | mips64r5900el \
-	| mips64vr | mips64vrel \
-	| mips64vr4100 | mips64vr4100el \
-	| mips64vr4300 | mips64vr4300el \
-	| mips64vr5000 | mips64vr5000el \
-	| mips64vr5900 | mips64vr5900el \
-	| mipsisa32 | mipsisa32el \
-	| mipsisa32r2 | mipsisa32r2el \
-	| mipsisa64 | mipsisa64el \
-	| mipsisa64r2 | mipsisa64r2el \
-	| mipsisa64sb1 | mipsisa64sb1el \
-	| mipsisa64sr71k | mipsisa64sr71kel \
-	| mipsr5900 | mipsr5900el \
-	| mipstx39 | mipstx39el \
-	| mn10200 | mn10300 \
-	| moxie \
-	| mt \
-	| msp430 \
-	| nds32 | nds32le | nds32be \
-	| nios | nios2 | nios2eb | nios2el \
-	| ns16k | ns32k \
-	| open8 \
-	| or1k | or32 \
-	| pdp10 | pdp11 | pj | pjl \
-	| powerpc | powerpc64 | powerpc64le | powerpcle \
-	| pyramid \
-	| rl78 | rx \
-	| score \
-	| sh | sh[1234] | sh[24]a | sh[24]aeb | sh[23]e | sh[34]eb | sheb | shbe | shle | sh[1234]le | sh3ele \
-	| sh64 | sh64le \
-	| sparc | sparc64 | sparc64b | sparc64v | sparc86x | sparclet | sparclite \
-	| sparcv8 | sparcv9 | sparcv9b | sparcv9v \
-	| spu \
-	| tahoe | tic4x | tic54x | tic55x | tic6x | tic80 | tron \
-	| ubicom32 \
-	| v850 | v850e | v850e1 | v850e2 | v850es | v850e2v3 \
-	| we32k \
-	| x86 | xc16x | xstormy16 | xtensa \
-	| z8k | z80)
-		basic_machine=$basic_machine-unknown
-		;;
-	c54x)
-		basic_machine=tic54x-unknown
-		;;
-	c55x)
-		basic_machine=tic55x-unknown
-		;;
-	c6x)
-		basic_machine=tic6x-unknown
-		;;
-	m6811 | m68hc11 | m6812 | m68hc12 | m68hcs12x | nvptx | picochip)
-		basic_machine=$basic_machine-unknown
-		os=-none
-		;;
-	m88110 | m680[12346]0 | m683?2 | m68360 | m5200 | v70 | w65 | z8k)
-		;;
-	ms1)
-		basic_machine=mt-unknown
+	# Here we handle the default manufacturer of certain CPU types.  It is in
+	# some cases the only manufacturer, in others, it is the most popular.
+	w89k)
+		cpu=hppa1.1
+		vendor=winbond
 		;;
-
-	strongarm | thumb | xscale)
-		basic_machine=arm-unknown
+	op50n)
+		cpu=hppa1.1
+		vendor=oki
 		;;
-	xgate)
-		basic_machine=$basic_machine-unknown
-		os=-none
+	op60c)
+		cpu=hppa1.1
+		vendor=oki
 		;;
-	xscaleeb)
-		basic_machine=armeb-unknown
+	ibm*)
+		cpu=i370
+		vendor=ibm
 		;;
-
-	xscaleel)
-		basic_machine=armel-unknown
+	orion105)
+		cpu=clipper
+		vendor=highlevel
 		;;
-
-	# We use `pc' rather than `unknown'
-	# because (1) that's what they normally are, and
-	# (2) the word "unknown" tends to confuse beginning users.
-	i*86 | x86_64)
-	  basic_machine=$basic_machine-pc
-	  ;;
-	# Object if more than one company name word.
-	*-*-*)
-		echo Invalid configuration \`$1\': machine \`$basic_machine\' not recognized 1>&2
-		exit 1
+	mac | mpw | mac-mpw)
+		cpu=m68k
+		vendor=apple
 		;;
-	# Recognize the basic CPU types with company name.
-	580-* \
-	| a29k-* \
-	| aarch64-* | aarch64_be-* \
-	| alpha-* | alphaev[4-8]-* | alphaev56-* | alphaev6[78]-* \
-	| alpha64-* | alpha64ev[4-8]-* | alpha64ev56-* | alpha64ev6[78]-* \
-	| alphapca5[67]-* | alpha64pca5[67]-* | arc-* | arceb-* \
-	| arm-*  | armbe-* | armle-* | armeb-* | armv*-* \
-	| avr-* | avr32-* \
-	| be32-* | be64-* \
-	| bfin-* | bs2000-* \
-	| c[123]* | c30-* | [cjt]90-* | c4x-* \
-	| c8051-* | clipper-* | craynv-* | cydra-* \
-	| d10v-* | d30v-* | dlx-* \
-	| elxsi-* \
-	| f30[01]-* | f700-* | fido-* | fr30-* | frv-* | fx80-* \
-	| h8300-* | h8500-* \
-	| hppa-* | hppa1.[01]-* | hppa2.0-* | hppa2.0[nw]-* | hppa64-* \
-	| hexagon-* \
-	| i*86-* | i860-* | i960-* | ia64-* \
-	| ip2k-* | iq2000-* \
-	| k1om-* \
-	| le32-* | le64-* \
-	| lm32-* \
-	| m32c-* | m32r-* | m32rle-* \
-	| m68000-* | m680[012346]0-* | m68360-* | m683?2-* | m68k-* \
-	| m88110-* | m88k-* | maxq-* | mcore-* | metag-* \
-	| microblaze-* | microblazeel-* \
-	| mips-* | mipsbe-* | mipseb-* | mipsel-* | mipsle-* \
-	| mips16-* \
-	| mips64-* | mips64el-* \
-	| mips64octeon-* | mips64octeonel-* \
-	| mips64orion-* | mips64orionel-* \
-	| mips64r5900-* | mips64r5900el-* \
-	| mips64vr-* | mips64vrel-* \
-	| mips64vr4100-* | mips64vr4100el-* \
-	| mips64vr4300-* | mips64vr4300el-* \
-	| mips64vr5000-* | mips64vr5000el-* \
-	| mips64vr5900-* | mips64vr5900el-* \
-	| mipsisa32-* | mipsisa32el-* \
-	| mipsisa32r2-* | mipsisa32r2el-* \
-	| mipsisa64-* | mipsisa64el-* \
-	| mipsisa64r2-* | mipsisa64r2el-* \
-	| mipsisa64sb1-* | mipsisa64sb1el-* \
-	| mipsisa64sr71k-* | mipsisa64sr71kel-* \
-	| mipsr5900-* | mipsr5900el-* \
-	| mipstx39-* | mipstx39el-* \
-	| mmix-* \
-	| mt-* \
-	| msp430-* \
-	| nds32-* | nds32le-* | nds32be-* \
-	| nios-* | nios2-* | nios2eb-* | nios2el-* \
-	| none-* | np1-* | ns16k-* | ns32k-* \
-	| open8-* \
-	| orion-* \
-	| pdp10-* | pdp11-* | pj-* | pjl-* | pn-* | power-* \
-	| powerpc-* | powerpc64-* | powerpc64le-* | powerpcle-* \
-	| pyramid-* \
-	| rl78-* | romp-* | rs6000-* | rx-* \
-	| sh-* | sh[1234]-* | sh[24]a-* | sh[24]aeb-* | sh[23]e-* | sh[34]eb-* | sheb-* | shbe-* \
-	| shle-* | sh[1234]le-* | sh3ele-* | sh64-* | sh64le-* \
-	| sparc-* | sparc64-* | sparc64b-* | sparc64v-* | sparc86x-* | sparclet-* \
-	| sparclite-* \
-	| sparcv8-* | sparcv9-* | sparcv9b-* | sparcv9v-* | sv1-* | sx?-* \
-	| tahoe-* \
-	| tic30-* | tic4x-* | tic54x-* | tic55x-* | tic6x-* | tic80-* \
-	| tile*-* \
-	| tron-* \
-	| ubicom32-* \
-	| v850-* | v850e-* | v850e1-* | v850es-* | v850e2-* | v850e2v3-* \
-	| vax-* \
-	| we32k-* \
-	| x86-* | x86_64-* | xc16x-* | xps100-* \
-	| xstormy16-* | xtensa*-* \
-	| ymp-* \
-	| z8k-* | z80-*)
-		;;
-	# Recognize the basic CPU types without company name, with glob match.
-	xtensa*)
-		basic_machine=$basic_machine-unknown
+	pmac | pmac-mpw)
+		cpu=powerpc
+		vendor=apple
 		;;
+
 	# Recognize the various machine names and aliases which stand
 	# for a CPU type and a company and sometimes even an OS.
-	386bsd)
-		basic_machine=i386-unknown
-		os=-bsd
-		;;
 	3b1 | 7300 | 7300-att | att-7300 | pc7300 | safari | unixpc)
-		basic_machine=m68000-att
+		cpu=m68000
+		vendor=att
 		;;
 	3b*)
-		basic_machine=we32k-att
-		;;
-	a29khif)
-		basic_machine=a29k-amd
-		os=-udi
-		;;
-	abacus)
-		basic_machine=abacus-unknown
-		;;
-	adobe68k)
-		basic_machine=m68010-adobe
-		os=-scout
-		;;
-	alliant | fx80)
-		basic_machine=fx80-alliant
-		;;
-	altos | altos3068)
-		basic_machine=m68k-altos
-		;;
-	am29k)
-		basic_machine=a29k-none
-		os=-bsd
-		;;
-	amd64)
-		basic_machine=x86_64-pc
-		;;
-	amd64-*)
-		basic_machine=x86_64-`echo $basic_machine | sed 's/^[^-]*-//'`
-		;;
-	amdahl)
-		basic_machine=580-amdahl
-		os=-sysv
-		;;
-	amiga | amiga-*)
-		basic_machine=m68k-unknown
-		;;
-	amigaos | amigados)
-		basic_machine=m68k-unknown
-		os=-amigaos
-		;;
-	amigaunix | amix)
-		basic_machine=m68k-unknown
-		os=-sysv4
-		;;
-	apollo68)
-		basic_machine=m68k-apollo
-		os=-sysv
-		;;
-	apollo68bsd)
-		basic_machine=m68k-apollo
-		os=-bsd
-		;;
-	aros)
-		basic_machine=i386-pc
-		os=-aros
-		;;
-	aux)
-		basic_machine=m68k-apple
-		os=-aux
-		;;
-	balance)
-		basic_machine=ns32k-sequent
-		os=-dynix
-		;;
-	blackfin)
-		basic_machine=bfin-unknown
-		os=-linux
-		;;
-	blackfin-*)
-		basic_machine=bfin-`echo $basic_machine | sed 's/^[^-]*-//'`
-		os=-linux
+		cpu=we32k
+		vendor=att
 		;;
 	bluegene*)
-		basic_machine=powerpc-ibm
-		os=-cnk
-		;;
-	c54x-*)
-		basic_machine=tic54x-`echo $basic_machine | sed 's/^[^-]*-//'`
-		;;
-	c55x-*)
-		basic_machine=tic55x-`echo $basic_machine | sed 's/^[^-]*-//'`
-		;;
-	c6x-*)
-		basic_machine=tic6x-`echo $basic_machine | sed 's/^[^-]*-//'`
-		;;
-	c90)
-		basic_machine=c90-cray
-		os=-unicos
-		;;
-	cegcc)
-		basic_machine=arm-unknown
-		os=-cegcc
-		;;
-	convex-c1)
-		basic_machine=c1-convex
-		os=-bsd
-		;;
-	convex-c2)
-		basic_machine=c2-convex
-		os=-bsd
-		;;
-	convex-c32)
-		basic_machine=c32-convex
-		os=-bsd
-		;;
-	convex-c34)
-		basic_machine=c34-convex
-		os=-bsd
-		;;
-	convex-c38)
-		basic_machine=c38-convex
-		os=-bsd
-		;;
-	cray | j90)
-		basic_machine=j90-cray
-		os=-unicos
-		;;
-	craynv)
-		basic_machine=craynv-cray
-		os=-unicosmp
-		;;
-	cr16 | cr16-*)
-		basic_machine=cr16-unknown
-		os=-elf
-		;;
-	crds | unos)
-		basic_machine=m68k-crds
-		;;
-	crisv32 | crisv32-* | etraxfs*)
-		basic_machine=crisv32-axis
-		;;
-	cris | cris-* | etrax*)
-		basic_machine=cris-axis
-		;;
-	crx)
-		basic_machine=crx-unknown
-		os=-elf
-		;;
-	da30 | da30-*)
-		basic_machine=m68k-da30
-		;;
-	decstation | decstation-3100 | pmax | pmax-* | pmin | dec3100 | decstatn)
-		basic_machine=mips-dec
+		cpu=powerpc
+		vendor=ibm
+		basic_os=cnk
 		;;
 	decsystem10* | dec10*)
-		basic_machine=pdp10-dec
-		os=-tops10
+		cpu=pdp10
+		vendor=dec
+		basic_os=tops10
 		;;
 	decsystem20* | dec20*)
-		basic_machine=pdp10-dec
-		os=-tops20
+		cpu=pdp10
+		vendor=dec
+		basic_os=tops20
 		;;
 	delta | 3300 | motorola-3300 | motorola-delta \
 	      | 3300-motorola | delta-motorola)
-		basic_machine=m68k-motorola
-		;;
-	delta88)
-		basic_machine=m88k-motorola
-		os=-sysv3
-		;;
-	dicos)
-		basic_machine=i686-pc
-		os=-dicos
-		;;
-	djgpp)
-		basic_machine=i586-pc
-		os=-msdosdjgpp
-		;;
-	dpx20 | dpx20-*)
-		basic_machine=rs6000-bull
-		os=-bosx
-		;;
-	dpx2* | dpx2*-bull)
-		basic_machine=m68k-bull
-		os=-sysv3
-		;;
-	ebmon29k)
-		basic_machine=a29k-amd
-		os=-ebmon
+		cpu=m68k
+		vendor=motorola
 		;;
-	elxsi)
-		basic_machine=elxsi-elxsi
-		os=-bsd
+	dpx2*)
+		cpu=m68k
+		vendor=bull
+		basic_os=sysv3
 		;;
 	encore | umax | mmax)
-		basic_machine=ns32k-encore
+		cpu=ns32k
+		vendor=encore
 		;;
-	es1800 | OSE68k | ose68k | ose | OSE)
-		basic_machine=m68k-ericsson
-		os=-ose
+	elxsi)
+		cpu=elxsi
+		vendor=elxsi
+		basic_os=${basic_os:-bsd}
 		;;
 	fx2800)
-		basic_machine=i860-alliant
+		cpu=i860
+		vendor=alliant
 		;;
 	genix)
-		basic_machine=ns32k-ns
-		;;
-	gmicro)
-		basic_machine=tron-gmicro
-		os=-sysv
-		;;
-	go32)
-		basic_machine=i386-pc
-		os=-go32
+		cpu=ns32k
+		vendor=ns
 		;;
 	h3050r* | hiux*)
-		basic_machine=hppa1.1-hitachi
-		os=-hiuxwe2
-		;;
-	h8300hms)
-		basic_machine=h8300-hitachi
-		os=-hms
-		;;
-	h8300xray)
-		basic_machine=h8300-hitachi
-		os=-xray
-		;;
-	h8500hms)
-		basic_machine=h8500-hitachi
-		os=-hms
-		;;
-	harris)
-		basic_machine=m88k-harris
-		os=-sysv3
-		;;
-	hp300-*)
-		basic_machine=m68k-hp
-		;;
-	hp300bsd)
-		basic_machine=m68k-hp
-		os=-bsd
-		;;
-	hp300hpux)
-		basic_machine=m68k-hp
-		os=-hpux
+		cpu=hppa1.1
+		vendor=hitachi
+		basic_os=hiuxwe2
 		;;
 	hp3k9[0-9][0-9] | hp9[0-9][0-9])
-		basic_machine=hppa1.0-hp
+		cpu=hppa1.0
+		vendor=hp
 		;;
 	hp9k2[0-9][0-9] | hp9k31[0-9])
-		basic_machine=m68000-hp
+		cpu=m68000
+		vendor=hp
 		;;
 	hp9k3[2-9][0-9])
-		basic_machine=m68k-hp
+		cpu=m68k
+		vendor=hp
 		;;
 	hp9k6[0-9][0-9] | hp6[0-9][0-9])
-		basic_machine=hppa1.0-hp
+		cpu=hppa1.0
+		vendor=hp
 		;;
 	hp9k7[0-79][0-9] | hp7[0-79][0-9])
-		basic_machine=hppa1.1-hp
+		cpu=hppa1.1
+		vendor=hp
 		;;
 	hp9k78[0-9] | hp78[0-9])
 		# FIXME: really hppa2.0-hp
-		basic_machine=hppa1.1-hp
+		cpu=hppa1.1
+		vendor=hp
 		;;
 	hp9k8[67]1 | hp8[67]1 | hp9k80[24] | hp80[24] | hp9k8[78]9 | hp8[78]9 | hp9k893 | hp893)
 		# FIXME: really hppa2.0-hp
-		basic_machine=hppa1.1-hp
+		cpu=hppa1.1
+		vendor=hp
 		;;
 	hp9k8[0-9][13679] | hp8[0-9][13679])
-		basic_machine=hppa1.1-hp
+		cpu=hppa1.1
+		vendor=hp
 		;;
 	hp9k8[0-9][0-9] | hp8[0-9][0-9])
-		basic_machine=hppa1.0-hp
-		;;
-	hppa-next)
-		os=-nextstep3
-		;;
-	hppaosf)
-		basic_machine=hppa1.1-hp
-		os=-osf
-		;;
-	hppro)
-		basic_machine=hppa1.1-hp
-		os=-proelf
-		;;
-	i370-ibm* | ibm*)
-		basic_machine=i370-ibm
+		cpu=hppa1.0
+		vendor=hp
 		;;
 	i*86v32)
-		basic_machine=`echo $1 | sed -e 's/86.*/86-pc/'`
-		os=-sysv32
+		cpu=`echo "$1" | sed -e 's/86.*/86/'`
+		vendor=pc
+		basic_os=sysv32
 		;;
 	i*86v4*)
-		basic_machine=`echo $1 | sed -e 's/86.*/86-pc/'`
-		os=-sysv4
+		cpu=`echo "$1" | sed -e 's/86.*/86/'`
+		vendor=pc
+		basic_os=sysv4
 		;;
 	i*86v)
-		basic_machine=`echo $1 | sed -e 's/86.*/86-pc/'`
-		os=-sysv
+		cpu=`echo "$1" | sed -e 's/86.*/86/'`
+		vendor=pc
+		basic_os=sysv
 		;;
 	i*86sol2)
-		basic_machine=`echo $1 | sed -e 's/86.*/86-pc/'`
-		os=-solaris2
-		;;
-	i386mach)
-		basic_machine=i386-mach
-		os=-mach
+		cpu=`echo "$1" | sed -e 's/86.*/86/'`
+		vendor=pc
+		basic_os=solaris2
 		;;
-	i386-vsta | vsta)
-		basic_machine=i386-unknown
-		os=-vsta
+	j90 | j90-cray)
+		cpu=j90
+		vendor=cray
+		basic_os=${basic_os:-unicos}
 		;;
 	iris | iris4d)
-		basic_machine=mips-sgi
-		case $os in
-		    -irix*)
+		cpu=mips
+		vendor=sgi
+		case $basic_os in
+		    irix*)
 			;;
 		    *)
-			os=-irix4
+			basic_os=irix4
 			;;
 		esac
 		;;
-	isi68 | isi)
-		basic_machine=m68k-isi
-		os=-sysv
-		;;
-	m68knommu)
-		basic_machine=m68k-unknown
-		os=-linux
-		;;
-	m68knommu-*)
-		basic_machine=m68k-`echo $basic_machine | sed 's/^[^-]*-//'`
-		os=-linux
-		;;
-	m88k-omron*)
-		basic_machine=m88k-omron
-		;;
-	magnum | m3230)
-		basic_machine=mips-mips
-		os=-sysv
-		;;
-	merlin)
-		basic_machine=ns32k-utek
-		os=-sysv
-		;;
-	microblaze*)
-		basic_machine=microblaze-xilinx
-		;;
-	mingw64)
-		basic_machine=x86_64-pc
-		os=-mingw64
-		;;
-	mingw32)
-		basic_machine=i686-pc
-		os=-mingw32
-		;;
-	mingw32ce)
-		basic_machine=arm-unknown
-		os=-mingw32ce
-		;;
 	miniframe)
-		basic_machine=m68000-convergent
+		cpu=m68000
+		vendor=convergent
 		;;
-	*mint | -mint[0-9]* | *MiNT | *MiNT[0-9]*)
-		basic_machine=m68k-atari
-		os=-mint
-		;;
-	mips3*-*)
-		basic_machine=`echo $basic_machine | sed -e 's/mips3/mips64/'`
-		;;
-	mips3*)
-		basic_machine=`echo $basic_machine | sed -e 's/mips3/mips64/'`-unknown
-		;;
-	monitor)
-		basic_machine=m68k-rom68k
-		os=-coff
-		;;
-	morphos)
-		basic_machine=powerpc-unknown
-		os=-morphos
-		;;
-	msdos)
-		basic_machine=i386-pc
-		os=-msdos
-		;;
-	ms1-*)
-		basic_machine=`echo $basic_machine | sed -e 's/ms1-/mt-/'`
-		;;
-	msys)
-		basic_machine=i686-pc
-		os=-msys
-		;;
-	mvs)
-		basic_machine=i370-ibm
-		os=-mvs
-		;;
-	nacl)
-		basic_machine=le32-unknown
-		os=-nacl
-		;;
-	ncr3000)
-		basic_machine=i486-ncr
-		os=-sysv4
-		;;
-	netbsd386)
-		basic_machine=i386-unknown
-		os=-netbsd
-		;;
-	netwinder)
-		basic_machine=armv4l-rebel
-		os=-linux
-		;;
-	news | news700 | news800 | news900)
-		basic_machine=m68k-sony
-		os=-newsos
-		;;
-	news1000)
-		basic_machine=m68030-sony
-		os=-newsos
+	*mint | mint[0-9]* | *MiNT | *MiNT[0-9]*)
+		cpu=m68k
+		vendor=atari
+		basic_os=mint
 		;;
 	news-3600 | risc-news)
-		basic_machine=mips-sony
-		os=-newsos
-		;;
-	necv70)
-		basic_machine=v70-nec
-		os=-sysv
-		;;
-	next | m*-next )
-		basic_machine=m68k-next
-		case $os in
-		    -nextstep* )
+		cpu=mips
+		vendor=sony
+		basic_os=newsos
+		;;
+	next | m*-next)
+		cpu=m68k
+		vendor=next
+		case $basic_os in
+		    openstep*)
+		        ;;
+		    nextstep*)
 			;;
-		    -ns2*)
-		      os=-nextstep2
+		    ns2*)
+		      basic_os=nextstep2
 			;;
 		    *)
-		      os=-nextstep3
+		      basic_os=nextstep3
 			;;
 		esac
 		;;
-	nh3000)
-		basic_machine=m68k-harris
-		os=-cxux
-		;;
-	nh[45]000)
-		basic_machine=m88k-harris
-		os=-cxux
-		;;
-	nindy960)
-		basic_machine=i960-intel
-		os=-nindy
-		;;
-	mon960)
-		basic_machine=i960-intel
-		os=-mon960
-		;;
-	nonstopux)
-		basic_machine=mips-compaq
-		os=-nonstopux
-		;;
 	np1)
-		basic_machine=np1-gould
-		;;
-	neo-tandem)
-		basic_machine=neo-tandem
-		;;
-	nse-tandem)
-		basic_machine=nse-tandem
-		;;
-	nsr-tandem)
-		basic_machine=nsr-tandem
+		cpu=np1
+		vendor=gould
 		;;
 	op50n-* | op60c-*)
-		basic_machine=hppa1.1-oki
-		os=-proelf
-		;;
-	openrisc | openrisc-*)
-		basic_machine=or32-unknown
-		;;
-	os400)
-		basic_machine=powerpc-ibm
-		os=-os400
-		;;
-	OSE68000 | ose68000)
-		basic_machine=m68000-ericsson
-		os=-ose
-		;;
-	os68k)
-		basic_machine=m68k-none
-		os=-os68k
+		cpu=hppa1.1
+		vendor=oki
+		basic_os=proelf
 		;;
 	pa-hitachi)
-		basic_machine=hppa1.1-hitachi
-		os=-hiuxwe2
-		;;
-	paragon)
-		basic_machine=i860-intel
-		os=-osf
-		;;
-	parisc)
-		basic_machine=hppa-unknown
-		os=-linux
-		;;
-	parisc-*)
-		basic_machine=hppa-`echo $basic_machine | sed 's/^[^-]*-//'`
-		os=-linux
+		cpu=hppa1.1
+		vendor=hitachi
+		basic_os=hiuxwe2
 		;;
 	pbd)
-		basic_machine=sparc-tti
+		cpu=sparc
+		vendor=tti
 		;;
 	pbb)
-		basic_machine=m68k-tti
-		;;
-	pc532 | pc532-*)
-		basic_machine=ns32k-pc532
-		;;
-	pc98)
-		basic_machine=i386-pc
-		;;
-	pc98-*)
-		basic_machine=i386-`echo $basic_machine | sed 's/^[^-]*-//'`
-		;;
-	pentium | p5 | k5 | k6 | nexgen | viac3)
-		basic_machine=i586-pc
-		;;
-	pentiumpro | p6 | 6x86 | athlon | athlon_*)
-		basic_machine=i686-pc
-		;;
-	pentiumii | pentium2 | pentiumiii | pentium3)
-		basic_machine=i686-pc
-		;;
-	pentium4)
-		basic_machine=i786-pc
-		;;
-	pentium-* | p5-* | k5-* | k6-* | nexgen-* | viac3-*)
-		basic_machine=i586-`echo $basic_machine | sed 's/^[^-]*-//'`
+		cpu=m68k
+		vendor=tti
 		;;
-	pentiumpro-* | p6-* | 6x86-* | athlon-*)
-		basic_machine=i686-`echo $basic_machine | sed 's/^[^-]*-//'`
-		;;
-	pentiumii-* | pentium2-* | pentiumiii-* | pentium3-*)
-		basic_machine=i686-`echo $basic_machine | sed 's/^[^-]*-//'`
-		;;
-	pentium4-*)
-		basic_machine=i786-`echo $basic_machine | sed 's/^[^-]*-//'`
+	pc532)
+		cpu=ns32k
+		vendor=pc532
 		;;
 	pn)
-		basic_machine=pn-gould
+		cpu=pn
+		vendor=gould
 		;;
-	power)	basic_machine=power-ibm
-		;;
-	ppc | ppcbe)	basic_machine=powerpc-unknown
-		;;
-	ppc-* | ppcbe-*)
-		basic_machine=powerpc-`echo $basic_machine | sed 's/^[^-]*-//'`
-		;;
-	ppcle | powerpclittle | ppc-le | powerpc-little)
-		basic_machine=powerpcle-unknown
-		;;
-	ppcle-* | powerpclittle-*)
-		basic_machine=powerpcle-`echo $basic_machine | sed 's/^[^-]*-//'`
-		;;
-	ppc64)	basic_machine=powerpc64-unknown
-		;;
-	ppc64-*) basic_machine=powerpc64-`echo $basic_machine | sed 's/^[^-]*-//'`
-		;;
-	ppc64le | powerpc64little | ppc64-le | powerpc64-little)
-		basic_machine=powerpc64le-unknown
-		;;
-	ppc64le-* | powerpc64little-*)
-		basic_machine=powerpc64le-`echo $basic_machine | sed 's/^[^-]*-//'`
+	power)
+		cpu=power
+		vendor=ibm
 		;;
 	ps2)
-		basic_machine=i386-ibm
-		;;
-	pw32)
-		basic_machine=i586-unknown
-		os=-pw32
-		;;
-	rdos | rdos64)
-		basic_machine=x86_64-pc
-		os=-rdos
-		;;
-	rdos32)
-		basic_machine=i386-pc
-		os=-rdos
-		;;
-	rom68k)
-		basic_machine=m68k-rom68k
-		os=-coff
+		cpu=i386
+		vendor=ibm
 		;;
 	rm[46]00)
-		basic_machine=mips-siemens
+		cpu=mips
+		vendor=siemens
 		;;
 	rtpc | rtpc-*)
-		basic_machine=romp-ibm
-		;;
-	s390 | s390-*)
-		basic_machine=s390-ibm
-		;;
-	s390x | s390x-*)
-		basic_machine=s390x-ibm
+		cpu=romp
+		vendor=ibm
 		;;
-	sa29200)
-		basic_machine=a29k-amd
-		os=-udi
+	sde)
+		cpu=mipsisa32
+		vendor=sde
+		basic_os=${basic_os:-elf}
 		;;
-	sb1)
-		basic_machine=mipsisa64sb1-unknown
+	simso-wrs)
+		cpu=sparclite
+		vendor=wrs
+		basic_os=vxworks
 		;;
-	sb1el)
-		basic_machine=mipsisa64sb1el-unknown
+	tower | tower-32)
+		cpu=m68k
+		vendor=ncr
 		;;
-	sde)
-		basic_machine=mipsisa32-sde
-		os=-elf
+	vpp*|vx|vx-*)
+		cpu=f301
+		vendor=fujitsu
 		;;
-	sei)
-		basic_machine=mips-sei
-		os=-seiux
+	w65)
+		cpu=w65
+		vendor=wdc
 		;;
-	sequent)
-		basic_machine=i386-sequent
+	w89k-*)
+		cpu=hppa1.1
+		vendor=winbond
+		basic_os=proelf
 		;;
-	sh)
-		basic_machine=sh-hitachi
-		os=-hms
+	none)
+		cpu=none
+		vendor=none
 		;;
-	sh5el)
-		basic_machine=sh5le-unknown
+	leon|leon[3-9])
+		cpu=sparc
+		vendor=$basic_machine
 		;;
-	sh64)
-		basic_machine=sh64-unknown
+	leon-*|leon[3-9]-*)
+		cpu=sparc
+		vendor=`echo "$basic_machine" | sed 's/-.*//'`
 		;;
-	sparclite-wrs | simso-wrs)
-		basic_machine=sparclite-wrs
-		os=-vxworks
+
+	*-*)
+		# shellcheck disable=SC2162
+		saved_IFS=$IFS
+		IFS="-" read cpu vendor <<EOF
+$basic_machine
+EOF
+		IFS=$saved_IFS
 		;;
-	sps7)
-		basic_machine=m68k-bull
-		os=-sysv2
+	# We use `pc' rather than `unknown'
+	# because (1) that's what they normally are, and
+	# (2) the word "unknown" tends to confuse beginning users.
+	i*86 | x86_64)
+		cpu=$basic_machine
+		vendor=pc
 		;;
-	spur)
-		basic_machine=spur-unknown
+	# These rules are duplicated from below for sake of the special case above;
+	# i.e. things that normalized to x86 arches should also default to "pc"
+	pc98)
+		cpu=i386
+		vendor=pc
 		;;
-	st2000)
-		basic_machine=m68k-tandem
+	x64 | amd64)
+		cpu=x86_64
+		vendor=pc
 		;;
-	stratus)
-		basic_machine=i860-stratus
-		os=-sysv4
+	# Recognize the basic CPU types without company name.
+	*)
+		cpu=$basic_machine
+		vendor=unknown
 		;;
-	strongarm-* | thumb-*)
-		basic_machine=arm-`echo $basic_machine | sed 's/^[^-]*-//'`
+esac
+
+unset -v basic_machine
+
+# Decode basic machines in the full and proper CPU-Company form.
+case $cpu-$vendor in
+	# Here we handle the default manufacturer of certain CPU types in canonical form. It is in
+	# some cases the only manufacturer, in others, it is the most popular.
+	craynv-unknown)
+		vendor=cray
+		basic_os=${basic_os:-unicosmp}
 		;;
-	sun2)
-		basic_machine=m68000-sun
+	c90-unknown | c90-cray)
+		vendor=cray
+		basic_os=${Basic_os:-unicos}
 		;;
-	sun2os3)
-		basic_machine=m68000-sun
-		os=-sunos3
+	fx80-unknown)
+		vendor=alliant
 		;;
-	sun2os4)
-		basic_machine=m68000-sun
-		os=-sunos4
+	romp-unknown)
+		vendor=ibm
 		;;
-	sun3os3)
-		basic_machine=m68k-sun
-		os=-sunos3
+	mmix-unknown)
+		vendor=knuth
 		;;
-	sun3os4)
-		basic_machine=m68k-sun
-		os=-sunos4
+	microblaze-unknown | microblazeel-unknown)
+		vendor=xilinx
 		;;
-	sun4os3)
-		basic_machine=sparc-sun
-		os=-sunos3
+	rs6000-unknown)
+		vendor=ibm
 		;;
-	sun4os4)
-		basic_machine=sparc-sun
-		os=-sunos4
+	vax-unknown)
+		vendor=dec
 		;;
-	sun4sol2)
-		basic_machine=sparc-sun
-		os=-solaris2
+	pdp11-unknown)
+		vendor=dec
 		;;
-	sun3 | sun3-*)
-		basic_machine=m68k-sun
+	we32k-unknown)
+		vendor=att
 		;;
-	sun4)
-		basic_machine=sparc-sun
+	cydra-unknown)
+		vendor=cydrome
 		;;
-	sun386 | sun386i | roadrunner)
-		basic_machine=i386-sun
+	i370-ibm*)
+		vendor=ibm
 		;;
-	sv1)
-		basic_machine=sv1-cray
-		os=-unicos
+	orion-unknown)
+		vendor=highlevel
 		;;
-	symmetry)
-		basic_machine=i386-sequent
-		os=-dynix
+	xps-unknown | xps100-unknown)
+		cpu=xps100
+		vendor=honeywell
 		;;
-	t3e)
-		basic_machine=alphaev5-cray
-		os=-unicos
+
+	# Here we normalize CPU types with a missing or matching vendor
+	armh-unknown | armh-alt)
+		cpu=armv7l
+		vendor=alt
+		basic_os=${basic_os:-linux-gnueabihf}
 		;;
-	t90)
-		basic_machine=t90-cray
-		os=-unicos
+	dpx20-unknown | dpx20-bull)
+		cpu=rs6000
+		vendor=bull
+		basic_os=${basic_os:-bosx}
 		;;
-	tile*)
-		basic_machine=$basic_machine-unknown
-		os=-linux-gnu
+
+	# Here we normalize CPU types irrespective of the vendor
+	amd64-*)
+		cpu=x86_64
 		;;
-	tx39)
-		basic_machine=mipstx39-unknown
+	blackfin-*)
+		cpu=bfin
+		basic_os=linux
 		;;
-	tx39el)
-		basic_machine=mipstx39el-unknown
+	c54x-*)
+		cpu=tic54x
 		;;
-	toad1)
-		basic_machine=pdp10-xkl
-		os=-tops20
+	c55x-*)
+		cpu=tic55x
 		;;
-	tower | tower-32)
-		basic_machine=m68k-ncr
+	c6x-*)
+		cpu=tic6x
 		;;
-	tpf)
-		basic_machine=s390x-ibm
-		os=-tpf
+	e500v[12]-*)
+		cpu=powerpc
+		basic_os=${basic_os}"spe"
 		;;
-	udi29k)
-		basic_machine=a29k-amd
-		os=-udi
+	mips3*-*)
+		cpu=mips64
 		;;
-	ultra3)
-		basic_machine=a29k-nyu
-		os=-sym1
+	ms1-*)
+		cpu=mt
 		;;
-	v810 | necv810)
-		basic_machine=v810-nec
-		os=-none
+	m68knommu-*)
+		cpu=m68k
+		basic_os=linux
 		;;
-	vaxv)
-		basic_machine=vax-dec
-		os=-sysv
+	m9s12z-* | m68hcs12z-* | hcs12z-* | s12z-*)
+		cpu=s12z
 		;;
-	vms)
-		basic_machine=vax-dec
-		os=-vms
+	openrisc-*)
+		cpu=or32
 		;;
-	vpp*|vx|vx-*)
-		basic_machine=f301-fujitsu
+	parisc-*)
+		cpu=hppa
+		basic_os=linux
 		;;
-	vxworks960)
-		basic_machine=i960-wrs
-		os=-vxworks
+	pentium-* | p5-* | k5-* | k6-* | nexgen-* | viac3-*)
+		cpu=i586
 		;;
-	vxworks68)
-		basic_machine=m68k-wrs
-		os=-vxworks
+	pentiumpro-* | p6-* | 6x86-* | athlon-* | athalon_*-*)
+		cpu=i686
 		;;
-	vxworks29k)
-		basic_machine=a29k-wrs
-		os=-vxworks
+	pentiumii-* | pentium2-* | pentiumiii-* | pentium3-*)
+		cpu=i686
 		;;
-	w65*)
-		basic_machine=w65-wdc
-		os=-none
+	pentium4-*)
+		cpu=i786
 		;;
-	w89k-*)
-		basic_machine=hppa1.1-winbond
-		os=-proelf
+	pc98-*)
+		cpu=i386
 		;;
-	xbox)
-		basic_machine=i686-pc
-		os=-mingw32
+	ppc-* | ppcbe-*)
+		cpu=powerpc
 		;;
-	xps | xps100)
-		basic_machine=xps100-honeywell
+	ppcle-* | powerpclittle-*)
+		cpu=powerpcle
 		;;
-	xscale-* | xscalee[bl]-*)
-		basic_machine=`echo $basic_machine | sed 's/^xscale/arm/'`
+	ppc64-*)
+		cpu=powerpc64
 		;;
-	ymp)
-		basic_machine=ymp-cray
-		os=-unicos
+	ppc64le-* | powerpc64little-*)
+		cpu=powerpc64le
 		;;
-	z8k-*-coff)
-		basic_machine=z8k-unknown
-		os=-sim
+	sb1-*)
+		cpu=mipsisa64sb1
 		;;
-	z80-*-coff)
-		basic_machine=z80-unknown
-		os=-sim
+	sb1el-*)
+		cpu=mipsisa64sb1el
 		;;
-	none)
-		basic_machine=none-none
-		os=-none
+	sh5e[lb]-*)
+		cpu=`echo "$cpu" | sed 's/^\(sh.\)e\(.\)$/\1\2e/'`
 		;;
-
-# Here we handle the default manufacturer of certain CPU types.  It is in
-# some cases the only manufacturer, in others, it is the most popular.
-	w89k)
-		basic_machine=hppa1.1-winbond
+	spur-*)
+		cpu=spur
 		;;
-	op50n)
-		basic_machine=hppa1.1-oki
+	strongarm-* | thumb-*)
+		cpu=arm
 		;;
-	op60c)
-		basic_machine=hppa1.1-oki
+	tx39-*)
+		cpu=mipstx39
 		;;
-	romp)
-		basic_machine=romp-ibm
+	tx39el-*)
+		cpu=mipstx39el
 		;;
-	mmix)
-		basic_machine=mmix-knuth
+	x64-*)
+		cpu=x86_64
 		;;
-	rs6000)
-		basic_machine=rs6000-ibm
+	xscale-* | xscalee[bl]-*)
+		cpu=`echo "$cpu" | sed 's/^xscale/arm/'`
 		;;
-	vax)
-		basic_machine=vax-dec
+	arm64-* | aarch64le-*)
+		cpu=aarch64
 		;;
-	pdp10)
-		# there are many clones, so DEC is not a safe bet
-		basic_machine=pdp10-unknown
+
+	# Recognize the canonical CPU Types that limit and/or modify the
+	# company names they are paired with.
+	cr16-*)
+		basic_os=${basic_os:-elf}
 		;;
-	pdp11)
-		basic_machine=pdp11-dec
+	crisv32-* | etraxfs*-*)
+		cpu=crisv32
+		vendor=axis
 		;;
-	we32k)
-		basic_machine=we32k-att
+	cris-* | etrax*-*)
+		cpu=cris
+		vendor=axis
 		;;
-	sh[1234] | sh[24]a | sh[24]aeb | sh[34]eb | sh[1234]le | sh[23]ele)
-		basic_machine=sh-unknown
+	crx-*)
+		basic_os=${basic_os:-elf}
 		;;
-	sparc | sparcv8 | sparcv9 | sparcv9b | sparcv9v)
-		basic_machine=sparc-sun
+	neo-tandem)
+		cpu=neo
+		vendor=tandem
 		;;
-	cydra)
-		basic_machine=cydra-cydrome
+	nse-tandem)
+		cpu=nse
+		vendor=tandem
 		;;
-	orion)
-		basic_machine=orion-highlevel
+	nsr-tandem)
+		cpu=nsr
+		vendor=tandem
 		;;
-	orion105)
-		basic_machine=clipper-highlevel
+	nsv-tandem)
+		cpu=nsv
+		vendor=tandem
 		;;
-	mac | mpw | mac-mpw)
-		basic_machine=m68k-apple
+	nsx-tandem)
+		cpu=nsx
+		vendor=tandem
 		;;
-	pmac | pmac-mpw)
-		basic_machine=powerpc-apple
+	mipsallegrexel-sony)
+		cpu=mipsallegrexel
+		vendor=sony
 		;;
-	*-unknown)
-		# Make sure to match an already-canonicalized machine name.
+	tile*-*)
+		basic_os=${basic_os:-linux-gnu}
 		;;
+
 	*)
-		echo Invalid configuration \`$1\': machine \`$basic_machine\' not recognized 1>&2
-		exit 1
+		# Recognize the canonical CPU types that are allowed with any
+		# company name.
+		case $cpu in
+			1750a | 580 \
+			| a29k \
+			| aarch64 | aarch64_be \
+			| abacus \
+			| alpha | alphaev[4-8] | alphaev56 | alphaev6[78] \
+			| alpha64 | alpha64ev[4-8] | alpha64ev56 | alpha64ev6[78] \
+			| alphapca5[67] | alpha64pca5[67] \
+			| am33_2.0 \
+			| amdgcn \
+			| arc | arceb | arc32 | arc64 \
+			| arm | arm[lb]e | arme[lb] | armv* \
+			| avr | avr32 \
+			| asmjs \
+			| ba \
+			| be32 | be64 \
+			| bfin | bpf | bs2000 \
+			| c[123]* | c30 | [cjt]90 | c4x \
+			| c8051 | clipper | craynv | csky | cydra \
+			| d10v | d30v | dlx | dsp16xx \
+			| e2k | elxsi | epiphany \
+			| f30[01] | f700 | fido | fr30 | frv | ft32 | fx80 \
+			| h8300 | h8500 \
+			| hppa | hppa1.[01] | hppa2.0 | hppa2.0[nw] | hppa64 \
+			| hexagon \
+			| i370 | i*86 | i860 | i960 | ia16 | ia64 \
+			| ip2k | iq2000 \
+			| k1om \
+			| le32 | le64 \
+			| lm32 \
+			| loongarch32 | loongarch64 | loongarchx32 \
+			| m32c | m32r | m32rle \
+			| m5200 | m68000 | m680[012346]0 | m68360 | m683?2 | m68k \
+			| m6811 | m68hc11 | m6812 | m68hc12 | m68hcs12x \
+			| m88110 | m88k | maxq | mb | mcore | mep | metag \
+			| microblaze | microblazeel \
+			| mips | mipsbe | mipseb | mipsel | mipsle \
+			| mips16 \
+			| mips64 | mips64eb | mips64el \
+			| mips64octeon | mips64octeonel \
+			| mips64orion | mips64orionel \
+			| mips64r5900 | mips64r5900el \
+			| mips64vr | mips64vrel \
+			| mips64vr4100 | mips64vr4100el \
+			| mips64vr4300 | mips64vr4300el \
+			| mips64vr5000 | mips64vr5000el \
+			| mips64vr5900 | mips64vr5900el \
+			| mipsisa32 | mipsisa32el \
+			| mipsisa32r2 | mipsisa32r2el \
+			| mipsisa32r3 | mipsisa32r3el \
+			| mipsisa32r5 | mipsisa32r5el \
+			| mipsisa32r6 | mipsisa32r6el \
+			| mipsisa64 | mipsisa64el \
+			| mipsisa64r2 | mipsisa64r2el \
+			| mipsisa64r3 | mipsisa64r3el \
+			| mipsisa64r5 | mipsisa64r5el \
+			| mipsisa64r6 | mipsisa64r6el \
+			| mipsisa64sb1 | mipsisa64sb1el \
+			| mipsisa64sr71k | mipsisa64sr71kel \
+			| mipsr5900 | mipsr5900el \
+			| mipstx39 | mipstx39el \
+			| mmix \
+			| mn10200 | mn10300 \
+			| moxie \
+			| mt \
+			| msp430 \
+			| nds32 | nds32le | nds32be \
+			| nfp \
+			| nios | nios2 | nios2eb | nios2el \
+			| none | np1 | ns16k | ns32k | nvptx \
+			| open8 \
+			| or1k* \
+			| or32 \
+			| orion \
+			| picochip \
+			| pdp10 | pdp11 | pj | pjl | pn | power \
+			| powerpc | powerpc64 | powerpc64le | powerpcle | powerpcspe \
+			| pru \
+			| pyramid \
+			| riscv | riscv32 | riscv32be | riscv64 | riscv64be \
+			| rl78 | romp | rs6000 | rx \
+			| s390 | s390x \
+			| score \
+			| sh | shl \
+			| sh[1234] | sh[24]a | sh[24]ae[lb] | sh[23]e | she[lb] | sh[lb]e \
+			| sh[1234]e[lb] |  sh[12345][lb]e | sh[23]ele | sh64 | sh64le \
+			| sparc | sparc64 | sparc64b | sparc64v | sparc86x | sparclet \
+			| sparclite \
+			| sparcv8 | sparcv9 | sparcv9b | sparcv9v | sv1 | sx* \
+			| spu \
+			| tahoe \
+			| thumbv7* \
+			| tic30 | tic4x | tic54x | tic55x | tic6x | tic80 \
+			| tron \
+			| ubicom32 \
+			| v70 | v850 | v850e | v850e1 | v850es | v850e2 | v850e2v3 \
+			| vax \
+			| visium \
+			| w65 \
+			| wasm32 | wasm64 \
+			| we32k \
+			| x86 | x86_64 | xc16x | xgate | xps100 \
+			| xstormy16 | xtensa* \
+			| ymp \
+			| z8k | z80)
+				;;
+
+			*)
+				echo Invalid configuration \`"$1"\': machine \`"$cpu-$vendor"\' not recognized 1>&2
+				exit 1
+				;;
+		esac
 		;;
 esac
 
 # Here we canonicalize certain aliases for manufacturers.
-case $basic_machine in
-	*-digital*)
-		basic_machine=`echo $basic_machine | sed 's/digital.*/dec/'`
+case $vendor in
+	digital*)
+		vendor=dec
 		;;
-	*-commodore*)
-		basic_machine=`echo $basic_machine | sed 's/commodore.*/cbm/'`
+	commodore*)
+		vendor=cbm
 		;;
 	*)
 		;;
@@ -1323,200 +1306,215 @@ esac
 
 # Decode manufacturer-specific aliases for certain operating systems.
 
-if [ x"$os" != x"" ]
+if test x$basic_os != x
 then
+
+# First recognize some ad-hoc cases, or perhaps split kernel-os, or else just
+# set os.
+case $basic_os in
+	gnu/linux*)
+		kernel=linux
+		os=`echo "$basic_os" | sed -e 's|gnu/linux|gnu|'`
+		;;
+	os2-emx)
+		kernel=os2
+		os=`echo "$basic_os" | sed -e 's|os2-emx|emx|'`
+		;;
+	nto-qnx*)
+		kernel=nto
+		os=`echo "$basic_os" | sed -e 's|nto-qnx|qnx|'`
+		;;
+	*-*)
+		# shellcheck disable=SC2162
+		saved_IFS=$IFS
+		IFS="-" read kernel os <<EOF
+$basic_os
+EOF
+		IFS=$saved_IFS
+		;;
+	# Default OS when just kernel was specified
+	nto*)
+		kernel=nto
+		os=`echo "$basic_os" | sed -e 's|nto|qnx|'`
+		;;
+	linux*)
+		kernel=linux
+		os=`echo "$basic_os" | sed -e 's|linux|gnu|'`
+		;;
+	*)
+		kernel=
+		os=$basic_os
+		;;
+esac
+
+# Now, normalize the OS (knowing we just have one component, it's not a kernel,
+# etc.)
 case $os in
-	# First match some system type aliases
-	# that might get confused with valid system types.
-	# -solaris* is a basic system type, with this one exception.
-	-auroraux)
-		os=-auroraux
+	# First match some system type aliases that might get confused
+	# with valid system types.
+	# solaris* is a basic system type, with this one exception.
+	auroraux)
+		os=auroraux
 		;;
-	-solaris1 | -solaris1.*)
-		os=`echo $os | sed -e 's|solaris1|sunos4|'`
+	bluegene*)
+		os=cnk
 		;;
-	-solaris)
-		os=-solaris2
+	solaris1 | solaris1.*)
+		os=`echo "$os" | sed -e 's|solaris1|sunos4|'`
 		;;
-	-svr4*)
-		os=-sysv4
+	solaris)
+		os=solaris2
 		;;
-	-unixware*)
-		os=-sysv4.2uw
+	unixware*)
+		os=sysv4.2uw
 		;;
-	-gnu/linux*)
-		os=`echo $os | sed -e 's|gnu/linux|linux-gnu|'`
+	# es1800 is here to avoid being matched by es* (a different OS)
+	es1800*)
+		os=ose
 		;;
-	# First accept the basic system types.
-	# The portable systems comes first.
-	# Each alternative MUST END IN A *, to match a version number.
-	# -sysv* is not here because it comes later, after sysvr4.
-	-gnu* | -bsd* | -mach* | -minix* | -genix* | -ultrix* | -irix* \
-	      | -*vms* | -sco* | -esix* | -isc* | -aix* | -cnk* | -sunos | -sunos[34]*\
-	      | -hpux* | -unos* | -osf* | -luna* | -dgux* | -auroraux* | -solaris* \
-	      | -sym* | -kopensolaris* | -plan9* \
-	      | -amigaos* | -amigados* | -msdos* | -newsos* | -unicos* | -aof* \
-	      | -aos* | -aros* \
-	      | -nindy* | -vxsim* | -vxworks* | -ebmon* | -hms* | -mvs* \
-	      | -clix* | -riscos* | -uniplus* | -iris* | -rtu* | -xenix* \
-	      | -hiux* | -386bsd* | -knetbsd* | -mirbsd* | -netbsd* \
-	      | -bitrig* | -openbsd* | -solidbsd* \
-	      | -ekkobsd* | -kfreebsd* | -freebsd* | -riscix* | -lynxos* \
-	      | -bosx* | -nextstep* | -cxux* | -aout* | -elf* | -oabi* \
-	      | -ptx* | -coff* | -ecoff* | -winnt* | -domain* | -vsta* \
-	      | -udi* | -eabi* | -lites* | -ieee* | -go32* | -aux* \
-	      | -chorusos* | -chorusrdb* | -cegcc* \
-	      | -cygwin* | -msys* | -pe* | -psos* | -moss* | -proelf* | -rtems* \
-	      | -mingw32* | -mingw64* | -linux-gnu* | -linux-android* \
-	      | -linux-newlib* | -linux-musl* | -linux-uclibc* \
-	      | -uxpv* | -beos* | -mpeix* | -udk* \
-	      | -interix* | -uwin* | -mks* | -rhapsody* | -darwin* | -opened* \
-	      | -openstep* | -oskit* | -conix* | -pw32* | -nonstopux* \
-	      | -storm-chaos* | -tops10* | -tenex* | -tops20* | -its* \
-	      | -os2* | -vos* | -palmos* | -uclinux* | -nucleus* \
-	      | -morphos* | -superux* | -rtmk* | -rtmk-nova* | -windiss* \
-	      | -powermax* | -dnix* | -nx6 | -nx7 | -sei* | -dragonfly* \
-	      | -skyos* | -haiku* | -rdos* | -toppers* | -drops* | -es*)
-	# Remember, each alternative MUST END IN *, to match a version number.
-		;;
-	-qnx*)
-		case $basic_machine in
-		    x86-* | i*86-*)
-			;;
-		    *)
-			os=-nto$os
-			;;
-		esac
+	# Some version numbers need modification
+	chorusos*)
+		os=chorusos
 		;;
-	-nto-qnx*)
+	isc)
+		os=isc2.2
 		;;
-	-nto*)
-		os=`echo $os | sed -e 's|nto|nto-qnx|'`
+	sco6)
+		os=sco5v6
 		;;
-	-sim | -es1800* | -hms* | -xray | -os68k* | -none* | -v88r* \
-	      | -windows* | -osx | -abug | -netware* | -os9* | -beos* | -haiku* \
-	      | -macos* | -mpw* | -magic* | -mmixware* | -mon960* | -lnews*)
+	sco5)
+		os=sco3.2v5
 		;;
-	-mac*)
-		os=`echo $os | sed -e 's|mac|macos|'`
+	sco4)
+		os=sco3.2v4
 		;;
-	-linux-dietlibc)
-		os=-linux-dietlibc
+	sco3.2.[4-9]*)
+		os=`echo "$os" | sed -e 's/sco3.2./sco3.2v/'`
 		;;
-	-linux*)
-		os=`echo $os | sed -e 's|linux|linux-gnu|'`
+	sco*v* | scout)
+		# Don't match below
 		;;
-	-sunos5*)
-		os=`echo $os | sed -e 's|sunos5|solaris2|'`
+	sco*)
+		os=sco3.2v2
 		;;
-	-sunos6*)
-		os=`echo $os | sed -e 's|sunos6|solaris3|'`
+	psos*)
+		os=psos
 		;;
-	-opened*)
-		os=-openedition
+	qnx*)
+		os=qnx
 		;;
-	-os400*)
-		os=-os400
+	hiux*)
+		os=hiuxwe2
 		;;
-	-wince*)
-		os=-wince
+	lynx*178)
+		os=lynxos178
 		;;
-	-osfrose*)
-		os=-osfrose
+	lynx*5)
+		os=lynxos5
 		;;
-	-osf*)
-		os=-osf
+	lynxos*)
+		# don't get caught up in next wildcard
 		;;
-	-utek*)
-		os=-bsd
+	lynx*)
+		os=lynxos
 		;;
-	-dynix*)
-		os=-bsd
+	mac[0-9]*)
+		os=`echo "$os" | sed -e 's|mac|macos|'`
 		;;
-	-acis*)
-		os=-aos
+	opened*)
+		os=openedition
 		;;
-	-atheos*)
-		os=-atheos
+	os400*)
+		os=os400
 		;;
-	-syllable*)
-		os=-syllable
+	sunos5*)
+		os=`echo "$os" | sed -e 's|sunos5|solaris2|'`
 		;;
-	-386bsd)
-		os=-bsd
+	sunos6*)
+		os=`echo "$os" | sed -e 's|sunos6|solaris3|'`
 		;;
-	-ctix* | -uts*)
-		os=-sysv
+	wince*)
+		os=wince
 		;;
-	-nova*)
-		os=-rtmk-nova
+	utek*)
+		os=bsd
 		;;
-	-ns2 )
-		os=-nextstep2
+	dynix*)
+		os=bsd
 		;;
-	-nsk*)
-		os=-nsk
+	acis*)
+		os=aos
 		;;
-	# Preserve the version number of sinix5.
-	-sinix5.*)
-		os=`echo $os | sed -e 's|sinix|sysv|'`
+	atheos*)
+		os=atheos
 		;;
-	-sinix*)
-		os=-sysv4
+	syllable*)
+		os=syllable
 		;;
-	-tpf*)
-		os=-tpf
+	386bsd)
+		os=bsd
 		;;
-	-triton*)
-		os=-sysv3
+	ctix* | uts*)
+		os=sysv
 		;;
-	-oss*)
-		os=-sysv3
+	nova*)
+		os=rtmk-nova
 		;;
-	-svr4)
-		os=-sysv4
+	ns2)
+		os=nextstep2
 		;;
-	-svr3)
-		os=-sysv3
+	# Preserve the version number of sinix5.
+	sinix5.*)
+		os=`echo "$os" | sed -e 's|sinix|sysv|'`
 		;;
-	-sysvr4)
-		os=-sysv4
+	sinix*)
+		os=sysv4
 		;;
-	# This must come after -sysvr4.
-	-sysv*)
+	tpf*)
+		os=tpf
 		;;
-	-ose*)
-		os=-ose
+	triton*)
+		os=sysv3
 		;;
-	-es1800*)
-		os=-ose
+	oss*)
+		os=sysv3
 		;;
-	-xenix)
-		os=-xenix
+	svr4*)
+		os=sysv4
 		;;
-	-*mint | -mint[0-9]* | -*MiNT | -MiNT[0-9]*)
-		os=-mint
+	svr3)
+		os=sysv3
 		;;
-	-aros*)
-		os=-aros
+	sysvr4)
+		os=sysv4
 		;;
-	-zvmoe)
-		os=-zvmoe
+	ose*)
+		os=ose
 		;;
-	-dicos*)
-		os=-dicos
+	*mint | mint[0-9]* | *MiNT | MiNT[0-9]*)
+		os=mint
 		;;
-	-nacl*)
+	dicos*)
+		os=dicos
 		;;
-	-none)
+	pikeos*)
+		# Until real need of OS specific support for
+		# particular features comes up, bare metal
+		# configurations are quite functional.
+		case $cpu in
+		    arm*)
+			os=eabi
+			;;
+		    *)
+			os=elf
+			;;
+		esac
 		;;
 	*)
-		# Get rid of the `-'@the beginning of $os.
-		os=`echo $os | sed 's/[^-]*-//'`
-		echo Invalid configuration \`$1\': system \`$os\' not recognized 1>&2
-		exit 1
+		# No normalization, but not necessarily accepted, that comes below.
 		;;
 esac
+
 else
 
 # Here we handle the default operating systems that come with various machines.
@@ -1529,264 +1527,363 @@ else
 # will signal an error saying that MANUFACTURER isn't an operating
 # system, and we'll never get to this point.
 
-case $basic_machine in
+kernel=
+case $cpu-$vendor in
 	score-*)
-		os=-elf
+		os=elf
 		;;
 	spu-*)
-		os=-elf
+		os=elf
 		;;
 	*-acorn)
-		os=-riscix1.2
+		os=riscix1.2
 		;;
 	arm*-rebel)
-		os=-linux
+		kernel=linux
+		os=gnu
 		;;
 	arm*-semi)
-		os=-aout
+		os=aout
 		;;
 	c4x-* | tic4x-*)
-		os=-coff
+		os=coff
 		;;
 	c8051-*)
-		os=-elf
+		os=elf
+		;;
+	clipper-intergraph)
+		os=clix
 		;;
 	hexagon-*)
-		os=-elf
+		os=elf
 		;;
 	tic54x-*)
-		os=-coff
+		os=coff
 		;;
 	tic55x-*)
-		os=-coff
+		os=coff
 		;;
 	tic6x-*)
-		os=-coff
+		os=coff
 		;;
 	# This must come before the *-dec entry.
 	pdp10-*)
-		os=-tops20
+		os=tops20
 		;;
 	pdp11-*)
-		os=-none
+		os=none
 		;;
 	*-dec | vax-*)
-		os=-ultrix4.2
+		os=ultrix4.2
 		;;
 	m68*-apollo)
-		os=-domain
+		os=domain
 		;;
 	i386-sun)
-		os=-sunos4.0.2
+		os=sunos4.0.2
 		;;
 	m68000-sun)
-		os=-sunos3
+		os=sunos3
 		;;
 	m68*-cisco)
-		os=-aout
+		os=aout
 		;;
 	mep-*)
-		os=-elf
+		os=elf
 		;;
 	mips*-cisco)
-		os=-elf
+		os=elf
 		;;
 	mips*-*)
-		os=-elf
-		;;
-	or1k-*)
-		os=-elf
+		os=elf
 		;;
 	or32-*)
-		os=-coff
+		os=coff
 		;;
 	*-tti)	# must be before sparc entry or we get the wrong os.
-		os=-sysv3
+		os=sysv3
 		;;
 	sparc-* | *-sun)
-		os=-sunos4.1.1
+		os=sunos4.1.1
 		;;
-	*-be)
-		os=-beos
+	pru-*)
+		os=elf
 		;;
-	*-haiku)
-		os=-haiku
+	*-be)
+		os=beos
 		;;
 	*-ibm)
-		os=-aix
+		os=aix
 		;;
 	*-knuth)
-		os=-mmixware
+		os=mmixware
 		;;
 	*-wec)
-		os=-proelf
+		os=proelf
 		;;
 	*-winbond)
-		os=-proelf
+		os=proelf
 		;;
 	*-oki)
-		os=-proelf
+		os=proelf
 		;;
 	*-hp)
-		os=-hpux
+		os=hpux
 		;;
 	*-hitachi)
-		os=-hiux
+		os=hiux
 		;;
 	i860-* | *-att | *-ncr | *-altos | *-motorola | *-convergent)
-		os=-sysv
+		os=sysv
 		;;
 	*-cbm)
-		os=-amigaos
+		os=amigaos
 		;;
 	*-dg)
-		os=-dgux
+		os=dgux
 		;;
 	*-dolphin)
-		os=-sysv3
+		os=sysv3
 		;;
 	m68k-ccur)
-		os=-rtu
+		os=rtu
 		;;
 	m88k-omron*)
-		os=-luna
+		os=luna
 		;;
-	*-next )
-		os=-nextstep
+	*-next)
+		os=nextstep
 		;;
 	*-sequent)
-		os=-ptx
+		os=ptx
 		;;
 	*-crds)
-		os=-unos
+		os=unos
 		;;
 	*-ns)
-		os=-genix
+		os=genix
 		;;
 	i370-*)
-		os=-mvs
-		;;
-	*-next)
-		os=-nextstep3
+		os=mvs
 		;;
 	*-gould)
-		os=-sysv
+		os=sysv
 		;;
 	*-highlevel)
-		os=-bsd
+		os=bsd
 		;;
 	*-encore)
-		os=-bsd
+		os=bsd
 		;;
 	*-sgi)
-		os=-irix
+		os=irix
 		;;
 	*-siemens)
-		os=-sysv4
+		os=sysv4
 		;;
 	*-masscomp)
-		os=-rtu
+		os=rtu
 		;;
 	f30[01]-fujitsu | f700-fujitsu)
-		os=-uxpv
+		os=uxpv
 		;;
 	*-rom68k)
-		os=-coff
+		os=coff
 		;;
 	*-*bug)
-		os=-coff
+		os=coff
 		;;
 	*-apple)
-		os=-macos
+		os=macos
 		;;
 	*-atari*)
-		os=-mint
+		os=mint
+		;;
+	*-wrs)
+		os=vxworks
 		;;
 	*)
-		os=-none
+		os=none
 		;;
 esac
+
 fi
 
+# Now, validate our (potentially fixed-up) OS.
+case $os in
+	# Sometimes we do "kernel-libc", so those need to count as OSes.
+	musl* | newlib* | relibc* | uclibc*)
+		;;
+	# Likewise for "kernel-abi"
+	eabi* | gnueabi*)
+		;;
+	# VxWorks passes extra cpu info in the 4th filed.
+	simlinux | simwindows | spe)
+		;;
+	# Now accept the basic system types.
+	# The portable systems comes first.
+	# Each alternative MUST end in a * to match a version number.
+	gnu* | android* | bsd* | mach* | minix* | genix* | ultrix* | irix* \
+	     | *vms* | esix* | aix* | cnk* | sunos | sunos[34]* \
+	     | hpux* | unos* | osf* | luna* | dgux* | auroraux* | solaris* \
+	     | sym* |  plan9* | psp* | sim* | xray* | os68k* | v88r* \
+	     | hiux* | abug | nacl* | netware* | windows* \
+	     | os9* | macos* | osx* | ios* \
+	     | mpw* | magic* | mmixware* | mon960* | lnews* \
+	     | amigaos* | amigados* | msdos* | newsos* | unicos* | aof* \
+	     | aos* | aros* | cloudabi* | sortix* | twizzler* \
+	     | nindy* | vxsim* | vxworks* | ebmon* | hms* | mvs* \
+	     | clix* | riscos* | uniplus* | iris* | isc* | rtu* | xenix* \
+	     | mirbsd* | netbsd* | dicos* | openedition* | ose* \
+	     | bitrig* | openbsd* | secbsd* | solidbsd* | libertybsd* | os108* \
+	     | ekkobsd* | freebsd* | riscix* | lynxos* | os400* \
+	     | bosx* | nextstep* | cxux* | aout* | elf* | oabi* \
+	     | ptx* | coff* | ecoff* | winnt* | domain* | vsta* \
+	     | udi* | lites* | ieee* | go32* | aux* | hcos* \
+	     | chorusrdb* | cegcc* | glidix* | serenity* \
+	     | cygwin* | msys* | pe* | moss* | proelf* | rtems* \
+	     | midipix* | mingw32* | mingw64* | mint* \
+	     | uxpv* | beos* | mpeix* | udk* | moxiebox* \
+	     | interix* | uwin* | mks* | rhapsody* | darwin* \
+	     | openstep* | oskit* | conix* | pw32* | nonstopux* \
+	     | storm-chaos* | tops10* | tenex* | tops20* | its* \
+	     | os2* | vos* | palmos* | uclinux* | nucleus* | morphos* \
+	     | scout* | superux* | sysv* | rtmk* | tpf* | windiss* \
+	     | powermax* | dnix* | nx6 | nx7 | sei* | dragonfly* \
+	     | skyos* | haiku* | rdos* | toppers* | drops* | es* \
+	     | onefs* | tirtos* | phoenix* | fuchsia* | redox* | bme* \
+	     | midnightbsd* | amdhsa* | unleashed* | emscripten* | wasi* \
+	     | nsk* | powerunix* | genode* | zvmoe* | qnx* | emx* | zephyr* \
+	     | fiwix* )
+		;;
+	# This one is extra strict with allowed versions
+	sco3.2v2 | sco3.2v[4-9]* | sco5v6*)
+		# Don't forget version if it is 3.2v4 or newer.
+		;;
+	none)
+		;;
+	*)
+		echo Invalid configuration \`"$1"\': OS \`"$os"\' not recognized 1>&2
+		exit 1
+		;;
+esac
+
+# As a final step for OS-related things, validate the OS-kernel combination
+# (given a valid OS), if there is a kernel.
+case $kernel-$os in
+	linux-gnu* | linux-dietlibc* | linux-android* | linux-newlib* \
+		   | linux-musl* | linux-relibc* | linux-uclibc* )
+		;;
+	uclinux-uclibc* )
+		;;
+	-dietlibc* | -newlib* | -musl* | -relibc* | -uclibc* )
+		# These are just libc implementations, not actual OSes, and thus
+		# require a kernel.
+		echo "Invalid configuration \`$1': libc \`$os' needs explicit kernel." 1>&2
+		exit 1
+		;;
+	kfreebsd*-gnu* | kopensolaris*-gnu*)
+		;;
+	vxworks-simlinux | vxworks-simwindows | vxworks-spe)
+		;;
+	nto-qnx*)
+		;;
+	os2-emx)
+		;;
+	*-eabi* | *-gnueabi*)
+		;;
+	-*)
+		# Blank kernel with real OS is always fine.
+		;;
+	*-*)
+		echo "Invalid configuration \`$1': Kernel \`$kernel' not known to work with OS \`$os'." 1>&2
+		exit 1
+		;;
+esac
+
 # Here we handle the case where we know the os, and the CPU type, but not the
 # manufacturer.  We pick the logical manufacturer.
-vendor=unknown
-case $basic_machine in
-	*-unknown)
-		case $os in
-			-riscix*)
+case $vendor in
+	unknown)
+		case $cpu-$os in
+			*-riscix*)
 				vendor=acorn
 				;;
-			-sunos*)
+			*-sunos*)
 				vendor=sun
 				;;
-			-cnk*|-aix*)
+			*-cnk* | *-aix*)
 				vendor=ibm
 				;;
-			-beos*)
+			*-beos*)
 				vendor=be
 				;;
-			-hpux*)
+			*-hpux*)
 				vendor=hp
 				;;
-			-mpeix*)
+			*-mpeix*)
 				vendor=hp
 				;;
-			-hiux*)
+			*-hiux*)
 				vendor=hitachi
 				;;
-			-unos*)
+			*-unos*)
 				vendor=crds
 				;;
-			-dgux*)
+			*-dgux*)
 				vendor=dg
 				;;
-			-luna*)
+			*-luna*)
 				vendor=omron
 				;;
-			-genix*)
+			*-genix*)
 				vendor=ns
 				;;
-			-mvs* | -opened*)
+			*-clix*)
+				vendor=intergraph
+				;;
+			*-mvs* | *-opened*)
+				vendor=ibm
+				;;
+			*-os400*)
 				vendor=ibm
 				;;
-			-os400*)
+			s390-* | s390x-*)
 				vendor=ibm
 				;;
-			-ptx*)
+			*-ptx*)
 				vendor=sequent
 				;;
-			-tpf*)
+			*-tpf*)
 				vendor=ibm
 				;;
-			-vxsim* | -vxworks* | -windiss*)
+			*-vxsim* | *-vxworks* | *-windiss*)
 				vendor=wrs
 				;;
-			-aux*)
+			*-aux*)
 				vendor=apple
 				;;
-			-hms*)
+			*-hms*)
 				vendor=hitachi
 				;;
-			-mpw* | -macos*)
+			*-mpw* | *-macos*)
 				vendor=apple
 				;;
-			-*mint | -mint[0-9]* | -*MiNT | -MiNT[0-9]*)
+			*-*mint | *-mint[0-9]* | *-*MiNT | *-MiNT[0-9]*)
 				vendor=atari
 				;;
-			-vos*)
+			*-vos*)
 				vendor=stratus
 				;;
 		esac
-		basic_machine=`echo $basic_machine | sed "s/unknown/$vendor/"`
 		;;
 esac
 
-echo $basic_machine$os
+echo "$cpu-$vendor-${kernel:+$kernel-}$os"
 exit
 
 # Local variables:
-# eval: (add-hook 'write-file-hooks 'time-stamp)
+# eval: (add-hook 'before-save-hook 'time-stamp)
 # time-stamp-start: "timestamp='"
 # time-stamp-format: "%:y-%02m-%02d"
 # time-stamp-end: "'"
diff --git a/autoconf/install-sh b/autoconf/install-sh
index 4fbbae7b7..e046efdf0 100755
--- a/autoconf/install-sh
+++ b/autoconf/install-sh
@@ -1,7 +1,7 @@
-#!/bin/sh
+#!/usr/bin/sh
 # install - install a program, script, or datafile
 
-scriptversion=2006-10-14.15
+scriptversion=2020-11-14.01; # UTC
 
 # This originates from X11R5 (mit/util/scripts/install.sh), which was
 # later released in X11R6 (xc/config/util/install.sh) with the
@@ -35,57 +35,62 @@ scriptversion=2006-10-14.15
 # FSF changes to this file are in the public domain.
 #
 # Calling this script install-sh is preferred over install.sh, to prevent
-# `make' implicit rules from creating a file called install from it
+# 'make' implicit rules from creating a file called install from it
 # when there is no Makefile.
 #
 # This script is compatible with the BSD install script, but was written
 # from scratch.
 
+tab='	'
 nl='
 '
-IFS=" ""	$nl"
+IFS=" $tab$nl"
 
-# set DOITPROG to echo to test this script
+# Set DOITPROG to "echo" to test this script.
 
-# Don't use :- since 4.3BSD and earlier shells don't like it.
-doit="${DOITPROG-}"
-if test -z "$doit"; then
-  doit_exec=exec
-else
-  doit_exec=$doit
-fi
+doit=${DOITPROG-}
+doit_exec=${doit:-exec}
 
 # Put in absolute file names if you don't have them in your path;
 # or use environment vars.
 
-mvprog="${MVPROG-mv}"
-cpprog="${CPPROG-cp}"
-chmodprog="${CHMODPROG-chmod}"
-chownprog="${CHOWNPROG-chown}"
-chgrpprog="${CHGRPPROG-chgrp}"
-stripprog="${STRIPPROG-strip}"
-rmprog="${RMPROG-rm}"
-mkdirprog="${MKDIRPROG-mkdir}"
+chgrpprog=${CHGRPPROG-chgrp}
+chmodprog=${CHMODPROG-chmod}
+chownprog=${CHOWNPROG-chown}
+cmpprog=${CMPPROG-cmp}
+cpprog=${CPPROG-cp}
+mkdirprog=${MKDIRPROG-mkdir}
+mvprog=${MVPROG-mv}
+rmprog=${RMPROG-rm}
+stripprog=${STRIPPROG-strip}
 
-posix_glob=
 posix_mkdir=
 
 # Desired mode of installed file.
 mode=0755
 
+# Create dirs (including intermediate dirs) using mode 755.
+# This is like GNU 'install' as of coreutils 8.32 (2020).
+mkdir_umask=22
+
+backupsuffix=
+chgrpcmd=
 chmodcmd=$chmodprog
 chowncmd=
-chgrpcmd=
-stripcmd=
+mvcmd=$mvprog
 rmcmd="$rmprog -f"
-mvcmd="$mvprog"
+stripcmd=
+
 src=
 dst=
 dir_arg=
-dstarg=
-no_target_directory=
+dst_arg=
+
+copy_on_change=false
+is_target_a_directory=possibly
 
-usage="Usage: $0 [OPTION]... [-T] SRCFILE DSTFILE
+usage="\
+Usage: $0 [OPTION]... [-T] SRCFILE DSTFILE
    or: $0 [OPTION]... SRCFILES... DIRECTORY
    or: $0 [OPTION]... -t DIRECTORY SRCFILES...
    or: $0 [OPTION]... -d DIRECTORIES...
@@ -95,91 +100,116 @@ In the 2nd and 3rd, copy all SRCFILES to DIRECTORY.
 In the 4th, create DIRECTORIES.
 
 Options:
--c         (ignored)
--d         create directories instead of installing files.
--g GROUP   $chgrpprog installed files to GROUP.
--m MODE    $chmodprog installed files to MODE.
--o USER    $chownprog installed files to USER.
--s         $stripprog installed files.
--t DIRECTORY  install into DIRECTORY.
--T         report an error if DSTFILE is a directory.
---help     display this help and exit.
---version  display version info and exit.
+     --help     display this help and exit.
+     --version  display version info and exit.
+
+  -c            (ignored)
+  -C            install only if different (preserve data modification time)
+  -d            create directories instead of installing files.
+  -g GROUP      $chgrpprog installed files to GROUP.
+  -m MODE       $chmodprog installed files to MODE.
+  -o USER       $chownprog installed files to USER.
+  -p            pass -p to $cpprog.
+  -s            $stripprog installed files.
+  -S SUFFIX     attempt to back up existing files, with suffix SUFFIX.
+  -t DIRECTORY  install into DIRECTORY.
+  -T            report an error if DSTFILE is a directory.
 
 Environment variables override the default commands:
-  CHGRPPROG CHMODPROG CHOWNPROG CPPROG MKDIRPROG MVPROG RMPROG STRIPPROG
+  CHGRPPROG CHMODPROG CHOWNPROG CMPPROG CPPROG MKDIRPROG MVPROG
+  RMPROG STRIPPROG
+
+By default, rm is invoked with -f; when overridden with RMPROG,
+it's up to you to specify -f if you want it.
+
+If -S is not specified, no backups are attempted.
+
+Email bug reports to bug-automake at gnu.org.
+Automake home page: https://www.gnu.org/software/automake/
 "
 
 while test $# -ne 0; do
   case $1 in
-    -c) shift
-        continue;;
+    -c) ;;
+
+    -C) copy_on_change=true;;
 
-    -d) dir_arg=true
-        shift
-        continue;;
+    -d) dir_arg=true;;
 
     -g) chgrpcmd="$chgrpprog $2"
-        shift
-        shift
-        continue;;
+        shift;;
 
     --help) echo "$usage"; exit $?;;
 
     -m) mode=$2
-        shift
-        shift
-	case $mode in
-	  *' '* | *'	'* | *'
-'*	  | *'*'* | *'?'* | *'['*)
-	    echo "$0: invalid mode: $mode" >&2
-	    exit 1;;
-	esac
-        continue;;
+        case $mode in
+          *' '* | *"$tab"* | *"$nl"* | *'*'* | *'?'* | *'['*)
+            echo "$0: invalid mode: $mode" >&2
+            exit 1;;
+        esac
+        shift;;
 
     -o) chowncmd="$chownprog $2"
-        shift
-        shift
-        continue;;
+        shift;;
 
-    -s) stripcmd=$stripprog
-        shift
-        continue;;
+    -p) cpprog="$cpprog -p";;
 
-    -t) dstarg=$2
-	shift
-	shift
-	continue;;
+    -s) stripcmd=$stripprog;;
 
-    -T) no_target_directory=true
-	shift
-	continue;;
+    -S) backupsuffix="$2"
+        shift;;
+
+    -t)
+        is_target_a_directory=always
+        dst_arg=$2
+        # Protect names problematic for 'test' and other utilities.
+        case $dst_arg in
+          -* | [=\(\)!]) dst_arg=./$dst_arg;;
+        esac
+        shift;;
+
+    -T) is_target_a_directory=never;;
 
     --version) echo "$0 $scriptversion"; exit $?;;
 
-    --)	shift
-	break;;
+    --) shift
+        break;;
 
-    -*)	echo "$0: invalid option: $1" >&2
-	exit 1;;
+    -*) echo "$0: invalid option: $1" >&2
+        exit 1;;
 
     *)  break;;
   esac
+  shift
 done
 
-if test $# -ne 0 && test -z "$dir_arg$dstarg"; then
+# We allow the use of options -d and -T together, by making -d
+# take the precedence; this is for compatibility with GNU install.
+
+if test -n "$dir_arg"; then
+  if test -n "$dst_arg"; then
+    echo "$0: target directory not allowed when installing a directory." >&2
+    exit 1
+  fi
+fi
+
+if test $# -ne 0 && test -z "$dir_arg$dst_arg"; then
   # When -d is used, all remaining arguments are directories to create.
   # When -t is used, the destination is already specified.
   # Otherwise, the last argument is the destination.  Remove it from $@.
   for arg
   do
-    if test -n "$dstarg"; then
+    if test -n "$dst_arg"; then
       # $@ is not empty: it contains at least $arg.
-      set fnord "$@" "$dstarg"
+      set fnord "$@" "$dst_arg"
       shift # fnord
     fi
     shift # arg
-    dstarg=$arg
+    dst_arg=$arg
+    # Protect names problematic for 'test' and other utilities.
+    case $dst_arg in
+      -* | [=\(\)!]) dst_arg=./$dst_arg;;
+    esac
   done
 fi
 
@@ -188,13 +218,26 @@ if test $# -eq 0; then
     echo "$0: no input file specified." >&2
     exit 1
   fi
-  # It's OK to call `install-sh -d' without argument.
+  # It's OK to call 'install-sh -d' without argument.
   # This can happen when creating conditional directories.
   exit 0
 fi
 
 if test -z "$dir_arg"; then
-  trap '(exit $?); exit' 1 2 13 15
+  if test $# -gt 1 || test "$is_target_a_directory" = always; then
+    if test ! -d "$dst_arg"; then
+      echo "$0: $dst_arg: Is not a directory." >&2
+      exit 1
+    fi
+  fi
+fi
+
+if test -z "$dir_arg"; then
+  do_exit='(exit $ret); exit $ret'
+  trap "ret=129; $do_exit" 1
+  trap "ret=130; $do_exit" 2
+  trap "ret=141; $do_exit" 13
+  trap "ret=143; $do_exit" 15
 
   # Set umask so as not to create temps with too-generous modes.
   # However, 'strip' requires both read and write access to temps.
@@ -205,16 +248,16 @@ if test -z "$dir_arg"; then
 
     *[0-7])
       if test -z "$stripcmd"; then
-	u_plus_rw=
+        u_plus_rw=
       else
-	u_plus_rw='% 200'
+        u_plus_rw='% 200'
       fi
       cp_umask=`expr '(' 777 - $mode % 1000 ')' $u_plus_rw`;;
     *)
       if test -z "$stripcmd"; then
-	u_plus_rw=
+        u_plus_rw=
       else
-	u_plus_rw=,u+rw
+        u_plus_rw=,u+rw
       fi
       cp_umask=$mode$u_plus_rw;;
   esac
@@ -222,9 +265,9 @@ fi
 
 for src
 do
-  # Protect names starting with `-'.
+  # Protect names problematic for 'test' and other utilities.
   case $src in
-    -*) src=./$src ;;
+    -* | [=\(\)!]) src=./$src;;
   esac
 
   if test -n "$dir_arg"; then
@@ -232,6 +275,10 @@ do
     dstdir=$dst
     test -d "$dstdir"
     dstdir_status=$?
+    # Don't chown directories that already exist.
+    if test $dstdir_status = 0; then
+      chowncmd=""
+    fi
   else
 
     # Waiting for this to be detected by the "$cpprog $src $dsttmp" command
@@ -242,196 +289,154 @@ do
       exit 1
     fi
 
-    if test -z "$dstarg"; then
+    if test -z "$dst_arg"; then
       echo "$0: no destination specified." >&2
       exit 1
     fi
+    dst=$dst_arg
 
-    dst=$dstarg
-    # Protect names starting with `-'.
-    case $dst in
-      -*) dst=./$dst ;;
-    esac
-
-    # If destination is a directory, append the input filename; won't work
-    # if double slashes aren't ignored.
+    # If destination is a directory, append the input filename.
     if test -d "$dst"; then
-      if test -n "$no_target_directory"; then
-	echo "$0: $dstarg: Is a directory" >&2
-	exit 1
+      if test "$is_target_a_directory" = never; then
+        echo "$0: $dst_arg: Is a directory" >&2
+        exit 1
       fi
       dstdir=$dst
-      dst=$dstdir/`basename "$src"`
+      dstbase=`basename "$src"`
+      case $dst in
+	*/) dst=$dst$dstbase;;
+	*)  dst=$dst/$dstbase;;
+      esac
       dstdir_status=0
     else
-      # Prefer dirname, but fall back on a substitute if dirname fails.
-      dstdir=`
-	(dirname "$dst") 2>/dev/null ||
-	expr X"$dst" : 'X\(.*[^/]\)//*[^/][^/]*/*$' \| \
-	     X"$dst" : 'X\(//\)[^/]' \| \
-	     X"$dst" : 'X\(//\)$' \| \
-	     X"$dst" : 'X\(/\)' \| . 2>/dev/null ||
-	echo X"$dst" |
-	    sed '/^X\(.*[^/]\)\/\/*[^/][^/]*\/*$/{
-		   s//\1/
-		   q
-		 }
-		 /^X\(\/\/\)[^/].*/{
-		   s//\1/
-		   q
-		 }
-		 /^X\(\/\/\)$/{
-		   s//\1/
-		   q
-		 }
-		 /^X\(\/\).*/{
-		   s//\1/
-		   q
-		 }
-		 s/.*/./; q'
-      `
-
+      dstdir=`dirname "$dst"`
       test -d "$dstdir"
       dstdir_status=$?
     fi
   fi
 
+  case $dstdir in
+    */) dstdirslash=$dstdir;;
+    *)  dstdirslash=$dstdir/;;
+  esac
+
   obsolete_mkdir_used=false
 
   if test $dstdir_status != 0; then
     case $posix_mkdir in
       '')
-	# Create intermediate dirs using mode 755 as modified by the umask.
-	# This is like FreeBSD 'install' as of 1997-10-28.
-	umask=`umask`
-	case $stripcmd.$umask in
-	  # Optimize common cases.
-	  *[2367][2367]) mkdir_umask=$umask;;
-	  .*0[02][02] | .[02][02] | .[02]) mkdir_umask=22;;
-
-	  *[0-7])
-	    mkdir_umask=`expr $umask + 22 \
-	      - $umask % 100 % 40 + $umask % 20 \
-	      - $umask % 10 % 4 + $umask % 2
-	    `;;
-	  *) mkdir_umask=$umask,go-w;;
-	esac
-
-	# With -d, create the new directory with the user-specified mode.
-	# Otherwise, rely on $mkdir_umask.
-	if test -n "$dir_arg"; then
-	  mkdir_mode=-m$mode
+        # With -d, create the new directory with the user-specified mode.
+        # Otherwise, rely on $mkdir_umask.
+        if test -n "$dir_arg"; then
+          mkdir_mode=-m$mode
+        else
+          mkdir_mode=
+        fi
+
+        posix_mkdir=false
+	# The $RANDOM variable is not portable (e.g., dash).  Use it
+	# here however when possible just to lower collision chance.
+	tmpdir=${TMPDIR-/tmp}/ins$RANDOM-$$
+
+	trap '
+	  ret=$?
+	  rmdir "$tmpdir/a/b" "$tmpdir/a" "$tmpdir" 2>/dev/null
+	  exit $ret
+	' 0
+
+	# Because "mkdir -p" follows existing symlinks and we likely work
+	# directly in world-writeable /tmp, make sure that the '$tmpdir'
+	# directory is successfully created first before we actually test
+	# 'mkdir -p'.
+	if (umask $mkdir_umask &&
+	    $mkdirprog $mkdir_mode "$tmpdir" &&
+	    exec $mkdirprog $mkdir_mode -p -- "$tmpdir/a/b") >/dev/null 2>&1
+	then
+	  if test -z "$dir_arg" || {
+	       # Check for POSIX incompatibilities with -m.
+	       # HP-UX 11.23 and IRIX 6.5 mkdir -m -p sets group- or
+	       # other-writable bit of parent directory when it shouldn't.
+	       # FreeBSD 6.1 mkdir -m -p sets mode of existing directory.
+	       test_tmpdir="$tmpdir/a"
+	       ls_ld_tmpdir=`ls -ld "$test_tmpdir"`
+	       case $ls_ld_tmpdir in
+		 d????-?r-*) different_mode=700;;
+		 d????-?--*) different_mode=755;;
+		 *) false;;
+	       esac &&
+	       $mkdirprog -m$different_mode -p -- "$test_tmpdir" && {
+		 ls_ld_tmpdir_1=`ls -ld "$test_tmpdir"`
+		 test "$ls_ld_tmpdir" = "$ls_ld_tmpdir_1"
+	       }
+	     }
+	  then posix_mkdir=:
+	  fi
+	  rmdir "$tmpdir/a/b" "$tmpdir/a" "$tmpdir"
 	else
-	  mkdir_mode=
+	  # Remove any dirs left behind by ancient mkdir implementations.
+	  rmdir ./$mkdir_mode ./-p ./-- "$tmpdir" 2>/dev/null
 	fi
-
-	posix_mkdir=false
-	case $umask in
-	  *[123567][0-7][0-7])
-	    # POSIX mkdir -p sets u+wx bits regardless of umask, which
-	    # is incompatible with FreeBSD 'install' when (umask & 300) != 0.
-	    ;;
-	  *)
-	    tmpdir=${TMPDIR-/tmp}/ins$RANDOM-$$
-	    trap 'ret=$?; rmdir "$tmpdir/d" "$tmpdir" 2>/dev/null; exit $ret' 0
-
-	    if (umask $mkdir_umask &&
-		exec $mkdirprog $mkdir_mode -p -- "$tmpdir/d") >/dev/null 2>&1
-	    then
-	      if test -z "$dir_arg" || {
-		   # Check for POSIX incompatibilities with -m.
-		   # HP-UX 11.23 and IRIX 6.5 mkdir -m -p sets group- or
-		   # other-writeable bit of parent directory when it shouldn't.
-		   # FreeBSD 6.1 mkdir -m -p sets mode of existing directory.
-		   ls_ld_tmpdir=`ls -ld "$tmpdir"`
-		   case $ls_ld_tmpdir in
-		     d????-?r-*) different_mode=700;;
-		     d????-?--*) different_mode=755;;
-		     *) false;;
-		   esac &&
-		   $mkdirprog -m$different_mode -p -- "$tmpdir" && {
-		     ls_ld_tmpdir_1=`ls -ld "$tmpdir"`
-		     test "$ls_ld_tmpdir" = "$ls_ld_tmpdir_1"
-		   }
-		 }
-	      then posix_mkdir=:
-	      fi
-	      rmdir "$tmpdir/d" "$tmpdir"
-	    else
-	      # Remove any dirs left behind by ancient mkdir implementations.
-	      rmdir ./$mkdir_mode ./-p ./-- 2>/dev/null
-	    fi
-	    trap '' 0;;
-	esac;;
+	trap '' 0;;
     esac
 
     if
       $posix_mkdir && (
-	umask $mkdir_umask &&
-	$doit_exec $mkdirprog $mkdir_mode -p -- "$dstdir"
+        umask $mkdir_umask &&
+        $doit_exec $mkdirprog $mkdir_mode -p -- "$dstdir"
       )
     then :
     else
 
-      # The umask is ridiculous, or mkdir does not conform to POSIX,
+      # mkdir does not conform to POSIX,
       # or it failed possibly due to a race condition.  Create the
       # directory the slow way, step by step, checking for races as we go.
 
       case $dstdir in
-	/*) prefix=/ ;;
-	-*) prefix=./ ;;
-	*)  prefix= ;;
-      esac
-
-      case $posix_glob in
-        '')
-	  if (set -f) 2>/dev/null; then
-	    posix_glob=true
-	  else
-	    posix_glob=false
-	  fi ;;
+        /*) prefix='/';;
+        [-=\(\)!]*) prefix='./';;
+        *)  prefix='';;
       esac
 
       oIFS=$IFS
       IFS=/
-      $posix_glob && set -f
+      set -f
       set fnord $dstdir
       shift
-      $posix_glob && set +f
+      set +f
       IFS=$oIFS
 
       prefixes=
 
       for d
       do
-	test -z "$d" && continue
-
-	prefix=$prefix$d
-	if test -d "$prefix"; then
-	  prefixes=
-	else
-	  if $posix_mkdir; then
-	    (umask=$mkdir_umask &&
-	     $doit_exec $mkdirprog $mkdir_mode -p -- "$dstdir") && break
-	    # Don't fail if two instances are running concurrently.
-	    test -d "$prefix" || exit 1
-	  else
-	    case $prefix in
-	      *\'*) qprefix=`echo "$prefix" | sed "s/'/'\\\\\\\\''/g"`;;
-	      *) qprefix=$prefix;;
-	    esac
-	    prefixes="$prefixes '$qprefix'"
-	  fi
-	fi
-	prefix=$prefix/
+        test X"$d" = X && continue
+
+        prefix=$prefix$d
+        if test -d "$prefix"; then
+          prefixes=
+        else
+          if $posix_mkdir; then
+            (umask $mkdir_umask &&
+             $doit_exec $mkdirprog $mkdir_mode -p -- "$dstdir") && break
+            # Don't fail if two instances are running concurrently.
+            test -d "$prefix" || exit 1
+          else
+            case $prefix in
+              *\'*) qprefix=`echo "$prefix" | sed "s/'/'\\\\\\\\''/g"`;;
+              *) qprefix=$prefix;;
+            esac
+            prefixes="$prefixes '$qprefix'"
+          fi
+        fi
+        prefix=$prefix/
       done
 
       if test -n "$prefixes"; then
-	# Don't fail if two instances are running concurrently.
-	(umask $mkdir_umask &&
-	 eval "\$doit_exec \$mkdirprog $prefixes") ||
-	  test -d "$dstdir" || exit 1
-	obsolete_mkdir_used=true
+        # Don't fail if two instances are running concurrently.
+        (umask $mkdir_umask &&
+         eval "\$doit_exec \$mkdirprog $prefixes") ||
+          test -d "$dstdir" || exit 1
+        obsolete_mkdir_used=true
       fi
     fi
   fi
@@ -444,14 +449,25 @@ do
   else
 
     # Make a couple of temp file names in the proper directory.
-    dsttmp=$dstdir/_inst.$$_
-    rmtmp=$dstdir/_rm.$$_
+    dsttmp=${dstdirslash}_inst.$$_
+    rmtmp=${dstdirslash}_rm.$$_
 
     # Trap to clean up those temp files at exit.
     trap 'ret=$?; rm -f "$dsttmp" "$rmtmp" && exit $ret' 0
 
     # Copy the file name to the temp name.
-    (umask $cp_umask && $doit_exec $cpprog "$src" "$dsttmp") &&
+    (umask $cp_umask &&
+     { test -z "$stripcmd" || {
+	 # Create $dsttmp read-write so that cp doesn't create it read-only,
+	 # which would cause strip to fail.
+	 if test -z "$doit"; then
+	   : >"$dsttmp" # No need to fork-exec 'touch'.
+	 else
+	   $doit touch "$dsttmp"
+	 fi
+       }
+     } &&
+     $doit_exec $cpprog "$src" "$dsttmp") &&
 
     # and set any options; do chmod last to preserve setuid bits.
     #
@@ -459,49 +475,67 @@ do
     # ignore errors from any of these, just make sure not to ignore
     # errors from the above "$doit $cpprog $src $dsttmp" command.
     #
-    { test -z "$chowncmd" || $doit $chowncmd "$dsttmp"; } \
-      && { test -z "$chgrpcmd" || $doit $chgrpcmd "$dsttmp"; } \
-      && { test -z "$stripcmd" || $doit $stripcmd "$dsttmp"; } \
-      && { test -z "$chmodcmd" || $doit $chmodcmd $mode "$dsttmp"; } &&
-
-    # Now rename the file to the real destination.
-    { $doit $mvcmd -f "$dsttmp" "$dst" 2>/dev/null \
-      || {
-	   # The rename failed, perhaps because mv can't rename something else
-	   # to itself, or perhaps because mv is so ancient that it does not
-	   # support -f.
-
-	   # Now remove or move aside any old file at destination location.
-	   # We try this two ways since rm can't unlink itself on some
-	   # systems and the destination file might be busy for other
-	   # reasons.  In this case, the final cleanup might fail but the new
-	   # file should still install successfully.
-	   {
-	     if test -f "$dst"; then
-	       $doit $rmcmd -f "$dst" 2>/dev/null \
-	       || { $doit $mvcmd -f "$dst" "$rmtmp" 2>/dev/null \
-		     && { $doit $rmcmd -f "$rmtmp" 2>/dev/null; :; }; }\
-	       || {
-		 echo "$0: cannot unlink or rename $dst" >&2
-		 (exit 1); exit 1
-	       }
-	     else
-	       :
-	     fi
-	   } &&
+    { test -z "$chowncmd" || $doit $chowncmd "$dsttmp"; } &&
+    { test -z "$chgrpcmd" || $doit $chgrpcmd "$dsttmp"; } &&
+    { test -z "$stripcmd" || $doit $stripcmd "$dsttmp"; } &&
+    { test -z "$chmodcmd" || $doit $chmodcmd $mode "$dsttmp"; } &&
+
+    # If -C, don't bother to copy if it wouldn't change the file.
+    if $copy_on_change &&
+       old=`LC_ALL=C ls -dlL "$dst"     2>/dev/null` &&
+       new=`LC_ALL=C ls -dlL "$dsttmp"  2>/dev/null` &&
+       set -f &&
+       set X $old && old=:$2:$4:$5:$6 &&
+       set X $new && new=:$2:$4:$5:$6 &&
+       set +f &&
+       test "$old" = "$new" &&
+       $cmpprog "$dst" "$dsttmp" >/dev/null 2>&1
+    then
+      rm -f "$dsttmp"
+    else
+      # If $backupsuffix is set, and the file being installed
+      # already exists, attempt a backup.  Don't worry if it fails,
+      # e.g., if mv doesn't support -f.
+      if test -n "$backupsuffix" && test -f "$dst"; then
+        $doit $mvcmd -f "$dst" "$dst$backupsuffix" 2>/dev/null
+      fi
 
-	   # Now rename the file to the real destination.
-	   $doit $mvcmd "$dsttmp" "$dst"
-	 }
-    } || exit 1
+      # Rename the file to the real destination.
+      $doit $mvcmd -f "$dsttmp" "$dst" 2>/dev/null ||
+
+      # The rename failed, perhaps because mv can't rename something else
+      # to itself, or perhaps because mv is so ancient that it does not
+      # support -f.
+      {
+        # Now remove or move aside any old file at destination location.
+        # We try this two ways since rm can't unlink itself on some
+        # systems and the destination file might be busy for other
+        # reasons.  In this case, the final cleanup might fail but the new
+        # file should still install successfully.
+        {
+          test ! -f "$dst" ||
+          $doit $rmcmd "$dst" 2>/dev/null ||
+          { $doit $mvcmd -f "$dst" "$rmtmp" 2>/dev/null &&
+            { $doit $rmcmd "$rmtmp" 2>/dev/null; :; }
+          } ||
+          { echo "$0: cannot unlink or rename $dst" >&2
+            (exit 1); exit 1
+          }
+        } &&
+
+        # Now rename the file to the real destination.
+        $doit $mvcmd "$dsttmp" "$dst"
+      }
+    fi || exit 1
 
     trap '' 0
   fi
 done
 
 # Local variables:
-# eval: (add-hook 'write-file-hooks 'time-stamp)
+# eval: (add-hook 'before-save-hook 'time-stamp)
 # time-stamp-start: "scriptversion="
 # time-stamp-format: "%:y-%02m-%02d.%02H"
-# time-stamp-end: "$"
+# time-stamp-time-zone: "UTC0"
+# time-stamp-end: "; # UTC"
 # End:
diff --git a/configure b/configure
index cfad36e51..3586dd91c 100755
--- a/configure
+++ b/configure
@@ -1,9 +1,10 @@
 #! /bin/sh
 # Guess values for system-dependent variables and create Makefiles.
-# Generated by GNU Autoconf 2.69.
+# Generated by GNU Autoconf 2.71.
 #
 #
-# Copyright (C) 1992-1996, 1998-2012 Free Software Foundation, Inc.
+# Copyright (C) 1992-1996, 1998-2017, 2020-2021 Free Software Foundation,
+# Inc.
 #
 #
 # This configure script is free software; the Free Software Foundation
@@ -14,14 +15,16 @@
 
 # Be more Bourne compatible
 DUALCASE=1; export DUALCASE # for MKS sh
-if test -n "${ZSH_VERSION+set}" && (emulate sh) >/dev/null 2>&1; then :
+as_nop=:
+if test ${ZSH_VERSION+y} && (emulate sh) >/dev/null 2>&1
+then :
   emulate sh
   NULLCMD=:
   # Pre-4.2 versions of Zsh do word splitting on ${1+"$@"}, which
   # is contrary to our usage.  Disable this feature.
   alias -g '${1+"$@"}'='"$@"'
   setopt NO_GLOB_SUBST
-else
+else $as_nop
   case `(set -o) 2>/dev/null` in #(
   *posix*) :
     set -o posix ;; #(
@@ -31,46 +34,46 @@ esac
 fi
 
 
+
+# Reset variables that may have inherited troublesome values from
+# the environment.
+
+# IFS needs to be set, to space, tab, and newline, in precisely that order.
+# (If _AS_PATH_WALK were called with IFS unset, it would have the
+# side effect of setting IFS to empty, thus disabling word splitting.)
+# Quoting is to prevent editors from complaining about space-tab.
 as_nl='
 '
 export as_nl
-# Printing a long string crashes Solaris 7 /usr/bin/printf.
-as_echo='\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\'
-as_echo=$as_echo$as_echo$as_echo$as_echo$as_echo
-as_echo=$as_echo$as_echo$as_echo$as_echo$as_echo$as_echo
-# Prefer a ksh shell builtin over an external printf program on Solaris,
-# but without wasting forks for bash or zsh.
-if test -z "$BASH_VERSION$ZSH_VERSION" \
-    && (test "X`print -r -- $as_echo`" = "X$as_echo") 2>/dev/null; then
-  as_echo='print -r --'
-  as_echo_n='print -rn --'
-elif (test "X`printf %s $as_echo`" = "X$as_echo") 2>/dev/null; then
-  as_echo='printf %s\n'
-  as_echo_n='printf %s'
-else
-  if test "X`(/usr/ucb/echo -n -n $as_echo) 2>/dev/null`" = "X-n $as_echo"; then
-    as_echo_body='eval /usr/ucb/echo -n "$1$as_nl"'
-    as_echo_n='/usr/ucb/echo -n'
-  else
-    as_echo_body='eval expr "X$1" : "X\\(.*\\)"'
-    as_echo_n_body='eval
-      arg=$1;
-      case $arg in #(
-      *"$as_nl"*)
-	expr "X$arg" : "X\\(.*\\)$as_nl";
-	arg=`expr "X$arg" : ".*$as_nl\\(.*\\)"`;;
-      esac;
-      expr "X$arg" : "X\\(.*\\)" | tr -d "$as_nl"
-    '
-    export as_echo_n_body
-    as_echo_n='sh -c $as_echo_n_body as_echo'
-  fi
-  export as_echo_body
-  as_echo='sh -c $as_echo_body as_echo'
-fi
+IFS=" ""	$as_nl"
+
+PS1='$ '
+PS2='> '
+PS4='+ '
+
+# Ensure predictable behavior from utilities with locale-dependent output.
+LC_ALL=C
+export LC_ALL
+LANGUAGE=C
+export LANGUAGE
+
+# We cannot yet rely on "unset" to work, but we need these variables
+# to be unset--not just set to an empty or harmless value--now, to
+# avoid bugs in old shells (e.g. pre-3.0 UWIN ksh).  This construct
+# also avoids known problems related to "unset" and subshell syntax
+# in other old shells (e.g. bash 2.01 and pdksh 5.2.14).
+for as_var in BASH_ENV ENV MAIL MAILPATH CDPATH
+do eval test \${$as_var+y} \
+  && ( (unset $as_var) || exit 1) >/dev/null 2>&1 && unset $as_var || :
+done
+
+# Ensure that fds 0, 1, and 2 are open.
+if (exec 3>&0) 2>/dev/null; then :; else exec 0</dev/null; fi
+if (exec 3>&1) 2>/dev/null; then :; else exec 1>/dev/null; fi
+if (exec 3>&2)            ; then :; else exec 2>/dev/null; fi
 
 # The user is always right.
-if test "${PATH_SEPARATOR+set}" != set; then
+if ${PATH_SEPARATOR+false} :; then
   PATH_SEPARATOR=:
   (PATH='/bin;/bin'; FPATH=$PATH; sh -c :) >/dev/null 2>&1 && {
     (PATH='/bin:/bin'; FPATH=$PATH; sh -c :) >/dev/null 2>&1 ||
@@ -79,13 +82,6 @@ if test "${PATH_SEPARATOR+set}" != set; then
 fi
 
 
-# IFS
-# We need space, tab and new line, in precisely that order.  Quoting is
-# there to prevent editors from complaining about space-tab.
-# (If _AS_PATH_WALK were called with IFS unset, it would disable word
-# splitting by setting IFS to empty value.)
-IFS=" ""	$as_nl"
-
 # Find who we are.  Look in the path if we contain no directory separator.
 as_myself=
 case $0 in #((
@@ -94,8 +90,12 @@ case $0 in #((
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
-    test -r "$as_dir/$0" && as_myself=$as_dir/$0 && break
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
+    test -r "$as_dir$0" && as_myself=$as_dir$0 && break
   done
 IFS=$as_save_IFS
 
@@ -107,30 +107,10 @@ if test "x$as_myself" = x; then
   as_myself=$0
 fi
 if test ! -f "$as_myself"; then
-  $as_echo "$as_myself: error: cannot find myself; rerun with an absolute file name" >&2
+  printf "%s\n" "$as_myself: error: cannot find myself; rerun with an absolute file name" >&2
   exit 1
 fi
 
-# Unset variables that we do not need and which cause bugs (e.g. in
-# pre-3.0 UWIN ksh).  But do not cause bugs in bash 2.01; the "|| exit 1"
-# suppresses any "Segmentation fault" message there.  '((' could
-# trigger a bug in pdksh 5.2.14.
-for as_var in BASH_ENV ENV MAIL MAILPATH
-do eval test x\${$as_var+set} = xset \
-  && ( (unset $as_var) || exit 1) >/dev/null 2>&1 && unset $as_var || :
-done
-PS1='$ '
-PS2='> '
-PS4='+ '
-
-# NLS nuisances.
-LC_ALL=C
-export LC_ALL
-LANGUAGE=C
-export LANGUAGE
-
-# CDPATH.
-(unset CDPATH) >/dev/null 2>&1 && unset CDPATH
 
 # Use a proper internal environment variable to ensure we don't fall
   # into an infinite loop, continuously re-executing ourselves.
@@ -152,20 +132,22 @@ esac
 exec $CONFIG_SHELL $as_opts "$as_myself" ${1+"$@"}
 # Admittedly, this is quite paranoid, since all the known shells bail
 # out after a failed `exec'.
-$as_echo "$0: could not re-execute with $CONFIG_SHELL" >&2
-as_fn_exit 255
+printf "%s\n" "$0: could not re-execute with $CONFIG_SHELL" >&2
+exit 255
   fi
   # We don't want this to propagate to other subprocesses.
           { _as_can_reexec=; unset _as_can_reexec;}
 if test "x$CONFIG_SHELL" = x; then
-  as_bourne_compatible="if test -n \"\${ZSH_VERSION+set}\" && (emulate sh) >/dev/null 2>&1; then :
+  as_bourne_compatible="as_nop=:
+if test \${ZSH_VERSION+y} && (emulate sh) >/dev/null 2>&1
+then :
   emulate sh
   NULLCMD=:
   # Pre-4.2 versions of Zsh do word splitting on \${1+\"\$@\"}, which
   # is contrary to our usage.  Disable this feature.
   alias -g '\${1+\"\$@\"}'='\"\$@\"'
   setopt NO_GLOB_SUBST
-else
+else \$as_nop
   case \`(set -o) 2>/dev/null\` in #(
   *posix*) :
     set -o posix ;; #(
@@ -185,42 +167,53 @@ as_fn_success || { exitcode=1; echo as_fn_success failed.; }
 as_fn_failure && { exitcode=1; echo as_fn_failure succeeded.; }
 as_fn_ret_success || { exitcode=1; echo as_fn_ret_success failed.; }
 as_fn_ret_failure && { exitcode=1; echo as_fn_ret_failure succeeded.; }
-if ( set x; as_fn_ret_success y && test x = \"\$1\" ); then :
+if ( set x; as_fn_ret_success y && test x = \"\$1\" )
+then :
 
-else
+else \$as_nop
   exitcode=1; echo positional parameters were not saved.
 fi
 test x\$exitcode = x0 || exit 1
+blah=\$(echo \$(echo blah))
+test x\"\$blah\" = xblah || exit 1
 test -x / || exit 1"
   as_suggested="  as_lineno_1=";as_suggested=$as_suggested$LINENO;as_suggested=$as_suggested" as_lineno_1a=\$LINENO
   as_lineno_2=";as_suggested=$as_suggested$LINENO;as_suggested=$as_suggested" as_lineno_2a=\$LINENO
   eval 'test \"x\$as_lineno_1'\$as_run'\" != \"x\$as_lineno_2'\$as_run'\" &&
   test \"x\`expr \$as_lineno_1'\$as_run' + 1\`\" = \"x\$as_lineno_2'\$as_run'\"' || exit 1
 test \$(( 1 + 1 )) = 2 || exit 1"
-  if (eval "$as_required") 2>/dev/null; then :
+  if (eval "$as_required") 2>/dev/null
+then :
   as_have_required=yes
-else
+else $as_nop
   as_have_required=no
 fi
-  if test x$as_have_required = xyes && (eval "$as_suggested") 2>/dev/null; then :
+  if test x$as_have_required = xyes && (eval "$as_suggested") 2>/dev/null
+then :
 
-else
+else $as_nop
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
 as_found=false
 for as_dir in /bin$PATH_SEPARATOR/usr/bin$PATH_SEPARATOR$PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
   as_found=:
   case $as_dir in #(
 	 /*)
 	   for as_base in sh bash ksh sh5; do
 	     # Try only shells that exist, to save several forks.
-	     as_shell=$as_dir/$as_base
+	     as_shell=$as_dir$as_base
 	     if { test -f "$as_shell" || test -f "$as_shell.exe"; } &&
-		    { $as_echo "$as_bourne_compatible""$as_required" | as_run=a "$as_shell"; } 2>/dev/null; then :
+		    as_run=a "$as_shell" -c "$as_bourne_compatible""$as_required" 2>/dev/null
+then :
   CONFIG_SHELL=$as_shell as_have_required=yes
-		   if { $as_echo "$as_bourne_compatible""$as_suggested" | as_run=a "$as_shell"; } 2>/dev/null; then :
+		   if as_run=a "$as_shell" -c "$as_bourne_compatible""$as_suggested" 2>/dev/null
+then :
   break 2
 fi
 fi
@@ -228,14 +221,21 @@ fi
        esac
   as_found=false
 done
-$as_found || { if { test -f "$SHELL" || test -f "$SHELL.exe"; } &&
-	      { $as_echo "$as_bourne_compatible""$as_required" | as_run=a "$SHELL"; } 2>/dev/null; then :
-  CONFIG_SHELL=$SHELL as_have_required=yes
-fi; }
 IFS=$as_save_IFS
+if $as_found
+then :
+
+else $as_nop
+  if { test -f "$SHELL" || test -f "$SHELL.exe"; } &&
+	      as_run=a "$SHELL" -c "$as_bourne_compatible""$as_required" 2>/dev/null
+then :
+  CONFIG_SHELL=$SHELL as_have_required=yes
+fi
+fi
 
 
-      if test "x$CONFIG_SHELL" != x; then :
+      if test "x$CONFIG_SHELL" != x
+then :
   export CONFIG_SHELL
              # We cannot yet assume a decent shell, so we have to provide a
 # neutralization value for shells without unset; and this also
@@ -253,18 +253,19 @@ esac
 exec $CONFIG_SHELL $as_opts "$as_myself" ${1+"$@"}
 # Admittedly, this is quite paranoid, since all the known shells bail
 # out after a failed `exec'.
-$as_echo "$0: could not re-execute with $CONFIG_SHELL" >&2
+printf "%s\n" "$0: could not re-execute with $CONFIG_SHELL" >&2
 exit 255
 fi
 
-    if test x$as_have_required = xno; then :
-  $as_echo "$0: This script requires a shell more modern than all"
-  $as_echo "$0: the shells that I found on your system."
-  if test x${ZSH_VERSION+set} = xset ; then
-    $as_echo "$0: In particular, zsh $ZSH_VERSION has bugs and should"
-    $as_echo "$0: be upgraded to zsh 4.3.4 or later."
+    if test x$as_have_required = xno
+then :
+  printf "%s\n" "$0: This script requires a shell more modern than all"
+  printf "%s\n" "$0: the shells that I found on your system."
+  if test ${ZSH_VERSION+y} ; then
+    printf "%s\n" "$0: In particular, zsh $ZSH_VERSION has bugs and should"
+    printf "%s\n" "$0: be upgraded to zsh 4.3.4 or later."
   else
-    $as_echo "$0: Please tell bug-autoconf at gnu.org about your system,
+    printf "%s\n" "$0: Please tell bug-autoconf at gnu.org about your system,
 $0: including any error possibly output before this
 $0: message. Then install a modern shell, or manually run
 $0: the script under such a shell if you do have one."
@@ -291,6 +292,7 @@ as_fn_unset ()
 }
 as_unset=as_fn_unset
 
+
 # as_fn_set_status STATUS
 # -----------------------
 # Set $? to STATUS, without forking.
@@ -308,6 +310,14 @@ as_fn_exit ()
   as_fn_set_status $1
   exit $1
 } # as_fn_exit
+# as_fn_nop
+# ---------
+# Do nothing but, unlike ":", preserve the value of $?.
+as_fn_nop ()
+{
+  return $?
+}
+as_nop=as_fn_nop
 
 # as_fn_mkdir_p
 # -------------
@@ -322,7 +332,7 @@ as_fn_mkdir_p ()
     as_dirs=
     while :; do
       case $as_dir in #(
-      *\'*) as_qdir=`$as_echo "$as_dir" | sed "s/'/'\\\\\\\\''/g"`;; #'(
+      *\'*) as_qdir=`printf "%s\n" "$as_dir" | sed "s/'/'\\\\\\\\''/g"`;; #'(
       *) as_qdir=$as_dir;;
       esac
       as_dirs="'$as_qdir' $as_dirs"
@@ -331,7 +341,7 @@ $as_expr X"$as_dir" : 'X\(.*[^/]\)//*[^/][^/]*/*$' \| \
 	 X"$as_dir" : 'X\(//\)[^/]' \| \
 	 X"$as_dir" : 'X\(//\)$' \| \
 	 X"$as_dir" : 'X\(/\)' \| . 2>/dev/null ||
-$as_echo X"$as_dir" |
+printf "%s\n" X"$as_dir" |
     sed '/^X\(.*[^/]\)\/\/*[^/][^/]*\/*$/{
 	    s//\1/
 	    q
@@ -370,12 +380,13 @@ as_fn_executable_p ()
 # advantage of any shell optimizations that allow amortized linear growth over
 # repeated appends, instead of the typical quadratic growth present in naive
 # implementations.
-if (eval "as_var=1; as_var+=2; test x\$as_var = x12") 2>/dev/null; then :
+if (eval "as_var=1; as_var+=2; test x\$as_var = x12") 2>/dev/null
+then :
   eval 'as_fn_append ()
   {
     eval $1+=\$2
   }'
-else
+else $as_nop
   as_fn_append ()
   {
     eval $1=\$$1\$2
@@ -387,18 +398,27 @@ fi # as_fn_append
 # Perform arithmetic evaluation on the ARGs, and store the result in the
 # global $as_val. Take advantage of shells that can avoid forks. The arguments
 # must be portable across $(()) and expr.
-if (eval "test \$(( 1 + 1 )) = 2") 2>/dev/null; then :
+if (eval "test \$(( 1 + 1 )) = 2") 2>/dev/null
+then :
   eval 'as_fn_arith ()
   {
     as_val=$(( $* ))
   }'
-else
+else $as_nop
   as_fn_arith ()
   {
     as_val=`expr "$@" || test $? -eq 1`
   }
 fi # as_fn_arith
 
+# as_fn_nop
+# ---------
+# Do nothing but, unlike ":", preserve the value of $?.
+as_fn_nop ()
+{
+  return $?
+}
+as_nop=as_fn_nop
 
 # as_fn_error STATUS ERROR [LINENO LOG_FD]
 # ----------------------------------------
@@ -410,9 +430,9 @@ as_fn_error ()
   as_status=$1; test $as_status -eq 0 && as_status=1
   if test "$4"; then
     as_lineno=${as_lineno-"$3"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
-    $as_echo "$as_me:${as_lineno-$LINENO}: error: $2" >&$4
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: $2" >&$4
   fi
-  $as_echo "$as_me: error: $2" >&2
+  printf "%s\n" "$as_me: error: $2" >&2
   as_fn_exit $as_status
 } # as_fn_error
 
@@ -439,7 +459,7 @@ as_me=`$as_basename -- "$0" ||
 $as_expr X/"$0" : '.*/\([^/][^/]*\)/*$' \| \
 	 X"$0" : 'X\(//\)$' \| \
 	 X"$0" : 'X\(/\)' \| . 2>/dev/null ||
-$as_echo X/"$0" |
+printf "%s\n" X/"$0" |
     sed '/^.*\/\([^/][^/]*\)\/*$/{
 	    s//\1/
 	    q
@@ -483,7 +503,7 @@ as_cr_alnum=$as_cr_Letters$as_cr_digits
       s/-\n.*//
     ' >$as_me.lineno &&
   chmod +x "$as_me.lineno" ||
-    { $as_echo "$as_me: error: cannot create $as_me.lineno; rerun with a POSIX shell" >&2; as_fn_exit 1; }
+    { printf "%s\n" "$as_me: error: cannot create $as_me.lineno; rerun with a POSIX shell" >&2; as_fn_exit 1; }
 
   # If we had to re-execute with $CONFIG_SHELL, we're ensured to have
   # already done that, so ensure we don't try to do so again and fall
@@ -497,6 +517,10 @@ as_cr_alnum=$as_cr_Letters$as_cr_digits
   exit
 }
 
+
+# Determine whether it's possible to make 'echo' print without a newline.
+# These variables are no longer used directly by Autoconf, but are AC_SUBSTed
+# for compatibility with existing Makefiles.
 ECHO_C= ECHO_N= ECHO_T=
 case `echo -n x` in #(((((
 -n*)
@@ -510,6 +534,13 @@ case `echo -n x` in #(((((
   ECHO_N='-n';;
 esac
 
+# For backward compatibility with old third-party macros, we provide
+# the shell variables $as_echo and $as_echo_n.  New code should use
+# AS_ECHO(["message"]) and AS_ECHO_N(["message"]), respectively.
+as_echo='printf %s\n'
+as_echo_n='printf %s'
+
+
 rm -f conf$$ conf$$.exe conf$$.file
 if test -d conf$$.dir; then
   rm -f conf$$.dir/conf$$.file
@@ -575,52 +606,47 @@ MFLAGS=
 MAKEFLAGS=
 
 # Identity of this package.
-PACKAGE_NAME=
-PACKAGE_TARNAME=
-PACKAGE_VERSION=
-PACKAGE_STRING=
-PACKAGE_BUGREPORT=
-PACKAGE_URL=
+PACKAGE_NAME=''
+PACKAGE_TARNAME=''
+PACKAGE_VERSION=''
+PACKAGE_STRING=''
+PACKAGE_BUGREPORT=''
+PACKAGE_URL=''
 
 ac_unique_file="lib/device/dev-cache.h"
 # Factoring default headers for most tests.
 ac_includes_default="\
-#include <stdio.h>
-#ifdef HAVE_SYS_TYPES_H
-# include <sys/types.h>
-#endif
-#ifdef HAVE_SYS_STAT_H
-# include <sys/stat.h>
+#include <stddef.h>
+#ifdef HAVE_STDIO_H
+# include <stdio.h>
 #endif
-#ifdef STDC_HEADERS
+#ifdef HAVE_STDLIB_H
 # include <stdlib.h>
-# include <stddef.h>
-#else
-# ifdef HAVE_STDLIB_H
-#  include <stdlib.h>
-# endif
 #endif
 #ifdef HAVE_STRING_H
-# if !defined STDC_HEADERS && defined HAVE_MEMORY_H
-#  include <memory.h>
-# endif
 # include <string.h>
 #endif
-#ifdef HAVE_STRINGS_H
-# include <strings.h>
-#endif
 #ifdef HAVE_INTTYPES_H
 # include <inttypes.h>
 #endif
 #ifdef HAVE_STDINT_H
 # include <stdint.h>
 #endif
+#ifdef HAVE_STRINGS_H
+# include <strings.h>
+#endif
+#ifdef HAVE_SYS_TYPES_H
+# include <sys/types.h>
+#endif
+#ifdef HAVE_SYS_STAT_H
+# include <sys/stat.h>
+#endif
 #ifdef HAVE_UNISTD_H
 # include <unistd.h>
 #endif"
 
-ac_header_list=
-ac_func_list=
+ac_header_c_list=
+ac_func_c_list=
 ac_default_prefix=/usr
 ac_subst_vars='LTLIBOBJS
 usrsbindir
@@ -765,9 +791,9 @@ pkgpyexecdir
 pyexecdir
 pkgpythondir
 pythondir
-PYTHON_PLATFORM
 PYTHON_EXEC_PREFIX
 PYTHON_PREFIX
+PYTHON_PLATFORM
 PYTHON_VERSION
 PYTHON
 LVM2CMD_LIB
@@ -969,6 +995,9 @@ enable_ioctl
 enable_o_direct
 enable_cmdlib
 enable_dbus_service
+with_python_sys_prefix
+with_python_prefix
+with_python_exec_prefix
 enable_pkgconfig
 enable_write_install
 enable_fsadm
@@ -1107,8 +1136,6 @@ do
   *)    ac_optarg=yes ;;
   esac
 
-  # Accept the important Cygnus configure options, so we can diagnose typos.
-
   case $ac_dashdash$ac_option in
   --)
     ac_dashdash=yes ;;
@@ -1149,9 +1176,9 @@ do
     ac_useropt=`expr "x$ac_option" : 'x-*disable-\(.*\)'`
     # Reject names that are not valid shell variable names.
     expr "x$ac_useropt" : ".*[^-+._$as_cr_alnum]" >/dev/null &&
-      as_fn_error $? "invalid feature name: $ac_useropt"
+      as_fn_error $? "invalid feature name: \`$ac_useropt'"
     ac_useropt_orig=$ac_useropt
-    ac_useropt=`$as_echo "$ac_useropt" | sed 's/[-+.]/_/g'`
+    ac_useropt=`printf "%s\n" "$ac_useropt" | sed 's/[-+.]/_/g'`
     case $ac_user_opts in
       *"
 "enable_$ac_useropt"
@@ -1175,9 +1202,9 @@ do
     ac_useropt=`expr "x$ac_option" : 'x-*enable-\([^=]*\)'`
     # Reject names that are not valid shell variable names.
     expr "x$ac_useropt" : ".*[^-+._$as_cr_alnum]" >/dev/null &&
-      as_fn_error $? "invalid feature name: $ac_useropt"
+      as_fn_error $? "invalid feature name: \`$ac_useropt'"
     ac_useropt_orig=$ac_useropt
-    ac_useropt=`$as_echo "$ac_useropt" | sed 's/[-+.]/_/g'`
+    ac_useropt=`printf "%s\n" "$ac_useropt" | sed 's/[-+.]/_/g'`
     case $ac_user_opts in
       *"
 "enable_$ac_useropt"
@@ -1388,9 +1415,9 @@ do
     ac_useropt=`expr "x$ac_option" : 'x-*with-\([^=]*\)'`
     # Reject names that are not valid shell variable names.
     expr "x$ac_useropt" : ".*[^-+._$as_cr_alnum]" >/dev/null &&
-      as_fn_error $? "invalid package name: $ac_useropt"
+      as_fn_error $? "invalid package name: \`$ac_useropt'"
     ac_useropt_orig=$ac_useropt
-    ac_useropt=`$as_echo "$ac_useropt" | sed 's/[-+.]/_/g'`
+    ac_useropt=`printf "%s\n" "$ac_useropt" | sed 's/[-+.]/_/g'`
     case $ac_user_opts in
       *"
 "with_$ac_useropt"
@@ -1404,9 +1431,9 @@ do
     ac_useropt=`expr "x$ac_option" : 'x-*without-\(.*\)'`
     # Reject names that are not valid shell variable names.
     expr "x$ac_useropt" : ".*[^-+._$as_cr_alnum]" >/dev/null &&
-      as_fn_error $? "invalid package name: $ac_useropt"
+      as_fn_error $? "invalid package name: \`$ac_useropt'"
     ac_useropt_orig=$ac_useropt
-    ac_useropt=`$as_echo "$ac_useropt" | sed 's/[-+.]/_/g'`
+    ac_useropt=`printf "%s\n" "$ac_useropt" | sed 's/[-+.]/_/g'`
     case $ac_user_opts in
       *"
 "with_$ac_useropt"
@@ -1450,9 +1477,9 @@ Try \`$0 --help' for more information"
 
   *)
     # FIXME: should be removed in autoconf 3.0.
-    $as_echo "$as_me: WARNING: you should use --build, --host, --target" >&2
+    printf "%s\n" "$as_me: WARNING: you should use --build, --host, --target" >&2
     expr "x$ac_option" : ".*[^-._$as_cr_alnum]" >/dev/null &&
-      $as_echo "$as_me: WARNING: invalid host type: $ac_option" >&2
+      printf "%s\n" "$as_me: WARNING: invalid host type: $ac_option" >&2
     : "${build_alias=$ac_option} ${host_alias=$ac_option} ${target_alias=$ac_option}"
     ;;
 
@@ -1468,7 +1495,7 @@ if test -n "$ac_unrecognized_opts"; then
   case $enable_option_checking in
     no) ;;
     fatal) as_fn_error $? "unrecognized options: $ac_unrecognized_opts" ;;
-    *)     $as_echo "$as_me: WARNING: unrecognized options: $ac_unrecognized_opts" >&2 ;;
+    *)     printf "%s\n" "$as_me: WARNING: unrecognized options: $ac_unrecognized_opts" >&2 ;;
   esac
 fi
 
@@ -1532,7 +1559,7 @@ $as_expr X"$as_myself" : 'X\(.*[^/]\)//*[^/][^/]*/*$' \| \
 	 X"$as_myself" : 'X\(//\)[^/]' \| \
 	 X"$as_myself" : 'X\(//\)$' \| \
 	 X"$as_myself" : 'X\(/\)' \| . 2>/dev/null ||
-$as_echo X"$as_myself" |
+printf "%s\n" X"$as_myself" |
     sed '/^X\(.*[^/]\)\/\/*[^/][^/]*\/*$/{
 	    s//\1/
 	    q
@@ -1776,6 +1803,11 @@ Optional Packages:
                           lvmlockd pidfile [PID_DIR/lvmlockd.pid]
   --with-lvmpolld-pidfile=PATH
                           lvmpolld pidfile [PID_DIR/lvmpolld.pid]
+  --with-python-sys-prefix
+                          use Python's sys.prefix and sys.exec_prefix values
+  --with-python_prefix    override the default PYTHON_PREFIX
+  --with-python_exec_prefix
+                          override the default PYTHON_EXEC_PREFIX
   --with-localedir=DIR    locale-dependent data [DATAROOTDIR/locale]
   --with-confdir=DIR      configuration files in DIR [/etc]
   --with-staticdir=DIR    static binaries in DIR [EPREFIX/sbin]
@@ -1889,9 +1921,9 @@ if test "$ac_init_help" = "recursive"; then
 case "$ac_dir" in
 .) ac_dir_suffix= ac_top_builddir_sub=. ac_top_build_prefix= ;;
 *)
-  ac_dir_suffix=/`$as_echo "$ac_dir" | sed 's|^\.[\\/]||'`
+  ac_dir_suffix=/`printf "%s\n" "$ac_dir" | sed 's|^\.[\\/]||'`
   # A ".." for each directory in $ac_dir_suffix.
-  ac_top_builddir_sub=`$as_echo "$ac_dir_suffix" | sed 's|/[^\\/]*|/..|g;s|/||'`
+  ac_top_builddir_sub=`printf "%s\n" "$ac_dir_suffix" | sed 's|/[^\\/]*|/..|g;s|/||'`
   case $ac_top_builddir_sub in
   "") ac_top_builddir_sub=. ac_top_build_prefix= ;;
   *)  ac_top_build_prefix=$ac_top_builddir_sub/ ;;
@@ -1919,7 +1951,8 @@ esac
 ac_abs_srcdir=$ac_abs_top_srcdir$ac_dir_suffix
 
     cd "$ac_dir" || { ac_status=$?; continue; }
-    # Check for guested configure.
+    # Check for configure.gnu first; this name is used for a wrapper for
+    # Metaconfig's "Configure" on case-insensitive file systems.
     if test -f "$ac_srcdir/configure.gnu"; then
       echo &&
       $SHELL "$ac_srcdir/configure.gnu" --help=recursive
@@ -1927,7 +1960,7 @@ ac_abs_srcdir=$ac_abs_top_srcdir$ac_dir_suffix
       echo &&
       $SHELL "$ac_srcdir/configure" --help=recursive
     else
-      $as_echo "$as_me: WARNING: no configuration information is in $ac_dir" >&2
+      printf "%s\n" "$as_me: WARNING: no configuration information is in $ac_dir" >&2
     fi || ac_status=$?
     cd "$ac_pwd" || { ac_status=$?; break; }
   done
@@ -1937,9 +1970,9 @@ test -n "$ac_init_help" && exit $ac_status
 if $ac_init_version; then
   cat <<\_ACEOF
 configure
-generated by GNU Autoconf 2.69
+generated by GNU Autoconf 2.71
 
-Copyright (C) 2012 Free Software Foundation, Inc.
+Copyright (C) 2021 Free Software Foundation, Inc.
 This configure script is free software; the Free Software Foundation
 gives unlimited permission to copy, distribute and modify it.
 _ACEOF
@@ -1956,14 +1989,14 @@ fi
 ac_fn_c_try_compile ()
 {
   as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
-  rm -f conftest.$ac_objext
+  rm -f conftest.$ac_objext conftest.beam
   if { { ac_try="$ac_compile"
 case "(($ac_try" in
   *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
   *) ac_try_echo=$ac_try;;
 esac
 eval ac_try_echo="\"\$as_me:${as_lineno-$LINENO}: $ac_try_echo\""
-$as_echo "$ac_try_echo"; } >&5
+printf "%s\n" "$ac_try_echo"; } >&5
   (eval "$ac_compile") 2>conftest.err
   ac_status=$?
   if test -s conftest.err; then
@@ -1971,14 +2004,15 @@ $as_echo "$ac_try_echo"; } >&5
     cat conftest.er1 >&5
     mv -f conftest.er1 conftest.err
   fi
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; } && {
 	 test -z "$ac_c_werror_flag" ||
 	 test ! -s conftest.err
-       } && test -s conftest.$ac_objext; then :
+       } && test -s conftest.$ac_objext
+then :
   ac_retval=0
-else
-  $as_echo "$as_me: failed program was:" >&5
+else $as_nop
+  printf "%s\n" "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
 	ac_retval=1
@@ -1994,14 +2028,14 @@ fi
 ac_fn_cxx_try_compile ()
 {
   as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
-  rm -f conftest.$ac_objext
+  rm -f conftest.$ac_objext conftest.beam
   if { { ac_try="$ac_compile"
 case "(($ac_try" in
   *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
   *) ac_try_echo=$ac_try;;
 esac
 eval ac_try_echo="\"\$as_me:${as_lineno-$LINENO}: $ac_try_echo\""
-$as_echo "$ac_try_echo"; } >&5
+printf "%s\n" "$ac_try_echo"; } >&5
   (eval "$ac_compile") 2>conftest.err
   ac_status=$?
   if test -s conftest.err; then
@@ -2009,14 +2043,15 @@ $as_echo "$ac_try_echo"; } >&5
     cat conftest.er1 >&5
     mv -f conftest.er1 conftest.err
   fi
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; } && {
 	 test -z "$ac_cxx_werror_flag" ||
 	 test ! -s conftest.err
-       } && test -s conftest.$ac_objext; then :
+       } && test -s conftest.$ac_objext
+then :
   ac_retval=0
-else
-  $as_echo "$as_me: failed program was:" >&5
+else $as_nop
+  printf "%s\n" "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
 	ac_retval=1
@@ -2038,7 +2073,7 @@ case "(($ac_try" in
   *) ac_try_echo=$ac_try;;
 esac
 eval ac_try_echo="\"\$as_me:${as_lineno-$LINENO}: $ac_try_echo\""
-$as_echo "$ac_try_echo"; } >&5
+printf "%s\n" "$ac_try_echo"; } >&5
   (eval "$ac_cpp conftest.$ac_ext") 2>conftest.err
   ac_status=$?
   if test -s conftest.err; then
@@ -2046,14 +2081,15 @@ $as_echo "$ac_try_echo"; } >&5
     cat conftest.er1 >&5
     mv -f conftest.er1 conftest.err
   fi
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; } > conftest.i && {
 	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
 	 test ! -s conftest.err
-       }; then :
+       }
+then :
   ac_retval=0
-else
-  $as_echo "$as_me: failed program was:" >&5
+else $as_nop
+  printf "%s\n" "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
     ac_retval=1
@@ -2069,14 +2105,14 @@ fi
 ac_fn_c_try_link ()
 {
   as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
-  rm -f conftest.$ac_objext conftest$ac_exeext
+  rm -f conftest.$ac_objext conftest.beam conftest$ac_exeext
   if { { ac_try="$ac_link"
 case "(($ac_try" in
   *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
   *) ac_try_echo=$ac_try;;
 esac
 eval ac_try_echo="\"\$as_me:${as_lineno-$LINENO}: $ac_try_echo\""
-$as_echo "$ac_try_echo"; } >&5
+printf "%s\n" "$ac_try_echo"; } >&5
   (eval "$ac_link") 2>conftest.err
   ac_status=$?
   if test -s conftest.err; then
@@ -2084,17 +2120,18 @@ $as_echo "$ac_try_echo"; } >&5
     cat conftest.er1 >&5
     mv -f conftest.er1 conftest.err
   fi
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; } && {
 	 test -z "$ac_c_werror_flag" ||
 	 test ! -s conftest.err
        } && test -s conftest$ac_exeext && {
 	 test "$cross_compiling" = yes ||
 	 test -x conftest$ac_exeext
-       }; then :
+       }
+then :
   ac_retval=0
-else
-  $as_echo "$as_me: failed program was:" >&5
+else $as_nop
+  printf "%s\n" "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
 	ac_retval=1
@@ -2109,135 +2146,6 @@ fi
 
 } # ac_fn_c_try_link
 
-# ac_fn_c_check_header_mongrel LINENO HEADER VAR INCLUDES
-# -------------------------------------------------------
-# Tests whether HEADER exists, giving a warning if it cannot be compiled using
-# the include files in INCLUDES and setting the cache variable VAR
-# accordingly.
-ac_fn_c_check_header_mongrel ()
-{
-  as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
-  if eval \${$3+:} false; then :
-  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $2" >&5
-$as_echo_n "checking for $2... " >&6; }
-if eval \${$3+:} false; then :
-  $as_echo_n "(cached) " >&6
-fi
-eval ac_res=\$$3
-	       { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
-$as_echo "$ac_res" >&6; }
-else
-  # Is the header compilable?
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking $2 usability" >&5
-$as_echo_n "checking $2 usability... " >&6; }
-cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-$4
-#include <$2>
-_ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
-  ac_header_compiler=yes
-else
-  ac_header_compiler=no
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_header_compiler" >&5
-$as_echo "$ac_header_compiler" >&6; }
-
-# Is the header present?
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking $2 presence" >&5
-$as_echo_n "checking $2 presence... " >&6; }
-cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <$2>
-_ACEOF
-if ac_fn_c_try_cpp "$LINENO"; then :
-  ac_header_preproc=yes
-else
-  ac_header_preproc=no
-fi
-rm -f conftest.err conftest.i conftest.$ac_ext
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_header_preproc" >&5
-$as_echo "$ac_header_preproc" >&6; }
-
-# So?  What about this header?
-case $ac_header_compiler:$ac_header_preproc:$ac_c_preproc_warn_flag in #((
-  yes:no: )
-    { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: $2: accepted by the compiler, rejected by the preprocessor!" >&5
-$as_echo "$as_me: WARNING: $2: accepted by the compiler, rejected by the preprocessor!" >&2;}
-    { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: $2: proceeding with the compiler's result" >&5
-$as_echo "$as_me: WARNING: $2: proceeding with the compiler's result" >&2;}
-    ;;
-  no:yes:* )
-    { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: $2: present but cannot be compiled" >&5
-$as_echo "$as_me: WARNING: $2: present but cannot be compiled" >&2;}
-    { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: $2:     check for missing prerequisite headers?" >&5
-$as_echo "$as_me: WARNING: $2:     check for missing prerequisite headers?" >&2;}
-    { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: $2: see the Autoconf documentation" >&5
-$as_echo "$as_me: WARNING: $2: see the Autoconf documentation" >&2;}
-    { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: $2:     section \"Present But Cannot Be Compiled\"" >&5
-$as_echo "$as_me: WARNING: $2:     section \"Present But Cannot Be Compiled\"" >&2;}
-    { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: $2: proceeding with the compiler's result" >&5
-$as_echo "$as_me: WARNING: $2: proceeding with the compiler's result" >&2;}
-    ;;
-esac
-  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $2" >&5
-$as_echo_n "checking for $2... " >&6; }
-if eval \${$3+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  eval "$3=\$ac_header_compiler"
-fi
-eval ac_res=\$$3
-	       { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
-$as_echo "$ac_res" >&6; }
-fi
-  eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
-
-} # ac_fn_c_check_header_mongrel
-
-# ac_fn_c_try_run LINENO
-# ----------------------
-# Try to link conftest.$ac_ext, and return whether this succeeded. Assumes
-# that executables *can* be run.
-ac_fn_c_try_run ()
-{
-  as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
-  if { { ac_try="$ac_link"
-case "(($ac_try" in
-  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
-  *) ac_try_echo=$ac_try;;
-esac
-eval ac_try_echo="\"\$as_me:${as_lineno-$LINENO}: $ac_try_echo\""
-$as_echo "$ac_try_echo"; } >&5
-  (eval "$ac_link") 2>&5
-  ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; } && { ac_try='./conftest$ac_exeext'
-  { { case "(($ac_try" in
-  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
-  *) ac_try_echo=$ac_try;;
-esac
-eval ac_try_echo="\"\$as_me:${as_lineno-$LINENO}: $ac_try_echo\""
-$as_echo "$ac_try_echo"; } >&5
-  (eval "$ac_try") 2>&5
-  ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; }; then :
-  ac_retval=0
-else
-  $as_echo "$as_me: program exited with status $ac_status" >&5
-       $as_echo "$as_me: failed program was:" >&5
-sed 's/^/| /' conftest.$ac_ext >&5
-
-       ac_retval=$ac_status
-fi
-  rm -rf conftest.dSYM conftest_ipa8_conftest.oo
-  eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
-  as_fn_set_status $ac_retval
-
-} # ac_fn_c_try_run
-
 # ac_fn_c_check_header_compile LINENO HEADER VAR INCLUDES
 # -------------------------------------------------------
 # Tests whether HEADER exists and can be compiled using the include files in
@@ -2245,26 +2153,28 @@ fi
 ac_fn_c_check_header_compile ()
 {
   as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
-  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $2" >&5
-$as_echo_n "checking for $2... " >&6; }
-if eval \${$3+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $2" >&5
+printf %s "checking for $2... " >&6; }
+if eval test \${$3+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 $4
 #include <$2>
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   eval "$3=yes"
-else
+else $as_nop
   eval "$3=no"
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
 eval ac_res=\$$3
-	       { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
-$as_echo "$ac_res" >&6; }
+	       { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
+printf "%s\n" "$ac_res" >&6; }
   eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
 
 } # ac_fn_c_check_header_compile
@@ -2276,17 +2186,18 @@ $as_echo "$ac_res" >&6; }
 ac_fn_c_check_type ()
 {
   as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
-  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $2" >&5
-$as_echo_n "checking for $2... " >&6; }
-if eval \${$3+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $2" >&5
+printf %s "checking for $2... " >&6; }
+if eval test \${$3+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   eval "$3=no"
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 $4
 int
-main ()
+main (void)
 {
 if (sizeof ($2))
 	 return 0;
@@ -2294,12 +2205,13 @@ if (sizeof ($2))
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 $4
 int
-main ()
+main (void)
 {
 if (sizeof (($2)))
 	    return 0;
@@ -2307,18 +2219,19 @@ if (sizeof (($2)))
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
 
-else
+else $as_nop
   eval "$3=yes"
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
 eval ac_res=\$$3
-	       { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
-$as_echo "$ac_res" >&6; }
+	       { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
+printf "%s\n" "$ac_res" >&6; }
   eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
 
 } # ac_fn_c_check_type
@@ -2330,16 +2243,17 @@ $as_echo "$ac_res" >&6; }
 ac_fn_c_check_member ()
 {
   as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
-  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $2.$3" >&5
-$as_echo_n "checking for $2.$3... " >&6; }
-if eval \${$4+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $2.$3" >&5
+printf %s "checking for $2.$3... " >&6; }
+if eval test \${$4+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 $5
 int
-main ()
+main (void)
 {
 static $2 ac_aggr;
 if (ac_aggr.$3)
@@ -2348,14 +2262,15 @@ return 0;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   eval "$4=yes"
-else
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 $5
 int
-main ()
+main (void)
 {
 static $2 ac_aggr;
 if (sizeof ac_aggr.$3)
@@ -2364,18 +2279,19 @@ return 0;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   eval "$4=yes"
-else
+else $as_nop
   eval "$4=no"
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
 eval ac_res=\$$4
-	       { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
-$as_echo "$ac_res" >&6; }
+	       { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
+printf "%s\n" "$ac_res" >&6; }
   eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
 
 } # ac_fn_c_check_member
@@ -2387,11 +2303,12 @@ $as_echo "$ac_res" >&6; }
 ac_fn_c_find_intX_t ()
 {
   as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
-  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for int$2_t" >&5
-$as_echo_n "checking for int$2_t... " >&6; }
-if eval \${$3+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for int$2_t" >&5
+printf %s "checking for int$2_t... " >&6; }
+if eval test \${$3+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   eval "$3=no"
      # Order is important - never check a type that is potentially smaller
      # than half of the expected target width.
@@ -2402,7 +2319,7 @@ else
 $ac_includes_default
 	     enum { N = $2 / 2 - 1 };
 int
-main ()
+main (void)
 {
 static int test_array [1 - 2 * !(0 < ($ac_type) ((((($ac_type) 1 << N) << N) - 1) * 2 + 1))];
 test_array [0] = 0;
@@ -2412,13 +2329,14 @@ return test_array [0];
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 $ac_includes_default
 	        enum { N = $2 / 2 - 1 };
 int
-main ()
+main (void)
 {
 static int test_array [1 - 2 * !(($ac_type) ((((($ac_type) 1 << N) << N) - 1) * 2 + 1)
 		 < ($ac_type) ((((($ac_type) 1 << N) << N) - 1) * 2 + 2))];
@@ -2429,9 +2347,10 @@ return test_array [0];
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
 
-else
+else $as_nop
   case $ac_type in #(
   int$2_t) :
     eval "$3=yes" ;; #(
@@ -2439,19 +2358,20 @@ else
     eval "$3=\$ac_type" ;;
 esac
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
-       if eval test \"x\$"$3"\" = x"no"; then :
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+       if eval test \"x\$"$3"\" = x"no"
+then :
 
-else
+else $as_nop
   break
 fi
      done
 fi
 eval ac_res=\$$3
-	       { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
-$as_echo "$ac_res" >&6; }
+	       { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
+printf "%s\n" "$ac_res" >&6; }
   eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
 
 } # ac_fn_c_find_intX_t
@@ -2463,11 +2383,12 @@ $as_echo "$ac_res" >&6; }
 ac_fn_c_find_uintX_t ()
 {
   as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
-  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for uint$2_t" >&5
-$as_echo_n "checking for uint$2_t... " >&6; }
-if eval \${$3+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for uint$2_t" >&5
+printf %s "checking for uint$2_t... " >&6; }
+if eval test \${$3+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   eval "$3=no"
      # Order is important - never check a type that is potentially smaller
      # than half of the expected target width.
@@ -2477,7 +2398,7 @@ else
 /* end confdefs.h.  */
 $ac_includes_default
 int
-main ()
+main (void)
 {
 static int test_array [1 - 2 * !((($ac_type) -1 >> ($2 / 2 - 1)) >> ($2 / 2 - 1) == 3)];
 test_array [0] = 0;
@@ -2487,7 +2408,8 @@ return test_array [0];
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   case $ac_type in #(
   uint$2_t) :
     eval "$3=yes" ;; #(
@@ -2495,17 +2417,18 @@ if ac_fn_c_try_compile "$LINENO"; then :
     eval "$3=\$ac_type" ;;
 esac
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
-       if eval test \"x\$"$3"\" = x"no"; then :
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+       if eval test \"x\$"$3"\" = x"no"
+then :
 
-else
+else $as_nop
   break
 fi
      done
 fi
 eval ac_res=\$$3
-	       { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
-$as_echo "$ac_res" >&6; }
+	       { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
+printf "%s\n" "$ac_res" >&6; }
   eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
 
 } # ac_fn_c_find_uintX_t
@@ -2516,11 +2439,12 @@ $as_echo "$ac_res" >&6; }
 ac_fn_c_check_func ()
 {
   as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
-  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $2" >&5
-$as_echo_n "checking for $2... " >&6; }
-if eval \${$3+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $2" >&5
+printf %s "checking for $2... " >&6; }
+if eval test \${$3+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 /* Define $2 to an innocuous variant, in case <limits.h> declares $2.
@@ -2528,16 +2452,9 @@ else
 #define $2 innocuous_$2
 
 /* System header to define __stub macros and hopefully few prototypes,
-    which can conflict with char $2 (); below.
-    Prefer <limits.h> to <assert.h> if __STDC__ is defined, since
-    <limits.h> exists even on freestanding compilers.  */
-
-#ifdef __STDC__
-# include <limits.h>
-#else
-# include <assert.h>
-#endif
+   which can conflict with char $2 (); below.  */
 
+#include <limits.h>
 #undef $2
 
 /* Override any GCC internal prototype to avoid an error.
@@ -2555,47 +2472,94 @@ choke me
 #endif
 
 int
-main ()
+main (void)
 {
 return $2 ();
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
+if ac_fn_c_try_link "$LINENO"
+then :
   eval "$3=yes"
-else
+else $as_nop
   eval "$3=no"
 fi
-rm -f core conftest.err conftest.$ac_objext \
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
     conftest$ac_exeext conftest.$ac_ext
 fi
 eval ac_res=\$$3
-	       { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
-$as_echo "$ac_res" >&6; }
+	       { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
+printf "%s\n" "$ac_res" >&6; }
   eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
 
 } # ac_fn_c_check_func
 
-# ac_fn_c_check_decl LINENO SYMBOL VAR INCLUDES
-# ---------------------------------------------
+# ac_fn_c_try_run LINENO
+# ----------------------
+# Try to run conftest.$ac_ext, and return whether this succeeded. Assumes that
+# executables *can* be run.
+ac_fn_c_try_run ()
+{
+  as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
+  if { { ac_try="$ac_link"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:${as_lineno-$LINENO}: $ac_try_echo\""
+printf "%s\n" "$ac_try_echo"; } >&5
+  (eval "$ac_link") 2>&5
+  ac_status=$?
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; } && { ac_try='./conftest$ac_exeext'
+  { { case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:${as_lineno-$LINENO}: $ac_try_echo\""
+printf "%s\n" "$ac_try_echo"; } >&5
+  (eval "$ac_try") 2>&5
+  ac_status=$?
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; }
+then :
+  ac_retval=0
+else $as_nop
+  printf "%s\n" "$as_me: program exited with status $ac_status" >&5
+       printf "%s\n" "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+       ac_retval=$ac_status
+fi
+  rm -rf conftest.dSYM conftest_ipa8_conftest.oo
+  eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
+  as_fn_set_status $ac_retval
+
+} # ac_fn_c_try_run
+
+# ac_fn_check_decl LINENO SYMBOL VAR INCLUDES EXTRA-OPTIONS FLAG-VAR
+# ------------------------------------------------------------------
 # Tests whether SYMBOL is declared in INCLUDES, setting cache variable VAR
-# accordingly.
-ac_fn_c_check_decl ()
+# accordingly. Pass EXTRA-OPTIONS to the compiler, using FLAG-VAR.
+ac_fn_check_decl ()
 {
   as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
   as_decl_name=`echo $2|sed 's/ *(.*//'`
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether $as_decl_name is declared" >&5
+printf %s "checking whether $as_decl_name is declared... " >&6; }
+if eval test \${$3+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   as_decl_use=`echo $2|sed -e 's/(/((/' -e 's/)/) 0&/' -e 's/,/) 0& (/g'`
-  { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $as_decl_name is declared" >&5
-$as_echo_n "checking whether $as_decl_name is declared... " >&6; }
-if eval \${$3+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+  eval ac_save_FLAGS=\$$6
+  as_fn_append $6 " $5"
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 $4
 int
-main ()
+main (void)
 {
 #ifndef $as_decl_name
 #ifdef __cplusplus
@@ -2609,27 +2573,50 @@ main ()
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   eval "$3=yes"
-else
+else $as_nop
   eval "$3=no"
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+  eval $6=\$ac_save_FLAGS
+
 fi
 eval ac_res=\$$3
-	       { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
-$as_echo "$ac_res" >&6; }
+	       { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
+printf "%s\n" "$ac_res" >&6; }
   eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
 
-} # ac_fn_c_check_decl
+} # ac_fn_check_decl
+ac_configure_args_raw=
+for ac_arg
+do
+  case $ac_arg in
+  *\'*)
+    ac_arg=`printf "%s\n" "$ac_arg" | sed "s/'/'\\\\\\\\''/g"` ;;
+  esac
+  as_fn_append ac_configure_args_raw " '$ac_arg'"
+done
+
+case $ac_configure_args_raw in
+  *$as_nl*)
+    ac_safe_unquote= ;;
+  *)
+    ac_unsafe_z='|&;<>()$`\\"*?[ ''	' # This string ends in space, tab.
+    ac_unsafe_a="$ac_unsafe_z#~"
+    ac_safe_unquote="s/ '\\([^$ac_unsafe_a][^$ac_unsafe_z]*\\)'/ \\1/g"
+    ac_configure_args_raw=`      printf "%s\n" "$ac_configure_args_raw" | sed "$ac_safe_unquote"`;;
+esac
+
 cat >config.log <<_ACEOF
 This file contains any messages produced by compilers while
 running configure, to aid debugging if configure makes a mistake.
 
 It was created by $as_me, which was
-generated by GNU Autoconf 2.69.  Invocation command line was
+generated by GNU Autoconf 2.71.  Invocation command line was
 
-  $ $0 $@
+  $ $0$ac_configure_args_raw
 
 _ACEOF
 exec 5>>config.log
@@ -2662,8 +2649,12 @@ as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
-    $as_echo "PATH: $as_dir"
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
+    printf "%s\n" "PATH: $as_dir"
   done
 IFS=$as_save_IFS
 
@@ -2698,7 +2689,7 @@ do
     | -silent | --silent | --silen | --sile | --sil)
       continue ;;
     *\'*)
-      ac_arg=`$as_echo "$ac_arg" | sed "s/'/'\\\\\\\\''/g"` ;;
+      ac_arg=`printf "%s\n" "$ac_arg" | sed "s/'/'\\\\\\\\''/g"` ;;
     esac
     case $ac_pass in
     1) as_fn_append ac_configure_args0 " '$ac_arg'" ;;
@@ -2733,11 +2724,13 @@ done
 # WARNING: Use '\'' to represent an apostrophe within the trap.
 # WARNING: Do not start the trap code with a newline, due to a FreeBSD 4.0 bug.
 trap 'exit_status=$?
+  # Sanitize IFS.
+  IFS=" ""	$as_nl"
   # Save into config.log some information that might help in debugging.
   {
     echo
 
-    $as_echo "## ---------------- ##
+    printf "%s\n" "## ---------------- ##
 ## Cache variables. ##
 ## ---------------- ##"
     echo
@@ -2748,8 +2741,8 @@ trap 'exit_status=$?
     case $ac_val in #(
     *${as_nl}*)
       case $ac_var in #(
-      *_cv_*) { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: cache variable $ac_var contains a newline" >&5
-$as_echo "$as_me: WARNING: cache variable $ac_var contains a newline" >&2;} ;;
+      *_cv_*) { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: cache variable $ac_var contains a newline" >&5
+printf "%s\n" "$as_me: WARNING: cache variable $ac_var contains a newline" >&2;} ;;
       esac
       case $ac_var in #(
       _ | IFS | as_nl) ;; #(
@@ -2773,7 +2766,7 @@ $as_echo "$as_me: WARNING: cache variable $ac_var contains a newline" >&2;} ;;
 )
     echo
 
-    $as_echo "## ----------------- ##
+    printf "%s\n" "## ----------------- ##
 ## Output variables. ##
 ## ----------------- ##"
     echo
@@ -2781,14 +2774,14 @@ $as_echo "$as_me: WARNING: cache variable $ac_var contains a newline" >&2;} ;;
     do
       eval ac_val=\$$ac_var
       case $ac_val in
-      *\'\''*) ac_val=`$as_echo "$ac_val" | sed "s/'\''/'\''\\\\\\\\'\'''\''/g"`;;
+      *\'\''*) ac_val=`printf "%s\n" "$ac_val" | sed "s/'\''/'\''\\\\\\\\'\'''\''/g"`;;
       esac
-      $as_echo "$ac_var='\''$ac_val'\''"
+      printf "%s\n" "$ac_var='\''$ac_val'\''"
     done | sort
     echo
 
     if test -n "$ac_subst_files"; then
-      $as_echo "## ------------------- ##
+      printf "%s\n" "## ------------------- ##
 ## File substitutions. ##
 ## ------------------- ##"
       echo
@@ -2796,15 +2789,15 @@ $as_echo "$as_me: WARNING: cache variable $ac_var contains a newline" >&2;} ;;
       do
 	eval ac_val=\$$ac_var
 	case $ac_val in
-	*\'\''*) ac_val=`$as_echo "$ac_val" | sed "s/'\''/'\''\\\\\\\\'\'''\''/g"`;;
+	*\'\''*) ac_val=`printf "%s\n" "$ac_val" | sed "s/'\''/'\''\\\\\\\\'\'''\''/g"`;;
 	esac
-	$as_echo "$ac_var='\''$ac_val'\''"
+	printf "%s\n" "$ac_var='\''$ac_val'\''"
       done | sort
       echo
     fi
 
     if test -s confdefs.h; then
-      $as_echo "## ----------- ##
+      printf "%s\n" "## ----------- ##
 ## confdefs.h. ##
 ## ----------- ##"
       echo
@@ -2812,8 +2805,8 @@ $as_echo "$as_me: WARNING: cache variable $ac_var contains a newline" >&2;} ;;
       echo
     fi
     test "$ac_signal" != 0 &&
-      $as_echo "$as_me: caught signal $ac_signal"
-    $as_echo "$as_me: exit $exit_status"
+      printf "%s\n" "$as_me: caught signal $ac_signal"
+    printf "%s\n" "$as_me: exit $exit_status"
   } >&5
   rm -f core *.core core.conftest.* &&
     rm -f -r conftest* confdefs* conf$$* $ac_clean_files &&
@@ -2827,63 +2820,48 @@ ac_signal=0
 # confdefs.h avoids OS command line length limits that DEFS can exceed.
 rm -f -r conftest* confdefs.h
 
-$as_echo "/* confdefs.h */" > confdefs.h
+printf "%s\n" "/* confdefs.h */" > confdefs.h
 
 # Predefined preprocessor variables.
 
-cat >>confdefs.h <<_ACEOF
-#define PACKAGE_NAME "$PACKAGE_NAME"
-_ACEOF
+printf "%s\n" "#define PACKAGE_NAME \"$PACKAGE_NAME\"" >>confdefs.h
 
-cat >>confdefs.h <<_ACEOF
-#define PACKAGE_TARNAME "$PACKAGE_TARNAME"
-_ACEOF
+printf "%s\n" "#define PACKAGE_TARNAME \"$PACKAGE_TARNAME\"" >>confdefs.h
 
-cat >>confdefs.h <<_ACEOF
-#define PACKAGE_VERSION "$PACKAGE_VERSION"
-_ACEOF
+printf "%s\n" "#define PACKAGE_VERSION \"$PACKAGE_VERSION\"" >>confdefs.h
 
-cat >>confdefs.h <<_ACEOF
-#define PACKAGE_STRING "$PACKAGE_STRING"
-_ACEOF
+printf "%s\n" "#define PACKAGE_STRING \"$PACKAGE_STRING\"" >>confdefs.h
 
-cat >>confdefs.h <<_ACEOF
-#define PACKAGE_BUGREPORT "$PACKAGE_BUGREPORT"
-_ACEOF
+printf "%s\n" "#define PACKAGE_BUGREPORT \"$PACKAGE_BUGREPORT\"" >>confdefs.h
 
-cat >>confdefs.h <<_ACEOF
-#define PACKAGE_URL "$PACKAGE_URL"
-_ACEOF
+printf "%s\n" "#define PACKAGE_URL \"$PACKAGE_URL\"" >>confdefs.h
 
 
 # Let the site file select an alternate cache file if it wants to.
 # Prefer an explicitly selected file to automatically selected ones.
-ac_site_file1=NONE
-ac_site_file2=NONE
 if test -n "$CONFIG_SITE"; then
-  # We do not want a PATH search for config.site.
-  case $CONFIG_SITE in #((
-    -*)  ac_site_file1=./$CONFIG_SITE;;
-    */*) ac_site_file1=$CONFIG_SITE;;
-    *)   ac_site_file1=./$CONFIG_SITE;;
-  esac
+  ac_site_files="$CONFIG_SITE"
 elif test "x$prefix" != xNONE; then
-  ac_site_file1=$prefix/share/config.site
-  ac_site_file2=$prefix/etc/config.site
+  ac_site_files="$prefix/share/config.site $prefix/etc/config.site"
 else
-  ac_site_file1=$ac_default_prefix/share/config.site
-  ac_site_file2=$ac_default_prefix/etc/config.site
+  ac_site_files="$ac_default_prefix/share/config.site $ac_default_prefix/etc/config.site"
 fi
-for ac_site_file in "$ac_site_file1" "$ac_site_file2"
+
+for ac_site_file in $ac_site_files
 do
-  test "x$ac_site_file" = xNONE && continue
-  if test /dev/null != "$ac_site_file" && test -r "$ac_site_file"; then
-    { $as_echo "$as_me:${as_lineno-$LINENO}: loading site script $ac_site_file" >&5
-$as_echo "$as_me: loading site script $ac_site_file" >&6;}
+  case $ac_site_file in #(
+  */*) :
+     ;; #(
+  *) :
+    ac_site_file=./$ac_site_file ;;
+esac
+  if test -f "$ac_site_file" && test -r "$ac_site_file"; then
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: loading site script $ac_site_file" >&5
+printf "%s\n" "$as_me: loading site script $ac_site_file" >&6;}
     sed 's/^/| /' "$ac_site_file" >&5
     . "$ac_site_file" \
-      || { { $as_echo "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
-$as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
+      || { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
 as_fn_error $? "failed to load site script $ac_site_file
 See \`config.log' for more details" "$LINENO" 5; }
   fi
@@ -2893,80 +2871,715 @@ if test -r "$cache_file"; then
   # Some versions of bash will fail to source /dev/null (special files
   # actually), so we avoid doing that.  DJGPP emulates it as a regular file.
   if test /dev/null != "$cache_file" && test -f "$cache_file"; then
-    { $as_echo "$as_me:${as_lineno-$LINENO}: loading cache $cache_file" >&5
-$as_echo "$as_me: loading cache $cache_file" >&6;}
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: loading cache $cache_file" >&5
+printf "%s\n" "$as_me: loading cache $cache_file" >&6;}
     case $cache_file in
       [\\/]* | ?:[\\/]* ) . "$cache_file";;
       *)                      . "./$cache_file";;
     esac
   fi
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: creating cache $cache_file" >&5
-$as_echo "$as_me: creating cache $cache_file" >&6;}
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: creating cache $cache_file" >&5
+printf "%s\n" "$as_me: creating cache $cache_file" >&6;}
   >$cache_file
 fi
 
-as_fn_append ac_header_list " sys/time.h"
-as_fn_append ac_header_list " unistd.h"
-as_fn_append ac_func_list " alarm"
-as_fn_append ac_header_list " stdlib.h"
-as_fn_append ac_header_list " sys/param.h"
-# Check that the precious variables saved in the cache have kept the same
-# value.
-ac_cache_corrupted=false
-for ac_var in $ac_precious_vars; do
-  eval ac_old_set=\$ac_cv_env_${ac_var}_set
-  eval ac_new_set=\$ac_env_${ac_var}_set
-  eval ac_old_val=\$ac_cv_env_${ac_var}_value
-  eval ac_new_val=\$ac_env_${ac_var}_value
-  case $ac_old_set,$ac_new_set in
-    set,)
-      { $as_echo "$as_me:${as_lineno-$LINENO}: error: \`$ac_var' was set to \`$ac_old_val' in the previous run" >&5
-$as_echo "$as_me: error: \`$ac_var' was set to \`$ac_old_val' in the previous run" >&2;}
-      ac_cache_corrupted=: ;;
-    ,set)
-      { $as_echo "$as_me:${as_lineno-$LINENO}: error: \`$ac_var' was not set in the previous run" >&5
-$as_echo "$as_me: error: \`$ac_var' was not set in the previous run" >&2;}
-      ac_cache_corrupted=: ;;
-    ,);;
-    *)
-      if test "x$ac_old_val" != "x$ac_new_val"; then
-	# differences in whitespace do not lead to failure.
-	ac_old_val_w=`echo x $ac_old_val`
-	ac_new_val_w=`echo x $ac_new_val`
-	if test "$ac_old_val_w" != "$ac_new_val_w"; then
-	  { $as_echo "$as_me:${as_lineno-$LINENO}: error: \`$ac_var' has changed since the previous run:" >&5
-$as_echo "$as_me: error: \`$ac_var' has changed since the previous run:" >&2;}
-	  ac_cache_corrupted=:
-	else
-	  { $as_echo "$as_me:${as_lineno-$LINENO}: warning: ignoring whitespace changes in \`$ac_var' since the previous run:" >&5
-$as_echo "$as_me: warning: ignoring whitespace changes in \`$ac_var' since the previous run:" >&2;}
-	  eval $ac_var=\$ac_old_val
-	fi
-	{ $as_echo "$as_me:${as_lineno-$LINENO}:   former value:  \`$ac_old_val'" >&5
-$as_echo "$as_me:   former value:  \`$ac_old_val'" >&2;}
-	{ $as_echo "$as_me:${as_lineno-$LINENO}:   current value: \`$ac_new_val'" >&5
-$as_echo "$as_me:   current value: \`$ac_new_val'" >&2;}
-      fi;;
-  esac
-  # Pass precious variables to config.status.
-  if test "$ac_new_set" = set; then
-    case $ac_new_val in
-    *\'*) ac_arg=$ac_var=`$as_echo "$ac_new_val" | sed "s/'/'\\\\\\\\''/g"` ;;
-    *) ac_arg=$ac_var=$ac_new_val ;;
-    esac
-    case " $ac_configure_args " in
-      *" '$ac_arg' "*) ;; # Avoid dups.  Use of quotes ensures accuracy.
-      *) as_fn_append ac_configure_args " '$ac_arg'" ;;
-    esac
-  fi
+# Test code for whether the C compiler supports C89 (global declarations)
+ac_c_conftest_c89_globals='
+/* Does the compiler advertise C89 conformance?
+   Do not test the value of __STDC__, because some compilers set it to 0
+   while being otherwise adequately conformant. */
+#if !defined __STDC__
+# error "Compiler does not advertise C89 conformance"
+#endif
+
+#include <stddef.h>
+#include <stdarg.h>
+struct stat;
+/* Most of the following tests are stolen from RCS 5.7 src/conf.sh.  */
+struct buf { int x; };
+struct buf * (*rcsopen) (struct buf *, struct stat *, int);
+static char *e (p, i)
+     char **p;
+     int i;
+{
+  return p[i];
+}
+static char *f (char * (*g) (char **, int), char **p, ...)
+{
+  char *s;
+  va_list v;
+  va_start (v,p);
+  s = g (p, va_arg (v,int));
+  va_end (v);
+  return s;
+}
+
+/* OSF 4.0 Compaq cc is some sort of almost-ANSI by default.  It has
+   function prototypes and stuff, but not \xHH hex character constants.
+   These do not provoke an error unfortunately, instead are silently treated
+   as an "x".  The following induces an error, until -std is added to get
+   proper ANSI mode.  Curiously \x00 != x always comes out true, for an
+   array size at least.  It is necessary to write \x00 == 0 to get something
+   that is true only with -std.  */
+int osf4_cc_array ['\''\x00'\'' == 0 ? 1 : -1];
+
+/* IBM C 6 for AIX is almost-ANSI by default, but it replaces macro parameters
+   inside strings and character constants.  */
+#define FOO(x) '\''x'\''
+int xlc6_cc_array[FOO(a) == '\''x'\'' ? 1 : -1];
+
+int test (int i, double x);
+struct s1 {int (*f) (int a);};
+struct s2 {int (*f) (double a);};
+int pairnames (int, char **, int *(*)(struct buf *, struct stat *, int),
+               int, int);'
+
+# Test code for whether the C compiler supports C89 (body of main).
+ac_c_conftest_c89_main='
+ok |= (argc == 0 || f (e, argv, 0) != argv[0] || f (e, argv, 1) != argv[1]);
+'
+
+# Test code for whether the C compiler supports C99 (global declarations)
+ac_c_conftest_c99_globals='
+// Does the compiler advertise C99 conformance?
+#if !defined __STDC_VERSION__ || __STDC_VERSION__ < 199901L
+# error "Compiler does not advertise C99 conformance"
+#endif
+
+#include <stdbool.h>
+extern int puts (const char *);
+extern int printf (const char *, ...);
+extern int dprintf (int, const char *, ...);
+extern void *malloc (size_t);
+
+// Check varargs macros.  These examples are taken from C99 6.10.3.5.
+// dprintf is used instead of fprintf to avoid needing to declare
+// FILE and stderr.
+#define debug(...) dprintf (2, __VA_ARGS__)
+#define showlist(...) puts (#__VA_ARGS__)
+#define report(test,...) ((test) ? puts (#test) : printf (__VA_ARGS__))
+static void
+test_varargs_macros (void)
+{
+  int x = 1234;
+  int y = 5678;
+  debug ("Flag");
+  debug ("X = %d\n", x);
+  showlist (The first, second, and third items.);
+  report (x>y, "x is %d but y is %d", x, y);
+}
+
+// Check long long types.
+#define BIG64 18446744073709551615ull
+#define BIG32 4294967295ul
+#define BIG_OK (BIG64 / BIG32 == 4294967297ull && BIG64 % BIG32 == 0)
+#if !BIG_OK
+  #error "your preprocessor is broken"
+#endif
+#if BIG_OK
+#else
+  #error "your preprocessor is broken"
+#endif
+static long long int bignum = -9223372036854775807LL;
+static unsigned long long int ubignum = BIG64;
+
+struct incomplete_array
+{
+  int datasize;
+  double data[];
+};
+
+struct named_init {
+  int number;
+  const wchar_t *name;
+  double average;
+};
+
+typedef const char *ccp;
+
+static inline int
+test_restrict (ccp restrict text)
+{
+  // See if C++-style comments work.
+  // Iterate through items via the restricted pointer.
+  // Also check for declarations in for loops.
+  for (unsigned int i = 0; *(text+i) != '\''\0'\''; ++i)
+    continue;
+  return 0;
+}
+
+// Check varargs and va_copy.
+static bool
+test_varargs (const char *format, ...)
+{
+  va_list args;
+  va_start (args, format);
+  va_list args_copy;
+  va_copy (args_copy, args);
+
+  const char *str = "";
+  int number = 0;
+  float fnumber = 0;
+
+  while (*format)
+    {
+      switch (*format++)
+	{
+	case '\''s'\'': // string
+	  str = va_arg (args_copy, const char *);
+	  break;
+	case '\''d'\'': // int
+	  number = va_arg (args_copy, int);
+	  break;
+	case '\''f'\'': // float
+	  fnumber = va_arg (args_copy, double);
+	  break;
+	default:
+	  break;
+	}
+    }
+  va_end (args_copy);
+  va_end (args);
+
+  return *str && number && fnumber;
+}
+'
+
+# Test code for whether the C compiler supports C99 (body of main).
+ac_c_conftest_c99_main='
+  // Check bool.
+  _Bool success = false;
+  success |= (argc != 0);
+
+  // Check restrict.
+  if (test_restrict ("String literal") == 0)
+    success = true;
+  char *restrict newvar = "Another string";
+
+  // Check varargs.
+  success &= test_varargs ("s, d'\'' f .", "string", 65, 34.234);
+  test_varargs_macros ();
+
+  // Check flexible array members.
+  struct incomplete_array *ia =
+    malloc (sizeof (struct incomplete_array) + (sizeof (double) * 10));
+  ia->datasize = 10;
+  for (int i = 0; i < ia->datasize; ++i)
+    ia->data[i] = i * 1.234;
+
+  // Check named initializers.
+  struct named_init ni = {
+    .number = 34,
+    .name = L"Test wide string",
+    .average = 543.34343,
+  };
+
+  ni.number = 58;
+
+  int dynamic_array[ni.number];
+  dynamic_array[0] = argv[0][0];
+  dynamic_array[ni.number - 1] = 543;
+
+  // work around unused variable warnings
+  ok |= (!success || bignum == 0LL || ubignum == 0uLL || newvar[0] == '\''x'\''
+	 || dynamic_array[ni.number - 1] != 543);
+'
+
+# Test code for whether the C compiler supports C11 (global declarations)
+ac_c_conftest_c11_globals='
+// Does the compiler advertise C11 conformance?
+#if !defined __STDC_VERSION__ || __STDC_VERSION__ < 201112L
+# error "Compiler does not advertise C11 conformance"
+#endif
+
+// Check _Alignas.
+char _Alignas (double) aligned_as_double;
+char _Alignas (0) no_special_alignment;
+extern char aligned_as_int;
+char _Alignas (0) _Alignas (int) aligned_as_int;
+
+// Check _Alignof.
+enum
+{
+  int_alignment = _Alignof (int),
+  int_array_alignment = _Alignof (int[100]),
+  char_alignment = _Alignof (char)
+};
+_Static_assert (0 < -_Alignof (int), "_Alignof is signed");
+
+// Check _Noreturn.
+int _Noreturn does_not_return (void) { for (;;) continue; }
+
+// Check _Static_assert.
+struct test_static_assert
+{
+  int x;
+  _Static_assert (sizeof (int) <= sizeof (long int),
+                  "_Static_assert does not work in struct");
+  long int y;
+};
+
+// Check UTF-8 literals.
+#define u8 syntax error!
+char const utf8_literal[] = u8"happens to be ASCII" "another string";
+
+// Check duplicate typedefs.
+typedef long *long_ptr;
+typedef long int *long_ptr;
+typedef long_ptr long_ptr;
+
+// Anonymous structures and unions -- taken from C11 6.7.2.1 Example 1.
+struct anonymous
+{
+  union {
+    struct { int i; int j; };
+    struct { int k; long int l; } w;
+  };
+  int m;
+} v1;
+'
+
+# Test code for whether the C compiler supports C11 (body of main).
+ac_c_conftest_c11_main='
+  _Static_assert ((offsetof (struct anonymous, i)
+		   == offsetof (struct anonymous, w.k)),
+		  "Anonymous union alignment botch");
+  v1.i = 2;
+  v1.w.k = 5;
+  ok |= v1.i != 5;
+'
+
+# Test code for whether the C compiler supports C11 (complete).
+ac_c_conftest_c11_program="${ac_c_conftest_c89_globals}
+${ac_c_conftest_c99_globals}
+${ac_c_conftest_c11_globals}
+
+int
+main (int argc, char **argv)
+{
+  int ok = 0;
+  ${ac_c_conftest_c89_main}
+  ${ac_c_conftest_c99_main}
+  ${ac_c_conftest_c11_main}
+  return ok;
+}
+"
+
+# Test code for whether the C compiler supports C99 (complete).
+ac_c_conftest_c99_program="${ac_c_conftest_c89_globals}
+${ac_c_conftest_c99_globals}
+
+int
+main (int argc, char **argv)
+{
+  int ok = 0;
+  ${ac_c_conftest_c89_main}
+  ${ac_c_conftest_c99_main}
+  return ok;
+}
+"
+
+# Test code for whether the C compiler supports C89 (complete).
+ac_c_conftest_c89_program="${ac_c_conftest_c89_globals}
+
+int
+main (int argc, char **argv)
+{
+  int ok = 0;
+  ${ac_c_conftest_c89_main}
+  return ok;
+}
+"
+
+# Test code for whether the C++ compiler supports C++98 (global declarations)
+ac_cxx_conftest_cxx98_globals='
+// Does the compiler advertise C++98 conformance?
+#if !defined __cplusplus || __cplusplus < 199711L
+# error "Compiler does not advertise C++98 conformance"
+#endif
+
+// These inclusions are to reject old compilers that
+// lack the unsuffixed header files.
+#include <cstdlib>
+#include <exception>
+
+// <cassert> and <cstring> are *not* freestanding headers in C++98.
+extern void assert (int);
+namespace std {
+  extern int strcmp (const char *, const char *);
+}
+
+// Namespaces, exceptions, and templates were all added after "C++ 2.0".
+using std::exception;
+using std::strcmp;
+
+namespace {
+
+void test_exception_syntax()
+{
+  try {
+    throw "test";
+  } catch (const char *s) {
+    // Extra parentheses suppress a warning when building autoconf itself,
+    // due to lint rules shared with more typical C programs.
+    assert (!(strcmp) (s, "test"));
+  }
+}
+
+template <typename T> struct test_template
+{
+  T const val;
+  explicit test_template(T t) : val(t) {}
+  template <typename U> T add(U u) { return static_cast<T>(u) + val; }
+};
+
+} // anonymous namespace
+'
+
+# Test code for whether the C++ compiler supports C++98 (body of main)
+ac_cxx_conftest_cxx98_main='
+  assert (argc);
+  assert (! argv[0]);
+{
+  test_exception_syntax ();
+  test_template<double> tt (2.0);
+  assert (tt.add (4) == 6.0);
+  assert (true && !false);
+}
+'
+
+# Test code for whether the C++ compiler supports C++11 (global declarations)
+ac_cxx_conftest_cxx11_globals='
+// Does the compiler advertise C++ 2011 conformance?
+#if !defined __cplusplus || __cplusplus < 201103L
+# error "Compiler does not advertise C++11 conformance"
+#endif
+
+namespace cxx11test
+{
+  constexpr int get_val() { return 20; }
+
+  struct testinit
+  {
+    int i;
+    double d;
+  };
+
+  class delegate
+  {
+  public:
+    delegate(int n) : n(n) {}
+    delegate(): delegate(2354) {}
+
+    virtual int getval() { return this->n; };
+  protected:
+    int n;
+  };
+
+  class overridden : public delegate
+  {
+  public:
+    overridden(int n): delegate(n) {}
+    virtual int getval() override final { return this->n * 2; }
+  };
+
+  class nocopy
+  {
+  public:
+    nocopy(int i): i(i) {}
+    nocopy() = default;
+    nocopy(const nocopy&) = delete;
+    nocopy & operator=(const nocopy&) = delete;
+  private:
+    int i;
+  };
+
+  // for testing lambda expressions
+  template <typename Ret, typename Fn> Ret eval(Fn f, Ret v)
+  {
+    return f(v);
+  }
+
+  // for testing variadic templates and trailing return types
+  template <typename V> auto sum(V first) -> V
+  {
+    return first;
+  }
+  template <typename V, typename... Args> auto sum(V first, Args... rest) -> V
+  {
+    return first + sum(rest...);
+  }
+}
+'
+
+# Test code for whether the C++ compiler supports C++11 (body of main)
+ac_cxx_conftest_cxx11_main='
+{
+  // Test auto and decltype
+  auto a1 = 6538;
+  auto a2 = 48573953.4;
+  auto a3 = "String literal";
+
+  int total = 0;
+  for (auto i = a3; *i; ++i) { total += *i; }
+
+  decltype(a2) a4 = 34895.034;
+}
+{
+  // Test constexpr
+  short sa[cxx11test::get_val()] = { 0 };
+}
+{
+  // Test initializer lists
+  cxx11test::testinit il = { 4323, 435234.23544 };
+}
+{
+  // Test range-based for
+  int array[] = {9, 7, 13, 15, 4, 18, 12, 10, 5, 3,
+                 14, 19, 17, 8, 6, 20, 16, 2, 11, 1};
+  for (auto &x : array) { x += 23; }
+}
+{
+  // Test lambda expressions
+  using cxx11test::eval;
+  assert (eval ([](int x) { return x*2; }, 21) == 42);
+  double d = 2.0;
+  assert (eval ([&](double x) { return d += x; }, 3.0) == 5.0);
+  assert (d == 5.0);
+  assert (eval ([=](double x) mutable { return d += x; }, 4.0) == 9.0);
+  assert (d == 5.0);
+}
+{
+  // Test use of variadic templates
+  using cxx11test::sum;
+  auto a = sum(1);
+  auto b = sum(1, 2);
+  auto c = sum(1.0, 2.0, 3.0);
+}
+{
+  // Test constructor delegation
+  cxx11test::delegate d1;
+  cxx11test::delegate d2();
+  cxx11test::delegate d3(45);
+}
+{
+  // Test override and final
+  cxx11test::overridden o1(55464);
+}
+{
+  // Test nullptr
+  char *c = nullptr;
+}
+{
+  // Test template brackets
+  test_template<::test_template<int>> v(test_template<int>(12));
+}
+{
+  // Unicode literals
+  char const *utf8 = u8"UTF-8 string \u2500";
+  char16_t const *utf16 = u"UTF-8 string \u2500";
+  char32_t const *utf32 = U"UTF-32 string \u2500";
+}
+'
+
+# Test code for whether the C compiler supports C++11 (complete).
+ac_cxx_conftest_cxx11_program="${ac_cxx_conftest_cxx98_globals}
+${ac_cxx_conftest_cxx11_globals}
+
+int
+main (int argc, char **argv)
+{
+  int ok = 0;
+  ${ac_cxx_conftest_cxx98_main}
+  ${ac_cxx_conftest_cxx11_main}
+  return ok;
+}
+"
+
+# Test code for whether the C compiler supports C++98 (complete).
+ac_cxx_conftest_cxx98_program="${ac_cxx_conftest_cxx98_globals}
+int
+main (int argc, char **argv)
+{
+  int ok = 0;
+  ${ac_cxx_conftest_cxx98_main}
+  return ok;
+}
+"
+
+as_fn_append ac_header_c_list " stdio.h stdio_h HAVE_STDIO_H"
+as_fn_append ac_header_c_list " stdlib.h stdlib_h HAVE_STDLIB_H"
+as_fn_append ac_header_c_list " string.h string_h HAVE_STRING_H"
+as_fn_append ac_header_c_list " inttypes.h inttypes_h HAVE_INTTYPES_H"
+as_fn_append ac_header_c_list " stdint.h stdint_h HAVE_STDINT_H"
+as_fn_append ac_header_c_list " strings.h strings_h HAVE_STRINGS_H"
+as_fn_append ac_header_c_list " sys/stat.h sys_stat_h HAVE_SYS_STAT_H"
+as_fn_append ac_header_c_list " sys/types.h sys_types_h HAVE_SYS_TYPES_H"
+as_fn_append ac_header_c_list " unistd.h unistd_h HAVE_UNISTD_H"
+as_fn_append ac_header_c_list " sys/time.h sys_time_h HAVE_SYS_TIME_H"
+as_fn_append ac_header_c_list " vfork.h vfork_h HAVE_VFORK_H"
+as_fn_append ac_func_c_list " fork HAVE_FORK"
+as_fn_append ac_func_c_list " vfork HAVE_VFORK"
+as_fn_append ac_func_c_list " alarm HAVE_ALARM"
+as_fn_append ac_header_c_list " sys/param.h sys_param_h HAVE_SYS_PARAM_H"
+as_fn_append ac_func_c_list " getpagesize HAVE_GETPAGESIZE"
+as_fn_append ac_func_c_list " vprintf HAVE_VPRINTF"
+
+# Auxiliary files required by this configure script.
+ac_aux_files="install-sh config.guess config.sub"
+
+# Locations in which to look for auxiliary files.
+ac_aux_dir_candidates="${srcdir}/autoconf"
+
+# Search for a directory containing all of the required auxiliary files,
+# $ac_aux_files, from the $PATH-style list $ac_aux_dir_candidates.
+# If we don't find one directory that contains all the files we need,
+# we report the set of missing files from the *first* directory in
+# $ac_aux_dir_candidates and give up.
+ac_missing_aux_files=""
+ac_first_candidate=:
+printf "%s\n" "$as_me:${as_lineno-$LINENO}: looking for aux files: $ac_aux_files" >&5
+as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+as_found=false
+for as_dir in $ac_aux_dir_candidates
+do
+  IFS=$as_save_IFS
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
+  as_found=:
+
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}:  trying $as_dir" >&5
+  ac_aux_dir_found=yes
+  ac_install_sh=
+  for ac_aux in $ac_aux_files
+  do
+    # As a special case, if "install-sh" is required, that requirement
+    # can be satisfied by any of "install-sh", "install.sh", or "shtool",
+    # and $ac_install_sh is set appropriately for whichever one is found.
+    if test x"$ac_aux" = x"install-sh"
+    then
+      if test -f "${as_dir}install-sh"; then
+        printf "%s\n" "$as_me:${as_lineno-$LINENO}:   ${as_dir}install-sh found" >&5
+        ac_install_sh="${as_dir}install-sh -c"
+      elif test -f "${as_dir}install.sh"; then
+        printf "%s\n" "$as_me:${as_lineno-$LINENO}:   ${as_dir}install.sh found" >&5
+        ac_install_sh="${as_dir}install.sh -c"
+      elif test -f "${as_dir}shtool"; then
+        printf "%s\n" "$as_me:${as_lineno-$LINENO}:   ${as_dir}shtool found" >&5
+        ac_install_sh="${as_dir}shtool install -c"
+      else
+        ac_aux_dir_found=no
+        if $ac_first_candidate; then
+          ac_missing_aux_files="${ac_missing_aux_files} install-sh"
+        else
+          break
+        fi
+      fi
+    else
+      if test -f "${as_dir}${ac_aux}"; then
+        printf "%s\n" "$as_me:${as_lineno-$LINENO}:   ${as_dir}${ac_aux} found" >&5
+      else
+        ac_aux_dir_found=no
+        if $ac_first_candidate; then
+          ac_missing_aux_files="${ac_missing_aux_files} ${ac_aux}"
+        else
+          break
+        fi
+      fi
+    fi
+  done
+  if test "$ac_aux_dir_found" = yes; then
+    ac_aux_dir="$as_dir"
+    break
+  fi
+  ac_first_candidate=false
+
+  as_found=false
+done
+IFS=$as_save_IFS
+if $as_found
+then :
+
+else $as_nop
+  as_fn_error $? "cannot find required auxiliary files:$ac_missing_aux_files" "$LINENO" 5
+fi
+
+
+# These three variables are undocumented and unsupported,
+# and are intended to be withdrawn in a future Autoconf release.
+# They can cause serious problems if a builder's source tree is in a directory
+# whose full name contains unusual characters.
+if test -f "${ac_aux_dir}config.guess"; then
+  ac_config_guess="$SHELL ${ac_aux_dir}config.guess"
+fi
+if test -f "${ac_aux_dir}config.sub"; then
+  ac_config_sub="$SHELL ${ac_aux_dir}config.sub"
+fi
+if test -f "$ac_aux_dir/configure"; then
+  ac_configure="$SHELL ${ac_aux_dir}configure"
+fi
+
+# Check that the precious variables saved in the cache have kept the same
+# value.
+ac_cache_corrupted=false
+for ac_var in $ac_precious_vars; do
+  eval ac_old_set=\$ac_cv_env_${ac_var}_set
+  eval ac_new_set=\$ac_env_${ac_var}_set
+  eval ac_old_val=\$ac_cv_env_${ac_var}_value
+  eval ac_new_val=\$ac_env_${ac_var}_value
+  case $ac_old_set,$ac_new_set in
+    set,)
+      { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: \`$ac_var' was set to \`$ac_old_val' in the previous run" >&5
+printf "%s\n" "$as_me: error: \`$ac_var' was set to \`$ac_old_val' in the previous run" >&2;}
+      ac_cache_corrupted=: ;;
+    ,set)
+      { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: \`$ac_var' was not set in the previous run" >&5
+printf "%s\n" "$as_me: error: \`$ac_var' was not set in the previous run" >&2;}
+      ac_cache_corrupted=: ;;
+    ,);;
+    *)
+      if test "x$ac_old_val" != "x$ac_new_val"; then
+	# differences in whitespace do not lead to failure.
+	ac_old_val_w=`echo x $ac_old_val`
+	ac_new_val_w=`echo x $ac_new_val`
+	if test "$ac_old_val_w" != "$ac_new_val_w"; then
+	  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: \`$ac_var' has changed since the previous run:" >&5
+printf "%s\n" "$as_me: error: \`$ac_var' has changed since the previous run:" >&2;}
+	  ac_cache_corrupted=:
+	else
+	  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: warning: ignoring whitespace changes in \`$ac_var' since the previous run:" >&5
+printf "%s\n" "$as_me: warning: ignoring whitespace changes in \`$ac_var' since the previous run:" >&2;}
+	  eval $ac_var=\$ac_old_val
+	fi
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}:   former value:  \`$ac_old_val'" >&5
+printf "%s\n" "$as_me:   former value:  \`$ac_old_val'" >&2;}
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}:   current value: \`$ac_new_val'" >&5
+printf "%s\n" "$as_me:   current value: \`$ac_new_val'" >&2;}
+      fi;;
+  esac
+  # Pass precious variables to config.status.
+  if test "$ac_new_set" = set; then
+    case $ac_new_val in
+    *\'*) ac_arg=$ac_var=`printf "%s\n" "$ac_new_val" | sed "s/'/'\\\\\\\\''/g"` ;;
+    *) ac_arg=$ac_var=$ac_new_val ;;
+    esac
+    case " $ac_configure_args " in
+      *" '$ac_arg' "*) ;; # Avoid dups.  Use of quotes ensures accuracy.
+      *) as_fn_append ac_configure_args " '$ac_arg'" ;;
+    esac
+  fi
 done
 if $ac_cache_corrupted; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
-$as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
-  { $as_echo "$as_me:${as_lineno-$LINENO}: error: changes in the environment can compromise the build" >&5
-$as_echo "$as_me: error: changes in the environment can compromise the build" >&2;}
-  as_fn_error $? "run \`make distclean' and/or \`rm $cache_file' and start over" "$LINENO" 5
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: changes in the environment can compromise the build" >&5
+printf "%s\n" "$as_me: error: changes in the environment can compromise the build" >&2;}
+  as_fn_error $? "run \`${MAKE-make} distclean' and/or \`rm $cache_file'
+	    and start over" "$LINENO" 5
 fi
 ## -------------------- ##
 ## Main body of script. ##
@@ -2985,57 +3598,33 @@ ac_config_headers="$ac_config_headers include/configure.h"
 
 
 ################################################################################
-ac_aux_dir=
-for ac_dir in autoconf "$srcdir"/autoconf; do
-  if test -f "$ac_dir/install-sh"; then
-    ac_aux_dir=$ac_dir
-    ac_install_sh="$ac_aux_dir/install-sh -c"
-    break
-  elif test -f "$ac_dir/install.sh"; then
-    ac_aux_dir=$ac_dir
-    ac_install_sh="$ac_aux_dir/install.sh -c"
-    break
-  elif test -f "$ac_dir/shtool"; then
-    ac_aux_dir=$ac_dir
-    ac_install_sh="$ac_aux_dir/shtool install -c"
-    break
-  fi
-done
-if test -z "$ac_aux_dir"; then
-  as_fn_error $? "cannot find install-sh, install.sh, or shtool in autoconf \"$srcdir\"/autoconf" "$LINENO" 5
-fi
 
-# These three variables are undocumented and unsupported,
-# and are intended to be withdrawn in a future Autoconf release.
-# They can cause serious problems if a builder's source tree is in a directory
-# whose full name contains unusual characters.
-ac_config_guess="$SHELL $ac_aux_dir/config.guess"  # Please don't use this var.
-ac_config_sub="$SHELL $ac_aux_dir/config.sub"  # Please don't use this var.
-ac_configure="$SHELL $ac_aux_dir/configure"  # Please don't use this var.
 
+################################################################################
 
 
-################################################################################
-# Make sure we can run config.sub.
-$SHELL "$ac_aux_dir/config.sub" sun4 >/dev/null 2>&1 ||
-  as_fn_error $? "cannot run $SHELL $ac_aux_dir/config.sub" "$LINENO" 5
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking build system type" >&5
-$as_echo_n "checking build system type... " >&6; }
-if ${ac_cv_build+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+  # Make sure we can run config.sub.
+$SHELL "${ac_aux_dir}config.sub" sun4 >/dev/null 2>&1 ||
+  as_fn_error $? "cannot run $SHELL ${ac_aux_dir}config.sub" "$LINENO" 5
+
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking build system type" >&5
+printf %s "checking build system type... " >&6; }
+if test ${ac_cv_build+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   ac_build_alias=$build_alias
 test "x$ac_build_alias" = x &&
-  ac_build_alias=`$SHELL "$ac_aux_dir/config.guess"`
+  ac_build_alias=`$SHELL "${ac_aux_dir}config.guess"`
 test "x$ac_build_alias" = x &&
   as_fn_error $? "cannot guess build type; you must specify one" "$LINENO" 5
-ac_cv_build=`$SHELL "$ac_aux_dir/config.sub" $ac_build_alias` ||
-  as_fn_error $? "$SHELL $ac_aux_dir/config.sub $ac_build_alias failed" "$LINENO" 5
+ac_cv_build=`$SHELL "${ac_aux_dir}config.sub" $ac_build_alias` ||
+  as_fn_error $? "$SHELL ${ac_aux_dir}config.sub $ac_build_alias failed" "$LINENO" 5
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_build" >&5
-$as_echo "$ac_cv_build" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_build" >&5
+printf "%s\n" "$ac_cv_build" >&6; }
 case $ac_cv_build in
 *-*-*) ;;
 *) as_fn_error $? "invalid value of canonical build" "$LINENO" 5;;
@@ -3054,21 +3643,22 @@ IFS=$ac_save_IFS
 case $build_os in *\ *) build_os=`echo "$build_os" | sed 's/ /-/g'`;; esac
 
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking host system type" >&5
-$as_echo_n "checking host system type... " >&6; }
-if ${ac_cv_host+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking host system type" >&5
+printf %s "checking host system type... " >&6; }
+if test ${ac_cv_host+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   if test "x$host_alias" = x; then
   ac_cv_host=$ac_cv_build
 else
-  ac_cv_host=`$SHELL "$ac_aux_dir/config.sub" $host_alias` ||
-    as_fn_error $? "$SHELL $ac_aux_dir/config.sub $host_alias failed" "$LINENO" 5
+  ac_cv_host=`$SHELL "${ac_aux_dir}config.sub" $host_alias` ||
+    as_fn_error $? "$SHELL ${ac_aux_dir}config.sub $host_alias failed" "$LINENO" 5
 fi
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_host" >&5
-$as_echo "$ac_cv_host" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_host" >&5
+printf "%s\n" "$ac_cv_host" >&6; }
 case $ac_cv_host in
 *-*-*) ;;
 *) as_fn_error $? "invalid value of canonical host" "$LINENO" 5;;
@@ -3087,21 +3677,22 @@ IFS=$ac_save_IFS
 case $host_os in *\ *) host_os=`echo "$host_os" | sed 's/ /-/g'`;; esac
 
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking target system type" >&5
-$as_echo_n "checking target system type... " >&6; }
-if ${ac_cv_target+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking target system type" >&5
+printf %s "checking target system type... " >&6; }
+if test ${ac_cv_target+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   if test "x$target_alias" = x; then
   ac_cv_target=$ac_cv_host
 else
-  ac_cv_target=`$SHELL "$ac_aux_dir/config.sub" $target_alias` ||
-    as_fn_error $? "$SHELL $ac_aux_dir/config.sub $target_alias failed" "$LINENO" 5
+  ac_cv_target=`$SHELL "${ac_aux_dir}config.sub" $target_alias` ||
+    as_fn_error $? "$SHELL ${ac_aux_dir}config.sub $target_alias failed" "$LINENO" 5
 fi
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_target" >&5
-$as_echo "$ac_cv_target" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_target" >&5
+printf "%s\n" "$ac_cv_target" >&6; }
 case $ac_cv_target in
 *-*-*) ;;
 *) as_fn_error $? "invalid value of canonical target" "$LINENO" 5;;
@@ -3127,7 +3718,8 @@ test -n "$target_alias" &&
     NONENONEs,x,x, &&
   program_prefix=${target_alias}-
 
-if test -z "$CFLAGS"; then :
+if test -z "$CFLAGS"
+then :
   COPTIMISE_FLAG="-O2"
 fi
 case "$host_os" in
@@ -3167,11 +3759,12 @@ case "$host_os" in
 esac
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for a sed that does not truncate output" >&5
-$as_echo_n "checking for a sed that does not truncate output... " >&6; }
-if ${ac_cv_path_SED+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for a sed that does not truncate output" >&5
+printf %s "checking for a sed that does not truncate output... " >&6; }
+if test ${ac_cv_path_SED+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
             ac_script=s/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa/bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb/
      for ac_i in 1 2 3 4 5 6 7; do
        ac_script="$ac_script$as_nl$ac_script"
@@ -3185,10 +3778,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
-    for ac_prog in sed gsed; do
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
+    for ac_prog in sed gsed
+   do
     for ac_exec_ext in '' $ac_executable_extensions; do
-      ac_path_SED="$as_dir/$ac_prog$ac_exec_ext"
+      ac_path_SED="$as_dir$ac_prog$ac_exec_ext"
       as_fn_executable_p "$ac_path_SED" || continue
 # Check for GNU ac_path_SED and select it if it is found.
   # Check for GNU $ac_path_SED
@@ -3197,13 +3795,13 @@ case `"$ac_path_SED" --version 2>&1` in
   ac_cv_path_SED="$ac_path_SED" ac_path_SED_found=:;;
 *)
   ac_count=0
-  $as_echo_n 0123456789 >"conftest.in"
+  printf %s 0123456789 >"conftest.in"
   while :
   do
     cat "conftest.in" "conftest.in" >"conftest.tmp"
     mv "conftest.tmp" "conftest.in"
     cp "conftest.in" "conftest.nl"
-    $as_echo '' >> "conftest.nl"
+    printf "%s\n" '' >> "conftest.nl"
     "$ac_path_SED" -f conftest.sed < "conftest.nl" >"conftest.out" 2>/dev/null || break
     diff "conftest.out" "conftest.nl" >/dev/null 2>&1 || break
     as_fn_arith $ac_count + 1 && ac_count=$as_val
@@ -3231,8 +3829,8 @@ else
 fi
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_path_SED" >&5
-$as_echo "$ac_cv_path_SED" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_path_SED" >&5
+printf "%s\n" "$ac_cv_path_SED" >&6; }
  SED="$ac_cv_path_SED"
   rm -f conftest.sed
 
@@ -3240,11 +3838,12 @@ for ac_prog in gawk mawk nawk awk
 do
   # Extract the first word of "$ac_prog", so it can be a program name with args.
 set dummy $ac_prog; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_prog_AWK+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_prog_AWK+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   if test -n "$AWK"; then
   ac_cv_prog_AWK="$AWK" # Let the user override the test.
 else
@@ -3252,11 +3851,15 @@ as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
     ac_cv_prog_AWK="$ac_prog"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -3267,11 +3870,11 @@ fi
 fi
 AWK=$ac_cv_prog_AWK
 if test -n "$AWK"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $AWK" >&5
-$as_echo "$AWK" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $AWK" >&5
+printf "%s\n" "$AWK" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -3280,6 +3883,15 @@ done
 
 save_CFLAGS=$CFLAGS
 save_CXXFLAGS=$CXXFLAGS
+
+
+
+
+
+
+
+
+
 ac_ext=c
 ac_cpp='$CPP $CPPFLAGS'
 ac_compile='$CC -c $CFLAGS $CPPFLAGS conftest.$ac_ext >&5'
@@ -3288,11 +3900,12 @@ ac_compiler_gnu=$ac_cv_c_compiler_gnu
 if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}gcc", so it can be a program name with args.
 set dummy ${ac_tool_prefix}gcc; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_prog_CC+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_prog_CC+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   if test -n "$CC"; then
   ac_cv_prog_CC="$CC" # Let the user override the test.
 else
@@ -3300,11 +3913,15 @@ as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
     ac_cv_prog_CC="${ac_tool_prefix}gcc"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -3315,11 +3932,11 @@ fi
 fi
 CC=$ac_cv_prog_CC
 if test -n "$CC"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CC" >&5
-$as_echo "$CC" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CC" >&5
+printf "%s\n" "$CC" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -3328,11 +3945,12 @@ if test -z "$ac_cv_prog_CC"; then
   ac_ct_CC=$CC
   # Extract the first word of "gcc", so it can be a program name with args.
 set dummy gcc; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_prog_ac_ct_CC+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_prog_ac_ct_CC+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   if test -n "$ac_ct_CC"; then
   ac_cv_prog_ac_ct_CC="$ac_ct_CC" # Let the user override the test.
 else
@@ -3340,11 +3958,15 @@ as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
     ac_cv_prog_ac_ct_CC="gcc"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -3355,11 +3977,11 @@ fi
 fi
 ac_ct_CC=$ac_cv_prog_ac_ct_CC
 if test -n "$ac_ct_CC"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_ct_CC" >&5
-$as_echo "$ac_ct_CC" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_ct_CC" >&5
+printf "%s\n" "$ac_ct_CC" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_ct_CC" = x; then
@@ -3367,8 +3989,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     CC=$ac_ct_CC
@@ -3381,11 +4003,12 @@ if test -z "$CC"; then
           if test -n "$ac_tool_prefix"; then
     # Extract the first word of "${ac_tool_prefix}cc", so it can be a program name with args.
 set dummy ${ac_tool_prefix}cc; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_prog_CC+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_prog_CC+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   if test -n "$CC"; then
   ac_cv_prog_CC="$CC" # Let the user override the test.
 else
@@ -3393,11 +4016,15 @@ as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
     ac_cv_prog_CC="${ac_tool_prefix}cc"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -3408,11 +4035,11 @@ fi
 fi
 CC=$ac_cv_prog_CC
 if test -n "$CC"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CC" >&5
-$as_echo "$CC" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CC" >&5
+printf "%s\n" "$CC" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -3421,11 +4048,12 @@ fi
 if test -z "$CC"; then
   # Extract the first word of "cc", so it can be a program name with args.
 set dummy cc; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_prog_CC+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_prog_CC+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   if test -n "$CC"; then
   ac_cv_prog_CC="$CC" # Let the user override the test.
 else
@@ -3434,15 +4062,19 @@ as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    if test "$as_dir/$ac_word$ac_exec_ext" = "/usr/ucb/cc"; then
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    if test "$as_dir$ac_word$ac_exec_ext" = "/usr/ucb/cc"; then
        ac_prog_rejected=yes
        continue
      fi
     ac_cv_prog_CC="cc"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -3458,18 +4090,18 @@ if test $ac_prog_rejected = yes; then
     # However, it has the same basename, so the bogon will be chosen
     # first if we set CC to just the basename; use the full file name.
     shift
-    ac_cv_prog_CC="$as_dir/$ac_word${1+' '}$@"
+    ac_cv_prog_CC="$as_dir$ac_word${1+' '}$@"
   fi
 fi
 fi
 fi
 CC=$ac_cv_prog_CC
 if test -n "$CC"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CC" >&5
-$as_echo "$CC" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CC" >&5
+printf "%s\n" "$CC" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -3480,11 +4112,12 @@ if test -z "$CC"; then
   do
     # Extract the first word of "$ac_tool_prefix$ac_prog", so it can be a program name with args.
 set dummy $ac_tool_prefix$ac_prog; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_prog_CC+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_prog_CC+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   if test -n "$CC"; then
   ac_cv_prog_CC="$CC" # Let the user override the test.
 else
@@ -3492,11 +4125,15 @@ as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
     ac_cv_prog_CC="$ac_tool_prefix$ac_prog"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -3507,11 +4144,11 @@ fi
 fi
 CC=$ac_cv_prog_CC
 if test -n "$CC"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CC" >&5
-$as_echo "$CC" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CC" >&5
+printf "%s\n" "$CC" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -3524,11 +4161,12 @@ if test -z "$CC"; then
 do
   # Extract the first word of "$ac_prog", so it can be a program name with args.
 set dummy $ac_prog; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_prog_ac_ct_CC+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_prog_ac_ct_CC+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   if test -n "$ac_ct_CC"; then
   ac_cv_prog_ac_ct_CC="$ac_ct_CC" # Let the user override the test.
 else
@@ -3536,11 +4174,15 @@ as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
     ac_cv_prog_ac_ct_CC="$ac_prog"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -3551,11 +4193,11 @@ fi
 fi
 ac_ct_CC=$ac_cv_prog_ac_ct_CC
 if test -n "$ac_ct_CC"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_ct_CC" >&5
-$as_echo "$ac_ct_CC" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_ct_CC" >&5
+printf "%s\n" "$ac_ct_CC" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -3567,8 +4209,8 @@ done
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     CC=$ac_ct_CC
@@ -3576,25 +4218,129 @@ esac
 fi
 
 fi
+if test -z "$CC"; then
+  if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}clang", so it can be a program name with args.
+set dummy ${ac_tool_prefix}clang; ac_word=$2
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_prog_CC+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if test -n "$CC"; then
+  ac_cv_prog_CC="$CC" # Let the user override the test.
+else
+as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_prog_CC="${ac_tool_prefix}clang"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
+
+fi
+fi
+CC=$ac_cv_prog_CC
+if test -n "$CC"; then
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CC" >&5
+printf "%s\n" "$CC" >&6; }
+else
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
+fi
 
 
-test -z "$CC" && { { $as_echo "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
-$as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
+fi
+if test -z "$ac_cv_prog_CC"; then
+  ac_ct_CC=$CC
+  # Extract the first word of "clang", so it can be a program name with args.
+set dummy clang; ac_word=$2
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_prog_ac_ct_CC+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if test -n "$ac_ct_CC"; then
+  ac_cv_prog_ac_ct_CC="$ac_ct_CC" # Let the user override the test.
+else
+as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_prog_ac_ct_CC="clang"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
+
+fi
+fi
+ac_ct_CC=$ac_cv_prog_ac_ct_CC
+if test -n "$ac_ct_CC"; then
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_ct_CC" >&5
+printf "%s\n" "$ac_ct_CC" >&6; }
+else
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
+fi
+
+  if test "x$ac_ct_CC" = x; then
+    CC=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    CC=$ac_ct_CC
+  fi
+else
+  CC="$ac_cv_prog_CC"
+fi
+
+fi
+
+
+test -z "$CC" && { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
 as_fn_error $? "no acceptable C compiler found in \$PATH
 See \`config.log' for more details" "$LINENO" 5; }
 
 # Provide some information about the compiler.
-$as_echo "$as_me:${as_lineno-$LINENO}: checking for C compiler version" >&5
+printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for C compiler version" >&5
 set X $ac_compile
 ac_compiler=$2
-for ac_option in --version -v -V -qversion; do
+for ac_option in --version -v -V -qversion -version; do
   { { ac_try="$ac_compiler $ac_option >&5"
 case "(($ac_try" in
   *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
   *) ac_try_echo=$ac_try;;
 esac
 eval ac_try_echo="\"\$as_me:${as_lineno-$LINENO}: $ac_try_echo\""
-$as_echo "$ac_try_echo"; } >&5
+printf "%s\n" "$ac_try_echo"; } >&5
   (eval "$ac_compiler $ac_option >&5") 2>conftest.err
   ac_status=$?
   if test -s conftest.err; then
@@ -3604,7 +4350,7 @@ $as_echo "$ac_try_echo"; } >&5
     cat conftest.er1 >&5
   fi
   rm -f conftest.er1 conftest.err
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }
 done
 
@@ -3612,7 +4358,7 @@ cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
 int
-main ()
+main (void)
 {
 
   ;
@@ -3624,9 +4370,9 @@ ac_clean_files="$ac_clean_files a.out a.out.dSYM a.exe b.out"
 # Try to create an executable without -o first, disregard a.out.
 # It will help us diagnose broken compilers, and finding out an intuition
 # of exeext.
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether the C compiler works" >&5
-$as_echo_n "checking whether the C compiler works... " >&6; }
-ac_link_default=`$as_echo "$ac_link" | sed 's/ -o *conftest[^ ]*//'`
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether the C compiler works" >&5
+printf %s "checking whether the C compiler works... " >&6; }
+ac_link_default=`printf "%s\n" "$ac_link" | sed 's/ -o *conftest[^ ]*//'`
 
 # The possible output files:
 ac_files="a.out conftest.exe conftest a.exe a_out.exe b.out conftest.*"
@@ -3647,11 +4393,12 @@ case "(($ac_try" in
   *) ac_try_echo=$ac_try;;
 esac
 eval ac_try_echo="\"\$as_me:${as_lineno-$LINENO}: $ac_try_echo\""
-$as_echo "$ac_try_echo"; } >&5
+printf "%s\n" "$ac_try_echo"; } >&5
   (eval "$ac_link_default") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; then :
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }
+then :
   # Autoconf-2.13 could set the ac_cv_exeext variable to `no'.
 # So ignore a value of `no', otherwise this would lead to `EXEEXT = no'
 # in a Makefile.  We should not override ac_cv_exeext if it was cached,
@@ -3668,7 +4415,7 @@ do
 	# certainly right.
 	break;;
     *.* )
-	if test "${ac_cv_exeext+set}" = set && test "$ac_cv_exeext" != no;
+	if test ${ac_cv_exeext+y} && test "$ac_cv_exeext" != no;
 	then :; else
 	   ac_cv_exeext=`expr "$ac_file" : '[^.]*\(\..*\)'`
 	fi
@@ -3684,44 +4431,46 @@ do
 done
 test "$ac_cv_exeext" = no && ac_cv_exeext=
 
-else
+else $as_nop
   ac_file=''
 fi
-if test -z "$ac_file"; then :
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
-$as_echo "$as_me: failed program was:" >&5
+if test -z "$ac_file"
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
+printf "%s\n" "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
-{ { $as_echo "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
-$as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
+{ { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
 as_fn_error 77 "C compiler cannot create executables
 See \`config.log' for more details" "$LINENO" 5; }
-else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
-fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for C compiler default output file name" >&5
-$as_echo_n "checking for C compiler default output file name... " >&6; }
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_file" >&5
-$as_echo "$ac_file" >&6; }
+else $as_nop
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+printf "%s\n" "yes" >&6; }
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for C compiler default output file name" >&5
+printf %s "checking for C compiler default output file name... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_file" >&5
+printf "%s\n" "$ac_file" >&6; }
 ac_exeext=$ac_cv_exeext
 
 rm -f -r a.out a.out.dSYM a.exe conftest$ac_cv_exeext b.out
 ac_clean_files=$ac_clean_files_save
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for suffix of executables" >&5
-$as_echo_n "checking for suffix of executables... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for suffix of executables" >&5
+printf %s "checking for suffix of executables... " >&6; }
 if { { ac_try="$ac_link"
 case "(($ac_try" in
   *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
   *) ac_try_echo=$ac_try;;
 esac
 eval ac_try_echo="\"\$as_me:${as_lineno-$LINENO}: $ac_try_echo\""
-$as_echo "$ac_try_echo"; } >&5
+printf "%s\n" "$ac_try_echo"; } >&5
   (eval "$ac_link") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; then :
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }
+then :
   # If both `conftest.exe' and `conftest' are `present' (well, observable)
 # catch `conftest.exe'.  For instance with Cygwin, `ls conftest' will
 # work properly (i.e., refer to `conftest.exe'), while it won't with
@@ -3735,15 +4484,15 @@ for ac_file in conftest.exe conftest conftest.*; do
     * ) break;;
   esac
 done
-else
-  { { $as_echo "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
-$as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
+else $as_nop
+  { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
 as_fn_error $? "cannot compute suffix of executables: cannot compile and link
 See \`config.log' for more details" "$LINENO" 5; }
 fi
 rm -f conftest conftest$ac_cv_exeext
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_exeext" >&5
-$as_echo "$ac_cv_exeext" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_exeext" >&5
+printf "%s\n" "$ac_cv_exeext" >&6; }
 
 rm -f conftest.$ac_ext
 EXEEXT=$ac_cv_exeext
@@ -3752,7 +4501,7 @@ cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 #include <stdio.h>
 int
-main ()
+main (void)
 {
 FILE *f = fopen ("conftest.out", "w");
  return ferror (f) || fclose (f) != 0;
@@ -3764,8 +4513,8 @@ _ACEOF
 ac_clean_files="$ac_clean_files conftest.out"
 # Check that the compiler produces executables we can run.  If not, either
 # the compiler is broken, or we cross compile.
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether we are cross compiling" >&5
-$as_echo_n "checking whether we are cross compiling... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether we are cross compiling" >&5
+printf %s "checking whether we are cross compiling... " >&6; }
 if test "$cross_compiling" != yes; then
   { { ac_try="$ac_link"
 case "(($ac_try" in
@@ -3773,10 +4522,10 @@ case "(($ac_try" in
   *) ac_try_echo=$ac_try;;
 esac
 eval ac_try_echo="\"\$as_me:${as_lineno-$LINENO}: $ac_try_echo\""
-$as_echo "$ac_try_echo"; } >&5
+printf "%s\n" "$ac_try_echo"; } >&5
   (eval "$ac_link") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }
   if { ac_try='./conftest$ac_cv_exeext'
   { { case "(($ac_try" in
@@ -3784,39 +4533,40 @@ $as_echo "$ac_try_echo"; } >&5
   *) ac_try_echo=$ac_try;;
 esac
 eval ac_try_echo="\"\$as_me:${as_lineno-$LINENO}: $ac_try_echo\""
-$as_echo "$ac_try_echo"; } >&5
+printf "%s\n" "$ac_try_echo"; } >&5
   (eval "$ac_try") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; }; then
     cross_compiling=no
   else
     if test "$cross_compiling" = maybe; then
 	cross_compiling=yes
     else
-	{ { $as_echo "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
-$as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
-as_fn_error $? "cannot run C compiled programs.
+	{ { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
+as_fn_error 77 "cannot run C compiled programs.
 If you meant to cross compile, use \`--host'.
 See \`config.log' for more details" "$LINENO" 5; }
     fi
   fi
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $cross_compiling" >&5
-$as_echo "$cross_compiling" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $cross_compiling" >&5
+printf "%s\n" "$cross_compiling" >&6; }
 
 rm -f conftest.$ac_ext conftest$ac_cv_exeext conftest.out
 ac_clean_files=$ac_clean_files_save
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for suffix of object files" >&5
-$as_echo_n "checking for suffix of object files... " >&6; }
-if ${ac_cv_objext+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for suffix of object files" >&5
+printf %s "checking for suffix of object files... " >&6; }
+if test ${ac_cv_objext+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
 int
-main ()
+main (void)
 {
 
   ;
@@ -3830,11 +4580,12 @@ case "(($ac_try" in
   *) ac_try_echo=$ac_try;;
 esac
 eval ac_try_echo="\"\$as_me:${as_lineno-$LINENO}: $ac_try_echo\""
-$as_echo "$ac_try_echo"; } >&5
+printf "%s\n" "$ac_try_echo"; } >&5
   (eval "$ac_compile") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; then :
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }
+then :
   for ac_file in conftest.o conftest.obj conftest.*; do
   test -f "$ac_file" || continue;
   case $ac_file in
@@ -3843,31 +4594,32 @@ $as_echo "$ac_try_echo"; } >&5
        break;;
   esac
 done
-else
-  $as_echo "$as_me: failed program was:" >&5
+else $as_nop
+  printf "%s\n" "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
-{ { $as_echo "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
-$as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
+{ { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
 as_fn_error $? "cannot compute suffix of object files: cannot compile
 See \`config.log' for more details" "$LINENO" 5; }
 fi
 rm -f conftest.$ac_cv_objext conftest.$ac_ext
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_objext" >&5
-$as_echo "$ac_cv_objext" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_objext" >&5
+printf "%s\n" "$ac_cv_objext" >&6; }
 OBJEXT=$ac_cv_objext
 ac_objext=$OBJEXT
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether we are using the GNU C compiler" >&5
-$as_echo_n "checking whether we are using the GNU C compiler... " >&6; }
-if ${ac_cv_c_compiler_gnu+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether the compiler supports GNU C" >&5
+printf %s "checking whether the compiler supports GNU C... " >&6; }
+if test ${ac_cv_c_compiler_gnu+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
 int
-main ()
+main (void)
 {
 #ifndef __GNUC__
        choke me
@@ -3877,29 +4629,33 @@ main ()
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   ac_compiler_gnu=yes
-else
+else $as_nop
   ac_compiler_gnu=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 ac_cv_c_compiler_gnu=$ac_compiler_gnu
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_c_compiler_gnu" >&5
-$as_echo "$ac_cv_c_compiler_gnu" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_c_compiler_gnu" >&5
+printf "%s\n" "$ac_cv_c_compiler_gnu" >&6; }
+ac_compiler_gnu=$ac_cv_c_compiler_gnu
+
 if test $ac_compiler_gnu = yes; then
   GCC=yes
 else
   GCC=
 fi
-ac_test_CFLAGS=${CFLAGS+set}
+ac_test_CFLAGS=${CFLAGS+y}
 ac_save_CFLAGS=$CFLAGS
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $CC accepts -g" >&5
-$as_echo_n "checking whether $CC accepts -g... " >&6; }
-if ${ac_cv_prog_cc_g+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether $CC accepts -g" >&5
+printf %s "checking whether $CC accepts -g... " >&6; }
+if test ${ac_cv_prog_cc_g+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   ac_save_c_werror_flag=$ac_c_werror_flag
    ac_c_werror_flag=yes
    ac_cv_prog_cc_g=no
@@ -3908,57 +4664,60 @@ else
 /* end confdefs.h.  */
 
 int
-main ()
+main (void)
 {
 
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   ac_cv_prog_cc_g=yes
-else
+else $as_nop
   CFLAGS=""
       cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
 int
-main ()
+main (void)
 {
 
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
 
-else
+else $as_nop
   ac_c_werror_flag=$ac_save_c_werror_flag
 	 CFLAGS="-g"
 	 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
 int
-main ()
+main (void)
 {
 
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   ac_cv_prog_cc_g=yes
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
    ac_c_werror_flag=$ac_save_c_werror_flag
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_prog_cc_g" >&5
-$as_echo "$ac_cv_prog_cc_g" >&6; }
-if test "$ac_test_CFLAGS" = set; then
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_prog_cc_g" >&5
+printf "%s\n" "$ac_cv_prog_cc_g" >&6; }
+if test $ac_test_CFLAGS; then
   CFLAGS=$ac_save_CFLAGS
 elif test $ac_cv_prog_cc_g = yes; then
   if test "$GCC" = yes; then
@@ -3973,94 +4732,144 @@ else
     CFLAGS=
   fi
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $CC option to accept ISO C89" >&5
-$as_echo_n "checking for $CC option to accept ISO C89... " >&6; }
-if ${ac_cv_prog_cc_c89+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  ac_cv_prog_cc_c89=no
+ac_prog_cc_stdc=no
+if test x$ac_prog_cc_stdc = xno
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $CC option to enable C11 features" >&5
+printf %s "checking for $CC option to enable C11 features... " >&6; }
+if test ${ac_cv_prog_cc_c11+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  ac_cv_prog_cc_c11=no
 ac_save_CC=$CC
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#include <stdarg.h>
-#include <stdio.h>
-struct stat;
-/* Most of the following tests are stolen from RCS 5.7's src/conf.sh.  */
-struct buf { int x; };
-FILE * (*rcsopen) (struct buf *, struct stat *, int);
-static char *e (p, i)
-     char **p;
-     int i;
-{
-  return p[i];
-}
-static char *f (char * (*g) (char **, int), char **p, ...)
-{
-  char *s;
-  va_list v;
-  va_start (v,p);
-  s = g (p, va_arg (v,int));
-  va_end (v);
-  return s;
-}
-
-/* OSF 4.0 Compaq cc is some sort of almost-ANSI by default.  It has
-   function prototypes and stuff, but not '\xHH' hex character constants.
-   These don't provoke an error unfortunately, instead are silently treated
-   as 'x'.  The following induces an error, until -std is added to get
-   proper ANSI mode.  Curiously '\x00'!='x' always comes out true, for an
-   array size at least.  It's necessary to write '\x00'==0 to get something
-   that's true only with -std.  */
-int osf4_cc_array ['\x00' == 0 ? 1 : -1];
+$ac_c_conftest_c11_program
+_ACEOF
+for ac_arg in '' -std=gnu11
+do
+  CC="$ac_save_CC $ac_arg"
+  if ac_fn_c_try_compile "$LINENO"
+then :
+  ac_cv_prog_cc_c11=$ac_arg
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam
+  test "x$ac_cv_prog_cc_c11" != "xno" && break
+done
+rm -f conftest.$ac_ext
+CC=$ac_save_CC
+fi
 
-/* IBM C 6 for AIX is almost-ANSI by default, but it replaces macro parameters
-   inside strings and character constants.  */
-#define FOO(x) 'x'
-int xlc6_cc_array[FOO(a) == 'x' ? 1 : -1];
+if test "x$ac_cv_prog_cc_c11" = xno
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: unsupported" >&5
+printf "%s\n" "unsupported" >&6; }
+else $as_nop
+  if test "x$ac_cv_prog_cc_c11" = x
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: none needed" >&5
+printf "%s\n" "none needed" >&6; }
+else $as_nop
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_prog_cc_c11" >&5
+printf "%s\n" "$ac_cv_prog_cc_c11" >&6; }
+     CC="$CC $ac_cv_prog_cc_c11"
+fi
+  ac_cv_prog_cc_stdc=$ac_cv_prog_cc_c11
+  ac_prog_cc_stdc=c11
+fi
+fi
+if test x$ac_prog_cc_stdc = xno
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $CC option to enable C99 features" >&5
+printf %s "checking for $CC option to enable C99 features... " >&6; }
+if test ${ac_cv_prog_cc_c99+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  ac_cv_prog_cc_c99=no
+ac_save_CC=$CC
+cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+$ac_c_conftest_c99_program
+_ACEOF
+for ac_arg in '' -std=gnu99 -std=c99 -c99 -qlanglvl=extc1x -qlanglvl=extc99 -AC99 -D_STDC_C99=
+do
+  CC="$ac_save_CC $ac_arg"
+  if ac_fn_c_try_compile "$LINENO"
+then :
+  ac_cv_prog_cc_c99=$ac_arg
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam
+  test "x$ac_cv_prog_cc_c99" != "xno" && break
+done
+rm -f conftest.$ac_ext
+CC=$ac_save_CC
+fi
 
-int test (int i, double x);
-struct s1 {int (*f) (int a);};
-struct s2 {int (*f) (double a);};
-int pairnames (int, char **, FILE *(*)(struct buf *, struct stat *, int), int, int);
-int argc;
-char **argv;
-int
-main ()
-{
-return f (e, argv, 0) != argv[0]  ||  f (e, argv, 1) != argv[1];
-  ;
-  return 0;
-}
+if test "x$ac_cv_prog_cc_c99" = xno
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: unsupported" >&5
+printf "%s\n" "unsupported" >&6; }
+else $as_nop
+  if test "x$ac_cv_prog_cc_c99" = x
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: none needed" >&5
+printf "%s\n" "none needed" >&6; }
+else $as_nop
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_prog_cc_c99" >&5
+printf "%s\n" "$ac_cv_prog_cc_c99" >&6; }
+     CC="$CC $ac_cv_prog_cc_c99"
+fi
+  ac_cv_prog_cc_stdc=$ac_cv_prog_cc_c99
+  ac_prog_cc_stdc=c99
+fi
+fi
+if test x$ac_prog_cc_stdc = xno
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $CC option to enable C89 features" >&5
+printf %s "checking for $CC option to enable C89 features... " >&6; }
+if test ${ac_cv_prog_cc_c89+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  ac_cv_prog_cc_c89=no
+ac_save_CC=$CC
+cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+$ac_c_conftest_c89_program
 _ACEOF
-for ac_arg in '' -qlanglvl=extc89 -qlanglvl=ansi -std \
-	-Ae "-Aa -D_HPUX_SOURCE" "-Xc -D__EXTENSIONS__"
+for ac_arg in '' -qlanglvl=extc89 -qlanglvl=ansi -std -Ae "-Aa -D_HPUX_SOURCE" "-Xc -D__EXTENSIONS__"
 do
   CC="$ac_save_CC $ac_arg"
-  if ac_fn_c_try_compile "$LINENO"; then :
+  if ac_fn_c_try_compile "$LINENO"
+then :
   ac_cv_prog_cc_c89=$ac_arg
 fi
-rm -f core conftest.err conftest.$ac_objext
+rm -f core conftest.err conftest.$ac_objext conftest.beam
   test "x$ac_cv_prog_cc_c89" != "xno" && break
 done
 rm -f conftest.$ac_ext
 CC=$ac_save_CC
-
 fi
-# AC_CACHE_VAL
-case "x$ac_cv_prog_cc_c89" in
-  x)
-    { $as_echo "$as_me:${as_lineno-$LINENO}: result: none needed" >&5
-$as_echo "none needed" >&6; } ;;
-  xno)
-    { $as_echo "$as_me:${as_lineno-$LINENO}: result: unsupported" >&5
-$as_echo "unsupported" >&6; } ;;
-  *)
-    CC="$CC $ac_cv_prog_cc_c89"
-    { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_prog_cc_c89" >&5
-$as_echo "$ac_cv_prog_cc_c89" >&6; } ;;
-esac
-if test "x$ac_cv_prog_cc_c89" != xno; then :
 
+if test "x$ac_cv_prog_cc_c89" = xno
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: unsupported" >&5
+printf "%s\n" "unsupported" >&6; }
+else $as_nop
+  if test "x$ac_cv_prog_cc_c89" = x
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: none needed" >&5
+printf "%s\n" "none needed" >&6; }
+else $as_nop
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_prog_cc_c89" >&5
+printf "%s\n" "$ac_cv_prog_cc_c89" >&6; }
+     CC="$CC $ac_cv_prog_cc_c89"
+fi
+  ac_cv_prog_cc_stdc=$ac_cv_prog_cc_c89
+  ac_prog_cc_stdc=c89
+fi
 fi
 
 ac_ext=c
@@ -4069,6 +4878,12 @@ ac_compile='$CC -c $CFLAGS $CPPFLAGS conftest.$ac_ext >&5'
 ac_link='$CC -o conftest$ac_exeext $CFLAGS $CPPFLAGS $LDFLAGS conftest.$ac_ext $LIBS >&5'
 ac_compiler_gnu=$ac_cv_c_compiler_gnu
 
+
+
+
+
+
+
 ac_ext=cpp
 ac_cpp='$CXXCPP $CPPFLAGS'
 ac_compile='$CXX -c $CXXFLAGS $CPPFLAGS conftest.$ac_ext >&5'
@@ -4079,15 +4894,16 @@ if test -z "$CXX"; then
     CXX=$CCC
   else
     if test -n "$ac_tool_prefix"; then
-  for ac_prog in g++ c++ gpp aCC CC cxx cc++ cl.exe FCC KCC RCC xlC_r xlC
+  for ac_prog in g++ c++ gpp aCC CC cxx cc++ cl.exe FCC KCC RCC xlC_r xlC clang++
   do
     # Extract the first word of "$ac_tool_prefix$ac_prog", so it can be a program name with args.
 set dummy $ac_tool_prefix$ac_prog; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_prog_CXX+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_prog_CXX+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   if test -n "$CXX"; then
   ac_cv_prog_CXX="$CXX" # Let the user override the test.
 else
@@ -4095,11 +4911,15 @@ as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
     ac_cv_prog_CXX="$ac_tool_prefix$ac_prog"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -4110,11 +4930,11 @@ fi
 fi
 CXX=$ac_cv_prog_CXX
 if test -n "$CXX"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CXX" >&5
-$as_echo "$CXX" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CXX" >&5
+printf "%s\n" "$CXX" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -4123,15 +4943,16 @@ fi
 fi
 if test -z "$CXX"; then
   ac_ct_CXX=$CXX
-  for ac_prog in g++ c++ gpp aCC CC cxx cc++ cl.exe FCC KCC RCC xlC_r xlC
+  for ac_prog in g++ c++ gpp aCC CC cxx cc++ cl.exe FCC KCC RCC xlC_r xlC clang++
 do
   # Extract the first word of "$ac_prog", so it can be a program name with args.
 set dummy $ac_prog; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_prog_ac_ct_CXX+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_prog_ac_ct_CXX+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   if test -n "$ac_ct_CXX"; then
   ac_cv_prog_ac_ct_CXX="$ac_ct_CXX" # Let the user override the test.
 else
@@ -4139,11 +4960,15 @@ as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
     ac_cv_prog_ac_ct_CXX="$ac_prog"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -4154,11 +4979,11 @@ fi
 fi
 ac_ct_CXX=$ac_cv_prog_ac_ct_CXX
 if test -n "$ac_ct_CXX"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_ct_CXX" >&5
-$as_echo "$ac_ct_CXX" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_ct_CXX" >&5
+printf "%s\n" "$ac_ct_CXX" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -4170,8 +4995,8 @@ done
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     CXX=$ac_ct_CXX
@@ -4181,7 +5006,7 @@ fi
   fi
 fi
 # Provide some information about the compiler.
-$as_echo "$as_me:${as_lineno-$LINENO}: checking for C++ compiler version" >&5
+printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for C++ compiler version" >&5
 set X $ac_compile
 ac_compiler=$2
 for ac_option in --version -v -V -qversion; do
@@ -4191,7 +5016,7 @@ case "(($ac_try" in
   *) ac_try_echo=$ac_try;;
 esac
 eval ac_try_echo="\"\$as_me:${as_lineno-$LINENO}: $ac_try_echo\""
-$as_echo "$ac_try_echo"; } >&5
+printf "%s\n" "$ac_try_echo"; } >&5
   (eval "$ac_compiler $ac_option >&5") 2>conftest.err
   ac_status=$?
   if test -s conftest.err; then
@@ -4201,20 +5026,21 @@ $as_echo "$ac_try_echo"; } >&5
     cat conftest.er1 >&5
   fi
   rm -f conftest.er1 conftest.err
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }
 done
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether we are using the GNU C++ compiler" >&5
-$as_echo_n "checking whether we are using the GNU C++ compiler... " >&6; }
-if ${ac_cv_cxx_compiler_gnu+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether the compiler supports GNU C++" >&5
+printf %s "checking whether the compiler supports GNU C++... " >&6; }
+if test ${ac_cv_cxx_compiler_gnu+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
 int
-main ()
+main (void)
 {
 #ifndef __GNUC__
        choke me
@@ -4224,29 +5050,33 @@ main ()
   return 0;
 }
 _ACEOF
-if ac_fn_cxx_try_compile "$LINENO"; then :
+if ac_fn_cxx_try_compile "$LINENO"
+then :
   ac_compiler_gnu=yes
-else
+else $as_nop
   ac_compiler_gnu=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 ac_cv_cxx_compiler_gnu=$ac_compiler_gnu
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_cxx_compiler_gnu" >&5
-$as_echo "$ac_cv_cxx_compiler_gnu" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_cxx_compiler_gnu" >&5
+printf "%s\n" "$ac_cv_cxx_compiler_gnu" >&6; }
+ac_compiler_gnu=$ac_cv_cxx_compiler_gnu
+
 if test $ac_compiler_gnu = yes; then
   GXX=yes
 else
   GXX=
 fi
-ac_test_CXXFLAGS=${CXXFLAGS+set}
+ac_test_CXXFLAGS=${CXXFLAGS+y}
 ac_save_CXXFLAGS=$CXXFLAGS
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $CXX accepts -g" >&5
-$as_echo_n "checking whether $CXX accepts -g... " >&6; }
-if ${ac_cv_prog_cxx_g+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether $CXX accepts -g" >&5
+printf %s "checking whether $CXX accepts -g... " >&6; }
+if test ${ac_cv_prog_cxx_g+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   ac_save_cxx_werror_flag=$ac_cxx_werror_flag
    ac_cxx_werror_flag=yes
    ac_cv_prog_cxx_g=no
@@ -4255,57 +5085,60 @@ else
 /* end confdefs.h.  */
 
 int
-main ()
+main (void)
 {
 
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_cxx_try_compile "$LINENO"; then :
+if ac_fn_cxx_try_compile "$LINENO"
+then :
   ac_cv_prog_cxx_g=yes
-else
+else $as_nop
   CXXFLAGS=""
       cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
 int
-main ()
+main (void)
 {
 
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_cxx_try_compile "$LINENO"; then :
+if ac_fn_cxx_try_compile "$LINENO"
+then :
 
-else
+else $as_nop
   ac_cxx_werror_flag=$ac_save_cxx_werror_flag
 	 CXXFLAGS="-g"
 	 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
 int
-main ()
+main (void)
 {
 
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_cxx_try_compile "$LINENO"; then :
+if ac_fn_cxx_try_compile "$LINENO"
+then :
   ac_cv_prog_cxx_g=yes
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
    ac_cxx_werror_flag=$ac_save_cxx_werror_flag
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_prog_cxx_g" >&5
-$as_echo "$ac_cv_prog_cxx_g" >&6; }
-if test "$ac_test_CXXFLAGS" = set; then
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_prog_cxx_g" >&5
+printf "%s\n" "$ac_cv_prog_cxx_g" >&6; }
+if test $ac_test_CXXFLAGS; then
   CXXFLAGS=$ac_save_CXXFLAGS
 elif test $ac_cv_prog_cxx_g = yes; then
   if test "$GXX" = yes; then
@@ -4320,6 +5153,100 @@ else
     CXXFLAGS=
   fi
 fi
+ac_prog_cxx_stdcxx=no
+if test x$ac_prog_cxx_stdcxx = xno
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $CXX option to enable C++11 features" >&5
+printf %s "checking for $CXX option to enable C++11 features... " >&6; }
+if test ${ac_cv_prog_cxx_11+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  ac_cv_prog_cxx_11=no
+ac_save_CXX=$CXX
+cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+$ac_cxx_conftest_cxx11_program
+_ACEOF
+for ac_arg in '' -std=gnu++11 -std=gnu++0x -std=c++11 -std=c++0x -qlanglvl=extended0x -AA
+do
+  CXX="$ac_save_CXX $ac_arg"
+  if ac_fn_cxx_try_compile "$LINENO"
+then :
+  ac_cv_prog_cxx_cxx11=$ac_arg
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam
+  test "x$ac_cv_prog_cxx_cxx11" != "xno" && break
+done
+rm -f conftest.$ac_ext
+CXX=$ac_save_CXX
+fi
+
+if test "x$ac_cv_prog_cxx_cxx11" = xno
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: unsupported" >&5
+printf "%s\n" "unsupported" >&6; }
+else $as_nop
+  if test "x$ac_cv_prog_cxx_cxx11" = x
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: none needed" >&5
+printf "%s\n" "none needed" >&6; }
+else $as_nop
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_prog_cxx_cxx11" >&5
+printf "%s\n" "$ac_cv_prog_cxx_cxx11" >&6; }
+     CXX="$CXX $ac_cv_prog_cxx_cxx11"
+fi
+  ac_cv_prog_cxx_stdcxx=$ac_cv_prog_cxx_cxx11
+  ac_prog_cxx_stdcxx=cxx11
+fi
+fi
+if test x$ac_prog_cxx_stdcxx = xno
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $CXX option to enable C++98 features" >&5
+printf %s "checking for $CXX option to enable C++98 features... " >&6; }
+if test ${ac_cv_prog_cxx_98+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  ac_cv_prog_cxx_98=no
+ac_save_CXX=$CXX
+cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+$ac_cxx_conftest_cxx98_program
+_ACEOF
+for ac_arg in '' -std=gnu++98 -std=c++98 -qlanglvl=extended -AA
+do
+  CXX="$ac_save_CXX $ac_arg"
+  if ac_fn_cxx_try_compile "$LINENO"
+then :
+  ac_cv_prog_cxx_cxx98=$ac_arg
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam
+  test "x$ac_cv_prog_cxx_cxx98" != "xno" && break
+done
+rm -f conftest.$ac_ext
+CXX=$ac_save_CXX
+fi
+
+if test "x$ac_cv_prog_cxx_cxx98" = xno
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: unsupported" >&5
+printf "%s\n" "unsupported" >&6; }
+else $as_nop
+  if test "x$ac_cv_prog_cxx_cxx98" = x
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: none needed" >&5
+printf "%s\n" "none needed" >&6; }
+else $as_nop
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_prog_cxx_cxx98" >&5
+printf "%s\n" "$ac_cv_prog_cxx_cxx98" >&6; }
+     CXX="$CXX $ac_cv_prog_cxx_cxx98"
+fi
+  ac_cv_prog_cxx_stdcxx=$ac_cv_prog_cxx_cxx98
+  ac_prog_cxx_stdcxx=cxx98
+fi
+fi
+
 ac_ext=c
 ac_cpp='$CPP $CPPFLAGS'
 ac_compile='$CC -c $CFLAGS $CPPFLAGS conftest.$ac_ext >&5'
@@ -4336,40 +5263,36 @@ ac_cpp='$CPP $CPPFLAGS'
 ac_compile='$CC -c $CFLAGS $CPPFLAGS conftest.$ac_ext >&5'
 ac_link='$CC -o conftest$ac_exeext $CFLAGS $CPPFLAGS $LDFLAGS conftest.$ac_ext $LIBS >&5'
 ac_compiler_gnu=$ac_cv_c_compiler_gnu
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking how to run the C preprocessor" >&5
-$as_echo_n "checking how to run the C preprocessor... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking how to run the C preprocessor" >&5
+printf %s "checking how to run the C preprocessor... " >&6; }
 # On Suns, sometimes $CPP names a directory.
 if test -n "$CPP" && test -d "$CPP"; then
   CPP=
 fi
 if test -z "$CPP"; then
-  if ${ac_cv_prog_CPP+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-      # Double quotes because CPP needs to be expanded
-    for CPP in "$CC -E" "$CC -E -traditional-cpp" "/lib/cpp"
+  if test ${ac_cv_prog_CPP+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+      # Double quotes because $CC needs to be expanded
+    for CPP in "$CC -E" "$CC -E -traditional-cpp" cpp /lib/cpp
     do
       ac_preproc_ok=false
 for ac_c_preproc_warn_flag in '' yes
 do
   # Use a header file that comes with gcc, so configuring glibc
   # with a fresh cross-compiler works.
-  # Prefer <limits.h> to <assert.h> if __STDC__ is defined, since
-  # <limits.h> exists even on freestanding compilers.
   # On the NeXT, cc -E runs the code through the compiler's parser,
   # not just through cpp. "Syntax error" is here to catch this case.
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#ifdef __STDC__
-# include <limits.h>
-#else
-# include <assert.h>
-#endif
+#include <limits.h>
 		     Syntax error
 _ACEOF
-if ac_fn_c_try_cpp "$LINENO"; then :
+if ac_fn_c_try_cpp "$LINENO"
+then :
 
-else
+else $as_nop
   # Broken: fails on valid input.
 continue
 fi
@@ -4381,10 +5304,11 @@ rm -f conftest.err conftest.i conftest.$ac_ext
 /* end confdefs.h.  */
 #include <ac_nonexistent.h>
 _ACEOF
-if ac_fn_c_try_cpp "$LINENO"; then :
+if ac_fn_c_try_cpp "$LINENO"
+then :
   # Broken: success on invalid input.
 continue
-else
+else $as_nop
   # Passes both tests.
 ac_preproc_ok=:
 break
@@ -4394,7 +5318,8 @@ rm -f conftest.err conftest.i conftest.$ac_ext
 done
 # Because of `break', _AC_PREPROC_IFELSE's cleaning code was skipped.
 rm -f conftest.i conftest.err conftest.$ac_ext
-if $ac_preproc_ok; then :
+if $ac_preproc_ok
+then :
   break
 fi
 
@@ -4406,29 +5331,24 @@ fi
 else
   ac_cv_prog_CPP=$CPP
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $CPP" >&5
-$as_echo "$CPP" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CPP" >&5
+printf "%s\n" "$CPP" >&6; }
 ac_preproc_ok=false
 for ac_c_preproc_warn_flag in '' yes
 do
   # Use a header file that comes with gcc, so configuring glibc
   # with a fresh cross-compiler works.
-  # Prefer <limits.h> to <assert.h> if __STDC__ is defined, since
-  # <limits.h> exists even on freestanding compilers.
   # On the NeXT, cc -E runs the code through the compiler's parser,
   # not just through cpp. "Syntax error" is here to catch this case.
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#ifdef __STDC__
-# include <limits.h>
-#else
-# include <assert.h>
-#endif
+#include <limits.h>
 		     Syntax error
 _ACEOF
-if ac_fn_c_try_cpp "$LINENO"; then :
+if ac_fn_c_try_cpp "$LINENO"
+then :
 
-else
+else $as_nop
   # Broken: fails on valid input.
 continue
 fi
@@ -4440,10 +5360,11 @@ rm -f conftest.err conftest.i conftest.$ac_ext
 /* end confdefs.h.  */
 #include <ac_nonexistent.h>
 _ACEOF
-if ac_fn_c_try_cpp "$LINENO"; then :
+if ac_fn_c_try_cpp "$LINENO"
+then :
   # Broken: success on invalid input.
 continue
-else
+else $as_nop
   # Passes both tests.
 ac_preproc_ok=:
 break
@@ -4453,11 +5374,12 @@ rm -f conftest.err conftest.i conftest.$ac_ext
 done
 # Because of `break', _AC_PREPROC_IFELSE's cleaning code was skipped.
 rm -f conftest.i conftest.err conftest.$ac_ext
-if $ac_preproc_ok; then :
+if $ac_preproc_ok
+then :
 
-else
-  { { $as_echo "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
-$as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
+else $as_nop
+  { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
 as_fn_error $? "C preprocessor \"$CPP\" fails sanity check
 See \`config.log' for more details" "$LINENO" 5; }
 fi
@@ -4469,11 +5391,12 @@ ac_link='$CC -o conftest$ac_exeext $CFLAGS $CPPFLAGS $LDFLAGS conftest.$ac_ext $
 ac_compiler_gnu=$ac_cv_c_compiler_gnu
 
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for grep that handles long lines and -e" >&5
-$as_echo_n "checking for grep that handles long lines and -e... " >&6; }
-if ${ac_cv_path_GREP+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for grep that handles long lines and -e" >&5
+printf %s "checking for grep that handles long lines and -e... " >&6; }
+if test ${ac_cv_path_GREP+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   if test -z "$GREP"; then
   ac_path_GREP_found=false
   # Loop through the user's path and test for each of PROGNAME-LIST
@@ -4481,10 +5404,15 @@ else
 for as_dir in $PATH$PATH_SEPARATOR/usr/xpg4/bin
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
-    for ac_prog in grep ggrep; do
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
+    for ac_prog in grep ggrep
+   do
     for ac_exec_ext in '' $ac_executable_extensions; do
-      ac_path_GREP="$as_dir/$ac_prog$ac_exec_ext"
+      ac_path_GREP="$as_dir$ac_prog$ac_exec_ext"
       as_fn_executable_p "$ac_path_GREP" || continue
 # Check for GNU ac_path_GREP and select it if it is found.
   # Check for GNU $ac_path_GREP
@@ -4493,13 +5421,13 @@ case `"$ac_path_GREP" --version 2>&1` in
   ac_cv_path_GREP="$ac_path_GREP" ac_path_GREP_found=:;;
 *)
   ac_count=0
-  $as_echo_n 0123456789 >"conftest.in"
+  printf %s 0123456789 >"conftest.in"
   while :
   do
     cat "conftest.in" "conftest.in" >"conftest.tmp"
     mv "conftest.tmp" "conftest.in"
     cp "conftest.in" "conftest.nl"
-    $as_echo 'GREP' >> "conftest.nl"
+    printf "%s\n" 'GREP' >> "conftest.nl"
     "$ac_path_GREP" -e 'GREP$' -e '-(cannot match)-' < "conftest.nl" >"conftest.out" 2>/dev/null || break
     diff "conftest.out" "conftest.nl" >/dev/null 2>&1 || break
     as_fn_arith $ac_count + 1 && ac_count=$as_val
@@ -4527,16 +5455,17 @@ else
 fi
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_path_GREP" >&5
-$as_echo "$ac_cv_path_GREP" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_path_GREP" >&5
+printf "%s\n" "$ac_cv_path_GREP" >&6; }
  GREP="$ac_cv_path_GREP"
 
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for egrep" >&5
-$as_echo_n "checking for egrep... " >&6; }
-if ${ac_cv_path_EGREP+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for egrep" >&5
+printf %s "checking for egrep... " >&6; }
+if test ${ac_cv_path_EGREP+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   if echo a | $GREP -E '(a|b)' >/dev/null 2>&1
    then ac_cv_path_EGREP="$GREP -E"
    else
@@ -4547,10 +5476,15 @@ else
 for as_dir in $PATH$PATH_SEPARATOR/usr/xpg4/bin
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
-    for ac_prog in egrep; do
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
+    for ac_prog in egrep
+   do
     for ac_exec_ext in '' $ac_executable_extensions; do
-      ac_path_EGREP="$as_dir/$ac_prog$ac_exec_ext"
+      ac_path_EGREP="$as_dir$ac_prog$ac_exec_ext"
       as_fn_executable_p "$ac_path_EGREP" || continue
 # Check for GNU ac_path_EGREP and select it if it is found.
   # Check for GNU $ac_path_EGREP
@@ -4559,13 +5493,13 @@ case `"$ac_path_EGREP" --version 2>&1` in
   ac_cv_path_EGREP="$ac_path_EGREP" ac_path_EGREP_found=:;;
 *)
   ac_count=0
-  $as_echo_n 0123456789 >"conftest.in"
+  printf %s 0123456789 >"conftest.in"
   while :
   do
     cat "conftest.in" "conftest.in" >"conftest.tmp"
     mv "conftest.tmp" "conftest.in"
     cp "conftest.in" "conftest.nl"
-    $as_echo 'EGREP' >> "conftest.nl"
+    printf "%s\n" 'EGREP' >> "conftest.nl"
     "$ac_path_EGREP" 'EGREP$' < "conftest.nl" >"conftest.out" 2>/dev/null || break
     diff "conftest.out" "conftest.nl" >/dev/null 2>&1 || break
     as_fn_arith $ac_count + 1 && ac_count=$as_val
@@ -4594,17 +5528,18 @@ fi
 
    fi
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_path_EGREP" >&5
-$as_echo "$ac_cv_path_EGREP" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_path_EGREP" >&5
+printf "%s\n" "$ac_cv_path_EGREP" >&6; }
  EGREP="$ac_cv_path_EGREP"
 
 
 if test $ac_cv_c_compiler_gnu = yes; then
-    { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $CC needs -traditional" >&5
-$as_echo_n "checking whether $CC needs -traditional... " >&6; }
-if ${ac_cv_prog_gcc_traditional+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether $CC needs -traditional" >&5
+printf %s "checking whether $CC needs -traditional... " >&6; }
+if test ${ac_cv_prog_gcc_traditional+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
     ac_pattern="Autoconf.*'x'"
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
@@ -4612,12 +5547,13 @@ else
 Autoconf TIOCGETP
 _ACEOF
 if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
-  $EGREP "$ac_pattern" >/dev/null 2>&1; then :
+  $EGREP "$ac_pattern" >/dev/null 2>&1
+then :
   ac_cv_prog_gcc_traditional=yes
-else
+else $as_nop
   ac_cv_prog_gcc_traditional=no
 fi
-rm -f conftest*
+rm -rf conftest*
 
 
   if test $ac_cv_prog_gcc_traditional = no; then
@@ -4627,21 +5563,23 @@ rm -f conftest*
 Autoconf TCGETA
 _ACEOF
 if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
-  $EGREP "$ac_pattern" >/dev/null 2>&1; then :
+  $EGREP "$ac_pattern" >/dev/null 2>&1
+then :
   ac_cv_prog_gcc_traditional=yes
 fi
-rm -f conftest*
+rm -rf conftest*
 
   fi
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_prog_gcc_traditional" >&5
-$as_echo "$ac_cv_prog_gcc_traditional" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_prog_gcc_traditional" >&5
+printf "%s\n" "$ac_cv_prog_gcc_traditional" >&6; }
   if test $ac_cv_prog_gcc_traditional = yes; then
     CC="$CC -traditional"
   fi
 fi
 
-# Find a good install program.  We prefer a C program (faster),
+
+  # Find a good install program.  We prefer a C program (faster),
 # so one script is as good as another.  But avoid the broken or
 # incompatible versions:
 # SysV /etc/install, /usr/sbin/install
@@ -4655,20 +5593,25 @@ fi
 # OS/2's system install, which has a completely different semantic
 # ./install, which can be erroneously created by make from ./install.sh.
 # Reject install programs that cannot install multiple files.
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for a BSD-compatible install" >&5
-$as_echo_n "checking for a BSD-compatible install... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for a BSD-compatible install" >&5
+printf %s "checking for a BSD-compatible install... " >&6; }
 if test -z "$INSTALL"; then
-if ${ac_cv_path_install+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+if test ${ac_cv_path_install+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
-    # Account for people who put trailing slashes in PATH elements.
-case $as_dir/ in #((
-  ./ | .// | /[cC]/* | \
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
+    # Account for fact that we put trailing slashes in our PATH walk.
+case $as_dir in #((
+  ./ | /[cC]/* | \
   /etc/* | /usr/sbin/* | /usr/etc/* | /sbin/* | /usr/afsws/bin/* | \
   ?:[\\/]os2[\\/]install[\\/]* | ?:[\\/]OS2[\\/]INSTALL[\\/]* | \
   /usr/ucb/* ) ;;
@@ -4678,13 +5621,13 @@ case $as_dir/ in #((
     # by default.
     for ac_prog in ginstall scoinst install; do
       for ac_exec_ext in '' $ac_executable_extensions; do
-	if as_fn_executable_p "$as_dir/$ac_prog$ac_exec_ext"; then
+	if as_fn_executable_p "$as_dir$ac_prog$ac_exec_ext"; then
 	  if test $ac_prog = install &&
-	    grep dspmsg "$as_dir/$ac_prog$ac_exec_ext" >/dev/null 2>&1; then
+	    grep dspmsg "$as_dir$ac_prog$ac_exec_ext" >/dev/null 2>&1; then
 	    # AIX install.  It has an incompatible calling convention.
 	    :
 	  elif test $ac_prog = install &&
-	    grep pwplus "$as_dir/$ac_prog$ac_exec_ext" >/dev/null 2>&1; then
+	    grep pwplus "$as_dir$ac_prog$ac_exec_ext" >/dev/null 2>&1; then
 	    # program-specific install script used by HP pwplus--don't use.
 	    :
 	  else
@@ -4692,12 +5635,12 @@ case $as_dir/ in #((
 	    echo one > conftest.one
 	    echo two > conftest.two
 	    mkdir conftest.dir
-	    if "$as_dir/$ac_prog$ac_exec_ext" -c conftest.one conftest.two "`pwd`/conftest.dir" &&
+	    if "$as_dir$ac_prog$ac_exec_ext" -c conftest.one conftest.two "`pwd`/conftest.dir/" &&
 	      test -s conftest.one && test -s conftest.two &&
 	      test -s conftest.dir/conftest.one &&
 	      test -s conftest.dir/conftest.two
 	    then
-	      ac_cv_path_install="$as_dir/$ac_prog$ac_exec_ext -c"
+	      ac_cv_path_install="$as_dir$ac_prog$ac_exec_ext -c"
 	      break 3
 	    fi
 	  fi
@@ -4713,7 +5656,7 @@ IFS=$as_save_IFS
 rm -rf conftest.one conftest.two conftest.dir
 
 fi
-  if test "${ac_cv_path_install+set}" = set; then
+  if test ${ac_cv_path_install+y}; then
     INSTALL=$ac_cv_path_install
   else
     # As a last resort, use the slow shell script.  Don't cache a
@@ -4723,8 +5666,8 @@ fi
     INSTALL=$ac_install_sh
   fi
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $INSTALL" >&5
-$as_echo "$INSTALL" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $INSTALL" >&5
+printf "%s\n" "$INSTALL" >&6; }
 
 # Use test -z because SunOS4 sh mishandles braces in ${var-val}.
 # It thinks the first close brace ends the variable substitution.
@@ -4734,24 +5677,25 @@ test -z "$INSTALL_SCRIPT" && INSTALL_SCRIPT='${INSTALL}'
 
 test -z "$INSTALL_DATA" && INSTALL_DATA='${INSTALL} -m 644'
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether ln -s works" >&5
-$as_echo_n "checking whether ln -s works... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether ln -s works" >&5
+printf %s "checking whether ln -s works... " >&6; }
 LN_S=$as_ln_s
 if test "$LN_S" = "ln -s"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+printf "%s\n" "yes" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no, using $LN_S" >&5
-$as_echo "no, using $LN_S" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no, using $LN_S" >&5
+printf "%s\n" "no, using $LN_S" >&6; }
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether ${MAKE-make} sets \$(MAKE)" >&5
-$as_echo_n "checking whether ${MAKE-make} sets \$(MAKE)... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether ${MAKE-make} sets \$(MAKE)" >&5
+printf %s "checking whether ${MAKE-make} sets \$(MAKE)... " >&6; }
 set x ${MAKE-make}
-ac_make=`$as_echo "$2" | sed 's/+/p/g; s/[^a-zA-Z0-9_]/_/g'`
-if eval \${ac_cv_prog_make_${ac_make}_set+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+ac_make=`printf "%s\n" "$2" | sed 's/+/p/g; s/[^a-zA-Z0-9_]/_/g'`
+if eval test \${ac_cv_prog_make_${ac_make}_set+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   cat >conftest.make <<\_ACEOF
 SHELL = /bin/sh
 all:
@@ -4767,34 +5711,40 @@ esac
 rm -f conftest.make
 fi
 if eval test \$ac_cv_prog_make_${ac_make}_set = yes; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+printf "%s\n" "yes" >&6; }
   SET_MAKE=
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
   SET_MAKE="MAKE=${MAKE-make}"
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for a thread-safe mkdir -p" >&5
-$as_echo_n "checking for a thread-safe mkdir -p... " >&6; }
+
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for a race-free mkdir -p" >&5
+printf %s "checking for a race-free mkdir -p... " >&6; }
 if test -z "$MKDIR_P"; then
-  if ${ac_cv_path_mkdir+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+  if test ${ac_cv_path_mkdir+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
 for as_dir in $PATH$PATH_SEPARATOR/opt/sfw/bin
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_prog in mkdir gmkdir; do
 	 for ac_exec_ext in '' $ac_executable_extensions; do
-	   as_fn_executable_p "$as_dir/$ac_prog$ac_exec_ext" || continue
-	   case `"$as_dir/$ac_prog$ac_exec_ext" --version 2>&1` in #(
-	     'mkdir (GNU coreutils) '* | \
-	     'mkdir (coreutils) '* | \
+	   as_fn_executable_p "$as_dir$ac_prog$ac_exec_ext" || continue
+	   case `"$as_dir$ac_prog$ac_exec_ext" --version 2>&1` in #(
+	     'mkdir ('*'coreutils) '* | \
+	     'BusyBox '* | \
 	     'mkdir (fileutils) '4.1*)
-	       ac_cv_path_mkdir=$as_dir/$ac_prog$ac_exec_ext
+	       ac_cv_path_mkdir=$as_dir$ac_prog$ac_exec_ext
 	       break 3;;
 	   esac
 	 done
@@ -4805,7 +5755,7 @@ IFS=$as_save_IFS
 fi
 
   test -d ./--version && rmdir ./--version
-  if test "${ac_cv_path_mkdir+set}" = set; then
+  if test ${ac_cv_path_mkdir+y}; then
     MKDIR_P="$ac_cv_path_mkdir -p"
   else
     # As a last resort, use the slow shell script.  Don't cache a
@@ -4815,17 +5765,18 @@ fi
     MKDIR_P="$ac_install_sh -d"
   fi
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $MKDIR_P" >&5
-$as_echo "$MKDIR_P" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $MKDIR_P" >&5
+printf "%s\n" "$MKDIR_P" >&6; }
 
 if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}ranlib", so it can be a program name with args.
 set dummy ${ac_tool_prefix}ranlib; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_prog_RANLIB+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_prog_RANLIB+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   if test -n "$RANLIB"; then
   ac_cv_prog_RANLIB="$RANLIB" # Let the user override the test.
 else
@@ -4833,11 +5784,15 @@ as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
     ac_cv_prog_RANLIB="${ac_tool_prefix}ranlib"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -4848,11 +5803,11 @@ fi
 fi
 RANLIB=$ac_cv_prog_RANLIB
 if test -n "$RANLIB"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $RANLIB" >&5
-$as_echo "$RANLIB" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $RANLIB" >&5
+printf "%s\n" "$RANLIB" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -4861,11 +5816,12 @@ if test -z "$ac_cv_prog_RANLIB"; then
   ac_ct_RANLIB=$RANLIB
   # Extract the first word of "ranlib", so it can be a program name with args.
 set dummy ranlib; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_prog_ac_ct_RANLIB+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_prog_ac_ct_RANLIB+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   if test -n "$ac_ct_RANLIB"; then
   ac_cv_prog_ac_ct_RANLIB="$ac_ct_RANLIB" # Let the user override the test.
 else
@@ -4873,11 +5829,15 @@ as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
     ac_cv_prog_ac_ct_RANLIB="ranlib"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -4888,11 +5848,11 @@ fi
 fi
 ac_ct_RANLIB=$ac_cv_prog_ac_ct_RANLIB
 if test -n "$ac_ct_RANLIB"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_ct_RANLIB" >&5
-$as_echo "$ac_ct_RANLIB" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_ct_RANLIB" >&5
+printf "%s\n" "$ac_ct_RANLIB" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_ct_RANLIB" = x; then
@@ -4900,8 +5860,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     RANLIB=$ac_ct_RANLIB
@@ -4913,11 +5873,12 @@ fi
 if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}ar", so it can be a program name with args.
 set dummy ${ac_tool_prefix}ar; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_prog_AR+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_prog_AR+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   if test -n "$AR"; then
   ac_cv_prog_AR="$AR" # Let the user override the test.
 else
@@ -4925,11 +5886,15 @@ as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
     ac_cv_prog_AR="${ac_tool_prefix}ar"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -4940,11 +5905,11 @@ fi
 fi
 AR=$ac_cv_prog_AR
 if test -n "$AR"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $AR" >&5
-$as_echo "$AR" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $AR" >&5
+printf "%s\n" "$AR" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -4953,11 +5918,12 @@ if test -z "$ac_cv_prog_AR"; then
   ac_ct_AR=$AR
   # Extract the first word of "ar", so it can be a program name with args.
 set dummy ar; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_prog_ac_ct_AR+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_prog_ac_ct_AR+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   if test -n "$ac_ct_AR"; then
   ac_cv_prog_ac_ct_AR="$ac_ct_AR" # Let the user override the test.
 else
@@ -4965,11 +5931,15 @@ as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
     ac_cv_prog_ac_ct_AR="ar"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -4980,11 +5950,11 @@ fi
 fi
 ac_ct_AR=$ac_cv_prog_ac_ct_AR
 if test -n "$ac_ct_AR"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_ct_AR" >&5
-$as_echo "$ac_ct_AR" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_ct_AR" >&5
+printf "%s\n" "$ac_ct_AR" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_ct_AR" = x; then
@@ -4992,8 +5962,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     AR=$ac_ct_AR
@@ -5005,11 +5975,12 @@ fi
 if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}cflow", so it can be a program name with args.
 set dummy ${ac_tool_prefix}cflow; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_CFLOW_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_CFLOW_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $CFLOW_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_CFLOW_CMD="$CFLOW_CMD" # Let the user override the test with a path.
@@ -5019,11 +5990,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_CFLOW_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_CFLOW_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -5035,11 +6010,11 @@ esac
 fi
 CFLOW_CMD=$ac_cv_path_CFLOW_CMD
 if test -n "$CFLOW_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CFLOW_CMD" >&5
-$as_echo "$CFLOW_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CFLOW_CMD" >&5
+printf "%s\n" "$CFLOW_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -5048,11 +6023,12 @@ if test -z "$ac_cv_path_CFLOW_CMD"; then
   ac_pt_CFLOW_CMD=$CFLOW_CMD
   # Extract the first word of "cflow", so it can be a program name with args.
 set dummy cflow; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_ac_pt_CFLOW_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_ac_pt_CFLOW_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $ac_pt_CFLOW_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_ac_pt_CFLOW_CMD="$ac_pt_CFLOW_CMD" # Let the user override the test with a path.
@@ -5062,11 +6038,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_ac_pt_CFLOW_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_CFLOW_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -5078,11 +6058,11 @@ esac
 fi
 ac_pt_CFLOW_CMD=$ac_cv_path_ac_pt_CFLOW_CMD
 if test -n "$ac_pt_CFLOW_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_CFLOW_CMD" >&5
-$as_echo "$ac_pt_CFLOW_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_pt_CFLOW_CMD" >&5
+printf "%s\n" "$ac_pt_CFLOW_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_pt_CFLOW_CMD" = x; then
@@ -5090,8 +6070,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     CFLOW_CMD=$ac_pt_CFLOW_CMD
@@ -5103,11 +6083,12 @@ fi
 if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}cscope", so it can be a program name with args.
 set dummy ${ac_tool_prefix}cscope; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_CSCOPE_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_CSCOPE_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $CSCOPE_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_CSCOPE_CMD="$CSCOPE_CMD" # Let the user override the test with a path.
@@ -5117,11 +6098,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_CSCOPE_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_CSCOPE_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -5133,11 +6118,11 @@ esac
 fi
 CSCOPE_CMD=$ac_cv_path_CSCOPE_CMD
 if test -n "$CSCOPE_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CSCOPE_CMD" >&5
-$as_echo "$CSCOPE_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CSCOPE_CMD" >&5
+printf "%s\n" "$CSCOPE_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -5146,11 +6131,12 @@ if test -z "$ac_cv_path_CSCOPE_CMD"; then
   ac_pt_CSCOPE_CMD=$CSCOPE_CMD
   # Extract the first word of "cscope", so it can be a program name with args.
 set dummy cscope; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_ac_pt_CSCOPE_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_ac_pt_CSCOPE_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $ac_pt_CSCOPE_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_ac_pt_CSCOPE_CMD="$ac_pt_CSCOPE_CMD" # Let the user override the test with a path.
@@ -5160,11 +6146,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_ac_pt_CSCOPE_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_CSCOPE_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -5176,11 +6166,11 @@ esac
 fi
 ac_pt_CSCOPE_CMD=$ac_cv_path_ac_pt_CSCOPE_CMD
 if test -n "$ac_pt_CSCOPE_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_CSCOPE_CMD" >&5
-$as_echo "$ac_pt_CSCOPE_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_pt_CSCOPE_CMD" >&5
+printf "%s\n" "$ac_pt_CSCOPE_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_pt_CSCOPE_CMD" = x; then
@@ -5188,8 +6178,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     CSCOPE_CMD=$ac_pt_CSCOPE_CMD
@@ -5201,11 +6191,12 @@ fi
 if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}chmod", so it can be a program name with args.
 set dummy ${ac_tool_prefix}chmod; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_CHMOD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_CHMOD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $CHMOD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_CHMOD="$CHMOD" # Let the user override the test with a path.
@@ -5215,11 +6206,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_CHMOD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_CHMOD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -5231,11 +6226,11 @@ esac
 fi
 CHMOD=$ac_cv_path_CHMOD
 if test -n "$CHMOD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CHMOD" >&5
-$as_echo "$CHMOD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CHMOD" >&5
+printf "%s\n" "$CHMOD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -5244,11 +6239,12 @@ if test -z "$ac_cv_path_CHMOD"; then
   ac_pt_CHMOD=$CHMOD
   # Extract the first word of "chmod", so it can be a program name with args.
 set dummy chmod; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_ac_pt_CHMOD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_ac_pt_CHMOD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $ac_pt_CHMOD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_ac_pt_CHMOD="$ac_pt_CHMOD" # Let the user override the test with a path.
@@ -5258,11 +6254,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_ac_pt_CHMOD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_CHMOD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -5274,11 +6274,11 @@ esac
 fi
 ac_pt_CHMOD=$ac_cv_path_ac_pt_CHMOD
 if test -n "$ac_pt_CHMOD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_CHMOD" >&5
-$as_echo "$ac_pt_CHMOD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_pt_CHMOD" >&5
+printf "%s\n" "$ac_pt_CHMOD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_pt_CHMOD" = x; then
@@ -5286,8 +6286,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     CHMOD=$ac_pt_CHMOD
@@ -5299,11 +6299,12 @@ fi
 if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}wc", so it can be a program name with args.
 set dummy ${ac_tool_prefix}wc; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_WC+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_WC+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $WC in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_WC="$WC" # Let the user override the test with a path.
@@ -5313,11 +6314,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_WC="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_WC="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -5329,11 +6334,11 @@ esac
 fi
 WC=$ac_cv_path_WC
 if test -n "$WC"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $WC" >&5
-$as_echo "$WC" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $WC" >&5
+printf "%s\n" "$WC" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -5342,11 +6347,12 @@ if test -z "$ac_cv_path_WC"; then
   ac_pt_WC=$WC
   # Extract the first word of "wc", so it can be a program name with args.
 set dummy wc; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_ac_pt_WC+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_ac_pt_WC+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $ac_pt_WC in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_ac_pt_WC="$ac_pt_WC" # Let the user override the test with a path.
@@ -5356,11 +6362,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_ac_pt_WC="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_WC="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -5372,11 +6382,11 @@ esac
 fi
 ac_pt_WC=$ac_cv_path_ac_pt_WC
 if test -n "$ac_pt_WC"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_WC" >&5
-$as_echo "$ac_pt_WC" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_pt_WC" >&5
+printf "%s\n" "$ac_pt_WC" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_pt_WC" = x; then
@@ -5384,8 +6394,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     WC=$ac_pt_WC
@@ -5397,11 +6407,12 @@ fi
 if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}sort", so it can be a program name with args.
 set dummy ${ac_tool_prefix}sort; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_SORT+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_SORT+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $SORT in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_SORT="$SORT" # Let the user override the test with a path.
@@ -5411,11 +6422,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_SORT="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_SORT="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -5427,11 +6442,11 @@ esac
 fi
 SORT=$ac_cv_path_SORT
 if test -n "$SORT"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $SORT" >&5
-$as_echo "$SORT" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $SORT" >&5
+printf "%s\n" "$SORT" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -5440,11 +6455,12 @@ if test -z "$ac_cv_path_SORT"; then
   ac_pt_SORT=$SORT
   # Extract the first word of "sort", so it can be a program name with args.
 set dummy sort; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_ac_pt_SORT+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_ac_pt_SORT+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $ac_pt_SORT in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_ac_pt_SORT="$ac_pt_SORT" # Let the user override the test with a path.
@@ -5454,11 +6470,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_ac_pt_SORT="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_SORT="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -5470,11 +6490,11 @@ esac
 fi
 ac_pt_SORT=$ac_cv_path_ac_pt_SORT
 if test -n "$ac_pt_SORT"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_SORT" >&5
-$as_echo "$ac_pt_SORT" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_pt_SORT" >&5
+printf "%s\n" "$ac_pt_SORT" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_pt_SORT" = x; then
@@ -5482,8 +6502,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     SORT=$ac_pt_SORT
@@ -5496,19 +6516,20 @@ fi
 ################################################################################
 ac_header_dirent=no
 for ac_hdr in dirent.h sys/ndir.h sys/dir.h ndir.h; do
-  as_ac_Header=`$as_echo "ac_cv_header_dirent_$ac_hdr" | $as_tr_sh`
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_hdr that defines DIR" >&5
-$as_echo_n "checking for $ac_hdr that defines DIR... " >&6; }
-if eval \${$as_ac_Header+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+  as_ac_Header=`printf "%s\n" "ac_cv_header_dirent_$ac_hdr" | $as_tr_sh`
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_hdr that defines DIR" >&5
+printf %s "checking for $ac_hdr that defines DIR... " >&6; }
+if eval test \${$as_ac_Header+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 #include <sys/types.h>
 #include <$ac_hdr>
 
 int
-main ()
+main (void)
 {
 if ((DIR *) 0)
 return 0;
@@ -5516,19 +6537,21 @@ return 0;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   eval "$as_ac_Header=yes"
-else
+else $as_nop
   eval "$as_ac_Header=no"
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
 eval ac_res=\$$as_ac_Header
-	       { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
-$as_echo "$ac_res" >&6; }
-if eval test \"x\$"$as_ac_Header"\" = x"yes"; then :
+	       { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
+printf "%s\n" "$ac_res" >&6; }
+if eval test \"x\$"$as_ac_Header"\" = x"yes"
+then :
   cat >>confdefs.h <<_ACEOF
-#define `$as_echo "HAVE_$ac_hdr" | $as_tr_cpp` 1
+#define `printf "%s\n" "HAVE_$ac_hdr" | $as_tr_cpp` 1
 _ACEOF
 
 ac_header_dirent=$ac_hdr; break
@@ -5537,68 +6560,12 @@ fi
 done
 # Two versions of opendir et al. are in -ldir and -lx on SCO Xenix.
 if test $ac_header_dirent = dirent.h; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for library containing opendir" >&5
-$as_echo_n "checking for library containing opendir... " >&6; }
-if ${ac_cv_search_opendir+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  ac_func_search_save_LIBS=$LIBS
-cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-
-/* Override any GCC internal prototype to avoid an error.
-   Use char because int might match the return type of a GCC
-   builtin and then its argument prototype would still apply.  */
-#ifdef __cplusplus
-extern "C"
-#endif
-char opendir ();
-int
-main ()
-{
-return opendir ();
-  ;
-  return 0;
-}
-_ACEOF
-for ac_lib in '' dir; do
-  if test -z "$ac_lib"; then
-    ac_res="none required"
-  else
-    ac_res=-l$ac_lib
-    LIBS="-l$ac_lib  $ac_func_search_save_LIBS"
-  fi
-  if ac_fn_c_try_link "$LINENO"; then :
-  ac_cv_search_opendir=$ac_res
-fi
-rm -f core conftest.err conftest.$ac_objext \
-    conftest$ac_exeext
-  if ${ac_cv_search_opendir+:} false; then :
-  break
-fi
-done
-if ${ac_cv_search_opendir+:} false; then :
-
-else
-  ac_cv_search_opendir=no
-fi
-rm conftest.$ac_ext
-LIBS=$ac_func_search_save_LIBS
-fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_search_opendir" >&5
-$as_echo "$ac_cv_search_opendir" >&6; }
-ac_res=$ac_cv_search_opendir
-if test "$ac_res" != no; then :
-  test "$ac_res" = "none required" || LIBS="$ac_res $LIBS"
-
-fi
-
-else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for library containing opendir" >&5
-$as_echo_n "checking for library containing opendir... " >&6; }
-if ${ac_cv_search_opendir+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for library containing opendir" >&5
+printf %s "checking for library containing opendir... " >&6; }
+if test ${ac_cv_search_opendir+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   ac_func_search_save_LIBS=$LIBS
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
@@ -5606,441 +6573,388 @@ cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* Override any GCC internal prototype to avoid an error.
    Use char because int might match the return type of a GCC
    builtin and then its argument prototype would still apply.  */
-#ifdef __cplusplus
-extern "C"
-#endif
 char opendir ();
 int
-main ()
+main (void)
 {
 return opendir ();
   ;
   return 0;
 }
 _ACEOF
-for ac_lib in '' x; do
+for ac_lib in '' dir
+do
   if test -z "$ac_lib"; then
     ac_res="none required"
   else
     ac_res=-l$ac_lib
     LIBS="-l$ac_lib  $ac_func_search_save_LIBS"
   fi
-  if ac_fn_c_try_link "$LINENO"; then :
+  if ac_fn_c_try_link "$LINENO"
+then :
   ac_cv_search_opendir=$ac_res
 fi
-rm -f core conftest.err conftest.$ac_objext \
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
     conftest$ac_exeext
-  if ${ac_cv_search_opendir+:} false; then :
+  if test ${ac_cv_search_opendir+y}
+then :
   break
 fi
 done
-if ${ac_cv_search_opendir+:} false; then :
+if test ${ac_cv_search_opendir+y}
+then :
 
-else
+else $as_nop
   ac_cv_search_opendir=no
 fi
-rm conftest.$ac_ext
-LIBS=$ac_func_search_save_LIBS
-fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_search_opendir" >&5
-$as_echo "$ac_cv_search_opendir" >&6; }
-ac_res=$ac_cv_search_opendir
-if test "$ac_res" != no; then :
-  test "$ac_res" = "none required" || LIBS="$ac_res $LIBS"
-
-fi
-
-fi
-
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for ANSI C header files" >&5
-$as_echo_n "checking for ANSI C header files... " >&6; }
-if ${ac_cv_header_stdc+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <stdlib.h>
-#include <stdarg.h>
-#include <string.h>
-#include <float.h>
-
-int
-main ()
-{
-
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
-  ac_cv_header_stdc=yes
-else
-  ac_cv_header_stdc=no
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
-
-if test $ac_cv_header_stdc = yes; then
-  # SunOS 4.x string.h does not declare mem*, contrary to ANSI.
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <string.h>
-
-_ACEOF
-if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
-  $EGREP "memchr" >/dev/null 2>&1; then :
-
-else
-  ac_cv_header_stdc=no
-fi
-rm -f conftest*
-
-fi
-
-if test $ac_cv_header_stdc = yes; then
-  # ISC 2.0.2 stdlib.h does not declare free, contrary to ANSI.
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <stdlib.h>
-
-_ACEOF
-if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
-  $EGREP "free" >/dev/null 2>&1; then :
-
-else
-  ac_cv_header_stdc=no
+rm conftest.$ac_ext
+LIBS=$ac_func_search_save_LIBS
 fi
-rm -f conftest*
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_search_opendir" >&5
+printf "%s\n" "$ac_cv_search_opendir" >&6; }
+ac_res=$ac_cv_search_opendir
+if test "$ac_res" != no
+then :
+  test "$ac_res" = "none required" || LIBS="$ac_res $LIBS"
 
 fi
 
-if test $ac_cv_header_stdc = yes; then
-  # /bin/cc in Irix-4.0.5 gets non-ANSI ctype macros unless using -ansi.
-  if test "$cross_compiling" = yes; then :
-  :
 else
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for library containing opendir" >&5
+printf %s "checking for library containing opendir... " >&6; }
+if test ${ac_cv_search_opendir+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  ac_func_search_save_LIBS=$LIBS
+cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#include <ctype.h>
-#include <stdlib.h>
-#if ((' ' & 0x0FF) == 0x020)
-# define ISLOWER(c) ('a' <= (c) && (c) <= 'z')
-# define TOUPPER(c) (ISLOWER(c) ? 'A' + ((c) - 'a') : (c))
-#else
-# define ISLOWER(c) \
-		   (('a' <= (c) && (c) <= 'i') \
-		     || ('j' <= (c) && (c) <= 'r') \
-		     || ('s' <= (c) && (c) <= 'z'))
-# define TOUPPER(c) (ISLOWER(c) ? ((c) | 0x40) : (c))
-#endif
 
-#define XOR(e, f) (((e) && !(f)) || (!(e) && (f)))
+/* Override any GCC internal prototype to avoid an error.
+   Use char because int might match the return type of a GCC
+   builtin and then its argument prototype would still apply.  */
+char opendir ();
 int
-main ()
+main (void)
 {
-  int i;
-  for (i = 0; i < 256; i++)
-    if (XOR (islower (i), ISLOWER (i))
-	|| toupper (i) != TOUPPER (i))
-      return 2;
+return opendir ();
+  ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_run "$LINENO"; then :
-
-else
-  ac_cv_header_stdc=no
+for ac_lib in '' x
+do
+  if test -z "$ac_lib"; then
+    ac_res="none required"
+  else
+    ac_res=-l$ac_lib
+    LIBS="-l$ac_lib  $ac_func_search_save_LIBS"
+  fi
+  if ac_fn_c_try_link "$LINENO"
+then :
+  ac_cv_search_opendir=$ac_res
 fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
+    conftest$ac_exeext
+  if test ${ac_cv_search_opendir+y}
+then :
+  break
 fi
+done
+if test ${ac_cv_search_opendir+y}
+then :
 
+else $as_nop
+  ac_cv_search_opendir=no
 fi
+rm conftest.$ac_ext
+LIBS=$ac_func_search_save_LIBS
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_header_stdc" >&5
-$as_echo "$ac_cv_header_stdc" >&6; }
-if test $ac_cv_header_stdc = yes; then
-
-$as_echo "#define STDC_HEADERS 1" >>confdefs.h
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_search_opendir" >&5
+printf "%s\n" "$ac_cv_search_opendir" >&6; }
+ac_res=$ac_cv_search_opendir
+if test "$ac_res" != no
+then :
+  test "$ac_res" = "none required" || LIBS="$ac_res $LIBS"
 
 fi
 
-# On IRIX 5.3, sys/types and inttypes.h are conflicting.
-for ac_header in sys/types.h sys/stat.h stdlib.h string.h memory.h strings.h \
-		  inttypes.h stdint.h unistd.h
-do :
-  as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
-ac_fn_c_check_header_compile "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default
-"
-if eval test \"x\$"$as_ac_Header"\" = x"yes"; then :
-  cat >>confdefs.h <<_ACEOF
-#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
-_ACEOF
-
 fi
 
+ac_header= ac_cache=
+for ac_item in $ac_header_c_list
+do
+  if test $ac_cache; then
+    ac_fn_c_check_header_compile "$LINENO" $ac_header ac_cv_header_$ac_cache "$ac_includes_default"
+    if eval test \"x\$ac_cv_header_$ac_cache\" = xyes; then
+      printf "%s\n" "#define $ac_item 1" >> confdefs.h
+    fi
+    ac_header= ac_cache=
+  elif test $ac_header; then
+    ac_cache=$ac_item
+  else
+    ac_header=$ac_item
+  fi
 done
 
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether sys/types.h defines makedev" >&5
-$as_echo_n "checking whether sys/types.h defines makedev... " >&6; }
-if ${ac_cv_header_sys_types_h_makedev+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <sys/types.h>
-int
-main ()
-{
-return makedev(0, 0);
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
-  ac_cv_header_sys_types_h_makedev=yes
-else
-  ac_cv_header_sys_types_h_makedev=no
-fi
-rm -f core conftest.err conftest.$ac_objext \
-    conftest$ac_exeext conftest.$ac_ext
 
-fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_header_sys_types_h_makedev" >&5
-$as_echo "$ac_cv_header_sys_types_h_makedev" >&6; }
 
-if test $ac_cv_header_sys_types_h_makedev = no; then
-ac_fn_c_check_header_mongrel "$LINENO" "sys/mkdev.h" "ac_cv_header_sys_mkdev_h" "$ac_includes_default"
-if test "x$ac_cv_header_sys_mkdev_h" = xyes; then :
 
-$as_echo "#define MAJOR_IN_MKDEV 1" >>confdefs.h
+
+
+
+if test $ac_cv_header_stdlib_h = yes && test $ac_cv_header_string_h = yes
+then :
+
+printf "%s\n" "#define STDC_HEADERS 1" >>confdefs.h
 
 fi
 
+ac_fn_c_check_header_compile "$LINENO" "sys/mkdev.h" "ac_cv_header_sys_mkdev_h" "$ac_includes_default"
+if test "x$ac_cv_header_sys_mkdev_h" = xyes
+then :
 
+printf "%s\n" "#define MAJOR_IN_MKDEV 1" >>confdefs.h
 
-  if test $ac_cv_header_sys_mkdev_h = no; then
-    ac_fn_c_check_header_mongrel "$LINENO" "sys/sysmacros.h" "ac_cv_header_sys_sysmacros_h" "$ac_includes_default"
-if test "x$ac_cv_header_sys_sysmacros_h" = xyes; then :
+fi
+
+if test $ac_cv_header_sys_mkdev_h = no; then
+  ac_fn_c_check_header_compile "$LINENO" "sys/sysmacros.h" "ac_cv_header_sys_sysmacros_h" "$ac_includes_default"
+if test "x$ac_cv_header_sys_sysmacros_h" = xyes
+then :
 
-$as_echo "#define MAJOR_IN_SYSMACROS 1" >>confdefs.h
+printf "%s\n" "#define MAJOR_IN_SYSMACROS 1" >>confdefs.h
 
 fi
 
+fi
+
+ac_fn_c_check_type "$LINENO" "_Bool" "ac_cv_type__Bool" "$ac_includes_default"
+if test "x$ac_cv_type__Bool" = xyes
+then :
+
+printf "%s\n" "#define HAVE__BOOL 1" >>confdefs.h
+
 
-  fi
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for stdbool.h that conforms to C99" >&5
-$as_echo_n "checking for stdbool.h that conforms to C99... " >&6; }
-if ${ac_cv_header_stdbool_h+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+   { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for stdbool.h that conforms to C99" >&5
+printf %s "checking for stdbool.h that conforms to C99... " >&6; }
+if test ${ac_cv_header_stdbool_h+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
+#include <stdbool.h>
 
-             #include <stdbool.h>
-             #ifndef bool
-              "error: bool is not defined"
-             #endif
-             #ifndef false
-              "error: false is not defined"
-             #endif
-             #if false
-              "error: false is not 0"
+             #ifndef __bool_true_false_are_defined
+               #error "__bool_true_false_are_defined is not defined"
              #endif
-             #ifndef true
-              "error: true is not defined"
+             char a[__bool_true_false_are_defined == 1 ? 1 : -1];
+
+             /* Regardless of whether this is C++ or "_Bool" is a
+                valid type name, "true" and "false" should be usable
+                in #if expressions and integer constant expressions,
+                and "bool" should be a valid type name.  */
+
+             #if !true
+               #error "'true' is not true"
              #endif
              #if true != 1
-              "error: true is not 1"
+               #error "'true' is not equal to 1"
              #endif
-             #ifndef __bool_true_false_are_defined
-              "error: __bool_true_false_are_defined is not defined"
+             char b[true == 1 ? 1 : -1];
+             char c[true];
+
+             #if false
+               #error "'false' is not false"
+             #endif
+             #if false != 0
+               #error "'false' is not equal to 0"
              #endif
+             char d[false == 0 ? 1 : -1];
+
+             enum { e = false, f = true, g = false * true, h = true * 256 };
+
+             char i[(bool) 0.5 == true ? 1 : -1];
+             char j[(bool) 0.0 == false ? 1 : -1];
+             char k[sizeof (bool) > 0 ? 1 : -1];
+
+             struct sb { bool s: 1; bool t; } s;
+             char l[sizeof s.t > 0 ? 1 : -1];
 
-             struct s { _Bool s: 1; _Bool t; } s;
-
-             char a[true == 1 ? 1 : -1];
-             char b[false == 0 ? 1 : -1];
-             char c[__bool_true_false_are_defined == 1 ? 1 : -1];
-             char d[(bool) 0.5 == true ? 1 : -1];
-             /* See body of main program for 'e'.  */
-             char f[(_Bool) 0.0 == false ? 1 : -1];
-             char g[true];
-             char h[sizeof (_Bool)];
-             char i[sizeof s.t];
-             enum { j = false, k = true, l = false * true, m = true * 256 };
              /* The following fails for
                 HP aC++/ANSI C B3910B A.05.55 [Dec 04 2003]. */
-             _Bool n[m];
-             char o[sizeof n == m * sizeof n[0] ? 1 : -1];
-             char p[-1 - (_Bool) 0 < 0 && -1 - (bool) 0 < 0 ? 1 : -1];
+             bool m[h];
+             char n[sizeof m == h * sizeof m[0] ? 1 : -1];
+             char o[-1 - (bool) 0 < 0 ? 1 : -1];
              /* Catch a bug in an HP-UX C compiler.  See
-                http://gcc.gnu.org/ml/gcc-patches/2003-12/msg02303.html
-                http://lists.gnu.org/archive/html/bug-coreutils/2005-11/msg00161.html
+         https://gcc.gnu.org/ml/gcc-patches/2003-12/msg02303.html
+         https://lists.gnu.org/archive/html/bug-coreutils/2005-11/msg00161.html
               */
-             _Bool q = true;
-             _Bool *pq = &q;
+             bool p = true;
+             bool *pp = &p;
+
+             /* C 1999 specifies that bool, true, and false are to be
+                macros, but C++ 2011 and later overrule this.  */
+             #if __cplusplus < 201103
+              #ifndef bool
+               #error "bool is not defined"
+              #endif
+              #ifndef false
+               #error "false is not defined"
+              #endif
+              #ifndef true
+               #error "true is not defined"
+              #endif
+             #endif
+
+             /* If _Bool is available, repeat with it all the tests
+                above that used bool.  */
+             #ifdef HAVE__BOOL
+               struct sB { _Bool s: 1; _Bool t; } t;
+
+               char q[(_Bool) 0.5 == true ? 1 : -1];
+               char r[(_Bool) 0.0 == false ? 1 : -1];
+               char u[sizeof (_Bool) > 0 ? 1 : -1];
+               char v[sizeof t.t > 0 ? 1 : -1];
+
+               _Bool w[h];
+               char x[sizeof m == h * sizeof m[0] ? 1 : -1];
+               char y[-1 - (_Bool) 0 < 0 ? 1 : -1];
+               _Bool z = true;
+               _Bool *pz = &p;
+             #endif
 
 int
-main ()
+main (void)
 {
 
-             bool e = &s;
-             *pq |= q;
-             *pq |= ! q;
-             /* Refer to every declared value, to avoid compiler optimizations.  */
-             return (!a + !b + !c + !d + !e + !f + !g + !h + !i + !!j + !k + !!l
-                     + !m + !n + !o + !p + !q + !pq);
+             bool ps = &s;
+             *pp |= p;
+             *pp |= ! p;
+
+             #ifdef HAVE__BOOL
+               _Bool pt = &t;
+               *pz |= z;
+               *pz |= ! z;
+             #endif
+
+             /* Refer to every declared value, so they cannot be
+                discarded as unused.  */
+             return (!a + !b + !c + !d + !e + !f + !g + !h + !i + !j + !k
+                     + !l + !m + !n + !o + !p + !pp + !ps
+             #ifdef HAVE__BOOL
+                     + !q + !r + !u + !v + !w + !x + !y + !z + !pt
+             #endif
+                    );
 
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   ac_cv_header_stdbool_h=yes
-else
+else $as_nop
   ac_cv_header_stdbool_h=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
-fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_header_stdbool_h" >&5
-$as_echo "$ac_cv_header_stdbool_h" >&6; }
-   ac_fn_c_check_type "$LINENO" "_Bool" "ac_cv_type__Bool" "$ac_includes_default"
-if test "x$ac_cv_type__Bool" = xyes; then :
-
-cat >>confdefs.h <<_ACEOF
-#define HAVE__BOOL 1
-_ACEOF
-
-
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_header_stdbool_h" >&5
+printf "%s\n" "$ac_cv_header_stdbool_h" >&6; }
 
 if test $ac_cv_header_stdbool_h = yes; then
 
-$as_echo "#define HAVE_STDBOOL_H 1" >>confdefs.h
-
-fi
-
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for ANSI C header files" >&5
-$as_echo_n "checking for ANSI C header files... " >&6; }
-if ${ac_cv_header_stdc+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <stdlib.h>
-#include <stdarg.h>
-#include <string.h>
-#include <float.h>
-
-int
-main ()
-{
-
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
-  ac_cv_header_stdc=yes
-else
-  ac_cv_header_stdc=no
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
-
-if test $ac_cv_header_stdc = yes; then
-  # SunOS 4.x string.h does not declare mem*, contrary to ANSI.
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <string.h>
-
-_ACEOF
-if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
-  $EGREP "memchr" >/dev/null 2>&1; then :
-
-else
-  ac_cv_header_stdc=no
-fi
-rm -f conftest*
-
-fi
-
-if test $ac_cv_header_stdc = yes; then
-  # ISC 2.0.2 stdlib.h does not declare free, contrary to ANSI.
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <stdlib.h>
-
-_ACEOF
-if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
-  $EGREP "free" >/dev/null 2>&1; then :
-
-else
-  ac_cv_header_stdc=no
-fi
-rm -f conftest*
+printf "%s\n" "#define HAVE_STDBOOL_H 1" >>confdefs.h
 
 fi
 
-if test $ac_cv_header_stdc = yes; then
-  # /bin/cc in Irix-4.0.5 gets non-ANSI ctype macros unless using -ansi.
-  if test "$cross_compiling" = yes; then :
-  :
-else
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <ctype.h>
-#include <stdlib.h>
-#if ((' ' & 0x0FF) == 0x020)
-# define ISLOWER(c) ('a' <= (c) && (c) <= 'z')
-# define TOUPPER(c) (ISLOWER(c) ? 'A' + ((c) - 'a') : (c))
-#else
-# define ISLOWER(c) \
-		   (('a' <= (c) && (c) <= 'i') \
-		     || ('j' <= (c) && (c) <= 'r') \
-		     || ('s' <= (c) && (c) <= 'z'))
-# define TOUPPER(c) (ISLOWER(c) ? ((c) | 0x40) : (c))
-#endif
+# Autoupdate added the next two lines to ensure that your configure
+# script's behavior did not change.  They are probably safe to remove.
 
-#define XOR(e, f) (((e) && !(f)) || (!(e) && (f)))
-int
-main ()
-{
-  int i;
-  for (i = 0; i < 256; i++)
-    if (XOR (islower (i), ISLOWER (i))
-	|| toupper (i) != TOUPPER (i))
-      return 2;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_run "$LINENO"; then :
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for egrep" >&5
+printf %s "checking for egrep... " >&6; }
+if test ${ac_cv_path_EGREP+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if echo a | $GREP -E '(a|b)' >/dev/null 2>&1
+   then ac_cv_path_EGREP="$GREP -E"
+   else
+     if test -z "$EGREP"; then
+  ac_path_EGREP_found=false
+  # Loop through the user's path and test for each of PROGNAME-LIST
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH$PATH_SEPARATOR/usr/xpg4/bin
+do
+  IFS=$as_save_IFS
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
+    for ac_prog in egrep
+   do
+    for ac_exec_ext in '' $ac_executable_extensions; do
+      ac_path_EGREP="$as_dir$ac_prog$ac_exec_ext"
+      as_fn_executable_p "$ac_path_EGREP" || continue
+# Check for GNU ac_path_EGREP and select it if it is found.
+  # Check for GNU $ac_path_EGREP
+case `"$ac_path_EGREP" --version 2>&1` in
+*GNU*)
+  ac_cv_path_EGREP="$ac_path_EGREP" ac_path_EGREP_found=:;;
+*)
+  ac_count=0
+  printf %s 0123456789 >"conftest.in"
+  while :
+  do
+    cat "conftest.in" "conftest.in" >"conftest.tmp"
+    mv "conftest.tmp" "conftest.in"
+    cp "conftest.in" "conftest.nl"
+    printf "%s\n" 'EGREP' >> "conftest.nl"
+    "$ac_path_EGREP" 'EGREP$' < "conftest.nl" >"conftest.out" 2>/dev/null || break
+    diff "conftest.out" "conftest.nl" >/dev/null 2>&1 || break
+    as_fn_arith $ac_count + 1 && ac_count=$as_val
+    if test $ac_count -gt ${ac_path_EGREP_max-0}; then
+      # Best one so far, save it but keep looking for a better one
+      ac_cv_path_EGREP="$ac_path_EGREP"
+      ac_path_EGREP_max=$ac_count
+    fi
+    # 10*(2^10) chars as input seems more than enough
+    test $ac_count -gt 10 && break
+  done
+  rm -f conftest.in conftest.tmp conftest.nl conftest.out;;
+esac
 
+      $ac_path_EGREP_found && break 3
+    done
+  done
+  done
+IFS=$as_save_IFS
+  if test -z "$ac_cv_path_EGREP"; then
+    as_fn_error $? "no acceptable egrep could be found in $PATH$PATH_SEPARATOR/usr/xpg4/bin" "$LINENO" 5
+  fi
 else
-  ac_cv_header_stdc=no
-fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
+  ac_cv_path_EGREP=$EGREP
 fi
 
+   fi
 fi
-fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_header_stdc" >&5
-$as_echo "$ac_cv_header_stdc" >&6; }
-if test $ac_cv_header_stdc = yes; then
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_path_EGREP" >&5
+printf "%s\n" "$ac_cv_path_EGREP" >&6; }
+ EGREP="$ac_cv_path_EGREP"
 
-$as_echo "#define STDC_HEADERS 1" >>confdefs.h
 
-fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for sys/wait.h that is POSIX.1 compatible" >&5
-$as_echo_n "checking for sys/wait.h that is POSIX.1 compatible... " >&6; }
-if ${ac_cv_header_sys_wait_h+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for sys/wait.h that is POSIX.1 compatible" >&5
+printf %s "checking for sys/wait.h that is POSIX.1 compatible... " >&6; }
+if test ${ac_cv_header_sys_wait_h+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 #include <sys/types.h>
@@ -6053,7 +6967,7 @@ else
 #endif
 
 int
-main ()
+main (void)
 {
   int s;
   wait (&s);
@@ -6062,151 +6976,145 @@ main ()
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   ac_cv_header_sys_wait_h=yes
-else
+else $as_nop
   ac_cv_header_sys_wait_h=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_header_sys_wait_h" >&5
-$as_echo "$ac_cv_header_sys_wait_h" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_header_sys_wait_h" >&5
+printf "%s\n" "$ac_cv_header_sys_wait_h" >&6; }
 if test $ac_cv_header_sys_wait_h = yes; then
 
-$as_echo "#define HAVE_SYS_WAIT_H 1" >>confdefs.h
+printf "%s\n" "#define HAVE_SYS_WAIT_H 1" >>confdefs.h
 
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether time.h and sys/time.h may both be included" >&5
-$as_echo_n "checking whether time.h and sys/time.h may both be included... " >&6; }
-if ${ac_cv_header_time+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <sys/types.h>
-#include <sys/time.h>
-#include <time.h>
 
-int
-main ()
-{
-if ((struct tm *) 0)
-return 0;
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
-  ac_cv_header_time=yes
-else
-  ac_cv_header_time=no
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
-fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_header_time" >&5
-$as_echo "$ac_cv_header_time" >&6; }
-if test $ac_cv_header_time = yes; then
 
-$as_echo "#define TIME_WITH_SYS_TIME 1" >>confdefs.h
+# Obsolete code to be removed.
+if test $ac_cv_header_sys_time_h = yes; then
+
+printf "%s\n" "#define TIME_WITH_SYS_TIME 1" >>confdefs.h
 
 fi
+# End of obsolete code.
 
 
-for ac_header in assert.h ctype.h dirent.h errno.h fcntl.h float.h \
-  getopt.h inttypes.h langinfo.h libgen.h limits.h locale.h paths.h \
-  signal.h stdarg.h stddef.h stdio.h stdlib.h string.h sys/file.h \
-  sys/ioctl.h syslog.h sys/mman.h sys/param.h sys/resource.h sys/stat.h \
-  sys/time.h sys/types.h sys/utsname.h sys/wait.h time.h \
-  unistd.h
+       for ac_header in assert.h ctype.h dirent.h errno.h fcntl.h float.h getopt.h inttypes.h langinfo.h libgen.h limits.h locale.h paths.h signal.h stdarg.h stddef.h stdio.h stdlib.h string.h sys/file.h sys/ioctl.h syslog.h sys/mman.h sys/param.h sys/resource.h sys/stat.h sys/time.h sys/types.h sys/utsname.h sys/wait.h time.h unistd.h
 do :
-  as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
-ac_fn_c_check_header_mongrel "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
-if eval test \"x\$"$as_ac_Header"\" = x"yes"; then :
+  as_ac_Header=`printf "%s\n" "ac_cv_header_$ac_header" | $as_tr_sh`
+ac_fn_c_check_header_compile "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
+if eval test \"x\$"$as_ac_Header"\" = x"yes"
+then :
   cat >>confdefs.h <<_ACEOF
-#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
+#define `printf "%s\n" "HAVE_$ac_header" | $as_tr_cpp` 1
 _ACEOF
 
-else
+else $as_nop
   as_fn_error $? "bailing out" "$LINENO" 5
 fi
 
 done
 
+ac_fn_c_check_header_compile "$LINENO" "termios.h" "ac_cv_header_termios_h" "$ac_includes_default"
+if test "x$ac_cv_header_termios_h" = xyes
+then :
+  printf "%s\n" "#define HAVE_TERMIOS_H 1" >>confdefs.h
 
-for ac_header in termios.h sys/statvfs.h sys/timerfd.h sys/vfs.h linux/magic.h linux/fiemap.h
-do :
-  as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
-ac_fn_c_check_header_mongrel "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
-if eval test \"x\$"$as_ac_Header"\" = x"yes"; then :
-  cat >>confdefs.h <<_ACEOF
-#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
-_ACEOF
+fi
+ac_fn_c_check_header_compile "$LINENO" "sys/statvfs.h" "ac_cv_header_sys_statvfs_h" "$ac_includes_default"
+if test "x$ac_cv_header_sys_statvfs_h" = xyes
+then :
+  printf "%s\n" "#define HAVE_SYS_STATVFS_H 1" >>confdefs.h
 
 fi
+ac_fn_c_check_header_compile "$LINENO" "sys/timerfd.h" "ac_cv_header_sys_timerfd_h" "$ac_includes_default"
+if test "x$ac_cv_header_sys_timerfd_h" = xyes
+then :
+  printf "%s\n" "#define HAVE_SYS_TIMERFD_H 1" >>confdefs.h
 
-done
+fi
+ac_fn_c_check_header_compile "$LINENO" "sys/vfs.h" "ac_cv_header_sys_vfs_h" "$ac_includes_default"
+if test "x$ac_cv_header_sys_vfs_h" = xyes
+then :
+  printf "%s\n" "#define HAVE_SYS_VFS_H 1" >>confdefs.h
+
+fi
+ac_fn_c_check_header_compile "$LINENO" "linux/magic.h" "ac_cv_header_linux_magic_h" "$ac_includes_default"
+if test "x$ac_cv_header_linux_magic_h" = xyes
+then :
+  printf "%s\n" "#define HAVE_LINUX_MAGIC_H 1" >>confdefs.h
+
+fi
+ac_fn_c_check_header_compile "$LINENO" "linux/fiemap.h" "ac_cv_header_linux_fiemap_h" "$ac_includes_default"
+if test "x$ac_cv_header_linux_fiemap_h" = xyes
+then :
+  printf "%s\n" "#define HAVE_LINUX_FIEMAP_H 1" >>confdefs.h
+
+fi
 
-for ac_header in libaio.h
+       for ac_header in libaio.h
 do :
-  ac_fn_c_check_header_mongrel "$LINENO" "libaio.h" "ac_cv_header_libaio_h" "$ac_includes_default"
-if test "x$ac_cv_header_libaio_h" = xyes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_LIBAIO_H 1
-_ACEOF
+  ac_fn_c_check_header_compile "$LINENO" "libaio.h" "ac_cv_header_libaio_h" "$ac_includes_default"
+if test "x$ac_cv_header_libaio_h" = xyes
+then :
+  printf "%s\n" "#define HAVE_LIBAIO_H 1" >>confdefs.h
  LVM_NEEDS_LIBAIO_WARN=
-else
+else $as_nop
   LVM_NEEDS_LIBAIO_WARN=y
 fi
 
 done
-
 case "$host_os" in
 	linux*)
-		for ac_header in asm/byteorder.h linux/fs.h malloc.h
+		       for ac_header in asm/byteorder.h linux/fs.h malloc.h
 do :
-  as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
-ac_fn_c_check_header_mongrel "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
-if eval test \"x\$"$as_ac_Header"\" = x"yes"; then :
+  as_ac_Header=`printf "%s\n" "ac_cv_header_$ac_header" | $as_tr_sh`
+ac_fn_c_check_header_compile "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
+if eval test \"x\$"$as_ac_Header"\" = x"yes"
+then :
   cat >>confdefs.h <<_ACEOF
-#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
+#define `printf "%s\n" "HAVE_$ac_header" | $as_tr_cpp` 1
 _ACEOF
 
-else
+else $as_nop
   as_fn_error $? "bailing out" "$LINENO" 5
 fi
 
-done
- ;;
+done ;;
 	darwin*)
-		for ac_header in machine/endian.h sys/disk.h
+		       for ac_header in machine/endian.h sys/disk.h
 do :
-  as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
-ac_fn_c_check_header_mongrel "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
-if eval test \"x\$"$as_ac_Header"\" = x"yes"; then :
+  as_ac_Header=`printf "%s\n" "ac_cv_header_$ac_header" | $as_tr_sh`
+ac_fn_c_check_header_compile "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
+if eval test \"x\$"$as_ac_Header"\" = x"yes"
+then :
   cat >>confdefs.h <<_ACEOF
-#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
+#define `printf "%s\n" "HAVE_$ac_header" | $as_tr_cpp` 1
 _ACEOF
 
-else
+else $as_nop
   as_fn_error $? "bailing out" "$LINENO" 5
 fi
 
-done
- ;;
+done ;;
 esac
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for an ANSI C-conforming const" >&5
-$as_echo_n "checking for an ANSI C-conforming const... " >&6; }
-if ${ac_cv_c_const+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for an ANSI C-conforming const" >&5
+printf %s "checking for an ANSI C-conforming const... " >&6; }
+if test ${ac_cv_c_const+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
 int
-main ()
+main (void)
 {
 
 #ifndef __cplusplus
@@ -6219,7 +7127,7 @@ main ()
   /* NEC SVR4.0.2 mips cc rejects this.  */
   struct point {int x, y;};
   static struct point const zero = {0,0};
-  /* AIX XL C 1.02.0.0 rejects this.
+  /* IBM XL C 1.02.0.0 rejects this.
      It does not let you subtract one const X* pointer from another in
      an arm of an if-expression whose if-part is not a constant
      expression */
@@ -6247,7 +7155,7 @@ main ()
     iptr p = 0;
     ++p;
   }
-  { /* AIX XL C 1.02.0.0 rejects this sort of thing, saying
+  { /* IBM XL C 1.02.0.0 rejects this sort of thing, saying
        "k.c", line 2.27: 1506-025 (S) Operand must be a modifiable lvalue. */
     struct s { int j; const int *ap[3]; } bx;
     struct s *b = &bx; b->j = 5;
@@ -6263,47 +7171,50 @@ main ()
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   ac_cv_c_const=yes
-else
+else $as_nop
   ac_cv_c_const=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_c_const" >&5
-$as_echo "$ac_cv_c_const" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_c_const" >&5
+printf "%s\n" "$ac_cv_c_const" >&6; }
 if test $ac_cv_c_const = no; then
 
-$as_echo "#define const /**/" >>confdefs.h
+printf "%s\n" "#define const /**/" >>confdefs.h
 
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for inline" >&5
-$as_echo_n "checking for inline... " >&6; }
-if ${ac_cv_c_inline+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for inline" >&5
+printf %s "checking for inline... " >&6; }
+if test ${ac_cv_c_inline+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   ac_cv_c_inline=no
 for ac_kw in inline __inline__ __inline; do
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 #ifndef __cplusplus
 typedef int foo_t;
-static $ac_kw foo_t static_foo () {return 0; }
-$ac_kw foo_t foo () {return 0; }
+static $ac_kw foo_t static_foo (void) {return 0; }
+$ac_kw foo_t foo (void) {return 0; }
 #endif
 
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   ac_cv_c_inline=$ac_kw
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
   test "$ac_cv_c_inline" != no && break
 done
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_c_inline" >&5
-$as_echo "$ac_cv_c_inline" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_c_inline" >&5
+printf "%s\n" "$ac_cv_c_inline" >&6; }
 
 case $ac_cv_c_inline in
   inline | yes) ;;
@@ -6321,36 +7232,33 @@ _ACEOF
 esac
 
 ac_fn_c_check_member "$LINENO" "struct stat" "st_rdev" "ac_cv_member_struct_stat_st_rdev" "$ac_includes_default"
-if test "x$ac_cv_member_struct_stat_st_rdev" = xyes; then :
+if test "x$ac_cv_member_struct_stat_st_rdev" = xyes
+then :
 
-cat >>confdefs.h <<_ACEOF
-#define HAVE_STRUCT_STAT_ST_RDEV 1
-_ACEOF
+printf "%s\n" "#define HAVE_STRUCT_STAT_ST_RDEV 1" >>confdefs.h
 
 
 fi
 
 ac_fn_c_check_type "$LINENO" "ptrdiff_t" "ac_cv_type_ptrdiff_t" "$ac_includes_default"
-if test "x$ac_cv_type_ptrdiff_t" = xyes; then :
+if test "x$ac_cv_type_ptrdiff_t" = xyes
+then :
 
-cat >>confdefs.h <<_ACEOF
-#define HAVE_PTRDIFF_T 1
-_ACEOF
+printf "%s\n" "#define HAVE_PTRDIFF_T 1" >>confdefs.h
 
 
 fi
 
 ac_fn_c_check_member "$LINENO" "struct stat" "st_blocks" "ac_cv_member_struct_stat_st_blocks" "$ac_includes_default"
-if test "x$ac_cv_member_struct_stat_st_blocks" = xyes; then :
+if test "x$ac_cv_member_struct_stat_st_blocks" = xyes
+then :
 
-cat >>confdefs.h <<_ACEOF
-#define HAVE_STRUCT_STAT_ST_BLOCKS 1
-_ACEOF
+printf "%s\n" "#define HAVE_STRUCT_STAT_ST_BLOCKS 1" >>confdefs.h
 
 
-$as_echo "#define HAVE_ST_BLOCKS 1" >>confdefs.h
+printf "%s\n" "#define HAVE_ST_BLOCKS 1" >>confdefs.h
 
-else
+else $as_nop
   case " $LIBOBJS " in
   *" fileblocks.$ac_objext "* ) ;;
   *) LIBOBJS="$LIBOBJS fileblocks.$ac_objext"
@@ -6360,18 +7268,19 @@ esac
 fi
 
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether struct tm is in sys/time.h or time.h" >&5
-$as_echo_n "checking whether struct tm is in sys/time.h or time.h... " >&6; }
-if ${ac_cv_struct_tm+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether struct tm is in sys/time.h or time.h" >&5
+printf %s "checking whether struct tm is in sys/time.h or time.h... " >&6; }
+if test ${ac_cv_struct_tm+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 #include <sys/types.h>
 #include <time.h>
 
 int
-main ()
+main (void)
 {
 struct tm tm;
 				     int *p = &tm.tm_sec;
@@ -6380,95 +7289,119 @@ struct tm tm;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   ac_cv_struct_tm=time.h
-else
+else $as_nop
   ac_cv_struct_tm=sys/time.h
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_struct_tm" >&5
-$as_echo "$ac_cv_struct_tm" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_struct_tm" >&5
+printf "%s\n" "$ac_cv_struct_tm" >&6; }
 if test $ac_cv_struct_tm = sys/time.h; then
 
-$as_echo "#define TM_IN_SYS_TIME 1" >>confdefs.h
+printf "%s\n" "#define TM_IN_SYS_TIME 1" >>confdefs.h
 
 fi
 
 ac_fn_c_check_type "$LINENO" "off_t" "ac_cv_type_off_t" "$ac_includes_default"
-if test "x$ac_cv_type_off_t" = xyes; then :
+if test "x$ac_cv_type_off_t" = xyes
+then :
 
-else
+else $as_nop
 
-cat >>confdefs.h <<_ACEOF
-#define off_t long int
-_ACEOF
+printf "%s\n" "#define off_t long int" >>confdefs.h
 
 fi
 
-ac_fn_c_check_type "$LINENO" "pid_t" "ac_cv_type_pid_t" "$ac_includes_default"
-if test "x$ac_cv_type_pid_t" = xyes; then :
 
-else
+  ac_fn_c_check_type "$LINENO" "pid_t" "ac_cv_type_pid_t" "$ac_includes_default
+"
+if test "x$ac_cv_type_pid_t" = xyes
+then :
+
+else $as_nop
+                                          cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+
+          #if defined _WIN64 && !defined __CYGWIN__
+          LLP64
+          #endif
+
+int
+main (void)
+{
+
+  ;
+  return 0;
+}
 
-cat >>confdefs.h <<_ACEOF
-#define pid_t int
 _ACEOF
+if ac_fn_c_try_compile "$LINENO"
+then :
+  ac_pid_type='int'
+else $as_nop
+  ac_pid_type='__int64'
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+
+printf "%s\n" "#define pid_t $ac_pid_type" >>confdefs.h
+
 
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking return type of signal handlers" >&5
-$as_echo_n "checking return type of signal handlers... " >&6; }
-if ${ac_cv_type_signal+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking return type of signal handlers" >&5
+printf %s "checking return type of signal handlers... " >&6; }
+if test ${ac_cv_type_signal+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 #include <sys/types.h>
 #include <signal.h>
 
 int
-main ()
+main (void)
 {
 return *(signal (0, 0)) (0) == 1;
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   ac_cv_type_signal=int
-else
+else $as_nop
   ac_cv_type_signal=void
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_type_signal" >&5
-$as_echo "$ac_cv_type_signal" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_type_signal" >&5
+printf "%s\n" "$ac_cv_type_signal" >&6; }
 
-cat >>confdefs.h <<_ACEOF
-#define RETSIGTYPE $ac_cv_type_signal
-_ACEOF
+printf "%s\n" "#define RETSIGTYPE $ac_cv_type_signal" >>confdefs.h
 
 
 ac_fn_c_check_type "$LINENO" "size_t" "ac_cv_type_size_t" "$ac_includes_default"
-if test "x$ac_cv_type_size_t" = xyes; then :
+if test "x$ac_cv_type_size_t" = xyes
+then :
 
-else
+else $as_nop
 
-cat >>confdefs.h <<_ACEOF
-#define size_t unsigned int
-_ACEOF
+printf "%s\n" "#define size_t unsigned int" >>confdefs.h
 
 fi
 
 ac_fn_c_check_type "$LINENO" "mode_t" "ac_cv_type_mode_t" "$ac_includes_default"
-if test "x$ac_cv_type_mode_t" = xyes; then :
+if test "x$ac_cv_type_mode_t" = xyes
+then :
 
-else
+else $as_nop
 
-cat >>confdefs.h <<_ACEOF
-#define mode_t int
-_ACEOF
+printf "%s\n" "#define mode_t int" >>confdefs.h
 
 fi
 
@@ -6477,9 +7410,7 @@ case $ac_cv_c_int8_t in #(
   no|yes) ;; #(
   *)
 
-cat >>confdefs.h <<_ACEOF
-#define int8_t $ac_cv_c_int8_t
-_ACEOF
+printf "%s\n" "#define int8_t $ac_cv_c_int8_t" >>confdefs.h
 ;;
 esac
 
@@ -6488,9 +7419,7 @@ case $ac_cv_c_int16_t in #(
   no|yes) ;; #(
   *)
 
-cat >>confdefs.h <<_ACEOF
-#define int16_t $ac_cv_c_int16_t
-_ACEOF
+printf "%s\n" "#define int16_t $ac_cv_c_int16_t" >>confdefs.h
 ;;
 esac
 
@@ -6499,9 +7428,7 @@ case $ac_cv_c_int32_t in #(
   no|yes) ;; #(
   *)
 
-cat >>confdefs.h <<_ACEOF
-#define int32_t $ac_cv_c_int32_t
-_ACEOF
+printf "%s\n" "#define int32_t $ac_cv_c_int32_t" >>confdefs.h
 ;;
 esac
 
@@ -6510,50 +7437,49 @@ case $ac_cv_c_int64_t in #(
   no|yes) ;; #(
   *)
 
-cat >>confdefs.h <<_ACEOF
-#define int64_t $ac_cv_c_int64_t
-_ACEOF
+printf "%s\n" "#define int64_t $ac_cv_c_int64_t" >>confdefs.h
 ;;
 esac
 
 ac_fn_c_check_type "$LINENO" "ssize_t" "ac_cv_type_ssize_t" "$ac_includes_default"
-if test "x$ac_cv_type_ssize_t" = xyes; then :
+if test "x$ac_cv_type_ssize_t" = xyes
+then :
 
-else
+else $as_nop
 
-cat >>confdefs.h <<_ACEOF
-#define ssize_t int
-_ACEOF
+printf "%s\n" "#define ssize_t int" >>confdefs.h
 
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for uid_t in sys/types.h" >&5
-$as_echo_n "checking for uid_t in sys/types.h... " >&6; }
-if ${ac_cv_type_uid_t+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for uid_t in sys/types.h" >&5
+printf %s "checking for uid_t in sys/types.h... " >&6; }
+if test ${ac_cv_type_uid_t+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 #include <sys/types.h>
 
 _ACEOF
 if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
-  $EGREP "uid_t" >/dev/null 2>&1; then :
+  $EGREP "uid_t" >/dev/null 2>&1
+then :
   ac_cv_type_uid_t=yes
-else
+else $as_nop
   ac_cv_type_uid_t=no
 fi
-rm -f conftest*
+rm -rf conftest*
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_type_uid_t" >&5
-$as_echo "$ac_cv_type_uid_t" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_type_uid_t" >&5
+printf "%s\n" "$ac_cv_type_uid_t" >&6; }
 if test $ac_cv_type_uid_t = no; then
 
-$as_echo "#define uid_t int" >>confdefs.h
+printf "%s\n" "#define uid_t int" >>confdefs.h
 
 
-$as_echo "#define gid_t int" >>confdefs.h
+printf "%s\n" "#define gid_t int" >>confdefs.h
 
 fi
 
@@ -6562,12 +7488,10 @@ case $ac_cv_c_uint8_t in #(
   no|yes) ;; #(
   *)
 
-$as_echo "#define _UINT8_T 1" >>confdefs.h
+printf "%s\n" "#define _UINT8_T 1" >>confdefs.h
 
 
-cat >>confdefs.h <<_ACEOF
-#define uint8_t $ac_cv_c_uint8_t
-_ACEOF
+printf "%s\n" "#define uint8_t $ac_cv_c_uint8_t" >>confdefs.h
 ;;
   esac
 
@@ -6577,9 +7501,7 @@ case $ac_cv_c_uint16_t in #(
   *)
 
 
-cat >>confdefs.h <<_ACEOF
-#define uint16_t $ac_cv_c_uint16_t
-_ACEOF
+printf "%s\n" "#define uint16_t $ac_cv_c_uint16_t" >>confdefs.h
 ;;
   esac
 
@@ -6588,12 +7510,10 @@ case $ac_cv_c_uint32_t in #(
   no|yes) ;; #(
   *)
 
-$as_echo "#define _UINT32_T 1" >>confdefs.h
+printf "%s\n" "#define _UINT32_T 1" >>confdefs.h
 
 
-cat >>confdefs.h <<_ACEOF
-#define uint32_t $ac_cv_c_uint32_t
-_ACEOF
+printf "%s\n" "#define uint32_t $ac_cv_c_uint32_t" >>confdefs.h
 ;;
   esac
 
@@ -6602,29 +7522,28 @@ case $ac_cv_c_uint64_t in #(
   no|yes) ;; #(
   *)
 
-$as_echo "#define _UINT64_T 1" >>confdefs.h
+printf "%s\n" "#define _UINT64_T 1" >>confdefs.h
 
 
-cat >>confdefs.h <<_ACEOF
-#define uint64_t $ac_cv_c_uint64_t
-_ACEOF
+printf "%s\n" "#define uint64_t $ac_cv_c_uint64_t" >>confdefs.h
 ;;
   esac
 
 
 
 
-    { $as_echo "$as_me:${as_lineno-$LINENO}: checking for __builtin_clz" >&5
-$as_echo_n "checking for __builtin_clz... " >&6; }
-if ${ax_cv_have___builtin_clz+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for __builtin_clz" >&5
+printf %s "checking for __builtin_clz... " >&6; }
+if test ${ax_cv_have___builtin_clz+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
 
         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
 int
-main ()
+main (void)
 {
 
             __builtin_clz(0)
@@ -6633,23 +7552,23 @@ main ()
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
+if ac_fn_c_try_link "$LINENO"
+then :
   ax_cv_have___builtin_clz=yes
-else
+else $as_nop
   ax_cv_have___builtin_clz=no
 fi
-rm -f core conftest.err conftest.$ac_objext \
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
     conftest$ac_exeext conftest.$ac_ext
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ax_cv_have___builtin_clz" >&5
-$as_echo "$ax_cv_have___builtin_clz" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ax_cv_have___builtin_clz" >&5
+printf "%s\n" "$ax_cv_have___builtin_clz" >&6; }
 
-    if test yes = $ax_cv_have___builtin_clz; then :
+    if test yes = $ax_cv_have___builtin_clz
+then :
 
-cat >>confdefs.h <<_ACEOF
-#define HAVE___BUILTIN_CLZ 1
-_ACEOF
+printf "%s\n" "#define HAVE___BUILTIN_CLZ 1" >>confdefs.h
 
 fi
 
@@ -6658,17 +7577,18 @@ fi
 
 
 
-    { $as_echo "$as_me:${as_lineno-$LINENO}: checking for __builtin_clzll" >&5
-$as_echo_n "checking for __builtin_clzll... " >&6; }
-if ${ax_cv_have___builtin_clzll+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for __builtin_clzll" >&5
+printf %s "checking for __builtin_clzll... " >&6; }
+if test ${ax_cv_have___builtin_clzll+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
 
         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
 int
-main ()
+main (void)
 {
 
             __builtin_clzll(0)
@@ -6677,23 +7597,23 @@ main ()
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
+if ac_fn_c_try_link "$LINENO"
+then :
   ax_cv_have___builtin_clzll=yes
-else
+else $as_nop
   ax_cv_have___builtin_clzll=no
 fi
-rm -f core conftest.err conftest.$ac_objext \
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
     conftest$ac_exeext conftest.$ac_ext
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ax_cv_have___builtin_clzll" >&5
-$as_echo "$ax_cv_have___builtin_clzll" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ax_cv_have___builtin_clzll" >&5
+printf "%s\n" "$ax_cv_have___builtin_clzll" >&6; }
 
-    if test yes = $ax_cv_have___builtin_clzll; then :
+    if test yes = $ax_cv_have___builtin_clzll
+then :
 
-cat >>confdefs.h <<_ACEOF
-#define HAVE___BUILTIN_CLZLL 1
-_ACEOF
+printf "%s\n" "#define HAVE___BUILTIN_CLZLL 1" >>confdefs.h
 
 fi
 
@@ -6702,17 +7622,18 @@ fi
 
 
 
-    { $as_echo "$as_me:${as_lineno-$LINENO}: checking for __builtin_ffs" >&5
-$as_echo_n "checking for __builtin_ffs... " >&6; }
-if ${ax_cv_have___builtin_ffs+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for __builtin_ffs" >&5
+printf %s "checking for __builtin_ffs... " >&6; }
+if test ${ax_cv_have___builtin_ffs+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
 
         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
 int
-main ()
+main (void)
 {
 
             __builtin_ffs(0)
@@ -6721,23 +7642,23 @@ main ()
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
+if ac_fn_c_try_link "$LINENO"
+then :
   ax_cv_have___builtin_ffs=yes
-else
+else $as_nop
   ax_cv_have___builtin_ffs=no
 fi
-rm -f core conftest.err conftest.$ac_objext \
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
     conftest$ac_exeext conftest.$ac_ext
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ax_cv_have___builtin_ffs" >&5
-$as_echo "$ax_cv_have___builtin_ffs" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ax_cv_have___builtin_ffs" >&5
+printf "%s\n" "$ax_cv_have___builtin_ffs" >&6; }
 
-    if test yes = $ax_cv_have___builtin_ffs; then :
+    if test yes = $ax_cv_have___builtin_ffs
+then :
 
-cat >>confdefs.h <<_ACEOF
-#define HAVE___BUILTIN_FFS 1
-_ACEOF
+printf "%s\n" "#define HAVE___BUILTIN_FFS 1" >>confdefs.h
 
 fi
 
@@ -6746,55 +7667,62 @@ fi
 
 
 
-$as_echo "#define _GNU_SOURCE 1" >>confdefs.h
+printf "%s\n" "#define _GNU_SOURCE 1" >>confdefs.h
 
 
-$as_echo "#define _REENTRANT 1" >>confdefs.h
+printf "%s\n" "#define _REENTRANT 1" >>confdefs.h
 
 
 
 ################################################################################
-for ac_func in ftruncate gethostname getpagesize gettimeofday localtime_r \
-  memchr memset mkdir mkfifo munmap nl_langinfo pselect realpath rmdir setenv \
-  setlocale strcasecmp strchr strcspn strdup strerror strncasecmp strndup \
-  strrchr strspn strstr strtol strtoul uname
+
+  for ac_func in ftruncate gethostname getpagesize gettimeofday localtime_r memchr memset mkdir mkfifo munmap nl_langinfo pselect realpath rmdir setenv setlocale strcasecmp strchr strcspn strdup strerror strncasecmp strndup strrchr strspn strstr strtol strtoul uname
 do :
-  as_ac_var=`$as_echo "ac_cv_func_$ac_func" | $as_tr_sh`
+  as_ac_var=`printf "%s\n" "ac_cv_func_$ac_func" | $as_tr_sh`
 ac_fn_c_check_func "$LINENO" "$ac_func" "$as_ac_var"
-if eval test \"x\$"$as_ac_var"\" = x"yes"; then :
+if eval test \"x\$"$as_ac_var"\" = x"yes"
+then :
   cat >>confdefs.h <<_ACEOF
-#define `$as_echo "HAVE_$ac_func" | $as_tr_cpp` 1
+#define `printf "%s\n" "HAVE_$ac_func" | $as_tr_cpp` 1
 _ACEOF
 
-else
+else $as_nop
   as_fn_error $? "bailing out" "$LINENO" 5
 fi
+
 done
+ac_fn_c_check_func "$LINENO" "ffs" "ac_cv_func_ffs"
+if test "x$ac_cv_func_ffs" = xyes
+then :
+  printf "%s\n" "#define HAVE_FFS 1" >>confdefs.h
 
-for ac_func in ffs prlimit versionsort
-do :
-  as_ac_var=`$as_echo "ac_cv_func_$ac_func" | $as_tr_sh`
-ac_fn_c_check_func "$LINENO" "$ac_func" "$as_ac_var"
-if eval test \"x\$"$as_ac_var"\" = x"yes"; then :
-  cat >>confdefs.h <<_ACEOF
-#define `$as_echo "HAVE_$ac_func" | $as_tr_cpp` 1
-_ACEOF
+fi
+ac_fn_c_check_func "$LINENO" "prlimit" "ac_cv_func_prlimit"
+if test "x$ac_cv_func_prlimit" = xyes
+then :
+  printf "%s\n" "#define HAVE_PRLIMIT 1" >>confdefs.h
+
+fi
+ac_fn_c_check_func "$LINENO" "versionsort" "ac_cv_func_versionsort"
+if test "x$ac_cv_func_versionsort" = xyes
+then :
+  printf "%s\n" "#define HAVE_VERSIONSORT 1" >>confdefs.h
 
 fi
-done
 
 # The Ultrix 4.2 mips builtin alloca declared by alloca.h only works
 # for constant arguments.  Useless!
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for working alloca.h" >&5
-$as_echo_n "checking for working alloca.h... " >&6; }
-if ${ac_cv_working_alloca_h+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for working alloca.h" >&5
+printf %s "checking for working alloca.h... " >&6; }
+if test ${ac_cv_working_alloca_h+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 #include <alloca.h>
 int
-main ()
+main (void)
 {
 char *p = (char *) alloca (2 * sizeof (int));
 			  if (p) return 0;
@@ -6802,52 +7730,52 @@ char *p = (char *) alloca (2 * sizeof (int));
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
+if ac_fn_c_try_link "$LINENO"
+then :
   ac_cv_working_alloca_h=yes
-else
+else $as_nop
   ac_cv_working_alloca_h=no
 fi
-rm -f core conftest.err conftest.$ac_objext \
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
     conftest$ac_exeext conftest.$ac_ext
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_working_alloca_h" >&5
-$as_echo "$ac_cv_working_alloca_h" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_working_alloca_h" >&5
+printf "%s\n" "$ac_cv_working_alloca_h" >&6; }
 if test $ac_cv_working_alloca_h = yes; then
 
-$as_echo "#define HAVE_ALLOCA_H 1" >>confdefs.h
+printf "%s\n" "#define HAVE_ALLOCA_H 1" >>confdefs.h
 
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for alloca" >&5
-$as_echo_n "checking for alloca... " >&6; }
-if ${ac_cv_func_alloca_works+:} false; then :
-  $as_echo_n "(cached) " >&6
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for alloca" >&5
+printf %s "checking for alloca... " >&6; }
+if test ${ac_cv_func_alloca_works+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if test $ac_cv_working_alloca_h = yes; then
+  ac_cv_func_alloca_works=yes
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#ifdef __GNUC__
-# define alloca __builtin_alloca
-#else
-# ifdef _MSC_VER
+#include <stdlib.h>
+#include <stddef.h>
+#ifndef alloca
+# ifdef __GNUC__
+#  define alloca __builtin_alloca
+# elif defined _MSC_VER
 #  include <malloc.h>
 #  define alloca _alloca
 # else
-#  ifdef HAVE_ALLOCA_H
-#   include <alloca.h>
-#  else
-#   ifdef _AIX
- #pragma alloca
-#   else
-#    ifndef alloca /* predefined by HP cc +Olibcalls */
-void *alloca (size_t);
-#    endif
-#   endif
+#  ifdef  __cplusplus
+extern "C"
 #  endif
+void *alloca (size_t);
 # endif
 #endif
 
 int
-main ()
+main (void)
 {
 char *p = (char *) alloca (1);
 				    if (p) return 0;
@@ -6855,20 +7783,22 @@ char *p = (char *) alloca (1);
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
+if ac_fn_c_try_link "$LINENO"
+then :
   ac_cv_func_alloca_works=yes
-else
+else $as_nop
   ac_cv_func_alloca_works=no
 fi
-rm -f core conftest.err conftest.$ac_objext \
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
     conftest$ac_exeext conftest.$ac_ext
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_alloca_works" >&5
-$as_echo "$ac_cv_func_alloca_works" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_alloca_works" >&5
+printf "%s\n" "$ac_cv_func_alloca_works" >&6; }
+fi
 
 if test $ac_cv_func_alloca_works = yes; then
 
-$as_echo "#define HAVE_ALLOCA 1" >>confdefs.h
+printf "%s\n" "#define HAVE_ALLOCA 1" >>confdefs.h
 
 else
   # The SVR3 libPW and SVR4 libucb both contain incompatible functions
@@ -6878,58 +7808,19 @@ else
 
 ALLOCA=\${LIBOBJDIR}alloca.$ac_objext
 
-$as_echo "#define C_ALLOCA 1" >>confdefs.h
-
-
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether \`alloca.c' needs Cray hooks" >&5
-$as_echo_n "checking whether \`alloca.c' needs Cray hooks... " >&6; }
-if ${ac_cv_os_cray+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#if defined CRAY && ! defined CRAY2
-webecray
-#else
-wenotbecray
-#endif
-
-_ACEOF
-if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
-  $EGREP "webecray" >/dev/null 2>&1; then :
-  ac_cv_os_cray=yes
-else
-  ac_cv_os_cray=no
-fi
-rm -f conftest*
-
-fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_os_cray" >&5
-$as_echo "$ac_cv_os_cray" >&6; }
-if test $ac_cv_os_cray = yes; then
-  for ac_func in _getb67 GETB67 getb67; do
-    as_ac_var=`$as_echo "ac_cv_func_$ac_func" | $as_tr_sh`
-ac_fn_c_check_func "$LINENO" "$ac_func" "$as_ac_var"
-if eval test \"x\$"$as_ac_var"\" = x"yes"; then :
-
-cat >>confdefs.h <<_ACEOF
-#define CRAY_STACKSEG_END $ac_func
-_ACEOF
+printf "%s\n" "#define C_ALLOCA 1" >>confdefs.h
 
-    break
-fi
-
-  done
-fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking stack direction for C alloca" >&5
-$as_echo_n "checking stack direction for C alloca... " >&6; }
-if ${ac_cv_c_stack_direction+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  if test "$cross_compiling" = yes; then :
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking stack direction for C alloca" >&5
+printf %s "checking stack direction for C alloca... " >&6; }
+if test ${ac_cv_c_stack_direction+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if test "$cross_compiling" = yes
+then :
   ac_cv_c_stack_direction=0
-else
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 $ac_includes_default
@@ -6950,9 +7841,10 @@ main (int argc, char **argv)
   return find_stack_direction (0, argc + !argv + 20) < 0;
 }
 _ACEOF
-if ac_fn_c_try_run "$LINENO"; then :
+if ac_fn_c_try_run "$LINENO"
+then :
   ac_cv_c_stack_direction=1
-else
+else $as_nop
   ac_cv_c_stack_direction=-1
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
@@ -6960,84 +7852,72 @@ rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
 fi
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_c_stack_direction" >&5
-$as_echo "$ac_cv_c_stack_direction" >&6; }
-cat >>confdefs.h <<_ACEOF
-#define STACK_DIRECTION $ac_cv_c_stack_direction
-_ACEOF
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_c_stack_direction" >&5
+printf "%s\n" "$ac_cv_c_stack_direction" >&6; }
+printf "%s\n" "#define STACK_DIRECTION $ac_cv_c_stack_direction" >>confdefs.h
 
 
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether closedir returns void" >&5
-$as_echo_n "checking whether closedir returns void... " >&6; }
-if ${ac_cv_func_closedir_void+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  if test "$cross_compiling" = yes; then :
-  ac_cv_func_closedir_void=yes
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether closedir returns void" >&5
+printf %s "checking whether closedir returns void... " >&6; }
+if test ${ac_cv_func_closedir_void+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-$ac_includes_default
+
 #include <$ac_header_dirent>
-#ifndef __cplusplus
-int closedir ();
-#endif
 
 int
-main ()
+main (void)
 {
-return closedir (opendir (".")) != 0;
+
+  return closedir(0);
+
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_run "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   ac_cv_func_closedir_void=no
-else
+else $as_nop
   ac_cv_func_closedir_void=yes
 fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
-fi
-
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_closedir_void" >&5
-$as_echo "$ac_cv_func_closedir_void" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_closedir_void" >&5
+printf "%s\n" "$ac_cv_func_closedir_void" >&6; }
 if test $ac_cv_func_closedir_void = yes; then
 
-$as_echo "#define CLOSEDIR_VOID 1" >>confdefs.h
-
-fi
-
-for ac_header in unistd.h
-do :
-  ac_fn_c_check_header_mongrel "$LINENO" "unistd.h" "ac_cv_header_unistd_h" "$ac_includes_default"
-if test "x$ac_cv_header_unistd_h" = xyes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_UNISTD_H 1
-_ACEOF
-
-fi
-
-done
-
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for working chown" >&5
-$as_echo_n "checking for working chown... " >&6; }
-if ${ac_cv_func_chown_works+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  if test "$cross_compiling" = yes; then :
-  ac_cv_func_chown_works=no
-else
+printf "%s\n" "#define CLOSEDIR_VOID 1" >>confdefs.h
+
+fi
+
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for working chown" >&5
+printf %s "checking for working chown... " >&6; }
+if test ${ac_cv_func_chown_works+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if test "$cross_compiling" = yes
+then :
+  case "$host_os" in # ((
+			  # Guess yes on glibc systems.
+		  *-gnu*) ac_cv_func_chown_works=yes ;;
+			  # If we don't know, assume the worst.
+		  *)      ac_cv_func_chown_works=no ;;
+		esac
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 $ac_includes_default
 #include <fcntl.h>
 
 int
-main ()
+main (void)
 {
   char *f = "conftest.chown";
   struct stat before, after;
@@ -7056,9 +7936,10 @@ main ()
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_run "$LINENO"; then :
+if ac_fn_c_try_run "$LINENO"
+then :
   ac_cv_func_chown_works=yes
-else
+else $as_nop
   ac_cv_func_chown_works=no
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
@@ -7068,52 +7949,47 @@ fi
 rm -f conftest.chown
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_chown_works" >&5
-$as_echo "$ac_cv_func_chown_works" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_chown_works" >&5
+printf "%s\n" "$ac_cv_func_chown_works" >&6; }
 if test $ac_cv_func_chown_works = yes; then
 
-$as_echo "#define HAVE_CHOWN 1" >>confdefs.h
+printf "%s\n" "#define HAVE_CHOWN 1" >>confdefs.h
 
 fi
 
-for ac_header in vfork.h
-do :
-  ac_fn_c_check_header_mongrel "$LINENO" "vfork.h" "ac_cv_header_vfork_h" "$ac_includes_default"
-if test "x$ac_cv_header_vfork_h" = xyes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_VFORK_H 1
-_ACEOF
-
-fi
 
+ac_func=
+for ac_item in $ac_func_c_list
+do
+  if test $ac_func; then
+    ac_fn_c_check_func "$LINENO" $ac_func ac_cv_func_$ac_func
+    if eval test \"x\$ac_cv_func_$ac_func\" = xyes; then
+      echo "#define $ac_item 1" >> confdefs.h
+    fi
+    ac_func=
+  else
+    ac_func=$ac_item
+  fi
 done
 
-for ac_func in fork vfork
-do :
-  as_ac_var=`$as_echo "ac_cv_func_$ac_func" | $as_tr_sh`
-ac_fn_c_check_func "$LINENO" "$ac_func" "$as_ac_var"
-if eval test \"x\$"$as_ac_var"\" = x"yes"; then :
-  cat >>confdefs.h <<_ACEOF
-#define `$as_echo "HAVE_$ac_func" | $as_tr_cpp` 1
-_ACEOF
 
-fi
-done
 
 if test "x$ac_cv_func_fork" = xyes; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for working fork" >&5
-$as_echo_n "checking for working fork... " >&6; }
-if ${ac_cv_func_fork_works+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  if test "$cross_compiling" = yes; then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for working fork" >&5
+printf %s "checking for working fork... " >&6; }
+if test ${ac_cv_func_fork_works+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if test "$cross_compiling" = yes
+then :
   ac_cv_func_fork_works=cross
-else
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 $ac_includes_default
 int
-main ()
+main (void)
 {
 
 	  /* By Ruediger Kuhlmann. */
@@ -7123,9 +7999,10 @@ main ()
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_run "$LINENO"; then :
+if ac_fn_c_try_run "$LINENO"
+then :
   ac_cv_func_fork_works=yes
-else
+else $as_nop
   ac_cv_func_fork_works=no
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
@@ -7133,8 +8010,8 @@ rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
 fi
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_fork_works" >&5
-$as_echo "$ac_cv_func_fork_works" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_fork_works" >&5
+printf "%s\n" "$ac_cv_func_fork_works" >&6; }
 
 else
   ac_cv_func_fork_works=$ac_cv_func_fork
@@ -7149,27 +8026,37 @@ if test "x$ac_cv_func_fork_works" = xcross; then
       ac_cv_func_fork_works=yes
       ;;
   esac
-  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: result $ac_cv_func_fork_works guessed because of cross compilation" >&5
-$as_echo "$as_me: WARNING: result $ac_cv_func_fork_works guessed because of cross compilation" >&2;}
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: result $ac_cv_func_fork_works guessed because of cross compilation" >&5
+printf "%s\n" "$as_me: WARNING: result $ac_cv_func_fork_works guessed because of cross compilation" >&2;}
 fi
 ac_cv_func_vfork_works=$ac_cv_func_vfork
 if test "x$ac_cv_func_vfork" = xyes; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for working vfork" >&5
-$as_echo_n "checking for working vfork... " >&6; }
-if ${ac_cv_func_vfork_works+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  if test "$cross_compiling" = yes; then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for working vfork" >&5
+printf %s "checking for working vfork... " >&6; }
+if test ${ac_cv_func_vfork_works+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if test "$cross_compiling" = yes
+then :
   ac_cv_func_vfork_works=cross
-else
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 /* Thanks to Paul Eggert for this test.  */
 $ac_includes_default
+#include <signal.h>
 #include <sys/wait.h>
 #ifdef HAVE_VFORK_H
 # include <vfork.h>
 #endif
+
+static void
+do_nothing (int sig)
+{
+  (void) sig;
+}
+
 /* On some sparc systems, changes by the child to local and incoming
    argument registers are propagated back to the parent.  The compiler
    is told about this with #include <vfork.h>, but some compilers
@@ -7177,11 +8064,7 @@ $ac_includes_default
    static variable whose address is put into a register that is
    clobbered by the vfork.  */
 static void
-#ifdef __cplusplus
 sparc_address_test (int arg)
-# else
-sparc_address_test (arg) int arg;
-#endif
 {
   static pid_t child;
   if (!child) {
@@ -7199,13 +8082,18 @@ sparc_address_test (arg) int arg;
 }
 
 int
-main ()
+main (void)
 {
   pid_t parent = getpid ();
   pid_t child;
 
   sparc_address_test (0);
 
+  /* On Solaris 2.4, changes by the child to the signal handler
+     also munge signal handlers in the parent.  To detect this,
+     start by putting the parent's handler in a known state.  */
+  signal (SIGTERM, SIG_DFL);
+
   child = vfork ();
 
   if (child == 0) {
@@ -7227,6 +8115,10 @@ main ()
 	|| p != p5 || p != p6 || p != p7)
       _exit(1);
 
+    /* Alter the child's signal handler.  */
+    if (signal (SIGTERM, do_nothing) != SIG_DFL)
+      _exit(1);
+
     /* On some systems (e.g. IRIX 3.3), vfork doesn't separate parent
        from child file descriptors.  If the child closes a descriptor
        before it execs or exits, this munges the parent's descriptor
@@ -7242,6 +8134,9 @@ main ()
 	 /* Was there some problem with vforking?  */
 	 child < 0
 
+	 /* Did the child munge the parent's signal handler?  */
+	 || signal (SIGTERM, SIG_DFL) != SIG_DFL
+
 	 /* Did the child fail?  (This shouldn't happen.)  */
 	 || status
 
@@ -7254,9 +8149,10 @@ main ()
   }
 }
 _ACEOF
-if ac_fn_c_try_run "$LINENO"; then :
+if ac_fn_c_try_run "$LINENO"
+then :
   ac_cv_func_vfork_works=yes
-else
+else $as_nop
   ac_cv_func_vfork_works=no
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
@@ -7264,47 +8160,54 @@ rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
 fi
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_vfork_works" >&5
-$as_echo "$ac_cv_func_vfork_works" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_vfork_works" >&5
+printf "%s\n" "$ac_cv_func_vfork_works" >&6; }
 
 fi;
 if test "x$ac_cv_func_fork_works" = xcross; then
   ac_cv_func_vfork_works=$ac_cv_func_vfork
-  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: result $ac_cv_func_vfork_works guessed because of cross compilation" >&5
-$as_echo "$as_me: WARNING: result $ac_cv_func_vfork_works guessed because of cross compilation" >&2;}
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: result $ac_cv_func_vfork_works guessed because of cross compilation" >&5
+printf "%s\n" "$as_me: WARNING: result $ac_cv_func_vfork_works guessed because of cross compilation" >&2;}
 fi
 
 if test "x$ac_cv_func_vfork_works" = xyes; then
 
-$as_echo "#define HAVE_WORKING_VFORK 1" >>confdefs.h
+printf "%s\n" "#define HAVE_WORKING_VFORK 1" >>confdefs.h
 
 else
 
-$as_echo "#define vfork fork" >>confdefs.h
+printf "%s\n" "#define vfork fork" >>confdefs.h
 
 fi
 if test "x$ac_cv_func_fork_works" = xyes; then
 
-$as_echo "#define HAVE_WORKING_FORK 1" >>confdefs.h
+printf "%s\n" "#define HAVE_WORKING_FORK 1" >>confdefs.h
 
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether lstat correctly handles trailing slash" >&5
-$as_echo_n "checking whether lstat correctly handles trailing slash... " >&6; }
-if ${ac_cv_func_lstat_dereferences_slashed_symlink+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether lstat correctly handles trailing slash" >&5
+printf %s "checking whether lstat correctly handles trailing slash... " >&6; }
+if test ${ac_cv_func_lstat_dereferences_slashed_symlink+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   rm -f conftest.sym conftest.file
 echo >conftest.file
 if test "$as_ln_s" = "ln -s" && ln -s conftest.file conftest.sym; then
-  if test "$cross_compiling" = yes; then :
-  ac_cv_func_lstat_dereferences_slashed_symlink=no
-else
+  if test "$cross_compiling" = yes
+then :
+  case "$host_os" in # ((
+			   # Guess yes on glibc systems.
+		   *-gnu*) ac_cv_func_lstat_dereferences_slashed_symlink=yes ;;
+			   # If we don't know, assume the worst.
+		   *)      ac_cv_func_lstat_dereferences_slashed_symlink=no ;;
+		 esac
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 $ac_includes_default
 int
-main ()
+main (void)
 {
 struct stat sbuf;
      /* Linux will dereference the symlink and fail, as required by POSIX.
@@ -7315,9 +8218,10 @@ struct stat sbuf;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_run "$LINENO"; then :
+if ac_fn_c_try_run "$LINENO"
+then :
   ac_cv_func_lstat_dereferences_slashed_symlink=yes
-else
+else $as_nop
   ac_cv_func_lstat_dereferences_slashed_symlink=no
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
@@ -7332,14 +8236,12 @@ fi
 rm -f conftest.sym conftest.file
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_lstat_dereferences_slashed_symlink" >&5
-$as_echo "$ac_cv_func_lstat_dereferences_slashed_symlink" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_lstat_dereferences_slashed_symlink" >&5
+printf "%s\n" "$ac_cv_func_lstat_dereferences_slashed_symlink" >&6; }
 
 test $ac_cv_func_lstat_dereferences_slashed_symlink = yes &&
 
-cat >>confdefs.h <<_ACEOF
-#define LSTAT_FOLLOWS_SLASHED_SYMLINK 1
-_ACEOF
+printf "%s\n" "#define LSTAT_FOLLOWS_SLASHED_SYMLINK 1" >>confdefs.h
 
 
 if test "x$ac_cv_func_lstat_dereferences_slashed_symlink" = xno; then
@@ -7351,19 +8253,21 @@ esac
 
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether lstat accepts an empty string" >&5
-$as_echo_n "checking whether lstat accepts an empty string... " >&6; }
-if ${ac_cv_func_lstat_empty_string_bug+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  if test "$cross_compiling" = yes; then :
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether lstat accepts an empty string" >&5
+printf %s "checking whether lstat accepts an empty string... " >&6; }
+if test ${ac_cv_func_lstat_empty_string_bug+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if test "$cross_compiling" = yes
+then :
   ac_cv_func_lstat_empty_string_bug=yes
-else
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 $ac_includes_default
 int
-main ()
+main (void)
 {
 struct stat sbuf;
   return lstat ("", &sbuf) == 0;
@@ -7371,9 +8275,10 @@ struct stat sbuf;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_run "$LINENO"; then :
+if ac_fn_c_try_run "$LINENO"
+then :
   ac_cv_func_lstat_empty_string_bug=no
-else
+else $as_nop
   ac_cv_func_lstat_empty_string_bug=yes
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
@@ -7381,8 +8286,8 @@ rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
 fi
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_lstat_empty_string_bug" >&5
-$as_echo "$ac_cv_func_lstat_empty_string_bug" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_lstat_empty_string_bug" >&5
+printf "%s\n" "$ac_cv_func_lstat_empty_string_bug" >&6; }
 if test $ac_cv_func_lstat_empty_string_bug = yes; then
   case " $LIBOBJS " in
   *" lstat.$ac_objext "* ) ;;
@@ -7391,51 +8296,46 @@ if test $ac_cv_func_lstat_empty_string_bug = yes; then
 esac
 
 
-cat >>confdefs.h <<_ACEOF
-#define HAVE_LSTAT_EMPTY_STRING_BUG 1
-_ACEOF
-
-fi
-
-for ac_header in stdlib.h
-do :
-  ac_fn_c_check_header_mongrel "$LINENO" "stdlib.h" "ac_cv_header_stdlib_h" "$ac_includes_default"
-if test "x$ac_cv_header_stdlib_h" = xyes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_STDLIB_H 1
-_ACEOF
+printf "%s\n" "#define HAVE_LSTAT_EMPTY_STRING_BUG 1" >>confdefs.h
 
 fi
 
-done
-
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for GNU libc compatible malloc" >&5
-$as_echo_n "checking for GNU libc compatible malloc... " >&6; }
-if ${ac_cv_func_malloc_0_nonnull+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  if test "$cross_compiling" = yes; then :
-  ac_cv_func_malloc_0_nonnull=no
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for GNU libc compatible malloc" >&5
+printf %s "checking for GNU libc compatible malloc... " >&6; }
+if test ${ac_cv_func_malloc_0_nonnull+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if test "$cross_compiling" = yes
+then :
+  case "$host_os" in # ((
+		  # Guess yes on platforms where we know the result.
+		  *-gnu* | freebsd* | netbsd* | openbsd* | bitrig* \
+		  | hpux* | solaris* | cygwin* | mingw* | msys* )
+		    ac_cv_func_malloc_0_nonnull=yes ;;
+		  # If we don't know, assume the worst.
+		  *) ac_cv_func_malloc_0_nonnull=no ;;
+		esac
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#if defined STDC_HEADERS || defined HAVE_STDLIB_H
-# include <stdlib.h>
-#else
-char *malloc ();
-#endif
+#include <stdlib.h>
 
 int
-main ()
+main (void)
 {
-return ! malloc (0);
+void *p = malloc (0);
+		   int result = !p;
+		   free (p);
+		   return result;
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_run "$LINENO"; then :
+if ac_fn_c_try_run "$LINENO"
+then :
   ac_cv_func_malloc_0_nonnull=yes
-else
+else $as_nop
   ac_cv_func_malloc_0_nonnull=no
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
@@ -7443,14 +8343,15 @@ rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
 fi
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_malloc_0_nonnull" >&5
-$as_echo "$ac_cv_func_malloc_0_nonnull" >&6; }
-if test $ac_cv_func_malloc_0_nonnull = yes; then :
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_malloc_0_nonnull" >&5
+printf "%s\n" "$ac_cv_func_malloc_0_nonnull" >&6; }
+if test $ac_cv_func_malloc_0_nonnull = yes
+then :
 
-$as_echo "#define HAVE_MALLOC 1" >>confdefs.h
+printf "%s\n" "#define HAVE_MALLOC 1" >>confdefs.h
 
-else
-  $as_echo "#define HAVE_MALLOC 0" >>confdefs.h
+else $as_nop
+  printf "%s\n" "#define HAVE_MALLOC 0" >>confdefs.h
 
    case " $LIBOBJS " in
   *" malloc.$ac_objext "* ) ;;
@@ -7459,24 +8360,26 @@ else
 esac
 
 
-$as_echo "#define malloc rpl_malloc" >>confdefs.h
+printf "%s\n" "#define malloc rpl_malloc" >>confdefs.h
 
 fi
 
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for working memcmp" >&5
-$as_echo_n "checking for working memcmp... " >&6; }
-if ${ac_cv_func_memcmp_working+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  if test "$cross_compiling" = yes; then :
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for working memcmp" >&5
+printf %s "checking for working memcmp... " >&6; }
+if test ${ac_cv_func_memcmp_working+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if test "$cross_compiling" = yes
+then :
   ac_cv_func_memcmp_working=no
-else
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 $ac_includes_default
 int
-main ()
+main (void)
 {
 
   /* Some versions of memcmp are not 8-bit clean.  */
@@ -7507,9 +8410,10 @@ main ()
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_run "$LINENO"; then :
+if ac_fn_c_try_run "$LINENO"
+then :
   ac_cv_func_memcmp_working=yes
-else
+else $as_nop
   ac_cv_func_memcmp_working=no
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
@@ -7517,8 +8421,8 @@ rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
 fi
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_memcmp_working" >&5
-$as_echo "$ac_cv_func_memcmp_working" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_memcmp_working" >&5
+printf "%s\n" "$ac_cv_func_memcmp_working" >&6; }
 test $ac_cv_func_memcmp_working = no && case " $LIBOBJS " in
   *" memcmp.$ac_objext "* ) ;;
   *) LIBOBJS="$LIBOBJS memcmp.$ac_objext"
@@ -7529,63 +8433,22 @@ esac
 
 
 
-  for ac_header in $ac_header_list
-do :
-  as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
-ac_fn_c_check_header_compile "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default
-"
-if eval test \"x\$"$as_ac_Header"\" = x"yes"; then :
-  cat >>confdefs.h <<_ACEOF
-#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
-_ACEOF
-
-fi
-
-done
-
-
-
-
-
-
-
-
-  for ac_func in $ac_func_list
-do :
-  as_ac_var=`$as_echo "ac_cv_func_$ac_func" | $as_tr_sh`
-ac_fn_c_check_func "$LINENO" "$ac_func" "$as_ac_var"
-if eval test \"x\$"$as_ac_var"\" = x"yes"; then :
-  cat >>confdefs.h <<_ACEOF
-#define `$as_echo "HAVE_$ac_func" | $as_tr_cpp` 1
-_ACEOF
-
-fi
-done
-
-
-
-
-
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for working mktime" >&5
-$as_echo_n "checking for working mktime... " >&6; }
-if ${ac_cv_func_working_mktime+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  if test "$cross_compiling" = yes; then :
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for working mktime" >&5
+printf %s "checking for working mktime... " >&6; }
+if test ${ac_cv_func_working_mktime+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if test "$cross_compiling" = yes
+then :
   ac_cv_func_working_mktime=no
-else
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 /* Test program from Paul Eggert and Tony Leneis.  */
-#ifdef TIME_WITH_SYS_TIME
+#include <time.h>
+#ifdef HAVE_SYS_TIME_H
 # include <sys/time.h>
-# include <time.h>
-#else
-# ifdef HAVE_SYS_TIME_H
-#  include <sys/time.h>
-# else
-#  include <time.h>
-# endif
 #endif
 
 #include <limits.h>
@@ -7724,7 +8587,7 @@ year_2050_test ()
 }
 
 int
-main ()
+main (void)
 {
   time_t t, delta;
   int i, j;
@@ -7768,9 +8631,10 @@ main ()
   return ! (irix_6_4_bug () && spring_forward_gap () && year_2050_test ());
 }
 _ACEOF
-if ac_fn_c_try_run "$LINENO"; then :
+if ac_fn_c_try_run "$LINENO"
+then :
   ac_cv_func_working_mktime=yes
-else
+else $as_nop
   ac_cv_func_working_mktime=no
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
@@ -7778,8 +8642,8 @@ rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
 fi
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_working_mktime" >&5
-$as_echo "$ac_cv_func_working_mktime" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_working_mktime" >&5
+printf "%s\n" "$ac_cv_func_working_mktime" >&6; }
 if test $ac_cv_func_working_mktime = no; then
   case " $LIBOBJS " in
   *" mktime.$ac_objext "* ) ;;
@@ -7793,26 +8657,21 @@ fi
 
 
 
-
-for ac_func in getpagesize
-do :
-  ac_fn_c_check_func "$LINENO" "getpagesize" "ac_cv_func_getpagesize"
-if test "x$ac_cv_func_getpagesize" = xyes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_GETPAGESIZE 1
-_ACEOF
-
-fi
-done
-
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for working mmap" >&5
-$as_echo_n "checking for working mmap... " >&6; }
-if ${ac_cv_func_mmap_fixed_mapped+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  if test "$cross_compiling" = yes; then :
-  ac_cv_func_mmap_fixed_mapped=no
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for working mmap" >&5
+printf %s "checking for working mmap... " >&6; }
+if test ${ac_cv_func_mmap_fixed_mapped+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if test "$cross_compiling" = yes
+then :
+  case "$host_os" in # ((
+			  # Guess yes on platforms where we know the result.
+		  linux*) ac_cv_func_mmap_fixed_mapped=yes ;;
+			  # If we don't know, assume the worst.
+		  *)      ac_cv_func_mmap_fixed_mapped=no ;;
+		esac
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 $ac_includes_default
@@ -7844,10 +8703,6 @@ $ac_includes_default
 #include <fcntl.h>
 #include <sys/mman.h>
 
-#if !defined STDC_HEADERS && !defined HAVE_STDLIB_H
-char *malloc ();
-#endif
-
 /* This mess was copied from the GNU getpagesize.h.  */
 #ifndef HAVE_GETPAGESIZE
 # ifdef _SC_PAGESIZE
@@ -7881,7 +8736,7 @@ char *malloc ();
 #endif /* no HAVE_GETPAGESIZE */
 
 int
-main ()
+main (void)
 {
   char *data, *data2, *data3;
   const char *cdata2;
@@ -7949,12 +8804,15 @@ main ()
     if (*(data + i) != *(data3 + i))
       return 14;
   close (fd);
+  free (data);
+  free (data3);
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_run "$LINENO"; then :
+if ac_fn_c_try_run "$LINENO"
+then :
   ac_cv_func_mmap_fixed_mapped=yes
-else
+else $as_nop
   ac_cv_func_mmap_fixed_mapped=no
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
@@ -7962,54 +8820,51 @@ rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
 fi
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_mmap_fixed_mapped" >&5
-$as_echo "$ac_cv_func_mmap_fixed_mapped" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_mmap_fixed_mapped" >&5
+printf "%s\n" "$ac_cv_func_mmap_fixed_mapped" >&6; }
 if test $ac_cv_func_mmap_fixed_mapped = yes; then
 
-$as_echo "#define HAVE_MMAP 1" >>confdefs.h
+printf "%s\n" "#define HAVE_MMAP 1" >>confdefs.h
 
 fi
 rm -f conftest.mmap conftest.txt
 
-for ac_header in stdlib.h
-do :
-  ac_fn_c_check_header_mongrel "$LINENO" "stdlib.h" "ac_cv_header_stdlib_h" "$ac_includes_default"
-if test "x$ac_cv_header_stdlib_h" = xyes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_STDLIB_H 1
-_ACEOF
-
-fi
-
-done
-
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for GNU libc compatible realloc" >&5
-$as_echo_n "checking for GNU libc compatible realloc... " >&6; }
-if ${ac_cv_func_realloc_0_nonnull+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  if test "$cross_compiling" = yes; then :
-  ac_cv_func_realloc_0_nonnull=no
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for GNU libc compatible realloc" >&5
+printf %s "checking for GNU libc compatible realloc... " >&6; }
+if test ${ac_cv_func_realloc_0_nonnull+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if test "$cross_compiling" = yes
+then :
+  case "$host_os" in # ((
+		  # Guess yes on platforms where we know the result.
+		  *-gnu* | freebsd* | netbsd* | openbsd* | bitrig* \
+		  | hpux* | solaris* | cygwin* | mingw* | msys* )
+		    ac_cv_func_realloc_0_nonnull=yes ;;
+		  # If we don't know, assume the worst.
+		  *) ac_cv_func_realloc_0_nonnull=no ;;
+		esac
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#if defined STDC_HEADERS || defined HAVE_STDLIB_H
-# include <stdlib.h>
-#else
-char *realloc ();
-#endif
+#include <stdlib.h>
 
 int
-main ()
+main (void)
 {
-return ! realloc (0, 0);
+void *p = realloc (0, 0);
+		   int result = !p;
+		   free (p);
+		   return result;
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_run "$LINENO"; then :
+if ac_fn_c_try_run "$LINENO"
+then :
   ac_cv_func_realloc_0_nonnull=yes
-else
+else $as_nop
   ac_cv_func_realloc_0_nonnull=no
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
@@ -8017,14 +8872,15 @@ rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
 fi
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_realloc_0_nonnull" >&5
-$as_echo "$ac_cv_func_realloc_0_nonnull" >&6; }
-if test $ac_cv_func_realloc_0_nonnull = yes; then :
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_realloc_0_nonnull" >&5
+printf "%s\n" "$ac_cv_func_realloc_0_nonnull" >&6; }
+if test $ac_cv_func_realloc_0_nonnull = yes
+then :
 
-$as_echo "#define HAVE_REALLOC 1" >>confdefs.h
+printf "%s\n" "#define HAVE_REALLOC 1" >>confdefs.h
 
-else
-  $as_echo "#define HAVE_REALLOC 0" >>confdefs.h
+else $as_nop
+  printf "%s\n" "#define HAVE_REALLOC 0" >>confdefs.h
 
    case " $LIBOBJS " in
   *" realloc.$ac_objext "* ) ;;
@@ -8033,24 +8889,26 @@ else
 esac
 
 
-$as_echo "#define realloc rpl_realloc" >>confdefs.h
+printf "%s\n" "#define realloc rpl_realloc" >>confdefs.h
 
 fi
 
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether stat accepts an empty string" >&5
-$as_echo_n "checking whether stat accepts an empty string... " >&6; }
-if ${ac_cv_func_stat_empty_string_bug+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  if test "$cross_compiling" = yes; then :
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether stat accepts an empty string" >&5
+printf %s "checking whether stat accepts an empty string... " >&6; }
+if test ${ac_cv_func_stat_empty_string_bug+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if test "$cross_compiling" = yes
+then :
   ac_cv_func_stat_empty_string_bug=yes
-else
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 $ac_includes_default
 int
-main ()
+main (void)
 {
 struct stat sbuf;
   return stat ("", &sbuf) == 0;
@@ -8058,9 +8916,10 @@ struct stat sbuf;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_run "$LINENO"; then :
+if ac_fn_c_try_run "$LINENO"
+then :
   ac_cv_func_stat_empty_string_bug=no
-else
+else $as_nop
   ac_cv_func_stat_empty_string_bug=yes
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
@@ -8068,8 +8927,8 @@ rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
 fi
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_stat_empty_string_bug" >&5
-$as_echo "$ac_cv_func_stat_empty_string_bug" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_stat_empty_string_bug" >&5
+printf "%s\n" "$ac_cv_func_stat_empty_string_bug" >&6; }
 if test $ac_cv_func_stat_empty_string_bug = yes; then
   case " $LIBOBJS " in
   *" stat.$ac_objext "* ) ;;
@@ -8078,20 +8937,20 @@ if test $ac_cv_func_stat_empty_string_bug = yes; then
 esac
 
 
-cat >>confdefs.h <<_ACEOF
-#define HAVE_STAT_EMPTY_STRING_BUG 1
-_ACEOF
+printf "%s\n" "#define HAVE_STAT_EMPTY_STRING_BUG 1" >>confdefs.h
 
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for working strtod" >&5
-$as_echo_n "checking for working strtod... " >&6; }
-if ${ac_cv_func_strtod+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  if test "$cross_compiling" = yes; then :
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for working strtod" >&5
+printf %s "checking for working strtod... " >&6; }
+if test ${ac_cv_func_strtod+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if test "$cross_compiling" = yes
+then :
   ac_cv_func_strtod=no
-else
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
@@ -8100,7 +8959,7 @@ $ac_includes_default
 double strtod ();
 #endif
 int
-main()
+main (void)
 {
   {
     /* Some versions of Linux strtod mis-parse strings with leading '+'.  */
@@ -8125,9 +8984,10 @@ main()
 }
 
 _ACEOF
-if ac_fn_c_try_run "$LINENO"; then :
+if ac_fn_c_try_run "$LINENO"
+then :
   ac_cv_func_strtod=yes
-else
+else $as_nop
   ac_cv_func_strtod=no
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
@@ -8135,8 +8995,8 @@ rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
 fi
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_strtod" >&5
-$as_echo "$ac_cv_func_strtod" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_strtod" >&5
+printf "%s\n" "$ac_cv_func_strtod" >&6; }
 if test $ac_cv_func_strtod = no; then
   case " $LIBOBJS " in
   *" strtod.$ac_objext "* ) ;;
@@ -8145,16 +9005,18 @@ if test $ac_cv_func_strtod = no; then
 esac
 
 ac_fn_c_check_func "$LINENO" "pow" "ac_cv_func_pow"
-if test "x$ac_cv_func_pow" = xyes; then :
+if test "x$ac_cv_func_pow" = xyes
+then :
 
 fi
 
 if test $ac_cv_func_pow = no; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for pow in -lm" >&5
-$as_echo_n "checking for pow in -lm... " >&6; }
-if ${ac_cv_lib_m_pow+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for pow in -lm" >&5
+printf %s "checking for pow in -lm... " >&6; }
+if test ${ac_cv_lib_m_pow+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   ac_check_lib_save_LIBS=$LIBS
 LIBS="-lm  $LIBS"
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -8163,130 +9025,128 @@ cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* Override any GCC internal prototype to avoid an error.
    Use char because int might match the return type of a GCC
    builtin and then its argument prototype would still apply.  */
-#ifdef __cplusplus
-extern "C"
-#endif
 char pow ();
 int
-main ()
+main (void)
 {
 return pow ();
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
+if ac_fn_c_try_link "$LINENO"
+then :
   ac_cv_lib_m_pow=yes
-else
+else $as_nop
   ac_cv_lib_m_pow=no
 fi
-rm -f core conftest.err conftest.$ac_objext \
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
     conftest$ac_exeext conftest.$ac_ext
 LIBS=$ac_check_lib_save_LIBS
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_m_pow" >&5
-$as_echo "$ac_cv_lib_m_pow" >&6; }
-if test "x$ac_cv_lib_m_pow" = xyes; then :
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_m_pow" >&5
+printf "%s\n" "$ac_cv_lib_m_pow" >&6; }
+if test "x$ac_cv_lib_m_pow" = xyes
+then :
   POW_LIB=-lm
-else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: cannot find library containing definition of pow" >&5
-$as_echo "$as_me: WARNING: cannot find library containing definition of pow" >&2;}
+else $as_nop
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: cannot find library containing definition of pow" >&5
+printf "%s\n" "$as_me: WARNING: cannot find library containing definition of pow" >&2;}
 fi
 
 fi
 
 fi
 
-for ac_func in vprintf
-do :
-  ac_fn_c_check_func "$LINENO" "vprintf" "ac_cv_func_vprintf"
-if test "x$ac_cv_func_vprintf" = xyes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_VPRINTF 1
-_ACEOF
 
-ac_fn_c_check_func "$LINENO" "_doprnt" "ac_cv_func__doprnt"
-if test "x$ac_cv_func__doprnt" = xyes; then :
 
-$as_echo "#define HAVE_DOPRNT 1" >>confdefs.h
+if test "x$ac_cv_func_vprintf" = xno
+then :
+  ac_fn_c_check_func "$LINENO" "_doprnt" "ac_cv_func__doprnt"
+if test "x$ac_cv_func__doprnt" = xyes
+then :
 
-fi
+printf "%s\n" "#define HAVE_DOPRNT 1" >>confdefs.h
 
 fi
-done
-
 
+fi
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable dependency tracking" >&5
-$as_echo_n "checking whether to enable dependency tracking... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to enable dependency tracking" >&5
+printf %s "checking whether to enable dependency tracking... " >&6; }
 # Check whether --enable-dependency-tracking was given.
-if test "${enable_dependency_tracking+set}" = set; then :
+if test ${enable_dependency_tracking+y}
+then :
   enableval=$enable_dependency_tracking; USE_TRACKING=$enableval
-else
+else $as_nop
   USE_TRACKING=yes
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $USE_TRACKING" >&5
-$as_echo "$USE_TRACKING" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $USE_TRACKING" >&5
+printf "%s\n" "$USE_TRACKING" >&6; }
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build silently" >&5
-$as_echo_n "checking whether to build silently... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to build silently" >&5
+printf %s "checking whether to build silently... " >&6; }
 # Check whether --enable-silent-rules was given.
-if test "${enable_silent_rules+set}" = set; then :
+if test ${enable_silent_rules+y}
+then :
   enableval=$enable_silent_rules; SILENT_RULES=$enableval
-else
+else $as_nop
   SILENT_RULES=yes
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $SILENT_RULES" >&5
-$as_echo "$SILENT_RULES" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $SILENT_RULES" >&5
+printf "%s\n" "$SILENT_RULES" >&6; }
 
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to use static linking" >&5
-$as_echo_n "checking whether to use static linking... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to use static linking" >&5
+printf %s "checking whether to use static linking... " >&6; }
 # Check whether --enable-static_link was given.
-if test "${enable_static_link+set}" = set; then :
+if test ${enable_static_link+y}
+then :
   enableval=$enable_static_link; STATIC_LINK=$enableval
-else
+else $as_nop
   STATIC_LINK=no
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $STATIC_LINK" >&5
-$as_echo "$STATIC_LINK" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $STATIC_LINK" >&5
+printf "%s\n" "$STATIC_LINK" >&6; }
 
 ################################################################################
 
 
     ac_save_CFLAGS=$CFLAGS
     CFLAGS=-pie
-    { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $CC accepts -pie flag" >&5
-$as_echo_n "checking whether $CC accepts -pie flag... " >&6; }
-if ${ac_cv_flag_HAVE_PIE+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether $CC accepts -pie flag" >&5
+printf %s "checking whether $CC accepts -pie flag... " >&6; }
+if test ${ac_cv_flag_HAVE_PIE+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
 int
-main ()
+main (void)
 {
 
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   ac_cv_flag_HAVE_PIE=yes
-else
+else $as_nop
   ac_cv_flag_HAVE_PIE=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_flag_HAVE_PIE" >&5
-$as_echo "$ac_cv_flag_HAVE_PIE" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_flag_HAVE_PIE" >&5
+printf "%s\n" "$ac_cv_flag_HAVE_PIE" >&6; }
     CFLAGS=$ac_save_CFLAGS
     HAVE_PIE=$ac_cv_flag_HAVE_PIE
     if test "HAVE_PIE" = yes; then
@@ -8300,32 +9160,34 @@ $as_echo "$ac_cv_flag_HAVE_PIE" >&6; }
 
     ac_save_LDFLAGS=$LDFLAGS
     LDFLAGS=-Wl,-z,relro,-z,now
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $CC accepts -Wl,-z,relro,-z,now ld flags" >&5
-$as_echo_n "checking whether $CC accepts -Wl,-z,relro,-z,now ld flags... " >&6; }
-if ${ac_cv_flag_HAVE_FULL_RELRO+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether $CC accepts -Wl,-z,relro,-z,now ld flags" >&5
+printf %s "checking whether $CC accepts -Wl,-z,relro,-z,now ld flags... " >&6; }
+if test ${ac_cv_flag_HAVE_FULL_RELRO+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
 int
-main ()
+main (void)
 {
 
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
+if ac_fn_c_try_link "$LINENO"
+then :
   ac_cv_flag_HAVE_FULL_RELRO=yes
-else
+else $as_nop
   ac_cv_flag_HAVE_FULL_RELRO=no
 fi
-rm -f core conftest.err conftest.$ac_objext \
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
     conftest$ac_exeext conftest.$ac_ext
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_flag_HAVE_FULL_RELRO" >&5
-$as_echo "$ac_cv_flag_HAVE_FULL_RELRO" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_flag_HAVE_FULL_RELRO" >&5
+printf "%s\n" "$ac_cv_flag_HAVE_FULL_RELRO" >&6; }
     LDFLAGS=$ac_save_LDFLAGS
     HAVE_FULL_RELRO=$ac_cv_flag_HAVE_FULL_RELRO
     if test "HAVE_FULL_RELRO" = yes; then
@@ -8347,98 +9209,98 @@ test "x$prefix" = xNONE && prefix=$ac_default_prefix
 test "x$exec_prefix" = xNONE && exec_prefix='${prefix}'
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking file owner" >&5
-$as_echo_n "checking file owner... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking file owner" >&5
+printf %s "checking file owner... " >&6; }
 
 # Check whether --with-user was given.
-if test "${with_user+set}" = set; then :
+if test ${with_user+y}
+then :
   withval=$with_user; OWNER=$withval
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $OWNER" >&5
-$as_echo "$OWNER" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $OWNER" >&5
+printf "%s\n" "$OWNER" >&6; }
 test -n "$OWNER" && INSTALL="$INSTALL -o $OWNER"
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking group owner" >&5
-$as_echo_n "checking group owner... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking group owner" >&5
+printf %s "checking group owner... " >&6; }
 
 # Check whether --with-group was given.
-if test "${with_group+set}" = set; then :
+if test ${with_group+y}
+then :
   withval=$with_group; GROUP=$withval
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $GROUP" >&5
-$as_echo "$GROUP" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $GROUP" >&5
+printf "%s\n" "$GROUP" >&6; }
 test -n "$GROUP" && INSTALL="$INSTALL -g $GROUP"
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking device node uid" >&5
-$as_echo_n "checking device node uid... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking device node uid" >&5
+printf %s "checking device node uid... " >&6; }
 
 
 # Check whether --with-device-uid was given.
-if test "${with_device_uid+set}" = set; then :
+if test ${with_device_uid+y}
+then :
   withval=$with_device_uid; DM_DEVICE_UID=$withval
-else
+else $as_nop
   DM_DEVICE_UID=0
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $DM_DEVICE_UID" >&5
-$as_echo "$DM_DEVICE_UID" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $DM_DEVICE_UID" >&5
+printf "%s\n" "$DM_DEVICE_UID" >&6; }
 
-cat >>confdefs.h <<_ACEOF
-#define DM_DEVICE_UID $DM_DEVICE_UID
-_ACEOF
+printf "%s\n" "#define DM_DEVICE_UID $DM_DEVICE_UID" >>confdefs.h
 
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking device node gid" >&5
-$as_echo_n "checking device node gid... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking device node gid" >&5
+printf %s "checking device node gid... " >&6; }
 
 
 # Check whether --with-device-gid was given.
-if test "${with_device_gid+set}" = set; then :
+if test ${with_device_gid+y}
+then :
   withval=$with_device_gid; DM_DEVICE_GID=$withval
-else
+else $as_nop
   DM_DEVICE_GID=0
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $DM_DEVICE_GID" >&5
-$as_echo "$DM_DEVICE_GID" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $DM_DEVICE_GID" >&5
+printf "%s\n" "$DM_DEVICE_GID" >&6; }
 
-cat >>confdefs.h <<_ACEOF
-#define DM_DEVICE_GID $DM_DEVICE_GID
-_ACEOF
+printf "%s\n" "#define DM_DEVICE_GID $DM_DEVICE_GID" >>confdefs.h
 
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking device node mode" >&5
-$as_echo_n "checking device node mode... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking device node mode" >&5
+printf %s "checking device node mode... " >&6; }
 
 
 # Check whether --with-device-mode was given.
-if test "${with_device_mode+set}" = set; then :
+if test ${with_device_mode+y}
+then :
   withval=$with_device_mode; DM_DEVICE_MODE=$withval
-else
+else $as_nop
   DM_DEVICE_MODE=0600
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $DM_DEVICE_MODE" >&5
-$as_echo "$DM_DEVICE_MODE" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $DM_DEVICE_MODE" >&5
+printf "%s\n" "$DM_DEVICE_MODE" >&6; }
 
-cat >>confdefs.h <<_ACEOF
-#define DM_DEVICE_MODE $DM_DEVICE_MODE
-_ACEOF
+printf "%s\n" "#define DM_DEVICE_MODE $DM_DEVICE_MODE" >>confdefs.h
 
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking when to create device nodes" >&5
-$as_echo_n "checking when to create device nodes... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking when to create device nodes" >&5
+printf %s "checking when to create device nodes... " >&6; }
 
 # Check whether --with-device-nodes-on was given.
-if test "${with_device_nodes_on+set}" = set; then :
+if test ${with_device_nodes_on+y}
+then :
   withval=$with_device_nodes_on; ADD_NODE=$withval
-else
+else $as_nop
   ADD_NODE=resume
 fi
 
@@ -8447,22 +9309,21 @@ case "$ADD_NODE" in
  create) add_on=DM_ADD_NODE_ON_CREATE;;
  *) as_fn_error $? "--with-device-nodes-on parameter invalid" "$LINENO" 5;;
 esac
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: on $ADD_NODE" >&5
-$as_echo "on $ADD_NODE" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: on $ADD_NODE" >&5
+printf "%s\n" "on $ADD_NODE" >&6; }
 
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_DM_ADD_NODE $add_on
-_ACEOF
+printf "%s\n" "#define DEFAULT_DM_ADD_NODE $add_on" >>confdefs.h
 
 
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking default for use_devicesfile" >&5
-$as_echo_n "checking default for use_devicesfile... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking default for use_devicesfile" >&5
+printf %s "checking default for use_devicesfile... " >&6; }
 
 # Check whether --with-default-use-devices-file was given.
-if test "${with_default_use_devices_file+set}" = set; then :
+if test ${with_default_use_devices_file+y}
+then :
   withval=$with_default_use_devices_file; DEFAULT_USE_DEVICES_FILE=$withval
-else
+else $as_nop
   DEFAULT_USE_DEVICES_FILE=0
 fi
 
@@ -8470,21 +9331,20 @@ case "$DEFAULT_USE_DEVICES_FILE" in
  0|1);;
  *) as_fn_error $? "--with-default-use-devices-file parameter invalid" "$LINENO" 5;;
 esac
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_USE_DEVICES_FILE" >&5
-$as_echo "$DEFAULT_USE_DEVICES_FILE" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_USE_DEVICES_FILE" >&5
+printf "%s\n" "$DEFAULT_USE_DEVICES_FILE" >&6; }
 
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_USE_DEVICES_FILE $DEFAULT_USE_DEVICES_FILE
-_ACEOF
+printf "%s\n" "#define DEFAULT_USE_DEVICES_FILE $DEFAULT_USE_DEVICES_FILE" >>confdefs.h
 
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking default name mangling" >&5
-$as_echo_n "checking default name mangling... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking default name mangling" >&5
+printf %s "checking default name mangling... " >&6; }
 
 # Check whether --with-default-name-mangling was given.
-if test "${with_default_name_mangling+set}" = set; then :
+if test ${with_default_name_mangling+y}
+then :
   withval=$with_default_name_mangling; MANGLING=$withval
-else
+else $as_nop
   MANGLING=auto
 fi
 
@@ -8494,54 +9354,54 @@ case "$MANGLING" in
  hex) mangling=DM_STRING_MANGLING_HEX;;
  *) as_fn_error $? "--with-default-name-mangling parameter invalid" "$LINENO" 5;;
 esac
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $MANGLING" >&5
-$as_echo "$MANGLING" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $MANGLING" >&5
+printf "%s\n" "$MANGLING" >&6; }
 
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_DM_NAME_MANGLING $mangling
-_ACEOF
+printf "%s\n" "#define DEFAULT_DM_NAME_MANGLING $mangling" >>confdefs.h
 
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include snapshots" >&5
-$as_echo_n "checking whether to include snapshots... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to include snapshots" >&5
+printf %s "checking whether to include snapshots... " >&6; }
 
 # Check whether --with-snapshots was given.
-if test "${with_snapshots+set}" = set; then :
+if test ${with_snapshots+y}
+then :
   withval=$with_snapshots; SNAPSHOTS=$withval
-else
+else $as_nop
   SNAPSHOTS=internal
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $SNAPSHOTS" >&5
-$as_echo "$SNAPSHOTS" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $SNAPSHOTS" >&5
+printf "%s\n" "$SNAPSHOTS" >&6; }
 
 case "$SNAPSHOTS" in
   no|none|shared) ;;
   internal)
-$as_echo "#define SNAPSHOT_INTERNAL 1" >>confdefs.h
+printf "%s\n" "#define SNAPSHOT_INTERNAL 1" >>confdefs.h
  ;;
   *) as_fn_error $? "--with-snapshots parameter invalid" "$LINENO" 5 ;;
 esac
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include mirrors" >&5
-$as_echo_n "checking whether to include mirrors... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to include mirrors" >&5
+printf %s "checking whether to include mirrors... " >&6; }
 
 # Check whether --with-mirrors was given.
-if test "${with_mirrors+set}" = set; then :
+if test ${with_mirrors+y}
+then :
   withval=$with_mirrors; MIRRORS=$withval
-else
+else $as_nop
   MIRRORS=internal
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $MIRRORS" >&5
-$as_echo "$MIRRORS" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $MIRRORS" >&5
+printf "%s\n" "$MIRRORS" >&6; }
 
 case "$MIRRORS" in
   no|none|shared) ;;
   internal)
-$as_echo "#define MIRRORED_INTERNAL 1" >>confdefs.h
+printf "%s\n" "#define MIRRORED_INTERNAL 1" >>confdefs.h
  ;;
   *) as_fn_error $? "--with-mirrors parameter invalid" "$LINENO" 5 ;;
 esac
@@ -8549,116 +9409,119 @@ esac
 ################################################################################
 
 # Check whether --with-default-mirror-segtype was given.
-if test "${with_default_mirror_segtype+set}" = set; then :
+if test ${with_default_mirror_segtype+y}
+then :
   withval=$with_default_mirror_segtype; DEFAULT_MIRROR_SEGTYPE=$withval
-else
+else $as_nop
   DEFAULT_MIRROR_SEGTYPE="raid1"
 fi
 
 
 # Check whether --with-default-raid10-segtype was given.
-if test "${with_default_raid10_segtype+set}" = set; then :
+if test ${with_default_raid10_segtype+y}
+then :
   withval=$with_default_raid10_segtype; DEFAULT_RAID10_SEGTYPE=$withval
-else
+else $as_nop
   DEFAULT_RAID10_SEGTYPE="raid10"
 fi
 
 
 
-$as_echo "#define RAID_INTERNAL 1" >>confdefs.h
+printf "%s\n" "#define RAID_INTERNAL 1" >>confdefs.h
 
 
 
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_MIRROR_SEGTYPE "$DEFAULT_MIRROR_SEGTYPE"
-_ACEOF
+printf "%s\n" "#define DEFAULT_MIRROR_SEGTYPE \"$DEFAULT_MIRROR_SEGTYPE\"" >>confdefs.h
 
 
 
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_RAID10_SEGTYPE "$DEFAULT_RAID10_SEGTYPE"
-_ACEOF
+printf "%s\n" "#define DEFAULT_RAID10_SEGTYPE \"$DEFAULT_RAID10_SEGTYPE\"" >>confdefs.h
 
 
 ################################################################################
 
 # Check whether --with-default-sparse-segtype was given.
-if test "${with_default_sparse_segtype+set}" = set; then :
+if test ${with_default_sparse_segtype+y}
+then :
   withval=$with_default_sparse_segtype;  case "$withval" in
 				thin|snapshot) DEFAULT_SPARSE_SEGTYPE=$withval ;;
 				*) as_fn_error $? "--with-default-sparse-segtype parameter invalid" "$LINENO" 5 ;;
 			     esac
-else
+else $as_nop
   DEFAULT_SPARSE_SEGTYPE="thin"
 fi
 
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include thin provisioning" >&5
-$as_echo_n "checking whether to include thin provisioning... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to include thin provisioning" >&5
+printf %s "checking whether to include thin provisioning... " >&6; }
 
 # Check whether --with-thin was given.
-if test "${with_thin+set}" = set; then :
+if test ${with_thin+y}
+then :
   withval=$with_thin; THIN=$withval
-else
+else $as_nop
   THIN=internal
 fi
 
 
 # Check whether --with-thin-check was given.
-if test "${with_thin_check+set}" = set; then :
+if test ${with_thin_check+y}
+then :
   withval=$with_thin_check; THIN_CHECK_CMD=$withval
-else
+else $as_nop
   THIN_CHECK_CMD="autodetect"
 fi
 
 
 # Check whether --with-thin-dump was given.
-if test "${with_thin_dump+set}" = set; then :
+if test ${with_thin_dump+y}
+then :
   withval=$with_thin_dump; THIN_DUMP_CMD=$withval
-else
+else $as_nop
   THIN_DUMP_CMD="autodetect"
 fi
 
 
 # Check whether --with-thin-repair was given.
-if test "${with_thin_repair+set}" = set; then :
+if test ${with_thin_repair+y}
+then :
   withval=$with_thin_repair; THIN_REPAIR_CMD=$withval
-else
+else $as_nop
   THIN_REPAIR_CMD="autodetect"
 fi
 
 
 # Check whether --with-thin-restore was given.
-if test "${with_thin_restore+set}" = set; then :
+if test ${with_thin_restore+y}
+then :
   withval=$with_thin_restore; THIN_RESTORE_CMD=$withval
-else
+else $as_nop
   THIN_RESTORE_CMD="autodetect"
 fi
 
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $THIN" >&5
-$as_echo "$THIN" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $THIN" >&5
+printf "%s\n" "$THIN" >&6; }
 
 case "$THIN" in
   no|none)  test "$DEFAULT_SPARSE_SEGTYPE" = "thin" && DEFAULT_SPARSE_SEGTYPE="snapshot" ;;
   shared) ;;
   internal)
-$as_echo "#define THIN_INTERNAL 1" >>confdefs.h
+printf "%s\n" "#define THIN_INTERNAL 1" >>confdefs.h
  ;;
   *) as_fn_error $? "--with-thin parameter invalid ($THIN)" "$LINENO" 5 ;;
 esac
 
 
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_SPARSE_SEGTYPE "$DEFAULT_SPARSE_SEGTYPE"
-_ACEOF
+printf "%s\n" "#define DEFAULT_SPARSE_SEGTYPE \"$DEFAULT_SPARSE_SEGTYPE\"" >>confdefs.h
 
 
 # Check whether --enable-thin_check_needs_check was given.
-if test "${enable_thin_check_needs_check+set}" = set; then :
+if test ${enable_thin_check_needs_check+y}
+then :
   enableval=$enable_thin_check_needs_check; THIN_CHECK_NEEDS_CHECK=$enableval
-else
+else $as_nop
   THIN_CHECK_NEEDS_CHECK=yes
 fi
 
@@ -8672,11 +9535,12 @@ case "$THIN" in
 		if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}thin_check", so it can be a program name with args.
 set dummy ${ac_tool_prefix}thin_check; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_THIN_CHECK_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_THIN_CHECK_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $THIN_CHECK_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_THIN_CHECK_CMD="$THIN_CHECK_CMD" # Let the user override the test with a path.
@@ -8686,11 +9550,15 @@ else
 for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_THIN_CHECK_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_THIN_CHECK_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -8702,11 +9570,11 @@ esac
 fi
 THIN_CHECK_CMD=$ac_cv_path_THIN_CHECK_CMD
 if test -n "$THIN_CHECK_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $THIN_CHECK_CMD" >&5
-$as_echo "$THIN_CHECK_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $THIN_CHECK_CMD" >&5
+printf "%s\n" "$THIN_CHECK_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -8715,11 +9583,12 @@ if test -z "$ac_cv_path_THIN_CHECK_CMD"; then
   ac_pt_THIN_CHECK_CMD=$THIN_CHECK_CMD
   # Extract the first word of "thin_check", so it can be a program name with args.
 set dummy thin_check; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_ac_pt_THIN_CHECK_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_ac_pt_THIN_CHECK_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $ac_pt_THIN_CHECK_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_ac_pt_THIN_CHECK_CMD="$ac_pt_THIN_CHECK_CMD" # Let the user override the test with a path.
@@ -8729,11 +9598,15 @@ else
 for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_ac_pt_THIN_CHECK_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_THIN_CHECK_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -8745,11 +9618,11 @@ esac
 fi
 ac_pt_THIN_CHECK_CMD=$ac_cv_path_ac_pt_THIN_CHECK_CMD
 if test -n "$ac_pt_THIN_CHECK_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_THIN_CHECK_CMD" >&5
-$as_echo "$ac_pt_THIN_CHECK_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_pt_THIN_CHECK_CMD" >&5
+printf "%s\n" "$ac_pt_THIN_CHECK_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_pt_THIN_CHECK_CMD" = x; then
@@ -8757,8 +9630,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     THIN_CHECK_CMD=$ac_pt_THIN_CHECK_CMD
@@ -8768,8 +9641,8 @@ else
 fi
 
 		if test -z "$THIN_CHECK_CMD"; then
-			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: thin_check not found in path $PATH" >&5
-$as_echo "$as_me: WARNING: thin_check not found in path $PATH" >&2;}
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: thin_check not found in path $PATH" >&5
+printf "%s\n" "$as_me: WARNING: thin_check not found in path $PATH" >&2;}
 			THIN_CHECK_CMD=/usr/sbin/thin_check
 			THIN_CONFIGURE_WARN=y
 		fi
@@ -8780,13 +9653,13 @@ $as_echo "$as_me: WARNING: thin_check not found in path $PATH" >&2;}
 		THIN_CHECK_VSN_MINOR=`echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $2}'`
 
 		if test -z "$THIN_CHECK_VSN_MAJOR" -o -z "$THIN_CHECK_VSN_MINOR"; then
-			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: $THIN_CHECK_CMD: Bad version \"$THIN_CHECK_VSN\" found" >&5
-$as_echo "$as_me: WARNING: $THIN_CHECK_CMD: Bad version \"$THIN_CHECK_VSN\" found" >&2;}
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: $THIN_CHECK_CMD: Bad version \"$THIN_CHECK_VSN\" found" >&5
+printf "%s\n" "$as_me: WARNING: $THIN_CHECK_CMD: Bad version \"$THIN_CHECK_VSN\" found" >&2;}
 			THIN_CHECK_VERSION_WARN=y
 			THIN_CHECK_NEEDS_CHECK=no
 		elif test "$THIN_CHECK_VSN_MAJOR" -eq 0 -a "$THIN_CHECK_VSN_MINOR" -lt 3; then
-			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: $THIN_CHECK_CMD: Old version \"$THIN_CHECK_VSN\" found" >&5
-$as_echo "$as_me: WARNING: $THIN_CHECK_CMD: Old version \"$THIN_CHECK_VSN\" found" >&2;}
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: $THIN_CHECK_CMD: Old version \"$THIN_CHECK_VSN\" found" >&5
+printf "%s\n" "$as_me: WARNING: $THIN_CHECK_CMD: Old version \"$THIN_CHECK_VSN\" found" >&2;}
 			THIN_CHECK_VERSION_WARN=y
 			THIN_CHECK_NEEDS_CHECK=no
 		fi
@@ -8796,11 +9669,12 @@ $as_echo "$as_me: WARNING: $THIN_CHECK_CMD: Old version \"$THIN_CHECK_VSN\" foun
 		if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}thin_dump", so it can be a program name with args.
 set dummy ${ac_tool_prefix}thin_dump; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_THIN_DUMP_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_THIN_DUMP_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $THIN_DUMP_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_THIN_DUMP_CMD="$THIN_DUMP_CMD" # Let the user override the test with a path.
@@ -8810,11 +9684,15 @@ else
 for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_THIN_DUMP_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_THIN_DUMP_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -8826,11 +9704,11 @@ esac
 fi
 THIN_DUMP_CMD=$ac_cv_path_THIN_DUMP_CMD
 if test -n "$THIN_DUMP_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $THIN_DUMP_CMD" >&5
-$as_echo "$THIN_DUMP_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $THIN_DUMP_CMD" >&5
+printf "%s\n" "$THIN_DUMP_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -8839,11 +9717,12 @@ if test -z "$ac_cv_path_THIN_DUMP_CMD"; then
   ac_pt_THIN_DUMP_CMD=$THIN_DUMP_CMD
   # Extract the first word of "thin_dump", so it can be a program name with args.
 set dummy thin_dump; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_ac_pt_THIN_DUMP_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_ac_pt_THIN_DUMP_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $ac_pt_THIN_DUMP_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_ac_pt_THIN_DUMP_CMD="$ac_pt_THIN_DUMP_CMD" # Let the user override the test with a path.
@@ -8853,11 +9732,15 @@ else
 for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_ac_pt_THIN_DUMP_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_THIN_DUMP_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -8869,11 +9752,11 @@ esac
 fi
 ac_pt_THIN_DUMP_CMD=$ac_cv_path_ac_pt_THIN_DUMP_CMD
 if test -n "$ac_pt_THIN_DUMP_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_THIN_DUMP_CMD" >&5
-$as_echo "$ac_pt_THIN_DUMP_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_pt_THIN_DUMP_CMD" >&5
+printf "%s\n" "$ac_pt_THIN_DUMP_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_pt_THIN_DUMP_CMD" = x; then
@@ -8881,8 +9764,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     THIN_DUMP_CMD=$ac_pt_THIN_DUMP_CMD
@@ -8892,8 +9775,8 @@ else
 fi
 
 		test -z "$THIN_DUMP_CMD" && {
-			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: thin_dump not found in path $PATH" >&5
-$as_echo "$as_me: WARNING: thin_dump not found in path $PATH" >&2;}
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: thin_dump not found in path $PATH" >&5
+printf "%s\n" "$as_me: WARNING: thin_dump not found in path $PATH" >&2;}
 			THIN_DUMP_CMD=/usr/sbin/thin_dump
 			THIN_CONFIGURE_WARN=y
 		}
@@ -8903,11 +9786,12 @@ $as_echo "$as_me: WARNING: thin_dump not found in path $PATH" >&2;}
 		if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}thin_repair", so it can be a program name with args.
 set dummy ${ac_tool_prefix}thin_repair; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_THIN_REPAIR_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_THIN_REPAIR_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $THIN_REPAIR_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_THIN_REPAIR_CMD="$THIN_REPAIR_CMD" # Let the user override the test with a path.
@@ -8917,11 +9801,15 @@ else
 for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_THIN_REPAIR_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_THIN_REPAIR_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -8933,11 +9821,11 @@ esac
 fi
 THIN_REPAIR_CMD=$ac_cv_path_THIN_REPAIR_CMD
 if test -n "$THIN_REPAIR_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $THIN_REPAIR_CMD" >&5
-$as_echo "$THIN_REPAIR_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $THIN_REPAIR_CMD" >&5
+printf "%s\n" "$THIN_REPAIR_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -8946,11 +9834,12 @@ if test -z "$ac_cv_path_THIN_REPAIR_CMD"; then
   ac_pt_THIN_REPAIR_CMD=$THIN_REPAIR_CMD
   # Extract the first word of "thin_repair", so it can be a program name with args.
 set dummy thin_repair; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_ac_pt_THIN_REPAIR_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_ac_pt_THIN_REPAIR_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $ac_pt_THIN_REPAIR_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_ac_pt_THIN_REPAIR_CMD="$ac_pt_THIN_REPAIR_CMD" # Let the user override the test with a path.
@@ -8960,11 +9849,15 @@ else
 for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_ac_pt_THIN_REPAIR_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_THIN_REPAIR_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -8976,11 +9869,11 @@ esac
 fi
 ac_pt_THIN_REPAIR_CMD=$ac_cv_path_ac_pt_THIN_REPAIR_CMD
 if test -n "$ac_pt_THIN_REPAIR_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_THIN_REPAIR_CMD" >&5
-$as_echo "$ac_pt_THIN_REPAIR_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_pt_THIN_REPAIR_CMD" >&5
+printf "%s\n" "$ac_pt_THIN_REPAIR_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_pt_THIN_REPAIR_CMD" = x; then
@@ -8988,8 +9881,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     THIN_REPAIR_CMD=$ac_pt_THIN_REPAIR_CMD
@@ -8999,8 +9892,8 @@ else
 fi
 
 		test -z "$THIN_REPAIR_CMD" && {
-			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: thin_repair not found in path $PATH" >&5
-$as_echo "$as_me: WARNING: thin_repair not found in path $PATH" >&2;}
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: thin_repair not found in path $PATH" >&5
+printf "%s\n" "$as_me: WARNING: thin_repair not found in path $PATH" >&2;}
 			THIN_REPAIR_CMD=/usr/sbin/thin_repair
 			THIN_CONFIGURE_WARN=y
 		}
@@ -9010,11 +9903,12 @@ $as_echo "$as_me: WARNING: thin_repair not found in path $PATH" >&2;}
 		if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}thin_restore", so it can be a program name with args.
 set dummy ${ac_tool_prefix}thin_restore; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_THIN_RESTORE_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_THIN_RESTORE_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $THIN_RESTORE_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_THIN_RESTORE_CMD="$THIN_RESTORE_CMD" # Let the user override the test with a path.
@@ -9024,11 +9918,15 @@ else
 for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_THIN_RESTORE_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_THIN_RESTORE_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -9040,11 +9938,11 @@ esac
 fi
 THIN_RESTORE_CMD=$ac_cv_path_THIN_RESTORE_CMD
 if test -n "$THIN_RESTORE_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $THIN_RESTORE_CMD" >&5
-$as_echo "$THIN_RESTORE_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $THIN_RESTORE_CMD" >&5
+printf "%s\n" "$THIN_RESTORE_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -9053,11 +9951,12 @@ if test -z "$ac_cv_path_THIN_RESTORE_CMD"; then
   ac_pt_THIN_RESTORE_CMD=$THIN_RESTORE_CMD
   # Extract the first word of "thin_restore", so it can be a program name with args.
 set dummy thin_restore; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_ac_pt_THIN_RESTORE_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_ac_pt_THIN_RESTORE_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $ac_pt_THIN_RESTORE_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_ac_pt_THIN_RESTORE_CMD="$ac_pt_THIN_RESTORE_CMD" # Let the user override the test with a path.
@@ -9067,11 +9966,15 @@ else
 for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_ac_pt_THIN_RESTORE_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_THIN_RESTORE_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -9083,11 +9986,11 @@ esac
 fi
 ac_pt_THIN_RESTORE_CMD=$ac_cv_path_ac_pt_THIN_RESTORE_CMD
 if test -n "$ac_pt_THIN_RESTORE_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_THIN_RESTORE_CMD" >&5
-$as_echo "$ac_pt_THIN_RESTORE_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_pt_THIN_RESTORE_CMD" >&5
+printf "%s\n" "$ac_pt_THIN_RESTORE_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_pt_THIN_RESTORE_CMD" = x; then
@@ -9095,8 +9998,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     THIN_RESTORE_CMD=$ac_pt_THIN_RESTORE_CMD
@@ -9106,107 +10009,105 @@ else
 fi
 
 		test -z "$THIN_RESTORE_CMD" && {
-			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: thin_restore not found in path $PATH" >&5
-$as_echo "$as_me: WARNING: thin_restore not found in path $PATH" >&2;}
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: thin_restore not found in path $PATH" >&5
+printf "%s\n" "$as_me: WARNING: thin_restore not found in path $PATH" >&2;}
 			THIN_RESTORE_CMD=/usr/sbin/thin_restore
 			THIN_CONFIGURE_WARN=y
 		}
 	fi
 
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether thin_check supports the needs-check flag" >&5
-$as_echo_n "checking whether thin_check supports the needs-check flag... " >&6; }
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $THIN_CHECK_NEEDS_CHECK" >&5
-$as_echo "$THIN_CHECK_NEEDS_CHECK" >&6; }
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether thin_check supports the needs-check flag" >&5
+printf %s "checking whether thin_check supports the needs-check flag... " >&6; }
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $THIN_CHECK_NEEDS_CHECK" >&5
+printf "%s\n" "$THIN_CHECK_NEEDS_CHECK" >&6; }
 	if test "$THIN_CHECK_NEEDS_CHECK" = yes; then
 
-$as_echo "#define THIN_CHECK_NEEDS_CHECK 1" >>confdefs.h
+printf "%s\n" "#define THIN_CHECK_NEEDS_CHECK 1" >>confdefs.h
 
 	fi
 	;;
 esac
 
 
-cat >>confdefs.h <<_ACEOF
-#define THIN_CHECK_CMD "$THIN_CHECK_CMD"
-_ACEOF
+printf "%s\n" "#define THIN_CHECK_CMD \"$THIN_CHECK_CMD\"" >>confdefs.h
 
 
 
-cat >>confdefs.h <<_ACEOF
-#define THIN_DUMP_CMD "$THIN_DUMP_CMD"
-_ACEOF
+printf "%s\n" "#define THIN_DUMP_CMD \"$THIN_DUMP_CMD\"" >>confdefs.h
 
 
 
-cat >>confdefs.h <<_ACEOF
-#define THIN_REPAIR_CMD "$THIN_REPAIR_CMD"
-_ACEOF
+printf "%s\n" "#define THIN_REPAIR_CMD \"$THIN_REPAIR_CMD\"" >>confdefs.h
 
 
 
-cat >>confdefs.h <<_ACEOF
-#define THIN_RESTORE_CMD "$THIN_RESTORE_CMD"
-_ACEOF
+printf "%s\n" "#define THIN_RESTORE_CMD \"$THIN_RESTORE_CMD\"" >>confdefs.h
 
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include cache" >&5
-$as_echo_n "checking whether to include cache... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to include cache" >&5
+printf %s "checking whether to include cache... " >&6; }
 
 # Check whether --with-cache was given.
-if test "${with_cache+set}" = set; then :
+if test ${with_cache+y}
+then :
   withval=$with_cache; CACHE=$withval
-else
+else $as_nop
   CACHE="internal"
 fi
 
 
 # Check whether --with-cache-check was given.
-if test "${with_cache_check+set}" = set; then :
+if test ${with_cache_check+y}
+then :
   withval=$with_cache_check; CACHE_CHECK_CMD=$withval
-else
+else $as_nop
   CACHE_CHECK_CMD="autodetect"
 fi
 
 
 # Check whether --with-cache-dump was given.
-if test "${with_cache_dump+set}" = set; then :
+if test ${with_cache_dump+y}
+then :
   withval=$with_cache_dump; CACHE_DUMP_CMD=$withval
-else
+else $as_nop
   CACHE_DUMP_CMD="autodetect"
 fi
 
 
 # Check whether --with-cache-repair was given.
-if test "${with_cache_repair+set}" = set; then :
+if test ${with_cache_repair+y}
+then :
   withval=$with_cache_repair; CACHE_REPAIR_CMD=$withval
-else
+else $as_nop
   CACHE_REPAIR_CMD="autodetect"
 fi
 
 
 # Check whether --with-cache-restore was given.
-if test "${with_cache_restore+set}" = set; then :
+if test ${with_cache_restore+y}
+then :
   withval=$with_cache_restore; CACHE_RESTORE_CMD=$withval
-else
+else $as_nop
   CACHE_RESTORE_CMD="autodetect"
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $CACHE" >&5
-$as_echo "$CACHE" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CACHE" >&5
+printf "%s\n" "$CACHE" >&6; }
 
 case "$CACHE" in
  no|none|shared) ;;
  internal)
-$as_echo "#define CACHE_INTERNAL 1" >>confdefs.h
+printf "%s\n" "#define CACHE_INTERNAL 1" >>confdefs.h
  ;;
  *) as_fn_error $? "--with-cache parameter invalid" "$LINENO" 5 ;;
 esac
 
 # Check whether --enable-cache_check_needs_check was given.
-if test "${enable_cache_check_needs_check+set}" = set; then :
+if test ${enable_cache_check_needs_check+y}
+then :
   enableval=$enable_cache_check_needs_check; CACHE_CHECK_NEEDS_CHECK=$enableval
-else
+else $as_nop
   CACHE_CHECK_NEEDS_CHECK=yes
 fi
 
@@ -9220,11 +10121,12 @@ case "$CACHE" in
 		if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}cache_check", so it can be a program name with args.
 set dummy ${ac_tool_prefix}cache_check; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_CACHE_CHECK_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_CACHE_CHECK_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $CACHE_CHECK_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_CACHE_CHECK_CMD="$CACHE_CHECK_CMD" # Let the user override the test with a path.
@@ -9234,11 +10136,15 @@ else
 for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_CACHE_CHECK_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_CACHE_CHECK_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -9250,11 +10156,11 @@ esac
 fi
 CACHE_CHECK_CMD=$ac_cv_path_CACHE_CHECK_CMD
 if test -n "$CACHE_CHECK_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CACHE_CHECK_CMD" >&5
-$as_echo "$CACHE_CHECK_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CACHE_CHECK_CMD" >&5
+printf "%s\n" "$CACHE_CHECK_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -9263,11 +10169,12 @@ if test -z "$ac_cv_path_CACHE_CHECK_CMD"; then
   ac_pt_CACHE_CHECK_CMD=$CACHE_CHECK_CMD
   # Extract the first word of "cache_check", so it can be a program name with args.
 set dummy cache_check; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_ac_pt_CACHE_CHECK_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_ac_pt_CACHE_CHECK_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $ac_pt_CACHE_CHECK_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_ac_pt_CACHE_CHECK_CMD="$ac_pt_CACHE_CHECK_CMD" # Let the user override the test with a path.
@@ -9277,11 +10184,15 @@ else
 for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_ac_pt_CACHE_CHECK_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_CACHE_CHECK_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -9293,11 +10204,11 @@ esac
 fi
 ac_pt_CACHE_CHECK_CMD=$ac_cv_path_ac_pt_CACHE_CHECK_CMD
 if test -n "$ac_pt_CACHE_CHECK_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_CACHE_CHECK_CMD" >&5
-$as_echo "$ac_pt_CACHE_CHECK_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_pt_CACHE_CHECK_CMD" >&5
+printf "%s\n" "$ac_pt_CACHE_CHECK_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_pt_CACHE_CHECK_CMD" = x; then
@@ -9305,8 +10216,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     CACHE_CHECK_CMD=$ac_pt_CACHE_CHECK_CMD
@@ -9316,8 +10227,8 @@ else
 fi
 
 		if test -z "$CACHE_CHECK_CMD"; then
-			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: cache_check not found in path $PATH" >&5
-$as_echo "$as_me: WARNING: cache_check not found in path $PATH" >&2;}
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: cache_check not found in path $PATH" >&5
+printf "%s\n" "$as_me: WARNING: cache_check not found in path $PATH" >&2;}
 			CACHE_CHECK_CMD=/usr/sbin/cache_check
 			CACHE_CONFIGURE_WARN=y
 		fi
@@ -9332,21 +10243,21 @@ $as_echo "$as_me: WARNING: cache_check not found in path $PATH" >&2;}
 		if test -z "$CACHE_CHECK_VSN_MAJOR" \
 			|| test -z "$CACHE_CHECK_VSN_MINOR" \
 			|| test -z "$CACHE_CHECK_VSN_PATCH"; then
-			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: $CACHE_CHECK_CMD: Bad version \"$CACHE_CHECK_VSN\" found" >&5
-$as_echo "$as_me: WARNING: $CACHE_CHECK_CMD: Bad version \"$CACHE_CHECK_VSN\" found" >&2;}
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: $CACHE_CHECK_CMD: Bad version \"$CACHE_CHECK_VSN\" found" >&5
+printf "%s\n" "$as_me: WARNING: $CACHE_CHECK_CMD: Bad version \"$CACHE_CHECK_VSN\" found" >&2;}
 			CACHE_CHECK_VERSION_WARN=y
 			CACHE_CHECK_NEEDS_CHECK=no
 		elif test "$CACHE_CHECK_VSN_MAJOR" -eq 0 ; then
 			if test "$CACHE_CHECK_VSN_MINOR" -lt 5 \
 				|| test "$CACHE_CHECK_VSN_MINOR" -eq 5 -a "$CACHE_CHECK_VSN_PATCH" -lt 4; then
-				{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: $CACHE_CHECK_CMD: Old version \"$CACHE_CHECK_VSN\" found" >&5
-$as_echo "$as_me: WARNING: $CACHE_CHECK_CMD: Old version \"$CACHE_CHECK_VSN\" found" >&2;}
+				{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: $CACHE_CHECK_CMD: Old version \"$CACHE_CHECK_VSN\" found" >&5
+printf "%s\n" "$as_me: WARNING: $CACHE_CHECK_CMD: Old version \"$CACHE_CHECK_VSN\" found" >&2;}
 				CACHE_CHECK_VERSION_WARN=y
 				CACHE_CHECK_NEEDS_CHECK=no
 			fi
 			if test "$CACHE_CHECK_VSN_MINOR" -lt 7 ; then
-				{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: $CACHE_CHECK_CMD: Old version \"$CACHE_CHECK_VSN\" does not support new cache format V2" >&5
-$as_echo "$as_me: WARNING: $CACHE_CHECK_CMD: Old version \"$CACHE_CHECK_VSN\" does not support new cache format V2" >&2;}
+				{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: $CACHE_CHECK_CMD: Old version \"$CACHE_CHECK_VSN\" does not support new cache format V2" >&5
+printf "%s\n" "$as_me: WARNING: $CACHE_CHECK_CMD: Old version \"$CACHE_CHECK_VSN\" does not support new cache format V2" >&2;}
 				CACHE_CHECK_VERSION_WARN=y
 			fi
 		fi
@@ -9356,11 +10267,12 @@ $as_echo "$as_me: WARNING: $CACHE_CHECK_CMD: Old version \"$CACHE_CHECK_VSN\" do
 		if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}cache_dump", so it can be a program name with args.
 set dummy ${ac_tool_prefix}cache_dump; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_CACHE_DUMP_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_CACHE_DUMP_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $CACHE_DUMP_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_CACHE_DUMP_CMD="$CACHE_DUMP_CMD" # Let the user override the test with a path.
@@ -9370,11 +10282,15 @@ else
 for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_CACHE_DUMP_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_CACHE_DUMP_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -9386,11 +10302,11 @@ esac
 fi
 CACHE_DUMP_CMD=$ac_cv_path_CACHE_DUMP_CMD
 if test -n "$CACHE_DUMP_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CACHE_DUMP_CMD" >&5
-$as_echo "$CACHE_DUMP_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CACHE_DUMP_CMD" >&5
+printf "%s\n" "$CACHE_DUMP_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -9399,11 +10315,12 @@ if test -z "$ac_cv_path_CACHE_DUMP_CMD"; then
   ac_pt_CACHE_DUMP_CMD=$CACHE_DUMP_CMD
   # Extract the first word of "cache_dump", so it can be a program name with args.
 set dummy cache_dump; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_ac_pt_CACHE_DUMP_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_ac_pt_CACHE_DUMP_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $ac_pt_CACHE_DUMP_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_ac_pt_CACHE_DUMP_CMD="$ac_pt_CACHE_DUMP_CMD" # Let the user override the test with a path.
@@ -9413,11 +10330,15 @@ else
 for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_ac_pt_CACHE_DUMP_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_CACHE_DUMP_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -9429,11 +10350,11 @@ esac
 fi
 ac_pt_CACHE_DUMP_CMD=$ac_cv_path_ac_pt_CACHE_DUMP_CMD
 if test -n "$ac_pt_CACHE_DUMP_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_CACHE_DUMP_CMD" >&5
-$as_echo "$ac_pt_CACHE_DUMP_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_pt_CACHE_DUMP_CMD" >&5
+printf "%s\n" "$ac_pt_CACHE_DUMP_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_pt_CACHE_DUMP_CMD" = x; then
@@ -9441,8 +10362,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     CACHE_DUMP_CMD=$ac_pt_CACHE_DUMP_CMD
@@ -9452,8 +10373,8 @@ else
 fi
 
 		test -z "$CACHE_DUMP_CMD" && {
-			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: cache_dump not found in path $PATH" >&5
-$as_echo "$as_me: WARNING: cache_dump not found in path $PATH" >&2;}
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: cache_dump not found in path $PATH" >&5
+printf "%s\n" "$as_me: WARNING: cache_dump not found in path $PATH" >&2;}
 			CACHE_DUMP_CMD=/usr/sbin/cache_dump
 			CACHE_CONFIGURE_WARN=y
 		}
@@ -9463,11 +10384,12 @@ $as_echo "$as_me: WARNING: cache_dump not found in path $PATH" >&2;}
 		if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}cache_repair", so it can be a program name with args.
 set dummy ${ac_tool_prefix}cache_repair; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_CACHE_REPAIR_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_CACHE_REPAIR_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $CACHE_REPAIR_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_CACHE_REPAIR_CMD="$CACHE_REPAIR_CMD" # Let the user override the test with a path.
@@ -9477,11 +10399,15 @@ else
 for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_CACHE_REPAIR_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_CACHE_REPAIR_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -9493,11 +10419,11 @@ esac
 fi
 CACHE_REPAIR_CMD=$ac_cv_path_CACHE_REPAIR_CMD
 if test -n "$CACHE_REPAIR_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CACHE_REPAIR_CMD" >&5
-$as_echo "$CACHE_REPAIR_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CACHE_REPAIR_CMD" >&5
+printf "%s\n" "$CACHE_REPAIR_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -9506,11 +10432,12 @@ if test -z "$ac_cv_path_CACHE_REPAIR_CMD"; then
   ac_pt_CACHE_REPAIR_CMD=$CACHE_REPAIR_CMD
   # Extract the first word of "cache_repair", so it can be a program name with args.
 set dummy cache_repair; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_ac_pt_CACHE_REPAIR_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_ac_pt_CACHE_REPAIR_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $ac_pt_CACHE_REPAIR_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_ac_pt_CACHE_REPAIR_CMD="$ac_pt_CACHE_REPAIR_CMD" # Let the user override the test with a path.
@@ -9520,11 +10447,15 @@ else
 for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_ac_pt_CACHE_REPAIR_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_CACHE_REPAIR_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -9536,11 +10467,11 @@ esac
 fi
 ac_pt_CACHE_REPAIR_CMD=$ac_cv_path_ac_pt_CACHE_REPAIR_CMD
 if test -n "$ac_pt_CACHE_REPAIR_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_CACHE_REPAIR_CMD" >&5
-$as_echo "$ac_pt_CACHE_REPAIR_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_pt_CACHE_REPAIR_CMD" >&5
+printf "%s\n" "$ac_pt_CACHE_REPAIR_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_pt_CACHE_REPAIR_CMD" = x; then
@@ -9548,8 +10479,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     CACHE_REPAIR_CMD=$ac_pt_CACHE_REPAIR_CMD
@@ -9559,8 +10490,8 @@ else
 fi
 
 		test -z "$CACHE_REPAIR_CMD" && {
-			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: cache_repair not found in path $PATH" >&5
-$as_echo "$as_me: WARNING: cache_repair not found in path $PATH" >&2;}
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: cache_repair not found in path $PATH" >&5
+printf "%s\n" "$as_me: WARNING: cache_repair not found in path $PATH" >&2;}
 			CACHE_REPAIR_CMD=/usr/sbin/cache_repair
 			CACHE_CONFIGURE_WARN=y
 		}
@@ -9570,11 +10501,12 @@ $as_echo "$as_me: WARNING: cache_repair not found in path $PATH" >&2;}
 		if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}cache_restore", so it can be a program name with args.
 set dummy ${ac_tool_prefix}cache_restore; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_CACHE_RESTORE_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_CACHE_RESTORE_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $CACHE_RESTORE_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_CACHE_RESTORE_CMD="$CACHE_RESTORE_CMD" # Let the user override the test with a path.
@@ -9584,11 +10516,15 @@ else
 for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_CACHE_RESTORE_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_CACHE_RESTORE_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -9600,11 +10536,11 @@ esac
 fi
 CACHE_RESTORE_CMD=$ac_cv_path_CACHE_RESTORE_CMD
 if test -n "$CACHE_RESTORE_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CACHE_RESTORE_CMD" >&5
-$as_echo "$CACHE_RESTORE_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CACHE_RESTORE_CMD" >&5
+printf "%s\n" "$CACHE_RESTORE_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -9613,11 +10549,12 @@ if test -z "$ac_cv_path_CACHE_RESTORE_CMD"; then
   ac_pt_CACHE_RESTORE_CMD=$CACHE_RESTORE_CMD
   # Extract the first word of "cache_restore", so it can be a program name with args.
 set dummy cache_restore; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_ac_pt_CACHE_RESTORE_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_ac_pt_CACHE_RESTORE_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $ac_pt_CACHE_RESTORE_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_ac_pt_CACHE_RESTORE_CMD="$ac_pt_CACHE_RESTORE_CMD" # Let the user override the test with a path.
@@ -9627,11 +10564,15 @@ else
 for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_ac_pt_CACHE_RESTORE_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_CACHE_RESTORE_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -9643,11 +10584,11 @@ esac
 fi
 ac_pt_CACHE_RESTORE_CMD=$ac_cv_path_ac_pt_CACHE_RESTORE_CMD
 if test -n "$ac_pt_CACHE_RESTORE_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_CACHE_RESTORE_CMD" >&5
-$as_echo "$ac_pt_CACHE_RESTORE_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_pt_CACHE_RESTORE_CMD" >&5
+printf "%s\n" "$ac_pt_CACHE_RESTORE_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_pt_CACHE_RESTORE_CMD" = x; then
@@ -9655,8 +10596,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     CACHE_RESTORE_CMD=$ac_pt_CACHE_RESTORE_CMD
@@ -9666,69 +10607,63 @@ else
 fi
 
 		test -z "$CACHE_RESTORE_CMD" && {
-			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: cache_restore not found in path $PATH" >&5
-$as_echo "$as_me: WARNING: cache_restore not found in path $PATH" >&2;}
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: cache_restore not found in path $PATH" >&5
+printf "%s\n" "$as_me: WARNING: cache_restore not found in path $PATH" >&2;}
 			CACHE_RESTORE_CMD=/usr/sbin/cache_restore
 			CACHE_CONFIGURE_WARN=y
 		}
 	fi
 
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether cache_check supports the needs-check flag" >&5
-$as_echo_n "checking whether cache_check supports the needs-check flag... " >&6; }
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $CACHE_CHECK_NEEDS_CHECK" >&5
-$as_echo "$CACHE_CHECK_NEEDS_CHECK" >&6; }
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether cache_check supports the needs-check flag" >&5
+printf %s "checking whether cache_check supports the needs-check flag... " >&6; }
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CACHE_CHECK_NEEDS_CHECK" >&5
+printf "%s\n" "$CACHE_CHECK_NEEDS_CHECK" >&6; }
 	if test "$CACHE_CHECK_NEEDS_CHECK" = yes; then
 
-$as_echo "#define CACHE_CHECK_NEEDS_CHECK 1" >>confdefs.h
+printf "%s\n" "#define CACHE_CHECK_NEEDS_CHECK 1" >>confdefs.h
 
 	fi
 	;;
 esac
 
 
-cat >>confdefs.h <<_ACEOF
-#define CACHE_CHECK_CMD "$CACHE_CHECK_CMD"
-_ACEOF
+printf "%s\n" "#define CACHE_CHECK_CMD \"$CACHE_CHECK_CMD\"" >>confdefs.h
 
 
 
-cat >>confdefs.h <<_ACEOF
-#define CACHE_DUMP_CMD "$CACHE_DUMP_CMD"
-_ACEOF
+printf "%s\n" "#define CACHE_DUMP_CMD \"$CACHE_DUMP_CMD\"" >>confdefs.h
 
 
 
-cat >>confdefs.h <<_ACEOF
-#define CACHE_REPAIR_CMD "$CACHE_REPAIR_CMD"
-_ACEOF
+printf "%s\n" "#define CACHE_REPAIR_CMD \"$CACHE_REPAIR_CMD\"" >>confdefs.h
 
 
 
-cat >>confdefs.h <<_ACEOF
-#define CACHE_RESTORE_CMD "$CACHE_RESTORE_CMD"
-_ACEOF
+printf "%s\n" "#define CACHE_RESTORE_CMD \"$CACHE_RESTORE_CMD\"" >>confdefs.h
 
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include vdo" >&5
-$as_echo_n "checking whether to include vdo... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to include vdo" >&5
+printf %s "checking whether to include vdo... " >&6; }
 
 # Check whether --with-vdo was given.
-if test "${with_vdo+set}" = set; then :
+if test ${with_vdo+y}
+then :
   withval=$with_vdo; VDO=$withval
-else
+else $as_nop
   VDO="internal"
 fi
 
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $VDO" >&5
-$as_echo "$VDO" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $VDO" >&5
+printf "%s\n" "$VDO" >&6; }
 
 
 # Check whether --with-vdo-format was given.
-if test "${with_vdo_format+set}" = set; then :
+if test ${with_vdo_format+y}
+then :
   withval=$with_vdo_format; VDO_FORMAT_CMD=$withval
-else
+else $as_nop
   VDO_FORMAT_CMD="autodetect"
 fi
 
@@ -9736,17 +10671,18 @@ case "$VDO" in
  no|none) ;;
  internal)
 
-$as_echo "#define VDO_INTERNAL 1" >>confdefs.h
+printf "%s\n" "#define VDO_INTERNAL 1" >>confdefs.h
 
 	if test "$VDO_FORMAT_CMD" = "autodetect"; then
 		if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}vdoformat", so it can be a program name with args.
 set dummy ${ac_tool_prefix}vdoformat; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_VDO_FORMAT_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_VDO_FORMAT_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $VDO_FORMAT_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_VDO_FORMAT_CMD="$VDO_FORMAT_CMD" # Let the user override the test with a path.
@@ -9756,11 +10692,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_VDO_FORMAT_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_VDO_FORMAT_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -9772,11 +10712,11 @@ esac
 fi
 VDO_FORMAT_CMD=$ac_cv_path_VDO_FORMAT_CMD
 if test -n "$VDO_FORMAT_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $VDO_FORMAT_CMD" >&5
-$as_echo "$VDO_FORMAT_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $VDO_FORMAT_CMD" >&5
+printf "%s\n" "$VDO_FORMAT_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -9785,11 +10725,12 @@ if test -z "$ac_cv_path_VDO_FORMAT_CMD"; then
   ac_pt_VDO_FORMAT_CMD=$VDO_FORMAT_CMD
   # Extract the first word of "vdoformat", so it can be a program name with args.
 set dummy vdoformat; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_ac_pt_VDO_FORMAT_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_ac_pt_VDO_FORMAT_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $ac_pt_VDO_FORMAT_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_ac_pt_VDO_FORMAT_CMD="$ac_pt_VDO_FORMAT_CMD" # Let the user override the test with a path.
@@ -9799,11 +10740,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_ac_pt_VDO_FORMAT_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_VDO_FORMAT_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -9815,11 +10760,11 @@ esac
 fi
 ac_pt_VDO_FORMAT_CMD=$ac_cv_path_ac_pt_VDO_FORMAT_CMD
 if test -n "$ac_pt_VDO_FORMAT_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_VDO_FORMAT_CMD" >&5
-$as_echo "$ac_pt_VDO_FORMAT_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_pt_VDO_FORMAT_CMD" >&5
+printf "%s\n" "$ac_pt_VDO_FORMAT_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_pt_VDO_FORMAT_CMD" = x; then
@@ -9827,8 +10772,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     VDO_FORMAT_CMD=$ac_pt_VDO_FORMAT_CMD
@@ -9838,8 +10783,8 @@ else
 fi
 
 		if test -z "$VDO_FORMAT_CMD"; then
-			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: vdoformat not found in path $PATH" >&5
-$as_echo "$as_me: WARNING: vdoformat not found in path $PATH" >&2;}
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: vdoformat not found in path $PATH" >&5
+printf "%s\n" "$as_me: WARNING: vdoformat not found in path $PATH" >&2;}
 			VDO_FORMAT_CMD=/usr/bin/vdoformat
 			VDO_CONFIGURE_WARN=y
 		fi
@@ -9849,9 +10794,7 @@ $as_echo "$as_me: WARNING: vdoformat not found in path $PATH" >&2;}
 esac
 
 
-cat >>confdefs.h <<_ACEOF
-#define VDO_FORMAT_CMD "$VDO_FORMAT_CMD"
-_ACEOF
+printf "%s\n" "#define VDO_FORMAT_CMD \"$VDO_FORMAT_CMD\"" >>confdefs.h
 
 #
 # Do we need to use the API??
@@ -9870,50 +10813,52 @@ _ACEOF
 #AC_MSG_RESULT($VDO_LIB)
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include writecache" >&5
-$as_echo_n "checking whether to include writecache... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to include writecache" >&5
+printf %s "checking whether to include writecache... " >&6; }
 
 # Check whether --with-writecache was given.
-if test "${with_writecache+set}" = set; then :
+if test ${with_writecache+y}
+then :
   withval=$with_writecache; WRITECACHE=$withval
-else
+else $as_nop
   WRITECACHE="internal"
 fi
 
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $WRITECACHE" >&5
-$as_echo "$WRITECACHE" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $WRITECACHE" >&5
+printf "%s\n" "$WRITECACHE" >&6; }
 
 case "$WRITECACHE" in
  no|none) ;;
  internal)
 
-$as_echo "#define WRITECACHE_INTERNAL 1" >>confdefs.h
+printf "%s\n" "#define WRITECACHE_INTERNAL 1" >>confdefs.h
 
 	;;
  *) as_fn_error $? "--with-writecache parameter invalid" "$LINENO" 5 ;;
 esac
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include integrity" >&5
-$as_echo_n "checking whether to include integrity... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to include integrity" >&5
+printf %s "checking whether to include integrity... " >&6; }
 
 # Check whether --with-integrity was given.
-if test "${with_integrity+set}" = set; then :
+if test ${with_integrity+y}
+then :
   withval=$with_integrity; INTEGRITY=$withval
-else
+else $as_nop
   INTEGRITY="internal"
 fi
 
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $INTEGRITY" >&5
-$as_echo "$INTEGRITY" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $INTEGRITY" >&5
+printf "%s\n" "$INTEGRITY" >&6; }
 
 case "$INTEGRITY" in
  no|none) ;;
  internal)
 
-$as_echo "#define INTEGRITY_INTERNAL 1" >>confdefs.h
+printf "%s\n" "#define INTEGRITY_INTERNAL 1" >>confdefs.h
 
 	;;
  *) as_fn_error $? "--with-integrity parameter invalid" "$LINENO" 5 ;;
@@ -9929,52 +10874,57 @@ AIO_LIBS=${AIO_LIBS:--laio}
 
 ################################################################################
 # Check whether --enable-readline was given.
-if test "${enable_readline+set}" = set; then :
+if test ${enable_readline+y}
+then :
   enableval=$enable_readline; READLINE=$enableval
-else
+else $as_nop
   READLINE=maybe
 fi
 
 
 ################################################################################
 # Check whether --enable-editline was given.
-if test "${enable_editline+set}" = set; then :
+if test ${enable_editline+y}
+then :
   enableval=$enable_editline; EDITLINE=$enableval
-else
+else $as_nop
   EDITLINE=no
 fi
 
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable realtime support" >&5
-$as_echo_n "checking whether to enable realtime support... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to enable realtime support" >&5
+printf %s "checking whether to enable realtime support... " >&6; }
 # Check whether --enable-realtime was given.
-if test "${enable_realtime+set}" = set; then :
+if test ${enable_realtime+y}
+then :
   enableval=$enable_realtime; REALTIME=$enableval
-else
+else $as_nop
   REALTIME=yes
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $REALTIME" >&5
-$as_echo "$REALTIME" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $REALTIME" >&5
+printf "%s\n" "$REALTIME" >&6; }
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable OCF resource agents" >&5
-$as_echo_n "checking whether to enable OCF resource agents... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to enable OCF resource agents" >&5
+printf %s "checking whether to enable OCF resource agents... " >&6; }
 # Check whether --enable-ocf was given.
-if test "${enable_ocf+set}" = set; then :
+if test ${enable_ocf+y}
+then :
   enableval=$enable_ocf; OCF=$enableval
-else
+else $as_nop
   OCF=no
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $OCF" >&5
-$as_echo "$OCF" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $OCF" >&5
+printf "%s\n" "$OCF" >&6; }
 
 # Check whether --with-ocfdir was given.
-if test "${with_ocfdir+set}" = set; then :
+if test ${with_ocfdir+y}
+then :
   withval=$with_ocfdir; OCFDIR=$withval
-else
+else $as_nop
   OCFDIR='${prefix}/lib/ocf/resource.d/lvm2'
 fi
 
@@ -9993,11 +10943,12 @@ if test "x$ac_cv_env_PKG_CONFIG_set" != "xset"; then
 	if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}pkg-config", so it can be a program name with args.
 set dummy ${ac_tool_prefix}pkg-config; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_PKG_CONFIG+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_PKG_CONFIG+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $PKG_CONFIG in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_PKG_CONFIG="$PKG_CONFIG" # Let the user override the test with a path.
@@ -10007,11 +10958,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_PKG_CONFIG="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_PKG_CONFIG="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -10023,11 +10978,11 @@ esac
 fi
 PKG_CONFIG=$ac_cv_path_PKG_CONFIG
 if test -n "$PKG_CONFIG"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $PKG_CONFIG" >&5
-$as_echo "$PKG_CONFIG" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $PKG_CONFIG" >&5
+printf "%s\n" "$PKG_CONFIG" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -10036,11 +10991,12 @@ if test -z "$ac_cv_path_PKG_CONFIG"; then
   ac_pt_PKG_CONFIG=$PKG_CONFIG
   # Extract the first word of "pkg-config", so it can be a program name with args.
 set dummy pkg-config; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_ac_pt_PKG_CONFIG+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_ac_pt_PKG_CONFIG+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $ac_pt_PKG_CONFIG in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_ac_pt_PKG_CONFIG="$ac_pt_PKG_CONFIG" # Let the user override the test with a path.
@@ -10050,11 +11006,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_ac_pt_PKG_CONFIG="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_PKG_CONFIG="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -10066,11 +11026,11 @@ esac
 fi
 ac_pt_PKG_CONFIG=$ac_cv_path_ac_pt_PKG_CONFIG
 if test -n "$ac_pt_PKG_CONFIG"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_PKG_CONFIG" >&5
-$as_echo "$ac_pt_PKG_CONFIG" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_pt_PKG_CONFIG" >&5
+printf "%s\n" "$ac_pt_PKG_CONFIG" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_pt_PKG_CONFIG" = x; then
@@ -10078,8 +11038,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     PKG_CONFIG=$ac_pt_PKG_CONFIG
@@ -10091,30 +11051,30 @@ fi
 fi
 if test -n "$PKG_CONFIG"; then
 	_pkg_min_version=0.9.0
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking pkg-config is at least version $_pkg_min_version" >&5
-$as_echo_n "checking pkg-config is at least version $_pkg_min_version... " >&6; }
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking pkg-config is at least version $_pkg_min_version" >&5
+printf %s "checking pkg-config is at least version $_pkg_min_version... " >&6; }
 	if $PKG_CONFIG --atleast-pkgconfig-version $_pkg_min_version; then
-		{ $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
+		{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+printf "%s\n" "yes" >&6; }
 	else
-		{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+		{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 		PKG_CONFIG=""
 	fi
 fi
 
 pkg_failed=no
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for PKGCONFIGINIT" >&5
-$as_echo_n "checking for PKGCONFIGINIT... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for PKGCONFIGINIT" >&5
+printf %s "checking for PKGCONFIGINIT... " >&6; }
 
 if test -n "$PKGCONFIGINIT_CFLAGS"; then
     pkg_cv_PKGCONFIGINIT_CFLAGS="$PKGCONFIGINIT_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"pkgconfiginit\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"pkgconfiginit\""; } >&5
   ($PKG_CONFIG --exists --print-errors "pkgconfiginit") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_PKGCONFIGINIT_CFLAGS=`$PKG_CONFIG --cflags "pkgconfiginit" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
@@ -10128,10 +11088,10 @@ if test -n "$PKGCONFIGINIT_LIBS"; then
     pkg_cv_PKGCONFIGINIT_LIBS="$PKGCONFIGINIT_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"pkgconfiginit\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"pkgconfiginit\""; } >&5
   ($PKG_CONFIG --exists --print-errors "pkgconfiginit") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_PKGCONFIGINIT_LIBS=`$PKG_CONFIG --libs "pkgconfiginit" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
@@ -10145,8 +11105,8 @@ fi
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -10161,18 +11121,18 @@ fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$PKGCONFIGINIT_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: pkg-config initialized" >&5
-$as_echo "pkg-config initialized" >&6; }
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: pkg-config initialized" >&5
+printf "%s\n" "pkg-config initialized" >&6; }
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: pkg-config initialized" >&5
-$as_echo "pkg-config initialized" >&6; }
+     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: pkg-config initialized" >&5
+printf "%s\n" "pkg-config initialized" >&6; }
 else
 	PKGCONFIGINIT_CFLAGS=$pkg_cv_PKGCONFIGINIT_CFLAGS
 	PKGCONFIGINIT_LIBS=$pkg_cv_PKGCONFIGINIT_LIBS
-        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+printf "%s\n" "yes" >&6; }
 
 fi
 		PKGCONFIG_INIT=1
@@ -10180,69 +11140,67 @@ fi
 }
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for default run directory" >&5
-$as_echo_n "checking for default run directory... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for default run directory" >&5
+printf %s "checking for default run directory... " >&6; }
 RUN_DIR="/run"
 test -d "/run" || RUN_DIR="/var/run"
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $RUN_DIR" >&5
-$as_echo "$RUN_DIR" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $RUN_DIR" >&5
+printf "%s\n" "$RUN_DIR" >&6; }
 
 
 # Check whether --with-default-pid-dir was given.
-if test "${with_default_pid_dir+set}" = set; then :
+if test ${with_default_pid_dir+y}
+then :
   withval=$with_default_pid_dir; DEFAULT_PID_DIR="$withval"
-else
+else $as_nop
   DEFAULT_PID_DIR=$RUN_DIR
 fi
 
 
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_PID_DIR "$DEFAULT_PID_DIR"
-_ACEOF
+printf "%s\n" "#define DEFAULT_PID_DIR \"$DEFAULT_PID_DIR\"" >>confdefs.h
 
 
 
 
 # Check whether --with-default-dm-run-dir was given.
-if test "${with_default_dm_run_dir+set}" = set; then :
+if test ${with_default_dm_run_dir+y}
+then :
   withval=$with_default_dm_run_dir; DEFAULT_DM_RUN_DIR="$withval"
-else
+else $as_nop
   DEFAULT_DM_RUN_DIR=$RUN_DIR
 fi
 
 
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_DM_RUN_DIR "$DEFAULT_DM_RUN_DIR"
-_ACEOF
+printf "%s\n" "#define DEFAULT_DM_RUN_DIR \"$DEFAULT_DM_RUN_DIR\"" >>confdefs.h
 
 
 
 
 # Check whether --with-default-run-dir was given.
-if test "${with_default_run_dir+set}" = set; then :
+if test ${with_default_run_dir+y}
+then :
   withval=$with_default_run_dir; DEFAULT_RUN_DIR="$withval"
-else
+else $as_nop
   DEFAULT_RUN_DIR="$RUN_DIR/lvm"
 fi
 
 
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_RUN_DIR "$DEFAULT_RUN_DIR"
-_ACEOF
+printf "%s\n" "#define DEFAULT_RUN_DIR \"$DEFAULT_RUN_DIR\"" >>confdefs.h
 
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build cluster mirror log daemon" >&5
-$as_echo_n "checking whether to build cluster mirror log daemon... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to build cluster mirror log daemon" >&5
+printf %s "checking whether to build cluster mirror log daemon... " >&6; }
 # Check whether --enable-cmirrord was given.
-if test "${enable_cmirrord+set}" = set; then :
+if test ${enable_cmirrord+y}
+then :
   enableval=$enable_cmirrord; CMIRRORD=$enableval
-else
+else $as_nop
   CMIRRORD=no
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $CMIRRORD" >&5
-$as_echo "$CMIRRORD" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CMIRRORD" >&5
+printf "%s\n" "$CMIRRORD" >&6; }
 
 BUILD_CMIRRORD=$CMIRRORD
 
@@ -10250,16 +11208,15 @@ BUILD_CMIRRORD=$CMIRRORD
 if test "$BUILD_CMIRRORD" = yes; then
 
 # Check whether --with-cmirrord-pidfile was given.
-if test "${with_cmirrord_pidfile+set}" = set; then :
+if test ${with_cmirrord_pidfile+y}
+then :
   withval=$with_cmirrord_pidfile; CMIRRORD_PIDFILE=$withval
-else
+else $as_nop
   CMIRRORD_PIDFILE="$DEFAULT_PID_DIR/cmirrord.pid"
 fi
 
 
-cat >>confdefs.h <<_ACEOF
-#define CMIRRORD_PIDFILE "$CMIRRORD_PIDFILE"
-_ACEOF
+printf "%s\n" "#define CMIRRORD_PIDFILE \"$CMIRRORD_PIDFILE\"" >>confdefs.h
 
 fi
 
@@ -10270,17 +11227,17 @@ if [ "$BUILD_CMIRRORD" = yes ]; then
 	if test "$HAVE_CPG" != yes; then
 
 pkg_failed=no
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for CPG" >&5
-$as_echo_n "checking for CPG... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for CPG" >&5
+printf %s "checking for CPG... " >&6; }
 
 if test -n "$CPG_CFLAGS"; then
     pkg_cv_CPG_CFLAGS="$CPG_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libcpg\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libcpg\""; } >&5
   ($PKG_CONFIG --exists --print-errors "libcpg") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_CPG_CFLAGS=`$PKG_CONFIG --cflags "libcpg" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
@@ -10294,10 +11251,10 @@ if test -n "$CPG_LIBS"; then
     pkg_cv_CPG_LIBS="$CPG_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libcpg\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libcpg\""; } >&5
   ($PKG_CONFIG --exists --print-errors "libcpg") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_CPG_LIBS=`$PKG_CONFIG --libs "libcpg" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
@@ -10311,8 +11268,8 @@ fi
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -10338,10 +11295,10 @@ Alternatively, you may set the environment variables CPG_CFLAGS
 and CPG_LIBS to avoid the need to call pkg-config.
 See the pkg-config man page for more details." "$LINENO" 5
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
-	{ { $as_echo "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
-$as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
+     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
+	{ { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
 as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
 is in your PATH or set the PKG_CONFIG environment variable to the full
 path to pkg-config.
@@ -10355,25 +11312,26 @@ See \`config.log' for more details" "$LINENO" 5; }
 else
 	CPG_CFLAGS=$pkg_cv_CPG_CFLAGS
 	CPG_LIBS=$pkg_cv_CPG_LIBS
-        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+printf "%s\n" "yes" >&6; }
 
 fi
 	fi
 fi
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable debugging" >&5
-$as_echo_n "checking whether to enable debugging... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to enable debugging" >&5
+printf %s "checking whether to enable debugging... " >&6; }
 # Check whether --enable-debug was given.
-if test "${enable_debug+set}" = set; then :
+if test ${enable_debug+y}
+then :
   enableval=$enable_debug; DEBUG=$enableval
-else
+else $as_nop
   DEBUG=no
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $DEBUG" >&5
-$as_echo "$DEBUG" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $DEBUG" >&5
+printf "%s\n" "$DEBUG" >&6; }
 
 if test "$DEBUG" = yes; then
 	COPTIMISE_FLAG=
@@ -10385,31 +11343,33 @@ fi
 
     ac_save_CFLAGS=$CFLAGS
     CFLAGS=-Wjump-misses-init
-    { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $CC accepts -Wjump-misses-init flag" >&5
-$as_echo_n "checking whether $CC accepts -Wjump-misses-init flag... " >&6; }
-if ${ac_cv_flag_HAVE_WJUMP+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether $CC accepts -Wjump-misses-init flag" >&5
+printf %s "checking whether $CC accepts -Wjump-misses-init flag... " >&6; }
+if test ${ac_cv_flag_HAVE_WJUMP+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
 int
-main ()
+main (void)
 {
 
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   ac_cv_flag_HAVE_WJUMP=yes
-else
+else $as_nop
   ac_cv_flag_HAVE_WJUMP=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_flag_HAVE_WJUMP" >&5
-$as_echo "$ac_cv_flag_HAVE_WJUMP" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_flag_HAVE_WJUMP" >&5
+printf "%s\n" "$ac_cv_flag_HAVE_WJUMP" >&6; }
     CFLAGS=$ac_save_CFLAGS
     HAVE_WJUMP=$ac_cv_flag_HAVE_WJUMP
     if test "HAVE_WJUMP" = yes; then
@@ -10423,31 +11383,33 @@ $as_echo "$ac_cv_flag_HAVE_WJUMP" >&6; }
 
     ac_save_CFLAGS=$CFLAGS
     CFLAGS=-Wclobbered
-    { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $CC accepts -Wclobbered flag" >&5
-$as_echo_n "checking whether $CC accepts -Wclobbered flag... " >&6; }
-if ${ac_cv_flag_HAVE_WCLOBBERED+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether $CC accepts -Wclobbered flag" >&5
+printf %s "checking whether $CC accepts -Wclobbered flag... " >&6; }
+if test ${ac_cv_flag_HAVE_WCLOBBERED+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
 int
-main ()
+main (void)
 {
 
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   ac_cv_flag_HAVE_WCLOBBERED=yes
-else
+else $as_nop
   ac_cv_flag_HAVE_WCLOBBERED=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_flag_HAVE_WCLOBBERED" >&5
-$as_echo "$ac_cv_flag_HAVE_WCLOBBERED" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_flag_HAVE_WCLOBBERED" >&5
+printf "%s\n" "$ac_cv_flag_HAVE_WCLOBBERED" >&6; }
     CFLAGS=$ac_save_CFLAGS
     HAVE_WCLOBBERED=$ac_cv_flag_HAVE_WCLOBBERED
     if test "HAVE_WCLOBBERED" = yes; then
@@ -10461,31 +11423,33 @@ $as_echo "$ac_cv_flag_HAVE_WCLOBBERED" >&6; }
 
     ac_save_CFLAGS=$CFLAGS
     CFLAGS=-Wsync-nand
-    { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $CC accepts -Wsync-nand flag" >&5
-$as_echo_n "checking whether $CC accepts -Wsync-nand flag... " >&6; }
-if ${ac_cv_flag_HAVE_WSYNCNAND+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether $CC accepts -Wsync-nand flag" >&5
+printf %s "checking whether $CC accepts -Wsync-nand flag... " >&6; }
+if test ${ac_cv_flag_HAVE_WSYNCNAND+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
 int
-main ()
+main (void)
 {
 
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   ac_cv_flag_HAVE_WSYNCNAND=yes
-else
+else $as_nop
   ac_cv_flag_HAVE_WSYNCNAND=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_flag_HAVE_WSYNCNAND" >&5
-$as_echo "$ac_cv_flag_HAVE_WSYNCNAND" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_flag_HAVE_WSYNCNAND" >&5
+printf "%s\n" "$ac_cv_flag_HAVE_WSYNCNAND" >&6; }
     CFLAGS=$ac_save_CFLAGS
     HAVE_WSYNCNAND=$ac_cv_flag_HAVE_WSYNCNAND
     if test "HAVE_WSYNCNAND" = yes; then
@@ -10497,37 +11461,39 @@ $as_echo "$ac_cv_flag_HAVE_WSYNCNAND" >&6; }
 
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for C optimisation flag" >&5
-$as_echo_n "checking for C optimisation flag... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for C optimisation flag" >&5
+printf %s "checking for C optimisation flag... " >&6; }
 
 # Check whether --with-optimisation was given.
-if test "${with_optimisation+set}" = set; then :
+if test ${with_optimisation+y}
+then :
   withval=$with_optimisation; COPTIMISE_FLAG=$withval
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $COPTIMISE_FLAG" >&5
-$as_echo "$COPTIMISE_FLAG" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $COPTIMISE_FLAG" >&5
+printf "%s\n" "$COPTIMISE_FLAG" >&6; }
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to use symbol versioning" >&5
-$as_echo_n "checking whether to use symbol versioning... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to use symbol versioning" >&5
+printf %s "checking whether to use symbol versioning... " >&6; }
 
 # Check whether --with-symvers was given.
-if test "${with_symvers+set}" = set; then :
+if test ${with_symvers+y}
+then :
   withval=$with_symvers;  case "$withval" in
 				gnu|no) symvers=$withval ;;
 				*) as_fn_error $? "--with-symvers parameter invalid" "$LINENO" 5 ;;
 			     esac
-else
+else $as_nop
   symvers=gnu
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $symvers" >&5
-$as_echo "$symvers" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $symvers" >&5
+printf "%s\n" "$symvers" >&6; }
 
 if test "$GCC" = "yes" && test "$symvers" = "gnu" ; then
 
-$as_echo "#define GNU_SYMVER 1" >>confdefs.h
+printf "%s\n" "#define GNU_SYMVER 1" >>confdefs.h
 
 		   case "$host_os" in
 			linux*)
@@ -10538,28 +11504,30 @@ $as_echo "#define GNU_SYMVER 1" >>confdefs.h
 fi
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to gather gcov profiling data" >&5
-$as_echo_n "checking whether to gather gcov profiling data... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to gather gcov profiling data" >&5
+printf %s "checking whether to gather gcov profiling data... " >&6; }
 # Check whether --enable-profiling was given.
-if test "${enable_profiling+set}" = set; then :
+if test ${enable_profiling+y}
+then :
   enableval=$enable_profiling; PROFILING=$enableval
-else
+else $as_nop
   PROFILING=no
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $PROFILING" >&5
-$as_echo "$PROFILING" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $PROFILING" >&5
+printf "%s\n" "$PROFILING" >&6; }
 
 if test "$PROFILING" = yes; then
   COPTIMISE_FLAG="$COPTIMISE_FLAG -fprofile-arcs -ftest-coverage"
   if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}lcov", so it can be a program name with args.
 set dummy ${ac_tool_prefix}lcov; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_LCOV+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_LCOV+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $LCOV in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_LCOV="$LCOV" # Let the user override the test with a path.
@@ -10569,11 +11537,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_LCOV="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_LCOV="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -10585,11 +11557,11 @@ esac
 fi
 LCOV=$ac_cv_path_LCOV
 if test -n "$LCOV"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $LCOV" >&5
-$as_echo "$LCOV" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $LCOV" >&5
+printf "%s\n" "$LCOV" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -10598,11 +11570,12 @@ if test -z "$ac_cv_path_LCOV"; then
   ac_pt_LCOV=$LCOV
   # Extract the first word of "lcov", so it can be a program name with args.
 set dummy lcov; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_ac_pt_LCOV+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_ac_pt_LCOV+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $ac_pt_LCOV in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_ac_pt_LCOV="$ac_pt_LCOV" # Let the user override the test with a path.
@@ -10612,11 +11585,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_ac_pt_LCOV="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_LCOV="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -10628,11 +11605,11 @@ esac
 fi
 ac_pt_LCOV=$ac_cv_path_ac_pt_LCOV
 if test -n "$ac_pt_LCOV"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_LCOV" >&5
-$as_echo "$ac_pt_LCOV" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_pt_LCOV" >&5
+printf "%s\n" "$ac_pt_LCOV" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_pt_LCOV" = x; then
@@ -10640,8 +11617,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     LCOV=$ac_pt_LCOV
@@ -10653,11 +11630,12 @@ fi
   if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}genhtml", so it can be a program name with args.
 set dummy ${ac_tool_prefix}genhtml; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_GENHTML+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_GENHTML+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $GENHTML in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_GENHTML="$GENHTML" # Let the user override the test with a path.
@@ -10667,11 +11645,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_GENHTML="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_GENHTML="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -10683,11 +11665,11 @@ esac
 fi
 GENHTML=$ac_cv_path_GENHTML
 if test -n "$GENHTML"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $GENHTML" >&5
-$as_echo "$GENHTML" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $GENHTML" >&5
+printf "%s\n" "$GENHTML" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -10696,11 +11678,12 @@ if test -z "$ac_cv_path_GENHTML"; then
   ac_pt_GENHTML=$GENHTML
   # Extract the first word of "genhtml", so it can be a program name with args.
 set dummy genhtml; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_ac_pt_GENHTML+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_ac_pt_GENHTML+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $ac_pt_GENHTML in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_ac_pt_GENHTML="$ac_pt_GENHTML" # Let the user override the test with a path.
@@ -10710,11 +11693,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_ac_pt_GENHTML="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_GENHTML="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -10726,11 +11713,11 @@ esac
 fi
 ac_pt_GENHTML=$ac_cv_path_ac_pt_GENHTML
 if test -n "$ac_pt_GENHTML"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_GENHTML" >&5
-$as_echo "$ac_pt_GENHTML" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_pt_GENHTML" >&5
+printf "%s\n" "$ac_pt_GENHTML" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_pt_GENHTML" = x; then
@@ -10738,8 +11725,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     GENHTML=$ac_pt_GENHTML
@@ -10752,11 +11739,12 @@ fi
   if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}genpng", so it can be a program name with args.
 set dummy ${ac_tool_prefix}genpng; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_GENPNG+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_GENPNG+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $GENPNG in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_GENPNG="$GENPNG" # Let the user override the test with a path.
@@ -10766,11 +11754,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_GENPNG="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_GENPNG="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -10782,11 +11774,11 @@ esac
 fi
 GENPNG=$ac_cv_path_GENPNG
 if test -n "$GENPNG"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $GENPNG" >&5
-$as_echo "$GENPNG" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $GENPNG" >&5
+printf "%s\n" "$GENPNG" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -10795,11 +11787,12 @@ if test -z "$ac_cv_path_GENPNG"; then
   ac_pt_GENPNG=$GENPNG
   # Extract the first word of "genpng", so it can be a program name with args.
 set dummy genpng; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_ac_pt_GENPNG+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_ac_pt_GENPNG+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $ac_pt_GENPNG in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_ac_pt_GENPNG="$ac_pt_GENPNG" # Let the user override the test with a path.
@@ -10809,11 +11802,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_ac_pt_GENPNG="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_GENPNG="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -10825,11 +11822,11 @@ esac
 fi
 ac_pt_GENPNG=$ac_cv_path_ac_pt_GENPNG
 if test -n "$ac_pt_GENPNG"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_GENPNG" >&5
-$as_echo "$ac_pt_GENPNG" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_pt_GENPNG" >&5
+printf "%s\n" "$ac_pt_GENPNG" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_pt_GENPNG" = x; then
@@ -10837,8 +11834,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     GENPNG=$ac_pt_GENPNG
@@ -10848,17 +11845,17 @@ else
 fi
 
   if test -n "$GENPNG"; then
-    { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $GENPNG has all required modules" >&5
-$as_echo_n "checking whether $GENPNG has all required modules... " >&6; }
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether $GENPNG has all required modules" >&5
+printf %s "checking whether $GENPNG has all required modules... " >&6; }
     if "$GENPNG" --help > /dev/null 2>&1 ; then
-      { $as_echo "$as_me:${as_lineno-$LINENO}: result: ok" >&5
-$as_echo "ok" >&6; }
+      { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: ok" >&5
+printf "%s\n" "ok" >&6; }
       GENHTML="$GENHTML --frames"
     else
-      { $as_echo "$as_me:${as_lineno-$LINENO}: result: not supported" >&5
-$as_echo "not supported" >&6; }
-      { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: GD.pm perl module is not installed" >&5
-$as_echo "$as_me: WARNING: GD.pm perl module is not installed" >&2;}
+      { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: not supported" >&5
+printf "%s\n" "not supported" >&6; }
+      { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: GD.pm perl module is not installed" >&5
+printf "%s\n" "$as_me: WARNING: GD.pm perl module is not installed" >&2;}
       GENPNG=
     fi
   fi
@@ -10868,38 +11865,37 @@ fi
 TESTSUITE_DATA='${datarootdir}/lvm2-testsuite'
 # double eval needed ${datarootdir} -> ${prefix}/share -> real path
 
-cat >>confdefs.h <<_ACEOF
-#define TESTSUITE_DATA "$(eval echo $(eval echo $TESTSUITE_DATA))"
-_ACEOF
+printf "%s\n" "#define TESTSUITE_DATA \"$(eval echo $(eval echo $TESTSUITE_DATA))\"" >>confdefs.h
 
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable valgrind awareness of pools" >&5
-$as_echo_n "checking whether to enable valgrind awareness of pools... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to enable valgrind awareness of pools" >&5
+printf %s "checking whether to enable valgrind awareness of pools... " >&6; }
 # Check whether --enable-valgrind_pool was given.
-if test "${enable_valgrind_pool+set}" = set; then :
+if test ${enable_valgrind_pool+y}
+then :
   enableval=$enable_valgrind_pool; VALGRIND_POOL=$enableval
-else
+else $as_nop
   VALGRIND_POOL=no
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $VALGRIND_POOL" >&5
-$as_echo "$VALGRIND_POOL" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $VALGRIND_POOL" >&5
+printf "%s\n" "$VALGRIND_POOL" >&6; }
 
 pkg_config_init
 
 pkg_failed=no
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for VALGRIND" >&5
-$as_echo_n "checking for VALGRIND... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for VALGRIND" >&5
+printf %s "checking for VALGRIND... " >&6; }
 
 if test -n "$VALGRIND_CFLAGS"; then
     pkg_cv_VALGRIND_CFLAGS="$VALGRIND_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"valgrind\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"valgrind\""; } >&5
   ($PKG_CONFIG --exists --print-errors "valgrind") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_VALGRIND_CFLAGS=`$PKG_CONFIG --cflags "valgrind" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
@@ -10913,10 +11909,10 @@ if test -n "$VALGRIND_LIBS"; then
     pkg_cv_VALGRIND_LIBS="$VALGRIND_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"valgrind\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"valgrind\""; } >&5
   ($PKG_CONFIG --exists --print-errors "valgrind") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_VALGRIND_LIBS=`$PKG_CONFIG --libs "valgrind" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
@@ -10930,8 +11926,8 @@ fi
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -10948,92 +11944,95 @@ fi
 
 	if test x$VALGRIND_POOL = xyes; then as_fn_error $? "bailing out" "$LINENO" 5; fi
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 	if test x$VALGRIND_POOL = xyes; then as_fn_error $? "bailing out" "$LINENO" 5; fi
 else
 	VALGRIND_CFLAGS=$pkg_cv_VALGRIND_CFLAGS
 	VALGRIND_LIBS=$pkg_cv_VALGRIND_LIBS
-        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+printf "%s\n" "yes" >&6; }
 	HAVE_VALGRIND=yes
 fi
 
 
 if test x$HAVE_VALGRIND = xyes; then
 
-$as_echo "#define HAVE_VALGRIND 1" >>confdefs.h
+printf "%s\n" "#define HAVE_VALGRIND 1" >>confdefs.h
 
 fi
 
 if test x$VALGRIND_POOL = xyes; then
 
-$as_echo "#define VALGRIND_POOL 1" >>confdefs.h
+printf "%s\n" "#define VALGRIND_POOL 1" >>confdefs.h
 
 fi
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to use device-mapper" >&5
-$as_echo_n "checking whether to use device-mapper... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to use device-mapper" >&5
+printf %s "checking whether to use device-mapper... " >&6; }
 # Check whether --enable-devmapper was given.
-if test "${enable_devmapper+set}" = set; then :
+if test ${enable_devmapper+y}
+then :
   enableval=$enable_devmapper; DEVMAPPER=$enableval
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $DEVMAPPER" >&5
-$as_echo "$DEVMAPPER" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $DEVMAPPER" >&5
+printf "%s\n" "$DEVMAPPER" >&6; }
 
 if test "$DEVMAPPER" = yes; then
 
-$as_echo "#define DEVMAPPER_SUPPORT 1" >>confdefs.h
+printf "%s\n" "#define DEVMAPPER_SUPPORT 1" >>confdefs.h
 
 fi
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lvmpolld" >&5
-$as_echo_n "checking whether to build lvmpolld... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to build lvmpolld" >&5
+printf %s "checking whether to build lvmpolld... " >&6; }
 # Check whether --enable-lvmpolld was given.
-if test "${enable_lvmpolld+set}" = set; then :
+if test ${enable_lvmpolld+y}
+then :
   enableval=$enable_lvmpolld; LVMPOLLD=$enableval
-else
+else $as_nop
   LVMPOLLD=no
 fi
 
 test -n "$LVMPOLLD" && BUILD_LVMPOLLD=$LVMPOLLD
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $BUILD_LVMPOLLD" >&5
-$as_echo "$BUILD_LVMPOLLD" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BUILD_LVMPOLLD" >&5
+printf "%s\n" "$BUILD_LVMPOLLD" >&6; }
 
 ################################################################################
 BUILD_LVMLOCKD=no
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lvmlockdsanlock" >&5
-$as_echo_n "checking whether to build lvmlockdsanlock... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to build lvmlockdsanlock" >&5
+printf %s "checking whether to build lvmlockdsanlock... " >&6; }
 # Check whether --enable-lvmlockd-sanlock was given.
-if test "${enable_lvmlockd_sanlock+set}" = set; then :
+if test ${enable_lvmlockd_sanlock+y}
+then :
   enableval=$enable_lvmlockd_sanlock; LOCKDSANLOCK=$enableval
-else
+else $as_nop
   LOCKDSANLOCK=no
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $LOCKDSANLOCK" >&5
-$as_echo "$LOCKDSANLOCK" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $LOCKDSANLOCK" >&5
+printf "%s\n" "$LOCKDSANLOCK" >&6; }
 
 BUILD_LOCKDSANLOCK=$LOCKDSANLOCK
 
 if test "$BUILD_LOCKDSANLOCK" = yes; then
 
 pkg_failed=no
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for LOCKD_SANLOCK" >&5
-$as_echo_n "checking for LOCKD_SANLOCK... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for LOCKD_SANLOCK" >&5
+printf %s "checking for LOCKD_SANLOCK... " >&6; }
 
 if test -n "$LOCKD_SANLOCK_CFLAGS"; then
     pkg_cv_LOCKD_SANLOCK_CFLAGS="$LOCKD_SANLOCK_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libsanlock_client >= 3.3.0\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libsanlock_client >= 3.3.0\""; } >&5
   ($PKG_CONFIG --exists --print-errors "libsanlock_client >= 3.3.0") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_LOCKD_SANLOCK_CFLAGS=`$PKG_CONFIG --cflags "libsanlock_client >= 3.3.0" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
@@ -11047,10 +12046,10 @@ if test -n "$LOCKD_SANLOCK_LIBS"; then
     pkg_cv_LOCKD_SANLOCK_LIBS="$LOCKD_SANLOCK_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libsanlock_client >= 3.3.0\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libsanlock_client >= 3.3.0\""; } >&5
   ($PKG_CONFIG --exists --print-errors "libsanlock_client >= 3.3.0") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_LOCKD_SANLOCK_LIBS=`$PKG_CONFIG --libs "libsanlock_client >= 3.3.0" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
@@ -11064,8 +12063,8 @@ fi
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -11082,51 +12081,52 @@ fi
 
 	$bailout
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 	$bailout
 else
 	LOCKD_SANLOCK_CFLAGS=$pkg_cv_LOCKD_SANLOCK_CFLAGS
 	LOCKD_SANLOCK_LIBS=$pkg_cv_LOCKD_SANLOCK_LIBS
-        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+printf "%s\n" "yes" >&6; }
 	HAVE_LOCKD_SANLOCK=yes
 fi
 
-$as_echo "#define LOCKDSANLOCK_SUPPORT 1" >>confdefs.h
+printf "%s\n" "#define LOCKDSANLOCK_SUPPORT 1" >>confdefs.h
 
 	BUILD_LVMLOCKD=yes
 fi
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lvmlockddlm" >&5
-$as_echo_n "checking whether to build lvmlockddlm... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to build lvmlockddlm" >&5
+printf %s "checking whether to build lvmlockddlm... " >&6; }
 # Check whether --enable-lvmlockd-dlm was given.
-if test "${enable_lvmlockd_dlm+set}" = set; then :
+if test ${enable_lvmlockd_dlm+y}
+then :
   enableval=$enable_lvmlockd_dlm; LOCKDDLM=$enableval
-else
+else $as_nop
   LOCKDDLM=no
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $LOCKDDLM" >&5
-$as_echo "$LOCKDDLM" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $LOCKDDLM" >&5
+printf "%s\n" "$LOCKDDLM" >&6; }
 
 BUILD_LOCKDDLM=$LOCKDDLM
 
 if test "$BUILD_LOCKDDLM" = yes; then
 
 pkg_failed=no
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for LOCKD_DLM" >&5
-$as_echo_n "checking for LOCKD_DLM... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for LOCKD_DLM" >&5
+printf %s "checking for LOCKD_DLM... " >&6; }
 
 if test -n "$LOCKD_DLM_CFLAGS"; then
     pkg_cv_LOCKD_DLM_CFLAGS="$LOCKD_DLM_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libdlm\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libdlm\""; } >&5
   ($PKG_CONFIG --exists --print-errors "libdlm") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_LOCKD_DLM_CFLAGS=`$PKG_CONFIG --cflags "libdlm" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
@@ -11140,10 +12140,10 @@ if test -n "$LOCKD_DLM_LIBS"; then
     pkg_cv_LOCKD_DLM_LIBS="$LOCKD_DLM_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libdlm\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libdlm\""; } >&5
   ($PKG_CONFIG --exists --print-errors "libdlm") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_LOCKD_DLM_LIBS=`$PKG_CONFIG --libs "libdlm" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
@@ -11157,8 +12157,8 @@ fi
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -11175,51 +12175,52 @@ fi
 
 	$bailout
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 	$bailout
 else
 	LOCKD_DLM_CFLAGS=$pkg_cv_LOCKD_DLM_CFLAGS
 	LOCKD_DLM_LIBS=$pkg_cv_LOCKD_DLM_LIBS
-        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+printf "%s\n" "yes" >&6; }
 	HAVE_LOCKD_DLM=yes
 fi
 
-$as_echo "#define LOCKDDLM_SUPPORT 1" >>confdefs.h
+printf "%s\n" "#define LOCKDDLM_SUPPORT 1" >>confdefs.h
 
 	BUILD_LVMLOCKD=yes
 fi
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lvmlockddlmcontrol" >&5
-$as_echo_n "checking whether to build lvmlockddlmcontrol... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to build lvmlockddlmcontrol" >&5
+printf %s "checking whether to build lvmlockddlmcontrol... " >&6; }
 # Check whether --enable-lvmlockd-dlmcontrol was given.
-if test "${enable_lvmlockd_dlmcontrol+set}" = set; then :
+if test ${enable_lvmlockd_dlmcontrol+y}
+then :
   enableval=$enable_lvmlockd_dlmcontrol; LOCKDDLM_CONTROL=$enableval
-else
+else $as_nop
   LOCKDDLM_CONTROL=no
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $LOCKDDLM_CONTROL" >&5
-$as_echo "$LOCKDDLM_CONTROL" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $LOCKDDLM_CONTROL" >&5
+printf "%s\n" "$LOCKDDLM_CONTROL" >&6; }
 
 BUILD_LOCKDDLM_CONTROL=$LOCKDDLM_CONTROL
 
 if test "$BUILD_LOCKDDLM_CONTROL" = yes; then
 
 pkg_failed=no
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for LOCKD_DLM_CONTROL" >&5
-$as_echo_n "checking for LOCKD_DLM_CONTROL... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for LOCKD_DLM_CONTROL" >&5
+printf %s "checking for LOCKD_DLM_CONTROL... " >&6; }
 
 if test -n "$LOCKD_DLM_CONTROL_CFLAGS"; then
     pkg_cv_LOCKD_DLM_CONTROL_CFLAGS="$LOCKD_DLM_CONTROL_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libdlmcontrol >= 3.2\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libdlmcontrol >= 3.2\""; } >&5
   ($PKG_CONFIG --exists --print-errors "libdlmcontrol >= 3.2") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_LOCKD_DLM_CONTROL_CFLAGS=`$PKG_CONFIG --cflags "libdlmcontrol >= 3.2" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
@@ -11233,10 +12234,10 @@ if test -n "$LOCKD_DLM_CONTROL_LIBS"; then
     pkg_cv_LOCKD_DLM_CONTROL_LIBS="$LOCKD_DLM_CONTROL_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libdlmcontrol >= 3.2\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libdlmcontrol >= 3.2\""; } >&5
   ($PKG_CONFIG --exists --print-errors "libdlmcontrol >= 3.2") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_LOCKD_DLM_CONTROL_LIBS=`$PKG_CONFIG --libs "libdlmcontrol >= 3.2" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
@@ -11250,8 +12251,8 @@ fi
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -11268,51 +12269,52 @@ fi
 
 	$bailout
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 	$bailout
 else
 	LOCKD_DLM_CONTROL_CFLAGS=$pkg_cv_LOCKD_DLM_CONTROL_CFLAGS
 	LOCKD_DLM_CONTROL_LIBS=$pkg_cv_LOCKD_DLM_CONTROL_LIBS
-        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+printf "%s\n" "yes" >&6; }
 	HAVE_LOCKD_DLM_CONTROL=yes
 fi
 
-$as_echo "#define LOCKDDLM_CONTROL_SUPPORT 1" >>confdefs.h
+printf "%s\n" "#define LOCKDDLM_CONTROL_SUPPORT 1" >>confdefs.h
 
 	BUILD_LVMLOCKD=yes
 fi
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lvmlockdidm" >&5
-$as_echo_n "checking whether to build lvmlockdidm... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to build lvmlockdidm" >&5
+printf %s "checking whether to build lvmlockdidm... " >&6; }
 # Check whether --enable-lvmlockd-idm was given.
-if test "${enable_lvmlockd_idm+set}" = set; then :
+if test ${enable_lvmlockd_idm+y}
+then :
   enableval=$enable_lvmlockd_idm; LOCKDIDM=$enableval
-else
+else $as_nop
   LOCKDIDM=no
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $LOCKDIDM" >&5
-$as_echo "$LOCKDIDM" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $LOCKDIDM" >&5
+printf "%s\n" "$LOCKDIDM" >&6; }
 
 BUILD_LOCKDIDM=$LOCKDIDM
 
 if test "$BUILD_LOCKDIDM" = yes; then
 
 pkg_failed=no
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for LOCKD_IDM" >&5
-$as_echo_n "checking for LOCKD_IDM... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for LOCKD_IDM" >&5
+printf %s "checking for LOCKD_IDM... " >&6; }
 
 if test -n "$LOCKD_IDM_CFLAGS"; then
     pkg_cv_LOCKD_IDM_CFLAGS="$LOCKD_IDM_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libseagate_ilm >= 0.1.0\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libseagate_ilm >= 0.1.0\""; } >&5
   ($PKG_CONFIG --exists --print-errors "libseagate_ilm >= 0.1.0") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_LOCKD_IDM_CFLAGS=`$PKG_CONFIG --cflags "libseagate_ilm >= 0.1.0" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
@@ -11326,10 +12328,10 @@ if test -n "$LOCKD_IDM_LIBS"; then
     pkg_cv_LOCKD_IDM_LIBS="$LOCKD_IDM_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libseagate_ilm >= 0.1.0\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libseagate_ilm >= 0.1.0\""; } >&5
   ($PKG_CONFIG --exists --print-errors "libseagate_ilm >= 0.1.0") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_LOCKD_IDM_LIBS=`$PKG_CONFIG --libs "libseagate_ilm >= 0.1.0" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
@@ -11343,8 +12345,8 @@ fi
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -11361,287 +12363,299 @@ fi
 
 	$bailout
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 	$bailout
 else
 	LOCKD_IDM_CFLAGS=$pkg_cv_LOCKD_IDM_CFLAGS
 	LOCKD_IDM_LIBS=$pkg_cv_LOCKD_IDM_LIBS
-        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+printf "%s\n" "yes" >&6; }
 	HAVE_LOCKD_IDM=yes
 fi
 	if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid >= 2.24\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid >= 2.24\""; } >&5
   ($PKG_CONFIG --exists --print-errors "blkid >= 2.24") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   HAVE_LOCKD_IDM=yes
 else
   $bailout
 fi
 
-$as_echo "#define LOCKDIDM_SUPPORT 1" >>confdefs.h
+printf "%s\n" "#define LOCKDIDM_SUPPORT 1" >>confdefs.h
 
 	BUILD_LVMLOCKD=yes
 fi
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lvmlockd" >&5
-$as_echo_n "checking whether to build lvmlockd... " >&6; }
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $BUILD_LVMLOCKD" >&5
-$as_echo "$BUILD_LVMLOCKD" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to build lvmlockd" >&5
+printf %s "checking whether to build lvmlockd... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BUILD_LVMLOCKD" >&5
+printf "%s\n" "$BUILD_LVMLOCKD" >&6; }
 
 if test "$BUILD_LVMLOCKD" = yes; then
-	if test "$LVMPOLLD" = no; then :
+	if test "$LVMPOLLD" = no
+then :
   as_fn_error $? "cannot build lvmlockd with --disable-lvmpolld." "$LINENO" 5
 fi
-	if test "$BUILD_LVMPOLLD" = no; then :
-  BUILD_LVMPOLLD=yes; { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Enabling lvmpolld - required by lvmlockd." >&5
-$as_echo "$as_me: WARNING: Enabling lvmpolld - required by lvmlockd." >&2;}
+	if test "$BUILD_LVMPOLLD" = no
+then :
+  BUILD_LVMPOLLD=yes; { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: Enabling lvmpolld - required by lvmlockd." >&5
+printf "%s\n" "$as_me: WARNING: Enabling lvmpolld - required by lvmlockd." >&2;}
 fi
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking defaults for use_lvmlockd" >&5
-$as_echo_n "checking defaults for use_lvmlockd... " >&6; }
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking defaults for use_lvmlockd" >&5
+printf %s "checking defaults for use_lvmlockd... " >&6; }
 	# Check whether --enable-use_lvmlockd was given.
-if test "${enable_use_lvmlockd+set}" = set; then :
+if test ${enable_use_lvmlockd+y}
+then :
   enableval=$enable_use_lvmlockd; case ${enableval} in
 		       yes) DEFAULT_USE_LVMLOCKD=1 ;;
 		       *) DEFAULT_USE_LVMLOCKD=0 ;;
 		       esac
-else
+else $as_nop
   DEFAULT_USE_LVMLOCKD=1
 fi
 
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_USE_LVMLOCKD" >&5
-$as_echo "$DEFAULT_USE_LVMLOCKD" >&6; }
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_USE_LVMLOCKD" >&5
+printf "%s\n" "$DEFAULT_USE_LVMLOCKD" >&6; }
 
-$as_echo "#define LVMLOCKD_SUPPORT 1" >>confdefs.h
+printf "%s\n" "#define LVMLOCKD_SUPPORT 1" >>confdefs.h
 
 
 
 # Check whether --with-lvmlockd-pidfile was given.
-if test "${with_lvmlockd_pidfile+set}" = set; then :
+if test ${with_lvmlockd_pidfile+y}
+then :
   withval=$with_lvmlockd_pidfile; LVMLOCKD_PIDFILE=$withval
-else
+else $as_nop
   LVMLOCKD_PIDFILE="$DEFAULT_PID_DIR/lvmlockd.pid"
 fi
 
 
-cat >>confdefs.h <<_ACEOF
-#define LVMLOCKD_PIDFILE "$LVMLOCKD_PIDFILE"
-_ACEOF
+printf "%s\n" "#define LVMLOCKD_PIDFILE \"$LVMLOCKD_PIDFILE\"" >>confdefs.h
 
 else
 	DEFAULT_USE_LVMLOCKD=0
 fi
 
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_USE_LVMLOCKD $DEFAULT_USE_LVMLOCKD
-_ACEOF
+printf "%s\n" "#define DEFAULT_USE_LVMLOCKD $DEFAULT_USE_LVMLOCKD" >>confdefs.h
 
 
 ################################################################################
 if test "$BUILD_LVMPOLLD" = yes; then
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking defaults for use_lvmpolld" >&5
-$as_echo_n "checking defaults for use_lvmpolld... " >&6; }
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking defaults for use_lvmpolld" >&5
+printf %s "checking defaults for use_lvmpolld... " >&6; }
 	# Check whether --enable-use_lvmpolld was given.
-if test "${enable_use_lvmpolld+set}" = set; then :
+if test ${enable_use_lvmpolld+y}
+then :
   enableval=$enable_use_lvmpolld; case ${enableval} in
 		       yes) DEFAULT_USE_LVMPOLLD=1 ;;
 		       *) DEFAULT_USE_LVMPOLLD=0 ;;
 		       esac
-else
+else $as_nop
   DEFAULT_USE_LVMPOLLD=1
 fi
 
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_USE_LVMPOLLD" >&5
-$as_echo "$DEFAULT_USE_LVMPOLLD" >&6; }
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_USE_LVMPOLLD" >&5
+printf "%s\n" "$DEFAULT_USE_LVMPOLLD" >&6; }
 
-$as_echo "#define LVMPOLLD_SUPPORT 1" >>confdefs.h
+printf "%s\n" "#define LVMPOLLD_SUPPORT 1" >>confdefs.h
 
 
 
 # Check whether --with-lvmpolld-pidfile was given.
-if test "${with_lvmpolld_pidfile+set}" = set; then :
+if test ${with_lvmpolld_pidfile+y}
+then :
   withval=$with_lvmpolld_pidfile; LVMPOLLD_PIDFILE=$withval
-else
+else $as_nop
   LVMPOLLD_PIDFILE="$DEFAULT_PID_DIR/lvmpolld.pid"
 fi
 
 
-cat >>confdefs.h <<_ACEOF
-#define LVMPOLLD_PIDFILE "$LVMPOLLD_PIDFILE"
-_ACEOF
+printf "%s\n" "#define LVMPOLLD_PIDFILE \"$LVMPOLLD_PIDFILE\"" >>confdefs.h
 
 else
 	DEFAULT_USE_LVMPOLLD=0
 fi
 
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_USE_LVMPOLLD $DEFAULT_USE_LVMPOLLD
-_ACEOF
+printf "%s\n" "#define DEFAULT_USE_LVMPOLLD $DEFAULT_USE_LVMPOLLD" >>confdefs.h
 
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build dmfilemapd" >&5
-$as_echo_n "checking whether to build dmfilemapd... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to build dmfilemapd" >&5
+printf %s "checking whether to build dmfilemapd... " >&6; }
 # Check whether --enable-dmfilemapd was given.
-if test "${enable_dmfilemapd+set}" = set; then :
+if test ${enable_dmfilemapd+y}
+then :
   enableval=$enable_dmfilemapd; BUILD_DMFILEMAPD=$enableval
-else
+else $as_nop
   BUILD_DMFILEMAPD=no
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $BUILD_DMFILEMAPD" >&5
-$as_echo "$BUILD_DMFILEMAPD" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BUILD_DMFILEMAPD" >&5
+printf "%s\n" "$BUILD_DMFILEMAPD" >&6; }
 
-$as_echo "#define DMFILEMAPD \$BUILD_DMFILEMAPD" >>confdefs.h
+printf "%s\n" "#define DMFILEMAPD \$BUILD_DMFILEMAPD" >>confdefs.h
 
 
 if test "$BUILD_DMFILEMAPD" = yes; then
-   ac_fn_c_check_header_mongrel "$LINENO" "linux/fiemap.h" "ac_cv_header_linux_fiemap_h" "$ac_includes_default"
-if test "x$ac_cv_header_linux_fiemap_h" = xyes; then :
+   ac_fn_c_check_header_compile "$LINENO" "linux/fiemap.h" "ac_cv_header_linux_fiemap_h" "$ac_includes_default"
+if test "x$ac_cv_header_linux_fiemap_h" = xyes
+then :
 
-else
+else $as_nop
   as_fn_error $? "--enable-dmfilemapd requires fiemap.h" "$LINENO" 5
 fi
 
-
 fi
 
 SYSTEMD_MIN_VERSION=0
 pkg_config_init
 if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 205\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 205\""; } >&5
   ($PKG_CONFIG --exists --print-errors "systemd >= 205") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   SYSTEMD_MIN_VERSION=205
 fi
 
 ################################################################################
 if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 221\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 221\""; } >&5
   ($PKG_CONFIG --exists --print-errors "systemd >= 221") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   SYSTEMD_MIN_VERSION=221
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build notifydbus" >&5
-$as_echo_n "checking whether to build notifydbus... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to build notifydbus" >&5
+printf %s "checking whether to build notifydbus... " >&6; }
 # Check whether --enable-notify-dbus was given.
-if test "${enable_notify_dbus+set}" = set; then :
-  enableval=$enable_notify_dbus; if test "$enableval" = yes && test "$SYSTEMD_MIN_VERSION" -lt 221; then :
+if test ${enable_notify_dbus+y}
+then :
+  enableval=$enable_notify_dbus; if test "$enableval" = yes && test "$SYSTEMD_MIN_VERSION" -lt 221
+then :
   as_fn_error $? "Enabling notify-dbus requires systemd >= 221" "$LINENO" 5
 fi
 	      NOTIFYDBUS_SUPPORT=$enableval
-else
+else $as_nop
   NOTIFYDBUS_SUPPORT=no
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $NOTIFYDBUS_SUPPORT" >&5
-$as_echo "$NOTIFYDBUS_SUPPORT" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $NOTIFYDBUS_SUPPORT" >&5
+printf "%s\n" "$NOTIFYDBUS_SUPPORT" >&6; }
 
-if test "$NOTIFYDBUS_SUPPORT" = yes; then :
+if test "$NOTIFYDBUS_SUPPORT" = yes
+then :
 
-$as_echo "#define NOTIFYDBUS_SUPPORT 1" >>confdefs.h
+printf "%s\n" "#define NOTIFYDBUS_SUPPORT 1" >>confdefs.h
 
 fi
 
 ################################################################################
-if test "$SYSTEMD_MIN_VERSION" -ge 221; then :
+if test "$SYSTEMD_MIN_VERSION" -ge 221
+then :
   SYSTEMD_JOURNAL_SUPPORT=maybe
-else
+else $as_nop
   SYSTEMD_JOURNAL_SUPPORT=no
 fi
-ac_fn_c_check_header_mongrel "$LINENO" "systemd/sd-journal.h" "ac_cv_header_systemd_sd_journal_h" "$ac_includes_default"
-if test "x$ac_cv_header_systemd_sd_journal_h" = xyes; then :
-  if test "$SYSTEMD_JOURNAL_SUPPORT" != no; then :
+ac_fn_c_check_header_compile "$LINENO" "systemd/sd-journal.h" "ac_cv_header_systemd_sd_journal_h" "$ac_includes_default"
+if test "x$ac_cv_header_systemd_sd_journal_h" = xyes
+then :
+  if test "$SYSTEMD_JOURNAL_SUPPORT" != no
+then :
   SYSTEMD_JOURNAL_SUPPORT=yes
 fi
-else
+else $as_nop
   SYSTEMD_JOURNAL_SUPPORT=no
 fi
 
-
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to log to systemd journal" >&5
-$as_echo_n "checking whether to log to systemd journal... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to log to systemd journal" >&5
+printf %s "checking whether to log to systemd journal... " >&6; }
 # Check whether --enable-systemd-journal was given.
-if test "${enable_systemd_journal+set}" = set; then :
-  enableval=$enable_systemd_journal; if test "$enableval" = yes && test "$SYSTEMD_JOURNAL_SUPPORT" = no; then :
+if test ${enable_systemd_journal+y}
+then :
+  enableval=$enable_systemd_journal; if test "$enableval" = yes && test "$SYSTEMD_JOURNAL_SUPPORT" = no
+then :
   as_fn_error $? "Enabling systemd journal requires systemd/sd-journal.h and systemd >= 221." "$LINENO" 5
 fi
 	      SYSTEMD_JOURNAL_SUPPORT=$enableval
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $SYSTEMD_JOURNAL_SUPPORT" >&5
-$as_echo "$SYSTEMD_JOURNAL_SUPPORT" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $SYSTEMD_JOURNAL_SUPPORT" >&5
+printf "%s\n" "$SYSTEMD_JOURNAL_SUPPORT" >&6; }
 
-if test "$SYSTEMD_JOURNAL_SUPPORT" = yes; then :
+if test "$SYSTEMD_JOURNAL_SUPPORT" = yes
+then :
 
-$as_echo "#define SYSTEMD_JOURNAL_SUPPORT 1" >>confdefs.h
+printf "%s\n" "#define SYSTEMD_JOURNAL_SUPPORT 1" >>confdefs.h
 
 fi
 
 ################################################################################
 if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 234\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 234\""; } >&5
   ($PKG_CONFIG --exists --print-errors "systemd >= 234") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   SYSTEMD_MIN_VERSION=234  APP_MACHINEID_SUPPORT=maybe
 else
   APP_MACHINEID_SUPPORT=no
 fi
-ac_fn_c_check_header_mongrel "$LINENO" "systemd/sd-id128.h" "ac_cv_header_systemd_sd_id128_h" "$ac_includes_default"
-if test "x$ac_cv_header_systemd_sd_id128_h" = xyes; then :
-  if test "$APP_MACHINEID_SUPPORT" != no; then :
+ac_fn_c_check_header_compile "$LINENO" "systemd/sd-id128.h" "ac_cv_header_systemd_sd_id128_h" "$ac_includes_default"
+if test "x$ac_cv_header_systemd_sd_id128_h" = xyes
+then :
+  if test "$APP_MACHINEID_SUPPORT" != no
+then :
   APP_MACHINEID_SUPPORT=yes
 fi
-else
+else $as_nop
   APP_MACHINEID_SUPPORT=no
 fi
 
-
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to support systemd appmachineid" >&5
-$as_echo_n "checking whether to support systemd appmachineid... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to support systemd appmachineid" >&5
+printf %s "checking whether to support systemd appmachineid... " >&6; }
 # Check whether --enable-app-machineid was given.
-if test "${enable_app_machineid+set}" = set; then :
-  enableval=$enable_app_machineid; if test "$enableval" = yes && test "$APP_MACHINEID_SUPPORT" = no; then :
+if test ${enable_app_machineid+y}
+then :
+  enableval=$enable_app_machineid; if test "$enableval" = yes && test "$APP_MACHINEID_SUPPORT" = no
+then :
   as_fn_error $? "Enabling app machineid requires systemd/sd-id128.h and systemd >= 234." "$LINENO" 5
 fi
 	      APP_MACHINEID_SUPPORT=$enableval
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $APP_MACHINEID_SUPPORT" >&5
-$as_echo "$APP_MACHINEID_SUPPORT" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $APP_MACHINEID_SUPPORT" >&5
+printf "%s\n" "$APP_MACHINEID_SUPPORT" >&6; }
 
-if test "$APP_MACHINEID_SUPPORT" = yes; then :
+if test "$APP_MACHINEID_SUPPORT" = yes
+then :
 
-$as_echo "#define APP_MACHINEID_SUPPORT 1" >>confdefs.h
+printf "%s\n" "#define APP_MACHINEID_SUPPORT 1" >>confdefs.h
 
 fi
 
-if test "$NOTIFYDBUS_SUPPORT" = yes || test "$SYSTEMD_JOURNAL_SUPPORT" = yes || test "$APP_MACHINEID_SUPPORT" = yes  ; then :
+if test "$NOTIFYDBUS_SUPPORT" = yes || test "$SYSTEMD_JOURNAL_SUPPORT" = yes || test "$APP_MACHINEID_SUPPORT" = yes
+then :
 
       pkg_config_init
 
 pkg_failed=no
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for SYSTEMD" >&5
-$as_echo_n "checking for SYSTEMD... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for SYSTEMD" >&5
+printf %s "checking for SYSTEMD... " >&6; }
 
 if test -n "$SYSTEMD_CFLAGS"; then
     pkg_cv_SYSTEMD_CFLAGS="$SYSTEMD_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd\""; } >&5
   ($PKG_CONFIG --exists --print-errors "systemd") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_SYSTEMD_CFLAGS=`$PKG_CONFIG --cflags "systemd" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
@@ -11655,10 +12669,10 @@ if test -n "$SYSTEMD_LIBS"; then
     pkg_cv_SYSTEMD_LIBS="$SYSTEMD_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd\""; } >&5
   ($PKG_CONFIG --exists --print-errors "systemd") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_SYSTEMD_LIBS=`$PKG_CONFIG --libs "systemd" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
@@ -11672,8 +12686,8 @@ fi
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -11690,14 +12704,14 @@ fi
 
 	$bailout
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 	$bailout
 else
 	SYSTEMD_CFLAGS=$pkg_cv_SYSTEMD_CFLAGS
 	SYSTEMD_LIBS=$pkg_cv_SYSTEMD_LIBS
-        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+printf "%s\n" "yes" >&6; }
 	SYSTEMD_LIBS="-lsystemd"
 fi
 fi
@@ -11705,9 +12719,10 @@ fi
 ################################################################################
 
 # Check whether --enable-blkid_wiping was given.
-if test "${enable_blkid_wiping+set}" = set; then :
+if test ${enable_blkid_wiping+y}
+then :
   enableval=$enable_blkid_wiping; BLKID_WIPING=$enableval
-else
+else $as_nop
   BLKID_WIPING=maybe
 fi
 
@@ -11717,17 +12732,17 @@ if test "$BLKID_WIPING" != no; then
 	pkg_config_init
 
 pkg_failed=no
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for BLKID" >&5
-$as_echo_n "checking for BLKID... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for BLKID" >&5
+printf %s "checking for BLKID... " >&6; }
 
 if test -n "$BLKID_CFLAGS"; then
     pkg_cv_BLKID_CFLAGS="$BLKID_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid >= 2.24\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid >= 2.24\""; } >&5
   ($PKG_CONFIG --exists --print-errors "blkid >= 2.24") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_BLKID_CFLAGS=`$PKG_CONFIG --cflags "blkid >= 2.24" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
@@ -11741,10 +12756,10 @@ if test -n "$BLKID_LIBS"; then
     pkg_cv_BLKID_LIBS="$BLKID_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid >= 2.24\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid >= 2.24\""; } >&5
   ($PKG_CONFIG --exists --print-errors "blkid >= 2.24") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_BLKID_LIBS=`$PKG_CONFIG --libs "blkid >= 2.24" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
@@ -11758,8 +12773,8 @@ fi
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -11780,8 +12795,8 @@ fi
 			        as_fn_error $? "bailing out... blkid library >= 2.24 is required" "$LINENO" 5
 			   fi
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 	if test "$BLKID_WIPING" = maybe; then
 				BLKID_WIPING=no
 			   else
@@ -11790,81 +12805,83 @@ $as_echo "no" >&6; }
 else
 	BLKID_CFLAGS=$pkg_cv_BLKID_CFLAGS
 	BLKID_LIBS=$pkg_cv_BLKID_LIBS
-        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+printf "%s\n" "yes" >&6; }
 	 BLKID_WIPING=yes
 			    BLKID_PC="blkid"
 			    DEFAULT_USE_BLKID_WIPING=1
 
-$as_echo "#define BLKID_WIPING_SUPPORT 1" >>confdefs.h
+printf "%s\n" "#define BLKID_WIPING_SUPPORT 1" >>confdefs.h
 
 
 fi
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable libblkid detection of signatures when wiping" >&5
-$as_echo_n "checking whether to enable libblkid detection of signatures when wiping... " >&6; }
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $BLKID_WIPING" >&5
-$as_echo "$BLKID_WIPING" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to enable libblkid detection of signatures when wiping" >&5
+printf %s "checking whether to enable libblkid detection of signatures when wiping... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BLKID_WIPING" >&5
+printf "%s\n" "$BLKID_WIPING" >&6; }
 
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_USE_BLKID_WIPING $DEFAULT_USE_BLKID_WIPING
-_ACEOF
+printf "%s\n" "#define DEFAULT_USE_BLKID_WIPING $DEFAULT_USE_BLKID_WIPING" >>confdefs.h
 
 
 ################################################################################
 # Check whether --enable-udev-systemd-background-jobs was given.
-if test "${enable_udev_systemd_background_jobs+set}" = set; then :
+if test ${enable_udev_systemd_background_jobs+y}
+then :
   enableval=$enable_udev_systemd_background_jobs; UDEV_SYSTEMD_BACKGROUND_JOBS=$enableval
-else
+else $as_nop
   UDEV_SYSTEMD_BACKGROUND_JOBS=maybe
 fi
 
 
 if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" != no; then
-	if test "$SYSTEMD_MIN_VERSION" -ge 205; then :
+	if test "$SYSTEMD_MIN_VERSION" -ge 205
+then :
   UDEV_SYSTEMD_BACKGROUND_JOBS=yes
-else
-  if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" = maybe; then :
+else $as_nop
+  if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" = maybe
+then :
   UDEV_SYSTEMD_BACKGROUND_JOBS=no
-else
+else $as_nop
   as_fn_error $? "bailing out... systemd >= 205 is required" "$LINENO" 5
 fi
 fi
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to use udev-systemd protocol for jobs in background" >&5
-$as_echo_n "checking whether to use udev-systemd protocol for jobs in background... " >&6; }
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $UDEV_SYSTEMD_BACKGROUND_JOBS" >&5
-$as_echo "$UDEV_SYSTEMD_BACKGROUND_JOBS" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to use udev-systemd protocol for jobs in background" >&5
+printf %s "checking whether to use udev-systemd protocol for jobs in background... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $UDEV_SYSTEMD_BACKGROUND_JOBS" >&5
+printf "%s\n" "$UDEV_SYSTEMD_BACKGROUND_JOBS" >&6; }
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable synchronisation with udev processing" >&5
-$as_echo_n "checking whether to enable synchronisation with udev processing... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to enable synchronisation with udev processing" >&5
+printf %s "checking whether to enable synchronisation with udev processing... " >&6; }
 # Check whether --enable-udev_sync was given.
-if test "${enable_udev_sync+set}" = set; then :
+if test ${enable_udev_sync+y}
+then :
   enableval=$enable_udev_sync; UDEV_SYNC=$enableval
-else
+else $as_nop
   UDEV_SYNC=no
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $UDEV_SYNC" >&5
-$as_echo "$UDEV_SYNC" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $UDEV_SYNC" >&5
+printf "%s\n" "$UDEV_SYNC" >&6; }
 
 if test "$UDEV_SYNC" = yes; then
 	pkg_config_init
 
 pkg_failed=no
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for UDEV" >&5
-$as_echo_n "checking for UDEV... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for UDEV" >&5
+printf %s "checking for UDEV... " >&6; }
 
 if test -n "$UDEV_CFLAGS"; then
     pkg_cv_UDEV_CFLAGS="$UDEV_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libudev >= 143\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libudev >= 143\""; } >&5
   ($PKG_CONFIG --exists --print-errors "libudev >= 143") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_UDEV_CFLAGS=`$PKG_CONFIG --cflags "libudev >= 143" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
@@ -11878,10 +12895,10 @@ if test -n "$UDEV_LIBS"; then
     pkg_cv_UDEV_LIBS="$UDEV_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libudev >= 143\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libudev >= 143\""; } >&5
   ($PKG_CONFIG --exists --print-errors "libudev >= 143") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_UDEV_LIBS=`$PKG_CONFIG --libs "libudev >= 143" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
@@ -11895,8 +12912,8 @@ fi
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -11922,10 +12939,10 @@ Alternatively, you may set the environment variables UDEV_CFLAGS
 and UDEV_LIBS to avoid the need to call pkg-config.
 See the pkg-config man page for more details." "$LINENO" 5
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
-	{ { $as_echo "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
-$as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
+     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
+	{ { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
 as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
 is in your PATH or set the PKG_CONFIG environment variable to the full
 path to pkg-config.
@@ -11939,19 +12956,20 @@ See \`config.log' for more details" "$LINENO" 5; }
 else
 	UDEV_CFLAGS=$pkg_cv_UDEV_CFLAGS
 	UDEV_LIBS=$pkg_cv_UDEV_LIBS
-        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+printf "%s\n" "yes" >&6; }
 	UDEV_PC="libudev"
 fi
 
-$as_echo "#define UDEV_SYNC_SUPPORT 1" >>confdefs.h
+printf "%s\n" "#define UDEV_SYNC_SUPPORT 1" >>confdefs.h
 
 
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for udev_device_get_is_initialized in -ludev" >&5
-$as_echo_n "checking for udev_device_get_is_initialized in -ludev... " >&6; }
-if ${ac_cv_lib_udev_udev_device_get_is_initialized+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for udev_device_get_is_initialized in -ludev" >&5
+printf %s "checking for udev_device_get_is_initialized in -ludev... " >&6; }
+if test ${ac_cv_lib_udev_udev_device_get_is_initialized+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   ac_check_lib_save_LIBS=$LIBS
 LIBS="-ludev  $LIBS"
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -11960,151 +12978,159 @@ cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* Override any GCC internal prototype to avoid an error.
    Use char because int might match the return type of a GCC
    builtin and then its argument prototype would still apply.  */
-#ifdef __cplusplus
-extern "C"
-#endif
 char udev_device_get_is_initialized ();
 int
-main ()
+main (void)
 {
 return udev_device_get_is_initialized ();
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
+if ac_fn_c_try_link "$LINENO"
+then :
   ac_cv_lib_udev_udev_device_get_is_initialized=yes
-else
+else $as_nop
   ac_cv_lib_udev_udev_device_get_is_initialized=no
 fi
-rm -f core conftest.err conftest.$ac_objext \
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
     conftest$ac_exeext conftest.$ac_ext
 LIBS=$ac_check_lib_save_LIBS
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_udev_udev_device_get_is_initialized" >&5
-$as_echo "$ac_cv_lib_udev_udev_device_get_is_initialized" >&6; }
-if test "x$ac_cv_lib_udev_udev_device_get_is_initialized" = xyes; then :
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_udev_udev_device_get_is_initialized" >&5
+printf "%s\n" "$ac_cv_lib_udev_udev_device_get_is_initialized" >&6; }
+if test "x$ac_cv_lib_udev_udev_device_get_is_initialized" = xyes
+then :
 
-$as_echo "#define HAVE_LIBUDEV_UDEV_DEVICE_GET_IS_INITIALIZED 1" >>confdefs.h
+printf "%s\n" "#define HAVE_LIBUDEV_UDEV_DEVICE_GET_IS_INITIALIZED 1" >>confdefs.h
 
 fi
 
 	LIBS=$ac_check_lib_save_LIBS
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable installation of udev rules required for synchronisation" >&5
-$as_echo_n "checking whether to enable installation of udev rules required for synchronisation... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to enable installation of udev rules required for synchronisation" >&5
+printf %s "checking whether to enable installation of udev rules required for synchronisation... " >&6; }
 # Check whether --enable-udev_rules was given.
-if test "${enable_udev_rules+set}" = set; then :
+if test ${enable_udev_rules+y}
+then :
   enableval=$enable_udev_rules; UDEV_RULES=$enableval
-else
+else $as_nop
   UDEV_RULES=$UDEV_SYNC
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $UDEV_RULES" >&5
-$as_echo "$UDEV_RULES" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $UDEV_RULES" >&5
+printf "%s\n" "$UDEV_RULES" >&6; }
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable executable path detection in udev rules" >&5
-$as_echo_n "checking whether to enable executable path detection in udev rules... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to enable executable path detection in udev rules" >&5
+printf %s "checking whether to enable executable path detection in udev rules... " >&6; }
 # Check whether --enable-udev_rule_exec_detection was given.
-if test "${enable_udev_rule_exec_detection+set}" = set; then :
+if test ${enable_udev_rule_exec_detection+y}
+then :
   enableval=$enable_udev_rule_exec_detection; UDEV_RULE_EXEC_DETECTION=$enableval
-else
+else $as_nop
   UDEV_RULE_EXEC_DETECTION=no
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $UDEV_RULE_EXEC_DETECTION" >&5
-$as_echo "$UDEV_RULE_EXEC_DETECTION" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $UDEV_RULE_EXEC_DETECTION" >&5
+printf "%s\n" "$UDEV_RULE_EXEC_DETECTION" >&6; }
 
 if test "$UDEV_RULE" != no ; then
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether udev supports built-in blkid" >&5
-$as_echo_n "checking whether udev supports built-in blkid... " >&6; }
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether udev supports built-in blkid" >&5
+printf %s "checking whether udev supports built-in blkid... " >&6; }
 	pkg_config_init
 	if $("$PKG_CONFIG" --atleast-version=176 libudev); then
 		UDEV_HAS_BUILTIN_BLKID=yes
 	else
 		UDEV_HAS_BUILTIN_BLKID=no
 	fi
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $UDEV_HAS_BUILTIN_BLKID" >&5
-$as_echo "$UDEV_HAS_BUILTIN_BLKID" >&6; }
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $UDEV_HAS_BUILTIN_BLKID" >&5
+printf "%s\n" "$UDEV_HAS_BUILTIN_BLKID" >&6; }
 fi
 
 ################################################################################
 # Check whether --enable-units-compat was given.
-if test "${enable_units_compat+set}" = set; then :
+if test ${enable_units_compat+y}
+then :
   enableval=$enable_units_compat; UNITS_COMPAT=$enableval
-else
+else $as_nop
   UNITS_COMPAT=no
 fi
 
 
 if test "$UNITS_COMPAT" = yes; then
 
-$as_echo "#define DEFAULT_SI_UNIT_CONSISTENCY 0" >>confdefs.h
+printf "%s\n" "#define DEFAULT_SI_UNIT_CONSISTENCY 0" >>confdefs.h
 
 fi
 
 ################################################################################
 # Check whether --enable-ioctl was given.
-if test "${enable_ioctl+set}" = set; then :
+if test ${enable_ioctl+y}
+then :
   enableval=$enable_ioctl; DM_IOCTLS=$enableval
 fi
 
-if test "$DM_IOCTLS" = yes; then :
+if test "$DM_IOCTLS" = yes
+then :
 
-$as_echo "#define DM_IOCTLS 1" >>confdefs.h
+printf "%s\n" "#define DM_IOCTLS 1" >>confdefs.h
 
 fi
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable O_DIRECT" >&5
-$as_echo_n "checking whether to enable O_DIRECT... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to enable O_DIRECT" >&5
+printf %s "checking whether to enable O_DIRECT... " >&6; }
 # Check whether --enable-o_direct was given.
-if test "${enable_o_direct+set}" = set; then :
+if test ${enable_o_direct+y}
+then :
   enableval=$enable_o_direct; ODIRECT=$enableval
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ODIRECT" >&5
-$as_echo "$ODIRECT" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ODIRECT" >&5
+printf "%s\n" "$ODIRECT" >&6; }
 
 if test "$ODIRECT" = yes; then
 
-$as_echo "#define O_DIRECT_SUPPORT 1" >>confdefs.h
+printf "%s\n" "#define O_DIRECT_SUPPORT 1" >>confdefs.h
 
 fi
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to compile liblvm2cmd.so" >&5
-$as_echo_n "checking whether to compile liblvm2cmd.so... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to compile liblvm2cmd.so" >&5
+printf %s "checking whether to compile liblvm2cmd.so... " >&6; }
 # Check whether --enable-cmdlib was given.
-if test "${enable_cmdlib+set}" = set; then :
+if test ${enable_cmdlib+y}
+then :
   enableval=$enable_cmdlib; CMDLIB=$enableval
-else
+else $as_nop
   CMDLIB=no
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $CMDLIB" >&5
-$as_echo "$CMDLIB" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CMDLIB" >&5
+printf "%s\n" "$CMDLIB" >&6; }
 
 test "$CMDLIB" = yes \
   && LVM2CMD_LIB=-llvm2cmd \
   || LVM2CMD_LIB=
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include Python D-Bus support" >&5
-$as_echo_n "checking whether to include Python D-Bus support... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to include Python D-Bus support" >&5
+printf %s "checking whether to include Python D-Bus support... " >&6; }
 # Check whether --enable-dbus-service was given.
-if test "${enable_dbus_service+set}" = set; then :
+if test ${enable_dbus_service+y}
+then :
   enableval=$enable_dbus_service; BUILD_LVMDBUSD=$enableval
-else
+else $as_nop
   BUILD_LVMDBUSD=no
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $BUILD_LVMDBUSD" >&5
-$as_echo "$BUILD_LVMDBUSD" >&6; }
-if test "$NOTIFYDBUS_SUPPORT" = yes && test "BUILD_LVMDBUSD" = yes; then :
-  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Building D-Bus support without D-Bus notifications." >&5
-$as_echo "$as_me: WARNING: Building D-Bus support without D-Bus notifications." >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BUILD_LVMDBUSD" >&5
+printf "%s\n" "$BUILD_LVMDBUSD" >&6; }
+if test "$NOTIFYDBUS_SUPPORT" = yes && test "BUILD_LVMDBUSD" = yes
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: Building D-Bus support without D-Bus notifications." >&5
+printf "%s\n" "$as_me: WARNING: Building D-Bus support without D-Bus notifications." >&2;}
 fi
 
 ################################################################################
@@ -12122,8 +13148,8 @@ if test "$BUILD_LVMDBUSD" = yes; then
 
         if test -n "$PYTHON"; then
       # If the user set $PYTHON, use it and don't search something else.
-      { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $PYTHON version is >= 3" >&5
-$as_echo_n "checking whether $PYTHON version is >= 3... " >&6; }
+      { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether $PYTHON version is >= 3" >&5
+printf %s "checking whether $PYTHON version is >= 3... " >&6; }
       prog="import sys
 # split strings by '.' and convert to numeric.  Append some zeros
 # because we need at least 4 digits for the hex conversion.
@@ -12137,23 +13163,25 @@ sys.exit(sys.hexversion < minverhex)"
    ($PYTHON -c "$prog") >&5 2>&5
    ac_status=$?
    echo "$as_me:$LINENO: \$? = $ac_status" >&5
-   (exit $ac_status); }; then :
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
-else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+   (exit $ac_status); }
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+printf "%s\n" "yes" >&6; }
+else $as_nop
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 			       as_fn_error $? "Python interpreter is too old" "$LINENO" 5
 fi
       am_display_PYTHON=$PYTHON
     else
       # Otherwise, try each interpreter until we find one that satisfies
       # VERSION.
-      { $as_echo "$as_me:${as_lineno-$LINENO}: checking for a Python interpreter with version >= 3" >&5
-$as_echo_n "checking for a Python interpreter with version >= 3... " >&6; }
-if ${am_cv_pathless_PYTHON+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+      { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for a Python interpreter with version >= 3" >&5
+printf %s "checking for a Python interpreter with version >= 3... " >&6; }
+if test ${am_cv_pathless_PYTHON+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
 
 	for am_cv_pathless_PYTHON in  python3 python2 python 	python3.9 python3.8 python3.7 python3.6 python3.5 python3.4 python3.3 python3.2 python3.1 python3.0 	python2.7 python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0  none; do
 	  test "$am_cv_pathless_PYTHON" = none && break
@@ -12170,24 +13198,26 @@ sys.exit(sys.hexversion < minverhex)"
    ($am_cv_pathless_PYTHON -c "$prog") >&5 2>&5
    ac_status=$?
    echo "$as_me:$LINENO: \$? = $ac_status" >&5
-   (exit $ac_status); }; then :
+   (exit $ac_status); }
+then :
   break
 fi
 	done
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $am_cv_pathless_PYTHON" >&5
-$as_echo "$am_cv_pathless_PYTHON" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $am_cv_pathless_PYTHON" >&5
+printf "%s\n" "$am_cv_pathless_PYTHON" >&6; }
       # Set $PYTHON to the absolute path of $am_cv_pathless_PYTHON.
       if test "$am_cv_pathless_PYTHON" = none; then
 	PYTHON=:
       else
         # Extract the first word of "$am_cv_pathless_PYTHON", so it can be a program name with args.
 set dummy $am_cv_pathless_PYTHON; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_PYTHON+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_PYTHON+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $PYTHON in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_PYTHON="$PYTHON" # Let the user override the test with a path.
@@ -12197,11 +13227,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_PYTHON="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_PYTHON="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -12213,11 +13247,11 @@ esac
 fi
 PYTHON=$ac_cv_path_PYTHON
 if test -n "$PYTHON"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $PYTHON" >&5
-$as_echo "$PYTHON" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $PYTHON" >&5
+printf "%s\n" "$PYTHON" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -12227,42 +13261,172 @@ fi
 
 
   if test "$PYTHON" = :; then
-      as_fn_error $? "no suitable Python interpreter found" "$LINENO" 5
+        as_fn_error $? "no suitable Python interpreter found" "$LINENO" 5
   else
 
-
-  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $am_display_PYTHON version" >&5
-$as_echo_n "checking for $am_display_PYTHON version... " >&6; }
-if ${am_cv_python_version+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  am_cv_python_version=`$PYTHON -c "import sys; print('%u.%u' % sys.version_info[:2])"`
+              { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $am_display_PYTHON version" >&5
+printf %s "checking for $am_display_PYTHON version... " >&6; }
+if test ${am_cv_python_version+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  am_cv_python_version=`$PYTHON -c "import sys; print ('%u.%u' % sys.version_info[:2])"`
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $am_cv_python_version" >&5
-$as_echo "$am_cv_python_version" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $am_cv_python_version" >&5
+printf "%s\n" "$am_cv_python_version" >&6; }
   PYTHON_VERSION=$am_cv_python_version
 
 
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $am_display_PYTHON platform" >&5
+printf %s "checking for $am_display_PYTHON platform... " >&6; }
+if test ${am_cv_python_platform+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  am_cv_python_platform=`$PYTHON -c "import sys; sys.stdout.write(sys.platform)"`
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $am_cv_python_platform" >&5
+printf "%s\n" "$am_cv_python_platform" >&6; }
+  PYTHON_PLATFORM=$am_cv_python_platform
 
-  PYTHON_PREFIX='${prefix}'
-
-  PYTHON_EXEC_PREFIX='${exec_prefix}'
 
+                            if test "x$prefix" = xNONE; then
+    am__usable_prefix=$ac_default_prefix
+  else
+    am__usable_prefix=$prefix
+  fi
 
+  # Allow user to request using sys.* values from Python,
+  # instead of the GNU $prefix values.
+
+# Check whether --with-python-sys-prefix was given.
+if test ${with_python_sys_prefix+y}
+then :
+  withval=$with_python_sys_prefix; am_use_python_sys=:
+else $as_nop
+  am_use_python_sys=false
+fi
+
+
+  # Allow user to override whatever the default Python prefix is.
+
+# Check whether --with-python_prefix was given.
+if test ${with_python_prefix+y}
+then :
+  withval=$with_python_prefix; am_python_prefix_subst=$withval
+   am_cv_python_prefix=$withval
+   { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for explicit $am_display_PYTHON prefix" >&5
+printf %s "checking for explicit $am_display_PYTHON prefix... " >&6; }
+   { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $am_cv_python_prefix" >&5
+printf "%s\n" "$am_cv_python_prefix" >&6; }
+else $as_nop
+
+   if $am_use_python_sys; then
+     # using python sys.prefix value, not GNU
+     { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for python default $am_display_PYTHON prefix" >&5
+printf %s "checking for python default $am_display_PYTHON prefix... " >&6; }
+if test ${am_cv_python_prefix+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  am_cv_python_prefix=`$PYTHON -c "import sys; sys.stdout.write(sys.prefix)"`
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $am_cv_python_prefix" >&5
+printf "%s\n" "$am_cv_python_prefix" >&6; }
+
+               case $am_cv_python_prefix in
+     $am__usable_prefix*)
+       am__strip_prefix=`echo "$am__usable_prefix" | sed 's|.|.|g'`
+       am_python_prefix_subst=`echo "$am_cv_python_prefix" | sed "s,^$am__strip_prefix,\\${prefix},"`
+       ;;
+     *)
+       am_python_prefix_subst=$am_cv_python_prefix
+       ;;
+     esac
+   else # using GNU prefix value, not python sys.prefix
+     am_python_prefix_subst='${prefix}'
+     am_python_prefix=$am_python_prefix_subst
+     { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for GNU default $am_display_PYTHON prefix" >&5
+printf %s "checking for GNU default $am_display_PYTHON prefix... " >&6; }
+     { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $am_python_prefix" >&5
+printf "%s\n" "$am_python_prefix" >&6; }
+   fi
+fi
 
-  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $am_display_PYTHON platform" >&5
-$as_echo_n "checking for $am_display_PYTHON platform... " >&6; }
-if ${am_cv_python_platform+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  am_cv_python_platform=`$PYTHON -c "import sys; sys.stdout.write(sys.platform)"`
+  # Substituting python_prefix_subst value.
+  PYTHON_PREFIX=$am_python_prefix_subst
+
+
+  # emacs-page Now do it all over again for Python exec_prefix, but with yet
+  # another conditional: fall back to regular prefix if that was specified.
+
+# Check whether --with-python_exec_prefix was given.
+if test ${with_python_exec_prefix+y}
+then :
+  withval=$with_python_exec_prefix; am_python_exec_prefix_subst=$withval
+   am_cv_python_exec_prefix=$withval
+   { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for explicit $am_display_PYTHON exec_prefix" >&5
+printf %s "checking for explicit $am_display_PYTHON exec_prefix... " >&6; }
+   { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $am_cv_python_exec_prefix" >&5
+printf "%s\n" "$am_cv_python_exec_prefix" >&6; }
+else $as_nop
+
+   # no explicit --with-python_exec_prefix, but if
+   # --with-python_prefix was given, use its value for python_exec_prefix too.
+   if test -n "$with_python_prefix"
+then :
+  am_python_exec_prefix_subst=$with_python_prefix
+    am_cv_python_exec_prefix=$with_python_prefix
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for python_prefix-given $am_display_PYTHON exec_prefix" >&5
+printf %s "checking for python_prefix-given $am_display_PYTHON exec_prefix... " >&6; }
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $am_cv_python_exec_prefix" >&5
+printf "%s\n" "$am_cv_python_exec_prefix" >&6; }
+else $as_nop
+
+    # Set am__usable_exec_prefix whether using GNU or Python values,
+    # since we use that variable for pyexecdir.
+    if test "x$exec_prefix" = xNONE; then
+      am__usable_exec_prefix=$am__usable_prefix
+    else
+      am__usable_exec_prefix=$exec_prefix
+    fi
+    #
+    if $am_use_python_sys; then # using python sys.exec_prefix, not GNU
+      { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for python default $am_display_PYTHON exec_prefix" >&5
+printf %s "checking for python default $am_display_PYTHON exec_prefix... " >&6; }
+if test ${am_cv_python_exec_prefix+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  am_cv_python_exec_prefix=`$PYTHON -c "import sys; sys.stdout.write(sys.exec_prefix)"`
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $am_cv_python_exec_prefix" >&5
+printf "%s\n" "$am_cv_python_exec_prefix" >&6; }
+                        case $am_cv_python_exec_prefix in
+      $am__usable_exec_prefix*)
+        am__strip_prefix=`echo "$am__usable_exec_prefix" | sed 's|.|.|g'`
+        am_python_exec_prefix_subst=`echo "$am_cv_python_exec_prefix" | sed "s,^$am__strip_prefix,\\${exec_prefix},"`
+        ;;
+      *)
+        am_python_exec_prefix_subst=$am_cv_python_exec_prefix
+        ;;
+     esac
+   else # using GNU $exec_prefix, not python sys.exec_prefix
+     am_python_exec_prefix_subst='${exec_prefix}'
+     am_python_exec_prefix=$am_python_exec_prefix_subst
+     { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for GNU default $am_display_PYTHON exec_prefix" >&5
+printf %s "checking for GNU default $am_display_PYTHON exec_prefix... " >&6; }
+     { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $am_python_exec_prefix" >&5
+printf "%s\n" "$am_python_exec_prefix" >&6; }
+   fi
+fi
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $am_cv_python_platform" >&5
-$as_echo "$am_cv_python_platform" >&6; }
-  PYTHON_PLATFORM=$am_cv_python_platform
 
+  # Substituting python_exec_prefix_subst.
+  PYTHON_EXEC_PREFIX=$am_python_exec_prefix_subst
 
-  # Just factor out some code duplication.
+
+  # Factor out some code duplication into this shell variable.
   am_python_setup_sysconfig="\
 import sys
 # Prefer sysconfig over distutils.sysconfig, for better compatibility
@@ -12283,108 +13447,106 @@ except ImportError:
     pass"
 
 
-            { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $am_display_PYTHON script directory" >&5
-$as_echo_n "checking for $am_display_PYTHON script directory... " >&6; }
-if ${am_cv_python_pythondir+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  if test "x$prefix" = xNONE
-     then
-       am_py_prefix=$ac_default_prefix
-     else
-       am_py_prefix=$prefix
-     fi
-     am_cv_python_pythondir=`$PYTHON -c "
+              { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $am_display_PYTHON script directory (pythondir)" >&5
+printf %s "checking for $am_display_PYTHON script directory (pythondir)... " >&6; }
+if test ${am_cv_python_pythondir+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if test "x$am_cv_python_prefix" = x; then
+     am_py_prefix=$am__usable_prefix
+   else
+     am_py_prefix=$am_cv_python_prefix
+   fi
+   am_cv_python_pythondir=`$PYTHON -c "
 $am_python_setup_sysconfig
 if can_use_sysconfig:
-    sitedir = sysconfig.get_path('purelib', vars={'base':'$am_py_prefix'})
+  sitedir = sysconfig.get_path('purelib', vars={'base':'$am_py_prefix'})
 else:
-    from distutils import sysconfig
-    sitedir = sysconfig.get_python_lib(0, 0, prefix='$am_py_prefix')
+  from distutils import sysconfig
+  sitedir = sysconfig.get_python_lib(0, 0, prefix='$am_py_prefix')
 sys.stdout.write(sitedir)"`
-     case $am_cv_python_pythondir in
-     $am_py_prefix*)
-       am__strip_prefix=`echo "$am_py_prefix" | sed 's|.|.|g'`
-       am_cv_python_pythondir=`echo "$am_cv_python_pythondir" | sed "s,^$am__strip_prefix,$PYTHON_PREFIX,"`
-       ;;
-     *)
-       case $am_py_prefix in
-         /usr|/System*) ;;
-         *)
-	  am_cv_python_pythondir=$PYTHON_PREFIX/lib/python$PYTHON_VERSION/site-packages
-	  ;;
-       esac
-       ;;
+   #
+   case $am_cv_python_pythondir in
+   $am_py_prefix*)
+     am__strip_prefix=`echo "$am_py_prefix" | sed 's|.|.|g'`
+     am_cv_python_pythondir=`echo "$am_cv_python_pythondir" | sed "s,^$am__strip_prefix,\\${PYTHON_PREFIX},"`
+     ;;
+   *)
+     case $am_py_prefix in
+       /usr|/System*) ;;
+       *) am_cv_python_pythondir="\${PYTHON_PREFIX}/lib/python$PYTHON_VERSION/site-packages"
+          ;;
      esac
+     ;;
+   esac
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $am_cv_python_pythondir" >&5
-$as_echo "$am_cv_python_pythondir" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $am_cv_python_pythondir" >&5
+printf "%s\n" "$am_cv_python_pythondir" >&6; }
   pythondir=$am_cv_python_pythondir
 
 
-
-  pkgpythondir=\${pythondir}/$PACKAGE
+          pkgpythondir=\${pythondir}/$PACKAGE
 
 
-        { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $am_display_PYTHON extension module directory" >&5
-$as_echo_n "checking for $am_display_PYTHON extension module directory... " >&6; }
-if ${am_cv_python_pyexecdir+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  if test "x$exec_prefix" = xNONE
-     then
-       am_py_exec_prefix=$am_py_prefix
-     else
-       am_py_exec_prefix=$exec_prefix
-     fi
-     am_cv_python_pyexecdir=`$PYTHON -c "
+          { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $am_display_PYTHON extension module directory (pyexecdir)" >&5
+printf %s "checking for $am_display_PYTHON extension module directory (pyexecdir)... " >&6; }
+if test ${am_cv_python_pyexecdir+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if test "x$am_cv_python_exec_prefix" = x; then
+     am_py_exec_prefix=$am__usable_exec_prefix
+   else
+     am_py_exec_prefix=$am_cv_python_exec_prefix
+   fi
+   am_cv_python_pyexecdir=`$PYTHON -c "
 $am_python_setup_sysconfig
 if can_use_sysconfig:
-    sitedir = sysconfig.get_path('platlib', vars={'platbase':'$am_py_prefix'})
+  sitedir = sysconfig.get_path('platlib', vars={'platbase':'$am_py_exec_prefix'})
 else:
-    from distutils import sysconfig
-    sitedir = sysconfig.get_python_lib(1, 0, prefix='$am_py_prefix')
+  from distutils import sysconfig
+  sitedir = sysconfig.get_python_lib(1, 0, prefix='$am_py_exec_prefix')
 sys.stdout.write(sitedir)"`
-     case $am_cv_python_pyexecdir in
-     $am_py_exec_prefix*)
-       am__strip_prefix=`echo "$am_py_exec_prefix" | sed 's|.|.|g'`
-       am_cv_python_pyexecdir=`echo "$am_cv_python_pyexecdir" | sed "s,^$am__strip_prefix,$PYTHON_EXEC_PREFIX,"`
-       ;;
-     *)
-       case $am_py_exec_prefix in
-         /usr|/System*) ;;
-         *)
-	   am_cv_python_pyexecdir=$PYTHON_EXEC_PREFIX/lib/python$PYTHON_VERSION/site-packages
-	   ;;
-       esac
-       ;;
+   #
+   case $am_cv_python_pyexecdir in
+   $am_py_exec_prefix*)
+     am__strip_prefix=`echo "$am_py_exec_prefix" | sed 's|.|.|g'`
+     am_cv_python_pyexecdir=`echo "$am_cv_python_pyexecdir" | sed "s,^$am__strip_prefix,\\${PYTHON_EXEC_PREFIX},"`
+     ;;
+   *)
+     case $am_py_exec_prefix in
+       /usr|/System*) ;;
+       *) am_cv_python_pyexecdir="\${PYTHON_EXEC_PREFIX}/lib/python$PYTHON_VERSION/site-packages"
+          ;;
      esac
+     ;;
+   esac
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $am_cv_python_pyexecdir" >&5
-$as_echo "$am_cv_python_pyexecdir" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $am_cv_python_pyexecdir" >&5
+printf "%s\n" "$am_cv_python_pyexecdir" >&6; }
   pyexecdir=$am_cv_python_pyexecdir
 
 
-
-  pkgpyexecdir=\${pyexecdir}/$PACKAGE
+      pkgpyexecdir=\${pyexecdir}/$PACKAGE
 
 
 
   fi
 
-
 	PYTHON3=$PYTHON
 	test -z "$PYTHON3" && as_fn_error $? "python3 is required for --enable-python3_bindings or --enable-dbus-service but cannot be found" "$LINENO" 5
 	if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}python3-config", so it can be a program name with args.
 set dummy ${ac_tool_prefix}python3-config; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_PYTHON3_CONFIG+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_PYTHON3_CONFIG+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $PYTHON3_CONFIG in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_PYTHON3_CONFIG="$PYTHON3_CONFIG" # Let the user override the test with a path.
@@ -12394,11 +13556,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_PYTHON3_CONFIG="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_PYTHON3_CONFIG="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -12410,11 +13576,11 @@ esac
 fi
 PYTHON3_CONFIG=$ac_cv_path_PYTHON3_CONFIG
 if test -n "$PYTHON3_CONFIG"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $PYTHON3_CONFIG" >&5
-$as_echo "$PYTHON3_CONFIG" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $PYTHON3_CONFIG" >&5
+printf "%s\n" "$PYTHON3_CONFIG" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -12423,11 +13589,12 @@ if test -z "$ac_cv_path_PYTHON3_CONFIG"; then
   ac_pt_PYTHON3_CONFIG=$PYTHON3_CONFIG
   # Extract the first word of "python3-config", so it can be a program name with args.
 set dummy python3-config; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_ac_pt_PYTHON3_CONFIG+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_ac_pt_PYTHON3_CONFIG+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $ac_pt_PYTHON3_CONFIG in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_ac_pt_PYTHON3_CONFIG="$ac_pt_PYTHON3_CONFIG" # Let the user override the test with a path.
@@ -12437,11 +13604,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_ac_pt_PYTHON3_CONFIG="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_PYTHON3_CONFIG="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -12453,11 +13624,11 @@ esac
 fi
 ac_pt_PYTHON3_CONFIG=$ac_cv_path_ac_pt_PYTHON3_CONFIG
 if test -n "$ac_pt_PYTHON3_CONFIG"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_PYTHON3_CONFIG" >&5
-$as_echo "$ac_pt_PYTHON3_CONFIG" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_pt_PYTHON3_CONFIG" >&5
+printf "%s\n" "$ac_pt_PYTHON3_CONFIG" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_pt_PYTHON3_CONFIG" = x; then
@@ -12465,8 +13636,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     PYTHON3_CONFIG=$ac_pt_PYTHON3_CONFIG
@@ -12493,17 +13664,17 @@ fi
         fi
     fi
     PYTHON_NAME=`basename $PYTHON`
-    { $as_echo "$as_me:${as_lineno-$LINENO}: checking $PYTHON_NAME module: pyudev" >&5
-$as_echo_n "checking $PYTHON_NAME module: pyudev... " >&6; }
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking $PYTHON_NAME module: pyudev" >&5
+printf %s "checking $PYTHON_NAME module: pyudev... " >&6; }
     $PYTHON -c "import pyudev" 2>/dev/null
     if test $? -eq 0;
     then
-        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+printf "%s\n" "yes" >&6; }
         eval HAVE_PYMOD_PYUDEV=yes
     else
-        { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
         eval HAVE_PYMOD_PYUDEV=no
         #
         if test -n "Required"
@@ -12524,17 +13695,17 @@ $as_echo "no" >&6; }
         fi
     fi
     PYTHON_NAME=`basename $PYTHON`
-    { $as_echo "$as_me:${as_lineno-$LINENO}: checking $PYTHON_NAME module: dbus" >&5
-$as_echo_n "checking $PYTHON_NAME module: dbus... " >&6; }
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking $PYTHON_NAME module: dbus" >&5
+printf %s "checking $PYTHON_NAME module: dbus... " >&6; }
     $PYTHON -c "import dbus" 2>/dev/null
     if test $? -eq 0;
     then
-        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+printf "%s\n" "yes" >&6; }
         eval HAVE_PYMOD_DBUS=yes
     else
-        { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
         eval HAVE_PYMOD_DBUS=no
         #
         if test -n "Required"
@@ -12548,68 +13719,74 @@ fi
 
 ################################################################################
 # Check whether --enable-pkgconfig was given.
-if test "${enable_pkgconfig+set}" = set; then :
+if test ${enable_pkgconfig+y}
+then :
   enableval=$enable_pkgconfig; PKGCONFIG=$enableval
-else
+else $as_nop
   PKGCONFIG=no
 fi
 
 
 ################################################################################
 # Check whether --enable-write_install was given.
-if test "${enable_write_install+set}" = set; then :
+if test ${enable_write_install+y}
+then :
   enableval=$enable_write_install; WRITE_INSTALL=$enableval
-else
+else $as_nop
   WRITE_INSTALL=no
 fi
 
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to install fsadm" >&5
-$as_echo_n "checking whether to install fsadm... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to install fsadm" >&5
+printf %s "checking whether to install fsadm... " >&6; }
 # Check whether --enable-fsadm was given.
-if test "${enable_fsadm+set}" = set; then :
+if test ${enable_fsadm+y}
+then :
   enableval=$enable_fsadm; FSADM=$enableval
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $FSADM" >&5
-$as_echo "$FSADM" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $FSADM" >&5
+printf "%s\n" "$FSADM" >&6; }
 
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to install lvm_import_vdo" >&5
-$as_echo_n "checking whether to install lvm_import_vdo... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to install lvm_import_vdo" >&5
+printf %s "checking whether to install lvm_import_vdo... " >&6; }
 # Check whether --enable-lvmimportvdo was given.
-if test "${enable_lvmimportvdo+set}" = set; then :
+if test ${enable_lvmimportvdo+y}
+then :
   enableval=$enable_lvmimportvdo; LVMIMPORTVDO=$enableval
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $LVMIMPORTVDO" >&5
-$as_echo "$LVMIMPORTVDO" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $LVMIMPORTVDO" >&5
+printf "%s\n" "$LVMIMPORTVDO" >&6; }
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to install blkdeactivate" >&5
-$as_echo_n "checking whether to install blkdeactivate... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to install blkdeactivate" >&5
+printf %s "checking whether to install blkdeactivate... " >&6; }
 # Check whether --enable-blkdeactivate was given.
-if test "${enable_blkdeactivate+set}" = set; then :
+if test ${enable_blkdeactivate+y}
+then :
   enableval=$enable_blkdeactivate; BLKDEACTIVATE=$enableval
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $BLKDEACTIVATE" >&5
-$as_echo "$BLKDEACTIVATE" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BLKDEACTIVATE" >&5
+printf "%s\n" "$BLKDEACTIVATE" >&6; }
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to use dmeventd" >&5
-$as_echo_n "checking whether to use dmeventd... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to use dmeventd" >&5
+printf %s "checking whether to use dmeventd... " >&6; }
 # Check whether --enable-dmeventd was given.
-if test "${enable_dmeventd+set}" = set; then :
+if test ${enable_dmeventd+y}
+then :
   enableval=$enable_dmeventd; BUILD_DMEVENTD=$enableval
-else
+else $as_nop
   BUILD_DMEVENTD=no
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $BUILD_DMEVENTD" >&5
-$as_echo "$BUILD_DMEVENTD" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BUILD_DMEVENTD" >&5
+printf "%s\n" "$BUILD_DMEVENTD" >&6; }
 
 if test "$BUILD_DMEVENTD" = yes; then
    if test "$MIRRORS" != internal; then
@@ -12620,17 +13797,18 @@ if test "$BUILD_DMEVENTD" = yes; then
    fi
 
 
-$as_echo "#define DMEVENTD 1" >>confdefs.h
+printf "%s\n" "#define DMEVENTD 1" >>confdefs.h
 
 fi
 
 ################################################################################
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for getline in -lc" >&5
-$as_echo_n "checking for getline in -lc... " >&6; }
-if ${ac_cv_lib_c_getline+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for getline in -lc" >&5
+printf %s "checking for getline in -lc... " >&6; }
+if test ${ac_cv_lib_c_getline+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   ac_check_lib_save_LIBS=$LIBS
 LIBS="-lc  $LIBS"
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -12639,43 +13817,43 @@ cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* Override any GCC internal prototype to avoid an error.
    Use char because int might match the return type of a GCC
    builtin and then its argument prototype would still apply.  */
-#ifdef __cplusplus
-extern "C"
-#endif
 char getline ();
 int
-main ()
+main (void)
 {
 return getline ();
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
+if ac_fn_c_try_link "$LINENO"
+then :
   ac_cv_lib_c_getline=yes
-else
+else $as_nop
   ac_cv_lib_c_getline=no
 fi
-rm -f core conftest.err conftest.$ac_objext \
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
     conftest$ac_exeext conftest.$ac_ext
 LIBS=$ac_check_lib_save_LIBS
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_c_getline" >&5
-$as_echo "$ac_cv_lib_c_getline" >&6; }
-if test "x$ac_cv_lib_c_getline" = xyes; then :
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_c_getline" >&5
+printf "%s\n" "$ac_cv_lib_c_getline" >&6; }
+if test "x$ac_cv_lib_c_getline" = xyes
+then :
 
-$as_echo "#define HAVE_GETLINE 1" >>confdefs.h
+printf "%s\n" "#define HAVE_GETLINE 1" >>confdefs.h
 
 fi
 
 
 ################################################################################
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for canonicalize_file_name in -lc" >&5
-$as_echo_n "checking for canonicalize_file_name in -lc... " >&6; }
-if ${ac_cv_lib_c_canonicalize_file_name+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for canonicalize_file_name in -lc" >&5
+printf %s "checking for canonicalize_file_name in -lc... " >&6; }
+if test ${ac_cv_lib_c_canonicalize_file_name+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   ac_check_lib_save_LIBS=$LIBS
 LIBS="-lc  $LIBS"
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -12684,42 +13862,42 @@ cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* Override any GCC internal prototype to avoid an error.
    Use char because int might match the return type of a GCC
    builtin and then its argument prototype would still apply.  */
-#ifdef __cplusplus
-extern "C"
-#endif
 char canonicalize_file_name ();
 int
-main ()
+main (void)
 {
 return canonicalize_file_name ();
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
+if ac_fn_c_try_link "$LINENO"
+then :
   ac_cv_lib_c_canonicalize_file_name=yes
-else
+else $as_nop
   ac_cv_lib_c_canonicalize_file_name=no
 fi
-rm -f core conftest.err conftest.$ac_objext \
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
     conftest$ac_exeext conftest.$ac_ext
 LIBS=$ac_check_lib_save_LIBS
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_c_canonicalize_file_name" >&5
-$as_echo "$ac_cv_lib_c_canonicalize_file_name" >&6; }
-if test "x$ac_cv_lib_c_canonicalize_file_name" = xyes; then :
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_c_canonicalize_file_name" >&5
+printf "%s\n" "$ac_cv_lib_c_canonicalize_file_name" >&6; }
+if test "x$ac_cv_lib_c_canonicalize_file_name" = xyes
+then :
 
-$as_echo "#define HAVE_CANONICALIZE_FILE_NAME 1" >>confdefs.h
+printf "%s\n" "#define HAVE_CANONICALIZE_FILE_NAME 1" >>confdefs.h
 
 fi
 
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for dlopen in -ldl" >&5
-$as_echo_n "checking for dlopen in -ldl... " >&6; }
-if ${ac_cv_lib_dl_dlopen+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for dlopen in -ldl" >&5
+printf %s "checking for dlopen in -ldl... " >&6; }
+if test ${ac_cv_lib_dl_dlopen+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   ac_check_lib_save_LIBS=$LIBS
 LIBS="-ldl  $LIBS"
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -12728,36 +13906,35 @@ cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* Override any GCC internal prototype to avoid an error.
    Use char because int might match the return type of a GCC
    builtin and then its argument prototype would still apply.  */
-#ifdef __cplusplus
-extern "C"
-#endif
 char dlopen ();
 int
-main ()
+main (void)
 {
 return dlopen ();
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
+if ac_fn_c_try_link "$LINENO"
+then :
   ac_cv_lib_dl_dlopen=yes
-else
+else $as_nop
   ac_cv_lib_dl_dlopen=no
 fi
-rm -f core conftest.err conftest.$ac_objext \
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
     conftest$ac_exeext conftest.$ac_ext
 LIBS=$ac_check_lib_save_LIBS
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_dl_dlopen" >&5
-$as_echo "$ac_cv_lib_dl_dlopen" >&6; }
-if test "x$ac_cv_lib_dl_dlopen" = xyes; then :
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_dl_dlopen" >&5
+printf "%s\n" "$ac_cv_lib_dl_dlopen" >&6; }
+if test "x$ac_cv_lib_dl_dlopen" = xyes
+then :
 
-$as_echo "#define HAVE_LIBDL 1" >>confdefs.h
+printf "%s\n" "#define HAVE_LIBDL 1" >>confdefs.h
 
 	      DL_LIBS="-ldl"
 	      HAVE_LIBDL=yes
-else
+else $as_nop
   DL_LIBS=
 	      HAVE_LIBDL=no
 fi
@@ -12770,11 +13947,12 @@ if [ \( "$LVM1" = shared -o "$POOL" = shared \
 fi
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for log10 in -lm" >&5
-$as_echo_n "checking for log10 in -lm... " >&6; }
-if ${ac_cv_lib_m_log10+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for log10 in -lm" >&5
+printf %s "checking for log10 in -lm... " >&6; }
+if test ${ac_cv_lib_m_log10+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   ac_check_lib_save_LIBS=$LIBS
 LIBS="-lm  $LIBS"
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -12783,42 +13961,42 @@ cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* Override any GCC internal prototype to avoid an error.
    Use char because int might match the return type of a GCC
    builtin and then its argument prototype would still apply.  */
-#ifdef __cplusplus
-extern "C"
-#endif
 char log10 ();
 int
-main ()
+main (void)
 {
 return log10 ();
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
+if ac_fn_c_try_link "$LINENO"
+then :
   ac_cv_lib_m_log10=yes
-else
+else $as_nop
   ac_cv_lib_m_log10=no
 fi
-rm -f core conftest.err conftest.$ac_objext \
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
     conftest$ac_exeext conftest.$ac_ext
 LIBS=$ac_check_lib_save_LIBS
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_m_log10" >&5
-$as_echo "$ac_cv_lib_m_log10" >&6; }
-if test "x$ac_cv_lib_m_log10" = xyes; then :
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_m_log10" >&5
+printf "%s\n" "$ac_cv_lib_m_log10" >&6; }
+if test "x$ac_cv_lib_m_log10" = xyes
+then :
   M_LIBS="-lm"
-else
+else $as_nop
   hard_bailout
 fi
 
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for pthread_mutex_lock in -lpthread" >&5
-$as_echo_n "checking for pthread_mutex_lock in -lpthread... " >&6; }
-if ${ac_cv_lib_pthread_pthread_mutex_lock+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for pthread_mutex_lock in -lpthread" >&5
+printf %s "checking for pthread_mutex_lock in -lpthread... " >&6; }
+if test ${ac_cv_lib_pthread_pthread_mutex_lock+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   ac_check_lib_save_LIBS=$LIBS
 LIBS="-lpthread  $LIBS"
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -12827,54 +14005,55 @@ cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* Override any GCC internal prototype to avoid an error.
    Use char because int might match the return type of a GCC
    builtin and then its argument prototype would still apply.  */
-#ifdef __cplusplus
-extern "C"
-#endif
 char pthread_mutex_lock ();
 int
-main ()
+main (void)
 {
 return pthread_mutex_lock ();
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
+if ac_fn_c_try_link "$LINENO"
+then :
   ac_cv_lib_pthread_pthread_mutex_lock=yes
-else
+else $as_nop
   ac_cv_lib_pthread_pthread_mutex_lock=no
 fi
-rm -f core conftest.err conftest.$ac_objext \
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
     conftest$ac_exeext conftest.$ac_ext
 LIBS=$ac_check_lib_save_LIBS
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_pthread_pthread_mutex_lock" >&5
-$as_echo "$ac_cv_lib_pthread_pthread_mutex_lock" >&6; }
-if test "x$ac_cv_lib_pthread_pthread_mutex_lock" = xyes; then :
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_pthread_pthread_mutex_lock" >&5
+printf "%s\n" "$ac_cv_lib_pthread_pthread_mutex_lock" >&6; }
+if test "x$ac_cv_lib_pthread_pthread_mutex_lock" = xyes
+then :
   PTHREAD_LIBS="-lpthread"
-else
+else $as_nop
   hard_bailout
 fi
 
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable selinux support" >&5
-$as_echo_n "checking whether to enable selinux support... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to enable selinux support" >&5
+printf %s "checking whether to enable selinux support... " >&6; }
 # Check whether --enable-selinux was given.
-if test "${enable_selinux+set}" = set; then :
+if test ${enable_selinux+y}
+then :
   enableval=$enable_selinux; SELINUX=$enableval
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $SELINUX" >&5
-$as_echo "$SELINUX" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $SELINUX" >&5
+printf "%s\n" "$SELINUX" >&6; }
 
 ################################################################################
 if test "$SELINUX" = yes; then
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for sepol_check_context in -lsepol" >&5
-$as_echo_n "checking for sepol_check_context in -lsepol... " >&6; }
-if ${ac_cv_lib_sepol_sepol_check_context+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for sepol_check_context in -lsepol" >&5
+printf %s "checking for sepol_check_context in -lsepol... " >&6; }
+if test ${ac_cv_lib_sepol_sepol_check_context+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   ac_check_lib_save_LIBS=$LIBS
 LIBS="-lsepol  $LIBS"
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -12883,43 +14062,43 @@ cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* Override any GCC internal prototype to avoid an error.
    Use char because int might match the return type of a GCC
    builtin and then its argument prototype would still apply.  */
-#ifdef __cplusplus
-extern "C"
-#endif
 char sepol_check_context ();
 int
-main ()
+main (void)
 {
 return sepol_check_context ();
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
+if ac_fn_c_try_link "$LINENO"
+then :
   ac_cv_lib_sepol_sepol_check_context=yes
-else
+else $as_nop
   ac_cv_lib_sepol_sepol_check_context=no
 fi
-rm -f core conftest.err conftest.$ac_objext \
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
     conftest$ac_exeext conftest.$ac_ext
 LIBS=$ac_check_lib_save_LIBS
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_sepol_sepol_check_context" >&5
-$as_echo "$ac_cv_lib_sepol_sepol_check_context" >&6; }
-if test "x$ac_cv_lib_sepol_sepol_check_context" = xyes; then :
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_sepol_sepol_check_context" >&5
+printf "%s\n" "$ac_cv_lib_sepol_sepol_check_context" >&6; }
+if test "x$ac_cv_lib_sepol_sepol_check_context" = xyes
+then :
 
 
-$as_echo "#define HAVE_SEPOL 1" >>confdefs.h
+printf "%s\n" "#define HAVE_SEPOL 1" >>confdefs.h
 
 		SELINUX_LIBS="-lsepol"
 fi
 
 
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for is_selinux_enabled in -lselinux" >&5
-$as_echo_n "checking for is_selinux_enabled in -lselinux... " >&6; }
-if ${ac_cv_lib_selinux_is_selinux_enabled+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for is_selinux_enabled in -lselinux" >&5
+printf %s "checking for is_selinux_enabled in -lselinux... " >&6; }
+if test ${ac_cv_lib_selinux_is_selinux_enabled+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   ac_check_lib_save_LIBS=$LIBS
 LIBS="-lselinux  $LIBS"
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -12928,67 +14107,59 @@ cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* Override any GCC internal prototype to avoid an error.
    Use char because int might match the return type of a GCC
    builtin and then its argument prototype would still apply.  */
-#ifdef __cplusplus
-extern "C"
-#endif
 char is_selinux_enabled ();
 int
-main ()
+main (void)
 {
 return is_selinux_enabled ();
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
+if ac_fn_c_try_link "$LINENO"
+then :
   ac_cv_lib_selinux_is_selinux_enabled=yes
-else
+else $as_nop
   ac_cv_lib_selinux_is_selinux_enabled=no
 fi
-rm -f core conftest.err conftest.$ac_objext \
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
     conftest$ac_exeext conftest.$ac_ext
 LIBS=$ac_check_lib_save_LIBS
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_selinux_is_selinux_enabled" >&5
-$as_echo "$ac_cv_lib_selinux_is_selinux_enabled" >&6; }
-if test "x$ac_cv_lib_selinux_is_selinux_enabled" = xyes; then :
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_selinux_is_selinux_enabled" >&5
+printf "%s\n" "$ac_cv_lib_selinux_is_selinux_enabled" >&6; }
+if test "x$ac_cv_lib_selinux_is_selinux_enabled" = xyes
+then :
 
-		for ac_header in selinux/selinux.h
+		       for ac_header in selinux/selinux.h
 do :
-  ac_fn_c_check_header_mongrel "$LINENO" "selinux/selinux.h" "ac_cv_header_selinux_selinux_h" "$ac_includes_default"
-if test "x$ac_cv_header_selinux_selinux_h" = xyes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_SELINUX_SELINUX_H 1
-_ACEOF
+  ac_fn_c_check_header_compile "$LINENO" "selinux/selinux.h" "ac_cv_header_selinux_selinux_h" "$ac_includes_default"
+if test "x$ac_cv_header_selinux_selinux_h" = xyes
+then :
+  printf "%s\n" "#define HAVE_SELINUX_SELINUX_H 1" >>confdefs.h
 
-else
+else $as_nop
   hard_bailout
 fi
 
 done
-
-		for ac_header in selinux/label.h
-do :
-  ac_fn_c_check_header_mongrel "$LINENO" "selinux/label.h" "ac_cv_header_selinux_label_h" "$ac_includes_default"
-if test "x$ac_cv_header_selinux_label_h" = xyes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_SELINUX_LABEL_H 1
-_ACEOF
+		ac_fn_c_check_header_compile "$LINENO" "selinux/label.h" "ac_cv_header_selinux_label_h" "$ac_includes_default"
+if test "x$ac_cv_header_selinux_label_h" = xyes
+then :
+  printf "%s\n" "#define HAVE_SELINUX_LABEL_H 1" >>confdefs.h
 
 fi
 
-done
-
 
-$as_echo "#define HAVE_SELINUX 1" >>confdefs.h
+printf "%s\n" "#define HAVE_SELINUX 1" >>confdefs.h
 
 		SELINUX_LIBS="-lselinux $SELINUX_LIBS"
 		SELINUX_PC="libselinux"
 		HAVE_SELINUX=yes
-else
+else $as_nop
 
-		{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Disabling selinux" >&5
-$as_echo "$as_me: WARNING: Disabling selinux" >&2;}
+		{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: Disabling selinux" >&5
+printf "%s\n" "$as_me: WARNING: Disabling selinux" >&2;}
 		SELINUX_LIBS=
 		SELINUX_PC=
 		HAVE_SELINUX=no
@@ -12998,11 +14169,12 @@ fi
 
 ################################################################################
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for BLKZEROOUT in sys/ioctl.h." >&5
-$as_echo_n "checking for BLKZEROOUT in sys/ioctl.h.... " >&6; }
-if ${ac_cv_have_blkzeroout+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for BLKZEROOUT in sys/ioctl.h." >&5
+printf %s "checking for BLKZEROOUT in sys/ioctl.h.... " >&6; }
+if test ${ac_cv_have_blkzeroout+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 #include <sys/ioctl.h>
@@ -13010,70 +14182,75 @@ else
 int bar(void) { return ioctl(0, BLKZEROOUT, 0); }
 
 int
-main ()
+main (void)
 {
 
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   ac_cv_have_blkzeroout=yes
-else
+else $as_nop
   ac_cv_have_blkzeroout=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_have_blkzeroout" >&5
-$as_echo "$ac_cv_have_blkzeroout" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_have_blkzeroout" >&5
+printf "%s\n" "$ac_cv_have_blkzeroout" >&6; }
 
 
 # Check whether --enable-blkzeroout was given.
-if test "${enable_blkzeroout+set}" = set; then :
+if test ${enable_blkzeroout+y}
+then :
   enableval=$enable_blkzeroout; BLKZEROOUT=$enableval
-else
+else $as_nop
   BLKZEROOUT=yes
 fi
 
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to use BLKZEROOUT for device zeroing" >&5
-$as_echo_n "checking whether to use BLKZEROOUT for device zeroing... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to use BLKZEROOUT for device zeroing" >&5
+printf %s "checking whether to use BLKZEROOUT for device zeroing... " >&6; }
 if test "$BLKZEROOUT" = yes; then
-	if test $ac_cv_have_blkzeroout = yes; then :
+	if test $ac_cv_have_blkzeroout = yes
+then :
 
-$as_echo "#define HAVE_BLKZEROOUT 1" >>confdefs.h
+printf "%s\n" "#define HAVE_BLKZEROOUT 1" >>confdefs.h
 
-else
+else $as_nop
   BLKZEROOUT=no
 fi
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $BLKZEROOUT" >&5
-$as_echo "$BLKZEROOUT" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BLKZEROOUT" >&5
+printf "%s\n" "$BLKZEROOUT" >&6; }
 
 
 ################################################################################
 RT_LIBS=
 HAVE_REALTIME=no
 if test "$REALTIME" = yes; then
-	for ac_func in clock_gettime
+
+  for ac_func in clock_gettime
 do :
   ac_fn_c_check_func "$LINENO" "clock_gettime" "ac_cv_func_clock_gettime"
-if test "x$ac_cv_func_clock_gettime" = xyes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_CLOCK_GETTIME 1
-_ACEOF
+if test "x$ac_cv_func_clock_gettime" = xyes
+then :
+  printf "%s\n" "#define HAVE_CLOCK_GETTIME 1" >>confdefs.h
  HAVE_REALTIME=yes
 fi
-done
 
+done
 
-	if test "$HAVE_REALTIME" != yes; then :
+	if test "$HAVE_REALTIME" != yes
+then :
    # try again with -lrt
-	      { $as_echo "$as_me:${as_lineno-$LINENO}: checking for clock_gettime in -lrt" >&5
-$as_echo_n "checking for clock_gettime in -lrt... " >&6; }
-if ${ac_cv_lib_rt_clock_gettime+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+	      { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for clock_gettime in -lrt" >&5
+printf %s "checking for clock_gettime in -lrt... " >&6; }
+if test ${ac_cv_lib_rt_clock_gettime+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   ac_check_lib_save_LIBS=$LIBS
 LIBS="-lrt  $LIBS"
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -13082,30 +14259,29 @@ cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* Override any GCC internal prototype to avoid an error.
    Use char because int might match the return type of a GCC
    builtin and then its argument prototype would still apply.  */
-#ifdef __cplusplus
-extern "C"
-#endif
 char clock_gettime ();
 int
-main ()
+main (void)
 {
 return clock_gettime ();
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
+if ac_fn_c_try_link "$LINENO"
+then :
   ac_cv_lib_rt_clock_gettime=yes
-else
+else $as_nop
   ac_cv_lib_rt_clock_gettime=no
 fi
-rm -f core conftest.err conftest.$ac_objext \
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
     conftest$ac_exeext conftest.$ac_ext
 LIBS=$ac_check_lib_save_LIBS
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_rt_clock_gettime" >&5
-$as_echo "$ac_cv_lib_rt_clock_gettime" >&6; }
-if test "x$ac_cv_lib_rt_clock_gettime" = xyes; then :
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_rt_clock_gettime" >&5
+printf "%s\n" "$ac_cv_lib_rt_clock_gettime" >&6; }
+if test "x$ac_cv_lib_rt_clock_gettime" = xyes
+then :
   RT_LIBS="-lrt"; HAVE_REALTIME=yes
 fi
 
@@ -13113,79 +14289,80 @@ fi
 
 	if test "$HAVE_REALTIME" = yes; then
 
-$as_echo "#define HAVE_REALTIME 1" >>confdefs.h
+printf "%s\n" "#define HAVE_REALTIME 1" >>confdefs.h
 
 	else
-		{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Disabling realtime clock" >&5
-$as_echo "$as_me: WARNING: Disabling realtime clock" >&2;}
+		{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: Disabling realtime clock" >&5
+printf "%s\n" "$as_me: WARNING: Disabling realtime clock" >&2;}
 	fi
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for struct stat has st_ctim." >&5
-$as_echo_n "checking for struct stat has st_ctim.... " >&6; }
-if ${ac_cv_stat_st_ctim+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for struct stat has st_ctim." >&5
+printf %s "checking for struct stat has st_ctim.... " >&6; }
+if test ${ac_cv_stat_st_ctim+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 #include <sys/stat.h>
 long bar(void) { struct stat s; return (long)(s.st_ctim.tv_sec + s.st_ctim.tv_nsec);}
 
 int
-main ()
+main (void)
 {
 
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   ac_cv_stat_st_ctim=yes
-else
+else $as_nop
   ac_cv_stat_st_ctim=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_stat_st_ctim" >&5
-$as_echo "$ac_cv_stat_st_ctim" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_stat_st_ctim" >&5
+printf "%s\n" "$ac_cv_stat_st_ctim" >&6; }
 
-if test $ac_cv_stat_st_ctim = yes; then :
+if test $ac_cv_stat_st_ctim = yes
+then :
 
-$as_echo "#define HAVE_STAT_ST_CTIM 1" >>confdefs.h
+printf "%s\n" "#define HAVE_STAT_ST_CTIM 1" >>confdefs.h
 
 fi
 
 ################################################################################
-for ac_header in getopt.h
+       for ac_header in getopt.h
 do :
-  ac_fn_c_check_header_mongrel "$LINENO" "getopt.h" "ac_cv_header_getopt_h" "$ac_includes_default"
-if test "x$ac_cv_header_getopt_h" = xyes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_GETOPT_H 1
-_ACEOF
+  ac_fn_c_check_header_compile "$LINENO" "getopt.h" "ac_cv_header_getopt_h" "$ac_includes_default"
+if test "x$ac_cv_header_getopt_h" = xyes
+then :
+  printf "%s\n" "#define HAVE_GETOPT_H 1" >>confdefs.h
 
-$as_echo "#define HAVE_GETOPTLONG 1" >>confdefs.h
+printf "%s\n" "#define HAVE_GETOPTLONG 1" >>confdefs.h
 
 fi
 
 done
 
-
 ################################################################################
 if test "$EDITLINE" == yes; then
 
 pkg_failed=no
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for EDITLINE" >&5
-$as_echo_n "checking for EDITLINE... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for EDITLINE" >&5
+printf %s "checking for EDITLINE... " >&6; }
 
 if test -n "$EDITLINE_CFLAGS"; then
     pkg_cv_EDITLINE_CFLAGS="$EDITLINE_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libedit\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libedit\""; } >&5
   ($PKG_CONFIG --exists --print-errors "libedit") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_EDITLINE_CFLAGS=`$PKG_CONFIG --cflags "libedit" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
@@ -13199,10 +14376,10 @@ if test -n "$EDITLINE_LIBS"; then
     pkg_cv_EDITLINE_LIBS="$EDITLINE_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libedit\""; } >&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libedit\""; } >&5
   ($PKG_CONFIG --exists --print-errors "libedit") 2>&5
   ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_EDITLINE_LIBS=`$PKG_CONFIG --libs "libedit" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
@@ -13216,8 +14393,8 @@ fi
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -13235,18 +14412,18 @@ fi
 	as_fn_error $? "libedit could not be found which is required for the --enable-editline option." "$LINENO" 5
 
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 	as_fn_error $? "libedit could not be found which is required for the --enable-editline option." "$LINENO" 5
 
 else
 	EDITLINE_CFLAGS=$pkg_cv_EDITLINE_CFLAGS
 	EDITLINE_LIBS=$pkg_cv_EDITLINE_LIBS
-        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+printf "%s\n" "yes" >&6; }
 
 
-$as_echo "#define EDITLINE_SUPPORT 1" >>confdefs.h
+printf "%s\n" "#define EDITLINE_SUPPORT 1" >>confdefs.h
 
 fi
 fi
@@ -13254,11 +14431,12 @@ fi
 ################################################################################
 if test "$READLINE" != no; then
 	lvm_saved_libs=$LIBS
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for library containing tgetent" >&5
-$as_echo_n "checking for library containing tgetent... " >&6; }
-if ${ac_cv_search_tgetent+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for library containing tgetent" >&5
+printf %s "checking for library containing tgetent... " >&6; }
+if test ${ac_cv_search_tgetent+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   ac_func_search_save_LIBS=$LIBS
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
@@ -13266,49 +14444,51 @@ cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* Override any GCC internal prototype to avoid an error.
    Use char because int might match the return type of a GCC
    builtin and then its argument prototype would still apply.  */
-#ifdef __cplusplus
-extern "C"
-#endif
 char tgetent ();
 int
-main ()
+main (void)
 {
 return tgetent ();
   ;
   return 0;
 }
 _ACEOF
-for ac_lib in '' tinfo ncurses curses termcap termlib; do
+for ac_lib in '' tinfo ncurses curses termcap termlib
+do
   if test -z "$ac_lib"; then
     ac_res="none required"
   else
     ac_res=-l$ac_lib
     LIBS="-l$ac_lib  $ac_func_search_save_LIBS"
   fi
-  if ac_fn_c_try_link "$LINENO"; then :
+  if ac_fn_c_try_link "$LINENO"
+then :
   ac_cv_search_tgetent=$ac_res
 fi
-rm -f core conftest.err conftest.$ac_objext \
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
     conftest$ac_exeext
-  if ${ac_cv_search_tgetent+:} false; then :
+  if test ${ac_cv_search_tgetent+y}
+then :
   break
 fi
 done
-if ${ac_cv_search_tgetent+:} false; then :
+if test ${ac_cv_search_tgetent+y}
+then :
 
-else
+else $as_nop
   ac_cv_search_tgetent=no
 fi
 rm conftest.$ac_ext
 LIBS=$ac_func_search_save_LIBS
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_search_tgetent" >&5
-$as_echo "$ac_cv_search_tgetent" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_search_tgetent" >&5
+printf "%s\n" "$ac_cv_search_tgetent" >&6; }
 ac_res=$ac_cv_search_tgetent
-if test "$ac_res" != no; then :
+if test "$ac_res" != no
+then :
   test "$ac_res" = "none required" || LIBS="$ac_res $LIBS"
   READLINE_LIBS=$ac_cv_search_tgetent
-else
+else $as_nop
 
 		if test "$READLINE" = yes; then
 			as_fn_error $? "termcap could not be found which is required for the
@@ -13322,11 +14502,12 @@ Note: (n)curses also seems to work as a substitute for termcap.  This was
 		fi
 fi
 
-		{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for readline in -lreadline" >&5
-$as_echo_n "checking for readline in -lreadline... " >&6; }
-if ${ac_cv_lib_readline_readline+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+		{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for readline in -lreadline" >&5
+printf %s "checking for readline in -lreadline... " >&6; }
+if test ${ac_cv_lib_readline_readline+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   ac_check_lib_save_LIBS=$LIBS
 LIBS="-lreadline  $LIBS"
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -13335,41 +14516,41 @@ cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* Override any GCC internal prototype to avoid an error.
    Use char because int might match the return type of a GCC
    builtin and then its argument prototype would still apply.  */
-#ifdef __cplusplus
-extern "C"
-#endif
 char readline ();
 int
-main ()
+main (void)
 {
 return readline ();
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
+if ac_fn_c_try_link "$LINENO"
+then :
   ac_cv_lib_readline_readline=yes
-else
+else $as_nop
   ac_cv_lib_readline_readline=no
 fi
-rm -f core conftest.err conftest.$ac_objext \
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
     conftest$ac_exeext conftest.$ac_ext
 LIBS=$ac_check_lib_save_LIBS
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_readline_readline" >&5
-$as_echo "$ac_cv_lib_readline_readline" >&6; }
-if test "x$ac_cv_lib_readline_readline" = xyes; then :
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_readline_readline" >&5
+printf "%s\n" "$ac_cv_lib_readline_readline" >&6; }
+if test "x$ac_cv_lib_readline_readline" = xyes
+then :
 
 
-$as_echo "#define READLINE_SUPPORT 1" >>confdefs.h
+printf "%s\n" "#define READLINE_SUPPORT 1" >>confdefs.h
 
 				READLINE=yes
 		LIBS=$lvm_saved_libs
-		{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for rl_line_buffer in -lreadline" >&5
-$as_echo_n "checking for rl_line_buffer in -lreadline... " >&6; }
-if ${ac_cv_lib_readline_rl_line_buffer+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+		{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for rl_line_buffer in -lreadline" >&5
+printf %s "checking for rl_line_buffer in -lreadline... " >&6; }
+if test ${ac_cv_lib_readline_rl_line_buffer+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   ac_check_lib_save_LIBS=$LIBS
 LIBS="-lreadline  $LIBS"
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -13378,40 +14559,39 @@ cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* Override any GCC internal prototype to avoid an error.
    Use char because int might match the return type of a GCC
    builtin and then its argument prototype would still apply.  */
-#ifdef __cplusplus
-extern "C"
-#endif
 char rl_line_buffer ();
 int
-main ()
+main (void)
 {
 return rl_line_buffer ();
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
+if ac_fn_c_try_link "$LINENO"
+then :
   ac_cv_lib_readline_rl_line_buffer=yes
-else
+else $as_nop
   ac_cv_lib_readline_rl_line_buffer=no
 fi
-rm -f core conftest.err conftest.$ac_objext \
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
     conftest$ac_exeext conftest.$ac_ext
 LIBS=$ac_check_lib_save_LIBS
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_readline_rl_line_buffer" >&5
-$as_echo "$ac_cv_lib_readline_rl_line_buffer" >&6; }
-if test "x$ac_cv_lib_readline_rl_line_buffer" = xyes; then :
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_readline_rl_line_buffer" >&5
+printf "%s\n" "$ac_cv_lib_readline_rl_line_buffer" >&6; }
+if test "x$ac_cv_lib_readline_rl_line_buffer" = xyes
+then :
    READLINE_LIBS="-lreadline"
-else
+else $as_nop
 
-			  { $as_echo "$as_me:${as_lineno-$LINENO}: result: linking -lreadline with $READLINE_LIBS needed" >&5
-$as_echo "linking -lreadline with $READLINE_LIBS needed" >&6; }
+			  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: linking -lreadline with $READLINE_LIBS needed" >&5
+printf "%s\n" "linking -lreadline with $READLINE_LIBS needed" >&6; }
 			  READLINE_LIBS="-lreadline $READLINE_LIBS"
 
 fi
 
-else
+else $as_nop
 
 		READLINE_LIBS=
 		if test "$READLINE" = yes; then
@@ -13425,32 +14605,29 @@ package as well (which may be called readline-devel or something similar)." "$LI
 fi
 
 	LIBS="$READLINE_LIBS $lvm_saved_libs"
-	for ac_func in rl_completion_matches
-do :
-  ac_fn_c_check_func "$LINENO" "rl_completion_matches" "ac_cv_func_rl_completion_matches"
-if test "x$ac_cv_func_rl_completion_matches" = xyes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_RL_COMPLETION_MATCHES 1
-_ACEOF
+	ac_fn_c_check_func "$LINENO" "rl_completion_matches" "ac_cv_func_rl_completion_matches"
+if test "x$ac_cv_func_rl_completion_matches" = xyes
+then :
+  printf "%s\n" "#define HAVE_RL_COMPLETION_MATCHES 1" >>confdefs.h
 
 fi
-done
 
 	LIBS=$lvm_saved_libs
 fi
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable internationalisation" >&5
-$as_echo_n "checking whether to enable internationalisation... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to enable internationalisation" >&5
+printf %s "checking whether to enable internationalisation... " >&6; }
 # Check whether --enable-nls was given.
-if test "${enable_nls+set}" = set; then :
+if test ${enable_nls+y}
+then :
   enableval=$enable_nls; INTL=$enableval
-else
+else $as_nop
   INTL=no
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $INTL" >&5
-$as_echo "$INTL" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $INTL" >&5
+printf "%s\n" "$INTL" >&6; }
 
 if test "$INTL" = yes; then
 # FIXME - Move this - can be device-mapper too
@@ -13458,11 +14635,12 @@ if test "$INTL" = yes; then
 	if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}msgfmt", so it can be a program name with args.
 set dummy ${ac_tool_prefix}msgfmt; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_MSGFMT+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_MSGFMT+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $MSGFMT in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_MSGFMT="$MSGFMT" # Let the user override the test with a path.
@@ -13472,11 +14650,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_MSGFMT="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_MSGFMT="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -13488,11 +14670,11 @@ esac
 fi
 MSGFMT=$ac_cv_path_MSGFMT
 if test -n "$MSGFMT"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $MSGFMT" >&5
-$as_echo "$MSGFMT" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $MSGFMT" >&5
+printf "%s\n" "$MSGFMT" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -13501,11 +14683,12 @@ if test -z "$ac_cv_path_MSGFMT"; then
   ac_pt_MSGFMT=$MSGFMT
   # Extract the first word of "msgfmt", so it can be a program name with args.
 set dummy msgfmt; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_ac_pt_MSGFMT+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_ac_pt_MSGFMT+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $ac_pt_MSGFMT in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_ac_pt_MSGFMT="$ac_pt_MSGFMT" # Let the user override the test with a path.
@@ -13515,11 +14698,15 @@ else
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_ac_pt_MSGFMT="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_MSGFMT="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -13531,11 +14718,11 @@ esac
 fi
 ac_pt_MSGFMT=$ac_cv_path_ac_pt_MSGFMT
 if test -n "$ac_pt_MSGFMT"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_MSGFMT" >&5
-$as_echo "$ac_pt_MSGFMT" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_pt_MSGFMT" >&5
+printf "%s\n" "$ac_pt_MSGFMT" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_pt_MSGFMT" = x; then
@@ -13543,8 +14730,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     MSGFMT=$ac_pt_MSGFMT
@@ -13554,69 +14741,69 @@ else
 fi
 
 
-	if test -z "$MSGFMT"; then :
+	if test -z "$MSGFMT"
+then :
   as_fn_error $? "msgfmt not found in path $PATH" "$LINENO" 5
 fi
 
 
 # Check whether --with-localedir was given.
-if test "${with_localedir+set}" = set; then :
+if test ${with_localedir+y}
+then :
   withval=$with_localedir; localedir=$withval
-else
+else $as_nop
   localedir=${localedir-'${datarootdir}/locale'}
 fi
 
 
-cat >>confdefs.h <<_ACEOF
-#define INTL_PACKAGE "$INTL_PACKAGE"
-_ACEOF
+printf "%s\n" "#define INTL_PACKAGE \"$INTL_PACKAGE\"" >>confdefs.h
 
 	# double eval needed ${datarootdir} -> ${prefix}/share -> real path
 
-cat >>confdefs.h <<_ACEOF
-#define LOCALEDIR "$(eval echo $(eval echo $localedir))"
-_ACEOF
+printf "%s\n" "#define LOCALEDIR \"$(eval echo $(eval echo $localedir))\"" >>confdefs.h
 
 fi
 
 ################################################################################
 
 # Check whether --with-confdir was given.
-if test "${with_confdir+set}" = set; then :
+if test ${with_confdir+y}
+then :
   withval=$with_confdir; CONFDIR=$withval
-else
+else $as_nop
   CONFDIR='/etc'
 fi
 
 
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_ETC_DIR "$CONFDIR"
-_ACEOF
+printf "%s\n" "#define DEFAULT_ETC_DIR \"$CONFDIR\"" >>confdefs.h
 
 
 
 # Check whether --with-staticdir was given.
-if test "${with_staticdir+set}" = set; then :
+if test ${with_staticdir+y}
+then :
   withval=$with_staticdir; STATICDIR=$withval
-else
+else $as_nop
   STATICDIR='${exec_prefix}/sbin'
 fi
 
 
 
 # Check whether --with-usrlibdir was given.
-if test "${with_usrlibdir+set}" = set; then :
+if test ${with_usrlibdir+y}
+then :
   withval=$with_usrlibdir; usrlibdir=$withval
-else
+else $as_nop
   usrlibdir='${prefix}/lib'
 fi
 
 
 
 # Check whether --with-usrsbindir was given.
-if test "${with_usrsbindir+set}" = set; then :
+if test ${with_usrsbindir+y}
+then :
   withval=$with_usrsbindir; usrsbindir=$withval
-else
+else $as_nop
   usrsbindir='${prefix}/sbin'
 fi
 
@@ -13624,18 +14811,20 @@ fi
 ################################################################################
 
 # Check whether --with-udev_prefix was given.
-if test "${with_udev_prefix+set}" = set; then :
+if test ${with_udev_prefix+y}
+then :
   withval=$with_udev_prefix; udev_prefix=$withval
-else
+else $as_nop
   udev_prefix='${exec_prefix}'
 fi
 
 
 
 # Check whether --with-udevdir was given.
-if test "${with_udevdir+set}" = set; then :
+if test ${with_udevdir+y}
+then :
   withval=$with_udevdir; udevdir=$withval
-else
+else $as_nop
   udevdir='${udev_prefix}/lib/udev/rules.d'
 fi
 
@@ -13643,9 +14832,10 @@ fi
 ################################################################################
 
 # Check whether --with-systemdsystemunitdir was given.
-if test "${with_systemdsystemunitdir+set}" = set; then :
+if test ${with_systemdsystemunitdir+y}
+then :
   withval=$with_systemdsystemunitdir; systemdsystemunitdir=$withval
-else
+else $as_nop
   pkg_config_init
 	    pkg_systemdsystemunitdir=$("$PKG_CONFIG" --variable=systemdsystemunitdir systemd)
 fi
@@ -13660,140 +14850,218 @@ test -z "$systemdutildir" && systemdutildir='${exec_prefix}/lib/systemd';
 ################################################################################
 
 # Check whether --with-tmpfilesdir was given.
-if test "${with_tmpfilesdir+set}" = set; then :
+if test ${with_tmpfilesdir+y}
+then :
   withval=$with_tmpfilesdir; tmpfilesdir=$withval
-else
+else $as_nop
   tmpfilesdir='${prefix}/lib/tmpfiles.d'
 fi
 
 ################################################################################
 if test "$READLINE" = yes; then
-	for ac_header in readline/readline.h readline/history.h
+	       for ac_header in readline/readline.h readline/history.h
 do :
-  as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
-ac_fn_c_check_header_mongrel "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
-if eval test \"x\$"$as_ac_Header"\" = x"yes"; then :
+  as_ac_Header=`printf "%s\n" "ac_cv_header_$ac_header" | $as_tr_sh`
+ac_fn_c_check_header_compile "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
+if eval test \"x\$"$as_ac_Header"\" = x"yes"
+then :
   cat >>confdefs.h <<_ACEOF
-#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
+#define `printf "%s\n" "HAVE_$ac_header" | $as_tr_cpp` 1
 _ACEOF
 
-else
+else $as_nop
   hard_bailout
 fi
 
 done
-
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable readline" >&5
-$as_echo_n "checking whether to enable readline... " >&6; }
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $READLINE" >&5
-$as_echo "$READLINE" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to enable readline" >&5
+printf %s "checking whether to enable readline... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $READLINE" >&5
+printf "%s\n" "$READLINE" >&6; }
 
 if test "$EDITLINE" = yes; then
-	for ac_header in editline/readline.h
+	       for ac_header in editline/readline.h
 do :
-  ac_fn_c_check_header_mongrel "$LINENO" "editline/readline.h" "ac_cv_header_editline_readline_h" "$ac_includes_default"
-if test "x$ac_cv_header_editline_readline_h" = xyes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_EDITLINE_READLINE_H 1
-_ACEOF
+  ac_fn_c_check_header_compile "$LINENO" "editline/readline.h" "ac_cv_header_editline_readline_h" "$ac_includes_default"
+if test "x$ac_cv_header_editline_readline_h" = xyes
+then :
+  printf "%s\n" "#define HAVE_EDITLINE_READLINE_H 1" >>confdefs.h
 
-else
+else $as_nop
   hard_bailout
 fi
 
 done
-
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable editline" >&5
-$as_echo_n "checking whether to enable editline... " >&6; }
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $EDITLINE" >&5
-$as_echo "$EDITLINE" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to enable editline" >&5
+printf %s "checking whether to enable editline... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $EDITLINE" >&5
+printf "%s\n" "$EDITLINE" >&6; }
 
 if test "$BUILD_CMIRRORD" = yes; then
-	for ac_func in atexit
+
+  for ac_func in atexit
 do :
   ac_fn_c_check_func "$LINENO" "atexit" "ac_cv_func_atexit"
-if test "x$ac_cv_func_atexit" = xyes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_ATEXIT 1
-_ACEOF
+if test "x$ac_cv_func_atexit" = xyes
+then :
+  printf "%s\n" "#define HAVE_ATEXIT 1" >>confdefs.h
 
-else
+else $as_nop
   hard_bailout
 fi
-done
 
+done
 fi
 
 if test "$BUILD_LVMLOCKD" = yes; then
-	if test "$HAVE_REALTIME" != yes; then :
+	if test "$HAVE_REALTIME" != yes
+then :
   as_fn_error $? "Realtime clock support is mandatory for lvmlockd." "$LINENO" 5
 fi
-	for ac_func in strtoull
+
+  for ac_func in strtoull
 do :
   ac_fn_c_check_func "$LINENO" "strtoull" "ac_cv_func_strtoull"
-if test "x$ac_cv_func_strtoull" = xyes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_STRTOULL 1
-_ACEOF
+if test "x$ac_cv_func_strtoull" = xyes
+then :
+  printf "%s\n" "#define HAVE_STRTOULL 1" >>confdefs.h
 
-else
+else $as_nop
   hard_bailout
 fi
-done
 
+done
 fi
 
 if test "$BUILD_LVMPOLLD" = yes; then
-	for ac_func in strpbrk
+
+  for ac_func in strpbrk
 do :
   ac_fn_c_check_func "$LINENO" "strpbrk" "ac_cv_func_strpbrk"
-if test "x$ac_cv_func_strpbrk" = xyes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_STRPBRK 1
-_ACEOF
+if test "x$ac_cv_func_strpbrk" = xyes
+then :
+  printf "%s\n" "#define HAVE_STRPBRK 1" >>confdefs.h
 
-else
+else $as_nop
   hard_bailout
 fi
+
 done
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $CC options needed to detect all undeclared functions" >&5
+printf %s "checking for $CC options needed to detect all undeclared functions... " >&6; }
+if test ${ac_cv_c_undeclared_builtin_options+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  ac_save_CFLAGS=$CFLAGS
+   ac_cv_c_undeclared_builtin_options='cannot detect'
+   for ac_arg in '' -fno-builtin; do
+     CFLAGS="$ac_save_CFLAGS $ac_arg"
+     # This test program should *not* compile successfully.
+     cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+
+int
+main (void)
+{
+(void) strchr;
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"
+then :
+
+else $as_nop
+  # This test program should compile successfully.
+        # No library function is consistently available on
+        # freestanding implementations, so test against a dummy
+        # declaration.  Include always-available headers on the
+        # off chance that they somehow elicit warnings.
+        cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#include <float.h>
+#include <limits.h>
+#include <stdarg.h>
+#include <stddef.h>
+extern void ac_decl (int, char *);
+
+int
+main (void)
+{
+(void) ac_decl (0, (char *) 0);
+  (void) ac_decl;
+
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"
+then :
+  if test x"$ac_arg" = x
+then :
+  ac_cv_c_undeclared_builtin_options='none needed'
+else $as_nop
+  ac_cv_c_undeclared_builtin_options=$ac_arg
+fi
+          break
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+    done
+    CFLAGS=$ac_save_CFLAGS
+
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_c_undeclared_builtin_options" >&5
+printf "%s\n" "$ac_cv_c_undeclared_builtin_options" >&6; }
+  case $ac_cv_c_undeclared_builtin_options in #(
+  'cannot detect') :
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
+as_fn_error $? "cannot make $CC report undeclared builtins
+See \`config.log' for more details" "$LINENO" 5; } ;; #(
+  'none needed') :
+    ac_c_undeclared_builtin_options='' ;; #(
+  *) :
+    ac_c_undeclared_builtin_options=$ac_cv_c_undeclared_builtin_options ;;
+esac
 
-	ac_fn_c_check_decl "$LINENO" "strerror_r" "ac_cv_have_decl_strerror_r" "$ac_includes_default"
-if test "x$ac_cv_have_decl_strerror_r" = xyes; then :
+ac_fn_check_decl "$LINENO" "strerror_r" "ac_cv_have_decl_strerror_r" "$ac_includes_default" "$ac_c_undeclared_builtin_options" "CFLAGS"
+if test "x$ac_cv_have_decl_strerror_r" = xyes
+then :
   ac_have_decl=1
-else
+else $as_nop
   ac_have_decl=0
 fi
+printf "%s\n" "#define HAVE_DECL_STRERROR_R $ac_have_decl" >>confdefs.h
 
-cat >>confdefs.h <<_ACEOF
-#define HAVE_DECL_STRERROR_R $ac_have_decl
-_ACEOF
 
-for ac_func in strerror_r
-do :
-  ac_fn_c_check_func "$LINENO" "strerror_r" "ac_cv_func_strerror_r"
-if test "x$ac_cv_func_strerror_r" = xyes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_STRERROR_R 1
-_ACEOF
+if test $ac_cv_have_decl_strerror_r = yes; then
+  # For backward compatibility's sake, define HAVE_STRERROR_R.
+  # (We used to run AC_CHECK_FUNCS_ONCE for strerror_r, as well
+  # as AC_CHECK_DECLS_ONCE.)
+
+printf "%s\n" "#define HAVE_STRERROR_R 1" >>confdefs.h
 
 fi
-done
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether strerror_r returns char *" >&5
-$as_echo_n "checking whether strerror_r returns char *... " >&6; }
-if ${ac_cv_func_strerror_r_char_p+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether strerror_r returns char *" >&5
+printf %s "checking whether strerror_r returns char *... " >&6; }
+if test ${ac_cv_func_strerror_r_char_p+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
 
     ac_cv_func_strerror_r_char_p=no
     if test $ac_cv_have_decl_strerror_r = yes; then
       cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-$ac_includes_default
+#include <string.h>
 int
-main ()
+main (void)
 {
 
 	  char buf[100];
@@ -13805,149 +15073,113 @@ main ()
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
-  ac_cv_func_strerror_r_char_p=yes
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
-    else
-      # strerror_r is not declared.  Choose between
-      # systems that have relatively inaccessible declarations for the
-      # function.  BeOS and DEC UNIX 4.0 fall in this category, but the
-      # former has a strerror_r that returns char*, while the latter
-      # has a strerror_r that returns `int'.
-      # This test should segfault on the DEC system.
-      if test "$cross_compiling" = yes; then :
-  :
-else
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-$ac_includes_default
-	extern char *strerror_r ();
-int
-main ()
-{
-char buf[100];
-	  char x = *strerror_r (0, buf, sizeof buf);
-	  return ! isalpha (x);
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_run "$LINENO"; then :
+if ac_fn_c_try_compile "$LINENO"
+then :
   ac_cv_func_strerror_r_char_p=yes
 fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
-fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 
     fi
 
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_strerror_r_char_p" >&5
-$as_echo "$ac_cv_func_strerror_r_char_p" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_strerror_r_char_p" >&5
+printf "%s\n" "$ac_cv_func_strerror_r_char_p" >&6; }
 if test $ac_cv_func_strerror_r_char_p = yes; then
 
-$as_echo "#define STRERROR_R_CHAR_P 1" >>confdefs.h
+printf "%s\n" "#define STRERROR_R_CHAR_P 1" >>confdefs.h
 
 fi
 
 fi
 
 if test "$BUILD_DMEVENTD" = yes; then
-	for ac_header in arpa/inet.h
+	       for ac_header in arpa/inet.h
 do :
-  ac_fn_c_check_header_mongrel "$LINENO" "arpa/inet.h" "ac_cv_header_arpa_inet_h" "$ac_includes_default"
-if test "x$ac_cv_header_arpa_inet_h" = xyes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_ARPA_INET_H 1
-_ACEOF
+  ac_fn_c_check_header_compile "$LINENO" "arpa/inet.h" "ac_cv_header_arpa_inet_h" "$ac_includes_default"
+if test "x$ac_cv_header_arpa_inet_h" = xyes
+then :
+  printf "%s\n" "#define HAVE_ARPA_INET_H 1" >>confdefs.h
 
-else
+else $as_nop
   hard_bailout
 fi
 
 done
-
 fi
 
 if test "$HAVE_LIBDL" = yes; then
-	for ac_header in dlfcn.h
+	       for ac_header in dlfcn.h
 do :
-  ac_fn_c_check_header_mongrel "$LINENO" "dlfcn.h" "ac_cv_header_dlfcn_h" "$ac_includes_default"
-if test "x$ac_cv_header_dlfcn_h" = xyes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_DLFCN_H 1
-_ACEOF
+  ac_fn_c_check_header_compile "$LINENO" "dlfcn.h" "ac_cv_header_dlfcn_h" "$ac_includes_default"
+if test "x$ac_cv_header_dlfcn_h" = xyes
+then :
+  printf "%s\n" "#define HAVE_DLFCN_H 1" >>confdefs.h
 
-else
+else $as_nop
   hard_bailout
 fi
 
 done
-
 fi
 
 if test "$INTL" = yes; then
-	for ac_header in libintl.h
+	       for ac_header in libintl.h
 do :
-  ac_fn_c_check_header_mongrel "$LINENO" "libintl.h" "ac_cv_header_libintl_h" "$ac_includes_default"
-if test "x$ac_cv_header_libintl_h" = xyes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_LIBINTL_H 1
-_ACEOF
+  ac_fn_c_check_header_compile "$LINENO" "libintl.h" "ac_cv_header_libintl_h" "$ac_includes_default"
+if test "x$ac_cv_header_libintl_h" = xyes
+then :
+  printf "%s\n" "#define HAVE_LIBINTL_H 1" >>confdefs.h
 
-else
+else $as_nop
   hard_bailout
 fi
 
 done
-
 fi
 
 if test "$UDEV_SYNC" = yes; then
-	for ac_header in sys/ipc.h sys/sem.h
+	       for ac_header in sys/ipc.h sys/sem.h
 do :
-  as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
-ac_fn_c_check_header_mongrel "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
-if eval test \"x\$"$as_ac_Header"\" = x"yes"; then :
+  as_ac_Header=`printf "%s\n" "ac_cv_header_$ac_header" | $as_tr_sh`
+ac_fn_c_check_header_compile "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
+if eval test \"x\$"$as_ac_Header"\" = x"yes"
+then :
   cat >>confdefs.h <<_ACEOF
-#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
+#define `printf "%s\n" "HAVE_$ac_header" | $as_tr_cpp` 1
 _ACEOF
 
-else
+else $as_nop
   hard_bailout
 fi
 
 done
-
 fi
 
 if test "$BUILD_DMFILEMAPD" = yes; then
-	for ac_header in sys/inotify.h
+	       for ac_header in sys/inotify.h
 do :
-  ac_fn_c_check_header_mongrel "$LINENO" "sys/inotify.h" "ac_cv_header_sys_inotify_h" "$ac_includes_default"
-if test "x$ac_cv_header_sys_inotify_h" = xyes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_SYS_INOTIFY_H 1
-_ACEOF
+  ac_fn_c_check_header_compile "$LINENO" "sys/inotify.h" "ac_cv_header_sys_inotify_h" "$ac_includes_default"
+if test "x$ac_cv_header_sys_inotify_h" = xyes
+then :
+  printf "%s\n" "#define HAVE_SYS_INOTIFY_H 1" >>confdefs.h
 
-else
+else $as_nop
   hard_bailout
 fi
 
 done
-
 fi
 
 ################################################################################
 if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}modprobe", so it can be a program name with args.
 set dummy ${ac_tool_prefix}modprobe; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_MODPROBE_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_MODPROBE_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $MODPROBE_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_MODPROBE_CMD="$MODPROBE_CMD" # Let the user override the test with a path.
@@ -13957,11 +15189,15 @@ else
 for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_MODPROBE_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_MODPROBE_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -13973,11 +15209,11 @@ esac
 fi
 MODPROBE_CMD=$ac_cv_path_MODPROBE_CMD
 if test -n "$MODPROBE_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $MODPROBE_CMD" >&5
-$as_echo "$MODPROBE_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $MODPROBE_CMD" >&5
+printf "%s\n" "$MODPROBE_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
 
@@ -13986,11 +15222,12 @@ if test -z "$ac_cv_path_MODPROBE_CMD"; then
   ac_pt_MODPROBE_CMD=$MODPROBE_CMD
   # Extract the first word of "modprobe", so it can be a program name with args.
 set dummy modprobe; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_ac_pt_MODPROBE_CMD+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_ac_pt_MODPROBE_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
   case $ac_pt_MODPROBE_CMD in
   [\\/]* | ?:[\\/]*)
   ac_cv_path_ac_pt_MODPROBE_CMD="$ac_pt_MODPROBE_CMD" # Let the user override the test with a path.
@@ -14000,11 +15237,15 @@ else
 for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_ac_pt_MODPROBE_CMD="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_MODPROBE_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
     break 2
   fi
 done
@@ -14016,11 +15257,11 @@ esac
 fi
 ac_pt_MODPROBE_CMD=$ac_cv_path_ac_pt_MODPROBE_CMD
 if test -n "$ac_pt_MODPROBE_CMD"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_MODPROBE_CMD" >&5
-$as_echo "$ac_pt_MODPROBE_CMD" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_pt_MODPROBE_CMD" >&5
+printf "%s\n" "$ac_pt_MODPROBE_CMD" >&6; }
 else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
 fi
 
   if test "x$ac_pt_MODPROBE_CMD" = x; then
@@ -14028,8 +15269,8 @@ fi
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
-{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
-$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
     MODPROBE_CMD=$ac_pt_MODPROBE_CMD
@@ -14041,9 +15282,7 @@ fi
 
 if test -n "$MODPROBE_CMD"; then
 
-cat >>confdefs.h <<_ACEOF
-#define MODPROBE_CMD "$MODPROBE_CMD"
-_ACEOF
+printf "%s\n" "#define MODPROBE_CMD \"$MODPROBE_CMD\"" >>confdefs.h
 
 fi
 
@@ -14052,136 +15291,121 @@ SYSCONFDIR="$(eval echo $(eval echo $sysconfdir))"
 SBINDIR="$(eval echo $(eval echo $sbindir))"
 LVM_PATH="$SBINDIR/lvm"
 
-cat >>confdefs.h <<_ACEOF
-#define LVM_PATH "$LVM_PATH"
-_ACEOF
+printf "%s\n" "#define LVM_PATH \"$LVM_PATH\"" >>confdefs.h
 
 
 LVMCONFIG_PATH="$SBINDIR/lvmconfig"
 
-cat >>confdefs.h <<_ACEOF
-#define LVMCONFIG_PATH "$LVMCONFIG_PATH"
-_ACEOF
+printf "%s\n" "#define LVMCONFIG_PATH \"$LVMCONFIG_PATH\"" >>confdefs.h
 
 
 USRSBINDIR="$(eval echo $(eval echo $usrsbindir))"
 
 FSADM_PATH="$SBINDIR/fsadm"
 
-cat >>confdefs.h <<_ACEOF
-#define FSADM_PATH "$FSADM_PATH"
-_ACEOF
+printf "%s\n" "#define FSADM_PATH \"$FSADM_PATH\"" >>confdefs.h
 
 
 LVMIMPORTVDO_PATH="$SBINDIR/lvm_import_vdo"
 
-cat >>confdefs.h <<_ACEOF
-#define LVMIMPORTVDO_PATH "$LVMIMPORTVDO_PATH"
-_ACEOF
+printf "%s\n" "#define LVMIMPORTVDO_PATH \"$LVMIMPORTVDO_PATH\"" >>confdefs.h
 
 
 ################################################################################
 if test "$BUILD_DMEVENTD" = yes; then
 
 # Check whether --with-dmeventd-pidfile was given.
-if test "${with_dmeventd_pidfile+set}" = set; then :
+if test ${with_dmeventd_pidfile+y}
+then :
   withval=$with_dmeventd_pidfile; DMEVENTD_PIDFILE=$withval
-else
+else $as_nop
   DMEVENTD_PIDFILE="$DEFAULT_PID_DIR/dmeventd.pid"
 fi
 
 
-cat >>confdefs.h <<_ACEOF
-#define DMEVENTD_PIDFILE "$DMEVENTD_PIDFILE"
-_ACEOF
+printf "%s\n" "#define DMEVENTD_PIDFILE \"$DMEVENTD_PIDFILE\"" >>confdefs.h
 
 fi
 
 if test "$BUILD_DMEVENTD" = yes; then
 
 # Check whether --with-dmeventd-path was given.
-if test "${with_dmeventd_path+set}" = set; then :
+if test ${with_dmeventd_path+y}
+then :
   withval=$with_dmeventd_path; DMEVENTD_PATH=$withval
-else
+else $as_nop
   DMEVENTD_PATH="$SBINDIR/dmeventd"
 fi
 
 
-cat >>confdefs.h <<_ACEOF
-#define DMEVENTD_PATH "$DMEVENTD_PATH"
-_ACEOF
+printf "%s\n" "#define DMEVENTD_PATH \"$DMEVENTD_PATH\"" >>confdefs.h
 
 fi
 
 ################################################################################
 
 # Check whether --with-default-system-dir was given.
-if test "${with_default_system_dir+set}" = set; then :
+if test ${with_default_system_dir+y}
+then :
   withval=$with_default_system_dir; DEFAULT_SYS_DIR=$withval
-else
+else $as_nop
   DEFAULT_SYS_DIR="/etc/lvm"
 fi
 
 
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_SYS_DIR "$DEFAULT_SYS_DIR"
-_ACEOF
+printf "%s\n" "#define DEFAULT_SYS_DIR \"$DEFAULT_SYS_DIR\"" >>confdefs.h
 
 
 
 # Check whether --with-default-profile-subdir was given.
-if test "${with_default_profile_subdir+set}" = set; then :
+if test ${with_default_profile_subdir+y}
+then :
   withval=$with_default_profile_subdir; DEFAULT_PROFILE_SUBDIR=$withval
-else
+else $as_nop
   DEFAULT_PROFILE_SUBDIR=profile
 fi
 
 
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_PROFILE_SUBDIR "$DEFAULT_PROFILE_SUBDIR"
-_ACEOF
+printf "%s\n" "#define DEFAULT_PROFILE_SUBDIR \"$DEFAULT_PROFILE_SUBDIR\"" >>confdefs.h
 
 
 
 # Check whether --with-default-archive-subdir was given.
-if test "${with_default_archive_subdir+set}" = set; then :
+if test ${with_default_archive_subdir+y}
+then :
   withval=$with_default_archive_subdir; DEFAULT_ARCHIVE_SUBDIR=$withval
-else
+else $as_nop
   DEFAULT_ARCHIVE_SUBDIR=archive
 fi
 
 
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_ARCHIVE_SUBDIR "$DEFAULT_ARCHIVE_SUBDIR"
-_ACEOF
+printf "%s\n" "#define DEFAULT_ARCHIVE_SUBDIR \"$DEFAULT_ARCHIVE_SUBDIR\"" >>confdefs.h
 
 
 
 # Check whether --with-default-backup-subdir was given.
-if test "${with_default_backup_subdir+set}" = set; then :
+if test ${with_default_backup_subdir+y}
+then :
   withval=$with_default_backup_subdir; DEFAULT_BACKUP_SUBDIR=$withval
-else
+else $as_nop
   DEFAULT_BACKUP_SUBDIR=backup
 fi
 
 
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_BACKUP_SUBDIR "$DEFAULT_BACKUP_SUBDIR"
-_ACEOF
+printf "%s\n" "#define DEFAULT_BACKUP_SUBDIR \"$DEFAULT_BACKUP_SUBDIR\"" >>confdefs.h
 
 
 
 # Check whether --with-default-cache-subdir was given.
-if test "${with_default_cache_subdir+set}" = set; then :
+if test ${with_default_cache_subdir+y}
+then :
   withval=$with_default_cache_subdir; DEFAULT_CACHE_SUBDIR=$withval
-else
+else $as_nop
   DEFAULT_CACHE_SUBDIR=cache
 fi
 
 
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_CACHE_SUBDIR "$DEFAULT_CACHE_SUBDIR"
-_ACEOF
+printf "%s\n" "#define DEFAULT_CACHE_SUBDIR \"$DEFAULT_CACHE_SUBDIR\"" >>confdefs.h
 
 
 # Select default system locking dir, prefer /run/lock over /var/lock
@@ -14191,43 +15415,41 @@ test -d "$DEFAULT_SYS_LOCK_DIR" || DEFAULT_SYS_LOCK_DIR="/var/lock"
 # Support configurable locking subdir for lvm
 
 # Check whether --with-default-locking-dir was given.
-if test "${with_default_locking_dir+set}" = set; then :
+if test ${with_default_locking_dir+y}
+then :
   withval=$with_default_locking_dir; DEFAULT_LOCK_DIR=$withval
-else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for default lock directory" >&5
-$as_echo_n "checking for default lock directory... " >&6; }
+else $as_nop
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for default lock directory" >&5
+printf %s "checking for default lock directory... " >&6; }
 	     DEFAULT_LOCK_DIR="$DEFAULT_SYS_LOCK_DIR/lvm"
-	     { $as_echo "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_LOCK_DIR" >&5
-$as_echo "$DEFAULT_LOCK_DIR" >&6; }
+	     { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_LOCK_DIR" >&5
+printf "%s\n" "$DEFAULT_LOCK_DIR" >&6; }
 fi
 
 
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_LOCK_DIR "$DEFAULT_LOCK_DIR"
-_ACEOF
+printf "%s\n" "#define DEFAULT_LOCK_DIR \"$DEFAULT_LOCK_DIR\"" >>confdefs.h
 
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for kernel interface choice" >&5
-$as_echo_n "checking for kernel interface choice... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for kernel interface choice" >&5
+printf %s "checking for kernel interface choice... " >&6; }
 
 # Check whether --with-interface was given.
-if test "${with_interface+set}" = set; then :
+if test ${with_interface+y}
+then :
   withval=$with_interface; interface=$withval
-else
+else $as_nop
   interface=ioctl
 fi
 
 test "$interface" != ioctl && as_fn_error $? "--with-interface=ioctl required. fs no longer supported." "$LINENO" 5
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $interface" >&5
-$as_echo "$interface" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $interface" >&5
+printf "%s\n" "$interface" >&6; }
 
 ################################################################################
 read DM_LIB_VERSION < "$srcdir"/VERSION_DM 2>/dev/null || DM_LIB_VERSION=Unknown
 
-cat >>confdefs.h <<_ACEOF
-#define DM_LIB_VERSION "$DM_LIB_VERSION"
-_ACEOF
+printf "%s\n" "#define DM_LIB_VERSION \"$DM_LIB_VERSION\"" >>confdefs.h
 
 
 DM_LIB_PATCHLEVEL=`cat "$srcdir"/VERSION_DM | $AWK -F '[-. ]' '{printf "%s.%s.%s",$1,$2,$3}'`
@@ -14245,9 +15467,7 @@ LVM_PATCHLEVEL=`echo "$VER" | $AWK -F '[(.]' '{print $3}'`
 LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
-cat >>confdefs.h <<_ACEOF
-#define LVM_CONFIGURE_LINE "$CONFIGURE_LINE"
-_ACEOF
+printf "%s\n" "#define LVM_CONFIGURE_LINE \"$CONFIGURE_LINE\"" >>confdefs.h
 
 
 
@@ -14443,8 +15663,8 @@ _ACEOF
     case $ac_val in #(
     *${as_nl}*)
       case $ac_var in #(
-      *_cv_*) { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: cache variable $ac_var contains a newline" >&5
-$as_echo "$as_me: WARNING: cache variable $ac_var contains a newline" >&2;} ;;
+      *_cv_*) { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: cache variable $ac_var contains a newline" >&5
+printf "%s\n" "$as_me: WARNING: cache variable $ac_var contains a newline" >&2;} ;;
       esac
       case $ac_var in #(
       _ | IFS | as_nl) ;; #(
@@ -14474,15 +15694,15 @@ $as_echo "$as_me: WARNING: cache variable $ac_var contains a newline" >&2;} ;;
      /^ac_cv_env_/b end
      t clear
      :clear
-     s/^\([^=]*\)=\(.*[{}].*\)$/test "${\1+set}" = set || &/
+     s/^\([^=]*\)=\(.*[{}].*\)$/test ${\1+y} || &/
      t end
      s/^\([^=]*\)=\(.*\)$/\1=${\1=\2}/
      :end' >>confcache
 if diff "$cache_file" confcache >/dev/null 2>&1; then :; else
   if test -w "$cache_file"; then
     if test "x$cache_file" != "x/dev/null"; then
-      { $as_echo "$as_me:${as_lineno-$LINENO}: updating cache $cache_file" >&5
-$as_echo "$as_me: updating cache $cache_file" >&6;}
+      { printf "%s\n" "$as_me:${as_lineno-$LINENO}: updating cache $cache_file" >&5
+printf "%s\n" "$as_me: updating cache $cache_file" >&6;}
       if test ! -f "$cache_file" || test -h "$cache_file"; then
 	cat confcache >"$cache_file"
       else
@@ -14496,8 +15716,8 @@ $as_echo "$as_me: updating cache $cache_file" >&6;}
       fi
     fi
   else
-    { $as_echo "$as_me:${as_lineno-$LINENO}: not updating unwritable cache $cache_file" >&5
-$as_echo "$as_me: not updating unwritable cache $cache_file" >&6;}
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: not updating unwritable cache $cache_file" >&5
+printf "%s\n" "$as_me: not updating unwritable cache $cache_file" >&6;}
   fi
 fi
 rm -f confcache
@@ -14514,7 +15734,7 @@ U=
 for ac_i in : $LIBOBJS; do test "x$ac_i" = x: && continue
   # 1. Remove the extension, and $U if already installed.
   ac_script='s/\$U\././;s/\.o$//;s/\.obj$//'
-  ac_i=`$as_echo "$ac_i" | sed "$ac_script"`
+  ac_i=`printf "%s\n" "$ac_i" | sed "$ac_script"`
   # 2. Prepend LIBOBJDIR.  When used with automake>=1.10 LIBOBJDIR
   #    will be set to the directory where LIBOBJS objects are built.
   as_fn_append ac_libobjs " \${LIBOBJDIR}$ac_i\$U.$ac_objext"
@@ -14530,8 +15750,8 @@ LTLIBOBJS=$ac_ltlibobjs
 ac_write_fail=0
 ac_clean_files_save=$ac_clean_files
 ac_clean_files="$ac_clean_files $CONFIG_STATUS"
-{ $as_echo "$as_me:${as_lineno-$LINENO}: creating $CONFIG_STATUS" >&5
-$as_echo "$as_me: creating $CONFIG_STATUS" >&6;}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: creating $CONFIG_STATUS" >&5
+printf "%s\n" "$as_me: creating $CONFIG_STATUS" >&6;}
 as_write_fail=0
 cat >$CONFIG_STATUS <<_ASEOF || as_write_fail=1
 #! $SHELL
@@ -14554,14 +15774,16 @@ cat >>$CONFIG_STATUS <<\_ASEOF || as_write_fail=1
 
 # Be more Bourne compatible
 DUALCASE=1; export DUALCASE # for MKS sh
-if test -n "${ZSH_VERSION+set}" && (emulate sh) >/dev/null 2>&1; then :
+as_nop=:
+if test ${ZSH_VERSION+y} && (emulate sh) >/dev/null 2>&1
+then :
   emulate sh
   NULLCMD=:
   # Pre-4.2 versions of Zsh do word splitting on ${1+"$@"}, which
   # is contrary to our usage.  Disable this feature.
   alias -g '${1+"$@"}'='"$@"'
   setopt NO_GLOB_SUBST
-else
+else $as_nop
   case `(set -o) 2>/dev/null` in #(
   *posix*) :
     set -o posix ;; #(
@@ -14571,46 +15793,46 @@ esac
 fi
 
 
+
+# Reset variables that may have inherited troublesome values from
+# the environment.
+
+# IFS needs to be set, to space, tab, and newline, in precisely that order.
+# (If _AS_PATH_WALK were called with IFS unset, it would have the
+# side effect of setting IFS to empty, thus disabling word splitting.)
+# Quoting is to prevent editors from complaining about space-tab.
 as_nl='
 '
 export as_nl
-# Printing a long string crashes Solaris 7 /usr/bin/printf.
-as_echo='\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\'
-as_echo=$as_echo$as_echo$as_echo$as_echo$as_echo
-as_echo=$as_echo$as_echo$as_echo$as_echo$as_echo$as_echo
-# Prefer a ksh shell builtin over an external printf program on Solaris,
-# but without wasting forks for bash or zsh.
-if test -z "$BASH_VERSION$ZSH_VERSION" \
-    && (test "X`print -r -- $as_echo`" = "X$as_echo") 2>/dev/null; then
-  as_echo='print -r --'
-  as_echo_n='print -rn --'
-elif (test "X`printf %s $as_echo`" = "X$as_echo") 2>/dev/null; then
-  as_echo='printf %s\n'
-  as_echo_n='printf %s'
-else
-  if test "X`(/usr/ucb/echo -n -n $as_echo) 2>/dev/null`" = "X-n $as_echo"; then
-    as_echo_body='eval /usr/ucb/echo -n "$1$as_nl"'
-    as_echo_n='/usr/ucb/echo -n'
-  else
-    as_echo_body='eval expr "X$1" : "X\\(.*\\)"'
-    as_echo_n_body='eval
-      arg=$1;
-      case $arg in #(
-      *"$as_nl"*)
-	expr "X$arg" : "X\\(.*\\)$as_nl";
-	arg=`expr "X$arg" : ".*$as_nl\\(.*\\)"`;;
-      esac;
-      expr "X$arg" : "X\\(.*\\)" | tr -d "$as_nl"
-    '
-    export as_echo_n_body
-    as_echo_n='sh -c $as_echo_n_body as_echo'
-  fi
-  export as_echo_body
-  as_echo='sh -c $as_echo_body as_echo'
-fi
+IFS=" ""	$as_nl"
+
+PS1='$ '
+PS2='> '
+PS4='+ '
+
+# Ensure predictable behavior from utilities with locale-dependent output.
+LC_ALL=C
+export LC_ALL
+LANGUAGE=C
+export LANGUAGE
+
+# We cannot yet rely on "unset" to work, but we need these variables
+# to be unset--not just set to an empty or harmless value--now, to
+# avoid bugs in old shells (e.g. pre-3.0 UWIN ksh).  This construct
+# also avoids known problems related to "unset" and subshell syntax
+# in other old shells (e.g. bash 2.01 and pdksh 5.2.14).
+for as_var in BASH_ENV ENV MAIL MAILPATH CDPATH
+do eval test \${$as_var+y} \
+  && ( (unset $as_var) || exit 1) >/dev/null 2>&1 && unset $as_var || :
+done
+
+# Ensure that fds 0, 1, and 2 are open.
+if (exec 3>&0) 2>/dev/null; then :; else exec 0</dev/null; fi
+if (exec 3>&1) 2>/dev/null; then :; else exec 1>/dev/null; fi
+if (exec 3>&2)            ; then :; else exec 2>/dev/null; fi
 
 # The user is always right.
-if test "${PATH_SEPARATOR+set}" != set; then
+if ${PATH_SEPARATOR+false} :; then
   PATH_SEPARATOR=:
   (PATH='/bin;/bin'; FPATH=$PATH; sh -c :) >/dev/null 2>&1 && {
     (PATH='/bin:/bin'; FPATH=$PATH; sh -c :) >/dev/null 2>&1 ||
@@ -14619,13 +15841,6 @@ if test "${PATH_SEPARATOR+set}" != set; then
 fi
 
 
-# IFS
-# We need space, tab and new line, in precisely that order.  Quoting is
-# there to prevent editors from complaining about space-tab.
-# (If _AS_PATH_WALK were called with IFS unset, it would disable word
-# splitting by setting IFS to empty value.)
-IFS=" ""	$as_nl"
-
 # Find who we are.  Look in the path if we contain no directory separator.
 as_myself=
 case $0 in #((
@@ -14634,8 +15849,12 @@ case $0 in #((
 for as_dir in $PATH
 do
   IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
-    test -r "$as_dir/$0" && as_myself=$as_dir/$0 && break
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
+    test -r "$as_dir$0" && as_myself=$as_dir$0 && break
   done
 IFS=$as_save_IFS
 
@@ -14647,30 +15866,10 @@ if test "x$as_myself" = x; then
   as_myself=$0
 fi
 if test ! -f "$as_myself"; then
-  $as_echo "$as_myself: error: cannot find myself; rerun with an absolute file name" >&2
+  printf "%s\n" "$as_myself: error: cannot find myself; rerun with an absolute file name" >&2
   exit 1
 fi
 
-# Unset variables that we do not need and which cause bugs (e.g. in
-# pre-3.0 UWIN ksh).  But do not cause bugs in bash 2.01; the "|| exit 1"
-# suppresses any "Segmentation fault" message there.  '((' could
-# trigger a bug in pdksh 5.2.14.
-for as_var in BASH_ENV ENV MAIL MAILPATH
-do eval test x\${$as_var+set} = xset \
-  && ( (unset $as_var) || exit 1) >/dev/null 2>&1 && unset $as_var || :
-done
-PS1='$ '
-PS2='> '
-PS4='+ '
-
-# NLS nuisances.
-LC_ALL=C
-export LC_ALL
-LANGUAGE=C
-export LANGUAGE
-
-# CDPATH.
-(unset CDPATH) >/dev/null 2>&1 && unset CDPATH
 
 
 # as_fn_error STATUS ERROR [LINENO LOG_FD]
@@ -14683,13 +15882,14 @@ as_fn_error ()
   as_status=$1; test $as_status -eq 0 && as_status=1
   if test "$4"; then
     as_lineno=${as_lineno-"$3"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
-    $as_echo "$as_me:${as_lineno-$LINENO}: error: $2" >&$4
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: $2" >&$4
   fi
-  $as_echo "$as_me: error: $2" >&2
+  printf "%s\n" "$as_me: error: $2" >&2
   as_fn_exit $as_status
 } # as_fn_error
 
 
+
 # as_fn_set_status STATUS
 # -----------------------
 # Set $? to STATUS, without forking.
@@ -14716,18 +15916,20 @@ as_fn_unset ()
   { eval $1=; unset $1;}
 }
 as_unset=as_fn_unset
+
 # as_fn_append VAR VALUE
 # ----------------------
 # Append the text in VALUE to the end of the definition contained in VAR. Take
 # advantage of any shell optimizations that allow amortized linear growth over
 # repeated appends, instead of the typical quadratic growth present in naive
 # implementations.
-if (eval "as_var=1; as_var+=2; test x\$as_var = x12") 2>/dev/null; then :
+if (eval "as_var=1; as_var+=2; test x\$as_var = x12") 2>/dev/null
+then :
   eval 'as_fn_append ()
   {
     eval $1+=\$2
   }'
-else
+else $as_nop
   as_fn_append ()
   {
     eval $1=\$$1\$2
@@ -14739,12 +15941,13 @@ fi # as_fn_append
 # Perform arithmetic evaluation on the ARGs, and store the result in the
 # global $as_val. Take advantage of shells that can avoid forks. The arguments
 # must be portable across $(()) and expr.
-if (eval "test \$(( 1 + 1 )) = 2") 2>/dev/null; then :
+if (eval "test \$(( 1 + 1 )) = 2") 2>/dev/null
+then :
   eval 'as_fn_arith ()
   {
     as_val=$(( $* ))
   }'
-else
+else $as_nop
   as_fn_arith ()
   {
     as_val=`expr "$@" || test $? -eq 1`
@@ -14775,7 +15978,7 @@ as_me=`$as_basename -- "$0" ||
 $as_expr X/"$0" : '.*/\([^/][^/]*\)/*$' \| \
 	 X"$0" : 'X\(//\)$' \| \
 	 X"$0" : 'X\(/\)' \| . 2>/dev/null ||
-$as_echo X/"$0" |
+printf "%s\n" X/"$0" |
     sed '/^.*\/\([^/][^/]*\)\/*$/{
 	    s//\1/
 	    q
@@ -14797,6 +16000,10 @@ as_cr_Letters=$as_cr_letters$as_cr_LETTERS
 as_cr_digits='0123456789'
 as_cr_alnum=$as_cr_Letters$as_cr_digits
 
+
+# Determine whether it's possible to make 'echo' print without a newline.
+# These variables are no longer used directly by Autoconf, but are AC_SUBSTed
+# for compatibility with existing Makefiles.
 ECHO_C= ECHO_N= ECHO_T=
 case `echo -n x` in #(((((
 -n*)
@@ -14810,6 +16017,12 @@ case `echo -n x` in #(((((
   ECHO_N='-n';;
 esac
 
+# For backward compatibility with old third-party macros, we provide
+# the shell variables $as_echo and $as_echo_n.  New code should use
+# AS_ECHO(["message"]) and AS_ECHO_N(["message"]), respectively.
+as_echo='printf %s\n'
+as_echo_n='printf %s'
+
 rm -f conf$$ conf$$.exe conf$$.file
 if test -d conf$$.dir; then
   rm -f conf$$.dir/conf$$.file
@@ -14851,7 +16064,7 @@ as_fn_mkdir_p ()
     as_dirs=
     while :; do
       case $as_dir in #(
-      *\'*) as_qdir=`$as_echo "$as_dir" | sed "s/'/'\\\\\\\\''/g"`;; #'(
+      *\'*) as_qdir=`printf "%s\n" "$as_dir" | sed "s/'/'\\\\\\\\''/g"`;; #'(
       *) as_qdir=$as_dir;;
       esac
       as_dirs="'$as_qdir' $as_dirs"
@@ -14860,7 +16073,7 @@ $as_expr X"$as_dir" : 'X\(.*[^/]\)//*[^/][^/]*/*$' \| \
 	 X"$as_dir" : 'X\(//\)[^/]' \| \
 	 X"$as_dir" : 'X\(//\)$' \| \
 	 X"$as_dir" : 'X\(/\)' \| . 2>/dev/null ||
-$as_echo X"$as_dir" |
+printf "%s\n" X"$as_dir" |
     sed '/^X\(.*[^/]\)\/\/*[^/][^/]*\/*$/{
 	    s//\1/
 	    q
@@ -14923,7 +16136,7 @@ cat >>$CONFIG_STATUS <<\_ACEOF || ac_write_fail=1
 # values after options handling.
 ac_log="
 This file was extended by $as_me, which was
-generated by GNU Autoconf 2.69.  Invocation command line was
+generated by GNU Autoconf 2.71.  Invocation command line was
 
   CONFIG_FILES    = $CONFIG_FILES
   CONFIG_HEADERS  = $CONFIG_HEADERS
@@ -14981,14 +16194,16 @@ $config_headers
 Report bugs to the package provider."
 
 _ACEOF
+ac_cs_config=`printf "%s\n" "$ac_configure_args" | sed "$ac_safe_unquote"`
+ac_cs_config_escaped=`printf "%s\n" "$ac_cs_config" | sed "s/^ //; s/'/'\\\\\\\\''/g"`
 cat >>$CONFIG_STATUS <<_ACEOF || ac_write_fail=1
-ac_cs_config="`$as_echo "$ac_configure_args" | sed 's/^ //; s/[\\""\`\$]/\\\\&/g'`"
+ac_cs_config='$ac_cs_config_escaped'
 ac_cs_version="\\
 config.status
-configured by $0, generated by GNU Autoconf 2.69,
+configured by $0, generated by GNU Autoconf 2.71,
   with options \\"\$ac_cs_config\\"
 
-Copyright (C) 2012 Free Software Foundation, Inc.
+Copyright (C) 2021 Free Software Foundation, Inc.
 This config.status script is free software; the Free Software Foundation
 gives unlimited permission to copy, distribute and modify it."
 
@@ -15028,15 +16243,15 @@ do
   -recheck | --recheck | --rechec | --reche | --rech | --rec | --re | --r)
     ac_cs_recheck=: ;;
   --version | --versio | --versi | --vers | --ver | --ve | --v | -V )
-    $as_echo "$ac_cs_version"; exit ;;
+    printf "%s\n" "$ac_cs_version"; exit ;;
   --config | --confi | --conf | --con | --co | --c )
-    $as_echo "$ac_cs_config"; exit ;;
+    printf "%s\n" "$ac_cs_config"; exit ;;
   --debug | --debu | --deb | --de | --d | -d )
     debug=: ;;
   --file | --fil | --fi | --f )
     $ac_shift
     case $ac_optarg in
-    *\'*) ac_optarg=`$as_echo "$ac_optarg" | sed "s/'/'\\\\\\\\''/g"` ;;
+    *\'*) ac_optarg=`printf "%s\n" "$ac_optarg" | sed "s/'/'\\\\\\\\''/g"` ;;
     '') as_fn_error $? "missing file argument" ;;
     esac
     as_fn_append CONFIG_FILES " '$ac_optarg'"
@@ -15044,7 +16259,7 @@ do
   --header | --heade | --head | --hea )
     $ac_shift
     case $ac_optarg in
-    *\'*) ac_optarg=`$as_echo "$ac_optarg" | sed "s/'/'\\\\\\\\''/g"` ;;
+    *\'*) ac_optarg=`printf "%s\n" "$ac_optarg" | sed "s/'/'\\\\\\\\''/g"` ;;
     esac
     as_fn_append CONFIG_HEADERS " '$ac_optarg'"
     ac_need_defaults=false;;
@@ -15053,7 +16268,7 @@ do
     as_fn_error $? "ambiguous option: \`$1'
 Try \`$0 --help' for more information.";;
   --help | --hel | -h )
-    $as_echo "$ac_cs_usage"; exit ;;
+    printf "%s\n" "$ac_cs_usage"; exit ;;
   -q | -quiet | --quiet | --quie | --qui | --qu | --q \
   | -silent | --silent | --silen | --sile | --sil | --si | --s)
     ac_cs_silent=: ;;
@@ -15081,7 +16296,7 @@ cat >>$CONFIG_STATUS <<_ACEOF || ac_write_fail=1
 if \$ac_cs_recheck; then
   set X $SHELL '$0' $ac_configure_args \$ac_configure_extra_args --no-create --no-recursion
   shift
-  \$as_echo "running CONFIG_SHELL=$SHELL \$*" >&6
+  \printf "%s\n" "running CONFIG_SHELL=$SHELL \$*" >&6
   CONFIG_SHELL='$SHELL'
   export CONFIG_SHELL
   exec "\$@"
@@ -15095,7 +16310,7 @@ exec 5>>config.log
   sed 'h;s/./-/g;s/^.../## /;s/...$/ ##/;p;x;p;x' <<_ASBOX
 ## Running $as_me. ##
 _ASBOX
-  $as_echo "$ac_log"
+  printf "%s\n" "$ac_log"
 } >&5
 
 _ACEOF
@@ -15180,8 +16395,8 @@ done
 # We use the long form for the default assignment because of an extremely
 # bizarre bug on SunOS 4.1.3.
 if $ac_need_defaults; then
-  test "${CONFIG_FILES+set}" = set || CONFIG_FILES=$config_files
-  test "${CONFIG_HEADERS+set}" = set || CONFIG_HEADERS=$config_headers
+  test ${CONFIG_FILES+y} || CONFIG_FILES=$config_files
+  test ${CONFIG_HEADERS+y} || CONFIG_HEADERS=$config_headers
 fi
 
 # Have a temporary directory for convenience.  Make it in the build tree
@@ -15517,7 +16732,7 @@ do
 	   esac ||
 	   as_fn_error 1 "cannot find input file: \`$ac_f'" "$LINENO" 5;;
       esac
-      case $ac_f in *\'*) ac_f=`$as_echo "$ac_f" | sed "s/'/'\\\\\\\\''/g"`;; esac
+      case $ac_f in *\'*) ac_f=`printf "%s\n" "$ac_f" | sed "s/'/'\\\\\\\\''/g"`;; esac
       as_fn_append ac_file_inputs " '$ac_f'"
     done
 
@@ -15525,17 +16740,17 @@ do
     # use $as_me), people would be surprised to read:
     #    /* config.h.  Generated by config.status.  */
     configure_input='Generated from '`
-	  $as_echo "$*" | sed 's|^[^:]*/||;s|:[^:]*/|, |g'
+	  printf "%s\n" "$*" | sed 's|^[^:]*/||;s|:[^:]*/|, |g'
 	`' by configure.'
     if test x"$ac_file" != x-; then
       configure_input="$ac_file.  $configure_input"
-      { $as_echo "$as_me:${as_lineno-$LINENO}: creating $ac_file" >&5
-$as_echo "$as_me: creating $ac_file" >&6;}
+      { printf "%s\n" "$as_me:${as_lineno-$LINENO}: creating $ac_file" >&5
+printf "%s\n" "$as_me: creating $ac_file" >&6;}
     fi
     # Neutralize special characters interpreted by sed in replacement strings.
     case $configure_input in #(
     *\&* | *\|* | *\\* )
-       ac_sed_conf_input=`$as_echo "$configure_input" |
+       ac_sed_conf_input=`printf "%s\n" "$configure_input" |
        sed 's/[\\\\&|]/\\\\&/g'`;; #(
     *) ac_sed_conf_input=$configure_input;;
     esac
@@ -15552,7 +16767,7 @@ $as_expr X"$ac_file" : 'X\(.*[^/]\)//*[^/][^/]*/*$' \| \
 	 X"$ac_file" : 'X\(//\)[^/]' \| \
 	 X"$ac_file" : 'X\(//\)$' \| \
 	 X"$ac_file" : 'X\(/\)' \| . 2>/dev/null ||
-$as_echo X"$ac_file" |
+printf "%s\n" X"$ac_file" |
     sed '/^X\(.*[^/]\)\/\/*[^/][^/]*\/*$/{
 	    s//\1/
 	    q
@@ -15576,9 +16791,9 @@ $as_echo X"$ac_file" |
 case "$ac_dir" in
 .) ac_dir_suffix= ac_top_builddir_sub=. ac_top_build_prefix= ;;
 *)
-  ac_dir_suffix=/`$as_echo "$ac_dir" | sed 's|^\.[\\/]||'`
+  ac_dir_suffix=/`printf "%s\n" "$ac_dir" | sed 's|^\.[\\/]||'`
   # A ".." for each directory in $ac_dir_suffix.
-  ac_top_builddir_sub=`$as_echo "$ac_dir_suffix" | sed 's|/[^\\/]*|/..|g;s|/||'`
+  ac_top_builddir_sub=`printf "%s\n" "$ac_dir_suffix" | sed 's|/[^\\/]*|/..|g;s|/||'`
   case $ac_top_builddir_sub in
   "") ac_top_builddir_sub=. ac_top_build_prefix= ;;
   *)  ac_top_build_prefix=$ac_top_builddir_sub/ ;;
@@ -15640,8 +16855,8 @@ ac_sed_dataroot='
 case `eval "sed -n \"\$ac_sed_dataroot\" $ac_file_inputs"` in
 *datarootdir*) ac_datarootdir_seen=yes;;
 *@datadir@*|*@docdir@*|*@infodir@*|*@localedir@*|*@mandir@*)
-  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: $ac_file_inputs seems to ignore the --datarootdir setting" >&5
-$as_echo "$as_me: WARNING: $ac_file_inputs seems to ignore the --datarootdir setting" >&2;}
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: $ac_file_inputs seems to ignore the --datarootdir setting" >&5
+printf "%s\n" "$as_me: WARNING: $ac_file_inputs seems to ignore the --datarootdir setting" >&2;}
 _ACEOF
 cat >>$CONFIG_STATUS <<_ACEOF || ac_write_fail=1
   ac_datarootdir_hack='
@@ -15685,9 +16900,9 @@ test -z "$ac_datarootdir_hack$ac_datarootdir_seen" &&
   { ac_out=`sed -n '/\${datarootdir}/p' "$ac_tmp/out"`; test -n "$ac_out"; } &&
   { ac_out=`sed -n '/^[	 ]*datarootdir[	 ]*:*=/p' \
       "$ac_tmp/out"`; test -z "$ac_out"; } &&
-  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: $ac_file contains a reference to the variable \`datarootdir'
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: $ac_file contains a reference to the variable \`datarootdir'
 which seems to be undefined.  Please make sure it is defined" >&5
-$as_echo "$as_me: WARNING: $ac_file contains a reference to the variable \`datarootdir'
+printf "%s\n" "$as_me: WARNING: $ac_file contains a reference to the variable \`datarootdir'
 which seems to be undefined.  Please make sure it is defined" >&2;}
 
   rm -f "$ac_tmp/stdin"
@@ -15703,20 +16918,20 @@ which seems to be undefined.  Please make sure it is defined" >&2;}
   #
   if test x"$ac_file" != x-; then
     {
-      $as_echo "/* $configure_input  */" \
+      printf "%s\n" "/* $configure_input  */" >&1 \
       && eval '$AWK -f "$ac_tmp/defines.awk"' "$ac_file_inputs"
     } >"$ac_tmp/config.h" \
       || as_fn_error $? "could not create $ac_file" "$LINENO" 5
     if diff "$ac_file" "$ac_tmp/config.h" >/dev/null 2>&1; then
-      { $as_echo "$as_me:${as_lineno-$LINENO}: $ac_file is unchanged" >&5
-$as_echo "$as_me: $ac_file is unchanged" >&6;}
+      { printf "%s\n" "$as_me:${as_lineno-$LINENO}: $ac_file is unchanged" >&5
+printf "%s\n" "$as_me: $ac_file is unchanged" >&6;}
     else
       rm -f "$ac_file"
       mv "$ac_tmp/config.h" "$ac_file" \
 	|| as_fn_error $? "could not create $ac_file" "$LINENO" 5
     fi
   else
-    $as_echo "/* $configure_input  */" \
+    printf "%s\n" "/* $configure_input  */" >&1 \
       && eval '$AWK -f "$ac_tmp/defines.awk"' "$ac_file_inputs" \
       || as_fn_error $? "could not create -" "$LINENO" 5
   fi
@@ -15757,42 +16972,50 @@ if test "$no_create" != yes; then
   $ac_cs_success || as_fn_exit 1
 fi
 if test -n "$ac_unrecognized_opts" && test "$enable_option_checking" != no; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: unrecognized options: $ac_unrecognized_opts" >&5
-$as_echo "$as_me: WARNING: unrecognized options: $ac_unrecognized_opts" >&2;}
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: unrecognized options: $ac_unrecognized_opts" >&5
+printf "%s\n" "$as_me: WARNING: unrecognized options: $ac_unrecognized_opts" >&2;}
 fi
 
 
-if test -n "$THIN_CONFIGURE_WARN"; then :
-  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Support for thin provisioning is limited since some thin provisioning tools are missing!" >&5
-$as_echo "$as_me: WARNING: Support for thin provisioning is limited since some thin provisioning tools are missing!" >&2;}
+if test -n "$THIN_CONFIGURE_WARN"
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: Support for thin provisioning is limited since some thin provisioning tools are missing!" >&5
+printf "%s\n" "$as_me: WARNING: Support for thin provisioning is limited since some thin provisioning tools are missing!" >&2;}
 fi
 
-if test -n "$THIN_CHECK_VERSION_WARN"; then :
-  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: You should also install latest thin_check vsn 0.7.0 (or later) for lvm2 thin provisioning" >&5
-$as_echo "$as_me: WARNING: You should also install latest thin_check vsn 0.7.0 (or later) for lvm2 thin provisioning" >&2;}
+if test -n "$THIN_CHECK_VERSION_WARN"
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: You should also install latest thin_check vsn 0.7.0 (or later) for lvm2 thin provisioning" >&5
+printf "%s\n" "$as_me: WARNING: You should also install latest thin_check vsn 0.7.0 (or later) for lvm2 thin provisioning" >&2;}
 fi
 
-if test -n "$CACHE_CONFIGURE_WARN"; then :
-  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Support for cache is limited since some cache tools are missing!" >&5
-$as_echo "$as_me: WARNING: Support for cache is limited since some cache tools are missing!" >&2;}
+if test -n "$CACHE_CONFIGURE_WARN"
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: Support for cache is limited since some cache tools are missing!" >&5
+printf "%s\n" "$as_me: WARNING: Support for cache is limited since some cache tools are missing!" >&2;}
 fi
 
-if test -n "$CACHE_CHECK_VERSION_WARN"; then :
-  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: You should install latest cache_check vsn 0.7.0 to use lvm2 cache metadata format 2" >&5
-$as_echo "$as_me: WARNING: You should install latest cache_check vsn 0.7.0 to use lvm2 cache metadata format 2" >&2;}
+if test -n "$CACHE_CHECK_VERSION_WARN"
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: You should install latest cache_check vsn 0.7.0 to use lvm2 cache metadata format 2" >&5
+printf "%s\n" "$as_me: WARNING: You should install latest cache_check vsn 0.7.0 to use lvm2 cache metadata format 2" >&2;}
 fi
 
-if test -n "$VDO_CONFIGURE_WARN"; then :
-  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Unrecognized 'vdoformat' tool is REQUIRED for VDO logical volume creation!" >&5
-$as_echo "$as_me: WARNING: Unrecognized 'vdoformat' tool is REQUIRED for VDO logical volume creation!" >&2;}
+if test -n "$VDO_CONFIGURE_WARN"
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: Unrecognized 'vdoformat' tool is REQUIRED for VDO logical volume creation!" >&5
+printf "%s\n" "$as_me: WARNING: Unrecognized 'vdoformat' tool is REQUIRED for VDO logical volume creation!" >&2;}
 fi
 
-if test -n "$LVM_NEEDS_LIBAIO_WARN"; then :
-  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Only libdm part can be build without libaio:  make [install_]device-mapper" >&5
-$as_echo "$as_me: WARNING: Only libdm part can be build without libaio:  make [install_]device-mapper" >&2;}
+if test -n "$LVM_NEEDS_LIBAIO_WARN"
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: Only libdm part can be build without libaio:  make [install_]device-mapper" >&5
+printf "%s\n" "$as_me: WARNING: Only libdm part can be build without libaio:  make [install_]device-mapper" >&2;}
 fi
 
-if test "$ODIRECT" != yes; then :
-  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&5
-$as_echo "$as_me: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&2;}
+if test "$ODIRECT" != yes
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&5
+printf "%s\n" "$as_me: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&2;}
 fi
+
diff --git a/include/configure.h.in b/include/configure.h.in
index e0d971bbf..83de33ab4 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -25,18 +25,13 @@
 /* The path to 'cache_restore', if available. */
 #undef CACHE_RESTORE_CMD
 
-/* Define to 1 if the `closedir' function returns void instead of `int'. */
+/* Define to 1 if the `closedir' function returns void instead of int. */
 #undef CLOSEDIR_VOID
 
 /* Path to cmirrord pidfile. */
 #undef CMIRRORD_PIDFILE
 
-/* Define to one of `_getb67', `GETB67', `getb67' for Cray-2 and Cray-YMP
-   systems. This function is required for `alloca.c' support on those systems.
-   */
-#undef CRAY_STACKSEG_END
-
-/* Define to 1 if using `alloca.c'. */
+/* Define to 1 if using 'alloca.c'. */
 #undef C_ALLOCA
 
 /* Name of default metadata archive subdirectory. */
@@ -90,7 +85,7 @@
 /* Use blkid wiping by default. */
 #undef DEFAULT_USE_BLKID_WIPING
 
-/* Default for lvm.conf use_devicefile. */
+/* Default for lvm.conf use_devicesfile. */
 #undef DEFAULT_USE_DEVICES_FILE
 
 /* Use lvmlockd by default. */
@@ -141,11 +136,10 @@
 /* Define to 1 if you have the `alarm' function. */
 #undef HAVE_ALARM
 
-/* Define to 1 if you have `alloca', as a function or macro. */
+/* Define to 1 if you have 'alloca', as a function or macro. */
 #undef HAVE_ALLOCA
 
-/* Define to 1 if you have <alloca.h> and it should be used (not on Ultrix).
-   */
+/* Define to 1 if <alloca.h> works. */
 #undef HAVE_ALLOCA_H
 
 /* Define to 1 if you have the <arpa/inet.h> header file. */
@@ -283,9 +277,6 @@
 /* Define to 1 if you have the `memchr' function. */
 #undef HAVE_MEMCHR
 
-/* Define to 1 if you have the <memory.h> header file. */
-#undef HAVE_MEMORY_H
-
 /* Define to 1 if you have the `memset' function. */
 #undef HAVE_MEMSET
 
@@ -402,7 +393,7 @@
 /* Define to 1 if you have the `strerror' function. */
 #undef HAVE_STRERROR
 
-/* Define to 1 if you have the `strerror_r' function. */
+/* Define if you have `strerror_r'. */
 #undef HAVE_STRERROR_R
 
 /* Define to 1 if you have the <strings.h> header file. */
@@ -662,7 +653,9 @@
 	STACK_DIRECTION = 0 => direction of growth unknown */
 #undef STACK_DIRECTION
 
-/* Define to 1 if you have the ANSI C header files. */
+/* Define to 1 if all of the C90 standard headers exist (not just the ones
+   required in a freestanding environment). This macro is provided for
+   backward compatibility; new code need not use it. */
 #undef STDC_HEADERS
 
 /* Define to 1 if strerror_r returns char *. */
@@ -693,7 +686,8 @@
 /* The path to 'thin_restore', if available. */
 #undef THIN_RESTORE_CMD
 
-/* Define to 1 if you can safely include both <sys/time.h> and <time.h>. */
+/* Define to 1 if you can safely include both <sys/time.h> and <time.h>. This
+   macro is obsolete. */
 #undef TIME_WITH_SYS_TIME
 
 /* Define to 1 if your <sys/time.h> declares `struct tm'. */
@@ -772,7 +766,7 @@
 /* Define to `long int' if <sys/types.h> does not define. */
 #undef off_t
 
-/* Define to `int' if <sys/types.h> does not define. */
+/* Define as a signed integer type capable of holding a process identifier. */
 #undef pid_t
 
 /* Define to rpl_realloc if the replacement function should be used. */

