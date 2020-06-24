From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 24 Jun 2020 13:02:44 +0000 (GMT)
Subject: master - cov: remove unused header
Message-ID: <20200624130244.E590B3938C10@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=eb06832b37d6d1e3d1c5fba69c5829d76d5d27a5
Commit:        eb06832b37d6d1e3d1c5fba69c5829d76d5d27a5
Parent:        dccaab3d79c0439fff26fd4d98e7f55be5a14318
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 16 16:38:15 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 24 15:01:03 2020 +0200

cov: remove unused header

---
 lib/metadata/integrity_manip.c  | 1 -
 lib/metadata/writecache_manip.c | 1 -
 2 files changed, 2 deletions(-)

diff --git a/lib/metadata/integrity_manip.c b/lib/metadata/integrity_manip.c
index 334452711..b622743f0 100644
--- a/lib/metadata/integrity_manip.c
+++ b/lib/metadata/integrity_manip.c
@@ -21,7 +21,6 @@
 #include "lib/metadata/segtype.h"
 #include "lib/activate/activate.h"
 #include "lib/config/defaults.h"
-#include "lib/activate/dev_manager.h"
 
 #define DEFAULT_TAG_SIZE 4 /* bytes */
 #define DEFAULT_MODE 'J'
diff --git a/lib/metadata/writecache_manip.c b/lib/metadata/writecache_manip.c
index 7ad8c75e7..fade82ef5 100644
--- a/lib/metadata/writecache_manip.c
+++ b/lib/metadata/writecache_manip.c
@@ -19,7 +19,6 @@
 #include "lib/commands/toolcontext.h"
 #include "lib/display/display.h"
 #include "lib/metadata/segtype.h"
-#include "lib/metadata/lv_alloc.h"
 #include "lib/activate/activate.h"
 #include "lib/config/defaults.h"
 #include "lib/datastruct/str_list.h"


