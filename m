From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Aug 2009 20:51:42 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in da ...
Message-ID: <20090828205142.11856.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-08-28 20:51:41

Modified files:
	.              : WHATS_NEW configure configure.in 
	daemons        : Makefile.in 
	daemons/clogd  : Makefile.in clogd.c 
	lib/misc       : configure.h.in 

Log message:
	change clogd to cmirrord
	make pidfile locn configurable

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1245&r2=1.1246
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.101&r2=1.102
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.108&r2=1.109
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/Makefile.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/Makefile.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/clogd.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/WHATS_NEW	2009/08/28 19:22:05	1.1245
+++ LVM2/WHATS_NEW	2009/08/28 20:51:40	1.1246
@@ -5,7 +5,7 @@
   Fix pvcreate string termination in duplicate uuid warning message.
   Fix pvcreate on a partition (2.02.51).
   Fix vgcfgrestore error paths when locking fails (2.02.49).
-  Added configure --enable-clogd to conditionally build the cluster log daemon.
+  Added configure --enable-cmirrord to build the cluster mirror log daemon.
   Make lvchange --refresh only take a read lock on volume group.
   Fix bug where non-blocking file locks could be granted in error.
   Make lvm2app pv_t, lv_t, vg_t handle definitions consistent with lvm_t.
--- LVM2/configure	2009/08/28 19:22:05	1.101
+++ LVM2/configure	2009/08/28 20:51:40	1.102
@@ -688,13 +688,13 @@
 COPTIMISE_FLAG
 CONFDIR
 CMDLIB
-CLOGD
 CLVMD
 CLUSTER
 CLDWHOLEARCHIVE
 CLDNOWHOLEARCHIVE
 CLDFLAGS
 BUILD_DMEVENTD
+BUILD_CMIRRORD
 APPLIB
 MODPROBE_CMD
 MSGFMT
@@ -814,7 +814,8 @@
 enable_readline
 enable_realtime
 with_clvmd
-enable_clogd
+enable_cmirrord
+with_cmirrord_pidfile
 enable_debug
 with_optimisation
 enable_profiling
@@ -1502,7 +1503,7 @@
                           device-mapper is missing from the kernel
   --disable-readline      Disable readline support
   --disable-realtime      Disable realtime clock support
-  --enable-clogd          Enable the cluster log daemon
+  --enable-cmirrord       Enable the cluster mirror log daemon
   --enable-debug          Enable debugging
   --enable-profiling      Gather gcov profiling data
   --disable-devmapper     Disable LVM2 device-mapper interaction
@@ -1545,6 +1546,7 @@
                            * all                   (autodetect)
                            * none                  (disable build)
                           TYPE=none
+  --with-cmirrord-pidfile=PATH    cmirrord pidfile [/var/run/cmirrord.pid]
   --with-optimisation=OPT C optimisation flag [OPT=-O2]
   --with-localedir=DIR    Translation files in DIR [PREFIX/share/locale]
   --with-confdir=DIR      Configuration files in DIR [/etc]
@@ -11653,19 +11655,45 @@
 fi
 
 ################################################################################
-{ $as_echo "$as_me:$LINENO: checking whether to build cluster log daemon" >&5
-$as_echo_n "checking whether to build cluster log daemon... " >&6; }
-# Check whether --enable-clogd was given.
-if test "${enable_clogd+set}" = set; then
-  enableval=$enable_clogd; CLOGD=$enableval
+{ $as_echo "$as_me:$LINENO: checking whether to build cluster mirror log daemon" >&5
+$as_echo_n "checking whether to build cluster mirror log daemon... " >&6; }
+# Check whether --enable-cmirrord was given.
+if test "${enable_cmirrord+set}" = set; then
+  enableval=$enable_cmirrord; CMIRRORD=$enableval
+else
+  CMIRRORD=no
 fi
 
-{ $as_echo "$as_me:$LINENO: result: $CLOGD" >&5
-$as_echo "$CLOGD" >&6; }
+{ $as_echo "$as_me:$LINENO: result: $CMIRRORD" >&5
+$as_echo "$CMIRRORD" >&6; }
+
+BUILD_CMIRRORD=$CMIRRORD
+
+################################################################################
+
 
-if [ "x$CLOGD" = xall -o `expr x"$CLOGD" : '.*corosync.*'` != 0 ]; then
+if test "x$BUILD_CMIRRORD" = xyes; then
+
+# Check whether --with-cmirrord-pidfile was given.
+if test "${with_cmirrord_pidfile+set}" = set; then
+  withval=$with_cmirrord_pidfile;  cat >>confdefs.h <<_ACEOF
+#define CMIRRORD_PIDFILE "$withval"
+_ACEOF
+
+else
+   cat >>confdefs.h <<_ACEOF
+#define CMIRRORD_PIDFILE "/var/run/cmirrord.pid"
+_ACEOF
+
+fi
+
+fi
+
+################################################################################
+if [ "x$BUILD_CMIRRORD" = xyes ]; then
 #
 #       FIXME: ALSO NEED TO CHECK FOR CHECKPOINT MODULE
+#       FIXME: Merge this with the new clvmd logic
 #
 
 pkg_failed=no
--- LVM2/configure.in	2009/08/28 19:22:05	1.108
+++ LVM2/configure.in	2009/08/28 20:51:40	1.109
@@ -550,16 +550,30 @@
 fi
 
 ################################################################################
-dnl -- Build cluster log daemon
-AC_MSG_CHECKING(whether to build cluster log daemon)
-AC_ARG_ENABLE(clogd, [  --enable-clogd          Enable the cluster log daemon],
-CLOGD=$enableval)
-AC_MSG_RESULT($CLOGD)
+dnl -- Build cluster mirror log daemon
+AC_MSG_CHECKING(whether to build cluster mirror log daemon)
+AC_ARG_ENABLE(cmirrord, [  --enable-cmirrord       Enable the cluster mirror log daemon],
+CMIRRORD=$enableval, CMIRRORD=no)
+AC_MSG_RESULT($CMIRRORD)
+
+BUILD_CMIRRORD=$CMIRRORD
+
+################################################################################
+dnl -- cmirrord pidfile
+AH_TEMPLATE(CMIRRORD_PIDFILE, [Path to cmirrord pidfile.])
+if test "x$BUILD_CMIRRORD" = xyes; then
+	AC_ARG_WITH(cmirrord-pidfile,
+		    [  --with-cmirrord-pidfile=PATH    cmirrord pidfile [[/var/run/cmirrord.pid]] ],
+		    [ AC_DEFINE_UNQUOTED(CMIRRORD_PIDFILE,"$withval") ],
+		    [ AC_DEFINE_UNQUOTED(CMIRRORD_PIDFILE,"/var/run/cmirrord.pid") ])
+fi
 
+################################################################################
 dnl -- Look for corosync libraries if required.
-if [[ "x$CLOGD" = xall -o `expr x"$CLOGD" : '.*corosync.*'` != 0 ]]; then
+if [[ "x$BUILD_CMIRRORD" = xyes ]]; then
 #
 #       FIXME: ALSO NEED TO CHECK FOR CHECKPOINT MODULE
+#       FIXME: Merge this with the new clvmd logic
 #
 	PKG_CHECK_MODULES(CPG, libcpg, [],
 		[AC_MSG_RESULT([no pkg for libcpg library, using -lcpg]);
@@ -1007,6 +1021,7 @@
 
 ################################################################################
 AC_SUBST(APPLIB)
+AC_SUBST(BUILD_CMIRRORD)
 AC_SUBST(BUILD_DMEVENTD)
 AC_SUBST(CCS_CFLAGS)
 AC_SUBST(CCS_LIBS)
@@ -1017,7 +1032,6 @@
 AC_SUBST(CLDWHOLEARCHIVE)
 AC_SUBST(CLUSTER)
 AC_SUBST(CLVMD)
-AC_SUBST(CLOGD)
 AC_SUBST(CMAN_CFLAGS)
 AC_SUBST(CMAN_LIBS)
 AC_SUBST(CMDLIB)
--- LVM2/daemons/Makefile.in	2009/08/13 16:34:07	1.8
+++ LVM2/daemons/Makefile.in	2009/08/28 20:51:40	1.9
@@ -21,16 +21,16 @@
   SUBDIRS = clvmd
 endif
 
-ifeq ("@CLOGD@", "yes")
-  SUBDIRS += clogd
+ifeq ("@BUILD_CMIRRORD@", "yes")
+  SUBDIRS += cmirrord
 endif
 
-ifeq ("@DMEVENTD@", "yes")
+ifeq ("@BUILD_DMEVENTD@", "yes")
   SUBDIRS += dmeventd
 endif
 
 include $(top_srcdir)/make.tmpl
 
-ifeq ("@DMEVENTD@", "yes")
+ifeq ("@BUILD_DMEVENTD@", "yes")
 device-mapper: dmeventd.device-mapper
 endif
--- LVM2/daemons/clogd/Makefile.in	2009/08/13 20:51:41	1.1
+++ LVM2/daemons/clogd/Makefile.in	2009/08/28 20:51:41	1.2
@@ -17,22 +17,17 @@
 
 SOURCES = clogd.c cluster.c functions.c link_mon.c local.c logging.c
 
-ifeq ("@DEBUG@", "yes")
-	DEFS += -DDEBUG
-endif
-
-TARGETS = clogd
+TARGETS = cmirrord
 
 include $(top_srcdir)/make.tmpl
 
 LDFLAGS += -L$(usrlibdir)/openais
 LIBS += -lcpg -lSaCkpt -ldevmapper
 
-clogd: $(OBJECTS) $(top_srcdir)/lib/liblvm-internal.a
-	echo $(LIBS)
-	$(CC) -o clogd $(OBJECTS) $(CFLAGS) $(LDFLAGS) \
+cmirrord: $(OBJECTS) $(top_srcdir)/lib/liblvm-internal.a
+	$(CC) -o cmirrord $(OBJECTS) $(CFLAGS) $(LDFLAGS) \
 		$(LVMLIBS) $(LMLIBS) $(LIBS)
 
 install: $(TARGETS)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) clogd \
-		$(usrsbindir)/clogd
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) cmirrord \
+		$(usrsbindir)/cmirrord
--- LVM2/daemons/clogd/clogd.c	2009/08/13 16:34:07	1.4
+++ LVM2/daemons/clogd/clogd.c	2009/08/28 20:51:41	1.5
@@ -52,7 +52,7 @@
 	/* Parent can now exit, we're ready to handle requests */
 	kill(getppid(), SIGTERM);
 
-	LOG_PRINT("Starting clogd:");
+	LOG_PRINT("Starting cmirrord:");
 	LOG_PRINT(" Built: "__DATE__" "__TIME__"\n");
 	LOG_DBG(" Compiled with debugging.");
 
@@ -233,9 +233,9 @@
 	open("/dev/null", O_WRONLY); /* reopen stdout */
 	open("/dev/null", O_WRONLY); /* reopen stderr */
 
-	LOG_OPEN("clogd", LOG_PID, LOG_DAEMON);
+	LOG_OPEN("cmirrord", LOG_PID, LOG_DAEMON);
 
-	if (create_lockfile("/var/run/clogd.pid"))
+	if (create_lockfile(CMIRRORD_PIDFILE))
 		exit(EXIT_LOCKFILE);
 
 	signal(SIGINT, &sig_handler);
--- LVM2/lib/misc/configure.h.in	2009/08/28 19:22:05	1.11
+++ LVM2/lib/misc/configure.h.in	2009/08/28 20:51:41	1.12
@@ -6,6 +6,9 @@
 /* Define to 1 to include built-in support for clustered LVM locking. */
 #undef CLUSTER_LOCKING_INTERNAL
 
+/* Path to cmirrord pidfile. */
+#undef CMIRRORD_PIDFILE
+
 /* Define to one of `_getb67', `GETB67', `getb67' for Cray-2 and Cray-YMP
    systems. This function is required for `alloca.c' support on those systems.
    */


