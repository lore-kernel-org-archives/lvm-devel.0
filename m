From: Mike Snitzer <snitzer@redhat.com>
Date: Thu,  1 Oct 2009 17:26:15 -0400
Subject: [PATCH] Hide merging snapshots from "lvs" command.
Message-ID: <1254432375-5880-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hide merging snapshots from "lvs" command. The prefix "snapshot" is reserved
and names with this prefix cannot be created by the user, so this change is
safe.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Reviewed-by: Mike Snitzer <snitzer@redhat.com>

---
 tools/toollib.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: lvm2/tools/toollib.c
===================================================================
--- lvm2.orig/tools/toollib.c
+++ lvm2/tools/toollib.c
@@ -119,7 +119,8 @@ int process_each_lv_in_vg(struct cmd_con
 	}
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (lvl->lv->status & SNAPSHOT)
+		/* Names starting with "snapshot" are reserved */
+		if (!strncmp(lvl->lv->name, "snapshot", strlen("snapshot")))
 			continue;
 
 		if (lv_is_virtual_origin(lvl->lv) && !arg_count(cmd, all_ARG))


