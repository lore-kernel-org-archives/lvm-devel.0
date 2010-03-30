From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 30 Mar 2010 17:17:21 +0200
Subject: [PATCH 20/22] Replicator: activate change for vgchange
In-Reply-To: <cover.1269961680.git.zkabelac@redhat.com>
References: <cover.1269961680.git.zkabelac@redhat.com>
Message-ID: <3551b58d93e99c5ab6bef48ba2cc7424ac339b11.1269961680.git.zkabelac@redhat.com>
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
index 68fac86..139a1a5 100644
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
1.7.0.1


