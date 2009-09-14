From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 14 Sep 2009 18:36:21 -0400
Subject: [PATCH] Fix build failure when enabling dmeventd and applib.
Message-ID: <1252967781-10182-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch fixes a build with options similar to the following:
./configure --enable-debug --enable-applib --enable-dmeventd --enable-cmdlib

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/Makefile.in   |    4 ++++
 test/api/Makefile.in |    5 +++++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index 305cef5..e1d18f3 100644
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -42,6 +42,10 @@ include $(top_srcdir)/make.tmpl
 
 LIBS += -ldevmapper -llvm-internal
 
+ifeq ("@DMEVENTD@", "yes")
+  LIBS += -ldevmapper-event
+endif
+
 $(VERSIONED_SHLIB): %.$(LIB_SUFFIX).$(LIB_VERSION_APP): %.$(LIB_SUFFIX)
 	rm -f $@
 	$(LN_S) $< $@
diff --git a/test/api/Makefile.in b/test/api/Makefile.in
index e280a53..0c784bd 100644
--- a/test/api/Makefile.in
+++ b/test/api/Makefile.in
@@ -33,6 +33,11 @@ include $(top_srcdir)/make.tmpl
 
 LDFLAGS = -L$(top_srcdir)/libdm -L$(top_srcdir)/liblvm
 
+ifeq ("@DMEVENTD@", "yes")
+	LVMLIBS += -ldevmapper-event -lpthread
+	LDFLAGS += -L$(top_srcdir)/daemons/dmeventd
+endif
+
 test_OBJECTS = $(test_SOURCES:.c=.o)
 vgtest_OBJECTS = $(vgtest_SOURCES:.c=.o)
 OBJECTS = $(test_OBJECTS) $(vgtest_OBJECTS)
-- 
1.6.0.6


