From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:20:25 +0000 (UTC)
Subject: master - commands: lvremove: also process historical LVs
Message-ID: <20160303132025.2E24E60308@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=53b064b9aed3bd2237638cab778b3bffd018ce08
Commit:        53b064b9aed3bd2237638cab778b3bffd018ce08
Parent:        f833a6d074979813e8bd9980b719b09758bd833a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:27:08 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:50:59 2016 +0100

commands: lvremove: also process historical LVs

---
 lib/metadata/lv_manip.c |   19 +++++++++++++------
 tools/commands.h        |    3 ++-
 tools/lvremove.c        |    1 +
 3 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c612873..85f61a1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5691,7 +5691,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	struct volume_group *vg;
 	struct logical_volume *format1_origin = NULL;
 	int format1_reload_required = 0;
-	int visible;
+	int visible, historical;
 	struct logical_volume *pool_lv = NULL;
 	struct logical_volume *lock_lv = lv;
 	struct lv_segment *cache_seg = NULL;
@@ -5782,7 +5782,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
-	if ((force == PROMPT) && ask_discard &&
+	if (!lv_is_historical(lv) && (force == PROMPT) && ask_discard &&
 	    yes_no_prompt("Do you really want to remove and DISCARD "
 			  "logical volume %s? [y/n]: ",
 			  lv->name) == 'n') {
@@ -5868,10 +5868,15 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	visible = lv_is_visible(lv);
+	historical = lv_is_historical(lv);
 
-	log_verbose("Releasing logical volume \"%s\"", lv->name);
+	log_verbose("Releasing %slogical volume \"%s\"",
+		    historical ? "historical " : "",
+		    historical ? lv->this_glv->historical->name : lv->name);
 	if (!lv_remove(lv)) {
-		log_error("Error releasing logical volume \"%s\"", lv->name);
+		log_error("Error releasing %slogical volume \"%s\"",
+			  historical ? "historical ": "",
+			  historical ? lv->this_glv->historical->name : lv->name);
 		return 0;
 	}
 
@@ -5934,8 +5939,10 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	lockd_lv(cmd, lock_lv, "un", LDLV_PERSISTENT);
 	lockd_free_lv(cmd, vg, lv->name, &lv->lvid.id[1], lv->lock_args);
 
-	if (!suppress_remove_message && visible)
-		log_print_unless_silent("Logical volume \"%s\" successfully removed", lv->name);
+	if (!suppress_remove_message && (visible || historical))
+		log_print_unless_silent("%sogical volume \"%s\" successfully removed",
+					historical ? "Historical l" : "L",
+					historical ? lv->this_glv->historical->name : lv->name);
 
 	return 1;
 }
diff --git a/tools/commands.h b/tools/commands.h
index 97f7de1..bc5eb92 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -606,7 +606,8 @@ xx(lvremove,
    "\t[--version]\n"
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
-   autobackup_ARG, force_ARG, nohistory_ARG, noudevsync_ARG, select_ARG, test_ARG)
+   autobackup_ARG, force_ARG, nohistory_ARG, noudevsync_ARG,
+   select_ARG, test_ARG)
 
 xx(lvrename,
    "Rename a logical volume",
diff --git a/tools/lvremove.c b/tools/lvremove.c
index 220d3e3..18da1fa 100644
--- a/tools/lvremove.c
+++ b/tools/lvremove.c
@@ -24,6 +24,7 @@ int lvremove(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	cmd->handles_missing_pvs = 1;
+	cmd->include_historical_lvs = 1;
 
 	return process_each_lv(cmd, argc, argv, READ_FOR_UPDATE, NULL,
 			       &lvremove_single);


