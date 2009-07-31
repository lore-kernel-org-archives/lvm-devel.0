From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Jul 2009 11:49:55 -0000
Subject: LVM2 ./WHATS_NEW ./make.tmpl.in ./configure.in ...
Message-ID: <20090731114955.23039.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-31 11:49:54

Modified files:
	.              : WHATS_NEW make.tmpl.in configure.in Makefile.in 
	lib/misc       : configure.h.in 

Log message:
	Prepare for udev synchronisation code.  (options don't work yet)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1218&r2=1.1219
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.103&r2=1.104
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/WHATS_NEW	2009/07/30 21:15:17	1.1218
+++ LVM2/WHATS_NEW	2009/07/31 11:49:53	1.1219
@@ -1,5 +1,7 @@
 Version 2.02.51 - 
 ================================
+  Added configure --enable-udev_rules --enable-udev_sync --with-udev-prefix.
+  Added udev dir to hold udev rules.
   Add --dataalignmentoffset to pvcreate to shift start of aligned data area.
   Fix _mda_setup() to not check first mda's size before pe_align rounding.
   Document -I option of clvmd in the man page.
--- LVM2/make.tmpl.in	2009/07/22 20:01:29	1.68
+++ LVM2/make.tmpl.in	2009/07/31 11:49:53	1.69
@@ -39,6 +39,7 @@
 # Setup directory variables
 prefix = @prefix@
 exec_prefix = @exec_prefix@
+udev_prefix = @udev_prefix@
 bindir = $(DESTDIR)@bindir@
 confdir = $(DESTDIR)@CONFDIR@/lvm
 includedir = $(DESTDIR)@includedir@
@@ -50,6 +51,7 @@
 mandir = $(DESTDIR)@mandir@
 localedir = $(DESTDIR)@LOCALEDIR@
 staticdir = $(DESTDIR)@STATICDIR@
+udevdir = $(DESTDIR)@udevdir@
 
 interface = @interface@
 interfacedir = $(top_srcdir)/libdm/$(interface)
--- LVM2/configure.in	2009/07/30 12:31:45	1.103
+++ LVM2/configure.in	2009/07/31 11:49:53	1.104
@@ -403,6 +403,23 @@
 fi
 
 ################################################################################
+dnl -- Enable udev synchronisation
+AC_MSG_CHECKING(whether to enable synchronisation with udev processing)
+AC_ARG_ENABLE(udev_sync, [  --enable-udev_sync      Enable synchronisation with udev processing],
+UDEV_SYNC=$enableval, UDEV_SYNC=no)
+AC_MSG_RESULT($UDEV_SYNC)
+
+if test x$UDEV_SYNC = xyes; then
+	AC_DEFINE([UDEV_SYNC_SUPPORT], 1, [Define to 1 to enable synchronisation with udev processing.])
+fi
+
+dnl -- Enable udev rules
+AC_MSG_CHECKING(whether to enable installation of udev rules required for synchronisation)
+AC_ARG_ENABLE(udev_rules, [  --enable-udev_rules     Install rule files needed for udev synchronisation],
+UDEV_RULES=$enableval, UDEV_RULES=$UDEV_SYNC)
+AC_MSG_RESULT($UDEV_RULES)
+
+################################################################################
 dnl -- Compatibility mode
 AC_ARG_ENABLE(compat,   [  --enable-compat         Enable support for old device-mapper versions],
   DM_COMPAT=$enableval, DM_COMPAT=no)
@@ -646,12 +663,12 @@
 
 ################################################################################
 AC_ARG_WITH(confdir,
-	    [  --with-confdir=DIR      Configuration files in DIR [/etc]],
+	    [  --with-confdir=DIR      Configuration files in DIR [[/etc]]],
 	    [ CONFDIR="$withval" ],
 	    [ CONFDIR='/etc' ])
 
 AC_ARG_WITH(staticdir,
-	    [  --with-staticdir=DIR    Static binary in DIR [EXEC_PREFIX/sbin]],
+	    [  --with-staticdir=DIR    Static binary in DIR [[EPREFIX/sbin]]],
 	    [ STATICDIR="$withval" ],
 	    [ STATICDIR='${exec_prefix}/sbin' ])
 
@@ -666,6 +683,14 @@
 	    [ usrsbindir='${prefix}/sbin' ])
 
 ################################################################################
+AC_ARG_WITH(udev_prefix,
+	    [  --with-udev-prefix=UPREFIX      Install udev rule files in UPREFIX [[EPREFIX]]],
+            [ udev_prefix="$withval"],
+            [ udev_prefix='${exec_prefix}' ])
+
+udevdir='${udev_prefix}/lib/udev/rules.d'
+
+################################################################################
 dnl -- Ensure additional headers required
 if test x$READLINE = xyes; then
 	AC_CHECK_HEADERS(readline/readline.h readline/history.h,,AC_MSG_ERROR(bailing out))
@@ -696,6 +721,10 @@
 	AC_CHECK_HEADERS(selinux/selinux.h,,AC_MSG_ERROR(bailing out))
 fi
 
+if test x$UDEV_SYNC = xyes; then
+	AC_CHECK_HEADERS(sys/ipc.h sys/sem.h,,AC_MSG_ERROR(bailing out))
+fi
+
 ################################################################################
 AC_PATH_PROG(MODPROBE_CMD, modprobe)
 
@@ -723,7 +752,7 @@
                 dmeventd_prefix=""
         fi
 	AC_ARG_WITH(dmeventd-path,
-		    [  --with-dmeventd-path=PATH       dmeventd path [[${exec_prefix}/sbin/dmeventd]] ],
+		    [  --with-dmeventd-path=PATH       dmeventd path [[EPREFIX/sbin/dmeventd]] ],
 		    [ AC_DEFINE_UNQUOTED(DMEVENTD_PATH,"$withval") ],
 		    [ AC_DEFINE_UNQUOTED(DMEVENTD_PATH,"$dmeventd_prefix/sbin/dmeventd") ])
 fi
@@ -818,12 +847,15 @@
 AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)
 AC_SUBST(STATIC_LINK)
+AC_SUBST(UDEV_RULES)
 AC_SUBST([LIB_PTHREAD])
 AC_SUBST(interface)
 AC_SUBST(kerneldir)
 AC_SUBST(missingkernel)
 AC_SUBST(kernelvsn)
 AC_SUBST(tmpdir)
+AC_SUBST(udev_prefix)
+AC_SUBST(udevdir)
 AC_SUBST(usrlibdir)
 AC_SUBST(usrsbindir)
 
@@ -860,6 +892,7 @@
 test/Makefile
 test/api/Makefile
 tools/Makefile
+udev/Makefile
 ])
 AC_OUTPUT
 
--- LVM2/Makefile.in	2009/05/22 14:44:59	1.33
+++ LVM2/Makefile.in	2009/07/31 11:49:53	1.34
@@ -18,6 +18,10 @@
 
 SUBDIRS = doc include man scripts
 
+ifeq ("@UDEV_RULES@", "yes")
+  SUBDIRS += udev
+endif
+
 ifeq ("@INTL@", "yes")
   SUBDIRS += po
 endif
--- LVM2/lib/misc/configure.h.in	2008/11/10 21:25:45	1.9
+++ LVM2/lib/misc/configure.h.in	2009/07/31 11:49:53	1.10
@@ -268,6 +268,9 @@
 /* Define to 1 if you have the <sys/ioctl.h> header file. */
 #undef HAVE_SYS_IOCTL_H
 
+/* Define to 1 if you have the <sys/ipc.h> header file. */
+#undef HAVE_SYS_IPC_H
+
 /* Define to 1 if you have the <sys/mman.h> header file. */
 #undef HAVE_SYS_MMAN_H
 
@@ -287,6 +290,9 @@
 /* Define to 1 if you have the <sys/select.h> header file. */
 #undef HAVE_SYS_SELECT_H
 
+/* Define to 1 if you have the <sys/sem.h> header file. */
+#undef HAVE_SYS_SEM_H
+
 /* Define to 1 if you have the <sys/socket.h> header file. */
 #undef HAVE_SYS_SOCKET_H
 
@@ -417,6 +423,9 @@
 /* Define to 1 if your <sys/time.h> declares `struct tm'. */
 #undef TM_IN_SYS_TIME
 
+/* Define to 1 to enable synchronisation with udev processing. */
+#undef UDEV_SYNC_SUPPORT
+
 /* Define to empty if `const' does not conform to ANSI C. */
 #undef const
 


