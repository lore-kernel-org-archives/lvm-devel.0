From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Jul 2009 11:51:24 -0000
Subject: LVM2 configure
Message-ID: <20090731115124.23620.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-31 11:51:23

Modified files:
	.              : configure 

Log message:
	add not-yet-working udev options

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.98&r2=1.99

--- LVM2/configure	2009/07/30 12:31:45	1.98
+++ LVM2/configure	2009/07/31 11:51:23	1.99
@@ -639,12 +639,15 @@
 ac_subst_vars='LTLIBOBJS
 usrsbindir
 usrlibdir
+udevdir
+udev_prefix
 tmpdir
 kernelvsn
 missingkernel
 kerneldir
 interface
 LIB_PTHREAD
+UDEV_RULES
 STATIC_LINK
 STATICDIR
 SNAPSHOTS
@@ -800,6 +803,8 @@
 with_optimisation
 enable_profiling
 enable_devmapper
+enable_udev_sync
+enable_udev_rules
 enable_compat
 enable_ioctl
 enable_o_direct
@@ -815,6 +820,7 @@
 with_staticdir
 with_usrlibdir
 with_usrsbindir
+with_udev_prefix
 with_dmeventd_pidfile
 with_dmeventd_path
 with_interface
@@ -1468,6 +1474,8 @@
   --enable-debug          Enable debugging
   --enable-profiling      Gather gcov profiling data
   --disable-devmapper     Disable LVM2 device-mapper interaction
+  --enable-udev_sync      Enable synchronisation with udev processing
+  --enable-udev_rules     Install rule files needed for udev synchronisation
   --enable-compat         Enable support for old device-mapper versions
   --disable-driver        Disable calls to device-mapper in the kernel
   --disable-o_direct      Disable O_DIRECT
@@ -1501,12 +1509,13 @@
                           TYPE=none
   --with-optimisation=OPT C optimisation flag [OPT=-O2]
   --with-localedir=DIR    Translation files in DIR [PREFIX/share/locale]
-  --with-confdir=DIR      Configuration files in DIR /etc
-  --with-staticdir=DIR    Static binary in DIR EXEC_PREFIX/sbin
+  --with-confdir=DIR      Configuration files in DIR [/etc]
+  --with-staticdir=DIR    Static binary in DIR [EPREFIX/sbin]
   --with-usrlibdir=DIR
   --with-usrsbindir=DIR
+  --with-udev-prefix=UPREFIX      Install udev rule files in UPREFIX [EPREFIX]
   --with-dmeventd-pidfile=PATH    dmeventd pidfile [/var/run/dmeventd.pid]
-  --with-dmeventd-path=PATH       dmeventd path [${exec_prefix}/sbin/dmeventd]
+  --with-dmeventd-path=PATH       dmeventd path [EPREFIX/sbin/dmeventd]
   --with-interface=IFACE  Choose kernel interface (ioctl) [ioctl]
 
 Some influential environment variables:
@@ -9677,6 +9686,39 @@
 fi
 
 ################################################################################
+{ $as_echo "$as_me:$LINENO: checking whether to enable synchronisation with udev processing" >&5
+$as_echo_n "checking whether to enable synchronisation with udev processing... " >&6; }
+# Check whether --enable-udev_sync was given.
+if test "${enable_udev_sync+set}" = set; then
+  enableval=$enable_udev_sync; UDEV_SYNC=$enableval
+else
+  UDEV_SYNC=no
+fi
+
+{ $as_echo "$as_me:$LINENO: result: $UDEV_SYNC" >&5
+$as_echo "$UDEV_SYNC" >&6; }
+
+if test x$UDEV_SYNC = xyes; then
+
+cat >>confdefs.h <<\_ACEOF
+#define UDEV_SYNC_SUPPORT 1
+_ACEOF
+
+fi
+
+{ $as_echo "$as_me:$LINENO: checking whether to enable installation of udev rules required for synchronisation" >&5
+$as_echo_n "checking whether to enable installation of udev rules required for synchronisation... " >&6; }
+# Check whether --enable-udev_rules was given.
+if test "${enable_udev_rules+set}" = set; then
+  enableval=$enable_udev_rules; UDEV_RULES=$enableval
+else
+  UDEV_RULES=$UDEV_SYNC
+fi
+
+{ $as_echo "$as_me:$LINENO: result: $UDEV_RULES" >&5
+$as_echo "$UDEV_RULES" >&6; }
+
+################################################################################
 # Check whether --enable-compat was given.
 if test "${enable_compat+set}" = set; then
   enableval=$enable_compat; DM_COMPAT=$enableval
@@ -11001,6 +11043,18 @@
 
 
 ################################################################################
+
+# Check whether --with-udev_prefix was given.
+if test "${with_udev_prefix+set}" = set; then
+  withval=$with_udev_prefix;  udev_prefix="$withval"
+else
+   udev_prefix='${exec_prefix}'
+fi
+
+
+udevdir='${udev_prefix}/lib/udev/rules.d'
+
+################################################################################
 if test x$READLINE = xyes; then
 
 
@@ -12478,6 +12532,160 @@
 
 fi
 
+if test x$UDEV_SYNC = xyes; then
+
+
+for ac_header in sys/ipc.h sys/sem.h
+do
+as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  { $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
+fi
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+else
+  # Is the header compilable?
+{ $as_echo "$as_me:$LINENO: checking $ac_header usability" >&5
+$as_echo_n "checking $ac_header usability... " >&6; }
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+$ac_includes_default
+#include <$ac_header>
+_ACEOF
+rm -f conftest.$ac_objext
+if { (ac_try="$ac_compile"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_compile") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest.$ac_objext; then
+  ac_header_compiler=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_header_compiler=no
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+{ $as_echo "$as_me:$LINENO: result: $ac_header_compiler" >&5
+$as_echo "$ac_header_compiler" >&6; }
+
+# Is the header present?
+{ $as_echo "$as_me:$LINENO: checking $ac_header presence" >&5
+$as_echo_n "checking $ac_header presence... " >&6; }
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
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_cpp conftest.$ac_ext") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } >/dev/null && {
+	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       }; then
+  ac_header_preproc=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+  ac_header_preproc=no
+fi
+
+rm -f conftest.err conftest.$ac_ext
+{ $as_echo "$as_me:$LINENO: result: $ac_header_preproc" >&5
+$as_echo "$ac_header_preproc" >&6; }
+
+# So?  What about this header?
+case $ac_header_compiler:$ac_header_preproc:$ac_c_preproc_warn_flag in
+  yes:no: )
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&5
+$as_echo "$as_me: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the compiler's result" >&5
+$as_echo "$as_me: WARNING: $ac_header: proceeding with the compiler's result" >&2;}
+    ac_header_preproc=yes
+    ;;
+  no:yes:* )
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: present but cannot be compiled" >&5
+$as_echo "$as_me: WARNING: $ac_header: present but cannot be compiled" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     check for missing prerequisite headers?" >&5
+$as_echo "$as_me: WARNING: $ac_header:     check for missing prerequisite headers?" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: see the Autoconf documentation" >&5
+$as_echo "$as_me: WARNING: $ac_header: see the Autoconf documentation" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&5
+$as_echo "$as_me: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the preprocessor's result" >&5
+$as_echo "$as_me: WARNING: $ac_header: proceeding with the preprocessor's result" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: in the future, the compiler will take precedence" >&5
+$as_echo "$as_me: WARNING: $ac_header: in the future, the compiler will take precedence" >&2;}
+
+    ;;
+esac
+{ $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
+else
+  eval "$as_ac_Header=\$ac_header_preproc"
+fi
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+
+fi
+as_val=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+   if test "x$as_val" = x""yes; then
+  cat >>confdefs.h <<_ACEOF
+#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
+_ACEOF
+
+else
+  { { $as_echo "$as_me:$LINENO: error: bailing out" >&5
+$as_echo "$as_me: error: bailing out" >&2;}
+   { (exit 1); exit 1; }; }
+fi
+
+done
+
+fi
+
 ################################################################################
 # Extract the first word of "modprobe", so it can be a program name with args.
 set dummy modprobe; ac_word=$2
@@ -12684,8 +12892,11 @@
 
 
 
+
+
+
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -13313,6 +13524,7 @@
     "test/Makefile") CONFIG_FILES="$CONFIG_FILES test/Makefile" ;;
     "test/api/Makefile") CONFIG_FILES="$CONFIG_FILES test/api/Makefile" ;;
     "tools/Makefile") CONFIG_FILES="$CONFIG_FILES tools/Makefile" ;;
+    "udev/Makefile") CONFIG_FILES="$CONFIG_FILES udev/Makefile" ;;
 
   *) { { $as_echo "$as_me:$LINENO: error: invalid argument: $ac_config_target" >&5
 $as_echo "$as_me: error: invalid argument: $ac_config_target" >&2;}


