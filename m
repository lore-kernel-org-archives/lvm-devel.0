From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Mar 2010 11:21:08 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in ./ ...
Message-ID: <20100304112108.15590.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-04 11:21:06

Modified files:
	.              : WHATS_NEW configure configure.in make.tmpl.in 
	daemons/clvmd  : Makefile.in 
	daemons/dmeventd: Makefile.in 
	daemons/dmeventd/plugins/lvm2: Makefile.in 
	daemons/dmeventd/plugins/mirror: Makefile.in 
	daemons/dmeventd/plugins/snapshot: Makefile.in 
	test/api       : Makefile.in 
	tools          : Makefile.in 

Log message:
	Pthread linking change
	
	Create new substituted variable PTHREAD_LIBS and link this library
	only with tools/libs which really needs it - i.e. dmeventd.
	
	Check for libpthread only for builds with clvmd or dmeventd.
	
	Remove variable LIB_PTHREAD

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1449&r2=1.1450
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.117&r2=1.118
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.127&r2=1.128
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/Makefile.in.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.107&r2=1.108

--- LVM2/WHATS_NEW	2010/03/04 11:12:39	1.1449
+++ LVM2/WHATS_NEW	2010/03/04 11:21:05	1.1450
@@ -1,5 +1,9 @@
 Version 2.02.62 -
 ====================================
+  Update check for pthread library and link it only when needed.
+  Define and use internal makefile variable PTHREAD_LIBS.
+  Update check for readline library and link it only when needed.
+  Define and use internal makefile variable READLINE_LIBS.
   Define and use internal makefile variable LVMINTERNAL_LIBS.
   Help for configure prints --disable-fsadm.
   Use consistently $() instead of ${} for all Makefile variables.
--- LVM2/configure	2010/03/04 11:19:15	1.117
+++ LVM2/configure	2010/03/04 11:21:05	1.118
@@ -646,7 +646,6 @@
 missingkernel
 kerneldir
 interface
-LIB_PTHREAD
 UDEV_SYNC
 UDEV_RULES
 STATIC_LINK
@@ -654,6 +653,7 @@
 SNAPSHOTS
 SELINUX_LIBS
 READLINE_LIBS
+PTHREAD_LIBS
 POOL
 PKGCONFIG
 OWNER
@@ -12711,6 +12711,81 @@
 fi
 
 ################################################################################
+if [ "$DMEVENTD" = yes -o "$CLVMD" != none ] ; then
+	{ $as_echo "$as_me:$LINENO: checking for pthread_mutex_lock in -lpthread" >&5
+$as_echo_n "checking for pthread_mutex_lock in -lpthread... " >&6; }
+if test "${ac_cv_lib_pthread_pthread_mutex_lock+set}" = set; then
+  $as_echo_n "(cached) " >&6
+else
+  ac_check_lib_save_LIBS=$LIBS
+LIBS="-lpthread  $LIBS"
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+
+/* Override any GCC internal prototype to avoid an error.
+   Use char because int might match the return type of a GCC
+   builtin and then its argument prototype would still apply.  */
+#ifdef __cplusplus
+extern "C"
+#endif
+char pthread_mutex_lock ();
+int
+main ()
+{
+return pthread_mutex_lock ();
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
+  ac_cv_lib_pthread_pthread_mutex_lock=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_cv_lib_pthread_pthread_mutex_lock=no
+fi
+
+rm -rf conftest.dSYM
+rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
+      conftest$ac_exeext conftest.$ac_ext
+LIBS=$ac_check_lib_save_LIBS
+fi
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_lib_pthread_pthread_mutex_lock" >&5
+$as_echo "$ac_cv_lib_pthread_pthread_mutex_lock" >&6; }
+if test "x$ac_cv_lib_pthread_pthread_mutex_lock" = x""yes; then
+  PTHREAD_LIBS="-lpthread"
+else
+  hard_bailout
+fi
+
+fi
+
+################################################################################
 { $as_echo "$as_me:$LINENO: checking whether to enable selinux support" >&5
 $as_echo_n "checking whether to enable selinux support... " >&6; }
 # Check whether --enable-selinux was given.
--- LVM2/configure.in	2010/03/04 11:19:15	1.127
+++ LVM2/configure.in	2010/03/04 11:21:05	1.128
@@ -809,6 +809,12 @@
 fi
 
 ################################################################################
+if [[ "$DMEVENTD" = yes -o "$CLVMD" != none ]] ; then
+	AC_CHECK_LIB([pthread], [pthread_mutex_lock],
+		[PTHREAD_LIBS="-lpthread"], hard_bailout)
+fi
+
+################################################################################
 dnl -- Disable selinux
 AC_MSG_CHECKING(whether to enable selinux support)
 AC_ARG_ENABLE(selinux, [  --disable-selinux       Disable selinux support],
@@ -1125,6 +1131,7 @@
 AC_SUBST(OWNER)
 AC_SUBST(PKGCONFIG)
 AC_SUBST(POOL)
+AC_SUBST(PTHREAD_LIBS)
 AC_SUBST(QUORUM_CFLAGS)
 AC_SUBST(QUORUM_LIBS)
 AC_SUBST(READLINE_LIBS)
@@ -1138,7 +1145,6 @@
 AC_SUBST(STATIC_LINK)
 AC_SUBST(UDEV_RULES)
 AC_SUBST(UDEV_SYNC)
-AC_SUBST([LIB_PTHREAD])
 AC_SUBST(interface)
 AC_SUBST(kerneldir)
 AC_SUBST(missingkernel)
--- LVM2/make.tmpl.in	2010/03/04 11:19:15	1.79
+++ LVM2/make.tmpl.in	2010/03/04 11:21:05	1.80
@@ -37,6 +37,7 @@
 LDFLAGS += @LDFLAGS@
 LIB_SUFFIX = @LIB_SUFFIX@
 LVMINTERNAL_LIBS = -llvm-internal
+PTHREAD_LIBS = @PTHREAD_LIBS@
 READLINE_LIBS = @READLINE_LIBS@
 
 # Setup directory variables
--- LVM2/daemons/clvmd/Makefile.in	2010/03/04 11:12:39	1.34
+++ LVM2/daemons/clvmd/Makefile.in	2010/03/04 11:21:05	1.35
@@ -75,13 +75,14 @@
 TARGETS = \
 	clvmd
 
-LVMLIBS = $(LVMINTERNAL_LIBS) -lpthread
+LVMLIBS = $(LVMINTERNAL_LIBS)
 
 ifeq ("@DMEVENTD@", "yes")
 	LVMLIBS += -ldevmapper-event
 endif
  
 LVMLIBS += -ldevmapper
+LIBS += $(PTHREAD_LIBS)
 
 DEFS += -D_REENTRANT
 CFLAGS += -fno-strict-aliasing
--- LVM2/daemons/dmeventd/Makefile.in	2010/03/04 09:51:38	1.32
+++ LVM2/daemons/dmeventd/Makefile.in	2010/03/04 11:21:05	1.33
@@ -54,7 +54,7 @@
 device-mapper: $(TARGETS)
 
 LIBS += -ldl
-LVMLIBS += -ldevmapper-event -lpthread -ldevmapper
+LVMLIBS += -ldevmapper-event -ldevmapper $(PTHREAD_LIBS)
 
 $(VERSIONED_SHLIB): $(LIB_SHARED)
 	$(RM) -f $@
--- LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in	2010/03/04 09:56:01	1.2
+++ LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in	2010/03/04 11:21:05	1.3
@@ -29,7 +29,7 @@
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper @LIB_PTHREAD@ @LVM2CMD_LIB@
+LIBS += @LVM2CMD_LIB@ -ldevmapper $(PTHREAD_LIBS)
 
 install_lvm2: libdevmapper-event-lvm2.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
--- LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2010/03/04 09:56:01	1.15
+++ LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2010/03/04 11:21:06	1.16
@@ -32,7 +32,7 @@
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper @LIB_PTHREAD@ @LVM2CMD_LIB@ -ldevmapper-event-lvm2
+LIBS += @LVM2CMD_LIB@ -ldevmapper-event-lvm2 -ldevmapper $(PTHREAD_LIBS)
 
 install_lvm2: libdevmapper-event-lvm2mirror.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
--- LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2010/03/04 09:56:01	1.11
+++ LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2010/03/04 11:21:06	1.12
@@ -32,7 +32,7 @@
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper @LIB_PTHREAD@ @LVM2CMD_LIB@ -ldevmapper-event-lvm2
+LIBS += @LVM2CMD_LIB@ -ldevmapper-event-lvm2 -ldevmapper $(PTHREAD_LIBS)
 
 install_lvm2: libdevmapper-event-lvm2snapshot.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
--- LVM2/test/api/Makefile.in	2009/11/30 15:12:34	1.11
+++ LVM2/test/api/Makefile.in	2010/03/04 11:21:06	1.12
@@ -35,7 +35,7 @@
 LDFLAGS = -L$(top_builddir)/libdm -L$(top_builddir)/liblvm
 
 ifeq ("@DMEVENTD@", "yes")
-	LVMLIBS += -ldevmapper-event -lpthread
+	LVMLIBS += -ldevmapper-event
 	LDFLAGS += -L$(top_builddir)/daemons/dmeventd
 endif
 
--- LVM2/tools/Makefile.in	2010/03/04 11:19:16	1.107
+++ LVM2/tools/Makefile.in	2010/03/04 11:21:06	1.108
@@ -17,8 +17,6 @@
 top_builddir = @top_builddir@
 VPATH = @srcdir@
 
-LIB_PTHREAD = @LIB_PTHREAD@
-
 SOURCES =\
 	dumpconfig.c \
 	formats.c \
@@ -100,7 +98,7 @@
 endif
 
 ifeq ("@DMEVENTD@", "yes")
-	LVMLIBS += -ldevmapper-event -lpthread
+	LVMLIBS += -ldevmapper-event
 endif
 
 LVMLIBS += -ldevmapper
@@ -113,21 +111,21 @@
 
 dmsetup: dmsetup.o $(top_builddir)/libdm/libdevmapper.$(LIB_SUFFIX)
 	$(CC) $(CFLAGS) $(LDFLAGS) -L$(top_builddir)/libdm \
-	      -o $@ dmsetup.o -ldevmapper $(LIBS) $(LIB_PTHREAD)
+	      -o $@ dmsetup.o -ldevmapper $(LIBS)
 
 dmsetup.static: dmsetup.o $(interfacebuilddir)/libdevmapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) \
-	      -o $@ dmsetup.o -ldevmapper $(LIBS) $(LIB_PTHREAD)
+	      -o $@ dmsetup.o -ldevmapper $(LIBS)
 
 all: device-mapper
 
 lvm: $(OBJECTS) lvm.o $(top_builddir)/lib/liblvm-internal.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) lvm.o \
-		$(LVMLIBS) $(READLINE_LIBS) $(LIBS) $(LIB_PTHREAD) -rdynamic
+		$(LVMLIBS) $(READLINE_LIBS) $(LIBS) -rdynamic
 
 lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a  $(interfacebuilddir)/libdevmapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) -o $@ \
-	      $(OBJECTS) lvm-static.o $(LVMLIBS) $(LIBS) $(LIB_PTHREAD) \
+	      $(OBJECTS) lvm-static.o $(LVMLIBS) $(LIBS) \
 	      -rdynamic
 
 liblvm2cmd.a: $(top_builddir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.o lvm2cmd.o


