From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 May 2015 22:20:04 +0000 (UTC)
Subject: master - makefiles: assign vars before include
Message-ID: <20150513222004.7654660CFB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a2c9ede6b38f2a454e1a18fc4cac9dd06af04972
Commit:        a2c9ede6b38f2a454e1a18fc4cac9dd06af04972
Parent:        b184d7a2ca03d0ad82cc37007578e8c9d4fa0497
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 13 23:42:17 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 14 00:19:33 2015 +0200

makefiles: assign vars before include

Before we include, set INCLUDE and TARGETS.
Extend CFLAGS after include.
---
 libdm/Makefile.in |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 8e057c3..852cab0 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -33,8 +33,7 @@ SOURCES =\
 	regex/ttree.c \
 	$(interface)/libdm-iface.c
 
-INCLUDES = -I$(srcdir)/$(interface) -I$(srcdir)
-CFLAGS += $(UDEV_CFLAGS) $(VALGRIND_CFLAGS)
+INCLUDES = -I$(srcdir)/$(interface)
 
 ifeq ("@STATIC_LINK@", "yes")
 LIB_STATIC = $(interface)/libdevmapper.a
@@ -42,7 +41,7 @@ endif
 
 LIB_SHARED = $(interface)/libdevmapper.$(LIB_SUFFIX)
 LIB_VERSION = $(LIB_VERSION_DM)
-TARGETS += libdevmapper.$(LIB_SUFFIX) libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION)
+TARGETS = libdevmapper.$(LIB_SUFFIX) libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION)
 
 CFLOW_LIST = $(SOURCES)
 CFLOW_LIST_TARGET = libdevmapper.cflow
@@ -52,6 +51,8 @@ EXPORTED_FN_PREFIX = dm
 
 include $(top_builddir)/make.tmpl
 
+CFLAGS += $(UDEV_CFLAGS) $(VALGRIND_CFLAGS)
+
 DEFS += -DDM_DEVICE_UID=@DM_DEVICE_UID@ -DDM_DEVICE_GID=@DM_DEVICE_GID@ \
 	-DDM_DEVICE_MODE=@DM_DEVICE_MODE@
 


