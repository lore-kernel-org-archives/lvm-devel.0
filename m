From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 May 2015 22:20:02 +0000 (UTC)
Subject: master - makefiles: drop DEBUG mangling
Message-ID: <20150513222002.5EB176006F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b184d7a2ca03d0ad82cc37007578e8c9d4fa0497
Commit:        b184d7a2ca03d0ad82cc37007578e8c9d4fa0497
Parent:        3fa66d103652df217059e2629da816adb9599e7c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 13 21:33:17 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 14 00:19:33 2015 +0200

makefiles: drop DEBUG mangling

DEBUG is already set through make.tmpl.
---
 daemons/clvmd/Makefile.in |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index d51ea3d..38ff1c7 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -36,10 +36,6 @@ SOURCES = \
 	lvm-functions.c  \
 	refresh_clvmd.c
 
-ifeq ("@DEBUG@", "yes")
-	DEFS += -DDEBUG
-endif
-
 ifneq (,$(findstring cman,, "@CLVMD@,"))
 	SOURCES += clvmd-cman.c
 	LMLIBS += $(CMAN_LIBS) $(CONFDB_LIBS) $(DLM_LIBS)


