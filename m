From: okozina <okozina@fedoraproject.org>
Date: Wed, 22 Jul 2015 10:30:08 +0000 (UTC)
Subject: master - lvconvert: retain retcode consistency
Message-ID: <20150722103008.056EA605B1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=03762f42c18812b95c550fefcdf531e0ff2f78b0
Commit:        03762f42c18812b95c550fefcdf531e0ff2f78b0
Parent:        ae88bf03a1d109a342a8ad31196c3ef8fa1a5b65
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Wed Jul 22 12:26:28 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Wed Jul 22 12:26:46 2015 +0200

lvconvert: retain retcode consistency

Always return the highest retcode caught during convert command
(regression in commit ae88bf03a1d109a342a8ad31196c3ef8fa1a5b65).
Also minor code cleanup.
---
 tools/lvconvert.c |   26 ++++++++++++--------------
 1 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 58428b7..d979e84 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3367,7 +3367,7 @@ static struct convert_poll_id_list* _convert_poll_id_list_create(struct cmd_cont
 
 	if (!(idl->id = _create_id(cmd, lv->vg->name, lv->name, lv->lvid.s))) {
 		dm_pool_free(cmd->mem, idl);
-		return NULL;
+		return_NULL;
 	}
 
 	idl->is_merging_origin = lv_is_merging_origin(lv);
@@ -3391,11 +3391,9 @@ static int _convert_and_add_to_poll_list(struct cmd_context *cmd,
 		if (!lv_info(cmd, lp->lv_to_poll, 0, &info, 0, 0) || !info.exists)
 			log_print_unless_silent("Conversion starts after activation.");
 		else {
-			idl = _convert_poll_id_list_create(cmd, lp->lv_to_poll);
-			if (!idl)
+			if (!(idl = _convert_poll_id_list_create(cmd, lp->lv_to_poll)))
 				return_ECMD_FAILED;
-			else
-				dm_list_add(&lp->idls, &idl->list);
+			dm_list_add(&lp->idls, &idl->list);
 		}
 	}
 
@@ -3490,21 +3488,21 @@ static int _lvconvert_merge_single(struct cmd_context *cmd, struct logical_volum
 
 int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 {
-	int ret;
+	int poll_ret, ret;
 	struct convert_poll_id_list *idl;
 	struct lvconvert_params lp = {
 		.target_attr = ~0,
 	};
 	struct processing_handle *handle = NULL;
 
+	dm_list_init(&lp.idls);
+
 	if (!(handle = init_processing_handle(cmd))) {
 		log_error("Failed to initialize processing handle.");
 		ret = ECMD_FAILED;
 		goto out;
 	}
 
-	dm_list_init(&lp.idls);
-
 	handle->custom_handle = &lp;
 
 	if (!_read_params(cmd, argc, argv, &lp)) {
@@ -3519,12 +3517,12 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 		ret = lvconvert_single(cmd, &lp);
 
 	dm_list_iterate_items(idl, &lp.idls) {
-		ret = _lvconvert_poll_by_id(cmd, idl->id,
-					    lp.wait_completion ? 0 : 1U,
-					    idl->is_merging_origin,
-					    idl->is_merging_origin_thin);
-		if (ret != ECMD_PROCESSED)
-			goto out;
+		poll_ret = _lvconvert_poll_by_id(cmd, idl->id,
+						 lp.wait_completion ? 0 : 1U,
+						 idl->is_merging_origin,
+						 idl->is_merging_origin_thin);
+		if (poll_ret > ret)
+			ret = poll_ret;
 	}
 
 out:


