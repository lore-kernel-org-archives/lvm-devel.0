From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:12:00 +0000 (GMT)
Subject: stable-2.02 - configure: update with latest AM_PATH_PYTHON
Message-ID: <20201016191200.24AD5396E83D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=305e80fe85e9fbc4fa30cdb70dc1576aebc80eec
Commit:        305e80fe85e9fbc4fa30cdb70dc1576aebc80eec
Parent:        3b5d51e821143202742c5ed7b1c57d48fe305913
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 16 15:39:54 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 18:09:55 2020 +0200

configure: update with latest AM_PATH_PYTHON

World has moved towards python3.9.
Although we still don't like path ordering.
---
 aclocal.m4 | 95 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--------
 configure  |  4 +--
 2 files changed, 85 insertions(+), 14 deletions(-)

diff --git a/aclocal.m4 b/aclocal.m4
index 07ea0b664..3e0fbd38d 100644
--- a/aclocal.m4
+++ b/aclocal.m4
@@ -1,6 +1,6 @@
-# generated automatically by aclocal 1.15 -*- Autoconf -*-
+# generated automatically by aclocal 1.16.2 -*- Autoconf -*-
 
-# Copyright (C) 1996-2014 Free Software Foundation, Inc.
+# Copyright (C) 1996-2020 Free Software Foundation, Inc.
 
 # This file is free software; the Free Software Foundation
 # gives unlimited permission to copy and/or distribute it,
@@ -13,7 +13,7 @@
 
 m4_ifndef([AC_CONFIG_MACRO_DIRS], [m4_defun([_AM_CONFIG_MACRO_DIRS], [])m4_defun([AC_CONFIG_MACRO_DIRS], [_AM_CONFIG_MACRO_DIRS($@)])])
 # ===========================================================================
-#     http://www.gnu.org/software/autoconf-archive/ax_python_module.html
+#     https://www.gnu.org/software/autoconf-archive/ax_python_module.html
 # ===========================================================================
 #
 # SYNOPSIS
@@ -37,7 +37,7 @@ m4_ifndef([AC_CONFIG_MACRO_DIRS], [m4_defun([_AM_CONFIG_MACRO_DIRS], [])m4_defun
 #   and this notice are preserved. This file is offered as-is, without any
 #   warranty.
 
-#serial 8
+#serial 9
 
 AU_ALIAS([AC_PYTHON_MODULE], [AX_PYTHON_MODULE])
 AC_DEFUN([AX_PYTHON_MODULE],[
@@ -69,9 +69,9 @@ AC_DEFUN([AX_PYTHON_MODULE],[
     fi
 ])
 
-dnl pkg.m4 - Macros to locate and utilise pkg-config.   -*- Autoconf -*-
-dnl serial 11 (pkg-config-0.29)
-dnl
+# pkg.m4 - Macros to locate and utilise pkg-config.   -*- Autoconf -*-
+# serial 11 (pkg-config-0.29.1)
+
 dnl Copyright ???? 2004 Scott James Remnant <scott@netsplit.com>.
 dnl Copyright ???? 2012-2015 Dan Nicholson <dbn.lists@gmail.com>
 dnl
@@ -112,7 +112,7 @@ dnl
 dnl See the "Since" comment for each macro you use to see what version
 dnl of the macros you require.
 m4_defun([PKG_PREREQ],
-[m4_define([PKG_MACROS_VERSION], [0.29])
+[m4_define([PKG_MACROS_VERSION], [0.29.1])
 m4_if(m4_version_compare(PKG_MACROS_VERSION, [$1]), -1,
     [m4_fatal([pkg.m4 version $1 or higher is required but ]PKG_MACROS_VERSION[ found])])
 ])dnl PKG_PREREQ
@@ -345,7 +345,75 @@ AS_VAR_COPY([$1], [pkg_cv_][$1])
 AS_VAR_IF([$1], [""], [$5], [$4])dnl
 ])dnl PKG_CHECK_VAR
 
-# Copyright (C) 1999-2014 Free Software Foundation, Inc.
+dnl PKG_WITH_MODULES(VARIABLE-PREFIX, MODULES,
+dnl   [ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND],
+dnl   [DESCRIPTION], [DEFAULT])
+dnl ------------------------------------------
+dnl
+dnl Prepare a "--with-" configure option using the lowercase
+dnl [VARIABLE-PREFIX] name, merging the behaviour of AC_ARG_WITH and
+dnl PKG_CHECK_MODULES in a single macro.
+AC_DEFUN([PKG_WITH_MODULES],
+[
+m4_pushdef([with_arg], m4_tolower([$1]))
+
+m4_pushdef([description],
+           [m4_default([$5], [build with ]with_arg[ support])])
+
+m4_pushdef([def_arg], [m4_default([$6], [auto])])
+m4_pushdef([def_action_if_found], [AS_TR_SH([with_]with_arg)=yes])
+m4_pushdef([def_action_if_not_found], [AS_TR_SH([with_]with_arg)=no])
+
+m4_case(def_arg,
+            [yes],[m4_pushdef([with_without], [--without-]with_arg)],
+            [m4_pushdef([with_without],[--with-]with_arg)])
+
+AC_ARG_WITH(with_arg,
+     AS_HELP_STRING(with_without, description[ @<:@default=]def_arg[@:>@]),,
+    [AS_TR_SH([with_]with_arg)=def_arg])
+
+AS_CASE([$AS_TR_SH([with_]with_arg)],
+            [yes],[PKG_CHECK_MODULES([$1],[$2],$3,$4)],
+            [auto],[PKG_CHECK_MODULES([$1],[$2],
+                                        [m4_n([def_action_if_found]) $3],
+                                        [m4_n([def_action_if_not_found]) $4])])
+
+m4_popdef([with_arg])
+m4_popdef([description])
+m4_popdef([def_arg])
+
+])dnl PKG_WITH_MODULES
+
+dnl PKG_HAVE_WITH_MODULES(VARIABLE-PREFIX, MODULES,
+dnl   [DESCRIPTION], [DEFAULT])
+dnl -----------------------------------------------
+dnl
+dnl Convenience macro to trigger AM_CONDITIONAL after PKG_WITH_MODULES
+dnl check._[VARIABLE-PREFIX] is exported as make variable.
+AC_DEFUN([PKG_HAVE_WITH_MODULES],
+[
+PKG_WITH_MODULES([$1],[$2],,,[$3],[$4])
+
+AM_CONDITIONAL([HAVE_][$1],
+               [test "$AS_TR_SH([with_]m4_tolower([$1]))" = "yes"])
+])dnl PKG_HAVE_WITH_MODULES
+
+dnl PKG_HAVE_DEFINE_WITH_MODULES(VARIABLE-PREFIX, MODULES,
+dnl   [DESCRIPTION], [DEFAULT])
+dnl ------------------------------------------------------
+dnl
+dnl Convenience macro to run AM_CONDITIONAL and AC_DEFINE after
+dnl PKG_WITH_MODULES check. HAVE_[VARIABLE-PREFIX] is exported as make
+dnl and preprocessor variable.
+AC_DEFUN([PKG_HAVE_DEFINE_WITH_MODULES],
+[
+PKG_HAVE_WITH_MODULES([$1],[$2],[$3],[$4])
+
+AS_IF([test "$AS_TR_SH([with_]m4_tolower([$1]))" = "yes"],
+        [AC_DEFINE([HAVE_][$1], 1, [Enable ]m4_tolower([$1])[ support])])
+])dnl PKG_HAVE_DEFINE_WITH_MODULES
+
+# Copyright (C) 1999-2020 Free Software Foundation, Inc.
 #
 # This file is free software; the Free Software Foundation
 # gives unlimited permission to copy and/or distribute it,
@@ -379,8 +447,11 @@ AC_DEFUN([AM_PATH_PYTHON],
   dnl Find a Python interpreter.  Python versions prior to 2.0 are not
   dnl supported. (2.0 was released on October 16, 2000).
   m4_define_default([_AM_PYTHON_INTERPRETER_LIST],
-[python python2 python3 python3.3 python3.2 python3.1 python3.0 python2.7 dnl
- python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0])
+[python python2 python3 dnl
+ python3.9 python3.8 python3.7 python3.6 python3.5 python3.4 python3.3 dnl
+ python3.2 python3.1 python3.0 dnl
+ python2.7 python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 dnl
+ python2.0])
 
   AC_ARG_VAR([PYTHON], [the Python interpreter])
 
@@ -580,7 +651,7 @@ for i in list(range(0, 4)): minverhex = (minverhex << 8) + minver[[i]]
 sys.exit(sys.hexversion < minverhex)"
   AS_IF([AM_RUN_LOG([$1 -c "$prog"])], [$3], [$4])])
 
-# Copyright (C) 2001-2014 Free Software Foundation, Inc.
+# Copyright (C) 2001-2020 Free Software Foundation, Inc.
 #
 # This file is free software; the Free Software Foundation
 # gives unlimited permission to copy and/or distribute it,
diff --git a/configure b/configure
index df27701ab..c2b65d5a8 100755
--- a/configure
+++ b/configure
@@ -12688,7 +12688,7 @@ if ${am_cv_pathless_PYTHON+:} false; then :
   $as_echo_n "(cached) " >&6
 else
 
-	for am_cv_pathless_PYTHON in python python2 python3 python3.5 python3.4 python3.3 python3.2 python3.1 python3.0 python2.7  python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0 none; do
+	for am_cv_pathless_PYTHON in python python2 python3  python3.9 python3.8 python3.7 python3.6 python3.5 python3.4 python3.3  python3.2 python3.1 python3.0  python2.7 python2.6 python2.5 python2.4 python2.3 python2.2 python2.1  python2.0 none; do
 	  test "$am_cv_pathless_PYTHON" = none && break
 	  prog="import sys
 # split strings by '.' and convert to numeric.  Append some zeros
@@ -13256,7 +13256,7 @@ if ${am_cv_pathless_PYTHON+:} false; then :
   $as_echo_n "(cached) " >&6
 else
 
-	for am_cv_pathless_PYTHON in python python2 python3 python3.5 python3.4 python3.3 python3.2 python3.1 python3.0 python2.7  python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0 none; do
+	for am_cv_pathless_PYTHON in python python2 python3  python3.9 python3.8 python3.7 python3.6 python3.5 python3.4 python3.3  python3.2 python3.1 python3.0  python2.7 python2.6 python2.5 python2.4 python2.3 python2.2 python2.1  python2.0 none; do
 	  test "$am_cv_pathless_PYTHON" = none && break
 	  prog="import sys
 # split strings by '.' and convert to numeric.  Append some zeros


