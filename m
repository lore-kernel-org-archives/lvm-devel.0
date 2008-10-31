From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Oct 2008 22:29:45 -0000
Subject: LVM2 ./Makefile.in ./configure.in daemons/Make ...
Message-ID: <20081031222945.7508.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-10-31 22:29:44

Modified files:
	.              : Makefile.in configure.in 
	daemons        : Makefile.in 

Log message:
	dmeventd plugins move

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.82&r2=1.83
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/Makefile.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/Makefile.in	2008/06/27 19:24:17	1.23
+++ LVM2/Makefile.in	2008/10/31 22:29:44	1.24
@@ -24,13 +24,9 @@
 
 SUBDIRS += lib tools daemons
 
-ifeq ("@DMEVENTD@", "yes")
-  SUBDIRS += dmeventd
-endif
-
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS += daemons/clvmd \
-	     dmeventd \
+	     daemons/dmeventd/plugins \
 	     lib/format1 \
 	     lib/format_pool \
 	     lib/locking \
@@ -47,15 +43,13 @@
 daemons: lib
 lib: include
 tools: lib
-dmeventd: tools
-po: tools daemons dmeventd
+po: tools daemons
 
 ifeq ("@INTL@", "yes")
 lib.pofile: include.pofile
 tools.pofile: lib.pofile
 daemons.pofile: lib.pofile
-dmeventd.pofile: tools.pofile
-po.pofile: tools.pofile daemons.pofile dmeventd.pofile
+po.pofile: tools.pofile daemons.pofile
 pofile: po.pofile
 endif
 
--- LVM2/configure.in	2008/10/31 22:22:04	1.82
+++ LVM2/configure.in	2008/10/31 22:29:44	1.83
@@ -774,6 +774,7 @@
 daemons/clvmd/Makefile
 daemons/dmeventd/Makefile
 daemons/dmeventd/libdevmapper-event.pc
+daemons/dmeventd/plugins/Makefile
 daemons/dmeventd/plugins/mirror/Makefile
 daemons/dmeventd/plugins/snapshot/Makefile
 doc/Makefile
--- LVM2/daemons/Makefile.in	2007/09/21 10:16:43	1.3
+++ LVM2/daemons/Makefile.in	2008/10/31 22:29:44	1.4
@@ -19,5 +19,9 @@
   SUBDIRS = clvmd
 endif
 
+ifeq ("@DMEVENTD@", "yes")
+  SUBDIRS += dmeventd/plugins
+endif
+
 include $(top_srcdir)/make.tmpl
 


