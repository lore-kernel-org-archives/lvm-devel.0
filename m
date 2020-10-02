From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  2 Oct 2020 20:27:47 +0000 (GMT)
Subject: master - configure: update with latest AM_PATH_PYTHON
Message-ID: <20201002202747.A551B3945C25@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2df7ef58a547a62b83264d291295890ce72066d5
Commit:        2df7ef58a547a62b83264d291295890ce72066d5
Parent:        ae96a43f05e7d5b9a420735bd4b652b275a3fe8f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 20:21:00 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 2 20:48:41 2020 +0200

configure: update with latest AM_PATH_PYTHON

World has moved towards python3.9.
Although we still don't like path ordering.
---
 aclocal.m4 | 16 +++++++++-------
 configure  |  4 +++-
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/aclocal.m4 b/aclocal.m4
index c57b12939..3e0fbd38d 100644
--- a/aclocal.m4
+++ b/aclocal.m4
@@ -1,6 +1,6 @@
-# generated automatically by aclocal 1.15.1 -*- Autoconf -*-
+# generated automatically by aclocal 1.16.2 -*- Autoconf -*-
 
-# Copyright (C) 1996-2017 Free Software Foundation, Inc.
+# Copyright (C) 1996-2020 Free Software Foundation, Inc.
 
 # This file is free software; the Free Software Foundation
 # gives unlimited permission to copy and/or distribute it,
@@ -413,7 +413,7 @@ AS_IF([test "$AS_TR_SH([with_]m4_tolower([$1]))" = "yes"],
         [AC_DEFINE([HAVE_][$1], 1, [Enable ]m4_tolower([$1])[ support])])
 ])dnl PKG_HAVE_DEFINE_WITH_MODULES
 
-# Copyright (C) 1999-2017 Free Software Foundation, Inc.
+# Copyright (C) 1999-2020 Free Software Foundation, Inc.
 #
 # This file is free software; the Free Software Foundation
 # gives unlimited permission to copy and/or distribute it,
@@ -446,10 +446,12 @@ AC_DEFUN([AM_PATH_PYTHON],
  [
   dnl Find a Python interpreter.  Python versions prior to 2.0 are not
   dnl supported. (2.0 was released on October 16, 2000).
-  dnl FIXME: Remove the need to hard-code Python versions here.
   m4_define_default([_AM_PYTHON_INTERPRETER_LIST],
-[python python2 python3 python3.5 python3.4 python3.3 python3.2 python3.1 python3.0 python2.7 dnl
- python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0])
+[python python2 python3 dnl
+ python3.9 python3.8 python3.7 python3.6 python3.5 python3.4 python3.3 dnl
+ python3.2 python3.1 python3.0 dnl
+ python2.7 python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 dnl
+ python2.0])
 
   AC_ARG_VAR([PYTHON], [the Python interpreter])
 
@@ -649,7 +651,7 @@ for i in list(range(0, 4)): minverhex = (minverhex << 8) + minver[[i]]
 sys.exit(sys.hexversion < minverhex)"
   AS_IF([AM_RUN_LOG([$1 -c "$prog"])], [$3], [$4])])
 
-# Copyright (C) 2001-2017 Free Software Foundation, Inc.
+# Copyright (C) 2001-2020 Free Software Foundation, Inc.
 #
 # This file is free software; the Free Software Foundation
 # gives unlimited permission to copy and/or distribute it,
diff --git a/configure b/configure
index 81f6d0875..4020eaa80 100755
--- a/configure
+++ b/configure
@@ -11845,6 +11845,7 @@ if test "$BUILD_LVMDBUSD" = yes; then
 
 
 
+
         if test -n "$PYTHON"; then
       # If the user set $PYTHON, use it and don't search something else.
       { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $PYTHON version is >= 3" >&5
@@ -11880,7 +11881,7 @@ if ${am_cv_pathless_PYTHON+:} false; then :
   $as_echo_n "(cached) " >&6
 else
 
-	for am_cv_pathless_PYTHON in python python2 python3 python3.5 python3.4 python3.3 python3.2 python3.1 python3.0 python2.7  python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0 none; do
+	for am_cv_pathless_PYTHON in python python2 python3  python3.9 python3.8 python3.7 python3.6 python3.5 python3.4 python3.3  python3.2 python3.1 python3.0  python2.7 python2.6 python2.5 python2.4 python2.3 python2.2 python2.1  python2.0 none; do
 	  test "$am_cv_pathless_PYTHON" = none && break
 	  prog="import sys
 # split strings by '.' and convert to numeric.  Append some zeros
@@ -14086,6 +14087,7 @@ _ACEOF
 
 
 
+
 
 
 


