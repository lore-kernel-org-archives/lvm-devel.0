From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 16 Feb 2023 23:10:55 +0000 (GMT)
Subject: main - makefiles: move include earlier
Message-ID: <20230216231055.530C63858D33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d58b475f6320257e72f01be3c57badd65af28d56
Commit:        d58b475f6320257e72f01be3c57badd65af28d56
Parent:        b9697acbd6b4283b430b5c6a9ced45676c54bc1d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 16 23:40:25 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 17 00:00:12 2023 +0100

makefiles: move include earlier

---
 daemons/lvmlockd/Makefile.in | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/daemons/lvmlockd/Makefile.in b/daemons/lvmlockd/Makefile.in
index aff4c0123..24191c439 100644
--- a/daemons/lvmlockd/Makefile.in
+++ b/daemons/lvmlockd/Makefile.in
@@ -16,6 +16,11 @@ top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
 SOURCES = lvmlockd-core.c
+SOURCES2 = lvmlockctl.c
+
+TARGETS = lvmlockd lvmlockctl
+
+include $(top_builddir)/make.tmpl
 
 ifeq ("@BUILD_LOCKDSANLOCK@", "yes")
   SOURCES += lvmlockd-sanlock.c
@@ -36,17 +41,11 @@ ifeq ("@BUILD_LOCKDIDM@", "yes")
   LOCK_LIBS += -lseagate_ilm $(BLKID_LIBS)
 endif
 
-SOURCES2 = lvmlockctl.c
-
-TARGETS = lvmlockd lvmlockctl
-
 CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
 CFLOW_TARGET = lvmlockd
 
 .PHONY: install_lvmlockd install_lvmlockctl
 
-include $(top_builddir)/make.tmpl
-
 CFLAGS += $(EXTRA_EXEC_CFLAGS)
 INCLUDES += -I$(top_srcdir)/libdaemon/server
 LDFLAGS += -L$(top_builddir)/libdaemon/server $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS)

