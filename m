From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Mar 2015 20:17:37 +0000 (UTC)
Subject: master - makefiles: split gcc -W options
Message-ID: <20150311201737.9C05360242@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e7e499e80fa31c7c465d43e11e14c2342477ee53
Commit:        e7e499e80fa31c7c465d43e11e14c2342477ee53
Parent:        8a2b9f045fffd4e9d9450477b946af31dde5848f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 11 15:41:03 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 11 21:17:23 2015 +0100

makefiles: split gcc -W options

Avoid using gcc only Warnings for compilation of g++ object files.
---
 make.tmpl.in |   52 ++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 38 insertions(+), 14 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 11721f1..3a8597a 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -142,21 +142,45 @@ INSTALL_SCRIPT = $(INSTALL) -p $(M_INSTALL_PROGRAM)
 
 .SUFFIXES: .c .cpp .d .o .so .a .po .pot .mo .dylib
 
-WFLAGS += -Wall -Wundef -Wshadow -Wcast-align -Wwrite-strings \
- -Wmissing-prototypes -Wmissing-declarations -Wnested-externs \
- -Winline -Wmissing-noreturn -Wformat-security -Wredundant-decls \
- -Wpointer-arith -Wuninitialized -Wmissing-include-dirs \
- -Wfloat-equal -Wstrict-prototypes \
- -Wold-style-definition -Wmissing-format-attribute
+WFLAGS +=\
+ -Wall\
+ -Wcast-align\
+ -Wfloat-equal\
+ -Wformat-security\
+ -Winline\
+ -Wmissing-declarations\
+ -Wmissing-format-attribute\
+ -Wmissing-include-dirs\
+ -Wmissing-noreturn\
+ -Wpointer-arith\
+ -Wredundant-decls\
+ -Wshadow\
+ -Wundef\
+ -Wuninitialized\
+ -Wwrite-strings
+
+WCFLAGS +=\
+ -Wmissing-prototypes\
+ -Wnested-externs\
+ -Wold-style-definition\
+ -Wstrict-prototypes
 
 ifeq ("@HAVE_WJUMP@", "yes")
-WFLAGS += -Wjump-misses-init
+WCFLAGS += -Wjump-misses-init
 endif
 
 ifeq ("@HAVE_WCLOBBERED@", "yes")
-WFLAGS += -Wclobbered -Wempty-body -Wignored-qualifiers \
- -Wmissing-parameter-type -Wold-style-declaration -Woverride-init \
- -Wtype-limits -Wlogical-op
+WFLAGS +=\
+ -Wclobbered\
+ -Wempty-body\
+ -Wignored-qualifiers\
+ -Wlogical-op\
+ -Wtype-limits
+
+WCFLAGS +=\
+ -Wmissing-parameter-type\
+ -Wold-style-declaration\
+ -Woverride-init
 endif
 
 ifeq ("@HAVE_WSYNCNAND@", "yes")
@@ -174,7 +198,7 @@ endif
 endif
 
 #WFLAGS += -W -Wno-sign-compare -Wno-unused-parameter -Wno-missing-field-initializers
-#WFLAGS += -Wsign-compare -Wunused-parameter -Wmissing-field-initializers 
+#WFLAGS += -Wsign-compare -Wunused-parameter -Wmissing-field-initializers
 #WFLAGS += -Wconversion -Wbad-function-cast -Wcast-qual -Waggregate-return -Wpacked
 #WFLAGS += -pedantic -std=gnu99
 #DEFS += -DDEBUG_CRC32
@@ -372,7 +396,7 @@ endif
 $(TARGETS): $(OBJECTS)
 
 %.o: %.c
-	$(CC) -c $(INCLUDES) $(DEFS) $(WFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
+	$(CC) -c $(INCLUDES) $(DEFS) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
 
 %.o: %.cpp
 	$(CXX) -c $(INCLUDES) $(DEFS) $(WFLAGS) $(CXXFLAGS) $(CXXFLAGS_$@) $< -o $@
@@ -405,7 +429,7 @@ install_lib_shared: $(LIB_SHARED)
 	$(INSTALL_DIR) $(usrlibdir)
 	$(LN_S) -f $(USRLIB_RELPATH)$(<F).$(LIB_VERSION) $(usrlibdir)/$(<F)
 
-# FIXME: plugins are installed to subdirs 
+# FIXME: plugins are installed to subdirs
 #        and for compatibility links in libdir are created
 #        when the code is fixed links could be removed.
 install_dm_plugin: $(LIB_SHARED)
@@ -446,7 +470,7 @@ clean: $(SUBDIRS.clean) cleandir
 
 distclean: cleandir $(SUBDIRS.distclean)
 	test -z "$(DISTCLEAN_DIRS)" || $(RM) -r $(DISTCLEAN_DIRS)
-	$(RM) $(DISTCLEAN_TARGETS) Makefile 
+	$(RM) $(DISTCLEAN_TARGETS) Makefile
 
 .exported_symbols_generated: $(EXPORTED_HEADER) .exported_symbols
 	set -e; \


