From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 3 Jun 2009 11:31:08 -0000
Subject: LVM2/lib Makefile.in
Message-ID: <20090603113108.12820.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-03 11:31:08

Modified files:
	lib            : Makefile.in 

Log message:
	Build shared parts with 'make' command (mpatocka)
	
	When some parts of lvm are built as shared libraries (for example with
	--with-snapshots=shared), the 'make' command does not build these parts.
	The shared parts are built with 'make install' command.
	
	This bug can be seen if you go to 'lib' subdirectory and type 'make'.
	If you type 'make', the shared libraries are not built, if you type
	'make all', the shared libraries are built.
	
	The reason for the bug is the line $(SUBDIRS): $(LIB_STATIC)
	If make is executed without any arguments, it makes the first target
	in the Makefile. If the first target is '$(SUBDIRS): $(LIB_STATIC)',
	it only builds static libraries.
	
	This patch moves '$(SUBDIRS): $(LIB_STATIC)' after
	include $(top_srcdir)/make.tmpl. make.tmpl contains the 'all' target
	as its first target, so 'make' will be equivalent to 'make all' and
	shared libraries will be build with 'make' command.
	
	Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.91&r2=1.92

--- LVM2/lib/Makefile.in	2009/03/17 13:59:56	1.91
+++ LVM2/lib/Makefile.in	2009/06/03 11:31:06	1.92
@@ -143,12 +143,12 @@
 LIB_NAME = liblvm-internal
 LIB_STATIC = $(LIB_NAME).a
 
-$(SUBDIRS): $(LIB_STATIC)
-
 CLEAN_TARGETS += $(LIB_NAME).cflow
 
 include $(top_srcdir)/make.tmpl
 
+$(SUBDIRS): $(LIB_STATIC)
+
 $(LIB_NAME).cflow: $(SOURCES)
 	set -e; (echo -n "SOURCES += "; \
 		 echo $(SOURCES) | \


