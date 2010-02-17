From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 17 Feb 2010 12:28:58 -0500
Subject: [PATCH 2/8] Refactor vgcreate to call new vg_change_tag() function.
In-Reply-To: <1266427744-30327-2-git-send-email-dwysocha@redhat.com>
References: <1266427744-30327-1-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1266427744-30327-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/vgcreate.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 5113b1f..6087145 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -94,16 +94,8 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 			goto bad;
 		}
 
-		if (!(vg->fid->fmt->features & FMT_TAGS)) {
-			log_error("Volume group format does not support tags");
-			goto bad;
-		}
-
-		if (!str_list_add(cmd->mem, &vg->tags, tag)) {
-			log_error("Failed to add tag %s to volume group %s",
-				  tag, vp_new.vg_name);
-			goto bad;
-		}
+		if (!vg_change_tag(vg, tag, 1))
+			goto_bad;
 	}
 
 	if (vg_is_clustered(vg)) {
-- 
1.6.0.6


