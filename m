From: Milan Broz <mbroz@redhat.com>
Date: Sat, 23 Jan 2010 21:58:46 +0100
Subject: [PATCH 4/6] [RFC] Always query device by uuid only in activation calls.
In-Reply-To: <1264280328-8728-1-git-send-email-mbroz@redhat.com>
References: <1264280328-8728-1-git-send-email-mbroz@redhat.com>
Message-ID: <1264280328-8728-4-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvm2 devices have always UUID set even if imported from lvm1 metadata.

Why not use query by UUID only always?
---
 lib/activate/activate.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 433c8cc..83d363a 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -453,7 +453,7 @@ static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv, in
 	    !(name = build_dm_name(cmd->mem, lv->vg->name, lv->name, NULL)))
 		return_0;
 
-	log_debug("Getting device info for %s", name);
+	log_debug("Getting device info for %s/%s", lv->vg->name, lv->name);
 	if (!dev_manager_info(lv->vg->cmd->mem, name, lv, with_mknodes,
 			      with_open_count, with_read_ahead, &dminfo,
 			      &info->read_ahead)) {
@@ -480,7 +480,7 @@ static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv, in
 int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, struct lvinfo *info,
 	    int with_open_count, int with_read_ahead)
 {
-	return _lv_info(cmd, lv, 0, info, with_open_count, with_read_ahead, 0);
+	return _lv_info(cmd, lv, 0, info, with_open_count, with_read_ahead, 1);
 }
 
 int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s,
-- 
1.6.6


