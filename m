From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Apr 2021 07:55:39 +0000 (GMT)
Subject: main - makefiles: deps also for cxx
Message-ID: <20210412075539.5B91C39FCC77@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ebf33323b93870f811c5a701826cfab1f4d41489
Commit:        ebf33323b93870f811c5a701826cfab1f4d41489
Parent:        75424dd6927ac38c97ca4acc78b7f4933cd7b139
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 10 01:21:33 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 12 09:54:16 2021 +0200

makefiles: deps also for cxx

Generate deps also for .cxx.
Remove include dir deps - there is nothing to build.
---
 Makefile.in        | 5 -----
 libdm/make.tmpl.in | 2 +-
 make.tmpl.in       | 2 +-
 3 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 5dd642f63..4dceaba1d 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -47,8 +47,6 @@ include $(top_srcdir)/base/Makefile
 include $(top_srcdir)/device_mapper/Makefile
 include $(top_srcdir)/test/unit/Makefile
 
-libdm: include
-libdaemon: include
 lib: libdaemon $(BASE_TARGET) $(DEVICE_MAPPER_TARGET)
 daemons: lib libdaemon tools
 scripts: lib
@@ -59,11 +57,8 @@ all_man: tools
 test: tools daemons
 unit-test  run-unit-test: test
 
-lib.device-mapper: include.device-mapper
-libdm.device-mapper: include.device-mapper
 daemons.device-mapper: libdm.device-mapper
 tools.device-mapper: libdm.device-mapper
-scripts.device-mapper: include.device-mapper
 device-mapper: tools.device-mapper daemons.device-mapper man.device-mapper
 device_mapper: device-mapper
 
diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index f7a5a7a73..a306101d5 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -403,7 +403,7 @@ DEFS+=-D_FILE_OFFSET_BITS=64
 %.o: %.cpp $(DEPS)
 	@echo "    [CXX] $(<F)"
 	@mkdir -p $(@D)
-	$(Q) $(CXX) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(CXXFLAGS) $(CXXFLAGS_$@) $< -o $@
+	$(Q) $(CXX) $(DEPFLAGS) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(CXXFLAGS) $(CXXFLAGS_$@) $< -o $@
 
 %.pot: %.c $(DEPS)
 	@echo "    [CC] $@"
diff --git a/make.tmpl.in b/make.tmpl.in
index 73bf298c7..6145b0bd5 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -454,7 +454,7 @@ DEFS+=-D_FILE_OFFSET_BITS=64
 %.o: %.cpp $(DEPS)
 	@echo "    [CXX] $(<F)"
 	@mkdir -p $(@D)
-	$(Q) $(CXX) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(CXXFLAGS) $(CXXFLAGS_$@) $< -o $@
+	$(Q) $(CXX) $(DEPFLAGS) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(CXXFLAGS) $(CXXFLAGS_$@) $< -o $@
 
 %.pot: %.c $(DEPS)
 	@echo "    [CC] $(<F)"


