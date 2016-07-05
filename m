From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 19:22:59 +0000 (UTC)
Subject: master - libdm: ensure flags constants have ULL suffix
Message-ID: <20160705192259.CB35860ED3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f1dd0258f1cb27e62d1133ba41c75bca04a7b174
Commit:        f1dd0258f1cb27e62d1133ba41c75bca04a7b174
Parent:        93034d0b695a72deebe51b3eb7075366728ba0f7
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Jul 5 20:21:49 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 20:21:49 2016 +0100

libdm: ensure flags constants have ULL suffix

The walk flags used by libdm-stats use the upper portion of a 64b
value: use the ULL suffix to ensure the compiler knows the expected
size.
---
 libdm/libdevmapper.h |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index e769be2..415928c 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1010,11 +1010,11 @@ typedef enum {
  * the resulting walk will visit instance of each type specified by
  * the flag combination.
  */
-#define DM_STATS_WALK_AREA   0x1000000000000
-#define DM_STATS_WALK_REGION 0x2000000000000
-#define DM_STATS_WALK_GROUP  0x4000000000000
+#define DM_STATS_WALK_AREA   0x1000000000000ULL
+#define DM_STATS_WALK_REGION 0x2000000000000ULL
+#define DM_STATS_WALK_GROUP  0x4000000000000ULL
 
-#define DM_STATS_WALK_ALL    0x7000000000000
+#define DM_STATS_WALK_ALL    0x7000000000000ULL
 #define DM_STATS_WALK_DEFAULT (DM_STATS_WALK_AREA | DM_STATS_WALK_REGION)
 
 /*
@@ -1024,7 +1024,7 @@ typedef enum {
  * suppress these duplicate entries during a dm_stats_walk_* with the
  * DM_STATS_WALK_REGION flag set.
  */
-#define DM_STATS_WALK_SKIP_SINGLE_AREA   0x8000000000000
+#define DM_STATS_WALK_SKIP_SINGLE_AREA   0x8000000000000ULL
 
 /*
  * Initialise the cursor control of a dm_stats handle for the specified


