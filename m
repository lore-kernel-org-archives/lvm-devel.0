From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Aug 2011 18:14:49 -0000
Subject: LVM2 ./configure lib/misc/configure.h.in
Message-ID: <20110809181449.16857.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-09 18:14:49

Modified files:
	.              : configure 
	lib/misc       : configure.h.in 

Log message:
	autoreconf

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.151&r2=1.152
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/configure	2011/08/09 17:56:47	1.151
+++ LVM2/configure	2011/08/09 18:14:48	1.152
@@ -669,6 +669,8 @@
 CLDWHOLEARCHIVE
 CLDNOWHOLEARCHIVE
 CLDFLAGS
+CCS_LIBS
+CCS_CFLAGS
 BUILD_DMEVENTD
 BUILD_CMIRRORD
 APPLIB
@@ -699,10 +701,6 @@
 COROSYNC_CFLAGS
 CMAN_LIBS
 CMAN_CFLAGS
-GULM_LIBS
-GULM_CFLAGS
-CCS_LIBS
-CCS_CFLAGS
 PKGCONFIGINIT_LIBS
 PKGCONFIGINIT_CFLAGS
 PKG_CONFIG_LIBDIR
@@ -860,10 +858,6 @@
 PKG_CONFIG_LIBDIR
 PKGCONFIGINIT_CFLAGS
 PKGCONFIGINIT_LIBS
-CCS_CFLAGS
-CCS_LIBS
-GULM_CFLAGS
-GULM_LIBS
 CMAN_CFLAGS
 CMAN_LIBS
 COROSYNC_CFLAGS
@@ -1553,7 +1547,6 @@
                           [[PREFIX/lib/ocf/resource.d/lvm2]]
   --with-clvmd=TYPE       build cluster LVM Daemon
                           The following cluster manager combinations are valid:
-                           * cman,gulm             (RHEL4 or equivalent)
                            * cman                  (RHEL5 or equivalent)
                            * cman,corosync,openais (or selection of them)
                            * singlenode            (localhost only)
@@ -1610,10 +1603,6 @@
               C compiler flags for PKGCONFIGINIT, overriding pkg-config
   PKGCONFIGINIT_LIBS
               linker flags for PKGCONFIGINIT, overriding pkg-config
-  CCS_CFLAGS  C compiler flags for CCS, overriding pkg-config
-  CCS_LIBS    linker flags for CCS, overriding pkg-config
-  GULM_CFLAGS C compiler flags for GULM, overriding pkg-config
-  GULM_LIBS   linker flags for GULM, overriding pkg-config
   CMAN_CFLAGS C compiler flags for CMAN, overriding pkg-config
   CMAN_LIBS   linker flags for CMAN, overriding pkg-config
   COROSYNC_CFLAGS
@@ -7205,9 +7194,7 @@
 CLVMD_NEEDS_QDISKD=no
 
 if [ `expr x"$CLVMD" : '.*gulm.*'` != 0 ]; then
-	BUILDGULM=yes
-	CLVMD_CMANAGERS="$CLVMD_CMANAGERS lock_gulmd"
-	CLVMD_NEEDS_QDISKD=yes
+	as_fn_error $? "Since version 2.02.87 GULM locking is no longer supported." "$LINENO" 5;
 fi
 if [ `expr x"$CLVMD" : '.*cman.*'` != 0 ]; then
 	BUILDCMAN=yes
@@ -7226,13 +7213,6 @@
 	CLVMD_CMANAGERS="$CLVMD_CMANAGERS qdiskd"
 fi
 
-if test x$BUILDGULM = xyes; then
-	if test x$BUILDCOROSYNC = xyes || \
-	   test x$BUILDOPENAIS = xyes; then
-		as_fn_error $? "requested clvmd configuration is not valid" "$LINENO" 5
-	fi
-fi
-
 soft_bailout() {
 	NOTFOUND=1
 }
@@ -7243,7 +7223,6 @@
 
 if test x$CLVMD = xall; then
 	bailout=soft_bailout
-	BUILDGULM=yes
 	BUILDCMAN=yes
 	BUILDCOROSYNC=yes
 	BUILDOPENAIS=yes
@@ -7309,231 +7288,6 @@
 	LIBS=$ac_check_lib_save_LIBS
 }
 
-if test x$BUILDGULM = xyes; then
-
-pkg_failed=no
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for CCS" >&5
-$as_echo_n "checking for CCS... " >&6; }
-
-if test -n "$CCS_CFLAGS"; then
-    pkg_cv_CCS_CFLAGS="$CCS_CFLAGS"
- elif test -n "$PKG_CONFIG"; then
-    if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libccs\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "libccs") 2>&5
-  ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; then
-  pkg_cv_CCS_CFLAGS=`$PKG_CONFIG --cflags "libccs" 2>/dev/null`
-else
-  pkg_failed=yes
-fi
- else
-    pkg_failed=untried
-fi
-if test -n "$CCS_LIBS"; then
-    pkg_cv_CCS_LIBS="$CCS_LIBS"
- elif test -n "$PKG_CONFIG"; then
-    if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libccs\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "libccs") 2>&5
-  ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; then
-  pkg_cv_CCS_LIBS=`$PKG_CONFIG --libs "libccs" 2>/dev/null`
-else
-  pkg_failed=yes
-fi
- else
-    pkg_failed=untried
-fi
-
-
-
-if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
-
-if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
-        _pkg_short_errors_supported=yes
-else
-        _pkg_short_errors_supported=no
-fi
-        if test $_pkg_short_errors_supported = yes; then
-	        CCS_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libccs" 2>&1`
-        else
-	        CCS_PKG_ERRORS=`$PKG_CONFIG --print-errors "libccs" 2>&1`
-        fi
-	# Put the nasty error message in config.log where it belongs
-	echo "$CCS_PKG_ERRORS" >&5
-
-	NOTFOUND=0
-		for ac_header in ccs.h
-do :
-  ac_fn_c_check_header_mongrel "$LINENO" "ccs.h" "ac_cv_header_ccs_h" "$ac_includes_default"
-if test "x$ac_cv_header_ccs_h" = x""yes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_CCS_H 1
-_ACEOF
-
-else
-  $bailout
-fi
-
-done
-
-		check_lib_no_libs ccs ccs_connect
-		if test $NOTFOUND = 0; then
-			{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no pkg for libccs, using -lccs" >&5
-$as_echo "no pkg for libccs, using -lccs" >&6; }
-			CCS_LIBS="-lccs"
-			HAVE_CCS=yes
-		fi
-elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
-	NOTFOUND=0
-		for ac_header in ccs.h
-do :
-  ac_fn_c_check_header_mongrel "$LINENO" "ccs.h" "ac_cv_header_ccs_h" "$ac_includes_default"
-if test "x$ac_cv_header_ccs_h" = x""yes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_CCS_H 1
-_ACEOF
-
-else
-  $bailout
-fi
-
-done
-
-		check_lib_no_libs ccs ccs_connect
-		if test $NOTFOUND = 0; then
-			{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no pkg for libccs, using -lccs" >&5
-$as_echo "no pkg for libccs, using -lccs" >&6; }
-			CCS_LIBS="-lccs"
-			HAVE_CCS=yes
-		fi
-else
-	CCS_CFLAGS=$pkg_cv_CCS_CFLAGS
-	CCS_LIBS=$pkg_cv_CCS_LIBS
-        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
-	HAVE_CCS=yes
-fi
-
-pkg_failed=no
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for GULM" >&5
-$as_echo_n "checking for GULM... " >&6; }
-
-if test -n "$GULM_CFLAGS"; then
-    pkg_cv_GULM_CFLAGS="$GULM_CFLAGS"
- elif test -n "$PKG_CONFIG"; then
-    if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libgulm\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "libgulm") 2>&5
-  ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; then
-  pkg_cv_GULM_CFLAGS=`$PKG_CONFIG --cflags "libgulm" 2>/dev/null`
-else
-  pkg_failed=yes
-fi
- else
-    pkg_failed=untried
-fi
-if test -n "$GULM_LIBS"; then
-    pkg_cv_GULM_LIBS="$GULM_LIBS"
- elif test -n "$PKG_CONFIG"; then
-    if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libgulm\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "libgulm") 2>&5
-  ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; then
-  pkg_cv_GULM_LIBS=`$PKG_CONFIG --libs "libgulm" 2>/dev/null`
-else
-  pkg_failed=yes
-fi
- else
-    pkg_failed=untried
-fi
-
-
-
-if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
-
-if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
-        _pkg_short_errors_supported=yes
-else
-        _pkg_short_errors_supported=no
-fi
-        if test $_pkg_short_errors_supported = yes; then
-	        GULM_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libgulm" 2>&1`
-        else
-	        GULM_PKG_ERRORS=`$PKG_CONFIG --print-errors "libgulm" 2>&1`
-        fi
-	# Put the nasty error message in config.log where it belongs
-	echo "$GULM_PKG_ERRORS" >&5
-
-	NOTFOUND=0
-		for ac_header in libgulm.h
-do :
-  ac_fn_c_check_header_mongrel "$LINENO" "libgulm.h" "ac_cv_header_libgulm_h" "$ac_includes_default"
-if test "x$ac_cv_header_libgulm_h" = x""yes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_LIBGULM_H 1
-_ACEOF
-
-else
-  $bailout
-fi
-
-done
-
-		check_lib_no_libs gulm lg_core_login
-		if test $NOTFOUND = 0; then
-			{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no pkg for libgulm, using -lgulm" >&5
-$as_echo "no pkg for libgulm, using -lgulm" >&6; }
-			GULM_LIBS="-lgulm"
-			HAVE_GULM=yes
-		fi
-elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
-	NOTFOUND=0
-		for ac_header in libgulm.h
-do :
-  ac_fn_c_check_header_mongrel "$LINENO" "libgulm.h" "ac_cv_header_libgulm_h" "$ac_includes_default"
-if test "x$ac_cv_header_libgulm_h" = x""yes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_LIBGULM_H 1
-_ACEOF
-
-else
-  $bailout
-fi
-
-done
-
-		check_lib_no_libs gulm lg_core_login
-		if test $NOTFOUND = 0; then
-			{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no pkg for libgulm, using -lgulm" >&5
-$as_echo "no pkg for libgulm, using -lgulm" >&6; }
-			GULM_LIBS="-lgulm"
-			HAVE_GULM=yes
-		fi
-else
-	GULM_CFLAGS=$pkg_cv_GULM_CFLAGS
-	GULM_LIBS=$pkg_cv_GULM_LIBS
-        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
-	HAVE_GULM=yes
-fi
-fi
-
 if test x$BUILDCMAN = xyes; then
 
 pkg_failed=no
@@ -8165,14 +7919,6 @@
 	CLVMD=none
 	CLVMD_CMANAGERS=""
 	CLVMD_NEEDS_QDISKD=no
-	if test x$HAVE_CCS = xyes && \
-	   test x$HAVE_GULM = xyes; then
-		{ $as_echo "$as_me:${as_lineno-$LINENO}: result: Enabling clvmd gulm cluster manager" >&5
-$as_echo "Enabling clvmd gulm cluster manager" >&6; }
-		CLVMD="$CLVMD,gulm"
-		CLVMD_CMANAGERS="$CLVMD_CMANAGERS lock_gulmd"
-		CLVMD_NEEDS_QDISKD=yes
-	fi
 	if test x$HAVE_CMAN = xyes && \
 	   test x$HAVE_DLM = xyes; then
 		{ $as_echo "$as_me:${as_lineno-$LINENO}: result: Enabling clvmd cman cluster manager" >&5
@@ -10418,8 +10164,6 @@
 
 
 
-
-
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makef!
 ile unit-tests/mm/Makefile"
 
--- LVM2/lib/misc/configure.h.in	2011/08/02 22:07:22	1.33
+++ LVM2/lib/misc/configure.h.in	2011/08/09 18:14:49	1.34
@@ -84,9 +84,6 @@
 /* Define to 1 if canonicalize_file_name is available. */
 #undef HAVE_CANONICALIZE_FILE_NAME
 
-/* Define to 1 if you have the <ccs.h> header file. */
-#undef HAVE_CCS_H
-
 /* Define to 1 if your system has a working `chown' function. */
 #undef HAVE_CHOWN
 
@@ -159,9 +156,6 @@
 /* Define to 1 if you have the <libgen.h> header file. */
 #undef HAVE_LIBGEN_H
 
-/* Define to 1 if you have the <libgulm.h> header file. */
-#undef HAVE_LIBGULM_H
-
 /* Define to 1 if you have the <libintl.h> header file. */
 #undef HAVE_LIBINTL_H
 


