From: meyering@sourceware.org <meyering@sourceware.org>
Date: 24 Jul 2008 14:54:27 -0000
Subject: LVM2 configure
Message-ID: <20080724145427.6071.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2008-07-24 14:54:26

Modified files:
	.              : configure 

Log message:
	configure: regenerate

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.74&r2=1.75

--- LVM2/configure	2008/07/09 09:59:41	1.74
+++ LVM2/configure	2008/07/24 14:54:26	1.75
@@ -8509,7 +8509,7 @@
 if test "${enable_readline+set}" = set; then
   enableval=$enable_readline; READLINE=$enableval
 else
-  READLINE=yes
+  READLINE=maybe
 fi
 
 { echo "$as_me:$LINENO: result: $READLINE" >&5
@@ -8783,7 +8783,7 @@
 fi;
 
 ################################################################################
-if test x$READLINE = xyes; then
+if test x$READLINE != xno; then
 	{ echo "$as_me:$LINENO: checking for library containing tgetent" >&5
 echo $ECHO_N "checking for library containing tgetent... $ECHO_C" >&6; }
 if test "${ac_cv_search_tgetent+set}" = set; then
@@ -8864,9 +8864,13 @@
 ac_res=$ac_cv_search_tgetent
 if test "$ac_res" != no; then
   test "$ac_res" = "none required" || LIBS="$ac_res $LIBS"
-
+  tg_found=yes
 else
-  { { echo "$as_me:$LINENO: error: termcap could not be found which is required for the
+  tg_found=no
+fi
+
+	test x$READLINE:$tg_found = xyes:no &&
+	  { { echo "$as_me:$LINENO: error: termcap could not be found which is required for the
 --enable-readline option (which is enabled by default).  Either disable readline
 support with --disable-readline or download and install termcap from:
 	ftp.gnu.org/gnu/termcap
@@ -8885,9 +8889,6 @@
   not found either - but you could try installing that as well.
 " >&2;}
    { (exit 1); exit 1; }; }
-
-fi
-
 fi
 
 ################################################################################
@@ -9488,9 +9489,8 @@
 
 
 ################################################################################
-if test x$READLINE = xyes; then
-
-{ echo "$as_me:$LINENO: checking for readline in -lreadline" >&5
+if test x$READLINE != xno; then
+	{ echo "$as_me:$LINENO: checking for readline in -lreadline" >&5
 echo $ECHO_N "checking for readline in -lreadline... $ECHO_C" >&6; }
 if test "${ac_cv_lib_readline_readline+set}" = set; then
   echo $ECHO_N "(cached) $ECHO_C" >&6
@@ -9552,14 +9552,13 @@
 { echo "$as_me:$LINENO: result: $ac_cv_lib_readline_readline" >&5
 echo "${ECHO_T}$ac_cv_lib_readline_readline" >&6; }
 if test $ac_cv_lib_readline_readline = yes; then
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_LIBREADLINE 1
-_ACEOF
-
-  LIBS="-lreadline $LIBS"
-
+  rl_found=yes
 else
-  { { echo "$as_me:$LINENO: error: GNU Readline could not be found which is required for the
+  rl_found=no
+fi
+
+	test x$READLINE:$rl_found = xyes:no &&
+	  { { echo "$as_me:$LINENO: error: GNU Readline could not be found which is required for the
 --enable-readline option (which is enabled by default).  Either disable readline
 support with --disable-readline or download and install readline from:
 	ftp.gnu.org/gnu/readline
@@ -9574,10 +9573,8 @@
 package as well (which may be called readline-devel or something similar).
 " >&2;}
    { (exit 1); exit 1; }; }
-
-fi
-
-	{ echo "$as_me:$LINENO: checking for rl_completion_matches" >&5
+	if test $rl_found = yes; then
+		{ echo "$as_me:$LINENO: checking for rl_completion_matches" >&5
 echo $ECHO_N "checking for rl_completion_matches... $ECHO_C" >&6; }
 if test "${ac_cv_func_rl_completion_matches+set}" = set; then
   echo $ECHO_N "(cached) $ECHO_C" >&6
@@ -9671,6 +9668,7 @@
 #define READLINE_SUPPORT 1
 _ACEOF
 
+	fi
 fi
 
 ################################################################################


