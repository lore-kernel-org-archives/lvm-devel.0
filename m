From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Dec 2018 05:08:32 -0500
Subject: master - makefiles: no longer used define
Message-ID: <201812171008.wBHA8Wv7024811@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=143c8dcd7f20f6ac07eeb859c5fa8d7fad9a5a44
Commit:        143c8dcd7f20f6ac07eeb859c5fa8d7fad9a5a44
Parent:        a66520645395eb2ee19a8a9bc924a5a618330379
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 15 00:20:15 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 17 10:51:01 2018 +0100

makefiles: no longer used define

Not used anymore -D_BUILDING_LVM
---
 libdm/make.tmpl.in |    2 --
 make.tmpl.in       |    2 --
 2 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index cc1642a..92f2f55 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -249,8 +249,6 @@ endif
 # end of fPIC protection
 endif
 
-DEFS += -D_BUILDING_LVM
-
 LDFLAGS += -L$(top_builddir)/libdm
 CLDFLAGS += -L$(top_builddir)/libdm
 
diff --git a/make.tmpl.in b/make.tmpl.in
index 13f9afc..56d7cd6 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -267,8 +267,6 @@ endif
 # end of fPIC protection
 endif
 
-DEFS += -D_BUILDING_LVM
-
 LDFLAGS += -L$(top_builddir)/lib
 CLDFLAGS += -L$(top_builddir)/lib
 


