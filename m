From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 23:19:37 +0000 (GMT)
Subject: main - debug: display_lvname
Message-ID: <20210310231937.62D133857C5E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2cbe88d6a1e9e6f637ee1b5ccdc7b78712d46998
Commit:        2cbe88d6a1e9e6f637ee1b5ccdc7b78712d46998
Parent:        a654148b76c71022997c3ea509b52354985b8d7f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 10 22:05:10 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 11 00:18:01 2021 +0100

debug: display_lvname

---
 tools/toollib.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index f60847b48..a8bda8bcd 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3074,7 +3074,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		if (!process_lv)
 			continue;
 
-		log_very_verbose("Adding %s/%s to the list of LVs to be processed.", vg->name, lvl->lv->name);
+		log_very_verbose("Adding %s to the list of LVs to be processed.", display_lvname(lvl->lv));
 
 		if (!(final_lvl = dm_pool_zalloc(cmd->mem, sizeof(struct lv_list)))) {
 			log_error("Failed to allocate final LV list item.");


