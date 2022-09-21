From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 21 Sep 2022 12:59:04 +0000 (GMT)
Subject: main - makefiles: use single libs definition
Message-ID: <20220921125904.861FD3856DC4@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cbfdb8735831412a7c87ce57c0ada5f1ee1c2358
Commit:        cbfdb8735831412a7c87ce57c0ada5f1ee1c2358
Parent:        1bf1aca544e6d422d34aea356e69d6dbf0bdf3ba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 5 15:57:21 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 21 14:58:34 2022 +0200

makefiles: use single libs definition

---
 make.tmpl.in | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index a390553a4..869b87e12 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -298,9 +298,7 @@ endif
 endif
 
 ifeq ("@BUILD_DMEVENTD@", "yes")
-  DMEVENT_LIBS = -ldevmapper-event -L$(interfacebuilddir) -ldevmapper
-  LDFLAGS += -L$(top_builddir)/daemons/dmeventd
-  CLDFLAGS += -L$(top_builddir)/daemons/dmeventd
+  DMEVENT_LIBS = -L$(top_builddir)/daemons/dmeventd -ldevmapper-event -L$(interfacebuilddir) -ldevmapper
 endif
 
 # Combination of DEBUG_POOL and DEBUG_ENFORCE_POOL_LOCKING is not suppored.

