From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:39:48 +0000 (UTC)
Subject: dev-dct-process-latest - Revert "toollib: print ignoring vorigin"
Message-ID: <20140922153948.BD80E60228@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aa33c4245b312cc883890d19e5d769a3d3c441ba
Commit:        aa33c4245b312cc883890d19e5d769a3d3c441ba
Parent:        392bb6f46eb73dcf725566fbdf006a4e02ae7502
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 4 13:27:05 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 22 10:32:23 2014 -0500

Revert "toollib: print ignoring vorigin"

This reverts commit 7f4b1e7411d7ff59abe2063db7273fd600e2bf72.

will reapply this on top of toollib patch set
---
 tools/toollib.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 7be5b5a..03d83e5 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -230,13 +230,8 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 		    lv_is_cow(lvl->lv) && !lv_is_virtual_origin(origin_from_cow(lvl->lv)))
 			continue;
 
-		if (lv_is_virtual_origin(lvl->lv) && !arg_count(cmd, all_ARG)) {
-			if (lvargs_supplied &&
-			    str_list_match_item(arg_lvnames, lvl->lv->name))
-				log_print_unless_silent("Ignoring virtual origin logical volume %s.",
-							display_lvname(lvl->lv));
+		if (lv_is_virtual_origin(lvl->lv) && !arg_count(cmd, all_ARG))
 			continue;
-		}
 
 		/*
 		 * Only let hidden LVs through it --all was used or the LVs 


