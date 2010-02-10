From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 10 Feb 2010 15:57:00 +0100
Subject: [PATCH 14/19] Replicator: activate change for vgchange
In-Reply-To: <cover.1265813098.git.zkabelac@redhat.com>
References: <cover.1265813098.git.zkabelac@redhat.com>
Message-ID: <1e72d0f82b1f3eb5b00631e043ace6041ef58d92.1265813098.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Activate only the first replicator-dev LV, that activates all other
related LVs from Replicator.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/vgchange.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 29d891b..7d8cf34 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -104,6 +104,10 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd,
 		if ((lv->status & MIRROR_IMAGE) || (lv->status & MIRROR_LOG))
 			continue;
 
+		/* Only request activation of the first replicator-dev LV */
+		if (lv_is_replicator_dev(lv) && (lv != first_replicator_dev(lv)))
+			continue;
+
 		/* Can't deactivate a pvmove LV */
 		/* FIXME There needs to be a controlled way of doing this */
 		if (((activate == CHANGE_AN) || (activate == CHANGE_ALN)) &&
-- 
1.6.6.1


