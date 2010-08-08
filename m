From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:57:16 +0200
Subject: [PATCH 04/25] Replicator: check for active replicator
In-Reply-To: <cover.1281256234.git.zkabelac@redhat.com>
References: <cover.1281256234.git.zkabelac@redhat.com>
Message-ID: <fb3955f34e0dc4adc1e2f81a6885c7449aec2713.1281256235.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Skip activation of other heads only for a active replicator.
For inactive active all heads with linear overlay mapping

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/vgchange.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 960d8dd..a3a0155 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -104,9 +104,9 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd,
 		if ((lv->status & MIRROR_IMAGE) || (lv->status & MIRROR_LOG))
 			continue;
 
-		/* Only request activation of the first replicator-dev LV */
-		/* Avoids retry with all heads in case of failure */
-		if (lv_is_replicator_dev(lv) && (lv != first_replicator_dev(lv)))
+		/* Only request activation of the first replicated LV */
+		/* Avoids retry with all heads in case of some failure */
+		if (lv_is_active_replicated(lv) && (lv != first_replicated(lv)))
 			continue;
 
 		/* Can't deactivate a pvmove LV */
-- 
1.7.2.1


