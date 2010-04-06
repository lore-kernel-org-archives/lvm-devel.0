From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 6 Apr 2010 11:53:55 -0000
Subject: LVM2 Makefile.in WHATS_NEW configure configure.in
Message-ID: <20100406115355.12879.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-04-06 11:53:54

Modified files:
	.              : Makefile.in WHATS_NEW configure configure.in 

Log message:
	As lcov module is not installed with GD.pm dependency we need
	to check for presence of this module and avoid using --frames
	option for genhtml in this case.
	
	Fix arg list for AC_PATH_PROG for lcov and genhtml.
	(detecting empty LCOV and GENHTML string in Makefiles).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1500&r2=1.1501
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.123&r2=1.124
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.133&r2=1.134

--- LVM2/Makefile.in	2010/04/06 09:54:11	1.49
+++ LVM2/Makefile.in	2010/04/06 11:53:53	1.50
@@ -112,7 +112,7 @@
 	for i in $(LCOV_TRACES); do \
 		test -s $$i && lc="$$lc $$i"; \
 	done; \
-	test -z "$$lc" || $(GENHTML) --frames -p @abs_top_builddir@ \
+	test -z "$$lc" || $(GENHTML) -p @abs_top_builddir@ \
 		-o $(LCOV_REPORTS_DIR) $$lc
 endif
 
--- LVM2/WHATS_NEW	2010/04/01 11:43:24	1.1500
+++ LVM2/WHATS_NEW	2010/04/06 11:53:53	1.1501
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Fix lcov rules and generate better coverage report.
   Improve vg_validate to detect some loops in lists.
   Change most remaining log_error WARNING messages to log_warn.
   Always use blocking lock for VGs and orphan locks.
--- LVM2/configure	2010/03/23 14:44:42	1.123
+++ LVM2/configure	2010/04/06 11:53:53	1.124
@@ -704,6 +704,7 @@
 MSGFMT
 LVM2CMD_LIB
 LVM2APP_LIB
+GENPNG
 GENHTML
 LCOV
 SACKPT_LIBS
@@ -12114,7 +12115,6 @@
 done
 IFS=$as_save_IFS
 
-  test -z "$ac_cv_path_LCOV" && ac_cv_path_LCOV="no"
   ;;
 esac
 fi
@@ -12155,7 +12155,6 @@
 done
 IFS=$as_save_IFS
 
-  test -z "$ac_cv_path_GENHTML" && ac_cv_path_GENHTML="no"
   ;;
 esac
 fi
@@ -12169,11 +12168,66 @@
 fi
 
 
-  if test "$LCOV" = no -o "$GENHTML" = no ; then
+  if test -z "$LCOV" -o -z "$GENHTML"; then
     { { $as_echo "$as_me:$LINENO: error: lcov and genhtml are required for profiling" >&5
 $as_echo "$as_me: error: lcov and genhtml are required for profiling" >&2;}
    { (exit 1); exit 1; }; }
   fi
+  # Extract the first word of "genpng", so it can be a program name with args.
+set dummy genpng; ac_word=$2
+{ $as_echo "$as_me:$LINENO: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if test "${ac_cv_path_GENPNG+set}" = set; then
+  $as_echo_n "(cached) " >&6
+else
+  case $GENPNG in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_GENPNG="$GENPNG" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+  for ac_exec_ext in '' $ac_executable_extensions; do
+  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+    ac_cv_path_GENPNG="$as_dir/$ac_word$ac_exec_ext"
+    $as_echo "$as_me:$LINENO: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+done
+IFS=$as_save_IFS
+
+  ;;
+esac
+fi
+GENPNG=$ac_cv_path_GENPNG
+if test -n "$GENPNG"; then
+  { $as_echo "$as_me:$LINENO: result: $GENPNG" >&5
+$as_echo "$GENPNG" >&6; }
+else
+  { $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+  if test -n "$GENPNG"; then
+    { $as_echo "$as_me:$LINENO: checking whether $GENPNG has all required modules" >&5
+$as_echo_n "checking whether $GENPNG has all required modules... " >&6; }
+    if $GENPNG --help > /dev/null 2>&1 ; then
+      { $as_echo "$as_me:$LINENO: result: ok" >&5
+$as_echo "ok" >&6; }
+      GENHTML="$GENHTML --frames"
+    else
+      { $as_echo "$as_me:$LINENO: result: not supported" >&5
+$as_echo "not supported" >&6; }
+      { $as_echo "$as_me:$LINENO: WARNING: GD.pm perl module is not installed" >&5
+$as_echo "$as_me: WARNING: GD.pm perl module is not installed" >&2;}
+      GENPNG=
+    fi
+  fi
 fi
 
 ################################################################################
--- LVM2/configure.in	2010/03/23 14:43:18	1.133
+++ LVM2/configure.in	2010/04/06 11:53:53	1.134
@@ -624,11 +624,23 @@
 
 if test "x$PROFILING" = xyes; then
   COPTIMISE_FLAG="$COPTIMISE_FLAG -fprofile-arcs -ftest-coverage"
-  AC_PATH_PROG(LCOV, lcov, no)
-  AC_PATH_PROG(GENHTML, genhtml, no)
-  if test "$LCOV" = no -o "$GENHTML" = no ; then
+  AC_PATH_PROG(LCOV, lcov)
+  AC_PATH_PROG(GENHTML, genhtml)
+  if test -z "$LCOV" -o -z "$GENHTML"; then
     AC_MSG_ERROR([lcov and genhtml are required for profiling])
   fi
+  AC_PATH_PROG(GENPNG, genpng)
+  if test -n "$GENPNG"; then
+    AC_MSG_CHECKING([whether $GENPNG has all required modules])
+    if $GENPNG --help > /dev/null 2>&1 ; then
+      AC_MSG_RESULT(ok)
+      GENHTML="$GENHTML --frames"
+    else
+      AC_MSG_RESULT(not supported)
+      AC_MSG_WARN([GD.pm perl module is not installed])
+      GENPNG=
+    fi
+  fi
 fi
 
 ################################################################################


