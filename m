From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  8 Jul 2015 15:28:46 +0000 (UTC)
Subject: master - toollib: skip processing the sanlock LV unless named or all
Message-ID: <20150708152846.42CED6052F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=143a9d7ee690c68269572a44f4f1e396916c9b57
Commit:        143a9d7ee690c68269572a44f4f1e396916c9b57
Parent:        6e1f421a6d3a515a9720514bbcceb6789f96dd44
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jul 7 16:04:18 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 8 10:27:21 2015 -0500

toollib: skip processing the sanlock LV unless named or all

This prevents 'lvremove vgname' from attempting to remove the
hidden sanlock LV.  Only vgremove should remove the hidden
sanlock LV holding the sanlock locks.
---
 tools/toollib.c |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 8c301bb..b0b2b01 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2135,13 +2135,26 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		}
 
 		/*
-		 * Only let hidden LVs through it --all was used or the LVs 
+		 * Only let hidden LVs through if --all was used or the LVs 
 		 * were specifically named on the command line.
 		 */
 		if (!lvargs_supplied && !lv_is_visible(lvl->lv) && !arg_count(cmd, all_ARG))
 			continue;
 
 		/*
+		 * Only let sanlock LV through if --all was used or if
+		 * it is named on the command line.
+		 */
+		if (lv_is_lockd_sanlock_lv(lvl->lv)) {
+			if (arg_count(cmd, all_ARG) ||
+			    (lvargs_supplied && str_list_match_item(arg_lvnames, lvl->lv->name))) {
+				log_very_verbose("Processing lockd_sanlock_lv %s/%s.", vg->name, lvl->lv->name);
+			} else {
+				continue;
+			}
+		}
+
+		/*
 		 * process the LV if one of the following:
 		 * - process_all is set
 		 * - LV name matches a supplied LV name


