From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Nov 2022 15:42:59 +0000 (GMT)
Subject: main - configure: allow for overriding of `readelf`
Message-ID: <20221125154259.14A5D384F6DA@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3dee7b7266f79aba12805dfbfcd770dac3171051
Commit:        3dee7b7266f79aba12805dfbfcd770dac3171051
Parent:        2da4ca7ce163fe89b3c79b1d6c55aa30eaa6307d
Author:        David Seifert <soap@gentoo.org>
AuthorDate:    Sat Nov 19 17:51:08 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 25 15:54:57 2022 +0100

configure: allow for overriding of `readelf`

This allows users to use e.g. `llvm-readelf`
on systems with binutils as default.

Bug: https://bugs.gentoo.org/840628
---
 configure.ac       | 1 +
 libdm/Makefile.in  | 4 ++--
 libdm/make.tmpl.in | 1 +
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/configure.ac b/configure.ac
index 704772b62..f39c87d08 100644
--- a/configure.ac
+++ b/configure.ac
@@ -83,6 +83,7 @@ AC_PROG_LN_S
 AC_PROG_MAKE_SET
 AC_PROG_MKDIR_P
 AC_PROG_RANLIB
+AC_CHECK_TOOL([READELF], [readelf])
 AC_CHECK_TOOL(AR, ar)
 AC_PATH_TOOL(CFLOW_CMD, cflow)
 AC_PATH_TOOL(CSCOPE_CMD, cscope)
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
index f1c88fac0..095fb028a 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -34,6 +34,7 @@ ifeq ($(CC), cc)
 endif
 
 RANLIB = @RANLIB@
+READELF = @READELF@
 INSTALL = @INSTALL@
 MKDIR_P = @MKDIR_P@
 MSGFMT = @MSGFMT@

