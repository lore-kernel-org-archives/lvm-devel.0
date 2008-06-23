From: meyering@sourceware.org <meyering@sourceware.org>
Date: 23 Jun 2008 09:25:09 -0000
Subject: LVM2 ./WHATS_NEW ./configure.in ./make.tmpl.in ...
Message-ID: <20080623092509.7133.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2008-06-23 09:25:08

Modified files:
	.              : WHATS_NEW configure.in make.tmpl.in 
	dmeventd/mirror: Makefile.in 
	dmeventd/snapshot: Makefile.in 

Log message:
	avoid link failure when configuring without --enable-cmdlib
	
	* configure.in (LVM2CMD_LIB): Define if --enable-cmdlib.
	* dmeventd/mirror/Makefile.in (CLDFLAGS): Use $(LVM2CMD_LIB) rather
	than hard-coding -llvm2cmd.
	* dmeventd/snapshot/Makefile.in (CLDFLAGS): Likewise.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.909&r2=1.910
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2008/06/23 09:23:48	1.909
+++ LVM2/WHATS_NEW	2008/06/23 09:25:07	1.910
@@ -1,5 +1,6 @@
 Version 2.02.39 -
 ================================
+  Avoid link failure when configuring without --enable-cmdlib.
   Avoid link failure when configuring without --enable-readline.
   Make clvmd return immediately if other nodes are down in an openais cluster.
   Make clvmd return immediately if other nodes are down in a gulm cluster.
--- LVM2/configure.in	2008/06/23 09:23:48	1.70
+++ LVM2/configure.in	2008/06/23 09:25:07	1.71
@@ -350,6 +350,10 @@
 AC_ARG_ENABLE(cmdlib, [  --enable-cmdlib         Build shared command library],
 CMDLIB=$enableval, CMDLIB=no)
 AC_MSG_RESULT($CMDLIB)
+AC_SUBST([LVM2CMD_LIB])
+test $CMDLIB=yes \
+  && LVM2CMD_LIB=-llvm2cmd \
+  || LVM2CMD_LIB=
 
 ################################################################################
 dnl -- Enable fsadm
--- LVM2/make.tmpl.in	2008/05/19 20:06:33	1.52
+++ LVM2/make.tmpl.in	2008/06/23 09:25:07	1.53
@@ -1,7 +1,7 @@
 # @configure_input@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004, 2008 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
--- LVM2/dmeventd/mirror/Makefile.in	2007/09/21 10:16:43	1.5
+++ LVM2/dmeventd/mirror/Makefile.in	2008/06/23 09:25:07	1.6
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2005, 2008 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -17,7 +17,7 @@
 VPATH = @srcdir@
 
 INCLUDES += -I${top_srcdir}/tools
-CLDFLAGS += -L${top_srcdir}/tools -ldevmapper -llvm2cmd
+CLDFLAGS += -L${top_srcdir}/tools -ldevmapper $(LVM2CMD_LIB)
 
 SOURCES = dmeventd_mirror.c
 
@@ -33,4 +33,3 @@
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
 		$(libdir)/$<.$(LIB_VERSION)
 	$(LN_S) -f $<.$(LIB_VERSION) $(libdir)/$<
-
--- LVM2/dmeventd/snapshot/Makefile.in	2008/01/09 15:32:19	1.1
+++ LVM2/dmeventd/snapshot/Makefile.in	2008/06/23 09:25:08	1.2
@@ -17,7 +17,7 @@
 VPATH = @srcdir@
 
 INCLUDES += -I${top_srcdir}/tools
-CLDFLAGS += -L${top_srcdir}/tools -ldevmapper -llvm2cmd
+CLDFLAGS += -L${top_srcdir}/tools -ldevmapper $(LVM2CMD_LIB)
 
 SOURCES = dmeventd_snapshot.c
 
@@ -33,4 +33,3 @@
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
 		$(libdir)/$<.$(LIB_VERSION)
 	$(LN_S) -f $<.$(LIB_VERSION) $(libdir)/$<
-


