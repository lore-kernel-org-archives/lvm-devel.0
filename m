From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  6 Apr 2021 20:07:19 +0000 (GMT)
Subject: main - makefiles: add check for versioned symbols
Message-ID: <20210406200719.6101D3846079@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c23f4c8075655aeaef96b3e19ad44c0be78020c9
Commit:        c23f4c8075655aeaef96b3e19ad44c0be78020c9
Parent:        40b277ae1799fc7a2e3f38b0abebd81a8e3d1995
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 6 14:39:44 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 6 21:26:57 2021 +0200

makefiles: add check for versioned symbols

Simple check produced library has the latest symbol as well as its versioned
older version with check for dm_stats_create_region().
---
 libdm/Makefile.in | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 12fec06b4..a78d2b517 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -47,7 +47,7 @@ endif
 
 LIB_SHARED = $(interface)/libdevmapper.$(LIB_SUFFIX)
 LIB_VERSION = $(LIB_VERSION_DM)
-TARGETS = libdevmapper.$(LIB_SUFFIX) libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION)
+TARGETS = libdevmapper.$(LIB_SUFFIX) libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION) .symver_check
 
 CFLOW_LIST = $(SOURCES)
 CFLOW_LIST_TARGET = libdevmapper.cflow
@@ -69,6 +69,16 @@ libdevmapper.$(LIB_SUFFIX) libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION): $(LIB_SHAR
 	@echo "    [LN] $<"
 	$(Q) $(LN_S) -f $< $@
 
+# Check versioned build when default versioned symbol is present @@
+# also the older symbol is built-in
+.symver_check: $(LIB_SHARED)
+	@echo "    [CHECK] $<"
+	$(Q) if readelf -Ws $< | grep -q dm_stats_create_region@@; then \
+	SYM=$$(readelf -Ws $< | grep dm_stats_create_region@DM_1_02_106); \
+	if test -n "$$SYM"; then touch $@; \
+	else echo >&2 "Missing versioned symbols in $<"; false; fi; \
+	else touch $@; fi
+
 .PHONY: install_dynamic install_static install_include \
 	install_ioctl install_ioctl_static \
 	install_pkgconfig


