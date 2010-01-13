From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 13 Jan 2010 14:42:14 +0100
Subject: [PATCH 10/18] Replicator: add vgs_print for message postponing
In-Reply-To: <cover.1263389894.git.zkabelac@redhat.com>
References: <cover.1263389894.git.zkabelac@redhat.com>
Message-ID: <3ff59fac51270d7b0a5be5c8b63f204383628529.1263389894.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

For replicator we introduce multiple runs over the same function.
In the first step some error prints could be generated, because not all
resources were available. Such message could be postponed so usually
only the last message gets printed.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/commands/toolcontext.h |    1 +
 tools/toollib.c            |    7 +++++++
 tools/vgchange.c           |   11 +++++++++--
 3 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index c7333f6..3b25af2 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -64,6 +64,7 @@ struct cmd_context {
 	struct dm_list vgs_list;	/* Required read-only VGs */
 	struct dm_list vgs_lvs_retry;	/* Retry LVs with more VGs */
 	int vgs_missed;			/* Missed VGs */
+	char *vgs_print;		/* Error case print */
 	const char *hostname;
 	const char *kernel_vsn;
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 6243600..afd945c 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -561,6 +561,13 @@ static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 			}
 	}
 out:
+	if (cmd->vgs_print) {
+		/* Postponed print */
+		log_print("%s", cmd->vgs_print);
+		dm_free(cmd->vgs_print);
+		cmd->vgs_print = NULL;
+	}
+
 	dm_list_iterate_back_items(vnl, &cmd->vgs_list)
 		if (vnl->vg) {
 			unlock_and_release_vg(cmd, vnl->vg, vnl->name);
diff --git a/tools/vgchange.c b/tools/vgchange.c
index c976746..068f12b 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -225,8 +225,15 @@ static int _vgchange_available(struct cmd_context *cmd, struct volume_group *vg)
 
 	ret = _activate_lvs_in_vg(cmd, vg, available);
 
-	log_print("%d logical volume(s) in volume group \"%s\" now active",
-		  lvs_in_vg_activated(vg), vg->name);
+	/* Postpone print */
+	dm_free(cmd->vgs_print);
+	if (dm_asprintf(&cmd->vgs_print,
+			"%d logical volume(s) in volume group \"%s\" now active",
+			lvs_in_vg_activated(vg), vg->name) < 0) {
+		log_error("Failed to allocate memory for active message");
+		cmd->vgs_print = NULL;
+	}
+
 	return ret;
 }
 
-- 
1.6.6


