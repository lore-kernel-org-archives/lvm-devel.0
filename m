From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 14:30:20 +0000 (UTC)
Subject: master - lvchange: missed bits for a8aee7dba2b76
Message-ID: <20140924143020.6161E601B3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=26dd17f8345f512a48768f7fcf74e0c65558032c
Commit:        26dd17f8345f512a48768f7fcf74e0c65558032c
Parent:        45f57477f46368fbad1864e4606690b274dd2e7d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 24 16:27:35 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 16:30:02 2014 +0200

lvchange: missed bits for a8aee7dba2b76

lv_info is not used here any more.
This code should have been committed with
lv_check_not_in_use API change commit.
---
 tools/lvchange.c |   25 +++++++++++--------------
 1 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 288b736..7976bf3 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -281,7 +281,6 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 	int active = 0;
 	int exclusive = 0;
 	int monitored;
-	struct lvinfo info;
 	struct lv_segment *seg = first_seg(lv);
 	struct dm_list device_list;
 	struct lv_list *lvl;
@@ -311,20 +310,18 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 			return 0;
 		}
 
-		if (info.exists) {
-			if (!arg_count(cmd, yes_ARG) &&
-			    yes_no_prompt("Do you really want to deactivate "
-					  "logical volume %s to resync it? [y/n]: ",
-					  lv->name) == 'n') {
-				log_error("Logical volume \"%s\" not resynced",
-					  lv->name);
-				return 0;
-			}
-
-			active = 1;
-			if (lv_is_active_exclusive_locally(lv))
-				exclusive = 1;
+		if (!arg_count(cmd, yes_ARG) &&
+		    yes_no_prompt("Do you really want to deactivate "
+				  "logical volume %s to resync it? [y/n]: ",
+				  lv->name) == 'n') {
+			log_error("Logical volume \"%s\" not resynced",
+				  lv->name);
+			return 0;
 		}
+
+		active = 1;
+		if (lv_is_active_exclusive_locally(lv))
+			exclusive = 1;
 	}
 
 	if (seg_is_raid(seg) && active && !exclusive) {


