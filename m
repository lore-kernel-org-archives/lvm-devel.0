From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  7 May 2010 16:14:49 +0200
Subject: [PATCH 2/9] Link liblvm2cmd.so with their depending libraries
In-Reply-To: <cover.1273241256.git.zkabelac@redhat.com>
References: <cover.1273241256.git.zkabelac@redhat.com>
Message-ID: <d3582ef6c48cc7e50a02504d25f7c3c327608e84.1273241256.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Link liblvm2cmd.so with devmapper-event and devmapper libs.
Remove generic %.so: %.a target.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 make.tmpl.in      |    5 -----
 tools/Makefile.in |    3 +++
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 2375e18..69fab00 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -320,11 +320,6 @@ install_lvm2_plugin: $(LIB_SHARED)
 	$(LN_S) -f $(<F) $(libdir)/$(<F).$(LIB_VERSION)
 endif
 
-%.so: %.a
-	$(CC) -shared -Wl,-soname,$(notdir $@).$(LIB_VERSION) \
-	$(CFLAGS) $(CLDFLAGS) $(LIBS) -o $@ \
-	@CLDWHOLEARCHIVE@ $< @CLDNOWHOLEARCHIVE@
-
 $(LIB_STATIC): $(OBJECTS)
 	$(RM) $@
 	$(AR) rs $@ $(OBJECTS)
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 47fa2db..e7b9b6a 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -145,6 +145,9 @@ liblvm2cmd-static.a: $(top_builddir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.
 	$(AR) rs $@ $(OBJECTS) lvmcmdlib.o lvm2cmd-static.o
 
 liblvm2cmd.$(LIB_SUFFIX): liblvm2cmd.a $(LDDEPS)
+	$(CC) -shared -Wl,-soname,$@.$(LIB_VERSION) \
+	$(CFLAGS) $(CLDFLAGS) -o $@ $(LVMLIBS) $(LIBS) \
+		@CLDWHOLEARCHIVE@ liblvm2cmd.a @CLDNOWHOLEARCHIVE@
 
 liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION): liblvm2cmd.$(LIB_SUFFIX)
 	$(LN_S) -f $< $@
-- 
1.7.0.1


