From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 13 Jan 2010 14:42:18 +0100
Subject: [PATCH 14/18] Replicator: activate change for vgchange
In-Reply-To: <cover.1263389894.git.zkabelac@redhat.com>
References: <cover.1263389894.git.zkabelac@redhat.com>
Message-ID: <ba7aa934633ede9db1983f4e67e39892a7005c00.1263389894.git.zkabelac@redhat.com>
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
index 068f12b..48cc4b5 100644
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
1.6.6


