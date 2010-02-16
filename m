From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 16 Feb 2010 14:39:44 -0500
Subject: [PATCH 2/7] Refactor vgcreate to call new vg_change_tag() function.
In-Reply-To: <1266349189-23166-2-git-send-email-dwysocha@redhat.com>
References: <1266349189-23166-1-git-send-email-dwysocha@redhat.com>
	<1266349189-23166-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1266349189-23166-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/vgcreate.c |   10 +---------
 1 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 5113b1f..75440c2 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -94,16 +94,8 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 			goto bad;
 		}
 
-		if (!(vg->fid->fmt->features & FMT_TAGS)) {
-			log_error("Volume group format does not support tags");
+		if (!vg_change_tag(vg, tag, 1))
 			goto bad;
-		}
-
-		if (!str_list_add(cmd->mem, &vg->tags, tag)) {
-			log_error("Failed to add tag %s to volume group %s",
-				  tag, vp_new.vg_name);
-			goto bad;
-		}
 	}
 
 	if (vg_is_clustered(vg)) {
-- 
1.6.0.6


