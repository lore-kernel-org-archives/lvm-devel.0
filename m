From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 13 Oct 2013 22:30:53 +0000 (UTC)
Subject: master - snapshot: move virtsnap code from tool to lib
Message-ID: <20131013223053.C5C9C60CFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=81504ba70caec0adaa63cb4a074b7296d109e807
Commit:        81504ba70caec0adaa63cb4a074b7296d109e807
Parent:        6b35c70e8b17b09691d2db6ea2eadba2ee2d095d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 11 22:42:34 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 12 00:14:52 2013 +0200

snapshot: move virtsnap code from tool to lib

Move code for removal dependency from tool's remove.c
into lib's manipulation code.

Same code then works with lvm2app.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    6 +++++-
 tools/lvremove.c        |    8 --------
 3 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d0ed2ce..8d83f71 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104
 ===================================
+  Move code to remove virtual snapshot from tools to lib for lvm2app.
   Fix possible race during daemon worker thread creation (lvmetad).
   Fix possible deadlock while clearing lvmetad cache for full rescan.
   Fix possible race while creating/destroying memory pools.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 22327d7..8f09af7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4685,6 +4685,7 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 	struct dm_list *snh, *snht;
 	struct lv_list *lvl;
 	struct lvinfo info;
+	struct logical_volume *origin;
 	int is_last_pool;
 
 	if (lv_is_cow(lv)) {
@@ -4713,7 +4714,10 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 					return 0;
 				}
 			}
-		}
+		} else if (!level && lv_is_virtual_origin(origin = origin_from_cow(lv)))
+			/* If this is a sparse device, remove its origin too. */
+			/* Stacking is not supported */
+			lv = origin;
 	}
 
 	if (lv_is_origin(lv)) {
diff --git a/tools/lvremove.c b/tools/lvremove.c
index 4f48746..dfc435c 100644
--- a/tools/lvremove.c
+++ b/tools/lvremove.c
@@ -18,14 +18,6 @@
 static int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
 			   void *handle __attribute__((unused)))
 {
-	struct logical_volume *origin;
-
-	/*
-	 * If this is a sparse device, remove its origin too.
-	 */
-        if (lv_is_cow(lv) && lv_is_virtual_origin(origin = origin_from_cow(lv)))
-                lv = origin;
-
 	if (!lv_remove_with_dependencies(cmd, lv, (force_t) arg_count(cmd, force_ARG), 0))
 		return_ECMD_FAILED;
 


