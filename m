From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:40:37 +0000 (UTC)
Subject: master - configure: Allow C++ components.
Message-ID: <20150205134037.40357602BB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf1f22cc997d3883f5ce481fb1ad1c6487fff9b7
Commit:        bf1f22cc997d3883f5ce481fb1ad1c6487fff9b7
Parent:        f476655fee6594b33b52ad5a90d5d442d155fbb9
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Jun 8 18:23:47 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Feb 3 08:49:35 2015 +0100

configure: Allow C++ components.

---
 configure.in |    1 +
 make.tmpl.in |   10 +++++++---
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/configure.in b/configure.in
index 107bb29..add6653 100644
--- a/configure.in
+++ b/configure.in
@@ -69,6 +69,7 @@ dnl -- Checks for programs.
 AC_PROG_SED
 AC_PROG_AWK
 AC_PROG_CC
+AC_PROG_CXX
 
 dnl probably no longer needed in 2008, but...
 AC_PROG_GCC_TRADITIONAL
diff --git a/make.tmpl.in b/make.tmpl.in
index 7efe46b..2a2107f 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -106,6 +106,7 @@ DEFAULT_MANGLING = @MANGLING@
 
 # Setup vpath search paths for some suffixes
 vpath %.c $(srcdir)
+vpath %.cpp $(srcdir)
 vpath %.in $(srcdir)
 vpath %.po $(srcdir)
 vpath %.exported_symbols $(srcdir)
@@ -136,7 +137,7 @@ INSTALL_ROOT_DIR = $(INSTALL) -m 700 -d
 INSTALL_ROOT_DATA = $(INSTALL) -m 600
 INSTALL_SCRIPT = $(INSTALL) -p $(M_INSTALL_PROGRAM)
 
-.SUFFIXES: .c .d .o .so .a .po .pot .mo .dylib
+.SUFFIXES: .c .cpp .d .o .so .a .po .pot .mo .dylib
 
 WFLAGS += -Wall -Wundef -Wshadow -Wcast-align -Wwrite-strings \
  -Wmissing-prototypes -Wmissing-declarations -Wnested-externs \
@@ -239,7 +240,7 @@ INC_LNS = $(top_builddir)/include/.symlinks_created
 DEPS = $(top_builddir)/make.tmpl $(top_srcdir)/VERSION \
        $(top_builddir)/Makefile $(INC_LNS)
 
-OBJECTS = $(SOURCES:%.c=%.o)
+OBJECTS = $(SOURCES:%.c=%.o) $(CXXSOURCES:%.cpp=%.o)
 POTFILES = $(SOURCES:%.c=%.pot)
 
 .PHONY: all pofile distclean clean cleandir cflow device-mapper
@@ -366,6 +367,9 @@ $(TARGETS): $(OBJECTS)
 %.o: %.c
 	$(CC) -c $(INCLUDES) $(DEFS) $(WFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
 
+%.o: %.cpp
+	$(CXX) -c $(INCLUDES) $(DEFS) $(WFLAGS) $(CXXFLAGS) $(CXXFLAGS_$@) $< -o $@
+
 %.pot: %.c Makefile
 	$(CC) -E $(INCLUDES) -include $(top_builddir)/include/pogen.h \
 		$(DEFS) $(WFLAGS) $(CFLAGS) $< > $@
@@ -454,7 +458,7 @@ distclean: cleandir $(SUBDIRS.distclean)
 ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov \
  help check check_local check_cluster check_lvmetad))
     ifdef SOURCES
-       -include $(SOURCES:.c=.d)
+       -include $(SOURCES:.c=.d) $(CXXSOURCES:.cpp=.d)
     endif
     ifdef SOURCES2
        -include $(SOURCES2:.c=.d)


