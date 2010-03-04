From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Mar 2010 11:19:17 -0000
Subject: LVM2 ./configure ./configure.in ./make.tmpl.in ...
Message-ID: <20100304111917.15035.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-04 11:19:16

Modified files:
	.              : configure configure.in make.tmpl.in 
	lib/misc       : configure.h.in 
	tools          : Makefile.in 

Log message:
	Readline linking update
	
	Modify linking of readline library. Create new  substituted varible
	READLINE_LIBS - readline library is linked ONLY with tools that really use
	it - i.e. lvm. (Static lvm does not use readlin).
	Previous behaviour put this library into the variable LIBS and thus
	linked it with all created object files of lvm project (i.e. plugins...).
	
	READLINE detection is simplified.
	
	Termcap library is linked in only if readline library doesn't have its own
	dependency (i.e. old distributions).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.126&r2=1.127
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.78&r2=1.79
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.106&r2=1.107

--- LVM2/configure	2010/03/04 11:09:08	1.116
+++ LVM2/configure	2010/03/04 11:19:15	1.117
@@ -653,6 +653,7 @@
 STATICDIR
 SNAPSHOTS
 SELINUX_LIBS
+READLINE_LIBS
 POOL
 PKGCONFIG
 OWNER
@@ -12615,119 +12616,6 @@
 fi;
 
 ################################################################################
-if test x$READLINE != xno; then
-	{ $as_echo "$as_me:$LINENO: checking for library containing tgetent" >&5
-$as_echo_n "checking for library containing tgetent... " >&6; }
-if test "${ac_cv_search_tgetent+set}" = set; then
-  $as_echo_n "(cached) " >&6
-else
-  ac_func_search_save_LIBS=$LIBS
-cat >conftest.$ac_ext <<_ACEOF
-/* confdefs.h.  */
-_ACEOF
-cat confdefs.h >>conftest.$ac_ext
-cat >>conftest.$ac_ext <<_ACEOF
-/* end confdefs.h.  */
-
-/* Override any GCC internal prototype to avoid an error.
-   Use char because int might match the return type of a GCC
-   builtin and then its argument prototype would still apply.  */
-#ifdef __cplusplus
-extern "C"
-#endif
-char tgetent ();
-int
-main ()
-{
-return tgetent ();
-  ;
-  return 0;
-}
-_ACEOF
-for ac_lib in '' tinfo ncurses curses termcap termlib; do
-  if test -z "$ac_lib"; then
-    ac_res="none required"
-  else
-    ac_res=-l$ac_lib
-    LIBS="-l$ac_lib  $ac_func_search_save_LIBS"
-  fi
-  rm -f conftest.$ac_objext conftest$ac_exeext
-if { (ac_try="$ac_link"
-case "(($ac_try" in
-  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
-  *) ac_try_echo=$ac_try;;
-esac
-eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
-$as_echo "$ac_try_echo") >&5
-  (eval "$ac_link") 2>conftest.er1
-  ac_status=$?
-  grep -v '^ *+' conftest.er1 >conftest.err
-  rm -f conftest.er1
-  cat conftest.err >&5
-  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
-  (exit $ac_status); } && {
-	 test -z "$ac_c_werror_flag" ||
-	 test ! -s conftest.err
-       } && test -s conftest$ac_exeext && {
-	 test "$cross_compiling" = yes ||
-	 $as_test_x conftest$ac_exeext
-       }; then
-  ac_cv_search_tgetent=$ac_res
-else
-  $as_echo "$as_me: failed program was:" >&5
-sed 's/^/| /' conftest.$ac_ext >&5
-
-
-fi
-
-rm -rf conftest.dSYM
-rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
-      conftest$ac_exeext
-  if test "${ac_cv_search_tgetent+set}" = set; then
-  break
-fi
-done
-if test "${ac_cv_search_tgetent+set}" = set; then
-  :
-else
-  ac_cv_search_tgetent=no
-fi
-rm conftest.$ac_ext
-LIBS=$ac_func_search_save_LIBS
-fi
-{ $as_echo "$as_me:$LINENO: result: $ac_cv_search_tgetent" >&5
-$as_echo "$ac_cv_search_tgetent" >&6; }
-ac_res=$ac_cv_search_tgetent
-if test "$ac_res" != no; then
-  test "$ac_res" = "none required" || LIBS="$ac_res $LIBS"
-  tg_found=yes
-else
-  tg_found=no
-fi
-
-	test x$READLINE:$tg_found = xyes:no &&
-	  { { $as_echo "$as_me:$LINENO: error: termcap could not be found which is required for the
---enable-readline option (which is enabled by default).  Either disable readline
-support with --disable-readline or download and install termcap from:
-	ftp.gnu.org/gnu/termcap
-Note: if you are using precompiled packages you will also need the development
-  package as well (which may be called termcap-devel or something similar).
-Note: (n)curses also seems to work as a substitute for termcap.  This was
-  not found either - but you could try installing that as well.
-" >&5
-$as_echo "$as_me: error: termcap could not be found which is required for the
---enable-readline option (which is enabled by default).  Either disable readline
-support with --disable-readline or download and install termcap from:
-	ftp.gnu.org/gnu/termcap
-Note: if you are using precompiled packages you will also need the development
-  package as well (which may be called termcap-devel or something similar).
-Note: (n)curses also seems to work as a substitute for termcap.  This was
-  not found either - but you could try installing that as well.
-" >&2;}
-   { (exit 1); exit 1; }; }
-fi
-
-################################################################################
 { $as_echo "$as_me:$LINENO: checking for dlopen in -ldl" >&5
 $as_echo_n "checking for dlopen in -ldl... " >&6; }
 if test "${ac_cv_lib_dl_dlopen+set}" = set; then
@@ -13340,9 +13228,116 @@
 
 ################################################################################
 if test x$READLINE != xno; then
-	rl_found=yes
+	lvm_saved_libs=$LIBS
+	{ $as_echo "$as_me:$LINENO: checking for library containing tgetent" >&5
+$as_echo_n "checking for library containing tgetent... " >&6; }
+if test "${ac_cv_search_tgetent+set}" = set; then
+  $as_echo_n "(cached) " >&6
+else
+  ac_func_search_save_LIBS=$LIBS
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
 
-{ $as_echo "$as_me:$LINENO: checking for readline in -lreadline" >&5
+/* Override any GCC internal prototype to avoid an error.
+   Use char because int might match the return type of a GCC
+   builtin and then its argument prototype would still apply.  */
+#ifdef __cplusplus
+extern "C"
+#endif
+char tgetent ();
+int
+main ()
+{
+return tgetent ();
+  ;
+  return 0;
+}
+_ACEOF
+for ac_lib in '' tinfo ncurses curses termcap termlib; do
+  if test -z "$ac_lib"; then
+    ac_res="none required"
+  else
+    ac_res=-l$ac_lib
+    LIBS="-l$ac_lib  $ac_func_search_save_LIBS"
+  fi
+  rm -f conftest.$ac_objext conftest$ac_exeext
+if { (ac_try="$ac_link"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_link") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest$ac_exeext && {
+	 test "$cross_compiling" = yes ||
+	 $as_test_x conftest$ac_exeext
+       }; then
+  ac_cv_search_tgetent=$ac_res
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+
+fi
+
+rm -rf conftest.dSYM
+rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
+      conftest$ac_exeext
+  if test "${ac_cv_search_tgetent+set}" = set; then
+  break
+fi
+done
+if test "${ac_cv_search_tgetent+set}" = set; then
+  :
+else
+  ac_cv_search_tgetent=no
+fi
+rm conftest.$ac_ext
+LIBS=$ac_func_search_save_LIBS
+fi
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_search_tgetent" >&5
+$as_echo "$ac_cv_search_tgetent" >&6; }
+ac_res=$ac_cv_search_tgetent
+if test "$ac_res" != no; then
+  test "$ac_res" = "none required" || LIBS="$ac_res $LIBS"
+  READLINE_LIBS=$ac_cv_search_tgetent
+else
+
+		if test "$READLINE" = yes; then
+			{ { $as_echo "$as_me:$LINENO: error: termcap could not be found which is required for the
+--enable-readline option (which is enabled by default).  Either disable readline
+support with --disable-readline or download and install termcap from:
+	ftp.gnu.org/gnu/termcap
+Note: if you are using precompiled packages you will also need the development
+  package as well (which may be called termcap-devel or something similar).
+Note: (n)curses also seems to work as a substitute for termcap.  This was
+  not found either - but you could try installing that as well." >&5
+$as_echo "$as_me: error: termcap could not be found which is required for the
+--enable-readline option (which is enabled by default).  Either disable readline
+support with --disable-readline or download and install termcap from:
+	ftp.gnu.org/gnu/termcap
+Note: if you are using precompiled packages you will also need the development
+  package as well (which may be called termcap-devel or something similar).
+Note: (n)curses also seems to work as a substitute for termcap.  This was
+  not found either - but you could try installing that as well." >&2;}
+   { (exit 1); exit 1; }; }
+		fi
+fi
+
+		{ $as_echo "$as_me:$LINENO: checking for readline in -lreadline" >&5
 $as_echo_n "checking for readline in -lreadline... " >&6; }
 if test "${ac_cv_lib_readline_readline+set}" = set; then
   $as_echo_n "(cached) " >&6
@@ -13408,33 +13403,109 @@
 { $as_echo "$as_me:$LINENO: result: $ac_cv_lib_readline_readline" >&5
 $as_echo "$ac_cv_lib_readline_readline" >&6; }
 if test "x$ac_cv_lib_readline_readline" = x""yes; then
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_LIBREADLINE 1
+
+
+cat >>confdefs.h <<\_ACEOF
+#define READLINE_SUPPORT 1
 _ACEOF
 
-  LIBS="-lreadline $LIBS"
+				LIBS=$lvm_saved_libs
+		{ $as_echo "$as_me:$LINENO: checking for rl_line_buffer in -lreadline" >&5
+$as_echo_n "checking for rl_line_buffer in -lreadline... " >&6; }
+if test "${ac_cv_lib_readline_rl_line_buffer+set}" = set; then
+  $as_echo_n "(cached) " >&6
+else
+  ac_check_lib_save_LIBS=$LIBS
+LIBS="-lreadline  $LIBS"
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
 
+/* Override any GCC internal prototype to avoid an error.
+   Use char because int might match the return type of a GCC
+   builtin and then its argument prototype would still apply.  */
+#ifdef __cplusplus
+extern "C"
+#endif
+char rl_line_buffer ();
+int
+main ()
+{
+return rl_line_buffer ();
+  ;
+  return 0;
+}
+_ACEOF
+rm -f conftest.$ac_objext conftest$ac_exeext
+if { (ac_try="$ac_link"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_link") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest$ac_exeext && {
+	 test "$cross_compiling" = yes ||
+	 $as_test_x conftest$ac_exeext
+       }; then
+  ac_cv_lib_readline_rl_line_buffer=yes
 else
-  rl_found=no
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_cv_lib_readline_rl_line_buffer=no
 fi
 
-	test x$READLINE:$rl_found = xyes:no &&
-	  { { $as_echo "$as_me:$LINENO: error: GNU Readline could not be found which is required for the
+rm -rf conftest.dSYM
+rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
+      conftest$ac_exeext conftest.$ac_ext
+LIBS=$ac_check_lib_save_LIBS
+fi
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_lib_readline_rl_line_buffer" >&5
+$as_echo "$ac_cv_lib_readline_rl_line_buffer" >&6; }
+if test "x$ac_cv_lib_readline_rl_line_buffer" = x""yes; then
+   READLINE_LIBS="-lreadline"
+else
+
+			  { $as_echo "$as_me:$LINENO: result: linking -lreadline with $READLINE_LIBS needed" >&5
+$as_echo "linking -lreadline with $READLINE_LIBS needed" >&6; }
+			  READLINE_LIBS="-lreadline $READLINE_LIBS"
+
+fi
+
+else
+
+		READLINE_LIBS=
+		if test "$READLINE" = yes; then
+			{ { $as_echo "$as_me:$LINENO: error: GNU Readline could not be found which is required for the
 --enable-readline option (which is enabled by default).  Either disable readline
 support with --disable-readline or download and install readline from:
 	ftp.gnu.org/gnu/readline
 Note: if you are using precompiled packages you will also need the development
-package as well (which may be called readline-devel or something similar).
-" >&5
+package as well (which may be called readline-devel or something similar)." >&5
 $as_echo "$as_me: error: GNU Readline could not be found which is required for the
 --enable-readline option (which is enabled by default).  Either disable readline
 support with --disable-readline or download and install readline from:
 	ftp.gnu.org/gnu/readline
 Note: if you are using precompiled packages you will also need the development
-package as well (which may be called readline-devel or something similar).
-" >&2;}
+package as well (which may be called readline-devel or something similar)." >&2;}
    { (exit 1); exit 1; }; }
-	if test $rl_found = yes; then
+		fi
+fi
+
+	LIBS="$READLINE_LIBS $lvm_saved_libs"
 
 for ac_func in rl_completion_matches
 do
@@ -13536,12 +13607,7 @@
 fi
 done
 
-
-cat >>confdefs.h <<\_ACEOF
-#define READLINE_SUPPORT 1
-_ACEOF
-
-	fi
+	LIBS=$lvm_saved_libs
 fi
 
 ################################################################################
@@ -15530,6 +15596,7 @@
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
 
--- LVM2/configure.in	2010/03/04 11:09:09	1.126
+++ LVM2/configure.in	2010/03/04 11:19:15	1.127
@@ -788,24 +788,6 @@
 fi;
 
 ################################################################################
-dnl -- Check for termcap (Shamelessly copied from parted 1.4.17)
-if test x$READLINE != xno; then
-	AC_SEARCH_LIBS([tgetent], [tinfo ncurses curses termcap termlib],
-	  [tg_found=yes], [tg_found=no])
-	test x$READLINE:$tg_found = xyes:no &&
-	  AC_MSG_ERROR(
-termcap could not be found which is required for the
---enable-readline option (which is enabled by default).  Either disable readline
-support with --disable-readline or download and install termcap from:
-	ftp.gnu.org/gnu/termcap
-Note: if you are using precompiled packages you will also need the development
-  package as well (which may be called termcap-devel or something similar).
-Note: (n)curses also seems to work as a substitute for termcap.  This was
-  not found either - but you could try installing that as well.
-)
-fi
-
-################################################################################
 dnl -- Check for dlopen
 AC_CHECK_LIB(dl, dlopen, HAVE_LIBDL=yes, HAVE_LIBDL=no)
 
@@ -887,22 +869,44 @@
 ################################################################################
 dnl -- Check for readline (Shamelessly copied from parted 1.4.17)
 if test x$READLINE != xno; then
-	rl_found=yes
-	AC_CHECK_LIB([readline], [readline], , [rl_found=no])
-	test x$READLINE:$rl_found = xyes:no &&
-	  AC_MSG_ERROR(
-GNU Readline could not be found which is required for the
+	lvm_saved_libs=$LIBS
+	AC_SEARCH_LIBS([tgetent], [tinfo ncurses curses termcap termlib],
+		READLINE_LIBS=$ac_cv_search_tgetent, [
+		if test "$READLINE" = yes; then
+			AC_MSG_ERROR(
+[termcap could not be found which is required for the
+--enable-readline option (which is enabled by default).  Either disable readline
+support with --disable-readline or download and install termcap from:
+	ftp.gnu.org/gnu/termcap
+Note: if you are using precompiled packages you will also need the development
+  package as well (which may be called termcap-devel or something similar).
+Note: (n)curses also seems to work as a substitute for termcap.  This was
+  not found either - but you could try installing that as well.])
+		fi])
+	dnl -- Old systems may need extra termcap dependency explicitly in LIBS
+	AC_CHECK_LIB([readline], [readline], [
+		AC_DEFINE([READLINE_SUPPORT], 1,
+			[Define to 1 to include the LVM readline shell.])
+		dnl -- Try only with -lreadline and check for different symbol
+		LIBS=$lvm_saved_libs
+		AC_CHECK_LIB([readline], [rl_line_buffer],
+			[ READLINE_LIBS="-lreadline" ], [
+			  AC_MSG_RESULT([linking -lreadline with $READLINE_LIBS needed])
+			  READLINE_LIBS="-lreadline $READLINE_LIBS"
+			]) ], [
+		READLINE_LIBS=
+		if test "$READLINE" = yes; then
+			AC_MSG_ERROR(
+[GNU Readline could not be found which is required for the
 --enable-readline option (which is enabled by default).  Either disable readline
 support with --disable-readline or download and install readline from:
 	ftp.gnu.org/gnu/readline
 Note: if you are using precompiled packages you will also need the development
-package as well (which may be called readline-devel or something similar).
-)
-	if test $rl_found = yes; then
-		AC_CHECK_FUNCS([rl_completion_matches])
-		AC_DEFINE([READLINE_SUPPORT], 1,
-		  [Define to 1 to include the LVM readline shell.])
-	fi
+package as well (which may be called readline-devel or something similar).])
+		fi ])
+	LIBS="$READLINE_LIBS $lvm_saved_libs"
+	AC_CHECK_FUNCS([rl_completion_matches])
+	LIBS=$lvm_saved_libs
 fi
 
 ################################################################################
@@ -1123,6 +1127,7 @@
 AC_SUBST(POOL)
 AC_SUBST(QUORUM_CFLAGS)
 AC_SUBST(QUORUM_LIBS)
+AC_SUBST(READLINE_LIBS)
 AC_SUBST(SACKPT_CFLAGS)
 AC_SUBST(SACKPT_LIBS)
 AC_SUBST(SALCK_CFLAGS)
--- LVM2/make.tmpl.in	2010/03/04 11:12:39	1.78
+++ LVM2/make.tmpl.in	2010/03/04 11:19:15	1.79
@@ -37,6 +37,7 @@
 LDFLAGS += @LDFLAGS@
 LIB_SUFFIX = @LIB_SUFFIX@
 LVMINTERNAL_LIBS = -llvm-internal
+READLINE_LIBS = @READLINE_LIBS@
 
 # Setup directory variables
 prefix = @prefix@
--- LVM2/lib/misc/configure.h.in	2009/09/28 21:23:02	1.15
+++ LVM2/lib/misc/configure.h.in	2010/03/04 11:19:15	1.16
@@ -120,9 +120,6 @@
 /* Define to 1 if you have the <libintl.h> header file. */
 #undef HAVE_LIBINTL_H
 
-/* Define to 1 if you have the `readline' library (-lreadline). */
-#undef HAVE_LIBREADLINE
-
 /* Define to 1 if you have the <limits.h> header file. */
 #undef HAVE_LIMITS_H
 
--- LVM2/tools/Makefile.in	2010/03/04 11:12:40	1.106
+++ LVM2/tools/Makefile.in	2010/03/04 11:19:16	1.107
@@ -123,7 +123,7 @@
 
 lvm: $(OBJECTS) lvm.o $(top_builddir)/lib/liblvm-internal.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) lvm.o \
-		$(LVMLIBS) $(LIBS) $(LIB_PTHREAD) -rdynamic
+		$(LVMLIBS) $(READLINE_LIBS) $(LIBS) $(LIB_PTHREAD) -rdynamic
 
 lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a  $(interfacebuilddir)/libdevmapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) -o $@ \


