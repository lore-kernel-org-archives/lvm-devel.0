From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 1 Aug 2017 12:34:36 -0400
Subject: master - makefiles: fix tested vars
Message-ID: <201708011634.v71GYaCw018020@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9dc1f51d2825c5e48da06e20a9c7a570fbef09a3
Commit:        9dc1f51d2825c5e48da06e20a9c7a570fbef09a3
Parent:        95dd5bc7fb7dc818116ee367aaa3079f410e2cf7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 1 18:18:05 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 1 18:18:05 2017 +0200

makefiles: fix tested vars

For resolving usability of DEBUG_MEM - check proper translated make
vars for proper value.
---
 make.tmpl.in |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 17276c3..91f38b8 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -243,12 +243,12 @@ endif
   CFLAGS += -fno-omit-frame-pointer
   DEFS += -DDEBUG
   # memory debugging is not thread-safe yet
-  ifneq ("@DMEVENTD@", "yes")
-  ifneq ("@DMFILEMAPD@", "yes")
-  ifneq ("@LVMLOCKD@", "yes")
-  ifneq ("@LVMPOLLD@", "yes")
-  ifneq ("@LVMETAD@", "yes")
-  ifneq ("@CLVMD@", "yes")
+  ifneq ("@BUILD_DMEVENTD@", "yes")
+  ifneq ("@BUILD_DMFILEMAPD@", "yes")
+  ifneq ("@BUILD_LVMLOCKD@", "yes")
+  ifneq ("@BUILD_LVMPOLLD@", "yes")
+  ifneq ("@BUILD_LVMETAD@", "yes")
+  ifeq ("@CLVMD@", "none")
     DEFS += -DDEBUG_MEM
   endif
   endif


