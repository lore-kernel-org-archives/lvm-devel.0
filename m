From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  7 Sep 2022 13:04:50 +0000 (GMT)
Subject: main - make: update make.tmpl
Message-ID: <20220907130450.8F6303858428@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2c7b9130499d17a657684fb3c762d608b50d139e
Commit:        2c7b9130499d17a657684fb3c762d608b50d139e
Parent:        85b436642baa4b957f70cf7e94355ee328fc8c02
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 5 15:56:58 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 7 14:58:01 2022 +0200

make: update make.tmpl

Add new define 'newline' for use in 'foreach()'
Add new $(SHOW) for makefile printing output
Add 'make print-VAR' for easier debugging of Makefiles' variables.
---
 libdm/make.tmpl.in | 24 +++++++++++++++++++-----
 make.tmpl.in       | 39 +++++++++++++++++++++++++++++++--------
 2 files changed, 50 insertions(+), 13 deletions(-)

diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index a306101d5..f1c88fac0 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -13,11 +13,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-ifeq ($(V),1)
-	Q=
-else
-	Q=@
-endif
+V ?= $(if ("@SILENT_RULES@","yes"),,1)
+Q := $(if $(V),,@)
+SHOW := $(if $(V), at true, at echo)
 
 SHELL = @SHELL@
 
@@ -129,6 +127,17 @@ DEFAULT_RUN_DIR = @DEFAULT_RUN_DIR@
 DEFAULT_PID_DIR = @DEFAULT_PID_DIR@
 DEFAULT_MANGLING = @MANGLING@
 
+#----------------------------------------------------------------------
+# From http://blog.melski.net/tag/debugging-makefiles/
+#
+# Usage: make print-CC print-CXX print-LD
+#----------------------------------------------------------------------
+print-%:
+	@echo '$*=$($*)'
+	@echo '  origin = $(origin $*)'
+	@echo '  flavor = $(flavor $*)'
+	@echo '   value = $(value  $*)'
+
 # Setup vpath search paths for some suffixes
 vpath %.c $(srcdir)
 vpath %.cpp $(srcdir)
@@ -145,6 +154,10 @@ ifndef MAKEFLAGS
 MAKEFLAGS = @JOBS@
 endif
 
+ifneq (1, $(firstword $(V)))
+MAKEFLAGS += --no-print-directory
+endif
+
 # Handle installation of files
 ifeq ("@WRITE_INSTALL@", "yes")
 # leaving defaults
@@ -524,6 +537,7 @@ endif
 ifeq ("@USE_TRACKING@","yes")
 ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov \
  help check check_local check_cluster check_lvmpolld))
+.SECONDARY:
 # Note: no tabs before -include
     -include $(SOURCES:.c=.d) $(SOURCES2:.c=.d) $(CXXSOURCES:.cpp=.d)
 endif
diff --git a/make.tmpl.in b/make.tmpl.in
index 427fee596..a390553a4 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -13,15 +13,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-ifneq ("@SILENT_RULES@","yes")
-	V ?= 1
-endif
 
-ifeq ($(V),1)
-	Q=
-else
-	Q=@
-endif
+V ?= $(if ("@SILENT_RULES@","yes"),,1)
+Q := $(if $(V),,@)
+SHOW := $(if $(V), at true, at echo)
 
 SHELL = @SHELL@
 
@@ -134,6 +129,18 @@ PYTHON_PREFIX = $(prefix)
 python2dir = @PYTHON2DIR@
 python3dir = @PYTHON3DIR@
 
+# Define macro NewLine for use in $(foreach) with 2 blank lines
+ifeq (1, $(firstword $(V)))
+define newline
+
+
+endef
+else
+define newline
+;
+endef
+endif
+
 USRLIB_RELPATH = $(shell echo $(abspath $(usrlibdir) $(libdir)) | \
   $(AWK) -f $(top_srcdir)/scripts/relpath.awk)
 
@@ -148,6 +155,17 @@ DEFAULT_RUN_DIR = @DEFAULT_RUN_DIR@
 DEFAULT_PID_DIR = @DEFAULT_PID_DIR@
 DEFAULT_MANGLING = @MANGLING@
 
+#----------------------------------------------------------------------
+# From http://blog.melski.net/tag/debugging-makefiles/
+#
+# Usage: make print-CC print-CXX print-LD
+#----------------------------------------------------------------------
+print-%:
+	@echo '$*=$($*)'
+	@echo '  origin = $(origin $*)'
+	@echo '  flavor = $(flavor $*)'
+	@echo '   value = $(value  $*)'
+
 # Setup vpath search paths for some suffixes
 vpath %.c $(srcdir)
 vpath %.cpp $(srcdir)
@@ -164,6 +182,10 @@ ifndef MAKEFLAGS
 MAKEFLAGS = @JOBS@
 endif
 
+ifneq (1, $(firstword $(V)))
+MAKEFLAGS += --no-print-directory
+endif
+
 # Handle installation of files
 ifeq ("@WRITE_INSTALL@", "yes")
 # leaving defaults
@@ -582,6 +604,7 @@ endif
 ifeq ("$(USE_TRACKING)","yes")
 ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov lcov-reset \
  help check check_local check_cluster check_lvmpolld run-unit-test tags))
+.SECONDARY:
 # Note: no tabs before -include
     -include $(SOURCES:.c=.d) $(SOURCES2:.c=.d) $(CXXSOURCES:.cpp=.d)
 endif

