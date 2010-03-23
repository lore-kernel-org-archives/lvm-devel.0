From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 23 Mar 2010 17:27:38 +0100
Subject: [PATCH 5/6] Fix distclean error for subtargets
In-Reply-To: <cover.1269361453.git.zkabelac@redhat.com>
References: <cover.1269361453.git.zkabelac@redhat.com>
Message-ID: <39d38d4ba06d0f3ae875acf5c3179fd411cab948.1269361453.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move daemons/ and lib/ subtargets to their Makefiles so we don't get
double cleanup error during execution of distclean target.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 Makefile.in         |   11 +----------
 daemons/Makefile.in |    4 ++++
 lib/Makefile.in     |    9 +++++++++
 3 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 967b026..5c64a9a 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -34,16 +34,7 @@ ifeq ("@APPLIB@", "yes")
 endif
 
 ifeq ($(MAKECMDGOALS),distclean)
-  SUBDIRS += daemons/clvmd \
-	     daemons/cmirrord \
-	     daemons/dmeventd/plugins \
-	     daemons/dmeventd \
-	     lib/format1 \
-	     lib/format_pool \
-	     lib/locking \
-	     lib/mirror \
-	     lib/snapshot \
-	     liblvm \
+  SUBDIRS += liblvm \
 	     udev \
 	     test/api \
 	     test \
diff --git a/daemons/Makefile.in b/daemons/Makefile.in
index a0e7268..1b4bcbb 100644
--- a/daemons/Makefile.in
+++ b/daemons/Makefile.in
@@ -30,6 +30,10 @@ ifeq ("@BUILD_DMEVENTD@", "yes")
   SUBDIRS += dmeventd
 endif
 
+ifeq ($(MAKECMDGOALS),distclean)
+  SUBDIRS = clvmd cmirrord dmeventd
+endif
+
 include $(top_builddir)/make.tmpl
 
 ifeq ("@BUILD_DMEVENTD@", "yes")
diff --git a/lib/Makefile.in b/lib/Makefile.in
index a2e66f3..c83dc89 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -152,6 +152,15 @@ LIB_STATIC = $(LIB_NAME).a
 
 CLEAN_TARGETS += $(LIB_NAME).cflow
 
+ifeq ($(MAKECMDGOALS),distclean)
+  SUBDIRS =\
+	format1 \
+	format_pool \
+	snapshot \
+	mirror \
+	locking
+endif
+
 include $(top_builddir)/make.tmpl
 
 $(SUBDIRS): $(LIB_STATIC)
-- 
1.7.0.1


