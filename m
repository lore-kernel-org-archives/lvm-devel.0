From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 19 Mar 2021 23:17:18 +0000 (GMT)
Subject: main - make: simplify dependency loading
Message-ID: <20210319231718.0F9EC386F411@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e86798203e4d2775aa418db6a17b908de7e15130
Commit:        e86798203e4d2775aa418db6a17b908de7e15130
Parent:        48d04afaa2015fe285b2ae499b7f06d0b25ae00d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 19 16:12:10 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 19 23:21:18 2021 +0100

make: simplify dependency loading

No need for extra ifdefs around.
---
 libdm/make.tmpl.in | 8 ++------
 make.tmpl.in       | 8 +-------
 2 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index 083fba9c3..549ef79d9 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -530,11 +530,7 @@ endif
 ifeq ("@USE_TRACKING@","yes")
 ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov \
  help check check_local check_cluster check_lvmpolld))
-    ifdef SOURCES
-       -include $(SOURCES:.c=.d) $(CXXSOURCES:.cpp=.d)
-    endif
-    ifdef SOURCES2
-       -include $(SOURCES2:.c=.d)
-    endif
+# Note: no tabs before -include
+    -include $(SOURCES:.c=.d) $(SOURCES2:.c=.d) $(CXXSOURCES:.cpp=.d)
 endif
 endif
diff --git a/make.tmpl.in b/make.tmpl.in
index 6f3f81915..75bb4f243 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -570,12 +570,6 @@ ifeq ("$(USE_TRACKING)","yes")
 ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov lcov-reset \
  help check check_local check_cluster check_lvmpolld run-unit-test tags))
 # Note: no tabs before -include
-    ifdef SOURCES
-       -include $(SOURCES:.c=.d) $(CXXSOURCES:.cpp=.d)
-    endif
-    ifdef SOURCES2
-       -include $(SOURCES2:.c=.d)
-    endif
-    DEPENDS = yes
+    -include $(SOURCES:.c=.d) $(SOURCES2:.c=.d) $(CXXSOURCES:.cpp=.d)
 endif
 endif


