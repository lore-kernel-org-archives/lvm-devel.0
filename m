From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Aug 2014 13:55:06 +0000 (UTC)
Subject: master - cleanup: use display_lvname
Message-ID: <20140815135506.A47C6603FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ec41bd1920be119538cd9c98a8fc3d38e184803f
Commit:        ec41bd1920be119538cd9c98a8fc3d38e184803f
Parent:        c894c3c87f7de3b1491455186fa49404685b2b10
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 15 15:52:01 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 15 15:53:17 2014 +0200

cleanup: use display_lvname

Show more complete LV names.
---
 tools/lvchange.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index db03176..42769c2 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1012,9 +1012,10 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 		if (!arg_count(cmd, yes_ARG) &&
 		    (yes_no_prompt("Change of snapshot %s will also change its "
-				   "origin %s%s. Proceed? [y/n]: ", lv->name,
-				   origin->name, snaps_msg) == 'n')) {
-			log_error("Logical volume %s not changed.", lv->name);
+				   "origin %s%s. Proceed? [y/n]: ",
+				   display_lvname(lv), display_lvname(origin),
+				   snaps_msg) == 'n')) {
+			log_error("Logical volume %s not changed.", display_lvname(lv));
 			return ECMD_FAILED;
 		}
 	}


