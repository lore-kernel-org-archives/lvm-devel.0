From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  4 Apr 2014 01:38:17 +0000 (UTC)
Subject: master - configure: regenerate
Message-ID: <20140404013817.5C36D60A35@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4d0c3ed0f89ed25707c0a16049dfb9da647ed842
Commit:        4d0c3ed0f89ed25707c0a16049dfb9da647ed842
Parent:        5d7614fcf971d66ccf27e765a110f01a0f2482ea
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Apr 4 02:36:47 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Apr 4 02:36:47 2014 +0100

configure: regenerate

Used rhel7 autoreconf.
---
 aclocal.m4              |   61 +++-
 configure               |  814 ++++++++++++++++++++++++++---------------------
 lib/misc/configure.h.in |    4 +
 3 files changed, 504 insertions(+), 375 deletions(-)

diff --git a/aclocal.m4 b/aclocal.m4
index 165d9bc..c9f8f52 100644
--- a/aclocal.m4
+++ b/aclocal.m4
@@ -1,7 +1,7 @@
-# generated automatically by aclocal 1.11.1 -*- Autoconf -*-
+# generated automatically by aclocal 1.13.4 -*- Autoconf -*-
+
+# Copyright (C) 1996-2013 Free Software Foundation, Inc.
 
-# Copyright (C) 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004,
-# 2005, 2006, 2007, 2008, 2009  Free Software Foundation, Inc.
 # This file is free software; the Free Software Foundation
 # gives unlimited permission to copy and/or distribute it,
 # with or without modifications, as long as this notice is preserved.
@@ -11,6 +11,7 @@
 # even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 # PARTICULAR PURPOSE.
 
+m4_ifndef([AC_CONFIG_MACRO_DIRS], [m4_defun([_AM_CONFIG_MACRO_DIRS], [])m4_defun([AC_CONFIG_MACRO_DIRS], [_AM_CONFIG_MACRO_DIRS($@)])])
 # pkg.m4 - Macros to locate and utilise pkg-config.            -*- Autoconf -*-
 # serial 1 (pkg-config-0.24)
 # 
@@ -39,7 +40,8 @@
 # ----------------------------------
 AC_DEFUN([PKG_PROG_PKG_CONFIG],
 [m4_pattern_forbid([^_?PKG_[A-Z_]+$])
-m4_pattern_allow([^PKG_CONFIG(_PATH)?$])
+m4_pattern_allow([^PKG_CONFIG(_(PATH|LIBDIR|SYSROOT_DIR|ALLOW_SYSTEM_(CFLAGS|LIBS)))?$])
+m4_pattern_allow([^PKG_CONFIG_(DISABLE_UNINSTALLED|TOP_BUILD_DIR|DEBUG_SPEW)$])
 AC_ARG_VAR([PKG_CONFIG], [path to pkg-config utility])
 AC_ARG_VAR([PKG_CONFIG_PATH], [directories to add to pkg-config's search path])
 AC_ARG_VAR([PKG_CONFIG_LIBDIR], [path overriding pkg-config's built-in search path])
@@ -85,7 +87,8 @@ m4_define([_PKG_CONFIG],
     pkg_cv_[]$1="$$1"
  elif test -n "$PKG_CONFIG"; then
     PKG_CHECK_EXISTS([$3],
-                     [pkg_cv_[]$1=`$PKG_CONFIG --[]$2 "$3" 2>/dev/null`],
+                     [pkg_cv_[]$1=`$PKG_CONFIG --[]$2 "$3" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes ],
 		     [pkg_failed=yes])
  else
     pkg_failed=untried
@@ -133,9 +136,9 @@ if test $pkg_failed = yes; then
    	AC_MSG_RESULT([no])
         _PKG_SHORT_ERRORS_SUPPORTED
         if test $_pkg_short_errors_supported = yes; then
-	        $1[]_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "$2" 2>&1`
+	        $1[]_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "$2" 2>&1`
         else 
-	        $1[]_PKG_ERRORS=`$PKG_CONFIG --print-errors "$2" 2>&1`
+	        $1[]_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "$2" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$$1[]_PKG_ERRORS" >&AS_MESSAGE_LOG_FD
@@ -148,7 +151,7 @@ $$1_PKG_ERRORS
 Consider adjusting the PKG_CONFIG_PATH environment variable if you
 installed software in a non-standard prefix.
 
-_PKG_TEXT])
+_PKG_TEXT])[]dnl
         ])
 elif test $pkg_failed = untried; then
      	AC_MSG_RESULT([no])
@@ -159,7 +162,7 @@ path to pkg-config.
 
 _PKG_TEXT
 
-To get pkg-config, see <http://pkg-config.freedesktop.org/>.])
+To get pkg-config, see <http://pkg-config.freedesktop.org/>.])[]dnl
         ])
 else
 	$1[]_CFLAGS=$pkg_cv_[]$1[]_CFLAGS
@@ -169,4 +172,44 @@ else
 fi[]dnl
 ])# PKG_CHECK_MODULES
 
+
+# PKG_INSTALLDIR(DIRECTORY)
+# -------------------------
+# Substitutes the variable pkgconfigdir as the location where a module
+# should install pkg-config .pc files. By default the directory is
+# $libdir/pkgconfig, but the default can be changed by passing
+# DIRECTORY. The user can override through the --with-pkgconfigdir
+# parameter.
+AC_DEFUN([PKG_INSTALLDIR],
+[m4_pushdef([pkg_default], [m4_default([$1], ['${libdir}/pkgconfig'])])
+m4_pushdef([pkg_description],
+    [pkg-config installation directory @<:@]pkg_default[@:>@])
+AC_ARG_WITH([pkgconfigdir],
+    [AS_HELP_STRING([--with-pkgconfigdir], pkg_description)],,
+    [with_pkgconfigdir=]pkg_default)
+AC_SUBST([pkgconfigdir], [$with_pkgconfigdir])
+m4_popdef([pkg_default])
+m4_popdef([pkg_description])
+]) dnl PKG_INSTALLDIR
+
+
+# PKG_NOARCH_INSTALLDIR(DIRECTORY)
+# -------------------------
+# Substitutes the variable noarch_pkgconfigdir as the location where a
+# module should install arch-independent pkg-config .pc files. By
+# default the directory is $datadir/pkgconfig, but the default can be
+# changed by passing DIRECTORY. The user can override through the
+# --with-noarch-pkgconfigdir parameter.
+AC_DEFUN([PKG_NOARCH_INSTALLDIR],
+[m4_pushdef([pkg_default], [m4_default([$1], ['${datadir}/pkgconfig'])])
+m4_pushdef([pkg_description],
+    [pkg-config arch-independent installation directory @<:@]pkg_default[@:>@])
+AC_ARG_WITH([noarch-pkgconfigdir],
+    [AS_HELP_STRING([--with-noarch-pkgconfigdir], pkg_description)],,
+    [with_noarch_pkgconfigdir=]pkg_default)
+AC_SUBST([noarch_pkgconfigdir], [$with_noarch_pkgconfigdir])
+m4_popdef([pkg_default])
+m4_popdef([pkg_description])
+]) dnl PKG_NOARCH_INSTALLDIR
+
 m4_include([acinclude.m4])
diff --git a/configure b/configure
index d9df1ed..7967449 100755
--- a/configure
+++ b/configure
@@ -1,11 +1,9 @@
 #! /bin/sh
 # Guess values for system-dependent variables and create Makefiles.
-# Generated by GNU Autoconf 2.66.
+# Generated by GNU Autoconf 2.69.
 #
 #
-# Copyright (C) 1992, 1993, 1994, 1995, 1996, 1998, 1999, 2000, 2001,
-# 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010 Free Software
-# Foundation, Inc.
+# Copyright (C) 1992-1996, 1998-2012 Free Software Foundation, Inc.
 #
 #
 # This configure script is free software; the Free Software Foundation
@@ -89,6 +87,7 @@ fi
 IFS=" ""	$as_nl"
 
 # Find who we are.  Look in the path if we contain no directory separator.
+as_myself=
 case $0 in #((
   *[\\/]* ) as_myself=$0 ;;
   *) as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
@@ -133,6 +132,31 @@ export LANGUAGE
 # CDPATH.
 (unset CDPATH) >/dev/null 2>&1 && unset CDPATH
 
+# Use a proper internal environment variable to ensure we don't fall
+  # into an infinite loop, continuously re-executing ourselves.
+  if test x"${_as_can_reexec}" != xno && test "x$CONFIG_SHELL" != x; then
+    _as_can_reexec=no; export _as_can_reexec;
+    # We cannot yet assume a decent shell, so we have to provide a
+# neutralization value for shells without unset; and this also
+# works around shells that cannot unset nonexistent variables.
+# Preserve -v and -x to the replacement shell.
+BASH_ENV=/dev/null
+ENV=/dev/null
+(unset BASH_ENV) >/dev/null 2>&1 && unset BASH_ENV ENV
+case $- in # ((((
+  *v*x* | *x*v* ) as_opts=-vx ;;
+  *v* ) as_opts=-v ;;
+  *x* ) as_opts=-x ;;
+  * ) as_opts= ;;
+esac
+exec $CONFIG_SHELL $as_opts "$as_myself" ${1+"$@"}
+# Admittedly, this is quite paranoid, since all the known shells bail
+# out after a failed `exec'.
+$as_echo "$0: could not re-execute with $CONFIG_SHELL" >&2
+as_fn_exit 255
+  fi
+  # We don't want this to propagate to other subprocesses.
+          { _as_can_reexec=; unset _as_can_reexec;}
 if test "x$CONFIG_SHELL" = x; then
   as_bourne_compatible="if test -n \"\${ZSH_VERSION+set}\" && (emulate sh) >/dev/null 2>&1; then :
   emulate sh
@@ -166,7 +190,8 @@ if ( set x; as_fn_ret_success y && test x = \"\$1\" ); then :
 else
   exitcode=1; echo positional parameters were not saved.
 fi
-test x\$exitcode = x0 || exit 1"
+test x\$exitcode = x0 || exit 1
+test -x / || exit 1"
   as_suggested="  as_lineno_1=";as_suggested=$as_suggested$LINENO;as_suggested=$as_suggested" as_lineno_1a=\$LINENO
   as_lineno_2=";as_suggested=$as_suggested$LINENO;as_suggested=$as_suggested" as_lineno_2a=\$LINENO
   eval 'test \"x\$as_lineno_1'\$as_run'\" != \"x\$as_lineno_2'\$as_run'\" &&
@@ -211,14 +236,25 @@ IFS=$as_save_IFS
 
 
       if test "x$CONFIG_SHELL" != x; then :
-  # We cannot yet assume a decent shell, so we have to provide a
-	# neutralization value for shells without unset; and this also
-	# works around shells that cannot unset nonexistent variables.
-	BASH_ENV=/dev/null
-	ENV=/dev/null
-	(unset BASH_ENV) >/dev/null 2>&1 && unset BASH_ENV ENV
-	export CONFIG_SHELL
-	exec "$CONFIG_SHELL" "$as_myself" ${1+"$@"}
+  export CONFIG_SHELL
+             # We cannot yet assume a decent shell, so we have to provide a
+# neutralization value for shells without unset; and this also
+# works around shells that cannot unset nonexistent variables.
+# Preserve -v and -x to the replacement shell.
+BASH_ENV=/dev/null
+ENV=/dev/null
+(unset BASH_ENV) >/dev/null 2>&1 && unset BASH_ENV ENV
+case $- in # ((((
+  *v*x* | *x*v* ) as_opts=-vx ;;
+  *v* ) as_opts=-v ;;
+  *x* ) as_opts=-x ;;
+  * ) as_opts= ;;
+esac
+exec $CONFIG_SHELL $as_opts "$as_myself" ${1+"$@"}
+# Admittedly, this is quite paranoid, since all the known shells bail
+# out after a failed `exec'.
+$as_echo "$0: could not re-execute with $CONFIG_SHELL" >&2
+exit 255
 fi
 
     if test x$as_have_required = xno; then :
@@ -320,6 +356,14 @@ $as_echo X"$as_dir" |
 
 
 } # as_fn_mkdir_p
+
+# as_fn_executable_p FILE
+# -----------------------
+# Test if FILE is an executable regular file.
+as_fn_executable_p ()
+{
+  test -f "$1" && test -x "$1"
+} # as_fn_executable_p
 # as_fn_append VAR VALUE
 # ----------------------
 # Append the text in VALUE to the end of the definition contained in VAR. Take
@@ -441,6 +485,10 @@ as_cr_alnum=$as_cr_Letters$as_cr_digits
   chmod +x "$as_me.lineno" ||
     { $as_echo "$as_me: error: cannot create $as_me.lineno; rerun with a POSIX shell" >&2; as_fn_exit 1; }
 
+  # If we had to re-execute with $CONFIG_SHELL, we're ensured to have
+  # already done that, so ensure we don't try to do so again and fall
+  # in an infinite loop.  This has already happened in practice.
+  _as_can_reexec=no; export _as_can_reexec
   # Don't try to exec as it changes $[0], causing all sort of problems
   # (the dirname of $[0] is not the place where we might find the
   # original and so on.  Autoconf is especially sensitive to this).
@@ -475,16 +523,16 @@ if (echo >conf$$.file) 2>/dev/null; then
     # ... but there are two gotchas:
     # 1) On MSYS, both `ln -s file dir' and `ln file dir' fail.
     # 2) DJGPP < 2.04 has no symlinks; `ln -s' creates a wrapper executable.
-    # In both cases, we have to default to `cp -p'.
+    # In both cases, we have to default to `cp -pR'.
     ln -s conf$$.file conf$$.dir 2>/dev/null && test ! -f conf$$.exe ||
-      as_ln_s='cp -p'
+      as_ln_s='cp -pR'
   elif ln conf$$.file conf$$ 2>/dev/null; then
     as_ln_s=ln
   else
-    as_ln_s='cp -p'
+    as_ln_s='cp -pR'
   fi
 else
-  as_ln_s='cp -p'
+  as_ln_s='cp -pR'
 fi
 rm -f conf$$ conf$$.exe conf$$.dir/conf$$.file conf$$.file
 rmdir conf$$.dir 2>/dev/null
@@ -496,28 +544,8 @@ else
   as_mkdir_p=false
 fi
 
-if test -x / >/dev/null 2>&1; then
-  as_test_x='test -x'
-else
-  if ls -dL / >/dev/null 2>&1; then
-    as_ls_L_option=L
-  else
-    as_ls_L_option=
-  fi
-  as_test_x='
-    eval sh -c '\''
-      if test -d "$1"; then
-	test -d "$1/.";
-      else
-	case $1 in #(
-	-*)set "./$1";;
-	esac;
-	case `ls -ld'$as_ls_L_option' "$1" 2>/dev/null` in #((
-	???[sx]*):;;*)false;;esac;fi
-    '\'' sh
-  '
-fi
-as_executable_p=$as_test_x
+as_test_x='test -x'
+as_executable_p=as_fn_executable_p
 
 # Sed expression to map a string onto a valid CPP name.
 as_tr_cpp="eval sed 'y%*$as_cr_letters%P$as_cr_LETTERS%;s%[^_$as_cr_alnum]%_%g'"
@@ -840,6 +868,7 @@ with_thin
 with_thin_check
 with_thin_dump
 with_thin_repair
+enable_thin_check_needs_check
 with_cache
 enable_readline
 enable_realtime
@@ -1001,8 +1030,9 @@ do
   fi
 
   case $ac_option in
-  *=*)	ac_optarg=`expr "X$ac_option" : '[^=]*=\(.*\)'` ;;
-  *)	ac_optarg=yes ;;
+  *=?*) ac_optarg=`expr "X$ac_option" : '[^=]*=\(.*\)'` ;;
+  *=)   ac_optarg= ;;
+  *)    ac_optarg=yes ;;
   esac
 
   # Accept the important Cygnus configure options, so we can diagnose typos.
@@ -1342,7 +1372,7 @@ Try \`$0 --help' for more information"
     $as_echo "$as_me: WARNING: you should use --build, --host, --target" >&2
     expr "x$ac_option" : ".*[^-._$as_cr_alnum]" >/dev/null &&
       $as_echo "$as_me: WARNING: invalid host type: $ac_option" >&2
-    : ${build_alias=$ac_option} ${host_alias=$ac_option} ${target_alias=$ac_option}
+    : "${build_alias=$ac_option} ${host_alias=$ac_option} ${target_alias=$ac_option}"
     ;;
 
   esac
@@ -1393,8 +1423,6 @@ target=$target_alias
 if test "x$host_alias" != x; then
   if test "x$build_alias" = x; then
     cross_compiling=maybe
-    $as_echo "$as_me: WARNING: if you wanted to set the --build type, don't use --host.
-    If a cross compiler is detected then cross compile mode will be used" >&2
   elif test "x$build_alias" != "x$host_alias"; then
     cross_compiling=yes
   fi
@@ -1556,6 +1584,8 @@ Optional Features:
                           statically (default is dynamic linking
   --enable-lvm1_fallback  use this to fall back and use LVM1 binaries if
                           device-mapper is missing from the kernel
+  --disable-thin_check_needs_check
+                          required if thin_check version is < 0.3.0
   --disable-readline      disable readline support
   --enable-realtime       enable realtime clock support
   --enable-ocf            enable Open Cluster Framework (OCF) compliant
@@ -1803,9 +1833,9 @@ test -n "$ac_init_help" && exit $ac_status
 if $ac_init_version; then
   cat <<\_ACEOF
 configure
-generated by GNU Autoconf 2.66
+generated by GNU Autoconf 2.69
 
-Copyright (C) 2010 Free Software Foundation, Inc.
+Copyright (C) 2012 Free Software Foundation, Inc.
 This configure script is free software; the Free Software Foundation
 gives unlimited permission to copy, distribute and modify it.
 _ACEOF
@@ -1849,7 +1879,7 @@ sed 's/^/| /' conftest.$ac_ext >&5
 
 	ac_retval=1
 fi
-  eval $as_lineno_stack; test "x$as_lineno_stack" = x && { as_lineno=; unset as_lineno;}
+  eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
   as_fn_set_status $ac_retval
 
 } # ac_fn_c_try_compile
@@ -1875,7 +1905,7 @@ $as_echo "$ac_try_echo"; } >&5
     mv -f conftest.er1 conftest.err
   fi
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; } >/dev/null && {
+  test $ac_status = 0; } > conftest.i && {
 	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
 	 test ! -s conftest.err
        }; then :
@@ -1886,7 +1916,7 @@ sed 's/^/| /' conftest.$ac_ext >&5
 
     ac_retval=1
 fi
-  eval $as_lineno_stack; test "x$as_lineno_stack" = x && { as_lineno=; unset as_lineno;}
+  eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
   as_fn_set_status $ac_retval
 
 } # ac_fn_c_try_cpp
@@ -1918,7 +1948,7 @@ $as_echo "$ac_try_echo"; } >&5
 	 test ! -s conftest.err
        } && test -s conftest$ac_exeext && {
 	 test "$cross_compiling" = yes ||
-	 $as_test_x conftest$ac_exeext
+	 test -x conftest$ac_exeext
        }; then :
   ac_retval=0
 else
@@ -1932,7 +1962,7 @@ fi
   # interfere with the next link command; also delete a directory that is
   # left behind by Apple's compiler.  We do this before executing the actions.
   rm -rf conftest.dSYM conftest_ipa8_conftest.oo
-  eval $as_lineno_stack; test "x$as_lineno_stack" = x && { as_lineno=; unset as_lineno;}
+  eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
   as_fn_set_status $ac_retval
 
 } # ac_fn_c_try_link
@@ -1945,10 +1975,10 @@ fi
 ac_fn_c_check_header_mongrel ()
 {
   as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
-  if eval "test \"\${$3+set}\"" = set; then :
+  if eval \${$3+:} false; then :
   { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $2" >&5
 $as_echo_n "checking for $2... " >&6; }
-if eval "test \"\${$3+set}\"" = set; then :
+if eval \${$3+:} false; then :
   $as_echo_n "(cached) " >&6
 fi
 eval ac_res=\$$3
@@ -1984,7 +2014,7 @@ if ac_fn_c_try_cpp "$LINENO"; then :
 else
   ac_header_preproc=no
 fi
-rm -f conftest.err conftest.$ac_ext
+rm -f conftest.err conftest.i conftest.$ac_ext
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_header_preproc" >&5
 $as_echo "$ac_header_preproc" >&6; }
 
@@ -2011,7 +2041,7 @@ $as_echo "$as_me: WARNING: $2: proceeding with the compiler's result" >&2;}
 esac
   { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $2" >&5
 $as_echo_n "checking for $2... " >&6; }
-if eval "test \"\${$3+set}\"" = set; then :
+if eval \${$3+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   eval "$3=\$ac_header_compiler"
@@ -2020,7 +2050,7 @@ eval ac_res=\$$3
 	       { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
 $as_echo "$ac_res" >&6; }
 fi
-  eval $as_lineno_stack; test "x$as_lineno_stack" = x && { as_lineno=; unset as_lineno;}
+  eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
 
 } # ac_fn_c_check_header_mongrel
 
@@ -2061,7 +2091,7 @@ sed 's/^/| /' conftest.$ac_ext >&5
        ac_retval=$ac_status
 fi
   rm -rf conftest.dSYM conftest_ipa8_conftest.oo
-  eval $as_lineno_stack; test "x$as_lineno_stack" = x && { as_lineno=; unset as_lineno;}
+  eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
   as_fn_set_status $ac_retval
 
 } # ac_fn_c_try_run
@@ -2075,7 +2105,7 @@ ac_fn_c_check_header_compile ()
   as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
   { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $2" >&5
 $as_echo_n "checking for $2... " >&6; }
-if eval "test \"\${$3+set}\"" = set; then :
+if eval \${$3+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -2093,7 +2123,7 @@ fi
 eval ac_res=\$$3
 	       { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
 $as_echo "$ac_res" >&6; }
-  eval $as_lineno_stack; test "x$as_lineno_stack" = x && { as_lineno=; unset as_lineno;}
+  eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
 
 } # ac_fn_c_check_header_compile
 
@@ -2106,7 +2136,7 @@ ac_fn_c_check_member ()
   as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
   { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $2.$3" >&5
 $as_echo_n "checking for $2.$3... " >&6; }
-if eval "test \"\${$4+set}\"" = set; then :
+if eval \${$4+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -2150,7 +2180,7 @@ fi
 eval ac_res=\$$4
 	       { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
 $as_echo "$ac_res" >&6; }
-  eval $as_lineno_stack; test "x$as_lineno_stack" = x && { as_lineno=; unset as_lineno;}
+  eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
 
 } # ac_fn_c_check_member
 
@@ -2163,7 +2193,7 @@ ac_fn_c_check_type ()
   as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
   { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $2" >&5
 $as_echo_n "checking for $2... " >&6; }
-if eval "test \"\${$3+set}\"" = set; then :
+if eval \${$3+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   eval "$3=no"
@@ -2204,7 +2234,7 @@ fi
 eval ac_res=\$$3
 	       { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
 $as_echo "$ac_res" >&6; }
-  eval $as_lineno_stack; test "x$as_lineno_stack" = x && { as_lineno=; unset as_lineno;}
+  eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
 
 } # ac_fn_c_check_type
 
@@ -2217,7 +2247,7 @@ ac_fn_c_find_intX_t ()
   as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
   { $as_echo "$as_me:${as_lineno-$LINENO}: checking for int$2_t" >&5
 $as_echo_n "checking for int$2_t... " >&6; }
-if eval "test \"\${$3+set}\"" = set; then :
+if eval \${$3+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   eval "$3=no"
@@ -2233,7 +2263,8 @@ int
 main ()
 {
 static int test_array [1 - 2 * !(0 < ($ac_type) ((((($ac_type) 1 << N) << N) - 1) * 2 + 1))];
-test_array [0] = 0
+test_array [0] = 0;
+return test_array [0];
 
   ;
   return 0;
@@ -2249,7 +2280,8 @@ main ()
 {
 static int test_array [1 - 2 * !(($ac_type) ((((($ac_type) 1 << N) << N) - 1) * 2 + 1)
 		 < ($ac_type) ((((($ac_type) 1 << N) << N) - 1) * 2 + 2))];
-test_array [0] = 0
+test_array [0] = 0;
+return test_array [0];
 
   ;
   return 0;
@@ -2278,7 +2310,7 @@ fi
 eval ac_res=\$$3
 	       { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
 $as_echo "$ac_res" >&6; }
-  eval $as_lineno_stack; test "x$as_lineno_stack" = x && { as_lineno=; unset as_lineno;}
+  eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
 
 } # ac_fn_c_find_intX_t
 
@@ -2291,7 +2323,7 @@ ac_fn_c_find_uintX_t ()
   as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
   { $as_echo "$as_me:${as_lineno-$LINENO}: checking for uint$2_t" >&5
 $as_echo_n "checking for uint$2_t... " >&6; }
-if eval "test \"\${$3+set}\"" = set; then :
+if eval \${$3+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   eval "$3=no"
@@ -2306,7 +2338,8 @@ int
 main ()
 {
 static int test_array [1 - 2 * !((($ac_type) -1 >> ($2 / 2 - 1)) >> ($2 / 2 - 1) == 3)];
-test_array [0] = 0
+test_array [0] = 0;
+return test_array [0];
 
   ;
   return 0;
@@ -2331,7 +2364,7 @@ fi
 eval ac_res=\$$3
 	       { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
 $as_echo "$ac_res" >&6; }
-  eval $as_lineno_stack; test "x$as_lineno_stack" = x && { as_lineno=; unset as_lineno;}
+  eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
 
 } # ac_fn_c_find_uintX_t
 
@@ -2343,7 +2376,7 @@ ac_fn_c_check_func ()
   as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
   { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $2" >&5
 $as_echo_n "checking for $2... " >&6; }
-if eval "test \"\${$3+set}\"" = set; then :
+if eval \${$3+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -2398,7 +2431,7 @@ fi
 eval ac_res=\$$3
 	       { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
 $as_echo "$ac_res" >&6; }
-  eval $as_lineno_stack; test "x$as_lineno_stack" = x && { as_lineno=; unset as_lineno;}
+  eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
 
 } # ac_fn_c_check_func
 cat >config.log <<_ACEOF
@@ -2406,7 +2439,7 @@ This file contains any messages produced by compilers while
 running configure, to aid debugging if configure makes a mistake.
 
 It was created by $as_me, which was
-generated by GNU Autoconf 2.66.  Invocation command line was
+generated by GNU Autoconf 2.69.  Invocation command line was
 
   $ $0 $@
 
@@ -2798,7 +2831,7 @@ $SHELL "$ac_aux_dir/config.sub" sun4 >/dev/null 2>&1 ||
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking build system type" >&5
 $as_echo_n "checking build system type... " >&6; }
-if test "${ac_cv_build+set}" = set; then :
+if ${ac_cv_build+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   ac_build_alias=$build_alias
@@ -2832,7 +2865,7 @@ case $build_os in *\ *) build_os=`echo "$build_os" | sed 's/ /-/g'`;; esac
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking host system type" >&5
 $as_echo_n "checking host system type... " >&6; }
-if test "${ac_cv_host+set}" = set; then :
+if ${ac_cv_host+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test "x$host_alias" = x; then
@@ -2865,7 +2898,7 @@ case $host_os in *\ *) host_os=`echo "$host_os" | sed 's/ /-/g'`;; esac
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking target system type" >&5
 $as_echo_n "checking target system type... " >&6; }
-if test "${ac_cv_target+set}" = set; then :
+if ${ac_cv_target+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test "x$target_alias" = x; then
@@ -2944,7 +2977,7 @@ esac
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for a sed that does not truncate output" >&5
 $as_echo_n "checking for a sed that does not truncate output... " >&6; }
-if test "${ac_cv_path_SED+set}" = set; then :
+if ${ac_cv_path_SED+:} false; then :
   $as_echo_n "(cached) " >&6
 else
             ac_script=s/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa/bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb/
@@ -2964,7 +2997,7 @@ do
     for ac_prog in sed gsed; do
     for ac_exec_ext in '' $ac_executable_extensions; do
       ac_path_SED="$as_dir/$ac_prog$ac_exec_ext"
-      { test -f "$ac_path_SED" && $as_test_x "$ac_path_SED"; } || continue
+      as_fn_executable_p "$ac_path_SED" || continue
 # Check for GNU ac_path_SED and select it if it is found.
   # Check for GNU $ac_path_SED
 case `"$ac_path_SED" --version 2>&1` in
@@ -3017,7 +3050,7 @@ do
 set dummy $ac_prog; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_prog_AWK+set}" = set; then :
+if ${ac_cv_prog_AWK+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test -n "$AWK"; then
@@ -3029,7 +3062,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_prog_AWK="$ac_prog"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -3063,7 +3096,7 @@ if test -n "$ac_tool_prefix"; then
 set dummy ${ac_tool_prefix}gcc; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_prog_CC+set}" = set; then :
+if ${ac_cv_prog_CC+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test -n "$CC"; then
@@ -3075,7 +3108,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_prog_CC="${ac_tool_prefix}gcc"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -3103,7 +3136,7 @@ if test -z "$ac_cv_prog_CC"; then
 set dummy gcc; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_prog_ac_ct_CC+set}" = set; then :
+if ${ac_cv_prog_ac_ct_CC+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test -n "$ac_ct_CC"; then
@@ -3115,7 +3148,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_prog_ac_ct_CC="gcc"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -3156,7 +3189,7 @@ if test -z "$CC"; then
 set dummy ${ac_tool_prefix}cc; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_prog_CC+set}" = set; then :
+if ${ac_cv_prog_CC+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test -n "$CC"; then
@@ -3168,7 +3201,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_prog_CC="${ac_tool_prefix}cc"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -3196,7 +3229,7 @@ if test -z "$CC"; then
 set dummy cc; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_prog_CC+set}" = set; then :
+if ${ac_cv_prog_CC+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test -n "$CC"; then
@@ -3209,7 +3242,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     if test "$as_dir/$ac_word$ac_exec_ext" = "/usr/ucb/cc"; then
        ac_prog_rejected=yes
        continue
@@ -3255,7 +3288,7 @@ if test -z "$CC"; then
 set dummy $ac_tool_prefix$ac_prog; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_prog_CC+set}" = set; then :
+if ${ac_cv_prog_CC+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test -n "$CC"; then
@@ -3267,7 +3300,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_prog_CC="$ac_tool_prefix$ac_prog"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -3299,7 +3332,7 @@ do
 set dummy $ac_prog; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_prog_ac_ct_CC+set}" = set; then :
+if ${ac_cv_prog_ac_ct_CC+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test -n "$ac_ct_CC"; then
@@ -3311,7 +3344,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_prog_ac_ct_CC="$ac_prog"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -3582,7 +3615,7 @@ rm -f conftest.$ac_ext conftest$ac_cv_exeext conftest.out
 ac_clean_files=$ac_clean_files_save
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for suffix of object files" >&5
 $as_echo_n "checking for suffix of object files... " >&6; }
-if test "${ac_cv_objext+set}" = set; then :
+if ${ac_cv_objext+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -3633,7 +3666,7 @@ OBJEXT=$ac_cv_objext
 ac_objext=$OBJEXT
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether we are using the GNU C compiler" >&5
 $as_echo_n "checking whether we are using the GNU C compiler... " >&6; }
-if test "${ac_cv_c_compiler_gnu+set}" = set; then :
+if ${ac_cv_c_compiler_gnu+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -3670,7 +3703,7 @@ ac_test_CFLAGS=${CFLAGS+set}
 ac_save_CFLAGS=$CFLAGS
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $CC accepts -g" >&5
 $as_echo_n "checking whether $CC accepts -g... " >&6; }
-if test "${ac_cv_prog_cc_g+set}" = set; then :
+if ${ac_cv_prog_cc_g+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   ac_save_c_werror_flag=$ac_c_werror_flag
@@ -3748,7 +3781,7 @@ else
 fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $CC option to accept ISO C89" >&5
 $as_echo_n "checking for $CC option to accept ISO C89... " >&6; }
-if test "${ac_cv_prog_cc_c89+set}" = set; then :
+if ${ac_cv_prog_cc_c89+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   ac_cv_prog_cc_c89=no
@@ -3757,8 +3790,7 @@ cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 #include <stdarg.h>
 #include <stdio.h>
-#include <sys/types.h>
-#include <sys/stat.h>
+struct stat;
 /* Most of the following tests are stolen from RCS 5.7's src/conf.sh.  */
 struct buf { int x; };
 FILE * (*rcsopen) (struct buf *, struct stat *, int);
@@ -3857,7 +3889,7 @@ if test -n "$CPP" && test -d "$CPP"; then
   CPP=
 fi
 if test -z "$CPP"; then
-  if test "${ac_cv_prog_CPP+set}" = set; then :
+  if ${ac_cv_prog_CPP+:} false; then :
   $as_echo_n "(cached) " >&6
 else
       # Double quotes because CPP needs to be expanded
@@ -3887,7 +3919,7 @@ else
   # Broken: fails on valid input.
 continue
 fi
-rm -f conftest.err conftest.$ac_ext
+rm -f conftest.err conftest.i conftest.$ac_ext
 
   # OK, works on sane cases.  Now check whether nonexistent headers
   # can be detected and how.
@@ -3903,11 +3935,11 @@ else
 ac_preproc_ok=:
 break
 fi
-rm -f conftest.err conftest.$ac_ext
+rm -f conftest.err conftest.i conftest.$ac_ext
 
 done
 # Because of `break', _AC_PREPROC_IFELSE's cleaning code was skipped.
-rm -f conftest.err conftest.$ac_ext
+rm -f conftest.i conftest.err conftest.$ac_ext
 if $ac_preproc_ok; then :
   break
 fi
@@ -3946,7 +3978,7 @@ else
   # Broken: fails on valid input.
 continue
 fi
-rm -f conftest.err conftest.$ac_ext
+rm -f conftest.err conftest.i conftest.$ac_ext
 
   # OK, works on sane cases.  Now check whether nonexistent headers
   # can be detected and how.
@@ -3962,11 +3994,11 @@ else
 ac_preproc_ok=:
 break
 fi
-rm -f conftest.err conftest.$ac_ext
+rm -f conftest.err conftest.i conftest.$ac_ext
 
 done
 # Because of `break', _AC_PREPROC_IFELSE's cleaning code was skipped.
-rm -f conftest.err conftest.$ac_ext
+rm -f conftest.i conftest.err conftest.$ac_ext
 if $ac_preproc_ok; then :
 
 else
@@ -3985,7 +4017,7 @@ ac_compiler_gnu=$ac_cv_c_compiler_gnu
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for grep that handles long lines and -e" >&5
 $as_echo_n "checking for grep that handles long lines and -e... " >&6; }
-if test "${ac_cv_path_GREP+set}" = set; then :
+if ${ac_cv_path_GREP+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test -z "$GREP"; then
@@ -3999,7 +4031,7 @@ do
     for ac_prog in grep ggrep; do
     for ac_exec_ext in '' $ac_executable_extensions; do
       ac_path_GREP="$as_dir/$ac_prog$ac_exec_ext"
-      { test -f "$ac_path_GREP" && $as_test_x "$ac_path_GREP"; } || continue
+      as_fn_executable_p "$ac_path_GREP" || continue
 # Check for GNU ac_path_GREP and select it if it is found.
   # Check for GNU $ac_path_GREP
 case `"$ac_path_GREP" --version 2>&1` in
@@ -4048,7 +4080,7 @@ $as_echo "$ac_cv_path_GREP" >&6; }
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for egrep" >&5
 $as_echo_n "checking for egrep... " >&6; }
-if test "${ac_cv_path_EGREP+set}" = set; then :
+if ${ac_cv_path_EGREP+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if echo a | $GREP -E '(a|b)' >/dev/null 2>&1
@@ -4065,7 +4097,7 @@ do
     for ac_prog in egrep; do
     for ac_exec_ext in '' $ac_executable_extensions; do
       ac_path_EGREP="$as_dir/$ac_prog$ac_exec_ext"
-      { test -f "$ac_path_EGREP" && $as_test_x "$ac_path_EGREP"; } || continue
+      as_fn_executable_p "$ac_path_EGREP" || continue
 # Check for GNU ac_path_EGREP and select it if it is found.
   # Check for GNU $ac_path_EGREP
 case `"$ac_path_EGREP" --version 2>&1` in
@@ -4116,7 +4148,7 @@ $as_echo "$ac_cv_path_EGREP" >&6; }
 if test $ac_cv_c_compiler_gnu = yes; then
     { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $CC needs -traditional" >&5
 $as_echo_n "checking whether $CC needs -traditional... " >&6; }
-if test "${ac_cv_prog_gcc_traditional+set}" = set; then :
+if ${ac_cv_prog_gcc_traditional+:} false; then :
   $as_echo_n "(cached) " >&6
 else
     ac_pattern="Autoconf.*'x'"
@@ -4172,7 +4204,7 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for a BSD-compatible install" >&5
 $as_echo_n "checking for a BSD-compatible install... " >&6; }
 if test -z "$INSTALL"; then
-if test "${ac_cv_path_install+set}" = set; then :
+if ${ac_cv_path_install+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
@@ -4192,7 +4224,7 @@ case $as_dir/ in #((
     # by default.
     for ac_prog in ginstall scoinst install; do
       for ac_exec_ext in '' $ac_executable_extensions; do
-	if { test -f "$as_dir/$ac_prog$ac_exec_ext" && $as_test_x "$as_dir/$ac_prog$ac_exec_ext"; }; then
+	if as_fn_executable_p "$as_dir/$ac_prog$ac_exec_ext"; then
 	  if test $ac_prog = install &&
 	    grep dspmsg "$as_dir/$ac_prog$ac_exec_ext" >/dev/null 2>&1; then
 	    # AIX install.  It has an incompatible calling convention.
@@ -4263,7 +4295,7 @@ fi
 $as_echo_n "checking whether ${MAKE-make} sets \$(MAKE)... " >&6; }
 set x ${MAKE-make}
 ac_make=`$as_echo "$2" | sed 's/+/p/g; s/[^a-zA-Z0-9_]/_/g'`
-if eval "test \"\${ac_cv_prog_make_${ac_make}_set+set}\"" = set; then :
+if eval \${ac_cv_prog_make_${ac_make}_set+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   cat >conftest.make <<\_ACEOF
@@ -4293,7 +4325,7 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for a thread-safe mkdir -p" >&5
 $as_echo_n "checking for a thread-safe mkdir -p... " >&6; }
 if test -z "$MKDIR_P"; then
-  if test "${ac_cv_path_mkdir+set}" = set; then :
+  if ${ac_cv_path_mkdir+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
@@ -4303,7 +4335,7 @@ do
   test -z "$as_dir" && as_dir=.
     for ac_prog in mkdir gmkdir; do
 	 for ac_exec_ext in '' $ac_executable_extensions; do
-	   { test -f "$as_dir/$ac_prog$ac_exec_ext" && $as_test_x "$as_dir/$ac_prog$ac_exec_ext"; } || continue
+	   as_fn_executable_p "$as_dir/$ac_prog$ac_exec_ext" || continue
 	   case `"$as_dir/$ac_prog$ac_exec_ext" --version 2>&1` in #(
 	     'mkdir (GNU coreutils) '* | \
 	     'mkdir (coreutils) '* | \
@@ -4337,7 +4369,7 @@ if test -n "$ac_tool_prefix"; then
 set dummy ${ac_tool_prefix}ranlib; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_prog_RANLIB+set}" = set; then :
+if ${ac_cv_prog_RANLIB+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test -n "$RANLIB"; then
@@ -4349,7 +4381,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_prog_RANLIB="${ac_tool_prefix}ranlib"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -4377,7 +4409,7 @@ if test -z "$ac_cv_prog_RANLIB"; then
 set dummy ranlib; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_prog_ac_ct_RANLIB+set}" = set; then :
+if ${ac_cv_prog_ac_ct_RANLIB+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test -n "$ac_ct_RANLIB"; then
@@ -4389,7 +4421,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_prog_ac_ct_RANLIB="ranlib"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -4428,7 +4460,7 @@ fi
 set dummy cflow; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_path_CFLOW_CMD+set}" = set; then :
+if ${ac_cv_path_CFLOW_CMD+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   case $CFLOW_CMD in
@@ -4442,7 +4474,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_path_CFLOW_CMD="$as_dir/$ac_word$ac_exec_ext"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -4468,7 +4500,7 @@ fi
 set dummy cscope; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_path_CSCOPE_CMD+set}" = set; then :
+if ${ac_cv_path_CSCOPE_CMD+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   case $CSCOPE_CMD in
@@ -4482,7 +4514,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_path_CSCOPE_CMD="$as_dir/$ac_word$ac_exec_ext"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -4511,7 +4543,7 @@ for ac_hdr in dirent.h sys/ndir.h sys/dir.h ndir.h; do
   as_ac_Header=`$as_echo "ac_cv_header_dirent_$ac_hdr" | $as_tr_sh`
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_hdr that defines DIR" >&5
 $as_echo_n "checking for $ac_hdr that defines DIR... " >&6; }
-if eval "test \"\${$as_ac_Header+set}\"" = set; then :
+if eval \${$as_ac_Header+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -4551,7 +4583,7 @@ done
 if test $ac_header_dirent = dirent.h; then
   { $as_echo "$as_me:${as_lineno-$LINENO}: checking for library containing opendir" >&5
 $as_echo_n "checking for library containing opendir... " >&6; }
-if test "${ac_cv_search_opendir+set}" = set; then :
+if ${ac_cv_search_opendir+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   ac_func_search_save_LIBS=$LIBS
@@ -4585,11 +4617,11 @@ for ac_lib in '' dir; do
 fi
 rm -f core conftest.err conftest.$ac_objext \
     conftest$ac_exeext
-  if test "${ac_cv_search_opendir+set}" = set; then :
+  if ${ac_cv_search_opendir+:} false; then :
   break
 fi
 done
-if test "${ac_cv_search_opendir+set}" = set; then :
+if ${ac_cv_search_opendir+:} false; then :
 
 else
   ac_cv_search_opendir=no
@@ -4608,7 +4640,7 @@ fi
 else
   { $as_echo "$as_me:${as_lineno-$LINENO}: checking for library containing opendir" >&5
 $as_echo_n "checking for library containing opendir... " >&6; }
-if test "${ac_cv_search_opendir+set}" = set; then :
+if ${ac_cv_search_opendir+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   ac_func_search_save_LIBS=$LIBS
@@ -4642,11 +4674,11 @@ for ac_lib in '' x; do
 fi
 rm -f core conftest.err conftest.$ac_objext \
     conftest$ac_exeext
-  if test "${ac_cv_search_opendir+set}" = set; then :
+  if ${ac_cv_search_opendir+:} false; then :
   break
 fi
 done
-if test "${ac_cv_search_opendir+set}" = set; then :
+if ${ac_cv_search_opendir+:} false; then :
 
 else
   ac_cv_search_opendir=no
@@ -4666,7 +4698,7 @@ fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for ANSI C header files" >&5
 $as_echo_n "checking for ANSI C header files... " >&6; }
-if test "${ac_cv_header_stdc+set}" = set; then :
+if ${ac_cv_header_stdc+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -4795,7 +4827,7 @@ done
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether sys/types.h defines makedev" >&5
 $as_echo_n "checking whether sys/types.h defines makedev... " >&6; }
-if test "${ac_cv_header_sys_types_h_makedev+set}" = set; then :
+if ${ac_cv_header_sys_types_h_makedev+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -4823,7 +4855,7 @@ $as_echo "$ac_cv_header_sys_types_h_makedev" >&6; }
 
 if test $ac_cv_header_sys_types_h_makedev = no; then
 ac_fn_c_check_header_mongrel "$LINENO" "sys/mkdev.h" "ac_cv_header_sys_mkdev_h" "$ac_includes_default"
-if test "x$ac_cv_header_sys_mkdev_h" = x""yes; then :
+if test "x$ac_cv_header_sys_mkdev_h" = xyes; then :
 
 $as_echo "#define MAJOR_IN_MKDEV 1" >>confdefs.h
 
@@ -4833,7 +4865,7 @@ fi
 
   if test $ac_cv_header_sys_mkdev_h = no; then
     ac_fn_c_check_header_mongrel "$LINENO" "sys/sysmacros.h" "ac_cv_header_sys_sysmacros_h" "$ac_includes_default"
-if test "x$ac_cv_header_sys_sysmacros_h" = x""yes; then :
+if test "x$ac_cv_header_sys_sysmacros_h" = xyes; then :
 
 $as_echo "#define MAJOR_IN_SYSMACROS 1" >>confdefs.h
 
@@ -4845,7 +4877,7 @@ fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for ANSI C header files" >&5
 $as_echo_n "checking for ANSI C header files... " >&6; }
-if test "${ac_cv_header_stdc+set}" = set; then :
+if ${ac_cv_header_stdc+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -4957,7 +4989,7 @@ fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for sys/wait.h that is POSIX.1 compatible" >&5
 $as_echo_n "checking for sys/wait.h that is POSIX.1 compatible... " >&6; }
-if test "${ac_cv_header_sys_wait_h+set}" = set; then :
+if ${ac_cv_header_sys_wait_h+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -4998,7 +5030,7 @@ fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether time.h and sys/time.h may both be included" >&5
 $as_echo_n "checking whether time.h and sys/time.h may both be included... " >&6; }
-if test "${ac_cv_header_time+set}" = set; then :
+if ${ac_cv_header_time+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -5119,7 +5151,7 @@ done
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for an ANSI C-conforming const" >&5
 $as_echo_n "checking for an ANSI C-conforming const... " >&6; }
-if test "${ac_cv_c_const+set}" = set; then :
+if ${ac_cv_c_const+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -5128,11 +5160,11 @@ else
 int
 main ()
 {
-/* FIXME: Include the comments suggested by Paul. */
+
 #ifndef __cplusplus
-  /* Ultrix mips cc rejects this.  */
+  /* Ultrix mips cc rejects this sort of thing.  */
   typedef int charset[2];
-  const charset cs;
+  const charset cs = { 0, 0 };
   /* SunOS 4.1.1 cc rejects this.  */
   char const *const *pcpcc;
   char **ppc;
@@ -5149,8 +5181,9 @@ main ()
   ++pcpcc;
   ppc = (char**) pcpcc;
   pcpcc = (char const *const *) ppc;
-  { /* SCO 3.2v4 cc rejects this.  */
-    char *t;
+  { /* SCO 3.2v4 cc rejects this sort of thing.  */
+    char tx;
+    char *t = &tx;
     char const *s = 0 ? (char *) 0 : (char const *) 0;
 
     *t++ = 0;
@@ -5166,10 +5199,10 @@ main ()
     iptr p = 0;
     ++p;
   }
-  { /* AIX XL C 1.02.0.0 rejects this saying
+  { /* AIX XL C 1.02.0.0 rejects this sort of thing, saying
        "k.c", line 2.27: 1506-025 (S) Operand must be a modifiable lvalue. */
-    struct s { int j; const int *ap[3]; };
-    struct s *b; b->j = 5;
+    struct s { int j; const int *ap[3]; } bx;
+    struct s *b = &bx; b->j = 5;
   }
   { /* ULTRIX-32 V3.1 (Rev 9) vcc rejects this */
     const int foo = 10;
@@ -5199,7 +5232,7 @@ fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for inline" >&5
 $as_echo_n "checking for inline... " >&6; }
-if test "${ac_cv_c_inline+set}" = set; then :
+if ${ac_cv_c_inline+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   ac_cv_c_inline=no
@@ -5240,7 +5273,7 @@ _ACEOF
 esac
 
 ac_fn_c_check_member "$LINENO" "struct stat" "st_rdev" "ac_cv_member_struct_stat_st_rdev" "$ac_includes_default"
-if test "x$ac_cv_member_struct_stat_st_rdev" = x""yes; then :
+if test "x$ac_cv_member_struct_stat_st_rdev" = xyes; then :
 
 cat >>confdefs.h <<_ACEOF
 #define HAVE_STRUCT_STAT_ST_RDEV 1
@@ -5250,7 +5283,7 @@ _ACEOF
 fi
 
 ac_fn_c_check_type "$LINENO" "off_t" "ac_cv_type_off_t" "$ac_includes_default"
-if test "x$ac_cv_type_off_t" = x""yes; then :
+if test "x$ac_cv_type_off_t" = xyes; then :
 
 else
 
@@ -5261,7 +5294,7 @@ _ACEOF
 fi
 
 ac_fn_c_check_type "$LINENO" "pid_t" "ac_cv_type_pid_t" "$ac_includes_default"
-if test "x$ac_cv_type_pid_t" = x""yes; then :
+if test "x$ac_cv_type_pid_t" = xyes; then :
 
 else
 
@@ -5273,7 +5306,7 @@ fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking return type of signal handlers" >&5
 $as_echo_n "checking return type of signal handlers... " >&6; }
-if test "${ac_cv_type_signal+set}" = set; then :
+if ${ac_cv_type_signal+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -5305,7 +5338,7 @@ _ACEOF
 
 
 ac_fn_c_check_type "$LINENO" "size_t" "ac_cv_type_size_t" "$ac_includes_default"
-if test "x$ac_cv_type_size_t" = x""yes; then :
+if test "x$ac_cv_type_size_t" = xyes; then :
 
 else
 
@@ -5316,7 +5349,7 @@ _ACEOF
 fi
 
 ac_fn_c_check_type "$LINENO" "mode_t" "ac_cv_type_mode_t" "$ac_includes_default"
-if test "x$ac_cv_type_mode_t" = x""yes; then :
+if test "x$ac_cv_type_mode_t" = xyes; then :
 
 else
 
@@ -5371,7 +5404,7 @@ _ACEOF
 esac
 
 ac_fn_c_check_type "$LINENO" "ssize_t" "ac_cv_type_ssize_t" "$ac_includes_default"
-if test "x$ac_cv_type_ssize_t" = x""yes; then :
+if test "x$ac_cv_type_ssize_t" = xyes; then :
 
 else
 
@@ -5383,7 +5416,7 @@ fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for uid_t in sys/types.h" >&5
 $as_echo_n "checking for uid_t in sys/types.h... " >&6; }
-if test "${ac_cv_type_uid_t+set}" = set; then :
+if ${ac_cv_type_uid_t+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -5466,7 +5499,7 @@ _ACEOF
   esac
 
 ac_fn_c_check_member "$LINENO" "struct stat" "st_rdev" "ac_cv_member_struct_stat_st_rdev" "$ac_includes_default"
-if test "x$ac_cv_member_struct_stat_st_rdev" = x""yes; then :
+if test "x$ac_cv_member_struct_stat_st_rdev" = xyes; then :
 
 cat >>confdefs.h <<_ACEOF
 #define HAVE_STRUCT_STAT_ST_RDEV 1
@@ -5477,7 +5510,7 @@ fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether struct tm is in sys/time.h or time.h" >&5
 $as_echo_n "checking whether struct tm is in sys/time.h or time.h... " >&6; }
-if test "${ac_cv_struct_tm+set}" = set; then :
+if ${ac_cv_struct_tm+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -5532,7 +5565,7 @@ done
 for ac_func in siginterrupt
 do :
   ac_fn_c_check_func "$LINENO" "siginterrupt" "ac_cv_func_siginterrupt"
-if test "x$ac_cv_func_siginterrupt" = x""yes; then :
+if test "x$ac_cv_func_siginterrupt" = xyes; then :
   cat >>confdefs.h <<_ACEOF
 #define HAVE_SIGINTERRUPT 1
 _ACEOF
@@ -5544,7 +5577,7 @@ done
 # for constant arguments.  Useless!
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for working alloca.h" >&5
 $as_echo_n "checking for working alloca.h... " >&6; }
-if test "${ac_cv_working_alloca_h+set}" = set; then :
+if ${ac_cv_working_alloca_h+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -5577,7 +5610,7 @@ fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for alloca" >&5
 $as_echo_n "checking for alloca... " >&6; }
-if test "${ac_cv_func_alloca_works+set}" = set; then :
+if ${ac_cv_func_alloca_works+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -5596,7 +5629,7 @@ else
  #pragma alloca
 #   else
 #    ifndef alloca /* predefined by HP cc +Olibcalls */
-char *alloca ();
+void *alloca (size_t);
 #    endif
 #   endif
 #  endif
@@ -5640,7 +5673,7 @@ $as_echo "#define C_ALLOCA 1" >>confdefs.h
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether \`alloca.c' needs Cray hooks" >&5
 $as_echo_n "checking whether \`alloca.c' needs Cray hooks... " >&6; }
-if test "${ac_cv_os_cray+set}" = set; then :
+if ${ac_cv_os_cray+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -5681,7 +5714,7 @@ fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking stack direction for C alloca" >&5
 $as_echo_n "checking stack direction for C alloca... " >&6; }
-if test "${ac_cv_c_stack_direction+set}" = set; then :
+if ${ac_cv_c_stack_direction+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test "$cross_compiling" = yes; then :
@@ -5691,23 +5724,20 @@ else
 /* end confdefs.h.  */
 $ac_includes_default
 int
-find_stack_direction ()
+find_stack_direction (int *addr, int depth)
 {
-  static char *addr = 0;
-  auto char dummy;
-  if (addr == 0)
-    {
-      addr = &dummy;
-      return find_stack_direction ();
-    }
-  else
-    return (&dummy > addr) ? 1 : -1;
+  int dir, dummy = 0;
+  if (! addr)
+    addr = &dummy;
+  *addr = addr < &dummy ? 1 : addr == &dummy ? 0 : -1;
+  dir = depth ? find_stack_direction (addr, depth - 1) : 0;
+  return dir + dummy;
 }
 
 int
-main ()
+main (int argc, char **argv)
 {
-  return find_stack_direction () < 0;
+  return find_stack_direction (0, argc + !argv + 20) < 0;
 }
 _ACEOF
 if ac_fn_c_try_run "$LINENO"; then :
@@ -5731,7 +5761,7 @@ fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether closedir returns void" >&5
 $as_echo_n "checking whether closedir returns void... " >&6; }
-if test "${ac_cv_func_closedir_void+set}" = set; then :
+if ${ac_cv_func_closedir_void+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test "$cross_compiling" = yes; then :
@@ -5774,7 +5804,7 @@ fi
 for ac_header in unistd.h
 do :
   ac_fn_c_check_header_mongrel "$LINENO" "unistd.h" "ac_cv_header_unistd_h" "$ac_includes_default"
-if test "x$ac_cv_header_unistd_h" = x""yes; then :
+if test "x$ac_cv_header_unistd_h" = xyes; then :
   cat >>confdefs.h <<_ACEOF
 #define HAVE_UNISTD_H 1
 _ACEOF
@@ -5785,7 +5815,7 @@ done
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for working chown" >&5
 $as_echo_n "checking for working chown... " >&6; }
-if test "${ac_cv_func_chown_works+set}" = set; then :
+if ${ac_cv_func_chown_works+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test "$cross_compiling" = yes; then :
@@ -5839,7 +5869,7 @@ fi
 for ac_header in vfork.h
 do :
   ac_fn_c_check_header_mongrel "$LINENO" "vfork.h" "ac_cv_header_vfork_h" "$ac_includes_default"
-if test "x$ac_cv_header_vfork_h" = x""yes; then :
+if test "x$ac_cv_header_vfork_h" = xyes; then :
   cat >>confdefs.h <<_ACEOF
 #define HAVE_VFORK_H 1
 _ACEOF
@@ -5863,7 +5893,7 @@ done
 if test "x$ac_cv_func_fork" = xyes; then
   { $as_echo "$as_me:${as_lineno-$LINENO}: checking for working fork" >&5
 $as_echo_n "checking for working fork... " >&6; }
-if test "${ac_cv_func_fork_works+set}" = set; then :
+if ${ac_cv_func_fork_works+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test "$cross_compiling" = yes; then :
@@ -5916,7 +5946,7 @@ ac_cv_func_vfork_works=$ac_cv_func_vfork
 if test "x$ac_cv_func_vfork" = xyes; then
   { $as_echo "$as_me:${as_lineno-$LINENO}: checking for working vfork" >&5
 $as_echo_n "checking for working vfork... " >&6; }
-if test "${ac_cv_func_vfork_works+set}" = set; then :
+if ${ac_cv_func_vfork_works+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test "$cross_compiling" = yes; then :
@@ -6051,7 +6081,7 @@ fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether lstat correctly handles trailing slash" >&5
 $as_echo_n "checking whether lstat correctly handles trailing slash... " >&6; }
-if test "${ac_cv_func_lstat_dereferences_slashed_symlink+set}" = set; then :
+if ${ac_cv_func_lstat_dereferences_slashed_symlink+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   rm -f conftest.sym conftest.file
@@ -6113,7 +6143,7 @@ fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether lstat accepts an empty string" >&5
 $as_echo_n "checking whether lstat accepts an empty string... " >&6; }
-if test "${ac_cv_func_lstat_empty_string_bug+set}" = set; then :
+if ${ac_cv_func_lstat_empty_string_bug+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test "$cross_compiling" = yes; then :
@@ -6160,7 +6190,7 @@ fi
 for ac_header in stdlib.h
 do :
   ac_fn_c_check_header_mongrel "$LINENO" "stdlib.h" "ac_cv_header_stdlib_h" "$ac_includes_default"
-if test "x$ac_cv_header_stdlib_h" = x""yes; then :
+if test "x$ac_cv_header_stdlib_h" = xyes; then :
   cat >>confdefs.h <<_ACEOF
 #define HAVE_STDLIB_H 1
 _ACEOF
@@ -6171,7 +6201,7 @@ done
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for GNU libc compatible malloc" >&5
 $as_echo_n "checking for GNU libc compatible malloc... " >&6; }
-if test "${ac_cv_func_malloc_0_nonnull+set}" = set; then :
+if ${ac_cv_func_malloc_0_nonnull+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test "$cross_compiling" = yes; then :
@@ -6226,7 +6256,7 @@ fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for working memcmp" >&5
 $as_echo_n "checking for working memcmp... " >&6; }
-if test "${ac_cv_func_memcmp_working+set}" = set; then :
+if ${ac_cv_func_memcmp_working+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test "$cross_compiling" = yes; then :
@@ -6313,7 +6343,7 @@ done
 for ac_func in getpagesize
 do :
   ac_fn_c_check_func "$LINENO" "getpagesize" "ac_cv_func_getpagesize"
-if test "x$ac_cv_func_getpagesize" = x""yes; then :
+if test "x$ac_cv_func_getpagesize" = xyes; then :
   cat >>confdefs.h <<_ACEOF
 #define HAVE_GETPAGESIZE 1
 _ACEOF
@@ -6323,7 +6353,7 @@ done
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for working mmap" >&5
 $as_echo_n "checking for working mmap... " >&6; }
-if test "${ac_cv_func_mmap_fixed_mapped+set}" = set; then :
+if ${ac_cv_func_mmap_fixed_mapped+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test "$cross_compiling" = yes; then :
@@ -6490,7 +6520,7 @@ rm -f conftest.mmap conftest.txt
 for ac_header in stdlib.h
 do :
   ac_fn_c_check_header_mongrel "$LINENO" "stdlib.h" "ac_cv_header_stdlib_h" "$ac_includes_default"
-if test "x$ac_cv_header_stdlib_h" = x""yes; then :
+if test "x$ac_cv_header_stdlib_h" = xyes; then :
   cat >>confdefs.h <<_ACEOF
 #define HAVE_STDLIB_H 1
 _ACEOF
@@ -6501,7 +6531,7 @@ done
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for GNU libc compatible realloc" >&5
 $as_echo_n "checking for GNU libc compatible realloc... " >&6; }
-if test "${ac_cv_func_realloc_0_nonnull+set}" = set; then :
+if ${ac_cv_func_realloc_0_nonnull+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test "$cross_compiling" = yes; then :
@@ -6556,7 +6586,7 @@ fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether stat accepts an empty string" >&5
 $as_echo_n "checking whether stat accepts an empty string... " >&6; }
-if test "${ac_cv_func_stat_empty_string_bug+set}" = set; then :
+if ${ac_cv_func_stat_empty_string_bug+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test "$cross_compiling" = yes; then :
@@ -6602,7 +6632,7 @@ fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for working strtod" >&5
 $as_echo_n "checking for working strtod... " >&6; }
-if test "${ac_cv_func_strtod+set}" = set; then :
+if ${ac_cv_func_strtod+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   if test "$cross_compiling" = yes; then :
@@ -6661,14 +6691,14 @@ if test $ac_cv_func_strtod = no; then
 esac
 
 ac_fn_c_check_func "$LINENO" "pow" "ac_cv_func_pow"
-if test "x$ac_cv_func_pow" = x""yes; then :
+if test "x$ac_cv_func_pow" = xyes; then :
 
 fi
 
 if test $ac_cv_func_pow = no; then
   { $as_echo "$as_me:${as_lineno-$LINENO}: checking for pow in -lm" >&5
 $as_echo_n "checking for pow in -lm... " >&6; }
-if test "${ac_cv_lib_m_pow+set}" = set; then :
+if ${ac_cv_lib_m_pow+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   ac_check_lib_save_LIBS=$LIBS
@@ -6702,7 +6732,7 @@ LIBS=$ac_check_lib_save_LIBS
 fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_m_pow" >&5
 $as_echo "$ac_cv_lib_m_pow" >&6; }
-if test "x$ac_cv_lib_m_pow" = x""yes; then :
+if test "x$ac_cv_lib_m_pow" = xyes; then :
   POW_LIB=-lm
 else
   { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: cannot find library containing definition of pow" >&5
@@ -6716,13 +6746,13 @@ fi
 for ac_func in vprintf
 do :
   ac_fn_c_check_func "$LINENO" "vprintf" "ac_cv_func_vprintf"
-if test "x$ac_cv_func_vprintf" = x""yes; then :
+if test "x$ac_cv_func_vprintf" = xyes; then :
   cat >>confdefs.h <<_ACEOF
 #define HAVE_VPRINTF 1
 _ACEOF
 
 ac_fn_c_check_func "$LINENO" "_doprnt" "ac_cv_func__doprnt"
-if test "x$ac_cv_func__doprnt" = x""yes; then :
+if test "x$ac_cv_func__doprnt" = xyes; then :
 
 $as_echo "#define HAVE_DOPRNT 1" >>confdefs.h
 
@@ -6753,7 +6783,7 @@ $as_echo "$STATIC_LINK" >&6; }
     CFLAGS=-pie
     { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $CC accepts -pie flag" >&5
 $as_echo_n "checking whether $CC accepts -pie flag... " >&6; }
-if test "${ac_cv_flag_HAVE_PIE+set}" = set; then :
+if ${ac_cv_flag_HAVE_PIE+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -6791,7 +6821,7 @@ $as_echo "$ac_cv_flag_HAVE_PIE" >&6; }
     LDFLAGS=-Wl,-z,relro,-z,now
 	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $CC accepts -Wl,-z,relro,-z,now ld flags" >&5
 $as_echo_n "checking whether $CC accepts -Wl,-z,relro,-z,now ld flags... " >&6; }
-if test "${ac_cv_flag_HAVE_FULL_RELRO+set}" = set; then :
+if ${ac_cv_flag_HAVE_FULL_RELRO+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -7199,7 +7229,7 @@ case "$THIN" in
 set dummy ${ac_tool_prefix}thin_check; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_path_THIN_CHECK_CMD+set}" = set; then :
+if ${ac_cv_path_THIN_CHECK_CMD+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   case $THIN_CHECK_CMD in
@@ -7213,7 +7243,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_path_THIN_CHECK_CMD="$as_dir/$ac_word$ac_exec_ext"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -7242,7 +7272,7 @@ if test -z "$ac_cv_path_THIN_CHECK_CMD"; then
 set dummy thin_check; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_path_ac_pt_THIN_CHECK_CMD+set}" = set; then :
+if ${ac_cv_path_ac_pt_THIN_CHECK_CMD+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   case $ac_pt_THIN_CHECK_CMD in
@@ -7256,7 +7286,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_path_ac_pt_THIN_CHECK_CMD="$as_dir/$ac_word$ac_exec_ext"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -7306,7 +7336,7 @@ $as_echo "$as_me: WARNING: thin_check not found in path $PATH" >&2;}
 set dummy ${ac_tool_prefix}thin_dump; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_path_THIN_DUMP_CMD+set}" = set; then :
+if ${ac_cv_path_THIN_DUMP_CMD+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   case $THIN_DUMP_CMD in
@@ -7320,7 +7350,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_path_THIN_DUMP_CMD="$as_dir/$ac_word$ac_exec_ext"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -7349,7 +7379,7 @@ if test -z "$ac_cv_path_THIN_DUMP_CMD"; then
 set dummy thin_dump; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_path_ac_pt_THIN_DUMP_CMD+set}" = set; then :
+if ${ac_cv_path_ac_pt_THIN_DUMP_CMD+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   case $ac_pt_THIN_DUMP_CMD in
@@ -7363,7 +7393,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_path_ac_pt_THIN_DUMP_CMD="$as_dir/$ac_word$ac_exec_ext"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -7413,7 +7443,7 @@ $as_echo "$as_me: WARNING: thin_dump not found in path $PATH" >&2;}
 set dummy ${ac_tool_prefix}thin_repair; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_path_THIN_REPAIR_CMD+set}" = set; then :
+if ${ac_cv_path_THIN_REPAIR_CMD+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   case $THIN_REPAIR_CMD in
@@ -7427,7 +7457,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_path_THIN_REPAIR_CMD="$as_dir/$ac_word$ac_exec_ext"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -7456,7 +7486,7 @@ if test -z "$ac_cv_path_THIN_REPAIR_CMD"; then
 set dummy thin_repair; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_path_ac_pt_THIN_REPAIR_CMD+set}" = set; then :
+if ${ac_cv_path_ac_pt_THIN_REPAIR_CMD+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   case $ac_pt_THIN_REPAIR_CMD in
@@ -7470,7 +7500,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_path_ac_pt_THIN_REPAIR_CMD="$as_dir/$ac_word$ac_exec_ext"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -7534,6 +7564,24 @@ cat >>confdefs.h <<_ACEOF
 _ACEOF
 
 
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether thin_check supports the needs-check flag" >&5
+$as_echo_n "checking whether thin_check supports the needs-check flag... " >&6; }
+# Check whether --enable-thin_check_needs_check was given.
+if test "${enable_thin_check_needs_check+set}" = set; then :
+  enableval=$enable_thin_check_needs_check; THIN_CHECK_NEEDS_CHECK=$enableval
+else
+  THIN_CHECK_NEEDS_CHECK=yes
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $THIN_CHECK_NEEDS_CHECK" >&5
+$as_echo "$THIN_CHECK_NEEDS_CHECK" >&6; }
+
+if test x$THIN_CHECK_NEEDS_CHECK = xyes; then
+
+$as_echo "#define THIN_CHECK_NEEDS_CHECK 1" >>confdefs.h
+
+fi
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include cache" >&5
 $as_echo_n "checking whether to include cache... " >&6; }
@@ -7612,13 +7660,14 @@ pkg_config_init() {
 
 
 
+
 if test "x$ac_cv_env_PKG_CONFIG_set" != "xset"; then
 	if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}pkg-config", so it can be a program name with args.
 set dummy ${ac_tool_prefix}pkg-config; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_path_PKG_CONFIG+set}" = set; then :
+if ${ac_cv_path_PKG_CONFIG+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   case $PKG_CONFIG in
@@ -7632,7 +7681,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_path_PKG_CONFIG="$as_dir/$ac_word$ac_exec_ext"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -7661,7 +7710,7 @@ if test -z "$ac_cv_path_PKG_CONFIG"; then
 set dummy pkg-config; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_path_ac_pt_PKG_CONFIG+set}" = set; then :
+if ${ac_cv_path_ac_pt_PKG_CONFIG+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   case $ac_pt_PKG_CONFIG in
@@ -7675,7 +7724,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_path_ac_pt_PKG_CONFIG="$as_dir/$ac_word$ac_exec_ext"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -7740,6 +7789,7 @@ if test -n "$PKGCONFIGINIT_CFLAGS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_PKGCONFIGINIT_CFLAGS=`$PKG_CONFIG --cflags "pkgconfiginit" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -7756,6 +7806,7 @@ if test -n "$PKGCONFIGINIT_LIBS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_PKGCONFIGINIT_LIBS=`$PKG_CONFIG --libs "pkgconfiginit" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -7775,9 +7826,9 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        PKGCONFIGINIT_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "pkgconfiginit" 2>&1`
+	        PKGCONFIGINIT_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "pkgconfiginit" 2>&1`
         else
-	        PKGCONFIGINIT_PKG_ERRORS=`$PKG_CONFIG --print-errors "pkgconfiginit" 2>&1`
+	        PKGCONFIGINIT_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "pkgconfiginit" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$PKGCONFIGINIT_PKG_ERRORS" >&5
@@ -7919,7 +7970,7 @@ check_lib_no_libs() {
 	as_ac_Lib=`$as_echo "ac_cv_lib_$lib_no_libs_arg1''_$lib_no_libs_arg2" | $as_tr_sh`
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $lib_no_libs_arg2 in -l$lib_no_libs_arg1" >&5
 $as_echo_n "checking for $lib_no_libs_arg2 in -l$lib_no_libs_arg1... " >&6; }
-if eval "test \"\${$as_ac_Lib+set}\"" = set; then :
+if eval \${$as_ac_Lib+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   ac_check_lib_save_LIBS=$LIBS
@@ -7984,6 +8035,7 @@ if test -n "$CMAN_CFLAGS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_CMAN_CFLAGS=`$PKG_CONFIG --cflags "libcman" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -8000,6 +8052,7 @@ if test -n "$CMAN_LIBS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_CMAN_LIBS=`$PKG_CONFIG --libs "libcman" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -8019,9 +8072,9 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        CMAN_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libcman" 2>&1`
+	        CMAN_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libcman" 2>&1`
         else
-	        CMAN_PKG_ERRORS=`$PKG_CONFIG --print-errors "libcman" 2>&1`
+	        CMAN_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libcman" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$CMAN_PKG_ERRORS" >&5
@@ -8030,7 +8083,7 @@ fi
 		for ac_header in libcman.h
 do :
   ac_fn_c_check_header_mongrel "$LINENO" "libcman.h" "ac_cv_header_libcman_h" "$ac_includes_default"
-if test "x$ac_cv_header_libcman_h" = x""yes; then :
+if test "x$ac_cv_header_libcman_h" = xyes; then :
   cat >>confdefs.h <<_ACEOF
 #define HAVE_LIBCMAN_H 1
 _ACEOF
@@ -8055,7 +8108,7 @@ $as_echo "no" >&6; }
 		for ac_header in libcman.h
 do :
   ac_fn_c_check_header_mongrel "$LINENO" "libcman.h" "ac_cv_header_libcman_h" "$ac_includes_default"
-if test "x$ac_cv_header_libcman_h" = x""yes; then :
+if test "x$ac_cv_header_libcman_h" = xyes; then :
   cat >>confdefs.h <<_ACEOF
 #define HAVE_LIBCMAN_H 1
 _ACEOF
@@ -8101,6 +8154,7 @@ if test -n "$COROSYNC_CFLAGS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_COROSYNC_CFLAGS=`$PKG_CONFIG --cflags "corosync" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -8117,6 +8171,7 @@ if test -n "$COROSYNC_LIBS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_COROSYNC_LIBS=`$PKG_CONFIG --libs "corosync" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -8136,9 +8191,9 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        COROSYNC_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "corosync" 2>&1`
+	        COROSYNC_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "corosync" 2>&1`
         else
-	        COROSYNC_PKG_ERRORS=`$PKG_CONFIG --print-errors "corosync" 2>&1`
+	        COROSYNC_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "corosync" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$COROSYNC_PKG_ERRORS" >&5
@@ -8175,6 +8230,7 @@ if test -n "$QUORUM_CFLAGS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_QUORUM_CFLAGS=`$PKG_CONFIG --cflags "libquorum" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -8191,6 +8247,7 @@ if test -n "$QUORUM_LIBS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_QUORUM_LIBS=`$PKG_CONFIG --libs "libquorum" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -8210,9 +8267,9 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        QUORUM_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libquorum" 2>&1`
+	        QUORUM_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libquorum" 2>&1`
         else
-	        QUORUM_PKG_ERRORS=`$PKG_CONFIG --print-errors "libquorum" 2>&1`
+	        QUORUM_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libquorum" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$QUORUM_PKG_ERRORS" >&5
@@ -8249,6 +8306,7 @@ if test -n "$SALCK_CFLAGS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_SALCK_CFLAGS=`$PKG_CONFIG --cflags "libSaLck" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -8265,6 +8323,7 @@ if test -n "$SALCK_LIBS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_SALCK_LIBS=`$PKG_CONFIG --libs "libSaLck" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -8284,9 +8343,9 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        SALCK_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libSaLck" 2>&1`
+	        SALCK_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libSaLck" 2>&1`
         else
-	        SALCK_PKG_ERRORS=`$PKG_CONFIG --print-errors "libSaLck" 2>&1`
+	        SALCK_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libSaLck" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$SALCK_PKG_ERRORS" >&5
@@ -8324,6 +8383,7 @@ if test -n "$CONFDB_CFLAGS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_CONFDB_CFLAGS=`$PKG_CONFIG --cflags "libconfdb" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -8340,6 +8400,7 @@ if test -n "$CONFDB_LIBS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_CONFDB_LIBS=`$PKG_CONFIG --libs "libconfdb" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -8359,9 +8420,9 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        CONFDB_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libconfdb" 2>&1`
+	        CONFDB_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libconfdb" 2>&1`
         else
-	        CONFDB_PKG_ERRORS=`$PKG_CONFIG --print-errors "libconfdb" 2>&1`
+	        CONFDB_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libconfdb" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$CONFDB_PKG_ERRORS" >&5
@@ -8382,7 +8443,7 @@ fi
 	for ac_header in corosync/confdb.h
 do :
   ac_fn_c_check_header_mongrel "$LINENO" "corosync/confdb.h" "ac_cv_header_corosync_confdb_h" "$ac_includes_default"
-if test "x$ac_cv_header_corosync_confdb_h" = x""yes; then :
+if test "x$ac_cv_header_corosync_confdb_h" = xyes; then :
   cat >>confdefs.h <<_ACEOF
 #define HAVE_COROSYNC_CONFDB_H 1
 _ACEOF
@@ -8421,6 +8482,7 @@ if test -n "$CMAP_CFLAGS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_CMAP_CFLAGS=`$PKG_CONFIG --cflags "libcmap" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -8437,6 +8499,7 @@ if test -n "$CMAP_LIBS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_CMAP_LIBS=`$PKG_CONFIG --libs "libcmap" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -8456,9 +8519,9 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        CMAP_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libcmap" 2>&1`
+	        CMAP_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libcmap" 2>&1`
         else
-	        CMAP_PKG_ERRORS=`$PKG_CONFIG --print-errors "libcmap" 2>&1`
+	        CMAP_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libcmap" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$CMAP_PKG_ERRORS" >&5
@@ -8479,7 +8542,7 @@ fi
 	for ac_header in corosync/cmap.h
 do :
   ac_fn_c_check_header_mongrel "$LINENO" "corosync/cmap.h" "ac_cv_header_corosync_cmap_h" "$ac_includes_default"
-if test "x$ac_cv_header_corosync_cmap_h" = x""yes; then :
+if test "x$ac_cv_header_corosync_cmap_h" = xyes; then :
   cat >>confdefs.h <<_ACEOF
 #define HAVE_COROSYNC_CMAP_H 1
 _ACEOF
@@ -8525,6 +8588,7 @@ if test -n "$CPG_CFLAGS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_CPG_CFLAGS=`$PKG_CONFIG --cflags "libcpg" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -8541,6 +8605,7 @@ if test -n "$CPG_LIBS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_CPG_LIBS=`$PKG_CONFIG --libs "libcpg" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -8560,9 +8625,9 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        CPG_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libcpg" 2>&1`
+	        CPG_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libcpg" 2>&1`
         else
-	        CPG_PKG_ERRORS=`$PKG_CONFIG --print-errors "libcpg" 2>&1`
+	        CPG_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libcpg" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$CPG_PKG_ERRORS" >&5
@@ -8597,6 +8662,7 @@ if test -n "$DLM_CFLAGS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_DLM_CFLAGS=`$PKG_CONFIG --cflags "libdlm" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -8613,6 +8679,7 @@ if test -n "$DLM_LIBS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_DLM_LIBS=`$PKG_CONFIG --libs "libdlm" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -8632,9 +8699,9 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        DLM_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libdlm" 2>&1`
+	        DLM_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libdlm" 2>&1`
         else
-	        DLM_PKG_ERRORS=`$PKG_CONFIG --print-errors "libdlm" 2>&1`
+	        DLM_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libdlm" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$DLM_PKG_ERRORS" >&5
@@ -8643,7 +8710,7 @@ fi
 		for ac_header in libdlm.h
 do :
   ac_fn_c_check_header_mongrel "$LINENO" "libdlm.h" "ac_cv_header_libdlm_h" "$ac_includes_default"
-if test "x$ac_cv_header_libdlm_h" = x""yes; then :
+if test "x$ac_cv_header_libdlm_h" = xyes; then :
   cat >>confdefs.h <<_ACEOF
 #define HAVE_LIBDLM_H 1
 _ACEOF
@@ -8668,7 +8735,7 @@ $as_echo "no" >&6; }
 		for ac_header in libdlm.h
 do :
   ac_fn_c_check_header_mongrel "$LINENO" "libdlm.h" "ac_cv_header_libdlm_h" "$ac_includes_default"
-if test "x$ac_cv_header_libdlm_h" = x""yes; then :
+if test "x$ac_cv_header_libdlm_h" = xyes; then :
   cat >>confdefs.h <<_ACEOF
 #define HAVE_LIBDLM_H 1
 _ACEOF
@@ -8814,6 +8881,7 @@ if test -n "$SACKPT_CFLAGS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_SACKPT_CFLAGS=`$PKG_CONFIG --cflags "libSaCkpt" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -8830,6 +8898,7 @@ if test -n "$SACKPT_LIBS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_SACKPT_LIBS=`$PKG_CONFIG --libs "libSaCkpt" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -8849,9 +8918,9 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        SACKPT_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libSaCkpt" 2>&1`
+	        SACKPT_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libSaCkpt" 2>&1`
         else
-	        SACKPT_PKG_ERRORS=`$PKG_CONFIG --print-errors "libSaCkpt" 2>&1`
+	        SACKPT_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libSaCkpt" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$SACKPT_PKG_ERRORS" >&5
@@ -8893,6 +8962,7 @@ if test -n "$CPG_CFLAGS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_CPG_CFLAGS=`$PKG_CONFIG --cflags "libcpg" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -8909,6 +8979,7 @@ if test -n "$CPG_LIBS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_CPG_LIBS=`$PKG_CONFIG --libs "libcpg" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -8928,9 +8999,9 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        CPG_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libcpg" 2>&1`
+	        CPG_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libcpg" 2>&1`
         else
-	        CPG_PKG_ERRORS=`$PKG_CONFIG --print-errors "libcpg" 2>&1`
+	        CPG_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libcpg" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$CPG_PKG_ERRORS" >&5
@@ -8945,7 +9016,6 @@ installed software in a non-standard prefix.
 Alternatively, you may set the environment variables CPG_CFLAGS
 and CPG_LIBS to avoid the need to call pkg-config.
 See the pkg-config man page for more details." "$LINENO" 5
-
 elif test $pkg_failed = untried; then
      	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
 $as_echo "no" >&6; }
@@ -8961,7 +9031,6 @@ See the pkg-config man page for more details.
 
 To get pkg-config, see <http://pkg-config.freedesktop.org/>.
 See \`config.log' for more details" "$LINENO" 5; }
-
 else
 	CPG_CFLAGS=$pkg_cv_CPG_CFLAGS
 	CPG_LIBS=$pkg_cv_CPG_LIBS
@@ -8997,7 +9066,7 @@ fi
     CFLAGS=-Wjump-misses-init
     { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $CC accepts -Wjump-misses-init flag" >&5
 $as_echo_n "checking whether $CC accepts -Wjump-misses-init flag... " >&6; }
-if test "${ac_cv_flag_HAVE_WJUMP+set}" = set; then :
+if ${ac_cv_flag_HAVE_WJUMP+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -9035,7 +9104,7 @@ $as_echo "$ac_cv_flag_HAVE_WJUMP" >&6; }
     CFLAGS=-Wclobbered
     { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $CC accepts -Wclobbered flag" >&5
 $as_echo_n "checking whether $CC accepts -Wclobbered flag... " >&6; }
-if test "${ac_cv_flag_HAVE_WCLOBBERED+set}" = set; then :
+if ${ac_cv_flag_HAVE_WCLOBBERED+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
@@ -9099,7 +9168,7 @@ if test "x$PROFILING" = xyes; then
 set dummy lcov; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_path_LCOV+set}" = set; then :
+if ${ac_cv_path_LCOV+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   case $LCOV in
@@ -9113,7 +9182,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_path_LCOV="$as_dir/$ac_word$ac_exec_ext"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -9139,7 +9208,7 @@ fi
 set dummy genhtml; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_path_GENHTML+set}" = set; then :
+if ${ac_cv_path_GENHTML+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   case $GENHTML in
@@ -9153,7 +9222,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_path_GENHTML="$as_dir/$ac_word$ac_exec_ext"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -9182,7 +9251,7 @@ fi
 set dummy genpng; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_path_GENPNG+set}" = set; then :
+if ${ac_cv_path_GENPNG+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   case $GENPNG in
@@ -9196,7 +9265,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_path_GENPNG="$as_dir/$ac_word$ac_exec_ext"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -9267,6 +9336,7 @@ if test -n "$CUNIT_CFLAGS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_CUNIT_CFLAGS=`$PKG_CONFIG --cflags "cunit >= 2.0" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -9283,6 +9353,7 @@ if test -n "$CUNIT_LIBS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_CUNIT_LIBS=`$PKG_CONFIG --libs "cunit >= 2.0" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -9302,9 +9373,9 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        CUNIT_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "cunit >= 2.0" 2>&1`
+	        CUNIT_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "cunit >= 2.0" 2>&1`
         else
-	        CUNIT_PKG_ERRORS=`$PKG_CONFIG --print-errors "cunit >= 2.0" 2>&1`
+	        CUNIT_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "cunit >= 2.0" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$CUNIT_PKG_ERRORS" >&5
@@ -9319,7 +9390,6 @@ installed software in a non-standard prefix.
 Alternatively, you may set the environment variables CUNIT_CFLAGS
 and CUNIT_LIBS to avoid the need to call pkg-config.
 See the pkg-config man page for more details." "$LINENO" 5
-
 elif test $pkg_failed = untried; then
      	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
 $as_echo "no" >&6; }
@@ -9335,7 +9405,6 @@ See the pkg-config man page for more details.
 
 To get pkg-config, see <http://pkg-config.freedesktop.org/>.
 See \`config.log' for more details" "$LINENO" 5; }
-
 else
 	CUNIT_CFLAGS=$pkg_cv_CUNIT_CFLAGS
 	CUNIT_LIBS=$pkg_cv_CUNIT_LIBS
@@ -9374,6 +9443,7 @@ if test -n "$VALGRIND_CFLAGS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_VALGRIND_CFLAGS=`$PKG_CONFIG --cflags "valgrind" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -9390,6 +9460,7 @@ if test -n "$VALGRIND_LIBS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_VALGRIND_LIBS=`$PKG_CONFIG --libs "valgrind" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -9409,9 +9480,9 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        VALGRIND_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "valgrind" 2>&1`
+	        VALGRIND_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "valgrind" 2>&1`
         else
-	        VALGRIND_PKG_ERRORS=`$PKG_CONFIG --print-errors "valgrind" 2>&1`
+	        VALGRIND_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "valgrind" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$VALGRIND_PKG_ERRORS" >&5
@@ -9517,6 +9588,7 @@ if test -n "$BLKID_CFLAGS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_BLKID_CFLAGS=`$PKG_CONFIG --cflags "blkid >= 2.24" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -9533,6 +9605,7 @@ if test -n "$BLKID_LIBS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_BLKID_LIBS=`$PKG_CONFIG --libs "blkid >= 2.24" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -9552,9 +9625,9 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        BLKID_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "blkid >= 2.24" 2>&1`
+	        BLKID_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "blkid >= 2.24" 2>&1`
         else
-	        BLKID_PKG_ERRORS=`$PKG_CONFIG --print-errors "blkid >= 2.24" 2>&1`
+	        BLKID_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "blkid >= 2.24" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$BLKID_PKG_ERRORS" >&5
@@ -9636,6 +9709,7 @@ if test -n "$UDEV_CFLAGS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_UDEV_CFLAGS=`$PKG_CONFIG --cflags "libudev >= 143" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -9652,6 +9726,7 @@ if test -n "$UDEV_LIBS"; then
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
   pkg_cv_UDEV_LIBS=`$PKG_CONFIG --libs "libudev >= 143" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
 fi
@@ -9671,9 +9746,9 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        UDEV_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libudev >= 143" 2>&1`
+	        UDEV_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libudev >= 143" 2>&1`
         else
-	        UDEV_PKG_ERRORS=`$PKG_CONFIG --print-errors "libudev >= 143" 2>&1`
+	        UDEV_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libudev >= 143" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$UDEV_PKG_ERRORS" >&5
@@ -9688,7 +9763,6 @@ installed software in a non-standard prefix.
 Alternatively, you may set the environment variables UDEV_CFLAGS
 and UDEV_LIBS to avoid the need to call pkg-config.
 See the pkg-config man page for more details." "$LINENO" 5
-
 elif test $pkg_failed = untried; then
      	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
 $as_echo "no" >&6; }
@@ -9704,7 +9778,6 @@ See the pkg-config man page for more details.
 
 To get pkg-config, see <http://pkg-config.freedesktop.org/>.
 See \`config.log' for more details" "$LINENO" 5; }
-
 else
 	UDEV_CFLAGS=$pkg_cv_UDEV_CFLAGS
 	UDEV_LIBS=$pkg_cv_UDEV_LIBS
@@ -9864,7 +9937,7 @@ if test x$PYTHON_BINDINGS = xyes; then
 set dummy python; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_path_PYTHON+set}" = set; then :
+if ${ac_cv_path_PYTHON+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   case $PYTHON in
@@ -9878,7 +9951,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_path_PYTHON="$as_dir/$ac_word$ac_exec_ext"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -9910,7 +9983,7 @@ fi
 set dummy python-config; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_path_PYTHON_CONFIG+set}" = set; then :
+if ${ac_cv_path_PYTHON_CONFIG+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   case $PYTHON_CONFIG in
@@ -9924,7 +9997,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_path_PYTHON_CONFIG="$as_dir/$ac_word$ac_exec_ext"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -10031,7 +10104,7 @@ fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for getline in -lc" >&5
 $as_echo_n "checking for getline in -lc... " >&6; }
-if test "${ac_cv_lib_c_getline+set}" = set; then :
+if ${ac_cv_lib_c_getline+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   ac_check_lib_save_LIBS=$LIBS
@@ -10065,7 +10138,7 @@ LIBS=$ac_check_lib_save_LIBS
 fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_c_getline" >&5
 $as_echo "$ac_cv_lib_c_getline" >&6; }
-if test "x$ac_cv_lib_c_getline" = x""yes; then :
+if test "x$ac_cv_lib_c_getline" = xyes; then :
 
 $as_echo "#define HAVE_GETLINE 1" >>confdefs.h
 
@@ -10076,7 +10149,7 @@ fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for canonicalize_file_name in -lc" >&5
 $as_echo_n "checking for canonicalize_file_name in -lc... " >&6; }
-if test "${ac_cv_lib_c_canonicalize_file_name+set}" = set; then :
+if ${ac_cv_lib_c_canonicalize_file_name+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   ac_check_lib_save_LIBS=$LIBS
@@ -10110,7 +10183,7 @@ LIBS=$ac_check_lib_save_LIBS
 fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_c_canonicalize_file_name" >&5
 $as_echo "$ac_cv_lib_c_canonicalize_file_name" >&6; }
-if test "x$ac_cv_lib_c_canonicalize_file_name" = x""yes; then :
+if test "x$ac_cv_lib_c_canonicalize_file_name" = xyes; then :
 
 $as_echo "#define HAVE_CANONICALIZE_FILE_NAME 1" >>confdefs.h
 
@@ -10125,7 +10198,7 @@ fi;
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for dlopen in -ldl" >&5
 $as_echo_n "checking for dlopen in -ldl... " >&6; }
-if test "${ac_cv_lib_dl_dlopen+set}" = set; then :
+if ${ac_cv_lib_dl_dlopen+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   ac_check_lib_save_LIBS=$LIBS
@@ -10159,7 +10232,7 @@ LIBS=$ac_check_lib_save_LIBS
 fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_dl_dlopen" >&5
 $as_echo "$ac_cv_lib_dl_dlopen" >&6; }
-if test "x$ac_cv_lib_dl_dlopen" = x""yes; then :
+if test "x$ac_cv_lib_dl_dlopen" = xyes; then :
 
 
 $as_echo "#define HAVE_LIBDL 1" >>confdefs.h
@@ -10186,7 +10259,7 @@ fi
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for pthread_mutex_lock in -lpthread" >&5
 $as_echo_n "checking for pthread_mutex_lock in -lpthread... " >&6; }
-if test "${ac_cv_lib_pthread_pthread_mutex_lock+set}" = set; then :
+if ${ac_cv_lib_pthread_pthread_mutex_lock+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   ac_check_lib_save_LIBS=$LIBS
@@ -10220,7 +10293,7 @@ LIBS=$ac_check_lib_save_LIBS
 fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_pthread_pthread_mutex_lock" >&5
 $as_echo "$ac_cv_lib_pthread_pthread_mutex_lock" >&6; }
-if test "x$ac_cv_lib_pthread_pthread_mutex_lock" = x""yes; then :
+if test "x$ac_cv_lib_pthread_pthread_mutex_lock" = xyes; then :
   PTHREAD_LIBS="-lpthread"
 else
   hard_bailout
@@ -10242,7 +10315,7 @@ $as_echo "$SELINUX" >&6; }
 if test x$SELINUX = xyes; then
 	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for sepol_check_context in -lsepol" >&5
 $as_echo_n "checking for sepol_check_context in -lsepol... " >&6; }
-if test "${ac_cv_lib_sepol_sepol_check_context+set}" = set; then :
+if ${ac_cv_lib_sepol_sepol_check_context+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   ac_check_lib_save_LIBS=$LIBS
@@ -10276,7 +10349,7 @@ LIBS=$ac_check_lib_save_LIBS
 fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_sepol_sepol_check_context" >&5
 $as_echo "$ac_cv_lib_sepol_sepol_check_context" >&6; }
-if test "x$ac_cv_lib_sepol_sepol_check_context" = x""yes; then :
+if test "x$ac_cv_lib_sepol_sepol_check_context" = xyes; then :
 
 
 $as_echo "#define HAVE_SEPOL 1" >>confdefs.h
@@ -10287,7 +10360,7 @@ fi
 
 	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for is_selinux_enabled in -lselinux" >&5
 $as_echo_n "checking for is_selinux_enabled in -lselinux... " >&6; }
-if test "${ac_cv_lib_selinux_is_selinux_enabled+set}" = set; then :
+if ${ac_cv_lib_selinux_is_selinux_enabled+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   ac_check_lib_save_LIBS=$LIBS
@@ -10321,12 +10394,12 @@ LIBS=$ac_check_lib_save_LIBS
 fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_selinux_is_selinux_enabled" >&5
 $as_echo "$ac_cv_lib_selinux_is_selinux_enabled" >&6; }
-if test "x$ac_cv_lib_selinux_is_selinux_enabled" = x""yes; then :
+if test "x$ac_cv_lib_selinux_is_selinux_enabled" = xyes; then :
 
 		for ac_header in selinux/selinux.h
 do :
   ac_fn_c_check_header_mongrel "$LINENO" "selinux/selinux.h" "ac_cv_header_selinux_selinux_h" "$ac_includes_default"
-if test "x$ac_cv_header_selinux_selinux_h" = x""yes; then :
+if test "x$ac_cv_header_selinux_selinux_h" = xyes; then :
   cat >>confdefs.h <<_ACEOF
 #define HAVE_SELINUX_SELINUX_H 1
 _ACEOF
@@ -10340,7 +10413,7 @@ done
 		for ac_header in selinux/label.h
 do :
   ac_fn_c_check_header_mongrel "$LINENO" "selinux/label.h" "ac_cv_header_selinux_label_h" "$ac_includes_default"
-if test "x$ac_cv_header_selinux_label_h" = x""yes; then :
+if test "x$ac_cv_header_selinux_label_h" = xyes; then :
   cat >>confdefs.h <<_ACEOF
 #define HAVE_SELINUX_LABEL_H 1
 _ACEOF
@@ -10370,7 +10443,7 @@ fi
 if test x$REALTIME = xyes; then
 	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for clock_gettime in -lrt" >&5
 $as_echo_n "checking for clock_gettime in -lrt... " >&6; }
-if test "${ac_cv_lib_rt_clock_gettime+set}" = set; then :
+if ${ac_cv_lib_rt_clock_gettime+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   ac_check_lib_save_LIBS=$LIBS
@@ -10404,7 +10477,7 @@ LIBS=$ac_check_lib_save_LIBS
 fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_rt_clock_gettime" >&5
 $as_echo "$ac_cv_lib_rt_clock_gettime" >&6; }
-if test "x$ac_cv_lib_rt_clock_gettime" = x""yes; then :
+if test "x$ac_cv_lib_rt_clock_gettime" = xyes; then :
   HAVE_REALTIME=yes
 else
   HAVE_REALTIME=no
@@ -10426,7 +10499,7 @@ fi
 for ac_header in getopt.h
 do :
   ac_fn_c_check_header_mongrel "$LINENO" "getopt.h" "ac_cv_header_getopt_h" "$ac_includes_default"
-if test "x$ac_cv_header_getopt_h" = x""yes; then :
+if test "x$ac_cv_header_getopt_h" = xyes; then :
   cat >>confdefs.h <<_ACEOF
 #define HAVE_GETOPT_H 1
 _ACEOF
@@ -10443,7 +10516,7 @@ if test "$READLINE" != no; then
 	lvm_saved_libs=$LIBS
 	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for library containing tgetent" >&5
 $as_echo_n "checking for library containing tgetent... " >&6; }
-if test "${ac_cv_search_tgetent+set}" = set; then :
+if ${ac_cv_search_tgetent+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   ac_func_search_save_LIBS=$LIBS
@@ -10477,11 +10550,11 @@ for ac_lib in '' tinfo ncurses curses termcap termlib; do
 fi
 rm -f core conftest.err conftest.$ac_objext \
     conftest$ac_exeext
-  if test "${ac_cv_search_tgetent+set}" = set; then :
+  if ${ac_cv_search_tgetent+:} false; then :
   break
 fi
 done
-if test "${ac_cv_search_tgetent+set}" = set; then :
+if ${ac_cv_search_tgetent+:} false; then :
 
 else
   ac_cv_search_tgetent=no
@@ -10511,7 +10584,7 @@ fi
 
 		{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for readline in -lreadline" >&5
 $as_echo_n "checking for readline in -lreadline... " >&6; }
-if test "${ac_cv_lib_readline_readline+set}" = set; then :
+if ${ac_cv_lib_readline_readline+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   ac_check_lib_save_LIBS=$LIBS
@@ -10545,7 +10618,7 @@ LIBS=$ac_check_lib_save_LIBS
 fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_readline_readline" >&5
 $as_echo "$ac_cv_lib_readline_readline" >&6; }
-if test "x$ac_cv_lib_readline_readline" = x""yes; then :
+if test "x$ac_cv_lib_readline_readline" = xyes; then :
 
 
 $as_echo "#define READLINE_SUPPORT 1" >>confdefs.h
@@ -10553,7 +10626,7 @@ $as_echo "#define READLINE_SUPPORT 1" >>confdefs.h
 				LIBS=$lvm_saved_libs
 		{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for rl_line_buffer in -lreadline" >&5
 $as_echo_n "checking for rl_line_buffer in -lreadline... " >&6; }
-if test "${ac_cv_lib_readline_rl_line_buffer+set}" = set; then :
+if ${ac_cv_lib_readline_rl_line_buffer+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   ac_check_lib_save_LIBS=$LIBS
@@ -10587,7 +10660,7 @@ LIBS=$ac_check_lib_save_LIBS
 fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_readline_rl_line_buffer" >&5
 $as_echo "$ac_cv_lib_readline_rl_line_buffer" >&6; }
-if test "x$ac_cv_lib_readline_rl_line_buffer" = x""yes; then :
+if test "x$ac_cv_lib_readline_rl_line_buffer" = xyes; then :
    READLINE_LIBS="-lreadline"
 else
 
@@ -10614,7 +10687,7 @@ fi
 	for ac_func in rl_completion_matches
 do :
   ac_fn_c_check_func "$LINENO" "rl_completion_matches" "ac_cv_func_rl_completion_matches"
-if test "x$ac_cv_func_rl_completion_matches" = x""yes; then :
+if test "x$ac_cv_func_rl_completion_matches" = xyes; then :
   cat >>confdefs.h <<_ACEOF
 #define HAVE_RL_COMPLETION_MATCHES 1
 _ACEOF
@@ -10645,7 +10718,7 @@ if test x$INTL = xyes; then
 set dummy msgfmt; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_path_MSGFMT+set}" = set; then :
+if ${ac_cv_path_MSGFMT+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   case $MSGFMT in
@@ -10659,7 +10732,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_path_MSGFMT="$as_dir/$ac_word$ac_exec_ext"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -10837,7 +10910,7 @@ done
 # -lseq on Dynix/PTX, -lgen on Unixware.
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for library containing getmntent" >&5
 $as_echo_n "checking for library containing getmntent... " >&6; }
-if test "${ac_cv_search_getmntent+set}" = set; then :
+if ${ac_cv_search_getmntent+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   ac_func_search_save_LIBS=$LIBS
@@ -10871,11 +10944,11 @@ for ac_lib in '' sun seq gen; do
 fi
 rm -f core conftest.err conftest.$ac_objext \
     conftest$ac_exeext
-  if test "${ac_cv_search_getmntent+set}" = set; then :
+  if ${ac_cv_search_getmntent+:} false; then :
   break
 fi
 done
-if test "${ac_cv_search_getmntent+set}" = set; then :
+if ${ac_cv_search_getmntent+:} false; then :
 
 else
   ac_cv_search_getmntent=no
@@ -10912,7 +10985,7 @@ done
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking types of arguments for select" >&5
 $as_echo_n "checking types of arguments for select... " >&6; }
-if test "${ac_cv_func_select_args+set}" = set; then :
+if ${ac_cv_func_select_args+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   for ac_arg234 in 'fd_set *' 'int *' 'void *'; do
@@ -10946,7 +11019,7 @@ rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
  done
 done
 # Provide a safe default value.
-: ${ac_cv_func_select_args='int,int *,struct timeval *'}
+: "${ac_cv_func_select_args=int,int *,struct timeval *}"
 
 fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_select_args" >&5
@@ -10993,7 +11066,7 @@ done
 	for ac_func in socket
 do :
   ac_fn_c_check_func "$LINENO" "socket" "ac_cv_func_socket"
-if test "x$ac_cv_func_socket" = x""yes; then :
+if test "x$ac_cv_func_socket" = xyes; then :
   cat >>confdefs.h <<_ACEOF
 #define HAVE_SOCKET 1
 _ACEOF
@@ -11009,7 +11082,7 @@ if test x$DMEVENTD = xyes; then
 	for ac_header in arpa/inet.h
 do :
   ac_fn_c_check_header_mongrel "$LINENO" "arpa/inet.h" "ac_cv_header_arpa_inet_h" "$ac_includes_default"
-if test "x$ac_cv_header_arpa_inet_h" = x""yes; then :
+if test "x$ac_cv_header_arpa_inet_h" = xyes; then :
   cat >>confdefs.h <<_ACEOF
 #define HAVE_ARPA_INET_H 1
 _ACEOF
@@ -11026,7 +11099,7 @@ if test x$HAVE_LIBDL = xyes; then
 	for ac_header in dlfcn.h
 do :
   ac_fn_c_check_header_mongrel "$LINENO" "dlfcn.h" "ac_cv_header_dlfcn_h" "$ac_includes_default"
-if test "x$ac_cv_header_dlfcn_h" = x""yes; then :
+if test "x$ac_cv_header_dlfcn_h" = xyes; then :
   cat >>confdefs.h <<_ACEOF
 #define HAVE_DLFCN_H 1
 _ACEOF
@@ -11043,7 +11116,7 @@ if test x$INTL = xyes; then
 	for ac_header in libintl.h
 do :
   ac_fn_c_check_header_mongrel "$LINENO" "libintl.h" "ac_cv_header_libintl_h" "$ac_includes_default"
-if test "x$ac_cv_header_libintl_h" = x""yes; then :
+if test "x$ac_cv_header_libintl_h" = xyes; then :
   cat >>confdefs.h <<_ACEOF
 #define HAVE_LIBINTL_H 1
 _ACEOF
@@ -11079,7 +11152,7 @@ fi
 set dummy modprobe; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_path_MODPROBE_CMD+set}" = set; then :
+if ${ac_cv_path_MODPROBE_CMD+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   case $MODPROBE_CMD in
@@ -11093,7 +11166,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
     ac_cv_path_MODPROBE_CMD="$as_dir/$ac_word$ac_exec_ext"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -11515,10 +11588,21 @@ $as_echo "$as_me: WARNING: cache variable $ac_var contains a newline" >&2;} ;;
      :end' >>confcache
 if diff "$cache_file" confcache >/dev/null 2>&1; then :; else
   if test -w "$cache_file"; then
-    test "x$cache_file" != "x/dev/null" &&
+    if test "x$cache_file" != "x/dev/null"; then
       { $as_echo "$as_me:${as_lineno-$LINENO}: updating cache $cache_file" >&5
 $as_echo "$as_me: updating cache $cache_file" >&6;}
-    cat confcache >$cache_file
+      if test ! -f "$cache_file" || test -h "$cache_file"; then
+	cat confcache >"$cache_file"
+      else
+        case $cache_file in #(
+        */* | ?:*)
+	  mv -f confcache "$cache_file"$$ &&
+	  mv -f "$cache_file"$$ "$cache_file" ;; #(
+        *)
+	  mv -f confcache "$cache_file" ;;
+	esac
+      fi
+    fi
   else
     { $as_echo "$as_me:${as_lineno-$LINENO}: not updating unwritable cache $cache_file" >&5
 $as_echo "$as_me: not updating unwritable cache $cache_file" >&6;}
@@ -11550,7 +11634,7 @@ LTLIBOBJS=$ac_ltlibobjs
 
 
 
-: ${CONFIG_STATUS=./config.status}
+: "${CONFIG_STATUS=./config.status}"
 ac_write_fail=0
 ac_clean_files_save=$ac_clean_files
 ac_clean_files="$ac_clean_files $CONFIG_STATUS"
@@ -11651,6 +11735,7 @@ fi
 IFS=" ""	$as_nl"
 
 # Find who we are.  Look in the path if we contain no directory separator.
+as_myself=
 case $0 in #((
   *[\\/]* ) as_myself=$0 ;;
   *) as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
@@ -11846,16 +11931,16 @@ if (echo >conf$$.file) 2>/dev/null; then
     # ... but there are two gotchas:
     # 1) On MSYS, both `ln -s file dir' and `ln file dir' fail.
     # 2) DJGPP < 2.04 has no symlinks; `ln -s' creates a wrapper executable.
-    # In both cases, we have to default to `cp -p'.
+    # In both cases, we have to default to `cp -pR'.
     ln -s conf$$.file conf$$.dir 2>/dev/null && test ! -f conf$$.exe ||
-      as_ln_s='cp -p'
+      as_ln_s='cp -pR'
   elif ln conf$$.file conf$$ 2>/dev/null; then
     as_ln_s=ln
   else
-    as_ln_s='cp -p'
+    as_ln_s='cp -pR'
   fi
 else
-  as_ln_s='cp -p'
+  as_ln_s='cp -pR'
 fi
 rm -f conf$$ conf$$.exe conf$$.dir/conf$$.file conf$$.file
 rmdir conf$$.dir 2>/dev/null
@@ -11915,28 +12000,16 @@ else
   as_mkdir_p=false
 fi
 
-if test -x / >/dev/null 2>&1; then
-  as_test_x='test -x'
-else
-  if ls -dL / >/dev/null 2>&1; then
-    as_ls_L_option=L
-  else
-    as_ls_L_option=
-  fi
-  as_test_x='
-    eval sh -c '\''
-      if test -d "$1"; then
-	test -d "$1/.";
-      else
-	case $1 in #(
-	-*)set "./$1";;
-	esac;
-	case `ls -ld'$as_ls_L_option' "$1" 2>/dev/null` in #((
-	???[sx]*):;;*)false;;esac;fi
-    '\'' sh
-  '
-fi
-as_executable_p=$as_test_x
+
+# as_fn_executable_p FILE
+# -----------------------
+# Test if FILE is an executable regular file.
+as_fn_executable_p ()
+{
+  test -f "$1" && test -x "$1"
+} # as_fn_executable_p
+as_test_x='test -x'
+as_executable_p=as_fn_executable_p
 
 # Sed expression to map a string onto a valid CPP name.
 as_tr_cpp="eval sed 'y%*$as_cr_letters%P$as_cr_LETTERS%;s%[^_$as_cr_alnum]%_%g'"
@@ -11958,7 +12031,7 @@ cat >>$CONFIG_STATUS <<\_ACEOF || ac_write_fail=1
 # values after options handling.
 ac_log="
 This file was extended by $as_me, which was
-generated by GNU Autoconf 2.66.  Invocation command line was
+generated by GNU Autoconf 2.69.  Invocation command line was
 
   CONFIG_FILES    = $CONFIG_FILES
   CONFIG_HEADERS  = $CONFIG_HEADERS
@@ -12020,10 +12093,10 @@ cat >>$CONFIG_STATUS <<_ACEOF || ac_write_fail=1
 ac_cs_config="`$as_echo "$ac_configure_args" | sed 's/^ //; s/[\\""\`\$]/\\\\&/g'`"
 ac_cs_version="\\
 config.status
-configured by $0, generated by GNU Autoconf 2.66,
+configured by $0, generated by GNU Autoconf 2.69,
   with options \\"\$ac_cs_config\\"
 
-Copyright (C) 2010 Free Software Foundation, Inc.
+Copyright (C) 2012 Free Software Foundation, Inc.
 This config.status script is free software; the Free Software Foundation
 gives unlimited permission to copy, distribute and modify it."
 
@@ -12041,11 +12114,16 @@ ac_need_defaults=:
 while test $# != 0
 do
   case $1 in
-  --*=*)
+  --*=?*)
     ac_option=`expr "X$1" : 'X\([^=]*\)='`
     ac_optarg=`expr "X$1" : 'X[^=]*=\(.*\)'`
     ac_shift=:
     ;;
+  --*=)
+    ac_option=`expr "X$1" : 'X\([^=]*\)='`
+    ac_optarg=
+    ac_shift=:
+    ;;
   *)
     ac_option=$1
     ac_optarg=$2
@@ -12067,6 +12145,7 @@ do
     $ac_shift
     case $ac_optarg in
     *\'*) ac_optarg=`$as_echo "$ac_optarg" | sed "s/'/'\\\\\\\\''/g"` ;;
+    '') as_fn_error $? "missing file argument" ;;
     esac
     as_fn_append CONFIG_FILES " '$ac_optarg'"
     ac_need_defaults=false;;
@@ -12108,7 +12187,7 @@ fi
 _ACEOF
 cat >>$CONFIG_STATUS <<_ACEOF || ac_write_fail=1
 if \$ac_cs_recheck; then
-  set X '$SHELL' '$0' $ac_configure_args \$ac_configure_extra_args --no-create --no-recursion
+  set X $SHELL '$0' $ac_configure_args \$ac_configure_extra_args --no-create --no-recursion
   shift
   \$as_echo "running CONFIG_SHELL=$SHELL \$*" >&6
   CONFIG_SHELL='$SHELL'
@@ -12229,9 +12308,10 @@ fi
 # after its creation but before its name has been assigned to `$tmp'.
 $debug ||
 {
-  tmp=
+  tmp= ac_tmp=
   trap 'exit_status=$?
-  { test -z "$tmp" || test ! -d "$tmp" || rm -fr "$tmp"; } && exit $exit_status
+  : "${ac_tmp:=$tmp}"
+  { test ! -d "$ac_tmp" || rm -fr "$ac_tmp"; } && exit $exit_status
 ' 0
   trap 'as_fn_exit 1' 1 2 13 15
 }
@@ -12239,12 +12319,13 @@ $debug ||
 
 {
   tmp=`(umask 077 && mktemp -d "./confXXXXXX") 2>/dev/null` &&
-  test -n "$tmp" && test -d "$tmp"
+  test -d "$tmp"
 }  ||
 {
   tmp=./conf$$-$RANDOM
   (umask 077 && mkdir "$tmp")
 } || as_fn_error $? "cannot create a temporary directory in ." "$LINENO" 5
+ac_tmp=$tmp
 
 # Set up the scripts for CONFIG_FILES section.
 # No need to generate them if there are no CONFIG_FILES.
@@ -12266,7 +12347,7 @@ else
   ac_cs_awk_cr=$ac_cr
 fi
 
-echo 'BEGIN {' >"$tmp/subs1.awk" &&
+echo 'BEGIN {' >"$ac_tmp/subs1.awk" &&
 _ACEOF
 
 
@@ -12294,7 +12375,7 @@ done
 rm -f conf$$subs.sh
 
 cat >>$CONFIG_STATUS <<_ACEOF || ac_write_fail=1
-cat >>"\$tmp/subs1.awk" <<\\_ACAWK &&
+cat >>"\$ac_tmp/subs1.awk" <<\\_ACAWK &&
 _ACEOF
 sed -n '
 h
@@ -12342,7 +12423,7 @@ t delim
 rm -f conf$$subs.awk
 cat >>$CONFIG_STATUS <<_ACEOF || ac_write_fail=1
 _ACAWK
-cat >>"\$tmp/subs1.awk" <<_ACAWK &&
+cat >>"\$ac_tmp/subs1.awk" <<_ACAWK &&
   for (key in S) S_is_set[key] = 1
   FS = ""
 
@@ -12374,7 +12455,7 @@ if sed "s/$ac_cr//" < /dev/null > /dev/null 2>&1; then
   sed "s/$ac_cr\$//; s/$ac_cr/$ac_cs_awk_cr/g"
 else
   cat
-fi < "$tmp/subs1.awk" > "$tmp/subs.awk" \
+fi < "$ac_tmp/subs1.awk" > "$ac_tmp/subs.awk" \
   || as_fn_error $? "could not setup config files machinery" "$LINENO" 5
 _ACEOF
 
@@ -12408,7 +12489,7 @@ fi # test -n "$CONFIG_FILES"
 # No need to generate them if there are no CONFIG_HEADERS.
 # This happens for instance with `./config.status Makefile'.
 if test -n "$CONFIG_HEADERS"; then
-cat >"$tmp/defines.awk" <<\_ACAWK ||
+cat >"$ac_tmp/defines.awk" <<\_ACAWK ||
 BEGIN {
 _ACEOF
 
@@ -12420,8 +12501,8 @@ _ACEOF
 # handling of long lines.
 ac_delim='%!_!# '
 for ac_last_try in false false :; do
-  ac_t=`sed -n "/$ac_delim/p" confdefs.h`
-  if test -z "$ac_t"; then
+  ac_tt=`sed -n "/$ac_delim/p" confdefs.h`
+  if test -z "$ac_tt"; then
     break
   elif $ac_last_try; then
     as_fn_error $? "could not make $CONFIG_HEADERS" "$LINENO" 5
@@ -12541,7 +12622,7 @@ do
     for ac_f
     do
       case $ac_f in
-      -) ac_f="$tmp/stdin";;
+      -) ac_f="$ac_tmp/stdin";;
       *) # Look for the file first in the build tree, then in the source tree
 	 # (if the path is not absolute).  The absolute path cannot be DOS-style,
 	 # because $ac_f cannot contain `:'.
@@ -12576,7 +12657,7 @@ $as_echo "$as_me: creating $ac_file" >&6;}
     esac
 
     case $ac_tag in
-    *:-:* | *:-) cat >"$tmp/stdin" \
+    *:-:* | *:-) cat >"$ac_tmp/stdin" \
       || as_fn_error $? "could not create $ac_file" "$LINENO" 5 ;;
     esac
     ;;
@@ -12713,21 +12794,22 @@ s&@INSTALL@&$ac_INSTALL&;t t
 s&@MKDIR_P@&$ac_MKDIR_P&;t t
 $ac_datarootdir_hack
 "
-eval sed \"\$ac_sed_extra\" "$ac_file_inputs" | $AWK -f "$tmp/subs.awk" >$tmp/out \
-  || as_fn_error $? "could not create $ac_file" "$LINENO" 5
+eval sed \"\$ac_sed_extra\" "$ac_file_inputs" | $AWK -f "$ac_tmp/subs.awk" \
+  >$ac_tmp/out || as_fn_error $? "could not create $ac_file" "$LINENO" 5
 
 test -z "$ac_datarootdir_hack$ac_datarootdir_seen" &&
-  { ac_out=`sed -n '/\${datarootdir}/p' "$tmp/out"`; test -n "$ac_out"; } &&
-  { ac_out=`sed -n '/^[	 ]*datarootdir[	 ]*:*=/p' "$tmp/out"`; test -z "$ac_out"; } &&
+  { ac_out=`sed -n '/\${datarootdir}/p' "$ac_tmp/out"`; test -n "$ac_out"; } &&
+  { ac_out=`sed -n '/^[	 ]*datarootdir[	 ]*:*=/p' \
+      "$ac_tmp/out"`; test -z "$ac_out"; } &&
   { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: $ac_file contains a reference to the variable \`datarootdir'
 which seems to be undefined.  Please make sure it is defined" >&5
 $as_echo "$as_me: WARNING: $ac_file contains a reference to the variable \`datarootdir'
 which seems to be undefined.  Please make sure it is defined" >&2;}
 
-  rm -f "$tmp/stdin"
+  rm -f "$ac_tmp/stdin"
   case $ac_file in
-  -) cat "$tmp/out" && rm -f "$tmp/out";;
-  *) rm -f "$ac_file" && mv "$tmp/out" "$ac_file";;
+  -) cat "$ac_tmp/out" && rm -f "$ac_tmp/out";;
+  *) rm -f "$ac_file" && mv "$ac_tmp/out" "$ac_file";;
   esac \
   || as_fn_error $? "could not create $ac_file" "$LINENO" 5
  ;;
@@ -12738,20 +12820,20 @@ which seems to be undefined.  Please make sure it is defined" >&2;}
   if test x"$ac_file" != x-; then
     {
       $as_echo "/* $configure_input  */" \
-      && eval '$AWK -f "$tmp/defines.awk"' "$ac_file_inputs"
-    } >"$tmp/config.h" \
+      && eval '$AWK -f "$ac_tmp/defines.awk"' "$ac_file_inputs"
+    } >"$ac_tmp/config.h" \
       || as_fn_error $? "could not create $ac_file" "$LINENO" 5
-    if diff "$ac_file" "$tmp/config.h" >/dev/null 2>&1; then
+    if diff "$ac_file" "$ac_tmp/config.h" >/dev/null 2>&1; then
       { $as_echo "$as_me:${as_lineno-$LINENO}: $ac_file is unchanged" >&5
 $as_echo "$as_me: $ac_file is unchanged" >&6;}
     else
       rm -f "$ac_file"
-      mv "$tmp/config.h" "$ac_file" \
+      mv "$ac_tmp/config.h" "$ac_file" \
 	|| as_fn_error $? "could not create $ac_file" "$LINENO" 5
     fi
   else
     $as_echo "/* $configure_input  */" \
-      && eval '$AWK -f "$tmp/defines.awk"' "$ac_file_inputs" \
+      && eval '$AWK -f "$ac_tmp/defines.awk"' "$ac_file_inputs" \
       || as_fn_error $? "could not create -" "$LINENO" 5
   fi
  ;;
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index c1f088e..507aae1 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -552,6 +552,10 @@
 /* The path to 'thin_check', if available. */
 #undef THIN_CHECK_CMD
 
+/* Define to 1 if the external 'thin_check' tool requires the
+   --clear-needs-check-flag option */
+#undef THIN_CHECK_NEEDS_CHECK
+
 /* The path to 'thin_dump', if available. */
 #undef THIN_DUMP_CMD
 


