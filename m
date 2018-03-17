From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 17 Mar 2018 18:34:57 -0400
Subject: master - coverity: drop unneeded header files
Message-ID: <201803172234.w2HMYv95011247@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aa75e181bec4e61ac08a5f1029e966d0593c5d45
Commit:        aa75e181bec4e61ac08a5f1029e966d0593c5d45
Parent:        b4c69320fcccaf5257039c3489d5227e82183f8a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 17 14:00:21 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 17 23:33:58 2018 +0100

coverity: drop unneeded header files

---
 lib/locking/file_locking.c |    1 -
 lib/misc/lvm-globals.c     |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 517a64f..8dbc54e 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -21,7 +21,6 @@
 #include "defaults.h"
 #include "lvm-string.h"
 #include "lvm-flock.h"
-#include "lvmcache.h"
 
 #include <limits.h>
 #include <unistd.h>
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index be33091..0575d21 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -15,7 +15,6 @@
 
 #include "lib.h"
 #include "device.h"
-#include "memlock.h"
 #include "lvm-string.h"
 #include "defaults.h"
 #include "metadata-exported.h"


