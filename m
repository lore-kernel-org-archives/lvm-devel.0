From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 1 Aug 2017 06:02:18 -0400
Subject: master - tests: update makefile
Message-ID: <201708011002.v71A2I9j011917@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a60fd5723645a56b677281007e6d5ed2493945cf
Commit:        a60fd5723645a56b677281007e6d5ed2493945cf
Parent:        00fdf01d9d3885e7b1e2c3d92664423892811e25
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 1 11:19:21 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 1 11:53:32 2017 +0200

tests: update makefile

---
 test/api/Makefile.in |   15 ++++-----------
 1 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/test/api/Makefile.in b/test/api/Makefile.in
index d474ddf..cc237df 100644
--- a/test/api/Makefile.in
+++ b/test/api/Makefile.in
@@ -42,21 +42,14 @@ include $(top_builddir)/make.tmpl
 
 DEFS += -D_REENTRANT
 DEPLIBS += $(top_builddir)/liblvm/liblvm2app.so $(top_builddir)/libdm/libdevmapper.so
-LDFLAGS += -L$(top_builddir)/liblvm
-LVMLIBS = @LVM2APP_LIB@ -ldevmapper
-
-ifeq ("@DMEVENTD@", "yes")
-       LVMLIBS += -ldevmapper-event
-       LDFLAGS += -L$(top_builddir)/daemons/dmeventd
-endif
-
-LVMLIBS += $(LIBS)
+LDFLAGS += -L$(top_builddir)/liblvm -L$(top_builddir)/daemons/dmeventd
+LIBS += @LVM2APP_LIB@ $(DMEVENT_LIBS) -ldevmapper
 
 %.t: %.o $(DEPLIBS)
-	$(CC) -o $@ $(<) $(LDFLAGS) $(LVMLIBS)
+	$(CC) -o $@ $(<) $(LDFLAGS) $(LIBS)
 
 test: $(OBJECTS) $(DEPLIBS)
-	$(CC) -o $@ $(OBJECTS) $(LDFLAGS) $(LVMLIBS) $(READLINE_LIBS)
+	$(CC) -o $@ $(OBJECTS) $(LDFLAGS) $(LIBS) $(READLINE_LIBS)
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status test/api/Makefile


