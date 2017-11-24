From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 24 Nov 2017 10:11:32 -0500
Subject: master - cleanup: update error messages
Message-ID: <201711241511.vAOFBWo9000781@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7bffbe0e2f7f43acf9cdb93f9d24cfb8638c7e7b
Commit:        7bffbe0e2f7f43acf9cdb93f9d24cfb8638c7e7b
Parent:        b0398f42ad125ca084e2b6942e23cacaafabd98e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 21 15:33:29 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 24 16:09:59 2017 +0100

cleanup: update error messages

Correct printed lv names in error messages
and add missing trace for return.
---
 tools/lvconvert.c   |   18 +++++++++---------
 tools/pvmove_poll.c |    2 +-
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d5491a7..deb7cc9 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2328,15 +2328,15 @@ static int _lvconvert_thin_pool_repair(struct cmd_context *cmd,
 deactivate_mlv:
 	if (!deactivate_lv(cmd, mlv)) {
 		log_error("Cannot deactivate thin pool metadata volume %s.",
-			  mlv->name);
-		return 0;
+			  display_lvname(mlv));
+		ret = 0;
 	}
 
 deactivate_pmslv:
 	if (!deactivate_lv(cmd, pmslv)) {
-		log_error("Cannot deactivate thin pool metadata volume %s.",
-			  mlv->name);
-		return 0;
+		log_error("Cannot deactivate pool metadata spare volume %s.",
+			  display_lvname(pmslv));
+		ret = 0;
 	}
 
 	if (!ret)
@@ -2500,15 +2500,15 @@ static int _lvconvert_cache_repair(struct cmd_context *cmd,
 deactivate_mlv:
 	if (!deactivate_lv(cmd, mlv)) {
 		log_error("Cannot deactivate pool metadata volume %s.",
-			  mlv->name);
-		return 0;
+			  display_lvname(mlv));
+		ret = 0;
 	}
 
 deactivate_pmslv:
 	if (!deactivate_lv(cmd, pmslv)) {
 		log_error("Cannot deactivate pool metadata spare volume %s.",
-			  mlv->name);
-		return 0;
+			  display_lvname(pmslv));
+		ret = 0;
 	}
 
 	if (!ret)
diff --git a/tools/pvmove_poll.c b/tools/pvmove_poll.c
index 982bf96..f573eb9 100644
--- a/tools/pvmove_poll.c
+++ b/tools/pvmove_poll.c
@@ -64,7 +64,7 @@ static int _detach_pvmove_mirror(struct cmd_context *cmd,
 	if (!lv_remove_mirrors(cmd, lv_mirr, 1, 0, _is_pvmove_image_removable, &mimage_to_remove, PVMOVE) ||
 	    !remove_layers_for_segments_all(cmd, lv_mirr, PVMOVE,
 					    &lvs_completed)) {
-		return 0;
+		return_0;
 	}
 
 	dm_list_iterate_items(lvl, &lvs_completed)


