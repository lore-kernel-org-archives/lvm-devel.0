From: okozina <okozina@fedoraproject.org>
Date: Mon, 13 Apr 2015 18:53:58 +0000 (UTC)
Subject: master - toollib: do not spawn polling in lv_change_activate
Message-ID: <20150413185358.85753606D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c26d81d6e6939906729d91fae83cd8bbdd743bb7
Commit:        c26d81d6e6939906729d91fae83cd8bbdd743bb7
Parent:        59c417379e067f85cd962c2024f7a042f04a41fd
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Wed Apr 8 12:05:14 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon Apr 13 20:52:22 2015 +0200

toollib: do not spawn polling in lv_change_activate

spawning a background polling from within the lv_change_activate
fn went to two problems:

1) vgchange should not spawn any background polling until after
   the whole activation process for a VG is finished. Otherwise
   it could lead to a duplicite request for spawning background
   polling. This statement was alredy true with one exception of
   mirror up-conversion polling (fixed by this commit).

2) due to current conditions in lv_change_activate lvchange cmd
   couldn't start background polling for pvmove LVs if such LV was
   about to get activated by the command in the same time.

This commit however doesn't alter the lvchange cmd so that it works same as
vgchange with regard to not to spawn duplicate background pollings per
unique LV.
---
 tools/lvchange.c |   13 +++++++++++++
 tools/toollib.c  |    5 -----
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 096aae4..e790ea0 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -212,6 +212,19 @@ static int _lvchange_activate(struct cmd_context *cmd, struct logical_volume *lv
 	if (!lv_change_activate(cmd, lv, activate))
 		return_0;
 
+	/*
+	 * FIXME: lvchange should defer background polling in a similar
+	 * 	  way as vgchange does. First activate all relevant LVs
+	 * 	  initate background polling later (for all actually
+	 * 	  activated LVs). So we can avoid duplicate background
+	 * 	  polling for pvmove (2 or more locked LVs on single pvmove
+	 * 	  LV)
+	 */
+	if (background_polling() && is_change_activating(activate) &&
+	    (lv_is_pvmove(lv) || lv_is_locked(lv) || lv_is_converting(lv) ||
+	     lv_is_merging(lv)))
+		lv_spawn_background_polling(cmd, lv);
+
 	return 1;
 }
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 142ff33..4856f02 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -843,11 +843,6 @@ int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!lv_active_change(cmd, lv, activate, 0))
 		return_0;
 
-	if (background_polling() &&
-	    is_change_activating(activate) &&
-	    (lv_is_pvmove(lv) || lv_is_converting(lv) || lv_is_merging(lv)))
-		lv_spawn_background_polling(cmd, lv);
-
 	return r;
 }
 


