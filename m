From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Feb 2012 18:25:49 -0000
Subject: LVM2/libdaemon Makefile.in
Message-ID: <20120228182549.25155.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-28 18:25:49

Added files:
	libdaemon      : Makefile.in 

Log message:
	Series of commits to move daemon code into separate top-level dir and
	fix build deps etc.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/Makefile.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/libdaemon/Makefile.in,v  -->  standard output
revision 1.1
--- LVM2/libdaemon/Makefile.in
+++ -	2012-02-28 18:25:49.262741000 +0000
@@ -0,0 +1,29 @@
+#
+# Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+srcdir = @srcdir@
+top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
+
+.PHONY: client server
+
+ifeq ("@BUILD_LVMETAD@", "yes")
+  SUBDIRS += client server
+server: client
+endif
+
+ifeq ($(MAKECMDGOALS),distclean)
+  SUBDIRS = client server
+endif
+
+include $(top_builddir)/make.tmpl


