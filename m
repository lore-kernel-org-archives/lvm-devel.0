From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  5 Oct 2009 16:00:37 +0200
Subject: [PATCH 10/13] Replicator: activate change for vgchange
In-Reply-To: <1254751240-17431-9-git-send-email-zkabelac@redhat.com>
References: <1254751240-17431-1-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-2-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-3-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-4-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-5-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-6-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-7-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-8-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-9-git-send-email-zkabelac@redhat.com>
Message-ID: <1254751240-17431-10-git-send-email-zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Activate only replicator-dev segment. Activation of one segment will
activivate also all other related heads.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/vgchange.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 07d5262..78660be 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -69,6 +69,11 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd,
 		if ((lv->status & MIRROR_IMAGE) || (lv->status & MIRROR_LOG))
 			continue;
 
+		/* Only request activation of replicator device LV */
+		if (lv_is_rlog(lv) || lv_is_slog(lv) || lv_is_rimage(lv) ||
+		    lv_is_replicator(lv))
+			continue;
+
 		/* Can't deactivate a pvmove LV */
 		/* FIXME There needs to be a controlled way of doing this */
 		if (((activate == CHANGE_AN) || (activate == CHANGE_ALN)) &&
-- 
1.6.5.rc2


