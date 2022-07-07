From: Mike Gilbert <floppym@gentoo.org>
Date: Thu,  7 Jul 2022 13:58:54 -0400
Subject: [PATCH] Use AC_CHECK_TOOL to find readelf
Message-ID: <20220707175854.1873031-1-floppym@gentoo.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Ensures the correct readelf binary is used when cross compiling.
---
 configure.ac       | 1 +
 libdm/Makefile.in  | 4 ++--
 libdm/make.tmpl.in | 1 +
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/configure.ac b/configure.ac
index 6cdf1a7e6..6cc8c0905 100644
--- a/configure.ac
+++ b/configure.ac
@@ -84,6 +84,7 @@ AC_PROG_MAKE_SET
 AC_PROG_MKDIR_P
 AC_PROG_RANLIB
 AC_CHECK_TOOL(AR, ar)
+AC_CHECK_TOOL(READELF, readelf)
 AC_PATH_TOOL(CFLOW_CMD, cflow)
 AC_PATH_TOOL(CSCOPE_CMD, cscope)
 AC_PATH_TOOL(CHMOD, chmod)
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 35115d7f0..2758648e6 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -71,8 +71,8 @@ libdevmapper.$(LIB_SUFFIX) libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION): $(LIB_SHAR
 # also the older symbol is built-in
 .symver_check: $(LIB_SHARED)
 	@echo "    [CHECK] $<"
-	$(Q) if readelf -Ws $< | grep -q dm_stats_create_region@@; then \
-	SYM=$$(readelf -Ws $< | grep dm_stats_create_region at DM_1_02_106); \
+	$(Q) if $(READELF) -Ws $< | grep -q dm_stats_create_region@@; then \
+	SYM=$$($(READELF) -Ws $< | grep dm_stats_create_region@DM_1_02_106); \
 	if test -n "$$SYM"; then touch $@; \
 	else echo >&2 "Missing versioned symbols in $<"; false; fi; \
 	else touch $@; fi
diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index a306101d5..777a5c23a 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -51,6 +51,7 @@ GREP = @GREP@
 SORT = @SORT@
 WC = @WC@
 AR = @AR@
+READELF = @READELF@
 RM = rm -f
 
 LIBS += @LIBS@ $(PTHREAD_LIBS) $(SELINUX_LIBS) $(UDEV_LIBS) $(RT_LIBS) $(M_LIBS)
-- 
2.37.0

