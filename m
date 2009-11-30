From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 30 Nov 2009 12:37:19 +0100
Subject: [PATCH 19/23] Replicator: activate change for vgchange
In-Reply-To: <1259581043-15308-19-git-send-email-zkabelac@redhat.com>
References: <1259581043-15308-1-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-2-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-3-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-4-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-5-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-6-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-7-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-8-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-9-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-10-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-11-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-12-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-13-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-14-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-15-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-16-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-17-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-18-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-19-git-send-email-zkabelac@redhat.com>
Message-ID: <1259581043-15308-20-git-send-email-zkabelac@redhat.com>
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
index 3a4ceca..c224633 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -72,6 +72,10 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd,
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
1.6.5.3


