From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Nov 2018 17:12:31 -0500
Subject: master - makefiles: avoid dependency calcs for base dir
Message-ID: <201811292212.wATMCV09016571@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f54ead831f3a7fcb26dcffe465189b8e052020a3
Commit:        f54ead831f3a7fcb26dcffe465189b8e052020a3
Parent:        ceb2f0ad3b2c162a78f7ad1c86de9fd3f1dd0923
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 29 17:34:32 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 29 23:05:43 2018 +0100

makefiles: avoid dependency calcs for base dir

For some targets we do not want to generate dependencies.
Also add note about usage of such Makefile - it might be
possibly better to rename it to different filename to avoid
any confusion.
---
 base/Makefile          |   10 +++++++++-
 device_mapper/Makefile |    2 +-
 test/unit/Makefile     |    2 +-
 3 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/base/Makefile b/base/Makefile
index e30cb44..a4b0504 100644
--- a/base/Makefile
+++ b/base/Makefile
@@ -14,6 +14,9 @@
 # Comment to build the advanced radix tree.
 #base/data-struct/radix-tree.o: CFLAGS += -DSIMPLE_RADIX_TREE
 
+# NOTE: this include only works as 'include' for toplevel Makefile
+#       which defined all top_* variables
+
 BASE_SOURCE=\
 	base/data-struct/radix-tree.c \
 	base/data-struct/hash.c \
@@ -23,7 +26,12 @@ BASE_DEPENDS=$(addprefix $(top_builddir)/,$(subst .c,.d,$(BASE_SOURCE)))
 BASE_OBJECTS=$(addprefix $(top_builddir)/,$(subst .c,.o,$(BASE_SOURCE)))
 CLEAN_TARGETS+=$(BASE_DEPENDS) $(BASE_OBJECTS)
 
--include $(BASE_DEPENDS)
+ifeq ("$(USE_TRACKING)","yes")
+ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov lcov-reset \
+ help check check_local check_cluster check_lvmetad check_lvmpolld))
+	-include $(BASE_DEPENDS)
+endif
+endif
 
 $(BASE_OBJECTS): INCLUDES+=-I$(top_srcdir)/base/
 
diff --git a/device_mapper/Makefile b/device_mapper/Makefile
index d74a751..0177040 100644
--- a/device_mapper/Makefile
+++ b/device_mapper/Makefile
@@ -36,7 +36,7 @@ CLEAN_TARGETS+=$(DEVICE_MAPPER_DEPENDS) $(DEVICE_MAPPER_OBJECTS)
 #$(DEVICE_MAPPER_OBJECTS): INCLUDES+=$(VDO_INCLUDES)
 
 ifeq ("$(USE_TRACKING)","yes")
-ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov \
+ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov lcov-reset \
  help check check_local check_cluster check_lvmetad check_lvmpolld))
 	-include $(DEVICE_MAPPER_DEPENDS)
 endif
diff --git a/test/unit/Makefile b/test/unit/Makefile
index 0530fca..44ab541 100644
--- a/test/unit/Makefile
+++ b/test/unit/Makefile
@@ -46,7 +46,7 @@ run-unit-test: test/unit/unit-test
 	LD_LIBRARY_PATH=libdm test/unit/unit-test run
 
 ifeq ("$(USE_TRACKING)","yes")
-ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov \
+ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov lcov-reset \
  help check check_local check_lvmpolld run-unit-test))
 	-include $(UNIT_DEPENDS)
 endif


