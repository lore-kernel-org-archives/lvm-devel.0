From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Mar 2012 02:00:01 -0000
Subject: LVM2 ./WHATS_NEW_DM ./configure ./configure.in ...
Message-ID: <20120324020001.7519.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-03-24 02:00:00

Modified files:
	.              : WHATS_NEW_DM configure configure.in 
	lib/misc       : configure.h.in 
Added files:
	veritysetup    : Makefile.in veritysetup.c 

Log message:
	First veritysetup version using configure --with-veritysetup.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.596&r2=1.597
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.177&r2=1.178
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.192&r2=1.193
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/veritysetup/Makefile.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/veritysetup/veritysetup.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/WHATS_NEW_DM	2012/03/20 17:38:47	1.596
+++ LVM2/WHATS_NEW_DM	2012/03/24 01:59:59	1.597
@@ -1,5 +1,6 @@
 Version 1.02.75 - 
 ================================
+  Add configure --with-veritysetup for independent veritysetup tool.
   Properly support passed in dmevent path in dm_event_register_handler().
   Remove dmeventd fifos on exit if they are not managed by systemd.
   Use SD_ACTIVATION env. var. in systemd units to better detect systemd in use.
--- LVM2/configure	2012/03/14 19:25:04	1.177
+++ LVM2/configure	2012/03/24 01:59:59	1.178
@@ -682,6 +682,13 @@
 APPLIB
 MODPROBE_CMD
 MSGFMT
+VERITYSETUP
+VERITYSETUP_LIBS
+VERITYSETUP_CFLAGS
+NSS_LIBS
+NSS_CFLAGS
+OPENSSL_LIBS
+OPENSSL_CFLAGS
 LVM2CMD_LIB
 LVM2APP_LIB
 UDEV_LIBS
@@ -837,6 +844,7 @@
 enable_write_install
 enable_fsadm
 enable_dmeventd
+with_veritysetup
 enable_selinux
 enable_nls
 with_localedir
@@ -894,7 +902,11 @@
 CUNIT_CFLAGS
 CUNIT_LIBS
 UDEV_CFLAGS
-UDEV_LIBS'
+UDEV_LIBS
+OPENSSL_CFLAGS
+OPENSSL_LIBS
+NSS_CFLAGS
+NSS_LIBS'
 
 
 # Initialize some variables set by options.
@@ -1584,6 +1596,7 @@
   --with-cmirrord-pidfile=PATH
                           cmirrord pidfile [[/var/run/cmirrord.pid]]
   --with-optimisation=OPT C optimisation flag [[OPT=-O2]]
+  --with-veritysetup=TYPE build veritysetup using openssl/nss/gcrypt
   --with-localedir=DIR    translation files in DIR [[PREFIX/share/locale]]
   --with-confdir=DIR      configuration files in DIR [[/etc]]
   --with-staticdir=DIR    static binaries in DIR [[EPREFIX/sbin]]
@@ -1663,6 +1676,12 @@
   CUNIT_LIBS  linker flags for CUNIT, overriding pkg-config
   UDEV_CFLAGS C compiler flags for UDEV, overriding pkg-config
   UDEV_LIBS   linker flags for UDEV, overriding pkg-config
+  OPENSSL_CFLAGS
+              C compiler flags for OPENSSL, overriding pkg-config
+  OPENSSL_LIBS
+              linker flags for OPENSSL, overriding pkg-config
+  NSS_CFLAGS  C compiler flags for NSS, overriding pkg-config
+  NSS_LIBS    linker flags for NSS, overriding pkg-config
 
 Use these variables to override the choices made by `configure' or to help
 it to find libraries and programs with nonstandard names/locations.
@@ -2867,6 +2886,8 @@
 		;;
 esac
 
+VERITYSETUP=no
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for a sed that does not truncate output" >&5
 $as_echo_n "checking for a sed that does not truncate output... " >&6; }
@@ -9090,6 +9111,407 @@
 fi
 
 ################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to install veritysetup" >&5
+$as_echo_n "checking whether to install veritysetup... " >&6; }
+
+# Check whether --with-veritysetup was given.
+if test "${with_veritysetup+set}" = set; then :
+  withval=$with_veritysetup; VERITYSETUP=$withval
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $VERITYSETUP" >&5
+$as_echo "$VERITYSETUP" >&6; }
+
+if test x$VERITYSETUP != xno -a x$VERITYSETUP != x; then
+	if test x$PKGCONFIG_INIT != x1; then
+		pkg_config_init
+	fi
+
+		if test -z "$VERITYSETUP_CFLAGS" && test x$VERITYSETUP = xyes -o x$VERITYSETUP = xopenssl; then
+
+pkg_failed=no
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for OPENSSL" >&5
+$as_echo_n "checking for OPENSSL... " >&6; }
+
+if test -n "$OPENSSL_CFLAGS"; then
+    pkg_cv_OPENSSL_CFLAGS="$OPENSSL_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"openssl\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "openssl") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_OPENSSL_CFLAGS=`$PKG_CONFIG --cflags "openssl" 2>/dev/null`
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$OPENSSL_LIBS"; then
+    pkg_cv_OPENSSL_LIBS="$OPENSSL_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"openssl\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "openssl") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_OPENSSL_LIBS=`$PKG_CONFIG --libs "openssl" 2>/dev/null`
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+
+
+
+if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+
+if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
+        _pkg_short_errors_supported=yes
+else
+        _pkg_short_errors_supported=no
+fi
+        if test $_pkg_short_errors_supported = yes; then
+	        OPENSSL_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "openssl" 2>&1`
+        else
+	        OPENSSL_PKG_ERRORS=`$PKG_CONFIG --print-errors "openssl" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$OPENSSL_PKG_ERRORS" >&5
+
+
+			{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for EVP_get_digestbyname in -lcrypto" >&5
+$as_echo_n "checking for EVP_get_digestbyname in -lcrypto... " >&6; }
+if test "${ac_cv_lib_crypto_EVP_get_digestbyname+set}" = set; then :
+  $as_echo_n "(cached) " >&6
+else
+  ac_check_lib_save_LIBS=$LIBS
+LIBS="-lcrypto  $LIBS"
+cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+
+/* Override any GCC internal prototype to avoid an error.
+   Use char because int might match the return type of a GCC
+   builtin and then its argument prototype would still apply.  */
+#ifdef __cplusplus
+extern "C"
+#endif
+char EVP_get_digestbyname ();
+int
+main ()
+{
+return EVP_get_digestbyname ();
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_link "$LINENO"; then :
+  ac_cv_lib_crypto_EVP_get_digestbyname=yes
+else
+  ac_cv_lib_crypto_EVP_get_digestbyname=no
+fi
+rm -f core conftest.err conftest.$ac_objext \
+    conftest$ac_exeext conftest.$ac_ext
+LIBS=$ac_check_lib_save_LIBS
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_crypto_EVP_get_digestbyname" >&5
+$as_echo "$ac_cv_lib_crypto_EVP_get_digestbyname" >&6; }
+if test "x$ac_cv_lib_crypto_EVP_get_digestbyname" = x""yes; then :
+
+				ac_fn_c_check_header_mongrel "$LINENO" "openssl/evp.h" "ac_cv_header_openssl_evp_h" "$ac_includes_default"
+if test "x$ac_cv_header_openssl_evp_h" = x""yes; then :
+
+
+$as_echo "#define CRYPT_OPENSSL 1" >>confdefs.h
+
+					VERITYSETUP_CFLAGS=
+					VERITYSETUP_LIBS="-lcrypto"
+
+fi
+
+
+
+fi
+
+
+elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+
+			{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for EVP_get_digestbyname in -lcrypto" >&5
+$as_echo_n "checking for EVP_get_digestbyname in -lcrypto... " >&6; }
+if test "${ac_cv_lib_crypto_EVP_get_digestbyname+set}" = set; then :
+  $as_echo_n "(cached) " >&6
+else
+  ac_check_lib_save_LIBS=$LIBS
+LIBS="-lcrypto  $LIBS"
+cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+
+/* Override any GCC internal prototype to avoid an error.
+   Use char because int might match the return type of a GCC
+   builtin and then its argument prototype would still apply.  */
+#ifdef __cplusplus
+extern "C"
+#endif
+char EVP_get_digestbyname ();
+int
+main ()
+{
+return EVP_get_digestbyname ();
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_link "$LINENO"; then :
+  ac_cv_lib_crypto_EVP_get_digestbyname=yes
+else
+  ac_cv_lib_crypto_EVP_get_digestbyname=no
+fi
+rm -f core conftest.err conftest.$ac_objext \
+    conftest$ac_exeext conftest.$ac_ext
+LIBS=$ac_check_lib_save_LIBS
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_crypto_EVP_get_digestbyname" >&5
+$as_echo "$ac_cv_lib_crypto_EVP_get_digestbyname" >&6; }
+if test "x$ac_cv_lib_crypto_EVP_get_digestbyname" = x""yes; then :
+
+				ac_fn_c_check_header_mongrel "$LINENO" "openssl/evp.h" "ac_cv_header_openssl_evp_h" "$ac_includes_default"
+if test "x$ac_cv_header_openssl_evp_h" = x""yes; then :
+
+
+$as_echo "#define CRYPT_OPENSSL 1" >>confdefs.h
+
+					VERITYSETUP_CFLAGS=
+					VERITYSETUP_LIBS="-lcrypto"
+
+fi
+
+
+
+fi
+
+
+else
+	OPENSSL_CFLAGS=$pkg_cv_OPENSSL_CFLAGS
+	OPENSSL_LIBS=$pkg_cv_OPENSSL_LIBS
+        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+
+
+$as_echo "#define CRYPT_OPENSSL 1" >>confdefs.h
+
+			VERITYSETUP_CFLAGS="$OPENSSL_CFLAGS"
+			VERITYSETUP_LIBS="`echo "$OPENSSL_LIBS" | sed 's/-lssl\>//'`"
+
+fi
+	fi
+
+		if test -z "$VERITYSETUP_CFLAGS" && test x$VERITYSETUP = xyes -o x$VERITYSETUP = xnss; then
+
+pkg_failed=no
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for NSS" >&5
+$as_echo_n "checking for NSS... " >&6; }
+
+if test -n "$NSS_CFLAGS"; then
+    pkg_cv_NSS_CFLAGS="$NSS_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"nss\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "nss") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_NSS_CFLAGS=`$PKG_CONFIG --cflags "nss" 2>/dev/null`
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$NSS_LIBS"; then
+    pkg_cv_NSS_LIBS="$NSS_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"nss\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "nss") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_NSS_LIBS=`$PKG_CONFIG --libs "nss" 2>/dev/null`
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+
+
+
+if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+
+if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
+        _pkg_short_errors_supported=yes
+else
+        _pkg_short_errors_supported=no
+fi
+        if test $_pkg_short_errors_supported = yes; then
+	        NSS_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "nss" 2>&1`
+        else
+	        NSS_PKG_ERRORS=`$PKG_CONFIG --print-errors "nss" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$NSS_PKG_ERRORS" >&5
+
+	true
+elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+	true
+else
+	NSS_CFLAGS=$pkg_cv_NSS_CFLAGS
+	NSS_LIBS=$pkg_cv_NSS_LIBS
+        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+
+
+$as_echo "#define CRYPT_NSS 1" >>confdefs.h
+
+			VERITYSETUP_CFLAGS="$NSS_CFLAGS"
+			VERITYSETUP_LIBS="`echo "$NSS_LIBS" | sed 's/-lsmime3\>//' | sed 's/-lssl3\>//'`"
+
+fi
+	fi
+
+		if test -z "$VERITYSETUP_CFLAGS" && test x$VERITYSETUP = xyes -o x$VERITYSETUP = xgcrypt; then
+		{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for gcry_md_map_name in -lgcrypt" >&5
+$as_echo_n "checking for gcry_md_map_name in -lgcrypt... " >&6; }
+if test "${ac_cv_lib_gcrypt_gcry_md_map_name+set}" = set; then :
+  $as_echo_n "(cached) " >&6
+else
+  ac_check_lib_save_LIBS=$LIBS
+LIBS="-lgcrypt  $LIBS"
+cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+
+/* Override any GCC internal prototype to avoid an error.
+   Use char because int might match the return type of a GCC
+   builtin and then its argument prototype would still apply.  */
+#ifdef __cplusplus
+extern "C"
+#endif
+char gcry_md_map_name ();
+int
+main ()
+{
+return gcry_md_map_name ();
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_link "$LINENO"; then :
+  ac_cv_lib_gcrypt_gcry_md_map_name=yes
+else
+  ac_cv_lib_gcrypt_gcry_md_map_name=no
+fi
+rm -f core conftest.err conftest.$ac_objext \
+    conftest$ac_exeext conftest.$ac_ext
+LIBS=$ac_check_lib_save_LIBS
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_gcrypt_gcry_md_map_name" >&5
+$as_echo "$ac_cv_lib_gcrypt_gcry_md_map_name" >&6; }
+if test "x$ac_cv_lib_gcrypt_gcry_md_map_name" = x""yes; then :
+
+			ac_fn_c_check_header_mongrel "$LINENO" "gcrypt.h" "ac_cv_header_gcrypt_h" "$ac_includes_default"
+if test "x$ac_cv_header_gcrypt_h" = x""yes; then :
+
+
+$as_echo "#define CRYPT_GCRYPT 1" >>confdefs.h
+
+				VERITYSETUP_CFLAGS=
+				VERITYSETUP_LIBS="-lgcrypt"
+
+fi
+
+
+
+fi
+
+	fi
+
+	if test -z "$VERITYSETUP_LIBS"; then
+		as_fn_error $? "No cryptographic library for veritysetup found" "$LINENO" 5
+	fi
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for poptGetContext in -lpopt" >&5
+$as_echo_n "checking for poptGetContext in -lpopt... " >&6; }
+if test "${ac_cv_lib_popt_poptGetContext+set}" = set; then :
+  $as_echo_n "(cached) " >&6
+else
+  ac_check_lib_save_LIBS=$LIBS
+LIBS="-lpopt  $LIBS"
+cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+
+/* Override any GCC internal prototype to avoid an error.
+   Use char because int might match the return type of a GCC
+   builtin and then its argument prototype would still apply.  */
+#ifdef __cplusplus
+extern "C"
+#endif
+char poptGetContext ();
+int
+main ()
+{
+return poptGetContext ();
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_link "$LINENO"; then :
+  ac_cv_lib_popt_poptGetContext=yes
+else
+  ac_cv_lib_popt_poptGetContext=no
+fi
+rm -f core conftest.err conftest.$ac_objext \
+    conftest$ac_exeext conftest.$ac_ext
+LIBS=$ac_check_lib_save_LIBS
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_popt_poptGetContext" >&5
+$as_echo "$ac_cv_lib_popt_poptGetContext" >&6; }
+if test "x$ac_cv_lib_popt_poptGetContext" = x""yes; then :
+  true
+else
+
+		as_fn_error $? "popt library was not found" "$LINENO" 5
+
+fi
+
+	ac_fn_c_check_header_mongrel "$LINENO" "popt.h" "ac_cv_header_popt_h" "$ac_includes_default"
+if test "x$ac_cv_header_popt_h" = x""yes; then :
+  true
+else
+
+		as_fn_error $? "popt.h was not found" "$LINENO" 5
+
+fi
+
+
+	VERITYSETUP_LIBS="$VERITYSETUP_LIBS -lpopt"
+
+
+	VERITYSETUP=yes
+fi
+
+
+################################################################################
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for getline in -lc" >&5
 $as_echo_n "checking for getline in -lc... " >&6; }
@@ -10491,7 +10913,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_!
 lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_!
 lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile veritysetup/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -11235,6 +11657,7 @@
     "unit-tests/datastruct/Makefile") CONFIG_FILES="$CONFIG_FILES unit-tests/datastruct/Makefile" ;;
     "unit-tests/regex/Makefile") CONFIG_FILES="$CONFIG_FILES unit-tests/regex/Makefile" ;;
     "unit-tests/mm/Makefile") CONFIG_FILES="$CONFIG_FILES unit-tests/mm/Makefile" ;;
+    "veritysetup/Makefile") CONFIG_FILES="$CONFIG_FILES veritysetup/Makefile" ;;
 
   *) as_fn_error $? "invalid argument: \`$ac_config_target'" "$LINENO" 5;;
   esac
--- LVM2/configure.in	2012/03/14 19:25:04	1.192
+++ LVM2/configure.in	2012/03/24 01:59:59	1.193
@@ -62,6 +62,8 @@
 		;;
 esac
 
+VERITYSETUP=no
+
 ################################################################################
 dnl -- Checks for programs.
 AC_PROG_SED
@@ -1030,6 +1032,71 @@
 fi
 
 ################################################################################
+dnl -- enable veritysetup
+AC_MSG_CHECKING(whether to install veritysetup)
+AC_ARG_WITH(veritysetup, AC_HELP_STRING([--with-veritysetup=TYPE], [build veritysetup using openssl/nss/gcrypt]),
+	      VERITYSETUP=$withval)
+AC_MSG_RESULT($VERITYSETUP)
+
+if test x$VERITYSETUP != xno -a x$VERITYSETUP != x; then
+	if test x$PKGCONFIG_INIT != x1; then
+		pkg_config_init
+	fi
+
+	dnl Test OPENSSL
+	if test -z "$VERITYSETUP_CFLAGS" && test x$VERITYSETUP = xyes -o x$VERITYSETUP = xopenssl; then
+		PKG_CHECK_MODULES(OPENSSL, openssl, [
+			AC_DEFINE([CRYPT_OPENSSL], 1, [Define to 1 if OpenSSL encryption is to be used.])
+			VERITYSETUP_CFLAGS="$OPENSSL_CFLAGS"
+			VERITYSETUP_LIBS="`echo "$OPENSSL_LIBS" | sed 's/-lssl\>//'`"
+		], [
+			AC_CHECK_LIB(crypto, EVP_get_digestbyname, [
+				AC_CHECK_HEADER(openssl/evp.h, [
+					AC_DEFINE([CRYPT_OPENSSL], 1, [Define to 1 if OpenSSL encryption is to be used.])
+					VERITYSETUP_CFLAGS=
+					VERITYSETUP_LIBS="-lcrypto"
+				])
+			])
+		])
+	fi
+
+	dnl Test NSS
+	if test -z "$VERITYSETUP_CFLAGS" && test x$VERITYSETUP = xyes -o x$VERITYSETUP = xnss; then
+		PKG_CHECK_MODULES(NSS, nss, [
+			AC_DEFINE([CRYPT_NSS], 1, [Define to 1 if nss encryption is to be used.])
+			VERITYSETUP_CFLAGS="$NSS_CFLAGS"
+			VERITYSETUP_LIBS="`echo "$NSS_LIBS" | sed 's/-lsmime3\>//' | sed 's/-lssl3\>//'`"
+		], true)
+	fi
+
+	dnl Test GCRYPT
+	if test -z "$VERITYSETUP_CFLAGS" && test x$VERITYSETUP = xyes -o x$VERITYSETUP = xgcrypt; then
+		AC_CHECK_LIB(gcrypt, gcry_md_map_name, [
+			AC_CHECK_HEADER(gcrypt.h, [
+				AC_DEFINE([CRYPT_GCRYPT], 1, [Define to 1 if gcrpyt encryption is to be used.])
+				VERITYSETUP_CFLAGS=
+				VERITYSETUP_LIBS="-lgcrypt"
+			])
+		])
+	fi
+
+	if test -z "$VERITYSETUP_LIBS"; then
+		AC_MSG_ERROR(No cryptographic library for veritysetup found)
+	fi
+	AC_CHECK_LIB(popt, poptGetContext, true, [
+		AC_MSG_ERROR(popt library was not found)
+	])
+	AC_CHECK_HEADER(popt.h, true, [
+		AC_MSG_ERROR(popt.h was not found)
+	])
+	VERITYSETUP_LIBS="$VERITYSETUP_LIBS -lpopt"
+	AC_SUBST(VERITYSETUP_CFLAGS)
+	AC_SUBST(VERITYSETUP_LIBS)
+	VERITYSETUP=yes
+fi
+AC_SUBST(VERITYSETUP)
+
+################################################################################
 dnl -- getline included in recent libc
 
 AC_CHECK_LIB(c, getline, AC_DEFINE([HAVE_GETLINE], 1,
@@ -1574,6 +1641,7 @@
 unit-tests/datastruct/Makefile
 unit-tests/regex/Makefile
 unit-tests/mm/Makefile
+veritysetup/Makefile
 ])
 AC_OUTPUT
 
--- LVM2/lib/misc/configure.h.in	2012/03/14 17:09:00	1.40
+++ LVM2/lib/misc/configure.h.in	2012/03/24 01:59:59	1.41
@@ -23,6 +23,15 @@
    */
 #undef CRAY_STACKSEG_END
 
+/* Define to 1 if gcrpyt encryption is to be used. */
+#undef CRYPT_GCRYPT
+
+/* Define to 1 if nss encryption is to be used. */
+#undef CRYPT_NSS
+
+/* Define to 1 if OpenSSL encryption is to be used. */
+#undef CRYPT_OPENSSL
+
 /* Define to 1 if using `alloca.c'. */
 #undef C_ALLOCA
 
/cvs/lvm2/LVM2/veritysetup/Makefile.in,v  -->  standard output
revision 1.1
--- LVM2/veritysetup/Makefile.in
+++ -	2012-03-24 02:00:00.975678000 +0000
@@ -0,0 +1,31 @@
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This file is part of the device-mapper userspace tools.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU Lesser General Public License v.2.1.
+#
+# You should have received a copy of the GNU Lesser General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+srcdir = @srcdir@
+top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
+
+SOURCES = veritysetup.c
+
+TARGETS = veritysetup
+
+INCLUDES += @VERITYSETUP_CFLAGS@
+
+include $(top_builddir)/make.tmpl
+
+VERITYSETUP_LIBS = @VERITYSETUP_LIBS@
+
+veritysetup: $(OBJECTS)
+	$(CC) $(CFLAGS) $(LDFLAGS) -o veritysetup $(OBJECTS) $(VERITYSETUP_LIBS)
+
+install: $(TARGETS)
+	$(INSTALL_PROGRAM) -D veritysetup $(sbindir)/veritysetup
/cvs/lvm2/LVM2/veritysetup/veritysetup.c,v  -->  standard output
revision 1.1
--- LVM2/veritysetup/veritysetup.c
+++ -	2012-03-24 02:00:01.171764000 +0000
@@ -0,0 +1,988 @@
+/*
+ * veritysetup
+ *
+ * (C) 2012 Red Hat Inc.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+/*
+ * Compile flags to use a specific crypto library:
+ * openssl: -lpopt -DCRYPT_OPENSSL -lcrypto
+ * nss: -lpopt -DCRYPT_NSS -I/usr/include/nspr/ -I/usr/include/nss -lnss3
+ * gcrypt: -lpopt -DCRYPT_GCRYPT -lgcrypt -lgpg-error
+ */
+
+#define _FILE_OFFSET_BITS	64
+
+#ifdef HAVE_CONFIG_H
+#  include "configure.h"
+#endif
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <stdint.h>
+#include <stdarg.h>
+#include <unistd.h>
+#include <errno.h>
+#include <string.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <sys/ioctl.h>
+#include <sys/mount.h>
+#include <arpa/inet.h>
+#include <popt.h>
+
+#ifdef CRYPT_OPENSSL
+#  include <openssl/evp.h>
+#  include <openssl/rand.h>
+#elif defined(CRYPT_GCRYPT)
+#  include <gcrypt.h>
+#elif defined(CRYPT_NSS)
+#  include <nss.h>
+#  include <sechash.h>
+#  include <pk11pub.h>
+#endif
+
+#if !defined(CRYPT_OPENSSL) && !defined(CRYPT_GCRYPT) && !defined(CRYPT_NSS)
+#error No crypto engine specified
+#endif
+
+#define DEFAULT_BLOCK_SIZE	4096
+#define DM_VERITY_MAX_LEVELS	63
+
+#define DEFAULT_SALT_SIZE	32
+#define MAX_SALT_SIZE		384
+
+#define MODE_VERIFY	0
+#define MODE_CREATE	1
+#define MODE_ACTIVATE	2
+
+#define MAX_FORMAT_VERSION	1
+
+static int mode = -1;
+static int use_superblock = 1;
+
+static const char *dm_device;
+static const char *data_device;
+static const char *hash_device;
+static const char *hash_algorithm = NULL;
+static const char *root_hash;
+
+static int version = -1;
+static int data_block_size = 0;
+static int hash_block_size = 0;
+static long long hash_start = 0;
+static long long data_blocks = 0;
+static const char *salt_string = NULL;
+static const char *hash_start_string = NULL;
+static const char *data_blocks_string = NULL;
+
+static FILE *data_file;
+static FILE *hash_file;
+
+static off_t data_file_blocks;
+static off_t hash_file_blocks;
+static off_t used_hash_blocks;
+
+static unsigned char *root_hash_bytes;
+static unsigned char *calculated_digest;
+
+static unsigned char *salt_bytes;
+static unsigned salt_size;
+
+static unsigned digest_size;
+static unsigned char digest_size_bits;
+static unsigned char levels;
+static unsigned char hash_per_block_bits;
+
+static off_t hash_level_block[DM_VERITY_MAX_LEVELS];
+static off_t hash_level_size[DM_VERITY_MAX_LEVELS];
+
+static off_t superblock_position;
+
+static int retval = 0;
+
+struct superblock {
+	uint8_t signature[8];
+	uint8_t version;
+	uint8_t data_block_bits;
+	uint8_t hash_block_bits;
+	uint8_t pad1[1];
+	uint16_t salt_size;
+	uint8_t pad2[2];
+	uint32_t data_blocks_hi;
+	uint32_t data_blocks_lo;
+	uint8_t algorithm[16];
+	uint8_t salt[MAX_SALT_SIZE];
+	uint8_t pad3[88];
+};
+
+#define DM_VERITY_SIGNATURE	"verity\0\0"
+#define DM_VERITY_VERSION	0
+
+__attribute__ ((noreturn))
+static void help(poptContext popt_context,
+		 enum poptCallbackReason reason,
+		 struct poptOption *key,
+		 const char *arg,
+		 void *data)
+{
+	if (!strcmp(key->longName, "help")) {
+		poptPrintHelp(popt_context, stdout, 0);
+	} else {
+		printf("veritysetup");
+#ifdef DM_LIB_VERSION
+		printf(", device mapper version %s", DM_LIB_VERSION);
+#endif
+		printf("\n");
+	}
+	exit(0);
+}
+
+static struct poptOption popt_help_options[] = {
+	{ NULL,			0,	POPT_ARG_CALLBACK, help, 0, NULL, NULL },
+	{ "help",		'h',	POPT_ARG_NONE, NULL, 0, "Show help", NULL },
+	{ "version",		0,	POPT_ARG_NONE, NULL, 0, "Show version", NULL },
+	POPT_TABLEEND
+};
+
+static struct poptOption popt_options[] = {
+	{ NULL,			'\0', POPT_ARG_INCLUDE_TABLE, popt_help_options, 0, NULL, NULL },
+	{ "create",		'c',	POPT_ARG_VAL, &mode, MODE_CREATE, "Create hash", NULL },
+	{ "verify",		'v',	POPT_ARG_VAL, &mode, MODE_VERIFY, "Verify integrity", NULL },
+	{ "activate",		'a',	POPT_ARG_VAL, &mode, MODE_ACTIVATE, "Activate the device", NULL },
+	{ "no-superblock",	0,	POPT_ARG_VAL, &use_superblock, 0, "Do not create/use superblock" },
+	{ "format",		0,	POPT_ARG_INT, &version, 0, "Format version (1 - normal format, 0 - original Chromium OS format)", "number" },
+	{ "data-block-size",	0, 	POPT_ARG_INT, &data_block_size, 0, "Block size on the data device", "bytes" },
+	{ "hash-block-size",	0, 	POPT_ARG_INT, &hash_block_size, 0, "Block size on the hash device", "bytes" },
+	{ "data-blocks",	0,	POPT_ARG_STRING, &data_blocks_string, 0, "The number of blocks in the data file", "blocks" },
+	{ "hash-start",		0,	POPT_ARG_STRING, &hash_start_string, 0, "Starting block on the hash device", "512-byte sectors" },
+	{ "algorithm",		0,	POPT_ARG_STRING, &hash_algorithm, 0, "Hash algorithm (default sha256)", "string" },
+	{ "salt",		0,	POPT_ARG_STRING, &salt_string, 0, "Salt", "hex string" },
+	POPT_TABLEEND
+};
+
+#if defined(__GNUC__) && __GNUC__ >= 2
+	__attribute__((__format__(__printf__, 1, 2)))
+#endif
+__attribute__((noreturn))
+static void exit_err(const char *msg, ...)
+{
+	va_list args;
+	va_start(args, msg);
+	vfprintf(stderr, msg, args);
+	va_end(args);
+	fputc('\n', stderr);
+	exit(2);
+}
+
+__attribute__((noreturn))
+static void stream_err(FILE *f, const char *msg)
+{
+	if (ferror(f)) {
+		perror(msg);
+		exit(2);
+	} else if (feof(f)) {
+		exit_err("eof on %s", msg);
+	} else {
+		exit_err("unknown error on %s", msg);
+	}
+}
+
+static void *xmalloc(size_t s)
+{
+	void *ptr = malloc(!s ? 1 : s);
+	if (!ptr) exit_err("out of memory");
+	return ptr;
+}
+
+static char *xstrdup(const char *str)
+{
+	return strcpy(xmalloc(strlen(str) + 1), str);
+}
+
+static char *xprint(unsigned long long num)
+{
+	size_t s = snprintf(NULL, 0, "%llu", num);
+	char *p = xmalloc(s + 1);
+	snprintf(p, s + 1, "%llu", num);
+	return p;
+}
+
+static char *xhexprint(unsigned char *bytes, size_t len)
+{
+	size_t i;
+	char *p = xmalloc(len * 2 + 1);
+	p[0] = 0;
+	for (i = 0; i < len; i++)
+		snprintf(p + i * 2, 3, "%02x", bytes[i]);
+	return p;
+}
+
+static off_t get_size(FILE *f, const char *name)
+{
+	struct stat st;
+	int h = fileno(f);
+	if (h < 0) {
+		perror("fileno");
+		exit(2);
+	}
+	if (fstat(h, &st)) {
+		perror("fstat");
+		exit(2);
+	}
+	if (S_ISREG(st.st_mode)) {
+		return st.st_size;
+	} else if (S_ISBLK(st.st_mode)) {
+		unsigned long long size64;
+		unsigned long sizeul;
+		if (!ioctl(h, BLKGETSIZE64, &size64)) {
+			return_size64:
+			if ((off_t)size64 < 0 || (off_t)size64 != size64) {
+				size_overflow:
+				exit_err("%s: device size overflow", name);
+			}
+			return size64;
+		}
+		if (!ioctl(h, BLKGETSIZE, &sizeul)) {
+			size64 = (unsigned long long)sizeul * 512;
+			if (size64 / 512 != sizeul) goto size_overflow;
+			goto return_size64;
+		}
+		perror("BLKGETSIZE");
+		exit(2);
+	} else {
+		exit_err("%s is not a file or a block device", name);
+	}
+	return -1;	/* never reached, shut up warning */
+}
+
+static void block_fseek(FILE *f, off_t block, int block_size)
+{
+	unsigned long long pos = (unsigned long long)block * block_size;
+	if (pos / block_size != block ||
+	    (off_t)pos < 0 ||
+	    (off_t)pos != pos)
+		exit_err("seek position overflow");
+	if (fseeko(f, pos, SEEK_SET)) {
+		perror("fseek");
+		exit(2);
+	}
+}
+
+
+#ifdef CRYPT_OPENSSL
+
+static const EVP_MD *evp;
+
+static int hash_init(const char *name)
+{
+	OpenSSL_add_all_digests();
+	evp = EVP_get_digestbyname(name);
+	if (!evp)
+		return 0;
+	return EVP_MD_size(evp);
+}
+
+typedef EVP_MD_CTX hash_context;
+
+static void hash_context_init(hash_context *ctx)
+{
+	EVP_MD_CTX_init(ctx);
+}
+
+static void hash_context_reset(hash_context *ctx)
+{
+	if (EVP_DigestInit_ex(ctx, evp, NULL) != 1)
+		exit_err("EVP_DigestInit_ex failed");
+}
+
+static void hash_context_update(hash_context *ctx, unsigned char *data, size_t len)
+{
+	if (EVP_DigestUpdate(ctx, data, len) != 1)
+		exit_err("EVP_DigestUpdate failed");
+}
+
+static void hash_context_final(hash_context *ctx, unsigned char *digest)
+{
+	if (EVP_DigestFinal_ex(ctx, digest, NULL) != 1)
+		exit_err("EVP_DigestFinal_ex failed");
+}
+
+static void hash_context_destroy(hash_context *ctx)
+{
+	if (EVP_MD_CTX_cleanup(ctx) != 1)
+		exit_err("EVP_MD_CTX_cleanup failed");
+}
+
+static void crypto_rand_bytes(unsigned char *data, size_t len)
+{
+	if (RAND_bytes(data, len) != 1)
+		exit_err("RAND_bytes failed");
+}
+
+#elif defined(CRYPT_GCRYPT)
+
+static int gcrypt_id;
+
+static int hash_init(const char *name)
+{
+	retry:
+	gcrypt_id = gcry_md_map_name(name);
+	if (!gcrypt_id) {
+		if (!strcmp(name, "wp512")) {
+			name = "whirlpool";
+			goto retry;
+		}
+		if (!strcmp(name, "rmd160")) {
+			name = "ripemd160";
+			goto retry;
+		}
+		return 0;
+	}
+	return gcry_md_get_algo_dlen(gcrypt_id);
+}
+
+typedef gcry_md_hd_t hash_context;
+
+static void hash_context_init(hash_context *ctx)
+{
+	if (gcry_md_open(ctx, gcrypt_id, 0))
+		exit_err("gcry_md_open failed");
+}
+
+static void hash_context_reset(hash_context *ctx)
+{
+	gcry_md_reset(*ctx);
+}
+
+static void hash_context_update(hash_context *ctx, unsigned char *data, size_t len)
+{
+	gcry_md_write(*ctx, data, len);
+}
+
+static void hash_context_final(hash_context *ctx, unsigned char *digest)
+{
+	unsigned char *p = gcry_md_read(*ctx, gcrypt_id);
+	memcpy(digest, p, gcry_md_get_algo_dlen(gcrypt_id));
+}
+
+static void hash_context_destroy(hash_context *ctx)
+{
+	gcry_md_close(*ctx);
+}
+
+static void crypto_rand_bytes(unsigned char *data, size_t len)
+{
+	gcry_randomize(data, len, GCRY_STRONG_RANDOM);
+}
+
+#elif defined(CRYPT_NSS)
+
+static HASH_HashType nss_alg;
+
+static int hash_init(const char *name)
+{
+	if (NSS_NoDB_Init(NULL) != SECSuccess)
+		exit_err("NSS_Init failed");
+	if (!strcmp(name, "md2"))
+		nss_alg = HASH_AlgMD2;
+	else if (!strcmp(name, "md5"))
+		nss_alg = HASH_AlgMD5;
+	else if (!strcmp(name, "sha1"))
+		nss_alg = HASH_AlgSHA1;
+	else if (!strcmp(name, "sha256"))
+		nss_alg = HASH_AlgSHA256;
+	else if (!strcmp(name, "sha384"))
+		nss_alg = HASH_AlgSHA384;
+	else if (!strcmp(name, "sha512"))
+		nss_alg = HASH_AlgSHA512;
+	else
+		return 0;
+
+	return HASH_ResultLen(nss_alg);
+}
+
+typedef HASHContext *hash_context;
+
+static void hash_context_init(hash_context *ctx)
+{
+	*ctx = HASH_Create(nss_alg);
+	if (!*ctx)
+		exit_err("HASH_Create failed");
+}
+
+static void hash_context_reset(hash_context *ctx)
+{
+	HASH_Begin(*ctx);
+}
+
+static void hash_context_update(hash_context *ctx, unsigned char *data, size_t len)
+{
+	HASH_Update(*ctx, data, len);
+}
+
+static void hash_context_final(hash_context *ctx, unsigned char *digest)
+{
+	unsigned result_len;
+	HASH_End(*ctx, digest, &result_len, HASH_ResultLen(nss_alg));
+}
+
+static void hash_context_destroy(hash_context *ctx)
+{
+	HASH_Destroy(*ctx);
+}
+
+static void crypto_rand_bytes(unsigned char *data, size_t len)
+{
+	if (PK11_GenerateRandom(data, len) != SECSuccess)
+		exit_err("PK11_GenerateRandom failed");
+}
+
+#endif
+
+
+static off_t verity_position_at_level(off_t block, int level)
+{
+	return block >> (level * hash_per_block_bits);
+}
+
+static void calculate_positions(void)
+{
+	unsigned long long hash_position;
+	int i;
+
+	digest_size_bits = 0;
+	while (1 << digest_size_bits < digest_size)
+		digest_size_bits++;
+	hash_per_block_bits = 0;
+	while (((hash_block_size / digest_size) >> hash_per_block_bits) > 1)
+		hash_per_block_bits++;
+	if (!hash_per_block_bits)
+		exit_err("at least two hashes must fit in a hash file block");
+	levels = 0;
+
+	if (data_file_blocks) {
+		while (hash_per_block_bits * levels < 64 &&
+		       (unsigned long long)(data_file_blocks - 1) >>
+		       (hash_per_block_bits * levels))
+			levels++;
+	}
+
+	if (levels > DM_VERITY_MAX_LEVELS)
+		exit_err("too many tree levels");
+
+	hash_position = hash_start * 512 / hash_block_size;
+	for (i = levels - 1; i >= 0; i--) {
+		off_t s;
+		hash_level_block[i] = hash_position;
+		s = verity_position_at_level(data_file_blocks, i);
+		s = (s >> hash_per_block_bits) +
+		    !!(s & ((1 << hash_per_block_bits) - 1));
+		hash_level_size[i] = s;
+		if (hash_position + s < hash_position ||
+		    (off_t)(hash_position + s) < 0 ||
+		    (off_t)(hash_position + s) != hash_position + s)
+			exit_err("hash device offset overflow");
+		hash_position += s;
+	}
+	used_hash_blocks = hash_position;
+}
+
+static void create_or_verify_zero(FILE *wr, unsigned char *left_block, unsigned left_bytes)
+{
+	if (left_bytes) {
+		if (mode != MODE_CREATE) {
+			unsigned x;
+			if (fread(left_block, left_bytes, 1, wr) != 1)
+				stream_err(wr, "read");
+			for (x = 0; x < left_bytes; x++) if (left_block[x]) {
+				retval = 1;
+				fprintf(stderr, "spare area is not zeroed@position %lld\n", (long long)ftello(wr) - left_bytes);
+			}
+		} else {
+			if (fwrite(left_block, left_bytes, 1, wr) != 1)
+				stream_err(wr, "write");
+		}
+	}
+}
+
+static void create_or_verify_stream(FILE *rd, FILE *wr, int block_size, off_t blocks)
+{
+	unsigned char *left_block = xmalloc(hash_block_size);
+	unsigned char *data_buffer = xmalloc(block_size);
+	unsigned char *read_digest = mode != MODE_CREATE ? xmalloc(digest_size) : NULL;
+	off_t blocks_to_write = (blocks >> hash_per_block_bits) +
+				!!(blocks & ((1 << hash_per_block_bits) - 1));
+	hash_context ctx;
+	hash_context_init(&ctx);
+	memset(left_block, 0, hash_block_size);
+	while (blocks_to_write--) {
+		unsigned x;
+		unsigned left_bytes = hash_block_size;
+		for (x = 0; x < 1 << hash_per_block_bits; x++) {
+			if (!blocks)
+				break;
+			blocks--;
+			if (fread(data_buffer, block_size, 1, rd) != 1)
+				stream_err(rd, "read");
+			hash_context_reset(&ctx);
+			if (version >= 1) {
+				hash_context_update(&ctx, salt_bytes, salt_size);
+			}
+			hash_context_update(&ctx, data_buffer, block_size);
+			if (!version) {
+				hash_context_update(&ctx, salt_bytes, salt_size);
+			}
+			hash_context_final(&ctx, calculated_digest);
+			if (!wr)
+				break;
+			if (mode != MODE_CREATE) {
+				if (fread(read_digest, digest_size, 1, wr) != 1)
+					stream_err(wr, "read");
+				if (memcmp(read_digest, calculated_digest, digest_size)) {
+					retval = 1;
+					fprintf(stderr, "verification failed at position %lld in %s file\n", (long long)ftello(rd) - block_size, rd == data_file ? "data" : "metadata");
+				}
+			} else {
+				if (fwrite(calculated_digest, digest_size, 1, wr) != 1)
+					stream_err(wr, "write");
+			}
+			if (!version) {
+				left_bytes -= digest_size;
+			} else {
+				create_or_verify_zero(wr, left_block, (1 << digest_size_bits) - digest_size);
+				left_bytes -= 1 << digest_size_bits;
+			}
+		}
+		if (wr)
+			create_or_verify_zero(wr, left_block, left_bytes);
+	}
+	if (mode == MODE_CREATE && wr) {
+		if (fflush(wr)) {
+			perror("fflush");
+			exit(1);
+		}
+		if (ferror(wr)) {
+			stream_err(wr, "write");
+		}
+	}
+	hash_context_destroy(&ctx);
+	free(left_block);
+	free(data_buffer);
+	if (mode != MODE_CREATE)
+		free(read_digest);
+}
+
+static char **make_target_line(void)
+{
+	const int line_elements = 14;
+	char **line = xmalloc(line_elements * sizeof(char *));
+	int i = 0;
+	char *algorithm_copy = xstrdup(hash_algorithm);
+		/* transform ripemdXXX to rmdXXX */
+	if (!strncmp(algorithm_copy, "ripemd", 6))
+		memmove(algorithm_copy + 1, algorithm_copy + 4, strlen(algorithm_copy + 4) + 1);
+	if (!strcmp(algorithm_copy, "whirlpool"))
+		strcpy(algorithm_copy, "wp512");
+	line[i++] = xstrdup("0");
+	line[i++] = xprint((unsigned long long)data_file_blocks * data_block_size / 512);
+	line[i++] = xstrdup("verity");
+	line[i++] = xprint(version);
+	line[i++] = xstrdup(data_device);
+	line[i++] = xstrdup(hash_device);
+	line[i++] = xprint(data_block_size);
+	line[i++] = xprint(hash_block_size);
+	line[i++] = xprint(data_file_blocks);
+	line[i++] = xprint(hash_start * 512 / hash_block_size);
+	line[i++] = algorithm_copy;
+	line[i++] = xhexprint(calculated_digest, digest_size);
+	line[i++] = !salt_size ? xstrdup("-") : xhexprint(salt_bytes, salt_size);
+	line[i++] = NULL;
+	if (i > line_elements)
+		exit_err("INTERNAL ERROR: insufficient array size");
+	return line;
+}
+
+static void free_target_line(char **line)
+{
+	int i;
+	for (i = 0; line[i]; i++)
+		free(line[i]);
+	free(line);
+}
+
+static void create_or_verify(void)
+{
+	int i;
+	if (mode != MODE_ACTIVATE)
+		for (i = 0; i < levels; i++) {
+			block_fseek(hash_file, hash_level_block[i], hash_block_size);
+			if (!i) {
+				block_fseek(data_file, 0, data_block_size);
+				create_or_verify_stream(data_file, hash_file, data_block_size, data_file_blocks);
+			} else {
+				FILE *hash_file_2 = fopen(hash_device, "r");
+				if (!hash_file_2) {
+					perror(hash_device);
+					exit(2);
+				}
+				block_fseek(hash_file_2, hash_level_block[i - 1], hash_block_size);
+				create_or_verify_stream(hash_file_2, hash_file, hash_block_size, hash_level_size[i - 1]);
+				fclose(hash_file_2);
+			}
+		}
+
+	if (levels) {
+		block_fseek(hash_file, hash_level_block[levels - 1], hash_block_size);
+		create_or_verify_stream(hash_file, NULL, hash_block_size, 1);
+	} else {
+		block_fseek(data_file, 0, data_block_size);
+		create_or_verify_stream(data_file, NULL, data_block_size, data_file_blocks);
+	}
+
+	if (mode != MODE_CREATE) {
+		if (memcmp(calculated_digest, root_hash_bytes, digest_size)) {
+			fprintf(stderr, "verification failed in the root block\n");
+			retval = 1;
+		}
+		if (!retval && mode == MODE_VERIFY)
+			fprintf(stderr, "hash successfully verified\n");
+	} else {
+		char **target_line;
+		char *p;
+		if (fsync(fileno(hash_file))) {
+			perror("fsync");
+			exit(1);
+		}
+		printf("hash device size: %llu\n", (unsigned long long)used_hash_blocks * hash_block_size);
+		printf("data block size %u, hash block size %u, %u tree levels\n", data_block_size, hash_block_size, levels);
+		if (salt_size)
+			p = xhexprint(salt_bytes, salt_size);
+		else
+			p = xstrdup("-");
+		printf("salt: %s\n", p);
+		free(p);
+		p = xhexprint(calculated_digest, digest_size);
+		printf("root hash: %s\n", p);
+		free(p);
+		printf("target line:");
+		target_line = make_target_line();
+		for (i = 0; target_line[i]; i++)
+			printf(" %s", target_line[i]);
+		free_target_line(target_line);
+		printf("\n");
+	}
+}
+
+__attribute__((noreturn))
+static void activate(void)
+{
+	int i;
+	size_t len = 1;
+	char *table_arg;
+	char **target_line = make_target_line();
+	for (i = 0; target_line[i]; i++) {
+		if (i)
+			len++;
+		len += strlen(target_line[i]);
+	}
+	table_arg = xmalloc(len);
+	table_arg[0] = 0;
+	for (i = 0; target_line[i]; i++) {
+		if (i)
+			strcat(table_arg, " ");
+		strcat(table_arg, target_line[i]);
+	}
+	free_target_line(target_line);
+	execlp("dmsetup", "dmsetup", "-r", "create", dm_device, "--table", table_arg, NULL);
+	perror("dmsetup");
+	exit(2);
+}
+
+static void get_hex(const char *string, unsigned char **result, size_t len, const char *description)
+{
+	size_t rl = strlen(string);
+	unsigned u;
+	if (strspn(string, "0123456789ABCDEFabcdef") != rl)
+		exit_err("invalid %s", description);
+	if (rl != len * 2)
+		exit_err("invalid length of %s", description);
+	*result = xmalloc(len);
+	memset(*result, 0, len);
+	for (u = 0; u < rl; u++) {
+		unsigned char c = (string[u] & 15) + (string[u] > '9' ? 9 : 0);
+		(*result)[u / 2] |= c << (((u & 1) ^ 1) << 2);
+	}
+}
+
+static struct superblock superblock;
+
+static void load_superblock(void)
+{
+	long long sb_data_blocks;
+
+	block_fseek(hash_file, superblock_position, 1);
+	if (fread(&superblock, sizeof(struct superblock), 1, hash_file) != 1)
+		stream_err(hash_file, "read");
+	if (memcmp(superblock.signature, DM_VERITY_SIGNATURE, sizeof(superblock.signature)))
+		exit_err("superblock not found on the hash device");
+	if (superblock.version > MAX_FORMAT_VERSION)
+		exit_err("unknown version");
+	if (superblock.data_block_bits < 9 || superblock.data_block_bits >= 31)
+		exit_err("invalid data_block_bits in the superblock");
+	if (superblock.hash_block_bits < 9 || superblock.hash_block_bits >= 31)
+		exit_err("invalid data_block_bits in the superblock");
+	sb_data_blocks = ((unsigned long long)ntohl(superblock.data_blocks_hi) << 31 << 1) | ntohl(superblock.data_blocks_lo);
+	if (sb_data_blocks < 0 || (off_t)sb_data_blocks < 0 || (off_t)sb_data_blocks != sb_data_blocks)
+		exit_err("invalid data blocks in the superblock");
+	if (!memchr(superblock.algorithm, 0, sizeof(superblock.algorithm)))
+		exit_err("invalid hash algorithm in the superblock");
+	if (ntohs(superblock.salt_size) > MAX_SALT_SIZE)
+		exit_err("invalid salt_size in the superblock");
+
+	if (version == -1) {
+		version = superblock.version;
+	} else {
+		if (version != superblock.version)
+			exit_err("version (%d) does not match superblock value (%d)", version, superblock.version);
+	}
+
+	if (!data_block_size) {
+		data_block_size = 1 << superblock.data_block_bits;
+	} else {
+		if (data_block_size != 1 << superblock.data_block_bits)
+			exit_err("data block size (%d) does not match superblock value (%d)", data_block_size, 1 << superblock.data_block_bits);
+	}
+
+	if (!hash_block_size) {
+		hash_block_size = 1 << superblock.hash_block_bits;
+	} else {
+		if (hash_block_size != 1 << superblock.hash_block_bits)
+			exit_err("hash block size (%d) does not match superblock value (%d)", hash_block_size, 1 << superblock.hash_block_bits);
+	}
+
+	if (!data_blocks) {
+		data_blocks = sb_data_blocks;
+	} else {
+		if (data_blocks != sb_data_blocks)
+			exit_err("data blocks (%lld) does not match superblock value (%lld)", data_blocks, sb_data_blocks);
+	}
+
+	if (!hash_algorithm) {
+		hash_algorithm = (char *)superblock.algorithm;
+	} else {
+		if (strcmp(hash_algorithm, (char *)superblock.algorithm))
+			exit_err("hash algorithm (%s) does not match superblock value (%s)", hash_algorithm, superblock.algorithm);
+	}
+
+	if (!salt_bytes) {
+		salt_size = ntohs(superblock.salt_size);
+		salt_bytes = xmalloc(salt_size);
+		memcpy(salt_bytes, superblock.salt, salt_size);
+	} else {
+		if (salt_size != ntohs(superblock.salt_size) ||
+		    memcmp(salt_bytes, superblock.salt, salt_size))
+			exit_err("salt does not match superblock value");
+	}
+}
+
+static void save_superblock(void)
+{
+	memset(&superblock, 0, sizeof(struct superblock));
+
+	memcpy(&superblock.signature, DM_VERITY_SIGNATURE, sizeof(superblock.signature));
+	superblock.version = version;
+	superblock.data_block_bits = ffs(data_block_size) - 1;
+	superblock.hash_block_bits = ffs(hash_block_size) - 1;
+	superblock.salt_size = htons(salt_size);
+	superblock.data_blocks_hi = htonl(data_blocks >> 31 >> 1);
+	superblock.data_blocks_lo = htonl(data_blocks & 0xFFFFFFFF);
+	strncpy((char *)superblock.algorithm, hash_algorithm, sizeof superblock.algorithm);
+	memcpy(superblock.salt, salt_bytes, salt_size);
+
+	block_fseek(hash_file, superblock_position, 1);
+	if (fwrite(&superblock, sizeof(struct superblock), 1, hash_file) != 1)
+		stream_err(hash_file, "write");
+}
+
+int main(int argc, const char **argv)
+{
+	poptContext popt_context;
+	int r;
+	const char *s;
+	char c;
+
+	if (sizeof(struct superblock) != 512)
+		exit_err("INTERNAL ERROR: bad superblock size %ld", (long)sizeof(struct superblock));
+
+	popt_context = poptGetContext("verity", argc, argv, popt_options, 0);
+
+	poptSetOtherOptionHelp(popt_context, "[-c | -v | -a] [<device name> if activating] <data device> <hash device> [<root hash> if activating or verifying] [OPTION...]");
+
+	if (argc <= 1) {
+		poptPrintHelp(popt_context, stdout, 0);
+		exit(1);
+	}
+
+	r = poptGetNextOpt(popt_context);
+	if (r < -1)
+		exit_err("bad option %s", poptBadOption(popt_context, 0));
+
+	if (mode < 0)
+		exit_err("verify, create or activate mode not specified");
+
+	if (mode == MODE_ACTIVATE) {
+		dm_device = poptGetArg(popt_context);
+		if (!dm_device)
+			exit_err("device name is missing");
+		if (!*dm_device || strchr(dm_device, '/'))
+			exit_err("invalid device name to activate");
+	}
+
+	data_device = poptGetArg(popt_context);
+	if (!data_device)
+		exit_err("data device is missing");
+
+	hash_device = poptGetArg(popt_context);
+	if (!hash_device)
+		exit_err("metadata device is missing");
+
+	if (mode != MODE_CREATE) {
+		root_hash = poptGetArg(popt_context);
+		if (!root_hash)
+			exit_err("root hash not specified");
+	}
+
+	s = poptGetArg(popt_context);
+	if (s)
+		exit_err("extra argument %s", s);
+
+	data_file = fopen(data_device, "r");
+	if (!data_file) {
+		perror(data_device);
+		exit(2);
+	}
+
+	hash_file = fopen(hash_device, mode != MODE_CREATE ? "r" : "r+");
+	if (!hash_file && errno == ENOENT && mode == MODE_CREATE)
+		hash_file = fopen(hash_device, "w+");
+	if (!hash_file) {
+		perror(hash_device);
+		exit(2);
+	}
+
+	if (hash_start_string)
+		if (sscanf(hash_start_string, "%lld%c", &hash_start, &c) != 1)
+			exit_err("invalid hash start");
+
+	if (hash_start < 0 ||
+	   (unsigned long long)hash_start * 512 / 512 != hash_start ||
+	   (off_t)(hash_start * 512) < 0 ||
+	   (off_t)(hash_start * 512) != hash_start * 512) exit_err("invalid hash start");
+
+	if (salt_string || !use_superblock) {
+		if (!salt_string || !strcmp(salt_string, "-"))
+			salt_string = "";
+		salt_size = strlen(salt_string) / 2;
+		if (salt_size > MAX_SALT_SIZE)
+			exit_err("too long salt (max %d bytes)", MAX_SALT_SIZE);
+		get_hex(salt_string, &salt_bytes, salt_size, "salt");
+	}
+
+	if (use_superblock) {
+		superblock_position = hash_start * 512;
+		if (mode != MODE_CREATE)
+			load_superblock();
+	}
+
+	if (version == -1)
+		version = MAX_FORMAT_VERSION;
+	if (version < 0 || version > MAX_FORMAT_VERSION)
+		exit_err("invalid format version");
+
+	if (!data_block_size)
+		data_block_size = DEFAULT_BLOCK_SIZE;
+	if (!hash_block_size)
+		hash_block_size = data_block_size;
+
+	if (data_block_size < 512 || (data_block_size & (data_block_size - 1)) || data_block_size >= 1U << 31)
+		exit_err("invalid data block size");
+
+	if (hash_block_size < 512 || (hash_block_size & (hash_block_size - 1)) || hash_block_size >= 1U << 31)
+		exit_err("invalid hash block size");
+
+	if (data_blocks_string)
+		if (sscanf(data_blocks_string, "%lld%c", &data_blocks, &c) != 1)
+			exit_err("invalid number of data blocks");
+
+	if (data_blocks < 0 || (off_t)data_blocks < 0 || (off_t)data_blocks != data_blocks)
+		exit_err("invalid number of data blocks");
+
+	data_file_blocks = get_size(data_file, data_device) / data_block_size;
+	hash_file_blocks = get_size(hash_file, hash_device) / hash_block_size;
+
+	if (data_file_blocks < data_blocks)
+		exit_err("data file is too small");
+	if (data_blocks) {
+		data_file_blocks = data_blocks;
+	}
+
+	if (use_superblock) {
+		hash_start = hash_start + (sizeof(struct superblock) + 511) / 512;
+		hash_start = (hash_start + (hash_block_size / 512 - 1)) & ~(long long)(hash_block_size / 512 - 1);
+	}
+
+	if ((unsigned long long)hash_start * 512 % hash_block_size)
+		exit_err("hash start not aligned on block size");
+
+	if (!hash_algorithm)
+		hash_algorithm = "sha256";
+	if (strlen(hash_algorithm) >= sizeof(superblock.algorithm) && use_superblock)
+		exit_err("hash algorithm name is too long");
+
+	digest_size = hash_init(hash_algorithm);
+	if (!digest_size) exit_err("hash algorithm %s not found", hash_algorithm);
+
+	if (!salt_bytes) {
+		salt_size = DEFAULT_SALT_SIZE;
+		salt_bytes = xmalloc(salt_size);
+		crypto_rand_bytes(salt_bytes, salt_size);
+	}
+
+	calculated_digest = xmalloc(digest_size);
+
+ 	if (mode != MODE_CREATE) {
+		get_hex(root_hash, &root_hash_bytes, digest_size, "root_hash");
+	}
+
+	calculate_positions();
+
+	create_or_verify();
+
+	if (use_superblock) {
+		if (mode == MODE_CREATE)
+			save_superblock();
+	}
+
+	fclose(data_file);
+	fclose(hash_file);
+
+	if (mode == MODE_ACTIVATE && !retval)
+		activate();
+
+	free(salt_bytes);
+	free(calculated_digest);
+	if (mode != MODE_CREATE)
+		free(root_hash_bytes);
+	poptFreeContext(popt_context);
+
+	return retval;
+}


