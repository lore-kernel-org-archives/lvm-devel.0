From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  4 Dec 2009 15:04:57 +0100
Subject: [PATCH 14/22] Replicator: add vgs_print for message postponing
In-Reply-To: <cover.1259934415.git.zkabelac@redhat.com>
References: <cover.1259934415.git.zkabelac@redhat.com>
Message-ID: <ea145dd780e1e1cfe3b85c15a93979e78fa0da03.1259934415.git.zkabelac@redhat.com>
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
 tools/vgchange.c           |   10 ++++++++--
 3 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index c48276c..44ebe1f 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -63,6 +63,7 @@ struct cmd_context {
 	struct dm_list vgs_list;	/* Required read-only VGs */
 	struct dm_list vgs_lvs_retry;	/* Retry LVs with more VGs */
 	int vgs_missed;			/* Missed VGs */
+	char *vgs_print;		/* Error case print */
 	const char *hostname;
 	const char *kernel_vsn;
 
diff --git a/tools/toollib.c b/tools/toollib.c
index f76879f..e784fb7 100644
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
index 9da877e..7171f5d 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -168,8 +168,14 @@ static int _vgchange_available(struct cmd_context *cmd, struct volume_group *vg)
 
 	ret = _activate_lvs_in_vg(cmd, vg, available);
 
-	log_print("%d logical volume(s) in volume group \"%s\" now active",
-		  lvs_in_vg_activated(vg), vg->name);
+	/* Postpone print */
+	dm_free(cmd->vgs_print);
+	if (dm_asprintf(&cmd->vgs_print,
+			"%d logical volume(s) in volume group \"%s\" now active",
+			lvs_in_vg_activated(vg), vg->name) < 0) {
+		cmd->vgs_print = NULL;
+	}
+
 	return ret;
 }
 
-- 
1.6.5.3


