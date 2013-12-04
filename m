From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  4 Dec 2013 13:31:35 +0000 (UTC)
Subject: master - merge: test only for meging origin
Message-ID: <20131204133135.7F74C60EB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cf7f4512384bac494fd352762f685377e2f10034
Commit:        cf7f4512384bac494fd352762f685377e2f10034
Parent:        993831bdb15657b1fc6b9985cdaca9e3ccc1cfbc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 29 11:01:02 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 4 14:30:25 2013 +0100

merge: test only for meging origin

It's enough to check only for merging origin.
This will be also used for thin volume merges which
do not need to be origins.
---
 WHATS_NEW       |    1 +
 tools/toollib.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c7c028a..cba7c8f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Drop extra test for origin when testing merging origin in lv_refresh().
   Extend lv_remove_single() to not print info about removed LV.
   Replace open_count check with lv_check_not_in_use() for snapshot open test.
   Add error messages with LV names for failing lv refresh.
diff --git a/tools/toollib.c b/tools/toollib.c
index 868fc69..183d832 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1442,7 +1442,7 @@ int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv)
 	 * - fortunately: polldaemon will immediately shutdown if the
 	 *   origin doesn't have a status with a snapshot percentage
 	 */
-	if (background_polling() && lv_is_origin(lv) && lv_is_merging_origin(lv))
+	if (background_polling() && lv_is_merging_origin(lv))
 		lv_spawn_background_polling(cmd, lv);
 
 	return 1;


