From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 4 Jun 2018 06:28:54 -0400
Subject: master - build: fixes
Message-ID: <201806041028.w54ASsGC032054@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1140d70893e4f246a46fa360d20838ceafa690ec
Commit:        1140d70893e4f246a46fa360d20838ceafa690ec
Parent:        eebf070d32b491fb08f7defccc08f9bcefb9aba2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 4 12:25:48 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 4 12:28:13 2018 +0200

build: fixes

---
 daemons/lvmlockd/Makefile.in |    6 ++++--
 daemons/lvmpolld/Makefile.in |    3 ++-
 lib/activate/activate.h      |    2 +-
 lib/metadata/lv.c            |    2 +-
 4 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmlockd/Makefile.in b/daemons/lvmlockd/Makefile.in
index 9e2297f..7c58fe2 100644
--- a/daemons/lvmlockd/Makefile.in
+++ b/daemons/lvmlockd/Makefile.in
@@ -42,10 +42,12 @@ LIBS += $(RT_LIBS) $(DAEMON_LIBS) $(PTHREAD_LIBS)
 
 lvmlockd: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
 		    $(top_builddir)/libdaemon/server/libdaemonserver.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LOCK_LIBS) -ldaemonserver $(LIBS)
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LOCK_LIBS) -ldaemonserver \
+		$(top_builddir)/device_mapper/libdevice-mapper.a $(LIBS)
 
 lvmlockctl: lvmlockctl.o $(top_builddir)/libdaemon/client/libdaemonclient.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ lvmlockctl.o $(LIBS)
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ lvmlockctl.o \
+		$(top_builddir)/device_mapper/libdevice-mapper.a $(LIBS)
 
 install_lvmlockd: lvmlockd
 	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
diff --git a/daemons/lvmpolld/Makefile.in b/daemons/lvmpolld/Makefile.in
index 69c4a8d..229a87e 100644
--- a/daemons/lvmpolld/Makefile.in
+++ b/daemons/lvmpolld/Makefile.in
@@ -34,7 +34,8 @@ LIBS += $(DAEMON_LIBS) -ldaemonserver $(PTHREAD_LIBS)
 
 lvmpolld: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
 		    $(top_builddir)/libdaemon/server/libdaemonserver.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LIBS)
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) \
+		$(top_builddir)/device_mapper/libdevice-mapper.a $(LIBS)
 
 install_lvmpolld: lvmpolld
 	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 60ee4a7..8175f68 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -210,7 +210,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 			   const struct lv_activate_opts *laopts, int monitor);
 
 #ifdef DMEVENTD
-#  include "libdevmapper-event.h"
+#  include "daemons/dmeventd/libdevmapper-event.h"
 char *get_monitor_dso_path(struct cmd_context *cmd, int id);
 int target_registered_with_dmeventd(struct cmd_context *cmd, const char *dso,
 				    const struct logical_volume *lv, int *pending, int *monitored);
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 54edc88..68507dc 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -290,7 +290,7 @@ char *lvseg_cachemode_dup(struct dm_pool *mem, const struct lv_segment *seg)
 }
 
 #ifdef DMEVENTD
-#  include "libdevmapper-event.h"
+#  include "daemons/dmeventd/libdevmapper-event.h"
 #endif
 char *lvseg_monitor_dup(struct dm_pool *mem, const struct lv_segment *seg)
 {


