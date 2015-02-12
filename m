From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 12 Feb 2015 14:49:09 +0000 (UTC)
Subject: master - autoreconf: recent changes
Message-ID: <20150212144909.7B47C60F2D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=acb6c062078fbfd5ccd5aa92fbfd8db081b39b19
Commit:        acb6c062078fbfd5ccd5aa92fbfd8db081b39b19
Parent:        77ceb3ee471075ce55f723a2efffb4465510ea88
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 12 15:48:12 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Feb 12 15:48:12 2015 +0100

autoreconf: recent changes

autoconf-2.69-14.fc20.noarch
automake-1.13.4-6.fc20.noarch
---
 configure |  326 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 319 insertions(+), 7 deletions(-)

diff --git a/configure b/configure
index 9d1d32f..3187473 100755
--- a/configure
+++ b/configure
@@ -639,6 +639,7 @@ CLVMD_PIDFILE
 LVMETAD_PIDFILE
 DMEVENTD_PIDFILE
 WRITE_INSTALL
+VALGRIND_POOL
 UDEV_HAS_BUILTIN_BLKID
 UDEV_RULE_EXEC_DETECTION
 UDEV_SYSTEMD_BACKGROUND_JOBS
@@ -681,6 +682,7 @@ LDDEPS
 JOBS
 INTL_PACKAGE
 INTL
+HAVE_VALGRIND
 HAVE_REALTIME
 HAVE_LIBDL
 BLKDEACTIVATE
@@ -740,7 +742,6 @@ SYSTEMD_LIBS
 SYSTEMD_CFLAGS
 BLKID_LIBS
 BLKID_CFLAGS
-VALGRIND_POOL
 VALGRIND_LIBS
 VALGRIND_CFLAGS
 CUNIT_LIBS
@@ -798,6 +799,9 @@ INSTALL_PROGRAM
 EGREP
 GREP
 CPP
+ac_ct_CXX
+CXXFLAGS
+CXX
 OBJEXT
 EXEEXT
 ac_ct_CC
@@ -956,6 +960,9 @@ CFLAGS
 LDFLAGS
 LIBS
 CPPFLAGS
+CXX
+CXXFLAGS
+CCC
 CPP
 PKG_CONFIG
 PKG_CONFIG_PATH
@@ -1751,6 +1758,8 @@ Some influential environment variables:
   LIBS        libraries to pass to the linker, e.g. -l<library>
   CPPFLAGS    (Objective) C/C++ preprocessor flags, e.g. -I<include dir> if
               you have headers in a nonstandard directory <include dir>
+  CXX         C++ compiler command
+  CXXFLAGS    C++ compiler flags
   CPP         C preprocessor
   PKG_CONFIG  path to pkg-config utility
   PKG_CONFIG_PATH
@@ -1920,6 +1929,44 @@ fi
 
 } # ac_fn_c_try_compile
 
+# ac_fn_cxx_try_compile LINENO
+# ----------------------------
+# Try to compile conftest.$ac_ext, and return whether this succeeded.
+ac_fn_cxx_try_compile ()
+{
+  as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
+  rm -f conftest.$ac_objext
+  if { { ac_try="$ac_compile"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:${as_lineno-$LINENO}: $ac_try_echo\""
+$as_echo "$ac_try_echo"; } >&5
+  (eval "$ac_compile") 2>conftest.err
+  ac_status=$?
+  if test -s conftest.err; then
+    grep -v '^ *+' conftest.err >conftest.er1
+    cat conftest.er1 >&5
+    mv -f conftest.er1 conftest.err
+  fi
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; } && {
+	 test -z "$ac_cxx_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest.$ac_objext; then :
+  ac_retval=0
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_retval=1
+fi
+  eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
+  as_fn_set_status $ac_retval
+
+} # ac_fn_cxx_try_compile
+
 # ac_fn_c_try_cpp LINENO
 # ----------------------
 # Try to preprocess conftest.$ac_ext, and return whether this succeeded.
@@ -3911,6 +3958,263 @@ ac_compile='$CC -c $CFLAGS $CPPFLAGS conftest.$ac_ext >&5'
 ac_link='$CC -o conftest$ac_exeext $CFLAGS $CPPFLAGS $LDFLAGS conftest.$ac_ext $LIBS >&5'
 ac_compiler_gnu=$ac_cv_c_compiler_gnu
 
+ac_ext=cpp
+ac_cpp='$CXXCPP $CPPFLAGS'
+ac_compile='$CXX -c $CXXFLAGS $CPPFLAGS conftest.$ac_ext >&5'
+ac_link='$CXX -o conftest$ac_exeext $CXXFLAGS $CPPFLAGS $LDFLAGS conftest.$ac_ext $LIBS >&5'
+ac_compiler_gnu=$ac_cv_cxx_compiler_gnu
+if test -z "$CXX"; then
+  if test -n "$CCC"; then
+    CXX=$CCC
+  else
+    if test -n "$ac_tool_prefix"; then
+  for ac_prog in g++ c++ gpp aCC CC cxx cc++ cl.exe FCC KCC RCC xlC_r xlC
+  do
+    # Extract the first word of "$ac_tool_prefix$ac_prog", so it can be a program name with args.
+set dummy $ac_tool_prefix$ac_prog; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_prog_CXX+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  if test -n "$CXX"; then
+  ac_cv_prog_CXX="$CXX" # Let the user override the test.
+else
+as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_prog_CXX="$ac_tool_prefix$ac_prog"
+    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
+
+fi
+fi
+CXX=$ac_cv_prog_CXX
+if test -n "$CXX"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CXX" >&5
+$as_echo "$CXX" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+    test -n "$CXX" && break
+  done
+fi
+if test -z "$CXX"; then
+  ac_ct_CXX=$CXX
+  for ac_prog in g++ c++ gpp aCC CC cxx cc++ cl.exe FCC KCC RCC xlC_r xlC
+do
+  # Extract the first word of "$ac_prog", so it can be a program name with args.
+set dummy $ac_prog; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_prog_ac_ct_CXX+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  if test -n "$ac_ct_CXX"; then
+  ac_cv_prog_ac_ct_CXX="$ac_ct_CXX" # Let the user override the test.
+else
+as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_prog_ac_ct_CXX="$ac_prog"
+    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
+
+fi
+fi
+ac_ct_CXX=$ac_cv_prog_ac_ct_CXX
+if test -n "$ac_ct_CXX"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_ct_CXX" >&5
+$as_echo "$ac_ct_CXX" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+  test -n "$ac_ct_CXX" && break
+done
+
+  if test "x$ac_ct_CXX" = x; then
+    CXX="g++"
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    CXX=$ac_ct_CXX
+  fi
+fi
+
+  fi
+fi
+# Provide some information about the compiler.
+$as_echo "$as_me:${as_lineno-$LINENO}: checking for C++ compiler version" >&5
+set X $ac_compile
+ac_compiler=$2
+for ac_option in --version -v -V -qversion; do
+  { { ac_try="$ac_compiler $ac_option >&5"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:${as_lineno-$LINENO}: $ac_try_echo\""
+$as_echo "$ac_try_echo"; } >&5
+  (eval "$ac_compiler $ac_option >&5") 2>conftest.err
+  ac_status=$?
+  if test -s conftest.err; then
+    sed '10a\
+... rest of stderr output deleted ...
+         10q' conftest.err >conftest.er1
+    cat conftest.er1 >&5
+  fi
+  rm -f conftest.er1 conftest.err
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }
+done
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether we are using the GNU C++ compiler" >&5
+$as_echo_n "checking whether we are using the GNU C++ compiler... " >&6; }
+if ${ac_cv_cxx_compiler_gnu+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+
+int
+main ()
+{
+#ifndef __GNUC__
+       choke me
+#endif
+
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_cxx_try_compile "$LINENO"; then :
+  ac_compiler_gnu=yes
+else
+  ac_compiler_gnu=no
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+ac_cv_cxx_compiler_gnu=$ac_compiler_gnu
+
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_cxx_compiler_gnu" >&5
+$as_echo "$ac_cv_cxx_compiler_gnu" >&6; }
+if test $ac_compiler_gnu = yes; then
+  GXX=yes
+else
+  GXX=
+fi
+ac_test_CXXFLAGS=${CXXFLAGS+set}
+ac_save_CXXFLAGS=$CXXFLAGS
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $CXX accepts -g" >&5
+$as_echo_n "checking whether $CXX accepts -g... " >&6; }
+if ${ac_cv_prog_cxx_g+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  ac_save_cxx_werror_flag=$ac_cxx_werror_flag
+   ac_cxx_werror_flag=yes
+   ac_cv_prog_cxx_g=no
+   CXXFLAGS="-g"
+   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+
+int
+main ()
+{
+
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_cxx_try_compile "$LINENO"; then :
+  ac_cv_prog_cxx_g=yes
+else
+  CXXFLAGS=""
+      cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+
+int
+main ()
+{
+
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_cxx_try_compile "$LINENO"; then :
+
+else
+  ac_cxx_werror_flag=$ac_save_cxx_werror_flag
+	 CXXFLAGS="-g"
+	 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+
+int
+main ()
+{
+
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_cxx_try_compile "$LINENO"; then :
+  ac_cv_prog_cxx_g=yes
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+   ac_cxx_werror_flag=$ac_save_cxx_werror_flag
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_prog_cxx_g" >&5
+$as_echo "$ac_cv_prog_cxx_g" >&6; }
+if test "$ac_test_CXXFLAGS" = set; then
+  CXXFLAGS=$ac_save_CXXFLAGS
+elif test $ac_cv_prog_cxx_g = yes; then
+  if test "$GXX" = yes; then
+    CXXFLAGS="-g -O2"
+  else
+    CXXFLAGS="-g"
+  fi
+else
+  if test "$GXX" = yes; then
+    CXXFLAGS="-O2"
+  else
+    CXXFLAGS=
+  fi
+fi
+ac_ext=c
+ac_cpp='$CPP $CPPFLAGS'
+ac_compile='$CC -c $CFLAGS $CPPFLAGS conftest.$ac_ext >&5'
+ac_link='$CC -o conftest$ac_exeext $CFLAGS $CPPFLAGS $LDFLAGS conftest.$ac_ext $LIBS >&5'
+ac_compiler_gnu=$ac_cv_c_compiler_gnu
+
 
 
 ac_ext=c
@@ -10370,8 +10674,7 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $VALGRIND_POOL" >&5
 $as_echo "$VALGRIND_POOL" >&6; }
 
-if test "$VALGRIND_POOL" = yes; then
-	pkg_config_init
+pkg_config_init
 
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for VALGRIND" >&5
@@ -10431,22 +10734,29 @@ fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$VALGRIND_PKG_ERRORS" >&5
 
-	as_fn_error $? "bailing out" "$LINENO" 5
+	if test x$VALGRIND_POOL = xyes; then as_fn_error $? "bailing out" "$LINENO" 5; fi
 elif test $pkg_failed = untried; then
      	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
 $as_echo "no" >&6; }
-	as_fn_error $? "bailing out" "$LINENO" 5
+	if test x$VALGRIND_POOL = xyes; then as_fn_error $? "bailing out" "$LINENO" 5; fi
 else
 	VALGRIND_CFLAGS=$pkg_cv_VALGRIND_CFLAGS
 	VALGRIND_LIBS=$pkg_cv_VALGRIND_LIBS
         { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 $as_echo "yes" >&6; }
-
+	HAVE_VALGRIND=yes
 fi
 
-$as_echo "#define VALGRIND_POOL 1" >>confdefs.h
 
+if test x$HAVE_VALGRIND = xyes; then
 
+$as_echo "#define HAVE_VALGRIND 1" >>confdefs.h
+
+fi
+
+if test x$VALGRIND_POOL = xyes; then
+
+$as_echo "#define VALGRIND_POOL 1" >>confdefs.h
 
 fi
 
@@ -12751,6 +13061,8 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile
  python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 


