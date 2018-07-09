From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 04:34:27 -0400
Subject: master - build: unit test Makefile update
Message-ID: <201807090834.w698YRCH024641@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4a64bb9573bb3c54cfac0b4f588cd80dba01d60d
Commit:        4a64bb9573bb3c54cfac0b4f588cd80dba01d60d
Parent:        5cf0923e1840375d23c4fd6035b919613ce6573b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 9 10:05:19 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 10:30:34 2018 +0200

build: unit test Makefile update

Update makefile to link with more libs since now whole liblvm-internal.a
is linked-in and  this library has futher dependencies.

Avoid including deps for run-unit-test.

Drop linking separate status.c as it's already linked via internal libs.
---
 test/unit/Makefile |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/test/unit/Makefile b/test/unit/Makefile
index 6fb6401..aeed2d7 100644
--- a/test/unit/Makefile
+++ b/test/unit/Makefile
@@ -11,8 +11,6 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 UNIT_SOURCE=\
-	device_mapper/vdo/status.c \
-	\
 	test/unit/activation-generator_t.c \
 	test/unit/bcache_t.c \
 	test/unit/bcache_utils_t.c \
@@ -36,7 +34,7 @@ CLEAN_TARGETS+=$(UNIT_DEPENDS) $(UNIT_OBJECTS)
 test/unit/unit-test: $(UNIT_OBJECTS) lib/liblvm-internal.a libdaemon/client/libdaemonclient.a $(INTERNAL_LIBS)
 	@echo "    [LD] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) \
-	      -o $@ $+ $(LIBS) -lm -ldl -laio
+	      -o $@ $+ $(LIBS) $(DMEVENT_LIBS) $(SYSTEMD_LIBS) -lm -ldl -laio
 
 .PHONEY: run-unit-test
 run-unit-test: test/unit/unit-test
@@ -45,7 +43,7 @@ run-unit-test: test/unit/unit-test
 
 ifeq ("$(USE_TRACKING)","yes")
 ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov \
- help check check_local check_cluster check_lvmetad check_lvmpolld))
+ help check check_local check_cluster check_lvmetad check_lvmpolld run-unit-test))
 	-include $(UNIT_DEPENDS)
 endif
 endif


