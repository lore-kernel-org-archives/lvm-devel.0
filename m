From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  7 Jul 2010 14:34:38 +0200
Subject: [PATCH 04/22] Replicator: check for active replicator
In-Reply-To: <cover.1278505885.git.zkabelac@redhat.com>
References: <cover.1278505885.git.zkabelac@redhat.com>
Message-ID: <8bb5de6b8a6459c2bc293fa14e22cd73819d941b.1278505885.git.zkabelac@redhat.com>
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
index ed5a7ef..840552a 100644
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
1.7.1.1


