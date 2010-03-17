From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 17 Mar 2010 14:47:09 +0100
Subject: [PATCH 16/25] Replicator: vg with missing_vgs does not print
In-Reply-To: <cover.1268833246.git.zkabelac@redhat.com>
References: <cover.1268833246.git.zkabelac@redhat.com>
Message-ID: <181d3f6256a184fb85dfd1016ba67387fb81f4d7.1268833246.git.zkabelac@redhat.com>
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
index 6d869f9..4045411 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -224,8 +224,9 @@ static int _vgchange_available(struct cmd_context *cmd, struct volume_group *vg)
 
 	ret = _activate_lvs_in_vg(cmd, vg, available);
 
-	log_print("%d logical volume(s) in volume group \"%s\" now active",
-		  lvs_in_vg_activated(vg), vg->name);
+	if (!vg->missing_vgs)
+		log_print("%d logical volume(s) in volume group \"%s\" now active",
+			  lvs_in_vg_activated(vg), vg->name);
 	return ret;
 }
 
-- 
1.7.0.1


