From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 18 Feb 2016 00:01:11 +0000 (UTC)
Subject: master - lvmdbus: Add new daemon.
Message-ID: <20160218000111.955506066A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5987562cf924090affc656e05ae484ead516da30
Commit:        5987562cf924090affc656e05ae484ead516da30
Parent:        055c628e38589bf1ea66bc0b2c5da36ed115b551
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Feb 17 23:53:35 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Feb 17 23:53:35 2016 +0000

lvmdbus: Add new daemon.

---
 .gitignore                                       |    2 +
 WHATS_NEW                                        |    2 +
 aclocal.m4                                       |  311 +++++++-
 autoconf/py-compile                              |  170 ++++
 configure                                        |  996 +++++++++++++++++++--
 configure.in                                     |   90 ++-
 daemons/Makefile.in                              |    6 +-
 daemons/lvmdbusd/Makefile.in                     |   65 ++
 daemons/lvmdbusd/__init__.py                     |   10 +
 daemons/lvmdbusd/automatedproperties.py          |  175 ++++
 daemons/lvmdbusd/background.py                   |  195 ++++
 daemons/lvmdbusd/cfg.py                          |   80 ++
 daemons/lvmdbusd/cmdhandler.py                   |  619 +++++++++++++
 daemons/lvmdbusd/fetch.py                        |   30 +
 daemons/lvmdbusd/job.py                          |  170 ++++
 daemons/lvmdbusd/loader.py                       |   85 ++
 daemons/lvmdbusd/lv.py                           |  818 +++++++++++++++++
 daemons/lvmdbusd/lvm_shell_proxy.py              |  184 ++++
 daemons/lvmdbusd/lvmdb.py                        |  412 +++++++++
 daemons/lvmdbusd/lvmdbus.py                      |  140 +++
 daemons/lvmdbusd/lvmdbusd                        |   16 +
 daemons/lvmdbusd/manager.py                      |  241 +++++
 daemons/lvmdbusd/objectmanager.py                |  282 ++++++
 daemons/lvmdbusd/path.py.in                      |   10 +
 daemons/lvmdbusd/pv.py                           |  282 ++++++
 daemons/lvmdbusd/refresh.py                      |   45 +
 daemons/lvmdbusd/request.py                      |  140 +++
 daemons/lvmdbusd/state.py                        |   27 +
 daemons/lvmdbusd/udevwatch.py                    |   54 ++
 daemons/lvmdbusd/utils.py                        |  388 ++++++++
 daemons/lvmdbusd/vg.py                           |  936 +++++++++++++++++++
 make.tmpl.in                                     |   14 +-
 man/Makefile.in                                  |    9 +-
 man/lvmdbusd.8.in                                |   38 +
 python/Makefile.in                               |   16 +-
 scripts/Makefile.in                              |   15 +-
 scripts/com.redhat.lvmdbus1.conf                 |   13 +
 scripts/com.redhat.lvmdbus1.service.in           |    5 +
 scripts/lvm2_lvmdbusd_systemd_red_hat.service.in |   11 +
 test/dbus/lvmdbustest.py                         | 1053 ++++++++++++++++++++++
 40 files changed, 8076 insertions(+), 79 deletions(-)

diff --git a/.gitignore b/.gitignore
index 19181c9..a890cee 100644
--- a/.gitignore
+++ b/.gitignore
@@ -7,6 +7,8 @@
 *.orig
 *.pc
 *.pot
+*.pyc
+*.pyo
 *.rej
 *.so
 *.so.*
diff --git a/WHATS_NEW b/WHATS_NEW
index 48f2fb3..896ecce 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.143 - 
 =====================================
+  Add configure --enable-dbus-service for an LVM D-Bus service.
+  Replace configure --enable-python-bindings with python2 and python3 vsns.
   If PV belongs to some VG and metadata missing, skip it if system ID is used.
   Automatically change PV header extension to latest version if writing PV/VG.
   Identify used PVs in pv_attr field by new 'u' character.
diff --git a/aclocal.m4 b/aclocal.m4
index 805e68e..35107ac 100644
--- a/aclocal.m4
+++ b/aclocal.m4
@@ -12,6 +12,63 @@
 # PARTICULAR PURPOSE.
 
 m4_ifndef([AC_CONFIG_MACRO_DIRS], [m4_defun([_AM_CONFIG_MACRO_DIRS], [])m4_defun([AC_CONFIG_MACRO_DIRS], [_AM_CONFIG_MACRO_DIRS($@)])])
+# ===========================================================================
+#     http://www.gnu.org/software/autoconf-archive/ax_python_module.html
+# ===========================================================================
+#
+# SYNOPSIS
+#
+#   AX_PYTHON_MODULE(modname[, fatal, python])
+#
+# DESCRIPTION
+#
+#   Checks for Python module.
+#
+#   If fatal is non-empty then absence of a module will trigger an error.
+#   The third parameter can either be "python" for Python 2 or "python3" for
+#   Python 3; defaults to Python 3.
+#
+# LICENSE
+#
+#   Copyright (c) 2008 Andrew Collier
+#
+#   Copying and distribution of this file, with or without modification, are
+#   permitted in any medium without royalty provided the copyright notice
+#   and this notice are preserved. This file is offered as-is, without any
+#   warranty.
+
+#serial 8
+
+AU_ALIAS([AC_PYTHON_MODULE], [AX_PYTHON_MODULE])
+AC_DEFUN([AX_PYTHON_MODULE],[
+    if test -z $PYTHON;
+    then
+        if test -z "$3";
+        then
+            PYTHON="python3"
+        else
+            PYTHON="$3"
+        fi
+    fi
+    PYTHON_NAME=`basename $PYTHON`
+    AC_MSG_CHECKING($PYTHON_NAME module: $1)
+    $PYTHON -c "import $1" 2>/dev/null
+    if test $? -eq 0;
+    then
+        AC_MSG_RESULT(yes)
+        eval AS_TR_CPP(HAVE_PYMOD_$1)=yes
+    else
+        AC_MSG_RESULT(no)
+        eval AS_TR_CPP(HAVE_PYMOD_$1)=no
+        #
+        if test -n "$2"
+        then
+            AC_MSG_ERROR(failed to find required module $1)
+            exit 1
+        fi
+    fi
+])
+
 # pkg.m4 - Macros to locate and utilise pkg-config.            -*- Autoconf -*-
 # serial 1 (pkg-config-0.24)
 # 
@@ -29,7 +86,7 @@ m4_ifndef([AC_CONFIG_MACRO_DIRS], [m4_defun([_AM_CONFIG_MACRO_DIRS], [])m4_defun
 #
 # You should have received a copy of the GNU General Public License
 # along with this program; if not, write to the Free Software
-# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 #
 # As a special exception to the GNU General Public License, if you
 # distribute this file as part of a program that contains a
@@ -227,4 +284,256 @@ AS_VAR_COPY([$1], [pkg_cv_][$1])
 AS_VAR_IF([$1], [""], [$5], [$4])dnl
 ])# PKG_CHECK_VAR
 
+# Copyright (C) 1999-2014 Free Software Foundation, Inc.
+#
+# This file is free software; the Free Software Foundation
+# gives unlimited permission to copy and/or distribute it,
+# with or without modifications, as long as this notice is preserved.
+
+
+# AM_PATH_PYTHON([MINIMUM-VERSION], [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
+# ---------------------------------------------------------------------------
+# Adds support for distributing Python modules and packages.  To
+# install modules, copy them to $(pythondir), using the python_PYTHON
+# automake variable.  To install a package with the same name as the
+# automake package, install to $(pkgpythondir), or use the
+# pkgpython_PYTHON automake variable.
+#
+# The variables $(pyexecdir) and $(pkgpyexecdir) are provided as
+# locations to install python extension modules (shared libraries).
+# Another macro is required to find the appropriate flags to compile
+# extension modules.
+#
+# If your package is configured with a different prefix to python,
+# users will have to add the install directory to the PYTHONPATH
+# environment variable, or create a .pth file (see the python
+# documentation for details).
+#
+# If the MINIMUM-VERSION argument is passed, AM_PATH_PYTHON will
+# cause an error if the version of python installed on the system
+# doesn't meet the requirement.  MINIMUM-VERSION should consist of
+# numbers and dots only.
+AC_DEFUN([AM_PATH_PYTHON],
+ [
+  dnl Find a Python interpreter.  Python versions prior to 2.0 are not
+  dnl supported. (2.0 was released on October 16, 2000).
+  m4_define_default([_AM_PYTHON_INTERPRETER_LIST],
+[python python2 python3 python3.3 python3.2 python3.1 python3.0 python2.7 dnl
+ python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0])
+
+  AC_ARG_VAR([PYTHON], [the Python interpreter])
+
+  m4_if([$1],[],[
+    dnl No version check is needed.
+    # Find any Python interpreter.
+    if test -z "$PYTHON"; then
+      AC_PATH_PROGS([PYTHON], _AM_PYTHON_INTERPRETER_LIST, :)
+    fi
+    am_display_PYTHON=python
+  ], [
+    dnl A version check is needed.
+    if test -n "$PYTHON"; then
+      # If the user set $PYTHON, use it and don't search something else.
+      AC_MSG_CHECKING([whether $PYTHON version is >= $1])
+      AM_PYTHON_CHECK_VERSION([$PYTHON], [$1],
+			      [AC_MSG_RESULT([yes])],
+			      [AC_MSG_RESULT([no])
+			       AC_MSG_ERROR([Python interpreter is too old])])
+      am_display_PYTHON=$PYTHON
+    else
+      # Otherwise, try each interpreter until we find one that satisfies
+      # VERSION.
+      AC_CACHE_CHECK([for a Python interpreter with version >= $1],
+	[am_cv_pathless_PYTHON],[
+	for am_cv_pathless_PYTHON in _AM_PYTHON_INTERPRETER_LIST none; do
+	  test "$am_cv_pathless_PYTHON" = none && break
+	  AM_PYTHON_CHECK_VERSION([$am_cv_pathless_PYTHON], [$1], [break])
+	done])
+      # Set $PYTHON to the absolute path of $am_cv_pathless_PYTHON.
+      if test "$am_cv_pathless_PYTHON" = none; then
+	PYTHON=:
+      else
+        AC_PATH_PROG([PYTHON], [$am_cv_pathless_PYTHON])
+      fi
+      am_display_PYTHON=$am_cv_pathless_PYTHON
+    fi
+  ])
+
+  if test "$PYTHON" = :; then
+  dnl Run any user-specified action, or abort.
+    m4_default([$3], [AC_MSG_ERROR([no suitable Python interpreter found])])
+  else
+
+  dnl Query Python for its version number.  Getting [:3] seems to be
+  dnl the best way to do this; it's what "site.py" does in the standard
+  dnl library.
+
+  AC_CACHE_CHECK([for $am_display_PYTHON version], [am_cv_python_version],
+    [am_cv_python_version=`$PYTHON -c "import sys; sys.stdout.write(sys.version[[:3]])"`])
+  AC_SUBST([PYTHON_VERSION], [$am_cv_python_version])
+
+  dnl Use the values of $prefix and $exec_prefix for the corresponding
+  dnl values of PYTHON_PREFIX and PYTHON_EXEC_PREFIX.  These are made
+  dnl distinct variables so they can be overridden if need be.  However,
+  dnl general consensus is that you shouldn't need this ability.
+
+  AC_SUBST([PYTHON_PREFIX], ['${prefix}'])
+  AC_SUBST([PYTHON_EXEC_PREFIX], ['${exec_prefix}'])
+
+  dnl At times (like when building shared libraries) you may want
+  dnl to know which OS platform Python thinks this is.
+
+  AC_CACHE_CHECK([for $am_display_PYTHON platform], [am_cv_python_platform],
+    [am_cv_python_platform=`$PYTHON -c "import sys; sys.stdout.write(sys.platform)"`])
+  AC_SUBST([PYTHON_PLATFORM], [$am_cv_python_platform])
+
+  # Just factor out some code duplication.
+  am_python_setup_sysconfig="\
+import sys
+# Prefer sysconfig over distutils.sysconfig, for better compatibility
+# with python 3.x.  See automake bug#10227.
+try:
+    import sysconfig
+except ImportError:
+    can_use_sysconfig = 0
+else:
+    can_use_sysconfig = 1
+# Can't use sysconfig in CPython 2.7, since it's broken in virtualenvs:
+# <https://github.com/pypa/virtualenv/issues/118>
+try:
+    from platform import python_implementation
+    if python_implementation() == 'CPython' and sys.version[[:3]] == '2.7':
+        can_use_sysconfig = 0
+except ImportError:
+    pass"
+
+  dnl Set up 4 directories:
+
+  dnl pythondir -- where to install python scripts.  This is the
+  dnl   site-packages directory, not the python standard library
+  dnl   directory like in previous automake betas.  This behavior
+  dnl   is more consistent with lispdir.m4 for example.
+  dnl Query distutils for this directory.
+  AC_CACHE_CHECK([for $am_display_PYTHON script directory],
+    [am_cv_python_pythondir],
+    [if test "x$prefix" = xNONE
+     then
+       am_py_prefix=$ac_default_prefix
+     else
+       am_py_prefix=$prefix
+     fi
+     am_cv_python_pythondir=`$PYTHON -c "
+$am_python_setup_sysconfig
+if can_use_sysconfig:
+    sitedir = sysconfig.get_path('purelib', vars={'base':'$am_py_prefix'})
+else:
+    from distutils import sysconfig
+    sitedir = sysconfig.get_python_lib(0, 0, prefix='$am_py_prefix')
+sys.stdout.write(sitedir)"`
+     case $am_cv_python_pythondir in
+     $am_py_prefix*)
+       am__strip_prefix=`echo "$am_py_prefix" | sed 's|.|.|g'`
+       am_cv_python_pythondir=`echo "$am_cv_python_pythondir" | sed "s,^$am__strip_prefix,$PYTHON_PREFIX,"`
+       ;;
+     *)
+       case $am_py_prefix in
+         /usr|/System*) ;;
+         *)
+	  am_cv_python_pythondir=$PYTHON_PREFIX/lib/python$PYTHON_VERSION/site-packages
+	  ;;
+       esac
+       ;;
+     esac
+    ])
+  AC_SUBST([pythondir], [$am_cv_python_pythondir])
+
+  dnl pkgpythondir -- $PACKAGE directory under pythondir.  Was
+  dnl   PYTHON_SITE_PACKAGE in previous betas, but this naming is
+  dnl   more consistent with the rest of automake.
+
+  AC_SUBST([pkgpythondir], [\${pythondir}/$PACKAGE])
+
+  dnl pyexecdir -- directory for installing python extension modules
+  dnl   (shared libraries)
+  dnl Query distutils for this directory.
+  AC_CACHE_CHECK([for $am_display_PYTHON extension module directory],
+    [am_cv_python_pyexecdir],
+    [if test "x$exec_prefix" = xNONE
+     then
+       am_py_exec_prefix=$am_py_prefix
+     else
+       am_py_exec_prefix=$exec_prefix
+     fi
+     am_cv_python_pyexecdir=`$PYTHON -c "
+$am_python_setup_sysconfig
+if can_use_sysconfig:
+    sitedir = sysconfig.get_path('platlib', vars={'platbase':'$am_py_prefix'})
+else:
+    from distutils import sysconfig
+    sitedir = sysconfig.get_python_lib(1, 0, prefix='$am_py_prefix')
+sys.stdout.write(sitedir)"`
+     case $am_cv_python_pyexecdir in
+     $am_py_exec_prefix*)
+       am__strip_prefix=`echo "$am_py_exec_prefix" | sed 's|.|.|g'`
+       am_cv_python_pyexecdir=`echo "$am_cv_python_pyexecdir" | sed "s,^$am__strip_prefix,$PYTHON_EXEC_PREFIX,"`
+       ;;
+     *)
+       case $am_py_exec_prefix in
+         /usr|/System*) ;;
+         *)
+	   am_cv_python_pyexecdir=$PYTHON_EXEC_PREFIX/lib/python$PYTHON_VERSION/site-packages
+	   ;;
+       esac
+       ;;
+     esac
+    ])
+  AC_SUBST([pyexecdir], [$am_cv_python_pyexecdir])
+
+  dnl pkgpyexecdir -- $(pyexecdir)/$(PACKAGE)
+
+  AC_SUBST([pkgpyexecdir], [\${pyexecdir}/$PACKAGE])
+
+  dnl Run any user-specified action.
+  $2
+  fi
+
+])
+
+
+# AM_PYTHON_CHECK_VERSION(PROG, VERSION, [ACTION-IF-TRUE], [ACTION-IF-FALSE])
+# ---------------------------------------------------------------------------
+# Run ACTION-IF-TRUE if the Python interpreter PROG has version >= VERSION.
+# Run ACTION-IF-FALSE otherwise.
+# This test uses sys.hexversion instead of the string equivalent (first
+# word of sys.version), in order to cope with versions such as 2.2c1.
+# This supports Python 2.0 or higher. (2.0 was released on October 16, 2000).
+AC_DEFUN([AM_PYTHON_CHECK_VERSION],
+ [prog="import sys
+# split strings by '.' and convert to numeric.  Append some zeros
+# because we need at least 4 digits for the hex conversion.
+# map returns an iterator in Python 3.0 and a list in 2.x
+minver = list(map(int, '$2'.split('.'))) + [[0, 0, 0]]
+minverhex = 0
+# xrange is not present in Python 3.0 and range returns an iterator
+for i in list(range(0, 4)): minverhex = (minverhex << 8) + minver[[i]]
+sys.exit(sys.hexversion < minverhex)"
+  AS_IF([AM_RUN_LOG([$1 -c "$prog"])], [$3], [$4])])
+
+# Copyright (C) 2001-2014 Free Software Foundation, Inc.
+#
+# This file is free software; the Free Software Foundation
+# gives unlimited permission to copy and/or distribute it,
+# with or without modifications, as long as this notice is preserved.
+
+# AM_RUN_LOG(COMMAND)
+# -------------------
+# Run COMMAND, save the exit status in ac_status, and log it.
+# (This has been adapted from Autoconf's _AC_RUN_LOG macro.)
+AC_DEFUN([AM_RUN_LOG],
+[{ echo "$as_me:$LINENO: $1" >&AS_MESSAGE_LOG_FD
+   ($1) >&AS_MESSAGE_LOG_FD 2>&AS_MESSAGE_LOG_FD
+   ac_status=$?
+   echo "$as_me:$LINENO: \$? = $ac_status" >&AS_MESSAGE_LOG_FD
+   (exit $ac_status); }])
+
 m4_include([acinclude.m4])
diff --git a/autoconf/py-compile b/autoconf/py-compile
new file mode 100644
index 0000000..bc20391
--- /dev/null
+++ b/autoconf/py-compile
@@ -0,0 +1,170 @@
+#!/bin/sh
+# py-compile - Compile a Python program
+
+scriptversion=2011-06-08.12; # UTC
+
+# Copyright (C) 2000-2014 Free Software Foundation, Inc.
+
+# This program is free software; you can redistribute it and/or modify
+# it under the terms of the GNU General Public License as published by
+# the Free Software Foundation; either version 2, or (at your option)
+# any later version.
+
+# This program is distributed in the hope that it will be useful,
+# but WITHOUT ANY WARRANTY; without even the implied warranty of
+# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+# GNU General Public License for more details.
+
+# You should have received a copy of the GNU General Public License
+# along with this program.  If not, see <http://www.gnu.org/licenses/>.
+
+# As a special exception to the GNU General Public License, if you
+# distribute this file as part of a program that contains a
+# configuration script generated by Autoconf, you may include it under
+# the same distribution terms that you use for the rest of that program.
+
+# This file is maintained in Automake, please report
+# bugs to <bug-automake@gnu.org> or send patches to
+# <automake-patches@gnu.org>.
+
+if [ -z "$PYTHON" ]; then
+  PYTHON=python
+fi
+
+me=py-compile
+
+usage_error ()
+{
+  echo "$me: $*" >&2
+  echo "Try '$me --help' for more information." >&2
+  exit 1
+}
+
+basedir=
+destdir=
+while test $# -ne 0; do
+  case "$1" in
+    --basedir)
+      if test $# -lt 2; then
+        usage_error "option '--basedir' requires an argument"
+      else
+        basedir=$2
+      fi
+      shift
+      ;;
+    --destdir)
+      if test $# -lt 2; then
+        usage_error "option '--destdir' requires an argument"
+      else
+        destdir=$2
+      fi
+      shift
+      ;;
+    -h|--help)
+      cat <<\EOF
+Usage: py-compile [--help] [--version] [--basedir DIR] [--destdir DIR] FILES..."
+
+Byte compile some python scripts FILES.  Use --destdir to specify any
+leading directory path to the FILES that you don't want to include in the
+byte compiled file.  Specify --basedir for any additional path information you
+do want to be shown in the byte compiled file.
+
+Example:
+  py-compile --destdir /tmp/pkg-root --basedir /usr/share/test test.py test2.py
+
+Report bugs to <bug-automake@gnu.org>.
+EOF
+      exit $?
+      ;;
+    -v|--version)
+      echo "$me $scriptversion"
+      exit $?
+      ;;
+    --)
+      shift
+      break
+      ;;
+    -*)
+      usage_error "unrecognized option '$1'"
+      ;;
+    *)
+      break
+      ;;
+  esac
+  shift
+done
+
+files=$*
+if test -z "$files"; then
+    usage_error "no files given"
+fi
+
+# if basedir was given, then it should be prepended to filenames before
+# byte compilation.
+if [ -z "$basedir" ]; then
+    pathtrans="path = file"
+else
+    pathtrans="path = os.path.join('$basedir', file)"
+fi
+
+# if destdir was given, then it needs to be prepended to the filename to
+# byte compile but not go into the compiled file.
+if [ -z "$destdir" ]; then
+    filetrans="filepath = path"
+else
+    filetrans="filepath = os.path.normpath('$destdir' + os.sep + path)"
+fi
+
+$PYTHON -c "
+import sys, os, py_compile, imp
+
+files = '''$files'''
+
+sys.stdout.write('Byte-compiling python modules...\n')
+for file in files.split():
+    $pathtrans
+    $filetrans
+    if not os.path.exists(filepath) or not (len(filepath) >= 3
+                                            and filepath[-3:] == '.py'):
+	    continue
+    sys.stdout.write(file)
+    sys.stdout.flush()
+    if hasattr(imp, 'get_tag'):
+        py_compile.compile(filepath, imp.cache_from_source(filepath), path)
+    else:
+        py_compile.compile(filepath, filepath + 'c', path)
+sys.stdout.write('\n')" || exit $?
+
+# this will fail for python < 1.5, but that doesn't matter ...
+$PYTHON -O -c "
+import sys, os, py_compile, imp
+
+# pypy does not use .pyo optimization
+if hasattr(sys, 'pypy_translation_info'):
+    sys.exit(0)
+
+files = '''$files'''
+sys.stdout.write('Byte-compiling python modules (optimized versions) ...\n')
+for file in files.split():
+    $pathtrans
+    $filetrans
+    if not os.path.exists(filepath) or not (len(filepath) >= 3
+                                            and filepath[-3:] == '.py'):
+	    continue
+    sys.stdout.write(file)
+    sys.stdout.flush()
+    if hasattr(imp, 'get_tag'):
+        py_compile.compile(filepath, imp.cache_from_source(filepath, False), path)
+    else:
+        py_compile.compile(filepath, filepath + 'o', path)
+sys.stdout.write('\n')" 2>/dev/null || :
+
+# Local Variables:
+# mode: shell-script
+# sh-indentation: 2
+# eval: (add-hook 'write-file-hooks 'time-stamp)
+# time-stamp-start: "scriptversion="
+# time-stamp-format: "%:y-%02m-%02d.%02H"
+# time-stamp-time-zone: "UTC"
+# time-stamp-end: "; # UTC"
+# End:
diff --git a/configure b/configure
index f22a11e..93e0003 100755
--- a/configure
+++ b/configure
@@ -662,9 +662,16 @@ REPLICATORS
 READLINE_LIBS
 RT_LIB
 RAID
-PYTHON_LIBDIRS
-PYTHON_INCDIRS
+PYTHON3DIR
+PYTHON2DIR
+PYTHON3_LIBDIRS
+PYTHON2_LIBDIRS
+PYTHON3_INCDIRS
+PYTHON2_INCDIRS
+PYTHON3_BINDINGS
+PYTHON2_BINDINGS
 PYTHON_BINDINGS
+PYTHON3
 PTHREAD_LIBS
 M_LIBS
 POOL
@@ -733,13 +740,24 @@ BUILD_LOCKDSANLOCK
 BUILD_LVMLOCKD
 BUILD_LVMPOLLD
 BUILD_LVMETAD
+BUILD_LVMDBUSD
 BUILD_DMEVENTD
 BUILD_CMIRRORD
 BLKID_PC
 APPLIB
 MODPROBE_CMD
 MSGFMT
-PYTHON_CONFIG
+PYTHON3_CONFIG
+PYTHON2_CONFIG
+PYTHON2
+pkgpyexecdir
+pyexecdir
+pkgpythondir
+pythondir
+PYTHON_PLATFORM
+PYTHON_EXEC_PREFIX
+PYTHON_PREFIX
+PYTHON_VERSION
 PYTHON
 LVM2CMD_LIB
 LVM2APP_LIB
@@ -799,6 +817,7 @@ HAVE_PIE
 POW_LIB
 LIBOBJS
 ALLOCA
+CHMOD
 CSCOPE_CMD
 CFLOW_CMD
 RANLIB
@@ -946,7 +965,10 @@ enable_ioctl
 enable_o_direct
 enable_applib
 enable_cmdlib
+enable_dbus_service
 enable_python_bindings
+enable_python2_bindings
+enable_python3_bindings
 enable_pkgconfig
 enable_write_install
 enable_fsadm
@@ -1022,7 +1044,8 @@ BLKID_LIBS
 SYSTEMD_CFLAGS
 SYSTEMD_LIBS
 UDEV_CFLAGS
-UDEV_LIBS'
+UDEV_LIBS
+PYTHON'
 
 
 # Initialize some variables set by options.
@@ -1678,8 +1701,13 @@ Optional Features:
   --disable-o_direct      disable O_DIRECT
   --enable-applib         build application library
   --enable-cmdlib         build shared command library
+  --enable-dbus-service   install D-Bus support
   --enable-python_bindings
-                          build Python applib bindings
+                          build default Python applib bindings
+  --enable-python2_bindings
+                          build Python2 applib bindings
+  --enable-python3_bindings
+                          build Python3 applib bindings
   --enable-pkgconfig      install pkgconfig support
   --enable-write_install  install user writable files
   --disable-fsadm         disable fsadm
@@ -1858,6 +1886,7 @@ Some influential environment variables:
               linker flags for SYSTEMD, overriding pkg-config
   UDEV_CFLAGS C compiler flags for UDEV, overriding pkg-config
   UDEV_LIBS   linker flags for UDEV, overriding pkg-config
+  PYTHON      the Python interpreter
 
 Use these variables to override the choices made by `configure' or to help
 it to find libraries and programs with nonstandard names/locations.
@@ -5095,6 +5124,104 @@ else
   CSCOPE_CMD="$ac_cv_path_CSCOPE_CMD"
 fi
 
+if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}chmod", so it can be a program name with args.
+set dummy ${ac_tool_prefix}chmod; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_CHMOD+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $CHMOD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_CHMOD="$CHMOD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_CHMOD="$as_dir/$ac_word$ac_exec_ext"
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
+CHMOD=$ac_cv_path_CHMOD
+if test -n "$CHMOD"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CHMOD" >&5
+$as_echo "$CHMOD" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+fi
+if test -z "$ac_cv_path_CHMOD"; then
+  ac_pt_CHMOD=$CHMOD
+  # Extract the first word of "chmod", so it can be a program name with args.
+set dummy chmod; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_ac_pt_CHMOD+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_CHMOD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_CHMOD="$ac_pt_CHMOD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_CHMOD="$as_dir/$ac_word$ac_exec_ext"
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
+ac_pt_CHMOD=$ac_cv_path_ac_pt_CHMOD
+if test -n "$ac_pt_CHMOD"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_CHMOD" >&5
+$as_echo "$ac_pt_CHMOD" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_pt_CHMOD" = x; then
+    CHMOD=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    CHMOD=$ac_pt_CHMOD
+  fi
+else
+  CHMOD="$ac_cv_path_CHMOD"
+fi
+
 
 ################################################################################
 ac_header_dirent=no
@@ -12187,6 +12314,19 @@ test "$CMDLIB" = yes \
   || LVM2CMD_LIB=
 
 ################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include Python D-Bus support" >&5
+$as_echo_n "checking whether to include Python D-Bus support... " >&6; }
+# Check whether --enable-dbus-service was given.
+if test "${enable_dbus_service+set}" = set; then :
+  enableval=$enable_dbus_service; BUILD_LVMDBUSD=$enableval
+else
+  BUILD_LVMDBUSD=no
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $BUILD_LVMDBUSD" >&5
+$as_echo "$BUILD_LVMDBUSD" >&6; }
+
+################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build Python wrapper for liblvm2app.so" >&5
 $as_echo_n "checking whether to build Python wrapper for liblvm2app.so... " >&6; }
 # Check whether --enable-python_bindings was given.
@@ -12199,12 +12339,105 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $PYTHON_BINDINGS" >&5
 $as_echo "$PYTHON_BINDINGS" >&6; }
 
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build Python2 wrapper for liblvm2app.so" >&5
+$as_echo_n "checking whether to build Python2 wrapper for liblvm2app.so... " >&6; }
+# Check whether --enable-python2_bindings was given.
+if test "${enable_python2_bindings+set}" = set; then :
+  enableval=$enable_python2_bindings; PYTHON2_BINDINGS=$enableval
+else
+  PYTHON2_BINDINGS=no
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $PYTHON2_BINDINGS" >&5
+$as_echo "$PYTHON2_BINDINGS" >&6; }
+
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build Python3 wrapper for liblvm2app.so" >&5
+$as_echo_n "checking whether to build Python3 wrapper for liblvm2app.so... " >&6; }
+# Check whether --enable-python3_bindings was given.
+if test "${enable_python3_bindings+set}" = set; then :
+  enableval=$enable_python3_bindings; PYTHON3_BINDINGS=$enableval
+else
+  PYTHON3_BINDINGS=no
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $PYTHON3_BINDINGS" >&5
+$as_echo "$PYTHON3_BINDINGS" >&6; }
+
 if test "$PYTHON_BINDINGS" = yes; then
-	test "$APPLIB" != yes && as_fn_error $? "--enable-python_bindings requires --enable-applib" "$LINENO" 5
+	as_fn_error $? "--enable-python-bindings is replaced by --enable-python2-bindings and --enable-python3-bindings" "$LINENO" 5
+fi
 
-	if test -n "$ac_tool_prefix"; then
-  # Extract the first word of "${ac_tool_prefix}python", so it can be a program name with args.
-set dummy ${ac_tool_prefix}python; ac_word=$2
+if test "$PYTHON2_BINDINGS" = yes; then
+
+
+
+
+
+
+        if test -n "$PYTHON"; then
+      # If the user set $PYTHON, use it and don't search something else.
+      { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $PYTHON version is >= 2" >&5
+$as_echo_n "checking whether $PYTHON version is >= 2... " >&6; }
+      prog="import sys
+# split strings by '.' and convert to numeric.  Append some zeros
+# because we need at least 4 digits for the hex conversion.
+# map returns an iterator in Python 3.0 and a list in 2.x
+minver = list(map(int, '2'.split('.'))) + [0, 0, 0]
+minverhex = 0
+# xrange is not present in Python 3.0 and range returns an iterator
+for i in list(range(0, 4)): minverhex = (minverhex << 8) + minver[i]
+sys.exit(sys.hexversion < minverhex)"
+  if { echo "$as_me:$LINENO: $PYTHON -c "$prog"" >&5
+   ($PYTHON -c "$prog") >&5 2>&5
+   ac_status=$?
+   echo "$as_me:$LINENO: \$? = $ac_status" >&5
+   (exit $ac_status); }; then :
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+			       as_fn_error $? "Python interpreter is too old" "$LINENO" 5
+fi
+      am_display_PYTHON=$PYTHON
+    else
+      # Otherwise, try each interpreter until we find one that satisfies
+      # VERSION.
+      { $as_echo "$as_me:${as_lineno-$LINENO}: checking for a Python interpreter with version >= 2" >&5
+$as_echo_n "checking for a Python interpreter with version >= 2... " >&6; }
+if ${am_cv_pathless_PYTHON+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+
+	for am_cv_pathless_PYTHON in python python2 python3 python3.3 python3.2 python3.1 python3.0 python2.7  python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0 none; do
+	  test "$am_cv_pathless_PYTHON" = none && break
+	  prog="import sys
+# split strings by '.' and convert to numeric.  Append some zeros
+# because we need at least 4 digits for the hex conversion.
+# map returns an iterator in Python 3.0 and a list in 2.x
+minver = list(map(int, '2'.split('.'))) + [0, 0, 0]
+minverhex = 0
+# xrange is not present in Python 3.0 and range returns an iterator
+for i in list(range(0, 4)): minverhex = (minverhex << 8) + minver[i]
+sys.exit(sys.hexversion < minverhex)"
+  if { echo "$as_me:$LINENO: $am_cv_pathless_PYTHON -c "$prog"" >&5
+   ($am_cv_pathless_PYTHON -c "$prog") >&5 2>&5
+   ac_status=$?
+   echo "$as_me:$LINENO: \$? = $ac_status" >&5
+   (exit $ac_status); }; then :
+  break
+fi
+	done
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $am_cv_pathless_PYTHON" >&5
+$as_echo "$am_cv_pathless_PYTHON" >&6; }
+      # Set $PYTHON to the absolute path of $am_cv_pathless_PYTHON.
+      if test "$am_cv_pathless_PYTHON" = none; then
+	PYTHON=:
+      else
+        # Extract the first word of "$am_cv_pathless_PYTHON", so it can be a program name with args.
+set dummy $am_cv_pathless_PYTHON; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
 if ${ac_cv_path_PYTHON+:} false; then :
@@ -12243,19 +12476,171 @@ $as_echo "no" >&6; }
 fi
 
 
+      fi
+      am_display_PYTHON=$am_cv_pathless_PYTHON
+    fi
+
+
+  if test "$PYTHON" = :; then
+      as_fn_error $? "no suitable Python interpreter found" "$LINENO" 5
+  else
+
+
+  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $am_display_PYTHON version" >&5
+$as_echo_n "checking for $am_display_PYTHON version... " >&6; }
+if ${am_cv_python_version+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  am_cv_python_version=`$PYTHON -c "import sys; sys.stdout.write(sys.version[:3])"`
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $am_cv_python_version" >&5
+$as_echo "$am_cv_python_version" >&6; }
+  PYTHON_VERSION=$am_cv_python_version
+
+
+
+  PYTHON_PREFIX='${prefix}'
+
+  PYTHON_EXEC_PREFIX='${exec_prefix}'
+
+
+
+  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $am_display_PYTHON platform" >&5
+$as_echo_n "checking for $am_display_PYTHON platform... " >&6; }
+if ${am_cv_python_platform+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  am_cv_python_platform=`$PYTHON -c "import sys; sys.stdout.write(sys.platform)"`
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $am_cv_python_platform" >&5
+$as_echo "$am_cv_python_platform" >&6; }
+  PYTHON_PLATFORM=$am_cv_python_platform
+
+
+  # Just factor out some code duplication.
+  am_python_setup_sysconfig="\
+import sys
+# Prefer sysconfig over distutils.sysconfig, for better compatibility
+# with python 3.x.  See automake bug#10227.
+try:
+    import sysconfig
+except ImportError:
+    can_use_sysconfig = 0
+else:
+    can_use_sysconfig = 1
+# Can't use sysconfig in CPython 2.7, since it's broken in virtualenvs:
+# <https://github.com/pypa/virtualenv/issues/118>
+try:
+    from platform import python_implementation
+    if python_implementation() == 'CPython' and sys.version[:3] == '2.7':
+        can_use_sysconfig = 0
+except ImportError:
+    pass"
+
+
+            { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $am_display_PYTHON script directory" >&5
+$as_echo_n "checking for $am_display_PYTHON script directory... " >&6; }
+if ${am_cv_python_pythondir+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  if test "x$prefix" = xNONE
+     then
+       am_py_prefix=$ac_default_prefix
+     else
+       am_py_prefix=$prefix
+     fi
+     am_cv_python_pythondir=`$PYTHON -c "
+$am_python_setup_sysconfig
+if can_use_sysconfig:
+    sitedir = sysconfig.get_path('purelib', vars={'base':'$am_py_prefix'})
+else:
+    from distutils import sysconfig
+    sitedir = sysconfig.get_python_lib(0, 0, prefix='$am_py_prefix')
+sys.stdout.write(sitedir)"`
+     case $am_cv_python_pythondir in
+     $am_py_prefix*)
+       am__strip_prefix=`echo "$am_py_prefix" | sed 's|.|.|g'`
+       am_cv_python_pythondir=`echo "$am_cv_python_pythondir" | sed "s,^$am__strip_prefix,$PYTHON_PREFIX,"`
+       ;;
+     *)
+       case $am_py_prefix in
+         /usr|/System*) ;;
+         *)
+	  am_cv_python_pythondir=$PYTHON_PREFIX/lib/python$PYTHON_VERSION/site-packages
+	  ;;
+       esac
+       ;;
+     esac
+
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $am_cv_python_pythondir" >&5
+$as_echo "$am_cv_python_pythondir" >&6; }
+  pythondir=$am_cv_python_pythondir
+
+
+
+  pkgpythondir=\${pythondir}/$PACKAGE
+
+
+        { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $am_display_PYTHON extension module directory" >&5
+$as_echo_n "checking for $am_display_PYTHON extension module directory... " >&6; }
+if ${am_cv_python_pyexecdir+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  if test "x$exec_prefix" = xNONE
+     then
+       am_py_exec_prefix=$am_py_prefix
+     else
+       am_py_exec_prefix=$exec_prefix
+     fi
+     am_cv_python_pyexecdir=`$PYTHON -c "
+$am_python_setup_sysconfig
+if can_use_sysconfig:
+    sitedir = sysconfig.get_path('platlib', vars={'platbase':'$am_py_prefix'})
+else:
+    from distutils import sysconfig
+    sitedir = sysconfig.get_python_lib(1, 0, prefix='$am_py_prefix')
+sys.stdout.write(sitedir)"`
+     case $am_cv_python_pyexecdir in
+     $am_py_exec_prefix*)
+       am__strip_prefix=`echo "$am_py_exec_prefix" | sed 's|.|.|g'`
+       am_cv_python_pyexecdir=`echo "$am_cv_python_pyexecdir" | sed "s,^$am__strip_prefix,$PYTHON_EXEC_PREFIX,"`
+       ;;
+     *)
+       case $am_py_exec_prefix in
+         /usr|/System*) ;;
+         *)
+	   am_cv_python_pyexecdir=$PYTHON_EXEC_PREFIX/lib/python$PYTHON_VERSION/site-packages
+	   ;;
+       esac
+       ;;
+     esac
+
 fi
-if test -z "$ac_cv_path_PYTHON"; then
-  ac_pt_PYTHON=$PYTHON
-  # Extract the first word of "python", so it can be a program name with args.
-set dummy python; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $am_cv_python_pyexecdir" >&5
+$as_echo "$am_cv_python_pyexecdir" >&6; }
+  pyexecdir=$am_cv_python_pyexecdir
+
+
+
+  pkgpyexecdir=\${pyexecdir}/$PACKAGE
+
+
+
+  fi
+
+
+	if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}python2", so it can be a program name with args.
+set dummy ${ac_tool_prefix}python2; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_ac_pt_PYTHON+:} false; then :
+if ${ac_cv_path_PYTHON2+:} false; then :
   $as_echo_n "(cached) " >&6
 else
-  case $ac_pt_PYTHON in
+  case $PYTHON2 in
   [\\/]* | ?:[\\/]*)
-  ac_cv_path_ac_pt_PYTHON="$ac_pt_PYTHON" # Let the user override the test with a path.
+  ac_cv_path_PYTHON2="$PYTHON2" # Let the user override the test with a path.
   ;;
   *)
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
@@ -12265,7 +12650,7 @@ do
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
   if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_ac_pt_PYTHON="$as_dir/$ac_word$ac_exec_ext"
+    ac_cv_path_PYTHON2="$as_dir/$ac_word$ac_exec_ext"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
   fi
@@ -12276,17 +12661,60 @@ IFS=$as_save_IFS
   ;;
 esac
 fi
-ac_pt_PYTHON=$ac_cv_path_ac_pt_PYTHON
-if test -n "$ac_pt_PYTHON"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_PYTHON" >&5
-$as_echo "$ac_pt_PYTHON" >&6; }
+PYTHON2=$ac_cv_path_PYTHON2
+if test -n "$PYTHON2"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $PYTHON2" >&5
+$as_echo "$PYTHON2" >&6; }
 else
   { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
 $as_echo "no" >&6; }
 fi
 
-  if test "x$ac_pt_PYTHON" = x; then
-    PYTHON=""
+
+fi
+if test -z "$ac_cv_path_PYTHON2"; then
+  ac_pt_PYTHON2=$PYTHON2
+  # Extract the first word of "python2", so it can be a program name with args.
+set dummy python2; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_ac_pt_PYTHON2+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_PYTHON2 in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_PYTHON2="$ac_pt_PYTHON2" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_PYTHON2="$as_dir/$ac_word$ac_exec_ext"
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
+ac_pt_PYTHON2=$ac_cv_path_ac_pt_PYTHON2
+if test -n "$ac_pt_PYTHON2"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_PYTHON2" >&5
+$as_echo "$ac_pt_PYTHON2" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_pt_PYTHON2" = x; then
+    PYTHON2=""
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
@@ -12294,25 +12722,397 @@ yes:)
 $as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
-    PYTHON=$ac_pt_PYTHON
+    PYTHON2=$ac_pt_PYTHON2
   fi
 else
-  PYTHON="$ac_cv_path_PYTHON"
+  PYTHON2="$ac_cv_path_PYTHON2"
 fi
 
-	test -z "$PYTHON" && as_fn_error $? "python is required for --enable-python_bindings but cannot be found" "$LINENO" 5
+	test -z "$PYTHON2" && as_fn_error $? "python2 is required for --enable-python2_bindings but cannot be found" "$LINENO" 5
+	if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}python2-config", so it can be a program name with args.
+set dummy ${ac_tool_prefix}python2-config; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_PYTHON2_CONFIG+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $PYTHON2_CONFIG in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_PYTHON2_CONFIG="$PYTHON2_CONFIG" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_PYTHON2_CONFIG="$as_dir/$ac_word$ac_exec_ext"
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
+PYTHON2_CONFIG=$ac_cv_path_PYTHON2_CONFIG
+if test -n "$PYTHON2_CONFIG"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $PYTHON2_CONFIG" >&5
+$as_echo "$PYTHON2_CONFIG" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+fi
+if test -z "$ac_cv_path_PYTHON2_CONFIG"; then
+  ac_pt_PYTHON2_CONFIG=$PYTHON2_CONFIG
+  # Extract the first word of "python2-config", so it can be a program name with args.
+set dummy python2-config; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_ac_pt_PYTHON2_CONFIG+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_PYTHON2_CONFIG in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_PYTHON2_CONFIG="$ac_pt_PYTHON2_CONFIG" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_PYTHON2_CONFIG="$as_dir/$ac_word$ac_exec_ext"
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
+ac_pt_PYTHON2_CONFIG=$ac_cv_path_ac_pt_PYTHON2_CONFIG
+if test -n "$ac_pt_PYTHON2_CONFIG"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_PYTHON2_CONFIG" >&5
+$as_echo "$ac_pt_PYTHON2_CONFIG" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
 
+  if test "x$ac_pt_PYTHON2_CONFIG" = x; then
+    PYTHON2_CONFIG=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    PYTHON2_CONFIG=$ac_pt_PYTHON2_CONFIG
+  fi
+else
+  PYTHON2_CONFIG="$ac_cv_path_PYTHON2_CONFIG"
+fi
+
+	test -z "$PYTHON2_CONFIG" && as_fn_error $? "python headers are required for --enable-python2_bindings but cannot be found" "$LINENO" 5
+	PYTHON2_INCDIRS=`"$PYTHON2_CONFIG" --includes`
+	PYTHON2_LIBDIRS=`"$PYTHON2_CONFIG" --libs`
+	PYTHON2DIR=$pythondir
+	PYTHON_BINDINGS=yes
+fi
+
+if test "$PYTHON3_BINDINGS" = yes -o "$BUILD_LVMDBUSD" = yes; then
+	unset PYTHON PYTHON_CONFIG
+	unset am_cv_pathless_PYTHON ac_cv_path_PYTHON am_cv_python_platform
+	unset am_cv_python_pythondir am_cv_python_version am_cv_python_pyexecdir
+	unset ac_cv_path_PYTHON_CONFIG ac_cv_path_ac_pt_PYTHON_CONFIG
+
+
+
+
+
+
+        if test -n "$PYTHON"; then
+      # If the user set $PYTHON, use it and don't search something else.
+      { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $PYTHON version is >= 3" >&5
+$as_echo_n "checking whether $PYTHON version is >= 3... " >&6; }
+      prog="import sys
+# split strings by '.' and convert to numeric.  Append some zeros
+# because we need at least 4 digits for the hex conversion.
+# map returns an iterator in Python 3.0 and a list in 2.x
+minver = list(map(int, '3'.split('.'))) + [0, 0, 0]
+minverhex = 0
+# xrange is not present in Python 3.0 and range returns an iterator
+for i in list(range(0, 4)): minverhex = (minverhex << 8) + minver[i]
+sys.exit(sys.hexversion < minverhex)"
+  if { echo "$as_me:$LINENO: $PYTHON -c "$prog"" >&5
+   ($PYTHON -c "$prog") >&5 2>&5
+   ac_status=$?
+   echo "$as_me:$LINENO: \$? = $ac_status" >&5
+   (exit $ac_status); }; then :
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+			       as_fn_error $? "Python interpreter is too old" "$LINENO" 5
+fi
+      am_display_PYTHON=$PYTHON
+    else
+      # Otherwise, try each interpreter until we find one that satisfies
+      # VERSION.
+      { $as_echo "$as_me:${as_lineno-$LINENO}: checking for a Python interpreter with version >= 3" >&5
+$as_echo_n "checking for a Python interpreter with version >= 3... " >&6; }
+if ${am_cv_pathless_PYTHON+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+
+	for am_cv_pathless_PYTHON in python python2 python3 python3.3 python3.2 python3.1 python3.0 python2.7  python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0 none; do
+	  test "$am_cv_pathless_PYTHON" = none && break
+	  prog="import sys
+# split strings by '.' and convert to numeric.  Append some zeros
+# because we need at least 4 digits for the hex conversion.
+# map returns an iterator in Python 3.0 and a list in 2.x
+minver = list(map(int, '3'.split('.'))) + [0, 0, 0]
+minverhex = 0
+# xrange is not present in Python 3.0 and range returns an iterator
+for i in list(range(0, 4)): minverhex = (minverhex << 8) + minver[i]
+sys.exit(sys.hexversion < minverhex)"
+  if { echo "$as_me:$LINENO: $am_cv_pathless_PYTHON -c "$prog"" >&5
+   ($am_cv_pathless_PYTHON -c "$prog") >&5 2>&5
+   ac_status=$?
+   echo "$as_me:$LINENO: \$? = $ac_status" >&5
+   (exit $ac_status); }; then :
+  break
+fi
+	done
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $am_cv_pathless_PYTHON" >&5
+$as_echo "$am_cv_pathless_PYTHON" >&6; }
+      # Set $PYTHON to the absolute path of $am_cv_pathless_PYTHON.
+      if test "$am_cv_pathless_PYTHON" = none; then
+	PYTHON=:
+      else
+        # Extract the first word of "$am_cv_pathless_PYTHON", so it can be a program name with args.
+set dummy $am_cv_pathless_PYTHON; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_PYTHON+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $PYTHON in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_PYTHON="$PYTHON" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_PYTHON="$as_dir/$ac_word$ac_exec_ext"
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
+PYTHON=$ac_cv_path_PYTHON
+if test -n "$PYTHON"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $PYTHON" >&5
+$as_echo "$PYTHON" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+      fi
+      am_display_PYTHON=$am_cv_pathless_PYTHON
+    fi
+
+
+  if test "$PYTHON" = :; then
+      as_fn_error $? "no suitable Python interpreter found" "$LINENO" 5
+  else
+
+
+  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $am_display_PYTHON version" >&5
+$as_echo_n "checking for $am_display_PYTHON version... " >&6; }
+if ${am_cv_python_version+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  am_cv_python_version=`$PYTHON -c "import sys; sys.stdout.write(sys.version[:3])"`
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $am_cv_python_version" >&5
+$as_echo "$am_cv_python_version" >&6; }
+  PYTHON_VERSION=$am_cv_python_version
+
+
+
+  PYTHON_PREFIX='${prefix}'
+
+  PYTHON_EXEC_PREFIX='${exec_prefix}'
+
+
+
+  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $am_display_PYTHON platform" >&5
+$as_echo_n "checking for $am_display_PYTHON platform... " >&6; }
+if ${am_cv_python_platform+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  am_cv_python_platform=`$PYTHON -c "import sys; sys.stdout.write(sys.platform)"`
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $am_cv_python_platform" >&5
+$as_echo "$am_cv_python_platform" >&6; }
+  PYTHON_PLATFORM=$am_cv_python_platform
+
+
+  # Just factor out some code duplication.
+  am_python_setup_sysconfig="\
+import sys
+# Prefer sysconfig over distutils.sysconfig, for better compatibility
+# with python 3.x.  See automake bug#10227.
+try:
+    import sysconfig
+except ImportError:
+    can_use_sysconfig = 0
+else:
+    can_use_sysconfig = 1
+# Can't use sysconfig in CPython 2.7, since it's broken in virtualenvs:
+# <https://github.com/pypa/virtualenv/issues/118>
+try:
+    from platform import python_implementation
+    if python_implementation() == 'CPython' and sys.version[:3] == '2.7':
+        can_use_sysconfig = 0
+except ImportError:
+    pass"
+
+
+            { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $am_display_PYTHON script directory" >&5
+$as_echo_n "checking for $am_display_PYTHON script directory... " >&6; }
+if ${am_cv_python_pythondir+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  if test "x$prefix" = xNONE
+     then
+       am_py_prefix=$ac_default_prefix
+     else
+       am_py_prefix=$prefix
+     fi
+     am_cv_python_pythondir=`$PYTHON -c "
+$am_python_setup_sysconfig
+if can_use_sysconfig:
+    sitedir = sysconfig.get_path('purelib', vars={'base':'$am_py_prefix'})
+else:
+    from distutils import sysconfig
+    sitedir = sysconfig.get_python_lib(0, 0, prefix='$am_py_prefix')
+sys.stdout.write(sitedir)"`
+     case $am_cv_python_pythondir in
+     $am_py_prefix*)
+       am__strip_prefix=`echo "$am_py_prefix" | sed 's|.|.|g'`
+       am_cv_python_pythondir=`echo "$am_cv_python_pythondir" | sed "s,^$am__strip_prefix,$PYTHON_PREFIX,"`
+       ;;
+     *)
+       case $am_py_prefix in
+         /usr|/System*) ;;
+         *)
+	  am_cv_python_pythondir=$PYTHON_PREFIX/lib/python$PYTHON_VERSION/site-packages
+	  ;;
+       esac
+       ;;
+     esac
+
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $am_cv_python_pythondir" >&5
+$as_echo "$am_cv_python_pythondir" >&6; }
+  pythondir=$am_cv_python_pythondir
+
+
+
+  pkgpythondir=\${pythondir}/$PACKAGE
+
+
+        { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $am_display_PYTHON extension module directory" >&5
+$as_echo_n "checking for $am_display_PYTHON extension module directory... " >&6; }
+if ${am_cv_python_pyexecdir+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  if test "x$exec_prefix" = xNONE
+     then
+       am_py_exec_prefix=$am_py_prefix
+     else
+       am_py_exec_prefix=$exec_prefix
+     fi
+     am_cv_python_pyexecdir=`$PYTHON -c "
+$am_python_setup_sysconfig
+if can_use_sysconfig:
+    sitedir = sysconfig.get_path('platlib', vars={'platbase':'$am_py_prefix'})
+else:
+    from distutils import sysconfig
+    sitedir = sysconfig.get_python_lib(1, 0, prefix='$am_py_prefix')
+sys.stdout.write(sitedir)"`
+     case $am_cv_python_pyexecdir in
+     $am_py_exec_prefix*)
+       am__strip_prefix=`echo "$am_py_exec_prefix" | sed 's|.|.|g'`
+       am_cv_python_pyexecdir=`echo "$am_cv_python_pyexecdir" | sed "s,^$am__strip_prefix,$PYTHON_EXEC_PREFIX,"`
+       ;;
+     *)
+       case $am_py_exec_prefix in
+         /usr|/System*) ;;
+         *)
+	   am_cv_python_pyexecdir=$PYTHON_EXEC_PREFIX/lib/python$PYTHON_VERSION/site-packages
+	   ;;
+       esac
+       ;;
+     esac
+
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $am_cv_python_pyexecdir" >&5
+$as_echo "$am_cv_python_pyexecdir" >&6; }
+  pyexecdir=$am_cv_python_pyexecdir
+
+
+
+  pkgpyexecdir=\${pyexecdir}/$PACKAGE
+
+
+
+  fi
+
+
+	PYTHON3=$PYTHON
+	test -z "$PYTHON3" && as_fn_error $? "python3 is required for --enable-python3_bindings or --enable-dbus-service but cannot be found" "$LINENO" 5
 	if test -n "$ac_tool_prefix"; then
-  # Extract the first word of "${ac_tool_prefix}python-config", so it can be a program name with args.
-set dummy ${ac_tool_prefix}python-config; ac_word=$2
+  # Extract the first word of "${ac_tool_prefix}python3-config", so it can be a program name with args.
+set dummy ${ac_tool_prefix}python3-config; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_PYTHON_CONFIG+:} false; then :
+if ${ac_cv_path_PYTHON3_CONFIG+:} false; then :
   $as_echo_n "(cached) " >&6
 else
-  case $PYTHON_CONFIG in
+  case $PYTHON3_CONFIG in
   [\\/]* | ?:[\\/]*)
-  ac_cv_path_PYTHON_CONFIG="$PYTHON_CONFIG" # Let the user override the test with a path.
+  ac_cv_path_PYTHON3_CONFIG="$PYTHON3_CONFIG" # Let the user override the test with a path.
   ;;
   *)
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
@@ -12322,7 +13122,7 @@ do
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
   if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_PYTHON_CONFIG="$as_dir/$ac_word$ac_exec_ext"
+    ac_cv_path_PYTHON3_CONFIG="$as_dir/$ac_word$ac_exec_ext"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
   fi
@@ -12333,10 +13133,10 @@ IFS=$as_save_IFS
   ;;
 esac
 fi
-PYTHON_CONFIG=$ac_cv_path_PYTHON_CONFIG
-if test -n "$PYTHON_CONFIG"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $PYTHON_CONFIG" >&5
-$as_echo "$PYTHON_CONFIG" >&6; }
+PYTHON3_CONFIG=$ac_cv_path_PYTHON3_CONFIG
+if test -n "$PYTHON3_CONFIG"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $PYTHON3_CONFIG" >&5
+$as_echo "$PYTHON3_CONFIG" >&6; }
 else
   { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
 $as_echo "no" >&6; }
@@ -12344,18 +13144,18 @@ fi
 
 
 fi
-if test -z "$ac_cv_path_PYTHON_CONFIG"; then
-  ac_pt_PYTHON_CONFIG=$PYTHON_CONFIG
-  # Extract the first word of "python-config", so it can be a program name with args.
-set dummy python-config; ac_word=$2
+if test -z "$ac_cv_path_PYTHON3_CONFIG"; then
+  ac_pt_PYTHON3_CONFIG=$PYTHON3_CONFIG
+  # Extract the first word of "python3-config", so it can be a program name with args.
+set dummy python3-config; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_ac_pt_PYTHON_CONFIG+:} false; then :
+if ${ac_cv_path_ac_pt_PYTHON3_CONFIG+:} false; then :
   $as_echo_n "(cached) " >&6
 else
-  case $ac_pt_PYTHON_CONFIG in
+  case $ac_pt_PYTHON3_CONFIG in
   [\\/]* | ?:[\\/]*)
-  ac_cv_path_ac_pt_PYTHON_CONFIG="$ac_pt_PYTHON_CONFIG" # Let the user override the test with a path.
+  ac_cv_path_ac_pt_PYTHON3_CONFIG="$ac_pt_PYTHON3_CONFIG" # Let the user override the test with a path.
   ;;
   *)
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
@@ -12365,7 +13165,7 @@ do
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
   if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
-    ac_cv_path_ac_pt_PYTHON_CONFIG="$as_dir/$ac_word$ac_exec_ext"
+    ac_cv_path_ac_pt_PYTHON3_CONFIG="$as_dir/$ac_word$ac_exec_ext"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
   fi
@@ -12376,17 +13176,17 @@ IFS=$as_save_IFS
   ;;
 esac
 fi
-ac_pt_PYTHON_CONFIG=$ac_cv_path_ac_pt_PYTHON_CONFIG
-if test -n "$ac_pt_PYTHON_CONFIG"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_PYTHON_CONFIG" >&5
-$as_echo "$ac_pt_PYTHON_CONFIG" >&6; }
+ac_pt_PYTHON3_CONFIG=$ac_cv_path_ac_pt_PYTHON3_CONFIG
+if test -n "$ac_pt_PYTHON3_CONFIG"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_PYTHON3_CONFIG" >&5
+$as_echo "$ac_pt_PYTHON3_CONFIG" >&6; }
 else
   { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
 $as_echo "no" >&6; }
 fi
 
-  if test "x$ac_pt_PYTHON_CONFIG" = x; then
-    PYTHON_CONFIG=""
+  if test "x$ac_pt_PYTHON3_CONFIG" = x; then
+    PYTHON3_CONFIG=""
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
@@ -12394,16 +13194,87 @@ yes:)
 $as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
 ac_tool_warned=yes ;;
 esac
-    PYTHON_CONFIG=$ac_pt_PYTHON_CONFIG
+    PYTHON3_CONFIG=$ac_pt_PYTHON3_CONFIG
   fi
 else
-  PYTHON_CONFIG="$ac_cv_path_PYTHON_CONFIG"
+  PYTHON3_CONFIG="$ac_cv_path_PYTHON3_CONFIG"
+fi
+
+	test -z "$PYTHON3_CONFIG" && as_fn_error $? "python3 headers are required for --enable-python3_bindings or --enable-dbus-service but cannot be found" "$LINENO" 5
+	PYTHON3_INCDIRS=`"$PYTHON3_CONFIG" --includes`
+	PYTHON3_LIBDIRS=`"$PYTHON3_CONFIG" --libs`
+	PYTHON3DIR=$pythondir
+	PYTHON_BINDINGS=yes
 fi
 
-	test -z "$PYTHON_CONFIG" && as_fn_error $? "python headers are required for --enable-python_bindings but cannot be found" "$LINENO" 5
+if test "$BUILD_LVMDBUSD" = yes; then
+	# To get this macro, install autoconf-archive package then run autoreconf
 
-	PYTHON_INCDIRS=`"$PYTHON_CONFIG" --includes`
-	PYTHON_LIBDIRS=`"$PYTHON_CONFIG" --libs`
+    if test -z $PYTHON;
+    then
+        if test -z "python3";
+        then
+            PYTHON="python3"
+        else
+            PYTHON="python3"
+        fi
+    fi
+    PYTHON_NAME=`basename $PYTHON`
+    { $as_echo "$as_me:${as_lineno-$LINENO}: checking $PYTHON_NAME module: pyudev" >&5
+$as_echo_n "checking $PYTHON_NAME module: pyudev... " >&6; }
+    $PYTHON -c "import pyudev" 2>/dev/null
+    if test $? -eq 0;
+    then
+        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+        eval HAVE_PYMOD_PYUDEV=yes
+    else
+        { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+        eval HAVE_PYMOD_PYUDEV=no
+        #
+        if test -n "Required"
+        then
+            as_fn_error $? "failed to find required module pyudev" "$LINENO" 5
+            exit 1
+        fi
+    fi
+
+
+    if test -z $PYTHON;
+    then
+        if test -z "python3";
+        then
+            PYTHON="python3"
+        else
+            PYTHON="python3"
+        fi
+    fi
+    PYTHON_NAME=`basename $PYTHON`
+    { $as_echo "$as_me:${as_lineno-$LINENO}: checking $PYTHON_NAME module: dbus" >&5
+$as_echo_n "checking $PYTHON_NAME module: dbus... " >&6; }
+    $PYTHON -c "import dbus" 2>/dev/null
+    if test $? -eq 0;
+    then
+        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+        eval HAVE_PYMOD_DBUS=yes
+    else
+        { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+        eval HAVE_PYMOD_DBUS=no
+        #
+        if test -n "Required"
+        then
+            as_fn_error $? "failed to find required module dbus" "$LINENO" 5
+            exit 1
+        fi
+    fi
+
+fi
+
+if test "$PYTHON_BINDINGS" = yes -o "$PYTHON2_BINDINGS" = yes -o "$PYTHON3_BINDINGS" = yes; then
+	test "$APPLIB" != yes && as_fn_error $? "Python_bindings require --enable-applib" "$LINENO" 5
 fi
 
 ################################################################################
@@ -14247,8 +15118,17 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
+
+
+
+
+
+
+
+
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile include/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevm
 apper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_
 systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile include/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile lib
 daemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlock
 ing_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -14956,6 +15836,8 @@ do
     "daemons/dmeventd/plugins/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/mirror/Makefile" ;;
     "daemons/dmeventd/plugins/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/snapshot/Makefile" ;;
     "daemons/dmeventd/plugins/thin/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/thin/Makefile" ;;
+    "daemons/lvmdbusd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmdbusd/Makefile" ;;
+    "daemons/lvmdbusd/path.py") CONFIG_FILES="$CONFIG_FILES daemons/lvmdbusd/path.py" ;;
     "daemons/lvmetad/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmetad/Makefile" ;;
     "daemons/lvmpolld/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmpolld/Makefile" ;;
     "daemons/lvmlockd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmlockd/Makefile" ;;
@@ -14993,12 +15875,14 @@ do
     "scripts/blk_availability_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/blk_availability_systemd_red_hat.service" ;;
     "scripts/clvmd_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/clvmd_init_red_hat" ;;
     "scripts/cmirrord_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/cmirrord_init_red_hat" ;;
+    "scripts/com.redhat.lvmdbus1.service") CONFIG_FILES="$CONFIG_FILES scripts/com.redhat.lvmdbus1.service" ;;
     "scripts/dm_event_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/dm_event_systemd_red_hat.service" ;;
     "scripts/dm_event_systemd_red_hat.socket") CONFIG_FILES="$CONFIG_FILES scripts/dm_event_systemd_red_hat.socket" ;;
     "scripts/lvm2_cluster_activation_red_hat.sh") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_cluster_activation_red_hat.sh" ;;
     "scripts/lvm2_cluster_activation_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_cluster_activation_systemd_red_hat.service" ;;
     "scripts/lvm2_clvmd_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_clvmd_systemd_red_hat.service" ;;
     "scripts/lvm2_cmirrord_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_cmirrord_systemd_red_hat.service" ;;
+    "scripts/lvm2_lvmdbusd_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmdbusd_systemd_red_hat.service" ;;
     "scripts/lvm2_lvmetad_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_init_red_hat" ;;
     "scripts/lvm2_lvmetad_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_systemd_red_hat.service" ;;
     "scripts/lvm2_lvmetad_systemd_red_hat.socket") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_systemd_red_hat.socket" ;;
diff --git a/configure.in b/configure.in
index 73a2dbe..22ba812 100644
--- a/configure.in
+++ b/configure.in
@@ -1,6 +1,6 @@
 ###############################################################################
 ## Copyright (C) 2000-2004 Sistina Software, Inc. All rights reserved.
-## Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
+## Copyright (C) 2004-2016 Red Hat, Inc. All rights reserved.
 ##
 ## This copyrighted material is made available to anyone wishing to use,
 ## modify, copy, or redistribute it subject to the terms and conditions
@@ -11,7 +11,7 @@
 ## Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 ################################################################################
 
-AC_PREREQ(2.61)
+AC_PREREQ(2.69)
 ################################################################################
 dnl -- Process this file with autoconf to produce a configure script.
 AC_INIT
@@ -85,6 +85,7 @@ AC_PROG_MKDIR_P
 AC_PROG_RANLIB
 AC_PATH_TOOL(CFLOW_CMD, cflow)
 AC_PATH_TOOL(CSCOPE_CMD, cscope)
+AC_PATH_TOOL(CHMOD, chmod)
 
 ################################################################################
 dnl -- Check for header files.
@@ -1438,24 +1439,74 @@ test "$CMDLIB" = yes \
   || LVM2CMD_LIB=
 
 ################################################################################
+dnl -- Enable D-Bus service
+AC_MSG_CHECKING(whether to include Python D-Bus support)
+AC_ARG_ENABLE(dbus-service,
+	      AC_HELP_STRING([--enable-dbus-service], [install D-Bus support]),
+	      BUILD_LVMDBUSD=$enableval, BUILD_LVMDBUSD=no)
+AC_MSG_RESULT($BUILD_LVMDBUSD)
+
+################################################################################
 dnl -- Enable Python liblvm2app bindings
 AC_MSG_CHECKING(whether to build Python wrapper for liblvm2app.so)
 AC_ARG_ENABLE(python_bindings,
-	      AC_HELP_STRING([--enable-python_bindings], [build Python applib bindings]),
+	      AC_HELP_STRING([--enable-python_bindings], [build default Python applib bindings]),
 	      PYTHON_BINDINGS=$enableval, PYTHON_BINDINGS=no)
 AC_MSG_RESULT($PYTHON_BINDINGS)
 
+AC_MSG_CHECKING(whether to build Python2 wrapper for liblvm2app.so)
+AC_ARG_ENABLE(python2_bindings,
+	      AC_HELP_STRING([--enable-python2_bindings], [build Python2 applib bindings]),
+	      PYTHON2_BINDINGS=$enableval, PYTHON2_BINDINGS=no)
+AC_MSG_RESULT($PYTHON2_BINDINGS)
+
+
+AC_MSG_CHECKING(whether to build Python3 wrapper for liblvm2app.so)
+AC_ARG_ENABLE(python3_bindings,
+	      AC_HELP_STRING([--enable-python3_bindings], [build Python3 applib bindings]),
+	      PYTHON3_BINDINGS=$enableval, PYTHON3_BINDINGS=no)
+AC_MSG_RESULT($PYTHON3_BINDINGS)
+
 if test "$PYTHON_BINDINGS" = yes; then
-	test "$APPLIB" != yes && AC_MSG_ERROR([--enable-python_bindings requires --enable-applib])
+	AC_MSG_ERROR([--enable-python-bindings is replaced by --enable-python2-bindings and --enable-python3-bindings])
+fi
 
-	AC_PATH_TOOL(PYTHON, python)
-	test -z "$PYTHON" && AC_MSG_ERROR([python is required for --enable-python_bindings but cannot be found])
+if test "$PYTHON2_BINDINGS" = yes; then
+	AM_PATH_PYTHON([2])
+	AC_PATH_TOOL(PYTHON2, python2)
+	test -z "$PYTHON2" && AC_MSG_ERROR([python2 is required for --enable-python2_bindings but cannot be found])
+	AC_PATH_TOOL(PYTHON2_CONFIG, python2-config)
+	test -z "$PYTHON2_CONFIG" && AC_MSG_ERROR([python headers are required for --enable-python2_bindings but cannot be found])
+	PYTHON2_INCDIRS=`"$PYTHON2_CONFIG" --includes`
+	PYTHON2_LIBDIRS=`"$PYTHON2_CONFIG" --libs`
+	PYTHON2DIR=$pythondir
+	PYTHON_BINDINGS=yes
+fi
+	
+if test "$PYTHON3_BINDINGS" = yes -o "$BUILD_LVMDBUSD" = yes; then
+	unset PYTHON PYTHON_CONFIG
+	unset am_cv_pathless_PYTHON ac_cv_path_PYTHON am_cv_python_platform
+	unset am_cv_python_pythondir am_cv_python_version am_cv_python_pyexecdir
+	unset ac_cv_path_PYTHON_CONFIG ac_cv_path_ac_pt_PYTHON_CONFIG
+	AM_PATH_PYTHON([3])
+	PYTHON3=$PYTHON
+	test -z "$PYTHON3" && AC_MSG_ERROR([python3 is required for --enable-python3_bindings or --enable-dbus-service but cannot be found])
+	AC_PATH_TOOL(PYTHON3_CONFIG, python3-config)
+	test -z "$PYTHON3_CONFIG" && AC_MSG_ERROR([python3 headers are required for --enable-python3_bindings or --enable-dbus-service but cannot be found])
+	PYTHON3_INCDIRS=`"$PYTHON3_CONFIG" --includes`
+	PYTHON3_LIBDIRS=`"$PYTHON3_CONFIG" --libs`
+	PYTHON3DIR=$pythondir
+	PYTHON_BINDINGS=yes
+fi
 
-	AC_PATH_TOOL(PYTHON_CONFIG, python-config)
-	test -z "$PYTHON_CONFIG" && AC_MSG_ERROR([python headers are required for --enable-python_bindings but cannot be found])
+if test "$BUILD_LVMDBUSD" = yes; then
+	# To get this macro, install autoconf-archive package then run autoreconf
+	AC_PYTHON_MODULE([pyudev], [Required], python3)
+	AC_PYTHON_MODULE([dbus], [Required], python3)
+fi
 
-	PYTHON_INCDIRS=`"$PYTHON_CONFIG" --includes`
-	PYTHON_LIBDIRS=`"$PYTHON_CONFIG" --libs`
+if test "$PYTHON_BINDINGS" = yes -o "$PYTHON2_BINDINGS" = yes -o "$PYTHON3_BINDINGS" = yes; then
+	test "$APPLIB" != yes && AC_MSG_ERROR([Python_bindings require --enable-applib])
 fi
 
 ################################################################################
@@ -1907,6 +1958,7 @@ AC_SUBST(AWK)
 AC_SUBST(BLKID_PC)
 AC_SUBST(BUILD_CMIRRORD)
 AC_SUBST(BUILD_DMEVENTD)
+AC_SUBST(BUILD_LVMDBUSD)
 AC_SUBST(BUILD_LVMETAD)
 AC_SUBST(BUILD_LVMPOLLD)
 AC_SUBST(BUILD_LVMLOCKD)
@@ -1915,6 +1967,7 @@ AC_SUBST(BUILD_LOCKDDLM)
 AC_SUBST(CACHE)
 AC_SUBST(CFLAGS)
 AC_SUBST(CFLOW_CMD)
+AC_SUBST(CHMOD)
 AC_SUBST(CLDFLAGS)
 AC_SUBST(CLDNOWHOLEARCHIVE)
 AC_SUBST(CLDWHOLEARCHIVE)
@@ -1991,10 +2044,17 @@ AC_SUBST(PKGCONFIG)
 AC_SUBST(POOL)
 AC_SUBST(M_LIBS)
 AC_SUBST(PTHREAD_LIBS)
-AC_SUBST(PYTHON)
+AC_SUBST(PYTHON2)
+AC_SUBST(PYTHON3)
 AC_SUBST(PYTHON_BINDINGS)
-AC_SUBST(PYTHON_INCDIRS)
-AC_SUBST(PYTHON_LIBDIRS)
+AC_SUBST(PYTHON2_BINDINGS)
+AC_SUBST(PYTHON3_BINDINGS)
+AC_SUBST(PYTHON2_INCDIRS)
+AC_SUBST(PYTHON3_INCDIRS)
+AC_SUBST(PYTHON2_LIBDIRS)
+AC_SUBST(PYTHON3_LIBDIRS)
+AC_SUBST(PYTHON2DIR)
+AC_SUBST(PYTHON3DIR)
 AC_SUBST(QUORUM_CFLAGS)
 AC_SUBST(QUORUM_LIBS)
 AC_SUBST(RAID)
@@ -2066,6 +2126,8 @@ daemons/dmeventd/plugins/raid/Makefile
 daemons/dmeventd/plugins/mirror/Makefile
 daemons/dmeventd/plugins/snapshot/Makefile
 daemons/dmeventd/plugins/thin/Makefile
+daemons/lvmdbusd/Makefile
+daemons/lvmdbusd/path.py
 daemons/lvmetad/Makefile
 daemons/lvmpolld/Makefile
 daemons/lvmlockd/Makefile
@@ -2103,12 +2165,14 @@ scripts/blk_availability_init_red_hat
 scripts/blk_availability_systemd_red_hat.service
 scripts/clvmd_init_red_hat
 scripts/cmirrord_init_red_hat
+scripts/com.redhat.lvmdbus1.service
 scripts/dm_event_systemd_red_hat.service
 scripts/dm_event_systemd_red_hat.socket
 scripts/lvm2_cluster_activation_red_hat.sh
 scripts/lvm2_cluster_activation_systemd_red_hat.service
 scripts/lvm2_clvmd_systemd_red_hat.service
 scripts/lvm2_cmirrord_systemd_red_hat.service
+scripts/lvm2_lvmdbusd_systemd_red_hat.service
 scripts/lvm2_lvmetad_init_red_hat
 scripts/lvm2_lvmetad_systemd_red_hat.service
 scripts/lvm2_lvmetad_systemd_red_hat.socket
diff --git a/daemons/Makefile.in b/daemons/Makefile.in
index bbe75aa..2d43278 100644
--- a/daemons/Makefile.in
+++ b/daemons/Makefile.in
@@ -44,8 +44,12 @@ ifeq ("@BUILD_LVMLOCKD@", "yes")
   SUBDIRS += lvmlockd 
 endif
 
+ifeq ("@BUILD_LVMDBUSD@", "yes")
+  SUBDIRS += lvmdbusd 
+endif
+
 ifeq ($(MAKECMDGOALS),distclean)
-  SUBDIRS = clvmd cmirrord dmeventd lvmetad lvmpolld lvmlockd
+  SUBDIRS = clvmd cmirrord dmeventd lvmetad lvmpolld lvmlockd lvmdbusd
 endif
 
 include $(top_builddir)/make.tmpl
diff --git a/daemons/lvmdbusd/Makefile.in b/daemons/lvmdbusd/Makefile.in
new file mode 100644
index 0000000..6d18564
--- /dev/null
+++ b/daemons/lvmdbusd/Makefile.in
@@ -0,0 +1,65 @@
+#
+# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+srcdir = @srcdir@
+top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
+
+lvmdbusdir = $(python3dir)/lvmdbus
+
+LVMDBUS_SRCDIR_FILES = \
+	automatedproperties.py \
+	background.py \
+	cfg.py \
+	cmdhandler.py \
+	fetch.py \
+	__init__.py \
+	job.py \
+	loader.py \
+	lvmdb.py \
+	lvmdbus.py \
+	lvm_shell_proxy.py \
+	lv.py \
+	manager.py \
+	objectmanager.py \
+	pv.py \
+	refresh.py \
+	request.py \
+	state.py \
+	udevwatch.py \
+	utils.py \
+	vg.py
+
+LVMDBUS_BUILDDIR_FILES = \
+	path.py
+
+LVMDBUSD = $(srcdir)/lvmdbusd
+
+include $(top_builddir)/make.tmpl
+
+.PHONY: install_lvmdbusd
+
+install_lvmdbusd:
+	$(INSTALL_DIR) $(sbindir)
+	$(INSTALL_SCRIPT) $(LVMDBUSD) $(sbindir)
+	$(INSTALL_DIR) $(DESTDIR)$(lvmdbusdir)
+	(cd $(srcdir); $(INSTALL_DATA) $(LVMDBUS_SRCDIR_FILES) $(DESTDIR)$(lvmdbusdir))
+	$(INSTALL_DATA) $(LVMDBUS_BUILDDIR_FILES) $(DESTDIR)$(lvmdbusdir)
+	PYTHON=$(PYTHON3) $(PYCOMPILE) --destdir "$(DESTDIR)" --basedir "$(lvmdbusdir)" $(LVMDBUS_SRCDIR_FILES) $(LVMDBUS_BUILDDIR_FILES)
+	$(CHMOD) 755 $(DESTDIR)$(lvmdbusdir)/__pycache__
+	$(CHMOD) 444 $(DESTDIR)$(lvmdbusdir)/__pycache__/*.pyc $(DESTDIR)$(lvmdbusdir)/__pycache__/*.pyo
+
+install_lvm2: install_lvmdbusd
+
+install: install_lvm2
+
diff --git a/daemons/lvmdbusd/__init__.py b/daemons/lvmdbusd/__init__.py
new file mode 100644
index 0000000..b733884
--- /dev/null
+++ b/daemons/lvmdbusd/__init__.py
@@ -0,0 +1,10 @@
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+from .lvmdbus import main
diff --git a/daemons/lvmdbusd/automatedproperties.py b/daemons/lvmdbusd/automatedproperties.py
new file mode 100644
index 0000000..aff920c
--- /dev/null
+++ b/daemons/lvmdbusd/automatedproperties.py
@@ -0,0 +1,175 @@
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+import dbus
+from . import cfg
+from .utils import get_properties, add_properties, get_object_property_diff, \
+	log_debug
+from .state import State
+
+
+# noinspection PyPep8Naming,PyUnresolvedReferences
+class AutomatedProperties(dbus.service.Object):
+	"""
+	This class implements the needed interfaces for:
+	org.freedesktop.DBus.Properties
+
+	Other classes inherit from it to get the same behavior
+	"""
+
+	def __init__(self, object_path, search_method=None):
+		dbus.service.Object.__init__(self, cfg.bus, object_path)
+		self._ap_interface = []
+		self._ap_o_path = object_path
+		self._ap_search_method = search_method
+		self.state = None
+
+	def dbus_object_path(self):
+		return self._ap_o_path
+
+	def emit_data(self):
+		props = {}
+
+		for i in self.interface():
+			props[i] = self.GetAll(i)
+
+		return self._ap_o_path, props
+
+	def set_interface(self, interface):
+		"""
+		With inheritance we can't easily tell what interfaces a class provides
+		so we will have each class that implements an interface tell the
+		base AutomatedProperties what it is they do provide.  This is kind of
+		clunky and perhaps we can figure out a better way to do this later.
+		:param interface:       An interface the object supports
+		:return:
+		"""
+		if interface not in self._ap_interface:
+			self._ap_interface.append(interface)
+
+	# noinspection PyUnusedLocal
+	def interface(self, all_interfaces=False):
+		if all_interfaces:
+			cpy = list(self._ap_interface)
+			cpy.extend(
+				["org.freedesktop.DBus.Introspectable",
+					"org.freedesktop.DBus.Properties"])
+			return cpy
+
+		return self._ap_interface
+
+	# Properties
+	# noinspection PyUnusedLocal
+	@dbus.service.method(dbus_interface=dbus.PROPERTIES_IFACE,
+							in_signature='ss', out_signature='v')
+	def Get(self, interface_name, property_name):
+		value = getattr(self, property_name)
+		# Note: If we get an exception in this handler we won't know about it,
+		# only the side effect of no returned value!
+		log_debug('Get (%s), type (%s), value(%s)' %
+					(property_name, str(type(value)), str(value)))
+		return value
+
+	@dbus.service.method(dbus_interface=dbus.PROPERTIES_IFACE,
+							in_signature='s', out_signature='a{sv}')
+	def GetAll(self, interface_name):
+		if interface_name in self.interface(True):
+			# Using introspection, lets build this dynamically
+			properties = get_properties(self)
+			if interface_name in properties:
+				return properties[interface_name][1]
+			return {}
+		raise dbus.exceptions.DBusException(
+			self._ap_interface,
+			'The object %s does not implement the %s interface'
+			% (self.__class__, interface_name))
+
+	@dbus.service.method(dbus_interface=dbus.PROPERTIES_IFACE,
+							in_signature='ssv')
+	def Set(self, interface_name, property_name, new_value):
+		setattr(self, property_name, new_value)
+		self.PropertiesChanged(interface_name,
+								{property_name: new_value}, [])
+
+	# As dbus-python does not support introspection for properties we will
+	# get the autogenerated xml and then add our wanted properties to it.
+	@dbus.service.method(dbus_interface=dbus.INTROSPECTABLE_IFACE,
+							out_signature='s')
+	def Introspect(self):
+		r = dbus.service.Object.Introspect(self, self._ap_o_path, cfg.bus)
+		# Look at the properties in the class
+		props = get_properties(self)
+
+		for int_f, v in props.items():
+			r = add_properties(r, int_f, v[0])
+
+		return r
+
+	@dbus.service.signal(dbus_interface=dbus.PROPERTIES_IFACE,
+							signature='sa{sv}as')
+	def PropertiesChanged(self, interface_name, changed_properties,
+							invalidated_properties):
+		log_debug(('SIGNAL: PropertiesChanged(%s, %s, %s, %s)' %
+					(str(self._ap_o_path), str(interface_name),
+					str(changed_properties), str(invalidated_properties))))
+
+	def refresh(self, search_key=None, object_state=None):
+		"""
+		Take the values (properties) of an object and update them with what
+		lvm currently has.  You can either fetch the new ones or supply the
+		new state to be updated with
+		:param search_key: The value to use to search for
+		:param object_state: Use this as the new object state
+		"""
+		num_changed = 0
+
+		# If we can't do a lookup, bail now, this happens if we blindly walk
+		# through all dbus objects as some don't have a search method, like
+		# 'Manager' object.
+		if not self._ap_search_method:
+			return
+
+		search = self.lvm_id
+		if search_key:
+			search = search_key
+
+		# Either we have the new object state or we need to go fetch it
+		if object_state:
+			new_state = object_state
+		else:
+			new_state = self._ap_search_method([search])[0]
+			assert isinstance(new_state, State)
+
+		assert new_state
+
+		# When we refresh an object the object identifiers might have changed
+		# because LVM allows the user to change them (name & uuid), thus if
+		# they have changed we need to update the object manager so that
+		# look-ups will happen correctly
+		old_id = self.state.identifiers()
+		new_id = new_state.identifiers()
+		if old_id[0] != new_id[0] or old_id[1] != new_id[1]:
+			cfg.om.lookup_update(self, new_id[0], new_id[1])
+
+		# Grab the properties values, then replace the state of the object
+		# and retrieve the new values
+		# TODO: We need to add locking to prevent concurrent access to the
+		# properties so that a client is not accessing while we are
+		# replacing.
+		o_prop = get_properties(self)
+		self.state = new_state
+		n_prop = get_properties(self)
+
+		changed = get_object_property_diff(o_prop, n_prop)
+
+		if changed:
+			for int_f, v in changed.items():
+				self.PropertiesChanged(int_f, v, [])
+			num_changed += 1
+		return num_changed
diff --git a/daemons/lvmdbusd/background.py b/daemons/lvmdbusd/background.py
new file mode 100644
index 0000000..16ee7a6
--- /dev/null
+++ b/daemons/lvmdbusd/background.py
@@ -0,0 +1,195 @@
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+import threading
+import subprocess
+from . import cfg
+import time
+from .cmdhandler import options_to_cli_args
+import dbus
+from .job import Job, JobState
+from .utils import pv_range_append, pv_dest_ranges
+from .request import RequestEntry
+
+_rlock = threading.RLock()
+_thread_list = list()
+
+
+def pv_move_lv_cmd(move_options, lv_full_name,
+					pv_source, pv_source_range, pv_dest_range_list):
+	cmd = ['pvmove', '-i', '1']
+	cmd.extend(options_to_cli_args(move_options))
+
+	if lv_full_name:
+		cmd.extend(['-n', lv_full_name])
+
+	pv_range_append(cmd, pv_source, *pv_source_range)
+	pv_dest_ranges(cmd, pv_dest_range_list)
+
+	return cmd
+
+
+def lv_merge_cmd(merge_options, lv_full_name):
+	cmd = ['lvconvert', '--merge', '-i', '1']
+	cmd.extend(options_to_cli_args(merge_options))
+	cmd.append(lv_full_name)
+	return cmd
+
+
+def _create_background_dbus_job(job_state):
+	job_obj = Job(None, job_state)
+	cfg.om.register_object(job_obj)
+	return job_obj.dbus_object_path()
+
+
+def _move_merge(interface_name, cmd, time_out, skip_first_line=False):
+	# Create job object to be used while running the command
+	rc = '/'
+	job_state = JobState(None)
+	add(cmd, job_state, skip_first_line)
+
+	if time_out == -1:
+		# Waiting forever
+		done = job_state.Wait(time_out)
+		if not done:
+			ec, err_msg = job_state.GetError
+			raise dbus.exceptions.DBusException(
+				interface_name,
+				'Exit code %s, stderr = %s' % (str(ec), err_msg))
+	elif time_out == 0:
+		# Immediately create and return a job
+		rc = _create_background_dbus_job(job_state)
+	else:
+		# Willing to wait for a bit
+		done = job_state.Wait(time_out)
+		if not done:
+			rc = _create_background_dbus_job(job_state)
+
+	return rc
+
+
+def move(interface_name, lv_name, pv_src_obj, pv_source_range,
+			pv_dests_and_ranges, move_options, time_out):
+	"""
+	Common code for the pvmove handling.
+	:param interface_name:  What dbus interface we are providing for
+	:param lv_name:     Optional (None or name of LV to move)
+	:param pv_src_obj:  dbus object patch for source PV
+	:param pv_source_range: (0,0 to ignore, else start, end segments)
+	:param pv_dests_and_ranges: Array of PV object paths and start/end segs
+	:param move_options: Hash with optional arguments
+	:param time_out:
+	:return: Object path to job object
+	"""
+	pv_dests = []
+	pv_src = cfg.om.get_object_by_path(pv_src_obj)
+	if pv_src:
+
+		# Check to see if we are handling a move to a specific
+		# destination(s)
+		if len(pv_dests_and_ranges):
+			for pr in pv_dests_and_ranges:
+				pv_dbus_obj = cfg.om.get_object_by_path(pr[0])
+				if not pv_dbus_obj:
+					raise dbus.exceptions.DBusException(
+						interface_name,
+						'PV Destination (%s) not found' % pr[0])
+
+				pv_dests.append((pv_dbus_obj.lvm_id, pr[1], pr[2]))
+
+		# Generate the command line for this command, but don't
+		# execute it.
+		cmd = pv_move_lv_cmd(move_options,
+								lv_name,
+								pv_src.lvm_id,
+								pv_source_range,
+								pv_dests)
+
+		return _move_merge(interface_name, cmd, time_out)
+	else:
+		raise dbus.exceptions.DBusException(
+			interface_name, 'pv_src_obj (%s) not found' % pv_src_obj)
+
+
+def merge(interface_name, lv_uuid, lv_name, merge_options, time_out):
+	# Make sure we have a dbus object representing it
+	dbo = cfg.om.get_object_by_uuid_lvm_id(lv_uuid, lv_name)
+	if dbo:
+		cmd = lv_merge_cmd(merge_options, dbo.lvm_id)
+		return _move_merge(interface_name, cmd, time_out, True)
+	else:
+		raise dbus.exceptions.DBusException(
+			interface_name,
+			'LV with uuid %s and name %s not present!' % (lv_uuid, lv_name))
+
+
+def background_reaper():
+	while cfg.run.value != 0:
+		with _rlock:
+			num_threads = len(_thread_list) - 1
+			if num_threads >= 0:
+				for i in range(num_threads, -1, -1):
+					_thread_list[i].join(0)
+					if not _thread_list[i].is_alive():
+						_thread_list.pop(i)
+
+		time.sleep(3)
+
+
+def process_background_result(job_object, exit_code, error_msg):
+	cfg.load()
+	job_object.set_result(exit_code, error_msg)
+	return None
+
+
+# noinspection PyUnusedLocal
+def empty_cb(disregard):
+	pass
+
+
+def background_execute(command, background_job, skip_first_line=False):
+	process = subprocess.Popen(command, stdout=subprocess.PIPE,
+								stderr=subprocess.PIPE, close_fds=True)
+	lines_iterator = iter(process.stdout.readline, b"")
+	for line in lines_iterator:
+		# Merge ouputs a line before updates, move does not
+		if skip_first_line:
+			skip_first_line = False
+			continue
+
+		if len(line) > 10:
+			(device, ignore, percentage) = line.decode("utf-8").split(':')
+			background_job.Percent = round(float(percentage.strip()[:-1]), 1)
+
+	out = process.communicate()
+
+	# print "DEBUG: EC %d, STDOUT %s, STDERR %s" % \
+	#      (process.returncode, out[0], out[1])
+
+	if process.returncode == 0:
+		background_job.Percent = 100
+
+	# Queue up the result so that it gets executed in same thread as others.
+	r = RequestEntry(
+		-1, process_background_result,
+		(background_job, process.returncode, out[1]),
+		empty_cb, empty_cb, False)
+	cfg.worker_q.put(r)
+
+
+def add(command, reporting_job, skip_first_line=False):
+	# Create the thread, get it running and then add it to the list
+	t = threading.Thread(
+		target=background_execute,
+		name="thread: " + ' '.join(command),
+		args=(command, reporting_job, skip_first_line))
+	t.start()
+
+	with _rlock:
+		_thread_list.append(t)
diff --git a/daemons/lvmdbusd/cfg.py b/daemons/lvmdbusd/cfg.py
new file mode 100644
index 0000000..bde6a64
--- /dev/null
+++ b/daemons/lvmdbusd/cfg.py
@@ -0,0 +1,80 @@
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+import os
+import multiprocessing
+import queue
+import itertools
+try:
+	from . import path
+except SystemError:
+	import path
+
+LVM_CMD = os.getenv('LVM_BINARY', path.LVM_BINARY)
+
+# This is the global object manager
+om = None
+
+# This is the global bus connection
+bus = None
+
+# Shared state variable across all processes
+run = multiprocessing.Value('i', 1)
+
+# Debug
+DEBUG = True
+
+# Use lvm shell
+USE_SHELL = False
+
+# Lock used by pprint
+stdout_lock = multiprocessing.Lock()
+
+kick_q = multiprocessing.Queue()
+worker_q = queue.Queue()
+
+# Main event loop
+loop = None
+
+BASE_INTERFACE = 'com.redhat.lvmdbus1'
+PV_INTERFACE = BASE_INTERFACE + '.Pv'
+VG_INTERFACE = BASE_INTERFACE + '.Vg'
+LV_INTERFACE = BASE_INTERFACE + '.Lv'
+LV_COMMON_INTERFACE = BASE_INTERFACE + '.LvCommon'
+THIN_POOL_INTERFACE = BASE_INTERFACE + '.ThinPool'
+CACHE_POOL_INTERFACE = BASE_INTERFACE + '.CachePool'
+LV_CACHED = BASE_INTERFACE + '.CachedLv'
+SNAPSHOT_INTERFACE = BASE_INTERFACE + '.Snapshot'
+MANAGER_INTERFACE = BASE_INTERFACE + '.Manager'
+JOB_INTERFACE = BASE_INTERFACE + '.Job'
+
+BASE_OBJ_PATH = '/' + BASE_INTERFACE.replace('.', '/')
+PV_OBJ_PATH = BASE_OBJ_PATH + '/Pv'
+VG_OBJ_PATH = BASE_OBJ_PATH + '/Vg'
+LV_OBJ_PATH = BASE_OBJ_PATH + '/Lv'
+THIN_POOL_PATH = BASE_OBJ_PATH + "/ThinPool"
+CACHE_POOL_PATH = BASE_OBJ_PATH + "/CachePool"
+HIDDEN_LV_PATH = BASE_OBJ_PATH + "/HiddenLv"
+MANAGER_OBJ_PATH = BASE_OBJ_PATH + '/Manager'
+JOB_OBJ_PATH = BASE_OBJ_PATH + '/Job'
+
+# Counters for object path generation
+pv_id = itertools.count()
+vg_id = itertools.count()
+lv_id = itertools.count()
+thin_id = itertools.count()
+cache_pool_id = itertools.count()
+job_id = itertools.count()
+hidden_lv = itertools.count()
+
+# Used to prevent circular imports...
+load = None
+
+# Global cached state
+db = None
diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
new file mode 100644
index 0000000..83feb0a
--- /dev/null
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -0,0 +1,619 @@
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+from subprocess import Popen, PIPE
+import time
+import threading
+from itertools import chain
+
+try:
+	from . import cfg
+	from .utils import pv_dest_ranges, log_debug, log_error
+	from .lvm_shell_proxy import LVMShellProxy
+except SystemError:
+	import cfg
+	from utils import pv_dest_ranges, log_debug, log_error
+	from lvm_shell_proxy import LVMShellProxy
+
+SEP = '{|}'
+
+total_time = 0.0
+total_count = 0
+
+# We need to prevent different threads from using the same lvm shell
+# at the same time.
+cmd_lock = threading.Lock()
+
+# The actual method which gets called to invoke the lvm command, can vary
+# from forking a new process to using lvm shell
+_t_call = None
+
+
+def _debug_c(cmd, exit_code, out):
+	log_error('CMD= %s' % ' '.join(cmd))
+	log_error(("EC= %d" % exit_code))
+	log_error(("STDOUT=\n %s\n" % out[0]))
+	log_error(("STDERR=\n %s\n" % out[1]))
+
+
+def call_lvm(command, debug=False):
+	"""
+	Call an executable and return a tuple of exitcode, stdout, stderr
+	:param command:     Command to execute
+	:param debug:       Dump debug to stdout
+	"""
+	# print 'STACK:'
+	# for line in traceback.format_stack():
+	#    print line.strip()
+
+	# Prepend the full lvm executable so that we can run different versions
+	# in different locations on the same box
+	command.insert(0, cfg.LVM_CMD)
+
+	process = Popen(command, stdout=PIPE, stderr=PIPE, close_fds=True)
+	out = process.communicate()
+
+	stdout_text = bytes(out[0]).decode("utf-8")
+	stderr_text = bytes(out[1]).decode("utf-8")
+
+	if debug or process.returncode != 0:
+		_debug_c(command, process.returncode, (stdout_text, stderr_text))
+
+	if process.returncode == 0:
+		if cfg.DEBUG and out[1] and len(out[1]):
+			log_error('WARNING: lvm is out-putting text to STDERR on success!')
+			_debug_c(command, process.returncode, (stdout_text, stderr_text))
+
+	return process.returncode, stdout_text, stderr_text
+
+
+def _shell_cfg():
+	global _t_call
+	log_debug('Using lvm shell!')
+	lvm_shell = LVMShellProxy()
+	_t_call = lvm_shell.call_lvm
+
+
+if cfg.USE_SHELL:
+	_shell_cfg()
+else:
+	_t_call = call_lvm
+
+
+def set_execution(shell):
+	global _t_call
+	with cmd_lock:
+		_t_call = None
+		if shell:
+			log_debug('Using lvm shell!')
+			lvm_shell = LVMShellProxy()
+			_t_call = lvm_shell.call_lvm
+		else:
+			_t_call = call_lvm
+
+
+def time_wrapper(command, debug=False):
+	global total_time
+	global total_count
+
+	with cmd_lock:
+		start = time.time()
+		results = _t_call(command, debug)
+		total_time += (time.time() - start)
+		total_count += 1
+
+	return results
+
+
+call = time_wrapper
+
+
+# Default cmd
+# Place default arguments for every command here.
+def _dc(cmd, args):
+	c = [cmd, '--noheading', '--separator', '%s' % SEP, '--nosuffix',
+		'--unbuffered', '--units', 'b']
+	c.extend(args)
+	return c
+
+
+def parse(out):
+	rc = []
+
+	for line in out.split('\n'):
+		# This line includes separators, so process them
+		if SEP in line:
+			elem = line.split(SEP)
+			cleaned_elem = []
+			for e in elem:
+				e = e.strip()
+				cleaned_elem.append(e)
+
+			if len(cleaned_elem) > 1:
+				rc.append(cleaned_elem)
+		else:
+			t = line.strip()
+			if len(t) > 0:
+				rc.append(t)
+	return rc
+
+
+def parse_column_names(out, column_names):
+	lines = parse(out)
+	rc = []
+
+	for i in range(0, len(lines)):
+		d = dict(list(zip(column_names, lines[i])))
+		rc.append(d)
+
+	return rc
+
+
+def options_to_cli_args(options):
+	rc = []
+	for k, v in list(dict(options).items()):
+		if k.startswith("-"):
+			rc.append(k)
+		else:
+			rc.append("--%s" % k)
+		if v != "":
+			rc.append(str(v))
+	return rc
+
+
+def pv_remove(device, remove_options):
+	cmd = ['pvremove']
+	cmd.extend(options_to_cli_args(remove_options))
+	cmd.append(device)
+	return call(cmd)
+
+
+def _tag(operation, what, add, rm, tag_options):
+	cmd = [operation]
+	cmd.extend(options_to_cli_args(tag_options))
+
+	if isinstance(what, list):
+		cmd.extend(what)
+	else:
+		cmd.append(what)
+
+	if add:
+		cmd.extend(list(chain.from_iterable(('--addtag', x) for x in add)))
+	if rm:
+		cmd.extend(list(chain.from_iterable(('--deltag', x) for x in rm)))
+
+	return call(cmd, False)
+
+
+def pv_tag(pv_devices, add, rm, tag_options):
+	return _tag('pvchange', pv_devices, add, rm, tag_options)
+
+
+def vg_tag(vg_name, add, rm, tag_options):
+	return _tag('vgchange', vg_name, add, rm, tag_options)
+
+
+def lv_tag(lv_name, add, rm, tag_options):
+	return _tag('lvchange', lv_name, add, rm, tag_options)
+
+
+def vg_rename(vg, new_name, rename_options):
+	cmd = ['vgrename']
+	cmd.extend(options_to_cli_args(rename_options))
+	cmd.extend([vg, new_name])
+	return call(cmd)
+
+
+def vg_remove(vg_name, remove_options):
+	cmd = ['vgremove']
+	cmd.extend(options_to_cli_args(remove_options))
+	cmd.extend(['-f', vg_name])
+	return call(cmd)
+
+
+def vg_lv_create(vg_name, create_options, name, size_bytes, pv_dests):
+	cmd = ['lvcreate']
+	cmd.extend(options_to_cli_args(create_options))
+	cmd.extend(['--size', str(size_bytes) + 'B'])
+	cmd.extend(['--name', name, vg_name])
+	pv_dest_ranges(cmd, pv_dests)
+	return call(cmd)
+
+
+def vg_lv_snapshot(vg_name, snapshot_options, name, size_bytes):
+	cmd = ['lvcreate']
+	cmd.extend(options_to_cli_args(snapshot_options))
+	cmd.extend(["-s"])
+
+	if size_bytes != 0:
+		cmd.extend(['--size', str(size_bytes) + 'B'])
+
+	cmd.extend(['--name', name, vg_name])
+	return call(cmd)
+
+
+def vg_lv_create_linear(vg_name, create_options, name, size_bytes, thin_pool):
+	cmd = ['lvcreate']
+	cmd.extend(options_to_cli_args(create_options))
+
+	if not thin_pool:
+		cmd.extend(['--size', str(size_bytes) + 'B'])
+	else:
+		cmd.extend(['--thin', '--size', str(size_bytes) + 'B'])
+	cmd.extend(['--name', name, vg_name])
+	return call(cmd)
+
+
+def vg_lv_create_striped(vg_name, create_options, name, size_bytes,
+							num_stripes, stripe_size_kb, thin_pool):
+	cmd = ['lvcreate']
+	cmd.extend(options_to_cli_args(create_options))
+
+	if not thin_pool:
+		cmd.extend(['--size', str(size_bytes) + 'B'])
+	else:
+		cmd.extend(['--thin', '--size', str(size_bytes) + 'B'])
+
+	cmd.extend(['--stripes', str(num_stripes)])
+
+	if stripe_size_kb != 0:
+		cmd.extend(['--stripesize', str(stripe_size_kb)])
+
+	cmd.extend(['--name', name, vg_name])
+	return call(cmd)
+
+
+def _vg_lv_create_raid(vg_name, create_options, name, raid_type, size_bytes,
+						num_stripes, stripe_size_kb):
+	cmd = ['lvcreate']
+
+	cmd.extend(options_to_cli_args(create_options))
+
+	cmd.extend(['--type', raid_type])
+	cmd.extend(['--size', str(size_bytes) + 'B'])
+
+	if num_stripes != 0:
+		cmd.extend(['--stripes', str(num_stripes)])
+
+	if stripe_size_kb != 0:
+		cmd.extend(['--stripesize', str(stripe_size_kb)])
+
+	cmd.extend(['--name', name, vg_name])
+	return call(cmd)
+
+
+def vg_lv_create_raid(vg_name, create_options, name, raid_type, size_bytes,
+						num_stripes, stripe_size_kb):
+	cmd = ['lvcreate']
+	cmd.extend(options_to_cli_args(create_options))
+
+	return _vg_lv_create_raid(vg_name, create_options, name, raid_type,
+								size_bytes, num_stripes, stripe_size_kb)
+
+
+def vg_lv_create_mirror(vg_name, create_options, name, size_bytes, num_copies):
+	cmd = ['lvcreate']
+	cmd.extend(options_to_cli_args(create_options))
+
+	cmd.extend(['--type', 'mirror'])
+	cmd.extend(['--mirrors', str(num_copies)])
+	cmd.extend(['--size', str(size_bytes) + 'B'])
+	cmd.extend(['--name', name, vg_name])
+	return call(cmd)
+
+
+def vg_create_cache_pool(md_full_name, data_full_name, create_options):
+	cmd = ['lvconvert']
+	cmd.extend(options_to_cli_args(create_options))
+	cmd.extend(['--type', 'cache-pool', '--force', '-y',
+				'--poolmetadata', md_full_name, data_full_name])
+	return call(cmd)
+
+
+def vg_create_thin_pool(md_full_name, data_full_name, create_options):
+	cmd = ['lvconvert']
+	cmd.extend(options_to_cli_args(create_options))
+	cmd.extend(['--type', 'thin-pool', '--force', '-y',
+				'--poolmetadata', md_full_name, data_full_name])
+	return call(cmd)
+
+
+def lv_remove(lv_path, remove_options):
+	cmd = ['lvremove']
+	cmd.extend(options_to_cli_args(remove_options))
+	cmd.extend(['-f', lv_path])
+	return call(cmd)
+
+
+def lv_rename(lv_path, new_name, rename_options):
+	cmd = ['lvrename']
+	cmd.extend(options_to_cli_args(rename_options))
+	cmd.extend([lv_path, new_name])
+	return call(cmd)
+
+
+def lv_resize(lv_full_name, size_change, pv_dests,
+				resize_options):
+	cmd = ['lvresize', '--force']
+
+	cmd.extend(options_to_cli_args(resize_options))
+
+	if size_change < 0:
+		cmd.append("-L-%dB" % (-size_change))
+	else:
+		cmd.append("-L+%dB" % (size_change))
+
+	cmd.append(lv_full_name)
+	pv_dest_ranges(cmd, pv_dests)
+	return call(cmd)
+
+
+def lv_lv_create(lv_full_name, create_options, name, size_bytes):
+	cmd = ['lvcreate']
+	cmd.extend(options_to_cli_args(create_options))
+	cmd.extend(['--virtualsize', str(size_bytes) + 'B', '-T'])
+	cmd.extend(['--name', name, lv_full_name])
+	return call(cmd)
+
+
+def lv_cache_lv(cache_pool_full_name, lv_full_name, cache_options):
+	# lvconvert --type cache --cachepool VG/CachePoolLV VG/OriginLV
+	cmd = ['lvconvert']
+	cmd.extend(options_to_cli_args(cache_options))
+	cmd.extend(['--type', 'cache', '--cachepool',
+				cache_pool_full_name, lv_full_name])
+	return call(cmd)
+
+
+def lv_detach_cache(lv_full_name, detach_options, destroy_cache):
+	cmd = ['lvconvert']
+	if destroy_cache:
+		option = '--uncache'
+	else:
+		# Currently fairly dangerous
+		# see: https://bugzilla.redhat.com/show_bug.cgi?id=1248972
+		option = '--splitcache'
+	cmd.extend(options_to_cli_args(detach_options))
+	# needed to prevent interactive questions
+	cmd.extend(["--yes", "--force"])
+	cmd.extend([option, lv_full_name])
+	return call(cmd)
+
+
+def pv_retrieve_with_segs(device=None):
+	d = []
+
+	columns = ['pv_name', 'pv_uuid', 'pv_fmt', 'pv_size', 'pv_free',
+				'pv_used', 'dev_size', 'pv_mda_size', 'pv_mda_free',
+				'pv_ba_start', 'pv_ba_size', 'pe_start', 'pv_pe_count',
+				'pv_pe_alloc_count', 'pv_attr', 'pv_tags', 'vg_name',
+				'vg_uuid', 'pv_seg_start', 'pvseg_size', 'segtype']
+
+	# Lvm has some issues where it returns failure when querying pvs when other
+	# operations are in process, see:
+	# https://bugzilla.redhat.com/show_bug.cgi?id=1274085
+	while True:
+		cmd = _dc('pvs', ['-o', ','.join(columns)])
+
+		if device:
+			cmd.extend(device)
+
+		rc, out, err = call(cmd)
+
+		if rc == 0:
+			d = parse_column_names(out, columns)
+			break
+		else:
+			time.sleep(0.2)
+			log_debug("LVM Bug workaround, retrying pvs command...")
+
+	return d
+
+
+def pv_resize(device, size_bytes, create_options):
+	cmd = ['pvresize']
+
+	cmd.extend(options_to_cli_args(create_options))
+
+	if size_bytes != 0:
+		cmd.extend(['--setphysicalvolumesize', str(size_bytes) + 'B'])
+
+	cmd.extend([device])
+	return call(cmd)
+
+
+def pv_create(create_options, devices):
+	cmd = ['pvcreate', '-ff']
+	cmd.extend(options_to_cli_args(create_options))
+	cmd.extend(devices)
+	return call(cmd)
+
+
+def pv_allocatable(device, yes, allocation_options):
+	yn = 'n'
+
+	if yes:
+		yn = 'y'
+
+	cmd = ['pvchange']
+	cmd.extend(options_to_cli_args(allocation_options))
+	cmd.extend(['-x', yn, device])
+	return call(cmd)
+
+
+def pv_scan(activate, cache, device_paths, major_minors, scan_options):
+	cmd = ['pvscan']
+	cmd.extend(options_to_cli_args(scan_options))
+
+	if activate:
+		cmd.extend(['--activate', "ay"])
+
+	if cache:
+		cmd.append('--cache')
+
+		if len(device_paths) > 0:
+			for d in device_paths:
+				cmd.append(d)
+
+		if len(major_minors) > 0:
+			for mm in major_minors:
+				cmd.append("%s:%s" % (mm))
+
+	return call(cmd)
+
+
+def vg_create(create_options, pv_devices, name):
+	cmd = ['vgcreate']
+	cmd.extend(options_to_cli_args(create_options))
+	cmd.append(name)
+	cmd.extend(pv_devices)
+	return call(cmd)
+
+
+def vg_change(change_options, name):
+	cmd = ['vgchange']
+	cmd.extend(options_to_cli_args(change_options))
+	cmd.append(name)
+	return call(cmd)
+
+
+def vg_reduce(vg_name, missing, pv_devices, reduce_options):
+	cmd = ['vgreduce']
+	cmd.extend(options_to_cli_args(reduce_options))
+
+	if len(pv_devices) == 0:
+		cmd.append('--all')
+	if missing:
+		cmd.append('--removemissing')
+
+	cmd.append(vg_name)
+	cmd.extend(pv_devices)
+	return call(cmd)
+
+
+def vg_extend(vg_name, extend_devices, extend_options):
+	cmd = ['vgextend']
+	cmd.extend(options_to_cli_args(extend_options))
+	cmd.append(vg_name)
+	cmd.extend(extend_devices)
+	return call(cmd)
+
+
+def _vg_value_set(name, arguments, options):
+	cmd = ['vgchange']
+	cmd.extend(options_to_cli_args(options))
+	cmd.append(name)
+	cmd.extend(arguments)
+	return call(cmd)
+
+
+def vg_allocation_policy(vg_name, policy, policy_options):
+	return _vg_value_set(vg_name, ['--alloc', policy], policy_options)
+
+
+def vg_max_pv(vg_name, number, max_options):
+	return _vg_value_set(vg_name, ['--maxphysicalvolumes', str(number)],
+							max_options)
+
+
+def vg_max_lv(vg_name, number, max_options):
+	return _vg_value_set(vg_name, ['-l', str(number)], max_options)
+
+
+def vg_uuid_gen(vg_name, ignore, options):
+	assert ignore is None
+	return _vg_value_set(vg_name, ['--uuid'], options)
+
+
+def activate_deactivate(op, name, activate, control_flags, options):
+	cmd = [op]
+	cmd.extend(options_to_cli_args(options))
+
+	op = '-a'
+
+	if control_flags:
+		# Autoactivation
+		if (1 << 0) & control_flags:
+			op += 'a'
+		# Exclusive locking (Cluster)
+		if (1 << 1) & control_flags:
+			op += 'e'
+
+		# Local node activation
+		if (1 << 2) & control_flags:
+			op += 'l'
+
+		# Activation modes
+		if (1 << 3) & control_flags:
+			cmd.extend(['--activationmode', 'complete'])
+		elif (1 << 4) & control_flags:
+			cmd.extend(['--activationmode', 'partial'])
+
+		# Ignore activation skip
+		if (1 << 5) & control_flags:
+			cmd.append('--ignoreactivationskip')
+
+	if activate:
+		op += 'y'
+	else:
+		op += 'n'
+
+	cmd.append(op)
+	cmd.append(name)
+	return call(cmd)
+
+
+def vg_retrieve(vg_specific):
+	if vg_specific:
+		assert isinstance(vg_specific, list)
+
+	columns = ['vg_name', 'vg_uuid', 'vg_fmt', 'vg_size', 'vg_free',
+				'vg_sysid', 'vg_extent_size', 'vg_extent_count',
+				'vg_free_count', 'vg_profile', 'max_lv', 'max_pv',
+				'pv_count', 'lv_count', 'snap_count', 'vg_seqno',
+				'vg_mda_count', 'vg_mda_free', 'vg_mda_size',
+				'vg_mda_used_count', 'vg_attr', 'vg_tags']
+
+	cmd = _dc('vgs', ['-o', ','.join(columns)])
+
+	if vg_specific:
+		cmd.extend(vg_specific)
+
+	d = []
+	rc, out, err = call(cmd)
+	if rc == 0:
+		d = parse_column_names(out, columns)
+
+	return d
+
+
+def lv_retrieve_with_segments():
+	columns = ['lv_uuid', 'lv_name', 'lv_path', 'lv_size',
+				'vg_name', 'pool_lv_uuid', 'pool_lv', 'origin_uuid',
+				'origin', 'data_percent',
+				'lv_attr', 'lv_tags', 'vg_uuid', 'lv_active', 'data_lv',
+				'metadata_lv', 'seg_pe_ranges', 'segtype', 'lv_parent',
+				'lv_role', 'lv_layout']
+
+	cmd = _dc('lvs', ['-a', '-o', ','.join(columns)])
+	rc, out, err = call(cmd)
+
+	d = []
+
+	if rc == 0:
+		d = parse_column_names(out, columns)
+
+	return d
+
+
+if __name__ == '__main__':
+	pv_data = pv_retrieve_with_segs()
+
+	for p in pv_data:
+		log_debug(str(p))
diff --git a/daemons/lvmdbusd/fetch.py b/daemons/lvmdbusd/fetch.py
new file mode 100644
index 0000000..51f130f
--- /dev/null
+++ b/daemons/lvmdbusd/fetch.py
@@ -0,0 +1,30 @@
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+from .pv import load_pvs
+from .vg import load_vgs
+from .lv import load_lvs
+from . import cfg
+
+
+def load(refresh=True, emit_signal=True, cache_refresh=True, log=True):
+	num_total_changes = 0
+
+	# Go through and load all the PVs, VGs and LVs
+	if cache_refresh:
+		cfg.db.refresh(log)
+
+	num_total_changes += load_pvs(refresh=refresh, emit_signal=emit_signal,
+									cache_refresh=False)[1]
+	num_total_changes += load_vgs(refresh=refresh, emit_signal=emit_signal,
+									cache_refresh=False)[1]
+	num_total_changes += load_lvs(refresh=refresh, emit_signal=emit_signal,
+									cache_refresh=False)[1]
+
+	return num_total_changes
diff --git a/daemons/lvmdbusd/job.py b/daemons/lvmdbusd/job.py
new file mode 100644
index 0000000..b16f8e6
--- /dev/null
+++ b/daemons/lvmdbusd/job.py
@@ -0,0 +1,170 @@
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+from .automatedproperties import AutomatedProperties
+from .utils import job_obj_path_generate
+from . import cfg
+from .cfg import JOB_INTERFACE
+import dbus
+import threading
+
+
+# noinspection PyPep8Naming
+class JobState(object):
+	def __init__(self, request):
+		self.rlock = threading.RLock()
+
+		self._percent = 0
+		self._complete = False
+		self._request = request
+		self._cond = threading.Condition(self.rlock)
+		self._ec = 0
+		self._stderr = ''
+
+		# This is an lvm command that is just taking too long and doesn't
+		# support background operation
+		if self._request:
+			# Faking the percentage when we don't have one
+			self._percent = 1
+
+	@property
+	def Percent(self):
+		with self.rlock:
+			return self._percent
+
+	@Percent.setter
+	def Percent(self, value):
+		with self.rlock:
+			self._percent = value
+
+	@property
+	def Complete(self):
+		with self.rlock:
+			if self._request:
+				self._complete = self._request.is_done()
+				if self._complete:
+					self._percent = 100
+
+			return self._complete
+
+	@Complete.setter
+	def Complete(self, value):
+		with self.rlock:
+			self._complete = value
+			self._cond.notify_all()
+
+	@property
+	def GetError(self):
+		with self.rlock:
+			if self.Complete:
+				if self._request:
+					(rc, error) = self._request.get_errors()
+					return (rc, str(error))
+				else:
+					return (self._ec, self._stderr)
+			else:
+				return (-1, 'Job is not complete!')
+
+	def set_result(self, ec, msg):
+		with self.rlock:
+			self.Complete = True
+			self._ec = ec
+			self._stderr = msg
+
+	def dtor(self):
+		with self.rlock:
+			self._request = None
+
+	def Wait(self, timeout):
+		try:
+			with self._cond:
+				# Check to see if we are done, before we wait
+				if not self.Complete:
+					if timeout != -1:
+						self._cond.wait(timeout)
+					else:
+						self._cond.wait()
+				return self.Complete
+		except RuntimeError:
+			return False
+
+	@property
+	def Result(self):
+		with self.rlock:
+			if self._request:
+				return self._request.result()
+			return '/'
+
+
+# noinspection PyPep8Naming
+class Job(AutomatedProperties):
+	_Percent_meta = ('y', JOB_INTERFACE)
+	_Complete_meta = ('b', JOB_INTERFACE)
+	_Result_meta = ('o', JOB_INTERFACE)
+	_GetError_meta = ('(is)', JOB_INTERFACE)
+
+	def __init__(self, request, job_state=None):
+		super(Job, self).__init__(job_obj_path_generate())
+		self.set_interface(JOB_INTERFACE)
+
+		if job_state:
+			self.state = job_state
+		else:
+			self.state = JobState(request)
+
+	@property
+	def Percent(self):
+		return self.state.Percent
+
+	@Percent.setter
+	def Percent(self, value):
+		self.state.Percent = value
+
+	@property
+	def Complete(self):
+		return self.state.Complete
+
+	@Complete.setter
+	def Complete(self, value):
+		self.state.Complete = value
+
+	@property
+	def GetError(self):
+		return self.state.GetError
+
+	def set_result(self, ec, msg):
+		self.state.set_result(ec, msg)
+
+	@dbus.service.method(dbus_interface=JOB_INTERFACE)
+	def Remove(self):
+		if self.state.Complete:
+			cfg.om.remove_object(self, True)
+			self.state.dtor()
+		else:
+			raise dbus.exceptions.DBusException(
+				JOB_INTERFACE, 'Job is not complete!')
+
+	@dbus.service.method(dbus_interface=JOB_INTERFACE,
+							in_signature='i',
+							out_signature='b')
+	def Wait(self, timeout):
+		return self.state.Wait(timeout)
+
+	@property
+	def Result(self):
+		return self.state.Result
+
+	@property
+	def lvm_id(self):
+		return str(id(self))
+
+	@property
+	def Uuid(self):
+		import uuid
+		return uuid.uuid1()
diff --git a/daemons/lvmdbusd/loader.py b/daemons/lvmdbusd/loader.py
new file mode 100644
index 0000000..f0462ef
--- /dev/null
+++ b/daemons/lvmdbusd/loader.py
@@ -0,0 +1,85 @@
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+from . import cfg
+
+
+def _compare_construction(o_state, new_state):
+	# We need to check to see if the objects would get constructed
+	# the same
+	existing_ctor, existing_path = o_state.creation_signature()
+	new_ctor, new_path = new_state.creation_signature()
+
+	# print("%s == %s and %s == %s" % (str(existing_ctor), str(new_ctor),
+	#      str(existing_path), str(new_path)))
+
+	return ((existing_ctor == new_ctor) and (existing_path == new_path))
+
+
+def common(retrieve, o_type, search_keys,
+			object_path, refresh, emit_signal, cache_refresh):
+	num_changes = 0
+	existing_paths = []
+	rc = []
+
+	if search_keys:
+		assert isinstance(search_keys, list)
+
+	if cache_refresh:
+		cfg.db.refresh()
+
+	objects = retrieve(search_keys, cache_refresh=False)
+
+	# If we are doing a refresh we need to know what we have in memory, what's
+	# in lvm and add those that are new and remove those that are gone!
+	if refresh:
+		existing_paths = cfg.om.object_paths_by_type(o_type)
+
+	for o in objects:
+		# Assume we need to add this one to dbus, unless we are refreshing
+		# and it's already present
+		return_object = True
+
+		if refresh:
+			# We are refreshing all the PVs from LVM, if this one exists
+			# we need to refresh our state.
+			dbus_object = cfg.om.get_object_by_uuid_lvm_id(*o.identifiers())
+
+			if dbus_object:
+				del existing_paths[dbus_object.dbus_object_path()]
+
+				# If the old object state and new object state wouldn't be
+				# created with the same path and same object constructor we
+				# need to remove the old object and construct the new one
+				# instead!
+				if not _compare_construction(dbus_object.state, o):
+					# Remove existing and construct new one
+					cfg.om.remove_object(dbus_object, emit_signal)
+					dbus_object = o.create_dbus_object(None)
+					cfg.om.register_object(dbus_object, emit_signal)
+					num_changes += 1
+				else:
+					num_changes += dbus_object.refresh(object_state=o)
+				return_object = False
+
+		if return_object:
+			dbus_object = o.create_dbus_object(object_path)
+			cfg.om.register_object(dbus_object, emit_signal)
+			rc.append(dbus_object)
+
+		object_path = None
+
+	if refresh:
+		for k in list(existing_paths.keys()):
+			cfg.om.remove_object(cfg.om.get_object_by_path(k), True)
+			num_changes += 1
+
+	num_changes += len(rc)
+
+	return rc, num_changes
diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
new file mode 100644
index 0000000..81ef20c
--- /dev/null
+++ b/daemons/lvmdbusd/lv.py
@@ -0,0 +1,818 @@
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+from .automatedproperties import AutomatedProperties
+
+from . import utils
+from .utils import vg_obj_path_generate
+import dbus
+from . import cmdhandler
+from . import cfg
+from .cfg import LV_INTERFACE, THIN_POOL_INTERFACE, SNAPSHOT_INTERFACE, \
+	LV_COMMON_INTERFACE, CACHE_POOL_INTERFACE, LV_CACHED
+from .request import RequestEntry
+from .utils import n, n32
+from .loader import common
+from .state import State
+from . import background
+from .utils import round_size
+
+
+# noinspection PyUnusedLocal
+def lvs_state_retrieve(selection, cache_refresh=True):
+	rc = []
+
+	if cache_refresh:
+		cfg.db.refresh()
+
+	for l in cfg.db.fetch_lvs(selection):
+		rc.append(LvState(
+			l['lv_uuid'], l['lv_name'],
+			l['lv_path'], n(l['lv_size']),
+			l['vg_name'],
+			l['vg_uuid'], l['pool_lv_uuid'],
+			l['pool_lv'], l['origin_uuid'], l['origin'],
+			n32(l['data_percent']), l['lv_attr'],
+			l['lv_tags'], l['lv_active'], l['data_lv'],
+			l['metadata_lv'], l['segtype'], l['lv_role'],
+			l['lv_layout']))
+	return rc
+
+
+def load_lvs(lv_name=None, object_path=None, refresh=False, emit_signal=False,
+				cache_refresh=True):
+	# noinspection PyUnresolvedReferences
+	return common(
+		lvs_state_retrieve,
+		(LvCommon, Lv, LvThinPool, LvSnapShot),
+		lv_name, object_path, refresh, emit_signal, cache_refresh)
+
+
+# noinspection PyPep8Naming,PyUnresolvedReferences,PyUnusedLocal
+class LvState(State):
+	@staticmethod
+	def _pv_devices(uuid):
+		rc = []
+		for pv in sorted(cfg.db.lv_contained_pv(uuid)):
+			(pv_uuid, pv_name, pv_segs) = pv
+			pv_obj = cfg.om.get_object_path_by_lvm_id(
+				pv_uuid, pv_name, gen_new=False)
+			rc.append((pv_obj, pv_segs))
+
+		return dbus.Array(rc, signature="(oa(tts))")
+
+	def vg_name_lookup(self):
+		return cfg.om.get_object_by_path(self.Vg).Name
+
+	@property
+	def lvm_id(self):
+		return "%s/%s" % (self.vg_name_lookup(), self.Name)
+
+	def identifiers(self):
+		return (self.Uuid, self.lvm_id)
+
+	def _get_hidden_lv(self):
+		rc = dbus.Array([], "o")
+
+		vg_name = self.vg_name_lookup()
+
+		for l in cfg.db.hidden_lvs(self.Uuid):
+			full_name = "%s/%s" % (vg_name, l[1])
+			op = cfg.om.get_object_path_by_lvm_id(
+				l[0], full_name, gen_new=False)
+			assert op
+			rc.append(op)
+		return rc
+
+	def __init__(self, Uuid, Name, Path, SizeBytes,
+			vg_name, vg_uuid, pool_lv_uuid, PoolLv,
+			origin_uuid, OriginLv, DataPercent, Attr, Tags, active,
+			data_lv, metadata_lv, segtypes, role, layout):
+		utils.init_class_from_arguments(self)
+
+		# The segtypes is possibly an array with potentially dupes or a single
+		# value
+		self._segs = dbus.Array([], signature='s')
+		if not isinstance(segtypes, list):
+			self._segs.append(segtypes)
+		else:
+			self._segs.extend(set(segtypes))
+
+		self.Vg = cfg.om.get_object_path_by_lvm_id(
+			vg_uuid, vg_name, vg_obj_path_generate)
+
+		self.Devices = LvState._pv_devices(self.Uuid)
+
+		if PoolLv:
+			gen = utils.lv_object_path_method(Name, (Attr, layout, role))
+
+			self.PoolLv = cfg.om.get_object_path_by_lvm_id(
+				pool_lv_uuid, '%s/%s' % (vg_name, PoolLv),
+				gen)
+		else:
+			self.PoolLv = '/'
+
+		if OriginLv:
+			self.OriginLv = \
+				cfg.om.get_object_path_by_lvm_id(
+					origin_uuid, '%s/%s' % (vg_name, OriginLv),
+					vg_obj_path_generate)
+		else:
+			self.OriginLv = '/'
+
+		self.HiddenLvs = self._get_hidden_lv()
+
+	@property
+	def SegType(self):
+		return self._segs
+
+	def _object_path_create(self):
+		return utils.lv_object_path_method(
+			self.Name, (self.Attr, self.layout, self.role))
+
+	def _object_type_create(self):
+		if self.Name[0] == '[':
+			return LvCommon
+		if self.Attr[0] == 't':
+			return LvThinPool
+		elif self.Attr[0] == 'C':
+			if 'pool' in self.layout:
+				return LvCachePool
+			else:
+				return LvCacheLv
+		elif self.OriginLv != '/':
+			return LvSnapShot
+		else:
+			return Lv
+
+	def create_dbus_object(self, path):
+		if not path:
+			path = cfg.om.get_object_path_by_lvm_id(
+				self.Uuid, self.lvm_id, self._object_path_create())
+
+		obj_ctor = self._object_type_create()
+		return obj_ctor(path, self)
+
+	def creation_signature(self):
+		klass = self._object_type_create()
+		path_method = self._object_path_create()
+		return (klass, path_method)
+
+
+# noinspection PyPep8Naming
+ at utils.dbus_property(LV_COMMON_INTERFACE, 'Uuid', 's')
+ at utils.dbus_property(LV_COMMON_INTERFACE, 'Name', 's')
+ at utils.dbus_property(LV_COMMON_INTERFACE, 'Path', 's')
+ at utils.dbus_property(LV_COMMON_INTERFACE, 'SizeBytes', 't')
+ at utils.dbus_property(LV_COMMON_INTERFACE, 'DataPercent', 'u')
+ at utils.dbus_property(LV_COMMON_INTERFACE, 'SegType', 'as')
+ at utils.dbus_property(LV_COMMON_INTERFACE, 'Vg', 'o')
+ at utils.dbus_property(LV_COMMON_INTERFACE, 'OriginLv', 'o')
+ at utils.dbus_property(LV_COMMON_INTERFACE, 'PoolLv', 'o')
+ at utils.dbus_property(LV_COMMON_INTERFACE, 'Devices', "a(oa(tts))")
+ at utils.dbus_property(LV_COMMON_INTERFACE, 'HiddenLvs', "ao")
+class LvCommon(AutomatedProperties):
+	_Tags_meta = ("as", LV_COMMON_INTERFACE)
+	_IsThinVolume_meta = ("b", LV_COMMON_INTERFACE)
+	_IsThinPool_meta = ("b", LV_COMMON_INTERFACE)
+	_Active_meta = ("b", LV_COMMON_INTERFACE)
+	_VolumeType_meta = ("(ss)", LV_COMMON_INTERFACE)
+	_Permissions_meta = ("(ss)", LV_COMMON_INTERFACE)
+	_AllocationPolicy_meta = ("(ss)", LV_COMMON_INTERFACE)
+	_State_meta = ("(ss)", LV_COMMON_INTERFACE)
+	_TargetType_meta = ("(ss)", LV_COMMON_INTERFACE)
+	_Health_meta = ("(ss)", LV_COMMON_INTERFACE)
+	_FixedMinor_meta = ('b', LV_COMMON_INTERFACE)
+	_ZeroBlocks_meta = ('b', LV_COMMON_INTERFACE)
+	_SkipActivation_meta = ('b', LV_COMMON_INTERFACE)
+
+	# noinspection PyUnusedLocal,PyPep8Naming
+	def __init__(self, object_path, object_state):
+		super(LvCommon, self).__init__(object_path, lvs_state_retrieve)
+		self.set_interface(LV_COMMON_INTERFACE)
+		self.state = object_state
+
+	@property
+	def VolumeType(self):
+		type_map = {'C': 'Cache', 'm': 'mirrored',
+					'M': 'Mirrored without initial sync', 'o': 'origin',
+					'O': 'Origin with merging snapshot', 'r': 'raid',
+					'R': 'Raid without initial sync', 's': 'snapshot',
+					'S': 'merging Snapshot', 'p': 'pvmove',
+					'v': 'virtual', 'i': 'mirror  or  raid  image',
+					'I': 'mirror or raid Image out-of-sync',
+					'l': 'mirror log device', 'c': 'under conversion',
+					'V': 'thin Volume', 't': 'thin pool', 'T': 'Thin pool data',
+					'e': 'raid or pool metadata or pool metadata spare',
+					'-': 'Unspecified'}
+		return (self.state.Attr[0], type_map[self.state.Attr[0]])
+
+	@property
+	def Permissions(self):
+		type_map = {'w': 'writable', 'r': 'read-only',
+					'R': 'Read-only activation of non-read-only volume',
+					'-': 'Unspecified'}
+		return (self.state.Attr[1], type_map[self.state.Attr[1]])
+
+	@property
+	def AllocationPolicy(self):
+		type_map = {'a': 'anywhere', 'A': 'anywhere locked',
+					'c': 'contiguous', 'C': 'contiguous locked',
+					'i': 'inherited', 'I': 'inherited locked',
+					'l': 'cling', 'L': 'cling locked',
+					'n': 'normal', 'N': 'normal locked', '-': 'Unspecified'}
+		return (self.state.Attr[2], type_map[self.state.Attr[2]])
+
+	@property
+	def FixedMinor(self):
+		return self.state.Attr[3] == 'm'
+
+	@property
+	def State(self):
+		type_map = {'a': 'active', 's': 'suspended', 'I': 'Invalid snapshot',
+					'S': 'invalid Suspended snapshot',
+					'm': 'snapshot merge failed',
+					'M': 'suspended snapshot (M)erge failed',
+					'd': 'mapped device present without  tables',
+					'i': 'mapped device present with inactive table',
+					'X': 'unknown', '-': 'Unspecified'}
+		return (self.state.Attr[4], type_map[self.state.Attr[4]])
+
+	@property
+	def TargetType(self):
+		type_map = {'C': 'Cache', 'm': 'mirror', 'r': 'raid',
+					's': 'snapshot', 't': 'thin', 'u': 'unknown',
+					'v': 'virtual', '-': 'Unspecified'}
+		return (self.state.Attr[6], type_map[self.state.Attr[6]])
+
+	@property
+	def ZeroBlocks(self):
+		return self.state.Attr[7] == 'z'
+
+	@property
+	def Health(self):
+		type_map = {'p': 'partial', 'r': 'refresh',
+					'm': 'mismatches', 'w': 'writemostly',
+					'X': 'X unknown', '-': 'Unspecified'}
+		return (self.state.Attr[8], type_map[self.state.Attr[8]])
+
+	@property
+	def SkipActivation(self):
+		return self.state.Attr[9] == 'k'
+
+	def vg_name_lookup(self):
+		return self.state.vg_name_lookup()
+
+	def lv_full_name(self):
+		return "%s/%s" % (self.state.vg_name_lookup(), self.state.Name)
+
+	@property
+	def identifiers(self):
+		return self.state.identifiers
+
+	@property
+	def Tags(self):
+		return utils.parse_tags(self.state.Tags)
+
+	@property
+	def lvm_id(self):
+		return self.state.lvm_id
+
+	@property
+	def IsThinVolume(self):
+		return self.state.Attr[0] == 'V'
+
+	@property
+	def IsThinPool(self):
+		return self.state.Attr[0] == 't'
+
+	@property
+	def Active(self):
+		return self.state.active == "active"
+
+	@dbus.service.method(
+		dbus_interface=LV_COMMON_INTERFACE,
+		in_signature='ia{sv}',
+		out_signature='o')
+	def _Future(self, tmo, open_options):
+		raise dbus.exceptions.DBusException(LV_COMMON_INTERFACE, 'Do not use!')
+
+
+# noinspection PyPep8Naming
+class Lv(LvCommon):
+	# noinspection PyUnusedLocal,PyPep8Naming
+	def __init__(self, object_path, object_state):
+		super(Lv, self).__init__(object_path, object_state)
+		self.set_interface(LV_INTERFACE)
+		self.state = object_state
+
+	@staticmethod
+	def _remove(lv_uuid, lv_name, remove_options):
+		# Make sure we have a dbus object representing it
+		dbo = cfg.om.get_object_by_uuid_lvm_id(lv_uuid, lv_name)
+
+		if dbo:
+			# Remove the LV, if successful then remove from the model
+			rc, out, err = cmdhandler.lv_remove(lv_name, remove_options)
+
+			if rc == 0:
+				cfg.om.remove_object(dbo, True)
+				cfg.load()
+			else:
+				# Need to work on error handling, need consistent
+				raise dbus.exceptions.DBusException(
+					LV_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+		else:
+			raise dbus.exceptions.DBusException(
+				LV_INTERFACE,
+				'LV with uuid %s and name %s not present!' %
+				(lv_uuid, lv_name))
+		return '/'
+
+	@dbus.service.method(
+		dbus_interface=LV_INTERFACE,
+		in_signature='ia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def Remove(self, tmo, remove_options, cb, cbe):
+		r = RequestEntry(
+			tmo, Lv._remove,
+			(self.Uuid, self.lvm_id, remove_options),
+			cb, cbe, False)
+		cfg.worker_q.put(r)
+
+	@staticmethod
+	def _rename(lv_uuid, lv_name, new_name, rename_options):
+		# Make sure we have a dbus object representing it
+		dbo = cfg.om.get_object_by_uuid_lvm_id(lv_uuid, lv_name)
+
+		if dbo:
+			# Rename the logical volume
+			rc, out, err = cmdhandler.lv_rename(lv_name, new_name,
+												rename_options)
+			if rc == 0:
+				cfg.load()
+			else:
+				# Need to work on error handling, need consistent
+				raise dbus.exceptions.DBusException(
+					LV_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+		else:
+			raise dbus.exceptions.DBusException(
+				LV_INTERFACE,
+				'LV with uuid %s and name %s not present!' %
+				(lv_uuid, lv_name))
+		return '/'
+
+	@dbus.service.method(
+		dbus_interface=LV_INTERFACE,
+		in_signature='sia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def Rename(self, name, tmo, rename_options, cb, cbe):
+		r = RequestEntry(
+			tmo, Lv._rename,
+			(self.Uuid, self.lvm_id, name, rename_options),
+			cb, cbe, False)
+		cfg.worker_q.put(r)
+
+	@dbus.service.method(
+		dbus_interface=LV_INTERFACE,
+		in_signature='o(tt)a(ott)ia{sv}',
+		out_signature='o')
+	def Move(self, pv_src_obj, pv_source_range,
+				pv_dests_and_ranges,
+				tmo, move_options):
+		return background.move(
+			LV_INTERFACE, self.lvm_id, pv_src_obj,
+			pv_source_range, pv_dests_and_ranges,
+			move_options, tmo)
+
+	@staticmethod
+	def _snap_shot(lv_uuid, lv_name, name, optional_size,
+			snapshot_options):
+		# Make sure we have a dbus object representing it
+		dbo = cfg.om.get_object_by_uuid_lvm_id(lv_uuid, lv_name)
+
+		if dbo:
+			# If you specify a size you get a 'thick' snapshot even if
+			# it is a thin lv
+			if not dbo.IsThinVolume:
+				if optional_size == 0:
+					# TODO: Should we pick a sane default or force user to
+					# make a decision?
+					space = dbo.SizeBytes / 80
+					remainder = space % 512
+					optional_size = space + 512 - remainder
+
+			rc, out, err = cmdhandler.vg_lv_snapshot(
+				lv_name, snapshot_options, name, optional_size)
+			if rc == 0:
+				return_path = '/'
+				full_name = "%s/%s" % (dbo.vg_name_lookup(), name)
+				lvs = load_lvs([full_name], emit_signal=True)[0]
+				for l in lvs:
+					return_path = l.dbus_object_path()
+
+				# Refresh self and all included PVs
+				cfg.load(cache_refresh=False)
+				return return_path
+			else:
+				raise dbus.exceptions.DBusException(
+					LV_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+		else:
+			raise dbus.exceptions.DBusException(
+				LV_INTERFACE,
+				'LV with uuid %s and name %s not present!' %
+				(lv_uuid, lv_name))
+
+	@dbus.service.method(
+		dbus_interface=LV_INTERFACE,
+		in_signature='stia{sv}',
+		out_signature='(oo)',
+		async_callbacks=('cb', 'cbe'))
+	def Snapshot(self, name, optional_size, tmo,
+			snapshot_options, cb, cbe):
+		r = RequestEntry(
+			tmo, Lv._snap_shot,
+			(self.Uuid, self.lvm_id, name,
+			optional_size, snapshot_options), cb, cbe)
+		cfg.worker_q.put(r)
+
+	@staticmethod
+	def _resize(lv_uuid, lv_name, new_size_bytes, pv_dests_and_ranges,
+				resize_options):
+		# Make sure we have a dbus object representing it
+		pv_dests = []
+		dbo = cfg.om.get_object_by_uuid_lvm_id(lv_uuid, lv_name)
+
+		if dbo:
+			# If we have PVs, verify them
+			if len(pv_dests_and_ranges):
+				for pr in pv_dests_and_ranges:
+					pv_dbus_obj = cfg.om.get_object_by_path(pr[0])
+					if not pv_dbus_obj:
+						raise dbus.exceptions.DBusException(
+							LV_INTERFACE,
+							'PV Destination (%s) not found' % pr[0])
+
+					pv_dests.append((pv_dbus_obj.lvm_id, pr[1], pr[2]))
+
+			size_change = new_size_bytes - dbo.SizeBytes
+
+			rc, out, err = cmdhandler.lv_resize(dbo.lvm_id, size_change,
+												pv_dests, resize_options)
+
+			if rc == 0:
+				# Refresh what's changed
+				cfg.load()
+				return "/"
+			else:
+				raise dbus.exceptions.DBusException(
+					LV_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+		else:
+			raise dbus.exceptions.DBusException(
+				LV_INTERFACE,
+				'LV with uuid %s and name %s not present!' %
+				(lv_uuid, lv_name))
+
+	@dbus.service.method(
+		dbus_interface=LV_INTERFACE,
+		in_signature='ta(ott)ia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def Resize(self, new_size_bytes, pv_dests_and_ranges, tmo,
+			resize_options, cb, cbe):
+		"""
+		Resize a LV
+		:param new_size_bytes: The requested final size in bytes
+		:param pv_dests_and_ranges: An array of pv object paths and src &
+									dst. segment ranges
+		:param tmo: -1 to wait forever, 0 to return job immediately, else
+					number of seconds to wait for operation to complete
+					before getting a job
+		:param resize_options: key/value hash of options
+		:param cb:  Used by framework not client facing API
+		:param cbe: Used by framework not client facing API
+		:return: '/' if complete, else job object path
+		"""
+		r = RequestEntry(
+			tmo, Lv._resize,
+			(self.Uuid, self.lvm_id, round_size(new_size_bytes),
+			pv_dests_and_ranges,
+			resize_options), cb, cbe, return_tuple=False)
+		cfg.worker_q.put(r)
+
+	@staticmethod
+	def _lv_activate_deactivate(uuid, lv_name, activate, control_flags,
+								options):
+		# Make sure we have a dbus object representing it
+		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, lv_name)
+
+		if dbo:
+			rc, out, err = cmdhandler.activate_deactivate(
+				'lvchange', lv_name, activate, control_flags, options)
+			if rc == 0:
+				dbo.refresh()
+				return '/'
+			else:
+				raise dbus.exceptions.DBusException(
+					LV_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+		else:
+			raise dbus.exceptions.DBusException(
+				LV_INTERFACE,
+				'LV with uuid %s and name %s not present!' %
+				(uuid, lv_name))
+
+	@dbus.service.method(
+		dbus_interface=LV_INTERFACE,
+		in_signature='tia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def Activate(self, control_flags, tmo, activate_options, cb, cbe):
+		r = RequestEntry(
+			tmo, Lv._lv_activate_deactivate,
+			(self.state.Uuid, self.state.lvm_id, True,
+			control_flags, activate_options),
+			cb, cbe, return_tuple=False)
+		cfg.worker_q.put(r)
+
+	# noinspection PyProtectedMember
+	@dbus.service.method(
+		dbus_interface=LV_INTERFACE,
+		in_signature='tia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def Deactivate(self, control_flags, tmo, activate_options, cb, cbe):
+		r = RequestEntry(
+			tmo, Lv._lv_activate_deactivate,
+			(self.state.Uuid, self.state.lvm_id, False,
+			control_flags, activate_options),
+			cb, cbe, return_tuple=False)
+		cfg.worker_q.put(r)
+
+	@staticmethod
+	def _add_rm_tags(uuid, lv_name, tags_add, tags_del, tag_options):
+		# Make sure we have a dbus object representing it
+		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, lv_name)
+
+		if dbo:
+
+			rc, out, err = cmdhandler.lv_tag(
+				lv_name, tags_add, tags_del, tag_options)
+			if rc == 0:
+				dbo.refresh()
+				return '/'
+			else:
+				raise dbus.exceptions.DBusException(
+					LV_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+
+		else:
+			raise dbus.exceptions.DBusException(
+				LV_INTERFACE,
+				'LV with uuid %s and name %s not present!' %
+				(uuid, lv_name))
+
+	@dbus.service.method(
+		dbus_interface=LV_INTERFACE,
+		in_signature='asia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def TagsAdd(self, tags, tmo, tag_options, cb, cbe):
+		r = RequestEntry(
+			tmo, Lv._add_rm_tags,
+			(self.state.Uuid, self.state.lvm_id,
+			tags, None, tag_options),
+			cb, cbe, return_tuple=False)
+		cfg.worker_q.put(r)
+
+	@dbus.service.method(
+		dbus_interface=LV_INTERFACE,
+		in_signature='asia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def TagsDel(self, tags, tmo, tag_options, cb, cbe):
+		r = RequestEntry(
+			tmo, Lv._add_rm_tags,
+			(self.state.Uuid, self.state.lvm_id,
+			None, tags, tag_options),
+			cb, cbe, return_tuple=False)
+		cfg.worker_q.put(r)
+
+
+# noinspection PyPep8Naming
+class LvThinPool(Lv):
+	_DataLv_meta = ("o", THIN_POOL_INTERFACE)
+	_MetaDataLv_meta = ("o", THIN_POOL_INTERFACE)
+
+	def _fetch_hidden(self, name):
+
+		# The name is vg/name
+		full_name = "%s/%s" % (self.vg_name_lookup(), name)
+
+		o = cfg.om.get_object_by_lvm_id(full_name)
+		if o:
+			return o.dbus_object_path()
+
+		return '/'
+
+	def _get_data_meta(self):
+
+		# Get the data
+		return (self._fetch_hidden(self.state.data_lv),
+				self._fetch_hidden(self.state.metadata_lv))
+
+	def __init__(self, object_path, object_state):
+		super(LvThinPool, self).__init__(object_path, object_state)
+		self.set_interface(THIN_POOL_INTERFACE)
+		self._data_lv, self._metadata_lv = self._get_data_meta()
+
+	@property
+	def DataLv(self):
+		return self._data_lv
+
+	@property
+	def MetaDataLv(self):
+		return self._metadata_lv
+
+	@staticmethod
+	def _lv_create(lv_uuid, lv_name, name, size_bytes, create_options):
+		# Make sure we have a dbus object representing it
+		dbo = cfg.om.get_object_by_uuid_lvm_id(lv_uuid, lv_name)
+
+		lv_created = '/'
+
+		if dbo:
+			rc, out, err = cmdhandler.lv_lv_create(
+				lv_name, create_options, name, size_bytes)
+			if rc == 0:
+				full_name = "%s/%s" % (dbo.vg_name_lookup(), name)
+				lvs = load_lvs([full_name], emit_signal=True)[0]
+				for l in lvs:
+					lv_created = l.dbus_object_path()
+			else:
+				raise dbus.exceptions.DBusException(
+					LV_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+		else:
+			raise dbus.exceptions.DBusException(
+				LV_INTERFACE,
+				'LV with uuid %s and name %s not present!' %
+				(lv_uuid, lv_name))
+		return lv_created
+
+	@dbus.service.method(
+		dbus_interface=THIN_POOL_INTERFACE,
+		in_signature='stia{sv}',
+		out_signature='(oo)',
+		async_callbacks=('cb', 'cbe'))
+	def LvCreate(self, name, size_bytes, tmo, create_options, cb, cbe):
+		r = RequestEntry(
+			tmo, LvThinPool._lv_create,
+			(self.Uuid, self.lvm_id, name,
+			round_size(size_bytes), create_options), cb, cbe)
+		cfg.worker_q.put(r)
+
+
+# noinspection PyPep8Naming
+class LvCachePool(Lv):
+	def __init__(self, object_path, object_state):
+		super(LvCachePool, self).__init__(object_path, object_state)
+		self.set_interface(CACHE_POOL_INTERFACE)
+
+	@staticmethod
+	def _cache_lv(lv_uuid, lv_name, lv_object_path, cache_options):
+
+		# Make sure we have a dbus object representing cache pool
+		dbo = cfg.om.get_object_by_uuid_lvm_id(lv_uuid, lv_name)
+
+		# Make sure we have dbus object representing lv to cache
+		lv_to_cache = cfg.om.get_object_by_path(lv_object_path)
+
+		if dbo and lv_to_cache:
+			fcn = lv_to_cache.lv_full_name()
+			rc, out, err = cmdhandler.lv_cache_lv(
+				dbo.lv_full_name(), fcn, cache_options)
+			if rc == 0:
+				# When we cache an LV, the cache pool and the lv that is getting
+				# cached need to be removed from the object manager and
+				# re-created as their interfaces have changed!
+				cfg.om.remove_object(dbo, emit_signal=True)
+				cfg.om.remove_object(lv_to_cache, emit_signal=True)
+				cfg.load()
+
+				lv_converted = \
+					cfg.om.get_object_by_lvm_id(fcn).dbus_object_path()
+
+			else:
+				raise dbus.exceptions.DBusException(
+					LV_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+		else:
+			msg = ""
+			if not dbo:
+				dbo += 'CachePool LV with uuid %s and name %s not present!' % \
+					(lv_uuid, lv_name)
+
+			if not lv_to_cache:
+				dbo += 'LV to cache with object path %s not present!' % \
+					(lv_object_path)
+
+			raise dbus.exceptions.DBusException(LV_INTERFACE, msg)
+		return lv_converted
+
+	@dbus.service.method(
+		dbus_interface=CACHE_POOL_INTERFACE,
+		in_signature='oia{sv}',
+		out_signature='(oo)',
+		async_callbacks=('cb', 'cbe'))
+	def CacheLv(self, lv_object, tmo, cache_options, cb, cbe):
+		r = RequestEntry(
+			tmo, LvCachePool._cache_lv,
+			(self.Uuid, self.lvm_id, lv_object,
+			cache_options), cb, cbe)
+		cfg.worker_q.put(r)
+
+
+# noinspection PyPep8Naming
+class LvCacheLv(Lv):
+	_CachePool_meta = ("o", LV_CACHED)
+
+	def __init__(self, object_path, object_state):
+		super(LvCacheLv, self).__init__(object_path, object_state)
+		self.set_interface(LV_CACHED)
+
+	@property
+	def CachePool(self):
+		return self.state.PoolLv
+
+	@staticmethod
+	def _detach_lv(lv_uuid, lv_name, detach_options, destroy_cache):
+		# Make sure we have a dbus object representing cache pool
+		dbo = cfg.om.get_object_by_uuid_lvm_id(lv_uuid, lv_name)
+
+		if dbo:
+
+			# Get current cache name
+			cache_pool = cfg.om.get_object_by_path(dbo.CachePool)
+
+			rc, out, err = cmdhandler.lv_detach_cache(
+				dbo.lv_full_name(), detach_options, destroy_cache)
+			if rc == 0:
+				# The cache pool gets removed as hidden and put back to
+				# visible, so lets delete
+				cfg.om.remove_object(cache_pool, emit_signal=True)
+				cfg.om.remove_object(dbo, emit_signal=True)
+				cfg.load()
+
+				uncached_lv_path = \
+					cfg.om.get_object_by_lvm_id(lv_name).dbus_object_path()
+
+			else:
+				raise dbus.exceptions.DBusException(
+					LV_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+		else:
+			raise dbus.exceptions.DBusException(
+				LV_INTERFACE,
+				'LV with uuid %s and name %s not present!' %
+				(lv_uuid, lv_name))
+		return uncached_lv_path
+
+	@dbus.service.method(
+		dbus_interface=LV_CACHED,
+		in_signature='bia{sv}',
+		out_signature='(oo)',
+		async_callbacks=('cb', 'cbe'))
+	def DetachCachePool(self, destroy_cache, tmo, detach_options, cb, cbe):
+		r = RequestEntry(
+			tmo, LvCacheLv._detach_lv,
+			(self.Uuid, self.lvm_id, detach_options,
+			destroy_cache), cb, cbe)
+		cfg.worker_q.put(r)
+
+
+# noinspection PyPep8Naming
+class LvSnapShot(Lv):
+	def __init__(self, object_path, object_state):
+		super(LvSnapShot, self).__init__(object_path, object_state)
+		self.set_interface(SNAPSHOT_INTERFACE)
+
+	@dbus.service.method(
+		dbus_interface=SNAPSHOT_INTERFACE,
+		in_signature='ia{sv}',
+		out_signature='o')
+	def Merge(self, tmo, merge_options):
+		return background.merge(SNAPSHOT_INTERFACE, self.Uuid, self.lvm_id,
+								merge_options, tmo)
diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py b/daemons/lvmdbusd/lvm_shell_proxy.py
new file mode 100644
index 0000000..3835c74
--- /dev/null
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py
@@ -0,0 +1,184 @@
+#!/usr/bin/env python3
+
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+#
+# Copyright 2015-2016, Vratislav Podzimek <vpodzime@redhat.com>
+
+import subprocess
+import shlex
+from fcntl import fcntl, F_GETFL, F_SETFL
+from os import O_NONBLOCK
+import traceback
+import sys
+import re
+
+try:
+	from .cfg import LVM_CMD
+	from .utils import log_debug, log_error
+except:
+	from cfg import LVM_CMD
+	from utils import log_debug, log_error
+
+SHELL_PROMPT = "lvm> "
+
+
+def _quote_arg(arg):
+	if len(shlex.split(arg)) > 1:
+		return '"%s"' % arg
+	else:
+		return arg
+
+
+class LVMShellProxy(object):
+	def _read_until_prompt(self):
+		prev_ec = None
+		stdout = ""
+		while not stdout.endswith(SHELL_PROMPT):
+			try:
+				tmp = self.lvm_shell.stdout.read()
+				if tmp:
+					stdout += tmp.decode("utf-8")
+			except IOError:
+				# nothing written yet
+				pass
+
+		# strip the prompt from the STDOUT before returning and grab the exit
+		# code if it's available
+		m = self.re.match(stdout)
+		if m:
+			prev_ec = int(m.group(2))
+			strip_idx = -1 * len(m.group(1))
+		else:
+			strip_idx = -1 * len(SHELL_PROMPT)
+
+		return stdout[:strip_idx], prev_ec
+
+	def _read_line(self):
+		while True:
+			try:
+				tmp = self.lvm_shell.stdout.readline()
+				if tmp:
+					return tmp.decode("utf-8")
+			except IOError:
+				pass
+
+	def _discard_echo(self, expected):
+		line = ""
+		while line != expected:
+			# GNU readline inserts some interesting characters at times...
+			line += self._read_line().replace(' \r', '')
+
+	def _write_cmd(self, cmd):
+		cmd_bytes = bytes(cmd, "utf-8")
+		num_written = self.lvm_shell.stdin.write(cmd_bytes)
+		assert (num_written == len(cmd_bytes))
+		self.lvm_shell.stdin.flush()
+
+	def _lvm_echos(self):
+		echo = False
+		cmd = "version\n"
+		self._write_cmd(cmd)
+		line = self._read_line()
+
+		if line == cmd:
+			echo = True
+
+		self._read_until_prompt()
+
+		return echo
+
+	def __init__(self):
+		self.re = re.compile(".*(\[(-?[0-9]+)\] lvm> $)", re.DOTALL)
+
+		# run the lvm shell
+		self.lvm_shell = subprocess.Popen(
+			[LVM_CMD], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
+			stderr=subprocess.PIPE, close_fds=True)
+		flags = fcntl(self.lvm_shell.stdout, F_GETFL)
+		fcntl(self.lvm_shell.stdout, F_SETFL, flags | O_NONBLOCK)
+		flags = fcntl(self.lvm_shell.stderr, F_GETFL)
+		fcntl(self.lvm_shell.stderr, F_SETFL, flags | O_NONBLOCK)
+
+		# wait for the first prompt
+		self._read_until_prompt()
+
+		# Check to see if the version of LVM we are using is running with
+		# gnu readline which will echo our writes from stdin to stdout
+		self.echo = self._lvm_echos()
+
+	def call_lvm(self, argv, debug=False):
+		# create the command string
+		cmd = " ".join(_quote_arg(arg) for arg in argv)
+		cmd += "\n"
+
+		# run the command by writing it to the shell's STDIN
+		self._write_cmd(cmd)
+
+		# If lvm is utilizing gnu readline, it echos stdin to stdout
+		if self.echo:
+			self._discard_echo(cmd)
+
+		# read everything from the STDOUT to the next prompt
+		stdout, exit_code = self._read_until_prompt()
+
+		# read everything from STDERR if there's something (we waited for the
+		# prompt on STDOUT so there should be all or nothing at this point on
+		# STDERR)
+		stderr = None
+		try:
+			t_error = self.lvm_shell.stderr.read()
+			if t_error:
+				stderr = t_error.decode("utf-8")
+		except IOError:
+			# nothing on STDERR
+			pass
+
+		if exit_code is not None:
+			rc = exit_code
+		else:
+			# LVM does write to stderr even when it did complete successfully,
+			# so without having the exit code in the prompt we can never be
+			# sure.
+			if stderr:
+				rc = 1
+			else:
+				rc = 0
+
+		if debug or rc != 0:
+			log_error(('CMD: %s' % cmd))
+			log_error(("EC = %d" % rc))
+			log_error(("STDOUT=\n %s\n" % stdout))
+			log_error(("STDERR=\n %s\n" % stderr))
+
+		return (rc, stdout, stderr)
+
+	def __del__(self):
+		self.lvm_shell.terminate()
+
+
+if __name__ == "__main__":
+	shell = LVMShellProxy()
+	in_line = "start"
+	try:
+		while in_line:
+			in_line = input("lvm> ")
+			if in_line:
+				ret, out, err, = shell.call_lvm(in_line.split())
+				print(("RET: %d" % ret))
+				print(("OUT:\n%s" % out))
+				print(("ERR:\n%s" % err))
+	except KeyboardInterrupt:
+		pass
+	except EOFError:
+		pass
+	except Exception:
+		traceback.print_exc(file=sys.stdout)
+	finally:
+		print()
diff --git a/daemons/lvmdbusd/lvmdb.py b/daemons/lvmdbusd/lvmdb.py
new file mode 100644
index 0000000..46e2099
--- /dev/null
+++ b/daemons/lvmdbusd/lvmdb.py
@@ -0,0 +1,412 @@
+#!/usr/bin/env python3
+
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+from collections import OrderedDict
+
+import pprint as prettyprint
+
+try:
+	from . import cmdhandler
+	from .utils import log_debug
+except SystemError:
+	import cmdhandler
+	from utils import log_debug
+
+
+class DataStore(object):
+	def __init__(self):
+		self.pvs = {}
+		self.vgs = {}
+		self.lvs = {}
+		self.pv_lvs = {}
+		self.lv_pvs = {}
+		self.lvs_hidden = {}
+
+		self.pv_path_to_uuid = {}
+		self.vg_name_to_uuid = {}
+		self.lv_full_name_to_uuid = {}
+
+		self.lvs_in_vgs = {}
+		self.pvs_in_vgs = {}
+
+		# self.refresh()
+		self.num_refreshes = 0
+
+	@staticmethod
+	def _insert_record(table, key, record, allowed_multiple):
+		if key in table:
+			existing = table[key]
+
+			for rec_k, rec_v in record.items():
+				if rec_k in allowed_multiple:
+					# This column name allows us to store multiple value for
+					# each type
+					if not isinstance(existing[rec_k], list):
+						existing_value = existing[rec_k]
+						existing[rec_k] = [existing_value, rec_v]
+					else:
+						existing[rec_k].append(rec_v)
+				else:
+					# If something is not expected to have changing values
+					# lets ensure that
+					if existing[rec_k] != rec_v:
+						raise RuntimeError(
+							"existing[%s]=%s != %s" %
+							(rec_k, str(existing[rec_k]),
+							str(rec_v)))
+		else:
+			table[key] = record
+
+	@staticmethod
+	def _parse_pvs(_pvs):
+		pvs = sorted(_pvs, key=lambda pk: pk['pv_name'])
+
+		c_pvs = OrderedDict()
+		c_lookup = {}
+		c_pvs_in_vgs = {}
+
+		for p in pvs:
+			DataStore._insert_record(
+				c_pvs, p['pv_uuid'], p,
+				['pv_seg_start', 'pvseg_size', 'segtype'])
+
+		for p in c_pvs.values():
+			# Capture which PVs are associated with which VG
+			if p['vg_uuid'] not in c_pvs_in_vgs:
+				c_pvs_in_vgs[p['vg_uuid']] = []
+
+			if p['vg_name']:
+				c_pvs_in_vgs[p['vg_uuid']].append(
+					(p['pv_name'], p['pv_uuid']))
+
+			# Lookup for translating between /dev/<name> and pv uuid
+			c_lookup[p['pv_name']] = p['pv_uuid']
+
+		return c_pvs, c_lookup, c_pvs_in_vgs
+
+	@staticmethod
+	def _parse_vgs(_vgs):
+		vgs = sorted(_vgs, key=lambda vk: vk['vg_name'])
+
+		c_vgs = OrderedDict()
+		c_lookup = {}
+
+		for i in vgs:
+			c_lookup[i['vg_name']] = i['vg_uuid']
+			DataStore._insert_record(c_vgs, i['vg_uuid'], i, [])
+
+		return c_vgs, c_lookup
+
+	@staticmethod
+	def _parse_lvs(_lvs):
+		lvs = sorted(_lvs, key=lambda vk: vk['lv_name'])
+
+		c_lvs = OrderedDict()
+		c_lvs_in_vgs = {}
+		c_lvs_hidden = {}
+		c_lv_full_lookup = {}
+
+		for i in lvs:
+			full_name = "%s/%s" % (i['vg_name'], i['lv_name'])
+			c_lv_full_lookup[full_name] = i['lv_uuid']
+			DataStore._insert_record(
+				c_lvs, i['lv_uuid'], i,
+				['seg_pe_ranges', 'segtype'])
+
+		for i in c_lvs.values():
+			if i['vg_uuid'] not in c_lvs_in_vgs:
+				c_lvs_in_vgs[i['vg_uuid']] = []
+
+			c_lvs_in_vgs[
+				i['vg_uuid']].append(
+					(i['lv_name'],
+					(i['lv_attr'], i['lv_layout'], i['lv_role']),
+					i['lv_uuid']))
+
+			if i['lv_parent']:
+				# Lookup what the parent refers too
+				parent_name = i['lv_parent']
+				full_parent_name = "%s/%s" % (i['vg_name'], parent_name)
+				if full_parent_name not in c_lv_full_lookup:
+					parent_name = '[%s]' % (parent_name)
+					full_parent_name = "%s/%s" % (i['vg_name'], parent_name)
+
+				parent_uuid = c_lv_full_lookup[full_parent_name]
+
+				if parent_uuid not in c_lvs_hidden:
+					c_lvs_hidden[parent_uuid] = []
+
+				c_lvs_hidden[parent_uuid].append(
+					(i['lv_uuid'], i['lv_name']))
+
+		return c_lvs, c_lvs_in_vgs, c_lvs_hidden, c_lv_full_lookup
+
+	@staticmethod
+	def _make_list(l):
+		if not isinstance(l, list):
+			l = [l]
+		return l
+
+	@staticmethod
+	def _parse_seg_entry(se, segtype):
+		if se:
+			# print("_parse_seg_entry %s %s" % (str(se), str(segtype)))
+			device, segs = se.split(":")
+			start, end = segs.split('-')
+			return (device, (start, end), segtype)
+		else:
+			return ("", (), segtype)
+
+	@staticmethod
+	def _build_segments(l, seg_types):
+		rc = []
+		l = DataStore._make_list(l)
+		s = DataStore._make_list(seg_types)
+
+		assert len(l) == len(s)
+		ls = list(zip(l, s))
+
+		for i in ls:
+			if ' ' in i[0]:
+				tmp = i[0].split(' ')
+				for t in tmp:
+					rc.append(DataStore._parse_seg_entry(t, i[1]))
+			else:
+				rc.append(DataStore._parse_seg_entry(*i))
+		return rc
+
+	@staticmethod
+	def _pv_device_lv_entry(table, pv_device, lv_uuid, meta, lv_attr,
+							segment_info):
+
+		if pv_device not in table:
+			table[pv_device] = {}
+
+		if lv_uuid not in table[pv_device]:
+			table[pv_device][lv_uuid] = {}
+			table[pv_device][lv_uuid]['segs'] = [segment_info]
+			table[pv_device][lv_uuid]['name'] = meta
+			table[pv_device][lv_uuid]['meta'] = lv_attr
+		else:
+			table[pv_device][lv_uuid]['segs'].append(segment_info)
+
+	@staticmethod
+	def _pv_device_lv_format(pv_device_lvs):
+		rc = {}
+
+		for pv_device, pd in pv_device_lvs.items():
+			lvs = []
+			for lv_uuid, ld in sorted(pd.items()):
+				lvs.append((lv_uuid, ld['name'], ld['meta'], ld['segs']))
+
+			rc[pv_device] = lvs
+		return rc
+
+	@staticmethod
+	def _lvs_device_pv_entry(table, lv_uuid, pv_device, pv_uuid, segment_info):
+		if lv_uuid not in table:
+			table[lv_uuid] = {}
+
+		if pv_device not in table[lv_uuid]:
+			table[lv_uuid][pv_device] = {}
+			table[lv_uuid][pv_device]['segs'] = [segment_info]
+			table[lv_uuid][pv_device]['pv_uuid'] = pv_uuid
+		else:
+			table[lv_uuid][pv_device]['segs'].append(segment_info)
+
+	@staticmethod
+	def _lvs_device_pv_format(lvs_device_pvs):
+		rc = {}
+
+		for lv_uuid, ld in lvs_device_pvs.items():
+			pvs = []
+			for pv_device, pd in sorted(ld.items()):
+				pvs.append((pd['pv_uuid'], pv_device, pd['segs']))
+
+			rc[lv_uuid] = pvs
+		return rc
+
+	def _parse_pv_in_lvs(self):
+		pv_device_lvs = {}  # What LVs are stored on a PV
+		lvs_device_pv = {}  # Where LV data is stored
+
+		for i in self.lvs.values():
+			segs = self._build_segments(i['seg_pe_ranges'], i['segtype'])
+			for s in segs:
+				# We are referring to physical device
+				if '/dev/' in s[0]:
+					device, r, seg_type = s
+
+					DataStore._pv_device_lv_entry(
+						pv_device_lvs, device, i['lv_uuid'], i['lv_name'],
+						(i['lv_attr'], i['lv_layout'], i['lv_role']),
+						(r[0], r[1], seg_type))
+
+					# (pv_name, pv_segs, pv_uuid)
+					DataStore._lvs_device_pv_entry(
+						lvs_device_pv, i['lv_uuid'], device,
+						self.pv_path_to_uuid[device], (r[0], r[1], seg_type))
+				else:
+					# TODO Handle the case where the segments refer to a LV
+					# and not a PV
+					pass
+					# print("Handle this %s %s %s" % (s[0], s[1], s[2]))
+
+		# Convert form to needed result for consumption
+		pv_device_lvs_result = DataStore._pv_device_lv_format(pv_device_lvs)
+		lvs_device_pv_result = DataStore._lvs_device_pv_format(lvs_device_pv)
+
+		return pv_device_lvs_result, lvs_device_pv_result
+
+	def refresh(self, log=True):
+		"""
+		Go out and query lvm for the latest data in as few trips as possible
+		:param log  Add debug log entry/exit messages
+		:return: None
+		"""
+
+		if log:
+			log_debug("lvmdb - refresh entry")
+			self.num_refreshes += 1
+
+		# Grab everything first then parse it
+		_raw_pvs = cmdhandler.pv_retrieve_with_segs()
+		_raw_vgs = cmdhandler.vg_retrieve(None)
+		_raw_lvs = cmdhandler.lv_retrieve_with_segments()
+
+		_pvs, _pvs_lookup, _pvs_in_vgs = self._parse_pvs(_raw_pvs)
+		_vgs, _vgs_lookup = self._parse_vgs(_raw_vgs)
+		_lvs, _lvs_in_vgs, _lvs_hidden, _lvs_lookup = self._parse_lvs(_raw_lvs)
+
+		# Set all
+		self.pvs = _pvs
+		self.pv_path_to_uuid = _pvs_lookup
+		self.vg_name_to_uuid = _vgs_lookup
+		self.lv_full_name_to_uuid = _lvs_lookup
+
+		self.vgs = _vgs
+		self.lvs = _lvs
+		self.lvs_in_vgs = _lvs_in_vgs
+		self.pvs_in_vgs = _pvs_in_vgs
+		self.lvs_hidden = _lvs_hidden
+
+		# Create lookup table for which LV and segments are on each PV
+		self.pv_lvs, self.lv_pvs = self._parse_pv_in_lvs()
+
+		if log:
+			log_debug("lvmdb - refresh exit")
+
+	def fetch_pvs(self, pv_name):
+		if not pv_name:
+			return self.pvs.values()
+		else:
+			rc = []
+			for s in pv_name:
+				rc.append(self.pvs[self.pv_path_to_uuid[s]])
+			return rc
+
+	def fetch_vgs(self, vg_name):
+		if not vg_name:
+			return self.vgs.values()
+		else:
+			rc = []
+			for s in vg_name:
+				rc.append(self.vgs[self.vg_name_to_uuid[s]])
+			return rc
+
+	def fetch_lvs(self, lv_names):
+		try:
+			if not lv_names:
+				return self.lvs.values()
+			else:
+				rc = []
+				for s in lv_names:
+					rc.append(self.lvs[self.lv_full_name_to_uuid[s]])
+				return rc
+		except KeyError as ke:
+			print("Key %s not found!" % (str(lv_names)))
+			print("lv name to uuid lookup")
+			for keys in sorted(self.lv_full_name_to_uuid.keys()):
+				print("%s" % (keys))
+			print("lvs entries by uuid")
+			for keys in sorted(self.lvs.keys()):
+				print("%s" % (keys))
+			raise ke
+
+	def pv_pe_segments(self, pv_uuid):
+		pv = self.pvs[pv_uuid]
+		return list(zip(pv['pv_seg_start'], pv['pvseg_size']))
+
+	def pv_contained_lv(self, pv_device):
+		rc = []
+		if pv_device in self.pv_lvs:
+			rc = self.pv_lvs[pv_device]
+		return rc
+
+	def lv_contained_pv(self, lv_uuid):
+		rc = []
+		if lv_uuid in self.lv_pvs:
+			rc = self.lv_pvs[lv_uuid]
+		return rc
+
+	def lvs_in_vg(self, vg_uuid):
+		# Return an array of
+		# (lv_name, (lv_attr, lv_layout, lv_role), lv_uuid)
+		rc = []
+		if vg_uuid in self.lvs_in_vgs:
+			rc = self.lvs_in_vgs[vg_uuid]
+		return rc
+
+	def pvs_in_vg(self, vg_uuid):
+		# Returns an array of (pv_name, pv_uuid)
+		rc = []
+		if vg_uuid in self.pvs_in_vgs:
+			rc = self.pvs_in_vgs[vg_uuid]
+		return rc
+
+	def hidden_lvs(self, lv_uuid):
+		# For a specified LV, return a list of hidden lv_uuid, lv_name
+		# for it
+		rc = []
+		if lv_uuid in self.lvs_hidden:
+			rc = self.lvs_hidden[lv_uuid]
+		return rc
+
+
+if __name__ == "__main__":
+	pp = prettyprint.PrettyPrinter(indent=4)
+
+	ds = DataStore()
+	ds.refresh()
+
+	for v in ds.pvs.values():
+		pp.pprint(v)
+
+	for v in ds.vgs.values():
+		pp.pprint(v)
+
+	print("LVS")
+	for v in ds.lvs.values():
+		pp.pprint(v)
+
+	print("LVS in VG")
+	for k, v in ds.lvs_in_vgs.items():
+		print("VG uuid = %s" % (k))
+		pp.pprint(v)
+
+	print("pv_in_lvs")
+	for k, v in ds.pv_lvs.items():
+		print("PV %s contains LVS:" % (k))
+		pp.pprint(v)
+
+	for k, v in ds.lv_pvs.items():
+		print("LV device = %s" % (k))
+		pp.pprint(v)
diff --git a/daemons/lvmdbusd/lvmdbus.py b/daemons/lvmdbusd/lvmdbus.py
new file mode 100644
index 0000000..43545b2
--- /dev/null
+++ b/daemons/lvmdbusd/lvmdbus.py
@@ -0,0 +1,140 @@
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+from . import cfg
+from . import objectmanager
+from . import utils
+from .cfg import BASE_INTERFACE, BASE_OBJ_PATH, MANAGER_OBJ_PATH
+import threading
+from . import cmdhandler
+import time
+import signal
+import dbus
+from . import lvmdb
+# noinspection PyUnresolvedReferences
+from gi.repository import GObject
+from .fetch import load
+from .manager import Manager
+from .background import background_reaper
+import traceback
+import queue
+import sys
+from . import udevwatch
+from .utils import log_debug
+import argparse
+
+
+class Lvm(objectmanager.ObjectManager):
+	def __init__(self, object_path):
+		super(Lvm, self).__init__(object_path, BASE_INTERFACE)
+
+
+def process_request():
+	while cfg.run.value != 0:
+		try:
+			req = cfg.worker_q.get(True, 5)
+
+			start = cfg.db.num_refreshes
+
+			log_debug(
+				"Running method: %s with args %s" %
+				(str(req.method), str(req.arguments)))
+			req.run_cmd()
+
+			end = cfg.db.num_refreshes
+
+			if end - start > 1:
+				log_debug(
+					"Inspect method %s for too many refreshes" %
+					(str(req.method)))
+			log_debug("Complete ")
+		except queue.Empty:
+			pass
+		except Exception:
+			traceback.print_exc(file=sys.stdout)
+			pass
+
+
+def main():
+	# Add simple command line handling
+	parser = argparse.ArgumentParser()
+	parser.add_argument("--udev", action='store_true',
+						help="Use udev for updating state", default=False,
+						dest='use_udev')
+	parser.add_argument("--debug", action='store_true',
+						help="Dump debug messages", default=False,
+						dest='debug')
+
+	args = parser.parse_args()
+
+	cfg.DEBUG = args.debug
+
+	# List of threads that we start up
+	thread_list = []
+
+	start = time.time()
+
+	# Install signal handlers
+	for s in [signal.SIGHUP, signal.SIGINT]:
+		try:
+			signal.signal(s, utils.handler)
+		except RuntimeError:
+			pass
+
+	dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
+	GObject.threads_init()
+	dbus.mainloop.glib.threads_init()
+	cfg.bus = dbus.SystemBus()
+	# The base name variable needs to exist for things to work.
+	# noinspection PyUnusedLocal
+	base_name = dbus.service.BusName(BASE_INTERFACE, cfg.bus)
+	cfg.om = Lvm(BASE_OBJ_PATH)
+	cfg.om.register_object(Manager(MANAGER_OBJ_PATH))
+
+	cfg.load = load
+
+	cfg.db = lvmdb.DataStore()
+
+	# Start up thread to monitor pv moves
+	thread_list.append(
+		threading.Thread(target=background_reaper, name="pv_move_reaper"))
+
+	# Using a thread to process requests.
+	thread_list.append(threading.Thread(target=process_request))
+
+	cfg.load(refresh=False, emit_signal=False)
+	cfg.loop = GObject.MainLoop()
+
+	for process in thread_list:
+		process.damon = True
+		process.start()
+
+	end = time.time()
+	log_debug(
+		'Service ready! total time= %.2f, lvm time= %.2f count= %d' %
+		(end - start, cmdhandler.total_time, cmdhandler.total_count),
+		'bg_black', 'fg_light_green')
+
+	# Add udev watching
+	if args.use_udev:
+		log_debug('Utilizing udev to trigger updates')
+		udevwatch.add()
+
+	try:
+		if cfg.run.value != 0:
+			cfg.loop.run()
+
+			if args.use_udev:
+				udevwatch.remove()
+
+			for process in thread_list:
+				process.join()
+	except KeyboardInterrupt:
+		utils.handler(signal.SIGINT, None)
+	return 0
diff --git a/daemons/lvmdbusd/lvmdbusd b/daemons/lvmdbusd/lvmdbusd
new file mode 100644
index 0000000..058ddf0
--- /dev/null
+++ b/daemons/lvmdbusd/lvmdbusd
@@ -0,0 +1,16 @@
+#!/usr/bin/env python3
+
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+import sys
+import lvmdbus
+
+if __name__ == '__main__':
+	sys.exit(lvmdbus.main())
diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
new file mode 100644
index 0000000..f7d194d
--- /dev/null
+++ b/daemons/lvmdbusd/manager.py
@@ -0,0 +1,241 @@
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+from .automatedproperties import AutomatedProperties
+
+from . import utils
+from .cfg import MANAGER_INTERFACE
+import dbus
+from . import cfg
+from . import cmdhandler
+from .fetch import load_pvs, load_vgs
+from .request import RequestEntry
+from .refresh import event_add
+
+
+# noinspection PyPep8Naming
+class Manager(AutomatedProperties):
+	_Version_meta = ("t", MANAGER_INTERFACE)
+
+	def __init__(self, object_path):
+		super(Manager, self).__init__(object_path)
+		self.set_interface(MANAGER_INTERFACE)
+
+	@property
+	def Version(self):
+		return '1.0.0'
+
+	@staticmethod
+	def _pv_create(device, create_options):
+
+		# Check to see if we are already trying to create a PV for an existing
+		# PV
+		pv = cfg.om.get_object_path_by_lvm_id(
+			device, device, None, False)
+		if pv:
+			raise dbus.exceptions.DBusException(
+				MANAGER_INTERFACE, "PV Already exists!")
+
+		created_pv = []
+		rc, out, err = cmdhandler.pv_create(create_options, [device])
+		if rc == 0:
+			pvs = load_pvs([device], emit_signal=True)[0]
+			for p in pvs:
+				created_pv = p.dbus_object_path()
+		else:
+			raise dbus.exceptions.DBusException(
+				MANAGER_INTERFACE,
+				'Exit code %s, stderr = %s' % (str(rc), err))
+
+		return created_pv
+
+	@dbus.service.method(
+		dbus_interface=MANAGER_INTERFACE,
+		in_signature='sia{sv}',
+		out_signature='(oo)',
+		async_callbacks=('cb', 'cbe'))
+	def PvCreate(self, device, tmo, create_options, cb, cbe):
+		r = RequestEntry(
+			tmo, Manager._pv_create,
+			(device, create_options), cb, cbe)
+		cfg.worker_q.put(r)
+
+	@staticmethod
+	def _create_vg(name, pv_object_paths, create_options):
+		pv_devices = []
+
+		for p in pv_object_paths:
+			pv = cfg.om.get_object_by_path(p)
+			if pv:
+				pv_devices.append(pv.Name)
+			else:
+				raise dbus.exceptions.DBusException(
+					MANAGER_INTERFACE, 'object path = %s not found' % p)
+
+		rc, out, err = cmdhandler.vg_create(create_options, pv_devices, name)
+		created_vg = "/"
+
+		if rc == 0:
+			vgs = load_vgs([name], emit_signal=True)[0]
+			for v in vgs:
+				created_vg = v.dbus_object_path()
+
+			# Update the PVS
+			load_pvs(refresh=True, emit_signal=True, cache_refresh=False)
+		else:
+			raise dbus.exceptions.DBusException(
+				MANAGER_INTERFACE,
+				'Exit code %s, stderr = %s' % (str(rc), err))
+		return created_vg
+
+	@dbus.service.method(
+		dbus_interface=MANAGER_INTERFACE,
+		in_signature='saoia{sv}',
+		out_signature='(oo)',
+		async_callbacks=('cb', 'cbe'))
+	def VgCreate(self, name, pv_object_paths, tmo, create_options, cb, cbe):
+		r = RequestEntry(
+			tmo, Manager._create_vg,
+			(name, pv_object_paths, create_options,),
+			cb, cbe)
+		cfg.worker_q.put(r)
+
+	@staticmethod
+	def _refresh():
+		utils.log_debug('Manager.Refresh - entry')
+
+		# This is a diagnostic and should not be run in normal operation, so
+		# lets remove the log entries for refresh as it's implied.
+		rc = cfg.load(log=False)
+
+		if rc != 0:
+			utils.log_debug('Manager.Refresh - exit %d' % (rc),
+							'bg_black', 'fg_light_red')
+		else:
+			utils.log_debug('Manager.Refresh - exit %d' % (rc))
+		return rc
+
+	@dbus.service.method(
+		dbus_interface=MANAGER_INTERFACE,
+		out_signature='t',
+		async_callbacks=('cb', 'cbe'))
+	def Refresh(self, cb, cbe):
+		"""
+		Take all the objects we know about and go out and grab the latest
+		more of a test method at the moment to make sure we are handling object
+		paths correctly.
+
+		:param cb   Callback for result
+		:param cbe  Callback for errors
+
+		Returns the number of changes, object add/remove/properties changed
+		"""
+		r = RequestEntry(-1, Manager._refresh, (), cb, cbe, False)
+		cfg.worker_q.put(r)
+
+	@dbus.service.method(
+		dbus_interface=MANAGER_INTERFACE,
+		in_signature='s',
+		out_signature='o')
+	def LookUpByLvmId(self, key):
+		"""
+		Given a lvm id in one of the forms:
+
+		/dev/sda
+		some_vg
+		some_vg/some_lv
+		Oe1rPX-Pf0W-15E5-n41N-ZmtF-jXS0-Osg8fn
+
+		return the object path in O(1) time.
+
+		:param key: The lookup value
+		:return: Return the object path.  If object not found you will get '/'
+		"""
+		p = cfg.om.get_object_path_by_lvm_id(
+			key, key, gen_new=False)
+		if p:
+			return p
+		return '/'
+
+	@dbus.service.method(
+		dbus_interface=MANAGER_INTERFACE,
+		in_signature='b')
+	def UseLvmShell(self, yes_no):
+		"""
+		Allow the client to enable/disable lvm shell, used for testing
+		:param yes_no:
+		:return: Nothing
+		"""
+		cmdhandler.set_execution(yes_no)
+
+	@dbus.service.method(
+		dbus_interface=MANAGER_INTERFACE,
+		in_signature='s', out_signature='i')
+	def ExternalEvent(self, command):
+
+		event_add((command,))
+		return dbus.Int32(0)
+
+	@staticmethod
+	def _pv_scan(activate, cache, device_path, major_minor, scan_options):
+
+		rc, out, err = cmdhandler.pv_scan(
+			activate, cache, device_path,
+			major_minor, scan_options)
+
+		if rc == 0:
+			# This could potentially change the state quite a bit, so lets
+			# update everything to be safe
+			cfg.load()
+			return '/'
+		else:
+			raise dbus.exceptions.DBusException(
+				MANAGER_INTERFACE,
+				'Exit code %s, stderr = %s' % (str(rc), err))
+
+	@dbus.service.method(
+		dbus_interface=MANAGER_INTERFACE,
+		in_signature='bbasa(ii)ia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def PvScan(self, activate, cache, device_paths, major_minors,
+			tmo, scan_options, cb, cbe):
+		"""
+		Scan all supported LVM block devices in the system for physical volumes
+		NOTE: major_minors & device_paths only usable when cache == True
+		:param activate: If True, activate any newly found LVs
+		:param cache:    If True, update lvmetad
+		:param device_paths: Array of device paths or empty
+		:param major_minors: Array of structures (major,minor)
+		:param tmo: Timeout for operation
+		:param scan_options:  Additional options to pvscan
+		:param cb: Not visible in API (used for async. callback)
+		:param cbe: Not visible in API (used for async. error callback)
+		:return: '/' if operation done, else job path
+		"""
+		r = RequestEntry(
+			tmo, Manager._pv_scan,
+			(activate, cache, device_paths, major_minors,
+			scan_options), cb, cbe, False)
+		cfg.worker_q.put(r)
+
+	@property
+	def lvm_id(self):
+		"""
+		Intended to be overridden by classes that inherit
+		"""
+		return str(id(self))
+
+	@property
+	def Uuid(self):
+		"""
+		Intended to be overridden by classes that inherit
+		"""
+		import uuid
+		return uuid.uuid1()
diff --git a/daemons/lvmdbusd/objectmanager.py b/daemons/lvmdbusd/objectmanager.py
new file mode 100644
index 0000000..e2f1e0a
--- /dev/null
+++ b/daemons/lvmdbusd/objectmanager.py
@@ -0,0 +1,282 @@
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+import sys
+import threading
+import traceback
+import dbus
+from . import cfg
+from .utils import log_debug
+from .automatedproperties import AutomatedProperties
+
+
+# noinspection PyPep8Naming
+class ObjectManager(AutomatedProperties):
+	"""
+	Implements the org.freedesktop.DBus.ObjectManager interface
+	"""
+
+	def __init__(self, object_path, interface):
+		super(ObjectManager, self).__init__(object_path, interface)
+		self.set_interface(interface)
+		self._ap_o_path = object_path
+		self._objects = {}
+		self._id_to_object_path = {}
+		self.rlock = threading.RLock()
+
+	@dbus.service.method(
+		dbus_interface="org.freedesktop.DBus.ObjectManager",
+		out_signature='a{oa{sa{sv}}}')
+	def GetManagedObjects(self):
+		with self.rlock:
+			rc = {}
+			try:
+				for k, v in list(self._objects.items()):
+					path, props = v[0].emit_data()
+					rc[path] = props
+			except Exception:
+				traceback.print_exc(file=sys.stdout)
+				sys.exit(1)
+			return rc
+
+	def locked(self):
+		"""
+		If some external code need to run across a number of different
+		calls into ObjectManager while blocking others they can use this method
+		to lock others out.
+		:return:
+		"""
+		return ObjectManagerLock(self.rlock)
+
+	@dbus.service.signal(
+		dbus_interface="org.freedesktop.DBus.ObjectManager",
+		signature='oa{sa{sv}}')
+	def InterfacesAdded(self, object_path, int_name_prop_dict):
+		log_debug(
+			('SIGNAL: InterfacesAdded(%s, %s)' %
+			(str(object_path), str(int_name_prop_dict))))
+
+	@dbus.service.signal(
+		dbus_interface="org.freedesktop.DBus.ObjectManager",
+		signature='oas')
+	def InterfacesRemoved(self, object_path, interface_list):
+		log_debug(('SIGNAL: InterfacesRemoved(%s, %s)' %
+			(str(object_path), str(interface_list))))
+
+	def _lookup_add(self, obj, path, lvm_id, uuid):
+		"""
+		Store information about what we added to the caches so that we
+		can remove it cleanly
+		:param obj:     The dbus object we are storing
+		:param lvm_id:  The user name for the asset
+		:param uuid:    The uuid for the asset
+		:return:
+		"""
+		# Note: Only called internally, lock implied
+
+		# We could have a temp entry from the forward creation of a path
+		self._lookup_remove(path)
+
+		self._objects[path] = (obj, lvm_id, uuid)
+		self._id_to_object_path[lvm_id] = path
+
+		if uuid:
+			self._id_to_object_path[uuid] = path
+
+	def _lookup_remove(self, obj_path):
+		# Note: Only called internally, lock implied
+		if obj_path in self._objects:
+			(obj, lvm_id, uuid) = self._objects[obj_path]
+			del self._id_to_object_path[lvm_id]
+			del self._id_to_object_path[uuid]
+			del self._objects[obj_path]
+
+	def lookup_update(self, dbus_obj, new_uuid, new_lvm_id):
+		with self.rlock:
+			obj_path = dbus_obj.dbus_object_path()
+			self._lookup_remove(obj_path)
+			self._lookup_add(
+				dbus_obj, obj_path,
+				new_lvm_id, new_uuid)
+
+	def object_paths_by_type(self, o_type):
+		with self.rlock:
+			rc = {}
+
+			for k, v in list(self._objects.items()):
+				if isinstance(v[0], o_type):
+					rc[k] = True
+			return rc
+
+	def register_object(self, dbus_object, emit_signal=False):
+		"""
+		Given a dbus object add it to the collection
+		:param dbus_object: Dbus object to register
+		:param emit_signal: If true emit a signal for interfaces added
+		"""
+		with self.rlock:
+			path, props = dbus_object.emit_data()
+
+			# print 'Registering object path %s for %s' %
+			# (path, dbus_object.lvm_id)
+
+			# We want fast access to the object by a number of different ways
+			# so we use multiple hashs with different keys
+			self._lookup_add(dbus_object, path, dbus_object.lvm_id,
+				dbus_object.Uuid)
+
+			if emit_signal:
+				self.InterfacesAdded(path, props)
+
+	def remove_object(self, dbus_object, emit_signal=False):
+		"""
+		Given a dbus object, remove it from the collection and remove it
+		from the dbus framework as well
+		:param dbus_object:  Dbus object to remove
+		:param emit_signal:  If true emit the interfaces removed signal
+		"""
+		with self.rlock:
+			# Store off the object path and the interface first
+			path = dbus_object.dbus_object_path()
+			interfaces = dbus_object.interface()
+
+			# print 'UN-Registering object path %s for %s' % \
+			#      (path, dbus_object.lvm_id)
+
+			self._lookup_remove(path)
+
+			# Remove from dbus library
+			dbus_object.remove_from_connection(cfg.bus, path)
+
+			# Optionally emit a signal
+			if emit_signal:
+				self.InterfacesRemoved(path, interfaces)
+
+	def get_object_by_path(self, path):
+		"""
+		Given a dbus path return the object registered for it
+		:param path: The dbus path
+		:return: The object
+		"""
+		with self.rlock:
+			if path in self._objects:
+				return self._objects[path][0]
+			return None
+
+	def get_object_by_uuid_lvm_id(self, uuid, lvm_id):
+		with self.rlock:
+			return self.get_object_by_path(
+				self.get_object_path_by_lvm_id(uuid, lvm_id, None, False))
+
+	def get_object_by_lvm_id(self, lvm_id):
+		"""
+		Given an lvm identifier, return the object registered for it
+		:param lvm_id: The lvm identifier
+		"""
+		with self.rlock:
+			if lvm_id in self._id_to_object_path:
+				return self.get_object_by_path(self._id_to_object_path[lvm_id])
+			return None
+
+	def _uuid_verify(self, path, lvm_id, uuid):
+		"""
+		Ensure uuid is present for a successful lvm_id lookup
+		NOTE: Internal call, assumes under object manager lock
+		:param path: 		Path to object we looked up
+		:param lvm_id:		lvm_id used to find object
+		:param uuid: 		lvm uuid to verify
+		:return: None
+		"""
+		# This gets called when we found an object based on lvm_id, ensure
+		# uuid is correct too, as they can change
+		if lvm_id != uuid:
+			if uuid not in self._id_to_object_path:
+				obj = self.get_object_by_path(path)
+				self._lookup_add(obj, path, lvm_id, uuid)
+
+	def get_object_path_by_lvm_id(self, uuid, lvm_id, path_create=None,
+								gen_new=True):
+		"""
+		For a given lvm asset return the dbus object registered to it.  If the
+		object is not found and gen_new == True and path_create is a valid
+		function we will create a new path, register it and return it.
+		:param uuid: The uuid for the lvm object
+		:param lvm_id: The lvm name
+		:param path_create: If true create an object path if not found
+		:param gen_new: The function used to create the new path
+		"""
+		with self.rlock:
+			assert lvm_id
+			assert uuid
+
+			if gen_new:
+				assert path_create
+
+			path = None
+
+			if lvm_id in self._id_to_object_path:
+				path = self._id_to_object_path[lvm_id]
+				self._uuid_verify(path, lvm_id, uuid)
+				return path
+			if "/" in lvm_id:
+				vg, lv = lvm_id.split("/", 1)
+				int_lvm_id = vg + "/" + ("[%s]" % lv)
+				if int_lvm_id in self._id_to_object_path:
+					path = self._id_to_object_path[int_lvm_id]
+					self._uuid_verify(path, int_lvm_id, uuid)
+					return path
+
+			if uuid and uuid in self._id_to_object_path:
+				# If we get here it indicates that we found the object, but
+				# the lvm_id lookup failed.  In the case of a rename, the uuid
+				# will be correct, but the lvm_id will be wrong and vise versa.
+				# If the lvm_id does not equal the uuid, lets fix up the table
+				# so that lookups will be handled correctly.
+				path = self._id_to_object_path[uuid]
+
+				# In some cases we are looking up by one or the other, don't
+				# update when they are the same.
+				if uuid != lvm_id:
+					obj = self.get_object_by_path(path)
+					self._lookup_add(obj, path, lvm_id, uuid)
+			else:
+				if gen_new:
+					path = path_create()
+					self._lookup_add(None, path, lvm_id, uuid)
+
+			# pprint('get_object_path_by_lvm_id(%s, %s, %s, %s: return %s' %
+			#       (uuid, lvm_id, str(path_create), str(gen_new), path))
+
+			return path
+
+
+class ObjectManagerLock(object):
+	"""
+	The sole purpose of this class is to allow other code the ability to
+	lock the object manager using a `with` statement, eg.
+
+	with cfg.om.locked():
+		# Do stuff with object manager
+
+	This will ensure that the lock is always released (assuming this is done
+	correctly)
+	"""
+
+	def __init__(self, recursive_lock):
+		self._lock = recursive_lock
+
+	def __enter__(self):
+		# Acquire lock
+		self._lock.acquire()
+
+	# noinspection PyUnusedLocal
+	def __exit__(self, e_type, e_value, e_traceback):
+		# Release lock
+		self._lock.release()
+		self._lock = None
diff --git a/daemons/lvmdbusd/path.py.in b/daemons/lvmdbusd/path.py.in
new file mode 100644
index 0000000..f0ef205
--- /dev/null
+++ b/daemons/lvmdbusd/path.py.in
@@ -0,0 +1,10 @@
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+LVM_BINARY = "@LVM_PATH@"
diff --git a/daemons/lvmdbusd/pv.py b/daemons/lvmdbusd/pv.py
new file mode 100644
index 0000000..287825f
--- /dev/null
+++ b/daemons/lvmdbusd/pv.py
@@ -0,0 +1,282 @@
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+from .automatedproperties import AutomatedProperties
+from . import utils
+from . import cfg
+import dbus
+from .cfg import PV_INTERFACE
+from . import cmdhandler
+from .utils import vg_obj_path_generate, n, pv_obj_path_generate, \
+	lv_object_path_method
+from .loader import common
+from .request import RequestEntry
+from .state import State
+from .utils import round_size
+
+
+# noinspection PyUnusedLocal
+def pvs_state_retrieve(selection, cache_refresh=True):
+	rc = []
+
+	if cache_refresh:
+		cfg.db.refresh()
+
+	for p in cfg.db.fetch_pvs(selection):
+		rc.append(
+			PvState(
+				p["pv_name"], p["pv_uuid"], p["pv_name"],
+				p["pv_fmt"], n(p["pv_size"]), n(p["pv_free"]),
+				n(p["pv_used"]), n(p["dev_size"]), n(p["pv_mda_size"]),
+				n(p["pv_mda_free"]), int(p["pv_ba_start"]),
+				n(p["pv_ba_size"]), n(p["pe_start"]),
+				int(p["pv_pe_count"]), int(p["pv_pe_alloc_count"]),
+				p["pv_attr"], p["pv_tags"], p["vg_name"], p["vg_uuid"]))
+	return rc
+
+
+def load_pvs(device=None, object_path=None, refresh=False, emit_signal=False,
+		cache_refresh=True):
+	return common(
+		pvs_state_retrieve, (Pv,), device, object_path, refresh,
+		emit_signal, cache_refresh)
+
+
+# noinspection PyUnresolvedReferences
+class PvState(State):
+	@property
+	def lvm_id(self):
+		return self.lvm_path
+
+	def _lv_object_list(self, vg_name):
+
+		# Note we are returning "a(oa(tts))"
+
+		rc = []
+		if vg_name:
+			for lv in sorted(cfg.db.pv_contained_lv(self.lvm_id)):
+				lv_uuid, lv_name, meta, segs = lv
+				full_name = "%s/%s" % (vg_name, lv_name)
+
+				path_create = lv_object_path_method(lv_name, meta)
+				lv_path = cfg.om.get_object_path_by_lvm_id(
+					lv_uuid, full_name, path_create)
+
+				rc.append((lv_path, segs))
+		return dbus.Array(rc, signature="(oa(tts))")
+
+	# noinspection PyUnusedLocal,PyPep8Naming
+	def __init__(self, lvm_path, Uuid, Name,
+			Fmt, SizeBytes, FreeBytes, UsedBytes, DevSizeBytes,
+			MdaSizeBytes, MdaFreeBytes, BaStart, BaSizeBytes,
+			PeStart, PeCount, PeAllocCount, attr, Tags, vg_name,
+			vg_uuid):
+		utils.init_class_from_arguments(self)
+		self.pe_segments = cfg.db.pv_pe_segments(Uuid)
+
+		self.lv = self._lv_object_list(vg_name)
+
+		if vg_name:
+			self.vg_path = cfg.om.get_object_path_by_lvm_id(
+				vg_uuid, vg_name, vg_obj_path_generate)
+		else:
+			self.vg_path = '/'
+
+	def identifiers(self):
+		return (self.Uuid, self.lvm_path)
+
+	def create_dbus_object(self, path):
+		if not path:
+			path = cfg.om.get_object_path_by_lvm_id(self.Uuid, self.Name,
+													pv_obj_path_generate)
+		return Pv(path, self)
+
+	# noinspection PyMethodMayBeStatic
+	def creation_signature(self):
+		return (Pv, pv_obj_path_generate)
+
+
+# noinspection PyPep8Naming
+ at utils.dbus_property(PV_INTERFACE, 'Uuid', 's')  # PV UUID/pv_uuid
+ at utils.dbus_property(PV_INTERFACE, 'Name', 's')  # PV/pv_name
+ at utils.dbus_property(PV_INTERFACE, 'Fmt', 's')  # Fmt/pv_fmt
+ at utils.dbus_property(PV_INTERFACE, 'SizeBytes', 't')  # PSize/pv_size
+ at utils.dbus_property(PV_INTERFACE, 'FreeBytes', 't')  # PFree/pv_free
+ at utils.dbus_property(PV_INTERFACE, 'UsedBytes', 't')  # Used/pv_used
+ at utils.dbus_property(PV_INTERFACE, 'DevSizeBytes', 't')  # DevSize/dev_size
+ at utils.dbus_property(PV_INTERFACE, 'MdaSizeBytes', 't')  # PMdaSize/pv_mda_size
+ at utils.dbus_property(PV_INTERFACE, 'MdaFreeBytes', 't')  # PMdaFree/pv_mda_free
+ at utils.dbus_property(PV_INTERFACE, 'BaStart', 't')  # BA start/pv_ba_start
+ at utils.dbus_property(PV_INTERFACE, 'BaSizeBytes', 't')  # BA size/pv_ba_size
+ at utils.dbus_property(PV_INTERFACE, 'PeStart', 't')  # 1st PE/pe_start
+ at utils.dbus_property(PV_INTERFACE, 'PeCount', 't')  # PE/pv_pe_count
+ at utils.dbus_property(PV_INTERFACE, 'PeAllocCount', 't')  # PE Allocation count
+class Pv(AutomatedProperties):
+	# For properties that we need custom handlers we need these, otherwise
+	# we won't get our introspection data
+	_Tags_meta = ("as", PV_INTERFACE)
+	_PeSegments_meta = ("a(tt)", PV_INTERFACE)
+	_Exportable_meta = ("b", PV_INTERFACE)
+	_Allocatable_meta = ("b", PV_INTERFACE)
+	_Missing_meta = ("b", PV_INTERFACE)
+	_Lv_meta = ("a(oa(tts))", PV_INTERFACE)
+	_Vg_meta = ("o", PV_INTERFACE)
+
+	# noinspection PyUnusedLocal,PyPep8Naming
+	def __init__(self, object_path, state_obj):
+		super(Pv, self).__init__(object_path, pvs_state_retrieve)
+		self.set_interface(PV_INTERFACE)
+		self.state = state_obj
+
+	@staticmethod
+	def _remove(pv_uuid, pv_name, remove_options):
+		# Remove the PV, if successful then remove from the model
+		# Make sure we have a dbus object representing it
+		dbo = cfg.om.get_object_by_uuid_lvm_id(pv_uuid, pv_name)
+
+		if dbo:
+			rc, out, err = cmdhandler.pv_remove(pv_name, remove_options)
+			if rc == 0:
+				cfg.om.remove_object(dbo, True)
+			else:
+				# Need to work on error handling, need consistent
+				raise dbus.exceptions.DBusException(
+					PV_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+		else:
+			raise dbus.exceptions.DBusException(
+				PV_INTERFACE,
+				'PV with uuid %s and name %s not present!' %
+				(pv_uuid, pv_name))
+		return '/'
+
+	@dbus.service.method(
+		dbus_interface=PV_INTERFACE,
+		in_signature='ia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def Remove(self, tmo, remove_options, cb, cbe):
+		r = RequestEntry(
+			tmo, Pv._remove,
+			(self.Uuid, self.lvm_id, remove_options),
+			cb, cbe, return_tuple=False)
+		cfg.worker_q.put(r)
+
+	@staticmethod
+	def _resize(pv_uuid, pv_name, new_size_bytes, resize_options):
+		# Make sure we have a dbus object representing it
+		dbo = cfg.om.get_object_by_uuid_lvm_id(pv_uuid, pv_name)
+
+		if dbo:
+			rc, out, err = cmdhandler.pv_resize(pv_name, new_size_bytes,
+												resize_options)
+			if rc == 0:
+				dbo.refresh()
+			else:
+				raise dbus.exceptions.DBusException(
+					PV_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+		else:
+			raise dbus.exceptions.DBusException(
+				PV_INTERFACE,
+				'PV with uuid %s and name %s not present!' %
+				(pv_uuid, pv_name))
+		return '/'
+
+	@dbus.service.method(
+		dbus_interface=PV_INTERFACE,
+		in_signature='tia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def ReSize(self, new_size_bytes, tmo, resize_options, cb, cbe):
+		r = RequestEntry(
+			tmo, Pv._resize,
+			(self.Uuid, self.lvm_id, round_size(new_size_bytes),
+			resize_options), cb, cbe, False)
+		cfg.worker_q.put(r)
+
+	@staticmethod
+	def _allocation_enabled(pv_uuid, pv_name, yes_no, allocation_options):
+		# Make sure we have a dbus object representing it
+		dbo = cfg.om.get_object_by_uuid_lvm_id(pv_uuid, pv_name)
+
+		if dbo:
+			rc, out, err = cmdhandler.pv_allocatable(
+				pv_name, yes_no, allocation_options)
+			if rc == 0:
+				cfg.load()
+			else:
+				raise dbus.exceptions.DBusException(
+					PV_INTERFACE, 'Exit code %s, stderr = %s' % (str(rc), err))
+		else:
+			raise dbus.exceptions.DBusException(
+				PV_INTERFACE,
+				'PV with uuid %s and name %s not present!' %
+				(pv_uuid, pv_name))
+		return '/'
+
+	@dbus.service.method(
+		dbus_interface=PV_INTERFACE,
+		in_signature='bia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def AllocationEnabled(self, yes, tmo, allocation_options, cb, cbe):
+		r = RequestEntry(
+			tmo, Pv._allocation_enabled,
+			(self.Uuid, self.lvm_id,
+			yes, allocation_options),
+			cb, cbe, False)
+		cfg.worker_q.put(r)
+
+	@property
+	def Tags(self):
+		return utils.parse_tags(self.state.Tags)
+
+	@property
+	def PeSegments(self):
+		if len(self.state.pe_segments):
+			return self.state.pe_segments
+		return dbus.Array([], '(tt)')
+
+	@property
+	def Exportable(self):
+		if self.state.attr[1] == 'x':
+			return True
+		return False
+
+	@property
+	def Allocatable(self):
+		if self.state.attr[0] == 'a':
+			return True
+		return False
+
+	@property
+	def Missing(self):
+		if self.state.attr[2] == 'm':
+			return True
+		return False
+
+	def object_path(self):
+		return self._object_path
+
+	@property
+	def lvm_id(self):
+		return self.state.lvm_id
+
+	@property
+	def identifiers(self):
+		return self.state.identifiers()
+
+	@property
+	def Lv(self):
+		return self.state.lv
+
+	@property
+	def Vg(self):
+		return self.state.vg_path
diff --git a/daemons/lvmdbusd/refresh.py b/daemons/lvmdbusd/refresh.py
new file mode 100644
index 0000000..e29afd6
--- /dev/null
+++ b/daemons/lvmdbusd/refresh.py
@@ -0,0 +1,45 @@
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+# Try and minimize the refreshes we do.
+
+import threading
+from .request import RequestEntry
+from . import cfg
+from . import utils
+
+_rlock = threading.RLock()
+_count = 0
+
+
+def handle_external_event(command):
+	utils.log_debug("External event: '%s'" % command)
+	event_complete()
+	cfg.load()
+
+
+def event_add(params):
+	global _rlock
+	global _count
+	with _rlock:
+		if _count == 0:
+			_count += 1
+			r = RequestEntry(
+				-1, handle_external_event,
+				params, None, None, False)
+			cfg.worker_q.put(r)
+
+
+def event_complete():
+	global _rlock
+	global _count
+	with _rlock:
+		if _count > 0:
+			_count -= 1
+		return _count
diff --git a/daemons/lvmdbusd/request.py b/daemons/lvmdbusd/request.py
new file mode 100644
index 0000000..15d852e
--- /dev/null
+++ b/daemons/lvmdbusd/request.py
@@ -0,0 +1,140 @@
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+import threading
+# noinspection PyUnresolvedReferences
+from gi.repository import GObject
+from .job import Job
+from . import cfg
+import traceback
+from .utils import log_error
+
+
+class RequestEntry(object):
+	def __init__(self, tmo, method, arguments, cb, cb_error,
+			return_tuple=True):
+		self.tmo = tmo
+		self.method = method
+		self.arguments = arguments
+		self.cb = cb
+		self.cb_error = cb_error
+
+		self.timer_id = -1
+		self.lock = threading.RLock()
+		self.done = False
+		self._result = None
+		self._job = False
+		self._rc = 0
+		self._rc_error = None
+		self._return_tuple = return_tuple
+
+		if self.tmo == -1:
+			# Client is willing to block forever
+			pass
+		elif tmo == 0:
+			self._return_job()
+		else:
+			self.timer_id = GObject.timeout_add_seconds(
+				tmo, RequestEntry._request_timeout, self)
+
+	@staticmethod
+	def _request_timeout(r):
+		"""
+		Method which gets called when the timer runs out!
+		:param r:  RequestEntry which timed out
+		:return: Nothing
+		"""
+		r.timer_expired()
+
+	def _return_job(self):
+		self._job = Job(self)
+		cfg.om.register_object(self._job, True)
+		if self._return_tuple:
+			self.cb(('/', self._job.dbus_object_path()))
+		else:
+			self.cb(self._job.dbus_object_path())
+
+	def run_cmd(self):
+		try:
+			result = self.method(*self.arguments)
+			self.register_result(result)
+		except Exception:
+			# Use the request entry to return the result as the client may
+			# have gotten a job by the time we hit an error
+			# Lets get the stacktrace and set that to the error message
+			st = traceback.format_exc()
+			log_error("Exception returned to client: \n%s" % st)
+			self.register_error(-1, st)
+
+	def is_done(self):
+		with self.lock:
+			rc = self.done
+		return rc
+
+	def get_errors(self):
+		with self.lock:
+			return (self._rc, self._rc_error)
+
+	def result(self):
+		with self.lock:
+			if self.done:
+				return self._result
+			return '/'
+
+	def _reg_ending(self, result, error_rc=0, error=None):
+		with self.lock:
+			self.done = True
+			if self.timer_id != -1:
+				# Try to prevent the timer from firing
+				GObject.source_remove(self.timer_id)
+
+			self._result = result
+			self._rc = error_rc
+			self._rc_error = error
+
+			if not self._job:
+				# We finished and there is no job, so return result or error
+				# now!
+				# Note: If we don't have a valid cb or cbe, this indicates a
+				# request that doesn't need a response as we already returned
+				# one before the request was processed.
+				if error_rc == 0:
+					if self.cb:
+						if self._return_tuple:
+							self.cb((result, '/'))
+						else:
+							self.cb(result)
+				else:
+					if self.cb_error:
+						self.cb_error(self._rc_error)
+			else:
+				# We have a job and it's complete, indicate that it's done.
+				# TODO: We need to signal the job is done too.
+				self._job.Complete = True
+				self._job = None
+
+	def register_error(self, error_rc, error):
+		self._reg_ending(None, error_rc, error)
+
+	def register_result(self, result):
+		self._reg_ending(result)
+
+	def timer_expired(self):
+		with self.lock:
+			# Set the timer back to -1 as we will get a warning if we try
+			# to remove a timer that doesn't exist
+			self.timer_id = -1
+			if not self.done:
+				# Create dbus job object and return path to caller
+				self._return_job()
+			else:
+				# The job is done, we have nothing to do
+				pass
+
+		return False
diff --git a/daemons/lvmdbusd/state.py b/daemons/lvmdbusd/state.py
new file mode 100644
index 0000000..bbc5901
--- /dev/null
+++ b/daemons/lvmdbusd/state.py
@@ -0,0 +1,27 @@
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+from abc import ABCMeta, abstractmethod
+
+
+class State(object, metaclass=ABCMeta):
+	@abstractmethod
+	def lvm_id(self):
+		pass
+
+	@abstractmethod
+	def identifiers(self):
+		pass
+
+	@abstractmethod
+	def create_dbus_object(self, path):
+		pass
+
+	def __str__(self):
+		return '*****\n' + str(self.__dict__) + '\n******\n'
diff --git a/daemons/lvmdbusd/udevwatch.py b/daemons/lvmdbusd/udevwatch.py
new file mode 100644
index 0000000..c3e6e60
--- /dev/null
+++ b/daemons/lvmdbusd/udevwatch.py
@@ -0,0 +1,54 @@
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+import pyudev
+from .refresh import event_add
+from . import cfg
+
+observer = None
+
+
+# noinspection PyUnusedLocal
+def filter_event(action, device):
+	# Filter for events of interest and add a request object to be processed
+	# when appropriate.
+	refresh = False
+
+	if '.ID_FS_TYPE_NEW' in device:
+		fs_type_new = device['.ID_FS_TYPE_NEW']
+
+		if 'LVM' in fs_type_new:
+			refresh = True
+		elif fs_type_new == '':
+			# Check to see if the device was one we knew about
+			if 'DEVNAME' in device:
+				found = cfg.om.get_object_by_lvm_id(device['DEVNAME'])
+				if found:
+					refresh = True
+
+	if 'DM_LV_NAME' in device:
+		refresh = True
+
+	if refresh:
+		event_add(('udev',))
+
+
+def add():
+	global observer
+	context = pyudev.Context()
+	monitor = pyudev.Monitor.from_netlink(context)
+	monitor.filter_by('block')
+	observer = pyudev.MonitorObserver(monitor, filter_event)
+	observer.start()
+
+
+def remove():
+	global observer
+	observer.stop()
+	observer = None
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
new file mode 100644
index 0000000..389f213
--- /dev/null
+++ b/daemons/lvmdbusd/utils.py
@@ -0,0 +1,388 @@
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+import xml.etree.ElementTree as Et
+import sys
+import inspect
+import ctypes
+import os
+
+import dbus
+import dbus.service
+import dbus.mainloop.glib
+
+try:
+	from . import cfg
+except SystemError:
+	import cfg
+
+STDOUT_TTY = os.isatty(sys.stdout.fileno())
+
+
+def rtype(dbus_type):
+	"""
+	Decorator making sure that the decorated function returns a value of
+	specified type.
+	:param dbus_type: The specific dbus type to return value as
+	"""
+
+	def decorator(fn):
+		def decorated(*args, **kwargs):
+			return dbus_type(fn(*args, **kwargs))
+
+		return decorated
+
+	return decorator
+
+
+# Field is expected to be a number, handle the corner cases when parsing
+ at rtype(dbus.UInt64)
+def n(v):
+	if not v:
+		return 0
+	return int(float(v))
+
+
+ at rtype(dbus.UInt32)
+def n32(v):
+	if not v:
+		return 0
+	return int(float(v))
+
+
+# noinspection PyProtectedMember
+def init_class_from_arguments(obj_instance):
+	for k, v in list(sys._getframe(1).f_locals.items()):
+		if k != 'self':
+			nt = k
+
+			# If the current attribute has a value, but the incoming does
+			# not, don't overwrite it.  Otherwise the default values on the
+			# property decorator don't work as expected.
+			cur = getattr(obj_instance, nt, v)
+
+			# print 'Init class %s = %s' % (nt, str(v))
+			if not (cur and len(str(cur)) and (v is None or len(str(v))) == 0):
+				setattr(obj_instance, nt, v)
+
+
+def get_properties(f):
+	"""
+	Walks through an object instance or it's parent class(es) and determines
+	which attributes are properties and if they were created to be used for
+	dbus.
+	:param f:   Object to inspect
+	:return:    A dictionary of tuples with each tuple being:
+				0 = An array of dicts with the keys being: p_t, p_name,
+				p_access(type, name, access)
+				1 = Hash of property names and current value
+	"""
+	interfaces = dict()
+
+	for c in inspect.getmro(f.__class__):
+
+		h = vars(c)
+		for p, value in h.items():
+			if isinstance(value, property):
+				# We found a property, see if it has a metadata type
+				key = attribute_type_name(p)
+				if key in h:
+					interface = h[key][1]
+
+					if interface not in interfaces:
+						interfaces[interface] = ([], {})
+
+					access = ''
+					if getattr(f.__class__, p).fget:
+						access += 'read'
+					if getattr(f.__class__, p).fset:
+						access += 'write'
+
+					interfaces[interface][0].append(
+						dict(
+							p_t=getattr(f, key)[0],
+							p_name=p,
+							p_access=access))
+
+					interfaces[interface][1][p] = getattr(f, p)
+
+	return interfaces
+
+
+def get_object_property_diff(o_prop, n_prop):
+	"""
+	Walk through each object properties and report what has changed and with
+	the new values
+	:param o_prop:   Old keys/values
+	:param n_prop:   New keys/values
+	:return: hash of properties that have changed and their new value
+	"""
+	rc = {}
+
+	for intf_k, intf_v in o_prop.items():
+		for k, v in list(intf_v[1].items()):
+			# print('Comparing %s:%s to %s:%s' %
+			#      (k, o_prop[intf_k][1][k], k, str(n_prop[intf_k][1][k])))
+			if o_prop[intf_k][1][k] != n_prop[intf_k][1][k]:
+				new_value = n_prop[intf_k][1][k]
+
+				if intf_k not in rc:
+					rc[intf_k] = dict()
+
+				rc[intf_k][k] = new_value
+	return rc
+
+
+def add_properties(xml, interface, props):
+	"""
+	Given xml that describes the interface, add property values to the XML
+	for the specified interface.
+	:param xml:         XML to edit
+	:param interface:   Interface to add the properties too
+	:param props:       Output from get_properties
+	:return: updated XML string
+	"""
+	root = Et.fromstring(xml)
+
+	if props:
+
+		for c in root:
+			# print c.attrib['name']
+			if c.attrib['name'] == interface:
+				for p in props:
+					temp = '<property type="%s" name="%s" access="%s"/>\n' % \
+						(p['p_t'], p['p_name'], p['p_access'])
+					c.append(Et.fromstring(temp))
+
+		return Et.tostring(root, encoding='utf8')
+	return xml
+
+
+def attribute_type_name(name):
+	"""
+	Given the property name, return string of the attribute type
+	:param name:
+	:return:
+	"""
+	return "_%s_meta" % name
+
+
+_type_map = dict(
+	s=dbus.String,
+	o=dbus.ObjectPath,
+	t=dbus.UInt64,
+	x=dbus.Int64,
+	u=dbus.UInt32,
+	i=dbus.Int32,
+	n=dbus.Int16,
+	q=dbus.UInt16,
+	d=dbus.Double,
+	y=dbus.Byte,
+	b=dbus.Boolean)
+
+
+def _pass_through(v):
+	"""
+	If we have something which is not a simple type we return the original
+	value un-wrapped.
+	:param v:
+	:return:
+	"""
+	return v
+
+
+def _dbus_type(t, value):
+	return _type_map.get(t, _pass_through)(value)
+
+
+def dbus_property(interface_name, name, dbus_type, doc=None):
+	"""
+	Creates the get/set properties for the given name.  It assumes that the
+	actual attribute is '_' + name and the attribute metadata is stuffed in
+	_name_type.
+
+	There is probably a better way todo this.
+	:param interface_name:  Dbus interface this property is associated with
+	:param name:            Name of property
+	:param dbus_type:       dbus string type eg. s,t,i,x
+	:param doc:             Python __doc__ for the property
+	:return:
+	"""
+	attribute_name = '_' + name
+
+	def getter(self):
+		t = getattr(self, attribute_name + '_meta')[0]
+		return _dbus_type(t, getattr(self.state, attribute_name[1:]))
+
+	prop = property(getter, None, None, doc)
+
+	def decorator(cls):
+		setattr(cls, attribute_name + '_meta', (dbus_type, interface_name))
+		setattr(cls, name, prop)
+		return cls
+
+	return decorator
+
+
+def parse_tags(tags):
+	if len(tags):
+		if ',' in tags:
+			return tags.split(',')
+		return sorted([tags])
+	return dbus.Array([], signature='s')
+
+
+def _common_log(msg, *attributes):
+	cfg.stdout_lock.acquire()
+	tid = ctypes.CDLL('libc.so.6').syscall(186)
+
+	msg = "%d:%d - %s" % (os.getpid(), tid, msg)
+
+	if STDOUT_TTY and attributes:
+		print(color(msg, *attributes))
+	else:
+		print(msg)
+
+	cfg.stdout_lock.release()
+	sys.stdout.flush()
+
+
+# Serializes access to stdout to prevent interleaved output
+# @param msg    Message to output to stdout
+# @return None
+def log_debug(msg, *attributes):
+	if cfg.DEBUG:
+		_common_log(msg, *attributes)
+
+
+def log_error(msg, *attributes):
+	_common_log(msg, *attributes)
+
+
+# noinspection PyUnusedLocal
+def handler(signum, frame):
+	cfg.run.value = 0
+	log_debug('Signal handler called with signal %d' % signum)
+	if cfg.loop is not None:
+		cfg.loop.quit()
+
+
+def pv_obj_path_generate():
+	return cfg.PV_OBJ_PATH + "/%d" % next(cfg.pv_id)
+
+
+def vg_obj_path_generate():
+	return cfg.VG_OBJ_PATH + "/%d" % next(cfg.vg_id)
+
+
+def lv_object_path_method(name, meta):
+	if name[0] == '[':
+		return _hidden_lv_obj_path_generate
+	elif meta[0][0] == 't':
+		return _thin_pool_obj_path_generate
+	elif meta[0][0] == 'C' and 'pool' in meta[1]:
+		return _cache_pool_obj_path_generate
+
+	return _lv_obj_path_generate
+
+
+# Note: None of the individual LV path generate functions should be called
+# directly, they should only be dispatched through lv_object_path_method
+
+def _lv_obj_path_generate():
+	return cfg.LV_OBJ_PATH + "/%d" % next(cfg.lv_id)
+
+
+def _thin_pool_obj_path_generate():
+	return cfg.THIN_POOL_PATH + "/%d" % next(cfg.thin_id)
+
+
+def _cache_pool_obj_path_generate():
+	return cfg.CACHE_POOL_PATH + "/%d" % next(cfg.cache_pool_id)
+
+
+def _hidden_lv_obj_path_generate():
+	return cfg.HIDDEN_LV_PATH + "/%d" % next(cfg.hidden_lv)
+
+
+def job_obj_path_generate():
+	return cfg.JOB_OBJ_PATH + "/%d" % next(cfg.job_id)
+
+
+def color(text, *user_styles):
+	styles = {
+		# styles
+		'reset': '\033[0m',
+		'bold': '\033[01m',
+		'disabled': '\033[02m',
+		'underline': '\033[04m',
+		'reverse': '\033[07m',
+		'strike_through': '\033[09m',
+		'invisible': '\033[08m',
+		# text colors
+		'fg_black': '\033[30m',
+		'fg_red': '\033[31m',
+		'fg_green': '\033[32m',
+		'fg_orange': '\033[33m',
+		'fg_blue': '\033[34m',
+		'fg_purple': '\033[35m',
+		'fg_cyan': '\033[36m',
+		'fg_light_grey': '\033[37m',
+		'fg_dark_grey': '\033[90m',
+		'fg_light_red': '\033[91m',
+		'fg_light_green': '\033[92m',
+		'fg_yellow': '\033[93m',
+		'fg_light_blue': '\033[94m',
+		'fg_pink': '\033[95m',
+		'fg_light_cyan': '\033[96m',
+		# background colors
+		'bg_black': '\033[40m',
+		'bg_red': '\033[41m',
+		'bg_green': '\033[42m',
+		'bg_orange': '\033[43m',
+		'bg_blue': '\033[44m',
+		'bg_purple': '\033[45m',
+		'bg_cyan': '\033[46m',
+		'bg_light_grey': '\033[47m'
+	}
+
+	color_text = ''
+	for style in user_styles:
+		try:
+			color_text += styles[style]
+		except KeyError:
+			return 'def color: parameter {} does not exist'.format(style)
+	color_text += text
+	return '\033[0m{0}\033[0m'.format(color_text)
+
+
+def pv_range_append(cmd, device, start, end):
+	if (start, end) == (0, 0):
+		cmd.append(device)
+	else:
+		if start != 0 and end == 0:
+			cmd.append("%s:%d-" % (device, start))
+		else:
+			cmd.append(
+				"%s:%d-%d" %
+				(device, start, end))
+
+
+def pv_dest_ranges(cmd, pv_dest_range_list):
+	if len(pv_dest_range_list):
+		for i in pv_dest_range_list:
+			pv_range_append(cmd, *i)
+
+
+def round_size(size_bytes):
+	bs = 512
+	remainder = size_bytes % bs
+	if not remainder:
+		return size_bytes
+	return size_bytes + bs - remainder
diff --git a/daemons/lvmdbusd/vg.py b/daemons/lvmdbusd/vg.py
new file mode 100644
index 0000000..c277412
--- /dev/null
+++ b/daemons/lvmdbusd/vg.py
@@ -0,0 +1,936 @@
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+from .automatedproperties import AutomatedProperties
+
+from . import utils
+from .utils import pv_obj_path_generate, vg_obj_path_generate, n
+import dbus
+from . import cfg
+from .cfg import VG_INTERFACE
+from . import cmdhandler
+from .request import RequestEntry
+from .loader import common
+from .state import State
+from . import background
+from .utils import round_size
+
+
+# noinspection PyUnusedLocal
+def vgs_state_retrieve(selection, cache_refresh=True):
+	rc = []
+
+	if cache_refresh:
+		cfg.db.refresh()
+
+	for v in cfg.db.fetch_vgs(selection):
+		rc.append(
+			VgState(
+				v['vg_uuid'], v['vg_name'], v['vg_fmt'], n(v['vg_size']),
+				n(v['vg_free']), v['vg_sysid'], n(v['vg_extent_size']),
+				n(v['vg_extent_count']), n(v['vg_free_count']),
+				v['vg_profile'], n(v['max_lv']), n(v['max_pv']),
+				n(v['pv_count']), n(v['lv_count']), n(v['snap_count']),
+				n(v['vg_seqno']), n(v['vg_mda_count']),
+				n(v['vg_mda_free']), n(v['vg_mda_size']),
+				n(v['vg_mda_used_count']), v['vg_attr'], v['vg_tags']))
+	return rc
+
+
+def load_vgs(vg_specific=None, object_path=None, refresh=False,
+		emit_signal=False, cache_refresh=True):
+	return common(vgs_state_retrieve, (Vg,), vg_specific, object_path, refresh,
+					emit_signal, cache_refresh)
+
+
+# noinspection PyPep8Naming,PyUnresolvedReferences,PyUnusedLocal
+class VgState(State):
+	@property
+	def lvm_id(self):
+		return self.Name
+
+	def identifiers(self):
+		return (self.Uuid, self.Name)
+
+	def _lv_paths_build(self):
+		rc = []
+		for lv in cfg.db.lvs_in_vg(self.Uuid):
+			(lv_name, meta, lv_uuid) = lv
+			full_name = "%s/%s" % (self.Name, lv_name)
+
+			gen = utils.lv_object_path_method(lv_name, meta)
+
+			lv_path = cfg.om.get_object_path_by_lvm_id(
+				lv_uuid, full_name, gen)
+			rc.append(lv_path)
+		return dbus.Array(rc, signature='o')
+
+	def _pv_paths_build(self):
+		rc = []
+		for p in cfg.db.pvs_in_vg(self.Uuid):
+			(pv_name, pv_uuid) = p
+			rc.append(cfg.om.get_object_path_by_lvm_id(
+				pv_uuid, pv_name, pv_obj_path_generate))
+		return dbus.Array(rc, signature='o')
+
+	def __init__(self, Uuid, Name, Fmt,
+			SizeBytes, FreeBytes, SysId, ExtentSizeBytes,
+			ExtentCount, FreeCount, Profile, MaxLv, MaxPv, PvCount,
+			LvCount, SnapCount, Seqno, MdaCount, MdaFree,
+			MdaSizeBytes, MdaUsedCount, attr, tags):
+		utils.init_class_from_arguments(self)
+		self.Pvs = self._pv_paths_build()
+		self.Lvs = self._lv_paths_build()
+
+	def create_dbus_object(self, path):
+		if not path:
+			path = cfg.om.get_object_path_by_lvm_id(
+				self.Uuid, self.Name, vg_obj_path_generate)
+		return Vg(path, self)
+
+	# noinspection PyMethodMayBeStatic
+	def creation_signature(self):
+		return (Vg, vg_obj_path_generate)
+
+
+# noinspection PyPep8Naming
+ at utils.dbus_property(VG_INTERFACE, 'Uuid', 's')
+ at utils.dbus_property(VG_INTERFACE, 'Name', 's')
+ at utils.dbus_property(VG_INTERFACE, 'Fmt', 's')
+ at utils.dbus_property(VG_INTERFACE, 'SizeBytes', 't', 0)
+ at utils.dbus_property(VG_INTERFACE, 'FreeBytes', 't', 0)
+ at utils.dbus_property(VG_INTERFACE, 'SysId', 's')
+ at utils.dbus_property(VG_INTERFACE, 'ExtentSizeBytes', 't')
+ at utils.dbus_property(VG_INTERFACE, 'ExtentCount', 't')
+ at utils.dbus_property(VG_INTERFACE, 'FreeCount', 't')
+ at utils.dbus_property(VG_INTERFACE, 'Profile', 's')
+ at utils.dbus_property(VG_INTERFACE, 'MaxLv', 't')
+ at utils.dbus_property(VG_INTERFACE, 'MaxPv', 't')
+ at utils.dbus_property(VG_INTERFACE, 'PvCount', 't')
+ at utils.dbus_property(VG_INTERFACE, 'LvCount', 't')
+ at utils.dbus_property(VG_INTERFACE, 'SnapCount', 't')
+ at utils.dbus_property(VG_INTERFACE, 'Seqno', 't')
+ at utils.dbus_property(VG_INTERFACE, 'MdaCount', 't')
+ at utils.dbus_property(VG_INTERFACE, 'MdaFree', 't')
+ at utils.dbus_property(VG_INTERFACE, 'MdaSizeBytes', 't')
+ at utils.dbus_property(VG_INTERFACE, 'MdaUsedCount', 't')
+class Vg(AutomatedProperties):
+	_Tags_meta = ("as", VG_INTERFACE)
+	_Pvs_meta = ("ao", VG_INTERFACE)
+	_Lvs_meta = ("ao", VG_INTERFACE)
+	_Writeable_meta = ("b", VG_INTERFACE)
+	_Readable_meta = ("b", VG_INTERFACE)
+	_Resizeable_meta = ("b", VG_INTERFACE)
+	_Exportable_meta = ('b', VG_INTERFACE)
+	_Partial_meta = ('b', VG_INTERFACE)
+	_AllocContiguous_meta = ('b', VG_INTERFACE)
+	_AllocCling_meta = ('b', VG_INTERFACE)
+	_AllocNormal_meta = ('b', VG_INTERFACE)
+	_AllocAnywhere_meta = ('b', VG_INTERFACE)
+	_Clustered_meta = ('b', VG_INTERFACE)
+
+	# noinspection PyUnusedLocal,PyPep8Naming
+	def __init__(self, object_path, object_state):
+		super(Vg, self).__init__(object_path, vgs_state_retrieve)
+		self.set_interface(VG_INTERFACE)
+		self._object_path = object_path
+		self.state = object_state
+
+	@staticmethod
+	def fetch_new_lv(vg_name, lv_name):
+		full_name = "%s/%s" % (vg_name, lv_name)
+
+		cfg.load()
+		l = cfg.om.get_object_by_lvm_id(full_name)
+		created_lv = l.dbus_object_path()
+
+		return created_lv
+
+	@staticmethod
+	def _rename(uuid, vg_name, new_name, rename_options):
+		# Make sure we have a dbus object representing it
+		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
+
+		if dbo:
+			rc, out, err = cmdhandler.vg_rename(vg_name, new_name,
+												rename_options)
+			if rc == 0:
+				cfg.load()
+			else:
+				# Need to work on error handling, need consistent
+				raise dbus.exceptions.DBusException(
+					VG_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+		else:
+			raise dbus.exceptions.DBusException(
+				VG_INTERFACE,
+				'VG with uuid %s and name %s not present!' %
+				(uuid, vg_name))
+		return '/'
+
+	@dbus.service.method(
+		dbus_interface=VG_INTERFACE,
+		in_signature='sia{sv}', out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def Rename(self, name, tmo, rename_options, cb, cbe):
+		r = RequestEntry(tmo, Vg._rename,
+				(self.state.Uuid, self.state.lvm_id, name,
+				rename_options), cb, cbe, False)
+		cfg.worker_q.put(r)
+
+	@staticmethod
+	def _remove(uuid, vg_name, remove_options):
+		# Make sure we have a dbus object representing it
+		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
+
+		if dbo:
+			# Remove the VG, if successful then remove from the model
+			rc, out, err = cmdhandler.vg_remove(vg_name, remove_options)
+
+			if rc == 0:
+				# Remove the VG
+				cfg.om.remove_object(dbo, True)
+
+				# If an LV has hidden LVs, things can get quite involved,
+				# especially if it's the last thin pool to get removed, so
+				# lets refresh all
+				cfg.load()
+
+			else:
+				# Need to work on error handling, need consistent
+				raise dbus.exceptions.DBusException(
+					VG_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+		else:
+			raise dbus.exceptions.DBusException(
+				VG_INTERFACE,
+				'VG with uuid %s and name %s not present!' %
+				(uuid, vg_name))
+		return '/'
+
+	@dbus.service.method(
+		dbus_interface=VG_INTERFACE,
+		in_signature='ia{sv}', out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def Remove(self, tmo, remove_options, cb, cbe):
+		r = RequestEntry(tmo, Vg._remove,
+				(self.state.Uuid, self.state.lvm_id, remove_options),
+				cb, cbe, False)
+		cfg.worker_q.put(r)
+
+	@staticmethod
+	def _change(uuid, vg_name, change_options):
+		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
+
+		if dbo:
+			rc, out, err = cmdhandler.vg_change(change_options, vg_name)
+
+			# To use an example with d-feet (Method input)
+			# {"activate": __import__('gi.repository.GLib', globals(),
+			# locals(), ['Variant']).Variant("s", "n")}
+
+			if rc == 0:
+				dbo.refresh()
+
+				if (('activate' in change_options) or ('-a' in change_options)):
+					cfg.load()
+			else:
+				raise dbus.exceptions.DBusException(
+					VG_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+		else:
+			raise dbus.exceptions.DBusException(
+				VG_INTERFACE,
+				'VG with uuid %s and name %s not present!' %
+				(uuid, vg_name))
+		return '/'
+
+	# TODO: This should be broken into a number of different methods
+	# instead of having one method that takes a hash for parameters.  Some of
+	# the changes that vgchange does works on entire system, not just a
+	# specfic vg, thus that should be in the Manager interface.
+	@dbus.service.method(
+		dbus_interface=VG_INTERFACE,
+		in_signature='ia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def Change(self, tmo, change_options, cb, cbe):
+		r = RequestEntry(tmo, Vg._change,
+				(self.state.Uuid, self.state.lvm_id, change_options),
+				cb, cbe, False)
+		cfg.worker_q.put(r)
+
+	@staticmethod
+	def _reduce(uuid, vg_name, missing, pv_object_paths, reduce_options):
+		# Make sure we have a dbus object representing it
+		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
+
+		if dbo:
+			pv_devices = []
+
+			# If pv_object_paths is not empty, then get the device paths
+			if pv_object_paths and len(pv_object_paths) > 0:
+				for pv_op in pv_object_paths:
+					pv = cfg.om.get_object_by_path(pv_op)
+					if pv:
+						pv_devices.append(pv.lvm_id)
+					else:
+						raise dbus.exceptions.DBusException(
+							VG_INTERFACE,
+							'PV Object path not found = %s!' % pv_op)
+
+			rc, out, err = cmdhandler.vg_reduce(vg_name, missing, pv_devices,
+												reduce_options)
+			if rc == 0:
+				cfg.load()
+			else:
+				raise dbus.exceptions.DBusException(
+					VG_INTERFACE, 'Exit code %s, stderr = %s' % (str(rc), err))
+		else:
+			raise dbus.exceptions.DBusException(
+				VG_INTERFACE,
+				'VG with uuid %s and name %s not present!' %
+				(uuid, vg_name))
+		return '/'
+
+	@dbus.service.method(
+		dbus_interface=VG_INTERFACE,
+		in_signature='baoia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def Reduce(self, missing, pv_object_paths, tmo, reduce_options, cb, cbe):
+		r = RequestEntry(tmo, Vg._reduce,
+				(self.state.Uuid, self.state.lvm_id, missing,
+				pv_object_paths, reduce_options), cb, cbe, False)
+		cfg.worker_q.put(r)
+
+	@staticmethod
+	def _extend(uuid, vg_name, pv_object_paths, extend_options):
+		# Make sure we have a dbus object representing it
+		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
+
+		if dbo:
+			extend_devices = []
+
+			for i in pv_object_paths:
+				pv = cfg.om.get_object_by_path(i)
+				if pv:
+					extend_devices.append(pv.lvm_id)
+				else:
+					raise dbus.exceptions.DBusException(
+						VG_INTERFACE, 'PV Object path not found = %s!' % i)
+
+			if len(extend_devices):
+				rc, out, err = cmdhandler.vg_extend(vg_name, extend_devices,
+													extend_options)
+				if rc == 0:
+					cfg.load()
+				else:
+					raise dbus.exceptions.DBusException(
+						VG_INTERFACE,
+						'Exit code %s, stderr = %s' % (str(rc), err))
+			else:
+				raise dbus.exceptions.DBusException(
+					VG_INTERFACE, 'No pv_object_paths provided!')
+		else:
+			raise dbus.exceptions.DBusException(
+				VG_INTERFACE,
+				'VG with uuid %s and name %s not present!' %
+				(uuid, vg_name))
+		return '/'
+
+	@dbus.service.method(
+		dbus_interface=VG_INTERFACE,
+		in_signature='aoia{sv}', out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def Extend(self, pv_object_paths, tmo, extend_options, cb, cbe):
+		r = RequestEntry(tmo, Vg._extend,
+				(self.state.Uuid, self.state.lvm_id, pv_object_paths,
+				extend_options),
+				cb, cbe, False)
+		cfg.worker_q.put(r)
+
+	@dbus.service.method(
+		dbus_interface=VG_INTERFACE,
+		in_signature='o(tt)a(ott)ia{sv}',
+		out_signature='o')
+	def Move(self, pv_src_obj, pv_source_range, pv_dests_and_ranges,
+			tmo, move_options):
+		return background.move(
+			VG_INTERFACE, None, pv_src_obj, pv_source_range,
+			pv_dests_and_ranges, move_options, tmo)
+
+	@staticmethod
+	def _lv_create(uuid, vg_name, name, size_bytes, pv_dests_and_ranges,
+			create_options):
+		# Make sure we have a dbus object representing it
+		pv_dests = []
+		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
+
+		if dbo:
+			if len(pv_dests_and_ranges):
+				for pr in pv_dests_and_ranges:
+					pv_dbus_obj = cfg.om.get_object_by_path(pr[0])
+					if not pv_dbus_obj:
+						raise dbus.exceptions.DBusException(
+							VG_INTERFACE,
+							'PV Destination (%s) not found' % pr[0])
+
+					pv_dests.append((pv_dbus_obj.lvm_id, pr[1], pr[2]))
+
+			rc, out, err = cmdhandler.vg_lv_create(
+				vg_name, create_options, name, size_bytes, pv_dests)
+
+			if rc == 0:
+				return Vg.fetch_new_lv(vg_name, name)
+			else:
+				raise dbus.exceptions.DBusException(
+					VG_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+		else:
+			raise dbus.exceptions.DBusException(
+				VG_INTERFACE,
+				'VG with uuid %s and name %s not present!' %
+				(uuid, vg_name))
+
+	@dbus.service.method(
+		dbus_interface=VG_INTERFACE,
+		in_signature='sta(ott)ia{sv}',
+		out_signature='(oo)',
+		async_callbacks=('cb', 'cbe'))
+	def LvCreate(self, name, size_bytes, pv_dests_and_ranges,
+			tmo, create_options, cb, cbe):
+		"""
+		This one it for the advanced users that want to roll their own
+		:param name:            Name of the LV
+		:param size_bytes:      Size of LV in bytes
+		:param pv_dests_and_ranges:   Optional array of PV object paths and
+									ranges
+		:param tmo: -1 == Wait forever, 0 == return job immediately, > 0 ==
+							willing to wait that number of seconds before
+							getting a job
+		:param create_options:  hash of key/value pairs
+		:param cb: Internal, not accessible by dbus API user
+		:param cbe: Internal, not accessible by dbus API user
+		:return: (oo) First object path is newly created object, second is
+					job object path if created.  Each == '/' when it doesn't
+					apply.
+		"""
+		r = RequestEntry(tmo, Vg._lv_create,
+				(self.state.Uuid, self.state.lvm_id,
+				name, round_size(size_bytes), pv_dests_and_ranges,
+				create_options), cb, cbe)
+		cfg.worker_q.put(r)
+
+	@staticmethod
+	def _lv_create_linear(uuid, vg_name, name, size_bytes,
+			thin_pool, create_options):
+		# Make sure we have a dbus object representing it
+		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
+
+		if dbo:
+			rc, out, err = cmdhandler.vg_lv_create_linear(
+				vg_name, create_options, name, size_bytes, thin_pool)
+
+			if rc == 0:
+				created_lv = Vg.fetch_new_lv(vg_name, name)
+			else:
+				raise dbus.exceptions.DBusException(
+					VG_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+		else:
+			raise dbus.exceptions.DBusException(
+				VG_INTERFACE,
+				'VG with uuid %s and name %s not present!' %
+				(uuid, vg_name))
+
+		return created_lv
+
+	@dbus.service.method(
+		dbus_interface=VG_INTERFACE,
+		in_signature='stbia{sv}',
+		out_signature='(oo)',
+		async_callbacks=('cb', 'cbe'))
+	def LvCreateLinear(self, name, size_bytes,
+			thin_pool, tmo, create_options, cb, cbe):
+		r = RequestEntry(tmo, Vg._lv_create_linear,
+						(self.state.Uuid, self.state.lvm_id,
+						name, round_size(size_bytes), thin_pool,
+						create_options), cb, cbe)
+		cfg.worker_q.put(r)
+
+	@staticmethod
+	def _lv_create_striped(uuid, vg_name, name, size_bytes, num_stripes,
+			stripe_size_kb, thin_pool, create_options):
+		# Make sure we have a dbus object representing it
+		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
+
+		if dbo:
+			rc, out, err = cmdhandler.vg_lv_create_striped(
+				vg_name, create_options, name, size_bytes,
+				num_stripes, stripe_size_kb, thin_pool)
+			if rc == 0:
+				created_lv = Vg.fetch_new_lv(vg_name, name)
+			else:
+				raise dbus.exceptions.DBusException(
+					VG_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+		else:
+			raise dbus.exceptions.DBusException(
+				VG_INTERFACE, 'VG with uuid %s and name %s not present!' %
+				(uuid, vg_name))
+
+		return created_lv
+
+	@dbus.service.method(
+		dbus_interface=VG_INTERFACE,
+		in_signature='stuubia{sv}',
+		out_signature='(oo)',
+		async_callbacks=('cb', 'cbe'))
+	def LvCreateStriped(self, name, size_bytes, num_stripes,
+						stripe_size_kb, thin_pool, tmo, create_options,
+						cb, cbe):
+		r = RequestEntry(
+				tmo, Vg._lv_create_striped,
+				(self.state.Uuid, self.state.lvm_id, name,
+				round_size(size_bytes), num_stripes, stripe_size_kb,
+				thin_pool, create_options),
+				cb, cbe)
+		cfg.worker_q.put(r)
+
+	@staticmethod
+	def _lv_create_mirror(uuid, vg_name, name, size_bytes,
+			num_copies, create_options):
+		# Make sure we have a dbus object representing it
+		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
+
+		if dbo:
+			rc, out, err = cmdhandler.vg_lv_create_mirror(
+				vg_name, create_options, name, size_bytes, num_copies)
+			if rc == 0:
+				created_lv = Vg.fetch_new_lv(vg_name, name)
+			else:
+				raise dbus.exceptions.DBusException(
+					VG_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+
+		else:
+			raise dbus.exceptions.DBusException(
+				VG_INTERFACE,
+				'VG with uuid %s and name %s not present!' %
+				(uuid, vg_name))
+
+		return created_lv
+
+	@dbus.service.method(
+		dbus_interface=VG_INTERFACE,
+		in_signature='stuia{sv}',
+		out_signature='(oo)',
+		async_callbacks=('cb', 'cbe'))
+	def LvCreateMirror(self, name, size_bytes, num_copies,
+			tmo, create_options, cb, cbe):
+		r = RequestEntry(
+			tmo, Vg._lv_create_mirror,
+			(self.state.Uuid, self.state.lvm_id, name,
+			round_size(size_bytes), num_copies,
+			create_options), cb, cbe)
+		cfg.worker_q.put(r)
+
+	@staticmethod
+	def _lv_create_raid(uuid, vg_name, name, raid_type, size_bytes,
+						num_stripes, stripe_size_kb, create_options):
+		# Make sure we have a dbus object representing it
+		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
+
+		if dbo:
+			rc, out, err = cmdhandler.vg_lv_create_raid(
+				vg_name, create_options, name, raid_type, size_bytes,
+				num_stripes, stripe_size_kb)
+			if rc == 0:
+				created_lv = Vg.fetch_new_lv(vg_name, name)
+			else:
+				raise dbus.exceptions.DBusException(
+					VG_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+
+		else:
+			raise dbus.exceptions.DBusException(
+				VG_INTERFACE,
+				'VG with uuid %s and name %s not present!' %
+				(uuid, vg_name))
+
+		return created_lv
+
+	@dbus.service.method(
+		dbus_interface=VG_INTERFACE,
+		in_signature='sstuuia{sv}',
+		out_signature='(oo)',
+		async_callbacks=('cb', 'cbe'))
+	def LvCreateRaid(self, name, raid_type, size_bytes,
+			num_stripes, stripe_size_kb, tmo,
+			create_options, cb, cbe):
+		r = RequestEntry(tmo, Vg._lv_create_raid,
+				(self.state.Uuid, self.state.lvm_id, name,
+				raid_type, round_size(size_bytes), num_stripes,
+				stripe_size_kb, create_options), cb, cbe)
+		cfg.worker_q.put(r)
+
+	@staticmethod
+	def _create_pool(uuid, vg_name, meta_data_lv, data_lv,
+						create_options, create_method):
+		# Make sure we have a dbus object representing it
+		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
+
+		# Retrieve the full names for the metadata and data lv
+		md = cfg.om.get_object_by_path(meta_data_lv)
+		data = cfg.om.get_object_by_path(data_lv)
+
+		if dbo and md and data:
+
+			new_name = data.Name
+
+			rc, out, err = create_method(
+				md.lv_full_name(), data.lv_full_name(), create_options)
+			if rc == 0:
+				cfg.om.remove_object(md, emit_signal=True)
+				cfg.om.remove_object(data, emit_signal=True)
+
+				cache_pool_lv = Vg.fetch_new_lv(vg_name, new_name)
+			else:
+				raise dbus.exceptions.DBusException(
+					VG_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+
+		else:
+			msg = ""
+
+			if not dbo:
+				msg += 'VG with uuid %s and name %s not present!' % \
+					(uuid, vg_name)
+
+			if not md:
+				msg += 'Meta data LV with object path %s not present!' % \
+					(meta_data_lv)
+
+			if not data_lv:
+				msg += 'Data LV with object path %s not present!' % \
+					(meta_data_lv)
+
+			raise dbus.exceptions.DBusException(VG_INTERFACE, msg)
+
+		return cache_pool_lv
+
+	@dbus.service.method(
+		dbus_interface=VG_INTERFACE,
+		in_signature='ooia{sv}',
+		out_signature='(oo)',
+		async_callbacks=('cb', 'cbe'))
+	def CreateCachePool(self, meta_data_lv, data_lv, tmo, create_options,
+						cb, cbe):
+		r = RequestEntry(
+			tmo, Vg._create_pool,
+			(self.state.Uuid, self.state.lvm_id, meta_data_lv,
+			data_lv, create_options, cmdhandler.vg_create_cache_pool), cb, cbe)
+		cfg.worker_q.put(r)
+
+	@dbus.service.method(
+		dbus_interface=VG_INTERFACE,
+		in_signature='ooia{sv}',
+		out_signature='(oo)',
+		async_callbacks=('cb', 'cbe'))
+	def CreateThinPool(self, meta_data_lv, data_lv, tmo, create_options,
+						cb, cbe):
+		r = RequestEntry(
+			tmo, Vg._create_pool,
+			(self.state.Uuid, self.state.lvm_id, meta_data_lv,
+			data_lv, create_options, cmdhandler.vg_create_thin_pool), cb, cbe)
+		cfg.worker_q.put(r)
+
+	@staticmethod
+	def _pv_add_rm_tags(uuid, vg_name, pv_object_paths, tags_add,
+						tags_del, tag_options):
+		pv_devices = []
+
+		# Make sure we have a dbus object representing it
+		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
+
+		if dbo:
+			# Check for existence of pv object paths
+			for p in pv_object_paths:
+				pv = cfg.om.get_object_by_path(p)
+				if pv:
+					pv_devices.append(pv.Name)
+				else:
+					raise dbus.exceptions.DBusException(
+						VG_INTERFACE, 'PV object path = %s not found' % p)
+
+			rc, out, err = cmdhandler.pv_tag(
+				pv_devices, tags_add, tags_del, tag_options)
+			if rc == 0:
+				cfg.load()
+				return '/'
+			else:
+				raise dbus.exceptions.DBusException(
+					VG_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+
+		else:
+			raise dbus.exceptions.DBusException(
+				VG_INTERFACE,
+				'VG with uuid %s and name %s not present!' %
+				(uuid, vg_name))
+
+	@dbus.service.method(
+		dbus_interface=VG_INTERFACE,
+		in_signature='aoasia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def PvTagsAdd(self, pvs, tags, tmo, tag_options, cb, cbe):
+		r = RequestEntry(tmo, Vg._pv_add_rm_tags,
+				(self.state.Uuid, self.state.lvm_id,
+				pvs, tags, None, tag_options),
+				cb, cbe, return_tuple=False)
+		cfg.worker_q.put(r)
+
+	@dbus.service.method(
+		dbus_interface=VG_INTERFACE,
+		in_signature='aoasia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def PvTagsDel(self, pvs, tags, tmo, tag_options, cb, cbe):
+		r = RequestEntry(
+			tmo, Vg._pv_add_rm_tags,
+			(self.state.Uuid, self.state.lvm_id,
+			pvs, None, tags, tag_options),
+			cb, cbe, return_tuple=False)
+		cfg.worker_q.put(r)
+
+	@staticmethod
+	def _vg_add_rm_tags(uuid, vg_name, tags_add, tags_del, tag_options):
+		# Make sure we have a dbus object representing it
+		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
+
+		if dbo:
+
+			rc, out, err = cmdhandler.vg_tag(
+				vg_name, tags_add, tags_del, tag_options)
+			if rc == 0:
+				dbo.refresh()
+				return '/'
+			else:
+				raise dbus.exceptions.DBusException(
+					VG_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+
+		else:
+			raise dbus.exceptions.DBusException(
+				VG_INTERFACE,
+				'VG with uuid %s and name %s not present!' %
+				(uuid, vg_name))
+
+	@dbus.service.method(
+		dbus_interface=VG_INTERFACE,
+		in_signature='asia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def TagsAdd(self, tags, tmo, tag_options, cb, cbe):
+		r = RequestEntry(tmo, Vg._vg_add_rm_tags,
+				(self.state.Uuid, self.state.lvm_id,
+				tags, None, tag_options),
+				cb, cbe, return_tuple=False)
+		cfg.worker_q.put(r)
+
+	@dbus.service.method(
+		dbus_interface=VG_INTERFACE,
+		in_signature='asia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def TagsDel(self, tags, tmo, tag_options, cb, cbe):
+		r = RequestEntry(tmo, Vg._vg_add_rm_tags,
+				(self.state.Uuid, self.state.lvm_id,
+				None, tags, tag_options),
+				cb, cbe, return_tuple=False)
+		cfg.worker_q.put(r)
+
+	@staticmethod
+	def _vg_change_set(uuid, vg_name, method, value, options):
+		# Make sure we have a dbus object representing it
+		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
+
+		if dbo:
+			rc, out, err = method(vg_name, value, options)
+			if rc == 0:
+				dbo.refresh()
+				return '/'
+			else:
+				raise dbus.exceptions.DBusException(
+					VG_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+
+		else:
+			raise dbus.exceptions.DBusException(
+				VG_INTERFACE,
+				'VG with uuid %s and name %s not present!' %
+				(uuid, vg_name))
+
+	@dbus.service.method(
+		dbus_interface=VG_INTERFACE,
+		in_signature='sia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def AllocationPolicySet(self, policy, tmo, policy_options, cb, cbe):
+		r = RequestEntry(tmo, Vg._vg_change_set,
+				(self.state.Uuid, self.state.lvm_id,
+				cmdhandler.vg_allocation_policy,
+				policy, policy_options),
+				cb, cbe, return_tuple=False)
+		cfg.worker_q.put(r)
+
+	@dbus.service.method(
+		dbus_interface=VG_INTERFACE,
+		in_signature='tia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def MaxPvSet(self, number, tmo, max_options, cb, cbe):
+		r = RequestEntry(tmo, Vg._vg_change_set,
+				(self.state.Uuid, self.state.lvm_id,
+				cmdhandler.vg_max_pv, number, max_options),
+				cb, cbe, return_tuple=False)
+		cfg.worker_q.put(r)
+
+	@dbus.service.method(
+		dbus_interface=VG_INTERFACE,
+		in_signature='ia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def UuidGenerate(self, tmo, options, cb, cbe):
+		r = RequestEntry(tmo, Vg._vg_change_set,
+				(self.state.Uuid, self.state.lvm_id,
+				cmdhandler.vg_uuid_gen, None, options),
+				cb, cbe, return_tuple=False)
+		cfg.worker_q.put(r)
+
+	def _attribute(self, pos, ch):
+		if self.state.attr[pos] == ch:
+			return True
+		return False
+
+	@dbus.service.method(
+		dbus_interface=VG_INTERFACE,
+		in_signature='tia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def MaxLvSet(self, number, tmo, max_options, cb, cbe):
+		r = RequestEntry(tmo, Vg._vg_change_set,
+				(self.state.Uuid, self.state.lvm_id,
+				cmdhandler.vg_max_lv, number, max_options),
+				cb, cbe, return_tuple=False)
+		cfg.worker_q.put(r)
+
+	@staticmethod
+	def _vg_activate_deactivate(uuid, vg_name, activate, control_flags,
+								options):
+		# Make sure we have a dbus object representing it
+		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
+
+		if dbo:
+			rc, out, err = cmdhandler.activate_deactivate(
+				'vgchange', vg_name, activate, control_flags, options)
+			if rc == 0:
+				cfg.load()
+				return '/'
+			else:
+				raise dbus.exceptions.DBusException(
+					VG_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+		else:
+			raise dbus.exceptions.DBusException(
+				VG_INTERFACE,
+				'VG with uuid %s and name %s not present!' %
+				(uuid, vg_name))
+
+	@dbus.service.method(
+		dbus_interface=VG_INTERFACE,
+		in_signature='tia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def Activate(self, control_flags, tmo, activate_options, cb, cbe):
+		r = RequestEntry(tmo, Vg._vg_activate_deactivate,
+				(self.state.Uuid, self.state.lvm_id, True,
+				control_flags, activate_options),
+				cb, cbe, return_tuple=False)
+		cfg.worker_q.put(r)
+
+	@dbus.service.method(
+		dbus_interface=VG_INTERFACE,
+		in_signature='tia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def Deactivate(self, control_flags, tmo, activate_options, cb, cbe):
+		r = RequestEntry(tmo, Vg._vg_activate_deactivate,
+				(self.state.Uuid, self.state.lvm_id, False,
+				control_flags, activate_options),
+				cb, cbe, return_tuple=False)
+		cfg.worker_q.put(r)
+
+	@property
+	def Tags(self):
+		return utils.parse_tags(self.state.tags)
+
+	@property
+	def Pvs(self):
+		return self.state.Pvs
+
+	@property
+	def Lvs(self):
+		return self.state.Lvs
+
+	@property
+	def lvm_id(self):
+		return self.state.lvm_id
+
+	@property
+	def Writeable(self):
+		return self._attribute(0, 'w')
+
+	@property
+	def Readable(self):
+		return self._attribute(0, 'r')
+
+	@property
+	def Resizeable(self):
+		return self._attribute(1, 'z')
+
+	@property
+	def Exportable(self):
+		return self._attribute(2, 'x')
+
+	@property
+	def Partial(self):
+		return self._attribute(3, 'p')
+
+	@property
+	def AllocContiguous(self):
+		return self._attribute(4, 'c')
+
+	@property
+	def AllocCling(self):
+		return self._attribute(4, 'l')
+
+	@property
+	def AllocNormal(self):
+		return self._attribute(4, 'n')
+
+	@property
+	def AllocAnywhere(self):
+		return self._attribute(4, 'a')
+
+	@property
+	def Clustered(self):
+		return self._attribute(5, 'c')
diff --git a/make.tmpl.in b/make.tmpl.in
index a640851..d418cfb 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -39,7 +39,10 @@ LN_S = @LN_S@
 SED = @SED@
 CFLOW_CMD = @CFLOW_CMD@
 AWK = @AWK@
-PYTHON = @PYTHON@
+CHMOD = @CHMOD@
+PYTHON2 = @PYTHON2@
+PYTHON3 = @PYTHON3@
+PYCOMPILE = $(top_srcdir)/autoconf/py-compile
 
 LIBS = @LIBS@
 # Extra libraries always linked with static binaries
@@ -88,12 +91,18 @@ staticdir = $(DESTDIR)@STATICDIR@
 udevdir = $(DESTDIR)@udevdir@
 pkgconfigdir = $(usrlibdir)/pkgconfig
 initdir = $(DESTDIR)$(sysconfdir)/rc.d/init.d
+dbusconfdir = $(DESTDIR)$(sysconfdir)/dbus-1/system.d
+dbusservicedir = $(datadir)/dbus-1/system-services
 systemd_unit_dir = $(DESTDIR)@systemdsystemunitdir@
 systemd_generator_dir = $(DESTDIR)$(SYSTEMD_GENERATOR_DIR)
 systemd_dir = $(DESTDIR)@systemdutildir@
 tmpfiles_dir = $(DESTDIR)@tmpfilesdir@
 ocf_scriptdir = $(DESTDIR)@OCFDIR@
-pyexecdir = $(DESTDIR)$(prefix)
+pythonprefix = $(DESTDIR)$(prefix)
+
+# N.B. No $(DESTDIR) prefix here.
+python2dir = @PYTHON2DIR@
+python3dir = @PYTHON3DIR@
 
 USRLIB_RELPATH = $(shell echo $(abspath $(usrlibdir) $(libdir)) | \
   $(AWK) -f $(top_srcdir)/scripts/relpath.awk)
@@ -274,6 +283,7 @@ POTFILES = $(SOURCES:%.c=%.pot)
 
 .PHONY: all pofile distclean clean cleandir cflow device-mapper
 .PHONY: install install_cluster install_device-mapper install_lvm2
+.PHONY: install_dbus_service
 .PHONY: install_lib_shared install_dm_plugin install_lvm2_plugin
 .PHONY: install_ocf install_systemd_generators install_all_man all_man man help
 .PHONY: python_bindings install_python_bindings
diff --git a/man/Makefile.in b/man/Makefile.in
index 62034b2..2e0fd95 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -26,6 +26,7 @@ CLVMDMAN = clvmd.8
 CMIRRORDMAN = cmirrord.8
 LVMCACHEMAN = lvmcache.7
 LVMTHINMAN = lvmthin.7
+LVMDBUSDMAN = lvmdbusd.8
 
 MAN5=lvm.conf.5
 MAN7=lvmsystemid.7
@@ -51,7 +52,7 @@ ifeq ($(MAKECMDGOALS),install_all_man)
 endif
 
 ifeq ($(MAN_ALL),"yes")
-  MAN8+=$(FSADMMAN) $(LVMETADMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN)
+  MAN8+=$(FSADMMAN) $(LVMETADMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(LVMDBUSDMAN)
   MAN8DM+=$(BLKDEACTIVATEMAN) $(DMEVENTDMAN)
   MAN8CLUSTER+=$(CLVMDMAN) $(CMIRRORDMAN)
   MAN7+=$(LVMCACHEMAN) $(LVMTHINMAN)
@@ -60,6 +61,10 @@ else
     MAN8+=$(FSADMMAN)
   endif
 
+  ifeq ("@BUILD_LVMDBUSD@", "yes")
+    MAN8+=$(LVMDBUSDMAN)
+  endif
+
   ifeq ("@BUILD_LVMETAD@", "yes")
     MAN8+=$(LVMETADMAN)
   endif
@@ -107,7 +112,7 @@ CLEAN_TARGETS+=$(MAN5) $(MAN7) $(MAN8) $(MAN8CLUSTER) \
 	$(MAN8SYSTEMD_GENERATORS) $(MAN8DM)
 DISTCLEAN_TARGETS+=$(FSADMMAN) $(BLKDEACTIVATEMAN) $(DMEVENTDMAN) \
 	$(LVMETADMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(CLVMDMAN) $(CMIRRORDMAN) \
-	$(LVMCACHEMAN) $(LVMTHINMAN)
+	$(LVMCACHEMAN) $(LVMTHINMAN) $(LVMDBUSDMAN)
 
 all: man device-mapper
 
diff --git a/man/lvmdbusd.8.in b/man/lvmdbusd.8.in
new file mode 100644
index 0000000..9e035f5
--- /dev/null
+++ b/man/lvmdbusd.8.in
@@ -0,0 +1,38 @@
+.TH LVMDBUSD 8 "LVM TOOLS #VERSION#" "Red Hat Inc" \" -*- nroff -*-
+.
+.SH NAME
+.
+lvmdbusd \(em LVM D-Bus daemon
+.
+.SH SYNOPSIS
+.
+.ad l
+.B lvmdbusd
+.RB [ \-\-debug \]
+.RB [ \-\-udev \]
+.ad b
+.
+.SH DESCRIPTION
+.
+lvmdbusd is a service which provides a D-Bus API to the logical volume manager (LVM).
+Run 
+.BR lvmdbusd (8)
+as root.
+.
+.SH OPTIONS
+.
+.HP
+.BR \-\-debug 
+.br
+Enable debug statements 
+.
+.HP
+.BR \-\-udev
+.br
+Use udev events to trigger updates
+.
+.SH SEE ALSO
+.
+.nh
+.BR dbus-send (1),
+.BR lvm (8)
diff --git a/python/Makefile.in b/python/Makefile.in
index 60d39ab..3dc5664 100644
--- a/python/Makefile.in
+++ b/python/Makefile.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2011-2013 Red Hat, Inc.
+# Copyright (C) 2011-2016 Red Hat, Inc.
 #
 # This file is part of LVM2.
 #
@@ -20,14 +20,24 @@ TARGETS = .liblvm_built
 include $(top_builddir)/make.tmpl
 
 .liblvm_built: liblvm_python.c
-	$(PYTHON) setup.py build
+ifeq ("@PYTHON2_BINDINGS@", "yes")
+	$(PYTHON2) setup.py build
+endif
+ifeq ("@PYTHON3_BINDINGS@", "yes")
+	$(PYTHON3) setup.py build
+endif
 	touch $@
 
 liblvm_python.c:
 	$(LN_S) $(srcdir)/liblvm.c $@
 
 install_python_bindings: $(TARGETS)
-	$(PYTHON) setup.py install --skip-build --prefix $(pyexecdir)
+ifeq ("@PYTHON2_BINDINGS@", "yes")
+	$(PYTHON2) setup.py install --skip-build --prefix $(pythonprefix)
+endif
+ifeq ("@PYTHON3_BINDINGS@", "yes")
+	$(PYTHON3) setup.py install --skip-build --prefix $(pythonprefix)
+endif
 
 install_lvm2: install_python_bindings
 
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 80b2cbb..6df7d05 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -100,7 +100,7 @@ else
 	      "It requires the LVM2 application library to be built as well."
 endif
 
-install_systemd_units:
+install_systemd_units:	install_dbus_service
 	$(INSTALL_DIR) $(systemd_unit_dir)
 ifeq ("@BUILD_DMEVENTD@", "yes")
 	$(INSTALL_DATA) dm_event_systemd_red_hat.socket $(systemd_unit_dir)/dm-event.socket
@@ -131,6 +131,19 @@ endif
 ifeq ("@BUILD_CMIRRORD@", "yes")
 	$(INSTALL_DATA) lvm2_cmirrord_systemd_red_hat.service $(systemd_unit_dir)/lvm2-cmirrord.service
 endif
+ifeq ("@BUILD_LVMDBUSD@", "yes")
+	$(INSTALL_DATA) lvm2_lvmdbusd_systemd_red_hat.service $(systemd_unit_dir)/lvm2-lvmdbusd.service
+endif
+
+ifeq ("@BUILD_LVMDBUSD@", "yes")
+install_dbus_service:
+	$(INSTALL_DIR) $(dbusconfdir)
+	$(INSTALL_DIR) $(dbusservicedir)
+	$(INSTALL_DATA) $(top_srcdir)/scripts/com.redhat.lvmdbus1.conf $(dbusconfdir)
+	$(INSTALL_DATA) com.redhat.lvmdbus1.service $(dbusservicedir)
+
+install_systemd_units:	install_dbus_service
+endif
 
 install_tmpfiles_configuration:
 	$(INSTALL_DIR) $(tmpfiles_dir)
diff --git a/scripts/com.redhat.lvmdbus1.conf b/scripts/com.redhat.lvmdbus1.conf
new file mode 100644
index 0000000..80758c6
--- /dev/null
+++ b/scripts/com.redhat.lvmdbus1.conf
@@ -0,0 +1,13 @@
+<?xml version="1.0"?> <!--*-nxml-*-->
+<!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
+	"http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
+<busconfig>
+	<policy user="root">
+		<allow own_prefix="com.redhat.lvmdbus1"/>
+		<allow send_destination="com.redhat.lvmdbus1"/>
+	</policy>
+	<policy context="default">
+		<deny own_prefix="com.redhat.lvmdbus1"/>
+		<deny send_destination="com.redhat.lvmdbus1"/>
+	</policy>
+</busconfig>
diff --git a/scripts/com.redhat.lvmdbus1.service.in b/scripts/com.redhat.lvmdbus1.service.in
new file mode 100644
index 0000000..e271b08
--- /dev/null
+++ b/scripts/com.redhat.lvmdbus1.service.in
@@ -0,0 +1,5 @@
+[D-BUS Service]
+Name=com.redhat.lvmdbus1
+Exec=@sbindir@/lvmdbusd --udev
+User=root
+SystemdService=lvmdbusd.service
diff --git a/scripts/lvm2_lvmdbusd_systemd_red_hat.service.in b/scripts/lvm2_lvmdbusd_systemd_red_hat.service.in
new file mode 100644
index 0000000..d3ad870
--- /dev/null
+++ b/scripts/lvm2_lvmdbusd_systemd_red_hat.service.in
@@ -0,0 +1,11 @@
+[Unit]
+Description=LVM2 D-Bus service
+Documentation=man:lvmdbusd(8)
+
+[Service]
+Type=dbus
+BusName=com.redhat.lvmdbus1
+ExecStart=@sbindir@/lvmdbusd --udev
+
+[Install]
+WantedBy=multi-user.target
diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
new file mode 100644
index 0000000..7f3bcca
--- /dev/null
+++ b/test/dbus/lvmdbustest.py
@@ -0,0 +1,1053 @@
+#!/usr/bin/env python3
+
+# This program is free software; you can redistribute it and/or modify
+# it under the terms of the GNU General Public License as
+# published by the Free Software Foundation; either version 3 of the
+# License, or (at your option) any later version.
+#
+# This program is distributed in the hope that it will be useful,
+# but WITHOUT ANY WARRANTY; without even the implied warranty of
+# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+# GNU General Public License for more details.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+#
+# Copyright 2015, Tony Asleson <tasleson@redhat.com>
+
+import dbus
+# noinspection PyUnresolvedReferences
+from dbus.mainloop.glib import DBusGMainLoop
+import unittest
+import sys
+import random
+import string
+import functools
+import time
+import pyudev
+import os
+import xml.etree.ElementTree as Et
+from collections import OrderedDict
+
+
+BUSNAME = "com.redhat.lvmdbus1"
+MANAGER_INT = BUSNAME + '.Manager'
+MANAGER_OBJ = '/' + BUSNAME.replace('.', '/') + 'Manager'
+PV_INT = BUSNAME + ".Pv"
+VG_INT = BUSNAME + ".Vg"
+LV_INT = BUSNAME + ".Lv"
+THINPOOL_INT = BUSNAME + ".ThinPool"
+SNAPSHOT_INT = BUSNAME + ".Snapshot"
+LV_COMMON_INT = BUSNAME + ".LvCommon"
+JOB_INT = BUSNAME + ".Job"
+CACHE_POOL_INT = BUSNAME + ".CachePool"
+CACHE_LV_INT = BUSNAME + ".CachedLv"
+
+THINPOOL_LV_PATH = '/' + THINPOOL_INT.replace('.', '/')
+
+
+def rs(length, suffix):
+    return ''.join(random.choice(string.ascii_lowercase)
+                   for _ in range(length)) + suffix
+
+bus = dbus.SystemBus(mainloop=DBusGMainLoop())
+
+
+class DbusIntrospection(object):
+
+    @staticmethod
+    def introspect(xml_representation):
+        interfaces = {}
+
+        root = Et.fromstring(xml_representation)
+
+        for c in root:
+            if c.tag == "interface":
+                in_f = c.attrib['name']
+                interfaces[in_f] = \
+                    dict(methods=OrderedDict(), properties={})
+                for nested in c:
+                    if nested.tag == "method":
+                        mn = nested.attrib['name']
+                        interfaces[in_f]['methods'][mn] = OrderedDict()
+
+                        for arg in nested:
+                            if arg.tag == 'arg':
+                                arg_dir = arg.attrib['direction']
+                                if arg_dir == 'in':
+                                    n = arg.attrib['name']
+                                else:
+                                    n = None
+
+                                arg_type = arg.attrib['type']
+
+                                if n:
+                                    v = dict(name=mn,
+                                             a_dir=arg_dir,
+                                             a_type=arg_type)
+                                    interfaces[in_f]['methods'][mn][n] = v
+
+                    elif nested.tag == 'property':
+                        pn = nested.attrib['name']
+                        p_access = nested.attrib['access']
+                        p_type = nested.attrib['type']
+
+                        interfaces[in_f]['properties'][pn] = \
+                            dict(p_access=p_access, p_type=p_type)
+                    else:
+                        pass
+
+        # print('Interfaces...')
+        # for k, v in list(interfaces.items()):
+        #     print('Interface %s' % k)
+        #     if v['methods']:
+        #         for m, args in list(v['methods'].items()):
+        #             print('    method: %s' % m)
+        #             for a, aa in args.items():
+        #                 print('         method arg: %s' % (a))
+        #     if v['properties']:
+        #         for p, d in list(v['properties'].items()):
+        #             print('    Property: %s' % (p))
+        # print('End interfaces')
+
+        return interfaces
+
+
+class RemoteObject(object):
+
+    def _set_props(self, props=None):
+        #print 'Fetching properties'
+        if not props:
+            #prop_fetch = dbus.Interface(self.bus.get_object(
+            #    BUSNAME, self.object_path), 'org.freedesktop.DBus.Properties')
+
+            for i in range(0, 3):
+                try:
+                    prop_fetch = dbus.Interface(self.bus.get_object(
+                        BUSNAME, self.object_path),
+                        'org.freedesktop.DBus.Properties')
+                    props = prop_fetch.GetAll(self.interface)
+                    break
+                except dbus.exceptions.DBusException as dbe:
+                    if "GetAll" not in str(dbe):
+                        raise dbe
+        if props:
+            for kl, vl in list(props.items()):
+                setattr(self, kl, vl)
+
+    def __init__(self, specified_bus, object_path, interface, properties=None):
+        self.object_path = object_path
+        self.interface = interface
+        self.bus = specified_bus
+
+        self.dbus_method = dbus.Interface(specified_bus.get_object(
+            BUSNAME, self.object_path), self.interface)
+
+        self._set_props(properties)
+
+    def __getattr__(self, item):
+        if hasattr(self.dbus_method, item):
+            return functools.partial(self._wrapper, item)
+        else:
+            return functools.partial(self, item)
+
+    def _wrapper(self, _method_name, *args, **kwargs):
+        return getattr(self.dbus_method, _method_name)(*args, **kwargs)
+
+    def update(self):
+        self._set_props()
+
+
+class ClientProxy(object):
+
+    @staticmethod
+    def _intf_short_name(nm):
+        return nm.split('.')[-1:][0]
+
+    def __init__(self, specified_bus, object_path, interface=None, props=None):
+        i = dbus.Interface(specified_bus.get_object(
+            BUSNAME, object_path), 'org.freedesktop.DBus.Introspectable')
+        self.intro_spect = DbusIntrospection.introspect(i.Introspect())
+
+        for k in self.intro_spect.keys():
+            sn = ClientProxy._intf_short_name(k)
+            #print('Client proxy has interface: %s %s' % (k, sn))
+
+            if interface and interface == k and props is not None:
+                ro = RemoteObject(specified_bus, object_path, k, props)
+            else:
+                ro = RemoteObject(specified_bus, object_path, k)
+
+            setattr(self, sn, ro)
+
+        self.object_path = object_path
+
+    def update(self):
+        # Go through all interfaces and update them
+        for int_f in self.intro_spect.keys():
+            sn = ClientProxy._intf_short_name(int_f)
+            getattr(self, sn).update()
+
+
+def get_objects():
+    rc = {MANAGER_INT: [], PV_INT: [], VG_INT: [], LV_INT: [],
+          THINPOOL_INT: [], JOB_INT: [], SNAPSHOT_INT: [], LV_COMMON_INT: [],
+          CACHE_POOL_INT: [], CACHE_LV_INT: []}
+
+    manager = dbus.Interface(bus.get_object(
+        BUSNAME, "/com/redhat/lvmdbus1"),
+        "org.freedesktop.DBus.ObjectManager")
+
+    objects = manager.GetManagedObjects()
+
+    for object_path, val in list(objects.items()):
+        for interface, props in list(val.items()):
+            o = ClientProxy(bus, object_path, interface, props)
+            rc[interface].append(o)
+
+    return rc, bus
+
+
+def set_execution(lvmshell):
+    lvm_manager = dbus.Interface(bus.get_object(
+        BUSNAME, "/com/redhat/lvmdbus1/Manager"),
+        "com.redhat.lvmdbus1.Manager")
+    lvm_manager.UseLvmShell(lvmshell)
+
+
+# noinspection PyUnresolvedReferences
+class TestDbusService(unittest.TestCase):
+    def setUp(self):
+        # Because of the sensitive nature of running LVM tests we will only
+        # run if we have PVs and nothing else, so that we can be confident that
+        # we are not mucking with someones data on their system
+        self.objs, self.bus = get_objects()
+        if len(self.objs[PV_INT]) == 0:
+            print('No PVs present exiting!')
+            sys.exit(1)
+        if len(self.objs[MANAGER_INT]) != 1:
+            print('Expecting a manager object!')
+            sys.exit(1)
+
+        if len(self.objs[VG_INT]) != 0:
+            print('Expecting no VGs to exist!')
+            sys.exit(1)
+
+        self.pvs = []
+        for p in self.objs[PV_INT]:
+            self.pvs.append(p.Pv.Name)
+
+    def tearDown(self):
+        # If we get here it means we passed setUp, so lets remove anything
+        # and everything that remains, besides the PVs themselves
+        self.objs, self.bus = get_objects()
+        for v in self.objs[VG_INT]:
+            #print "DEBUG: Removing VG= ", v.Uuid, v.Name
+            v.Vg.Remove(-1, {})
+
+        # Check to make sure the PVs we had to start exist, else re-create
+        # them
+        if len(self.pvs) != len(self.objs[PV_INT]):
+            for p in self.pvs:
+                found = False
+                for pc in self.objs[PV_INT]:
+                    if pc.Pv.Name == p:
+                        found = True
+                        break
+
+                if not found:
+                    # print('Re-creating PV=', p)
+                    self._pv_create(p)
+
+    def _pv_create(self, device):
+        pv_path = self.objs[MANAGER_INT][0].Manager.PvCreate(device, -1, {})[0]
+        self.assertTrue(pv_path is not None and len(pv_path) > 0)
+        return pv_path
+
+    def _manager(self):
+        return self.objs[MANAGER_INT][0]
+
+    def _refresh(self):
+        return self._manager().Manager.Refresh()
+
+    def test_refresh(self):
+        rc = self._refresh()
+        self.assertEqual(rc, 0)
+
+    def test_version(self):
+        rc = self.objs[MANAGER_INT][0].Manager.Version
+        self.assertTrue(rc is not None and len(rc) > 0)
+        self.assertEqual(self._refresh(), 0)
+
+    def _vg_create(self, pv_paths=None):
+
+        if not pv_paths:
+            pv_paths = [self.objs[PV_INT][0].object_path]
+
+        vg_name = rs(8, '_vg')
+
+        vg_path = self.objs[MANAGER_INT][0].Manager.VgCreate(
+            vg_name,
+            pv_paths,
+            -1,
+            {})[0]
+        self.assertTrue(vg_path is not None and len(vg_path) > 0)
+        return ClientProxy(self.bus, vg_path)
+
+    def test_vg_create(self):
+        self._vg_create()
+        self.assertEqual(self._refresh(), 0)
+
+    def test_vg_delete(self):
+        vg = self._vg_create().Vg
+        vg.Remove(-1, {})
+        self.assertEqual(self._refresh(), 0)
+
+    def _pv_remove(self, pv):
+        rc = pv.Pv.Remove(-1, {})
+        return rc
+
+    def test_pv_remove_add(self):
+        target = self.objs[PV_INT][0]
+
+        # Remove the PV
+        rc = self._pv_remove(target)
+        self.assertTrue(rc == '/')
+        self.assertEqual(self._refresh(), 0)
+
+        # Add it back
+        rc = self._pv_create(target.Pv.Name)[0]
+        self.assertTrue(rc == '/')
+        self.assertEqual(self._refresh(), 0)
+
+    def _lookup(self, lvm_id):
+        return self.objs[MANAGER_INT][0].Manager.LookUpByLvmId(lvm_id)
+
+    def test_lookup_by_lvm_id(self):
+        # For the moment lets just lookup what we know about which is PVs
+        # When we start testing VGs and LVs we will test lookups for those
+        # during those unit tests
+        for p in self.objs[PV_INT]:
+            rc = self._lookup(p.Pv.Name)
+            self.assertTrue(rc is not None and rc != '/')
+
+        # Search for something which doesn't exist
+        rc = self._lookup('/dev/null')
+        self.assertTrue(rc == '/')
+
+    def test_vg_extend(self):
+        # Create a VG
+        self.assertTrue(len(self.objs[PV_INT]) >= 2)
+
+        if len(self.objs[PV_INT]) >= 2:
+            pv_initial = self.objs[PV_INT][0]
+            pv_next = self.objs[PV_INT][1]
+
+            vg = self._vg_create([pv_initial.object_path]).Vg
+            path = vg.Extend([pv_next.object_path], -1, {})
+            self.assertTrue(path == '/')
+            self.assertEqual(self._refresh(), 0)
+
+    # noinspection PyUnresolvedReferences
+    def test_vg_reduce(self):
+        self.assertTrue(len(self.objs[PV_INT]) >= 2)
+
+        if len(self.objs[PV_INT]) >= 2:
+            vg = self._vg_create(
+                [self.objs[PV_INT][0].object_path,
+                 self.objs[PV_INT][1].object_path]).Vg
+
+            path = vg.Reduce(False, [vg.Pvs[0]], -1, {})
+            self.assertTrue(path == '/')
+            self.assertEqual(self._refresh(), 0)
+
+    # noinspection PyUnresolvedReferences
+    def test_vg_rename(self):
+        vg = self._vg_create().Vg
+
+        # Create some LVs in the VG
+        for i in range(0, 5):
+            self._create_lv(size=1024 * 1024 * 16, vg=vg)
+
+        path = vg.Rename('renamed_' + vg.Name, -1, {})
+        self.assertTrue(path == '/')
+        self.assertEqual(self._refresh(), 0)
+
+        # Go through each LV and make sure it has the correct path back to the
+        # VG
+        vg.update()
+
+        lv_paths = vg.Lvs
+        self.assertTrue(len(lv_paths) == 5)
+
+        for l in lv_paths:
+            lv_proxy = ClientProxy(self.bus, l).LvCommon
+            self.assertTrue(lv_proxy.Vg == vg.object_path, "%s != %s" %
+                            (lv_proxy.Vg, vg.object_path))
+
+    def _test_lv_create(self, method, params, vg):
+        lv = None
+        path = method(*params)[0]
+
+        self.assertTrue(vg)
+
+        if path:
+            lv = ClientProxy(self.bus, path)
+            # TODO verify object properties
+
+        self.assertEqual(self._refresh(), 0)
+        return lv
+
+    def test_lv_create(self):
+        vg = self._vg_create().Vg
+        self._test_lv_create(vg.LvCreate,
+                             (rs(8, '_lv'), 1024 * 1024 * 4,
+                              dbus.Array([], '(ott)'), -1, {}),
+                             vg)
+
+    def test_lv_create_linear(self):
+
+        vg = self._vg_create().Vg
+        self._test_lv_create(vg.LvCreateLinear,
+                             (rs(8, '_lv'), 1024 * 1024 * 4, False, -1, {}),
+                             vg)
+
+    def test_lv_create_striped(self):
+        pv_paths = []
+        for pp in self.objs[PV_INT]:
+            pv_paths.append(pp.object_path)
+
+        vg = self._vg_create(pv_paths).Vg
+        self._test_lv_create(vg.LvCreateStriped,
+                             (rs(8, '_lv'), 1024 * 1024 * 4, 2, 8, False,
+                              -1, {}), vg)
+
+    def test_lv_create_mirror(self):
+        pv_paths = []
+        for pp in self.objs[PV_INT]:
+            pv_paths.append(pp.object_path)
+
+        vg = self._vg_create(pv_paths).Vg
+        self._test_lv_create(vg.LvCreateMirror,
+                             (rs(8, '_lv'), 1024 * 1024 * 4, 2, -1, {}), vg)
+
+    def test_lv_create_raid(self):
+        pv_paths = []
+        for pp in self.objs[PV_INT]:
+            pv_paths.append(pp.object_path)
+
+        vg = self._vg_create(pv_paths).Vg
+        self._test_lv_create(vg.LvCreateRaid,
+                             (rs(8, '_lv'), 'raid4',
+                              1024 * 1024 * 16, 2, 8, -1, {}), vg)
+
+    def _create_lv(self, thinpool=False, size=None, vg=None):
+
+        if not vg:
+            pv_paths = []
+            for pp in self.objs[PV_INT]:
+                pv_paths.append(pp.object_path)
+
+            vg = self._vg_create(pv_paths).Vg
+
+        if size is None:
+            size = 1024 * 1024 * 128
+
+        return self._test_lv_create(
+            vg.LvCreateLinear,
+            (rs(8, '_lv'), size, thinpool, -1, {}), vg)
+
+    def test_lv_create_rounding(self):
+        self._create_lv(size=1024 * 1024 * 2 + 13)
+
+    def test_lv_create_thin_pool(self):
+        self._create_lv(True)
+
+    def test_lv_rename(self):
+        # Rename a regular LV
+        lv = self._create_lv()
+        lv.Lv.Rename('renamed_' + lv.LvCommon.Name, -1, {})
+        self.assertEqual(self._refresh(), 0)
+
+    def test_lv_thinpool_rename(self):
+        # Rename a thin pool
+        tp = self._create_lv(True)
+        self.assertTrue(THINPOOL_LV_PATH in tp.object_path,
+                        "%s" % (tp.object_path))
+
+        new_name = 'renamed_' + tp.LvCommon.Name
+        tp.Lv.Rename(new_name, -1, {})
+        tp.update()
+        self.assertEqual(self._refresh(), 0)
+        self.assertEqual(new_name, tp.LvCommon.Name)
+
+    # noinspection PyUnresolvedReferences
+    def test_lv_on_thin_pool_rename(self):
+        # Rename a LV on a thin Pool
+
+        # This returns a LV with the LV interface, need to get a proxy for
+        # thinpool interface too
+        tp = self._create_lv(True)
+
+        thin_path = tp.ThinPool.LvCreate(
+            rs(10, '_thin_lv'), 1024 * 1024 * 10, -1, {})[0]
+
+        lv = ClientProxy(self.bus, thin_path)
+        rc = lv.Lv.Rename('rename_test' + lv.LvCommon.Name, -1, {})
+        self.assertTrue(rc == '/')
+        self.assertEqual(self._refresh(), 0)
+
+    def test_lv_remove(self):
+        lv = self._create_lv().Lv
+        rc = lv.Remove(-1, {})
+        self.assertTrue(rc == '/')
+        self.assertEqual(self._refresh(), 0)
+
+    def test_lv_snapshot(self):
+        lv_p = self._create_lv()
+        ss_name = 'ss_' + lv_p.LvCommon.Name
+
+        # Test waiting to complete
+        ss, job = lv_p.Lv.Snapshot(ss_name, 0, -1, {})
+        self.assertTrue(ss != '/')
+        self.assertTrue(job == '/')
+
+        snapshot = ClientProxy(self.bus, ss)
+        self.assertTrue(snapshot.LvCommon.Name == ss_name)
+
+        self.assertEqual(self._refresh(), 0)
+
+        # Test getting a job returned immediately
+        rc, job = lv_p.Lv.Snapshot('ss2_' + lv_p.LvCommon.Name, 0, 0, {})
+        self.assertTrue(rc == '/')
+        self.assertTrue(job != '/')
+        self._wait_for_job(job)
+
+        self.assertEqual(self._refresh(), 0)
+
+    # noinspection PyUnresolvedReferences
+    def _wait_for_job(self, j_path):
+        import time
+        rc = None
+        j = ClientProxy(self.bus, j_path).Job
+
+        while True:
+            j.update()
+            if j.Complete:
+                (ec, error_msg) = j.GetError
+                self.assertTrue(ec == 0, "%d :%s" % (ec, error_msg))
+
+                if ec == 0:
+                    self.assertTrue(j.Percent == 100, "P= %f" % j.Percent)
+
+                rc = j.Result
+                j.Remove()
+
+                break
+
+            if j.Wait(1):
+                j.update()
+                self.assertTrue(j.Complete)
+
+        return rc
+
+    def test_lv_create_pv_specific(self):
+        vg = self._vg_create().Vg
+
+        pv = vg.Pvs
+
+        self._test_lv_create(vg.LvCreate,
+                             (rs(8, '_lv'), 1024 * 1024 * 4,
+                              dbus.Array([[pv[0], 0, 100]], '(ott)'), -1, {}),
+                             vg)
+
+    def test_lv_resize(self):
+
+        pv_paths = []
+        for pp in self.objs[PV_INT]:
+            pv_paths.append(pp.object_path)
+
+        vg = self._vg_create(pv_paths).Vg
+        lv = self._create_lv(vg=vg)
+
+        for size in [lv.LvCommon.SizeBytes + 4194304,
+                     lv.LvCommon.SizeBytes - 4194304,
+                     lv.LvCommon.SizeBytes + 2048,
+                     lv.LvCommon.SizeBytes - 2048,
+                     lv.LvCommon.SizeBytes]:
+
+            pv_in_use = [i[0] for i in lv.LvCommon.Devices]
+            # Select a PV in the VG that isn't in use
+            pv_empty = [p for p in vg.Pvs if p not in pv_in_use]
+
+            prev = lv.LvCommon.SizeBytes
+
+            if len(pv_empty):
+                rc = lv.Lv.Resize(size,
+                                  dbus.Array([[pv_empty[0], 0, 100]], '(oii)'),
+                                  -1, {})
+            else:
+                rc = lv.Lv.Resize(size, dbus.Array([], '(oii)'), -1, {})
+
+            self.assertEqual(rc, '/')
+            self.assertEqual(self._refresh(), 0)
+
+            lv.update()
+
+            if prev < size:
+                self.assertTrue(lv.LvCommon.SizeBytes > prev)
+            else:
+                # We are testing re-sizing to same size too...
+                self.assertTrue(lv.LvCommon.SizeBytes <= prev)
+
+    def test_lv_move(self):
+        lv = self._create_lv()
+
+        pv_path_move = str(lv.LvCommon.Devices[0][0])
+
+        # Test moving a specific LV
+        job = lv.Lv.Move(pv_path_move, (0, 0), dbus.Array([], '(oii)'), 0, {})
+        self._wait_for_job(job)
+        self.assertEqual(self._refresh(), 0)
+
+        lv.update()
+        new_pv = str(lv.LvCommon.Devices[0][0])
+        self.assertTrue(pv_path_move != new_pv, "%s == %s" %
+                        (pv_path_move, new_pv))
+
+    def test_lv_activate_deactivate(self):
+        lv_p = self._create_lv()
+        lv_p.update()
+
+        lv_p.Lv.Deactivate(0, -1, {})
+        lv_p.update()
+        self.assertFalse(lv_p.LvCommon.Active)
+        self.assertEqual(self._refresh(), 0)
+
+        lv_p.Lv.Activate(0, -1, {})
+
+        lv_p.update()
+        self.assertTrue(lv_p.LvCommon.Active)
+        self.assertEqual(self._refresh(), 0)
+
+        # Try control flags
+        for i in range(0, 5):
+            lv_p.Lv.Activate(1 << i, -1, {})
+            self.assertTrue(lv_p.LvCommon.Active)
+            self.assertEqual(self._refresh(), 0)
+
+    def test_move(self):
+        lv = self._create_lv()
+
+        # Test moving without being LV specific
+        vg = ClientProxy(self.bus, lv.LvCommon.Vg).Vg
+        pv_to_move = str(lv.LvCommon.Devices[0][0])
+        job = vg.Move(pv_to_move, (0, 0), dbus.Array([], '(oii)'), 0, {})
+        self._wait_for_job(job)
+        self.assertEqual(self._refresh(), 0)
+
+        # Test Vg.Move
+        # TODO Test this more!
+        vg.update()
+        lv.update()
+
+        location = lv.LvCommon.Devices[0][0]
+
+        dst = None
+        for p in vg.Pvs:
+            if p != location:
+                dst = p
+
+        # Fetch the destination
+        pv = ClientProxy(self.bus, dst).Pv
+
+        # Test range, move it to the middle of the new destination and blocking
+        # blocking for it to complete
+        job = vg.Move(location,
+                      (0, 0), [(dst, pv.PeCount / 2, 0), ], -1, {})
+        self.assertEqual(job, '/')
+        self.assertEqual(self._refresh(), 0)
+
+    def test_job_handling(self):
+        pv_paths = []
+        for pp in self.objs[PV_INT]:
+            pv_paths.append(pp.object_path)
+
+        vg_name = rs(8, '_vg')
+
+        # Test getting a job right away
+        vg_path, vg_job = self.objs[MANAGER_INT][0].Manager.VgCreate(
+            vg_name, pv_paths,
+            0, {})
+
+        self.assertTrue(vg_path == '/')
+        self.assertTrue(vg_job and len(vg_job) > 0)
+
+        self._wait_for_job(vg_job)
+
+    def _test_expired_timer(self, num_lvs):
+        rc = False
+        pv_paths = []
+        for pp in self.objs[PV_INT]:
+            pv_paths.append(pp.object_path)
+
+        # In small configurations lvm is pretty snappy, so lets create a VG
+        # add a number of LVs and then remove the VG and all the contained
+        # LVs which appears to consistently run a little slow.
+
+        vg = self._vg_create(pv_paths).Vg
+
+        for i in range(0, num_lvs):
+            obj_path, job = vg.LvCreateLinear(rs(8, "_lv"),
+                                              1024 * 1024 * 4, False, -1, {})
+            self.assertTrue(job == '/')
+
+        # Make sure that we are honoring the timeout
+        start = time.time()
+
+        remove_job = vg.Remove(1, {})
+
+        end = time.time()
+
+        tt_remove = float(end) - float(start)
+
+        self.assertTrue(tt_remove < 2.0, "remove time %s" % (str(tt_remove)))
+
+        # Depending on how long it took we could finish either way
+        if remove_job != '/':
+            # We got a job
+            result = self._wait_for_job(remove_job)
+            self.assertTrue(result == '/')
+            rc = True
+        else:
+            # It completed before timer popped
+            pass
+
+        return rc
+
+    def test_job_handling_timer(self):
+
+        yes = False
+
+        # This may not pass
+        for i in [48, 64, 128]:
+            yes = self._test_expired_timer(i)
+            if yes:
+                break
+            print('Attempt (%d) failed, trying again...' % (i))
+
+        self.assertTrue(yes)
+
+    def test_pv_tags(self):
+        pvs = []
+
+        pv_paths = []
+        for pp in self.objs[PV_INT]:
+            pv_paths.append(pp.object_path)
+
+        vg = self._vg_create(pv_paths).Vg
+
+        # Get the PVs
+        for p in vg.Pvs:
+            pvs.append(ClientProxy(self.bus, p).Pv)
+
+        for tags_value in [['hello'], ['foo', 'bar']]:
+            rc = vg.PvTagsAdd(vg.Pvs, tags_value, -1, {})
+            self.assertTrue(rc == '/')
+
+            for p in pvs:
+                p.update()
+                self.assertTrue(sorted(tags_value) == p.Tags)
+
+            vg.PvTagsDel(vg.Pvs, tags_value, -1, {})
+            for p in pvs:
+                p.update()
+                self.assertTrue([] == p.Tags)
+
+    def test_vg_tags(self):
+        vg = self._vg_create().Vg
+
+        t = ['Testing', 'tags']
+
+        vg.TagsAdd(t, -1, {})
+        vg.update()
+        self.assertTrue(t == vg.Tags)
+        vg.TagsDel(t, -1, {})
+        vg.update()
+        self.assertTrue([] == vg.Tags)
+
+    def test_lv_tags(self):
+        vg = self._vg_create().Vg
+        lv = self._test_lv_create(
+            vg.LvCreateLinear,
+            (rs(8, '_lv'), 1024 * 1024 * 4, False, -1, {}),
+            vg)
+
+        t = ['Testing', 'tags']
+
+        lv.Lv.TagsAdd(t, -1, {})
+        lv.update()
+        self.assertTrue(t == lv.LvCommon.Tags)
+        lv.Lv.TagsDel(t, -1, {})
+        lv.update()
+        self.assertTrue([] == lv.LvCommon.Tags)
+
+    def test_vg_allocation_policy_set(self):
+        vg = self._vg_create().Vg
+
+        for p in ['anywhere', 'contiguous', 'cling', 'normal']:
+            rc = vg.AllocationPolicySet(p, -1, {})
+            self.assertEqual(rc, '/')
+            vg.update()
+
+            prop = getattr(vg, 'Alloc' + p.title())
+            self.assertTrue(prop)
+
+    def test_vg_max_pv(self):
+        vg = self._vg_create().Vg
+
+        # BZ: https://bugzilla.redhat.com/show_bug.cgi?id=1280496
+        # TODO: Add a test back for larger values here when bug is resolved
+        for p in [0, 1, 10, 100, 100, 1024, 2**32 - 1]:
+            rc = vg.MaxPvSet(p, -1, {})
+            self.assertEqual(rc, '/')
+            vg.update()
+            self.assertTrue(vg.MaxPv == p, "Expected %s != Actual %s" %
+                            (str(p), str(vg.MaxPv)))
+
+    def test_vg_max_lv(self):
+        vg = self._vg_create().Vg
+
+        # BZ: https://bugzilla.redhat.com/show_bug.cgi?id=1280496
+        # TODO: Add a test back for larger values here when bug is resolved
+        for p in [0, 1, 10, 100, 100, 1024, 2**32 - 1]:
+            rc = vg.MaxLvSet(p, -1, {})
+            self.assertEqual(rc, '/')
+            vg.update()
+            self.assertTrue(vg.MaxLv == p, "Expected %s != Actual %s" %
+                            (str(p), str(vg.MaxLv)))
+
+    def test_vg_uuid_gen(self):
+        # TODO renable test case when
+        # https://bugzilla.redhat.com/show_bug.cgi?id=1264169 gets fixed
+        # This was tested with lvmetad disabled and we passed
+        print("\nSkipping Vg.UuidGenerate until BZ: 1264169 resolved\n")
+
+        if False:
+            vg = self._vg_create().Vg
+            prev_uuid = vg.Uuid
+            rc = vg.UuidGenerate(-1, {})
+            self.assertEqual(rc, '/')
+            vg.update()
+            self.assertTrue(vg.Uuid != prev_uuid, "Expected %s != Actual %s" %
+                            (vg.Uuid, prev_uuid))
+
+    def test_vg_activate_deactivate(self):
+        vg = self._vg_create().Vg
+        self._test_lv_create(
+            vg.LvCreateLinear,
+            (rs(8, '_lv'), 1024 * 1024 * 4, False, -1, {}),
+            vg)
+
+        vg.update()
+
+        vg.Deactivate(0, -1, {})
+        self.assertEqual(self._refresh(), 0)
+
+        vg.Activate(0, -1, {})
+        self.assertEqual(self._refresh(), 0)
+
+        # Try control flags
+        for i in range(0, 5):
+            vg.Activate(1 << i, -1, {})
+
+    def test_pv_resize(self):
+
+        self.assertTrue(len(self.objs[PV_INT]) > 0)
+
+        if len(self.objs[PV_INT]) > 0:
+            pv = ClientProxy(self.bus, self.objs[PV_INT][0].object_path).Pv
+
+            original_size = pv.SizeBytes
+
+            new_size = original_size / 2
+
+            pv.ReSize(new_size, -1, {})
+            self.assertEqual(self._refresh(), 0)
+            pv.update()
+
+            self.assertTrue(pv.SizeBytes != original_size)
+            pv.ReSize(0, -1, {})
+            self.assertEqual(self._refresh(), 0)
+            pv.update()
+            self.assertTrue(pv.SizeBytes == original_size)
+
+    def test_pv_allocation(self):
+
+        pv_paths = []
+        for pp in self.objs[PV_INT]:
+            pv_paths.append(pp.object_path)
+
+        vg = self._vg_create(pv_paths).Vg
+
+        pv = ClientProxy(self.bus, vg.Pvs[0]).Pv
+
+        pv.AllocationEnabled(False, -1, {})
+        pv.update()
+        self.assertFalse(pv.Allocatable)
+
+        pv.AllocationEnabled(True, -1, {})
+        pv.update()
+        self.assertTrue(pv.Allocatable)
+
+        self.assertEqual(self._refresh(), 0)
+
+    def _get_devices(self):
+        context = pyudev.Context()
+        return context.list_devices(subsystem='block', MAJOR='8')
+
+    def test_pv_scan(self):
+        devices = self._get_devices()
+
+        mgr = self._manager().Manager
+
+        self.assertEqual(mgr.PvScan(False, True,
+                                    dbus.Array([], 's'),
+                                    dbus.Array([], '(ii)'), -1, {}), '/')
+        self.assertEqual(self._refresh(), 0)
+        self.assertEqual(mgr.PvScan(False, False,
+                                    dbus.Array([], 's'),
+                                    dbus.Array([], '(ii)'), -1, {}), '/')
+        self.assertEqual(self._refresh(), 0)
+
+        block_path = []
+        for d in devices:
+            block_path.append(d['DEVNAME'])
+
+        self.assertEqual(mgr.PvScan(False, True,
+                                    block_path,
+                                    dbus.Array([], '(ii)'), -1, {}), '/')
+
+        self.assertEqual(self._refresh(), 0)
+
+        mm = []
+        for d in devices:
+            mm.append((int(d['MAJOR']), int(d['MINOR'])))
+
+        self.assertEqual(mgr.PvScan(False, True,
+                                    block_path,
+                                    mm, -1, {}), '/')
+
+        self.assertEqual(self._refresh(), 0)
+
+        self.assertEqual(mgr.PvScan(False, True,
+                                    dbus.Array([], 's'),
+                                    mm, -1, {}), '/')
+
+        self.assertEqual(self._refresh(), 0)
+
+    @staticmethod
+    def _write_some_data(device_path, size):
+        blocks = int(size / 512)
+        block = bytearray(512)
+        for i in range(0, 512):
+            block[i] = i % 255
+
+        with open(device_path, mode='wb') as lv:
+            for i in range(0, blocks):
+                lv.write(block)
+
+    def test_snapshot_merge(self):
+        # Create a non-thin LV and merge it
+        ss_size = 1024 * 1024 * 512
+
+        lv_p = self._create_lv(size=1024 * 1024 * 1024)
+        ss_name = lv_p.LvCommon.Name + '_snap'
+        snapshot_path = lv_p.Lv.Snapshot(ss_name, ss_size, -1, {})[0]
+        ss = ClientProxy(self.bus, snapshot_path)
+
+        # Write some data to snapshot so merge takes some time
+        TestDbusService._write_some_data(ss.LvCommon.Path, ss_size / 2)
+
+        job_path = ss.Snapshot.Merge(0, {})
+
+        self.assertTrue(job_path != '/')
+        self._wait_for_job(job_path)
+
+    def test_snapshot_merge_thin(self):
+        # Create a thin LV, snapshot it and merge it
+        tp = self._create_lv(True)
+
+        thin_path = tp.ThinPool.LvCreate(
+            rs(10, '_thin_lv'), 1024 * 1024 * 10, -1, {})[0]
+
+        lv_p = ClientProxy(self.bus, thin_path)
+
+        ss_name = lv_p.LvCommon.Name + '_snap'
+        snapshot_path = lv_p.Lv.Snapshot(ss_name, 0, -1, {})[0]
+        ss = ClientProxy(self.bus, snapshot_path)
+        job_path = ss.Snapshot.Merge(0, {})
+        self.assertTrue(job_path != '/')
+        self._wait_for_job(job_path)
+
+    def _create_cache_pool(self):
+        vg = self._vg_create().Vg
+
+        md = self._create_lv(size=(1024 * 1024 * 8), vg=vg)
+        data = self._create_lv(size=(1024 * 1024 * 256), vg=vg)
+
+        cache_pool_path = vg.CreateCachePool(
+            md.object_path, data.object_path, -1, {})[0]
+
+        cp = ClientProxy(self.bus, cache_pool_path)
+
+        return (vg, cp)
+
+    def test_cache_pool_create(self):
+
+        vg, cache_pool = self._create_cache_pool()
+
+        self.assertTrue('/com/redhat/lvmdbus1/CachePool' in
+                        cache_pool.object_path)
+
+    def test_cache_lv_create(self):
+
+        for destroy_cache in [True, False]:
+            vg, cache_pool = self._create_cache_pool()
+
+            lv_to_cache = self._create_lv(size=(1024 * 1024 * 1024), vg=vg)
+
+            c_lv_path = cache_pool.CachePool.CacheLv(
+                lv_to_cache.object_path, -1, {})[0]
+
+            cached_lv = ClientProxy(self.bus, c_lv_path)
+
+            uncached_lv_path = \
+                cached_lv.CachedLv.DetachCachePool(destroy_cache, -1, {})[0]
+
+            self.assertTrue('/com/redhat/lvmdbus1/Lv' in
+                            uncached_lv_path)
+
+            vg.Remove(-1, {})
+
+    def test_vg_change(self):
+        vg_proxy = self._vg_create()
+        result = vg_proxy.Vg.Change(-1, {'-a': 'ay'})
+        self.assertTrue(result == '/')
+        result = vg_proxy.Vg.Change(-1, {'-a': 'n'})
+        self.assertTrue(result == '/')
+
+if __name__ == '__main__':
+    # Test forking & exec new each time
+    test_shell = os.getenv('LVM_DBUS_TEST_SHELL', 0)
+
+    set_execution(False)
+
+    if test_shell == 0:
+        unittest.main(exit=True)
+    else:
+        unittest.main(exit=False)
+        # Test lvm shell
+        print('\n *** Testing lvm shell *** \n')
+        set_execution(True)
+        unittest.main()


