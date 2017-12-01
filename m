From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 1 Dec 2017 06:20:23 -0500
Subject: master - pvmove: move code from tools to lib
Message-ID: <201712011120.vB1BKNw7029420@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fbd8b456dbc963bbc306e5b3c643d0f67d3a2d6c
Commit:        fbd8b456dbc963bbc306e5b3c643d0f67d3a2d6c
Parent:        94d3878efb7cec344681bf4a2b28774ffebda3ba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 29 22:19:05 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 1 12:18:32 2017 +0100

pvmove: move code from tools to lib

Move code manipulating with locking flags into /lib part of lvm.
---
 lib/metadata/lv_manip.c |    6 ++++++
 tools/pvmove_poll.c     |    5 -----
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 33a4f7d..d4a4b8b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6633,6 +6633,12 @@ int remove_layers_for_segments_all(struct cmd_context *cmd,
 	if (!lv_empty(layer_lv))
 		return_0;
 
+	/* Assumes only used by PVMOVE ATM when unlocking LVs */
+	dm_list_iterate_items(lvl, lvs_changed) {
+		/* FIXME Assumes only one pvmove at a time! */
+		lvl->lv->status &= ~LOCKED;
+	}
+
 	return 1;
 }
 
diff --git a/tools/pvmove_poll.c b/tools/pvmove_poll.c
index f573eb9..e50747c 100644
--- a/tools/pvmove_poll.c
+++ b/tools/pvmove_poll.c
@@ -52,7 +52,6 @@ static int _detach_pvmove_mirror(struct cmd_context *cmd,
 {
 	uint32_t mimage_to_remove = 0;
 	struct dm_list lvs_completed;
-	struct lv_list *lvl;
 
 	/* Update metadata to remove mirror segments and break dependencies */
 	dm_list_init(&lvs_completed);
@@ -67,10 +66,6 @@ static int _detach_pvmove_mirror(struct cmd_context *cmd,
 		return_0;
 	}
 
-	dm_list_iterate_items(lvl, &lvs_completed)
-		/* FIXME Assumes only one pvmove at a time! */
-		lvl->lv->status &= ~LOCKED;
-
 	return 1;
 }
 


