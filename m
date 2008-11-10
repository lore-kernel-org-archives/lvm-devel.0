From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Nov 2008 21:25:46 -0000
Subject: LVM2 ./configure ./configure.in lib/misc/confi ...
Message-ID: <20081110212546.7691.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-10 21:25:45

Modified files:
	.              : configure configure.in 
	lib/misc       : configure.h.in 

Log message:
	no need for libdevmapper.h on system any more

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/configure	2008/11/03 22:14:26	1.84
+++ LVM2/configure	2008/11/10 21:25:45	1.85
@@ -11389,151 +11389,6 @@
 
 fi
 
-
-for ac_header in libdevmapper.h
-do
-as_ac_Header=`echo "ac_cv_header_$ac_header" | $as_tr_sh`
-if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
-  { echo "$as_me:$LINENO: checking for $ac_header" >&5
-echo $ECHO_N "checking for $ac_header... $ECHO_C" >&6; }
-if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
-  echo $ECHO_N "(cached) $ECHO_C" >&6
-fi
-ac_res=`eval echo '${'$as_ac_Header'}'`
-	       { echo "$as_me:$LINENO: result: $ac_res" >&5
-echo "${ECHO_T}$ac_res" >&6; }
-else
-  # Is the header compilable?
-{ echo "$as_me:$LINENO: checking $ac_header usability" >&5
-echo $ECHO_N "checking $ac_header usability... $ECHO_C" >&6; }
-cat >conftest.$ac_ext <<_ACEOF
-/* confdefs.h.  */
-_ACEOF
-cat confdefs.h >>conftest.$ac_ext
-cat >>conftest.$ac_ext <<_ACEOF
-/* end confdefs.h.  */
-$ac_includes_default
-#include <$ac_header>
-_ACEOF
-rm -f conftest.$ac_objext
-if { (ac_try="$ac_compile"
-case "(($ac_try" in
-  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
-  *) ac_try_echo=$ac_try;;
-esac
-eval "echo \"\$as_me:$LINENO: $ac_try_echo\"") >&5
-  (eval "$ac_compile") 2>conftest.er1
-  ac_status=$?
-  grep -v '^ *+' conftest.er1 >conftest.err
-  rm -f conftest.er1
-  cat conftest.err >&5
-  echo "$as_me:$LINENO: \$? = $ac_status" >&5
-  (exit $ac_status); } && {
-	 test -z "$ac_c_werror_flag" ||
-	 test ! -s conftest.err
-       } && test -s conftest.$ac_objext; then
-  ac_header_compiler=yes
-else
-  echo "$as_me: failed program was:" >&5
-sed 's/^/| /' conftest.$ac_ext >&5
-
-	ac_header_compiler=no
-fi
-
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
-{ echo "$as_me:$LINENO: result: $ac_header_compiler" >&5
-echo "${ECHO_T}$ac_header_compiler" >&6; }
-
-# Is the header present?
-{ echo "$as_me:$LINENO: checking $ac_header presence" >&5
-echo $ECHO_N "checking $ac_header presence... $ECHO_C" >&6; }
-cat >conftest.$ac_ext <<_ACEOF
-/* confdefs.h.  */
-_ACEOF
-cat confdefs.h >>conftest.$ac_ext
-cat >>conftest.$ac_ext <<_ACEOF
-/* end confdefs.h.  */
-#include <$ac_header>
-_ACEOF
-if { (ac_try="$ac_cpp conftest.$ac_ext"
-case "(($ac_try" in
-  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
-  *) ac_try_echo=$ac_try;;
-esac
-eval "echo \"\$as_me:$LINENO: $ac_try_echo\"") >&5
-  (eval "$ac_cpp conftest.$ac_ext") 2>conftest.er1
-  ac_status=$?
-  grep -v '^ *+' conftest.er1 >conftest.err
-  rm -f conftest.er1
-  cat conftest.err >&5
-  echo "$as_me:$LINENO: \$? = $ac_status" >&5
-  (exit $ac_status); } >/dev/null && {
-	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
-	 test ! -s conftest.err
-       }; then
-  ac_header_preproc=yes
-else
-  echo "$as_me: failed program was:" >&5
-sed 's/^/| /' conftest.$ac_ext >&5
-
-  ac_header_preproc=no
-fi
-
-rm -f conftest.err conftest.$ac_ext
-{ echo "$as_me:$LINENO: result: $ac_header_preproc" >&5
-echo "${ECHO_T}$ac_header_preproc" >&6; }
-
-# So?  What about this header?
-case $ac_header_compiler:$ac_header_preproc:$ac_c_preproc_warn_flag in
-  yes:no: )
-    { echo "$as_me:$LINENO: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&5
-echo "$as_me: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&2;}
-    { echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the compiler's result" >&5
-echo "$as_me: WARNING: $ac_header: proceeding with the compiler's result" >&2;}
-    ac_header_preproc=yes
-    ;;
-  no:yes:* )
-    { echo "$as_me:$LINENO: WARNING: $ac_header: present but cannot be compiled" >&5
-echo "$as_me: WARNING: $ac_header: present but cannot be compiled" >&2;}
-    { echo "$as_me:$LINENO: WARNING: $ac_header:     check for missing prerequisite headers?" >&5
-echo "$as_me: WARNING: $ac_header:     check for missing prerequisite headers?" >&2;}
-    { echo "$as_me:$LINENO: WARNING: $ac_header: see the Autoconf documentation" >&5
-echo "$as_me: WARNING: $ac_header: see the Autoconf documentation" >&2;}
-    { echo "$as_me:$LINENO: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&5
-echo "$as_me: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&2;}
-    { echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the preprocessor's result" >&5
-echo "$as_me: WARNING: $ac_header: proceeding with the preprocessor's result" >&2;}
-    { echo "$as_me:$LINENO: WARNING: $ac_header: in the future, the compiler will take precedence" >&5
-echo "$as_me: WARNING: $ac_header: in the future, the compiler will take precedence" >&2;}
-
-    ;;
-esac
-{ echo "$as_me:$LINENO: checking for $ac_header" >&5
-echo $ECHO_N "checking for $ac_header... $ECHO_C" >&6; }
-if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
-  echo $ECHO_N "(cached) $ECHO_C" >&6
-else
-  eval "$as_ac_Header=\$ac_header_preproc"
-fi
-ac_res=`eval echo '${'$as_ac_Header'}'`
-	       { echo "$as_me:$LINENO: result: $ac_res" >&5
-echo "${ECHO_T}$ac_res" >&6; }
-
-fi
-if test `eval echo '${'$as_ac_Header'}'` = yes; then
-  cat >>confdefs.h <<_ACEOF
-#define `echo "HAVE_$ac_header" | $as_tr_cpp` 1
-_ACEOF
-
-else
-  { { echo "$as_me:$LINENO: error: bailing out" >&5
-echo "$as_me: error: bailing out" >&2;}
-   { (exit 1); exit 1; }; }
-fi
-
-done
-
-
 if test x$HAVE_SELINUX = xyes; then
 
 for ac_header in selinux/selinux.h
--- LVM2/configure.in	2008/11/03 22:14:26	1.88
+++ LVM2/configure.in	2008/11/10 21:25:45	1.89
@@ -666,8 +666,6 @@
 	AC_CHECK_HEADERS(libintl.h,,AC_MSG_ERROR(bailing out))
 fi
 
-AC_CHECK_HEADERS(libdevmapper.h,,AC_MSG_ERROR(bailing out))
-
 if test x$HAVE_SELINUX = xyes; then
 	AC_CHECK_HEADERS(selinux/selinux.h,,AC_MSG_ERROR(bailing out))
 fi
--- LVM2/lib/misc/configure.h.in	2008/11/01 02:19:17	1.8
+++ LVM2/lib/misc/configure.h.in	2008/11/10 21:25:45	1.9
@@ -90,9 +90,6 @@
 /* Define to 1 if you have the <inttypes.h> header file. */
 #undef HAVE_INTTYPES_H
 
-/* Define to 1 if you have the <libdevmapper.h> header file. */
-#undef HAVE_LIBDEVMAPPER_H
-
 /* Define to 1 if dynamic libraries are available. */
 #undef HAVE_LIBDL
 


