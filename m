From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 25 Feb 2016 22:36:21 +0000 (UTC)
Subject: master - lvconvert: simplify handler processing
Message-ID: <20160225223621.C07CE60AA6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=86a651854f136b780d30e43a58c2390fa0d05e97
Commit:        86a651854f136b780d30e43a58c2390fa0d05e97
Parent:        abd9618dd8b77ca1974074ae76fa6a08f1a687d9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 25 12:15:26 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 25 23:30:25 2016 +0100

lvconvert: simplify handler processing

Easier code for handler init.
Drop release of pool mem - not needed, as command pool get dropped just
later.
---
 tools/lvconvert.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 3ec6d59..7fba48d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3503,15 +3503,13 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 	struct convert_poll_id_list *idl;
 	struct lvconvert_params lp = {
 		.target_attr = ~0,
+		.idls = DM_LIST_HEAD_INIT(lp.idls),
 	};
-	struct processing_handle *handle = NULL;
+	struct processing_handle *handle = init_processing_handle(cmd);
 
-	dm_list_init(&lp.idls);
-
-	if (!(handle = init_processing_handle(cmd))) {
+	if (!handle) {
 		log_error("Failed to initialize processing handle.");
-		ret = ECMD_FAILED;
-		goto out;
+		return ECMD_FAILED;
 	}
 
 	handle->custom_handle = &lp;
@@ -3537,10 +3535,10 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 	}
 
 out:
-	if (!dm_list_empty(&lp.idls))
-		dm_pool_free(cmd->mem, dm_list_item(dm_list_first(&lp.idls), struct convert_poll_id_list));
 	if (lp.policy_settings)
 		dm_config_destroy(lp.policy_settings);
+
 	destroy_processing_handle(cmd, handle);
+
 	return ret;
 }


