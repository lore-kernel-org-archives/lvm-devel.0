From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 25 Oct 2020 19:36:59 +0000 (GMT)
Subject: stable-2.02 - make: remove file from master
Message-ID: <20201025193659.296A8388701C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=66ea26131ba1f6206eafe49c9c581a02fab00395
Commit:        66ea26131ba1f6206eafe49c9c581a02fab00395
Parent:        bb5f81624bc03d17a7e4ec57417b6bbcc5dc8ab8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 25 16:02:33 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 25 17:36:04 2020 +0100

make: remove file from master

To ensure lcov creation is not trying to pick wrong files
when using same machine for building stable-2.02 and master branch,
ensure the new files are being deleted even in stable-2.02
branch for  'make clean & make distclean' targets
---
 base/Makefile     |  6 ++++++
 lib/Makefile.in   | 12 ++++++++++++
 libdm/Makefile.in |  5 +++++
 3 files changed, 23 insertions(+)

diff --git a/base/Makefile b/base/Makefile
index 056ea5910..69ea118fc 100644
--- a/base/Makefile
+++ b/base/Makefile
@@ -33,6 +33,12 @@ $(BASE_TARGET): $(BASE_OBJECTS)
 	$(Q) $(RM) $@
 	$(Q) $(AR) rsv $@ $(BASE_OBJECTS) > /dev/null
 
+ifneq (,$(findstring $(MAKECMDGOALS),clean distclean))
+   BASE_SOURCE += \
+	base/data-struct/hash.c \
+	base/data-struct/list.c
+endif
+
 ifeq ("$(DEPENDS)","yes")
 -include $(BASE_DEPENDS)
 endif
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 1d422354c..358b7a704 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -152,6 +152,18 @@ CFLOW_LIST_TARGET = $(LIB_NAME).cflow
 
 PROGS_CFLAGS = $(BLKID_CFLAGS) $(UDEV_CFLAGS)
 
+ifneq (,$(findstring $(MAKECMDGOALS),clean distclean))
+   SOURCES += \
+	integrity/integrity.c \
+	label/hints.c \
+	metadata/integrity_manip.c \
+	metadata/pv_list.c \
+	metadata/vdo_manip.c \
+	metadata/writecache_manip.c \
+	vdo/vdo.c \
+	writecache/writecache.c
+endif
+
 include $(top_builddir)/make.tmpl
 
 $(SUBDIRS): $(LIB_STATIC)
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 66ec39513..46e55f089 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -36,6 +36,11 @@ SOURCES =\
 	regex/ttree.c \
 	$(interface)/libdm-iface.c
 
+ifneq (,$(findstring $(MAKECMDGOALS),clean distclean))
+   SOURCES += \
+	dm-tools/dmsetup.c
+endif
+
 INCLUDES = -I$(srcdir)/$(interface)
 
 ifeq ("@STATIC_LINK@", "yes")


