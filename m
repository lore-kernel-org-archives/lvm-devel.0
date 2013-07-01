From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  1 Jul 2013 21:13:29 +0000 (UTC)
Subject: master - vg/lvchange: drop local archived handling
Message-ID: <20130701211329.D68CD610D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4d9ed81075729936666b151f981461f91e8f7437
Commit:        4d9ed81075729936666b151f981461f91e8f7437
Parent:        e30028004b45a962c525685824e25dad80b7fbcf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jun 30 18:03:34 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 1 23:10:33 2013 +0200

vg/lvchange: drop local archived handling

Drop code handling archived flag now handled implicitely.
---
 tools/lvchange.c |   26 ++++++++------------------
 tools/vgchange.c |    6 ++----
 2 files changed, 10 insertions(+), 22 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index c88d8ef..f4706d1 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -863,7 +863,6 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 			   void *handle __attribute__((unused)))
 {
 	int doit = 0, docmds = 0;
-	int archived = 0;
 	struct logical_volume *origin;
 	char snaps_msg[128];
 
@@ -955,40 +954,36 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 			stack;
 			return ECMD_FAILED;
 		}
-		archived = 1;
 		doit += lvchange_permission(cmd, lv);
 		docmds++;
 	}
 
 	/* allocation policy change */
 	if (arg_count(cmd, contiguous_ARG) || arg_count(cmd, alloc_ARG)) {
-		if (!archived && !archive(lv->vg)) {
+		if (!archive(lv->vg)) {
 			stack;
 			return ECMD_FAILED;
 		}
-		archived = 1;
 		doit += lvchange_alloc(cmd, lv);
 		docmds++;
 	}
 
 	/* read ahead sector change */
 	if (arg_count(cmd, readahead_ARG)) {
-		if (!archived && !archive(lv->vg)) {
+		if (!archive(lv->vg)) {
 			stack;
 			return ECMD_FAILED;
 		}
-		archived = 1;
 		doit += lvchange_readahead(cmd, lv);
 		docmds++;
 	}
 
 	/* persistent device number change */
 	if (arg_count(cmd, persistent_ARG)) {
-		if (!archived && !archive(lv->vg)) {
+		if (!archive(lv->vg)) {
 			stack;
 			return ECMD_FAILED;
 		}
-		archived = 1;
 		doit += lvchange_persistent(cmd, lv);
 		docmds++;
 		if (sigint_caught()) {
@@ -999,44 +994,40 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (arg_count(cmd, discards_ARG) ||
 	    arg_count(cmd, zero_ARG)) {
-		if (!archived && !archive(lv->vg)) {
+		if (!archive(lv->vg)) {
 			stack;
 			return ECMD_FAILED;
 		}
-		archived = 1;
 		doit += lvchange_pool_update(cmd, lv);
 		docmds++;
 	}
 
 	/* add tag */
 	if (arg_count(cmd, addtag_ARG)) {
-		if (!archived && !archive(lv->vg)) {
+		if (!archive(lv->vg)) {
 			stack;
 			return ECMD_FAILED;
 		}
-		archived = 1;
 		doit += lvchange_tag(cmd, lv, addtag_ARG);
 		docmds++;
 	}
 
 	/* del tag */
 	if (arg_count(cmd, deltag_ARG)) {
-		if (!archived && !archive(lv->vg)) {
+		if (!archive(lv->vg)) {
 			stack;
 			return ECMD_FAILED;
 		}
-		archived = 1;
 		doit += lvchange_tag(cmd, lv, deltag_ARG);
 		docmds++;
 	}
 
 	/* change writemostly/writebehind */
 	if (arg_count(cmd, writemostly_ARG) || arg_count(cmd, writebehind_ARG)) {
-		if (!archived && !archive(lv->vg)) {
+		if (!archive(lv->vg)) {
 			stack;
 			return ECMD_FAILED;
 		}
-		archived = 1;
 		doit += lvchange_writemostly(lv);
 		docmds++;
 	}
@@ -1044,11 +1035,10 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	/* change [min|max]_recovery_rate */
 	if (arg_count(cmd, minrecoveryrate_ARG) ||
 	    arg_count(cmd, maxrecoveryrate_ARG)) {
-		if (!archived && !archive(lv->vg)) {
+		if (!archive(lv->vg)) {
 			stack;
 			return ECMD_FAILED;
 		}
-		archived = 1;
 		doit += lvchange_recovery_rate(lv);
 		docmds++;
 	}
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 71982f1..e9093f5 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -425,7 +425,6 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg,
 			   void *handle __attribute__((unused)))
 {
-	int archived = 0;
 	int i;
 
 	static struct {
@@ -465,11 +464,10 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 
 	for (i = 0; _vgchange_args[i].arg >= 0; i++) {
 		if (arg_count(cmd, _vgchange_args[i].arg)) {
-			if (!archived && !archive(vg)) {
+			if (!archive(vg)) {
 				stack;
 				return ECMD_FAILED;
 			}
-			archived = 1;
 			if (!_vgchange_args[i].fn(cmd, vg)) {
 				stack;
 				return ECMD_FAILED;
@@ -477,7 +475,7 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 		}
 	}
 
-	if (archived) {
+	if (vg_is_archived(vg)) {
 		if (!vg_write(vg) || !vg_commit(vg)) {
 			stack;
 			return ECMD_FAILED;


