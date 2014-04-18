From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:23 +0000 (UTC)
Subject: master - cleanup: set _REENTRANT in header
Message-ID: <20140418145523.3539C60F48@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=20179523e2ab0d0dce757e1a689f30ad4add3f17
Commit:        20179523e2ab0d0dce757e1a689f30ad4add3f17
Parent:        451a168bf8ce913eee5c8c055345413a067569cc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 15 20:20:46 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:38:50 2014 +0200

cleanup: set _REENTRANT in header

Use same way of setting _REENTRANT as in other
files - set it in the first included header file
(clvmd-common.h)
---
 daemons/clvmd/Makefile.in    |    1 -
 daemons/clvmd/clvmd-common.h |    3 +--
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index 0da95a7..d51ea3d 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -87,7 +87,6 @@ include $(top_builddir)/make.tmpl
 LVMLIBS += -ldevmapper
 LIBS += $(PTHREAD_LIBS)
 
-DEFS += -D_REENTRANT
 CFLAGS += -fno-strict-aliasing $(EXTRA_EXEC_CFLAGS)
 LDFLAGS += $(EXTRA_EXEC_LDFLAGS)
 
diff --git a/daemons/clvmd/clvmd-common.h b/daemons/clvmd/clvmd-common.h
index a94edd4..3070e49 100644
--- a/daemons/clvmd/clvmd-common.h
+++ b/daemons/clvmd/clvmd-common.h
@@ -20,14 +20,13 @@
 
 #include "configure.h"
 
+#define _REENTRANT
 #define _GNU_SOURCE
 #define _FILE_OFFSET_BITS 64
 
 #include "libdevmapper.h"
-
 #include "lvm-logging.h"
 
 #include <unistd.h>
-#include <sys/stat.h>
 
 #endif


