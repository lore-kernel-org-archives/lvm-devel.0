From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Feb 2012 18:26:41 -0000
Subject: LVM2/libdaemon client/Makefile.in server/Makef ...
Message-ID: <20120228182641.26171.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-28 18:26:40

Added files:
	libdaemon/client: Makefile.in 
	libdaemon/server: Makefile.in 

Log message:
	new makefiles

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/client/Makefile.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/server/Makefile.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/libdaemon/client/Makefile.in,v  -->  standard output
revision 1.1
--- LVM2/libdaemon/client/Makefile.in
+++ -	2012-02-28 18:26:41.200567000 +0000
@@ -0,0 +1,20 @@
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
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
+LIB_STATIC = libdaemonclient.a
+SOURCES = daemon-shared.c daemon-client.c
+
+include $(top_builddir)/make.tmpl
/cvs/lvm2/LVM2/libdaemon/server/Makefile.in,v  -->  standard output
revision 1.1
--- LVM2/libdaemon/server/Makefile.in
+++ -	2012-02-28 18:26:41.541492000 +0000
@@ -0,0 +1,22 @@
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
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
+LIB_STATIC = libdaemonserver.a
+SOURCES = daemon-server.c
+
+include $(top_builddir)/make.tmpl
+
+LIBS += $(DAEMON_LIBS)


