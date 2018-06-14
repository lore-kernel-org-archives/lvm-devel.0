From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Jun 2018 17:23:26 -0400
Subject: master - build: cmirrord with internal dm lib
Message-ID: <201806142123.w5ELNQQL014823@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b2cb8f846ac8061bb3e71d5805edd72e67d277db
Commit:        b2cb8f846ac8061bb3e71d5805edd72e67d277db
Parent:        b1729dbcddb7243f556b286f958cd4a97f821d65
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 14 23:14:04 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 14 23:14:04 2018 +0200

build: cmirrord with internal dm lib

---
 daemons/cmirrord/Makefile.in |    2 +-
 daemons/cmirrord/functions.c |    1 +
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/cmirrord/Makefile.in b/daemons/cmirrord/Makefile.in
index b6bab2d..a78dafe 100644
--- a/daemons/cmirrord/Makefile.in
+++ b/daemons/cmirrord/Makefile.in
@@ -30,7 +30,7 @@ LDFLAGS += $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS)
 
 cmirrord: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) \
-		$(LVMLIBS) $(LMLIBS) $(LIBS)
+		$(LVMLIBS) $(LMLIBS) $(INTERNAL_LIBS) $(LIBS)
 
 install: $(TARGETS)
 	$(INSTALL_PROGRAM) -D cmirrord $(usrsbindir)/cmirrord
diff --git a/daemons/cmirrord/functions.c b/daemons/cmirrord/functions.c
index 61bcf16..f10a8d5 100644
--- a/daemons/cmirrord/functions.c
+++ b/daemons/cmirrord/functions.c
@@ -11,6 +11,7 @@
  */
 #include "logging.h"
 #include "functions.h"
+#include "base/memory/zalloc.h"
 
 #include <sys/sysmacros.h>
 #include <dirent.h>


