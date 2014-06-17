From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Jun 2014 13:24:33 +0000 (UTC)
Subject: master - snapshot: do not spawn when origin is not active
Message-ID: <20140617132433.97DDD61207@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=15e7066fe3ea7ca9129b68e3b39e9667348a02cc
Commit:        15e7066fe3ea7ca9129b68e3b39e9667348a02cc
Parent:        c46d4a745dc8c5cb4cfc0c94863e555387e9af75
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 16 12:43:22 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 17 13:36:07 2014 +0200

snapshot: do not spawn when origin is not active

Since the code is not doing anything when origin is not active,
avoid spawning polling thread.
---
 tools/toollib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index add20e3..c619d9b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1455,7 +1455,7 @@ int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv)
 	 * - fortunately: polldaemon will immediately shutdown if the
 	 *   origin doesn't have a status with a snapshot percentage
 	 */
-	if (background_polling() && lv_is_merging_origin(lv))
+	if (background_polling() && lv_is_merging_origin(lv) && lv_is_active_locally(lv))
 		lv_spawn_background_polling(cmd, lv);
 
 	return 1;


