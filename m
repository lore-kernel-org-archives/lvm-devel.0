From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 21 Jan 2016 12:29:50 +0000 (UTC)
Subject: master - toollib: use cmd mempool for list
Message-ID: <20160121122950.3C8E2614E8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c701d9cc8c9c559622c8ce27aa9c7f28169b4dfc
Commit:        c701d9cc8c9c559622c8ce27aa9c7f28169b4dfc
Parent:        fcbef05aae94f1fc5f91b2708d9dee22d883ca18
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 21 13:18:11 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 21 13:28:28 2016 +0100

toollib: use cmd mempool for list

When creating a list in 'context of command' - use proper mempool.

vg->vgmem is mempool related to VG metadata - and can be eventually
locked read-only when VG struct is shared.
---
 WHATS_NEW       |    1 +
 tools/toollib.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0a9e17a..fe1da46 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.141 - 
 ====================================
+  Use correct mempool when process_each_lv_in_vg() (2.02.118).
   Fix lvm.8 man to show again prohibited suffixes.
   Fix configure to set proper use_blkid_wiping if autodetected as disabled.
   Initialise udev in clvmd for use in device scanning. (2.02.116)
diff --git a/tools/toollib.c b/tools/toollib.c
index 400821e..e681afe 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2406,7 +2406,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 
 		log_very_verbose("Adding %s/%s to the list of LVs to be processed.", vg->name, lvl->lv->name);
 
-		if (!(final_lvl = dm_pool_zalloc(vg->vgmem, sizeof(struct lv_list)))) {
+		if (!(final_lvl = dm_pool_zalloc(cmd->mem, sizeof(struct lv_list)))) {
 			log_error("Failed to allocate final LV list item.");
 			ret_max = ECMD_FAILED;
 			goto_out;


