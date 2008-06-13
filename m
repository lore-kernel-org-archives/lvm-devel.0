From: meyering@sourceware.org <meyering@sourceware.org>
Date: 13 Jun 2008 14:37:21 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in li ...
Message-ID: <20080613143721.28502.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2008-06-13 14:37:19

Modified files:
	.              : WHATS_NEW configure configure.in 
	lib/misc       : configure.h.in 

Log message:
	Begin syncing configure.in for merge/unification with device-mapper.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.903&r2=1.904
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2008/06/13 12:15:55	1.903
+++ LVM2/WHATS_NEW	2008/06/13 14:37:15	1.904
@@ -1,5 +1,6 @@
 Version 2.02.39 -
 ================================
+  Begin syncing configure.in for merge/unification with device-mapper.
   Fix add_mirror_images not to dereference uninitialized log_lv upon failure.
   Don't call openlog for every debug line output by clvmd.
   Add --force to lvextend and lvresize.
--- LVM2/configure	2008/05/19 20:06:33	1.68
+++ LVM2/configure	2008/06/13 14:37:15	1.69
@@ -671,6 +671,9 @@
 ac_ct_CC
 EXEEXT
 OBJEXT
+CPP
+GREP
+EGREP
 INSTALL_PROGRAM
 INSTALL_SCRIPT
 INSTALL_DATA
@@ -679,46 +682,51 @@
 RANLIB
 CFLOW_CMD
 CSCOPE_CMD
-CPP
-GREP
-EGREP
 ALLOCA
 LIBOBJS
 POW_LIB
 MSGFMT
 MODPROBE_CMD
-JOBS
-STATIC_LINK
-LVM1
-POOL
-SNAPSHOTS
-MIRRORS
-OWNER
-GROUP
-COPTIMISE_FLAG
+BUILD_DMEVENTD
 CLDFLAGS
-CLDWHOLEARCHIVE
 CLDNOWHOLEARCHIVE
-LDDEPS
-LIB_SUFFIX
-LVM_VERSION
-LVM1_FALLBACK
+CLDWHOLEARCHIVE
+CLUSTER
+CLVMD
+CMDLIB
+COPTIMISE_FLAG
 DEBUG
 DEVMAPPER
+DMDIR
+DMEVENTD
+DM_COMPAT
+DM_DEVICE_GID
+DM_DEVICE_MODE
+DM_DEVICE_UID
+DM_IOCTLS
+DM_LIB_VERSION
+FSADM
+GROUP
 HAVE_LIBDL
-HAVE_SELINUX
 HAVE_REALTIME
-CMDLIB
+HAVE_SELINUX
+INTL
+INTL_PACKAGE
+JOBS
+LDDEPS
+LIB_SUFFIX
 LOCALEDIR
+LVM1
+LVM1_FALLBACK
 CONFDIR
+LVM_VERSION
+MIRRORS
+OWNER
+PKGCONFIG
+POOL
+SNAPSHOTS
 STATICDIR
-DMDIR
-INTL_PACKAGE
-INTL
-CLVMD
-CLUSTER
-FSADM
-DMEVENTD
+STATIC_LINK
 LIB_PTHREAD
 LTLIBOBJS'
 ac_subst_files=''
@@ -1304,13 +1312,9 @@
 Optional Features:
   --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
   --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
-  --enable-jobs=NUM       Number of jobs to run simultaneously
   --enable-lvm1_fallback  Use this to fall back and use LVM1 binaries if
                           device-mapper is missing from the kernel
-  --enable-static_link    Use this to link the tools to their libraries
-                          statically.  Default is dynamic linking
   --enable-readline       Enable readline support
-  --disable-selinux       Disable selinux support
   --disable-realtime      Disable realtime clock support
   --enable-debug          Enable debugging
   --disable-devmapper     Disable device-mapper interaction
@@ -1318,13 +1322,16 @@
   --enable-cmdlib         Build shared command library
   --enable-fsadm          Enable fsadm
   --enable-dmeventd       Enable the device-mapper event daemon
+  --enable-static_link    Use this to link the tools to their libraries
+                          statically.  Default is dynamic linking
+  --disable-selinux       Disable selinux support
   --enable-nls            Enable Native Language Support
 
 Optional Packages:
   --with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]
   --without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
-  --with-user=USER        Set the owner of installed files
-  --with-group=GROUP      Set the group owner of installed files
+  --with-user=USER        Set the owner of installed files [USER=root]
+  --with-group=GROUP      Set the group owner of installed files [GROUP=root]
   --with-lvm1=TYPE        LVM1 metadata support: internal/shared/none
                           TYPE=internal
   --with-pool=TYPE        GFS pool read-only support: internal/shared/none
@@ -1337,8 +1344,8 @@
                           TYPE=internal
   --with-clvmd=TYPE       Build cluster LVM Daemon: cman/gulm/none/all
                           TYPE=none
-  --with-optimisation=OPT C optimisation flag OPT=-O2
-  --with-localedir=DIR    Translation files in DIR PREFIX/share/locale
+  --with-optimisation=OPT C optimisation flag [OPT=-O2]
+  --with-localedir=DIR    Translation files in DIR [PREFIX/share/locale]
   --with-confdir=DIR      Configuration files in DIR /etc
   --with-staticdir=DIR    Static binary in DIR EXEC_PREFIX/sbin
   --with-dmdir=DIR        Build against device-mapper source tree in DIR
@@ -1776,8 +1783,6 @@
 
 
 
-
-################################################################################
 ac_config_headers="$ac_config_headers lib/misc/configure.h"
 
 
@@ -1944,35 +1949,36 @@
 
 case "$host_os" in
 	linux*)
-		CFLAGS="$CFLAGS"
 		COPTIMISE_FLAG="-O2"
 		CLDFLAGS="$CLDFLAGS -Wl,--version-script,.export.sym"
 		CLDWHOLEARCHIVE="-Wl,-whole-archive"
 		CLDNOWHOLEARCHIVE="-Wl,-no-whole-archive"
 		LDDEPS="$LDDEPS .export.sym"
 		LDFLAGS="$LDFLAGS -Wl,--export-dynamic"
-		LIB_SUFFIX="so"
+		LIB_SUFFIX=so
 		DEVMAPPER=yes
 		ODIRECT=yes
+		DM_IOCTLS=yes
 		SELINUX=yes
 		REALTIME=yes
 		CLUSTER=internal
-		FSADM=no ;;
+		FSADM=no
+		;;
 	darwin*)
 		CFLAGS="$CFLAGS -no-cpp-precomp -fno-common"
 		COPTIMISE_FLAG="-O2"
 		CLDFLAGS="$CLDFLAGS"
 		CLDWHOLEARCHIVE="-all_load"
 		CLDNOWHOLEARCHIVE=
-		LDDEPS="$LDDEPS"
-		LDFLAGS="$LDFLAGS"
-		LIB_SUFFIX="dylib"
+		LIB_SUFFIX=dylib
 		DEVMAPPER=yes
 		ODIRECT=no
+		DM_IOCTLS=no
 		SELINUX=no
 		REALTIME=no
 		CLUSTER=none
-		FSADM=no ;;
+		FSADM=no
+		;;
 esac
 
 ################################################################################
@@ -2937,939 +2943,990 @@
 ac_link='$CC -o conftest$ac_exeext $CFLAGS $CPPFLAGS $LDFLAGS conftest.$ac_ext $LIBS >&5'
 ac_compiler_gnu=$ac_cv_c_compiler_gnu
 
-# Find a good install program.  We prefer a C program (faster),
-# so one script is as good as another.  But avoid the broken or
-# incompatible versions:
-# SysV /etc/install, /usr/sbin/install
-# SunOS /usr/etc/install
-# IRIX /sbin/install
-# AIX /bin/install
-# AmigaOS /C/install, which installs bootblocks on floppy discs
-# AIX 4 /usr/bin/installbsd, which doesn't work without a -g flag
-# AFS /usr/afsws/bin/install, which mishandles nonexistent args
-# SVR4 /usr/ucb/install, which tries to use the nonexistent group "staff"
-# OS/2's system install, which has a completely different semantic
-# ./install, which can be erroneously created by make from ./install.sh.
-{ echo "$as_me:$LINENO: checking for a BSD-compatible install" >&5
-echo $ECHO_N "checking for a BSD-compatible install... $ECHO_C" >&6; }
-if test -z "$INSTALL"; then
-if test "${ac_cv_path_install+set}" = set; then
+
+
+ac_ext=c
+ac_cpp='$CPP $CPPFLAGS'
+ac_compile='$CC -c $CFLAGS $CPPFLAGS conftest.$ac_ext >&5'
+ac_link='$CC -o conftest$ac_exeext $CFLAGS $CPPFLAGS $LDFLAGS conftest.$ac_ext $LIBS >&5'
+ac_compiler_gnu=$ac_cv_c_compiler_gnu
+{ echo "$as_me:$LINENO: checking how to run the C preprocessor" >&5
+echo $ECHO_N "checking how to run the C preprocessor... $ECHO_C" >&6; }
+# On Suns, sometimes $CPP names a directory.
+if test -n "$CPP" && test -d "$CPP"; then
+  CPP=
+fi
+if test -z "$CPP"; then
+  if test "${ac_cv_prog_CPP+set}" = set; then
   echo $ECHO_N "(cached) $ECHO_C" >&6
 else
-  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
+      # Double quotes because CPP needs to be expanded
+    for CPP in "$CC -E" "$CC -E -traditional-cpp" "/lib/cpp"
+    do
+      ac_preproc_ok=false
+for ac_c_preproc_warn_flag in '' yes
 do
-  IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
-  # Account for people who put trailing slashes in PATH elements.
-case $as_dir/ in
-  ./ | .// | /cC/* | \
-  /etc/* | /usr/sbin/* | /usr/etc/* | /sbin/* | /usr/afsws/bin/* | \
-  ?:\\/os2\\/install\\/* | ?:\\/OS2\\/INSTALL\\/* | \
-  /usr/ucb/* ) ;;
-  *)
-    # OSF1 and SCO ODT 3.0 have their own names for install.
-    # Don't use installbsd from OSF since it installs stuff as root
-    # by default.
-    for ac_prog in ginstall scoinst install; do
-      for ac_exec_ext in '' $ac_executable_extensions; do
-	if { test -f "$as_dir/$ac_prog$ac_exec_ext" && $as_test_x "$as_dir/$ac_prog$ac_exec_ext"; }; then
-	  if test $ac_prog = install &&
-	    grep dspmsg "$as_dir/$ac_prog$ac_exec_ext" >/dev/null 2>&1; then
-	    # AIX install.  It has an incompatible calling convention.
-	    :
-	  elif test $ac_prog = install &&
-	    grep pwplus "$as_dir/$ac_prog$ac_exec_ext" >/dev/null 2>&1; then
-	    # program-specific install script used by HP pwplus--don't use.
-	    :
-	  else
-	    ac_cv_path_install="$as_dir/$ac_prog$ac_exec_ext -c"
-	    break 3
-	  fi
-	fi
-      done
-    done
-    ;;
+  # Use a header file that comes with gcc, so configuring glibc
+  # with a fresh cross-compiler works.
+  # Prefer <limits.h> to <assert.h> if __STDC__ is defined, since
+  # <limits.h> exists even on freestanding compilers.
+  # On the NeXT, cc -E runs the code through the compiler's parser,
+  # not just through cpp. "Syntax error" is here to catch this case.
+  cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+#ifdef __STDC__
+# include <limits.h>
+#else
+# include <assert.h>
+#endif
+		     Syntax error
+_ACEOF
+if { (ac_try="$ac_cpp conftest.$ac_ext"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
 esac
-done
-IFS=$as_save_IFS
-
+eval "echo \"\$as_me:$LINENO: $ac_try_echo\"") >&5
+  (eval "$ac_cpp conftest.$ac_ext") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } >/dev/null && {
+	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       }; then
+  :
+else
+  echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
 
+  # Broken: fails on valid input.
+continue
 fi
-  if test "${ac_cv_path_install+set}" = set; then
-    INSTALL=$ac_cv_path_install
-  else
-    # As a last resort, use the slow shell script.  Don't cache a
-    # value for INSTALL within a source directory, because that will
-    # break other packages using the cache if that directory is
-    # removed, or if the value is a relative name.
-    INSTALL=$ac_install_sh
-  fi
-fi
-{ echo "$as_me:$LINENO: result: $INSTALL" >&5
-echo "${ECHO_T}$INSTALL" >&6; }
 
-# Use test -z because SunOS4 sh mishandles braces in ${var-val}.
-# It thinks the first close brace ends the variable substitution.
-test -z "$INSTALL_PROGRAM" && INSTALL_PROGRAM='${INSTALL}'
+rm -f conftest.err conftest.$ac_ext
 
-test -z "$INSTALL_SCRIPT" && INSTALL_SCRIPT='${INSTALL}'
+  # OK, works on sane cases.  Now check whether nonexistent headers
+  # can be detected and how.
+  cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+#include <ac_nonexistent.h>
+_ACEOF
+if { (ac_try="$ac_cpp conftest.$ac_ext"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval "echo \"\$as_me:$LINENO: $ac_try_echo\"") >&5
+  (eval "$ac_cpp conftest.$ac_ext") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } >/dev/null && {
+	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       }; then
+  # Broken: success on invalid input.
+continue
+else
+  echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
 
-test -z "$INSTALL_DATA" && INSTALL_DATA='${INSTALL} -m 644'
+  # Passes both tests.
+ac_preproc_ok=:
+break
+fi
 
-{ echo "$as_me:$LINENO: checking whether ln -s works" >&5
-echo $ECHO_N "checking whether ln -s works... $ECHO_C" >&6; }
-LN_S=$as_ln_s
-if test "$LN_S" = "ln -s"; then
-  { echo "$as_me:$LINENO: result: yes" >&5
-echo "${ECHO_T}yes" >&6; }
-else
-  { echo "$as_me:$LINENO: result: no, using $LN_S" >&5
-echo "${ECHO_T}no, using $LN_S" >&6; }
+rm -f conftest.err conftest.$ac_ext
+
+done
+# Because of `break', _AC_PREPROC_IFELSE's cleaning code was skipped.
+rm -f conftest.err conftest.$ac_ext
+if $ac_preproc_ok; then
+  break
 fi
 
-{ echo "$as_me:$LINENO: checking whether ${MAKE-make} sets \$(MAKE)" >&5
-echo $ECHO_N "checking whether ${MAKE-make} sets \$(MAKE)... $ECHO_C" >&6; }
-set x ${MAKE-make}; ac_make=`echo "$2" | sed 's/+/p/g; s/[^a-zA-Z0-9_]/_/g'`
-if { as_var=ac_cv_prog_make_${ac_make}_set; eval "test \"\${$as_var+set}\" = set"; }; then
-  echo $ECHO_N "(cached) $ECHO_C" >&6
+    done
+    ac_cv_prog_CPP=$CPP
+
+fi
+  CPP=$ac_cv_prog_CPP
 else
-  cat >conftest.make <<\_ACEOF
-SHELL = /bin/sh
-all:
-	@echo '@@@%%%=$(MAKE)=@@@%%%'
+  ac_cv_prog_CPP=$CPP
+fi
+{ echo "$as_me:$LINENO: result: $CPP" >&5
+echo "${ECHO_T}$CPP" >&6; }
+ac_preproc_ok=false
+for ac_c_preproc_warn_flag in '' yes
+do
+  # Use a header file that comes with gcc, so configuring glibc
+  # with a fresh cross-compiler works.
+  # Prefer <limits.h> to <assert.h> if __STDC__ is defined, since
+  # <limits.h> exists even on freestanding compilers.
+  # On the NeXT, cc -E runs the code through the compiler's parser,
+  # not just through cpp. "Syntax error" is here to catch this case.
+  cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
 _ACEOF
-# GNU make sometimes prints "make[1]: Entering...", which would confuse us.
-case `${MAKE-make} -f conftest.make 2>/dev/null` in
-  *@@@%%%=?*=@@@%%%*)
-    eval ac_cv_prog_make_${ac_make}_set=yes;;
-  *)
-    eval ac_cv_prog_make_${ac_make}_set=no;;
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+#ifdef __STDC__
+# include <limits.h>
+#else
+# include <assert.h>
+#endif
+		     Syntax error
+_ACEOF
+if { (ac_try="$ac_cpp conftest.$ac_ext"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
 esac
-rm -f conftest.make
-fi
-if eval test \$ac_cv_prog_make_${ac_make}_set = yes; then
-  { echo "$as_me:$LINENO: result: yes" >&5
-echo "${ECHO_T}yes" >&6; }
-  SET_MAKE=
+eval "echo \"\$as_me:$LINENO: $ac_try_echo\"") >&5
+  (eval "$ac_cpp conftest.$ac_ext") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } >/dev/null && {
+	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       }; then
+  :
 else
-  { echo "$as_me:$LINENO: result: no" >&5
-echo "${ECHO_T}no" >&6; }
-  SET_MAKE="MAKE=${MAKE-make}"
+  echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+  # Broken: fails on valid input.
+continue
 fi
 
-if test -n "$ac_tool_prefix"; then
-  # Extract the first word of "${ac_tool_prefix}ranlib", so it can be a program name with args.
-set dummy ${ac_tool_prefix}ranlib; ac_word=$2
-{ echo "$as_me:$LINENO: checking for $ac_word" >&5
-echo $ECHO_N "checking for $ac_word... $ECHO_C" >&6; }
-if test "${ac_cv_prog_RANLIB+set}" = set; then
-  echo $ECHO_N "(cached) $ECHO_C" >&6
-else
-  if test -n "$RANLIB"; then
-  ac_cv_prog_RANLIB="$RANLIB" # Let the user override the test.
+rm -f conftest.err conftest.$ac_ext
+
+  # OK, works on sane cases.  Now check whether nonexistent headers
+  # can be detected and how.
+  cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+#include <ac_nonexistent.h>
+_ACEOF
+if { (ac_try="$ac_cpp conftest.$ac_ext"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval "echo \"\$as_me:$LINENO: $ac_try_echo\"") >&5
+  (eval "$ac_cpp conftest.$ac_ext") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } >/dev/null && {
+	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       }; then
+  # Broken: success on invalid input.
+continue
 else
-as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
-do
-  IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
-  for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
-    ac_cv_prog_RANLIB="${ac_tool_prefix}ranlib"
-    echo "$as_me:$LINENO: found $as_dir/$ac_word$ac_exec_ext" >&5
-    break 2
-  fi
-done
-done
-IFS=$as_save_IFS
+  echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
 
+  # Passes both tests.
+ac_preproc_ok=:
+break
 fi
-fi
-RANLIB=$ac_cv_prog_RANLIB
-if test -n "$RANLIB"; then
-  { echo "$as_me:$LINENO: result: $RANLIB" >&5
-echo "${ECHO_T}$RANLIB" >&6; }
+
+rm -f conftest.err conftest.$ac_ext
+
+done
+# Because of `break', _AC_PREPROC_IFELSE's cleaning code was skipped.
+rm -f conftest.err conftest.$ac_ext
+if $ac_preproc_ok; then
+  :
 else
-  { echo "$as_me:$LINENO: result: no" >&5
-echo "${ECHO_T}no" >&6; }
+  { { echo "$as_me:$LINENO: error: C preprocessor \"$CPP\" fails sanity check
+See \`config.log' for more details." >&5
+echo "$as_me: error: C preprocessor \"$CPP\" fails sanity check
+See \`config.log' for more details." >&2;}
+   { (exit 1); exit 1; }; }
 fi
 
+ac_ext=c
+ac_cpp='$CPP $CPPFLAGS'
+ac_compile='$CC -c $CFLAGS $CPPFLAGS conftest.$ac_ext >&5'
+ac_link='$CC -o conftest$ac_exeext $CFLAGS $CPPFLAGS $LDFLAGS conftest.$ac_ext $LIBS >&5'
+ac_compiler_gnu=$ac_cv_c_compiler_gnu
+
 
-fi
-if test -z "$ac_cv_prog_RANLIB"; then
-  ac_ct_RANLIB=$RANLIB
-  # Extract the first word of "ranlib", so it can be a program name with args.
-set dummy ranlib; ac_word=$2
-{ echo "$as_me:$LINENO: checking for $ac_word" >&5
-echo $ECHO_N "checking for $ac_word... $ECHO_C" >&6; }
-if test "${ac_cv_prog_ac_ct_RANLIB+set}" = set; then
+{ echo "$as_me:$LINENO: checking for grep that handles long lines and -e" >&5
+echo $ECHO_N "checking for grep that handles long lines and -e... $ECHO_C" >&6; }
+if test "${ac_cv_path_GREP+set}" = set; then
   echo $ECHO_N "(cached) $ECHO_C" >&6
 else
-  if test -n "$ac_ct_RANLIB"; then
-  ac_cv_prog_ac_ct_RANLIB="$ac_ct_RANLIB" # Let the user override the test.
+  # Extract the first word of "grep ggrep" to use in msg output
+if test -z "$GREP"; then
+set dummy grep ggrep; ac_prog_name=$2
+if test "${ac_cv_path_GREP+set}" = set; then
+  echo $ECHO_N "(cached) $ECHO_C" >&6
 else
+  ac_path_GREP_found=false
+# Loop through the user's path and test for each of PROGNAME-LIST
 as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
+for as_dir in $PATH$PATH_SEPARATOR/usr/xpg4/bin
 do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
+  for ac_prog in grep ggrep; do
   for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
-    ac_cv_prog_ac_ct_RANLIB="ranlib"
-    echo "$as_me:$LINENO: found $as_dir/$ac_word$ac_exec_ext" >&5
-    break 2
-  fi
+    ac_path_GREP="$as_dir/$ac_prog$ac_exec_ext"
+    { test -f "$ac_path_GREP" && $as_test_x "$ac_path_GREP"; } || continue
+    # Check for GNU ac_path_GREP and select it if it is found.
+  # Check for GNU $ac_path_GREP
+case `"$ac_path_GREP" --version 2>&1` in
+*GNU*)
+  ac_cv_path_GREP="$ac_path_GREP" ac_path_GREP_found=:;;
+*)
+  ac_count=0
+  echo $ECHO_N "0123456789$ECHO_C" >"conftest.in"
+  while :
+  do
+    cat "conftest.in" "conftest.in" >"conftest.tmp"
+    mv "conftest.tmp" "conftest.in"
+    cp "conftest.in" "conftest.nl"
+    echo 'GREP' >> "conftest.nl"
+    "$ac_path_GREP" -e 'GREP$' -e '-(cannot match)-' < "conftest.nl" >"conftest.out" 2>/dev/null || break
+    diff "conftest.out" "conftest.nl" >/dev/null 2>&1 || break
+    ac_count=`expr $ac_count + 1`
+    if test $ac_count -gt ${ac_path_GREP_max-0}; then
+      # Best one so far, save it but keep looking for a better one
+      ac_cv_path_GREP="$ac_path_GREP"
+      ac_path_GREP_max=$ac_count
+    fi
+    # 10*(2^10) chars as input seems more than enough
+    test $ac_count -gt 10 && break
+  done
+  rm -f conftest.in conftest.tmp conftest.nl conftest.out;;
+esac
+
+
+    $ac_path_GREP_found && break 3
+  done
 done
+
 done
 IFS=$as_save_IFS
 
+
 fi
+
+GREP="$ac_cv_path_GREP"
+if test -z "$GREP"; then
+  { { echo "$as_me:$LINENO: error: no acceptable $ac_prog_name could be found in $PATH$PATH_SEPARATOR/usr/xpg4/bin" >&5
+echo "$as_me: error: no acceptable $ac_prog_name could be found in $PATH$PATH_SEPARATOR/usr/xpg4/bin" >&2;}
+   { (exit 1); exit 1; }; }
 fi
-ac_ct_RANLIB=$ac_cv_prog_ac_ct_RANLIB
-if test -n "$ac_ct_RANLIB"; then
-  { echo "$as_me:$LINENO: result: $ac_ct_RANLIB" >&5
-echo "${ECHO_T}$ac_ct_RANLIB" >&6; }
+
 else
-  { echo "$as_me:$LINENO: result: no" >&5
-echo "${ECHO_T}no" >&6; }
+  ac_cv_path_GREP=$GREP
 fi
 
-  if test "x$ac_ct_RANLIB" = x; then
-    RANLIB=":"
-  else
-    case $cross_compiling:$ac_tool_warned in
-yes:)
-{ echo "$as_me:$LINENO: WARNING: In the future, Autoconf will not detect cross-tools
-whose name does not start with the host triplet.  If you think this
-configuration is useful to you, please write to autoconf at gnu.org." >&5
-echo "$as_me: WARNING: In the future, Autoconf will not detect cross-tools
-whose name does not start with the host triplet.  If you think this
-configuration is useful to you, please write to autoconf at gnu.org." >&2;}
-ac_tool_warned=yes ;;
-esac
-    RANLIB=$ac_ct_RANLIB
-  fi
-else
-  RANLIB="$ac_cv_prog_RANLIB"
+
 fi
+{ echo "$as_me:$LINENO: result: $ac_cv_path_GREP" >&5
+echo "${ECHO_T}$ac_cv_path_GREP" >&6; }
+ GREP="$ac_cv_path_GREP"
 
-# Extract the first word of "cflow", so it can be a program name with args.
-set dummy cflow; ac_word=$2
-{ echo "$as_me:$LINENO: checking for $ac_word" >&5
-echo $ECHO_N "checking for $ac_word... $ECHO_C" >&6; }
-if test "${ac_cv_path_CFLOW_CMD+set}" = set; then
+
+{ echo "$as_me:$LINENO: checking for egrep" >&5
+echo $ECHO_N "checking for egrep... $ECHO_C" >&6; }
+if test "${ac_cv_path_EGREP+set}" = set; then
   echo $ECHO_N "(cached) $ECHO_C" >&6
 else
-  case $CFLOW_CMD in
-  [\\/]* | ?:[\\/]*)
-  ac_cv_path_CFLOW_CMD="$CFLOW_CMD" # Let the user override the test with a path.
-  ;;
-  *)
-  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
+  if echo a | $GREP -E '(a|b)' >/dev/null 2>&1
+   then ac_cv_path_EGREP="$GREP -E"
+   else
+     # Extract the first word of "egrep" to use in msg output
+if test -z "$EGREP"; then
+set dummy egrep; ac_prog_name=$2
+if test "${ac_cv_path_EGREP+set}" = set; then
+  echo $ECHO_N "(cached) $ECHO_C" >&6
+else
+  ac_path_EGREP_found=false
+# Loop through the user's path and test for each of PROGNAME-LIST
+as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH$PATH_SEPARATOR/usr/xpg4/bin
 do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
+  for ac_prog in egrep; do
   for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
-    ac_cv_path_CFLOW_CMD="$as_dir/$ac_word$ac_exec_ext"
-    echo "$as_me:$LINENO: found $as_dir/$ac_word$ac_exec_ext" >&5
-    break 2
-  fi
-done
-done
-IFS=$as_save_IFS
-
-  ;;
+    ac_path_EGREP="$as_dir/$ac_prog$ac_exec_ext"
+    { test -f "$ac_path_EGREP" && $as_test_x "$ac_path_EGREP"; } || continue
+    # Check for GNU ac_path_EGREP and select it if it is found.
+  # Check for GNU $ac_path_EGREP
+case `"$ac_path_EGREP" --version 2>&1` in
+*GNU*)
+  ac_cv_path_EGREP="$ac_path_EGREP" ac_path_EGREP_found=:;;
+*)
+  ac_count=0
+  echo $ECHO_N "0123456789$ECHO_C" >"conftest.in"
+  while :
+  do
+    cat "conftest.in" "conftest.in" >"conftest.tmp"
+    mv "conftest.tmp" "conftest.in"
+    cp "conftest.in" "conftest.nl"
+    echo 'EGREP' >> "conftest.nl"
+    "$ac_path_EGREP" 'EGREP$' < "conftest.nl" >"conftest.out" 2>/dev/null || break
+    diff "conftest.out" "conftest.nl" >/dev/null 2>&1 || break
+    ac_count=`expr $ac_count + 1`
+    if test $ac_count -gt ${ac_path_EGREP_max-0}; then
+      # Best one so far, save it but keep looking for a better one
+      ac_cv_path_EGREP="$ac_path_EGREP"
+      ac_path_EGREP_max=$ac_count
+    fi
+    # 10*(2^10) chars as input seems more than enough
+    test $ac_count -gt 10 && break
+  done
+  rm -f conftest.in conftest.tmp conftest.nl conftest.out;;
 esac
-fi
-CFLOW_CMD=$ac_cv_path_CFLOW_CMD
-if test -n "$CFLOW_CMD"; then
-  { echo "$as_me:$LINENO: result: $CFLOW_CMD" >&5
-echo "${ECHO_T}$CFLOW_CMD" >&6; }
-else
-  { echo "$as_me:$LINENO: result: no" >&5
-echo "${ECHO_T}no" >&6; }
-fi
 
 
-# Extract the first word of "cscope", so it can be a program name with args.
-set dummy cscope; ac_word=$2
-{ echo "$as_me:$LINENO: checking for $ac_word" >&5
-echo $ECHO_N "checking for $ac_word... $ECHO_C" >&6; }
-if test "${ac_cv_path_CSCOPE_CMD+set}" = set; then
-  echo $ECHO_N "(cached) $ECHO_C" >&6
-else
-  case $CSCOPE_CMD in
-  [\\/]* | ?:[\\/]*)
-  ac_cv_path_CSCOPE_CMD="$CSCOPE_CMD" # Let the user override the test with a path.
-  ;;
-  *)
-  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
-do
-  IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
-  for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
-    ac_cv_path_CSCOPE_CMD="$as_dir/$ac_word$ac_exec_ext"
-    echo "$as_me:$LINENO: found $as_dir/$ac_word$ac_exec_ext" >&5
-    break 2
-  fi
+    $ac_path_EGREP_found && break 3
+  done
 done
+
 done
 IFS=$as_save_IFS
 
-  ;;
-esac
-fi
-CSCOPE_CMD=$ac_cv_path_CSCOPE_CMD
-if test -n "$CSCOPE_CMD"; then
-  { echo "$as_me:$LINENO: result: $CSCOPE_CMD" >&5
-echo "${ECHO_T}$CSCOPE_CMD" >&6; }
-else
-  { echo "$as_me:$LINENO: result: no" >&5
-echo "${ECHO_T}no" >&6; }
-fi
-
-
 
-################################################################################
+fi
 
+EGREP="$ac_cv_path_EGREP"
+if test -z "$EGREP"; then
+  { { echo "$as_me:$LINENO: error: no acceptable $ac_prog_name could be found in $PATH$PATH_SEPARATOR/usr/xpg4/bin" >&5
+echo "$as_me: error: no acceptable $ac_prog_name could be found in $PATH$PATH_SEPARATOR/usr/xpg4/bin" >&2;}
+   { (exit 1); exit 1; }; }
+fi
 
+else
+  ac_cv_path_EGREP=$EGREP
+fi
 
 
+   fi
+fi
+{ echo "$as_me:$LINENO: result: $ac_cv_path_EGREP" >&5
+echo "${ECHO_T}$ac_cv_path_EGREP" >&6; }
+ EGREP="$ac_cv_path_EGREP"
 
 
-ac_header_dirent=no
-for ac_hdr in dirent.h sys/ndir.h sys/dir.h ndir.h; do
-  as_ac_Header=`echo "ac_cv_header_dirent_$ac_hdr" | $as_tr_sh`
-{ echo "$as_me:$LINENO: checking for $ac_hdr that defines DIR" >&5
-echo $ECHO_N "checking for $ac_hdr that defines DIR... $ECHO_C" >&6; }
-if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+if test $ac_cv_c_compiler_gnu = yes; then
+    { echo "$as_me:$LINENO: checking whether $CC needs -traditional" >&5
+echo $ECHO_N "checking whether $CC needs -traditional... $ECHO_C" >&6; }
+if test "${ac_cv_prog_gcc_traditional+set}" = set; then
   echo $ECHO_N "(cached) $ECHO_C" >&6
 else
+    ac_pattern="Autoconf.*'x'"
   cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
 cat confdefs.h >>conftest.$ac_ext
 cat >>conftest.$ac_ext <<_ACEOF
 /* end confdefs.h.  */
-#include <sys/types.h>
-#include <$ac_hdr>
-
-int
-main ()
-{
-if ((DIR *) 0)
-return 0;
-  ;
-  return 0;
-}
+#include <sgtty.h>
+Autoconf TIOCGETP
 _ACEOF
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
-  eval "$as_ac_Header=yes"
+if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
+  $EGREP "$ac_pattern" >/dev/null 2>&1; then
+  ac_cv_prog_gcc_traditional=yes
 else
-  echo "$as_me: failed program was:" >&5
-sed 's/^/| /' conftest.$ac_ext >&5
-
-	eval "$as_ac_Header=no"
-fi
-
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+  ac_cv_prog_gcc_traditional=no
 fi
-ac_res=`eval echo '${'$as_ac_Header'}'`
-	       { echo "$as_me:$LINENO: result: $ac_res" >&5
-echo "${ECHO_T}$ac_res" >&6; }
-if test `eval echo '${'$as_ac_Header'}'` = yes; then
-  cat >>confdefs.h <<_ACEOF
-#define `echo "HAVE_$ac_hdr" | $as_tr_cpp` 1
-_ACEOF
+rm -f conftest*
 
-ac_header_dirent=$ac_hdr; break
-fi
 
-done
-# Two versions of opendir et al. are in -ldir and -lx on SCO Xenix.
-if test $ac_header_dirent = dirent.h; then
-  { echo "$as_me:$LINENO: checking for library containing opendir" >&5
-echo $ECHO_N "checking for library containing opendir... $ECHO_C" >&6; }
-if test "${ac_cv_search_opendir+set}" = set; then
-  echo $ECHO_N "(cached) $ECHO_C" >&6
-else
-  ac_func_search_save_LIBS=$LIBS
-cat >conftest.$ac_ext <<_ACEOF
+  if test $ac_cv_prog_gcc_traditional = no; then
+    cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
 cat confdefs.h >>conftest.$ac_ext
 cat >>conftest.$ac_ext <<_ACEOF
 /* end confdefs.h.  */
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
+#include <termio.h>
+Autoconf TCGETA
 _ACEOF
-for ac_lib in '' dir; do
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
-eval "echo \"\$as_me:$LINENO: $ac_try_echo\"") >&5
-  (eval "$ac_link") 2>conftest.er1
-  ac_status=$?
-  grep -v '^ *+' conftest.er1 >conftest.err
-  rm -f conftest.er1
-  cat conftest.err >&5
-  echo "$as_me:$LINENO: \$? = $ac_status" >&5
-  (exit $ac_status); } && {
-	 test -z "$ac_c_werror_flag" ||
-	 test ! -s conftest.err
-       } && test -s conftest$ac_exeext &&
-       $as_test_x conftest$ac_exeext; then
-  ac_cv_search_opendir=$ac_res
-else
-  echo "$as_me: failed program was:" >&5
-sed 's/^/| /' conftest.$ac_ext >&5
-
-
+if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
+  $EGREP "$ac_pattern" >/dev/null 2>&1; then
+  ac_cv_prog_gcc_traditional=yes
 fi
+rm -f conftest*
 
-rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
-      conftest$ac_exeext
-  if test "${ac_cv_search_opendir+set}" = set; then
-  break
+  fi
 fi
-done
-if test "${ac_cv_search_opendir+set}" = set; then
-  :
-else
-  ac_cv_search_opendir=no
-fi
-rm conftest.$ac_ext
-LIBS=$ac_func_search_save_LIBS
-fi
-{ echo "$as_me:$LINENO: result: $ac_cv_search_opendir" >&5
-echo "${ECHO_T}$ac_cv_search_opendir" >&6; }
-ac_res=$ac_cv_search_opendir
-if test "$ac_res" != no; then
-  test "$ac_res" = "none required" || LIBS="$ac_res $LIBS"
-
+{ echo "$as_me:$LINENO: result: $ac_cv_prog_gcc_traditional" >&5
+echo "${ECHO_T}$ac_cv_prog_gcc_traditional" >&6; }
+  if test $ac_cv_prog_gcc_traditional = yes; then
+    CC="$CC -traditional"
+  fi
 fi
 
-else
-  { echo "$as_me:$LINENO: checking for library containing opendir" >&5
-echo $ECHO_N "checking for library containing opendir... $ECHO_C" >&6; }
-if test "${ac_cv_search_opendir+set}" = set; then
+# Find a good install program.  We prefer a C program (faster),
+# so one script is as good as another.  But avoid the broken or
+# incompatible versions:
+# SysV /etc/install, /usr/sbin/install
+# SunOS /usr/etc/install
+# IRIX /sbin/install
+# AIX /bin/install
+# AmigaOS /C/install, which installs bootblocks on floppy discs
+# AIX 4 /usr/bin/installbsd, which doesn't work without a -g flag
+# AFS /usr/afsws/bin/install, which mishandles nonexistent args
+# SVR4 /usr/ucb/install, which tries to use the nonexistent group "staff"
+# OS/2's system install, which has a completely different semantic
+# ./install, which can be erroneously created by make from ./install.sh.
+{ echo "$as_me:$LINENO: checking for a BSD-compatible install" >&5
+echo $ECHO_N "checking for a BSD-compatible install... $ECHO_C" >&6; }
+if test -z "$INSTALL"; then
+if test "${ac_cv_path_install+set}" = set; then
   echo $ECHO_N "(cached) $ECHO_C" >&6
 else
-  ac_func_search_save_LIBS=$LIBS
-cat >conftest.$ac_ext <<_ACEOF
-/* confdefs.h.  */
-_ACEOF
-cat confdefs.h >>conftest.$ac_ext
-cat >>conftest.$ac_ext <<_ACEOF
-/* end confdefs.h.  */
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+  # Account for people who put trailing slashes in PATH elements.
+case $as_dir/ in
+  ./ | .// | /cC/* | \
+  /etc/* | /usr/sbin/* | /usr/etc/* | /sbin/* | /usr/afsws/bin/* | \
+  ?:\\/os2\\/install\\/* | ?:\\/OS2\\/INSTALL\\/* | \
+  /usr/ucb/* ) ;;
+  *)
+    # OSF1 and SCO ODT 3.0 have their own names for install.
+    # Don't use installbsd from OSF since it installs stuff as root
+    # by default.
+    for ac_prog in ginstall scoinst install; do
+      for ac_exec_ext in '' $ac_executable_extensions; do
+	if { test -f "$as_dir/$ac_prog$ac_exec_ext" && $as_test_x "$as_dir/$ac_prog$ac_exec_ext"; }; then
+	  if test $ac_prog = install &&
+	    grep dspmsg "$as_dir/$ac_prog$ac_exec_ext" >/dev/null 2>&1; then
+	    # AIX install.  It has an incompatible calling convention.
+	    :
+	  elif test $ac_prog = install &&
+	    grep pwplus "$as_dir/$ac_prog$ac_exec_ext" >/dev/null 2>&1; then
+	    # program-specific install script used by HP pwplus--don't use.
+	    :
+	  else
+	    ac_cv_path_install="$as_dir/$ac_prog$ac_exec_ext -c"
+	    break 3
+	  fi
+	fi
+      done
+    done
+    ;;
+esac
+done
+IFS=$as_save_IFS
 
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
-for ac_lib in '' x; do
-  if test -z "$ac_lib"; then
-    ac_res="none required"
+
+fi
+  if test "${ac_cv_path_install+set}" = set; then
+    INSTALL=$ac_cv_path_install
   else
-    ac_res=-l$ac_lib
-    LIBS="-l$ac_lib  $ac_func_search_save_LIBS"
+    # As a last resort, use the slow shell script.  Don't cache a
+    # value for INSTALL within a source directory, because that will
+    # break other packages using the cache if that directory is
+    # removed, or if the value is a relative name.
+    INSTALL=$ac_install_sh
   fi
-  rm -f conftest.$ac_objext conftest$ac_exeext
-if { (ac_try="$ac_link"
-case "(($ac_try" in
-  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
-  *) ac_try_echo=$ac_try;;
-esac
-eval "echo \"\$as_me:$LINENO: $ac_try_echo\"") >&5
-  (eval "$ac_link") 2>conftest.er1
-  ac_status=$?
-  grep -v '^ *+' conftest.er1 >conftest.err
-  rm -f conftest.er1
-  cat conftest.err >&5
-  echo "$as_me:$LINENO: \$? = $ac_status" >&5
-  (exit $ac_status); } && {
-	 test -z "$ac_c_werror_flag" ||
-	 test ! -s conftest.err
-       } && test -s conftest$ac_exeext &&
-       $as_test_x conftest$ac_exeext; then
-  ac_cv_search_opendir=$ac_res
-else
-  echo "$as_me: failed program was:" >&5
-sed 's/^/| /' conftest.$ac_ext >&5
+fi
+{ echo "$as_me:$LINENO: result: $INSTALL" >&5
+echo "${ECHO_T}$INSTALL" >&6; }
 
+# Use test -z because SunOS4 sh mishandles braces in ${var-val}.
+# It thinks the first close brace ends the variable substitution.
+test -z "$INSTALL_PROGRAM" && INSTALL_PROGRAM='${INSTALL}'
 
-fi
+test -z "$INSTALL_SCRIPT" && INSTALL_SCRIPT='${INSTALL}'
 
-rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
-      conftest$ac_exeext
-  if test "${ac_cv_search_opendir+set}" = set; then
-  break
+test -z "$INSTALL_DATA" && INSTALL_DATA='${INSTALL} -m 644'
+
+{ echo "$as_me:$LINENO: checking whether ln -s works" >&5
+echo $ECHO_N "checking whether ln -s works... $ECHO_C" >&6; }
+LN_S=$as_ln_s
+if test "$LN_S" = "ln -s"; then
+  { echo "$as_me:$LINENO: result: yes" >&5
+echo "${ECHO_T}yes" >&6; }
+else
+  { echo "$as_me:$LINENO: result: no, using $LN_S" >&5
+echo "${ECHO_T}no, using $LN_S" >&6; }
 fi
-done
-if test "${ac_cv_search_opendir+set}" = set; then
-  :
+
+{ echo "$as_me:$LINENO: checking whether ${MAKE-make} sets \$(MAKE)" >&5
+echo $ECHO_N "checking whether ${MAKE-make} sets \$(MAKE)... $ECHO_C" >&6; }
+set x ${MAKE-make}; ac_make=`echo "$2" | sed 's/+/p/g; s/[^a-zA-Z0-9_]/_/g'`
+if { as_var=ac_cv_prog_make_${ac_make}_set; eval "test \"\${$as_var+set}\" = set"; }; then
+  echo $ECHO_N "(cached) $ECHO_C" >&6
 else
-  ac_cv_search_opendir=no
+  cat >conftest.make <<\_ACEOF
+SHELL = /bin/sh
+all:
+	@echo '@@@%%%=$(MAKE)=@@@%%%'
+_ACEOF
+# GNU make sometimes prints "make[1]: Entering...", which would confuse us.
+case `${MAKE-make} -f conftest.make 2>/dev/null` in
+  *@@@%%%=?*=@@@%%%*)
+    eval ac_cv_prog_make_${ac_make}_set=yes;;
+  *)
+    eval ac_cv_prog_make_${ac_make}_set=no;;
+esac
+rm -f conftest.make
 fi
-rm conftest.$ac_ext
-LIBS=$ac_func_search_save_LIBS
+if eval test \$ac_cv_prog_make_${ac_make}_set = yes; then
+  { echo "$as_me:$LINENO: result: yes" >&5
+echo "${ECHO_T}yes" >&6; }
+  SET_MAKE=
+else
+  { echo "$as_me:$LINENO: result: no" >&5
+echo "${ECHO_T}no" >&6; }
+  SET_MAKE="MAKE=${MAKE-make}"
 fi
-{ echo "$as_me:$LINENO: result: $ac_cv_search_opendir" >&5
-echo "${ECHO_T}$ac_cv_search_opendir" >&6; }
-ac_res=$ac_cv_search_opendir
-if test "$ac_res" != no; then
-  test "$ac_res" = "none required" || LIBS="$ac_res $LIBS"
 
-fi
+if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}ranlib", so it can be a program name with args.
+set dummy ${ac_tool_prefix}ranlib; ac_word=$2
+{ echo "$as_me:$LINENO: checking for $ac_word" >&5
+echo $ECHO_N "checking for $ac_word... $ECHO_C" >&6; }
+if test "${ac_cv_prog_RANLIB+set}" = set; then
+  echo $ECHO_N "(cached) $ECHO_C" >&6
+else
+  if test -n "$RANLIB"; then
+  ac_cv_prog_RANLIB="$RANLIB" # Let the user override the test.
+else
+as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+  for ac_exec_ext in '' $ac_executable_extensions; do
+  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+    ac_cv_prog_RANLIB="${ac_tool_prefix}ranlib"
+    echo "$as_me:$LINENO: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+done
+IFS=$as_save_IFS
 
 fi
+fi
+RANLIB=$ac_cv_prog_RANLIB
+if test -n "$RANLIB"; then
+  { echo "$as_me:$LINENO: result: $RANLIB" >&5
+echo "${ECHO_T}$RANLIB" >&6; }
+else
+  { echo "$as_me:$LINENO: result: no" >&5
+echo "${ECHO_T}no" >&6; }
+fi
+
 
-ac_ext=c
-ac_cpp='$CPP $CPPFLAGS'
-ac_compile='$CC -c $CFLAGS $CPPFLAGS conftest.$ac_ext >&5'
-ac_link='$CC -o conftest$ac_exeext $CFLAGS $CPPFLAGS $LDFLAGS conftest.$ac_ext $LIBS >&5'
-ac_compiler_gnu=$ac_cv_c_compiler_gnu
-{ echo "$as_me:$LINENO: checking how to run the C preprocessor" >&5
-echo $ECHO_N "checking how to run the C preprocessor... $ECHO_C" >&6; }
-# On Suns, sometimes $CPP names a directory.
-if test -n "$CPP" && test -d "$CPP"; then
-  CPP=
 fi
-if test -z "$CPP"; then
-  if test "${ac_cv_prog_CPP+set}" = set; then
+if test -z "$ac_cv_prog_RANLIB"; then
+  ac_ct_RANLIB=$RANLIB
+  # Extract the first word of "ranlib", so it can be a program name with args.
+set dummy ranlib; ac_word=$2
+{ echo "$as_me:$LINENO: checking for $ac_word" >&5
+echo $ECHO_N "checking for $ac_word... $ECHO_C" >&6; }
+if test "${ac_cv_prog_ac_ct_RANLIB+set}" = set; then
   echo $ECHO_N "(cached) $ECHO_C" >&6
 else
-      # Double quotes because CPP needs to be expanded
-    for CPP in "$CC -E" "$CC -E -traditional-cpp" "/lib/cpp"
-    do
-      ac_preproc_ok=false
-for ac_c_preproc_warn_flag in '' yes
+  if test -n "$ac_ct_RANLIB"; then
+  ac_cv_prog_ac_ct_RANLIB="$ac_ct_RANLIB" # Let the user override the test.
+else
+as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
 do
-  # Use a header file that comes with gcc, so configuring glibc
-  # with a fresh cross-compiler works.
-  # Prefer <limits.h> to <assert.h> if __STDC__ is defined, since
-  # <limits.h> exists even on freestanding compilers.
-  # On the NeXT, cc -E runs the code through the compiler's parser,
-  # not just through cpp. "Syntax error" is here to catch this case.
-  cat >conftest.$ac_ext <<_ACEOF
-/* confdefs.h.  */
-_ACEOF
-cat confdefs.h >>conftest.$ac_ext
-cat >>conftest.$ac_ext <<_ACEOF
-/* end confdefs.h.  */
-#ifdef __STDC__
-# include <limits.h>
-#else
-# include <assert.h>
-#endif
-		     Syntax error
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
-  :
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+  for ac_exec_ext in '' $ac_executable_extensions; do
+  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+    ac_cv_prog_ac_ct_RANLIB="ranlib"
+    echo "$as_me:$LINENO: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+done
+IFS=$as_save_IFS
+
+fi
+fi
+ac_ct_RANLIB=$ac_cv_prog_ac_ct_RANLIB
+if test -n "$ac_ct_RANLIB"; then
+  { echo "$as_me:$LINENO: result: $ac_ct_RANLIB" >&5
+echo "${ECHO_T}$ac_ct_RANLIB" >&6; }
 else
-  echo "$as_me: failed program was:" >&5
-sed 's/^/| /' conftest.$ac_ext >&5
+  { echo "$as_me:$LINENO: result: no" >&5
+echo "${ECHO_T}no" >&6; }
+fi
 
-  # Broken: fails on valid input.
-continue
+  if test "x$ac_ct_RANLIB" = x; then
+    RANLIB=":"
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ echo "$as_me:$LINENO: WARNING: In the future, Autoconf will not detect cross-tools
+whose name does not start with the host triplet.  If you think this
+configuration is useful to you, please write to autoconf at gnu.org." >&5
+echo "$as_me: WARNING: In the future, Autoconf will not detect cross-tools
+whose name does not start with the host triplet.  If you think this
+configuration is useful to you, please write to autoconf at gnu.org." >&2;}
+ac_tool_warned=yes ;;
+esac
+    RANLIB=$ac_ct_RANLIB
+  fi
+else
+  RANLIB="$ac_cv_prog_RANLIB"
 fi
 
-rm -f conftest.err conftest.$ac_ext
+# Extract the first word of "cflow", so it can be a program name with args.
+set dummy cflow; ac_word=$2
+{ echo "$as_me:$LINENO: checking for $ac_word" >&5
+echo $ECHO_N "checking for $ac_word... $ECHO_C" >&6; }
+if test "${ac_cv_path_CFLOW_CMD+set}" = set; then
+  echo $ECHO_N "(cached) $ECHO_C" >&6
+else
+  case $CFLOW_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_CFLOW_CMD="$CFLOW_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+  for ac_exec_ext in '' $ac_executable_extensions; do
+  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+    ac_cv_path_CFLOW_CMD="$as_dir/$ac_word$ac_exec_ext"
+    echo "$as_me:$LINENO: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+done
+IFS=$as_save_IFS
 
-  # OK, works on sane cases.  Now check whether nonexistent headers
-  # can be detected and how.
-  cat >conftest.$ac_ext <<_ACEOF
-/* confdefs.h.  */
-_ACEOF
-cat confdefs.h >>conftest.$ac_ext
-cat >>conftest.$ac_ext <<_ACEOF
-/* end confdefs.h.  */
-#include <ac_nonexistent.h>
-_ACEOF
-if { (ac_try="$ac_cpp conftest.$ac_ext"
-case "(($ac_try" in
-  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
-  *) ac_try_echo=$ac_try;;
+  ;;
 esac
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
-  # Broken: success on invalid input.
-continue
+fi
+CFLOW_CMD=$ac_cv_path_CFLOW_CMD
+if test -n "$CFLOW_CMD"; then
+  { echo "$as_me:$LINENO: result: $CFLOW_CMD" >&5
+echo "${ECHO_T}$CFLOW_CMD" >&6; }
 else
-  echo "$as_me: failed program was:" >&5
-sed 's/^/| /' conftest.$ac_ext >&5
-
-  # Passes both tests.
-ac_preproc_ok=:
-break
+  { echo "$as_me:$LINENO: result: no" >&5
+echo "${ECHO_T}no" >&6; }
 fi
 
-rm -f conftest.err conftest.$ac_ext
 
+# Extract the first word of "cscope", so it can be a program name with args.
+set dummy cscope; ac_word=$2
+{ echo "$as_me:$LINENO: checking for $ac_word" >&5
+echo $ECHO_N "checking for $ac_word... $ECHO_C" >&6; }
+if test "${ac_cv_path_CSCOPE_CMD+set}" = set; then
+  echo $ECHO_N "(cached) $ECHO_C" >&6
+else
+  case $CSCOPE_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_CSCOPE_CMD="$CSCOPE_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+  for ac_exec_ext in '' $ac_executable_extensions; do
+  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+    ac_cv_path_CSCOPE_CMD="$as_dir/$ac_word$ac_exec_ext"
+    echo "$as_me:$LINENO: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
 done
-# Because of `break', _AC_PREPROC_IFELSE's cleaning code was skipped.
-rm -f conftest.err conftest.$ac_ext
-if $ac_preproc_ok; then
-  break
-fi
-
-    done
-    ac_cv_prog_CPP=$CPP
+done
+IFS=$as_save_IFS
 
+  ;;
+esac
 fi
-  CPP=$ac_cv_prog_CPP
+CSCOPE_CMD=$ac_cv_path_CSCOPE_CMD
+if test -n "$CSCOPE_CMD"; then
+  { echo "$as_me:$LINENO: result: $CSCOPE_CMD" >&5
+echo "${ECHO_T}$CSCOPE_CMD" >&6; }
 else
-  ac_cv_prog_CPP=$CPP
+  { echo "$as_me:$LINENO: result: no" >&5
+echo "${ECHO_T}no" >&6; }
 fi
-{ echo "$as_me:$LINENO: result: $CPP" >&5
-echo "${ECHO_T}$CPP" >&6; }
-ac_preproc_ok=false
-for ac_c_preproc_warn_flag in '' yes
-do
-  # Use a header file that comes with gcc, so configuring glibc
-  # with a fresh cross-compiler works.
-  # Prefer <limits.h> to <assert.h> if __STDC__ is defined, since
-  # <limits.h> exists even on freestanding compilers.
-  # On the NeXT, cc -E runs the code through the compiler's parser,
-  # not just through cpp. "Syntax error" is here to catch this case.
-  cat >conftest.$ac_ext <<_ACEOF
-/* confdefs.h.  */
-_ACEOF
-cat confdefs.h >>conftest.$ac_ext
-cat >>conftest.$ac_ext <<_ACEOF
-/* end confdefs.h.  */
-#ifdef __STDC__
-# include <limits.h>
-#else
-# include <assert.h>
-#endif
-		     Syntax error
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
-  :
-else
-  echo "$as_me: failed program was:" >&5
-sed 's/^/| /' conftest.$ac_ext >&5
 
-  # Broken: fails on valid input.
-continue
-fi
 
-rm -f conftest.err conftest.$ac_ext
 
-  # OK, works on sane cases.  Now check whether nonexistent headers
-  # can be detected and how.
+################################################################################
+
+
+
+
+
+ac_header_dirent=no
+for ac_hdr in dirent.h sys/ndir.h sys/dir.h ndir.h; do
+  as_ac_Header=`echo "ac_cv_header_dirent_$ac_hdr" | $as_tr_sh`
+{ echo "$as_me:$LINENO: checking for $ac_hdr that defines DIR" >&5
+echo $ECHO_N "checking for $ac_hdr that defines DIR... $ECHO_C" >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  echo $ECHO_N "(cached) $ECHO_C" >&6
+else
   cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
 cat confdefs.h >>conftest.$ac_ext
 cat >>conftest.$ac_ext <<_ACEOF
 /* end confdefs.h.  */
-#include <ac_nonexistent.h>
+#include <sys/types.h>
+#include <$ac_hdr>
+
+int
+main ()
+{
+if ((DIR *) 0)
+return 0;
+  ;
+  return 0;
+}
 _ACEOF
-if { (ac_try="$ac_cpp conftest.$ac_ext"
+rm -f conftest.$ac_objext
+if { (ac_try="$ac_compile"
 case "(($ac_try" in
   *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
   *) ac_try_echo=$ac_try;;
 esac
 eval "echo \"\$as_me:$LINENO: $ac_try_echo\"") >&5
-  (eval "$ac_cpp conftest.$ac_ext") 2>conftest.er1
+  (eval "$ac_compile") 2>conftest.er1
   ac_status=$?
   grep -v '^ *+' conftest.er1 >conftest.err
   rm -f conftest.er1
   cat conftest.err >&5
   echo "$as_me:$LINENO: \$? = $ac_status" >&5
-  (exit $ac_status); } >/dev/null && {
-	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
 	 test ! -s conftest.err
-       }; then
-  # Broken: success on invalid input.
-continue
+       } && test -s conftest.$ac_objext; then
+  eval "$as_ac_Header=yes"
 else
   echo "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
-  # Passes both tests.
-ac_preproc_ok=:
-break
+	eval "$as_ac_Header=no"
 fi
 
-rm -f conftest.err conftest.$ac_ext
-
-done
-# Because of `break', _AC_PREPROC_IFELSE's cleaning code was skipped.
-rm -f conftest.err conftest.$ac_ext
-if $ac_preproc_ok; then
-  :
-else
-  { { echo "$as_me:$LINENO: error: C preprocessor \"$CPP\" fails sanity check
-See \`config.log' for more details." >&5
-echo "$as_me: error: C preprocessor \"$CPP\" fails sanity check
-See \`config.log' for more details." >&2;}
-   { (exit 1); exit 1; }; }
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
 fi
+ac_res=`eval echo '${'$as_ac_Header'}'`
+	       { echo "$as_me:$LINENO: result: $ac_res" >&5
+echo "${ECHO_T}$ac_res" >&6; }
+if test `eval echo '${'$as_ac_Header'}'` = yes; then
+  cat >>confdefs.h <<_ACEOF
+#define `echo "HAVE_$ac_hdr" | $as_tr_cpp` 1
+_ACEOF
 
-ac_ext=c
-ac_cpp='$CPP $CPPFLAGS'
-ac_compile='$CC -c $CFLAGS $CPPFLAGS conftest.$ac_ext >&5'
-ac_link='$CC -o conftest$ac_exeext $CFLAGS $CPPFLAGS $LDFLAGS conftest.$ac_ext $LIBS >&5'
-ac_compiler_gnu=$ac_cv_c_compiler_gnu
-
+ac_header_dirent=$ac_hdr; break
+fi
 
-{ echo "$as_me:$LINENO: checking for grep that handles long lines and -e" >&5
-echo $ECHO_N "checking for grep that handles long lines and -e... $ECHO_C" >&6; }
-if test "${ac_cv_path_GREP+set}" = set; then
-  echo $ECHO_N "(cached) $ECHO_C" >&6
-else
-  # Extract the first word of "grep ggrep" to use in msg output
-if test -z "$GREP"; then
-set dummy grep ggrep; ac_prog_name=$2
-if test "${ac_cv_path_GREP+set}" = set; then
+done
+# Two versions of opendir et al. are in -ldir and -lx on SCO Xenix.
+if test $ac_header_dirent = dirent.h; then
+  { echo "$as_me:$LINENO: checking for library containing opendir" >&5
+echo $ECHO_N "checking for library containing opendir... $ECHO_C" >&6; }
+if test "${ac_cv_search_opendir+set}" = set; then
   echo $ECHO_N "(cached) $ECHO_C" >&6
 else
-  ac_path_GREP_found=false
-# Loop through the user's path and test for each of PROGNAME-LIST
-as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH$PATH_SEPARATOR/usr/xpg4/bin
-do
-  IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
-  for ac_prog in grep ggrep; do
-  for ac_exec_ext in '' $ac_executable_extensions; do
-    ac_path_GREP="$as_dir/$ac_prog$ac_exec_ext"
-    { test -f "$ac_path_GREP" && $as_test_x "$ac_path_GREP"; } || continue
-    # Check for GNU ac_path_GREP and select it if it is found.
-  # Check for GNU $ac_path_GREP
-case `"$ac_path_GREP" --version 2>&1` in
-*GNU*)
-  ac_cv_path_GREP="$ac_path_GREP" ac_path_GREP_found=:;;
-*)
-  ac_count=0
-  echo $ECHO_N "0123456789$ECHO_C" >"conftest.in"
-  while :
-  do
-    cat "conftest.in" "conftest.in" >"conftest.tmp"
-    mv "conftest.tmp" "conftest.in"
-    cp "conftest.in" "conftest.nl"
-    echo 'GREP' >> "conftest.nl"
-    "$ac_path_GREP" -e 'GREP$' -e '-(cannot match)-' < "conftest.nl" >"conftest.out" 2>/dev/null || break
-    diff "conftest.out" "conftest.nl" >/dev/null 2>&1 || break
-    ac_count=`expr $ac_count + 1`
-    if test $ac_count -gt ${ac_path_GREP_max-0}; then
-      # Best one so far, save it but keep looking for a better one
-      ac_cv_path_GREP="$ac_path_GREP"
-      ac_path_GREP_max=$ac_count
-    fi
-    # 10*(2^10) chars as input seems more than enough
-    test $ac_count -gt 10 && break
-  done
-  rm -f conftest.in conftest.tmp conftest.nl conftest.out;;
-esac
-
-
-    $ac_path_GREP_found && break 3
-  done
-done
+  ac_func_search_save_LIBS=$LIBS
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
 
-done
-IFS=$as_save_IFS
+/* Override any GCC internal prototype to avoid an error.
+   Use char because int might match the return type of a GCC
+   builtin and then its argument prototype would still apply.  */
+#ifdef __cplusplus
+extern "C"
+#endif
+char opendir ();
+int
+main ()
+{
+return opendir ();
+  ;
+  return 0;
+}
+_ACEOF
+for ac_lib in '' dir; do
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
+eval "echo \"\$as_me:$LINENO: $ac_try_echo\"") >&5
+  (eval "$ac_link") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest$ac_exeext &&
+       $as_test_x conftest$ac_exeext; then
+  ac_cv_search_opendir=$ac_res
+else
+  echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
 
 
 fi
 
-GREP="$ac_cv_path_GREP"
-if test -z "$GREP"; then
-  { { echo "$as_me:$LINENO: error: no acceptable $ac_prog_name could be found in $PATH$PATH_SEPARATOR/usr/xpg4/bin" >&5
-echo "$as_me: error: no acceptable $ac_prog_name could be found in $PATH$PATH_SEPARATOR/usr/xpg4/bin" >&2;}
-   { (exit 1); exit 1; }; }
+rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
+      conftest$ac_exeext
+  if test "${ac_cv_search_opendir+set}" = set; then
+  break
 fi
-
+done
+if test "${ac_cv_search_opendir+set}" = set; then
+  :
 else
-  ac_cv_path_GREP=$GREP
+  ac_cv_search_opendir=no
 fi
-
-
+rm conftest.$ac_ext
+LIBS=$ac_func_search_save_LIBS
 fi
-{ echo "$as_me:$LINENO: result: $ac_cv_path_GREP" >&5
-echo "${ECHO_T}$ac_cv_path_GREP" >&6; }
- GREP="$ac_cv_path_GREP"
+{ echo "$as_me:$LINENO: result: $ac_cv_search_opendir" >&5
+echo "${ECHO_T}$ac_cv_search_opendir" >&6; }
+ac_res=$ac_cv_search_opendir
+if test "$ac_res" != no; then
+  test "$ac_res" = "none required" || LIBS="$ac_res $LIBS"
 
+fi
 
-{ echo "$as_me:$LINENO: checking for egrep" >&5
-echo $ECHO_N "checking for egrep... $ECHO_C" >&6; }
-if test "${ac_cv_path_EGREP+set}" = set; then
-  echo $ECHO_N "(cached) $ECHO_C" >&6
 else
-  if echo a | $GREP -E '(a|b)' >/dev/null 2>&1
-   then ac_cv_path_EGREP="$GREP -E"
-   else
-     # Extract the first word of "egrep" to use in msg output
-if test -z "$EGREP"; then
-set dummy egrep; ac_prog_name=$2
-if test "${ac_cv_path_EGREP+set}" = set; then
+  { echo "$as_me:$LINENO: checking for library containing opendir" >&5
+echo $ECHO_N "checking for library containing opendir... $ECHO_C" >&6; }
+if test "${ac_cv_search_opendir+set}" = set; then
   echo $ECHO_N "(cached) $ECHO_C" >&6
 else
-  ac_path_EGREP_found=false
-# Loop through the user's path and test for each of PROGNAME-LIST
-as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH$PATH_SEPARATOR/usr/xpg4/bin
-do
-  IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
-  for ac_prog in egrep; do
-  for ac_exec_ext in '' $ac_executable_extensions; do
-    ac_path_EGREP="$as_dir/$ac_prog$ac_exec_ext"
-    { test -f "$ac_path_EGREP" && $as_test_x "$ac_path_EGREP"; } || continue
-    # Check for GNU ac_path_EGREP and select it if it is found.
-  # Check for GNU $ac_path_EGREP
-case `"$ac_path_EGREP" --version 2>&1` in
-*GNU*)
-  ac_cv_path_EGREP="$ac_path_EGREP" ac_path_EGREP_found=:;;
-*)
-  ac_count=0
-  echo $ECHO_N "0123456789$ECHO_C" >"conftest.in"
-  while :
-  do
-    cat "conftest.in" "conftest.in" >"conftest.tmp"
-    mv "conftest.tmp" "conftest.in"
-    cp "conftest.in" "conftest.nl"
-    echo 'EGREP' >> "conftest.nl"
-    "$ac_path_EGREP" 'EGREP$' < "conftest.nl" >"conftest.out" 2>/dev/null || break
-    diff "conftest.out" "conftest.nl" >/dev/null 2>&1 || break
-    ac_count=`expr $ac_count + 1`
-    if test $ac_count -gt ${ac_path_EGREP_max-0}; then
-      # Best one so far, save it but keep looking for a better one
-      ac_cv_path_EGREP="$ac_path_EGREP"
-      ac_path_EGREP_max=$ac_count
-    fi
-    # 10*(2^10) chars as input seems more than enough
-    test $ac_count -gt 10 && break
-  done
-  rm -f conftest.in conftest.tmp conftest.nl conftest.out;;
-esac
-
-
-    $ac_path_EGREP_found && break 3
-  done
-done
+  ac_func_search_save_LIBS=$LIBS
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
 
-done
-IFS=$as_save_IFS
+/* Override any GCC internal prototype to avoid an error.
+   Use char because int might match the return type of a GCC
+   builtin and then its argument prototype would still apply.  */
+#ifdef __cplusplus
+extern "C"
+#endif
+char opendir ();
+int
+main ()
+{
+return opendir ();
+  ;
+  return 0;
+}
+_ACEOF
+for ac_lib in '' x; do
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
+eval "echo \"\$as_me:$LINENO: $ac_try_echo\"") >&5
+  (eval "$ac_link") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest$ac_exeext &&
+       $as_test_x conftest$ac_exeext; then
+  ac_cv_search_opendir=$ac_res
+else
+  echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
 
 
 fi
 
-EGREP="$ac_cv_path_EGREP"
-if test -z "$EGREP"; then
-  { { echo "$as_me:$LINENO: error: no acceptable $ac_prog_name could be found in $PATH$PATH_SEPARATOR/usr/xpg4/bin" >&5
-echo "$as_me: error: no acceptable $ac_prog_name could be found in $PATH$PATH_SEPARATOR/usr/xpg4/bin" >&2;}
-   { (exit 1); exit 1; }; }
+rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
+      conftest$ac_exeext
+  if test "${ac_cv_search_opendir+set}" = set; then
+  break
 fi
-
+done
+if test "${ac_cv_search_opendir+set}" = set; then
+  :
 else
-  ac_cv_path_EGREP=$EGREP
+  ac_cv_search_opendir=no
 fi
+rm conftest.$ac_ext
+LIBS=$ac_func_search_save_LIBS
+fi
+{ echo "$as_me:$LINENO: result: $ac_cv_search_opendir" >&5
+echo "${ECHO_T}$ac_cv_search_opendir" >&6; }
+ac_res=$ac_cv_search_opendir
+if test "$ac_res" != no; then
+  test "$ac_res" = "none required" || LIBS="$ac_res $LIBS"
 
-
-   fi
 fi
-{ echo "$as_me:$LINENO: result: $ac_cv_path_EGREP" >&5
-echo "${ECHO_T}$ac_cv_path_EGREP" >&6; }
- EGREP="$ac_cv_path_EGREP"
 
+fi
 
 { echo "$as_me:$LINENO: checking for ANSI C header files" >&5
 echo $ECHO_N "checking for ANSI C header files... $ECHO_C" >&6; }
@@ -4174,7 +4231,74 @@
 fi
 
 
-# On IRIX 5.3, sys/types and inttypes.h are conflicting.
+# On IRIX 5.3, sys/types and inttypes.h are conflicting.
+
+
+
+
+
+
+
+
+
+for ac_header in sys/types.h sys/stat.h stdlib.h string.h memory.h strings.h \
+		  inttypes.h stdint.h unistd.h
+do
+as_ac_Header=`echo "ac_cv_header_$ac_header" | $as_tr_sh`
+{ echo "$as_me:$LINENO: checking for $ac_header" >&5
+echo $ECHO_N "checking for $ac_header... $ECHO_C" >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  echo $ECHO_N "(cached) $ECHO_C" >&6
+else
+  cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+$ac_includes_default
+
+#include <$ac_header>
+_ACEOF
+rm -f conftest.$ac_objext
+if { (ac_try="$ac_compile"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval "echo \"\$as_me:$LINENO: $ac_try_echo\"") >&5
+  (eval "$ac_compile") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest.$ac_objext; then
+  eval "$as_ac_Header=yes"
+else
+  echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	eval "$as_ac_Header=no"
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+ac_res=`eval echo '${'$as_ac_Header'}'`
+	       { echo "$as_me:$LINENO: result: $ac_res" >&5
+echo "${ECHO_T}$ac_res" >&6; }
+if test `eval echo '${'$as_ac_Header'}'` = yes; then
+  cat >>confdefs.h <<_ACEOF
+#define `echo "HAVE_$ac_header" | $as_tr_cpp` 1
+_ACEOF
+
+fi
+
+done
+
 
 
 
@@ -4184,23 +4308,35 @@
 
 
 
-for ac_header in sys/types.h sys/stat.h stdlib.h string.h memory.h strings.h \
-		  inttypes.h stdint.h unistd.h
+
+
+
+
+
+for ac_header in locale.h stddef.h syslog.h sys/file.h sys/time.h assert.h \
+  libgen.h signal.h sys/mman.h sys/resource.h sys/utsname.h sys/wait.h time.h
 do
 as_ac_Header=`echo "ac_cv_header_$ac_header" | $as_tr_sh`
-{ echo "$as_me:$LINENO: checking for $ac_header" >&5
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  { echo "$as_me:$LINENO: checking for $ac_header" >&5
 echo $ECHO_N "checking for $ac_header... $ECHO_C" >&6; }
 if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
   echo $ECHO_N "(cached) $ECHO_C" >&6
+fi
+ac_res=`eval echo '${'$as_ac_Header'}'`
+	       { echo "$as_me:$LINENO: result: $ac_res" >&5
+echo "${ECHO_T}$ac_res" >&6; }
 else
-  cat >conftest.$ac_ext <<_ACEOF
+  # Is the header compilable?
+{ echo "$as_me:$LINENO: checking $ac_header usability" >&5
+echo $ECHO_N "checking $ac_header usability... $ECHO_C" >&6; }
+cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
 cat confdefs.h >>conftest.$ac_ext
 cat >>conftest.$ac_ext <<_ACEOF
 /* end confdefs.h.  */
 $ac_includes_default
-
 #include <$ac_header>
 _ACEOF
 rm -f conftest.$ac_objext
@@ -4220,39 +4356,114 @@
 	 test -z "$ac_c_werror_flag" ||
 	 test ! -s conftest.err
        } && test -s conftest.$ac_objext; then
-  eval "$as_ac_Header=yes"
+  ac_header_compiler=yes
 else
   echo "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
-	eval "$as_ac_Header=no"
+	ac_header_compiler=no
 fi
 
 rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+{ echo "$as_me:$LINENO: result: $ac_header_compiler" >&5
+echo "${ECHO_T}$ac_header_compiler" >&6; }
+
+# Is the header present?
+{ echo "$as_me:$LINENO: checking $ac_header presence" >&5
+echo $ECHO_N "checking $ac_header presence... $ECHO_C" >&6; }
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+#include <$ac_header>
+_ACEOF
+if { (ac_try="$ac_cpp conftest.$ac_ext"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval "echo \"\$as_me:$LINENO: $ac_try_echo\"") >&5
+  (eval "$ac_cpp conftest.$ac_ext") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } >/dev/null && {
+	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       }; then
+  ac_header_preproc=yes
+else
+  echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+  ac_header_preproc=no
+fi
+
+rm -f conftest.err conftest.$ac_ext
+{ echo "$as_me:$LINENO: result: $ac_header_preproc" >&5
+echo "${ECHO_T}$ac_header_preproc" >&6; }
+
+# So?  What about this header?
+case $ac_header_compiler:$ac_header_preproc:$ac_c_preproc_warn_flag in
+  yes:no: )
+    { echo "$as_me:$LINENO: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&5
+echo "$as_me: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&2;}
+    { echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the compiler's result" >&5
+echo "$as_me: WARNING: $ac_header: proceeding with the compiler's result" >&2;}
+    ac_header_preproc=yes
+    ;;
+  no:yes:* )
+    { echo "$as_me:$LINENO: WARNING: $ac_header: present but cannot be compiled" >&5
+echo "$as_me: WARNING: $ac_header: present but cannot be compiled" >&2;}
+    { echo "$as_me:$LINENO: WARNING: $ac_header:     check for missing prerequisite headers?" >&5
+echo "$as_me: WARNING: $ac_header:     check for missing prerequisite headers?" >&2;}
+    { echo "$as_me:$LINENO: WARNING: $ac_header: see the Autoconf documentation" >&5
+echo "$as_me: WARNING: $ac_header: see the Autoconf documentation" >&2;}
+    { echo "$as_me:$LINENO: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&5
+echo "$as_me: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&2;}
+    { echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the preprocessor's result" >&5
+echo "$as_me: WARNING: $ac_header: proceeding with the preprocessor's result" >&2;}
+    { echo "$as_me:$LINENO: WARNING: $ac_header: in the future, the compiler will take precedence" >&5
+echo "$as_me: WARNING: $ac_header: in the future, the compiler will take precedence" >&2;}
+
+    ;;
+esac
+{ echo "$as_me:$LINENO: checking for $ac_header" >&5
+echo $ECHO_N "checking for $ac_header... $ECHO_C" >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  echo $ECHO_N "(cached) $ECHO_C" >&6
+else
+  eval "$as_ac_Header=\$ac_header_preproc"
 fi
 ac_res=`eval echo '${'$as_ac_Header'}'`
 	       { echo "$as_me:$LINENO: result: $ac_res" >&5
 echo "${ECHO_T}$ac_res" >&6; }
+
+fi
 if test `eval echo '${'$as_ac_Header'}'` = yes; then
   cat >>confdefs.h <<_ACEOF
 #define `echo "HAVE_$ac_header" | $as_tr_cpp` 1
 _ACEOF
 
+else
+  { { echo "$as_me:$LINENO: error: bailing out" >&5
+echo "$as_me: error: bailing out" >&2;}
+   { (exit 1); exit 1; }; }
 fi
 
 done
 
 
+case "$host_os" in
+	linux*)
 
 
 
-
-
-
-
-
-
-for ac_header in fcntl.h limits.h locale.h stddef.h syslog.h sys/file.h sys/ioctl.h sys/param.h sys/time.h
+for ac_header in asm/byteorder.h linux/fs.h malloc.h
 do
 as_ac_Header=`echo "ac_cv_header_$ac_header" | $as_tr_sh`
 if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
@@ -4394,20 +4605,11 @@
 fi
 
 done
+ ;;
+	darwin*)
 
 
-
-
-
-
-
-
-
-
-
-
-
-for ac_header in assert.h ctype.h libgen.h signal.h stdio.h sys/mman.h sys/resource.h sys/stat.h sys/types.h sys/utsname.h sys/wait.h time.h
+for ac_header in machine/endian.h sys/disk.h
 do
 as_ac_Header=`echo "ac_cv_header_$ac_header" | $as_tr_sh`
 if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
@@ -4549,14 +4751,28 @@
 fi
 
 done
+ ;;
+esac
 
 
-case "$host_os" in
-	linux*)
 
 
 
-for ac_header in asm/byteorder.h linux/fs.h malloc.h
+
+
+
+
+
+
+
+
+
+
+
+
+for ac_header in ctype.h dirent.h errno.h fcntl.h getopt.h inttypes.h limits.h \
+  stdarg.h stdio.h stdlib.h string.h sys/ioctl.h sys/param.h sys/stat.h \
+  sys/types.h unistd.h
 do
 as_ac_Header=`echo "ac_cv_header_$ac_header" | $as_tr_sh`
 if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
@@ -4698,11 +4914,10 @@
 fi
 
 done
- ;;
-	darwin*)
 
 
-for ac_header in machine/endian.h sys/disk.h
+
+for ac_header in termios.h sys/statvfs.h
 do
 as_ac_Header=`echo "ac_cv_header_$ac_header" | $as_tr_sh`
 if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
@@ -4837,15 +5052,10 @@
 #define `echo "HAVE_$ac_header" | $as_tr_cpp` 1
 _ACEOF
 
-else
-  { { echo "$as_me:$LINENO: error: bailing out" >&5
-echo "$as_me: error: bailing out" >&2;}
-   { (exit 1); exit 1; }; }
 fi
 
 done
- ;;
-esac
+
 
 ################################################################################
 { echo "$as_me:$LINENO: checking for an ANSI C-conforming const" >&5
@@ -5020,8 +5230,110 @@
 #define inline $ac_val
 #endif
 _ACEOF
-    ;;
-esac
+    ;;
+esac
+
+{ echo "$as_me:$LINENO: checking for struct stat.st_rdev" >&5
+echo $ECHO_N "checking for struct stat.st_rdev... $ECHO_C" >&6; }
+if test "${ac_cv_member_struct_stat_st_rdev+set}" = set; then
+  echo $ECHO_N "(cached) $ECHO_C" >&6
+else
+  cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+$ac_includes_default
+int
+main ()
+{
+static struct stat ac_aggr;
+if (ac_aggr.st_rdev)
+return 0;
+  ;
+  return 0;
+}
+_ACEOF
+rm -f conftest.$ac_objext
+if { (ac_try="$ac_compile"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval "echo \"\$as_me:$LINENO: $ac_try_echo\"") >&5
+  (eval "$ac_compile") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest.$ac_objext; then
+  ac_cv_member_struct_stat_st_rdev=yes
+else
+  echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+$ac_includes_default
+int
+main ()
+{
+static struct stat ac_aggr;
+if (sizeof ac_aggr.st_rdev)
+return 0;
+  ;
+  return 0;
+}
+_ACEOF
+rm -f conftest.$ac_objext
+if { (ac_try="$ac_compile"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval "echo \"\$as_me:$LINENO: $ac_try_echo\"") >&5
+  (eval "$ac_compile") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest.$ac_objext; then
+  ac_cv_member_struct_stat_st_rdev=yes
+else
+  echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_cv_member_struct_stat_st_rdev=no
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+{ echo "$as_me:$LINENO: result: $ac_cv_member_struct_stat_st_rdev" >&5
+echo "${ECHO_T}$ac_cv_member_struct_stat_st_rdev" >&6; }
+if test $ac_cv_member_struct_stat_st_rdev = yes; then
+
+cat >>confdefs.h <<_ACEOF
+#define HAVE_STRUCT_STAT_ST_RDEV 1
+_ACEOF
+
+
+fi
 
 { echo "$as_me:$LINENO: checking for off_t" >&5
 echo $ECHO_N "checking for off_t... $ECHO_C" >&6; }
@@ -5149,6 +5461,63 @@
 
 fi
 
+{ echo "$as_me:$LINENO: checking return type of signal handlers" >&5
+echo $ECHO_N "checking return type of signal handlers... $ECHO_C" >&6; }
+if test "${ac_cv_type_signal+set}" = set; then
+  echo $ECHO_N "(cached) $ECHO_C" >&6
+else
+  cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+#include <sys/types.h>
+#include <signal.h>
+
+int
+main ()
+{
+return *(signal (0, 0)) (0) == 1;
+  ;
+  return 0;
+}
+_ACEOF
+rm -f conftest.$ac_objext
+if { (ac_try="$ac_compile"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval "echo \"\$as_me:$LINENO: $ac_try_echo\"") >&5
+  (eval "$ac_compile") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest.$ac_objext; then
+  ac_cv_type_signal=int
+else
+  echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_cv_type_signal=void
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+{ echo "$as_me:$LINENO: result: $ac_cv_type_signal" >&5
+echo "${ECHO_T}$ac_cv_type_signal" >&6; }
+
+cat >>confdefs.h <<_ACEOF
+#define RETSIGTYPE $ac_cv_type_signal
+_ACEOF
+
+
 { echo "$as_me:$LINENO: checking for size_t" >&5
 echo $ECHO_N "checking for size_t... $ECHO_C" >&6; }
 if test "${ac_cv_type_size_t+set}" = set; then
@@ -5454,7 +5823,12 @@
 
 
 
-for ac_func in gethostname getpagesize memset munmap setlocale strcasecmp strchr strdup strncasecmp strerror strrchr strstr strtol strtoul
+
+
+
+for ac_func in gethostname getpagesize memset mkdir rmdir munmap setlocale \
+  strcasecmp strchr strdup strncasecmp strerror strrchr strstr strtol strtoul \
+  uname
 do
 as_ac_var=`echo "ac_cv_func_$ac_func" | $as_tr_sh`
 { echo "$as_me:$LINENO: checking for $ac_func" >&5
@@ -7676,830 +8050,588 @@
 rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
       conftest$ac_exeext conftest.$ac_ext
 LIBS=$ac_check_lib_save_LIBS
-fi
-{ echo "$as_me:$LINENO: result: $ac_cv_lib_m_pow" >&5
-echo "${ECHO_T}$ac_cv_lib_m_pow" >&6; }
-if test $ac_cv_lib_m_pow = yes; then
-  POW_LIB=-lm
-else
-  { echo "$as_me:$LINENO: WARNING: cannot find library containing definition of pow" >&5
-echo "$as_me: WARNING: cannot find library containing definition of pow" >&2;}
-fi
-
-fi
-
-fi
-
-
-################################################################################
-
-
-################################################################################
-# Check whether --enable-jobs was given.
-if test "${enable_jobs+set}" = set; then
-  enableval=$enable_jobs; JOBS=-j$enableval
-else
-  JOBS=-j2
-fi
-
-
-################################################################################
-{ echo "$as_me:$LINENO: checking file owner" >&5
-echo $ECHO_N "checking file owner... $ECHO_C" >&6; }
-OWNER="root"
-
-
-# Check whether --with-user was given.
-if test "${with_user+set}" = set; then
-  withval=$with_user;  OWNER="$withval"
-fi
-
-{ echo "$as_me:$LINENO: result: $OWNER" >&5
-echo "${ECHO_T}$OWNER" >&6; }
-
-if test x$OWNER != x; then
-	OWNER="-o $OWNER"
-fi
-
-################################################################################
-{ echo "$as_me:$LINENO: checking group owner" >&5
-echo $ECHO_N "checking group owner... $ECHO_C" >&6; }
-GROUP="root"
-
-# Check whether --with-group was given.
-if test "${with_group+set}" = set; then
-  withval=$with_group;  GROUP="$withval"
-fi
-
-{ echo "$as_me:$LINENO: result: $GROUP" >&5
-echo "${ECHO_T}$GROUP" >&6; }
-
-if test x$GROUP != x; then
-	GROUP="-g $GROUP"
-fi
-
-################################################################################
-{ echo "$as_me:$LINENO: checking whether to enable lvm1 fallback" >&5
-echo $ECHO_N "checking whether to enable lvm1 fallback... $ECHO_C" >&6; }
-# Check whether --enable-lvm1_fallback was given.
-if test "${enable_lvm1_fallback+set}" = set; then
-  enableval=$enable_lvm1_fallback; LVM1_FALLBACK=$enableval
-else
-  LVM1_FALLBACK=no
-fi
-
-{ echo "$as_me:$LINENO: result: $LVM1_FALLBACK" >&5
-echo "${ECHO_T}$LVM1_FALLBACK" >&6; }
-
-if test x$LVM1_FALLBACK = xyes; then
-
-cat >>confdefs.h <<\_ACEOF
-#define LVM1_FALLBACK 1
-_ACEOF
-
-fi
-
-################################################################################
-{ echo "$as_me:$LINENO: checking whether to include support for lvm1 metadata" >&5
-echo $ECHO_N "checking whether to include support for lvm1 metadata... $ECHO_C" >&6; }
-
-# Check whether --with-lvm1 was given.
-if test "${with_lvm1+set}" = set; then
-  withval=$with_lvm1;  LVM1="$withval"
-else
-   LVM1="internal"
-fi
-
-{ echo "$as_me:$LINENO: result: $LVM1" >&5
-echo "${ECHO_T}$LVM1" >&6; }
-
-if [ "x$LVM1" != xnone -a "x$LVM1" != xinternal -a "x$LVM1" != xshared ];
- then  { { echo "$as_me:$LINENO: error: --with-lvm1 parameter invalid
-" >&5
-echo "$as_me: error: --with-lvm1 parameter invalid
-" >&2;}
-   { (exit 1); exit 1; }; }
-fi;
-
-if test x$LVM1 = xinternal; then
-
-cat >>confdefs.h <<\_ACEOF
-#define LVM1_INTERNAL 1
-_ACEOF
-
-fi
-
-################################################################################
-{ echo "$as_me:$LINENO: checking whether to include support for GFS pool metadata" >&5
-echo $ECHO_N "checking whether to include support for GFS pool metadata... $ECHO_C" >&6; }
-
-# Check whether --with-pool was given.
-if test "${with_pool+set}" = set; then
-  withval=$with_pool;  POOL="$withval"
-else
-   POOL="internal"
-fi
-
-{ echo "$as_me:$LINENO: result: $POOL" >&5
-echo "${ECHO_T}$POOL" >&6; }
-
-if [ "x$POOL" != xnone -a "x$POOL" != xinternal -a "x$POOL" != xshared ];
- then  { { echo "$as_me:$LINENO: error: --with-pool parameter invalid
-" >&5
-echo "$as_me: error: --with-pool parameter invalid
-" >&2;}
-   { (exit 1); exit 1; }; }
-fi;
-
-if test x$POOL = xinternal; then
-
-cat >>confdefs.h <<\_ACEOF
-#define POOL_INTERNAL 1
-_ACEOF
-
-fi
-
-################################################################################
-{ echo "$as_me:$LINENO: checking whether to include support for cluster locking" >&5
-echo $ECHO_N "checking whether to include support for cluster locking... $ECHO_C" >&6; }
-
-# Check whether --with-cluster was given.
-if test "${with_cluster+set}" = set; then
-  withval=$with_cluster;  CLUSTER="$withval"
-fi
-
-{ echo "$as_me:$LINENO: result: $CLUSTER" >&5
-echo "${ECHO_T}$CLUSTER" >&6; }
-
-if [ "x$CLUSTER" != xnone -a "x$CLUSTER" != xinternal -a "x$CLUSTER" != xshared ];
- then  { { echo "$as_me:$LINENO: error: --with-cluster parameter invalid
-" >&5
-echo "$as_me: error: --with-cluster parameter invalid
-" >&2;}
-   { (exit 1); exit 1; }; }
-fi;
-
-if test x$CLUSTER = xinternal; then
-
-cat >>confdefs.h <<\_ACEOF
-#define CLUSTER_LOCKING_INTERNAL 1
-_ACEOF
-
-fi
-
-################################################################################
-{ echo "$as_me:$LINENO: checking whether to include snapshots" >&5
-echo $ECHO_N "checking whether to include snapshots... $ECHO_C" >&6; }
-
-# Check whether --with-snapshots was given.
-if test "${with_snapshots+set}" = set; then
-  withval=$with_snapshots;  SNAPSHOTS="$withval"
-else
-   SNAPSHOTS="internal"
-fi
-
-{ echo "$as_me:$LINENO: result: $SNAPSHOTS" >&5
-echo "${ECHO_T}$SNAPSHOTS" >&6; }
-
-if [ "x$SNAPSHOTS" != xnone -a "x$SNAPSHOTS" != xinternal -a "x$SNAPSHOTS" != xshared ];
- then  { { echo "$as_me:$LINENO: error: --with-snapshots parameter invalid
-" >&5
-echo "$as_me: error: --with-snapshots parameter invalid
-" >&2;}
-   { (exit 1); exit 1; }; }
-fi;
-
-if test x$SNAPSHOTS = xinternal; then
+fi
+{ echo "$as_me:$LINENO: result: $ac_cv_lib_m_pow" >&5
+echo "${ECHO_T}$ac_cv_lib_m_pow" >&6; }
+if test $ac_cv_lib_m_pow = yes; then
+  POW_LIB=-lm
+else
+  { echo "$as_me:$LINENO: WARNING: cannot find library containing definition of pow" >&5
+echo "$as_me: WARNING: cannot find library containing definition of pow" >&2;}
+fi
 
-cat >>confdefs.h <<\_ACEOF
-#define SNAPSHOT_INTERNAL 1
-_ACEOF
+fi
 
 fi
 
-################################################################################
-{ echo "$as_me:$LINENO: checking whether to include mirrors" >&5
-echo $ECHO_N "checking whether to include mirrors... $ECHO_C" >&6; }
 
-# Check whether --with-mirrors was given.
-if test "${with_mirrors+set}" = set; then
-  withval=$with_mirrors;  MIRRORS="$withval"
+for ac_func in vprintf
+do
+as_ac_var=`echo "ac_cv_func_$ac_func" | $as_tr_sh`
+{ echo "$as_me:$LINENO: checking for $ac_func" >&5
+echo $ECHO_N "checking for $ac_func... $ECHO_C" >&6; }
+if { as_var=$as_ac_var; eval "test \"\${$as_var+set}\" = set"; }; then
+  echo $ECHO_N "(cached) $ECHO_C" >&6
 else
-   MIRRORS="internal"
-fi
+  cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+/* Define $ac_func to an innocuous variant, in case <limits.h> declares $ac_func.
+   For example, HP-UX 11i <limits.h> declares gettimeofday.  */
+#define $ac_func innocuous_$ac_func
 
-{ echo "$as_me:$LINENO: result: $MIRRORS" >&5
-echo "${ECHO_T}$MIRRORS" >&6; }
+/* System header to define __stub macros and hopefully few prototypes,
+    which can conflict with char $ac_func (); below.
+    Prefer <limits.h> to <assert.h> if __STDC__ is defined, since
+    <limits.h> exists even on freestanding compilers.  */
 
-if [ "x$MIRRORS" != xnone -a "x$MIRRORS" != xinternal -a "x$MIRRORS" != xshared ];
- then  { { echo "$as_me:$LINENO: error: --with-mirrors parameter invalid
-" >&5
-echo "$as_me: error: --with-mirrors parameter invalid
-" >&2;}
-   { (exit 1); exit 1; }; }
-fi;
+#ifdef __STDC__
+# include <limits.h>
+#else
+# include <assert.h>
+#endif
 
-if test x$MIRRORS = xinternal; then
+#undef $ac_func
 
-cat >>confdefs.h <<\_ACEOF
-#define MIRRORED_INTERNAL 1
+/* Override any GCC internal prototype to avoid an error.
+   Use char because int might match the return type of a GCC
+   builtin and then its argument prototype would still apply.  */
+#ifdef __cplusplus
+extern "C"
+#endif
+char $ac_func ();
+/* The GNU C library defines this for functions which it implements
+    to always fail with ENOSYS.  Some functions are actually named
+    something starting with __ and the normal name is an alias.  */
+#if defined __stub_$ac_func || defined __stub___$ac_func
+choke me
+#endif
+
+int
+main ()
+{
+return $ac_func ();
+  ;
+  return 0;
+}
 _ACEOF
+rm -f conftest.$ac_objext conftest$ac_exeext
+if { (ac_try="$ac_link"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval "echo \"\$as_me:$LINENO: $ac_try_echo\"") >&5
+  (eval "$ac_link") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest$ac_exeext &&
+       $as_test_x conftest$ac_exeext; then
+  eval "$as_ac_var=yes"
+else
+  echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
 
+	eval "$as_ac_var=no"
 fi
 
-################################################################################
-{ echo "$as_me:$LINENO: checking whether to use static linking" >&5
-echo $ECHO_N "checking whether to use static linking... $ECHO_C" >&6; }
-# Check whether --enable-static_link was given.
-if test "${enable_static_link+set}" = set; then
-  enableval=$enable_static_link; STATIC_LINK=$enableval
-else
-  STATIC_LINK=no
+rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
+      conftest$ac_exeext conftest.$ac_ext
 fi
+ac_res=`eval echo '${'$as_ac_var'}'`
+	       { echo "$as_me:$LINENO: result: $ac_res" >&5
+echo "${ECHO_T}$ac_res" >&6; }
+if test `eval echo '${'$as_ac_var'}'` = yes; then
+  cat >>confdefs.h <<_ACEOF
+#define `echo "HAVE_$ac_func" | $as_tr_cpp` 1
+_ACEOF
 
-{ echo "$as_me:$LINENO: result: $STATIC_LINK" >&5
-echo "${ECHO_T}$STATIC_LINK" >&6; }
-
-################################################################################
-{ echo "$as_me:$LINENO: checking whether to enable readline" >&5
-echo $ECHO_N "checking whether to enable readline... $ECHO_C" >&6; }
-# Check whether --enable-readline was given.
-if test "${enable_readline+set}" = set; then
-  enableval=$enable_readline; READLINE=$enableval
+{ echo "$as_me:$LINENO: checking for _doprnt" >&5
+echo $ECHO_N "checking for _doprnt... $ECHO_C" >&6; }
+if test "${ac_cv_func__doprnt+set}" = set; then
+  echo $ECHO_N "(cached) $ECHO_C" >&6
 else
-  READLINE=no
-fi
+  cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+/* Define _doprnt to an innocuous variant, in case <limits.h> declares _doprnt.
+   For example, HP-UX 11i <limits.h> declares gettimeofday.  */
+#define _doprnt innocuous__doprnt
 
-{ echo "$as_me:$LINENO: result: $READLINE" >&5
-echo "${ECHO_T}$READLINE" >&6; }
+/* System header to define __stub macros and hopefully few prototypes,
+    which can conflict with char _doprnt (); below.
+    Prefer <limits.h> to <assert.h> if __STDC__ is defined, since
+    <limits.h> exists even on freestanding compilers.  */
 
-if test x$READLINE = xyes; then
+#ifdef __STDC__
+# include <limits.h>
+#else
+# include <assert.h>
+#endif
 
-cat >>confdefs.h <<\_ACEOF
-#define READLINE_SUPPORT 1
+#undef _doprnt
+
+/* Override any GCC internal prototype to avoid an error.
+   Use char because int might match the return type of a GCC
+   builtin and then its argument prototype would still apply.  */
+#ifdef __cplusplus
+extern "C"
+#endif
+char _doprnt ();
+/* The GNU C library defines this for functions which it implements
+    to always fail with ENOSYS.  Some functions are actually named
+    something starting with __ and the normal name is an alias.  */
+#if defined __stub__doprnt || defined __stub____doprnt
+choke me
+#endif
+
+int
+main ()
+{
+return _doprnt ();
+  ;
+  return 0;
+}
 _ACEOF
+rm -f conftest.$ac_objext conftest$ac_exeext
+if { (ac_try="$ac_link"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval "echo \"\$as_me:$LINENO: $ac_try_echo\"") >&5
+  (eval "$ac_link") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest$ac_exeext &&
+       $as_test_x conftest$ac_exeext; then
+  ac_cv_func__doprnt=yes
+else
+  echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
 
+	ac_cv_func__doprnt=no
 fi
 
-################################################################################
-{ echo "$as_me:$LINENO: checking whether to enable selinux support" >&5
-echo $ECHO_N "checking whether to enable selinux support... $ECHO_C" >&6; }
-# Check whether --enable-selinux was given.
-if test "${enable_selinux+set}" = set; then
-  enableval=$enable_selinux; SELINUX=$enableval
+rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
+      conftest$ac_exeext conftest.$ac_ext
 fi
+{ echo "$as_me:$LINENO: result: $ac_cv_func__doprnt" >&5
+echo "${ECHO_T}$ac_cv_func__doprnt" >&6; }
+if test $ac_cv_func__doprnt = yes; then
 
-{ echo "$as_me:$LINENO: result: $SELINUX" >&5
-echo "${ECHO_T}$SELINUX" >&6; }
+cat >>confdefs.h <<\_ACEOF
+#define HAVE_DOPRNT 1
+_ACEOF
 
-################################################################################
-{ echo "$as_me:$LINENO: checking whether to enable realtime support" >&5
-echo $ECHO_N "checking whether to enable realtime support... $ECHO_C" >&6; }
-# Check whether --enable-realtime was given.
-if test "${enable_realtime+set}" = set; then
-  enableval=$enable_realtime; REALTIME=$enableval
 fi
 
-{ echo "$as_me:$LINENO: result: $REALTIME" >&5
-echo "${ECHO_T}$REALTIME" >&6; }
+fi
+done
 
-################################################################################
-{ echo "$as_me:$LINENO: checking whether to build cluster LVM daemon" >&5
-echo $ECHO_N "checking whether to build cluster LVM daemon... $ECHO_C" >&6; }
 
-# Check whether --with-clvmd was given.
-if test "${with_clvmd+set}" = set; then
-  withval=$with_clvmd;  CLVMD="$withval"
-else
-   CLVMD="none"
-fi
 
-if test x$CLVMD = xyes; then
-	CLVMD=all
-fi
-{ echo "$as_me:$LINENO: result: $CLVMD" >&5
-echo "${ECHO_T}$CLVMD" >&6; }
+################################################################################
 
-if  test x$CLVMD != xnone && test x$CLUSTER = xnone; then
-	CLUSTER=internal
-fi
 
 ################################################################################
-{ echo "$as_me:$LINENO: checking whether to enable debugging" >&5
-echo $ECHO_N "checking whether to enable debugging... $ECHO_C" >&6; }
-# Check whether --enable-debug was given.
-if test "${enable_debug+set}" = set; then
-  enableval=$enable_debug; DEBUG=$enableval
-else
-  DEBUG=no
+{ echo "$as_me:$LINENO: checking file owner" >&5
+echo $ECHO_N "checking file owner... $ECHO_C" >&6; }
+OWNER="root"
+
+
+# Check whether --with-user was given.
+if test "${with_user+set}" = set; then
+  withval=$with_user;  OWNER="$withval"
 fi
 
-{ echo "$as_me:$LINENO: result: $DEBUG" >&5
-echo "${ECHO_T}$DEBUG" >&6; }
+{ echo "$as_me:$LINENO: result: $OWNER" >&5
+echo "${ECHO_T}$OWNER" >&6; }
 
-if test x$DEBUG = xyes; then
-	COPTIMISE_FLAG=
-else
-	CSCOPE_CMD=
+if test x$OWNER != x; then
+	OWNER="-o $OWNER"
 fi
 
 ################################################################################
-{ echo "$as_me:$LINENO: checking for C optimisation flag" >&5
-echo $ECHO_N "checking for C optimisation flag... $ECHO_C" >&6; }
+{ echo "$as_me:$LINENO: checking group owner" >&5
+echo $ECHO_N "checking group owner... $ECHO_C" >&6; }
+GROUP="root"
 
-# Check whether --with-optimisation was given.
-if test "${with_optimisation+set}" = set; then
-  withval=$with_optimisation;  COPTIMISE_FLAG="$withval"
+# Check whether --with-group was given.
+if test "${with_group+set}" = set; then
+  withval=$with_group;  GROUP="$withval"
 fi
 
-{ echo "$as_me:$LINENO: result: $COPTIMISE_FLAG" >&5
-echo "${ECHO_T}$COPTIMISE_FLAG" >&6; }
+{ echo "$as_me:$LINENO: result: $GROUP" >&5
+echo "${ECHO_T}$GROUP" >&6; }
+
+if test x$GROUP != x; then
+	GROUP="-g $GROUP"
+fi
 
 ################################################################################
-{ echo "$as_me:$LINENO: checking whether to use device-mapper" >&5
-echo $ECHO_N "checking whether to use device-mapper... $ECHO_C" >&6; }
-# Check whether --enable-devmapper was given.
-if test "${enable_devmapper+set}" = set; then
-  enableval=$enable_devmapper; DEVMAPPER=$enableval
+{ echo "$as_me:$LINENO: checking whether to enable lvm1 fallback" >&5
+echo $ECHO_N "checking whether to enable lvm1 fallback... $ECHO_C" >&6; }
+# Check whether --enable-lvm1_fallback was given.
+if test "${enable_lvm1_fallback+set}" = set; then
+  enableval=$enable_lvm1_fallback; LVM1_FALLBACK=$enableval
+else
+  LVM1_FALLBACK=no
 fi
 
-{ echo "$as_me:$LINENO: result: $DEVMAPPER" >&5
-echo "${ECHO_T}$DEVMAPPER" >&6; }
+{ echo "$as_me:$LINENO: result: $LVM1_FALLBACK" >&5
+echo "${ECHO_T}$LVM1_FALLBACK" >&6; }
 
-if test x$DEVMAPPER = xyes; then
+if test x$LVM1_FALLBACK = xyes; then
 
 cat >>confdefs.h <<\_ACEOF
-#define DEVMAPPER_SUPPORT 1
+#define LVM1_FALLBACK 1
 _ACEOF
 
 fi
 
 ################################################################################
-{ echo "$as_me:$LINENO: checking whether to enable O_DIRECT" >&5
-echo $ECHO_N "checking whether to enable O_DIRECT... $ECHO_C" >&6; }
-# Check whether --enable-o_direct was given.
-if test "${enable_o_direct+set}" = set; then
-  enableval=$enable_o_direct; ODIRECT=$enableval
+{ echo "$as_me:$LINENO: checking whether to include support for lvm1 metadata" >&5
+echo $ECHO_N "checking whether to include support for lvm1 metadata... $ECHO_C" >&6; }
+
+# Check whether --with-lvm1 was given.
+if test "${with_lvm1+set}" = set; then
+  withval=$with_lvm1;  LVM1="$withval"
+else
+   LVM1="internal"
 fi
 
-{ echo "$as_me:$LINENO: result: $ODIRECT" >&5
-echo "${ECHO_T}$ODIRECT" >&6; }
+{ echo "$as_me:$LINENO: result: $LVM1" >&5
+echo "${ECHO_T}$LVM1" >&6; }
 
-if test x$ODIRECT = xyes; then
+if [ "x$LVM1" != xnone -a "x$LVM1" != xinternal -a "x$LVM1" != xshared ];
+ then  { { echo "$as_me:$LINENO: error: --with-lvm1 parameter invalid
+" >&5
+echo "$as_me: error: --with-lvm1 parameter invalid
+" >&2;}
+   { (exit 1); exit 1; }; }
+fi;
+
+if test x$LVM1 = xinternal; then
 
 cat >>confdefs.h <<\_ACEOF
-#define O_DIRECT_SUPPORT 1
+#define LVM1_INTERNAL 1
 _ACEOF
 
 fi
 
 ################################################################################
-{ echo "$as_me:$LINENO: checking whether to compile liblvm2cmd.so" >&5
-echo $ECHO_N "checking whether to compile liblvm2cmd.so... $ECHO_C" >&6; }
-# Check whether --enable-cmdlib was given.
-if test "${enable_cmdlib+set}" = set; then
-  enableval=$enable_cmdlib; CMDLIB=$enableval
+{ echo "$as_me:$LINENO: checking whether to include support for GFS pool metadata" >&5
+echo $ECHO_N "checking whether to include support for GFS pool metadata... $ECHO_C" >&6; }
+
+# Check whether --with-pool was given.
+if test "${with_pool+set}" = set; then
+  withval=$with_pool;  POOL="$withval"
 else
-  CMDLIB=no
+   POOL="internal"
 fi
 
-{ echo "$as_me:$LINENO: result: $CMDLIB" >&5
-echo "${ECHO_T}$CMDLIB" >&6; }
+{ echo "$as_me:$LINENO: result: $POOL" >&5
+echo "${ECHO_T}$POOL" >&6; }
 
-################################################################################
-{ echo "$as_me:$LINENO: checking whether to install fsadm" >&5
-echo $ECHO_N "checking whether to install fsadm... $ECHO_C" >&6; }
-# Check whether --enable-fsadm was given.
-if test "${enable_fsadm+set}" = set; then
-  enableval=$enable_fsadm; FSADM=$enableval
-fi
+if [ "x$POOL" != xnone -a "x$POOL" != xinternal -a "x$POOL" != xshared ];
+ then  { { echo "$as_me:$LINENO: error: --with-pool parameter invalid
+" >&5
+echo "$as_me: error: --with-pool parameter invalid
+" >&2;}
+   { (exit 1); exit 1; }; }
+fi;
 
-{ echo "$as_me:$LINENO: result: $FSADM" >&5
-echo "${ECHO_T}$FSADM" >&6; }
+if test x$POOL = xinternal; then
+
+cat >>confdefs.h <<\_ACEOF
+#define POOL_INTERNAL 1
+_ACEOF
+
+fi
 
 ################################################################################
-{ echo "$as_me:$LINENO: checking whether to use dmeventd" >&5
-echo $ECHO_N "checking whether to use dmeventd... $ECHO_C" >&6; }
-# Check whether --enable-dmeventd was given.
-if test "${enable_dmeventd+set}" = set; then
-  enableval=$enable_dmeventd; DMEVENTD=$enableval
+{ echo "$as_me:$LINENO: checking whether to include support for cluster locking" >&5
+echo $ECHO_N "checking whether to include support for cluster locking... $ECHO_C" >&6; }
+
+# Check whether --with-cluster was given.
+if test "${with_cluster+set}" = set; then
+  withval=$with_cluster;  CLUSTER="$withval"
 fi
 
-{ echo "$as_me:$LINENO: result: $DMEVENTD" >&5
-echo "${ECHO_T}$DMEVENTD" >&6; }
+{ echo "$as_me:$LINENO: result: $CLUSTER" >&5
+echo "${ECHO_T}$CLUSTER" >&6; }
 
-if test x$DMEVENTD = xyes && test x$MIRRORS != xinternal; then
-{ { echo "$as_me:$LINENO: error: --enable-dmeventd currently requires --with-mirrors=internal
+if [ "x$CLUSTER" != xnone -a "x$CLUSTER" != xinternal -a "x$CLUSTER" != xshared ];
+ then  { { echo "$as_me:$LINENO: error: --with-cluster parameter invalid
 " >&5
-echo "$as_me: error: --enable-dmeventd currently requires --with-mirrors=internal
+echo "$as_me: error: --with-cluster parameter invalid
 " >&2;}
    { (exit 1); exit 1; }; }
-fi
+fi;
 
-if test x$DMEVENTD = xyes; then
+if test x$CLUSTER = xinternal; then
 
 cat >>confdefs.h <<\_ACEOF
-#define DMEVENTD 1
+#define CLUSTER_LOCKING_INTERNAL 1
 _ACEOF
 
 fi
-################################################################################
-if [ "x$exec_prefix" = xNONE -a "x$prefix" = xNONE ];
- then  exec_prefix="";
-fi;
 
 ################################################################################
-if test $ac_cv_c_compiler_gnu = yes; then
-    { echo "$as_me:$LINENO: checking whether $CC needs -traditional" >&5
-echo $ECHO_N "checking whether $CC needs -traditional... $ECHO_C" >&6; }
-if test "${ac_cv_prog_gcc_traditional+set}" = set; then
-  echo $ECHO_N "(cached) $ECHO_C" >&6
-else
-    ac_pattern="Autoconf.*'x'"
-  cat >conftest.$ac_ext <<_ACEOF
-/* confdefs.h.  */
-_ACEOF
-cat confdefs.h >>conftest.$ac_ext
-cat >>conftest.$ac_ext <<_ACEOF
-/* end confdefs.h.  */
-#include <sgtty.h>
-Autoconf TIOCGETP
-_ACEOF
-if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
-  $EGREP "$ac_pattern" >/dev/null 2>&1; then
-  ac_cv_prog_gcc_traditional=yes
-else
-  ac_cv_prog_gcc_traditional=no
-fi
-rm -f conftest*
-
-
-  if test $ac_cv_prog_gcc_traditional = no; then
-    cat >conftest.$ac_ext <<_ACEOF
-/* confdefs.h.  */
-_ACEOF
-cat confdefs.h >>conftest.$ac_ext
-cat >>conftest.$ac_ext <<_ACEOF
-/* end confdefs.h.  */
-#include <termio.h>
-Autoconf TCGETA
-_ACEOF
-if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
-  $EGREP "$ac_pattern" >/dev/null 2>&1; then
-  ac_cv_prog_gcc_traditional=yes
-fi
-rm -f conftest*
+{ echo "$as_me:$LINENO: checking whether to include snapshots" >&5
+echo $ECHO_N "checking whether to include snapshots... $ECHO_C" >&6; }
 
-  fi
-fi
-{ echo "$as_me:$LINENO: result: $ac_cv_prog_gcc_traditional" >&5
-echo "${ECHO_T}$ac_cv_prog_gcc_traditional" >&6; }
-  if test $ac_cv_prog_gcc_traditional = yes; then
-    CC="$CC -traditional"
-  fi
+# Check whether --with-snapshots was given.
+if test "${with_snapshots+set}" = set; then
+  withval=$with_snapshots;  SNAPSHOTS="$withval"
+else
+   SNAPSHOTS="internal"
 fi
 
-{ echo "$as_me:$LINENO: checking return type of signal handlers" >&5
-echo $ECHO_N "checking return type of signal handlers... $ECHO_C" >&6; }
-if test "${ac_cv_type_signal+set}" = set; then
-  echo $ECHO_N "(cached) $ECHO_C" >&6
-else
-  cat >conftest.$ac_ext <<_ACEOF
-/* confdefs.h.  */
-_ACEOF
-cat confdefs.h >>conftest.$ac_ext
-cat >>conftest.$ac_ext <<_ACEOF
-/* end confdefs.h.  */
-#include <sys/types.h>
-#include <signal.h>
+{ echo "$as_me:$LINENO: result: $SNAPSHOTS" >&5
+echo "${ECHO_T}$SNAPSHOTS" >&6; }
 
-int
-main ()
-{
-return *(signal (0, 0)) (0) == 1;
-  ;
-  return 0;
-}
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
-  ac_cv_type_signal=int
-else
-  echo "$as_me: failed program was:" >&5
-sed 's/^/| /' conftest.$ac_ext >&5
+if [ "x$SNAPSHOTS" != xnone -a "x$SNAPSHOTS" != xinternal -a "x$SNAPSHOTS" != xshared ];
+ then  { { echo "$as_me:$LINENO: error: --with-snapshots parameter invalid
+" >&5
+echo "$as_me: error: --with-snapshots parameter invalid
+" >&2;}
+   { (exit 1); exit 1; }; }
+fi;
+
+if test x$SNAPSHOTS = xinternal; then
+
+cat >>confdefs.h <<\_ACEOF
+#define SNAPSHOT_INTERNAL 1
+_ACEOF
 
-	ac_cv_type_signal=void
 fi
 
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+################################################################################
+{ echo "$as_me:$LINENO: checking whether to include mirrors" >&5
+echo $ECHO_N "checking whether to include mirrors... $ECHO_C" >&6; }
+
+# Check whether --with-mirrors was given.
+if test "${with_mirrors+set}" = set; then
+  withval=$with_mirrors;  MIRRORS="$withval"
+else
+   MIRRORS="internal"
 fi
-{ echo "$as_me:$LINENO: result: $ac_cv_type_signal" >&5
-echo "${ECHO_T}$ac_cv_type_signal" >&6; }
 
-cat >>confdefs.h <<_ACEOF
-#define RETSIGTYPE $ac_cv_type_signal
-_ACEOF
+{ echo "$as_me:$LINENO: result: $MIRRORS" >&5
+echo "${ECHO_T}$MIRRORS" >&6; }
 
+if [ "x$MIRRORS" != xnone -a "x$MIRRORS" != xinternal -a "x$MIRRORS" != xshared ];
+ then  { { echo "$as_me:$LINENO: error: --with-mirrors parameter invalid
+" >&5
+echo "$as_me: error: --with-mirrors parameter invalid
+" >&2;}
+   { (exit 1); exit 1; }; }
+fi;
 
+if test x$MIRRORS = xinternal; then
 
-for ac_func in vprintf
-do
-as_ac_var=`echo "ac_cv_func_$ac_func" | $as_tr_sh`
-{ echo "$as_me:$LINENO: checking for $ac_func" >&5
-echo $ECHO_N "checking for $ac_func... $ECHO_C" >&6; }
-if { as_var=$as_ac_var; eval "test \"\${$as_var+set}\" = set"; }; then
-  echo $ECHO_N "(cached) $ECHO_C" >&6
-else
-  cat >conftest.$ac_ext <<_ACEOF
-/* confdefs.h.  */
+cat >>confdefs.h <<\_ACEOF
+#define MIRRORED_INTERNAL 1
 _ACEOF
-cat confdefs.h >>conftest.$ac_ext
-cat >>conftest.$ac_ext <<_ACEOF
-/* end confdefs.h.  */
-/* Define $ac_func to an innocuous variant, in case <limits.h> declares $ac_func.
-   For example, HP-UX 11i <limits.h> declares gettimeofday.  */
-#define $ac_func innocuous_$ac_func
 
-/* System header to define __stub macros and hopefully few prototypes,
-    which can conflict with char $ac_func (); below.
-    Prefer <limits.h> to <assert.h> if __STDC__ is defined, since
-    <limits.h> exists even on freestanding compilers.  */
+fi
 
-#ifdef __STDC__
-# include <limits.h>
-#else
-# include <assert.h>
-#endif
+################################################################################
+{ echo "$as_me:$LINENO: checking whether to enable readline" >&5
+echo $ECHO_N "checking whether to enable readline... $ECHO_C" >&6; }
+# Check whether --enable-readline was given.
+if test "${enable_readline+set}" = set; then
+  enableval=$enable_readline; READLINE=$enableval
+else
+  READLINE=no
+fi
 
-#undef $ac_func
+{ echo "$as_me:$LINENO: result: $READLINE" >&5
+echo "${ECHO_T}$READLINE" >&6; }
 
-/* Override any GCC internal prototype to avoid an error.
-   Use char because int might match the return type of a GCC
-   builtin and then its argument prototype would still apply.  */
-#ifdef __cplusplus
-extern "C"
-#endif
-char $ac_func ();
-/* The GNU C library defines this for functions which it implements
-    to always fail with ENOSYS.  Some functions are actually named
-    something starting with __ and the normal name is an alias.  */
-#if defined __stub_$ac_func || defined __stub___$ac_func
-choke me
-#endif
+if test x$READLINE = xyes; then
 
-int
-main ()
-{
-return $ac_func ();
-  ;
-  return 0;
-}
+cat >>confdefs.h <<\_ACEOF
+#define READLINE_SUPPORT 1
 _ACEOF
-rm -f conftest.$ac_objext conftest$ac_exeext
-if { (ac_try="$ac_link"
-case "(($ac_try" in
-  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
-  *) ac_try_echo=$ac_try;;
-esac
-eval "echo \"\$as_me:$LINENO: $ac_try_echo\"") >&5
-  (eval "$ac_link") 2>conftest.er1
-  ac_status=$?
-  grep -v '^ *+' conftest.er1 >conftest.err
-  rm -f conftest.er1
-  cat conftest.err >&5
-  echo "$as_me:$LINENO: \$? = $ac_status" >&5
-  (exit $ac_status); } && {
-	 test -z "$ac_c_werror_flag" ||
-	 test ! -s conftest.err
-       } && test -s conftest$ac_exeext &&
-       $as_test_x conftest$ac_exeext; then
-  eval "$as_ac_var=yes"
-else
-  echo "$as_me: failed program was:" >&5
-sed 's/^/| /' conftest.$ac_ext >&5
 
-	eval "$as_ac_var=no"
 fi
 
-rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
-      conftest$ac_exeext conftest.$ac_ext
+################################################################################
+{ echo "$as_me:$LINENO: checking whether to enable realtime support" >&5
+echo $ECHO_N "checking whether to enable realtime support... $ECHO_C" >&6; }
+# Check whether --enable-realtime was given.
+if test "${enable_realtime+set}" = set; then
+  enableval=$enable_realtime; REALTIME=$enableval
 fi
-ac_res=`eval echo '${'$as_ac_var'}'`
-	       { echo "$as_me:$LINENO: result: $ac_res" >&5
-echo "${ECHO_T}$ac_res" >&6; }
-if test `eval echo '${'$as_ac_var'}'` = yes; then
-  cat >>confdefs.h <<_ACEOF
-#define `echo "HAVE_$ac_func" | $as_tr_cpp` 1
-_ACEOF
 
-{ echo "$as_me:$LINENO: checking for _doprnt" >&5
-echo $ECHO_N "checking for _doprnt... $ECHO_C" >&6; }
-if test "${ac_cv_func__doprnt+set}" = set; then
-  echo $ECHO_N "(cached) $ECHO_C" >&6
+{ echo "$as_me:$LINENO: result: $REALTIME" >&5
+echo "${ECHO_T}$REALTIME" >&6; }
+
+################################################################################
+{ echo "$as_me:$LINENO: checking whether to build cluster LVM daemon" >&5
+echo $ECHO_N "checking whether to build cluster LVM daemon... $ECHO_C" >&6; }
+
+# Check whether --with-clvmd was given.
+if test "${with_clvmd+set}" = set; then
+  withval=$with_clvmd;  CLVMD="$withval"
 else
-  cat >conftest.$ac_ext <<_ACEOF
-/* confdefs.h.  */
-_ACEOF
-cat confdefs.h >>conftest.$ac_ext
-cat >>conftest.$ac_ext <<_ACEOF
-/* end confdefs.h.  */
-/* Define _doprnt to an innocuous variant, in case <limits.h> declares _doprnt.
-   For example, HP-UX 11i <limits.h> declares gettimeofday.  */
-#define _doprnt innocuous__doprnt
+   CLVMD="none"
+fi
 
-/* System header to define __stub macros and hopefully few prototypes,
-    which can conflict with char _doprnt (); below.
-    Prefer <limits.h> to <assert.h> if __STDC__ is defined, since
-    <limits.h> exists even on freestanding compilers.  */
+if test x$CLVMD = xyes; then
+	CLVMD=all
+fi
+{ echo "$as_me:$LINENO: result: $CLVMD" >&5
+echo "${ECHO_T}$CLVMD" >&6; }
 
-#ifdef __STDC__
-# include <limits.h>
-#else
-# include <assert.h>
-#endif
+if  test x$CLVMD != xnone && test x$CLUSTER = xnone; then
+	CLUSTER=internal
+fi
 
-#undef _doprnt
+################################################################################
+{ echo "$as_me:$LINENO: checking whether to enable debugging" >&5
+echo $ECHO_N "checking whether to enable debugging... $ECHO_C" >&6; }
+# Check whether --enable-debug was given.
+if test "${enable_debug+set}" = set; then
+  enableval=$enable_debug; DEBUG=$enableval
+else
+  DEBUG=no
+fi
 
-/* Override any GCC internal prototype to avoid an error.
-   Use char because int might match the return type of a GCC
-   builtin and then its argument prototype would still apply.  */
-#ifdef __cplusplus
-extern "C"
-#endif
-char _doprnt ();
-/* The GNU C library defines this for functions which it implements
-    to always fail with ENOSYS.  Some functions are actually named
-    something starting with __ and the normal name is an alias.  */
-#if defined __stub__doprnt || defined __stub____doprnt
-choke me
-#endif
+{ echo "$as_me:$LINENO: result: $DEBUG" >&5
+echo "${ECHO_T}$DEBUG" >&6; }
 
-int
-main ()
-{
-return _doprnt ();
-  ;
-  return 0;
-}
-_ACEOF
-rm -f conftest.$ac_objext conftest$ac_exeext
-if { (ac_try="$ac_link"
-case "(($ac_try" in
-  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
-  *) ac_try_echo=$ac_try;;
-esac
-eval "echo \"\$as_me:$LINENO: $ac_try_echo\"") >&5
-  (eval "$ac_link") 2>conftest.er1
-  ac_status=$?
-  grep -v '^ *+' conftest.er1 >conftest.err
-  rm -f conftest.er1
-  cat conftest.err >&5
-  echo "$as_me:$LINENO: \$? = $ac_status" >&5
-  (exit $ac_status); } && {
-	 test -z "$ac_c_werror_flag" ||
-	 test ! -s conftest.err
-       } && test -s conftest$ac_exeext &&
-       $as_test_x conftest$ac_exeext; then
-  ac_cv_func__doprnt=yes
+if test x$DEBUG = xyes; then
+	COPTIMISE_FLAG=
 else
-  echo "$as_me: failed program was:" >&5
-sed 's/^/| /' conftest.$ac_ext >&5
+	CSCOPE_CMD=
+fi
 
-	ac_cv_func__doprnt=no
+################################################################################
+{ echo "$as_me:$LINENO: checking for C optimisation flag" >&5
+echo $ECHO_N "checking for C optimisation flag... $ECHO_C" >&6; }
+
+# Check whether --with-optimisation was given.
+if test "${with_optimisation+set}" = set; then
+  withval=$with_optimisation;  COPTIMISE_FLAG="$withval"
+fi
+
+{ echo "$as_me:$LINENO: result: $COPTIMISE_FLAG" >&5
+echo "${ECHO_T}$COPTIMISE_FLAG" >&6; }
+
+################################################################################
+{ echo "$as_me:$LINENO: checking whether to use device-mapper" >&5
+echo $ECHO_N "checking whether to use device-mapper... $ECHO_C" >&6; }
+# Check whether --enable-devmapper was given.
+if test "${enable_devmapper+set}" = set; then
+  enableval=$enable_devmapper; DEVMAPPER=$enableval
 fi
 
-rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
-      conftest$ac_exeext conftest.$ac_ext
-fi
-{ echo "$as_me:$LINENO: result: $ac_cv_func__doprnt" >&5
-echo "${ECHO_T}$ac_cv_func__doprnt" >&6; }
-if test $ac_cv_func__doprnt = yes; then
+{ echo "$as_me:$LINENO: result: $DEVMAPPER" >&5
+echo "${ECHO_T}$DEVMAPPER" >&6; }
+
+if test x$DEVMAPPER = xyes; then
 
 cat >>confdefs.h <<\_ACEOF
-#define HAVE_DOPRNT 1
+#define DEVMAPPER_SUPPORT 1
 _ACEOF
 
 fi
 
+################################################################################
+{ echo "$as_me:$LINENO: checking whether to enable O_DIRECT" >&5
+echo $ECHO_N "checking whether to enable O_DIRECT... $ECHO_C" >&6; }
+# Check whether --enable-o_direct was given.
+if test "${enable_o_direct+set}" = set; then
+  enableval=$enable_o_direct; ODIRECT=$enableval
 fi
-done
 
+{ echo "$as_me:$LINENO: result: $ODIRECT" >&5
+echo "${ECHO_T}$ODIRECT" >&6; }
 
+if test x$ODIRECT = xyes; then
 
+cat >>confdefs.h <<\_ACEOF
+#define O_DIRECT_SUPPORT 1
+_ACEOF
 
+fi
 
-for ac_func in mkdir rmdir uname
-do
-as_ac_var=`echo "ac_cv_func_$ac_func" | $as_tr_sh`
-{ echo "$as_me:$LINENO: checking for $ac_func" >&5
-echo $ECHO_N "checking for $ac_func... $ECHO_C" >&6; }
-if { as_var=$as_ac_var; eval "test \"\${$as_var+set}\" = set"; }; then
-  echo $ECHO_N "(cached) $ECHO_C" >&6
+################################################################################
+{ echo "$as_me:$LINENO: checking whether to compile liblvm2cmd.so" >&5
+echo $ECHO_N "checking whether to compile liblvm2cmd.so... $ECHO_C" >&6; }
+# Check whether --enable-cmdlib was given.
+if test "${enable_cmdlib+set}" = set; then
+  enableval=$enable_cmdlib; CMDLIB=$enableval
 else
-  cat >conftest.$ac_ext <<_ACEOF
-/* confdefs.h.  */
-_ACEOF
-cat confdefs.h >>conftest.$ac_ext
-cat >>conftest.$ac_ext <<_ACEOF
-/* end confdefs.h.  */
-/* Define $ac_func to an innocuous variant, in case <limits.h> declares $ac_func.
-   For example, HP-UX 11i <limits.h> declares gettimeofday.  */
-#define $ac_func innocuous_$ac_func
+  CMDLIB=no
+fi
 
-/* System header to define __stub macros and hopefully few prototypes,
-    which can conflict with char $ac_func (); below.
-    Prefer <limits.h> to <assert.h> if __STDC__ is defined, since
-    <limits.h> exists even on freestanding compilers.  */
+{ echo "$as_me:$LINENO: result: $CMDLIB" >&5
+echo "${ECHO_T}$CMDLIB" >&6; }
 
-#ifdef __STDC__
-# include <limits.h>
-#else
-# include <assert.h>
-#endif
+################################################################################
+{ echo "$as_me:$LINENO: checking whether to install fsadm" >&5
+echo $ECHO_N "checking whether to install fsadm... $ECHO_C" >&6; }
+# Check whether --enable-fsadm was given.
+if test "${enable_fsadm+set}" = set; then
+  enableval=$enable_fsadm; FSADM=$enableval
+fi
 
-#undef $ac_func
+{ echo "$as_me:$LINENO: result: $FSADM" >&5
+echo "${ECHO_T}$FSADM" >&6; }
 
-/* Override any GCC internal prototype to avoid an error.
-   Use char because int might match the return type of a GCC
-   builtin and then its argument prototype would still apply.  */
-#ifdef __cplusplus
-extern "C"
-#endif
-char $ac_func ();
-/* The GNU C library defines this for functions which it implements
-    to always fail with ENOSYS.  Some functions are actually named
-    something starting with __ and the normal name is an alias.  */
-#if defined __stub_$ac_func || defined __stub___$ac_func
-choke me
-#endif
+################################################################################
+{ echo "$as_me:$LINENO: checking whether to use dmeventd" >&5
+echo $ECHO_N "checking whether to use dmeventd... $ECHO_C" >&6; }
+# Check whether --enable-dmeventd was given.
+if test "${enable_dmeventd+set}" = set; then
+  enableval=$enable_dmeventd; DMEVENTD=$enableval
+fi
 
-int
-main ()
-{
-return $ac_func ();
-  ;
-  return 0;
-}
-_ACEOF
-rm -f conftest.$ac_objext conftest$ac_exeext
-if { (ac_try="$ac_link"
-case "(($ac_try" in
-  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
-  *) ac_try_echo=$ac_try;;
-esac
-eval "echo \"\$as_me:$LINENO: $ac_try_echo\"") >&5
-  (eval "$ac_link") 2>conftest.er1
-  ac_status=$?
-  grep -v '^ *+' conftest.er1 >conftest.err
-  rm -f conftest.er1
-  cat conftest.err >&5
-  echo "$as_me:$LINENO: \$? = $ac_status" >&5
-  (exit $ac_status); } && {
-	 test -z "$ac_c_werror_flag" ||
-	 test ! -s conftest.err
-       } && test -s conftest$ac_exeext &&
-       $as_test_x conftest$ac_exeext; then
-  eval "$as_ac_var=yes"
-else
-  echo "$as_me: failed program was:" >&5
-sed 's/^/| /' conftest.$ac_ext >&5
+{ echo "$as_me:$LINENO: result: $DMEVENTD" >&5
+echo "${ECHO_T}$DMEVENTD" >&6; }
 
-	eval "$as_ac_var=no"
+if test x$DMEVENTD = xyes && test x$MIRRORS != xinternal; then
+{ { echo "$as_me:$LINENO: error: --enable-dmeventd currently requires --with-mirrors=internal
+" >&5
+echo "$as_me: error: --enable-dmeventd currently requires --with-mirrors=internal
+" >&2;}
+   { (exit 1); exit 1; }; }
 fi
 
-rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
-      conftest$ac_exeext conftest.$ac_ext
-fi
-ac_res=`eval echo '${'$as_ac_var'}'`
-	       { echo "$as_me:$LINENO: result: $ac_res" >&5
-echo "${ECHO_T}$ac_res" >&6; }
-if test `eval echo '${'$as_ac_var'}'` = yes; then
-  cat >>confdefs.h <<_ACEOF
-#define `echo "HAVE_$ac_func" | $as_tr_cpp` 1
+if test x$DMEVENTD = xyes; then
+
+cat >>confdefs.h <<\_ACEOF
+#define DMEVENTD 1
 _ACEOF
 
-else
-  { { echo "$as_me:$LINENO: error: bailing out" >&5
-echo "$as_me: error: bailing out" >&2;}
-   { (exit 1); exit 1; }; }
 fi
-done
-
+################################################################################
+if [ "x$exec_prefix" = xNONE -a "x$prefix" = xNONE ];
+ then  exec_prefix="";
+fi;
 
 ################################################################################
 if test x$READLINE = xyes; then
@@ -8701,6 +8833,30 @@
 fi
 
 ################################################################################
+{ echo "$as_me:$LINENO: checking whether to use static linking" >&5
+echo $ECHO_N "checking whether to use static linking... $ECHO_C" >&6; }
+# Check whether --enable-static_link was given.
+if test "${enable_static_link+set}" = set; then
+  enableval=$enable_static_link; STATIC_LINK=$enableval
+else
+  STATIC_LINK=no
+fi
+
+{ echo "$as_me:$LINENO: result: $STATIC_LINK" >&5
+echo "${ECHO_T}$STATIC_LINK" >&6; }
+
+################################################################################
+{ echo "$as_me:$LINENO: checking whether to enable selinux support" >&5
+echo $ECHO_N "checking whether to enable selinux support... $ECHO_C" >&6; }
+# Check whether --enable-selinux was given.
+if test "${enable_selinux+set}" = set; then
+  enableval=$enable_selinux; SELINUX=$enableval
+fi
+
+{ echo "$as_me:$LINENO: result: $SELINUX" >&5
+echo "${ECHO_T}$SELINUX" >&6; }
+
+################################################################################
 if test x$SELINUX = xyes; then
 	{ echo "$as_me:$LINENO: checking for sepol_check_context in -lsepol" >&5
 echo $ECHO_N "checking for sepol_check_context in -lsepol... $ECHO_C" >&6; }
@@ -8771,6 +8927,11 @@
 
 
 	if test x$HAVE_SEPOL = xyes; then
+
+cat >>confdefs.h <<\_ACEOF
+#define HAVE_SEPOL 1
+_ACEOF
+
 		LIBS="-lsepol $LIBS"
 	fi
 
@@ -8854,7 +9015,7 @@
 echo "$as_me: WARNING: Disabling selinux" >&2;}
 	fi
 
-	# With --enable-static_link and selinux enabled, linking lvm.static
+	# With --enable-static_link and selinux enabled, linking
 	# fails on at least Debian unstable due to unsatisfied references
 	# to pthread_mutex_lock and _unlock.  See if we need -lpthread.
 	if test "$STATIC_LINK-$HAVE_SELINUX" = yes-yes; then
@@ -9955,7 +10116,7 @@
   ac_cv_func_getmntent=yes
 
 cat >>confdefs.h <<\_ACEOF
-#define HAVE_GETMNTENT
+#define HAVE_GETMNTENT 1
 _ACEOF
 
 else
@@ -11078,11 +11239,7 @@
 fi
 
 ################################################################################
-if test "-f VERSION"; then
-  LVM_VERSION="\"`cat VERSION`\""
-else
-  LVM_VERSION="Unknown"
-fi
+LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
 
 ################################################################################
 
@@ -11099,6 +11256,8 @@
 
 
 
+# FIXME: rename to LVM_USE_DMEVENTD
+
 
 
 
@@ -11119,6 +11278,13 @@
 
 
 
+# FIXME: rename to LVM_CONF_DIR
+
+
+
+
+
+
 
 
 
@@ -11126,7 +11292,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile dmeventd/Makefile dmeventd/mirror/Makefile dmeventd/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile test/Makefile man/Makefile po/Makefile scripts/Makefile tools/Makefile tools/version.h"
+ac_config_files="$ac_config_files Makefile make.tmpl include/Makefile lib/Makefile man/Makefile po/Makefile dmeventd/Makefile daemons/Makefile daemons/clvmd/Makefile dmeventd/mirror/Makefile dmeventd/snapshot/Makefile doc/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile test/Makefile scripts/Makefile tools/Makefile tools/version.h"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -11684,22 +11850,22 @@
     "lib/misc/configure.h") CONFIG_HEADERS="$CONFIG_HEADERS lib/misc/configure.h" ;;
     "Makefile") CONFIG_FILES="$CONFIG_FILES Makefile" ;;
     "make.tmpl") CONFIG_FILES="$CONFIG_FILES make.tmpl" ;;
+    "include/Makefile") CONFIG_FILES="$CONFIG_FILES include/Makefile" ;;
+    "lib/Makefile") CONFIG_FILES="$CONFIG_FILES lib/Makefile" ;;
+    "man/Makefile") CONFIG_FILES="$CONFIG_FILES man/Makefile" ;;
+    "po/Makefile") CONFIG_FILES="$CONFIG_FILES po/Makefile" ;;
+    "dmeventd/Makefile") CONFIG_FILES="$CONFIG_FILES dmeventd/Makefile" ;;
     "daemons/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/Makefile" ;;
     "daemons/clvmd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/clvmd/Makefile" ;;
-    "dmeventd/Makefile") CONFIG_FILES="$CONFIG_FILES dmeventd/Makefile" ;;
     "dmeventd/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES dmeventd/mirror/Makefile" ;;
-    "dmeventd/snapshot/Makefile" ) CONFIG_FILES="$CONFIG_FILES dmeventd/snapshot/Makefile" ;;
+    "dmeventd/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES dmeventd/snapshot/Makefile" ;;
     "doc/Makefile") CONFIG_FILES="$CONFIG_FILES doc/Makefile" ;;
-    "include/Makefile") CONFIG_FILES="$CONFIG_FILES include/Makefile" ;;
-    "lib/Makefile") CONFIG_FILES="$CONFIG_FILES lib/Makefile" ;;
     "lib/format1/Makefile") CONFIG_FILES="$CONFIG_FILES lib/format1/Makefile" ;;
     "lib/format_pool/Makefile") CONFIG_FILES="$CONFIG_FILES lib/format_pool/Makefile" ;;
     "lib/locking/Makefile") CONFIG_FILES="$CONFIG_FILES lib/locking/Makefile" ;;
     "lib/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES lib/mirror/Makefile" ;;
     "lib/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES lib/snapshot/Makefile" ;;
     "test/Makefile") CONFIG_FILES="$CONFIG_FILES test/Makefile" ;;
-    "man/Makefile") CONFIG_FILES="$CONFIG_FILES man/Makefile" ;;
-    "po/Makefile") CONFIG_FILES="$CONFIG_FILES po/Makefile" ;;
     "scripts/Makefile") CONFIG_FILES="$CONFIG_FILES scripts/Makefile" ;;
     "tools/Makefile") CONFIG_FILES="$CONFIG_FILES tools/Makefile" ;;
     "tools/version.h") CONFIG_FILES="$CONFIG_FILES tools/version.h" ;;
@@ -11821,6 +11987,9 @@
 ac_ct_CC!$ac_ct_CC$ac_delim
 EXEEXT!$EXEEXT$ac_delim
 OBJEXT!$OBJEXT$ac_delim
+CPP!$CPP$ac_delim
+GREP!$GREP$ac_delim
+EGREP!$EGREP$ac_delim
 INSTALL_PROGRAM!$INSTALL_PROGRAM$ac_delim
 INSTALL_SCRIPT!$INSTALL_SCRIPT$ac_delim
 INSTALL_DATA!$INSTALL_DATA$ac_delim
@@ -11829,38 +11998,35 @@
 RANLIB!$RANLIB$ac_delim
 CFLOW_CMD!$CFLOW_CMD$ac_delim
 CSCOPE_CMD!$CSCOPE_CMD$ac_delim
-CPP!$CPP$ac_delim
-GREP!$GREP$ac_delim
-EGREP!$EGREP$ac_delim
 ALLOCA!$ALLOCA$ac_delim
 LIBOBJS!$LIBOBJS$ac_delim
 POW_LIB!$POW_LIB$ac_delim
 MSGFMT!$MSGFMT$ac_delim
 MODPROBE_CMD!$MODPROBE_CMD$ac_delim
-JOBS!$JOBS$ac_delim
-STATIC_LINK!$STATIC_LINK$ac_delim
-LVM1!$LVM1$ac_delim
-POOL!$POOL$ac_delim
-SNAPSHOTS!$SNAPSHOTS$ac_delim
-MIRRORS!$MIRRORS$ac_delim
-OWNER!$OWNER$ac_delim
-GROUP!$GROUP$ac_delim
-COPTIMISE_FLAG!$COPTIMISE_FLAG$ac_delim
+BUILD_DMEVENTD!$BUILD_DMEVENTD$ac_delim
 CLDFLAGS!$CLDFLAGS$ac_delim
-CLDWHOLEARCHIVE!$CLDWHOLEARCHIVE$ac_delim
 CLDNOWHOLEARCHIVE!$CLDNOWHOLEARCHIVE$ac_delim
-LDDEPS!$LDDEPS$ac_delim
-LIB_SUFFIX!$LIB_SUFFIX$ac_delim
-LVM_VERSION!$LVM_VERSION$ac_delim
-LVM1_FALLBACK!$LVM1_FALLBACK$ac_delim
+CLDWHOLEARCHIVE!$CLDWHOLEARCHIVE$ac_delim
+CLUSTER!$CLUSTER$ac_delim
+CLVMD!$CLVMD$ac_delim
+CMDLIB!$CMDLIB$ac_delim
+COPTIMISE_FLAG!$COPTIMISE_FLAG$ac_delim
 DEBUG!$DEBUG$ac_delim
 DEVMAPPER!$DEVMAPPER$ac_delim
+DMDIR!$DMDIR$ac_delim
+DMEVENTD!$DMEVENTD$ac_delim
+DM_COMPAT!$DM_COMPAT$ac_delim
+DM_DEVICE_GID!$DM_DEVICE_GID$ac_delim
+DM_DEVICE_MODE!$DM_DEVICE_MODE$ac_delim
+DM_DEVICE_UID!$DM_DEVICE_UID$ac_delim
+DM_IOCTLS!$DM_IOCTLS$ac_delim
+DM_LIB_VERSION!$DM_LIB_VERSION$ac_delim
+FSADM!$FSADM$ac_delim
+GROUP!$GROUP$ac_delim
 HAVE_LIBDL!$HAVE_LIBDL$ac_delim
-HAVE_SELINUX!$HAVE_SELINUX$ac_delim
 HAVE_REALTIME!$HAVE_REALTIME$ac_delim
-CMDLIB!$CMDLIB$ac_delim
-LOCALEDIR!$LOCALEDIR$ac_delim
-CONFDIR!$CONFDIR$ac_delim
+HAVE_SELINUX!$HAVE_SELINUX$ac_delim
+INTL!$INTL$ac_delim
 _ACEOF
 
   if test `sed -n "s/.*$ac_delim\$/X/p" conf$$subs.sed | grep -c X` = 97; then
@@ -11902,19 +12068,27 @@
 ac_delim='%!_!# '
 for ac_last_try in false false false false false :; do
   cat >conf$$subs.sed <<_ACEOF
-STATICDIR!$STATICDIR$ac_delim
-DMDIR!$DMDIR$ac_delim
 INTL_PACKAGE!$INTL_PACKAGE$ac_delim
-INTL!$INTL$ac_delim
-CLVMD!$CLVMD$ac_delim
-CLUSTER!$CLUSTER$ac_delim
-FSADM!$FSADM$ac_delim
-DMEVENTD!$DMEVENTD$ac_delim
+JOBS!$JOBS$ac_delim
+LDDEPS!$LDDEPS$ac_delim
+LIB_SUFFIX!$LIB_SUFFIX$ac_delim
+LOCALEDIR!$LOCALEDIR$ac_delim
+LVM1!$LVM1$ac_delim
+LVM1_FALLBACK!$LVM1_FALLBACK$ac_delim
+CONFDIR!$CONFDIR$ac_delim
+LVM_VERSION!$LVM_VERSION$ac_delim
+MIRRORS!$MIRRORS$ac_delim
+OWNER!$OWNER$ac_delim
+PKGCONFIG!$PKGCONFIG$ac_delim
+POOL!$POOL$ac_delim
+SNAPSHOTS!$SNAPSHOTS$ac_delim
+STATICDIR!$STATICDIR$ac_delim
+STATIC_LINK!$STATIC_LINK$ac_delim
 LIB_PTHREAD!$LIB_PTHREAD$ac_delim
 LTLIBOBJS!$LTLIBOBJS$ac_delim
 _ACEOF
 
-  if test `sed -n "s/.*$ac_delim\$/X/p" conf$$subs.sed | grep -c X` = 10; then
+  if test `sed -n "s/.*$ac_delim\$/X/p" conf$$subs.sed | grep -c X` = 18; then
     break
   elif $ac_last_try; then
     { { echo "$as_me:$LINENO: error: could not make $CONFIG_STATUS" >&5
--- LVM2/configure.in	2008/05/19 20:06:33	1.68
+++ LVM2/configure.in	2008/06/13 14:37:17	1.69
@@ -1,8 +1,6 @@
-##
+###############################################################################
 ## Copyright (C) 2000-2004 Sistina Software, Inc. All rights reserved.
-## Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
-##
-## This file is part of LVM2.
+## Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
 ##
 ## This copyrighted material is made available to anyone wishing to use,
 ## modify, copy, or redistribute it subject to the terms and conditions
@@ -18,9 +16,7 @@
 dnl -- Process this file with autoconf to produce a configure script.
 AC_INIT
 AC_CONFIG_SRCDIR([lib/device/dev-cache.h])
-
-################################################################################
-AC_CONFIG_HEADERS(lib/misc/configure.h)
+AC_CONFIG_HEADERS([lib/misc/configure.h])
 
 ################################################################################
 dnl -- Setup the directory where autoconf has auxilary files
@@ -32,41 +28,45 @@
 
 case "$host_os" in
 	linux*)
-		CFLAGS="$CFLAGS"
 		COPTIMISE_FLAG="-O2"
 		CLDFLAGS="$CLDFLAGS -Wl,--version-script,.export.sym"
 		CLDWHOLEARCHIVE="-Wl,-whole-archive"
 		CLDNOWHOLEARCHIVE="-Wl,-no-whole-archive"
 		LDDEPS="$LDDEPS .export.sym"
 		LDFLAGS="$LDFLAGS -Wl,--export-dynamic"
-		LIB_SUFFIX="so"
+		LIB_SUFFIX=so
 		DEVMAPPER=yes
 		ODIRECT=yes
+		DM_IOCTLS=yes
 		SELINUX=yes
 		REALTIME=yes
 		CLUSTER=internal
-		FSADM=no ;;
+		FSADM=no
+		;;
 	darwin*)
 		CFLAGS="$CFLAGS -no-cpp-precomp -fno-common"
 		COPTIMISE_FLAG="-O2"
 		CLDFLAGS="$CLDFLAGS"
 		CLDWHOLEARCHIVE="-all_load"
 		CLDNOWHOLEARCHIVE=
-		LDDEPS="$LDDEPS"
-		LDFLAGS="$LDFLAGS"
-		LIB_SUFFIX="dylib"
+		LIB_SUFFIX=dylib
 		DEVMAPPER=yes
 		ODIRECT=no
+		DM_IOCTLS=no
 		SELINUX=no
 		REALTIME=no
 		CLUSTER=none
-		FSADM=no ;;
+		FSADM=no
+		;;
 esac
 
 ################################################################################
 dnl -- Checks for programs.
 AC_PROG_AWK
 AC_PROG_CC
+
+dnl probably no longer needed in 2008, but...
+AC_PROG_GCC_TRADITIONAL
 AC_PROG_INSTALL
 AC_PROG_LN_S
 AC_PROG_MAKE_SET
@@ -75,14 +75,15 @@
 AC_PATH_PROG(CSCOPE_CMD, cscope)
 
 ################################################################################
-dnl -- Checks for header files.
+dnl -- Check for header files.
 AC_HEADER_DIRENT
 AC_HEADER_STDC
 AC_HEADER_SYS_WAIT
 AC_HEADER_TIME
 
-AC_CHECK_HEADERS(fcntl.h limits.h locale.h stddef.h syslog.h sys/file.h sys/ioctl.h sys/param.h sys/time.h,,AC_MSG_ERROR(bailing out))
-AC_CHECK_HEADERS(assert.h ctype.h libgen.h signal.h stdio.h sys/mman.h sys/resource.h sys/stat.h sys/types.h sys/utsname.h sys/wait.h time.h,,AC_MSG_ERROR(bailing out))
+AC_CHECK_HEADERS([locale.h stddef.h syslog.h sys/file.h sys/time.h assert.h \
+  libgen.h signal.h sys/mman.h sys/resource.h sys/utsname.h sys/wait.h time.h], ,
+  [AC_MSG_ERROR(bailing out)])
 
 case "$host_os" in
 	linux*)
@@ -91,12 +92,19 @@
 		AC_CHECK_HEADERS(machine/endian.h sys/disk.h,,AC_MSG_ERROR(bailing out)) ;;
 esac
 
+AC_CHECK_HEADERS([ctype.h dirent.h errno.h fcntl.h getopt.h inttypes.h limits.h \
+  stdarg.h stdio.h stdlib.h string.h sys/ioctl.h sys/param.h sys/stat.h \
+  sys/types.h unistd.h], , [AC_MSG_ERROR(bailing out)])
+AC_CHECK_HEADERS(termios.h sys/statvfs.h)
+
 ################################################################################
-dnl -- Checks for typedefs, structures, and compiler characteristics.
+dnl -- Check for typedefs, structures, and compiler characteristics.
 AC_C_CONST
 AC_C_INLINE
+AC_CHECK_MEMBERS([struct stat.st_rdev])
 AC_TYPE_OFF_T
 AC_TYPE_PID_T
+AC_TYPE_SIGNAL
 AC_TYPE_SIZE_T
 AC_TYPE_MODE_T
 AC_CHECK_MEMBERS([struct stat.st_rdev])
@@ -104,7 +112,9 @@
 
 ################################################################################
 dnl -- Check for functions
-AC_CHECK_FUNCS(gethostname getpagesize memset munmap setlocale strcasecmp strchr strdup strncasecmp strerror strrchr strstr strtol strtoul,,AC_MSG_ERROR(bailing out))
+AC_CHECK_FUNCS([gethostname getpagesize memset mkdir rmdir munmap setlocale \
+  strcasecmp strchr strdup strncasecmp strerror strrchr strstr strtol strtoul \
+  uname], , [AC_MSG_ERROR(bailing out)])
 AC_FUNC_ALLOCA
 AC_FUNC_CLOSEDIR_VOID
 AC_FUNC_FORK
@@ -114,22 +124,19 @@
 AC_FUNC_MMAP
 AC_FUNC_STAT
 AC_FUNC_STRTOD
+AC_FUNC_VPRINTF
 
 ################################################################################
 dnl -- Prefix is /usr by default, the exec_prefix default is setup later
 AC_PREFIX_DEFAULT(/usr)
 
 ################################################################################
-dnl -- Parallel make jobs?
-AC_ARG_ENABLE(jobs, [  --enable-jobs=NUM       Number of jobs to run simultaneously], JOBS=-j$enableval, JOBS=-j2)
-
-################################################################################
 dnl -- Setup the ownership of the files
 AC_MSG_CHECKING(file owner)
 OWNER="root"
 
 AC_ARG_WITH(user,
-  [  --with-user=USER        Set the owner of installed files ],
+  [  --with-user=USER        Set the owner of installed files [[USER=root]] ],
   [ OWNER="$withval" ])
 AC_MSG_RESULT($OWNER)
 
@@ -142,7 +149,7 @@
 AC_MSG_CHECKING(group owner)
 GROUP="root"
 AC_ARG_WITH(group,
-  [  --with-group=GROUP      Set the group owner of installed files ],
+  [  --with-group=GROUP      Set the group owner of installed files [[GROUP=root]] ],
   [ GROUP="$withval" ])
 AC_MSG_RESULT($GROUP)
 
@@ -261,13 +268,6 @@
 fi
 
 ################################################################################
-dnl -- Enables staticly-linked tools
-AC_MSG_CHECKING(whether to use static linking)
-AC_ARG_ENABLE(static_link, [  --enable-static_link    Use this to link the tools to their libraries
-                          statically.  Default is dynamic linking],  STATIC_LINK=$enableval, STATIC_LINK=no)
-AC_MSG_RESULT($STATIC_LINK)
-
-################################################################################
 dnl -- Enable readline
 AC_MSG_CHECKING(whether to enable readline)
 AC_ARG_ENABLE(readline, [  --enable-readline       Enable readline support],
@@ -279,13 +279,6 @@
 fi
 
 ################################################################################
-dnl -- Disable selinux
-AC_MSG_CHECKING(whether to enable selinux support)
-AC_ARG_ENABLE(selinux, [  --disable-selinux       Disable selinux support],
-SELINUX=$enableval)
-AC_MSG_RESULT($SELINUX)
-
-################################################################################
 dnl -- Disable realtime clock support
 AC_MSG_CHECKING(whether to enable realtime support)
 AC_ARG_ENABLE(realtime, [  --disable-realtime      Disable realtime clock support],
@@ -314,7 +307,7 @@
 dnl -- Enable debugging
 AC_MSG_CHECKING(whether to enable debugging)
 AC_ARG_ENABLE(debug,    [  --enable-debug          Enable debugging],
-DEBUG=$enableval, DEBUG=no)
+  DEBUG=$enableval, DEBUG=no)
 AC_MSG_RESULT($DEBUG)
 
 dnl -- Normally turn off optimisation for debug builds
@@ -328,7 +321,7 @@
 dnl -- Override optimisation
 AC_MSG_CHECKING(for C optimisation flag)
 AC_ARG_WITH(optimisation,
-  [  --with-optimisation=OPT C optimisation flag [OPT=-O2] ],
+  [  --with-optimisation=OPT C optimisation flag [[OPT=-O2]] ],
   [ COPTIMISE_FLAG="$withval" ])
 AC_MSG_RESULT($COPTIMISE_FLAG)
 
@@ -386,19 +379,12 @@
 	AC_DEFINE([DMEVENTD], 1, [Define to 1 to enable the device-mapper event daemon.])
 fi
 ################################################################################
-dnl -- Mess with default exec_prefix
+dnl -- Clear default exec_prefix - install into /sbin rather than /usr/sbin
 if [[ "x$exec_prefix" = xNONE -a "x$prefix" = xNONE ]];
  then  exec_prefix="";
 fi;
 
 ################################################################################
-dnl -- Checks for library functions.
-AC_PROG_GCC_TRADITIONAL
-AC_TYPE_SIGNAL
-AC_FUNC_VPRINTF
-AC_CHECK_FUNCS(mkdir rmdir uname,,AC_MSG_ERROR(bailing out))
-
-################################################################################
 dnl -- Check for termcap (Shamelessly copied from parted 1.4.17)
 if test x$READLINE = xyes; then
 	AC_SEARCH_LIBS(tgetent, ncurses curses termcap termlib, ,
@@ -437,11 +423,29 @@
 fi
 
 ################################################################################
+dnl -- Enables statically-linked tools
+AC_MSG_CHECKING(whether to use static linking)
+AC_ARG_ENABLE(static_link,
+  [  --enable-static_link    Use this to link the tools to their libraries
+                          statically.  Default is dynamic linking],
+  STATIC_LINK=$enableval, STATIC_LINK=no)
+AC_MSG_RESULT($STATIC_LINK)
+
+################################################################################
+dnl -- Disable selinux
+AC_MSG_CHECKING(whether to enable selinux support)
+AC_ARG_ENABLE(selinux, [  --disable-selinux       Disable selinux support],
+  SELINUX=$enableval)
+AC_MSG_RESULT($SELINUX)
+
+################################################################################
 dnl -- Check for selinux
 if test x$SELINUX = xyes; then
 	AC_CHECK_LIB(sepol, sepol_check_context, HAVE_SEPOL=yes, HAVE_SEPOL=no)
 
 	if test x$HAVE_SEPOL = xyes; then
+		AC_DEFINE([HAVE_SEPOL], 1,
+		  [Define to 1 if sepol_check_context is available.])
 		LIBS="-lsepol $LIBS"
 	fi
 
@@ -454,7 +458,7 @@
 		AC_MSG_WARN(Disabling selinux)
 	fi
 
-	# With --enable-static_link and selinux enabled, linking lvm.static
+	# With --enable-static_link and selinux enabled, linking
 	# fails on at least Debian unstable due to unsatisfied references
 	# to pthread_mutex_lock and _unlock.  See if we need -lpthread.
 	if test "$STATIC_LINK-$HAVE_SELINUX" = yes-yes; then
@@ -482,7 +486,7 @@
 
 ################################################################################
 dnl -- Check for getopt
-AC_CHECK_HEADERS(getopt.h, AC_DEFINE([HAVE_GETOPTLONG], 1, [Define to 1 to if getopt_long is available.]))
+AC_CHECK_HEADERS(getopt.h, AC_DEFINE([HAVE_GETOPTLONG], 1, [Define to 1 if getopt_long is available.]))
 
 ################################################################################
 dnl -- Check for readline (Shamelessly copied from parted 1.4.17)
@@ -517,25 +521,25 @@
 	fi;
 
 	AC_ARG_WITH(localedir,
-  		    [  --with-localedir=DIR    Translation files in DIR [PREFIX/share/locale]],
-  		    [ LOCALEDIR="$withval" ],
-  		    [ LOCALEDIR='${prefix}/share/locale' ])
+		    [  --with-localedir=DIR    Translation files in DIR [[PREFIX/share/locale]] ],
+		    [ LOCALEDIR="$withval" ],
+		    [ LOCALEDIR='${prefix}/share/locale' ])
 fi
 
 ################################################################################
 AC_ARG_WITH(confdir,
 	    [  --with-confdir=DIR      Configuration files in DIR [/etc]],
-  	    [ CONFDIR="$withval" ],
- 	    [ CONFDIR='/etc' ])
+	    [ CONFDIR="$withval" ],
+	    [ CONFDIR='/etc' ])
 
 AC_ARG_WITH(staticdir,
 	    [  --with-staticdir=DIR    Static binary in DIR [EXEC_PREFIX/sbin]],
-  	    [ STATICDIR="$withval" ],
- 	    [ STATICDIR='${exec_prefix}/sbin' ])
+	    [ STATICDIR="$withval" ],
+	    [ STATICDIR='${exec_prefix}/sbin' ])
 
 AC_ARG_WITH(dmdir,
 	    [  --with-dmdir=DIR        Build against device-mapper source tree in DIR],
-  	    [ DMDIR="$withval" CPPFLAGS="$CPPFLAGS -I$DMDIR/include"],
+	    [ DMDIR="$withval" CPPFLAGS="$CPPFLAGS -I$DMDIR/include"],
 	    [ DMDIR= ])
 
 # Convert a relative dir name to absolute.
@@ -585,51 +589,56 @@
 fi
 
 ################################################################################
-if test "-f VERSION"; then
-  LVM_VERSION="\"`cat VERSION`\""
-else
-  LVM_VERSION="Unknown"
-fi
+LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
 
 ################################################################################
-AC_SUBST(JOBS)
-AC_SUBST(STATIC_LINK)
-AC_SUBST(LVM1)
-AC_SUBST(POOL)
-AC_SUBST(SNAPSHOTS)
-AC_SUBST(MIRRORS)
-AC_SUBST(OWNER)
-AC_SUBST(GROUP)
+AC_SUBST(BUILD_DMEVENTD)
 AC_SUBST(CFLAGS)
-AC_SUBST(COPTIMISE_FLAG)
+AC_SUBST(CFLOW_CMD)
 AC_SUBST(CLDFLAGS)
-AC_SUBST(CLDWHOLEARCHIVE)
 AC_SUBST(CLDNOWHOLEARCHIVE)
-AC_SUBST(LDDEPS)
-AC_SUBST(LDFLAGS)
-AC_SUBST(LIB_SUFFIX)
-AC_SUBST(LIBS)
-AC_SUBST(LVM_VERSION)
-AC_SUBST(LVM1_FALLBACK)
+AC_SUBST(CLDWHOLEARCHIVE)
+AC_SUBST(CLUSTER)
+AC_SUBST(CLVMD)
+AC_SUBST(CMDLIB)
+AC_SUBST(COPTIMISE_FLAG)
+AC_SUBST(CSCOPE_CMD)
 AC_SUBST(DEBUG)
 AC_SUBST(DEVMAPPER)
+AC_SUBST(DMDIR)
+# FIXME: rename to LVM_USE_DMEVENTD
+AC_SUBST(DMEVENTD)
+AC_SUBST(DM_COMPAT)
+AC_SUBST(DM_DEVICE_GID)
+AC_SUBST(DM_DEVICE_MODE)
+AC_SUBST(DM_DEVICE_UID)
+AC_SUBST(DM_IOCTLS)
+AC_SUBST(DM_LIB_VERSION)
+AC_SUBST(FSADM)
+AC_SUBST(GROUP)
 AC_SUBST(HAVE_LIBDL)
-AC_SUBST(HAVE_SELINUX)
 AC_SUBST(HAVE_REALTIME)
-AC_SUBST(CMDLIB)
-AC_SUBST(MSGFMT)
+AC_SUBST(HAVE_SELINUX)
+AC_SUBST(INTL)
+AC_SUBST(INTL_PACKAGE)
+AC_SUBST(JOBS)
+AC_SUBST(LDDEPS)
+AC_SUBST(LIBS)
+AC_SUBST(LIB_SUFFIX)
 AC_SUBST(LOCALEDIR)
+AC_SUBST(LVM1)
+AC_SUBST(LVM1_FALLBACK)
+# FIXME: rename to LVM_CONF_DIR
 AC_SUBST(CONFDIR)
+AC_SUBST(LVM_VERSION)
+AC_SUBST(MIRRORS)
+AC_SUBST(MSGFMT)
+AC_SUBST(OWNER)
+AC_SUBST(PKGCONFIG)
+AC_SUBST(POOL)
+AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)
-AC_SUBST(DMDIR)
-AC_SUBST(INTL_PACKAGE)
-AC_SUBST(INTL)
-AC_SUBST(CLVMD)
-AC_SUBST(CLUSTER)
-AC_SUBST(FSADM)
-AC_SUBST(DMEVENTD)
-AC_SUBST(CFLOW_CMD)
-AC_SUBST(CSCOPE_CMD)
+AC_SUBST(STATIC_LINK)
 AC_SUBST([LIB_PTHREAD])
 
 ################################################################################
@@ -638,22 +647,22 @@
 AC_CONFIG_FILES([
 Makefile
 make.tmpl
+include/Makefile
+lib/Makefile
+man/Makefile
+po/Makefile
+dmeventd/Makefile
 daemons/Makefile
 daemons/clvmd/Makefile
-dmeventd/Makefile
 dmeventd/mirror/Makefile
 dmeventd/snapshot/Makefile
 doc/Makefile
-include/Makefile
-lib/Makefile
 lib/format1/Makefile
 lib/format_pool/Makefile
 lib/locking/Makefile
 lib/mirror/Makefile
 lib/snapshot/Makefile
 test/Makefile
-man/Makefile
-po/Makefile
 scripts/Makefile
 tools/Makefile
 tools/version.h
--- LVM2/lib/misc/configure.h.in	2007/12/17 12:23:23	1.4
+++ LVM2/lib/misc/configure.h.in	2008/06/13 14:37:18	1.5
@@ -36,8 +36,7 @@
 /* Define to 1 if you have the <ctype.h> header file. */
 #undef HAVE_CTYPE_H
 
-/* Define to 1 if you have the <dirent.h> header file, and it defines `DIR'.
-   */
+/* Define to 1 if you have the <dirent.h> header file. */
 #undef HAVE_DIRENT_H
 
 /* Define to 1 if you have the <dlfcn.h> header file. */
@@ -49,6 +48,9 @@
 /* Define to 1 if you have the `dup2' function. */
 #undef HAVE_DUP2
 
+/* Define to 1 if you have the <errno.h> header file. */
+#undef HAVE_ERRNO_H
+
 /* Define to 1 if you have the <fcntl.h> header file. */
 #undef HAVE_FCNTL_H
 
@@ -61,7 +63,7 @@
 /* Define to 1 if you have the `getmntent' function. */
 #undef HAVE_GETMNTENT
 
-/* Define to 1 to if getopt_long is available. */
+/* Define to 1 if getopt_long is available. */
 #undef HAVE_GETOPTLONG
 
 /* Define to 1 if you have the <getopt.h> header file. */
@@ -171,6 +173,9 @@
 /* Define to 1 if you have the <selinux/selinux.h> header file. */
 #undef HAVE_SELINUX_SELINUX_H
 
+/* Define to 1 if sepol_check_context is available. */
+#undef HAVE_SEPOL
+
 /* Define to 1 if you have the `setlocale' function. */
 #undef HAVE_SETLOCALE
 
@@ -184,6 +189,9 @@
    zero-length file name argument. */
 #undef HAVE_STAT_EMPTY_STRING_BUG
 
+/* Define to 1 if you have the <stdarg.h> header file. */
+#undef HAVE_STDARG_H
+
 /* Define to 1 if you have the <stddef.h> header file. */
 #undef HAVE_STDDEF_H
 
@@ -270,6 +278,9 @@
 /* Define to 1 if you have the <sys/socket.h> header file. */
 #undef HAVE_SYS_SOCKET_H
 
+/* Define to 1 if you have the <sys/statvfs.h> header file. */
+#undef HAVE_SYS_STATVFS_H
+
 /* Define to 1 if you have the <sys/stat.h> header file. */
 #undef HAVE_SYS_STAT_H
 
@@ -291,6 +302,9 @@
 /* Define to 1 if you have the <sys/wait.h> header file. */
 #undef HAVE_SYS_WAIT_H
 
+/* Define to 1 if you have the <termios.h> header file. */
+#undef HAVE_TERMIOS_H
+
 /* Define to 1 if you have the <time.h> header file. */
 #undef HAVE_TIME_H
 


