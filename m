From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 25 Jul 2016 20:16:41 +0000 (UTC)
Subject: master - lvconvert: --trackchanges requires --splitmirrors 1
Message-ID: <20160725201641.7BFD161C79@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d180bf63119580073235191c3527c9c8ee9cacbb
Commit:        d180bf63119580073235191c3527c9c8ee9cacbb
Parent:        d0e15b86b53bd4960a7c15a7771548ab4aface8b
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jul 25 21:15:25 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jul 25 21:15:25 2016 +0100

lvconvert: --trackchanges requires --splitmirrors 1

---
 WHATS_NEW         |    2 +-
 tools/lvconvert.c |   10 ++++++++--
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b80d189..c96b5be 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,6 @@
 Version 2.02.162 - 
 =================================
-  Improve lvconvert --trackchanges validation to require --splitmirrors.
+  Improve lvconvert --trackchanges validation to require --splitmirrors 1.
   Add note about lastlog built-in command to lvm man page.
   Fix unrecognised segtype flag message.
   lvconvert reuse cachepool metadade now ONLY with -Zn and clear otherwise.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 91765d6..c0838d1 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1894,6 +1894,13 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 				  lp->keep_mimages ? "split" : "reduce");
 			return 0;
 		}
+
+		/* --trackchanges requires --splitmirrors which always has SIGN_MINUS */
+		if (lp->track_changes && lp->mirrors != 1) {
+                        log_error("Exactly one image must be split off from %s when tracking changes.",
+				  display_lvname(lv));
+                        return 0;
+                }
 	}
 
 	if (lp->merge_mirror)
@@ -1903,8 +1910,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		return lv_raid_split_and_track(lv, lp->pvh);
 
 	if (lp->keep_mimages)
-		return lv_raid_split(lv, lp->lv_split_name,
-				     image_count, lp->pvh);
+		return lv_raid_split(lv, lp->lv_split_name, image_count, lp->pvh);
 
 	if (lp->mirrors_supplied)
 		return lv_raid_change_image_count(lv, image_count, lp->pvh);


