From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Dec 2018 05:08:24 -0500
Subject: master - makefiles: drop unneeded LIBS add
Message-ID: <201812171008.wBHA8Oto024777@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a63015442e8bf3893e8531b209057a44158e438b
Commit:        a63015442e8bf3893e8531b209057a44158e438b
Parent:        d76b4afb8ed9531c1609804b684900a0ea96815c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 23:27:35 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 17 10:36:52 2018 +0100

makefiles: drop unneeded LIBS add

---
 libdaemon/server/Makefile.in |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/libdaemon/server/Makefile.in b/libdaemon/server/Makefile.in
index e971a52..3a5a220 100644
--- a/libdaemon/server/Makefile.in
+++ b/libdaemon/server/Makefile.in
@@ -18,5 +18,3 @@ LIB_STATIC = libdaemonserver.a
 SOURCES = daemon-server.c daemon-log.c
 
 include $(top_builddir)/make.tmpl
-
-LIBS += $(DAEMON_LIBS)


