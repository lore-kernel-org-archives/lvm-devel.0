From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 7 Nov 2017 15:36:21 -0500
Subject: master - cleanup: drop unneeded headerfiles
Message-ID: <201711072036.vA7KaLn2008038@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3076a839a507196548b664ac9fd2307d7fbdb47e
Commit:        3076a839a507196548b664ac9fd2307d7fbdb47e
Parent:        f7f2f77dcad0d23c84a1146de05217beeb3fbde5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 5 18:21:16 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 7 21:26:11 2017 +0100

cleanup: drop unneeded headerfiles

Coverity reported these are no longer in use.
---
 lib/metadata/metadata.c |    1 -
 lib/metadata/pv_manip.c |    4 ----
 2 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2a9819d..b5acf07 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -19,7 +19,6 @@
 #include "toolcontext.h"
 #include "lvm-string.h"
 #include "lvm-file.h"
-#include "lvm-signal.h"
 #include "lvmcache.h"
 #include "lvmetad.h"
 #include "memlock.h"
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index d68561c..e75be76 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -19,12 +19,8 @@
 #include "toolcontext.h"
 #include "locking.h"
 #include "defaults.h"
-#include "lvmcache.h"
-#include "lvmetad.h"
 #include "display.h"
-#include "label.h"
 #include "archiver.h"
-#include "lvm-signal.h"
 
 static struct pv_segment *_alloc_pv_segment(struct dm_pool *mem,
 					    struct physical_volume *pv,


