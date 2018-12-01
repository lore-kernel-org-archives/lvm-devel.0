From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 30 Nov 2018 19:07:58 -0500
Subject: master - makefiles: ensure test dir can run unit-test
Message-ID: <201812010007.wB107wN4031203@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=250e05a9656bf8888ac6e399791c46369e77d667
Commit:        250e05a9656bf8888ac6e399791c46369e77d667
Parent:        a1e5b8832b99d977fda326e914a5d6d834316f42
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 1 00:44:22 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 1 01:05:53 2018 +0100

makefiles: ensure test dir can run unit-test

---
 test/Makefile.in   |    4 ++--
 test/unit/Makefile |    5 +++--
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index e471a11..69e2cfc 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -169,7 +169,7 @@ endif
 
 run-unit-test unit-test:
 	@echo "    [MAKE] $<"
-	$(Q) $(MAKE) -C unit $(@)
+	$(Q) $(MAKE) -C $(top_builddir) $(@)
 
 DATADIR = $(datadir)/lvm2-testsuite
 EXECDIR = $(libexecdir)/lvm2-testsuite
@@ -314,7 +314,7 @@ lib/dm-version-expected: $(top_srcdir)/VERSION_DM .lib-dir-stamp
 CMDS = lvm $(shell cat $(top_builddir)/tools/.commands 2>/dev/null)
 LIB = $(addprefix lib/, $(LIB_SECURETEST) $(LIB_DMSECURETEST) $(LIB_SHARED) $(LIB_LOCAL) $(LIB_NOT) $(LIB_LINK_NOT) $(LIB_FLAVOURS))
 
-.tests-stamp: $(ALL) $(LIB) $(SUBDIRS) lib/version-expected lib/dm-version-expected
+.tests-stamp: $(ALL) $(LIB) $(SUBDIRS) lib/version-expected lib/dm-version-expected unit-test
 	@echo "    [TEST-STAMP]"
 	@if test "$(srcdir)" != . ; then \
 		echo "Linking tests to builddir."; \
diff --git a/test/unit/Makefile b/test/unit/Makefile
index 909cef2..0ba98ee 100644
--- a/test/unit/Makefile
+++ b/test/unit/Makefile
@@ -41,9 +41,10 @@ CLEAN_TARGETS += $(UNIT_DEPENDS) $(UNIT_OBJECTS) \
 test/unit/unit-test: $(UNIT_OBJECTS) lib/liblvm-internal.a libdaemon/client/libdaemonclient.a $(INTERNAL_LIBS)
 	@echo "    [LD] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) \
-	      -o $@ $+ $(LIBS) $(DMEVENT_LIBS) $(SYSTEMD_LIBS) -lm -ldl -laio
+	      -o $@ $+ $(DMEVENT_LIBS) $(SYSTEMD_LIBS) $(LIBS) -ldl -laio
 
-.PHONEY: run-unit-test
+.PHONEY: run-unit-test unit-test
+unit-test: test/unit/unit-test
 run-unit-test: test/unit/unit-test
 	@echo Running unit tests
 	LD_LIBRARY_PATH=libdm test/unit/unit-test run


