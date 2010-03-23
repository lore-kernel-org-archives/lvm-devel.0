From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 23 Mar 2010 17:27:36 +0100
Subject: [PATCH 3/6] Fix cleanup of libdevmapper-event.a and dmeventd
In-Reply-To: <cover.1269361453.git.zkabelac@redhat.com>
References: <cover.1269361453.git.zkabelac@redhat.com>
Message-ID: <0b700093a39897556fe078a4d42a5d05032f97f2.1269361453.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add $(LIB_STATIC) to TARGETS so it's cleaned in the same way
as other libraries in project.
Add dmeventd.gcda dmeventd.gcno to CLEAN_TARGETS.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/dmeventd/Makefile.in |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index dc48f0d..948d908 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -26,9 +26,10 @@ TARGETS = dmeventd
 INSTALL_DMEVENTD_TARGETS = install_dmeventd_dynamic
 INSTALL_LIB_TARGETS = install_lib_dynamic
 
+LIB_NAME = libdevmapper-event
 ifeq ("@STATIC_LINK@", "yes")
-  LIB_STATIC = libdevmapper-event.a
-  TARGETS += dmeventd.static
+  LIB_STATIC = $(LIB_NAME).a
+  TARGETS += $(LIB_STATIC) dmeventd.static
   INSTALL_DMEVENTD_TARGETS += install_dmeventd_static
   INSTALL_LIB_TARGETS += install_lib_static
 endif
@@ -36,13 +37,13 @@ endif
 LIB_VERSION = $(LIB_VERSION_DM)
 
 ifeq ("@LIB_SUFFIX@","dylib")
-  LIB_SHARED = libdevmapper-event.dylib
+  LIB_SHARED = $(LIB_NAME).dylib
 else
-  LIB_SHARED = libdevmapper-event.so
+  LIB_SHARED = $(LIB_NAME).so
   VERSIONED_SHLIB = $(LIB_SHARED).$(LIB_VERSION)
 endif
 
-CLEAN_TARGETS = dmeventd.o dmeventd.static
+CLEAN_TARGETS = dmeventd.o dmeventd.static dmeventd.gcda dmeventd.gcno
 
 ifneq ($(MAKECMDGOALS),device-mapper)
   SUBDIRS+=plugins
-- 
1.7.0.1


