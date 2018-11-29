From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Nov 2018 17:12:38 -0500
Subject: master - makefiles: improving cleaning rules
Message-ID: <201811292212.wATMCcBT016600@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=98c21e98b2537d171d558363aaf6adeecc685aea
Commit:        98c21e98b2537d171d558363aaf6adeecc685aea
Parent:        f54ead831f3a7fcb26dcffe465189b8e052020a3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 29 21:47:11 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 29 23:05:43 2018 +0100

makefiles: improving cleaning rules

---
 base/Makefile          |   12 +++++++-----
 device_mapper/Makefile |   15 ++++++++++-----
 include/Makefile.in    |    2 +-
 libdm/Makefile.in      |    2 +-
 test/unit/Makefile     |    8 +++++---
 5 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/base/Makefile b/base/Makefile
index a4b0504..f150ad9 100644
--- a/base/Makefile
+++ b/base/Makefile
@@ -22,9 +22,11 @@ BASE_SOURCE=\
 	base/data-struct/hash.c \
 	base/data-struct/list.c
 
-BASE_DEPENDS=$(addprefix $(top_builddir)/,$(subst .c,.d,$(BASE_SOURCE)))
-BASE_OBJECTS=$(addprefix $(top_builddir)/,$(subst .c,.o,$(BASE_SOURCE)))
-CLEAN_TARGETS+=$(BASE_DEPENDS) $(BASE_OBJECTS)
+BASE_DEPENDS = $(BASE_SOURCE:%.c=%.d)
+BASE_OBJECTS = $(BASE_SOURCE:%.c=%.o)
+CLEAN_TARGETS += $(BASE_DEPENDS) $(BASE_OBJECTS) \
+	$(BASE_SOURCE:%.c=%.gcda) \
+	$(BASE_SOURCE:%.c=%.gcno)
 
 ifeq ("$(USE_TRACKING)","yes")
 ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov lcov-reset \
@@ -35,9 +37,9 @@ endif
 
 $(BASE_OBJECTS): INCLUDES+=-I$(top_srcdir)/base/
 
-$(top_builddir)/base/libbase.a: $(BASE_OBJECTS)
+base/libbase.a: $(BASE_OBJECTS)
 	@echo "    [AR] $@"
 	$(Q) $(RM) $@
 	$(Q) $(AR) rsv $@ $(BASE_OBJECTS) > /dev/null
 
-CLEAN_TARGETS+=$(top_builddir)/base/libbase.a
+CLEAN_TARGETS += base/libbase.a
diff --git a/device_mapper/Makefile b/device_mapper/Makefile
index 0177040..bb0880d 100644
--- a/device_mapper/Makefile
+++ b/device_mapper/Makefile
@@ -10,6 +10,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+# NOTE: this include only works as 'include' for toplevel Makefile
+#       which defined all top_* variables
+
 DEVICE_MAPPER_SOURCE=\
 	device_mapper/datastruct/bitset.c \
 	device_mapper/libdm-common.c \
@@ -28,9 +31,11 @@ DEVICE_MAPPER_SOURCE=\
 	device_mapper/vdo/vdo_target.c \
 	device_mapper/vdo/status.c
 
-DEVICE_MAPPER_DEPENDS=$(addprefix $(top_builddir)/,$(subst .c,.d,$(DEVICE_MAPPER_SOURCE)))
-DEVICE_MAPPER_OBJECTS=$(addprefix $(top_builddir)/,$(subst .c,.o,$(DEVICE_MAPPER_SOURCE)))
-CLEAN_TARGETS+=$(DEVICE_MAPPER_DEPENDS) $(DEVICE_MAPPER_OBJECTS)
+DEVICE_MAPPER_DEPENDS = $(DEVICE_MAPPER_SOURCE:%.c=%.d)
+DEVICE_MAPPER_OBJECTS = $(DEVICE_MAPPER_SOURCE:%.c=%.o)
+CLEAN_TARGETS += $(DEVICE_MAPPER_DEPENDS) $(DEVICE_MAPPER_OBJECTS) \
+	$(DEVICE_MAPPER_SOURCE:%.c=%.gcda) \
+	$(DEVICE_MAPPER_SOURCE:%.c=%.gcno)
 
 #$(DEVICE_MAPPER_DEPENDS): INCLUDES+=$(VDO_INCLUDES)
 #$(DEVICE_MAPPER_OBJECTS): INCLUDES+=$(VDO_INCLUDES)
@@ -44,9 +49,9 @@ endif
 
 $(DEVICE_MAPPER_OBJECTS): INCLUDES+=-I$(top_srcdir)/device_mapper/
 
-$(top_builddir)/device_mapper/libdevice-mapper.a: $(DEVICE_MAPPER_OBJECTS)
+device_mapper/libdevice-mapper.a: $(DEVICE_MAPPER_OBJECTS)
 	@echo "    [AR] $@"
 	$(Q) $(RM) $@
 	$(Q) $(AR) rsv $@ $(DEVICE_MAPPER_OBJECTS) > /dev/null
 
-CLEAN_TARGETS+=$(top_builddir)/device_mapper/libdevice-mapper.a
+CLEAN_TARGETS += device_mapper/libdevice-mapper.a
diff --git a/include/Makefile.in b/include/Makefile.in
index dd5dd68..d6c30d1 100644
--- a/include/Makefile.in
+++ b/include/Makefile.in
@@ -18,7 +18,7 @@ top_builddir = @top_builddir@
 
 include $(top_builddir)/make.tmpl
 
-DISTCLEAN_TARGETS += .configure.h lvm-version.h
+DISTCLEAN_TARGETS += configure.h lvm-version.h
 CLEAN_TARGETS += \
  .symlinks \
  .symlinks_created \
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 2a117e6..4ea83d0 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -105,4 +105,4 @@ install_ioctl_static: $(LIB_STATIC)
 	$(Q) $(INSTALL_DATA) -D $< $(usrlibdir)/$(<F)
 
 CLEAN_TARGETS += ioctl/libdevmapper.a
-DISTCLEAN_TARGETS += libdevmapper.pc
+DISTCLEAN_TARGETS += libdevmapper.pc make.tmpl
diff --git a/test/unit/Makefile b/test/unit/Makefile
index 44ab541..a37a0aa 100644
--- a/test/unit/Makefile
+++ b/test/unit/Makefile
@@ -31,9 +31,11 @@ UNIT_SOURCE=\
 
 test/unit/radix_tree_t.o: test/unit/rt_case1.c
 
-UNIT_DEPENDS=$(subst .c,.d,$(UNIT_SOURCE))
-UNIT_OBJECTS=$(UNIT_SOURCE:%.c=%.o)
-CLEAN_TARGETS+=$(UNIT_DEPENDS) $(UNIT_OBJECTS)
+UNIT_DEPENDS = $(UNIT_SOURCE:%.c=%.d)
+UNIT_OBJECTS = $(UNIT_SOURCE:%.c=%.o)
+CLEAN_TARGETS += $(UNIT_DEPENDS) $(UNIT_OBJECTS) \
+	$(UNIT_SOURCE:%.c=%.gcda) \
+	$(UNIT_SOURCE:%.c=%.gcno)
 
 test/unit/unit-test: $(UNIT_OBJECTS) lib/liblvm-internal.a libdaemon/client/libdaemonclient.a $(INTERNAL_LIBS)
 	@echo "    [LD] $@"


