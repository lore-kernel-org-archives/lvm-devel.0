From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Aug 2014 13:07:33 +0000 (UTC)
Subject: master - toollib: print ignoring vorigin
Message-ID: <20140815130733.9AB1660319@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7f4b1e7411d7ff59abe2063db7273fd600e2bf72
Commit:        7f4b1e7411d7ff59abe2063db7273fd600e2bf72
Parent:        10e3715564e80e08daf04f0ae51067a04dfaa7b8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 15 13:53:04 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 15 15:06:44 2014 +0200

toollib: print ignoring vorigin

When ignoring 'listed' volume, print info message.
(So the final command error message is a bit less confusing,
i.e. when user tries to deactive virtual origin:

> lvchange -an vg/lvol2_vorigin
  Ignoring virtual origin logical volume vg/lvol2_vorigin.
  One or more specified logical volume(s) not found.
---
 tools/toollib.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index d6ef845..25ff21d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -230,8 +230,13 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 		    lv_is_cow(lvl->lv) && !lv_is_virtual_origin(origin_from_cow(lvl->lv)))
 			continue;
 
-		if (lv_is_virtual_origin(lvl->lv) && !arg_count(cmd, all_ARG))
+		if (lv_is_virtual_origin(lvl->lv) && !arg_count(cmd, all_ARG)) {
+			if (lvargs_supplied &&
+			    str_list_match_item(arg_lvnames, lvl->lv->name))
+				log_print_unless_silent("Ignoring virtual origin logical volume %s.",
+							display_lvname(lvl->lv));
 			continue;
+		}
 
 		/*
 		 * Only let hidden LVs through it --all was used or the LVs 


