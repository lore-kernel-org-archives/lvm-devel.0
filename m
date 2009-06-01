From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 1 Jun 2009 12:05:20 -0400 (EDT)
Subject: [PATCH] build the whole lvm with 'make' command
Message-ID: <Pine.LNX.4.64.0906011204190.16282@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Build shared parts with 'make' command

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

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com

---
 lib/Makefile.in |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: LVM2.2.02.47/lib/Makefile.in
===================================================================
--- LVM2.2.02.47.orig/lib/Makefile.in	2009-05-29 23:30:34.000000000 +0200
+++ LVM2.2.02.47/lib/Makefile.in	2009-05-29 23:30:53.000000000 +0200
@@ -143,12 +143,12 @@ endif
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


