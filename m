From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  3 Mar 2010 21:42:51 +0100
Subject: [PATCH 05/15] Replace just one CFLOW_CMD
In-Reply-To: <cover.1267648294.git.zkabelac@redhat.com>
References: <cover.1267648294.git.zkabelac@redhat.com>
Message-ID: <631c9e5d467749d2db57a1708a6cff21f0cc1d69.1267648294.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Replace CFLOW_CMD only in make.tmpl and use it as variable elsewhere.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 make.tmpl.in      |    1 +
 tools/Makefile.in |   12 ++++++------
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 61365ec..5b8476f 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -27,6 +27,7 @@ LCOV = @LCOV@
 GENHTML = @GENHTML@
 LN_S = @LN_S@
 SED = @SED@
+CFLOW_CMD = @CFLOW_CMD@
 
 LIBS = @LIBS@
 DEFS += @DEFS@
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 880ea89..41c20db 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -147,20 +147,20 @@ liblvm2cmd.$(LIB_SUFFIX): liblvm2cmd.a $(LDDEPS)
 .PHONY: install_cmdlib_dynamic install_cmdlib_static \
 	install_tools_dynamic install_tools_static
 
-ifneq ("@CFLOW_CMD@", "")
+ifneq ("$(CFLOW_CMD)", "")
 CFLOW_FLAGS += --cpp="$(CC) -E"
 .PHONY: lvm.cflow
 -include $(top_srcdir)/lib/liblvm-internal.cflow
 lvm.cflow: $(SOURCES)
-	@CFLOW_CMD@ -o$@ $(CFLOW_FLAGS) $(INCLUDES) $(DEFS) $(SOURCES)
+	$(CFLOW_CMD) -o$@ $(CFLOW_FLAGS) $(INCLUDES) $(DEFS) $(SOURCES)
 lvm.rxref: $(SOURCES)
-	@CFLOW_CMD@ -o$@ --cpp="$(CC) -E" -r --omit-arguments -x $(INCLUDES) $(DEFS) $(SOURCES)
+	$(CFLOW_CMD) -o$@ --cpp="$(CC) -E" -r --omit-arguments -x $(INCLUDES) $(DEFS) $(SOURCES)
 lvm.xref: $(SOURCES)
-	@CFLOW_CMD@ -o$@ --cpp="$(CC) -E" --omit-arguments -x $(INCLUDES) $(DEFS) $(SOURCES)
+	$(CFLOW_CMD) -o$@ --cpp="$(CC) -E" --omit-arguments -x $(INCLUDES) $(DEFS) $(SOURCES)
 lvm.rtree: $(SOURCES)
-	@CFLOW_CMD@ -o$@ --cpp="$(CC) -E" -r --omit-arguments -T -b $(INCLUDES) $(DEFS) $(SOURCES)
+	$(CFLOW_CMD) -o$@ --cpp="$(CC) -E" -r --omit-arguments -T -b $(INCLUDES) $(DEFS) $(SOURCES)
 lvm.tree: $(SOURCES)
-	@CFLOW_CMD@ -o$@ --cpp="$(CC) -E" --omit-arguments -T -b $(INCLUDES) $(DEFS) $(SOURCES)
+	$(CFLOW_CMD) -o$@ --cpp="$(CC) -E" --omit-arguments -T -b $(INCLUDES) $(DEFS) $(SOURCES)
 cflow: lvm.cflow lvm.xref lvm.tree lvm.rtree lvm.rxref
 endif
 
-- 
1.7.0


