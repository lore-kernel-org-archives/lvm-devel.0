From: fabbione@sourceware.org <fabbione@sourceware.org>
Date: 13 Jul 2010 13:51:07 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM ./configure ./ ...
Message-ID: <20100713135107.28171.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	fabbione at sourceware.org	2010-07-13 13:51:03

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM configure configure.in 
	daemons/clvmd  : clvmd.c 
	daemons/cmirrord: clogd.c 
	daemons/dmeventd: dmeventd.c dmeventd.h 
	lib/misc       : configure.h.in 
	libdm          : libdevmapper.h libdm-file.c 

Log message:
	Add dm_create_lockfile to libdm to handle pidfiles for all daemons.
	Switch dmeventd to use dm_create_lockfile and drop duplicate code.
	Allow clvmd pidfile to be configurable.
	Switch cmirrord and clvmd to use dm_create_lockfile.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1665&r2=1.1666
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.394&r2=1.395
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.134&r2=1.135
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.145&r2=1.146
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/clogd.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.120&r2=1.121
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-file.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW	2010/07/12 18:12:23	1.1665
+++ LVM2/WHATS_NEW	2010/07/13 13:51:01	1.1666
@@ -1,5 +1,7 @@
 Version 2.02.71 -
 ===============================
+  Switch cmirrord and clvmd to use dm_create_lockfile.
+  Allow clvmd pidfile to be configurable.
   Update comments about memory handling in lvm2app.h.
   Add more verbose messages while checking volume_list and hosttags settings.
   Add log_error when strdup fails in {vg|lv}_change_tag().
--- LVM2/WHATS_NEW_DM	2010/07/08 14:29:26	1.394
+++ LVM2/WHATS_NEW_DM	2010/07/13 13:51:01	1.395
@@ -1,5 +1,7 @@
 Version 1.02.53 -
 ===============================
+  Switch dmeventd to use dm_create_lockfile and drop duplicate code.
+  Add dm_create_lockfile to libdm to handle pidfiles for all daemons.
   Use "nowatch" udev rule for inappropriate devices.
 
 Version 1.02.52 - 6th July 2010
--- LVM2/configure	2010/07/08 12:02:48	1.134
+++ LVM2/configure	2010/07/13 13:51:01	1.135
@@ -736,8 +736,6 @@
 CCS_CFLAGS
 PKGCONFIGINIT_LIBS
 PKGCONFIGINIT_CFLAGS
-PKG_CONFIG_LIBDIR
-PKG_CONFIG_PATH
 PKG_CONFIG
 POW_LIB
 LIBOBJS
@@ -831,6 +829,7 @@
 enable_readline
 enable_realtime
 with_clvmd
+with_clvmd_pidfile
 enable_cmirrord
 with_cmirrord_pidfile
 enable_debug
@@ -877,8 +876,6 @@
 CPPFLAGS
 CPP
 PKG_CONFIG
-PKG_CONFIG_PATH
-PKG_CONFIG_LIBDIR
 PKGCONFIGINIT_CFLAGS
 PKGCONFIGINIT_LIBS
 CCS_CFLAGS
@@ -1580,6 +1577,8 @@
                            * all                   (autodetect)
                            * none                  (disable build)
                           [TYPE=none]
+  --with-clvmd-pidfile=PATH
+                          clvmd pidfile [/var/run/clvmd.pid]
   --with-cmirrord-pidfile=PATH
                           cmirrord pidfile [/var/run/cmirrord.pid]
   --with-optimisation=OPT C optimisation flag [OPT=-O2]
@@ -1617,10 +1616,6 @@
               you have headers in a nonstandard directory <include dir>
   CPP         C preprocessor
   PKG_CONFIG  path to pkg-config utility
-  PKG_CONFIG_PATH
-              directories to add to pkg-config's search path
-  PKG_CONFIG_LIBDIR
-              path overriding pkg-config's built-in search path
   PKGCONFIGINIT_CFLAGS
               C compiler flags for PKGCONFIGINIT, overriding pkg-config
   PKGCONFIGINIT_LIBS
@@ -11415,10 +11410,6 @@
 pkg_config_init() {
 
 
-
-
-
-
 if test "x$ac_cv_env_PKG_CONFIG_set" != "xset"; then
 	if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}pkg-config", so it can be a program name with args.
@@ -11531,6 +11522,7 @@
 $as_echo "no" >&6; }
 		PKG_CONFIG=""
 	fi
+
 fi
 
 pkg_failed=no
@@ -11573,8 +11565,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -11589,11 +11579,11 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$PKGCONFIGINIT_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: pkg-config initialized" >&5
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+                { $as_echo "$as_me:$LINENO: result: pkg-config initialized" >&5
 $as_echo "pkg-config initialized" >&6; }
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 	{ $as_echo "$as_me:$LINENO: result: pkg-config initialized" >&5
 $as_echo "pkg-config initialized" >&6; }
 else
@@ -11601,7 +11591,7 @@
 	PKGCONFIGINIT_LIBS=$pkg_cv_PKGCONFIGINIT_LIBS
         { $as_echo "$as_me:$LINENO: result: yes" >&5
 $as_echo "yes" >&6; }
-
+	:
 fi
 	PKGCONFIG_INIT=1
 }
@@ -11807,8 +11797,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -11823,7 +11811,9 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$CCS_PKG_ERRORS" >&5
 
-	NOTFOUND=0
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+                NOTFOUND=0
 
 for ac_header in ccs.h
 do
@@ -11980,8 +11970,6 @@
 			HAVE_CCS=yes
 		fi
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 	NOTFOUND=0
 
 for ac_header in ccs.h
@@ -12186,8 +12174,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -12202,7 +12188,9 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$GULM_PKG_ERRORS" >&5
 
-	NOTFOUND=0
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+                NOTFOUND=0
 
 for ac_header in libgulm.h
 do
@@ -12359,8 +12347,6 @@
 			HAVE_GULM=yes
 		fi
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 	NOTFOUND=0
 
 for ac_header in libgulm.h
@@ -12568,8 +12554,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -12584,7 +12568,9 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$CMAN_PKG_ERRORS" >&5
 
-	NOTFOUND=0
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+                NOTFOUND=0
 
 for ac_header in libcman.h
 do
@@ -12741,8 +12727,6 @@
 			HAVE_CMAN=yes
 		fi
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 	NOTFOUND=0
 
 for ac_header in libcman.h
@@ -12953,8 +12937,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -12969,10 +12951,10 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$COROSYNC_PKG_ERRORS" >&5
 
-	$bailout
-elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
 $as_echo "no" >&6; }
+                $bailout
+elif test $pkg_failed = untried; then
 	$bailout
 else
 	COROSYNC_CFLAGS=$pkg_cv_COROSYNC_CFLAGS
@@ -13026,8 +13008,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -13042,10 +13022,10 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$QUORUM_PKG_ERRORS" >&5
 
-	$bailout
-elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
 $as_echo "no" >&6; }
+                $bailout
+elif test $pkg_failed = untried; then
 	$bailout
 else
 	QUORUM_CFLAGS=$pkg_cv_QUORUM_CFLAGS
@@ -13100,8 +13080,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -13116,10 +13094,10 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$SALCK_PKG_ERRORS" >&5
 
-	$bailout
-elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
 $as_echo "no" >&6; }
+                $bailout
+elif test $pkg_failed = untried; then
 	$bailout
 else
 	SALCK_CFLAGS=$pkg_cv_SALCK_CFLAGS
@@ -13175,8 +13153,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -13191,10 +13167,10 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$CONFDB_PKG_ERRORS" >&5
 
-	HAVE_CONFDB=no
-elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
 $as_echo "no" >&6; }
+                HAVE_CONFDB=no
+elif test $pkg_failed = untried; then
 	HAVE_CONFDB=no
 else
 	CONFDB_CFLAGS=$pkg_cv_CONFDB_CFLAGS
@@ -13413,8 +13389,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -13429,10 +13403,10 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$CPG_PKG_ERRORS" >&5
 
-	$bailout
-elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
 $as_echo "no" >&6; }
+                $bailout
+elif test $pkg_failed = untried; then
 	$bailout
 else
 	CPG_CFLAGS=$pkg_cv_CPG_CFLAGS
@@ -13485,8 +13459,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -13501,7 +13473,9 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$DLM_PKG_ERRORS" >&5
 
-	NOTFOUND=0
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+                NOTFOUND=0
 
 for ac_header in libdlm.h
 do
@@ -13658,8 +13632,6 @@
 			HAVE_DLM=yes
 		fi
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 	NOTFOUND=0
 
 for ac_header in libdlm.h
@@ -13862,6 +13834,23 @@
 fi
 
 ################################################################################
+if test "x$CLVMD" != xnone; then
+
+# Check whether --with-clvmd-pidfile was given.
+if test "${with_clvmd_pidfile+set}" = set; then
+  withval=$with_clvmd_pidfile; CLVMD_PIDFILE=$withval
+else
+  CLVMD_PIDFILE="/var/run/clvmd.pid"
+fi
+
+
+cat >>confdefs.h <<_ACEOF
+#define CLVMD_PIDFILE "$CLVMD_PIDFILE"
+_ACEOF
+
+fi
+
+################################################################################
 { $as_echo "$as_me:$LINENO: checking whether to build cluster mirror log daemon" >&5
 $as_echo_n "checking whether to build cluster mirror log daemon... " >&6; }
 # Check whether --enable-cmirrord was given.
@@ -13939,8 +13928,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -13964,7 +13951,8 @@
 
 Alternatively, you may set the environment variables SACKPT_CFLAGS
 and SACKPT_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details." >&5
+See the pkg-config man page for more details.
+" >&5
 $as_echo "$as_me: error: Package requirements (libSaCkpt) were not met:
 
 $SACKPT_PKG_ERRORS
@@ -13974,11 +13962,10 @@
 
 Alternatively, you may set the environment variables SACKPT_CFLAGS
 and SACKPT_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details." >&2;}
+See the pkg-config man page for more details.
+" >&2;}
    { (exit 1); exit 1; }; }
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 	{ { $as_echo "$as_me:$LINENO: error: in \`$ac_pwd':" >&5
 $as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
 { { $as_echo "$as_me:$LINENO: error: The pkg-config script could not be found or is too old.  Make sure it
@@ -14007,7 +13994,7 @@
 	SACKPT_LIBS=$pkg_cv_SACKPT_LIBS
         { $as_echo "$as_me:$LINENO: result: yes" >&5
 $as_echo "yes" >&6; }
-
+	:
 fi
 	if test x$HAVE_CPG != xyes; then
 
@@ -14051,8 +14038,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -14076,7 +14061,8 @@
 
 Alternatively, you may set the environment variables CPG_CFLAGS
 and CPG_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details." >&5
+See the pkg-config man page for more details.
+" >&5
 $as_echo "$as_me: error: Package requirements (libcpg) were not met:
 
 $CPG_PKG_ERRORS
@@ -14086,11 +14072,10 @@
 
 Alternatively, you may set the environment variables CPG_CFLAGS
 and CPG_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details." >&2;}
+See the pkg-config man page for more details.
+" >&2;}
    { (exit 1); exit 1; }; }
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 	{ { $as_echo "$as_me:$LINENO: error: in \`$ac_pwd':" >&5
 $as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
 { { $as_echo "$as_me:$LINENO: error: The pkg-config script could not be found or is too old.  Make sure it
@@ -14119,7 +14104,7 @@
 	CPG_LIBS=$pkg_cv_CPG_LIBS
         { $as_echo "$as_me:$LINENO: result: yes" >&5
 $as_echo "yes" >&6; }
-
+	:
 fi
 	fi
 fi
--- LVM2/configure.in	2010/07/08 12:02:48	1.145
+++ LVM2/configure.in	2010/07/13 13:51:01	1.146
@@ -601,6 +601,18 @@
 fi
 
 ################################################################################
+dnl -- clvmd pidfile
+if test "x$CLVMD" != xnone; then
+	AC_ARG_WITH(clvmd-pidfile,
+		    AC_HELP_STRING([--with-clvmd-pidfile=PATH],
+				   [clvmd pidfile [[/var/run/clvmd.pid]]]),
+		    CLVMD_PIDFILE=$withval,
+		    CLVMD_PIDFILE="/var/run/clvmd.pid")
+	AC_DEFINE_UNQUOTED(CLVMD_PIDFILE, ["$CLVMD_PIDFILE"],
+			   [Path to clvmd pidfile.])
+fi
+
+################################################################################
 dnl -- Build cluster mirror log daemon
 AC_MSG_CHECKING(whether to build cluster mirror log daemon)
 AC_ARG_ENABLE(cmirrord,
--- LVM2/daemons/clvmd/clvmd.c	2010/06/21 15:56:58	1.72
+++ LVM2/daemons/clvmd/clvmd.c	2010/07/13 13:51:02	1.73
@@ -271,6 +271,11 @@
 	return buf;
 }
 
+static void remove_lockfile(void)
+{
+	unlink(CLVMD_PIDFILE);
+}
+
 int main(int argc, char *argv[])
 {
 	int local_sock;
@@ -370,6 +375,14 @@
 		be_daemon(start_timeout);
 	}
 
+	/* Create pidfile */
+	if (dm_create_lockfile(CLVMD_PIDFILE) == 0) {
+		DEBUGLOG("clvmd: unable to create lockfile\n");
+		exit(1);
+	}
+
+	atexit(remove_lockfile);
+
 	DEBUGLOG("CLVMD started\n");
 
 	/* Open the Unix socket we listen for commands on.
--- LVM2/daemons/cmirrord/clogd.c	2010/07/09 15:34:40	1.11
+++ LVM2/daemons/cmirrord/clogd.c	2010/07/13 13:51:02	1.12
@@ -65,49 +65,6 @@
 	exit_now = 1;
 }
 
-/*
- * create_lockfile - create and lock a lock file
- * @lockfile: location of lock file
- *
- * Returns: 0 on success, -1 otherwise
- */
-static int create_lockfile(const char *lockfile)
-{
-	int fd;
-	struct flock lock;
-	char buffer[50];
-
-	if((fd = open(lockfile, O_CREAT | O_WRONLY,
-		      (S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH))) < 0)
-		return -errno;
-
-	lock.l_type = F_WRLCK;
-	lock.l_start = 0;
-	lock.l_whence = SEEK_SET;
-	lock.l_len = 0;
-
-	if (fcntl(fd, F_SETLK, &lock) < 0) {
-		close(fd);
-		return -errno;
-	}
-
-	if (ftruncate(fd, 0) < 0) {
-		close(fd);
-		return -errno;
-	}
-
-	sprintf(buffer, "%d\n", getpid());
-
-	/* FIXME Handle other non-error returns without aborting */
-	if (write(fd, buffer, strlen(buffer)) < strlen(buffer)){
-		close(fd);
-		unlink(lockfile);
-		return -errno;
-	}
-
-	return 0;
-}
-
 static void sig_handler(int sig)
 {
 	/* FIXME Races - don't touch signal_mask here. */
@@ -162,6 +119,11 @@
 	}
 }
 
+static void remove_lockfile(void)
+{
+	unlink(CMIRRORD_PIDFILE);
+}
+
 /*
  * daemonize
  *
@@ -226,9 +188,11 @@
 
 	LOG_OPEN("cmirrord", LOG_PID, LOG_DAEMON);
 
-	if (create_lockfile(CMIRRORD_PIDFILE))
+	if (dm_create_lockfile(CMIRRORD_PIDFILE) == 0)
 		exit(EXIT_LOCKFILE);
 
+	atexit(remove_lockfile);
+
 	/* FIXME Replace with sigaction. (deprecated) */
 	signal(SIGINT, &sig_handler);
 	signal(SIGQUIT, &sig_handler);
--- LVM2/daemons/dmeventd/dmeventd.c	2010/07/09 15:34:41	1.63
+++ LVM2/daemons/dmeventd/dmeventd.c	2010/07/13 13:51:02	1.64
@@ -394,26 +394,6 @@
 	return pthread_mutex_unlock(&_global_mutex);
 }
 
-/* Store pid in pidfile. */
-static int _storepid(int lf)
-{
-	int len;
-	char pid[8];
-
-	if ((len = snprintf(pid, sizeof(pid), "%u\n", getpid())) < 0)
-		return 0;
-
-	if (len > (int) sizeof(pid))
-		len = (int) sizeof(pid);
-
-	if (write(lf, pid, (size_t) len) != len)
-		return 0;
-
-	fsync(lf);
-
-	return 1;
-}
-
 /* Check, if a device exists. */
 static int _fill_device_data(struct thread_status *ts)
 {
@@ -1541,23 +1521,6 @@
 
 }
 
-static int _lock_pidfile(void)
-{
-	int lf;
-	char pidfile[] = DMEVENTD_PIDFILE;
-
-	if ((lf = open(pidfile, O_CREAT | O_RDWR, 0644)) < 0)
-		exit(EXIT_OPEN_PID_FAILURE);
-
-	if (flock(lf, LOCK_EX | LOCK_NB) < 0)
-		exit(EXIT_LOCKFILE_INUSE);
-
-	if (!_storepid(lf))
-		exit(EXIT_FAILURE);
-
-	return 0;
-}
-
 #ifdef linux
 /*
  * Protection against OOM killer if kernel supports it
@@ -1589,6 +1552,11 @@
 }
 #endif
 
+static void remove_lockfile(void)
+{
+	unlink(DMEVENTD_PIDFILE);
+}
+
 static void _daemonize(void)
 {
 	int child_status;
@@ -1626,12 +1594,8 @@
 
 		/* Problem with child.  Determine what it is by exit code */
 		switch (WEXITSTATUS(child_status)) {
-		case EXIT_LOCKFILE_INUSE:
-			fprintf(stderr, "Another dmeventd daemon is already running\n");
-			break;
 		case EXIT_DESC_CLOSE_FAILURE:
 		case EXIT_DESC_OPEN_FAILURE:
-		case EXIT_OPEN_PID_FAILURE:
 		case EXIT_FIFO_FAILURE:
 		case EXIT_CHDIR_FAILURE:
 		default:
@@ -1717,7 +1681,10 @@
 
 	openlog("dmeventd", LOG_PID, LOG_DAEMON);
 
-	_lock_pidfile();		/* exits if failure */
+	if (dm_create_lockfile(DMEVENTD_PIDFILE) == 0)
+		exit(EXIT_FAILURE);
+
+	atexit(remove_lockfile);
 
 	/* Set the rest of the signals to cause '_exit_now' to be set */
 	signal(SIGINT, &_exit_handler);
--- LVM2/daemons/dmeventd/dmeventd.h	2007/08/21 16:26:06	1.5
+++ LVM2/daemons/dmeventd/dmeventd.h	2010/07/13 13:51:02	1.6
@@ -56,10 +56,10 @@
 
 /*      EXIT_SUCCESS             0 -- stdlib.h */
 /*      EXIT_FAILURE             1 -- stdlib.h */
-#define EXIT_LOCKFILE_INUSE      2
+/*      EXIT_LOCKFILE_INUSE      2 -- obsoleted */
 #define EXIT_DESC_CLOSE_FAILURE  3
 #define EXIT_DESC_OPEN_FAILURE   4
-#define EXIT_OPEN_PID_FAILURE    5
+/*      EXIT_OPEN_PID_FAILURE    5 -- obsoleted */
 #define EXIT_FIFO_FAILURE        6
 #define EXIT_CHDIR_FAILURE       7
 
--- LVM2/lib/misc/configure.h.in	2010/07/05 22:23:15	1.24
+++ LVM2/lib/misc/configure.h.in	2010/07/13 13:51:03	1.25
@@ -9,6 +9,9 @@
 /* Path to clvmd binary. */
 #undef CLVMD_PATH
 
+/* Path to clvmd pidfile. */
+#undef CLVMD_PIDFILE
+
 /* Path to cmirrord pidfile. */
 #undef CMIRRORD_PIDFILE
 
--- LVM2/libdm/libdevmapper.h	2010/07/09 15:34:47	1.120
+++ LVM2/libdm/libdevmapper.h	2010/07/13 13:51:03	1.121
@@ -980,6 +980,14 @@
 int dm_asprintf(char **buf, const char *format, ...)
     __attribute__ ((format(printf, 2, 3)));
 
+/*
+ * create lockfile (pidfile) - create and lock a lock file
+ * @lockfile: location of lock file
+ *
+ * Returns: 1 on success, 0 otherwise, errno is handled internally
+ */
+int dm_create_lockfile(const char* lockfile);
+
 /*********************
  * regular expressions
  *********************/
--- LVM2/libdm/libdm-file.c	2008/11/03 18:59:59	1.10
+++ LVM2/libdm/libdm-file.c	2010/07/13 13:51:03	1.11
@@ -84,3 +84,85 @@
 
 	return prev_fail || fclose_fail ? EOF : 0;
 }
+
+int dm_create_lockfile(const char *lockfile)
+{
+	int fd, value;
+	size_t bufferlen;
+	ssize_t write_out;
+	struct flock lock;
+	char buffer[50];
+
+	if((fd = open(lockfile, O_CREAT | O_WRONLY,
+		      (S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH))) < 0) {
+		log_error("Cannot open lockfile [%s], error was [%s]",
+			  lockfile, strerror(errno));
+		return 0;
+	}
+
+	lock.l_type = F_WRLCK;
+	lock.l_start = 0;
+	lock.l_whence = SEEK_SET;
+	lock.l_len = 0;
+	if (fcntl(fd, F_SETLK, &lock) < 0) {
+		if (errno != EACCES && errno != EAGAIN)
+			log_error("Cannot lock lockfile [%s], error was [%s]",
+				   lockfile, strerror(errno));
+		else
+			log_error("process is already running");
+
+		goto fail;
+	}
+
+	if (ftruncate(fd, 0) < 0) {
+		log_error("Cannot truncate pidfile [%s], error was [%s]",
+			  lockfile, strerror(errno));
+
+		goto fail;
+	}
+
+	memset(buffer, 0, sizeof(buffer));
+	snprintf(buffer, sizeof(buffer)-1, "%u\n", getpid());
+
+	bufferlen = strlen(buffer);
+	write_out = write(fd, buffer, bufferlen);
+
+	if ((write_out < 0) || (write_out == 0 && errno)) {
+		log_error("Cannot write pid to pidfile [%s], error was [%s]",
+			  lockfile, strerror(errno));
+
+		goto fail;
+	}
+
+	if ((write_out == 0) || (write_out < bufferlen)) {
+		log_error("Cannot write pid to pidfile [%s], shortwrite of"
+			  "[%" PRIsize_t "] bytes, expected [%" PRIsize_t "]\n",
+			  lockfile, write_out, bufferlen);
+
+		goto fail;
+	}
+
+	if ((value = fcntl(fd, F_GETFD, 0)) < 0) {
+		log_error("Cannot get close-on-exec flag from pidfile [%s], "
+			  "error was [%s]", lockfile, strerror(errno));
+
+		goto fail;
+	}
+	value |= FD_CLOEXEC;
+	if (fcntl(fd, F_SETFD, value) < 0) {
+		log_error("Cannot set close-on-exec flag from pidfile [%s], "
+			  "error was [%s]", lockfile, strerror(errno));
+
+		goto fail;
+	}
+
+	return 1;
+
+fail:
+	if (close(fd))
+		stack;
+	if (unlink(lockfile))
+		stack;
+
+	return 0;
+}


