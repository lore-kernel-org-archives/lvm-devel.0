From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Feb 2023 13:31:31 +0000 (GMT)
Subject: main - makefiles: use configured systemd library paths
Message-ID: <20230213133131.8A01C3881D2D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=50f73de4b27c11c810c8f7aea3e36a5c947408af
Commit:        50f73de4b27c11c810c8f7aea3e36a5c947408af
Parent:        0fc2d418f76a9e98ab988ff5a3440a3beef5295f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 11 16:06:26 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 13 13:41:59 2023 +0100

makefiles: use configured systemd library paths

Use discovered/selected systemd library from configure.
---
 daemons/lvmlockd/Makefile.in | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmlockd/Makefile.in b/daemons/lvmlockd/Makefile.in
index 91beb1ad8..e5ba82517 100644
--- a/daemons/lvmlockd/Makefile.in
+++ b/daemons/lvmlockd/Makefile.in
@@ -52,8 +52,8 @@ LDFLAGS += -L$(top_builddir)/libdaemon/server $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS)
 LIBS += $(DAEMON_LIBS) $(PTHREAD_LIBS)
 
 ifeq ($(USE_SD_NOTIFY),yes)
-	CFLAGS += $(shell pkg-config --cflags libsystemd) -DUSE_SD_NOTIFY
-	LIBS += $(shell pkg-config --libs libsystemd)
+	CFLAGS += $(SYSTEMD_CFLAGS) -DUSE_SD_NOTIFY
+	LIBS += $(SYSTEMD_LIBS)
 endif
 
 lvmlockd: $(OBJECTS) $(top_builddir)/libdaemon/server/libdaemonserver.a $(INTERNAL_LIBS)

