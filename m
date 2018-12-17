From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Dec 2018 05:07:55 -0500
Subject: master - dmfilemapd: avoid linking with DL_LIBS
Message-ID: <201812171007.wBHA7thS024721@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c666e8d25e724802a85489c548adc763949fdfa9
Commit:        c666e8d25e724802a85489c548adc763949fdfa9
Parent:        f514e379786689a47518bf67d71a388977cc7369
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 16:27:27 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 14 22:27:33 2018 +0100

dmfilemapd: avoid linking with DL_LIBS

Dmfilemapd is not using dlopen so doesn't need to be linked with
DL_LIBS.
---
 libdm/dm-tools/Makefile.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/dm-tools/Makefile.in b/libdm/dm-tools/Makefile.in
index abb0e95..33110dc 100644
--- a/libdm/dm-tools/Makefile.in
+++ b/libdm/dm-tools/Makefile.in
@@ -82,12 +82,12 @@ ifeq ("@BUILD_DMFILEMAPD@", "yes")
   dmfilemapd: $(LIB_SHARED) dmfilemapd.o
 	@echo "    [CC] $<"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) \
-		-o $@ dmfilemapd.o -L$(top_builddir)/libdm -ldevmapper $(DL_LIBS) $(LIBS)
+		-o $@ dmfilemapd.o -L$(top_builddir)/libdm -ldevmapper $(LIBS)
 
   dmfilemapd.static: $(LIB_STATIC) dmfilemapd.o
 	@echo "    [CC] $<"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) -static -L$(interfacebuilddir) \
-		-o $@ dmfilemapd.o $(DL_LIBS) $(LIBS) $(STATIC_LIBS)
+		-o $@ dmfilemapd.o $(LIBS) $(STATIC_LIBS)
 
   install_dmfilemapd_dynamic: dmfilemapd
 	@echo "    [INSTALL] $<"


