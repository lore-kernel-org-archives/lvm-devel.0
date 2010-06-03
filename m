From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Jun 2010 13:50:29 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in da ...
Message-ID: <20100603135029.1707.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-06-03 13:50:27

Modified files:
	.              : WHATS_NEW configure configure.in 
	daemons/clvmd  : clvmd-command.c lvm-functions.c 
	lib/misc       : configure.h.in 

Log message:
	Use absolute paths in commands
	
	clvmd restart does not work at all if clvmd binary is not in current
	dir.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1604&r2=1.1605
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.130&r2=1.131
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.141&r2=1.142
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/WHATS_NEW	2010/06/03 12:45:05	1.1604
+++ LVM2/WHATS_NEW	2010/06/03 13:50:26	1.1605
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Use absolute paths for clvmd restart.
   Require partial option in lvchange --refresh for partial LVs.
   Do not fail lvm_init() if init_logging() or _init_rand() generates an errno.
   Don't merge unchanged persistent cache file before dumping if tool scanned.
--- LVM2/configure	2010/05/21 12:36:30	1.130
+++ LVM2/configure	2010/06/03 13:50:26	1.131
@@ -736,6 +736,8 @@
 CCS_CFLAGS
 PKGCONFIGINIT_LIBS
 PKGCONFIGINIT_CFLAGS
+PKG_CONFIG_LIBDIR
+PKG_CONFIG_PATH
 PKG_CONFIG
 POW_LIB
 LIBOBJS
@@ -875,6 +877,8 @@
 CPPFLAGS
 CPP
 PKG_CONFIG
+PKG_CONFIG_PATH
+PKG_CONFIG_LIBDIR
 PKGCONFIGINIT_CFLAGS
 PKGCONFIGINIT_LIBS
 CCS_CFLAGS
@@ -1603,6 +1607,10 @@
               you have headers in a nonstandard directory <include dir>
   CPP         C preprocessor
   PKG_CONFIG  path to pkg-config utility
+  PKG_CONFIG_PATH
+              directories to add to pkg-config's search path
+  PKG_CONFIG_LIBDIR
+              path overriding pkg-config's built-in search path
   PKGCONFIGINIT_CFLAGS
               C compiler flags for PKGCONFIGINIT, overriding pkg-config
   PKGCONFIGINIT_LIBS
@@ -9401,6 +9409,10 @@
 pkg_config_init() {
 
 
+
+
+
+
 if test "x$ac_cv_env_PKG_CONFIG_set" != "xset"; then
 	if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}pkg-config", so it can be a program name with args.
@@ -9513,7 +9525,6 @@
 $as_echo "no" >&6; }
 		PKG_CONFIG=""
 	fi
-
 fi
 
 pkg_failed=no
@@ -9556,6 +9567,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -9570,11 +9583,11 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$PKGCONFIGINIT_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
-                { $as_echo "$as_me:$LINENO: result: pkg-config initialized" >&5
+	{ $as_echo "$as_me:$LINENO: result: pkg-config initialized" >&5
 $as_echo "pkg-config initialized" >&6; }
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	{ $as_echo "$as_me:$LINENO: result: pkg-config initialized" >&5
 $as_echo "pkg-config initialized" >&6; }
 else
@@ -9582,7 +9595,7 @@
 	PKGCONFIGINIT_LIBS=$pkg_cv_PKGCONFIGINIT_LIBS
         { $as_echo "$as_me:$LINENO: result: yes" >&5
 $as_echo "yes" >&6; }
-	:
+
 fi
 	PKGCONFIG_INIT=1
 }
@@ -9788,6 +9801,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -9802,9 +9817,7 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$CCS_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
-                NOTFOUND=0
+	NOTFOUND=0
 
 for ac_header in ccs.h
 do
@@ -9961,6 +9974,8 @@
 			HAVE_CCS=yes
 		fi
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	NOTFOUND=0
 
 for ac_header in ccs.h
@@ -10165,6 +10180,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -10179,9 +10196,7 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$GULM_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
-                NOTFOUND=0
+	NOTFOUND=0
 
 for ac_header in libgulm.h
 do
@@ -10338,6 +10353,8 @@
 			HAVE_GULM=yes
 		fi
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	NOTFOUND=0
 
 for ac_header in libgulm.h
@@ -10545,6 +10562,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -10559,9 +10578,7 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$CMAN_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
-                NOTFOUND=0
+	NOTFOUND=0
 
 for ac_header in libcman.h
 do
@@ -10718,6 +10735,8 @@
 			HAVE_CMAN=yes
 		fi
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	NOTFOUND=0
 
 for ac_header in libcman.h
@@ -10928,6 +10947,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -10942,10 +10963,10 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$COROSYNC_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
-                $bailout
+	$bailout
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	$bailout
 else
 	COROSYNC_CFLAGS=$pkg_cv_COROSYNC_CFLAGS
@@ -10999,6 +11020,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -11013,10 +11036,10 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$QUORUM_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
-                $bailout
+	$bailout
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	$bailout
 else
 	QUORUM_CFLAGS=$pkg_cv_QUORUM_CFLAGS
@@ -11071,6 +11094,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -11085,10 +11110,10 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$SALCK_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
-                $bailout
+	$bailout
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	$bailout
 else
 	SALCK_CFLAGS=$pkg_cv_SALCK_CFLAGS
@@ -11144,6 +11169,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -11158,10 +11185,10 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$CONFDB_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
-                HAVE_CONFDB=no
+	HAVE_CONFDB=no
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	HAVE_CONFDB=no
 else
 	CONFDB_CFLAGS=$pkg_cv_CONFDB_CFLAGS
@@ -11380,6 +11407,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -11394,10 +11423,10 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$CPG_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
-                $bailout
+	$bailout
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	$bailout
 else
 	CPG_CFLAGS=$pkg_cv_CPG_CFLAGS
@@ -11450,6 +11479,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -11464,9 +11495,7 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$DLM_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
-                NOTFOUND=0
+	NOTFOUND=0
 
 for ac_header in libdlm.h
 do
@@ -11623,6 +11652,8 @@
 			HAVE_DLM=yes
 		fi
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	NOTFOUND=0
 
 for ac_header in libdlm.h
@@ -11905,6 +11936,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -11928,8 +11961,7 @@
 
 Alternatively, you may set the environment variables SACKPT_CFLAGS
 and SACKPT_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details.
-" >&5
+See the pkg-config man page for more details." >&5
 $as_echo "$as_me: error: Package requirements (libSaCkpt) were not met:
 
 $SACKPT_PKG_ERRORS
@@ -11939,10 +11971,11 @@
 
 Alternatively, you may set the environment variables SACKPT_CFLAGS
 and SACKPT_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details.
-" >&2;}
+See the pkg-config man page for more details." >&2;}
    { (exit 1); exit 1; }; }
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	{ { $as_echo "$as_me:$LINENO: error: in \`$ac_pwd':" >&5
 $as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
 { { $as_echo "$as_me:$LINENO: error: The pkg-config script could not be found or is too old.  Make sure it
@@ -11971,7 +12004,7 @@
 	SACKPT_LIBS=$pkg_cv_SACKPT_LIBS
         { $as_echo "$as_me:$LINENO: result: yes" >&5
 $as_echo "yes" >&6; }
-	:
+
 fi
 	if test x$HAVE_CPG != xyes; then
 
@@ -12015,6 +12048,8 @@
 
 
 if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -12038,8 +12073,7 @@
 
 Alternatively, you may set the environment variables CPG_CFLAGS
 and CPG_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details.
-" >&5
+See the pkg-config man page for more details." >&5
 $as_echo "$as_me: error: Package requirements (libcpg) were not met:
 
 $CPG_PKG_ERRORS
@@ -12049,10 +12083,11 @@
 
 Alternatively, you may set the environment variables CPG_CFLAGS
 and CPG_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details.
-" >&2;}
+See the pkg-config man page for more details." >&2;}
    { (exit 1); exit 1; }; }
 elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
 	{ { $as_echo "$as_me:$LINENO: error: in \`$ac_pwd':" >&5
 $as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
 { { $as_echo "$as_me:$LINENO: error: The pkg-config script could not be found or is too old.  Make sure it
@@ -12081,7 +12116,7 @@
 	CPG_LIBS=$pkg_cv_CPG_LIBS
         { $as_echo "$as_me:$LINENO: result: yes" >&5
 $as_echo "yes" >&6; }
-	:
+
 fi
 	fi
 fi
@@ -15482,6 +15517,22 @@
 
 fi
 
+
+cat >>confdefs.h <<_ACEOF
+#define LVM_PATH "$exec_prefix/sbin/lvm"
+_ACEOF
+
+
+if  test "$CLVMD" != none; then
+        clvmd_prefix=$ac_default_prefix
+        test "$prefix" != NONE && clvmd_prefix=$prefix
+
+cat >>confdefs.h <<_ACEOF
+#define CLVMD_PATH "$clvmd_prefix/sbin/clvmd"
+_ACEOF
+
+fi
+
 ################################################################################
 
 
--- LVM2/configure.in	2010/05/21 12:36:30	1.141
+++ LVM2/configure.in	2010/06/03 13:50:26	1.142
@@ -1009,6 +1009,14 @@
 	AC_DEFINE_UNQUOTED([MODPROBE_CMD], ["$MODPROBE_CMD"], [The path to 'modprobe', if available.])
 fi
 
+AC_DEFINE_UNQUOTED(LVM_PATH, ["$exec_prefix/sbin/lvm"], [Path to lvm binary.])
+
+if  test "$CLVMD" != none; then
+        clvmd_prefix=$ac_default_prefix
+        test "$prefix" != NONE && clvmd_prefix=$prefix
+	AC_DEFINE_UNQUOTED(CLVMD_PATH, ["$clvmd_prefix/sbin/clvmd"], [Path to clvmd binary.])
+fi
+
 ################################################################################
 dnl -- dmeventd pidfile and executable path
 AH_TEMPLATE(DMEVENTD_PIDFILE, [Path to dmeventd pidfile.])
--- LVM2/daemons/clvmd/clvmd-command.c	2010/04/30 14:51:58	1.34
+++ LVM2/daemons/clvmd/clvmd-command.c	2010/06/03 13:50:26	1.35
@@ -400,7 +400,7 @@
 
 	/* Exec new clvmd */
 	/* NOTE: This will fail when downgrading! */
-	execve("clvmd", argv, NULL);
+	execve(CLVMD_PATH, argv, NULL);
 
 	/* We failed */
 	return 0;
--- LVM2/daemons/clvmd/lvm-functions.c	2010/04/20 14:07:38	1.89
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/06/03 13:50:26	1.90
@@ -653,7 +653,7 @@
 	char line[255];
 	FILE *vgs =
 	    popen
-	    ("lvm pvs  --config 'log{command_names=0 prefix=\"\"}' --nolocking --noheadings -o vg_name", "r");
+	    (LVM_PATH " pvs  --config 'log{command_names=0 prefix=\"\"}' --nolocking --noheadings -o vg_name", "r");
 
 	sync_unlock("P_" VG_ORPHANS, LCK_EXCL);
 	sync_unlock("P_" VG_GLOBAL, LCK_EXCL);
@@ -762,7 +762,7 @@
 	char line[255];
 	FILE *lvs =
 	    popen
-	    ("lvm lvs  --config 'log{command_names=0 prefix=\"\"}' --nolocking --noheadings -o vg_uuid,lv_uuid,lv_attr,vg_attr",
+	    (LVM_PATH " lvs  --config 'log{command_names=0 prefix=\"\"}' --nolocking --noheadings -o vg_uuid,lv_uuid,lv_attr,vg_attr",
 	     "r");
 
 	if (!lvs)
--- LVM2/lib/misc/configure.h.in	2010/05/21 12:36:31	1.22
+++ LVM2/lib/misc/configure.h.in	2010/06/03 13:50:27	1.23
@@ -6,6 +6,9 @@
 /* Define to 1 to include built-in support for clustered LVM locking. */
 #undef CLUSTER_LOCKING_INTERNAL
 
+/* Path to clvmd binary. */
+#undef CLVMD_PATH
+
 /* Path to cmirrord pidfile. */
 #undef CMIRRORD_PIDFILE
 
@@ -397,6 +400,9 @@
 /* Define to 1 to include built-in support for LVM1 metadata. */
 #undef LVM1_INTERNAL
 
+/* Path to lvm binary. */
+#undef LVM_PATH
+
 /* Define to 1 to include built-in support for mirrors. */
 #undef MIRRORED_INTERNAL
 


