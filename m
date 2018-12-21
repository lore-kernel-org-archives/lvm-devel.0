From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Dec 2018 15:46:18 -0500
Subject: master - lvmpolld: improve makefile deps
Message-ID: <201812212046.wBLKkIFi021012@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=98924e4703bd798f4e872fbc7e6c6e32a199e102
Commit:        98924e4703bd798f4e872fbc7e6c6e32a199e102
Parent:        18aa541ca270d70899ab7ec6095075b70a21fb09
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 21 11:24:00 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 21 21:42:23 2018 +0100

lvmpolld: improve makefile deps

Add correct build dependencies on internal libraries.
---
 WHATS_NEW                    |    1 +
 daemons/lvmpolld/Makefile.in |    9 ++++-----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 38525e3..1a9c521 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Improve Makefile dependency tracking.
   Move VDO support towards V2 target (6.2) support.
   Fix missing proper initialization of pv_list struct when adding pv.
   Fix (de)activation of RaidLVs with visible SubLVs
diff --git a/daemons/lvmpolld/Makefile.in b/daemons/lvmpolld/Makefile.in
index cfda0f6..05b12ff 100644
--- a/daemons/lvmpolld/Makefile.in
+++ b/daemons/lvmpolld/Makefile.in
@@ -29,13 +29,12 @@ include $(top_builddir)/make.tmpl
 
 CFLAGS += $(EXTRA_EXEC_CFLAGS)
 INCLUDES += -I$(top_srcdir)/libdaemon/server
-LDFLAGS += -L$(top_builddir)/libdaemon/server $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS)
-LIBS += $(DAEMON_LIBS) -ldaemonserver $(PTHREAD_LIBS)
+LDFLAGS += $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS)
+LIBS += $(DAEMON_LIBS) $(PTHREAD_LIBS)
 
-lvmpolld: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
-		    $(top_builddir)/libdaemon/server/libdaemonserver.a
+lvmpolld: $(OBJECTS) $(top_builddir)/libdaemon/server/libdaemonserver.a $(INTERNAL_LIBS)
 	@echo "    [CC] $@"
-	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(INTERNAL_LIBS) $(LIBS)
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $+ $(LIBS)
 
 install_lvmpolld: lvmpolld
 	@echo "    [INSTALL] $<"


