From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 10 Oct 2018 07:28:48 -0400
Subject: master - build: gcc can be fussy about order of libs
Message-ID: <201810101128.w9ABSmlh031684@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=37366ec3b061c86ce897560213df5769c5d91eb6
Commit:        37366ec3b061c86ce897560213df5769c5d91eb6
Parent:        6e12a332923bb81cc293b64821226e8c2632742c
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Oct 10 11:10:42 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Oct 10 11:25:50 2018 +0200

build: gcc can be fussy about order of libs

---
 daemons/lvmlockd/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmlockd/Makefile.in b/daemons/lvmlockd/Makefile.in
index 01abaca..0f1386b 100644
--- a/daemons/lvmlockd/Makefile.in
+++ b/daemons/lvmlockd/Makefile.in
@@ -45,7 +45,7 @@ LIBS += $(RT_LIBS) $(DAEMON_LIBS) $(PTHREAD_LIBS)
 
 ifeq ($(USE_SD_NOTIFY),yes)
 	CFLAGS += $(shell pkg-config --cflags libsystemd) -DUSE_SD_NOTIFY
-	LDFLAGS += $(shell pkg-config --libs libsystemd)
+	LIBS += $(shell pkg-config --libs libsystemd)
 endif
 
 lvmlockd: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \


