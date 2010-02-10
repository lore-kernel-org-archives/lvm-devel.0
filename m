From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 10 Feb 2010 15:56:56 +0100
Subject: [PATCH 10/19] Replicator: using vgs_missed for error count
In-Reply-To: <cover.1265813098.git.zkabelac@redhat.com>
References: <cover.1265813098.git.zkabelac@redhat.com>
Message-ID: <5c0611c8c27e956f3b99363f546b31ee533904ed.1265813098.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Lower expected_count for the case of missed VGs so no error is printed
in case the remote VGs are not opened. Currently it's needed only for
Replicator target.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/commands/toolcontext.h |    1 +
 tools/toollib.c            |    7 +++++++
 tools/vgchange.c           |   12 ++++++++++--
 3 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 533cd04..2723725 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -55,6 +55,7 @@ struct replicator_info {
 	struct dm_list vgs_lvs_retry;	/* Retry LVs with more VGs */
 	struct dm_list vgs_list;	/* Required read-only VGs */
 	int vgs_missed;			/* Missed VGs */
+	char *vgs_print;		/* Error case print */
 };
 
 struct config_tree;
diff --git a/tools/toollib.c b/tools/toollib.c
index 34683e9..fc750e1 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -559,6 +559,13 @@ static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 			}
 	}
 out:
+	if (cmd->rep_info.vgs_print) {
+		/* Postponed print */
+		log_print("%s", cmd->rep_info.vgs_print);
+		dm_free(cmd->rep_info.vgs_print);
+		cmd->rep_info.vgs_print = NULL;
+	}
+
 	dm_list_iterate_back_items(vnl, &cmd->rep_info.vgs_list)
 		if (vnl->vg) {
 			unlock_and_release_vg(cmd, vnl->vg, vnl->name);
diff --git a/tools/vgchange.c b/tools/vgchange.c
index b4f5d00..29d891b 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -145,6 +145,7 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd,
 		count++;
 	}
 
+	expected_count -= cmd->rep_info.vgs_missed;
 	if (expected_count)
 		log_verbose("%s %d logical volumes in volume group %s",
 			    (activate == CHANGE_AN || activate == CHANGE_ALN)?
@@ -224,8 +225,15 @@ static int _vgchange_available(struct cmd_context *cmd, struct volume_group *vg)
 
 	ret = _activate_lvs_in_vg(cmd, vg, available);
 
-	log_print("%d logical volume(s) in volume group \"%s\" now active",
-		  lvs_in_vg_activated(vg), vg->name);
+	/* Postpone print */
+	dm_free(cmd->rep_info.vgs_print);
+	if (dm_asprintf(&cmd->rep_info.vgs_print,
+			"%d logical volume(s) in volume group \"%s\" now active",
+			lvs_in_vg_activated(vg), vg->name) < 0) {
+		log_error("Failed to allocate memory for active message");
+		cmd->rep_info.vgs_print = NULL;
+	}
+
 	return ret;
 }
 
-- 
1.6.6.1


