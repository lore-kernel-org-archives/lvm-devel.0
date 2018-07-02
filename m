From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 2 Jul 2018 04:26:43 -0400
Subject: master - build: avoid rebuild deps for top-level makefiles
Message-ID: <201807020826.w628Qh7Z025634@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=52b07672f867a4ec695ab1eff277f0a7f7d88087
Commit:        52b07672f867a4ec695ab1eff277f0a7f7d88087
Parent:        29b9ccd261be025aaf75e58e5d2547e818ef22c3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 1 15:16:18 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 2 10:21:42 2018 +0200

build: avoid rebuild deps for top-level makefiles

---
 device_mapper/Makefile |    7 ++++++-
 make.tmpl.in           |    3 ++-
 test/unit/Makefile     |    7 ++++++-
 3 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/device_mapper/Makefile b/device_mapper/Makefile
index 931431c..0a06a8b 100644
--- a/device_mapper/Makefile
+++ b/device_mapper/Makefile
@@ -30,7 +30,12 @@ DEVICE_MAPPER_DEPENDS=$(addprefix $(top_builddir)/,$(subst .c,.d,$(DEVICE_MAPPER
 DEVICE_MAPPER_OBJECTS=$(addprefix $(top_builddir)/,$(subst .c,.o,$(DEVICE_MAPPER_SOURCE)))
 CLEAN_TARGETS+=$(DEVICE_MAPPER_DEPENDS) $(DEVICE_MAPPER_OBJECTS)
 
--include $(DEVICE_MAPPER_DEPENDS)
+ifeq ("$(USE_TRACKING)","yes")
+ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov \
+ help check check_local check_cluster check_lvmetad check_lvmpolld))
+	-include $(DEVICE_MAPPER_DEPENDS)
+endif
+endif
 
 $(DEVICE_MAPPER_OBJECTS): INCLUDES+=-I$(top_srcdir)/device_mapper/
 
diff --git a/make.tmpl.in b/make.tmpl.in
index 38fdc73..dcdc093 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -88,6 +88,7 @@ BLKID_CFLAGS = @BLKID_CFLAGS@
 BLKID_LIBS = @BLKID_LIBS@
 SYSTEMD_LIBS = @SYSTEMD_LIBS@
 VALGRIND_CFLAGS = @VALGRIND_CFLAGS@
+USE_TRACKING = @USE_TRACKING@
 
 # Setup directory variables
 prefix = @prefix@
@@ -577,7 +578,7 @@ else
 	) > $@
 endif
 
-ifeq ("@USE_TRACKING@","yes")
+ifeq ("$(USE_TRACKING)","yes")
 ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov \
  help check check_local check_cluster check_lvmetad check_lvmpolld))
     ifdef SOURCES
diff --git a/test/unit/Makefile b/test/unit/Makefile
index 9155c47..6fb6401 100644
--- a/test/unit/Makefile
+++ b/test/unit/Makefile
@@ -43,4 +43,9 @@ run-unit-test: test/unit/unit-test
 	@echo Running unit tests
 	LD_LIBRARY_PATH=libdm test/unit/unit-test run
 
--include $(UNIT_DEPENDS)
+ifeq ("$(USE_TRACKING)","yes")
+ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov \
+ help check check_local check_cluster check_lvmetad check_lvmpolld))
+	-include $(UNIT_DEPENDS)
+endif
+endif


