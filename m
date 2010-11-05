From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 5 Nov 2010 16:10:10 -0000
Subject: LVM2/include Makefile.in
Message-ID: <20101105161010.17169.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-05 16:10:08

Modified files:
	include        : Makefile.in 

Log message:
	Use include make.tmpl
	
	Makes easier to use recursive targets and simplifies Makefile.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/Makefile.in.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/include/Makefile.in	2010/08/02 13:17:04	1.14
+++ LVM2/include/Makefile.in	2010/11/05 16:10:08	1.15
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -12,15 +12,11 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-SHELL = /bin/sh
-
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-LN_S = @LN_S@
-
-.PHONY: clean distclean all install pofile install_cluster install_device-mapper
+include $(top_builddir)/make.tmpl
 
 all: .symlinks_created
 
@@ -37,14 +33,4 @@
 
 device-mapper: all
 
-clean:
-
-install:
-
-install_cluster:
-
-install_device-mapper:
-
-install_lvm2:
-
 cflow: all


