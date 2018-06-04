From: Joe Thornber <thornber@sourceware.org>
Date: Mon, 4 Jun 2018 08:22:54 -0400
Subject: master - build: get separate builddir working again
Message-ID: <201806041222.w54CMsuA018622@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=29abba378520a270c3a9385724c8ef5df66497b1
Commit:        29abba378520a270c3a9385724c8ef5df66497b1
Parent:        66b10275c5ce7328cd5fb0f00a52de6c76e45481
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Jun 4 13:22:14 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Jun 4 13:22:14 2018 +0100

build: get separate builddir working again

---
 Makefile.in                       |    2 +-
 device_mapper/Makefile            |   10 +++++-----
 device_mapper/datastruct/bitset.c |    2 +-
 device_mapper/datastruct/hash.c   |    2 +-
 device_mapper/datastruct/list.c   |    2 +-
 device_mapper/ioctl/libdm-iface.c |   10 +++++-----
 device_mapper/mm/dbg_malloc.c     |    2 +-
 device_mapper/mm/pool-fast.c      |    2 +-
 device_mapper/mm/pool.c           |    2 +-
 device_mapper/regex/matcher.c     |    2 +-
 device_mapper/regex/parse_rx.c    |    2 +-
 device_mapper/regex/ttree.c       |    2 +-
 libdm/make.tmpl.in                |   29 ++++++++++++++++++++---------
 make.tmpl.in                      |   19 +++++++++++++------
 14 files changed, 53 insertions(+), 35 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 00b4f1e..851447e 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -213,7 +213,7 @@ endif
 endif
 
 include test/unit/Makefile
-include device_mapper/Makefile
+include $(top_srcdir)/device_mapper/Makefile
 
 ifneq ($(shell which ctags),)
 .PHONY: tags
diff --git a/device_mapper/Makefile b/device_mapper/Makefile
index 999c3ba..b246f82 100644
--- a/device_mapper/Makefile
+++ b/device_mapper/Makefile
@@ -30,17 +30,17 @@ DEVICE_MAPPER_SOURCE=\
 	device_mapper/regex/ttree.c \
 	device_mapper/ioctl/libdm-iface.c
 
-DEVICE_MAPPER_DEPENDS=$(subst .c,.d,$(DEVICE_MAPPER_SOURCE))
-DEVICE_MAPPER_OBJECTS=$(subst .c,.o,$(DEVICE_MAPPER_SOURCE))
+DEVICE_MAPPER_DEPENDS=$(addprefix $(top_builddir)/,$(subst .c,.d,$(DEVICE_MAPPER_SOURCE)))
+DEVICE_MAPPER_OBJECTS=$(addprefix $(top_builddir)/,$(subst .c,.o,$(DEVICE_MAPPER_SOURCE)))
 CLEAN_TARGETS+=$(DEVICE_MAPPER_DEPENDS) $(DEVICE_MAPPER_OBJECTS)
 
 -include $(DEVICE_MAPPER_DEPENDS)
 
-$(DEVICE_MAPPER_OBJECTS): INCLUDES+=-Idevice_mapper/
+$(DEVICE_MAPPER_OBJECTS): INCLUDES+=-I$(top_srcdir)/device_mapper/
 
-device_mapper/libdevice-mapper.a: $(DEVICE_MAPPER_OBJECTS)
+$(top_builddir)/device_mapper/libdevice-mapper.a: $(DEVICE_MAPPER_OBJECTS)
 	@echo "    [AR] $@"
 	$(Q) $(RM) $@
 	$(Q) $(AR) rsv $@ $(DEVICE_MAPPER_OBJECTS) > /dev/null
 
-CLEAN_TARGETS+=device_mapper/libdevice-mapper.a
+CLEAN_TARGETS+=$(top_builddir)/device_mapper/libdevice-mapper.a
diff --git a/device_mapper/datastruct/bitset.c b/device_mapper/datastruct/bitset.c
index 6ae99d3..f093ac0 100644
--- a/device_mapper/datastruct/bitset.c
+++ b/device_mapper/datastruct/bitset.c
@@ -13,7 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "misc/dmlib.h"
+#include "device_mapper/misc/dmlib.h"
 
 #include <ctype.h>
 
diff --git a/device_mapper/datastruct/hash.c b/device_mapper/datastruct/hash.c
index 9b9c939..59e719b 100644
--- a/device_mapper/datastruct/hash.c
+++ b/device_mapper/datastruct/hash.c
@@ -13,7 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "misc/dmlib.h"
+#include "device_mapper/misc/dmlib.h"
 
 struct dm_hash_node {
 	struct dm_hash_node *next;
diff --git a/device_mapper/datastruct/list.c b/device_mapper/datastruct/list.c
index 86c3e4e..bda8027 100644
--- a/device_mapper/datastruct/list.c
+++ b/device_mapper/datastruct/list.c
@@ -13,7 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "misc/dmlib.h"
+#include "device_mapper/misc/dmlib.h"
 #include <assert.h>
 
 /*
diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index 4825f1d..3e1b445 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -13,9 +13,9 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "misc/dmlib.h"
-#include "libdm-targets.h"
-#include "libdm-common.h"
+#include "device_mapper/misc/dmlib.h"
+#include "device_mapper/ioctl/libdm-targets.h"
+#include "device_mapper/libdm-common.h"
 
 #include <stddef.h>
 #include <fcntl.h>
@@ -26,7 +26,7 @@
 #include <unistd.h>
 
 #ifdef __linux__
-#  include "misc/kdev_t.h"
+#  include "device_mapper/misc/kdev_t.h"
 #  include <linux/limits.h>
 #else
 #  define MAJOR(x) major((x))
@@ -34,7 +34,7 @@
 #  define MKDEV(x,y) makedev((x),(y))
 #endif
 
-#include "misc/dm-ioctl.h"
+#include "device_mapper/misc/dm-ioctl.h"
 
 /*
  * Ensure build compatibility.  
diff --git a/device_mapper/mm/dbg_malloc.c b/device_mapper/mm/dbg_malloc.c
index a17203c..b169f8b 100644
--- a/device_mapper/mm/dbg_malloc.c
+++ b/device_mapper/mm/dbg_malloc.c
@@ -13,7 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "misc/dmlib.h"
+#include "device_mapper/misc/dmlib.h"
 
 #ifdef VALGRIND_POOL
 #include "memcheck.h"
diff --git a/device_mapper/mm/pool-fast.c b/device_mapper/mm/pool-fast.c
index 895872e..b83c693 100644
--- a/device_mapper/mm/pool-fast.c
+++ b/device_mapper/mm/pool-fast.c
@@ -17,7 +17,7 @@
 #include "memcheck.h"
 #endif
 
-#include "misc/dmlib.h"
+#include "device_mapper/misc/dmlib.h"
 #include <stddef.h>	/* For musl libc */
 #include <malloc.h>
 
diff --git a/device_mapper/mm/pool.c b/device_mapper/mm/pool.c
index a710704..20d7fd9 100644
--- a/device_mapper/mm/pool.c
+++ b/device_mapper/mm/pool.c
@@ -13,7 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "misc/dmlib.h"
+#include "device_mapper/misc/dmlib.h"
 #include <sys/mman.h>
 #include <pthread.h>
 
diff --git a/device_mapper/regex/matcher.c b/device_mapper/regex/matcher.c
index 375c1ab..b3870e0 100644
--- a/device_mapper/regex/matcher.c
+++ b/device_mapper/regex/matcher.c
@@ -13,7 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "misc/dmlib.h"
+#include "device_mapper/misc/dmlib.h"
 #include "parse_rx.h"
 #include "ttree.h"
 #include "assert.h"
diff --git a/device_mapper/regex/parse_rx.c b/device_mapper/regex/parse_rx.c
index cc83bfe..563d2ae 100644
--- a/device_mapper/regex/parse_rx.c
+++ b/device_mapper/regex/parse_rx.c
@@ -13,7 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "misc/dmlib.h"
+#include "device_mapper/misc/dmlib.h"
 #include "parse_rx.h"
 
 #ifdef DEBUG
diff --git a/device_mapper/regex/ttree.c b/device_mapper/regex/ttree.c
index 62c5bf7..27b775e 100644
--- a/device_mapper/regex/ttree.c
+++ b/device_mapper/regex/ttree.c
@@ -13,7 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "misc/dmlib.h"
+#include "device_mapper/misc/dmlib.h"
 #include "ttree.h"
 
 struct node {
diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index 7e3f4a4..b9672dc 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -58,6 +58,7 @@ PYTHON3 = @PYTHON3@
 PYCOMPILE = $(top_srcdir)/autoconf/py-compile
 
 LIBS = @LIBS@
+LIBS += $(SELINUX_LIBS) $(UDEV_LIBS) $(BLKID_LIBS) $(RT_LIBS) -lm
 # Extra libraries always linked with static binaries
 STATIC_LIBS = $(SELINUX_LIBS) $(UDEV_LIBS) $(BLKID_LIBS)
 DEFS += @DEFS@
@@ -68,7 +69,9 @@ CLDFLAGS += @CLDFLAGS@
 ELDFLAGS += @ELDFLAGS@
 LDDEPS += @LDDEPS@
 LIB_SUFFIX = @LIB_SUFFIX@
-LVMINTERNAL_LIBS = -llvm-internal $(DMEVENT_LIBS) $(DAEMON_LIBS) $(SYSTEMD_LIBS) $(UDEV_LIBS) $(DL_LIBS) $(BLKID_LIBS)
+LVMINTERNAL_LIBS=\
+	-llvm-internal \
+	$(DMEVENT_LIBS) $(DAEMON_LIBS) $(SYSTEMD_LIBS) $(UDEV_LIBS) $(DL_LIBS) $(BLKID_LIBS)
 DL_LIBS = @DL_LIBS@
 RT_LIBS = @RT_LIBS@
 M_LIBS = @M_LIBS@
@@ -308,6 +311,7 @@ LIB_VERSION_APP := $(shell $(AWK) -F '[(). ]' '{printf "%s.%s",$$1,$$4}' $(top_s
 
 INCLUDES += -I$(top_srcdir) -I$(srcdir) -I$(top_builddir)/include
 
+
 DEPS = $(top_builddir)/make.tmpl $(top_srcdir)/VERSION \
        $(top_builddir)/Makefile
 
@@ -338,7 +342,7 @@ SUBDIRS.distclean := $(SUBDIRS:=.distclean)
 
 TARGETS += $(LIB_SHARED) $(LIB_STATIC)
 
-all: $(SUBDIRS) $(TARGETS)
+all: $(top_builddir)/device_mapper/libdevice-mapper.a $(SUBDIRS) $(TARGETS)
 
 install: all $(SUBDIRS.install)
 install_cluster: all $(SUBDIRS.install_cluster)
@@ -347,7 +351,7 @@ install_lvm2: $(SUBDIRS.install_lvm2)
 install_ocf: $(SUBDIRS.install_ocf)
 cflow: $(SUBDIRS.cflow)
 
-$(SUBDIRS): $(SUBDIRS.device-mapper)
+$(SUBDIRS): $(SUBDIRS.device-mapper) $(top_builddir)/device_mapper/libdevice-mapper.a
 	$(MAKE) -C $@
 
 $(SUBDIRS.device-mapper):
@@ -440,14 +444,12 @@ endif
 
 .LIBPATTERNS = lib%.so lib%.a
 
-DEPFLAGS=-MT $@ -MMD -MP -MF $*.d
-
 # still needed in 2018 for 32bit builds
 DEFS+=-D_FILE_OFFSET_BITS=64
 
 %.o: %.c
 	@echo "    [CC] $<"
-	$(Q) $(CC) $(DEPFLAGS) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
+	$(Q) $(CC) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
 
 %.o: %.cpp
 	@echo "    [CXX] $<"
@@ -507,9 +509,18 @@ $(LIB_STATIC): $(OBJECTS)
 	$(Q) $(RM) $@
 	$(Q) $(AR) rsv $@ $(OBJECTS) > /dev/null
 
-%.d:
-.PRECIOUS: %.d
-	
+%.d: %.c
+	@echo "    [DEP] $<"
+	$(Q) $(MKDIR_P) $(dir $@); \
+	set -e; \
+	FILE=`echo $@ | sed 's/\\//\\\\\\//g;s/\\.d//g'`; \
+	DEPS=`echo $(DEPS) | sed -e 's/\\//\\\\\\//g'`; \
+	$(CC) -MM $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) -o $@ $<; \
+	sed -i "s/\(.*\)\.o[ :]*/$$FILE.o $$FILE.d $$FILE.pot: $$DEPS /g" $@; \
+	DEPLIST=`sed 's/ \\\\//;s/.*://;' < $@`; \
+	echo $$DEPLIST | fmt -1 | sed 's/ //g;s/\(.*\)/\1:/' >> $@; \
+	[ -s $@ ] || $(RM) $@
+
 %.mo: %.po
 	@echo "    [MSGFMT] $<"
 	$(Q) $(MSGFMT) -o $@ $<
diff --git a/make.tmpl.in b/make.tmpl.in
index 16a8571..b9672dc 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -444,14 +444,12 @@ endif
 
 .LIBPATTERNS = lib%.so lib%.a
 
-DEPFLAGS=-MT $@ -MMD -MP -MF $*.d
-
 # still needed in 2018 for 32bit builds
 DEFS+=-D_FILE_OFFSET_BITS=64
 
 %.o: %.c
 	@echo "    [CC] $<"
-	$(Q) $(CC) $(DEPFLAGS) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
+	$(Q) $(CC) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
 
 %.o: %.cpp
 	@echo "    [CXX] $<"
@@ -511,9 +509,18 @@ $(LIB_STATIC): $(OBJECTS)
 	$(Q) $(RM) $@
 	$(Q) $(AR) rsv $@ $(OBJECTS) > /dev/null
 
-%.d:
-.PRECIOUS: %.d
-	
+%.d: %.c
+	@echo "    [DEP] $<"
+	$(Q) $(MKDIR_P) $(dir $@); \
+	set -e; \
+	FILE=`echo $@ | sed 's/\\//\\\\\\//g;s/\\.d//g'`; \
+	DEPS=`echo $(DEPS) | sed -e 's/\\//\\\\\\//g'`; \
+	$(CC) -MM $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) -o $@ $<; \
+	sed -i "s/\(.*\)\.o[ :]*/$$FILE.o $$FILE.d $$FILE.pot: $$DEPS /g" $@; \
+	DEPLIST=`sed 's/ \\\\//;s/.*://;' < $@`; \
+	echo $$DEPLIST | fmt -1 | sed 's/ //g;s/\(.*\)/\1:/' >> $@; \
+	[ -s $@ ] || $(RM) $@
+
 %.mo: %.po
 	@echo "    [MSGFMT] $<"
 	$(Q) $(MSGFMT) -o $@ $<


