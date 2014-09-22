From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:40:13 +0000 (UTC)
Subject: dev-dct-process-latest - toollib: print ignoring vorigin
Message-ID: <20140922154013.E621560D27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6be399b5ebb0f9a0e0d345747d1c164cc3911e2e
Commit:        6be399b5ebb0f9a0e0d345747d1c164cc3911e2e
Parent:        57d65e0681aeba46f221cea7e5686d531f4f53ae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 4 13:31:17 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 22 10:32:24 2014 -0500

toollib: print ignoring vorigin

When ignoring 'listed' volume, print info message.
(So the final command error message is a bit less confusing,
i.e. when user tries to deactive virtual origin:

> lvchange -an vg/lvol2_vorigin
Ignoring virtual origin logical volume vg/lvol2_vorigin.
One or more specified logical volume(s) not found.

(Reapplied after revert.)
---
 tools/toollib.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 903ea19..0c671ac 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1505,8 +1505,14 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 		    lv_is_cow(lvl->lv) && !lv_is_virtual_origin(origin_from_cow(lvl->lv)))
 			continue;
 
-		if (lv_is_virtual_origin(lvl->lv) && !arg_count(cmd, all_ARG))
+		if (lv_is_virtual_origin(lvl->lv) && !arg_count(cmd, all_ARG)) {
+			if (lvargs_supplied &&
+			    str_list_match_item(arg_lvnames, lvl->lv->name))
+				log_print_unless_silent("Ignoring virtual origin logical 
+							display_lvname(lvl->lv));
+
 			continue;
+		}
 
 		/*
 		 * Only let hidden LVs through it --all was used or the LVs 


