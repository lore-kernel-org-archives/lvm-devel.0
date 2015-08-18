From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Aug 2015 13:01:36 +0000 (UTC)
Subject: master - cleanup: unused header files (Coverity)
Message-ID: <20150818130136.EB75B60643@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=55a9262bdbc53acbd79035e904e7e00df8eec88b
Commit:        55a9262bdbc53acbd79035e904e7e00df8eec88b
Parent:        ba94d0f144844ff3fb15d0a2a87ccf7f27f550bc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 18 12:31:20 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 18 15:00:08 2015 +0200

cleanup: unused header files (Coverity)

---
 lib/config/config.c       |    1 -
 lib/metadata/raid_manip.c |    1 -
 lib/metadata/vg.c         |    1 -
 libdm/libdm-stats.c       |    2 --
 4 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 0c3cf92..ac1049d 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -23,7 +23,6 @@
 #include "toolcontext.h"
 #include "lvm-file.h"
 #include "memlock.h"
-#include "segtype.h"
 
 #include <sys/stat.h>
 #include <sys/mman.h>
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index c574a14..8ecdc02 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -21,7 +21,6 @@
 #include "activate.h"
 #include "lv_alloc.h"
 #include "lvm-string.h"
-#include "lvmlockd.h"
 
 static int _lv_is_raid_with_tracking(const struct logical_volume *lv,
 				     struct logical_volume **tracking)
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 0e5aee5..ca2bf96 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -20,7 +20,6 @@
 #include "toolcontext.h"
 #include "lvmcache.h"
 #include "archiver.h"
-#include "lvmlockd.h"
 
 struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 			      const char *vg_name)
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index f231016..4b4135a 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -13,8 +13,6 @@
  */
 
 #include "dmlib.h"
-#include "libdm-targets.h"
-#include "libdm-common.h"
 
 #define DM_STATS_REGION_NOT_PRESENT UINT64_MAX
 


