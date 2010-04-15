From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 15 Apr 2010 11:40:05 +0200
Subject: [PATCH 3/3] Use relative paths for creating links .so
In-Reply-To: <cover.1271324076.git.zkabelac@redhat.com>
References: <cover.1271324076.git.zkabelac@redhat.com>
Message-ID: <d505a739950dacc0205b9b422294ddedf3154298.1271324076.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Using relpath.sh to generate link path between libs.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 make.tmpl.in      |    3 ++-
 tools/Makefile.in |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index a6b00fc..b3b54f4 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -62,6 +62,7 @@ mandir = $(datarootdir)/man
 localedir = $(DESTDIR)@LOCALEDIR@
 staticdir = $(DESTDIR)@STATICDIR@
 udevdir = $(DESTDIR)@udevdir@
+USRLIB_RELPATH = $(shell $(top_srcdir)/scripts/relpath.sh $(abspath $(usrlibdir) $(libdir)))
 
 # Setup vpath search paths for some suffixes
 vpath %.c $(srcdir)
@@ -301,7 +302,7 @@ $(LIB_SHARED): $(LIB_SHARED).$(LIB_VERSION)
 install_lib_shared: $(LIB_SHARED)
 	$(INSTALL_PROGRAM) -D $< $(libdir)/$(<F).$(LIB_VERSION)
 	$(INSTALL) -d $(usrlibdir)
-	$(LN_S) -f $(libdir)/$(<F).$(LIB_VERSION) $(usrlibdir)/$(<F)
+	$(LN_S) -f $(USRLIB_RELPATH)$(<F).$(LIB_VERSION) $(usrlibdir)/$(<F)
 
 # FIXME: plugins are currently installed with .so suffix only
 install_lib_shared_plugin: $(LIB_SHARED)
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 0a4d75f..47fa2db 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -169,7 +169,7 @@ install_cmdlib_include: $(srcdir)/lvm2cmd.h
 install_cmdlib_dynamic: liblvm2cmd.$(LIB_SUFFIX)
 	$(INSTALL_PROGRAM) -D $< $(libdir)/$(<F).$(LIB_VERSION)
 	$(INSTALL) -d $(usrlibdir)
-	$(LN_S) -f $(libdir)/$<.$(LIB_VERSION) $(usrlibdir)/$(<F)
+	$(LN_S) -f $(USRLIB_RELPATH)$(<F).$(LIB_VERSION) $(usrlibdir)/$(<F)
 
 install_cmdlib_static: liblvm2cmd-static.a
 	$(INSTALL_DATA) -D $< $(usrlibdir)/liblvm2cmd.a
-- 
1.7.0.1


