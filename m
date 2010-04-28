From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Apr 2010 14:36:14 +0200
Subject: [PATCH 18/23] Replicator: vg with cmd_missing_vgs does not print
In-Reply-To: <cover.1272457502.git.zkabelac@redhat.com>
References: <cover.1272457502.git.zkabelac@redhat.com>
Message-ID: <6f7f28706772986169f616a0da21b7120e065361.1272457502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If missed VGs do not print message and wait for retry.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/vgchange.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 81c95d1..ff2cdd8 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -224,8 +224,9 @@ static int _vgchange_available(struct cmd_context *cmd, struct volume_group *vg)
 
 	ret = _activate_lvs_in_vg(cmd, vg, available);
 
-	log_print("%d logical volume(s) in volume group \"%s\" now active",
-		  lvs_in_vg_activated(vg), vg->name);
+	if (!vg->cmd_missing_vgs)
+		log_print("%d logical volume(s) in volume group \"%s\" now active",
+			  lvs_in_vg_activated(vg), vg->name);
 	return ret;
 }
 
-- 
1.7.0.1


