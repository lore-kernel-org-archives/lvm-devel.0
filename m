From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 29 Jun 2010 18:26:02 +0200
Subject: [PATCH 02/12] Replicator: check for active replicator
In-Reply-To: <cover.1277828149.git.zkabelac@redhat.com>
References: <cover.1277828149.git.zkabelac@redhat.com>
Message-ID: <f894bd252ba537f593cbaeb09bc08f0595e89141.1277828149.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Skip activation of other heads only for a active replicator.
For inactive active all heads with linear overlay mapping

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/vgchange.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 1d3e321..5a9edd8 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -106,7 +106,7 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd,
 
 		/* Only request activation of the first replicator-dev LV */
 		/* Avoids retry with all heads in case of failure */
-		if (lv_is_replicator_dev(lv) && (lv != first_replicator_dev(lv)))
+		if (lv_is_active_replicator_dev(lv) && (lv != first_replicator_dev(lv)))
 			continue;
 
 		/* Can't deactivate a pvmove LV */
-- 
1.7.1


